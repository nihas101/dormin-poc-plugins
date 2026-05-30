-- Super Mario World Plugin Logic
Coins = 0
Deaths = 0
BoppedCounter = 0
LevelNumString = "0x0"
GameModeString = "00 Load Nintendo Presents"

function handle_event(msg)
    if msg.type == "coin_collected" then
        Coins = Coins + 1
    elseif msg.type == "death" then
        Deaths = Deaths + 1
    elseif msg.type == "bop" then
        BoppedCounter = BoppedCounter + 1
    elseif msg.type == "tick" then
        if msg.level_id ~= nil then
            LevelNumString = msg.level_id
        end
        if msg.game_mode ~= nil then
            GameModeString = msg.game_mode
        end
    end

    update_ui()
end

function update_ui()
    local html = "Level ID: <span class=\"number\">" .. LevelNumString .. "</span><br/>" ..
        "Total Coins: <span class=\"number\">" .. Coins .. "</span><br/>" ..
        "Total Deaths: <span class=\"number\">" .. Deaths .. "</span><br/>" ..
        "Things Bopped: <span class=\"number\">" .. BoppedCounter .. "</span><br/>" ..
        "Game Mode:<span class=\"number\">" .. GameModeString .. "</span>"
    writeHTML("messagearea", html)
end
