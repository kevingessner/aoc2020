local E = "E"
local W = "W"
local N = "N"
local S = "S"

local RIGHT_TURNS = {[E] = {S, W, N}, [W] = {N, E, S}, [N] = {E, S, W}, [S] = {W, N, E}}

local curdir = E
local x = 0
local y = 0

actions = {
    [N] = function (n) y = y - n end,
    [S] = function (n) y = y + n end,
    [E] = function (n) x = x + n end,
    [W] = function (n) x = x - n end,
    ["L"] = function (n) curdir = RIGHT_TURNS[curdir][(360 - n) / 90] end,
    ["R"] = function (n) curdir = RIGHT_TURNS[curdir][n / 90] end,
    ["F"] = function (n) actions[curdir](n) end,
}

for line in io.stdin:lines() do
    local command = line:sub(0, 1)
    local val = line:sub(2)
    print(string.format("do %s %s at %d,%d -> %s", command, val, x, y, curdir))
    actions[command](val)
end

print(string.format("ended at %d,%d (%d)", x, y, math.abs(x) + math.abs(y)))
