local E = "E"
local W = "W"
local N = "N"
local S = "S"

local shipx = 0
local shipy = 0
-- offsets from the ship
local wayx = 10
local wayy = -1

local turn_right = function()
    tx = wayx
    ty = wayy
    wayx = -ty
    wayy = tx
end

local turn_left = function()
    tx = wayx
    ty = wayy
    wayx = ty
    wayy = -tx
end


actions = {
    [N] = function (n) wayy = wayy - n end,
    [S] = function (n) wayy = wayy + n end,
    [E] = function (n) wayx = wayx + n end,
    [W] = function (n) wayx = wayx - n end,
    ["L"] = function (n) for i = 1, n / 90 do turn_left() end end,
    ["R"] = function (n) for i = 1, n / 90 do turn_right() end end,
    ["F"] = function (n) shipx = shipx + (wayx * n); shipy = shipy + (wayy * n) end,
}

for line in io.stdin:lines() do
    local command = line:sub(0, 1)
    local val = line:sub(2)
    print(string.format("do %s %s at %d,%d -> %d,%d", command, val, shipx, shipy, wayx, wayy))
    actions[command](val)
end

print(string.format("ended at %d,%d (%d)", shipx, shipy, math.abs(shipx) + math.abs(shipy)))
