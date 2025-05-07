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
--> Created all by loueque, thanks to RuizuKun_Dev and LucasMZ for finding spelling mistakes and suggestions. :thumbs_up:
--> Source of HTTP, credits to them with some modifications: https://scriptinghelpers.org/questions/50784/how-to-get-list-of-object-properties

local ParseException = import('propertyapi/ParseException.lua')

local HttpService = game:GetService("HttpService")
local IsAPILoaded, APILoaded = false, Instance.new("BindableEvent")

local function GetApiData()
	local retries = 0
	local sucess, data

	while retries <= 3 do
		sucess, data = pcall(
			HttpService.GetAsync, HttpService,
			"https://anaminus.github.io/rbx/json/api/latest.json"
		)

		if sucess then
			return HttpService:JSONDecode(data)
		end

		task.wait(3)
	end

	warn("[Properties+ Http Error]: ", data)
end

local Classes = {}

local function CreatePropertiesForClasses()
	local HttpData = GetApiData()

	if HttpData then
		for _, Table in ipairs(HttpData) do
			local Type = Table.type

			if Type == "Class" then
				local ClassData = {}

				local Superclass = Classes[Table.Superclass]

				if Superclass then
					for j = 1, #Superclass do
						ClassData[j] = Superclass[j]
					end
				end

				Classes[Table.Name] = ClassData
			elseif Type == "Property" then
				if not next(Table.tags) or table.find(ParseException, Table.Name) then
					local Class = Classes[Table.Class]
					local Property = Table.Name
					local Inserted = false

					for j = 1, #Class do
						if Property < Class[j] then
							Inserted = true
							table.insert(Class, j, Property)
							break
						end
					end

					if not Inserted then
						table.insert(Class, Property)
					end
				end
			end
		end

		IsAPILoaded = true
		APILoaded:Fire()

		APILoaded:Destroy()
		APILoaded = nil
	end
end

task.spawn(CreatePropertiesForClasses)

local Properties = {}
--Properties.__index = {}

--function Properties.new()
--	return setmetatable({}, Properties)
--end

-- local gp = script:WaitForChild("GetProperties")
function Properties.GetProperties(instance: string | any)
	if not IsAPILoaded then
		APILoaded.Event:Wait()
	end
	return Classes[tostring(instance)]
end

function Properties.ReadEnumerator(enum: Enum)
	return enum:GetEnumItems()
end

return Properties
