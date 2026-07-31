local Mod = GelloCharMod

local DROP_CHANCE = 0.075
local BLACK_HEART_CHANCE = 100    -- 1%
local FULL_SOUL_HEART_CHANCE = 20 -- 5%

local DropRNG = RNG()
Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, ent)
	if ent:ToNPC() and ent.SpawnerType == 0 and ent.SpawnerEntity == nil and ent.Parent == nil and ent:CanShutDoors() then
		if not Mod.PlayerTools.AnyPlayerHasCollectible(Mod.Enum.Item.USE_PLACENTA) then return end
		if not Mod.Game:GetRoom():IsFirstVisit() then return end

		DropRNG:SetSeed(ent.InitSeed, 35)
		if DropRNG:RandomFloat() >= DROP_CHANCE then return end
		
		if DropRNG:RandomInt(BLACK_HEART_CHANCE) == 0 then
			Mod:Spawn(5, 10, 6, ent.Position, Vector.Zero, nil, DropRNG:Next()) -- black heart
		elseif DropRNG:RandomInt(FULL_SOUL_HEART_CHANCE) == 0 then
			Mod:Spawn(5, 10, 3, ent.Position, Vector.Zero, nil, DropRNG:Next()) -- soul heart
		else
			Mod:Spawn(5, 10, 8, ent.Position, Vector.Zero, nil, DropRNG:Next()) -- half soul heart
		end
	end
end)
