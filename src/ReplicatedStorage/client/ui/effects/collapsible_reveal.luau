local ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const get_ui_scale_factor = require(script.Parent.get_ui_scale_factor)
const use_ui_motion = require(script.Parent.Parent.components.hooks.use_ui_motion)

const create_element = React.createElement

export type props = {
	shown: boolean,
	name: string?,
	layout_order: number?,
	-- extra space that collapses together with the content, used instead of a list layout's padding
	gap: number?,
	-- pushes the content down inside the gap, for gaps that belong above the content
	top_offset: number?,
	fade: boolean?,
	children: unknown?,
}

const function is_visible(value: number): boolean
	return value > 0.001
end

const function is_clipped(value: number): boolean
	return value < 0.999
end

const function invert(value: number): number
	return 1 - value
end

-- slides its children open and closed by animating its height between 0 and the measured content height
const function collapsible_reveal(props: props)
	const motion = use_ui_motion(if props.shown then 1 else 0)
	const gap = props.gap or 0
	const height, set_height = React.useBinding(0)
	const content_ref = React.useRef(nil :: GuiObject?)
	const function measure(content: GuiObject): ()
		set_height(content.AbsoluteSize.Y / math.max(0.001, get_ui_scale_factor(content)))
	end
	const function measure_on_mount(): ()
		if content_ref.current then
			measure(content_ref.current)
		end
	end
	React.useLayoutEffect(measure_on_mount, {})
	const function reveal_size(values: { motion: number, height: number }): UDim2
		return UDim2.new(1, 0, 0, (values.height + gap) * values.motion)
	end
	return create_element("Frame", {
		Name = props.name,
		LayoutOrder = props.layout_order,
		BackgroundTransparency = 1,
		Size = React.joinBindings({ motion = motion, height = height }):map(reveal_size),
		Visible = motion:map(is_visible),
		ClipsDescendants = motion:map(is_clipped),
	}, {
		content = create_element(if props.fade then "CanvasGroup" else "Frame", {
			ref = content_ref,
			Position = UDim2.fromOffset(0, props.top_offset or 0),
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			GroupTransparency = if props.fade then motion:map(invert) else nil,
			[React.Change.AbsoluteSize] = measure,
		}, props.children),
	})
end

return collapsible_reveal
