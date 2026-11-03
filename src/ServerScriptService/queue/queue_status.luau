const queue_record = require(script.Parent.queue_record)

local function start(player: Player, mode: queue_record.mode): ()
	if player:GetAttribute("queue_mode") ~= mode then
		player:SetAttribute("queue_started_at", workspace:GetServerTimeNow())
	end
	player:SetAttribute("queue_teleporting", false)
	player:SetAttribute("queue_mode", mode)
end

local function clear(player: Player): ()
	player:SetAttribute("queue_mode", nil)
	player:SetAttribute("queue_started_at", nil)
	player:SetAttribute("queue_teleporting", nil)
end

return {
	clear = clear,
	start = start,
}
