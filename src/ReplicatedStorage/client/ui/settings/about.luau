local ReplicatedStorage = game:GetService("ReplicatedStorage")

const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
local React = require(ReplicatedStorage.Packages.react)

local git_info = ReplicatedStorage:WaitForChild("git_info")
local commit = git_info:WaitForChild("commit") :: StringValue
local license = git_info:WaitForChild("license") :: StringValue

const function about()
	return React.createElement("Frame", {
		Name = "about",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, {
		layout = React.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 20),
		}),
		logo = React.createElement("ImageLabel", {
			LayoutOrder = 1,
			Size = UDim2.fromOffset(256, 192),
			BackgroundTransparency = 1,
			Image = "rbxassetid://129555975021646",
			ScaleType = Enum.ScaleType.Fit,
		}),
		details = React.createElement("Frame", {
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
		}, {
			layout = React.createElement("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
			build = React.createElement("TextLabel", {
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				FontFace = FONTS.regular,
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 36,
				TextWrapped = true,
				Text = string.format("Git commit: %s", commit.Value:sub(1, 12)),
			}),
			license = React.createElement("TextLabel", {
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				FontFace = FONTS.regular,
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 20,
				TextWrapped = true,
				Text = license.Value,
			}),
		}),
	})
end

return about
