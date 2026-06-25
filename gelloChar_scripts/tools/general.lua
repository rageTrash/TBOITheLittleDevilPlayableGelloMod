local rng = GelloCharMod.RNG
local Mod = GelloCharMod
local game = Mod.Game



function GelloCharMod:Error(str, lvl, justWarning, justDebug)
	if justWarning then
		if REPENTOGON then
			Console.PrintWarning(("[Gello Character] Warning - ".. tostring(str) ))
		else
			print(("[Gello Character] Warning - ".. tostring(str) ))
		end
		Isaac.DebugString(("[Gello Character] Warning - ".. tostring(str) ))
	elseif justDebug then
		Isaac.DebugString(("[Gello Character] Debug - ".. tostring(str) ))
	else
		error(("[Gello Character] Error - ".. tostring(str) ), lvl+1)
	end
end


function GelloCharMod:Spawn(t, v, s, pos, vel, spawner, seed)
	local t = t or 0
	local v = v or 0
	local s = s or 0
	local pos = pos or Vector.Zero
	local vel = vel or Vector.Zero
	local seed = seed or Random()
	if seed == 0 then seed = 1 end

	return game:Spawn(t, v, pos, vel, spawner, s, seed)
end



function GelloCharMod:Lerp(vec1, vec2, percent)
    return vec1 * (1 - percent) + vec2 * percent
end

function GelloCharMod:NormalLerp(val1, val2, percent)
    return val1 + percent * (val2 - val1)
end



function GelloCharMod:TimeToFrame(time)
	if type(time) == "number" then
		return time * 30
	end
	if type(time) ~= "table" then return 0 end
	local frames = 0
	local min = min or 0
	local sec = sec or 0

	if type(time.F) == "number" then
		frames = time.F
	end
	if type(time.S) == "number" then
		frames = frames + (time.S *30)
	end
	if type(time.M) == "number" then
		frames = frames + (time.M *60 *30)
	end
	if type(time.H) == "number" then
		frames = frames + (time.H *60 *60 *30)
	end
	return frames
end



function GelloCharMod:IsHardMode()
	return game.Difficulty & 1 == 1
end


function GelloCharMod:GetFloorNum(countAscent)
	local level = game:GetLevel()
	local floorNum = level:GetStage()
	if countAscent and level:IsAscent() then
		floorNum = 7 + (6-floorNum)
	end
	return floorNum
end



function GelloCharMod:RoundToClosest(num, offset)
	local offset = 10^(offset or 0)
	local num = math.floor((num *offset) + 0.5)

	return num / offset
end



function GelloCharMod:RandomFloat(Min, Max, RNG)
	local Min = Min or 0
	local Max = Max or 0
	local RNG = RNG or rng

	if Min > Max then
		local trans = Min
		Min = Max
		Max = trans
	end

	return Min + RNG:RandomFloat() * (Max - Min)
end

function GelloCharMod:RandomInt(Min, Max, RNG)
	local Min = Min or 0
	local Max = Max or 0
	local RNG = RNG or rng

	if Min > Max then
		local trans = Min
		Min = Max
		Max = trans
	end

	Min = GelloCharMod:RoundToClosest(Min)
	Max = GelloCharMod:RoundToClosest(Max)

	return Min + RNG:RandomInt((Max - Min) +1)
end

function GelloCharMod:RandomVector(MinX, MaxX, RNG, MinY, MaxY)
	local MinX = MinX or -1
	local MaxX = MaxX or 1
	local RNG = RNG or rng

	if MinX > MaxX then
		local trans = MinX
		MinX = MaxX
		MaxX = trans
	end

	local MinY = MinY or MinX
	local MaxY = MaxY or MaxX
	if MinY > MaxY then
		local trans = MinY
		MinY = MaxY
		MaxY = trans
	end

	return Vector( GelloCharMod:RandomFloat(MinX, MaxX, RNG), GelloCharMod:RandomFloat(MinY, MaxY, RNG) )
end



function GelloCharMod:SpawnFromSlot(SlotEnt, Pickup, Vel)
	local Type = 5
	local Variant = 0
	local SubType = 0
	local Vel = Vel or 3

	if type(Pickup) == "table" then
		Type = Pickup.Type or 5
		Variant = Pickup.Variant or 0
		SubType = Pickup.SubType or 0
	else
		Variant = Pickup
	end

	Mod:Spawn(Type, Variant, SubType, SlotEnt.Position, Vector.FromAngle(Mod:RandomFloat(22.5, 135, SlotEnt:GetDropRNG())) * Vel, SlotEnt)
