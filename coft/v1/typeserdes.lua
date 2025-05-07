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

local cursor = import('cursor.lua')
type cursor = cursor.cursor

local stream = import('stream.lua')
type stream = stream.stream

local lookup = import('lookup.lua')
type lookup = lookup.lookup

type GlobalLookup = {
	[string]: lookup;
	instanceIds: lookup;
	dynamicClasses: lookup;
	properties: lookup;
}

type GlobalLookupDeserialize = {
	[string]: {any};
	instanceIds: {Instance};
	dynamicClasses: {string};
}

local module = {}

module.Encode = {
	['nil'] = function(stream: stream, inp: nil, globalLookup: GlobalLookup)
		-- 😐
		stream:writeu8(0)
	end;
	string = function(stream: stream, inp: string, globalLookup: GlobalLookup)
		stream:writeblocks(inp)
	end;
	number = function(stream: stream, inp: number, globalLookup: GlobalLookup)
		stream:writef32(inp)
	end;
	boolean = function(stream: stream, inp: boolean, globalLookup: GlobalLookup)
		stream:writeu8(inp and 1 or 0)
	end;
	BrickColor = function(stream: stream, inp: BrickColor, globalLookup: GlobalLookup)
		stream:writeu8(inp.Number)
	end;
	Color3 = function(stream: stream, inp: Color3, globalLookup: GlobalLookup)
		stream:writeu8(math.floor(inp.R*255))
		stream:writeu8(math.floor(inp.G*255))
		stream:writeu8(math.floor(inp.B*255))
	end;
	Vector3 = function(stream: stream, inp: Vector3, globalLookup: GlobalLookup)
		stream:writef32(inp.X)
		stream:writef32(inp.Y)
		stream:writef32(inp.Z)
	end;
	Vector2 = function(stream: stream, inp: Vector2, globalLookup: GlobalLookup)
		stream:writef32(inp.X)
		stream:writef32(inp.Y)
	end;
	UDim = function(stream: stream, inp: UDim, globalLookup: GlobalLookup)
		stream:writef32(inp.Scale)
		stream:writef32(inp.Offset)
	end;
	UDim2 = function(stream: stream, inp: UDim2, globalLookup: GlobalLookup)
		stream:writef32(inp.X.Scale)
		stream:writef32(inp.X.Offset)
		stream:writef32(inp.Y.Scale)
		stream:writef32(inp.Y.Offset)
	end;
	CFrame = function(stream: stream, inp: CFrame, globalLookup: GlobalLookup)
		-- in order to save space, I will be saving:
		-- the position (x, y, z)
		-- the axis (dx, dy, dz)
		-- the angle (r)

		stream:writef32(inp.X)
		stream:writef32(inp.Y)
		stream:writef32(inp.Z)

		local axis, angle = inp:ToAxisAngle()

		stream:writef32(axis.X)
		stream:writef32(axis.Y)
		stream:writef32(axis.Z)

		stream:writef32(math.deg(angle))
	end;
	EnumItem = function(stream: stream, inp: EnumItem, globalLookup: GlobalLookup)
		-- enums are weird; I can't exactly have a stored list due to roblox's
		-- constant insertion to this data type

		-- ill have to risk space to save the stringified names of these enums

		stream:writeblocks(tostring(inp.EnumType))
		stream:writeblocks(tostring(inp.Name))

		-- if I can, ill use a lookup table eventually
	end;
	ColorSequence = function(stream: stream, inp: ColorSequence, globalLookup: GlobalLookup)
		stream:writeu8(#inp.Keypoints)
		for _, keyPoint in inp.Keypoints do
			stream:writeu16(math.floor(keyPoint.Time*65535))
			stream:writeu8(math.floor(keyPoint.Value.R*255))
			stream:writeu8(math.floor(keyPoint.Value.G*255))
			stream:writeu8(math.floor(keyPoint.Value.B*255))
		end
	end;
	NumberSequence = function(stream: stream, inp: NumberSequence, globalLookup: GlobalLookup)
		stream:writeu8(#inp.Keypoints)
		for _, keyPoint in inp.Keypoints do
			stream:writeu16(math.floor(keyPoint.Time*65535))
			stream:writeu16(math.floor(keyPoint.Value*65535))
			stream:writeu16(math.floor(keyPoint.Envelope*65535))
		end
	end;
	NumberRange = function(stream: stream, inp: NumberRange, globalLookup: GlobalLookup)
		stream:writef32(inp.Min)
		stream:writef32(inp.Max)
	end;
	Rect = function(stream: stream, inp: Rect, globalLookup: GlobalLookup)
		stream:writef32(inp.Min.X)
		stream:writef32(inp.Min.Y)
		stream:writef32(inp.Max.X)
		stream:writef32(inp.Max.Y)
	end;

	-- vvvvv   the bane of my existence
	Instance = function(stream: stream, inp: Instance, globalLookup: GlobalLookup)
		local instanceId = globalLookup.instanceIds(inp)
		stream:writeu16(instanceId)
	end;
} :: {[string]: (stream: stream, inp: any, globalLookup: GlobalLookup) -> ()}

module.Decode = {
	['nil'] = function(cursor: cursor, globalLookup: GlobalLookupDeserialize)
		-- 😐
		cursor:readu8()
		return nil
	end;
	string = function(cursor: cursor, globalLookup: GlobalLookupDeserialize)
		return cursor:readblocks()
	end;
	number = function(cursor: cursor, globalLookup: GlobalLookupDeserialize)
		return cursor:readf32()
	end;
	boolean = function(cursor: cursor, globalLookup: GlobalLookupDeserialize)
		return cursor:readu8() == 1
	end;
	Vector3 = function(cursor: cursor, globalLookup: GlobalLookupDeserialize)
		local x = cursor:readf32()
		local y = cursor:readf32()
		local z = cursor:readf32()

		return Vector3.new(x, y, z)
	end;
	Vector2 = function(cursor: cursor, globalLookup: GlobalLookupDeserialize)
		local x = cursor:readf32()
		local y = cursor:readf32()

		return Vector2.new(x, y) 
	end;
	UDim = function(cursor: cursor, globalLookup: GlobalLookupDeserialize)
		local scale = cursor:readf32()
		local offset = cursor:readf32()

		return UDim.new(scale, offset) 
	end;
	UDim2 = function(cursor: cursor, globalLookup: GlobalLookupDeserialize)
		local xscale = cursor:readf32()
		local xoffset = cursor:readf32()
		local yscale = cursor:readf32()
		local yoffset = cursor:readf32()

		return UDim2.new(xscale, xoffset, yscale, yoffset) 
	end;
	BrickColor = function(cursor: cursor, globalLookup: GlobalLookupDeserialize)
		local pi = cursor:readu8()
		return BrickColor.palette(pi)
	end;
	Color3 = function(cursor: cursor, globalLookup: GlobalLookupDeserialize)
		local r = cursor:readu8()
		local g = cursor:readu8()
		local b = cursor:readu8()
		return Color3.fromRGB(r, g, b)
	end;
	CFrame = function(cursor: cursor, globalLookup: GlobalLookupDeserialize)
		local x = cursor:readf32()
		local y = cursor:readf32()
		local z = cursor:readf32()

		local ax = cursor:readf32()
		local ay = cursor:readf32()
		local az = cursor:readf32()

		local r = cursor:readf32()

		return CFrame.new(x, y, z)*CFrame.fromAxisAngle(Vector3.new(ax, ay, az), math.rad(r))
	end;
	EnumItem = function(cursor: cursor, globalLookup: GlobalLookupDeserialize)
		local enumType = cursor:readblocks()
		local value = cursor:readblocks()

		local enum = Enum[enumType]
		assert(enum, `enum "{enumType}" does not exist`)

		local enumitem = enum[value]
		assert(enum, `enumitem "{value}" does not exist in`, enum)

		return enumitem
	end,
	ColorSequence = function(cursor: cursor, globalLookup: GlobalLookupDeserialize)
		local keypointCount = cursor:readu8()
		local keypoints = {}

		for _ = 1, keypointCount do
			local keypointTime = cursor:readu16()/65535
			local r = cursor:readu8()
			local g = cursor:readu8()
			local b = cursor:readu8()
			local color = Color3.fromRGB(r, g, b)
			table.insert(keypoints, ColorSequenceKeypoint.new(keypointTime, color))
		end

		return ColorSequence.new(keypoints)
	end,
	NumberSequence = function(cursor: cursor, globalLookup: GlobalLookupDeserialize)
		local keypointCount = cursor:readu8()
		local keypoints = {}

		for _ = 1, keypointCount do
			local keypointTime = cursor:readu16()/65535
			local value = cursor:readu16()/65535
			local envelope = cursor:readu16()/65535
			table.insert(keypoints, NumberSequenceKeypoint.new(keypointTime, value, envelope))
		end

		return NumberSequence.new(keypoints)
	end,
	NumberRange = function(cursor: cursor, globalLookup: GlobalLookupDeserialize)
		local min = cursor:readf32()
		local max = cursor:readf32()

		return NumberRange.new(min, max) 
	end,
	Rect = function(cursor: cursor, globalLookup: GlobalLookupDeserialize)
		local minx = cursor:readf32()
		local miny = cursor:readf32()
		local maxx = cursor:readf32()
		local maxy = cursor:readf32()

		return Rect.new(minx, miny, maxx, maxy)
	end,

	-- vvvvv   the bane of my existence
	Instance = function(cursor: cursor, globalLookup: GlobalLookupDeserialize)
		local instanceId = cursor:readu16()
		return globalLookup.instanceIds[instanceId]
	end;
} :: {[string]: (cursor: cursor, globalLookup: GlobalLookupDeserialize) -> any}

return module
