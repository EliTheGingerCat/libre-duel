local queue_record = require(script.Parent.queue_record)

local function start(player: Player, mode: queue_record.mode): ()
	if player:GetAttribute("QueueMode") ~= mode then
		player:SetAttribute("QueueStartedAt", workspace:GetServerTimeNow())
	end
	player:SetAttribute("QueueTeleporting", false)
	player:SetAttribute("QueueMode", mode)
end

local function clear(player: Player): ()
	player:SetAttribute("QueueMode", nil)
	player:SetAttribute("QueueStartedAt", nil)
	player:SetAttribute("QueueTeleporting", nil)
end

return {
	clear = clear,
	start = start,
}
