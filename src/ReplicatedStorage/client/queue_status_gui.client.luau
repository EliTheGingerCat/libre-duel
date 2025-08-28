local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local React = require(ReplicatedStorage.vendor.ReactLua.React)
local ReactRoblox = require(ReplicatedStorage.vendor.ReactLua.ReactRoblox)
local gamemode_api = require(ReplicatedStorage.client.gamemode_client_api)

local create_element = React.createElement

local player = Players.LocalPlayer
local player_gui = player:WaitForChild("PlayerGui")

local global_queue_info = nil
local global_set_queue_info = nil

local function force_update_queue_status()
	if global_set_queue_info then
		local status, error_msg = gamemode_api.get_queue_status()
		if status then
			global_queue_info = status
			global_set_queue_info(status)
		else
			global_queue_info = nil
			global_set_queue_info(nil)
		end
	end
end

_G.LibreDuel_ForceQueueStatusUpdate = force_update_queue_status

local function main()
	local queue_info, set_queue_info = React.useState(nil)
	local is_leaving, set_is_leaving = React.useState(false)
	local last_server_job_id, set_last_server_job_id = React.useState(nil)
	
	React.useEffect(function()
		global_set_queue_info = set_queue_info
		
		return function()
			if global_set_queue_info == set_queue_info then
				global_set_queue_info = nil
			end
		end
	end, {})

	React.useEffect(function()
		local function check_queue_status()
			local server_info = gamemode_api.get_this_server()
			local current_job_id = server_info.jobId
			
			if last_server_job_id and last_server_job_id ~= current_job_id then
				set_queue_info(nil)
				set_is_leaving(false)
				set_last_server_job_id(current_job_id)
				return
			end
			
			if not last_server_job_id then
				set_last_server_job_id(current_job_id)
			end
			
			local status, error_msg = gamemode_api.get_queue_status()
			if status then
				global_queue_info = status
				set_queue_info(status)
				set_is_leaving(false)
			else
				if not is_leaving then
					global_queue_info = nil
					set_queue_info(nil)
				end
			end
		end

		check_queue_status()
		
		local connection = task.spawn(function()
			while task.wait(0.3) do
				check_queue_status()
			end
		end)

		return function()
			task.cancel(connection)
		end
	end, {last_server_job_id, is_leaving})

	local function handle_leave_queue()
		if is_leaving then
			return
		end
		set_is_leaving(true)
		
		task.spawn(function()
			local success, error_msg = gamemode_api.leave_queue()
			
			if success then
				set_queue_info(nil)
				set_is_leaving(false)
			else
				task.wait(2)
				set_is_leaving(false)
			end
		end)
	end

	if not queue_info and not is_leaving then
		return nil
	end

	local display_name = ""
	local current_count = 0
	local required_count = 0
	
	if queue_info then
		local gamemode_parts = string.split(queue_info.queue, "-")
		local gamemode = gamemode_parts[1]
		local variant = gamemode_parts[2]
		
		if gamemode == "bridge" then
			display_name = "Bridge " .. string.upper(variant)
		elseif gamemode == "basicfight" then
			display_name = "Basic Fight " .. string.upper(variant)
		elseif gamemode == "boxing" then
			display_name = "Boxing " .. string.upper(variant)
		end
		
		current_count = queue_info.current
		required_count = queue_info.required
	end

	return create_element("ScreenGui", {
		ScreenInsets = "None",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		create_element("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -20),
			Size = UDim2.fromOffset(350, 70),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.5,
		}, {
			create_element("UICorner", { CornerRadius = UDim.new(0, 20) }),
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
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 15),
				PaddingRight = UDim.new(0, 15),
			}),

			create_element("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(0.7, 0, 1, 0),
				BackgroundTransparency = 1,
				FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
				TextSize = 18,
				RichText = true,
				Text = if is_leaving 
					then "Leaving queue..."
					else display_name .. '<br/><font color="#85dd32">' .. current_count .. "/" .. required_count .. '</font>',
				TextColor3 = if is_leaving then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(255, 255, 255),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
			}),

			create_element("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(0.3, -10, 0, 35),
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 0.7,
				Text = is_leaving and "Leaving..." or "Cancel",
				FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
				TextSize = 14,
				TextColor3 = Color3.fromRGB(231, 76, 60),
				TextScaled = true,
				Active = not is_leaving,
				[React.Event.Activated] = handle_leave_queue,
			}, {
				create_element("UICorner", { CornerRadius = UDim.new(0, 30) }),
				create_element("UIStroke", {
					Color = Color3.fromRGB(255, 255, 255),
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Thickness = 1,
				}, {
					create_element("UIGradient", {
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromRGB(231, 76, 60)),
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
	})
end

local tree = ReactRoblox.createRoot(Instance.new("Folder"))
tree:render(ReactRoblox.createPortal(React.createElement(main), player_gui))

return {}
