local Mod = GelloCharMod
local game = Mod.Game
local pTools = Mod.PlayerTools
local pSave = GelloCharMod.SaveHandler.Player
local SAVE_FLAT_DMG_NAME = "Gello perma damage"
local SAVE_PERMA_STATS_NAME = "Gello extra perma stats"
--[[
{
		dmg = function() return end,
		tears = function() return end,
		speed = function() return end,
		shotspeed = function() return end,
		size = function() return end,
	}
	]]
local tGelloStats = {
	[Mod.Enum.Character.GELLO_B1] = { -- figther
		tears = -0.3,
		speed = -0.15,
	},
	[Mod.Enum.Character.GELLO_B2] = { -- jester
		dmg = -0.5,
		speed = 0.2,
		shotspeed = 0.15,
	},
	[Mod.Enum.Character.GELLO_B3] = { -- tank
		tears = -0.15,
		speed = -0.2,
		size = 0.25,
	},
	[Mod.Enum.Character.GELLO_B4] = { -- scout
		dmg = -1,
		tears = 0.2,
		speed = 0.3,
		size = -0.3,
	},
	[Mod.Enum.Character.GELLO_B5] = { -- singer
		dmg = -1,
		tears = 0.3,
		shotspeed = 0.15,
	},
	[Mod.Enum.Character.GELLO_B6] = { -- explosivo
		dmg = -1,
		speed = 0.15,
		size = -0.15,
	},
	[Mod.Enum.Character.GELLO_B7] = { -- gravediger
		dmg = -0.75,
		speed = -0.2,
	},
	[Mod.Enum.Character.GELLO_B8] = { -- merchant
		dmg = -0.5,
		tears = -0.15,
		speed = -0.15,
	},
	[Mod.Enum.Character.GELLO_B9] = { -- healer
		dmg = -0.75,
		speed = -0.2,
	},
	[Mod.Enum.Character.GELLO_B10] = { -- botanic
		dmg = -1,
		speed = 0.15,
	},
	[Mod.Enum.Character.GELLO_B11] = { -- venom
		dmg = 1.5,
		speed = 0.2,
	},
	[Mod.Enum.Character.GELLO_B12] = { -- geologist
		dmg = 0.5,
		tears = -0.15,
		speed = -0.1,
	},
}

local tGelloMults = {
	[Mod.Enum.Character.GELLO_B1] = { -- figther
		dmg = 1.15,
	},
	[Mod.Enum.Character.GELLO_B6] = { -- explosivo
		tears = 0.66,
	},
	[Mod.Enum.Character.GELLO_B7] = { -- gravediger
		tears = 0.66,
	},
	[Mod.Enum.Character.GELLO_B9] = { -- healer
		tears = 0.75,
	},
	[Mod.Enum.Character.GELLO_B10] = { -- botanic
		tears = 0.75,
	},
	[Mod.Enum.Character.GELLO_B11] = { -- venom
		tears = 0.66,
	},
}

Mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, -2048, function(_, player, cacheflag)
	if cacheflag & CacheFlag.CACHE_SPEED > 0 and pSave("Consume - Notched Axe - Active", player):Get(false) then
		player.MoveSpeed = player.MoveSpeed +0.4
	end

	local pType = player:GetPlayerType()
	if pType == Mod.Enum.Character.GELLO then
		if cacheflag & CacheFlag.CACHE_DAMAGE > 0 then
			player.Damage = player.Damage + 1 * MultiplierHandler:GetPlayerDamageMult(player)
		end
		if cacheflag & CacheFlag.CACHE_FIREDELAY > 0 then
			player.MaxFireDelay = pTools.AddTears(player, -0.3 * MultiplierHandler:GetPlayerTearsMult(player))
		end
		if cacheflag & CacheFlag.CACHE_SPEED > 0 then
			player.MoveSpeed = player.MoveSpeed + 0.12 *MultiplierHandler:GetPlayerSpeedMult(player)
		end
	elseif Mod:IsTaintedGello(player) then
		local dataDmg =       tGelloStats[ Mod:GetGlitchClassCopyDMG(player)]
		local dataTears =     tGelloStats[ Mod:GetGlitchClassCopyTears(player)]
		local dataSpeed =     tGelloStats[ Mod:GetGlitchClassCopySpeed(player)]
		local dataShotSpeed = tGelloStats[ Mod:GetGlitchClassCopyShotSpeed(player)]
		local dataSize =      tGelloStats[ Mod:GetGlitchClassCopySize(player)]

		if cacheflag & CacheFlag.CACHE_DAMAGE > 0 and dataDmg and dataDmg.dmg then
			player.Damage = player.Damage + dataDmg.dmg * MultiplierHandler:GetPlayerDamageMult(player)
		end
		if cacheflag & CacheFlag.CACHE_FIREDELAY > 0 and dataTears and dataTears.tears then
			player.MaxFireDelay = pTools.AddCappedTears(player, dataTears.tears * MultiplierHandler:GetPlayerTearsMult(player))
		end
		if cacheflag & CacheFlag.CACHE_SPEED > 0 and dataSpeed and dataSpeed.speed then
			player.MoveSpeed = player.MoveSpeed + dataSpeed.speed * MultiplierHandler:GetPlayerSpeedMult(player)
		end
		if cacheflag & CacheFlag.CACHE_SHOTSPEED > 0 and dataShotSpeed and dataShotSpeed.shotSpeed then
			player.ShotSpeed = player.ShotSpeed + dataShotSpeed.shotSpeed * MultiplierHandler:GetPlayerShotSpeedMult(player)
		end
		if cacheflag & CacheFlag.CACHE_SIZE > 0 and dataSize and dataSize.size then
			player.SpriteScale = player.SpriteScale * (1 + dataSize.size)
		end
	end
end)

Mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 0, function(_, player, cacheflag)
	local fetalJarRevives = 0
	if Mod.RepentogonPlus then
		fetalJarRevives = player:GetEffects():GetNullEffectNum(Mod.Enum.NullItem.FETAL_JAR_STATS)
	else fetalJarRevives = pSave("Fetal Jar revives", player):Get(0) end
	
	local permaStats = pSave(SAVE_PERMA_STATS_NAME, player):Get({})

	if cacheflag & CacheFlag.CACHE_DAMAGE > 0 then
		local dmgMult = MultiplierHandler:GetPlayerDamageMult(player)
		if player:HasCollectible(Mod.Enum.Item.CURSED_PLUSHIE) then
			local dmg = 1.5 * player:GetCollectibleNum(Mod.Enum.Item.CURSED_PLUSHIE)
			dmg = dmg + (0.5 * player:GetTrinketMultiplier(TrinketType.TRINKET_BLACK_FEATHER) * player:GetCollectibleNum(Mod.Enum.Item.CURSED_PLUSHIE)) -- black feather synergy
			player.Damage = player.Damage + dmg * dmgMult
		end

		local tempDmg = Mod:GetTempDamage(player) + Mod:GetSlowTempDamage(player)
		if tempDmg > 0 then
			player.Damage = player.Damage + tempDmg * dmgMult
		end
		if fetalJarRevives > 0 then
			player.Damage = player.Damage + (fetalJarRevives / 2) * dmgMult
		end


		if permaStats.Damage then
			player.Damage = player.Damage + permaStats.Damage * dmgMult
		end
	end
	
	if cacheflag & CacheFlag.CACHE_FIREDELAY > 0 then
		if permaStats.Tears then
			player.MaxFireDelay = pTools.AddCappedTears(player, permaStats.Tears * MultiplierHandler:GetPlayerTearsMult(player))
		end
		if fetalJarRevives >0 then
			local tears = 30.0 / (player.MaxFireDelay + 1)
			local tearMult = MultiplierHandler:GetPlayerTearsMult(player)
			local cap = 5 * tearMult *1.5 --it can go 50% over the tear cap
			local rest = tears + (0.24 * fetalJarRevives) * tearMult
			
			if rest > cap then
				tears = math.max(cap, tears)
			else
				tears = rest
			end

			player.MaxFireDelay = 30 / tears - 1
		end
	end

	if cacheflag & CacheFlag.CACHE_SPEED > 0 and permaStats.Speed then
		player.MoveSpeed = player.MoveSpeed + permaStats.Speed * MultiplierHandler:GetPlayerSpeedMult(player)
	end

	if cacheflag & CacheFlag.CACHE_SHOTSPEED > 0 and permaStats.ShotSpeed then
		player.ShotSpeed = player.ShotSpeed + permaStats.ShotSpeed * MultiplierHandler:GetPlayerShotSpeedMult(player)
	end

	if cacheflag & CacheFlag.CACHE_RANGE > 0 and permaStats.Range then
		player.TearRange = player.TearRange + permaStats.Range * 40 * MultiplierHandler:GetPlayerRangeMult(player)
	end

	if cacheflag & CacheFlag.CACHE_LUCK > 0 and permaStats.Luck then
		player.Luck = player.Luck + permaStats.Luck
	end

	if cacheflag & CacheFlag.CACHE_SIZE > 0 and fetalJarRevives > 0 then
		player.SpriteScale = player.SpriteScale * (0.85 ^ math.min(fetalJarRevives, 3))
	end

