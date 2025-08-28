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
	local join_code, set_join_code = React.useState("")
	local is_creating, set_is_creating = React.useState(false)
	local is_joining, set_is_joining = React.useState(false)

	React.useEffect(function()
		gui_manager.register_gui("playground", set_is_visible)
		
		local proximity_prompt = game:GetService("Workspace"):WaitForChild("NPCs"):WaitForChild("PlaygroundNPC"):FindFirstChild("ProximityPrompt")

		if not proximity_prompt then
			return
		end
		local conn = proximity_prompt.Triggered:Connect(function()
			gui_manager.show_gui("playground")
		end)
		return function()
			conn:Disconnect()
		end
	end, {})

	local function handle_create_playground()
		if is_creating or is_joining then
			return
		end
		set_is_creating(true)
		set_is_joining(false)

		local code, error_msg = gamemode_api.create_playground_and_teleport()
		set_is_creating(false)
		
		if code then
			notification_system.show("Playground created! Code: ", "#ffffff", code, "#85dd32")
		else
			notification_system.show("Failed to create playground: ", "#ffffff", error_msg or "Unknown error", "#ff6464")
		end
	end

	local function handle_join_playground()
		local filtered = string.upper(string.gsub(join_code, "%s+", ""))
		if #filtered ~= 6 then
			notification_system.show("Code must be 6 characters", "#ff6464")
			return
		end
		if is_creating or is_joining then
			return
		end
		set_is_joining(true)
		set_is_creating(false)

		local success, error_msg = gamemode_api.teleport_to_playground_by_code(filtered)
		set_is_joining(false)
		
		if success then
			notification_system.show("Joining playground...", "#85dd32")
		else
			notification_system.show("Invalid playground code: ", "#ffffff", error_msg or "Unknown error", "#ff6464")
		end
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
				gui_manager.hide_gui("playground")
			end,
		}),
		
		create_element("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 147),
			Size = UDim2.fromOffset(480, 220),
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
				Text = '<font color="#b14c4e">Play</font><font color="#0da2dd">ground</font>',
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextYAlignment = Enum.TextYAlignment.Top,
				ZIndex = 3,
			}),

			create_element("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 50),
				Size = UDim2.new(1, 0, 0, 110),
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
					Text = is_creating and "Creating..." or "Create Playground",
					FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
					TextSize = 18,
					TextColor3 = Color3.fromRGB(13, 162, 221),
					TextScaled = true,
					ZIndex = 4,
					[React.Event.Activated] = handle_create_playground,
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

				create_element("Frame", {
					LayoutOrder = 2,
					Size = UDim2.new(0, 280, 0, 38),
					BackgroundTransparency = 1,
					ZIndex = 4,
				}, {
					create_element("TextBox", {
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0, 0, 0.5, 0),
						Size = UDim2.new(0.65, -5, 1, 0),
						BackgroundColor3 = Color3.fromRGB(0, 0, 0),
						BackgroundTransparency = 0.7,
						Text = join_code,
						PlaceholderText = "Enter code",
						FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
						TextSize = 16,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						PlaceholderColor3 = Color3.fromRGB(180, 180, 180),
						TextXAlignment = Enum.TextXAlignment.Center,
						ZIndex = 5,
						ClearTextOnFocus = false,
						[React.Event.FocusLost] = function(enter_pressed)
							if enter_pressed then
								handle_join_playground()
							end
						end,
						[React.Change.Text] = function(text_box)
							local current_text = text_box.Text
							local filtered = string.gsub(current_text, "[^%w]", "")
							filtered = string.upper(filtered)
							
							if #filtered > 6 then
								filtered = string.sub(filtered, 1, 6)
							end
							
							if filtered ~= current_text then
								text_box.Text = filtered
							end
							
							if filtered ~= join_code then
								set_join_code(filtered)
							end
						end,
					}, {
						create_element("UICorner", { CornerRadius = UDim.new(0, 50) }),
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
							PaddingLeft = UDim.new(0, 12),
							PaddingRight = UDim.new(0, 12),
						}),
					}),

					create_element("TextButton", {
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.new(1, 0, 0.5, 0),
						Size = UDim2.new(0.35, -5, 1, 0),
						BackgroundColor3 = Color3.fromRGB(0, 0, 0),
						BackgroundTransparency = 0.7,
						Text = is_joining and "Joining..." or "Join",
						FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
						TextSize = 16,
						TextColor3 = Color3.fromRGB(133, 221, 50),
						TextScaled = true,
						ZIndex = 5,
						[React.Event.Activated] = handle_join_playground,
					}, {
						create_element("UICorner", { CornerRadius = UDim.new(0, 50) }),
						create_element("UIStroke", {
							Color = Color3.fromRGB(255, 255, 255),
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Thickness = 2,
						}, {
							create_element("UIGradient", {
								Color = ColorSequence.new({
									ColorSequenceKeypoint.new(0, Color3.fromRGB(133, 221, 50)),
									ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
								}),
								Rotation = -90,
							}),
						}),
						create_element("UIPadding", {
							PaddingLeft = UDim.new(0, 8),
							PaddingRight = UDim.new(0, 8),
						}),
					}),
				}),
			}),
		}),
	})
end

local tree = ReactRoblox.createRoot(Instance.new("Folder"))
tree:render(ReactRoblox.createPortal(React.createElement(main), player_gui))

return {}
