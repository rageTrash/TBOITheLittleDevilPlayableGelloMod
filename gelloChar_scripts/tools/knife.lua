local Mod = GelloCharMod
local game = Mod.Game


local KnifeTools = {}
GelloCharMod.KnifeTools = KnifeTools



GelloCharMod.KnifeVariant = {
	MOMS_KNIFE = 0,
	BONE_CLUB = 1,
	BONE_SCYTHE = 2,
	DONKEY_JAWBONE = 3,
	BAG_OF_CRAFTING = 4,
	SUMPTORIUM = 5,
	NOTCHED_AXE = 9,
	SPIRIT_SWORD = 10,
	TECH_SWORD = 11,
}

--- taken from repentogon
GelloCharMod.KnifeSubType = {
	DEFAULT = 0,
	PROJECTILE = 1,
	UNKNOW = 2,
	YES_MOTHER = 3,
	CLUB_HIT_BOX = 4,
}


local swingAnim = {
	"Swing", "Swing2",
	"SwingDown", "SwingDown2",

    "AttackRight",
    "AttackLeft",
    "AttackUp",
    "AttackDown",
	
    "SpinRight",
    "SpinLeft",
    "SpinUp",
    "SpinDown",
}

-- taken from Epiphany
local knifeOffset = {
    [1] = 28, -- bone club
    [2] = 40, -- bone knife
    [3] = 28, -- donkey jawbone/berserk club
    [4] = 28, -- bag of crafting
    [9] = 28, -- notched axe
    [10] = 40, -- spirit sword
    [11] = 40, -- tech sword
}

local spiritSword = {
	AngleOffset = {
		[0] = -135,
		[1] = -101.5,
		[2] = -56.5,
		[3] = -11.5,
		[4] = 33.5
	},
	SpinOffset = {
		[2] = -56.5,
		[3] = -11.5,
		[4] = 33.5,
		[5] = 78.5,
		[6] = 123.5,
		[7] = 168.5,
		[8] = 213.5,
		[9] = -101.5,
		[10]= -56.5
	}
}

local knifeRadius = {
	[1] = 30, -- bone club
    [2] = 45, -- bone knife
    [3] = 30, -- donkey jawbone/berserk club
    [4] = 30, -- bag of crafting
    [9] = 30, -- notched axe
    [10] = 36, -- spirit sword
    [11] = 36, -- tech sword
}



function KnifeTools.GetKnifeRadius(knife)
	if type(knife) == "number" then
		return knifeRadius[knife] or 0
	end
	return knifeRadius[knife.Variant] or 0
end

function KnifeTools.GetKnifeOffset(knife)
	if type(knife) == "number" then
		return knifeOffset[knife] or 0
	end
	return knifeOffset[knife.Variant] or 0
end


function KnifeTools.GetKnife(playerKnife)
	if playerKnife == nil then return end
	if playerKnife:ToPlayer() then
		local playerKnife = playerKnife:ToPlayer()
		local knife = playerKnife:GetActiveWeaponEntity() and playerKnife:GetActiveWeaponEntity():ToKnife()
		if knife then return knife end
	end
	return playerKnife:ToKnife()
end


function KnifeTools.DoesKnifeSwing(playerKnife)
	local knife = KnifeTools.GetKnife(playerKnife)

	if knife then
		if knife.Variant == 0 or knife.Variant == 5 then return false end
		return true
	end

	return false
end

if Mod.Repentogon then
	function KnifeTools.IsKnifeSwinging(playerKnife)
		local knife = KnifeTools.GetKnife(playerKnife)

		if knife and knife.SubType == 4 then
			return knife:GetIsSwinging()
		end
		return false
	end


	function KnifeTools.IsKnifeSpining(playerKnife)
		local knife = KnifeTools.GetKnife(playerKnife)

		if knife and knife.SubType == 4 then
			return knife:GetIsSpinAttack()
		end
		return false
	end
else
	function KnifeTools.IsKnifeSwinging(playerKnife)
		local knife = KnifeTools.GetKnife(playerKnife)

		if knife and knife.SubType == 4 then
			local sprite = knife:GetSprite()

			if sprite:GetAnimation():match("Swing") then
				return true
			end
		end
		return false
	end


	function KnifeTools.IsKnifeSpining(playerKnife)
		local knife = KnifeTools.GetKnife(playerKnife)

		if knife and knife.SubType == 4 then
			local sprite = knife:GetSprite()

			if sprite:GetAnimation():match("Spin") then
				return true
			end
		end
		return false
	end
end


function KnifeTools.CanOpenChest(knife)
	local knife = knife:ToKnife()
	if not knife or knife.SubType ~= 4 then return false end

	return Mod.KnifeVariant.BAG_OF_CRAFTING ~= knife.Variant
end


if Mod.Repentogon then
	function KnifeTools.GetEntitiesInKnifeRadius(knife)
		local knife = knife:ToKnife()
		if not knife then return {} end
		
		return knife:GetHitList()
	end
else
	function KnifeTools.GetEntitiesInKnifeRadius(knife)
		local knife = knife:ToKnife()
		if not knife or knife.SubType ~= 4 then return {} end

		local sprite = knife:GetSprite()
		local anim = sprite:GetAnimation()
		local frame = sprite:GetFrame()

		local scale = (knife.SpriteScale.X + knife.SpriteScale.Y) /2

		local extraRotation = 0
		local offset = knifeOffset[knife.Variant] * scale
		local radius = knifeRadius[knife.Variant] * scale

		if anim:match("Attack") then
			extraRotation = spiritSword.AngleOffset[frame]
		elseif anim:match("Spin") then
			extraRotation = spiritSword.SpinOffset[frame]
			radius = 54 * scale
		end
		if not extraRotation then extraRotation = 0 end

		local pos = knife.Position + ( Vector.FromAngle(knife.Rotation):Rotated(extraRotation) * offset )

		return Isaac.FindInRadius(pos, radius)
	end
end
