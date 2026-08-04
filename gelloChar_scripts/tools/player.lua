local Mod = GelloCharMod
local rng = GelloCharMod.RNG
local SFX = Mod.SFX
local game = Mod.Game


local PlayerTools = {}
GelloCharMod.PlayerTools = PlayerTools


local isJacobEsau = Mod.TableTools.Set({PlayerType.PLAYER_JACOB, PlayerType.PLAYER_ESAU})
function PlayerTools.IsJacobEsau(player)
	--if not type(player) == "userdata" or not player.ToPlayer or not player:ToPlayer() then Mod:Error("function IsJacobEsau argument #1 is nil", 2); return false end
	return isJacobEsau[player:GetPlayerType()] ~= nil
end

local isTaintedLaz = Mod.TableTools.Set({PlayerType.PLAYER_LAZARUS_B, PlayerType.PLAYER_LAZARUS2_B})
function PlayerTools.IsTaintedLazarus(player)
	--if not type(player) == "userdata" or not player.ToPlayer or not player:ToPlayer() then Mod:Error("function IsTaintedLazarus argument #1 is nil", 2); return false end
	return isTaintedLaz[player:GetPlayerType()] ~= nil
end

local isTaintedFor = Mod.TableTools.Set({PlayerType.PLAYER_THEFORGOTTEN_B, PlayerType.PLAYER_THESOUL_B})
function PlayerTools.IsTaintedForgotten(player)
	--if not type(player) == "userdata" or not player.ToPlayer or not player:ToPlayer() then Mod:Error("function IsTaintedForgotten argument #1 is nil", 2); return false end
	return isTaintedFor[player:GetPlayerType()] ~= nil
end

local isLilith = Mod.TableTools.Set({PlayerType.PLAYER_LILITH, PlayerType.PLAYER_LILITH_B})
function PlayerTools.IsLilithVariant(player)
	--if not type(player) == "userdata" or not player.ToPlayer or not player:ToPlayer() then Mod:Error("function IsLilithVariant argument #1 is nil", 2); return false end
	return isLilith[player:GetPlayerType()] ~= nil
end


if Mod.Repentogon then
	function PlayerTools.IsFakeTwin(player, excludeTaintedLaz)
		--if not type(player) == "userdata" or not player.ToPlayer or not player:ToPlayer() then Mod:Error("function IsFakeTwin argument #1 is nil", 2); return false end
		local pType = player:GetPlayerType()

		if pType == PlayerType.PLAYER_THESOUL_B and player:GetOtherTwin() ~= nil then return true end
		if not excludeTaintedLaz and PlayerTools.IsTaintedLazarus(player) then return player:IsHologram() end
		return false
	end
else
	function PlayerTools.IsFakeTwin(player, excludeTaintedLaz)
		--if not type(player) == "userdata" or not player.ToPlayer or not player:ToPlayer() then Mod:Error("function IsFakeTwin argument #1 is nil", 2); return false end
		local pType = player:GetPlayerType()

		if pType == PlayerType.PLAYER_THESOUL_B and player:GetOtherTwin() ~= nil then return true end
		if not excludeTaintedLaz and PlayerTools.IsTaintedLazarus(player) then
			if player:GetMainTwin():GetPlayerType() == pType then return false end
			return true
		end
		return false
	end
end

function PlayerTools.IsFakePlayer(player)
	return player.Parent ~= nil
end



local playerIndexCache = {}
Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function() playerIndexCache = {} end)-- clears ptr hash of the players because it changes when starting a run

