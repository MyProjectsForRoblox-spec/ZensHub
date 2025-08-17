--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local Window = Rayfield:CreateWindow({
   Name = "ZensHub - Dea Hood",
   Icon = "skull",
   LoadingTitle = "ZensHub Interface",
   LoadingSubtitle = "by ZensTeam",
   ShowText = "ZensHub",
   Theme = {
      TextColor = Color3.fromRGB(200, 0, 0),
      Background = Color3.fromRGB(0, 0, 0),
      Topbar = Color3.fromRGB(15, 15, 15),
      Shadow = Color3.fromRGB(10, 10, 10),
      NotificationBackground = Color3.fromRGB(20, 20, 20),
      NotificationActionsBackground = Color3.fromRGB(200, 0, 0),
      TabBackground = Color3.fromRGB(10, 10, 10),
      TabStroke = Color3.fromRGB(255, 255, 255),
      TabBackgroundSelected = Color3.fromRGB(25, 25, 25),
      TabTextColor = Color3.fromRGB(200, 0, 0),
      SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
      ElementBackground = Color3.fromRGB(15, 15, 15),
      ElementBackgroundHover = Color3.fromRGB(35, 35, 35),
      SecondaryElementBackground = Color3.fromRGB(10, 10, 10),
      ElementStroke = Color3.fromRGB(255, 255, 255),
      SecondaryElementStroke = Color3.fromRGB(180, 0, 0),
      SliderBackground = Color3.fromRGB(40, 40, 40),
      SliderProgress = Color3.fromRGB(200, 0, 0),
      SliderStroke = Color3.fromRGB(255, 255, 255),
      ToggleBackground = Color3.fromRGB(15, 15, 15),
      ToggleEnabled = Color3.fromRGB(200, 0, 0),
      ToggleDisabled = Color3.fromRGB(60, 60, 60),
      ToggleEnabledStroke = Color3.fromRGB(255, 255, 255),
      ToggleDisabledStroke = Color3.fromRGB(120, 120, 120),
      ToggleEnabledOuterStroke = Color3.fromRGB(255, 255, 255),
      ToggleDisabledOuterStroke = Color3.fromRGB(140, 140, 140),
      DropdownSelected = Color3.fromRGB(25, 25, 25),
      DropdownUnselected = Color3.fromRGB(15, 15, 15),
      InputBackground = Color3.fromRGB(15, 15, 15),
      InputStroke = Color3.fromRGB(255, 255, 255),
      PlaceholderColor = Color3.fromRGB(120, 120, 120)
   },
   ToggleUIKeybind = "K",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "ZensHub",
      FileName = "DeaHoodConfig"
   },
   Discord = {
      Enabled = true,
      Invite = "uKVQK9UHXm",
      RememberJoins = true
   }
})

local CombatTab = Window:CreateTab("Combat", "sword")
local MovementTab = Window:CreateTab("Movement", "move")
local UtilityTab = Window:CreateTab("Utility", "settings")

local WelcomeSection = CombatTab:CreateSection("Welcome to ZensHub")
local WelcomeLabel = CombatTab:CreateLabel("ZensHub - Dea Hood by ZensTeam", "skull", Color3.fromRGB(200, 0, 0), false)

local function welcomeAnimation()
   Rayfield:Notify({
      Title = "ZensHub Loaded",
      Content = "Initializing ZensHub - Dea Hood...",
      Duration = 2,
      Image = "skull"
   })
   wait(2.1)
   Rayfield:Notify({
      Title = "Ready to Dominate",
      Content = "Unleash chaos with ZensTeam!",
      Duration = 2,
      Image = "flame"
   })
   wait(2.1)
   Rayfield:Notify({
      Title = "Join Us",
      Content = "Connect with ZensTeam: discord.gg/uKVQK9UHXm",
      Duration = 3,
      Image = "message-circle"
   })
end
welcomeAnimation()

local notificationColor = Color3.fromRGB(200, 0, 0)
local CustomizationSection = UtilityTab:CreateSection("UI Customization")
local ColorPicker = UtilityTab:CreateColorPicker({
   Name = "Notification Color",
   Color = notificationColor,
   Flag = "NotificationColor",
   Callback = function(Value)
      notificationColor = Value
      Rayfield:Notify({
         Title = "Color Updated",
         Content = "Notification color changed successfully!",
         Duration = 3,
         Image = "palette",
         ActionsBackground = notificationColor
      })
   end
})

