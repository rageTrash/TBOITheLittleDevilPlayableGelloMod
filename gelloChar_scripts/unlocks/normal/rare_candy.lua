local Mod = GelloCharMod

local recurtion = false
Mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -200, function(_, ent, amount, dmgFlags, src, coolFrames)
	if recurtion then return end

	local srcEnt = src.Entity
	if not srcEnt or ent:ToPlayer() then return end
	local player
	local fam
	if srcEnt.Type == 3 then
		fam = srcEnt:ToFamiliar()
	elseif srcEnt.Parent and srcEnt.Parent.Type == 3 then
		fam = srcEnt.Parent:ToFamiliar()
	elseif srcEnt.SpawnerEntity and srcEnt.SpawnerEntity.Type == 3 then
		fam = srcEnt.SpawnerEntity:ToFamiliar()
	end
	if fam then player = fam.Player end

	if player and player:HasTrinket(Mod.Enum.Trinket.WEIRD_CANDY) then
		local mult = 2-(4/5) ^ math.min( player:GetTrinketMultiplier(Mod.Enum.Trinket.WEIRD_CANDY), 4 )
		if REPENTOGON then
			return { Damage = amount *mult }
		else
			recurtion = true
			ent:TakeDamage(amount *mult, dmgFlags, src, coolFrames)
			recurtion = false
			return false
		end
	end
end)