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

local serialize = import('coft/v2/serialize.lua')
local deserialize = import('coft/v2/deserialize.lua')

return table.freeze {
	serialize = serialize;
	deserialize = deserialize;
}
