--!nocheck
-- Objectual UI Blur by Tavikron: https://devforum.roblox.com/t/objectual-ui-blur-12-revision-2/3626057
-- Local changes: exposes DepthOfField, checks ancestor visibility, and supports offset corner radii.
-- Only the Normal meshes are included, so the Fragmented argument does not work.

-- Thanks to SomeFedoraGuy (me) for spending time to make this bloatware
-- For future use: PBR-124652808947078

-- V.1.2 / REVISION 2

local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local Utilities = require(script.Utilities)

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local DepthOfField = Instance.new("DepthOfFieldEffect")

local Container = Camera:FindFirstChild("UIBlur")
local InvertedContainer = Container and Container:FindFirstChild("Inverted") or Instance.new("Model")

local GameSettings = UserSettings().GameSettings
local QualityLevel = GameSettings.SavedQualityLevel

local Offset = 0.02
local InvertedInstances = 0

local UIBlur = {}
UIBlur.__index = UIBlur
UIBlur.DepthOfField = DepthOfField

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	Camera = workspace.CurrentCamera
end)

local function GetContainer() : Folder
	if not Container then
		Container = Instance.new("Folder")
		Container.Name = "UIBlur"
		Container.Parent = Camera
		InvertedContainer.Parent = Container
	end
	return Container
end
local function GenerateInverter() : Highlight
	if not InvertedContainer:FindFirstChild("Inverter") then
		local Highlight = Instance.new("Highlight")
		Highlight.Name = "Inverter"
		Highlight.Adornee = InvertedContainer
		Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		Highlight.FillColor = Color3.new(0.5,0.5,0.5)
		Highlight.FillTransparency = -1
		Highlight.OutlineColor = Color3.new(0,0,0)
		Highlight.OutlineTransparency = 1
		Highlight.Parent = InvertedContainer
	end
end
local function GenerateForBlurEffect(Object:BlurEffect)
	if Object:IsA("BlurEffect") and Object.Parent:IsA("GuiObject") then
		UIBlur.new(Object.Parent,{Fragmented = Object:GetAttribute("Fragmented"),Inverted = Object:GetAttribute("Inverted")})
	end
end

DepthOfField.Name = "UIBlur"
DepthOfField.FarIntensity = 0
DepthOfField.FocusDistance = 0
DepthOfField.InFocusRadius = 0
DepthOfField.NearIntensity = 1
DepthOfField.Parent = Lighting

InvertedContainer.Name = "Inverted"
function UIBlur.new(GuiObject:GuiObject,Arguments:Utilities.UIBlurArguments) : Utilities.UIBlur
	if not GuiObject:IsA("GuiObject") then return end
	assert(Utilities:IsDescendantOfClass(GuiObject,"ScreenGui"),"GuiObject must be a child of a ScreenGui in order to blur it")

	local self = {} :: Utilities.UIBlurInternal

	if not Arguments then Arguments = {} end
	if not Arguments.StrokeSize then Arguments.StrokeSize = 0 else Arguments.StrokeSize = Utilities:MapStrokeSize(Arguments.StrokeSize) end

	self._GuiObject = GuiObject
	self._Arguments = Arguments

	self._Transparency = 0.98

	self._IsRendering = true

	self._UICorner = GuiObject:FindFirstChildWhichIsA("UICorner")
	self._BlurEffect = GuiObject:FindFirstChildWhichIsA("BlurEffect")
	self._ScreenGui = Utilities:IsDescendantOfClass(GuiObject,"ScreenGui")

	self._Connections = {}
	self._Planes = {} -- up, right, down, left,
	self._Corners = {} -- top left, top right, bottom right, bottom left
	self._MainPlane = script[self._Arguments.Fragmented and "Fragmented" or "Normal"].Plane:Clone()
	self._Model = Instance.new("Model")

	self = setmetatable(self,UIBlur)

	self._MainPlane.Material = Enum.Material.Glass

	table.insert(self._Connections,GuiObject.ChildAdded:Connect(function(Object)
		if Object:IsA("UICorner") then
			self._UICorner = Object
		end
	end))
	table.insert(self._Connections,GuiObject.ChildRemoved:Connect(function(Object)
		if Object:IsA("UICorner") and Object == self._UICorner then
			self._UICorner = nil
		end
	end))
	table.insert(self._Connections,RunService.PreRender:Connect(function()
		self:_Update()
	end))
	table.insert(self._Connections,GuiObject.AncestryChanged:Connect(function(_,Parent)
		if not Parent then
			self:Destroy()
		end
	end))

	if self._Arguments.Inverted then
		InvertedInstances += 1
		if InvertedInstances == 1 then
			GenerateInverter()
		end
	end

	self._MainPlane.Parent = self._Model
	self._Model.Name = GuiObject.Name
	self._Model.PrimaryPart = self._MainPlane	
	self:SetCornered(self._UICorner)

	self._Model.Parent = self._Arguments.Inverted and InvertedContainer or GetContainer()
	GetContainer()

	return self
