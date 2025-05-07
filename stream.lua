-- import from sb-utils
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

local RunService = game:GetService("RunService")
local UnsafeYield = import('unsafeyield.lua')

local DEFAULT_STREAM_SIZE = 0xffff
local DEBUG_STREAMS = false

if not shared.StreamsCreated then
	shared.StreamsCreated = 0
end

local emptyfunction = function() end

local warn = DEBUG_STREAMS and function(...)
	warn(...)
end or emptyfunction

local print = DEBUG_STREAMS and function(...)
	print(...)
end or emptyfunction

local Stream = {}
Stream.__index = Stream

local module = {}

local function NewStream(initialSize: number?)
	shared.StreamsCreated += 1
	
	local self = {}
	
	self._yield = UnsafeYield(50000)
	self._c = 0
	self._b = buffer.create(initialSize or DEFAULT_STREAM_SIZE)
	self._si = shared.StreamsCreated
	
	return setmetatable(self, Stream)
end
export type stream = typeof(NewStream())

function Stream.realloc(self: stream, size: number)
	RunService.Heartbeat:Wait()
	local new = buffer.create(size)
	buffer.copy(
		new,
		0,
		self._b,
		0,
		math.min(
			size,
			buffer.len(self._b)
		)
	)
	self._b = new
end

--[[
Shift the stream's cursor forward by the specified shift amount.
]]--
function Stream.__call(self: stream, shift: number?): number
	if DEBUG_STREAMS then
		RunService.Heartbeat:Wait()
	end
	if shift then
		self._c += shift
	end
	return self._c
end

--[[
undocumented
]]--
function Stream.checkalloc(self: stream, offset: number)
	local buflen = buffer.len(self._b)
	local maxindex = buflen - 1
	if offset > maxindex then
		warn(`the current buffer is too small ({buflen}) to index {offset}`)
		
		self:realloc(2^(math.ceil(math.log(buflen, 2))+1))
		warn('re-allocated to', buffer.len(self._b))
	end
end

--[[
undocumented
]]--
function Stream.checkshift(self: stream, offset: number)
	self:checkalloc(self._c + offset)
end

--[[
undocumented
]]--
@checked
function Stream.writestring(self: stream, s: string)
	print('writing string',s)
	self:checkshift(#s)
	buffer.writestring(self._b, self._c, s)
	self(#s)
end

--[[
undocumented
]]--
function Stream.writeblocks(self: stream, s: string)
	print('writing blocks', s)
	
	for _ = 1, math.ceil(#s/255) do
		local content = s:sub(1, 255)
		s = s:sub(256, -1)
		
		self:writeu8(#content)
		self:writestring(content)
		
		print(`writing sub-block [length={#content}]`)
		
		self._yield()
	end
	
	self:writeu8(0)
end

--[[
undocumented
]]--
function Stream.writeu8(self: stream, value: number)
	print('writing uint8', value)
	self:checkshift(1)
	buffer.writeu8(self._b, self._c, value)
	self(1)
end

--[[
undocumented
]]--
function Stream.writeu16(self: stream, value: number)
	print('writing uint16', value)
	self:checkshift(2)
	buffer.writeu16(self._b, self._c, value)
	self(2)
end

--[[
undocumented
]]--
function Stream.writeu32(self: stream, value: number)
	print('writing uint32', value)
	self:checkshift(4)
	buffer.writeu32(self._b, self._c, value)
	self(4)
end

--[[
undocumented
]]--
function Stream.writei8(self: stream, value: number)
	print('writing int8', value)
	self:checkshift(1)
	buffer.writei8(self._b, self._c, value)
	self(1)
end

--[[
undocumented
]]--
function Stream.writei16(self: stream, value: number)
	print('writing int16', value)
	self:checkshift(2)
	buffer.writei16(self._b, self._c, value)
	self(2)
end

--[[
undocumented
]]--
function Stream.writei32(self: stream, value: number)
	print('writing int32', value)
	self:checkshift(4)
	buffer.writei32(self._b, self._c, value)
	self(4)
end

--[[
undocumented
]]--
function Stream.writef32(self: stream, value: number)
	print('writing float32', value)
	self:checkshift(4)
	buffer.writef32(self._b, self._c, value)
	self(4)
end

--[[
undocumented
]]--
function Stream.writef64(self: stream, value: number)
	print('writing float64', value)
	self:checkshift(8)
	buffer.writef64(self._b, self._c, value)
	self(8)
end

--[[
undocumented
]]--
function Stream.writebool(self: stream, value: boolean)
	print('writing bool', value)
	self:writeu8(value and 1 or 0)
end

--[[
Writes a maximum of 8 booleans to the buffer at the specified offset.
]]--
function Stream.writebools(self: stream, values: {boolean})
	print('writing bools', values)
	assert(#values <= 8, "The boolean pack cannot contain more than 8 booleans.")
	
	local r = 0
	for i = 1, 8 do
		r = bit32.bor(bit32.lshift(r, 1), values[i] and 1 or 0)
	end
	
	self:writeu8(r)
end

--[[
undocumented
]]--
function Stream.export(self: stream)
	print(`exporting stream #{self._si}`)
	return buffer.readstring(self._b, 0, self._c)
end

return NewStream