local DiscordPromptToggle = UtilityTab:CreateToggle({
   Name = "Auto-Rejoin Discord Prompt",
   CurrentValue = true,
   Flag = "DiscordPromptToggle",
   Callback = function(Value)
      Window.Discord.Enabled = Value
      Rayfield:Notify({
         Title = "Discord Prompt " .. (Value and "Enabled" or "Disabled"),
         Content = "Auto-rejoin prompt set to " .. (Value and "on" or "off"),
         Duration = 3,
         Image = "message-circle",
         ActionsBackground = notificationColor
      })
   end
})

-- Mod Check System
local SHIELD_ICON = "🛡️"
local CROWN_ICON = "👑"
local STAR_ICON = "⭐"
local NOTIFICATION_DURATION = 6
local SCAN_INTERVAL = 5
local TRACK_HISTORY = true
local playerDatabase = {}
local creatorUserId
local lastScanTime = 0
local modCheckConnection

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

    Rayfield:Notify({
        Title = titles[iconType] or "Important Player",
        Content = string.format("%s has %s the game", displayText, actions[isJoining]),
        Duration = NOTIFICATION_DURATION,
        Image = iconType,
        ActionsBackground = notificationColor
    })

    if TRACK_HISTORY then
        print(string.format("[%s] %s %s - %s", os.date("%X"), iconType, displayText, actions[isJoining]))
    end
end

local function detectPlayerRole(player)
    if not player.Character then return nil end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end
    
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
        task.wait(0.5)
        checkCharacter()
    end)

    if player.Character then
        player.Character:WaitForChild("Humanoid"):GetPropertyChangedSignal("DisplayName"):Connect(checkCharacter)
    end
end

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

local WeaponSection = CombatTab:CreateSection("Weapon Enhancements")
local DividerWeapons = CombatTab:CreateDivider()

local RapidFireToggle = CombatTab:CreateToggle({
   Name = "Rapid Fire",
   CurrentValue = false,
   Flag = "RapidFireToggle",
   Callback = function(Value)
      local backpack = LocalPlayer.Backpack
      local z = backpack:FindFirstChild("[TacticalShotgun]") and backpack["[TacticalShotgun]"].ShootingCooldown
      local e = backpack:FindFirstChild("[Revolver]") and backpack["[Revolver]"].ShootingCooldown
      local n = backpack:FindFirstChild("[Double-Barrel SG]") and backpack["[Double-Barrel SG]"].ShootingCooldown
      
      if Value then
         if z or e or n then
            if z then z.Value = 0 end
            if e then e.Value = 0 end
            if n then n.Value = 0 end
            Rayfield:Notify({
               Title = "Rapid Fire ON",
               Content = "Weapons now fire instantly!",
               Duration = 4,
               Image = "flame",
               ActionsBackground = notificationColor
            })
         else
            RapidFireToggle:Set(false)
            Rayfield:Notify({
               Title = "Error",
               Content = "No compatible weapons found!",
               Duration = 4,
               Image = "alert-circle",
               ActionsBackground = notificationColor
            })
         end
      else
         Rayfield:Notify({
            Title = "Rapid Fire OFF",
            Content = "Weapon cooldowns restored.",
            Duration = 4,
            Image = "flame",
            ActionsBackground = notificationColor
         })
      end
   end
})

local RapidFireKeybind = CombatTab:CreateKeybind({
   Name = "Rapid Fire Keybind",
   CurrentKeybind = "R",
   HoldToInteract = false,
   Flag = "RapidFireKeybind",
   Callback = function()
      RapidFireToggle:Set(not RapidFireToggle.CurrentValue)
   end
})

local KillAuraToggle = CombatTab:CreateToggle({
   Name = "Kill Aura",
   CurrentValue = false,
   Flag = "KillAuraToggle",
   Callback = function(Value)
      if Value then
         spawn(function()
            while Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") do
               local hrp = LocalPlayer.Character.HumanoidRootPart
               for _, player in ipairs(Players:GetPlayers()) do
                  if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
                     local targetHrp = player.Character.HumanoidRootPart
                     local distance = (hrp.Position - targetHrp.Position).Magnitude
                     if distance <= 15 then
                        local humanoid = player.Character.Humanoid
                        humanoid:TakeDamage(100)
                     end
                  end
               end
               wait(0.5)
            end
         end)
         Rayfield:Notify({
            Title = "Kill Aura ON",
            Content = "Dealing damage to nearby players!",
            Duration = 4,
            Image = "zap",
            ActionsBackground = notificationColor
         })
      else
         Rayfield:Notify({
            Title = "Kill Aura OFF",
            Content = "Kill aura disabled.",
            Duration = 4,
            Image = "zap",
            ActionsBackground = notificationColor
         })
      end
   end
})