end

function UIBlur.SetCornered(self:Utilities.UIBlurInternal,Cornered:boolean)
	if Cornered then
		for _ = 1,4 do
			local Mesh = script[self._Arguments.Fragmented and "Fragmented" or "Normal"].Plane:Clone()
			table.insert(self._Planes,Mesh)
			Mesh.Material = Enum.Material.Glass
			Mesh.Parent = self._Model
		end
		for _ = 1,4 do
			local Mesh = script[self._Arguments.Fragmented and "Fragmented" or "Normal"].Corner:Clone()
			table.insert(self._Corners,Mesh)
			Mesh.Material = Enum.Material.Glass
			Mesh.Parent = self._Model
		end
	else
		for _,Group in {self._Planes,self._Corners} do
			for _,Mesh in Group do
				Mesh:Destroy()
			end
		end
	end
end
function UIBlur.SetStrokeSize(self:Utilities.UIBlurInternal,StrokeSize:number)
	self._Arguments.StrokeSize = Utilities:MapStrokeSize(StrokeSize)
end
function UIBlur.Destroy(self:Utilities.UIBlurInternal)
	for _,Connection in self._Connections do
		Connection:Disconnect()
	end
	self._Model:Destroy()

	if self._Inverted then
		InvertedInstances -= 1
	end
	if InvertedInstances <= 0 then
		InvertedInstances = 0
		InvertedContainer:ClearAllChildren()
	end
end

function UIBlur._UpdateCorners(self:Utilities.UIBlurInternal,CornerOffset:number,Size3D:Vector2)
	CornerOffset /= 2
	for _,Corner in self._Corners do
		Corner.Size = Vector3.new(CornerOffset,CornerOffset)
		Corner.PivotOffset = CFrame.new(CornerOffset/2,CornerOffset/2,0)
	end

	local RightVector = self._MainPlane.CFrame.RightVector
	local UpVector = self._MainPlane.CFrame.UpVector

	self._Corners[1]:PivotTo( self._MainPlane.CFrame + RightVector * Size3D.X / 2 + UpVector * Size3D.Y / 2)
	self._Corners[2]:PivotTo((self._MainPlane.CFrame - RightVector * Size3D.X / 2 + UpVector * Size3D.Y / 2) * CFrame.Angles(0,0,math.pi/2))
	self._Corners[3]:PivotTo((self._MainPlane.CFrame - RightVector * Size3D.X / 2 - UpVector * Size3D.Y / 2) * CFrame.Angles(0,0,math.pi))
	self._Corners[4]:PivotTo((self._MainPlane.CFrame + RightVector * Size3D.X / 2 - UpVector * Size3D.Y / 2) * CFrame.Angles(0,0,-math.pi/2))