end

function GelloCharMod:RemoveSlotDrops(SlotEnt)
	local pos = SlotEnt.Position

	for _, ent in pairs(Isaac.FindByType(5)) do
		if ent.FrameCount <= 2 and ent.Position:Distance(pos) <= 40 then
			ent:Remove()
		end
	end

	for _, ent in pairs(Isaac.FindByType(4)) do
		if ent.FrameCount <= 2 and ent.Position:Distance(pos) <= 40 then
			ent:Remove()
		end
	end
end

function GelloCharMod:SlotDrops(SlotEnt, DropPool, MaxAmount, ExtraPickup)
	local DropPool = DropPool or {}
	local MaxAmount = MaxAmount or 1
	local SlotRNG = SlotEnt:GetDropRNG()

	if MaxAmount < 1 then return end

	if type(DropPool) ~= "table" then
		DropPool = {{Weight = 1, DropPool}}
	end


	local ExtraPickup = ExtraPickup or true
	local Amount = Mod:RandomInt(1, MaxAmount)

	if ExtraPickup and Mod.PlayerTools.AnyPlayerHasTrinket(TrinketType.TRINKET_LUCKY_TOE) and SlotRNG:RandomFloat() <= 0.33 then
		Amount = Amount +1
	end
	
	
	for i=1, Amount do
		local Drop = Mod.TableTools.GetRandomContent(DropPool, SlotRNG)
		local spawnDrop = true

		local Type = 5
		local Variant = 0
		local SubType = 0
		local VelMult = 3

		if type(Drop) ~= "table" then
			Variant = tonumber(Drop) or 0
		elseif type(Drop) ~= "function" then
			Drop(_, SlotEnt, SlotRNG)
			spawnDrop = false
		else
			Type = tonumber(Drop.Type) or 5
			Variant = tonumber(Drop.Variant) or 0
			SubType = tonumber(Drop.SubType) or 0
			VelMult = tonumber(Drop.VelMult) or 3
		end

		if spawnDrop then
			Mod:Spawn(Type, Variant, SubType, SlotEnt.Position, Vector.FromAngle(Mod:RandomFloat(0, 360, SlotRNG)) * VelMult, SlotEnt)
		end
	end


	if ExtraPickup then
		if Mod.PlayerTools.AnyPlayerHasTrinket(TrinketType.TRINKET_ACE_SPADES) and SlotRNG:RandomFloat() <= 0.33 then
			Mod:Spawn(5, 300, 0, SlotEnt.Position, Vector.FromAngle(Mod:RandomFloat(0, 360, SlotRNG)) * 3, SlotEnt)
		end
		if Mod.PlayerTools.AnyPlayerHasTrinket(TrinketType.TRINKET_SAFETY_CAP) and SlotRNG:RandomFloat() <= 0.33 then
			Mod:Spawn(5, 70, 0, SlotEnt.Position, Vector.FromAngle(Mod:RandomFloat(0, 360, SlotRNG)) * 3, SlotEnt)
		end
		if Mod.PlayerTools.AnyPlayerHasTrinket(TrinketType.TRINKET_MATCH_STICK) and SlotRNG:RandomFloat() <= 0.33 then
			Mod:Spawn(5, 40, 0, SlotEnt.Position, Vector.FromAngle(Mod:RandomFloat(0, 360, SlotRNG)) * 3, SlotEnt)
		end
		if Mod.PlayerTools.AnyPlayerHasTrinket(TrinketType.TRINKET_CHILDS_HEART) and SlotRNG:RandomFloat() <= 0.33 then
			Mod:Spawn(5, 10, 0, SlotEnt.Position, Vector.FromAngle(Mod:RandomFloat(0, 360, SlotRNG)) * 3, SlotEnt)
		end
		if Mod.PlayerTools.AnyPlayerHasTrinket(TrinketType.TRINKET_RUSTED_KEY) and SlotRNG:RandomFloat() <= 0.33 then
			Mod:Spawn(5, 30, 0, SlotEnt.Position, Vector.FromAngle(Mod:RandomFloat(0, 360, SlotRNG)) * 3, SlotEnt)
		end
	end
end

function GelloCharMod:ReplaceSlotDrops(SlotEnt, DropPool, Amount, ExtraPickup)
	GelloCharMod:RemoveSlotDrops(SlotEnt)
	GelloCharMod:SlotDrops(SlotEnt, DropPool, Amount, ExtraPickup)
end


