local addonName, addonTable = ...
local frame = CreateFrame("Frame")

local isActive = false

local function SetFramesClickable(clickable)
    if InCombatLockdown() then
        print("|cffff0000kliker: Cannot change frame state while in combat!|r")
        return
    end

    -- 1. Try iterating through the CompactRaidFrameContainer children (most reliable for Raid-Style frames)
    if CompactRaidFrameContainer then
        local children = {CompactRaidFrameContainer:GetChildren()}
        for _, f in ipairs(children) do
            -- In Classic, these frames often have names like CompactRaidFrame1, etc.
            -- We check if it's a unit frame and if it targets a party member or the player
            if f.unit and (f.unit:find("party") or f.unit:find("player")) then
                f:EnableMouse(clickable)
            end
        end
    end

    -- 2. Fallback: Iterate by name for standard Classic Raid Frame naming
    for i = 1, 40 do
        local f = _G["CompactRaidFrame" .. i]
        if f then
            -- Only disable if it's actually assigned to a unit (party or player)
            if f.unit and (f.unit:find("party") or f.unit:find("player")) then
                f:EnableMouse(clickable)
            end
        end
    end
    
    -- 3. Modern Party Frame fallback (in case some elements use the newer naming)
    for i = 1, 5 do
        local f = _G["CompactPartyFrameMember" .. i]
        if f then
            f:EnableMouse(clickable)
        end
    end

    isActive = not clickable
    local status = clickable and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r"
    print("|cff00ccffkliker:|r Party frame clicking is now " .. status)
end

local function UpdateState()
    local _, instanceType = GetInstanceInfo()
    local isArena = (instanceType == "arena")

    if isArena and not isActive then
        SetFramesClickable(false)
    elseif not isArena and isActive then
        SetFramesClickable(true)
    end
end

-- Events to monitor
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_REGEN_ENABLED" then
        UpdateState()
    else
        -- Delay slightly to ensure frames are initialized after loading screens
        C_Timer.After(2, function()
            UpdateState()
        end)
    end
end)

-- Slash commands
SLASH_KLIKER1 = "/kliker"
SlashCmdList["KLIKER"] = function(msg)
    local _, instanceType = GetInstanceInfo()
    print("|cff00ccffkliker Status:|r")
    print("- Current Zone Type: " .. (instanceType or "none"))
    print("- Clicking Disabled: " .. (isActive and "Yes" or "No"))
    
    if msg == "toggle" then
        SetFramesClickable(isActive)
    elseif msg == "on" then
        SetFramesClickable(false)
    elseif msg == "off" then
        SetFramesClickable(true)
    else
        print("|cff00ccffUsage:|r /kliker [toggle|on|off]")
    end
end