end
function UIBlur._UpdateSidePlanes(self:Utilities.UIBlurInternal, CornerOffset:number, Size3D:Vector2)
	local RightVector = self._MainPlane.CFrame.RightVector
	local UpVector = self._MainPlane.CFrame.UpVector

	CornerOffset /= 2	

	self._Planes[1].Size = Vector3.new(CornerOffset,Size3D.Y - CornerOffset * 2)
	self._Planes[2].Size = Vector3.new(Size3D.X - CornerOffset * 2,CornerOffset)
	self._Planes[3].Size = self._Planes[1].Size
	self._Planes[4].Size = self._Planes[2].Size

	self._Planes[1].CFrame = self._MainPlane.CFrame + RightVector * (Size3D.X / 2 - CornerOffset / 2)
	self._Planes[2].CFrame = self._MainPlane.CFrame + UpVector * (Size3D.Y / 2 - CornerOffset / 2)
	self._Planes[3].CFrame = self._MainPlane.CFrame - RightVector * (Size3D.X / 2 - CornerOffset / 2)
	self._Planes[4].CFrame = self._MainPlane.CFrame - UpVector * (Size3D.Y / 2 - CornerOffset / 2)
end

function UIBlur._Update(self:Utilities.UIBlurInternal)
	if self._IsRendering and QualityLevel.Value >= 8 and Utilities:IsRendered(self._GuiObject) and (self._BlurEffect and self._BlurEffect.Enabled or not self._BlurEffect) then
		local GuiPos,GuiSize = self._GuiObject.AbsolutePosition,self._GuiObject.AbsoluteSize
		local Center = Utilities:ProjectIn3D(Camera,GuiPos + GuiSize / 2,Offset)
		local ScaleFactor = (6.8 + self._Arguments.StrokeSize) * Offset * math.tan(math.rad(Camera.FieldOfView / 2)) * 2 / Camera.ViewportSize.Y

		self._MainPlane.Transparency = self._Transparency

		if not self._UICorner then
			self._MainPlane.CFrame = CFrame.new(Center,Center - Camera.CFrame.LookVector) * CFrame.Angles(0,0,math.rad(self._GuiObject.AbsoluteRotation))
			self._MainPlane.Size = Vector3.new(GuiSize.X * ScaleFactor,GuiSize.Y * ScaleFactor)
		else
			local CornerOffset = Utilities:GetCornerRadius(self._UICorner) * ScaleFactor
			local Size3D = Vector2.new(GuiSize.X * ScaleFactor,GuiSize.Y * ScaleFactor)
			local MainPlaneSizes = {
				X = Size3D.X - CornerOffset,
				Y = Size3D.Y - CornerOffset,
			}

			self._MainPlane.CFrame = CFrame.new(Center,Center - Camera.CFrame.LookVector) * CFrame.Angles(0,0,math.rad(self._GuiObject.AbsoluteRotation))
			if MainPlaneSizes.X <= 0.01 or MainPlaneSizes.Y <= 0.01 then
				self._MainPlane.Transparency = 1
			else
				self._MainPlane.Size = Vector3.new(MainPlaneSizes.X,MainPlaneSizes.Y)
			end

			for _,Group in {self._Planes,self._Corners} do
				for _,Mesh in Group do
					Mesh.Transparency = self._Transparency
				end
			end

			self:_UpdateCorners(CornerOffset,Size3D)
			self:_UpdateSidePlanes(CornerOffset,Size3D)
		end
	else
		self._MainPlane.Transparency = 1
		for _,Group in {self._Planes,self._Corners} do
			for _,Mesh in Group do
				Mesh.Transparency = 1
			end
		end
	end
end

GameSettings:GetPropertyChangedSignal("SavedQualityLevel"):Connect(function()
	QualityLevel = GameSettings.SavedQualityLevel
end)
if script:GetAttribute("AutoAddEnabled") then
	for _,Object:Instance in Player.PlayerGui:GetDescendants() do
		GenerateForBlurEffect(Object)
	end
	Player.PlayerGui.DescendantAdded:Connect(function(Object)
		GenerateForBlurEffect(Object)
	end)
end

return UIBlur :: Utilities.UIBlurModule