local MatchmakingService = game:GetService("MatchmakingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ADJECTIVES = require(ReplicatedStorage.shared.common_words.ADJECTIVES)
local ANIMALS = require(ReplicatedStorage.shared.common_words.ANIMALS)

local function generate_random_username(): string
	local adjective = ADJECTIVES[math.random(1, #ADJECTIVES)]
	local first_adjective_letter = string.sub(adjective, 1, 1)
	-- i want an alliteration so let's look through the ANIMALS array for matches
	local matches: { string } = {}

	for _, v in ANIMALS do
		local first_animal_letter = string.sub(v, 1, 1)
		if first_animal_letter == first_adjective_letter then
			table.insert(matches, v)
		end
	end

    --[[ examples:
        SneakyStoat19
        PretentiousPenguin93
        HappyHorse72
    ]]
	return `{adjective}{matches[math.random(1, #matches)]}{math.random(1, 99)}`
end

return generate_random_username
