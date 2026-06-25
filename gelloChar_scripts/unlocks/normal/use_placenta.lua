local Mod = GelloCharMod

local DROP_CHANCE = 0.075
local BLACK_HEART_CHANCE = 100    -- 1%
local FULL_SOUL_HEART_CHANCE = 20 -- 5%

local DropRNG = RNG()
Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, ent)
	if ent:ToNPC() and ent.SpawnerType == 0 and ent.SpawnerEntity == nil and ent.Parent == nil and ent:CanShutDoors() then
		if Mod.PlayerTools.AnyPlayerHasCollectible(Mod.Enum.Item.USE_PLACENTA) then
			DropRNG:SetSeed(ent.InitSeed, 35)
			if DropRNG:RandomFloat() < DROP_CHANCE then
				if DropRNG:RandomInt(BLACK_HEART_CHANCE) == 0 then
					Mod:Spawn(5, 10, 6, ent.Position, Vector.Zero) -- black heart
				elseif DropRNG:RandomInt(FULL_SOUL_HEART_CHANCE) == 0 then
					Mod:Spawn(5, 10, 3, ent.Position, Vector.Zero) -- soul heart
				else
					Mod:Spawn(5, 10, 8, ent.Position, Vector.Zero) -- half soul heart
				end
			end
		end
	end
end)
