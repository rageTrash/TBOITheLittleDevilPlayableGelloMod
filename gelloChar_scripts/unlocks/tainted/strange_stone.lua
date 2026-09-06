
local Mod = GelloCharMod
local game = Mod.Game
local SFX = Mod.SFX
local pTools = Mod.PlayerTools


local function AddFam(player)
	if not player:HasTrinket(Mod.Enum.Trinket.STRANGE_STONE) or game:GetRoom():IsClear() or player:GetTrinketRNG(Mod.Enum.Trinket.STRANGE_STONE):RandomInt(3) > 0 then
		return
	end

	local effects = player:GetEffects()
	local RNG = player:GetTrinketRNG(Mod.Enum.Trinket.STRANGE_STONE)
	for i=1, player:GetTrinketMultiplier(Mod.Enum.Trinket.STRANGE_STONE) do
		local data = Mod:GetRandomSpawnableFam(RNG)
		if data.IsTrinket then
			effects:AddTrinketEffect(data.ID, 1)
		else
			effects:AddCollectibleEffect(data.ID, 1)
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, -100, function() pTools.ForEach(AddFam) end)