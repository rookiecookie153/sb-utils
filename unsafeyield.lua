local RunService = game:GetService("RunService")
return function(n: number)
	local i = 0
	local n = n or 1
	local t = os.clock()
	return function()
		local now = os.clock()
		if now-t >= n then
			t = now
			
			RunService.Heartbeat:Wait()
			return true
		end
		return false
	end
end
