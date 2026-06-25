--[[
	Start:
		Health : R R(Bn)

	Stats:
		+ 0.15 speed
		- 1 damage
		x0.8 tears

	Ability:
		On a unclear room, plants can grow randomly in the room.
		If an enemy goes to the same tile it would be trap by the plant
		la planta retendra al enemigo por 5 seg, en el proseso lo dañara cada tanto

	LV1:
		plantas se generan cerca de enemigos
		hacen mas daño

	LV2:
		disparar recarga la habilidad de generar una ola de plantas
		estas plantas desaparencen al no atrapar a un enemigo

	LV3:
		enemigos atrapados reciben doble daño por isac
		
]]

local Mod = GelloCharMod
local game = Mod.Game
local pTools = Mod.PlayerTools
local MAX_LIFETIME = 90 -- 3 seconds

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
	local sp = eff:GetSprite()
	if sp:IsPlaying("Disappear") then return
	elseif sp:IsFinished("Disappear") then
		eff:Remove()
		return
	elseif eff.FrameCount <= 1 then
		eff.DepthOffset = 10
		sp:Play("Appear", true)
		return
	elseif sp:IsPlaying("Appear") then return
	end


	if eff.Timeout == 0 then
		if eff.Target then Mod:SetEntityData(eff.Target, "Grabed By Plant", Mod:GetEntityData(eff.Target, "Grabed By Plant", 0) -1 ) end
		
		sp:Play("Disappear", true)
		return
	end

	if eff.Target then
		local ent = eff.Target
		local grabTime = Mod:GetEntityData(eff, "Plant Wait Min")
		
		if grabTime and game:GetFrameCount() > grabTime  then
			if ent.Position:Distance(eff.Position) > 60 then
				Mod:SetEntityData(eff.Target, "Grabed By Plant", Mod:GetEntityData(eff.Target, "Grabed By Plant", 0) -1 )

				sp:Play("Disappear", true)
				eff.Timeout = 0
				return
			end
		end

		ent.Position = Mod:Lerp(ent.Position, eff.Position, 0.1)

		if eff:IsFrame(5, 0) then
			local dmg = 2.35
			local player = eff.SpawnerEntity and eff.SpawnerEntity:ToPlayer()
			if player then
				dmg = math.max(0.3, player.Damage /10)
				if Mod:GetGlitchClassCopyAbility(player) == Mod.Enum.Character.GELLO_B10 and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
					dmg = dmg * 1.35
				end
			end
			ent:TakeDamage(dmg, 0, EntityRef(eff), 0)
		end
	else
		target = Isaac.FindInRadius(eff.Position, 20, EntityPartition.ENEMY)[1]

		if target then
			if target.HitPoints <= 0 or target.Type == 33 or not target.Visible then
				if not sp:IsPlaying("Idle") then
					sp:Play("Idle", true)
				end
				return
			end
			eff.Target = target
			Mod:SetEntityData(target, "Grabed By Plant", 1 + Mod:GetEntityData(target, "Grabed By Plant", 0) )
			sp:Play("GrabNull", true)
			eff.Timeout = MAX_LIFETIME
			Mod:SetEntityData(eff, "Plant Wait Min", game:GetFrameCount() + 10)
		elseif not sp:IsPlaying("Idle") then
			sp:Play("Idle", true)
		end
	end
end, Mod.Enum.Effect.PLANT)

Mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
	local amount = Mod:GetEntityData(npc, "Grabed By Plant")
	if amount == nil or amount <= 0 then return end
	npc.Velocity = npc.Velocity * (0.985 ^ math.max(amount, 7))
end)

local VINE_GRAB_SPRITE = Sprite()
VINE_GRAB_SPRITE:Load("gfx/gello_ass_plant.anm2", true)
Mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, npc, offset)
	local amount = Mod:GetEntityData(npc, "Grabed By Plant")
	if amount == nil or amount <= 0 then return end

	local renderPos
	if game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then
		renderPos = Isaac.WorldToRenderPosition(npc.Position + npc.PositionOffset) + offset
	else
		renderPos = Isaac.WorldToScreen(npc.Position + npc.PositionOffset)
	end

	local frame = Mod:GetEntityData(npc, "Grabed Plant frame", 0)
	VINE_GRAB_SPRITE:SetFrame("Grab", frame)
	VINE_GRAB_SPRITE:Render(renderPos)
	if game:IsPaused() then return end

	frame = frame +1
	if frame > 16 then frame = 0 end
	Mod:SetEntityData(npc, "Grabed Plant frame", frame)
end)
--[[
local VINE_ARM_SPRITE = Sprite()
VINE_ARM_SPRITE:Load("gfx/gello_ass_plant.anm2", true)
Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function(_, eff, offset)
	local target = eff.Target
	if target == nil then return end
	local effPos = eff.Position
	local targetPos = target.Position
	local dis = math.floor(effPos:Distance(targetPos))

	local renderPos
	if game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then
		renderPos = Isaac.WorldToRenderPosition(effPos + eff.PositionOffset) + offset
	else
		renderPos = Isaac.WorldToScreen(effPos + eff.PositionOffset)
	end

	VINE_ARM_SPRITE.Rotation = (targetPos - effPos):GetAngleDegrees()
	VINE_ARM_SPRITE.FlipY = VINE_ARM_SPRITE.Rotation > 90

	VINE_ARM_SPRITE:Render(renderPos, nil, Vector(32, dis))
end, Mod.Enum.Effect.PLANT)]]


return {
	Id = Mod.Enum.Character.GELLO_B10,

	InitPlayer = function(player, init) if init then pTools.ReplacePlayerHealth(player, {MaxHearts = 1, Bone = 1, Hearts = 4}) end end,
}
