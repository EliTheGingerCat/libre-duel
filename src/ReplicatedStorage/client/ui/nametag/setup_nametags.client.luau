local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local React = require(ReplicatedStorage.Packages.react)
local ReactRoblox = require(ReplicatedStorage.Packages["react-roblox"])

local create_element = React.createElement

local nametag = require(script.Parent.Parent.visuals.nametag)


local function give_nametag_to_entity(entity: Model)
    local head = entity:WaitForChild("Head")

    local humanoid = entity:WaitForChild("Humanoid") :: Humanoid

    local container = Instance.new("Folder")
    local tree = ReactRoblox.createRoot(container)

    local function render_health(health: number)
    tree:render(ReactRoblox.createPortal(create_element(nametag, {
        adornee = head,
        name = entity.Name,
        extra_text = `♥ {math.round(health)}`,
    }), head))
    end

    local health_connection = humanoid.HealthChanged:Connect(render_health)
    render_health(humanoid.Health)

    head.Destroying:Once(function()
        health_connection:Disconnect()
        tree:unmount()
        container:Destroy()
    end)
end

for _, player in Players:GetPlayers() do
    player.CharacterAdded:Connect(function(character)
        give_nametag_to_entity(character)
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        give_nametag_to_entity(character)
    end)
end)