local espConnections = {}
local ESPToggle = CombatTab:CreateToggle({
   Name = "ESP",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
      if Value then
         for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
               local highlight = Instance.new("Highlight")
               highlight.Adornee = player.Character
               highlight.FillColor = Color3.fromRGB(255, 0, 0)
               highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
               highlight.Parent = player.Character
               espConnections[player] = highlight
            end
         end
         Players.PlayerAdded:Connect(function(player)
            if Value and player ~= LocalPlayer then
               player.CharacterAdded:Connect(function(character)
                  local highlight = Instance.new("Highlight")
                  highlight.Adornee = character
                  highlight.FillColor = Color3.fromRGB(255, 0, 0)
                  highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                  highlight.Parent = character
                  espConnections[player] = highlight
               end)
            end
         end)
         Players.PlayerRemoving:Connect(function(player)
            if espConnections[player] then
               espConnections[player]:Destroy()
               espConnections[player] = nil
            end
         end)
         Rayfield:Notify({
            Title = "ESP ON",
            Content = "Player ESP enabled!",
            Duration = 4,
            Image = "eye",
            ActionsBackground = notificationColor
         })
      else
         for _, highlight in pairs(espConnections) do
            highlight:Destroy()
         end
         espConnections = {}
         Rayfield:Notify({
            Title = "ESP OFF",
            Content = "Player ESP disabled.",
            Duration = 4,
            Image = "eye",
            ActionsBackground = notificationColor
         })
      end
   end
})

local AimbotToggle = CombatTab:CreateToggle({
   Name = "Aimbot (Under Construction)",
   CurrentValue = false,
   Flag = "AimbotToggle",
   Callback = function(Value)
      Rayfield:Notify({
         Title = "Aimbot",
         Content = "Aimbot is under construction and not functional yet.",
         Duration = 4,
         Image = "alert-circle",
         ActionsBackground = notificationColor
      })
   end
})

local TeleportSection = MovementTab:CreateSection("Teleport System")
local DividerTeleport = MovementTab:CreateDivider()

local teleportSpeed = 2
local TeleportSpeedSlider = MovementTab:CreateSlider({
   Name = "Teleport Speed",
   Range = {0.5, 5},
   Increment = 0.5,
   Suffix = "Seconds",
   CurrentValue = teleportSpeed,
   Flag = "TeleportSpeed",
   Callback = function(Value)
      teleportSpeed = Value
      Rayfield:Notify({
         Title = "Speed Updated",
         Content = "Teleport speed set to " .. Value .. " seconds",
         Duration = 3,
         Image = "gauge",
         ActionsBackground = notificationColor
      })
   end
})

local teleportLocations = {
   {Name = "Armor", Position = {528.021973, 47.2999992, -637.093994, 0, 0, -1, 0, 1, 0, 1, 0, 0}, Orientation = {1, 0, 0}, ClickPart = true},
   {Name = "Mask", Position = {-207.504959, 18.8557835, -813.700012, 1, 0.000172610511, -8.63890818e-05, -0.000172677566, 0.999999702, -0.000776890782, 8.62549568e-05, 0.000776905683, 0.999999702}, Orientation = {1, 0, 0}, ClickPart = true},
   {Name = "Gas Station", Position = {554.057495, 34.8749237, -191.4375}, Orientation = {1, 0, 0}},
   {Name = "Lab", Position = {618.619995, 38.125, -252.25}, Orientation = {1, 0, 0}},
   {Name = "School", Position = {-836.26825, -18.0625, 339.35907}, Orientation = {-0.499959469, 0, -0.866048813}},
   {Name = "Arcade", Position = {-921.625, 46.5474625, -113.000046}, Orientation = {1, 0, 0}},
   {Name = "Theater", Position = {-1005.02032, 43.099968, -111.949974}, Orientation = {1, 0, 0}},
   {Name = "Furniture", Position = {-490.099976, 31.3498573, -94.1999969}, Orientation = {1, 0, 0}},
   {Name = "BasketBallCourt", Position = {-876.045227, 27.999836, -492.200012}, Orientation = {-1, 0, 0}},
   {Name = "Uphill Guns", Position = {481.655762, 51.9035988, -626.19696}, Orientation = {1.78813934e-07, -0.000122077588, -3.57627869e-07}},
   {Name = "Downhill Guns", Position = {-584.347229, 12.1478767, -736.2005}, Orientation = {1, -8.63220121e-05, 4.84346927e-08}}
}

