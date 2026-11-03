local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

const conch = require(ReplicatedStorage.Packages.conch)

const get_owner = require(script.Parent.Parent.util.get_owner)

local owner = Players[get_owner("username")]
local user = conch.get_user(owner)
conch.give_roles(user, "super-user")
