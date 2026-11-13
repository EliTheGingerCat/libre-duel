const ReplicatedStorage = game:GetService("ReplicatedStorage")

const map_data = require(ReplicatedStorage.shared.maps.map_data)

const MAP_ROOT = script.Parent.map

-- For now, these are unused: MAP_DESCRIPTION, MAP_ICON, MAP_AUTHORS.

const MAP_DATA: map_data.map_data = {
	MAP_NAME = script.Parent.Name,
	MAP_DESCRIPTION = "Just a test map...",
	MAP_ICON = 123123213,
	MAP_AUTHORS = {
		"breter98",
		"Jane Doe",
	},
	BRIDGE = MAP_ROOT.bridge,
	TEAM1 = {
		CAGE = MAP_ROOT.team1_base.Cage1,
		GOAL = MAP_ROOT.team1_base.Goal1,
		SPAWN = MAP_ROOT.team1_base.Spawn1,
	},
	TEAM2 = {
		CAGE = MAP_ROOT.team2_base.Cage2,
		GOAL = MAP_ROOT.team2_base.Goal2,
		SPAWN = MAP_ROOT.team2_base.Spawn2,
	},
}

return MAP_DATA