local teleportOptions = {}
for _, loc in ipairs(teleportLocations) do
   table.insert(teleportOptions, loc.Name)
end

local TeleportDropdown = MovementTab:CreateDropdown({
   Name = "Select Teleport Location",
   Options = teleportOptions,
   CurrentOption = {teleportOptions[1]},
   MultipleOptions = false,
   Flag = "TeleportDropdown",
   Callback = function(Options)
      local selected = Options[1]
      for _, loc in ipairs(teleportLocations) do
         if loc.Name == selected then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
               local hrp = character.HumanoidRootPart
               local targetCFrame = CFrame.new(Vector3.new(loc.Position[1], loc.Position[2], loc.Position[3]), Vector3.new(loc.Orientation[1], loc.Orientation[2], loc.Orientation[3]))
               local tweenInfo = TweenInfo.new(teleportSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
               local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
               tween:Play()
               tween.Completed:Connect(function()
                  if loc.Name == "Armor" and loc.ClickPart then
                     local part = workspace:FindFirstChild("ArmorPart")
                     if part and clickPart(part) then
                        Rayfield:Notify({
                           Title = "Armor Activated",
                           Content = "Teleported to Armor and clicked part!",
                           Duration = 4,
                           Image = "shield",
                           ActionsBackground = notificationColor
                        })
                     else
                        Rayfield:Notify({
                           Title = "Error",
                           Content = "Armor part not found!",
                           Duration = 4,
                           Image = "alert-circle",
                           ActionsBackground = notificationColor
                        })
                     end
                  else
                     Rayfield:Notify({
                        Title = "Teleported",
                        Content = "Moved to " .. loc.Name,
                        Duration = 3,
                        Image = "map-pin",
                        ActionsBackground = notificationColor
                     })
                  end
               end)
            else
               Rayfield:Notify({
                  Title = "Error",
                  Content = "Character or HumanoidRootPart not found!",
                  Duration = 4,
                  Image = "alert-circle",
                  ActionsBackground = notificationColor
               })
            end
            break
         end
      end
   end
})

local function clickPart(part)
   if part then
      local mouse = LocalPlayer:GetMouse()
      mouse.TargetFilter = nil
      VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, part, 0)
      wait(0.1)
      VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, part, 0)
      return true
   end
   return false
end

local playerOptions = {}
local function updatePlayerOptions()
   playerOptions = {}
   for _, player in ipairs(Players:GetPlayers()) do
      if player ~= LocalPlayer then
         table.insert(playerOptions, player.Name)
      end
   end
end
updatePlayerOptions()
Players.PlayerAdded:Connect(updatePlayerOptions)
Players.PlayerRemoving:Connect(updatePlayerOptions)