function PlayerTools.GetIndex(player)
	--if not type(player) == "userdata" or not player.ToPlayer or not player:ToPlayer() then Mod:Error("function GetIndex argument #1 is nil", 2); return end
	if PlayerTools.IsFakeTwin(player, true) then
		return PlayerTools.GetIndex(player:GetOtherTwin())
	end

	local pHash = GetPtrHash(player)
	if PlayerTools.IsTaintedLazarus(player) then -- avoid t. laz because allway changes the ptr hash when swiching
		local pType = player:GetPlayerType()
		local IsDeadTwin = pType == PlayerType.PLAYER_LAZARUS2_B

		-- this is just for tainted laz birthright
		if PlayerTools.IsFakeTwin(player) then player = player:GetMainTwin() end
		if IsDeadTwin then return tostring(player:GetCollectibleRNG(2):GetSeed()) end

		return tostring(player:GetCollectibleRNG(1):GetSeed())
	elseif not playerIndexCache[pHash] then
		local pIndex = tostring(player:GetCollectibleRNG(1):GetSeed())
		if not playerIndexCache[pHash] then
			playerIndexCache[pHash] = pIndex
		end

		return pIndex
	end
	return playerIndexCache[pHash]
end

function PlayerTools.GetAllPlayers()
	local playersTab = {}

	for i = 0, game:GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)
		
		if PlayerTools.IsTaintedLazarus(player) then
			local IsDeadTwin = player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B

			-- this is just for tainted laz birthright
			if PlayerTools.IsFakeTwin(player) then player = player:GetMainTwin() end
			if IsDeadTwin then 
				table.insert(playersTab, {Index = tostring(player:GetCollectibleRNG(2):GetSeed()), Player = player})
			else
				table.insert(playersTab, {Index = tostring(player:GetCollectibleRNG(1):GetSeed()), Player = player})
			end
		else
			table.insert(playersTab, {Index = tostring(player:GetCollectibleRNG(1):GetSeed()), Player = player})
		end
	end

	return playersTab
end



function PlayerTools.ForEach(fun)
	if type(fun) ~= "function" then Mod:Error("Argument #1 is not a function", 2); return end
	for i=0, game:GetNumPlayers()-1 do
		local p = Isaac.GetPlayer(i)
		if not PlayerTools.IsFakeTwin(p, true) then
			if fun(p, i) then break end
		end
	end
end



function PlayerTools.GetAlivePlayer()
	for i = 0, game:GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)

		if not player:IsCoopGhost() and player.Parent == nil and player.Variant == 0 then
			return player
		end
	end
end

function PlayerTools.GetAllAlive()
	local allPlayers = PlayerTools.GetAllPlayers()
	local alivePlayers = {}
	for _, data in pairs(allPlayers) do
		if not data.Player:IsCoopGhost() and data.Player.Parent == nil and player.Variant == 0 then
			alivePlayers[data.Index] = data.Player
		end
	end
	return alivePlayers
end



function PlayerTools.IsKeeper(player)
	if type(player) ~= "userdata" then Mod:Error("PlayerTools.IsKeeper - not a player", 2) end
	return Mod.KeepersVariants[player:GetPlayerType()] == true
end

function PlayerTools.IsLost(player)
	if type(player) ~= "userdata" then Mod:Error("PlayerTools.IsLost - not a player", 2) end
	return Mod.LostVariants[player:GetPlayerType()] == true
end


function PlayerTools.AnyPlayerHasTrinket(trinketID)
	for i=0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)

		if player:HasTrinket(trinketID) then
			return true, player
		end
	end
	return false
end

function PlayerTools.AnyPlayerHasCollectible(ItemID)
	for i=0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)

		if player:HasCollectible(ItemID) then
			return true, player
		end
	end
	return false
end

function PlayerTools.IsPlayerPresent(charList)
	local charList = charList or {}
	if type(charList) ~= "table" then charList = {charList} end

	charList = Mod.TableTools.Set(charList, true)

	for i=0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)

		if charList[player:GetPlayerType()] then
			return true, player
		end
	end
	return false
end

function PlayerTools.AllPlayersArePlayerType(charID)
	for i=0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)

		if player:GetPlayerType() ~= charID then
			return false
		end
	end
	return true
end

