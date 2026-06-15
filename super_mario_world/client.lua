-- Pure RAM Polling BizHawk Lua client for the dormin Super Mario World plugin

local function encode_json(o)
    if type(o) == "string" then
        return '"' .. o .. '"'
    elseif type(o) == "number" then
        return tostring(o)
    elseif type(o) == "boolean" then
        return tostring(o)
    elseif type(o) == "table" then
        local parts = {}
        for k, v in pairs(o) do
            parts[#parts + 1] = '"' .. k .. '":' .. encode_json(v)
        end
        return "{" .. table.concat(parts, ",") .. "}"
    else
        return "null"
    end
end

local url = "http://127.0.0.1:8091/smw"

-- TODO: What about windows?
local function post_event(payload)
    local message = {
        payload = payload
    }
    local body = encode_json(message)
    local safe = body:gsub("'", "'\\''")
    local cmd = string.format(
        "curl -s -X POST -H 'Content-Type: application/json' --data-binary '%s' '%s' > /dev/null 2>&1", safe, url)
    os.execute(cmd)
end

local WRAM_DOMAIN = "WRAM"

-- WRAM address offsets
-- See: https://www.smwcentral.net/?p=memorymap&game=smw&u=0&address&sizeOperation=%3D&sizeValue&region[]=ram&type=*&description
local ADDR_LIVES  = 0x0DBE
local ADDR_COINS  = 0x0DBF
local ADDR_SCORE  = 0x0F34 -- 3 bytes
local ADDR_LEVEL  = 0x13BF
local ADDR_MODE   = 0x0100

local function get_score()
    local b1 = memory.readbyte(ADDR_SCORE, WRAM_DOMAIN) or 0
    local b2 = memory.readbyte(ADDR_SCORE + 1, WRAM_DOMAIN) or 0
    local b3 = memory.readbyte(ADDR_SCORE + 2, WRAM_DOMAIN) or 0
    return b1 + b2 * 256 + b3 * 65536
end

-- Initialize state variables
local prev_lives = memory.readbyte(ADDR_LIVES, WRAM_DOMAIN)
local prev_coins = memory.readbyte(ADDR_COINS, WRAM_DOMAIN)
local prev_score = get_score()
local prev_level = -1
local prev_mode  = -1

console.log("SMW RAM Polling Client started. Domain: " .. WRAM_DOMAIN)

while true do
    emu.frameadvance()

    local cur_lives = memory.readbyte(ADDR_LIVES, WRAM_DOMAIN)
    local cur_coins = memory.readbyte(ADDR_COINS, WRAM_DOMAIN)
    local cur_score = get_score()
    local cur_level = memory.readbyte(ADDR_LEVEL, WRAM_DOMAIN)
    local cur_mode  = memory.readbyte(ADDR_MODE, WRAM_DOMAIN)

    -- Detect changes and POST events
    if cur_coins > prev_coins then
        post_event({ type = "coin_collected" })
    end

    if cur_lives < prev_lives then
        post_event({ type = "death" })
    end

    if cur_score > prev_score then
        post_event({ type = "bop" })
    end

    if cur_level ~= prev_level or cur_mode ~= prev_mode then
        post_event({
            type = "tick",
            level_id = string.format("0x%02X", cur_level),
            game_mode = string.format("%02X", cur_mode)
        })
    end

    prev_lives = cur_lives
    prev_coins = cur_coins
    prev_score = cur_score
    prev_level = cur_level
    prev_mode  = cur_mode
end
