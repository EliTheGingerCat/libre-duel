-- Palette from <https://tailwindcolor.com/>.
-- (Breter98: I cranked down the saturation by 35% bc it was waaay too strong for me).
--[[
Intended usage:
- If applicable, use a contextual colour, such as "error".
- Otherwise, use basic colours, such as "red", "orange", and so on.
- If one wants an even more specific colour, then use a numerical colour, such as "red_50", "red_100", and so on.

The contextual colours and basic colours are just aliases of the numerical colours. These aliases are defined below all the numerical colours.
]]

local colours = {
	["red_50"] = Color3.fromHSV(1.00, 0.033, 1.00),
	["red_100"] = Color3.fromHSV(1.00, 0.072, 1.00),
	["red_200"] = Color3.fromHSV(1.00, 0.137, 1.00),
	["red_300"] = Color3.fromHSV(1.00, 0.240, 1.00),
	["red_400"] = Color3.fromHSV(1.00, 0.397, 1.00),
	["red_500"] = Color3.fromHSV(0.99, 0.539, 0.98),
	["red_600"] = Color3.fromHSV(0.99, 0.650, 0.91),
	["red_700"] = Color3.fromHSV(0.99, 0.650, 0.76),
	["red_800"] = Color3.fromHSV(0.99, 0.617, 0.62),
	["red_900"] = Color3.fromHSV(1.00, 0.533, 0.51),
	["red_950"] = Color3.fromHSV(1.00, 0.579, 0.28),

	["orange_50"] = Color3.fromHSV(0.09, 0.046, 1.00),
	["orange_100"] = Color3.fromHSV(0.10, 0.111, 1.00),
	["orange_200"] = Color3.fromHSV(0.09, 0.221, 1.00),
	["orange_300"] = Color3.fromHSV(0.09, 0.384, 1.00),
	["orange_400"] = Color3.fromHSV(0.09, 0.643, 1.00),
	["orange_500"] = Color3.fromHSV(0.07, 0.650, 1.00),
	["orange_600"] = Color3.fromHSV(0.05, 0.650, 0.96),
	["orange_700"] = Color3.fromHSV(0.04, 0.650, 0.79),
	["orange_800"] = Color3.fromHSV(0.05, 0.650, 0.62),
	["orange_900"] = Color3.fromHSV(0.04, 0.592, 0.50),
	["orange_950"] = Color3.fromHSV(0.04, 0.598, 0.27),

	["amber_50"] = Color3.fromHSV(0.13, 0.052, 1.00),
	["amber_100"] = Color3.fromHSV(0.13, 0.143, 1.00),
	["amber_200"] = Color3.fromHSV(0.13, 0.312, 1.00),
	["amber_300"] = Color3.fromHSV(0.13, 0.527, 1.00),
	["amber_400"] = Color3.fromHSV(0.12, 0.650, 1.00),
	["amber_500"] = Color3.fromHSV(0.10, 0.650, 0.99),
	["amber_600"] = Color3.fromHSV(0.08, 0.650, 0.88),
	["amber_700"] = Color3.fromHSV(0.07, 0.650, 0.73),
	["amber_800"] = Color3.fromHSV(0.07, 0.650, 0.59),
	["amber_900"] = Color3.fromHSV(0.06, 0.617, 0.48),
	["amber_950"] = Color3.fromHSV(0.06, 0.637, 0.27),

	["yellow_50"] = Color3.fromHSV(0.15, 0.058, 1.00),
	["yellow_100"] = Color3.fromHSV(0.15, 0.156, 1.00),
	["yellow_200"] = Color3.fromHSV(0.15, 0.312, 1.00),
	["yellow_300"] = Color3.fromHSV(0.14, 0.566, 1.00),
	["yellow_400"] = Color3.fromHSV(0.13, 0.650, 0.99),
	["yellow_500"] = Color3.fromHSV(0.12, 0.650, 0.94),
	["yellow_600"] = Color3.fromHSV(0.11, 0.650, 0.82),
	["yellow_700"] = Color3.fromHSV(0.10, 0.650, 0.65),
	["yellow_800"] = Color3.fromHSV(0.09, 0.650, 0.54),
	["yellow_900"] = Color3.fromHSV(0.08, 0.592, 0.45),
	["yellow_950"] = Color3.fromHSV(0.07, 0.605, 0.26),

	["lime_50"] = Color3.fromHSV(0.22, 0.058, 1.00),
	["lime_100"] = Color3.fromHSV(0.22, 0.130, 0.99),
	["lime_200"] = Color3.fromHSV(0.22, 0.254, 0.98),
	["lime_300"] = Color3.fromHSV(0.22, 0.436, 0.96),
	["lime_400"] = Color3.fromHSV(0.22, 0.650, 0.90),
	["lime_500"] = Color3.fromHSV(0.23, 0.650, 0.81),
	["lime_600"] = Color3.fromHSV(0.24, 0.650, 0.65),
	["lime_700"] = Color3.fromHSV(0.24, 0.650, 0.49),
	["lime_800"] = Color3.fromHSV(0.23, 0.650, 0.39),
	["lime_900"] = Color3.fromHSV(0.24, 0.539, 0.33),
	["lime_950"] = Color3.fromHSV(0.25, 0.611, 0.18),

	["green_50"] = Color3.fromHSV(0.38, 0.033, 0.99),
	["green_100"] = Color3.fromHSV(0.39, 0.085, 0.99),
	["green_200"] = Color3.fromHSV(0.39, 0.163, 0.97),
	["green_300"] = Color3.fromHSV(0.40, 0.319, 0.95),
	["green_400"] = Color3.fromHSV(0.42, 0.637, 0.88),
	["green_500"] = Color3.fromHSV(0.40, 0.650, 0.79),
	["green_600"] = Color3.fromHSV(0.40, 0.650, 0.65),
	["green_700"] = Color3.fromHSV(0.40, 0.650, 0.51),
	["green_800"] = Color3.fromHSV(0.41, 0.643, 0.40),
	["green_900"] = Color3.fromHSV(0.40, 0.546, 0.33),
	["green_950"] = Color3.fromHSV(0.40, 0.605, 0.18),

	["emerald_50"] = Color3.fromHSV(0.42, 0.046, 0.99),
	["emerald_100"] = Color3.fromHSV(0.41, 0.111, 0.98),
	["emerald_200"] = Color3.fromHSV(0.42, 0.215, 0.96),
	["emerald_300"] = Color3.fromHSV(0.44, 0.390, 0.92),
	["emerald_400"] = Color3.fromHSV(0.45, 0.650, 0.83),
	["emerald_500"] = Color3.fromHSV(0.44, 0.650, 0.74),
	["emerald_600"] = Color3.fromHSV(0.44, 0.650, 0.60),
	["emerald_700"] = Color3.fromHSV(0.45, 0.650, 0.48),
	["emerald_800"] = Color3.fromHSV(0.45, 0.650, 0.38),
	["emerald_900"] = Color3.fromHSV(0.46, 0.650, 0.31),
	["emerald_950"] = Color3.fromHSV(0.46, 0.650, 0.17),

	["teal_50"] = Color3.fromHSV(0.46, 0.033, 0.99),
	["teal_100"] = Color3.fromHSV(0.46, 0.124, 0.99),
	["teal_200"] = Color3.fromHSV(0.47, 0.254, 0.97),
	["teal_300"] = Color3.fromHSV(0.48, 0.455, 0.93),
	["teal_400"] = Color3.fromHSV(0.48, 0.650, 0.84),
	["teal_500"] = Color3.fromHSV(0.48, 0.650, 0.73),
	["teal_600"] = Color3.fromHSV(0.49, 0.650, 0.59),
	["teal_700"] = Color3.fromHSV(0.49, 0.650, 0.47),
	["teal_800"] = Color3.fromHSV(0.49, 0.650, 0.37),
	["teal_900"] = Color3.fromHSV(0.49, 0.559, 0.31),
	["teal_950"] = Color3.fromHSV(0.50, 0.624, 0.18),

	["cyan_50"] = Color3.fromHSV(0.51, 0.046, 1.00),
	["cyan_100"] = Color3.fromHSV(0.51, 0.124, 1.00),
	["cyan_200"] = Color3.fromHSV(0.52, 0.234, 0.99),
	["cyan_300"] = Color3.fromHSV(0.52, 0.436, 0.99),
	["cyan_400"] = Color3.fromHSV(0.52, 0.650, 0.95),
	["cyan_500"] = Color3.fromHSV(0.53, 0.650, 0.86),
	["cyan_600"] = Color3.fromHSV(0.53, 0.650, 0.72),
	["cyan_700"] = Color3.fromHSV(0.54, 0.650, 0.58),
	["cyan_800"] = Color3.fromHSV(0.54, 0.650, 0.47),
	["cyan_900"] = Color3.fromHSV(0.54, 0.546, 0.39),
	["cyan_950"] = Color3.fromHSV(0.55, 0.598, 0.27),

	["sky_50"] = Color3.fromHSV(0.56, 0.039, 1.00),
	["sky_100"] = Color3.fromHSV(0.57, 0.078, 1.00),
	["sky_200"] = Color3.fromHSV(0.56, 0.182, 1.00),
	["sky_300"] = Color3.fromHSV(0.55, 0.358, 1.00),
	["sky_400"] = Color3.fromHSV(0.54, 0.650, 1.00),
	["sky_500"] = Color3.fromHSV(0.55, 0.650, 0.96),
	["sky_600"] = Color3.fromHSV(0.56, 0.650, 0.82),
	["sky_700"] = Color3.fromHSV(0.56, 0.650, 0.66),
	["sky_800"] = Color3.fromHSV(0.56, 0.650, 0.54),
	["sky_900"] = Color3.fromHSV(0.56, 0.637, 0.44),
	["sky_950"] = Color3.fromHSV(0.57, 0.605, 0.29),

	["blue_50"] = Color3.fromHSV(0.59, 0.039, 1.00),
	["blue_100"] = Color3.fromHSV(0.60, 0.091, 1.00),
	["blue_200"] = Color3.fromHSV(0.59, 0.163, 1.00),
	["blue_300"] = Color3.fromHSV(0.59, 0.286, 1.00),
	["blue_400"] = Color3.fromHSV(0.59, 0.442, 1.00),
	["blue_500"] = Color3.fromHSV(0.60, 0.539, 1.00),
	["blue_600"] = Color3.fromHSV(0.61, 0.598, 0.99),
	["blue_700"] = Color3.fromHSV(0.63, 0.592, 0.90),
	["blue_800"] = Color3.fromHSV(0.63, 0.559, 0.72),
	["blue_900"] = Color3.fromHSV(0.62, 0.520, 0.56),
	["blue_950"] = Color3.fromHSV(0.63, 0.481, 0.34),

	["indigo_50"] = Color3.fromHSV(0.63, 0.046, 1.00),
	["indigo_100"] = Color3.fromHSV(0.63, 0.078, 1.00),
	["indigo_200"] = Color3.fromHSV(0.63, 0.143, 1.00),
	["indigo_300"] = Color3.fromHSV(0.64, 0.234, 1.00),
	["indigo_400"] = Color3.fromHSV(0.65, 0.332, 1.00),
	["indigo_500"] = Color3.fromHSV(0.67, 0.410, 1.00),
	["indigo_600"] = Color3.fromHSV(0.69, 0.501, 0.97),
	["indigo_700"] = Color3.fromHSV(0.69, 0.514, 0.84),
	["indigo_800"] = Color3.fromHSV(0.68, 0.494, 0.67),
	["indigo_900"] = Color3.fromHSV(0.68, 0.436, 0.52),
	["indigo_950"] = Color3.fromHSV(0.68, 0.429, 0.30),

	["violet_50"] = Color3.fromHSV(0.69, 0.033, 1.00),
	["violet_100"] = Color3.fromHSV(0.70, 0.052, 1.00),
	["violet_200"] = Color3.fromHSV(0.70, 0.104, 1.00),
	["violet_300"] = Color3.fromHSV(0.70, 0.195, 1.00),
	["violet_400"] = Color3.fromHSV(0.71, 0.312, 1.00),
	["violet_500"] = Color3.fromHSV(0.72, 0.442, 1.00),
	["violet_600"] = Color3.fromHSV(0.74, 0.566, 1.00),
	["violet_700"] = Color3.fromHSV(0.74, 0.630, 0.91),
	["violet_800"] = Color3.fromHSV(0.74, 0.605, 0.75),
	["violet_900"] = Color3.fromHSV(0.74, 0.552, 0.60),
	["violet_950"] = Color3.fromHSV(0.73, 0.566, 0.41),

	["purple_50"] = Color3.fromHSV(0.75, 0.026, 1.00),
	["purple_100"] = Color3.fromHSV(0.75, 0.058, 1.00),
	["purple_200"] = Color3.fromHSV(0.75, 0.111, 1.00),
	["purple_300"] = Color3.fromHSV(0.75, 0.195, 1.00),
	["purple_400"] = Color3.fromHSV(0.76, 0.338, 1.00),
	["purple_500"] = Color3.fromHSV(0.76, 0.468, 1.00),
	["purple_600"] = Color3.fromHSV(0.76, 0.611, 0.98),
	["purple_700"] = Color3.fromHSV(0.77, 0.650, 0.86),
	["purple_800"] = Color3.fromHSV(0.76, 0.585, 0.69),
	["purple_900"] = Color3.fromHSV(0.76, 0.546, 0.55),
	["purple_950"] = Color3.fromHSV(0.76, 0.630, 0.40),

	["fuchsia_50"] = Color3.fromHSV(0.80, 0.026, 1.00),
	["fuchsia_100"] = Color3.fromHSV(0.80, 0.058, 1.00),
	["fuchsia_200"] = Color3.fromHSV(0.80, 0.124, 1.00),
	["fuchsia_300"] = Color3.fromHSV(0.81, 0.221, 1.00),
	["fuchsia_400"] = Color3.fromHSV(0.81, 0.377, 1.00),
	["fuchsia_500"] = Color3.fromHSV(0.81, 0.539, 0.98),
	["fuchsia_600"] = Color3.fromHSV(0.82, 0.650, 0.87),
	["fuchsia_700"] = Color3.fromHSV(0.82, 0.650, 0.72),
	["fuchsia_800"] = Color3.fromHSV(0.82, 0.643, 0.58),
	["fuchsia_900"] = Color3.fromHSV(0.82, 0.546, 0.47),
	["fuchsia_950"] = Color3.fromHSV(0.82, 0.650, 0.31),

	["pink_50"] = Color3.fromHSV(0.91, 0.026, 0.99),
	["pink_100"] = Color3.fromHSV(0.90, 0.052, 0.99),
	["pink_200"] = Color3.fromHSV(0.91, 0.117, 0.99),
	["pink_300"] = Color3.fromHSV(0.91, 0.227, 0.99),
	["pink_400"] = Color3.fromHSV(0.91, 0.390, 0.99),
	["pink_500"] = Color3.fromHSV(0.91, 0.514, 0.97),
	["pink_600"] = Color3.fromHSV(0.91, 0.650, 0.90),
	["pink_700"] = Color3.fromHSV(0.92, 0.650, 0.78),
	["pink_800"] = Color3.fromHSV(0.92, 0.650, 0.64),
	["pink_900"] = Color3.fromHSV(0.93, 0.572, 0.53),
	["pink_950"] = Color3.fromHSV(0.93, 0.617, 0.32),

	["rose_50"] = Color3.fromHSV(0.99, 0.033, 1.00),
	["rose_100"] = Color3.fromHSV(0.99, 0.072, 1.00),
	["rose_200"] = Color3.fromHSV(0.98, 0.130, 1.00),
	["rose_300"] = Color3.fromHSV(0.98, 0.240, 1.00),
	["rose_400"] = Color3.fromHSV(0.97, 0.397, 1.00),
	["rose_500"] = Color3.fromHSV(0.96, 0.572, 1.00),
	["rose_600"] = Color3.fromHSV(0.96, 0.650, 0.93),
	["rose_700"] = Color3.fromHSV(0.95, 0.650, 0.78),
	["rose_800"] = Color3.fromHSV(0.95, 0.650, 0.65),
	["rose_900"] = Color3.fromHSV(0.94, 0.611, 0.54),
	["rose_950"] = Color3.fromHSV(0.95, 0.630, 0.30),

	["grey_50"] = Color3.fromHSV(0, 0.000, 0.99),
	["grey_100"] = Color3.fromHSV(0, 0.000, 0.97),
	["grey_200"] = Color3.fromHSV(0, 0.000, 0.92),
	["grey_300"] = Color3.fromHSV(0, 0.000, 0.86),
	["grey_400"] = Color3.fromHSV(0, 0.000, 0.69),
	["grey_500"] = Color3.fromHSV(0, 0.000, 0.51),
	["grey_600"] = Color3.fromHSV(0, 0.000, 0.40),
	["grey_700"] = Color3.fromHSV(0, 0.000, 0.32),
	["grey_800"] = Color3.fromHSV(0, 0.000, 0.22),
	["grey_900"] = Color3.fromHSV(0, 0.000, 0.16),
	["grey_950"] = Color3.fromHSV(0, 0.000, 0.07),
}

-- Basic colours.

colours.red = colours.red_500
colours.orange = colours.orange_500
colours.amber = colours.amber_500
colours.yellow = colours.yellow_500
colours.lime = colours.lime_500
colours.green = colours.green_500
colours.emerald = colours.emerald_500
colours.teal = colours.teal_500
colours.cyan = colours.cyan_500
colours.sky = colours.sky_500
colours.blue = colours.blue_500
colours.indigo = colours.indigo_500
colours.violet = colours.violet_500
colours.purple = colours.purple_500
colours.fuchsia = colours.fuchsia_500
colours.pink = colours.pink_500
colours.rose = colours.rose_500
colours.grey = colours.grey_500
colours.light_grey = colours.grey_300
colours.dark_grey = colours.grey_700
colours.black = colours.grey_950
colours.white = colours.grey_50

-- Contextual colours.

colours.error = colours.red_400
colours.info = colours.blue_400
colours.success = colours.green_400

return colours
