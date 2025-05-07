-- import from sb-utils
local import: (file: string) -> any
local importraw: (file: string) -> string
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
			print('returned cached',file)
			return data
		end
		
		print('attempting to import',file)
		data = http:GetAsync(string.format(BASE_IMPORT_URL, file), true)
		local load, e = loadstring(data)
		if not load then
			warn(e)
			return
		end
		data = load()
		cache[file] = data
		print('imported',file)
		
		return data
	end
	
	importraw = function(file: string)
		local data = cache[file..'.raw']
		if data then
			print('returned cached raw',file)
			return data
		end
		
		print('attempting to import raw',file)
		data = http:GetAsync(string.format(BASE_IMPORT_URL, file), true)
		cache[file..'.raw'] = data
		print('imported raw',file)

		return data
	end
end

-- modules

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--local gizmo = import('gizmo.lua')
local noise = import('noise.lua')
local coft = import('coft.lua')

local LegTemplate, SpiderTemplate
do
	local assetbuf = buffer.fromstring(importraw('spider_assets.coft'))
	local deserialized = coft.deserialize(assetbuf)
	local folder = deserialized.serialized
	LegTemplate = folder.leg
	
	LegTemplate.a.b.C0 = CFrame.new(0, 1.25, 0)
	LegTemplate.a.b.C1 = CFrame.new(0, -1.25, 0)
	LegTemplate.a.CanCollide = false
	LegTemplate.a.CanQuery = false
	LegTemplate.a.CanTouch = false
	
	LegTemplate.b.c.C0 = CFrame.new(0, 1.25, 0)
	LegTemplate.b.c.C1 = CFrame.new(0, -1.25, 0)
	LegTemplate.b.CanCollide = false
	LegTemplate.b.CanQuery = false
	LegTemplate.b.CanTouch = false
	
	LegTemplate.c.tip.C0 = CFrame.new(0, 1.25, 0)
	LegTemplate.c.tip.C1 = CFrame.identity
	LegTemplate.c.CanCollide = false
	LegTemplate.c.CanQuery = false
	LegTemplate.c.CanTouch = false
	
	SpiderTemplate = folder.spider
	SpiderTemplate.root.pole.Visible = false
	SpiderTemplate.attachmentroot.Transparency = 1
end

local plr = owner or game.Players.rookiecookie153
local CurrentPosition = (plr.Character.HumanoidRootPart.CFrame*CFrame.new(0, 0, -5)).Position

-- spider vars
local Velocity = Vector3.zero
local Grav = Vector3.new(0, -workspace.Gravity, 0)
workspace:GetPropertyChangedSignal('Gravity'):Connect(function()
	Grav = Vector3.new(0, -workspace.Gravity, 0)
end)

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
local function raycast(origin: Vector3, direction: Vector3): RaycastResult?
	local r = workspace:Raycast(origin, direction)
	if r then
		--gizmo.setColor3(Color3.new(0,1,0))
		--gizmo.drawLine(origin, r.Position)
		--gizmo.setColor3(Color3.new(1, 1, 0))
		--gizmo.drawPoint(r.Position)
		return r
	end
	--gizmo.setColor3(Color3.new(1,0,0))
	--gizmo.drawRay(origin, direction)
	return nil
end

task.wait(2)
print('start')

local Spider = SpiderTemplate:Clone()
Spider.root.Position = CurrentPosition
Spider.Parent = workspace
params.FilterDescendantsInstances = {Spider}

local function CreateLeg()
	local cl = LegTemplate:Clone()

	local IKControl = Instance.new('IKControl')
	IKControl.Enabled = false
	IKControl.Type = Enum.IKControlType.Transform

	IKControl.ChainRoot = cl.a
	IKControl.EndEffector = cl.tip

	local poleAttachment = Instance.new('Attachment')
	poleAttachment.Name = 'pole'
	poleAttachment.Position = CurrentPosition+Vector3.new(0,10,0)
	poleAttachment.Parent = Spider.root

	local targetAttachment = Instance.new('Attachment')
	targetAttachment.Name = 'goal'
	targetAttachment.Position = CurrentPosition+Vector3.new(0,0,-10)
	targetAttachment.Parent = Spider.attachmentroot

	IKControl.Target = targetAttachment
	IKControl.Pole = poleAttachment--Spider.root.pole

	IKControl.SmoothTime = .01

	IKControl.Parent = Spider.AnimationController
	IKControl.Enabled = true

	cl:PivotTo(Spider.root.CFrame*CFrame.new(0,1.25,0))

	local motor = Instance.new('Motor6D')
	motor.Part0 = Spider.root
	motor.Part1 = cl.a
	motor.C1 = CFrame.new(0, -1.25, 0)
	motor.Parent = Spider.root

	cl.Parent = Spider

	return {
		goal = targetAttachment;
		pole = poleAttachment;
		oldanchor = nil :: Vector3?;
		anchor = nil :: Vector3?;
		anchortime = 0;
		grounded = false;
		stepping = false;
	}
end

local LEG_COUNT = 6