end)

local STATSRNG = RNG()
Mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 2048, function(_, player, cacheflag)
	if Mod:IsTaintedGello(player) then
		local dataDmg =       tGelloMults[ Mod:GetGlitchClassCopyDMG(player) ]
		local dataTears =     tGelloMults[ Mod:GetGlitchClassCopyTears(player) ]
		local dataSpeed =     tGelloMults[ Mod:GetGlitchClassCopySpeed(player) ]
		local dataShotSpeed = tGelloMults[ Mod:GetGlitchClassCopyShotSpeed(player) ]

		if cacheflag & CacheFlag.CACHE_DAMAGE > 0 and dataDmg and dataDmg.dmg then
			player.Damage = player.Damage * dataDmg.dmg
		end
		if cacheflag & CacheFlag.CACHE_FIREDELAY > 0 and dataTears and dataTears.tears then
			player.MaxFireDelay = pTools.ApplyTearsMultiplier(player, dataTears.tears)
		end
		if cacheflag & CacheFlag.CACHE_SPEED > 0 and dataSpeed and dataSpeed.speed then
			player.MoveSpeed = player.MoveSpeed * dataSpeed.speed
		end
		if cacheflag & CacheFlag.CACHE_SHOTSPEED > 0 and dataShotSpeed and dataShotSpeed.shotSpeed then
			player.ShotSpeed = player.ShotSpeed * dataShotSpeed.shotSpeed
		end

		if player:GetPlayerType() == Mod.Enum.Character.GELLO_B13 then
			local seed = game:GetLevel():GetDungeonPlacementSeed() + player.InitSeed
			if seed == 0 then seed = player.InitSeed end
			STATSRNG:SetSeed(seed, 35)

			-- range of x0.85 to x1.2
			if cacheflag & CacheFlag.CACHE_DAMAGE > 0 then
				player.Damage = player.Damage * (0.85 + 0.05 * STATSRNG:RandomInt(8))
			else STATSRNG:Next() end
			if cacheflag & CacheFlag.CACHE_FIREDELAY > 0 then
				player.MaxFireDelay = pTools.ApplyTearsMultiplier(player, 0.85 + 0.05 * STATSRNG:RandomInt(8) )
			else STATSRNG:Next() end
			if cacheflag & CacheFlag.CACHE_SPEED > 0 then
				player.MoveSpeed = player.MoveSpeed * (0.85 + 0.05 * STATSRNG:RandomInt(8))
			else STATSRNG:Next() end
			if cacheflag & CacheFlag.CACHE_SHOTSPEED > 0 then
				player.ShotSpeed = player.ShotSpeed * (0.85 + 0.05 * STATSRNG:RandomInt(8))
			end
		end
	end
