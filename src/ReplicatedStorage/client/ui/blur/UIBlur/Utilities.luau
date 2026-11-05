--!nocheck
local Utilities = {}

function Utilities:ProjectIn3D(Camera:Camera,Vector:Vector2,Offset:number) : Vector3
	local Ray = Camera:ScreenPointToRay(Vector.X,Vector.Y,Offset)
	return Ray.Origin + Ray.Direction * Offset
end
function Utilities:MapStrokeSize(Stroke:number) : number
	return Stroke * 0.2
end
function Utilities:GetCornerRadius(UICorner:UICorner) : number
	local CornerRadius = UICorner.CornerRadius
	local Size = math.min(UICorner.Parent.AbsoluteSize.X,UICorner.Parent.AbsoluteSize.Y)

	local Factor = 1
	local Current = UICorner.Parent
	while Current and not Current:IsA("LayerCollector") do
		local Scale = Current:FindFirstChildWhichIsA("UIScale")
		if Scale then
			Factor *= Scale.Scale
		end
		Current = Current.Parent
	end

	return math.min(math.clamp(CornerRadius.Scale,0,0.5) * Size + CornerRadius.Offset * Factor,Size / 2) * 2
end
function Utilities:IsRendered(GuiObject:GuiObject) : boolean
	local Current = GuiObject
	while Current do
		if Current:IsA("LayerCollector") then
			return Current.Enabled
		end
		if Current:IsA("GuiObject") and not Current.Visible then
			return false
		end
		Current = Current.Parent
	end
	return false
end
function Utilities:IsDescendantOfClass(Instance:Instance,ClassName:string) : boolean
	local CurrentParent = Instance.Parent
	for _ = 1,100 do
		if CurrentParent == game then return false end
		if CurrentParent:IsA(ClassName) then
			return CurrentParent
		end
		CurrentParent = CurrentParent.Parent
	end
	return false
end

export type UIBlur = {
	SetCornered : (self:UIBlur,Cornered:boolean) -> (),
	SetStrokeSize : (self:UIBlur,StrokeSize:number) -> (),
	Destroy : (self:UIBlur) -> (),
}
export type UIBlurInternal = {
	_GuiObject : GuiObject,
	_UICorner : UICorner,
	_BlurEffect : BlurEffect,
	_ScreenGui : ScreenGui,
	_MainPlane : MeshPart,
	_Model : Model,

	_IsRendering : boolean,
	_IsAboveGraphicsLevel : boolean,

	_Transparency : number,

	_Connections : {MeshPart},
	_Planes : {MeshPart},
	_Corners : {MeshPart},

	_Arguments : UIBlurArguments,

	_UpdateCorners : (self:UIBlurInternal,CornerOffset:number,Size3D:Vector2) -> (),
	_UpdateSidePlanes : (self:UIBlurInternal,CornerOffset:number,Size3D:Vector2) -> (),
	_Update : (self:UIBlurInternal) -> (),
}
export type UIBlurArguments = {
	Fragmented : boolean?, -- Little sunlight effect using displaced geometry
	Inverted : boolean?, -- Inverts the screen colors for that particular GuiObject
	StrokeSize : number?, -- Outer blur; "1" means the actual model is the same size as the frame (DepthOfField stuff)
}
export type UIBlurModule = {
	DepthOfField : DepthOfFieldEffect,
	new : (GuiObject:GuiObject,UIBlurArguments:UIBlurParameters) -> (UIBlur)
}

return Utilities