function handle_event(msg)
    print("HandleEvent called with " .. msg.type)

    if msg.type == "text_displayed" then
        local display_message = "#sfc-script-" .. msg.text_id
        callJSFunction("displayScriptDiv", display_message)
    elseif msg.type == "text_closed" then
        callJSFunction("clearAllData")
    else
        print("Unknown msg.type: " .. tostring(msg.type))
    end
end
