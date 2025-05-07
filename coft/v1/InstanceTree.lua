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

local serialize = import('coft/v1/serialize.lua')
local deserialize = import('coft/v1/deserialize.lua')

return table.freeze {
	serialize = serialize;
	deserialize = deserialize;
}
