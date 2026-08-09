local Mod = GelloCharMod
local game = Mod.Game
local playerSave = Mod.SaveHandler.Player
local saveHand = Mod.SaveHandler.Save("Non Edible Item")
local tGelloPointsSave = Mod.SaveHandler.Save("GelloPoints")
local SAVE_FLAT_DMG_NAME = "Gello perma damage"
local SAVE_PERMA_STATS_NAME = "Gello extra perma stats"
--local ADD_DMG = 40
local ADD_DMG = 1
local CONSUME_BLACKLIST = {
	[CollectibleType.COLLECTIBLE_BROKEN_SHOVEL_1]=true,
	[CollectibleType.COLLECTIBLE_BROKEN_SHOVEL_2]=true,
	[CollectibleType.COLLECTIBLE_BROKEN_SHOVEL]=true,
	[CollectibleType.COLLECTIBLE_DADS_NOTE]=true,
}

local GELLO_SAVEDATA = {
	PrevClasses = {},
	CurrentClasses = {},
	RunClasses = {},
	Level = 0,
}

local itemPool = game:GetItemPool()
local itemConfig = Isaac.GetItemConfig()


local itemExtraEffects = {}


itemExtraEffects[CollectibleType.COLLECTIBLE_KING_BABY] = function(player, rng)
	local seen = {[CollectibleType.COLLECTIBLE_KING_BABY] = true}
	local funcs = {}
	while #funcs < 3 do
		local fam = Mod:GetRandomSpawnableFam(rng)
		if seen[fam] == nil then
			seen[fam] = true
			if itemExtraEffects[fam] then
				funcs[#funcs] = itemExtraEffects[fam]
			end
		end
	end
	for i=1, 3 do
		funcs[i](player, rng)
	end
end

itemExtraEffects[CollectibleType.COLLECTIBLE_CHAOS] = function(player, rng)
	local num = Mod:RandomInt(2, 5, rng)

	local condeceFunTable = {}
	for _, fun in pairs(itemExtraEffects) do
		table.insert(condeceFunTable, fun)
	end

	local funcs = {}
	while #funcs < num do
		table.insert(funcs, condeceFunTable[rng:RandomInt(#condeceFunTable) +1] )
	end

	for i=1, num do funcs[i](player, rng) end
end

local itemExtraStatMod = {
	--[[ [CollectibleType.COLLECTIBLE_NULL] = {
		ForceDmg = 1, -- forces how much damage grants
		ForceTempDmg = 1, -- forces how much temp damage grants
		DmgOffset = 1.25, -- offset the damage that grants, it will be overwriten by ForceDmg
		TempDmgOffset = 0.8, -- offset the temp damage that gives, it will be overwriten by ForceTempDmg
		Tears = 0.1, -- how much tears grants
		Speed = 0.1, -- how much speed grants
		ShotSpeed = 0.1, -- how much shot speed grants
		Range = 0.1, -- how much range grants
		GelloPoints = 1, -- how much points grants to tainted gello
	},]]
}




local itemNoActive = {}
local itemExtraEffectsEID = {
	StatsName = {
		TempDmg = {
			en_us = "{1} Temporal Damage",
			spa = "{1} Damage Daño temporal",
		},
		ActiveItem = {
			en_us = "Upon being consume, it will activate the item",
			spa = "Al consumirlo, hará el efecto del objeto",
		},
		Price = {
			en_us = "!!! Isaac will pay the item price",
			spa = "!!! Isaac pagará el precio del objeto",
		}
	},

	TGelloPoints = {
		en_us = "{{ArrowUp}} {{TaintedGelloPoints}} +{1} Points",
		spa = "{{ArrowUp}} {{TaintedGelloPoints}} +{1} Puntos",
	},


	[CollectibleType.COLLECTIBLE_KING_BABY] = {en_us = "Does the consume effect of 3 familiars", spa = "Hace el efecto de consumir de 3 familiares"},
	[CollectibleType.COLLECTIBLE_CHAOS] =     {en_us = "Does the consume effect of 2 to 5 random items", spa = "Hace el efecto de consumir de 2 a 5 objetos"},
}


GelloCharMod.EID_ItemExtraEffects = itemExtraEffectsEID


function GelloCharMod:GelloTryConsumePickup(player, pickup, isVoidStomach)
	if pickup == nil then return false end
	pickup = pickup:ToPickup()
	if pickup == nil or pickup.Variant ~= 100 then return false end

	local sub = pickup.SubType
	if sub <= 0 or CONSUME_BLACKLIST[sub] then return false end

	if pickup.Variant == 100 and Mod:CanEatPickup(pickup) then
		if not Mod.PlayerTools.PayPickup(player, pickup, false) then return false end
		
		--player:AddHearts(2)
		--if holditem then player:AnimateCollectible(sub, "Pickup", "PlayerPickup") end

		if itemExtraEffects[sub] and sub > 2 then -- dont touch sad onion and inner eye rng just in case
			itemExtraEffects[sub](player, player:GetCollectibleRNG(sub), pickup)
		end

		local itemCon = itemConfig:GetCollectible(sub)
		local itemval = itemCon.Quality+1
		local dmg = itemval /4
		local tempdmg = dmg *1.75 +0.25

		local extraStats
		local cacheflags = CacheFlag.CACHE_DAMAGE
		if itemExtraStatMod[sub] then
			if itemExtraStatMod[sub].ForceDmg then
				dmg = itemExtraStatMod[sub].ForceDmg
			elseif itemExtraStatMod[sub].DmgOffset then
				dmg = dmg + itemExtraStatMod[sub].DmgOffset
			end
			if itemExtraStatMod[sub].ForceTempDmg then
				tempdmg = itemExtraStatMod[sub].ForceTempDmg
			elseif itemExtraStatMod[sub].TempDmgOffset then
				tempdmg = tempdmg+ itemExtraStatMod[sub].TempDmgOffset
			else tempdmg = dmg *1.75 +0.25
			end

			if itemExtraStatMod[sub].Tears then
				extraStats = extraStats or {}
				extraStats.Tears = itemExtraStatMod[sub].Tears
				cacheflags = cacheflags | CacheFlag.CACHE_FIREDELAY
			end
			if itemExtraStatMod[sub].Speed then
				extraStats = extraStats or {}
				extraStats.Speed = itemExtraStatMod[sub].Speed
				cacheflags = cacheflags | CacheFlag.CACHE_SPEED
			end
			if itemExtraStatMod[sub].ShotSpeed then
				extraStats = extraStats or {}
				extraStats.ShotSpeed = itemExtraStatMod[sub].ShotSpeed
				cacheflags = cacheflags | CacheFlag.CACHE_SHOTSPEED
			end
			if itemExtraStatMod[sub].Range then
				extraStats = extraStats or {}
				extraStats.Range = itemExtraStatMod[sub].Range
				cacheflags = cacheflags | CacheFlag.CACHE_RANGE
			end
			if itemExtraStatMod[sub].Luck then
				extraStats = extraStats or {}
				extraStats.Luck = itemExtraStatMod[sub].Luck
				cacheflags = cacheflags | CacheFlag.CACHE_LUCK
			end
		end

		if isVoidStomach and player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
			dmg = dmg * 1.5
			tempdmg = tempdmg * 1.5
			if extraStats then
				if extraStats.Tears and extraStats.Tears > 0 then extraStats.Tears = extraStats.Tears *1.5 end
				if extraStats.Speed and extraStats.Speed > 0 then extraStats.Speed = extraStats.Speed *1.5 end
				if extraStats.ShotSpeed and extraStats.ShotSpeed > 0 then extraStats.ShotSpeed = extraStats.ShotSpeed *1.5 end
				if extraStats.Range and extraStats.Range > 0 then extraStats.Range = extraStats.Range *1.5 end
				if extraStats.Luck and extraStats.Luck > 0 then extraStats.Luck = extraStats.Luck *1.5 end
			end
		end

		if tempdmg > 0 then
			--print("DMG GRANTED :",math.ceil(ADD_DMG *tempdmg), "=",ADD_DMG,"x",tempdmg)
			Mod:AddSlowTempDamage(player, ADD_DMG *tempdmg)
			--if Mod.RepentogonPlus then
			--	player:GetEffects():AddNullEffect(Mod.Enum.NullItem.TEMP_DMG_SLOW, false, math.ceil(ADD_DMG *tempdmg) )
			--else
			--	player:GetEffects():AddCollectibleEffect(Mod.Enum.Item.TEMP_DMG_SLOW, false, math.ceil(ADD_DMG *tempdmg) )
			--end
		end

		

		local permaStats = playerSave(SAVE_PERMA_STATS_NAME, player):Get({})
		permaStats.Damage = (permaStats.Damage or 0) + (dmg or 0)
		if extraStats then
			permaStats.Tears = (permaStats.Tears or 0) + (extraStats.Tears or 0)
			permaStats.Speed = (permaStats.Speed or 0) + (extraStats.Speed or 0)
			permaStats.ShotSpeed = (permaStats.ShotSpeed or 0) + (extraStats.ShotSpeed or 0)
			permaStats.Range = (permaStats.Range or 0) + (extraStats.Range or 0)
			permaStats.Luck = (permaStats.Luck or 0) + (extraStats.Luck or 0)
		end
		playerSave(SAVE_PERMA_STATS_NAME, player):Set(permaStats)
		Mod.PlayerTools.DoCache(player, cacheflags)

		
		for _, ent in ipairs(Mod:GetChoiceGroup(pickup)) do
			Mod:Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, ent.Position, Vector.Zero, nil)
			ent:Remove()
		end

		if itemCon.Type == ItemType.ITEM_ACTIVE and itemCon.ChargeType == ItemConfig.CHARGE_NORMAL and itemNoActive[sub] ~= true then
			player:UseActiveItem(sub, UseFlag.USE_NOANIM)
			if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
				player:UseActiveItem(sub, UseFlag.USE_NOANIM | UseFlag.USE_CARBATTERY)
			end
		end

		if Mod:IsTaintedGello(player) then
			local points = tGelloPointsSave:Get(0)
			local add = 1
			if itemExtraStatMod[sub] and itemExtraStatMod[sub].GelloPoints then
				add = itemExtraStatMod[sub].GelloPoints
			else
				add = 1.55 ^ itemCon.Quality +0.24
			end
			add = Mod:RoundToClosest(add, 0)
			if add < 1 then add = 1 end
			tGelloPointsSave:Set(points + add)
		end

		if pickup.Price ~= 0 then
			if REPENTOGON then
				if pickup:GetFlipCollectible() == nil then
					pickup:Remove()
					return true
				end
			elseif not Mod.PlayerTools.AnyPlayerHasCollectible(CollectibleType.COLLECTIBLE_FLIP) then
				pickup:Remove()
				return true
			end
			pickup.Price = 0
		end

		pickup.SubType = 0
		local sp = pickup:GetSprite()
		sp:ReplaceSpritesheet(1, "")
		sp:ReplaceSpritesheet(4, "")
		sp:LoadGraphics()
		
		return true
	end
	return false
end



function GelloCharMod:AddConsumeItemEffect(...)
	local list = {...}
	for idx, data in ipairs(list) do
		if type(data) == "table" then
			if type(data.Id) ~="number" then 
				error("argument #"..idx..", key Id is not a number", 2)
				return
			end
			local id = data.Id
			if data.Fun then
				itemExtraEffects[id] = data.Fun
			end
			if data.Stats then
				if type(data.Stats) ~= "table" then
					error("argument #"..idx..", key Stats is not a table", 2)
					return
				end
				itemExtraStatMod[id] = data.Stats
			end
			if data.NoActive then
				itemNoActive[id] = true
			end
			if data.EID then
				if type(data.EID) ~= "table" then
					data.EID = {en_us = tostring(data.EID)}
				end
				itemExtraEffectsEID[id] = data.EID
			end
		else
			error("argument #"..idx.." is not a table", 2)
		end
	end
end

function GelloCharMod:GetConsumeItemEffect(itemID)
	if itemID == -1 then return itemExtraStatMod end
	return itemExtraStatMod[itemID]
end


function GelloCharMod:SetPickupNonEat(pickup)
	local list = saveHand:Get({})
	list[tostring(pickup.InitSeed)] = true
	saveHand:Set(list)
end

function GelloCharMod:CanEatPickup(pickup)
	if pickup.Type ~= 5 or pickup.Variant ~= 100 or pickup.SubType == 0 or CONSUME_BLACKLIST[pickup.SubType] then return false end
	local list = saveHand:Get({})
	return list[tostring(pickup.InitSeed)] ~= true
end


if EID then
	EID:addDescriptionModifier(
		"Gello Desc Mod",
		function (descObj)
			local ent = EID.CurrentConditionalDescObj and EID.CurrentConditionalDescObj.Entity
			if not ent then return false end
			
			local player = EID:ClosestPlayerTo(ent)
			if player == nil then return false end

			if player:GetPlayerType() == Mod.Enum.Character.GELLO or
				Mod:IsTaintedGello(player) or
				player:HasCollectible(Mod.Enum.Item.VOID_STOMACH) then
				
				return descObj.ObjType == 5 and descObj.ObjVariant == 100 and descObj.ObjSubType >0 and Mod:CanEatPickup(ent)
			end
			return false
		end,
		function (descObj)
			local leng = EID:getLanguage()
			local desc = "#"
			local pickup = EID.CurrentConditionalDescObj.Entity:ToPickup()
			local player = EID:ClosestPlayerTo(pickup)
			--local isTainted = Mod:IsTaintedGello(player)

			desc = desc .. EID:GetPlayerIcon(player:GetPlayerType())

			local str = ""
			local sub = descObj.ObjSubType

			local itemCon = itemConfig:GetCollectible(sub)
			local itemval = itemCon.Quality+1
			local dmg = itemval /4
			local tempdmg = dmg *1.75 +0.25

			local voidNames = EID:getDescriptionEntry("VoidNames")
			
			if Mod:IsTaintedGello(player) then
				local add = 1
				if itemExtraStatMod[sub] and itemExtraStatMod[sub].GelloPoints then
					add = itemExtraStatMod[sub].GelloPoints
				else
					add = 1.55 ^ itemCon.Quality +0.24
				end
				add = Mod:RoundToClosest(add, 0)
				if add < 1 then add = 1 end
				desc = desc .. "#" EID:ReplaceVariableStr((itemExtraEffectsEID.TGelloPoints[leng] or itemExtraEffectsEID.TGelloPoints.en_us), 1, string.format("%.2g", add))
			end
			
			if itemCon.Type == ItemType.ITEM_ACTIVE and itemCon.ChargeType == ItemConfig.CHARGE_NORMAL and itemNoActive[sub] ~= true then
				desc = desc .. "#" .. (itemExtraEffectsEID.StatsName.ActiveItem[leng] or itemExtraEffectsEID.StatsName.ActiveItem.en_us)
			end

			if itemExtraStatMod[sub] then
				if itemExtraStatMod[sub].ForceDmg then
					dmg = itemExtraStatMod[sub].ForceDmg
				elseif itemExtraStatMod[sub].DmgOffset then
					dmg = dmg + itemExtraStatMod[sub].DmgOffset
				end
				if itemExtraStatMod[sub].ForceTempDmg then
					tempdmg = itemExtraStatMod[sub].ForceTempDmg
				elseif itemExtraStatMod[sub].TempDmgOffset then
					tempdmg = tempdmg+ itemExtraStatMod[sub].TempDmgOffset
				else tempdmg = dmg *1.75 +0.25
				end

				if dmg ~= 0 then
					local isPos = dmg >0
					str = str .. "#{{Arrow".. (isPos and "Up" or "Down") .. "}} {{Damage}}"..(isPos and " +" or " ").. EID:ReplaceVariableStr(voidNames[3], 1, string.format("%.4g", Mod:RoundToClosest(dmg, 2)))
				end
				if tempdmg > 0 then
					str = str .. "#{{ArrowUp}} {{Damage}} +".. EID:ReplaceVariableStr(
						itemExtraEffectsEID.StatsName.TempDmg[leng] or itemExtraEffectsEID.StatsName.TempDmg.en_us,
						1,
						string.format("%.4g", Mod:RoundToClosest(tempdmg , 2))
					)

				end

				if itemExtraStatMod[sub].Tears then
					local isPos = itemExtraStatMod[sub].Tears >0
					str = str .. "#{{Arrow".. (isPos and "Up" or "Down") .. "}} {{Tears}}"..(isPos and " +" or " ").. EID:ReplaceVariableStr(voidNames[2], 1, string.format("%.4g", Mod:RoundToClosest(itemExtraStatMod[sub].Tears, 2)))
				end
				if itemExtraStatMod[sub].Speed then
					local isPos = itemExtraStatMod[sub].Speed >0
					str = str .. "#{{Arrow".. (isPos and "Up" or "Down") .. "}} {{Speed}}"..(isPos and " +" or " ").. EID:ReplaceVariableStr(voidNames[1], 1, string.format("%.4g", Mod:RoundToClosest(itemExtraStatMod[sub].Speed, 2)))
				end
				if itemExtraStatMod[sub].ShotSpeed then
					local isPos = itemExtraStatMod[sub].ShotSpeed >0
					str = str .. "#{{Arrow".. (isPos and "Up" or "Down") .. "}} {{ShotSpeed}}"..(isPos and " +" or " ").. EID:ReplaceVariableStr(voidNames[5], 1, string.format("%.4g", Mod:RoundToClosest(itemExtraStatMod[sub].ShotSpeed, 2)))
				end
				if itemExtraStatMod[sub].Range then
					local isPos = itemExtraStatMod[sub].Range >0
					str = str .. "#{{Arrow".. (isPos and "Up" or "Down") .. "}} {{Range}}"..(isPos and " +" or " ").. EID:ReplaceVariableStr(voidNames[4], 1, string.format("%.4g", Mod:RoundToClosest(itemExtraStatMod[sub].Range, 2)))
				end
				if itemExtraStatMod[sub].Luck then
					local isPos = itemExtraStatMod[sub].Luck >0
					str = str .. "#{{Arrow".. (isPos and "Up" or "Down") .. "}} {{Luck}}"..(isPos and " +" or " ").. EID:ReplaceVariableStr(voidNames[6], 1, string.format("%.4g", Mod:RoundToClosest(itemExtraStatMod[sub].Luck, 2)))
				end
			else
				str = str .. "#{{ArrowUp}} +".. EID:ReplaceVariableStr(voidNames[3], 1, string.format("%.4g", Mod:RoundToClosest(dmg, 2)))
				str = str .. "#{{ArrowUp}} {{Damage}} +".. EID:ReplaceVariableStr(
					itemExtraEffectsEID.StatsName.TempDmg[leng] or itemExtraEffectsEID.StatsName.TempDmg.en_us,
					1,
					string.format("%.4g", Mod:RoundToClosest(tempdmg, 2))
				)

			end

			--str = str:gsub(".0 ", " ")-- make it look cleaner
			desc = desc .. "#".. str

			if itemExtraEffectsEID[sub] then
				local extraDesc = (itemExtraEffectsEID[sub][leng] or itemExtraEffectsEID[sub].en_us)
				if extraDesc then desc = desc .."#".. extraDesc end
			end

			if pickup.Price ~= 0 and pickup.Price ~= PickupPrice.PRICE_FREE then
				local extraDesc = (itemExtraEffectsEID.StatsName.Price[leng] or itemExtraEffectsEID.StatsName.Price.en_us)
				if extraDesc then desc = desc .."#".. extraDesc end
			end

			EID:appendToDescription(descObj, desc)

			return descObj
		end
	)
end