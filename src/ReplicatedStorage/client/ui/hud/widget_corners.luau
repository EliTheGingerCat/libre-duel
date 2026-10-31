export type controller = {
	get: () -> number,
	set: (number) -> (),
	disconnect: () -> (),
}

local function widget_corners(content: GuiObject): controller
	local roundness: number? = nil
	local connections: { [UICorner]: RBXScriptConnection } = {}

	local function apply(corner: UICorner): ()
		if roundness ~= nil then
			local radius = UDim.new(roundness / 200, 0)
			if corner.CornerRadius ~= radius then
				corner.CornerRadius = radius
			end
		end
	end

	local function watch(descendant: Instance): ()
		if descendant:IsA("UICorner") then
			connections[descendant] = descendant:GetPropertyChangedSignal("CornerRadius"):Connect(function()
				apply(descendant)
			end)
			apply(descendant)
		end
	end

	local function unwatch(descendant: Instance): ()
		if descendant:IsA("UICorner") then
			local connection = connections[descendant]
			if connection then
				connection:Disconnect()
				connections[descendant] = nil
			end
		end
	end

	local function get(): number
		if roundness ~= nil then
			return roundness
		end
		for _, descendant in content:GetDescendants() do
			if descendant:IsA("UICorner") then
				local radius = descendant.CornerRadius
				local parent = descendant.Parent
				local size = if parent and parent:IsA("GuiObject") then parent.AbsoluteSize else Vector2.one
				local fraction = radius.Scale + radius.Offset / math.max(1, math.min(size.X, size.Y))
				return math.clamp(math.round(200 * fraction), 0, 100)
			end
		end
		return 0
	end

	local function set(value: number): ()
		roundness = math.clamp(value, 0, 100)
		for corner in connections do
			apply(corner)
		end
	end

	local added_connection = content.DescendantAdded:Connect(watch)
	local removing_connection = content.DescendantRemoving:Connect(unwatch)
	for _, descendant in content:GetDescendants() do
		watch(descendant)
	end

	local function disconnect(): ()
		added_connection:Disconnect()
		removing_connection:Disconnect()
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)
	end

	return { get = get, set = set, disconnect = disconnect }
end

return widget_corners