if Mod.Repentogon then
	function GelloCharMod:TryStartAmbush()
		local room = game:GetRoom():GetType()
		if room ~= RoomType.ROOM_BOSSRUSH and room ~= RoomType.ROOM_CHALLENGE then return end
		Ambush.StartChallenge()
	end
else
	--- literaly copy from Epiphany because i'm to stupid to make this
	function GelloCharMod:TryStartAmbush()
		local room = game:GetRoom():GetType()
		if room ~= RoomType.ROOM_BOSSRUSH and room ~= RoomType.ROOM_CHALLENGE then return end

		local player = Mod.PlayerTools.GetAlivePlayer()
		local sack = game:Spawn(5, PickupVariant.PICKUP_GRAB_BAG, player.Position, Vector.Zero, nil, SackSubType.SACK_NORMAL, 6)
		local sprite = sack:GetSprite()
		sprite:Stop()

		local sackPtr = EntityPtr(sack)
		Mod:RunLater(1, function(futureSackPtr)
			local futureSack = futureSackPtr.Ref
			if not futureSack then
				return
			end

			futureSack:Remove()
			local sackPtrHash = GetPtrHash(futureSack)
			for _, coin in pairs(Isaac.FindByType(5, PickupVariant.PICKUP_COIN)) do
				if coin.SpawnerEntity and GetPtrHash(coin.SpawnerEntity) == sackPtrHash then
					coin:Remove()
				end
			end
			-- stop bag pickup sound
			SFXManager():Stop(SoundEffect.SOUND_SHELLGAME)
		end, sackPtr)
	end
end


function GelloCharMod:ForEach(tableData, func)
	local tableData = tableData or {}
	for i=1, #tableData do
		func(tableData[i], i)
	end
end





function GelloCharMod:Clamp(val, min, max)
	local min = min or 0
	local max = max or 0

	if min > max then
		local trans = min
		min = max
		max = trans
	end

	if val < min then
		return min
	elseif val > max then
		return max
	end
	return val
end


local function tableToString(tab)
	local newStr = ""
	
	for i, str in pairs(tab) do
		if type(str) == "function" then
			str = str()
		end
		if type(str) == "table" then
			str = tableToString(str)
		end
		if type(str) ~= "string" then
			str = tostring(str)
		end
		
		newStr = newStr .. str
	end
	return newStr
end


function GelloCharMod:MakeDescription(...)
	local desc = {...}
	local newDesc = ""
	
	for i, str in pairs(desc) do
		if type(str) == "function" then
			str = str()
		end
		if type(str) == "table" then
			str = tableToString(str)
		end
		if type(str) ~= "string" then
			str = tostring(str)
		end

		newDesc = newDesc .. (i > 1 and "#" or "") .. str
	end
	return newDesc
end



local cache_GetData = {}
function GelloCharMod:GetEntityData(ent, key, default)
	if not ent then return end
	local ptr = GetPtrHash(ent)
	if not cache_GetData[ptr] then cache_GetData[ptr] = {} end

	local data = cache_GetData[ptr] or {}
	local val = data[key]

	return (val ~= nil and val or default)
end

function GelloCharMod:SetEntityData(ent, key, val)
	if not ent then return end
	local ptr = GetPtrHash(ent)
	if not cache_GetData[ptr] then cache_GetData[ptr] = {} end

	local data = cache_GetData[ptr] or {}
	data[key] = val
	
	cache_GetData[ptr] = data
end
Mod:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, 10000, function(_, ent) cache_GetData[ GetPtrHash(ent) ] = nil end)
Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function() cache_GetData = {} end)



function GelloCharMod:IsDoubleDamageStage()
	local level = game:GetLevel()
	return not game:IsGreedMode() and (level:IsAscent() or level:GetStage() >= LevelStage.STAGE4_1)
end


function GelloCharMod:FakeMorph(ent, t, v, s, keepSeed)
	local seed = ent.InitSeed
	if not keepSeed then
		seed = Random()
	end
	if seed == 0 then seed = 1 end
	ent:Remove()
	Mod:Spawn(t, v, s, ent.Position, ent.Velocity, ent.SpawnerEntity, seed)
end


function GelloCharMod:CanTargetEntity(ent)
	return ent:GetEntityFlags() & (EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_ICE_FROZEN) == 0
end


function GelloCharMod:GetClosesTarget(pos, range)
	local target = nil
	local dis = 999999
	for _, ent in pairs(Isaac.FindInRadius(pos, (range or 1), EntityPartition.ENEMY)) do
		local entDis = ent.Position:Distance(pos)
		if ent:Exists() and not ent:IsDead() and GelloCharMod:CanTargetEntity(ent) and entDis <= dis then
			target = ent
			dis = entDis
		end
	end
	return target
