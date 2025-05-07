-- import from sb-utils
local import: (file: string) -> any
do
	local cache = shared.import153cache
	if not cache then
		cache = {}
		shared.import153cache = cache
	end
	
	local http = game:GetService("HttpService")
	local BASE_IMPORT_URL = "https://raw.githubusercontent.com/rookiecookie153/sb-utils/refs/heads/main/%s"
	import = function(file: string)
		local data = cache[file]
		if data then
			return data
		end
		
		data = http:GetAsync(string.format(BASE_IMPORT_URL, file), true)
		local load, e = loadstring(data)
		if not load then
			error(e)
			return
		end
		data = load()
		cache[file] = data
		
		return data
	end
end

local RunService = game:GetService("RunService")
local LogService = game:GetService("LogService")

-- const
local SERDES_DEBUG_ENABLED = shared.SERDES_DEBUG_ENABLED
local INSTANCE_TREE_SPLITUP = 0xfffff

local emptyfunction = function() end

local debugw = SERDES_DEBUG_ENABLED and function()
	task.wait()
end or emptyfunction

local print = SERDES_DEBUG_ENABLED and function(...)
	print(...)
end or emptyfunction

local clear = SERDES_DEBUG_ENABLED and function(...)
	LogService:ClearOutput()
end or emptyfunction

-- local lib
local TypeSerdes = import('coft/v2/typeserdes.lua')
local const = import('coft/v2/enum.lua')

-- lib
local compression = import('compression.lua')
local properties = import('properties.lua')
local lookup = import('lookup.lua')
local stream = import('stream.lua')

-- idek anymore
local function genericIdLookup(lookup: lookup, obj: any): number
	lookup.id += 1
	return lookup.id
end

local function propertyLookup(lookup: lookup, className: string): {string}
	print('performing property lookup on',className)
	local props = properties.GetProperties(className)
	print('finished property lookup; caching')
	return props
end

local ignoreProperty = {
	"BrickColor",
	--"Position",
	--"Orientation",
	"PivotOffset"
}

-- ok
return function(serializable: Instance): string
	serializable.Archivable = true
	
	local tmpClone = serializable:Clone()
	local f = Instance.new("Folder")
	f.Name = "COFT_EXPORT"
	tmpClone.Parent = f
	
	serializable = tmpClone
	
	local graph = stream(0xffffff)
	
	-- write header stuff
	graph:writestring("COFT") 			  -- COFT header
	graph:writeu16(2) 					  -- version #
	graph:writeblocks(script.Parent.Name) -- serdes type
	
	-- start parsing instances
	local lookup = {
		instanceIds = lookup(genericIdLookup),
		dynamicClasses = lookup(genericIdLookup),
		properties = lookup(propertyLookup);
	}
	
	lookup.instanceIds(serializable.Parent)
	
	local propertyDatas = {}
	
	do -- put in a (do end) to delete propertygraph after execution of this scope
		print('starting property serialization')
		
		local toserialize = serializable:GetDescendants()
		table.sort(toserialize, function(a,b)
			return a.Name < b.Name
		end)
		table.insert(toserialize, 1, serializable)
		
		local instanceCount = #toserialize
		
		local serializeGroupCount = math.ceil(#toserialize/INSTANCE_TREE_SPLITUP)
		local serializeGroup = {}
		for i = 1, serializeGroupCount do
			local start =  (i-1)*INSTANCE_TREE_SPLITUP+1
			local goal = math.min(i*INSTANCE_TREE_SPLITUP, #toserialize)
			
			table.clear(serializeGroup)
			table.move(toserialize, start, goal, 1, serializeGroup)
			
			do
				local propertygraph = stream()

				for i, obj: Instance in serializeGroup do

					print('serializing', obj:GetFullName())

					local instanceId = lookup.instanceIds(obj) :: number

					propertygraph:writeu16(instanceId)

					local props = lookup.properties(obj.ClassName) :: {string}
					if not props then
						warn(`Properties+ did not return the properties of ClassName {obj.ClassName}; Skipping {obj:GetFullName()}`)
						propertygraph:writeu16(const.SECTIONS.NULL)
						continue
					end
					
					for _, name in pairs(props) do

						if table.find(ignoreProperty, name) then
							print('|  ignoring property', name)
							continue
						end

						--if not obj:IsPropertyModified(name) then continue end
						local value
						local s, e = pcall(function()
							value = obj[name]
						end)
						if not s then
							warn(e)
							continue
						end
						if value == nil then
							if SERDES_DEBUG_ENABLED then
								warn(`|  property "{name}" of {obj:GetFullName()} is nil`)
							end
							continue
						end
						
						local valuetype = typeof(value)

						local typeSerializerHandler = TypeSerdes.Encode[valuetype]
						if not typeSerializerHandler then
							warn(`|  could not serialize type {valuetype}; skipping`)
							continue
						end
						
						local nameIndex = lookup.dynamicClasses(name) :: number
						propertygraph:writeu16(nameIndex)
						
						local valuetypeIndex = lookup.dynamicClasses(valuetype) :: number
						propertygraph:writeu16(valuetypeIndex)

						typeSerializerHandler(propertygraph, value, lookup)

						print('|  serialized', `{name}<{valuetype}>`)
					end

					-- stop checking properties for this instance
					propertygraph:writeu16(const.SECTIONS.NULL)
				end

				table.insert(propertyDatas, propertygraph:export())
			end

			warn(`serialized group of instances ({#serializeGroup})`)
			
			debugw()
		end
		
		print(`finished property serialization for all instance groups ({serializeGroupCount} total groups)`)
	end
	
	-- start writing to the main graph
	graph:writeu8(const.SECTIONS.DYNAMIC_CLASSES)
	
	local dynamicdata
	do
		local dynamicgraph = stream()
		for name: string, index: number in pairs(lookup.dynamicClasses.entries) do
			dynamicgraph:writeu16(index)
			dynamicgraph:writeblocks(name)
		end
		dynamicdata = dynamicgraph:export()
	end
	graph:writeblocks(compression.Deflate.Compress(dynamicdata))
	
	graph:writeu8(const.SECTIONS.INSTANCE_IDS)
	
	
	
	
	
	
	--for obj: Instance, index: number in pairs(lookup.instanceIds.entries) do
	--	graph:writeu16(index)
	--	graph:writeblocks(obj.ClassName)
	--end
	
	local instanceIdData
	do
		local instanceidgraph = stream()
		
		-- the main idea is that when we're decoding, instances
		-- may be referenced in properties of other instances.
		-- for example, parent

		-- having the instances created *beforehand* prevents any
		-- errors relating to instance references in properties.

		-- this is a BIG fix for a bug with BoneMeal too
		for obj: Instance, index: number in pairs(lookup.instanceIds.entries) do
			instanceidgraph:writeu16(index)
			instanceidgraph:writeblocks(obj.ClassName)
		end
		
		instanceIdData = instanceidgraph:export()
	end
	graph:writeblocks(compression.Deflate.Compress(instanceIdData))	
	
	
	
	
	
	
	for i, propertyData in propertyDatas do
		print('serializing tree', i)
		graph:writeu8(const.SECTIONS.INSTANCE_TREE)
		graph:writeblocks(compression.Deflate.Compress(propertyData))
	end
	
	graph:writeu8(const.SECTIONS.TERMINATE)
	
	serializable:Destroy()
	
	local exp = graph:export()
	
	print('graph size:', #exp)
	
	return exp
end