function PlayerTools.PlayerTypeHasCollectible(charID, itemID)
	local tab = PlayerTools.GetPlayerTypeList(charID)
	for i=1, #tab do
		if tab[i]:HasCollectible(itemID) then
			return true, tab[i]
		end
	end

	return false
end

function PlayerTools.PlayerTypeHasTrinket(charID, trinketID)
	local tab = PlayerTools.GetPlayerTypeList(charID)
	for i=1, #tab do
		if tab[i]:HasTrinket(trinketID) then
			return true, tab[i]
		end
	end
	
	return false
end

function PlayerTools.GetPlayerTypeList(charID, countNonPlayer)
	local list = {}
	PlayerTools.ForEach(function(player)
		if player:GetPlayerType() == charID and player.Variant == 0 and (countNonPlayer or player.Parent == nil) then
			table.insert(list, player)
		end
	end)
	return list
end

function PlayerTools.GetCurrentPlayers()
	local list = {}
	PlayerTools.ForEach(function(player)
		if player.Variant == 0 and (countNonPlayer or player.Parent == nil) then
			table.insert(list, player)
		end
	end)
	return list
end


function PlayerTools.AddTears(player, addtears)
	local tears = 30.0 / (player.MaxFireDelay + 1)
	return 30 / math.max(tears + addtears, 0.01) - 1
end

function PlayerTools.ApplyTearsMultiplier(player, addmult)
	local tears = 30.0 / (player.MaxFireDelay + 1)
	return 30 / math.max(tears * addmult, 0.01) - 1
end

function PlayerTools.AddCappedTears(player, addtears)
	local tears = 30.0 / (player.MaxFireDelay + 1)
	local cap = MultiplierHandler:GetPlayerTearCap(player)
	local rest = math.max(tears + addtears, 0.01)
	
	if rest > cap then
		if rest < tears then -- tears down apply
			tears = rest
		else
			tears = math.max(cap, tears) -- if tears already was over cap let it be
		end
	else
	 	tears = rest
	end

	return 30 / tears - 1
end

function PlayerTools.GetTearsToTPS(player)
	return 30.0 / (player.MaxFireDelay + 1)
end

function PlayerTools.GetTPSToTears(num)
	return 30 / num - 1
end


function PlayerTools.AddRange(player, addrange)
	local range = player.TearRange / 40
	return math.max(range + addrange, 1) * 40
end

function PlayerTools.ApplyRangeMultiplier(player, addmult)
	local range = player.TearRange / 40
	return (range * addmult) * 40
end



function PlayerTools.GetActiveMaxCharge(player, slot, overcharge, forceDefault)
	local overcharge = overcharge or player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY)
	
	--- doing this weird thing because the item config maxcharge isn't very accurate with items that change the max charge (like blank card, clear rune, d infinity, etc)
	local ogCharge = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
	player:SetActiveCharge(65536, slot)

	local maxCharge = player:GetActiveCharge(slot)
	if not forceDefault and overcharge then maxCharge = maxCharge + player:GetBatteryCharge(slot) end

	player:SetActiveCharge(ogCharge, slot)
	return maxCharge
end


if Mod.Repentogon then
	function PlayerTools.AddActiveCharge(player, charge, slot, overcharge, force, flash)
		local overcharge = overcharge or false
		local slot = slot or ActiveSlot.SLOT_PRIMARY
		local force = force or false
		local flash = flash or true

		player:AddActiveCharge(charge, slot, flash, overcharge, force)
	end
