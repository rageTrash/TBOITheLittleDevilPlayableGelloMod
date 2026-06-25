local Mod = GelloCharMod
local game = Mod.Game
local pTools = Mod.PlayerTools

local SFX = Mod.SFX
local ACTIVATION_CHANCE = 4 -- 25%

local function ChickenClear(player)
	if player:HasCollectible(Mod.Enum.Item.MOTHERLY_CHICKEN) then
		local RNG = player:GetCollectibleRNG(Mod.Enum.Item.MOTHERLY_CHICKEN)

		if RNG:RandomInt(ACTIVATION_CHANCE) == 0 then
			player:UseActiveItem(CollectibleType.COLLECTIBLE_MONSTER_MANUAL, UseFlag.USE_NOANIM | UseFlag.USE_MIMIC)
			SFX:Stop(SoundEffect.SOUND_SATAN_GROW)

			--SFX:Play(Mod.Enum.Sound.CHICKEN_OUT)
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, -200, function()
	pTools.ForEach(ChickenClear)
end)

Mod:AddCallback(ModCallbacks.WC_WAVE_CHANGE, function()
	pTools.ForEach(ChickenClear)
end, WaveHelper.WaveType.ALL_WAVES_NO_GIDEON)