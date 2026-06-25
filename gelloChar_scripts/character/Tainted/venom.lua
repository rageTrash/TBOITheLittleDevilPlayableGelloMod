--[[
	Start:
		Health : B

	On Selection:
		Pocket : XVI - The Tower

	Stats:
		+ 0.2 speed
		+ 1.5 damage
		x0.8 tears

	Ability:
		lagrimas tienen 10% de ser venenosas
		disparar en la misma direccion aumenta la probabilidad

	LV1:
		

	LV2:
		

	LV3:
		
		
]]

local Mod = GelloCharMod
local game = Mod.Game
local pTools = Mod.PlayerTools
local kTools = Mod.KnifeTools

local VENOM_CHANCE = 30 --0.3333 chance
local TEARVEL = Vector(10, 0)
local DIR_TO_VEC = {
	[Direction.NO_DIRECTION] = Vector(0,1),
	[Direction.LEFT]         = Vector(-1,0),
	[Direction.UP]           = Vector(0,-1),
	[Direction.RIGHT]        = Vector(1,0),
	[Direction.DOWN]         = Vector(0,1),
}


return {
	Id = Mod.Enum.Character.GELLO_B11,

	InitPlayer = function(player, init)
		if init then pTools.ReplacePlayerHealth(player, {Black = 2}) end
		player:AddCard(Card.CARD_TOWER)
	end,

	BombInit = function(bomb, rng, parent)
		if rng:RandomInt(VENOM_CHANCE) == 0 then
			tear:AddTearFlags(TearFlags.TEAR_POISON)
		end
	end,
	TearUpdate = function(tear, rng, parent)
		if tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
			if rng:RandomInt(VENOM_CHANCE * 10) == 0 then
				tear:AddTearFlags(TearFlags.TEAR_POISON | TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP)
			end
			return
		end
		if tear.FrameCount == 0 and rng:RandomInt(VENOM_CHANCE) == 0 then
			tear:AddTearFlags(TearFlags.TEAR_POISON | TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP)
		end
	end,
	LaserUpdate = function(laser, rng, parent)
		if laser.SubType == LaserSubType.LASER_SUBTYPE_RING_LUDOVICO then
			if rng:RandomInt(VENOM_CHANCE * 10) == 0 then
				laser:AddTearFlags(TearFlags.TEAR_POISON | TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP)
			end
			return
		end
		if laser.FrameCount == 0 and rng:RandomInt(VENOM_CHANCE) == 0 then
			laser:AddTearFlags(TearFlags.TEAR_POISON | TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP)
		end
	end,
	KnifeUpdate = function(knife, rng, parent)
		if knife:IsFlying() then
			if rng:RandomInt(VENOM_CHANCE) == 0 then
				knife:AddTearFlags(TearFlags.TEAR_POISON)
			end
		elseif kTools.DoesKnifeSwing(knife) then
			if (kTools.IsKnifeSwinging(knife) or kTools.IsKnifeSpining(knife)) and knife:GetSprite():GetFrame() == 1 and rng:RandomInt(VENOM_CHANCE) == 0 then
				knife:AddTearFlags(TearFlags.TEAR_POISON)
			end
		end
	end,

	UpdatePlayer = function(player)
		local venomTimer = Mod:GetEntityData(player, "GelloVomitVenomTime")

		if not venomTimer or not player:IsFrame(3, 0) then return end
			
		local tFlags = player.TearFlags | TearFlags.TEAR_POISON
		local rng = player:GetDropRNG()
		local shootDir = DIR_TO_VEC[player:GetHeadDirection()]
		local angle = shootDir:GetAngleDegrees()
		local vel = TEARVEL + player:GetTearMovementInheritance(shootDir)

		for i=1, Mod:RandomInt(1,2, rng) do
			local tear = Mod:Spawn(2, 0,0, player.Position, vel:Rotated( angle + Mod:RandomFloat(-22.5, 22.5, rng) ) , player):ToTear()
			tear:AddTearFlags(tFlags)
			if tear:GetDropRNG():RandomInt(2) == 0 then tear:AddTearFlags(TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP) end
			tear:ClearTearFlags(TearFlags.TEAR_EXPLOSIVE)
			tear.Color = Color(Mod:RandomInt(95, 110, rng) /255, Mod:RandomInt(232, 255, rng) /255, Mod:RandomInt(118, 136, rng) /255, 1, 0, 0, 0)
			
			tear.CollisionDamage = math.max(player.Damage *1.25, 3.5)
			tear.Height = player.TearHeight
			tear.Scale = Mod:RandomFloat(1.088, 1.124, rng)
			tear.FallingSpeed = Mod:RandomFloat(-4, 0.6, rng)
			tear.FallingAcceleration = Mod:RandomFloat(0.33, 0.65, rng)
		end
		if venomTimer < game:GetFrameCount() then Mod:SetEntityData(player, "GelloVomitVenomTime", nil) end
	end,
}