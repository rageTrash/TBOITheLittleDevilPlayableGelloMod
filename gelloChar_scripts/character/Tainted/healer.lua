--[[
	Start:
		Health : R R

	On Selection:
		Pocket : Random Pill
		
		+ 2 friendly gaspers
		+ 1 random familiar

	Stats:
		- 0.2 speed
		- 1.5 damage
		x0.66 tears

	Ability:
		enemigos amistosos recuperan vida si isac esta (muy) cerca
		si un enemigo muere tiene un 20% de revivir como un enemigo amistoso

	LV1:
		al limpiar un cuarto regenera al ultimo enemigo como un amistoso

	LV2:
		los enemigos amistosos resiven 30% menos daño de las explosiones

	LV3:
		mayor area de recuperacion
		cura a los enemigos 30% mas rapido
		
]]
local Mod = GelloCharMod
local pTools = Mod.PlayerTools
local game = Mod.Game
local sfx = Mod.SFX
local itemPool = game:GetItemPool()

--local ENT_FLAGS = EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM | EntityFlag.FLAG_PERSISTENT | EntityFlag.FLAG_NO_SPIKE_DAMAGE
local ENT_FLAGS = EntityFlag.FLAG_PERSISTENT | EntityFlag.FLAG_NO_SPIKE_DAMAGE
local MAX_FRIENDLYS = 12
local HEALTIME = 20
local HEART_OFFSET = Vector(0, -40)

return {
	Id = Mod.Enum.Character.GELLO_B9,
	
	InitPlayer = function(player, init)
		if init then pTools.ReplacePlayerHealth(player, {MaxHearts = 2, Hearts = 4}) end
		local seed = game:GetLevel():GetDungeonPlacementSeed() + player.InitSeed
		if seed == 0 then seed = player.InitSeed end
		player:AddPill(itemPool:GetPill(seed))
		
		local extraHealth = 5 * (game:GetLevel():GetStage() + (Mod.LevelTools.IsAltPath() and 1 or 0) -1)

		for _=1, 3 do
			local ent = Mod:Spawn(EntityType.ENTITY_GAPER, 0, 0, player.Position, Vector.Zero, player)
			ent.MaxHitPoints = ent.MaxHitPoints + extraHealth
			ent.HitPoints = ent.MaxHitPoints
			ent:AddCharmed(EntityRef(player), -1)
			ent:AddEntityFlags(ENT_FLAGS)
			ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		end

		--player:UseActiveItem(CollectibleType.COLLECTIBLE_MONSTER_MANUAL, UseFlag.USE_NOANIM | UseFlag.USE_MIMIC)
		--sfx:Stop(SoundEffect.SOUND_SATAN_GROW)
	end,

	UpdatePlayer = function(player)
		if game:GetRoom():IsClear() then return end
		if player:IsFrame(HEALTIME, 0) then
			for _, e in ipairs(Isaac.FindInRadius(player.Position, 60, EntityPartition.ENEMY)) do
				if e:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
					local maxHitPoints = e.MaxHitPoints
					if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then maxHitPoints = e.MaxHitPoints *1.33 end
					if e.HitPoints < maxHitPoints and e:GetDropRNG():RandomInt(3) == 0 then
						e.HitPoints = math.min(maxHitPoints, e.HitPoints + e.MaxHitPoints / 20)
						local effect = Mod:Spawn(1000, EffectVariant.HEART, 0, e.Position, Vector.Zero, nil):ToEffect()
						effect:GetSprite().Offset = HEART_OFFSET
						effect:FollowParent(e)

						sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1)
					end
				end
			end
		end
	end,

	NPCDeath = function(npc, rng, firstPlayer)
		if npc.MaxHitPoints <= 5 then return end
		local countFriendlies = 0
		for _, e in ipairs(Isaac.GetRoomEntities()) do
			if e:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_PERSISTENT) then countFriendlies = countFriendlies +1 end
		end

		if countFriendlies > 1 and (countFriendlies > MAX_FRIENDLYS or rng:RandomInt(countFriendlies) ~= 0) then return end

		local ent = Mod:Spawn(npc.Type, npc.Variant, npc.SubType, npc.Position, Vector.Zero, firstPlayer)
		ent:AddCharmed(EntityRef(firstPlayer), -1)
		ent:AddEntityFlags(ENT_FLAGS)
		ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		
		ent.MaxHitPoints = ent.MaxHitPoints + 2.5 * (game:GetLevel():GetStage() + (Mod.LevelTools.IsAltPath() and 1 or 0) -1)
		ent.HitPoints = ent.MaxHitPoints
	end,

	PostRoom = function(player)
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then return end
		local ent = Mod:Spawn(EntityType.ENTITY_GAPER, 0, 0, player.Position, Vector.Zero, player)

		ent.MaxHitPoints = ent.MaxHitPoints + 10 * (game:GetLevel():GetStage() + (Mod.LevelTools.IsAltPath() and 1 or 0) -1)
		ent.HitPoints = ent.MaxHitPoints
		ent:AddCharmed(EntityRef(player), -1)
		ent:AddEntityFlags(EntityFlag.FLAG_NO_SPIKE_DAMAGE)
		ent:ClearEntityFlags(EntityFlag.FLAG_PERSISTENT | EntityFlag.FLAG_APPEAR)
		
	end,
}