local TeleportToPlayerDropdown = MovementTab:CreateDropdown({
   Name = "Teleport to Player",
   Options = playerOptions,
   CurrentOption = {playerOptions[1] or "None"},
   MultipleOptions = false,
   Flag = "TeleportToPlayerDropdown",
   Callback = function(Options)
      local selected = Options[1]
      local targetPlayer = Players:FindFirstChild(selected)
      if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
         local character = LocalPlayer.Character
         if character and character:FindFirstChild("HumanoidRootPart") then
            local hrp = character.HumanoidRootPart
            local targetHrp = targetPlayer.Character.HumanoidRootPart
            local targetCFrame = targetHrp.CFrame * CFrame.new(0, 0, -3)
            local tweenInfo = TweenInfo.new(teleportSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
            tween:Play()
            tween.Completed:Connect(function()
               Rayfield:Notify({
                  Title = "Teleported",
                  Content = "Moved to " .. selected,
                  Duration = 3,
                  Image = "map-pin",
                  ActionsBackground = notificationColor
               })
            end)
         else
            Rayfield:Notify({
               Title = "Error",
               Content = "Your character or HumanoidRootPart not found!",
               Duration = 4,
               Image = "alert-circle",
               ActionsBackground = notificationColor
            })
         end
      else
         Rayfield:Notify({
            Title = "Error",
            Content = "Target player or their HumanoidRootPart not found!",
            Duration = 4,
            Image = "alert-circle",
            ActionsBackground = notificationColor
         })
      end
   end
})

local tpFollowConnection
local originalPosition
local TPFollowToggle = MovementTab:CreateToggle({
   Name = "TP Follow",
   CurrentValue = false,
   Flag = "TPFollowToggle",
   Callback = function(Value)
      local character = LocalPlayer.Character
      if Value then
         local selected = TeleportToPlayerDropdown.CurrentOption[1]
         local targetPlayer = Players:FindFirstChild(selected)
         if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if character and character:FindFirstChild("HumanoidRootPart") then
               originalPosition = character.HumanoidRootPart.CFrame
               tpFollowConnection = RunService.Heartbeat:Connect(function()
                  if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                     local targetHrp = targetPlayer.Character.HumanoidRootPart
                     local humanoid = targetPlayer.Character:FindFirstChild("Humanoid")
                     if humanoid and humanoid.Health > 0 then
                        local hrp = character.HumanoidRootPart
                        local targetCFrame = targetHrp.CFrame * CFrame.new(0, 0, -3)
                        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
                        tween:Play()
                     else
                        TPFollowToggle:Set(false)
                     end
                  else
                     TPFollowToggle:Set(false)
                  end
               end)
               Players.PlayerRemoving:Connect(function(player)
                  if player.Name == selected then
                     TPFollowToggle:Set(false)
                  end
               end)
               Rayfield:Notify({
                  Title = "TP Follow ON",
                  Content = "Following " .. selected .. "!",
                  Duration = 4,
                  Image = "map-pin",
                  ActionsBackground = notificationColor
               })
            else
               TPFollowToggle:Set(false)
               Rayfield:Notify({
                  Title = "Error",
                  Content = "Your character or HumanoidRootPart not found!",
                  Duration = 4,
                  Image = "alert-circle",
                  ActionsBackground = notificationColor
               })
            end
         else
            TPFollowToggle:Set(false)
            Rayfield:Notify({
               Title = "Error",
               Content = "Target player not found!",
               Duration = 4,
               Image = "alert-circle",
               ActionsBackground = notificationColor
            })
         end
      else
         if tpFollowConnection then
            tpFollowConnection:Disconnect()
            tpFollowConnection = nil
         end
         if character and character:FindFirstChild("HumanoidRootPart") and originalPosition then
            local hrp = character.HumanoidRootPart
            local tweenInfo = TweenInfo.new(teleportSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            local tween = TweenService:Create(hrp, tweenInfo, {CFrame = originalPosition})
            tween:Play()
            tween.Completed:Connect(function()
               Rayfield:Notify({
                  Title = "TP Follow OFF",
                  Content = "Returned to original position.",
                  Duration = 4,
                  Image = "map-pin",
                  ActionsBackground = notificationColor
               })
            end)
         end
         originalPosition = nil
      end
   end
})

local PlayerSection = MovementTab:CreateSection("Player Movement")
local DividerPlayer = MovementTab:CreateDivider()

local walkspeed = 16
local WalkspeedSlider = MovementTab:CreateSlider({
   Name = "Walkspeed",
   Range = {16, 200},
   Increment = 1,
   Suffix = "Studs/Sec",
   CurrentValue = walkspeed,
   Flag = "Walkspeed",
   Callback = function(Value)
      walkspeed = Value
      local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
      if humanoid then
         humanoid.WalkSpeed = Value
         Rayfield:Notify({
            Title = "Walkspeed Updated",
            Content = "Walkspeed set to " .. Value .. " studs/sec",
            Duration = 3,
            Image = "move",
            ActionsBackground = notificationColor
         })
      else
         Rayfield:Notify({
            Title = "Error",
            Content = "Humanoid not found!",
            Duration = 3,
            Image = "alert-circle",
            ActionsBackground = notificationColor
         })
      end
   end
})

local jumpPower = 50
local JumpPowerSlider = MovementTab:CreateSlider({
   Name = "Jump Power",
   Range = {50, 200},
   Increment = 1,
   Suffix = "Studs",
   CurrentValue = jumpPower,
   Flag = "JumpPower",
   Callback = function(Value)
      jumpPower = Value
      local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
      if humanoid then
         humanoid.JumpPower = Value
         Rayfield:Notify({
            Title = "Jump Power Updated",
            Content = "Jump power set to " .. Value .. " studs",
            Duration = 3,
            Image = "arrow-up",
            ActionsBackground = notificationColor
         })
      else
         Rayfield:Notify({
            Title = "Error",
            Content = "Humanoid not found!",
            Duration = 3,
            Image = "alert-circle",
            ActionsBackground = notificationColor
         })
      end
   end
})

local flyConnection
local flySpeed = 50
local FlyToggle = MovementTab:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      local character = LocalPlayer.Character
      local hrp = character and character:FindFirstChild("HumanoidRootPart")
      local humanoid = character and character:FindFirstChild("Humanoid")
      
      if Value then
         if hrp and humanoid then
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = hrp
            flyConnection = RunService.RenderStepped:Connect(function()
               local camera = workspace.CurrentCamera
               local direction = Vector3.new(
                  (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
                  (UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and 1 or 0),
                  (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0)
               )
               local targetVelocity = camera.CFrame:VectorToWorldSpace(direction * flySpeed)
               local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear)
               local tween = TweenService:Create(bodyVelocity, tweenInfo, {Velocity = targetVelocity})
               tween:Play()
            end)
            humanoid.PlatformStand = true
            Rayfield:Notify({
               Title = "Fly ON",
               Content = "Use WASD, Space, and Ctrl to fly with smooth velocity!",
               Duration = 4,
               Image = "feather",
               ActionsBackground = notificationColor
            })
         else
            FlyToggle:Set(false)
            Rayfield:Notify({
               Title = "Error",
               Content = "Character or HumanoidRootPart not found!",
               Duration = 4,
               Image = "alert-circle",
               ActionsBackground = notificationColor
            })
         end
      else
         if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
         end
         if hrp then
            local bodyVelocity = hrp:FindFirstChildOfClass("BodyVelocity")
            if bodyVelocity then
               bodyVelocity:Destroy()
            end
         end
         if humanoid then
            humanoid.PlatformStand = false
         end
         Rayfield:Notify({
            Title = "Fly OFF",
            Content = "Flight disabled.",
            Duration = 4,
            Image = "feather",
            ActionsBackground = notificationColor
         })
      end
   end
})

