local function newNoise()
	local xr, yr, zr
	do
		local rng = Random.new()
		xr = rng:NextNumber(0, 999)
		yr = rng:NextNumber(0, 999)
		zr = rng:NextNumber(0, 999)
	end
	return function(x: number, y: number?, z: number?)
		y = y or 0
		z = z or 0
		return math.noise(x+xr,y+yr,z+zr)
	end
end

return newNoise
