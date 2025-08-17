local z = game:GetService("Players").LocalPlayer.Backpack["[TacticalShotgun]"].ShootingCooldown
local e = game:GetService("Players").LocalPlayer.Backpack["[Revolver]"].ShootingCooldown
local n = game:GetService("Players").LocalPlayer.Backpack["[Double-Barrel SG]"].ShootingCooldown
local s = game.Players.LocalPlayer

if s or z or e or n then
	z.Value = 0
	e.Value = 0
	n.Value = 0
end
