local Lookup = {}
Lookup.__index = Lookup

local module = {}

local function new(onNewIndex: (self: lookup, index: any) -> any)
	local self = {}
	
	self.id = 0
	self.entries = {} :: {[any]: any}
	self.newindex = onNewIndex :: (index: any) -> any
	
	return setmetatable(self, Lookup)
end
export type lookup = typeof(new(function(self: lookup, index: string): any
	self.id += 1
	return self.id
end))

function Lookup:__call(index: any): any
	local res = self.entries[index]
	if not res then
		res = self:newindex(index)
		self.entries[index] = res
	end
	return res
end

return new