else
	local function chargeFun(player, slot, charge, maxCharge, isOvercharge, flash)
		local newCharge = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
		if newCharge >= maxCharge then return end
		newCharge = newCharge + charge

		player:SetActiveCharge(math.min(newCharge, maxCharge), slot)

		if not flash then return end
		game:GetHUD():FlashChargeBar(player, slot)
		
		if charge < 0 then
			SFX:Stop(SoundEffect.SOUND_BATTERYDISCHARGE)
			SFX:Play(SoundEffect.SOUND_BATTERYDISCHARGE)
		else
			SFX:Stop(SoundEffect.SOUND_BATTERYCHARGE)
			SFX:Stop(SoundEffect.SOUND_BEEP)

			if isOvercharge and (maxCharge == newCharge or maxCharge /2 == newCharge) or maxCharge == newCharge then
				SFX:Play(SoundEffect.SOUND_BATTERYCHARGE)
			else
				SFX:Play(SoundEffect.SOUND_BEEP)
			end
		end
	end

	local config = Isaac.GetItemConfig()
	function PlayerTools.AddActiveCharge(player, charge, slot, overcharge, force, flash)
		local overcharge = overcharge or false
		local slot = slot or ActiveSlot.SLOT_PRIMARY
		local force = force or false
		local flash = flash or true

		local ID = player:GetActiveItem(slot)
		if ID == 0 then return end

		local chargeType = config:GetCollectible(ID).ChargeType
		if not force and (chargeType == ItemConfig.CHARGE_TIMED or chargeType == ItemConfig.CHARGE_SPECIAL) then return end
		
		local overcharge = ( overcharge or player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) )
		local maxCharge = PlayerTools.GetActiveMaxCharge(player, slot, overcharge)

		Mod:RunLater(1, chargeFun,
			player, slot, charge, maxCharge, overcharge, flash
		)
	end
end


function PlayerTools.GetPlayersInRange(pos, range)
	local range = range 
	local playerTable = {}

	PlayerTools.ForEach(function(player)
		if pos:Distance(player.Position) <= range then
			table.insert(playerTable, player)
		end
	end)

	return playerTable
end



function PlayerTools.AddPermaStat(value, player, statFlag)
	local Save = Mod.SaveHandler.Player("Perma Stats", player)
	local stats = Save:Get({})

	if statFlag & CacheFlag.CACHE_DAMAGE > 0 	then stats.DAMAGE = (stats.DAMAGE or 0) + value end
	if statFlag & CacheFlag.CACHE_FIREDELAY > 0 then stats.TEARS = (stats.TEARS or 0) + value end
	if statFlag & CacheFlag.CACHE_SHOTSPEED > 0 then stats.SHOTSPEED = (stats.SHOTSPEED or 0) + value end
	if statFlag & CacheFlag.CACHE_RANGE > 0 	then stats.RANGE = (stats.RANGE or 0) + value end
	if statFlag & CacheFlag.CACHE_SPEED > 0 	then stats.SPEED = (stats.SPEED or 0) + value end
	if statFlag & CacheFlag.CACHE_LUCK > 0 		then stats.LUCK = (stats.LUCK or 0) + value end

	Save:Set(stats)
end


local CacheDefault = CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_FLYING | CacheFlag.CACHE_LUCK
function PlayerTools.DoCache(player, cacheFlags)
	local cacheFlags = cacheFlags or CacheDefault
	player:AddCacheFlags(cacheFlags)
	player:EvaluateItems()
end



function PlayerTools.GetPocketTrinketMultiplier(player, trinketID, excludeMomsBox)
	local excludeMomsBox = excludeMomsBox or false
	local Mult = 0

	for i =0, 1 do
		local pTrinket = player:GetTrinket(i)

		if pTrinket > TrinketType.TRINKET_GOLDEN_FLAG and pTrinket - TrinketType.TRINKET_GOLDEN_FLAG == trinketID then
			Mult = Mult +2
		elseif pTrinket == trinketID then
			Mult = Mult +1
		end
	end

	if not excludeMomsBox and Mult >0 and player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
		Mult = Mult +1
	end

	return Mult
end

function PlayerTools.GetSmeltedTrinketMultiplier(player, trinketID, excludeMomsBox)
	local excludeMomsBox = excludeMomsBox or false
	local Mult = player:GetTrinketMultiplier(trinketID) - PlayerTools.GetPocketTrinketMultiplier(player, trinketID)

	if Mult > 0 and excludeMomsBox and player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
		Mult = Mult -1
	end

	return Mult >0 and Mult or 0
