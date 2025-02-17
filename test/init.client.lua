local CacheTagger = require(game.ReplicatedStorage.CacheTagger)
CacheTagger:disableTagWarning()

local randomNumberCache = CacheTagger:unstableCache(function()
	return math.random(1, 4)
end, { "number", "quest" })

local s = 0
local t = 0

while wait(1) do
	if s % 2 == 0 and s ~= 0 then
		CacheTagger:revalidateTag(if t % 2 == 0 then "number" else "quest")
		t += 1
	end
	print(randomNumberCache())
	s += 1
end
