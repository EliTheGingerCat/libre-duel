local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local fade = require(script.Parent.Parent.effects.fade)

local create_element = React.createElement

type title_text = {
	top_text: string,
	bottom_text: string?,
}

local function background_transparency(transparency: number): number
	return 0.5 + transparency * 0.5
end

local function stroke_gradient()
	return create_element("UIGradient", {
		Color = ColorSequence.new(Color3.new(1, 1, 1)),
		Rotation = -90,
		Transparency = NumberSequence.new(0, 1),
	})
end

local function title_label(props: {
	text: string,
	top: boolean,
	transparency: React.Binding<number>,
})
	local padding = if props.top then 30 else 20
	return create_element("TextLabel", {
		Name = if props.top then "TopText" else "BottomText",
		AnchorPoint = Vector2.new(0.5, if props.top then 1 else 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.new(17 / 255, 17 / 255, 17 / 255),
		BackgroundTransparency = props.transparency:map(background_transparency),
		BorderSizePixel = 0,
		FontFace = Font.fromId(11702779409, Enum.FontWeight.SemiBold),
		Position = UDim2.new(0.5, 0, 0.5, if props.top then 0 else 10),
		RichText = true,
		Size = UDim2.fromOffset(0, 0),
		Text = props.text,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = if props.top then 100 else 50,
		TextTransparency = props.transparency,
		TextWrapped = true,
		Visible = props.text ~= "",
	}, {
		corner = create_element("UICorner", {
			CornerRadius = UDim.new(0.4, 0),
		}),
		padding = create_element("UIPadding", {
			PaddingLeft = UDim.new(0, padding),
			PaddingRight = UDim.new(0, padding),
			PaddingTop = UDim.new(0, 5),
		}),
		shadow = create_element("UIShadow", {
			BlurRadius = UDim.new(0, 8),
			ShowBehindParent = false,
			Transparency = props.transparency:map(background_transparency),
		}),
		border_stroke = create_element("UIStroke", {
			Name = "BorderStroke",
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Color3.new(1, 1, 1),
			Thickness = 2,
			Transparency = props.transparency,
		}, {
			gradient = create_element(stroke_gradient),
		}),
		text_stroke = create_element("UIStroke", {
			Name = "TextStroke",
			ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
			Color = Color3.new(1, 1, 1),
			Thickness = 1,
			Transparency = props.transparency,
		}, {
			gradient = create_element(stroke_gradient),
		}),
	})
end

local function title()
	local current_title, set_current_title = React.useState(nil :: title_text?)
	local transparency, set_transparency = React.useBinding(1)

	local function effect_titles()
		local animation: thread? = nil

		local function cancel_animation(): ()
			if animation ~= nil and coroutine.status(animation) ~= "dead" then
				task.cancel(animation)
			end
		end

		local function on_title(
			fade_in: number,
			stay: number,
			fade_out: number,
			top_text: string,
			bottom_text: string?
		): ()
			local replacing = animation ~= nil and coroutine.status(animation) ~= "dead"
			cancel_animation()
			set_transparency(if replacing then 0 else 1)
			set_current_title({ top_text = top_text, bottom_text = bottom_text })

			local function animate(): ()
				if not replacing then
					fade(1, 0, fade_in, set_transparency)
				end
				if stay > 0 then
					task.wait(stay)
				end
				fade(0, 1, fade_out, set_transparency)
				set_current_title(nil)
			end

			animation = task.spawn(animate)
		end

		local connection = ReplicatedStorage.remotes.show_title.OnClientEvent:Connect(on_title)

		local function disconnect(): ()
			connection:Disconnect()
			cancel_animation()
		end

		return disconnect
	end

	React.useEffect(effect_titles, {})

	if current_title == nil then
		return nil
	end
	local bottom_text = current_title.bottom_text

	return create_element("ScreenGui", {
		Name = "Title",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		top_text = create_element(title_label, {
			text = current_title.top_text,
			top = true,
			transparency = transparency,
		}),
		bottom_text = if bottom_text ~= nil and bottom_text ~= ""
			then create_element(title_label, {
				text = bottom_text,
				top = false,
				transparency = transparency,
			})
			else nil,
	})
end

return title
