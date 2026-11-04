const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const inventory_util = require(script.Parent.inventory_util)

const select_slot = ReplicatedStorage.remotes.select_slot

local function on_select_slot(player: Player, slot: unknown): ()
	if type(slot) ~= "number" or not inventory_util.is_hotbar_slot(slot) then
		return
	end
	inventory_util.set_selected_slot(player, slot)
end

local function on_player_removing(player: Player): ()
	inventory_util.clear_selected_slot(player)
end

select_slot.OnServerEvent:Connect(on_select_slot)
Players.PlayerRemoving:Connect(on_player_removing)