end

if Mod.Repentogon then
	function PlayerTools.SmeltTrinket(player, trinketID, firstTime)
		local firstTime = firstTime or true
		player:AddSmeltedTrinket(trinketID, firstTime)
	end

	function PlayerTools.TryRemoveSmeltedTrinket(player, trinketID)
		player:TryRemoveSmeltedTrinket(trinketID)
	end

else
	function PlayerTools.SmeltTrinket(player, trinketID, firstTime)
		local firstTime = firstTime or true
		local ogTrinkets = {
			player:GetTrinket(0),
			player:GetTrinket(1),
		}

		for _, t in pairs(ogTrinkets) do
			if t ~= 0 then player:TryRemoveTrinket(t) end
		end

		player:AddTrinket(trinketID, firstTime)
		player:UseActiveItem(479, UseFlag.USE_NOANIM | UseFlag.USE_MIMIC, -1)

		for _, t in pairs(ogTrinkets) do
			if t ~= 0 then player:AddTrinket(t, false) end
		end
	end


	function PlayerTools.TryRemoveSmeltedTrinket(player, trinketID)
		local ogTrinkets = {
			player:GetTrinket(0),
			player:GetTrinket(1),
		}

		for _, t in pairs(ogTrinkets) do
			if t ~= 0 then player:TryRemoveTrinket(t) end
		end

		player:TryRemoveTrinket(trinketID)

		for _, t in pairs(ogTrinkets) do
			if t ~= 0 then player:AddTrinket(t, false) end
		end
	end
end


local function HoldPickup(player, pickup)
	if not pickup or not player then return end

	if pickup.Variant == 100 then
		player:AnimateCollectible(pickup.SubType, nil, "PlayerPickup")
	elseif pickup.Variant == 350 then
		player:AnimateTrinket(pickup.SubType, nil, "Idle")
	else
		local sprite = pickup:GetSprite()
		sprite:SetFrame("Idle", 0)

		player:AnimatePickup(sprite)
	end
end



GelloCharMod.CustomPricesTable = {
	[PickupPrice.PRICE_ONE_HEART] = function(player) player:AddMaxHearts(-2) end,
	[PickupPrice.PRICE_TWO_HEARTS] = function(player) player:AddMaxHearts(-4) end,
	[PickupPrice.PRICE_THREE_SOULHEARTS] = function(player) player:AddSoulHearts(-6) end,
	[PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS] = function(player) player:AddMaxHearts(-2); player:AddSoulHearts(-4) end,
	[PickupPrice.PRICE_SPIKES] = function(player, pickup) --- copy from epiphany
			local ref = EntityRef(pickup)
			ref.Type = 0
			ref.Variant = 0
			ref.Entity = nil
			player:TakeDamage(2, DamageFlag.DAMAGE_SPIKES | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_PENALTIES, ref, 30)
		end,
	[PickupPrice.PRICE_SOUL] = function(player) player:TryRemoveTrinket(TrinketType.TRINKET_YOUR_SOUL) end,
	[PickupPrice.PRICE_ONE_SOUL_HEART] = function(player) player:AddSoulHearts(-2) end,
	[PickupPrice.PRICE_TWO_SOUL_HEARTS] = function(player) player:AddSoulHearts(-4) end,
	[PickupPrice.PRICE_ONE_HEART_AND_ONE_SOUL_HEART] = function(player) player:AddMaxHearts(-2); player:AddSoulHearts(-2) end,
	[PickupPrice.PRICE_FREE] = function(player) player:TryRemoveTrinket(TrinketType.TRINKET_STORE_CREDIT) end,
}

