local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local React = require(ReplicatedStorage.vendor.ReactLua.React)
local ReactRoblox = require(ReplicatedStorage.vendor.ReactLua.ReactRoblox)
local create_element = React.createElement

local player = Players.LocalPlayer
local player_gui = player:WaitForChild("PlayerGui")

local function main()
	local playground_code, set_playground_code = React.useState("")
	local is_playground, set_is_playground = React.useState(false)

	React.useEffect(function()
		local rf = ReplicatedStorage:FindFirstChild("GetThisServerMetadata")
		if not rf then
			rf = ReplicatedStorage:WaitForChild("GetThisServerMetadata", 5)
		end
		if not rf then
			set_is_playground(false)
			set_playground_code("")
			return
		end

		local ok, meta = pcall(function()
			return (rf :: RemoteFunction):InvokeServer()
		end)
		if ok and meta and meta.type == "playground" then
			set_is_playground(true)
			set_playground_code(meta.code or "")
		else
			set_is_playground(false)
			set_playground_code("")
		end
	end, {})

	if not is_playground or playground_code == "" then
		return nil
	end

	return create_element("ScreenGui", {
		ScreenInsets = "None",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		create_element("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -30, 0.5, 0),
			Size = UDim2.fromOffset(220, 110),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.5,
		}, {
			create_element("UICorner", { CornerRadius = UDim.new(0, 30) }),
			create_element("UIStroke", {
				Color = Color3.fromRGB(255, 255, 255),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = 2,
			}, {
				create_element("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(134, 134, 134)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
					}),
					Rotation = -90,
				}),
			}),
			create_element("UIPadding", {
				PaddingTop = UDim.new(0, 15),
				PaddingBottom = UDim.new(0, 15),
				PaddingLeft = UDim.new(0, 15),
				PaddingRight = UDim.new(0, 15),
			}),

			create_element("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 0),
				Size = UDim2.new(1, 0, 0, 25),
				BackgroundTransparency = 1,
				FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
				TextSize = 18,
				RichText = true,
				Text = '<font color="#b14c4e">Join</font> <font color="#0da2dd">Code</font>',
				TextXAlignment = Enum.TextXAlignment.Center,
			}),

			create_element("TextBox", {
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, 0),
				Size = UDim2.new(1, 0, 0, 50),
				BackgroundTransparency = 1,
				FontFace = Font.fromId(11702779409, Enum.FontWeight.Bold),
				TextSize = 36,
				Text = playground_code,
				TextColor3 = Color3.fromRGB(133, 221, 50),
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				TextEditable = false,
				ClearTextOnFocus = false,
			}),
		}),
	})
end

local tree = ReactRoblox.createRoot(Instance.new("Folder"))
tree:render(ReactRoblox.createPortal(React.createElement(main), player_gui))
return {}
