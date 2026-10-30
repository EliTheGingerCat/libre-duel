const ReplicatedStorage = game:GetService("ReplicatedStorage")
const TeleportService = game:GetService("TeleportService")

const data: unknown = TeleportService:GetLocalPlayerTeleportData()
if typeof(data) == "table" then
	const fields = data :: { [string]: unknown }
	if fields.queue_match_id ~= nil or fields.skip_queue == true then
		return
	end
end

local join_queue = ReplicatedStorage:WaitForChild("remotes"):WaitForChild("join_queue")

join_queue:InvokeServer("solo")