GelloCharMod.CanPayCustomPricesTable = {
	[PickupPrice.PRICE_ONE_HEART] = function(player) return player:GetEffectiveMaxHearts() >0 end,
	[PickupPrice.PRICE_TWO_HEARTS] = function(player) return player:GetEffectiveMaxHearts() >0 end,
	[PickupPrice.PRICE_THREE_SOULHEARTS] = function(player) return player:GetSoulHearts() >0 end,
	[PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS] = function(player) return player:GetEffectiveMaxHearts() >0 end,
	[PickupPrice.PRICE_SPIKES] = function(player, pickup) return true end,
	[PickupPrice.PRICE_SOUL] = function(player) return player:HasTrinket(TrinketType.TRINKET_YOUR_SOUL) end,
	[PickupPrice.PRICE_ONE_SOUL_HEART] = function(player) return player:GetSoulHearts() >0 end,
	[PickupPrice.PRICE_TWO_SOUL_HEARTS] = function(player) return player:GetSoulHearts() >0 end,
	[PickupPrice.PRICE_ONE_HEART_AND_ONE_SOUL_HEART] = function(player) return player:GetEffectiveMaxHearts() >0 end,
	[PickupPrice.PRICE_FREE] = function(player) return player:HasTrinket(TrinketType.TRINKET_STORE_CREDIT) end,
}

function PlayerTools.PayPickup(player, pickup, holdPickup)
	pickup = pickup:ToPickup()
	if pickup == nil then return false end
	local price = pickup.Price
	if player:IsHoldingItem() and not player:CanPickupItem() and not player:IsExtraAnimationFinished() then return false end

	if price == 0 then
		return true

	elseif price > 0 then
		if price > player:GetNumCoins() then return false end

		player:AddCoins(-price)
		if holdPickup then
			HoldPickup(player, pickup)
		end
		return true

	elseif price < 0 then
		local ret = Mod.TableTools.Switch(price, Mod.CustomPricesTable, function()end)(player, pickup)

		if ret == false then return false end
		if holdPickup then
			HoldPickup(player, pickup)
		else
			if player:GetEffectiveMaxHearts() + player:GetSoulHearts() == 0 then player:Kill() end
		end

		return true
	end

	return false
end


function PlayerTools.CanPlayerPayPickup(player, pickup)
	pickup = pickup:ToPickup()
	if pickup == nil then return false end

	local price = pickup.Price
	if price == 0 then
		return true

	elseif price > 0 then
		if price > player:GetNumCoins() then return false end
		return true

	elseif price < 0 then
		local ret = Mod.TableTools.Switch(price, Mod.CanPayCustomPricesTable, function()end)(player, pickup)
		if ret == false then return false end
		return true
	end

	return false
end



function PlayerTools.GetTearEffectLuck(player)
	return player.Luck + 4 * player:GetTrinketMultiplier(TrinketType.TRINKET_TEARDROP_CHARM)
end


function PlayerTools.IsTryingShooting(player)
	local dir = player:GetShootingJoystick()
	local aim = player:GetAimDirection()
	if dir.X ~= 0 or dir.Y ~= 0 or aim.X ~= 0 or aim.Y ~= 0 or player:AreOpposingShootDirectionsPressed() or player:HasWeaponType(WeaponType.WEAPON_LUDOVICO_TECHNIQUE) then return true end
	if player:HasWeaponType(WeaponType.WEAPON_ROCKETS) then
		local ent = player:GetActiveWeaponEntity()
		if ent and ent:Exists() and ent.Type == 1000 and ent.Variant == EffectVariant.TARGET then
			for _, target in pairs(Isaac.FindByType(1000, EffectVariant.TARGET)) do
				if GetPtrHash(ent) == GetPtrHash(target) then return true end
			end
		end
	end
	return false
end


if Mod.Repentogon then
	function PlayerTools.SetCanShoot(player, canShoot)
		player:SetCanShoot(canShoot)
	end
