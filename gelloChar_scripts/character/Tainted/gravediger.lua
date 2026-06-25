--[[
	Start:
		Health : R(Bn)
		
	On Selection:
		Pocket : XII - Death
		+2 friendly skeleton

	Stats:
		- 0.2 speed
		- 1 damage
		x 0.75 tears

	Ability:
		matar a un enemigo tiene un 50% de que genere un esqueleto
		el esqueleto obtine la cantidad de vida de ese enemigo
		no genera esqueletos si la vida total da 75 o mas

	LV1:
		al matar a un enemigo, los esqueletos, recuperan 10% de la vida maxima del enemigo matado
		matar a un enemigo tiene 10% de ser un esqueleto explosivo

	LV2:
		matar a un enemigo tiene 20% de ser un esqueleto explosivo
		esqueltos son inmunes a las explosiones

	LV3:
		no genera esqueletos si la vida total da 160 o mas
		matar a un jefe genera 4 esqueletos com mucha vida (cada uno con 1/4 de la vida del jefe)
]]

local Mod = GelloCharMod
local game = Mod.Game
local pTools = Mod.PlayerTools

local EXPLOSIVE_SKELY_CHANCE = 8
local REVENANT_SKELY_CHANCE = 25
local MAX_TOTAL_HEALTH = 100

--local ENT_FLAGS = EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM | EntityFlag.FLAG_PERSISTENT | EntityFlag.FLAG_NO_SPIKE_DAMAGE
local ENT_FLAGS = EntityFlag.FLAG_PERSISTENT | EntityFlag.FLAG_NO_SPIKE_DAMAGE

return {
	Id = Mod.Enum.Character.GELLO_B7,

	InitPlayer = function(player, init)
		if init then pTools.ReplacePlayerHealth(player, {Bone = 1, Hearts = 2}) end
		--player:AddCard(Card.CARD_DEATH)

		local rng = RNG()
		rng:SetSeed(game:GetLevel():GetDungeonPlacementSeed(), player.InitSeed %30 +10)

		local extraHealth = 5 * (game:GetLevel():GetStage() + (Mod.LevelTools.IsAltPath() and 1 or 0) -1)
		for _=1, 2 do
			local t = EntityType.ENTITY_BONY
			if rng:RandomInt(EXPLOSIVE_SKELY_CHANCE) == 0 then
				t = EntityType.ENTITY_BLACK_BONY
			elseif rng:RandomInt(REVENANT_SKELY_CHANCE) == 0 then
				t = EntityType.ENTITY_REVENANT
			end
			local ent = Mod:Spawn(t, 0, 0, player.Position, Vector.Zero, player)
			ent:AddCharmed(EntityRef(player), -1)
			ent:AddEntityFlags(ENT_FLAGS)
			ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

			ent.MaxHitPoints = ent.MaxHitPoints + extraHealth
			ent.HitPoints = ent.MaxHitPoints
		end
	end,

	NPCDeath = function(npc, rng, firstPlayer)
		if npc.MaxHitPoints <= 5 or npc:AddEntityFlags(EntityFlag.FLAG_FRIENDLY) then return end
		
		local skelyTotalHealth = 0
		for _, e in ipairs(Isaac.FindByType(EntityType.ENTITY_BONY)) do
			if e:HasEntityFlags(ENT_FLAGS) then
				skelyTotalHealth = skelyTotalHealth + e.MaxHitPoints
			end
		end
		for _, e in ipairs(Isaac.FindByType(EntityType.ENTITY_BLACK_BONY)) do
			if e:HasEntityFlags(ENT_FLAGS) then
				skelyTotalHealth = skelyTotalHealth + e.MaxHitPoints
			end
		end
		for _, e in ipairs(Isaac.FindByType(EntityType.ENTITY_REVENANT)) do
			if e:HasEntityFlags(ENT_FLAGS) then
				skelyTotalHealth = skelyTotalHealth + e.MaxHitPoints
			end
		end

		if skelyTotalHealth >= MAX_TOTAL_HEALTH or rng:RandomInt(5) ~= 0 then return end -- if the total skeletons health is less than 100 has a 20% to spawn a skeleton

		local t = EntityType.ENTITY_BONY
		if rng:RandomInt(EXPLOSIVE_SKELY_CHANCE) == 0 then
			t = EntityType.ENTITY_BLACK_BONY
		elseif rng:RandomInt(REVENANT_SKELY_CHANCE) == 0 then
			t = EntityType.ENTITY_REVENANT
		end
		local skely = Mod:Spawn(t, 0, 0, npc.Position, Vector.Zero, firstPlayer)
		skely:AddCharmed(EntityRef(firstPlayer), -1)
		skely:AddEntityFlags(ENT_FLAGS)
		skely:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		
		skely.MaxHitPoints = npc.MaxHitPoints + 5 * (game:GetLevel():GetStage() + (Mod.LevelTools.IsAltPath() and 1 or 0) -1)
		skely.HitPoints = skely.MaxHitPoints
	end,

	PostRoom = function(player)
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then return end
		if player:GetActiveItem(ActiveSlot.SLOT_POCKET2) == CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER then
			player:RemoveCollectible(CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER, true, ActiveSlot.SLOT_POCKET2)
		end

		local room = game:GetRoom()
		if not room:IsFirstVisit() then return end

		local seed = player.InitSeed + room:GetDecorationSeed()
		if seed == 0 then seed = 1  end

		roomRNG:SetSeed(seed, 30)

		if roomRNG:RandomInt(3) == 0 then
			player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER, ActiveSlot.SLOT_POCKET2, true)
		end
	end,
}
