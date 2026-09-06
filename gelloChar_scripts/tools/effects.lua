local Mod = GelloCharMod
local game = Mod.Game
local EffectTools = {}
GelloCharMod.EffectTools = EffectTools


if not Mod.Repentogon then
	function EffectTools.AddBaited(ent, entRef, duration)
		if ent:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then return end
		local d = Mod:GetEntityData(ent, "Effects Tools", {})
		d.BaitedEffect = d.BaitedEffect or {}
		d.BaitedEffect.Duration = (d.BaitedEffect.Duration or 0) + duration
		d.BaitedEffect.EntityRef = entRef
		Mod:SetEntityData(ent, "Effects Tools", d)
	end

	function EffectTools.AddBleeding(ent, entRef, duration)
		if ent:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then return end
		local d = Mod:GetEntityData(ent, "Effects Tools", {})
		d.BleedingEffect = d.BleedingEffect or {}
		d.BleedingEffect.Duration = (d.BleedingEffect.Duration or 0) + duration
		d.BleedingEffect.EntityRef = entRef
		Mod:SetEntityData(ent, "Effects Tools", d)
	end

	function EffectTools.AddBrimstoneMark(ent, entRef, duration)
		if ent:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then return end
		local d = Mod:GetEntityData(ent, "Effects Tools", {})
		d.BrimMarkEffect = d.BrimMarkEffect or {}
		d.BrimMarkEffect.Duration = (d.BrimMarkEffect.Duration or 0) + duration
		d.BrimMarkEffect.EntityRef = entRef
		Mod:SetEntityData(ent, "Effects Tools", d)
	end

	local slowColor = Color(1,1,1,1, 0.16, 0.16, 0.2) -- close enough
	function EffectTools.AddIce(ent, entRef, duration)
		if ent:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then return end
		local d = Mod:GetEntityData(ent, "Effects Tools", {})
		d.IceEffect = d.IceEffect or {}
		d.IceEffect.Duration = (d.IceEffect.Duration or 0) + duration
		d.IceEffect.EntityRef = entRef
		Mod:SetEntityData(ent, "Effects Tools", d)

		ent:AddSlowing(entRef, duration, 0.5, slowColor)
	end

	function EffectTools.AddKnockback(ent, entRef, pushDir, duration, takeDmgInImpact)
		if ent:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then return end
		local d = Mod:GetEntityData(ent, "Effects Tools", {})
		d.KnockEffect = d.KnockEffect or {}
		d.KnockEffect.Duration = math.min((d.KnockEffect.Duration or 0) + duration, 15)
		d.KnockEffect.Push = pushDir
		d.KnockEffect.TakeDmg = takeDmgInImpact
		d.KnockEffect.EntityRef = entRef
		Mod:SetEntityData(ent, "Effects Tools", d)
	end

	function EffectTools.AddMagnetized(ent, entRef, duration)
		if ent:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then return end
		local d = Mod:GetEntityData(ent, "Effects Tools", {})
		d.MagneEffect = d.MagneEffect or {}
		d.MagneEffect.Duration = (d.MagneEffect.Duration or 0) + duration
		d.MagneEffect.EntityRef = entRef
		Mod:SetEntityData(ent, "Effects Tools", d)
	end

	function EffectTools.AddWeakness(ent, entRef, duration)
		if ent:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then return end
		local d = Mod:GetEntityData(ent, "Effects Tools", {})
		d.WeakEffect = d.WeakEffect or {}
		d.WeakEffect.Duration = (d.WeakEffect.Duration or 0) + duration
		d.WeakEffect.EntityRef = entRef
		Mod:SetEntityData(ent, "Effects Tools", d)
	end
else
	function EffectTools.AddBaited(ent, entRef, duration)
		ent:AddBaited(entRef, duration)
	end

	function EffectTools.AddBleeding(ent, entRef, duration)
		ent:AddBleeding(entRef, duration)
	end

	function EffectTools.AddBrimstoneMark(ent, entRef, duration)
		ent:AddBrimstoneMark(entRef, duration)
	end

	function EffectTools.AddIce(ent, entRef, duration)
		ent:AddIce(entRef, duration)
	end

	function EffectTools.AddKnockback(ent, entRef, pushDir, duration, takeDmgInImpact)
		ent:AddKnockback(entRef, pushDir, duration, takeDmgInImpact)
	end

	function EffectTools.AddMagnetized(ent, entRef, duration)
		ent:AddMagnetized(entRef, duration)
	end

	function EffectTools.AddWeakness(ent, entRef, duration)
		ent:AddWeakness(entRef, duration)
	end
