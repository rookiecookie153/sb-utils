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

local lz4 = import('lz4.lua')

local Cursor = {}
Cursor.__index = Cursor

--[[
undocumented
]]--
local function NewCursor(buf: buffer)
	local self = {}

	self.pos = 0
	self.len = buffer.len(buf)
	self.buf = buf

	return setmetatable(self, Cursor)
end

export type cursor = typeof(NewCursor(buffer.create(1)))

--[[
undocumented
]]--
function Cursor:shift(amount: number?)
	self.pos += amount or 1
	return self
end

--[[
Reads the specified count of bytes from the cursor's current position and advances the cursor by that amount.
If count is not provided, it will read 1 byte.
]]--
function Cursor:c(count: number?)
	if count then
		local s = buffer.readstring(self.buf, self.pos, count)
		self.pos += count
		return s
	end
	return string.char(self:readu8())
end

--[[
undocumented
]]--
function Cursor:readblocks(): string
	local r = ''
	while true do
		local blockSize = self()
		if blockSize == 0 then break end
		r ..= self:c(blockSize)
	end
	return r
end

--[[
undocumented
]]--
function Cursor:readlz4(): string
	local data = self:readblocks()
	data = lz4.decompress(data)
	return data
end

--[[
undocumented
]]--
function Cursor:readlz4tocursor(): cursor
	return NewCursor(buffer.fromstring(self:readlz4()))
end

--[[
undocumented
]]--
function Cursor:readu8()
	local b = buffer.readu8(self.buf, self.pos)
	self:shift()
	return b
end

--[[
undocumented
]]--
function Cursor:readu16()
	local b = buffer.readu16(self.buf, self.pos)
	self:shift(2)
	return b
end

--[[
undocumented
]]--
function Cursor:readu32()
	local b = buffer.readu32(self.buf, self.pos)
	self:shift(4)
	return b
end

--[[
undocumented
]]--
function Cursor:readi8()
	local b = buffer.readi8(self.buf, self.pos)
	self:shift()
	return b
end

--[[
undocumented
]]--
function Cursor:readi16()
	local b = buffer.readi16(self.buf, self.pos)
	self:shift(2)
	return b
end

--[[
undocumented
]]--
function Cursor:readi32()
	local b = buffer.readi32(self.buf, self.pos)
	self:shift(4)
	return b
end

--[[
undocumented
]]--
function Cursor:readu32_leb128()
	local result = 0
	local shift = 0
	
	while true do
		local byte = self()
		result = bit32.bor(result, bit32.lshift(bit32.band(byte, 0x7F), shift))
		if bit32.band(byte, 0x80) == 0 then break end
		shift = shift + 7
	end
	
	return result
end

--[[
undocumented
]]--
function Cursor:readi32_leb128()
	local result = 0
	local shift = 0
	
	while true do
		local byte = self()
		
		result = bit32.bor(
			result,
			bit32.lshift(
				bit32.band(byte, 0x7f),
				shift
			)
		)
		
		shift += 7
		
		if bit32.band(byte, 0x80) == 0 then
			if shift < 32 and bit32.band(byte, 0x40) ~= 0 then
				result = bit32.bor(result, bit32.lshift(0, shift))
			end
			break
		end
	end
	
	return result
end

--[[
undocumented
]]--
function Cursor:readf32()
	local b = buffer.readf32(self.buf, self.pos)
	self:shift(4)
	return b
end

--[[
undocumented
]]--
function Cursor:readf64()
	local b = buffer.readf64(self.buf, self.pos)
	self:shift(4)
	return b
end

--[[
undocumented
]]--
function Cursor:__call()
	return self:readu8()
end

return NewCursor
