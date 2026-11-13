-- What each on-screen touch button does when pressed and released.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local inventory_state = require(script.Parent.Parent.inventory.inventory_state)
local tablist_state = require(script.Parent.Parent.visuals.tablist_state)
local tool_state = require(ReplicatedStorage.client.tools.tool_state)

export type action = { press: () -> (), release: () -> () }

local local_player = Players.LocalPlayer

local function nothing(): () end

const JUMP_BIND = "touch_jump"

local jumping = false

-- Holding keeps jumping, like the stock button.
local function press_jump(): ()
	if jumping then
		return
	end
	jumping = true
	local function jump(): ()
		local character = local_player.Character
		local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
		if humanoid then
			humanoid.Jump = true
		end
	end
	-- The ControlModule overwrites Humanoid.Jump every frame at Input priority, so this has to run right after it.
	RunService:BindToRenderStep(JUMP_BIND, Enum.RenderPriority.Input.Value + 1, jump)
end

local function release_jump(): ()
	if jumping then
		jumping = false
		RunService:UnbindFromRenderStep(JUMP_BIND)
	end
end

local function tool_button(button: string, click_type: string): action
	local function press(): ()
		-- counts towards the server's cps check like a mouse click would
		ReplicatedStorage.remotes.mouse_click:FireServer(click_type)
		tool_state.on_button_requested:Fire(button, true)
	end
	local function release(): ()
		tool_state.on_button_requested:Fire(button, false)
	end
	return { press = press, release = release }
end

local function toggle_inventory(): ()
	inventory_state.set_enabled(not inventory_state.enabled)
end

local function toggle_tablist(): ()
	tablist_state.set_pinned(not tablist_state.pinned)
end

const TOUCH_ACTIONS: { [string]: action } = {
	JumpButton = { press = press_jump, release = release_jump },
	AttackButton = tool_button("attack", "attack"),
	UseItemButton = tool_button("use", "use"),
	InventoryButton = { press = toggle_inventory, release = nothing },
	TablistButton = { press = toggle_tablist, release = nothing },
}

return TOUCH_ACTIONS
