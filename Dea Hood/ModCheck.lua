--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local SHIELD_ICON = "🛡️"  -- Staff
local CROWN_ICON = "👑"   -- Owner
local STAR_ICON = "⭐"    -- Star Player (can report)
local NOTIFICATION_DURATION = 6
local SCAN_INTERVAL = 5  -- Seconds between scans
local TRACK_HISTORY = true

local playerDatabase = {}
local creatorUserId
local lastScanTime = 0

local function getCreatorId()
    local success, result = pcall(function()
        if game.CreatorType == Enum.CreatorType.User then
            return game.CreatorId
        end
        return nil
    end)
    return success and result or nil
end

creatorUserId = getCreatorId()

local function sendAlert(iconType, player, isJoining)
    local titles = {
        [SHIELD_ICON] = "⚠️ Staff Presence",
        [CROWN_ICON] = "👑 Owner Alert",
        [STAR_ICON] = "⭐ Star Player"
    }

    local actions = {
        [true] = "joined",
        [false] = "left"
    }

    local displayText = player.DisplayName ~= player.Name 
        and string.format("(@%s) %s", player.DisplayName, player.Name)
        or player.Name

    StarterGui:SetCore("SendNotification", {
        Title = titles[iconType] or "Important Player",
        Text = string.format("%s has %s the game", displayText, actions[isJoining]),
        Duration = NOTIFICATION_DURATION,
        Icon = iconType
    })

    if TRACK_HISTORY then
        print(string.format("[%s] %s %s - %s", os.date("%X"), iconType, displayText, actions[isJoining]))
    end
end

local function detectPlayerRole(player)
    if not player.Character then return nil end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end
    
    -- Check for special roles
    if creatorUserId and player.UserId == creatorUserId then
        return CROWN_ICON
    end

    local displayName = humanoid.DisplayName
    
    if displayName:find(SHIELD_ICON) then
        return SHIELD_ICON
    elseif displayName:find(CROWN_ICON) then
        return CROWN_ICON
    elseif displayName:find(STAR_ICON) then
        return STAR_ICON
    end

    return nil
end

-- Player monitoring system
local function monitorPlayer(player)
    if player == LocalPlayer then return end

    local lastKnownRole = nil

    local function checkCharacter()
        if not player.Character then return end

        local currentRole = detectPlayerRole(player)
        
        if currentRole ~= lastKnownRole then
            if currentRole then
                sendAlert(currentRole, player, true)
            elseif lastKnownRole then
                sendAlert(lastKnownRole, player, false)
            end
            lastKnownRole = currentRole
        end
    end

    checkCharacter()

    player.CharacterAdded:Connect(function()
        task.wait(0.5)  -- Allow time for character to load
        checkCharacter()
    end)

    if player.Character then
        player.Character:WaitForChild("Humanoid"):GetPropertyChangedSignal("DisplayName"):Connect(checkCharacter)
    end
end

-- Player join/leave handlers
local function onPlayerAdded(player)
    playerDatabase[player] = {
        joinTime = os.time(),
        displayName = player.DisplayName
    }
    monitorPlayer(player)
end

local function onPlayerRemoving(player)
    local data = playerDatabase[player]
    if data then
        local role = detectPlayerRole(player)
        if role then
            sendAlert(role, player, false)
        end
        playerDatabase[player] = nil
    end
end

local function periodicScan()
    while true do
        task.wait(SCAN_INTERVAL)
        for player, data in pairs(playerDatabase) do
            if player.Character then
                local currentRole = detectPlayerRole(player)
                if currentRole ~= data.lastRole then
                    if currentRole then
                        sendAlert(currentRole, player, true)
                    elseif data.lastRole then
                        sendAlert(data.lastRole, player, false)
                    end
                    data.lastRole = currentRole
                end
            end
        end
    end
end

-- Initial setup
for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
coroutine.wrap(periodicScan)()