local FlySpeedSlider = MovementTab:CreateSlider({
   Name = "Fly Speed",
   Range = {10, 200},
   Increment = 10,
   Suffix = "Studs/Sec",
   CurrentValue = flySpeed,
   Flag = "FlySpeed",
   Callback = function(Value)
      flySpeed = Value
      Rayfield:Notify({
         Title = "Fly Speed Updated",
         Content = "Fly speed set to " .. Value .. " studs/sec",
         Duration = 3,
         Image = "gauge",
         ActionsBackground = notificationColor
      })
   end
})

local infiniteJumpConnection
local InfiniteJumpToggle = MovementTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfiniteJumpToggle",
   Callback = function(Value)
      if Value then
         infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
               humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
         end)
         Rayfield:Notify({
            Title = "Infinite Jump ON",
            Content = "Jump as many times as you want in the air!",
            Duration = 4,
            Image = "arrow-up",
            ActionsBackground = notificationColor
         })
      else
         if infiniteJumpConnection then
            infiniteJumpConnection:Disconnect()
            infiniteJumpConnection = nil
         end
         Rayfield:Notify({
            Title = "Infinite Jump OFF",
            Content = "Jumping restored to normal.",
            Duration = 4,
            Image = "arrow-up",
            ActionsBackground = notificationColor
         })
      end
   end
})

local UtilitySection = UtilityTab:CreateSection("Utility Features")
local DividerUtility = UtilityTab:CreateDivider()

