local Mod = GelloCharMod
local game = Mod.Game

local RerollRNG = RNG()
Mod:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_INIT, -200, function(_, pickup)
	if not Mod.PlayerTools.AnyPlayerHasCollectible(Mod.Enum.Item.CURSED_PLUSHIE) then return end
	local room = game:GetRoom()
	
	if room:IsFirstVisit() or room:GetFrameCount() > pickup.FrameCount then
		if pickup.SubType == 3 then
			RerollRNG:SetSeed(pickup.InitSeed, 35)
			if RerollRNG:RandomInt(20) == 0 then -- 5% to repleace a soul heart to a black heart
				pickup:Morph(5, 10, 6, true)
			end
		elseif pickup.SubType == 8 then
			RerollRNG:SetSeed(pickup.InitSeed, 35)
			if RerollRNG:RandomInt(40) == 0 then -- 2.5% to repleace a half soul heart to a black heart
				pickup:Morph(5, 10, 6, true)
			end
		end
	end
end, 10)


Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_ , player)
	if player:HasCollectible(Mod.Enum.Item.CURSED_PLUSHIE) then
		local prevBlackNum = Mod:GetEntityData(player, "BlackHeartNum", nil)
		local currentBlackNum = Mod.PlayerTools.GetTotalBlackHearts(player)

		if not prevBlackNum or prevBlackNum ~= currentBlackNum then
			Mod.PlayerTools.DoCache(player, CacheFlag.CACHE_DAMAGE)
			Mod:SetEntityData(player, "BlackHeartNum", currentBlackNum)
		end
	end
end)