end


function GelloCharMod:GetFardestTarget(pos, range)
	local target = nil
	local dis = -1
	for _, ent in pairs(Isaac.FindInRadius(pos, (range or 50000), EntityPartition.ENEMY)) do
		local entDis = ent.Position:Distance(pos)
		if ent:Exists() and not ent:IsDead() and GelloCharMod:CanTargetEntity(ent) and entDis >= dis then
			target = ent
			dis = entDis
		end
	end
	return target
end



function GelloCharMod:GetClosesListTarget(pos, range, amount)
	local list = {}
	for _, ent in pairs(Isaac.FindInRadius(pos, (range or 1), EntityPartition.ENEMY)) do
		if ent:Exists() and not ent:IsDead() and GelloCharMod:CanTargetEntity(ent) then
			local dis = ent.Position:Distance(pos)
			if #list < amount then
				table.insert(list, {Entity = ent, Distance = dis})
			else
				for i= #list, 1, -1 do
					if list[i].Distance > dis then
						table.remove(list, i)
						table.insert(list, {Entity = ent, Distance = dis})
						break
					end
				end
			end
		end
	end
	return list
end


function GelloCharMod:GetFardestListTarget(pos, range, amount)
	local list = {}
	for _, ent in pairs(Isaac.FindInRadius(pos, (range or 50000), EntityPartition.ENEMY)) do
		if ent:Exists() and not ent:IsDead() and GelloCharMod:CanTargetEntity(ent) and entDis >= dis then
			local dis = ent.Position:Distance(pos)
			if #list < amount then
				table.insert(list, {Entity = ent, Distance = dis})
			else
				for i= #list, 1, -1 do
					if list[i].Distance < dis then
						table.remove(list, i)
						table.insert(list, {Entity = ent, Distance = dis})
						break
					end
				end
			end
		end
	end
	return list
end


function GelloCharMod:Color(r ,g ,b , a, ro, go, bo)
	return Color(r /255, g /255, b /255, (a or 255) /255, (ro or 0) /255, (go or 0) /255, (bo or 0) /255)
end


local famCopy = { -- familiars that shoot the same as the player
	[FamiliarVariant.CAINS_OTHER_EYE] = true,
	[FamiliarVariant.INCUBUS] = true,
	[FamiliarVariant.SPRINKLER] = true,
	[FamiliarVariant.TWISTED_BABY] = true,
	[FamiliarVariant.BLOOD_BABY] = true,
	[FamiliarVariant.UMBILICAL_BABY] = true,
}
function GelloCharMod:IsFamiliarCopyPlayerTears(fam, includeFateReward)
	local fam = type(fam) == "userdata" and fam:ToFamiliar()
	if not fam then return false end

	local includeFateReward = includeFateReward or false

	return famCopy[fam.Variant] == true or (includeFateReward and fam.Variant == FamiliarVariant.FATES_REWARD)
end


function GelloCharMod:TearFlag(x)
    return x >= 64 and BitSet128(0,1<<(x-64)) or BitSet128(1<<x,0)
end



function GelloCharMod:IsHUDVisible()
	return not (game:GetSeeds():HasSeedEffect(SeedEffect.SEED_NO_HUD) or (StageAPI ~= nil and (StageAPI.PlayingBossSprite or StageAPI.IsHUDAnimationPlaying()) )) and game:GetHUD():IsVisible()
end

function GelloCharMod:AreHeartsVisible()
	return game:GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN == 0 and GelloCharMod:IsHUDVisible()
end

function GelloCharMod:IsGamePause()
	return game:IsPaused()
end



function GelloCharMod:GenerateTableCoins(value, rng)
	local tab = {}
	local currentVal = 0
	while currentVal < value do
		local validSpace = value - currentVal
		if validSpace >= 5 and rng:RandomInt(20) == 0 then
			table.insert(tab, CoinSubType.COIN_NICKEL)
			currentVal = currentVal +5
		elseif validSpace >= 10 and rng:RandomInt(94) == 0 then
			table.insert(tab, CoinSubType.COIN_DIME)
			currentVal = currentVal +10
		elseif rng:RandomInt(100) == 0 then
			table.insert(tab, CoinSubType.COIN_LUCKYPENNY)
			currentVal = currentVal +1
		else
			table.insert(tab, CoinSubType.COIN_PENNY)
			currentVal = currentVal +1
		end
	end
	return tab
end