local noclipConnection
local NoclipToggle = UtilityTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value)
      if Value then
         noclipConnection = RunService.Stepped:Connect(function()
            local character = LocalPlayer.Character
            if character then
               for _, part in ipairs(character:GetDescendants()) do
                  if part:IsA("BasePart") then
                     part.CanCollide = false
                  end
               end
            end
         end)
         Rayfield:Notify({
            Title = "Noclip ON",
            Content = "You can now pass through objects!",
            Duration = 4,
            Image = "ghost",
            ActionsBackground = notificationColor
         })
      else
         if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
         end
         local character = LocalPlayer.Character
         if character and character:FindFirstChild("Humanoid") then
            for _, part in ipairs(character:GetDescendants()) do
               if part:IsA("BasePart") then
                  part.CanCollide = true
               end
            end
         end
         Rayfield:Notify({
            Title = "Noclip OFF",
            Content = "Collisions restored.",
            Duration = 4,
            Image = "ghost",
            ActionsBackground = notificationColor
         })
      end
   end
})

local ModCheckToggle = UtilityTab:CreateToggle({
   Name = "Mod Check",
   CurrentValue = false,
   Flag = "ModCheckToggle",
   Callback = function(Value)
      if Value then
         for _, player in ipairs(Players:GetPlayers()) do
            onPlayerAdded(player)
         end
         Players.PlayerAdded:Connect(onPlayerAdded)
         Players.PlayerRemoving:Connect(onPlayerRemoving)
         modCheckConnection = coroutine.wrap(periodicScan)()
         Rayfield:Notify({
            Title = "Mod Check ON",
            Content = "Monitoring for staff and special players!",
            Duration = 4,
            Image = "shield",
            ActionsBackground = notificationColor
         })
      else
         if modCheckConnection then
            modCheckConnection = nil
         end
         playerDatabase = {}
         Rayfield:Notify({
            Title = "Mod Check OFF",
            Content = "Staff monitoring disabled.",
            Duration = 4,
            Image = "shield",
            ActionsBackground = notificationColor
         })
      end
   end
})

local RespawnButton = UtilityTab:CreateButton({
   Name = "Respawn",
   Callback = function()
      local character = LocalPlayer.Character
      if character then
         local humanoid = character:FindFirstChild("Humanoid")
         if humanoid then
            humanoid.Health = 0
            Rayfield:Notify({
               Title = "Respawned",
               Content = "Character has been reset!",
               Duration = 3,
               Image = "refresh-cw",
               ActionsBackground = notificationColor
            })
         else
            Rayfield:Notify({
               Title = "Error",
               Content = "Humanoid not found!",
               Duration = 3,
               Image = "alert-circle",
               ActionsBackground = notificationColor
            })
         end
      end
   end
})

local InfoSection = UtilityTab:CreateSection("ZensTeam Info")
local InfoParagraph = UtilityTab:CreateParagraph({
   Title = "About ZensHub",
   Content = "ZensHub - Dea Hood by ZensTeam. Join our Discord for updates and support: discord.gg/uKVQK9UHXm"
})

local DestroyButton = UtilityTab:CreateButton({
   Name = "Destroy GUI",
   Callback = function()
      if noclipConnection then noclipConnection:Disconnect() end
      if flyConnection then flyConnection:Disconnect() end
      if infiniteJumpConnection then infiniteJumpConnection:Disconnect() end
      if tpFollowConnection then tpFollowConnection:Disconnect() end
      if modCheckConnection then modCheckConnection = nil end
      for _, highlight in pairs(espConnections) do
         highlight:Destroy()
      end
      local character = LocalPlayer.Character
      if character then
         local humanoid = character:FindFirstChild("Humanoid")
         local hrp = character:FindFirstChild("HumanoidRootPart")
         if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
            humanoid.PlatformStand = false
         end
         if hrp then
            local bodyVelocity = hrp:FindFirstChildOfClass("BodyVelocity")
            if bodyVelocity then
               bodyVelocity:Destroy()
            end
         end
         for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
               part.CanCollide = true
            end
         end
      end
      playerDatabase = {}
      Rayfield:Notify({
         Title = "GUI Destroyed",
         Content = "ZensHub has been terminated. All mods disabled.",
         Duration = 3,
         Image = "trash-2",
         ActionsBackground = notificationColor
      })
      wait(1)
      Rayfield:Destroy()
   end
})

LocalPlayer.CharacterAdded:Connect(function(character)
   local humanoid = character:WaitForChild("Humanoid")
   humanoid.WalkSpeed = walkspeed
   humanoid.JumpPower = jumpPower
end)