else
	function PlayerTools.SetCanShoot(player, canShoot)
		local challenge = Isaac.GetChallenge()
		if canShoot then
			game.Challenge = Challenge.CHALLENGE_SOLAR_SYSTEM
			player:UpdateCanShoot()
			game.Challenge = challenge

			player:TryRemoveNullCostume(NullItemID.ID_BLINDFOLD)
			return
		end
		
		game.Challenge = Challenge.CHALLENGE_NULL
		player:UpdateCanShoot()
		game.Challenge = challenge
		player:UpdateCanShoot()
	end
end


function PlayerTools.AnimateItem(player, itemID, animName, anm2File)
	local anm2File = anm2File or "gfx/005.350_trinket.anm2"
	local sprite = Sprite()
	sprite:Load(anm2File, true)

	sprite:ReplaceSpritesheet(0, Isaac.GetItemConfig():GetCollectible(itemID).GfxFileName)
	
	sprite:SetFrame("Idle", 0)
	sprite:LoadGraphics()
	player:AnimatePickup(sprite, true, animName)
end


function PlayerTools.GetTotalBlackHearts(player)
	local endIndex = player:GetSoulHearts()
	if endIndex == 0 then return 0 end
	
	local isOdd = endIndex % 2 == 1

	local amount = 0
	for idx = 1, endIndex, 2 do
		if player:IsBlackHeart(idx) then
			if idx == 1 and isOdd then
				amount = amount +1
			else
				amount = amount +2
			end
		end
	end
	return amount
end


local itemSize = Isaac.GetItemConfig():GetCollectibles().Size -1
function PlayerTools.GetPlayerItems(player, ignoreQuestItems)
	local tab = {}
	local totalItems = player:GetCollectibleCount()
	if totalItems == 0 then return tab end
	local effects = player:GetEffects()
	for itemID=1, itemSize do
		if player:HasCollectible(itemID, true) and (not ignoreQuestItems or ( ignoreQuestItems and not Isaac.GetItemConfig():GetCollectible(itemID):HasTags(ItemConfig.TAG_QUEST) )) then
			local num = player:GetCollectibleNum(itemID, true)
			if num > 0 then
				tab[itemID] = num
				totalItems = totalItems - num
			end
		end
		if totalItems <= 0 then break end
	end

	return tab
end


function PlayerTools.ReplacePlayerHealth(player, heartsTab)
	if type(heartsTab) ~= "table" or player.Variant == 1 then return end

	player:AddHearts(-player:GetHearts())
	player:AddMaxHearts(-player:GetMaxHearts())
	player:AddSoulHearts(-player:GetSoulHearts())
	player:AddGoldenHearts(-player:GetGoldenHearts())
	player:AddEternalHearts(-player:GetEternalHearts())
	player:AddBoneHearts(-player:GetBoneHearts())
	player:AddRottenHearts(-player:GetRottenHearts())
	player:AddBrokenHearts(-player:GetBrokenHearts())


	if heartsTab.MaxHearts then player:AddMaxHearts(heartsTab.MaxHearts * 2) end
	if heartsTab.Soul then player:AddSoulHearts(heartsTab.Soul) end
	if heartsTab.Black then player:AddBlackHearts(heartsTab.Black) end
	if heartsTab.Golden then player:AddGoldenHearts(heartsTab.Golden) end
	if heartsTab.Bone then player:AddBoneHearts(heartsTab.Bone) end

	if heartsTab.AddOrder then
		for _, data in pairs(heartsTab.AddOrder) do
			if data.Type == "Soul" then player:AddSoulHearts(data.Num)
			elseif data.Type == "Black" then player:AddBlackHearts(data.Num)
			elseif data.Type == "Bone" then player:AddBoneHearts(data.Num) end
		end
	end

	if heartsTab.Hearts then player:AddHearts(heartsTab.Hearts) end
	if heartsTab.Rotten then player:AddRottenHearts(heartsTab.Rotten) end

	if heartsTab.Broken then player:AddBrokenHearts(heartsTab.Broken) end
	if heartsTab.Eternal then player:AddEternalHearts(heartsTab.Eternal) end

end


