local Mod = GelloCharMod
local FamiliarTools = {}
GelloCharMod.FamiliarTools = FamiliarTools


function FamiliarTools.GetShootingVector(fam)
	local player = fam.Player

	if player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) then
		local mark = Mod:GetEntityData(player, "Marked_Cache")
		if mark == nil or not mark:Exists()  then
			for _, e in pairs(Isaac.FindByType(1000, EffectVariant.TARGET)) do
				local mark = e:ToEffect()
				if mark then
					if mark.State == 0 and mark.SpawnerEntity and GetPtrHash(mark.SpawnerEntity) == GetPtrHash(player) and
						player:GetAimDirection():GetAngleDegrees() == (mark.Position - player.Position):GetAngleDegrees() then

						Mod:SetEntityData(player, "Marked_Cache", mark)
						return ( mark.Position - fam.Position ):Normalized()
					end
				end
			end
		else
			return ( mark.Position - fam.Position ):Normalized()
		end
		return nil
	end

	local dir = player:GetFireDirection()
	if dir == -1 then
		return nil
	elseif dir == 0 then
		return Vector(-1, 0)
	elseif dir == 1 then
		return Vector(0, -1)
	elseif dir == 2 then
		return Vector(1, 0)
	elseif dir == 3 then
		return Vector(0, 1)
	end
end


function FamiliarTools.GetKingBabyTarget(player)
	if not player:HasCollectible(472) then return end -- king baby

	local kingBaby = Mod:GetEntityData(player, "KingBB_Cache")
	if kingBaby == nil or not kingBaby:Exists() then
		for _, e in pairs(Isaac.FindByType(3, FamiliarVariant.KING_BABY)) do
			local f = e:ToFamiliar()
			if f and f.Player and GetPtrHash(f.Player) == GetPtrHash(player) then
				if f.Parent == nil then
					kingBaby = f
					break
				else
					kingBaby = f
				end
			end
		end

		Mod:SetEntityData(player, "KingBB_Cache", kingBaby)
	end
	if kingBaby then
		return kingBaby.Target
	end
end


function FamiliarTools.IsCharmBySiren(fam)
	local helper = Mod:GetEntityData(fam, "SirenHelper_Cache")
	if helper == nil or not helper:Exists() or GetPtrHash(helper.Target) ~= GetPtrHash(fam) then
		Mod:SetEntityData(fam, "SirenHelper_Cache", nil)
		for _, e in pairs(Isaac.FindByType(EntityType.ENTITY_SIREN_HELPER)) do
			if e.Target and GetPtrHash(e.Target) == GetPtrHash(fam) then
				Mod:SetEntityData(fam, "SirenHelper_Cache", e)
				return true, e
			end
		end
	else
		return true, helper
	end

	return false
end