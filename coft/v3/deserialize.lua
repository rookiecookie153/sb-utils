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

-- const
local SERDES_DEBUG_ENABLED = shared.SERDES_DEBUG_ENABLED

local emptyfunction = function() end

local debugw = SERDES_DEBUG_ENABLED and function()
	task.wait()
end or emptyfunction

if not SERDES_DEBUG_ENABLED then
	print = emptyfunction
end
--local print = SERDES_DEBUG_ENABLED and print or emptyfunction

-- local lib
local SpecialCase = import('coft/v3/specialcase.lua')
local TypeSerdes = import('coft/v3/typeserdes.lua')
local const = import('coft/v3/enum.lua')

-- lib
local compression = import('compression.lua')
local properties = import('properties.lua')
local lookup = import('lookup.lua')
local cursor = import('cursor.lua')

-- idek anymore

-- ok
return function(graph: cursor)
	local lookup = {
		instanceIds = {};
		dynamicClasses = {};
	}
	
	while true do
		debugw()
		
		print('reading next section')
		local sectionType = graph:readu8()
		
		if sectionType == const.SECTIONS.DYNAMIC_CLASSES then
			print('parsing dynamic classes')
			local dynamicGraph = cursor(buffer.fromstring(compression.Zlib.Decompress(graph:readblocks())))
			while dynamicGraph.pos < dynamicGraph.len do
				debugw()
				local index = dynamicGraph:readu16()
				local name = dynamicGraph:readblocks()
				lookup.dynamicClasses[index] = name
			end
			continue
		end
		
		if sectionType == const.SECTIONS.INSTANCE_IDS then
			print('parsing instance ids')
			local instanceIdGraph = cursor(buffer.fromstring(compression.Deflate.Decompress(graph:readblocks())))
			while instanceIdGraph.pos < instanceIdGraph.len do
				local instanceId = instanceIdGraph:readu16()
				
				print(lookup.dynamicClasses)
				
				local classNameIndex = instanceIdGraph:readu16()
				local className = lookup.dynamicClasses[classNameIndex]
				
				local obj = Instance.new(className)
				--if obj:IsA("BasePart") then
				--	obj.Anchored = true
				--end
				--obj.Parent = workspace.t
				lookup.instanceIds[instanceId] = obj
			end
			continue
		end
		
		if sectionType == const.SECTIONS.INSTANCE_TREE then
			print('parsing instance tree')
			local instanceTreeGraph = cursor(buffer.fromstring(compression.Deflate.Decompress(graph:readblocks())))
			while instanceTreeGraph.pos < instanceTreeGraph.len do
				debugw()
				local instanceId = instanceTreeGraph:readu16()
				local obj = lookup.instanceIds[instanceId] :: Instance
				
				print('parsing properties of a', obj.ClassName)
				
				local matchingSpecialCase: SpecialCase = SpecialCase[obj.ClassName]
				local caseProps = {}
				if matchingSpecialCase then
					print('found special case for said instance')
				end
				
				while true do
					debugw()
					local propertyNameIndex = instanceTreeGraph:readu16()
					local propertyName = lookup.dynamicClasses[propertyNameIndex]
					
					if propertyNameIndex == const.SECTIONS.NULL then
						print('|  received finish signal')
						break
					end
					
					local valueTypeIndex = instanceTreeGraph:readu16()
					local valueType = lookup.dynamicClasses[valueTypeIndex]
					
					if not valueType then
						error(`\ncould not find type name at lookup index {valueTypeIndex}, cannot resume deserialization\npropindex: {propertyNameIndex}\nproperty: {propertyName}`)
					end
					
					local typeDeserializer = TypeSerdes.Decode[valueType]
					if not typeDeserializer then
						error(`could not find deserializer for type "{valueType}"; cannot resume deserialization`)
						
						---- rare error...
						--typeDeserializer = TypeSerdes.Decode[propertyName]
						--if typeDeserializer then -- why the hell does this happen
						--	propertyName, valueType = valueType, propertyName
							
						--	warn(`[! weird bug ocurred here... property name swapped with the type`)
						--else
						--	error(`could not find deserializer for {valueType}; cannot resume deserialization`)
						--end
					end
					
					-- cry about it typechecker
					local value = typeDeserializer(instanceTreeGraph, lookup)
					
					if not propertyName then
						warn(`|  could not find property name at lookup index {propertyNameIndex}, skipping this property`)
					end
					
					if matchingSpecialCase and table.find(matchingSpecialCase.process, propertyName) then
						print('|  cached',propertyName,'to',value,'for special case')
						caseProps[propertyName] = value
						continue
					end
					
					local s, e = pcall(function()
						print('|  set',propertyName,'to',value)
						obj[propertyName] = value
						--local s2, e2 = pcall(function()
						--	game.TweenService:Create(
						--		obj,
						--		TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						--		{[propertyName] = value}
						--	):Play()
						--end)
						--if not s2 then
						--	obj[propertyName] = value
						--end
					end)
					
					if not s then
						warn(`[! {e}`)
					end
				end
				
				if matchingSpecialCase then
					matchingSpecialCase.callback(obj, caseProps)
				end
			end
			continue
		end
		
		if sectionType == const.SECTIONS.TERMINATE then
			print('terminate signal received')
			break
		end
		
		error(string.format('invalid section type: 0x%X', sectionType))
	end
	
	return lookup.instanceIds[1]
end