end

if not Mod.Repentogon and not EffectTools.Fun then
	function EffectTools.Fun(_, npc)
		local d = Mod:GetEntityData(npc, "Effects Tools", nil)
		if not d or (d.LastCheckFrame and game:GetFrameCount() == d.LastCheckFrame) then return end

		if d.BaitedEffect then
			d.BaitedEffect.Duration = d.BaitedEffect.Duration -1
			if d.BaitedEffect.Duration < 0 then
				npc:ClearEntityFlags(EntityFlag.FLAG_BAITED)
				d.BaitedEffect = nil
			elseif not npc:HasEntityFlags(EntityFlag.FLAG_BAITED) then
				npc:AddEntityFlags(EntityFlag.FLAG_BAITED)
			end
		end
		if d.BleedingEffect then
			d.BleedingEffect.Duration = d.BleedingEffect.Duration -1
			if d.BleedingEffect.Duration < 0 then
				npc:ClearEntityFlags(EntityFlag.FLAG_BLEED_OUT)
				d.BleedingEffect = nil
			elseif not npc:HasEntityFlags(EntityFlag.FLAG_BLEED_OUT) then
				npc:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
			end
		end
		if d.BrimMarkEffect then
			d.BrimMarkEffect.Duration = d.BrimMarkEffect.Duration -1
			if d.BrimMarkEffect.Duration < 0 then
				npc:ClearEntityFlags(EntityFlag.FLAG_BRIMSTONE_MARKED)
				d.BrimMarkEffect = nil
			elseif not npc:HasEntityFlags(EntityFlag.FLAG_BRIMSTONE_MARKED) then
				npc:AddEntityFlags(EntityFlag.FLAG_BRIMSTONE_MARKED)
			end
		end
		if d.IceEffect then
			d.IceEffect.Duration = d.IceEffect.Duration -1
			if d.IceEffect.Duration < 0 then
				npc:ClearEntityFlags(EntityFlag.FLAG_ICE)
				d.IceEffect = nil
			elseif not npc:HasEntityFlags(EntityFlag.FLAG_ICE) then
				npc:AddEntityFlags(EntityFlag.FLAG_ICE)
			end
		end
		if d.KnockEffect then
			d.KnockEffect.Duration = d.KnockEffect.Duration -1
			if d.KnockEffect.Duration < 0 then
				npc:ClearEntityFlags(EntityFlag.FLAG_KNOCKED_BACK)
				d.KnockEffect = nil
			elseif not npc:HasEntityFlags(EntityFlag.FLAG_KNOCKED_BACK) then
				npc:AddEntityFlags(EntityFlag.FLAG_KNOCKED_BACK)
			end
			if d.KnockEffect and d.KnockEffect.TakeDmg and not npc:HasEntityFlags(EntityFlag.FLAG_APPLY_IMPACT_DAMAGE) then
				npc:AddEntityFlags(EntityFlag.FLAG_APPLY_IMPACT_DAMAGE)
				d.KnockEffect.TakeDmg = nil
			end
			if d.KnockEffect.Push and npc:HasEntityFlags(EntityFlag.FLAG_KNOCKED_BACK) then
				npc.Velocity = d.KnockEffect.Push
			end
		end
		if d.MagneEffect then
			d.MagneEffect.Duration = d.MagneEffect.Duration -1
			if d.MagneEffect.Duration < 0 then
				npc:ClearEntityFlags(EntityFlag.FLAG_MAGNETIZED)
				d.MagneEffect = nil
			elseif not npc:HasEntityFlags(EntityFlag.FLAG_MAGNETIZED) then
				npc:AddEntityFlags(EntityFlag.FLAG_MAGNETIZED)
			end
		end
		if d.WeakEffect then
			d.WeakEffect.Duration = d.WeakEffect.Duration -1
			if d.WeakEffect.Duration < 0 then
				npc:ClearEntityFlags(EntityFlag.FLAG_WEAKNESS)
				d.WeakEffect = nil
			elseif not npc:HasEntityFlags(EntityFlag.FLAG_WEAKNESS) then
				npc:AddEntityFlags(EntityFlag.FLAG_WEAKNESS)
			end
		end

		d.LastCheckFrame = game:GetFrameCount()
		Mod:SetEntityData(npc, "Effects Tools", d)
	end
	Mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, EffectTools.Fun)
end