end)


local temDamageFun
if GelloCharMod.RepentogonPlus then
	function GelloCharMod:AddTempDamage(player, dmg)
		local eff = player:GetEffects()
		if dmg < 0 then
			eff:RemoveNullEffect(Mod.Enum.NullItem.TEMP_DMG, math.ceil(dmg / 0.025 *-1) )
		elseif dmg > 0 then
			eff:AddNullEffect(Mod.Enum.NullItem.TEMP_DMG, false, math.ceil(dmg / 0.025) )
		end
	end
	function GelloCharMod:AddSlowTempDamage(player, dmg)
		local eff = player:GetEffects()
		if dmg < 0 then
			eff:RemoveNullEffect(Mod.Enum.NullItem.TEMP_DMG_SLOW, math.ceil(dmg / 0.025 *-1) )
		elseif dmg > 0 then
			eff:AddNullEffect(Mod.Enum.NullItem.TEMP_DMG_SLOW, false, math.ceil(dmg / 0.025) )
		end
	end
	function GelloCharMod:GetTempDamage(player)
		return player:GetEffects():GetNullEffectNum(Mod.Enum.NullItem.TEMP_DMG) * 0.025
	end
	function GelloCharMod:GetSlowTempDamage(player)
		return player:GetEffects():GetNullEffectNum(Mod.Enum.NullItem.TEMP_DMG_SLOW) * 0.025
	end
else
	function GelloCharMod:AddTempDamage(player, dmg)
		local eff = player:GetEffects()
		if dmg < 0 then
			eff:RemoveCollectibleEffect(Mod.Enum.Item.TEMP_DMG, math.ceil(dmg / 0.025 *-1))
		elseif dmg > 0 then
			eff:AddCollectibleEffect(Mod.Enum.Item.TEMP_DMG, false, math.ceil(dmg / 0.025) )
		end
	end
	function GelloCharMod:AddSlowTempDamage(player, dmg)
		local eff = player:GetEffects()
		if dmg < 0 then
			eff:RemoveCollectibleEffect(Mod.Enum.Item.TEMP_DMG_SLOW, math.ceil(dmg / 0.025 *-1) )
		elseif dmg > 0 then
			eff:AddCollectibleEffect(Mod.Enum.Item.TEMP_DMG_SLOW, false, math.ceil(dmg / 0.025) )
		end
	end
	function GelloCharMod:GetTempDamage(player)
		return player:GetEffects():GetCollectibleEffectNum(Mod.Enum.Item.TEMP_DMG) * 0.025
	end
	function GelloCharMod:GetSlowTempDamage(player)
		return player:GetEffects():GetCollectibleEffectNum(Mod.Enum.Item.TEMP_DMG_SLOW) * 0.025
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, -1000, function(_, player)
	local itemEffect = player:GetEffects()
	if player:IsFrame(10, 0) then
		local tempDmg = Mod:GetTempDamage(player)
		if tempDmg > 0 then
			-- if damage > 10 removes 0.05 damage
			if tempDmg > 10 then Mod:AddTempDamage(player, -0.05)
			else Mod:AddTempDamage(player, -0.025) end
		end
	end
	
	if player:IsFrame(20, 0) then
		local tempDmg = Mod:GetSlowTempDamage(player)
		if tempDmg > 0 then
			-- if damage > 18.75 removes 0.05 damage
			if tempDmg > 18.75 then Mod:AddSlowTempDamage(player, -0.05)
			else Mod:AddSlowTempDamage(player, -0.025) end
		end
	end
end)