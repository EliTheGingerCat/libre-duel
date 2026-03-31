--q: what is mitigation?
--a: it's basically silent flagging but not really. like, if someone clicks above 30 cps, or goes too fast, the server will start artificially rejecting the suspect's packets, without actually letting them know they're being flagged.
--...right now it only has support for cps, but adding mitigation for exploits (speed, fly, etc) could be a good idea.

local mitigation_config = {
	cps_treshold = 28,
	rejection_chance = 50, --percentage
	duration = 0.5
}

return mitigation_config
