local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local React = require(ReplicatedStorage.vendor.ReactLua.React)
local ReactRoblox = require(ReplicatedStorage.vendor.ReactLua.ReactRoblox)
local gamemode_api = require(ReplicatedStorage.client.gamemode_client_api)
local gui_manager = require(ReplicatedStorage.client.modules.gui_manager)
local notification_system = require(ReplicatedStorage.client.modules.notification_system)

local create_element = React.createElement

local player = Players.LocalPlayer
local player_gui = player:WaitForChild("PlayerGui")

local function main()
	local is_visible, set_is_visible = React.useState(false)
	local joining_variant, set_joining_variant = React.useState("")

	React.useEffect(function()
		gui_manager.register_gui("bridge", set_is_visible)
		
		local proximity_prompt = game:GetService("Workspace"):WaitForChild("NPCs"):WaitForChild("BridgeNPC"):FindFirstChild("ProximityPrompt")

		if not proximity_prompt then
			return
		end
		local conn = proximity_prompt.Triggered:Connect(function()
			gui_manager.show_gui("bridge")
		end)
		return function()
			conn:Disconnect()
		end
	end, {})

	local function handle_join_queue(variant: string)
		if joining_variant ~= "" then
			return
		end
		set_joining_variant(variant)

		gamemode_api.leave_queue()
		gui_manager.hide_gui("bridge")
		
		if _G.LibreDuel_ForceQueueStatusUpdate then
			_G.LibreDuel_ForceQueueStatusUpdate()
		end

		task.spawn(function()
			local result, error_msg = gamemode_api.join_queue("bridge", variant)
			set_joining_variant("")
			
			if not result then
				notification_system.show("Failed to join queue: ", "#ffffff", error_msg or "Unknown error", "#ff6464")
			end
		end)
	end

	if not is_visible then
		return nil
	end

	return create_element("ScreenGui", {
		ScreenInsets = "None",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		create_element("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = 1,
			Text = "",
			[React.Event.Activated] = function()
				gui_manager.hide_gui("bridge")
			end,
		}),
		
		create_element("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 147),
			Size = UDim2.fromOffset(480, 280),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.5,
			ZIndex = 2,
		}, {
			create_element("UICorner", { CornerRadius = UDim.new(0, 30) }),
			create_element("UIStroke", {
				Thickness = 2,
				Color = Color3.fromRGB(255, 255, 255),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
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
				PaddingTop = UDim.new(0, 30),
				PaddingBottom = UDim.new(0, 30),
				PaddingLeft = UDim.new(0, 20),
				PaddingRight = UDim.new(0, 20),
			}),

			create_element("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 0),
				Size = UDim2.new(1, 0, 0, 35),
				BackgroundTransparency = 1,
				FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
				TextSize = 32,
				RichText = true,
				Text = '<font color="#b14c4e">Bridge</font> <font color="#0da2dd">Duels</font>',
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextYAlignment = Enum.TextYAlignment.Top,
				ZIndex = 3,
			}),

			create_element("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 50),
				Size = UDim2.new(1, 0, 0, 170),
				BackgroundTransparency = 1,
				ZIndex = 3,
			}, {
				create_element("UIListLayout", {
					Padding = UDim.new(0, 12),
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
				}),

				create_element("TextButton", {
					LayoutOrder = 1,
					Size = UDim2.new(0, 280, 0, 38),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 0.7,
					Text = joining_variant == "1v1" and "Joining..." or "1v1",
					FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
					TextSize = 18,
					TextColor3 = Color3.fromRGB(13, 162, 221),
					TextScaled = true,
					ZIndex = 4,
					[React.Event.Activated] = function() handle_join_queue("1v1") end,
				}, {
					create_element("UICorner", { CornerRadius = UDim.new(0, 50) }),
					create_element("UIStroke", {
						Color = Color3.fromRGB(255, 255, 255),
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Thickness = 2,
					}, {
						create_element("UIGradient", {
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(13, 162, 221)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
							}),
							Rotation = -90,
						}),
					}),
					create_element("UIPadding", {
						PaddingLeft = UDim.new(0, 15),
						PaddingRight = UDim.new(0, 15),
					}),
				}),

				create_element("TextButton", {
					LayoutOrder = 2,
					Size = UDim2.new(0, 280, 0, 38),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 0.7,
					Text = joining_variant == "2v2" and "Joining..." or "2v2",
					FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
					TextSize = 18,
					TextColor3 = Color3.fromRGB(177, 76, 78),
					TextScaled = true,
					ZIndex = 4,
					[React.Event.Activated] = function() handle_join_queue("2v2") end,
				}, {
					create_element("UICorner", { CornerRadius = UDim.new(0, 50) }),
					create_element("UIStroke", {
						Color = Color3.fromRGB(255, 255, 255),
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Thickness = 2,
					}, {
						create_element("UIGradient", {
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(177, 76, 78)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
							}),
							Rotation = -90,
						}),
					}),
					create_element("UIPadding", {
						PaddingLeft = UDim.new(0, 15),
						PaddingRight = UDim.new(0, 15),
					}),
				}),

				create_element("TextButton", {
					LayoutOrder = 3,
					Size = UDim2.new(0, 280, 0, 38),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 0.7,
					Text = joining_variant == "3v3" and "Joining..." or "3v3",
					FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
					TextSize = 18,
					TextColor3 = Color3.fromRGB(13, 162, 221),
					TextScaled = true,
					ZIndex = 4,
					[React.Event.Activated] = function() handle_join_queue("3v3") end,
				}, {
					create_element("UICorner", { CornerRadius = UDim.new(0, 50) }),
					create_element("UIStroke", {
						Color = Color3.fromRGB(255, 255, 255),
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Thickness = 2,
					}, {
						create_element("UIGradient", {
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(13, 162, 221)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
							}),
							Rotation = -90,
						}),
					}),
					create_element("UIPadding", {
						PaddingLeft = UDim.new(0, 15),
						PaddingRight = UDim.new(0, 15),
					}),
				}),

				create_element("TextButton", {
					LayoutOrder = 4,
					Size = UDim2.new(0, 280, 0, 38),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 0.7,
					Text = joining_variant == "4v4" and "Joining..." or "4v4",
					FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
					TextSize = 18,
					TextColor3 = Color3.fromRGB(177, 76, 78),
					TextScaled = true,
					ZIndex = 4,
					[React.Event.Activated] = function() handle_join_queue("4v4") end,
				}, {
					create_element("UICorner", { CornerRadius = UDim.new(0, 50) }),
					create_element("UIStroke", {
						Color = Color3.fromRGB(255, 255, 255),
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Thickness = 2,
					}, {
						create_element("UIGradient", {
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(177, 76, 78)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
							}),
							Rotation = -90,
						}),
					}),
					create_element("UIPadding", {
						PaddingLeft = UDim.new(0, 15),
						PaddingRight = UDim.new(0, 15),
					}),
				}),
			}),
		}),
	})
end

local tree = ReactRoblox.createRoot(Instance.new("Folder"))
tree:render(ReactRoblox.createPortal(React.createElement(main), player_gui))

return {}
