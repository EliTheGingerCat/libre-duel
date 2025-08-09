local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Services
local keybinds = require(script.Parent.modules.keybinds)
local Remote = ReplicatedStorage.remotes.server_location
local LocalPlayer = Players.LocalPlayer
local tablist = LocalPlayer.PlayerGui:WaitForChild("ScreenGui")
local pingText = tablist.Frame:WaitForChild("6") -- reactlua made the ping texts name 6 for no reason .-.
local serverLocation = tablist.Frame:WaitForChild("7")
local pingColors = {
    good = Color3.fromHex("85dd32"), 
    mid = Color3.fromHex("fed023"),
    bad = Color3.fromHex("b14c4e")
}
-- Variables



local function tablistFunc()
    if UserInputService:IsKeyDown(keybinds.tablist) then
        tablist.Frame.Visible = true
        
        local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000) 
        
        if ping <= 90 then
            pingText.TextColor3 = pingColors.good
        elseif ping <= 120 then
            pingText.TextColor3 = pingColors.mid
        else
            pingText.TextColor3 = pingColors.bad
        end
        
        pingText.Text = "Ping: " .. ping .. " ms"
    
    else
        tablist.Frame.Visible = false
    end
end

Remote.OnClientEvent:Connect(function(data)
    serverLocation.Text = data
    print(data)
end)    
RunService.Heartbeat:Connect(tablistFunc)

