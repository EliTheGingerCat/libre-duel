local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Services
local Remote = ReplicatedStorage.remotes.server_location


Players.PlayerAdded:Connect(function(player)
        local success, responseOrError = pcall(function()
        return HttpService:GetAsync("https://ipinfo.io/json")
    end)

        if success then
        local data = HttpService:JSONDecode(responseOrError)
        local location = data.country .. ", " .. data.city
        print(location)
        Remote:FireClient(player, location)
    end
end)