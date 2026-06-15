--- TODO: Implement logic
-- See: https://github.com/mabako/LiveSplit.LinkToThePast/blob/master/notes/RAM_Map.txt
-- See: http://alttp.run/hacking/index.php?title=SRAM_Map
-- See: http://alttp.run/hacking/index.php?title=RAM
-- See: https://datacrystal.tcrf.net/wiki/The_Legend_of_Zelda/RAM_map

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

local url = "http://127.0.0.1:8091/lttp"

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

--

local SNES_TO_SFC_OFFSET = 2; -- the SFC and SNES scripts don't line up perfectly

local TEXT_ID_LOCATION = 0x01CF0

-- TODO: Read and send the player name along?
local function on_text_loaded()
    local lo = memory.read_u16_le(TEXT_ID_LOCATION, "WRAM")
    local hi = memory.read_u16_be(TEXT_ID_LOCATION + 1, "WRAM")
    local text_id = lo + (hi << 8)

    if text_id >= 0x0D then
        text_id = text_id - SNES_TO_SFC_OFFSET
    end

    console.log("Text loaded: " .. tostring(text_id))

    post_event({
        type = "text_displayed",
        text_id = text_id
    })
end

local function on_text_closed()
    console.log("Text closed")
    post_event({
        type = "text_closed"
    })
end

local MAIN_TEXT_LOADING = 0x0EC4E7
local SECONDARY_TEXT_LOADING = 0x05E1DA
local TEXT_BOX_CLOSE_A = 0x0ECA64
local TEXT_BOX_CLOSE_B = 0x0CC2EB

-- Register execution breakpoints
event.onmemoryexecute(on_text_loaded, MAIN_TEXT_LOADING)
event.onmemoryexecute(on_text_loaded, SECONDARY_TEXT_LOADING)
event.onmemoryexecute(on_text_closed, TEXT_BOX_CLOSE_A)
event.onmemoryexecute(on_text_closed, TEXT_BOX_CLOSE_B)
console.log("ALTTP execution breakpoints registered.")

while true do
    emu.frameadvance()
end
