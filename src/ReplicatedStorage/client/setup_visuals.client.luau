local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.vendor.ReactLua.React)
local ReactRoblox = require(ReplicatedStorage.vendor.ReactLua.ReactRoblox)
local main = require(script.Parent.visuals.main)

local local_player = Players.LocalPlayer
local player_gui = local_player:WaitForChild("PlayerGui") :: PlayerGui

local tree = ReactRoblox.createRoot(Instance.new("Folder"))
tree:render(ReactRoblox.createPortal(React.createElement(main), player_gui))
