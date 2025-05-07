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

-- modules
local stream = import('stream.lua')
local cursor = import('cursor.lua')

-- instances
--local SerdesModules: Folder = script:WaitForChild("serdes")

-- types
export type SerializerType = "InstanceTree"

type serializable = any;

type SerializerHandler = (obj: serializable) -> string
type DeserializerHandler = (src: cursor) -> serializable

type SerdesHandler = {
	serialize: SerializerHandler;
	deserialize: DeserializerHandler;
}

-- enums
local E = {}

E.FILE_HEADER = 'COFT'

E.VERSION_1 = 1
E.VERSION_2 = 2
E.VERSION_3 = 3

-- caches / lookups
local serdesModuleCache: {[string]: SerdesHandler} = {}
local function getCachedSerdes(ver: string, name: string)
	local serdes: SerdesHandler = serdesModuleCache[name..ver]
	if not serdes then
		serdes, e = import('coft/v'..ver..'/'..name..'.lua')
		assert(serdes, e)
		
		--local versionFolder: Folder = SerdesModules:WaitForChild(ver, 1) :: Folder
		--assert(versionFolder, `no such version as {ver}`)
		--assert(versionFolder:IsA("Folder"), `{ver} is not a folder`)

		--assert(name, "no serdes name provided")
		--assert(type(name)=="string", "serdes name provided is not a string")

		--local serializerModule: ModuleScript = versionFolder:WaitForChild(name, 1) :: ModuleScript
		--assert(serializerModule, `couldn't find serdes "{name}" in {versionFolder:GetFullName()}`)
		--assert(serializerModule:IsA("ModuleScript"), `instance {serializerModule:GetFullName()} is not a ModuleScript; did you tinker with the dependencies under the module?`)

		--serdes = require(serializerModule) :: SerdesHandler

		--assert(type(serdes)=='table', `serdes {serializerModule:GetFullName()} did not return a function dictionary with serialize`)
		--assert(serdes.serialize, `serdes {serializerModule:GetFullName()} has no serialize function`)

		--serdesModuleCache[name..ver] = serdes
	end
	return serdes
end

-- main
local module = {ENUM=E}

function module.serialize(obj: Instance, version: number, serializerType: SerializerType | string): string
	assert(serializerType, "no serializer type provided")
	assert(type(serializerType)=="string", "serializer type provided is not a string")

	local serdes: SerdesHandler = getCachedSerdes('v'..tostring(version), serializerType)

	return serdes.serialize(obj)
end

function module.deserialize(source: buffer): any
	-- in the deserializer, the version will be fetched from the COFT file itself in the header

	local sourceCursor = cursor(source)

	local header = sourceCursor:c(4)

	assert(header == E.FILE_HEADER, "the provided COFT has an invalid header")

	local version = sourceCursor:readu16()
	local serializerType = sourceCursor:readblocks()

	local serdes: SerdesHandler = getCachedSerdes('v'..tostring(version), serializerType)

	return serdes.deserialize(sourceCursor)
end

return module
