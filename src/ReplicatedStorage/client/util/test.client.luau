local ReplicatedStorage = game:GetService("ReplicatedStorage")
local join_queue = ReplicatedStorage:WaitForChild("remotes"):WaitForChild("join_queue")

join_queue:InvokeServer("solo")
