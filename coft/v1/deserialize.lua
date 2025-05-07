local import: (file: string) -> any
do
	local http = game:GetService("HttpService")
	local BASE_IMPORT_URL = "https://raw.githubusercontent.com/rookiecookie153/sb-utils/refs/heads/main/%s"
	import = function(file: string)
		local data = http:GetAsync(string.format(BASE_IMPORT_URL, file), true)
		local load, e = loadstring(data)
		if not load then
			error(e)
			return
		end
		return load()
	end
end

-- const
local SERDES_DEBUG_ENABLED = shared.SERDES_DEBUG_ENABLED

local emptyfunction = function() end

local debugw = SERDES_DEBUG_ENABLED and function()
	task.wait()
end or emptyfunction

local print = SERDES_DEBUG_ENABLED and function(...)
	print(...)
end or emptyfunction

-- local lib
local TypeSerdes = import('coft/v1/typeserdes.lua')
local const = import('coft/v1/enum.lua')

-- lib
local lz4 = import('lz4.lua')
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
			local dynamicGraph = graph:readlz4tocursor()
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
			local instanceIdGraph = graph:readlz4tocursor()
			while instanceIdGraph.pos < instanceIdGraph.len do
				local instanceId = instanceIdGraph:readu16()
				local className = instanceIdGraph:readblocks()
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
			local instanceTreeGraph = graph:readlz4tocursor()
			while instanceTreeGraph.pos < instanceTreeGraph.len do
				debugw()
				local instanceId = instanceTreeGraph:readu16()
				local obj = lookup.instanceIds[instanceId] :: Instance
				
				print('parsing properties of a', obj.ClassName)
				
				while true do
					debugw()
					local propertyNameIndex = instanceTreeGraph:readu16()
					local propertyName = lookup.dynamicClasses[propertyNameIndex]
					
					if propertyNameIndex == const.SECTIONS.NULL then
						print('null reached; breaking')
						break
					end
					
					local valueTypeIndex = instanceTreeGraph:readu16()
					local valueType = lookup.dynamicClasses[valueTypeIndex]
					
					if not valueType then
						error(`could not find type name at lookup index {valueTypeIndex}, cannot resume deserialization`)
					end
					
					local typeDeserializer = TypeSerdes.Decode[valueType]
					if not typeDeserializer then
						error(`could not find deserializer for {valueType}; cannot resume deserialization`)
					end
					
					-- cry about it typechecker
					local value = typeDeserializer(instanceTreeGraph, lookup)
					
					if not propertyName then
						warn(`could not find property name at lookup index {propertyNameIndex}, skipping this property`)
					end
					
					local s, e = pcall(function()
						print('set',propertyName,'to',value)
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
						warn(e)
					end
				end
			end
			continue
		end
		
		if sectionType == const.SECTIONS.TERMINATE then
			print('terminate signal received')
			break
		end
		
		error(string.format('invalid section type: %x', sectionType))
	end
	
	return lookup.instanceIds[1]
end
