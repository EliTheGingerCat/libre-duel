local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local debug_print = require(ReplicatedStorage.client.util.debug_print)

local create_element = React.createElement

local bot_count = 0
local function try_create_bot(): ()
	if bot_count >= 3 then
		debug_print("Too many bots.")
		return
	end
	bot_count += 1

	ReplicatedStorage.remotes.create_bot:FireServer()
end

local function menu_create_bot(): ()
	return create_element("ScreenGui", {
		Name = "create_bot",
		ResetOnSpawn = false,
	},
		create_element("TextButton", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			Position = UDim2.fromScale(0.1, 0.8),
			Size = UDim2.fromScale(0.15, 0.1),
			Text = "create a bot",
			TextColor3 = Color3.new(0, 0, 0),

			[React.Event.MouseButton1Click] = try_create_bot,
		})
	)
end

return menu_create_bot
