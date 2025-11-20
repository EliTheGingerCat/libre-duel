-- Because of the specific values in this calculation, `math.map(time_fraction, 0, 1, 0, transparency_maximum)` simplifies to `time_fraction * transparency_maximum`.

local transparency_maximum = 0.5

return transparency_maximum