local Legs = {}
for i = 1, LEG_COUNT do
	table.insert(Legs, CreateLeg())
end
setmetatable(Legs, {__index = function(self, key)
	return Legs[((key-1)%LEG_COUNT)+1]
end})

local HEIGHT = 3
local STEP_DURATION = .15
local STEP_DISTANCE_RADIUS = 2
local DISTANCE_FROM_BODY = 4
local LEG_LENGTH = 7.5
local RAYCAST_DISTANCE = math.sqrt(LEG_LENGTH^2-DISTANCE_FROM_BODY^2)

local GIZMO_SEGMENT_COUNT = 20
local function drawCircle(at: Vector3, facing: Vector3, radius: number)
	for i = 0, GIZMO_SEGMENT_COUNT-1 do
		local theta1 = (i/GIZMO_SEGMENT_COUNT)*math.pi*2
		local theta2 = ((i+1)/GIZMO_SEGMENT_COUNT)*math.pi*2
		local pos1 = (CFrame.lookAlong(at, facing)*CFrame.Angles(0, 0, theta1)*CFrame.new(0,radius,0)).Position
		local pos2 = (CFrame.lookAlong(at, facing)*CFrame.Angles(0, 0, theta2)*CFrame.new(0,radius,0)).Position
		gizmo.drawLine(pos1,pos2)
	end
end

local function bezierBlendCFrame(t: number, ...:CFrame)
	local result = {...}
	while #result > 1 do
		local temp = {}
		for i = 1, #result-1 do
			local a = result[i]
			local b = result[i+1]
			temp[i] = a:Lerp(b, t)
		end
		result = temp
	end
	return result[1]
end

local function bezierBlendVector3(t: number, ...:Vector3)
	local result = {...}
	while #result > 1 do
		local temp = {}
		for i = 1, #result-1 do
			local a = result[i]
			local b = result[i+1]
			temp[i] = a:Lerp(b, t)
		end
		result = temp
	end
	return result[1]
end

local funny = Spider.root.funny:GetChildren()
local function tap()
	local player = funny[math.random(1, #funny)]:Clone()
	player.Parent = Spider.root
	player:Play()
	player.Ended:Once(function()
		player:Destroy()
	end)
end

Velocity = Vector3.new(0, 0, 10)

local now = 0

local init = CurrentPosition

local n1 = noise()
local n2 = noise()

for i = 1, LEG_COUNT do
	local leg = Legs[i]

	local theta = ((i-1)/#Legs + 0.125)*math.pi*2

	leg.pole.Position = Vector3.new(math.sin(theta)*LEG_LENGTH,RAYCAST_DISTANCE,math.cos(theta)*LEG_LENGTH)
end

RunService.Heartbeat:Connect(function(dt)
	now += dt

	Velocity = Vector3.new(n1(now*.5),0,n2(now*.5))*10

	--gizmo.drawRay(CurrentPosition, Velocity)

	CurrentPosition += Velocity*dt

	Spider.root.CFrame = CFrame.new(CurrentPosition)

	for i = 1, LEG_COUNT do
		local adj1 = Legs[i-1]
		local leg = Legs[i]
		local adj2 = Legs[i+1]

		local theta = ((i-1)/#Legs + 0.125)*math.pi*2
		local offset = Vector3.new(math.sin(theta)*DISTANCE_FROM_BODY,0,math.cos(theta)*DISTANCE_FROM_BODY)

		local topdowngoal = CurrentPosition+offset
		local cast = raycast((topdowngoal-(Velocity*dt)):Lerp(topdowngoal, STEP_DISTANCE_RADIUS), Vector3.yAxis*-RAYCAST_DISTANCE)
		local goal = cast and cast.Position or topdowngoal-Vector3.yAxis*RAYCAST_DISTANCE

		leg.grounded = cast and true or false
		--if not cast then
		--	leg.grounded = false
		--end
		if leg.anchor and cast then
			if (leg.anchor-goal).Magnitude > STEP_DISTANCE_RADIUS and not leg.stepping and not adj1.stepping and not adj2.stepping then
				leg.anchortime = 0
			end
		elseif not leg.grounded or not leg.anchor then
			leg.anchor = goal+Vector3.new(.1,0,-.1)
		end

		local legAnchorLerp = leg.anchortime

		local isStepping = legAnchorLerp < 1
		if isStepping then
			--gizmo.setColor3(Color3.new(1,0,0))
			leg.anchortime += (Velocity.Magnitude*dt*.1)/STEP_DURATION
			goal = bezierBlendVector3(math.min(legAnchorLerp, 1), leg.anchor, (CFrame.new(goal:Lerp(leg.anchor, .5), leg.anchor)*CFrame.new(0, 5, 0)).Position, goal)
		else
			--gizmo.setColor3(Color3.new(1,1,1))
			if leg.stepping then
				tap()
				leg.anchor = goal
			end
			goal = leg.anchor
		end
		leg.stepping = isStepping

		--drawCircle(leg.anchor, Vector3.yAxis, STEP_DISTANCE_RADIUS)

		local attachment = leg.goal
		attachment.WorldPosition = goal
	end
end)
