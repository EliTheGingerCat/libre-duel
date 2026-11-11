-- Roblox has no API to move or remove its jump button, so it's hidden here and replaced by the JumpButton widget.
local function hide_stock_jump(player_gui: PlayerGui): () -> ()
	local connections: { RBXScriptConnection } = {}
	local function hide(button: Instance): ()
		local parent = button.Parent
		if
			button.Name ~= "JumpButton"
			or not button:IsA("GuiObject")
			or not parent
			or parent.Name ~= "TouchControlFrame"
		then
			return
		end
		button.Visible = false
		-- the PlayerModule shows it again whenever it rebuilds the controls
		local function keep_hidden(): ()
			if button.Visible then
				button.Visible = false
			end
		end
		table.insert(connections, button:GetPropertyChangedSignal("Visible"):Connect(keep_hidden))
	end
	for _, descendant in player_gui:GetDescendants() do
		hide(descendant)
	end
	table.insert(connections, player_gui.DescendantAdded:Connect(hide))
	local function disconnect(): ()
		for _, connection in connections do
			connection:Disconnect()
		end
		for _, descendant in player_gui:GetDescendants() do
			if descendant.Name == "JumpButton" and descendant:IsA("GuiObject") then
				descendant.Visible = true
			end
		end
	end
	return disconnect
end

return hide_stock_jump
