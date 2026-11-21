const GuiService = game:GetService("GuiService")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const TweenService = game:GetService("TweenService")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const React = require(ReplicatedStorage.Packages.react)
const normalize_rank_history = require(script.Parent.normalize_rank_history)
const profile_types = require(script.Parent.Parent.profile_types)
const scale_animation_time = require(script.Parent.Parent.Parent.effects.scale_animation_time)
const slice_line_by_progress = require(script.Parent.slice_line_by_progress)

const create_element = React.createElement

const GRAPH_HEIGHT = 200
const LABEL_GUTTER = 56
const AXIS_LABEL_HEIGHT = 28
-- keeps the line and the end dot from being cut off at the top and bottom
const PLOT_INSET = 8
const DOT_SIZE = 12
const DRAW_IN_SECONDS = 0.8
const LINE_THICKNESS = 3
const DEFAULT_LINE_COLOUR = COLOURS.emerald_300
const GRID_COLOUR = Color3.new(1, 1, 1)
const LABEL_COLOUR = Color3.fromRGB(200, 200, 200)
const DATE_FORMAT = "MMM D"

const function to_udim2(point: Vector2): UDim2
	return UDim2.fromScale(point.X, point.Y)
end

const function format_date(unix_seconds: number): string
	return DateTime.fromUnixTimestamp(unix_seconds):FormatLocalTime(DATE_FORMAT, "en-us")
end

const function create_grid_line(y: number, rank: number, layout_order: number)
	return create_element("Frame", {
		Name = `grid_{layout_order}`,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, y),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = GRID_COLOUR,
		BackgroundTransparency = 0.9,
		BorderSizePixel = 0,
	}, {
		label = create_element("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(0, -12, 0.5, 0),
			Size = UDim2.fromOffset(LABEL_GUTTER, 24),
			BackgroundTransparency = 1,
			FontFace = FONTS.regular,
			Text = `#{rank}`,
			TextSize = 20,
			TextColor3 = LABEL_COLOUR,
			TextXAlignment = Enum.TextXAlignment.Right,
		}),
	})
end

const function create_date_label(text: string, x: number, alignment: Enum.TextXAlignment)
	return create_element("TextLabel", {
		AnchorPoint = Vector2.new(x, 1),
		Position = UDim2.fromScale(x, 1),
		Size = UDim2.new(0.5, 0, 0, AXIS_LABEL_HEIGHT),
		BackgroundTransparency = 1,
		FontFace = FONTS.regular,
		Text = text,
		TextSize = 20,
		TextColor3 = LABEL_COLOUR,
		TextXAlignment = alignment,
		TextYAlignment = Enum.TextYAlignment.Bottom,
	})
end

-- line graph of rank over time that draws itself in from left to right when mounted
const function rank_history_graph(props: {
	history: { profile_types.rank_point },
	colour: Color3?,
	layout_order: number?,
})
	const function normalize_history(): normalize_rank_history.normalized_rank_history
		return normalize_rank_history(props.history)
	end
	const normalized = React.useMemo(normalize_history, { props.history })
	const path_ref = React.useRef(nil :: Path2D?)
	const dot_ref = React.useRef(nil :: Frame?)

	const function draw_in(): (() -> ())?
		const path = path_ref.current
		const dot = dot_ref.current
		if not path or not dot then
			return nil
		end
		const function draw(progress: number): ()
			const sliced = slice_line_by_progress(normalized.points, progress)
			const control_points = table.create(#sliced)
			for index, point in sliced do
				control_points[index] = Path2DControlPoint.new(to_udim2(point))
			end
			path:SetControlPoints(control_points)
			const head: Vector2? = sliced[#sliced]
			dot.Visible = head ~= nil
			if head then
				dot.Position = to_udim2(head)
			end
		end
		const driver = Instance.new("NumberValue")
		const connection = driver.Changed:Connect(draw)
		const tween = TweenService:Create(
			driver,
			TweenInfo.new(scale_animation_time(DRAW_IN_SECONDS), Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Value = 1 }
		)
		if GuiService.ReducedMotionEnabled then
			driver.Value = 1
		else
			draw(0)
			tween:Play()
		end
		const function cleanup(): ()
			tween:Cancel()
			tween:Destroy()
			connection:Disconnect()
			driver:Destroy()
		end
		return cleanup
	end
	React.useLayoutEffect(draw_in, { normalized })

	const middle_rank = math.round((normalized.best_rank + normalized.worst_rank) / 2)
	const show_middle = middle_rank ~= normalized.best_rank and middle_rank ~= normalized.worst_rank
	const middle_y = if normalized.worst_rank > normalized.best_rank
		then (middle_rank - normalized.best_rank) / (normalized.worst_rank - normalized.best_rank)
		else 0.5
	const line_colour = props.colour or DEFAULT_LINE_COLOUR
	return create_element("Frame", {
		Name = "rank_history_graph",
		LayoutOrder = props.layout_order,
		Size = UDim2.new(1, 0, 0, GRAPH_HEIGHT),
		BackgroundTransparency = 1,
	}, {
		padding = create_element("UIPadding", {
			PaddingTop = UDim.new(0, 16),
			PaddingLeft = UDim.new(0, LABEL_GUTTER),
		}),
		plot = create_element("Frame", {
			Position = UDim2.fromOffset(0, PLOT_INSET),
			Size = UDim2.new(1, 0, 1, -AXIS_LABEL_HEIGHT - PLOT_INSET * 2),
			BackgroundTransparency = 1,
		}, {
			best = create_grid_line(0, normalized.best_rank, 1),
			middle = show_middle and create_grid_line(middle_y, middle_rank, 2),
			worst = normalized.worst_rank ~= normalized.best_rank and create_grid_line(1, normalized.worst_rank, 3),
			line = create_element("Path2D", {
				ref = path_ref,
				Color3 = line_colour,
				Thickness = LINE_THICKNESS,
				ZIndex = 2,
			}),
			dot = create_element("Frame", {
				ref = dot_ref,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(DOT_SIZE, DOT_SIZE),
				BackgroundColor3 = line_colour,
				Visible = false,
				ZIndex = 3,
			}, {
				corner = create_element("UICorner", { CornerRadius = UDim.new(1, 0) }),
			}),
		}),
		first_date = create_date_label(format_date(normalized.first_time), 0, Enum.TextXAlignment.Left),
		last_date = create_date_label(format_date(normalized.last_time), 1, Enum.TextXAlignment.Right),
	})
end

return rank_history_graph
