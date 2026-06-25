local Mod = GelloCharMod
local pTools = Mod.PlayerTools

local GALLUS_CHANCE = 10
local MINI_ISAAC_GALLUS_SUBTYPE = 100 
local GALLUS_ANIM_PATH = "gfx/familiar/minisaac_gallus.anm2"


local DropRNG = RNG()
Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, ent)
	if ent:ToNPC() and ent.SpawnerType == 0 then
		if pTools.AnyPlayerHasCollectible(Mod.Enum.Item.GALLUS) then
			DropRNG:SetSeed(ent.InitSeed, 35)

			if DropRNG:RandomInt(GALLUS_CHANCE) ~= 0 then return end
			local player
			pTools.ForEach(function(p)
				if p:HasCollectible(Mod.Enum.Item.GALLUS) then
					if not player or player.Position:Distance(fam.Position) > p.Position:Distance(fam.Position) then
						player = p
					end
				end
			end)
			local fam = player:AddMinisaac(ent.Position, false)
			fam.SubType = MINI_ISAAC_GALLUS_SUBTYPE
			fam.MaxHitPoints = 25
			fam.HitPoints = 25

			Mod:SetEntityData(fam, "GallusSpecialAppear", true)
		end
	end
end)

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear)
	if tear.FrameCount == 0 then
		local spawner = tear.SpawnerEntity
		if spawner and spawner.Type == 3 and spawner.Variant == FamiliarVariant.MINISAAC and spawner.SubType == MINI_ISAAC_GALLUS_SUBTYPE then
			tear:ChangeVariant(1)
			tear.CollisionDamage = tear.CollisionDamage * 1.35
			tear.Scale = tear.Scale * 1.25
		end
	end
end)

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	if fam.SubType == MINI_ISAAC_GALLUS_SUBTYPE then
		local sp = fam:GetSprite()
		if sp:GetFilename() ~= GALLUS_ANIM_PATH then
			sp:Load(GALLUS_ANIM_PATH, true)

			if Mod:GetEntityData(fam, "GallusSpecialAppear", false) then
				sp:Play("GallusAppear", true)
				Mod:SetEntityData(fam, "GallusSpecialAppear", false)
			end
		end
	end
end, FamiliarVariant.MINISAAC)