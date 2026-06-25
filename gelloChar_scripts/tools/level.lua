local Mod = GelloCharMod
local game = Mod.Game
local tTools = Mod.TableTools

--- get level RNG
--- get room RNG
--- 
local LevelTools = {}



if Mod.Repentogon then
function LevelTools.GetDimension()
	return game:GetLevel():GetDimension()
end
else
function LevelTools.GetDimension()
	local level = game:GetLevel()
    local desc = level:GetCurrentRoomDesc()
    local ptr = GetPtrHash(desc)
    for dimension = 0, 2 do
        if GetPtrHash( level:GetRoomByIdx(desc.SafeGridIndex, dimension) ) == ptr then
            return dimension
        end
    end
end
end


function LevelTools.IsAltPath()
	local level = game:GetLevel()
	return level:GetStageType() >= StageType.STAGETYPE_REPENTANCE
end



local LEVEL_RNG = RNG()
local LevelSeed
function LevelTools.GeLevelRNG()
	if LevelSeed == nil then
		LevelSeed = game:GetLevel():GetDungeonPlacementSeed()
		LEVEL_RNG:SetSeed(LevelSeed, 20)
	end
	
	return LEVEL_RNG
end


local prevRoomIdx = ""
local prevDimension = ""
local ROOM_RNG = RNG()
function LevelTools.GetRoomRNG(roomIndex, dim)
	dim = dim or LevelTools.GetDimension()
	local level = game:GetLevel()
	local roomIndex = roomIndex or level:GetCurrentRoomIndex()
	local strDim = tostring(dim)
	local strRoomIndex = tostring(roomIndex)

	if prevDimension == strDim and prevRoomIdx == strRoomIndex then return ROOM_RNG end
	
	local roomRNGSeedList = Mod.SaveHandler.Level("rooms_RNGSeed"):Get({})
	roomRNGSeedList[strDim] = roomRNGSeedList[strDim] or {}
	roomRNGSeedList[strDim][strRoomIndex] = roomRNGSeedList[strDim][roomInstrRoomIndexdex] or level:GetRoomByIdx(roomIndex, dim).DecorationSeed
	
	if prevDimension ~= "" then roomRNGSeedList[prevDimension][prevRoomIdx] = ROOM_RNG:GetSeed() end
	Mod.SaveHandler.Level("rooms_RNGSeed"):Set(roomRNGSeedList)

	ROOM_RNG:SetSeed(roomRNGSeedList[strDim][strRoomIndex], 30)

	prevRoomIdx = strRoomIndex
	prevDimension = strDim

	return ROOM_RNG
end
Mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, -200, function()
	LevelSeed = Mod.SaveHandler.Level("RNGSeed"):Get(game:GetLevel():GetDungeonPlacementSeed())
	LEVEL_RNG:SetSeed(LevelSeed, 35)
	prevRoomIdx = ""
	prevDimension = ""

	Mod.SaveHandler.Level("rooms_RNGSeed"):Get({})
end)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_GAME_EXIT, 200, function()
	Mod.SaveHandler.Level("RNGSeed"):Set(LevelSeed)
	
	local roomRNGSeedList = Mod.SaveHandler.Level("rooms_RNGSeed"):Get({})
	if prevDimension ~= "" then roomRNGSeedList[prevDimension][prevRoomIdx] = ROOM_RNG:GetSeed() end
	Mod.SaveHandler.Level("rooms_RNGSeed"):Set(roomRNGSeedList)
end)
Mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, -199, function()
	if Mod.RunStarted ~= true then return end
	Mod.SaveHandler.Level("RNGSeed"):Set(game:GetLevel():GetDungeonPlacementSeed())
	Mod.SaveHandler.Level("rooms_RNGSeed"):Set({})

	prevRoomIdx = ""
	prevDimension = ""
end)



function LevelTools.GetLevelsTravel()
	local level = game:GetLevel()
	local stage = level:GetStage()

	if stage == LevelStage.STAGE8 then
		return 11
	end
	if level:GetStageType() >= StageType.STAGETYPE_REPENTANCE then
		stage = stage +1
	end
	if level:IsAscent() then
		stage = 10 - stage
	end
	return stage
end


function LevelTools.GetRoomCount()
	local count = 0
	local checkedSafeGrids = {}
	local levelRooms = game:GetLevel():GetRooms()
	for i = 0, levelRooms.Size -1 do
		local gridIdx = levelRooms:Get(i).SafeGridIndex

		if not checkedSafeGrids[gridIdx] then
			checkedSafeGrids[gridIdx] = true
			count = count +1
		end
	end

	return count
end


local specialRooms = tTools.Set({
	RoomType.ROOM_SHOP,
	RoomType.ROOM_TREASURE,
	RoomType.ROOM_BOSS,
	RoomType.ROOM_MINIBOSS,
	RoomType.ROOM_SECRET,
	RoomType.ROOM_SUPERSECRET,
	RoomType.ROOM_ARCADE,
	RoomType.ROOM_CURSE,
	RoomType.ROOM_CHALLENGE,
	RoomType.ROOM_LIBRARY,
	RoomType.ROOM_SACRIFICE,
	RoomType.ROOM_ISAACS,
	RoomType.ROOM_BARREN,
	RoomType.ROOM_CHEST,
	RoomType.ROOM_DICE,
	RoomType.ROOM_PLANETARIUM,
	RoomType.ROOM_ULTRASECRET,
})
function LevelTools.GetSpecialRoomsIdxs(roomList, isWhiteList)
	local roomList = roomList or {}
	local returnList = {}
	local validList = tTools.Copy(specialRooms)
	
	if type(roomList) ~= "table" then roomList = {roomList} end
	if #roomList > 0 then roomList = tTools.Set(roomList) end

	if isWhiteList then
		local resetList = {}
		for t, _ in pairs(validList) do
			if roomList[t] then
				validList[t] = true
			else
				validList[t] = false
			end
		end
	else
		for t, _ in pairs(validList) do
			if roomList[t] then
				validList[t] = false
			else
				validList[t] = true
			end
		end
	end

	local checkedSafeGrids = {}

	local levelRooms = game:GetLevel():GetRooms()
	for i = 0, levelRooms.Size -1 do
		local gridIdx = levelRooms:Get(i).SafeGridIndex
		local rType = levelRooms:Get(i).Data.Type

		if validList[ rType ] and not checkedSafeGrids[gridIdx] then
			checkedSafeGrids[gridIdx] = true
			table.insert(returnList, gridIdx)
		end
	end

	return returnList
end


function LevelTools.IsSpecialRoomOnFloor(roomType)
	local levelRooms = game:GetLevel():GetRooms()
	for i = 0, levelRooms.Size -1 do
		local gridIdx = levelRooms:Get(i).SafeGridIndex
		local rType = levelRooms:Get(i).Data.Type

		if specialRooms[ rType ] and rType == roomType then
			return true
		end
	end
	return false
end


function LevelTools.GetSpecialRoomNum(roomType)
	local num = 0
	local levelRooms = game:GetLevel():GetRooms()
	for i = 0, levelRooms.Size -1 do
		local gridIdx = levelRooms:Get(i).SafeGridIndex
		local rType = levelRooms:Get(i).Data.Type

		if specialRooms[ rType ] and rType == roomType then
			num = num +1
		end
	end
	return num
end


function LevelTools.IsCursePresent(curseFlags, checkForAll)
	local lvlCurses = game:GetLevel():GetCurses()
	if checkForAll then
		return ( lvlCurses & curseFlags ) == curseFlags
	end

	return ( lvlCurses & curseFlags ) > 0
end


function LevelTools.AddCurse(curseID)
	local wasAdded = not LevelTools.IsCursePresent(curseFlags, true)
	game:GetLevel():AddCurse(curseFlags)
	
	return wasAdded
end


local doorSlotIdxFun = {
	[RoomShape.ROOMSHAPE_1x1] = function(index, doorSlot)
		if doorSlot >= DoorSlot.LEFT1 then
			return -1
		end
		return index
	end,
	[RoomShape.ROOMSHAPE_IH] = function(index, doorSlot)
		if doorSlot >= DoorSlot.LEFT1 or doorSlot == DoorSlot.UP0 or doorSlot == DoorSlot.DOWN0 then
			return -1
		end
		return index
	end,
	[RoomShape.ROOMSHAPE_IV] = function(index, doorSlot)
		if doorSlot >= DoorSlot.LEFT1 or doorSlot == DoorSlot.RIGHT0 or doorSlot == DoorSlot.LEFT0 then
			return -1
		end
		return index
	end,
	[RoomShape.ROOMSHAPE_1x2] = function(index, doorSlot)
		if doorSlot == DoorSlot.UP1 or doorSlot == DoorSlot.DOWN1 then
			return -1
		elseif doorSlot == DoorSlot.DOWN0 or doorSlot == DoorSlot.LEFT1 or doorSlot == DoorSlot.RIGHT1 then
			return index +13
		end
		return index
	end,
	[RoomShape.ROOMSHAPE_IIV] = function(index, doorSlot)
		if doorSlot % 4 == 2 or doorSlot % 4 == 0 or doorSlot == DoorSlot.UP1 or doorSlot == DoorSlot.DOWN1 then
			return -1
		elseif doorSlot == DoorSlot.DOWN0 then
			return index +13
		end
		return index
	end,
	[RoomShape.ROOMSHAPE_2x1] = function(index, doorSlot)
		if doorSlot == DoorSlot.LEFT1 or doorSlot == DoorSlot.RIGHT1 then
			return -1
		elseif doorSlot == DoorSlot.RIGHT0 or doorSlot == DoorSlot.UP1 or doorSlot == DoorSlot.DOWN1 then
			return index +1
		end
		return index
	end,
	[RoomShape.ROOMSHAPE_IIH] = function(index, doorSlot)
		if doorSlot % 4 == 3 or doorSlot % 4 == 1 or doorSlot == DoorSlot.LEFT1 or doorSlot == DoorSlot.RIGHT1 then
			return -1
		elseif doorSlot == DoorSlot.RIGHT0 then
			return index +1
		end
		return index
	end,
	[RoomShape.ROOMSHAPE_2x2] = function(index, doorSlot)
		if doorSlot == DoorSlot.RIGHT0 or doorSlot == DoorSlot.UP1 then
			return index +1
		elseif doorSlot == DoorSlot.DOWN0 or doorSlot == DoorSlot.LEFT1 then
			return index +13
		elseif doorSlot == DoorSlot.DOWN1 or doorSlot == DoorSlot.RIGHT1 then
			return index +14
		end
		return index
	end,
	[RoomShape.ROOMSHAPE_LTL] = function(index, doorSlot)
		if doorSlot == DoorSlot.UP0 or doorSlot == DoorSlot.DOWN0 or doorSlot == DoorSlot.LEFT1 then
			return index +12
		elseif doorSlot == DoorSlot.RIGHT1 or doorSlot == DoorSlot.DOWN1 then
			return index +13
		end
		return index
	end,
	[RoomShape.ROOMSHAPE_LTR] = function(index, doorSlot)
		if doorSlot == DoorSlot.UP1 or doorSlot == DoorSlot.RIGHT1 or doorSlot == DoorSlot.DOWN1 then
			return index +14
		elseif doorSlot == DoorSlot.DOWN0 or doorSlot == DoorSlot.LEFT1 then
			return index +13
		end
		return index
	end,
	[RoomShape.ROOMSHAPE_LBL] = function(index, doorSlot)
		if doorSlot == DoorSlot.LEFT1 or doorSlot == DoorSlot.RIGHT1 or doorSlot == DoorSlot.DOWN1 then
			return index +14
		elseif doorSlot == DoorSlot.RIGHT0 or doorSlot == DoorSlot.UP1 then
			return index +1
		end
		return index
	end,
	[RoomShape.ROOMSHAPE_LBR] = function(index, doorSlot)
		if doorSlot == DoorSlot.DOWN0 or doorSlot == DoorSlot.UP1 or doorSlot == DoorSlot.RIGHT1 then
			return index +13
		elseif doorSlot == DoorSlot.RIGHT0 or doorSlot == DoorSlot.LEFT1 or doorSlot == DoorSlot.DOWN1 then
			return index +1
		end
		return index
	end,
}
function LevelTools.GetDoorSlotRoomIdx(doorSlot)
	if doorSlot < 0 or doorSlot > 7 then return -1 end
	local level = game:GetLevel()
	local roomIndex = level:GetCurrentRoomIndex()

	local roomDesc = level:GetCurrentRoomDesc()
	if roomDesc.Data == nil then return -1 end

	local roomShape = roomDesc.Data.Shape

	return tTools.Switch(roomShape, doorSlotIdxFun, function() return -1 end)(roomDesc.SafeGridIndex, doorSlot)
end


local roomNeigFun = {
	[RoomShape.ROOMSHAPE_1x1] = function(index)
		local tab = {}
		local level = game:GetLevel()

		if index % 13 ~= 0 then
			local roomDesc = level:GetRoomByIdx(index -1)
			if roomDesc.Data then
				tab[DoorSlot.LEFT0] = roomDesc
			end
		end
		if index > 12 then
			local roomDesc = level:GetRoomByIdx(index -13)
			if roomDesc.Data then
				tab[DoorSlot.UP0] = roomDesc
			end
		end
		if index % 13 ~= 12 then
			local roomDesc = level:GetRoomByIdx(index +1)
			if roomDesc.Data then
				tab[DoorSlot.RIGHT0] = roomDesc
			end
		end
		if index < 156 then
			local roomDesc = level:GetRoomByIdx(index +13)
			if roomDesc.Data then
				tab[DoorSlot.DOWN0] = roomDesc
			end
		end

		return tab
	end,
	[RoomShape.ROOMSHAPE_IH] = function(index)
		local tab = {}
		local level = game:GetLevel()

		if index % 13 ~= 0 then
			local roomDesc = level:GetRoomByIdx(index -1)
			if roomDesc.Data then
				tab[DoorSlot.LEFT0] = roomDesc
			end
		end
		if index % 13 ~= 12 then
			local roomDesc = level:GetRoomByIdx(index +1)
			if roomDesc.Data then
				tab[DoorSlot.RIGHT0] = roomDesc
			end
		end

		return tab
	end,
	[RoomShape.ROOMSHAPE_IV] = function(index)
		local tab = {}
		local level = game:GetLevel()

		if index > 12 then
			local roomDesc = level:GetRoomByIdx(index -13)
			if roomDesc.Data then
				tab[DoorSlot.UP0] = roomDesc
			end
		end
		if index < 156 then
			local roomDesc = level:GetRoomByIdx(index +13)
			if roomDesc.Data then
				tab[DoorSlot.DOWN0] = roomDesc
			end
		end

		return tab
	end,
	[RoomShape.ROOMSHAPE_1x2] = function(index)
		local tab = {}
		local level = game:GetLevel()

		if index % 13 ~= 0 then
			local roomDesc = level:GetRoomByIdx(index -1)
			local roomDesc2 = level:GetRoomByIdx(index +12 )
			if roomDesc.Data then
				tab[DoorSlot.LEFT0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.LEFT1] = roomDesc2
			end
		end
		if index > 12 then
			local roomDesc = level:GetRoomByIdx(index -13)
			if roomDesc.Data then
				tab[DoorSlot.UP0] = roomDesc
			end
		end
		if index % 13 ~= 12 then
			local roomDesc = level:GetRoomByIdx(index +1)
			local roomDesc2 = level:GetRoomByIdx(index +14)
			if roomDesc.Data then
				tab[DoorSlot.RIGHT0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.RIGHT1] = roomDesc2
			end
		end
		if index < 143 then
			local roomDesc = level:GetRoomByIdx(index +26)
			if roomDesc.Data then
				tab[DoorSlot.DOWN0] = roomDesc
			end
		end

		return tab
	end,
	[RoomShape.ROOMSHAPE_IIV] = function(index)
		local tab = {}
		local level = game:GetLevel()

		if index > 12 then
			local roomDesc = level:GetRoomByIdx(index -13)
			if roomDesc.Data then
				tab[DoorSlot.UP0] = roomDesc
			end
		end
		if index < 143 then
			local roomDesc = level:GetRoomByIdx(index +26)
			if roomDesc.Data then
				tab[DoorSlot.DOWN0] = roomDesc
			end
		end

		return tab
	end,
	[RoomShape.ROOMSHAPE_2x1] = function(index)
		local tab = {}
		local level = game:GetLevel()

		if index % 13 ~= 0 then
			local roomDesc = level:GetRoomByIdx(index -1)
			if roomDesc.Data then
				tab[DoorSlot.LEFT0] = roomDesc
			end
		end
		if index > 12 then
			local roomDesc = level:GetRoomByIdx(index -13)
			local roomDesc2 = level:GetRoomByIdx(index -12)
			if roomDesc.Data then
				tab[DoorSlot.UP0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.UP1] = roomDesc2
			end
		end
		if (index+1) % 13 ~= 12 then
			local roomDesc = level:GetRoomByIdx(index +2)
			if roomDesc.Data then
				tab[DoorSlot.RIGHT0] = roomDesc
			end
		end
		if index < 156 then
			local roomDesc = level:GetRoomByIdx(index +13)
			local roomDesc2 = level:GetRoomByIdx(index +14)
			if roomDesc.Data then
				tab[DoorSlot.DOWN0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.DOWN1] = roomDesc2
			end
		end

		return tab
	end,
	[RoomShape.ROOMSHAPE_IIH] = function(index)
		local tab = {}
		local level = game:GetLevel()

		if index % 13 ~= 0 then
			local roomDesc = level:GetRoomByIdx(index -1)
			if roomDesc.Data then
				tab[DoorSlot.LEFT0] = roomDesc
			end
		end
		if (index+1) % 13 ~= 12 then
			local roomDesc = level:GetRoomByIdx(index +2)
			if roomDesc.Data then
				tab[DoorSlot.RIGHT0] = roomDesc
			end
		end

		return tab
	end,
	[RoomShape.ROOMSHAPE_2x2] = function(index)
		local tab = {}
		local level = game:GetLevel()

		if index % 13 ~= 0 then
			local roomDesc = level:GetRoomByIdx(index -1)
			local roomDesc2 = level:GetRoomByIdx(index +12 )
			if roomDesc.Data then
				tab[DoorSlot.LEFT0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.LEFT1] = roomDesc2
			end
		end
		if index > 12 then
			local roomDesc = level:GetRoomByIdx(index -13)
			local roomDesc2 = level:GetRoomByIdx(index -12)
			if roomDesc.Data then
				tab[DoorSlot.UP0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.UP1] = roomDesc2
			end
		end
		if (index+1) % 13 ~= 12 then
			local roomDesc = level:GetRoomByIdx(index +2)
			local roomDesc2 = level:GetRoomByIdx(index +15)
			if roomDesc.Data then
				tab[DoorSlot.RIGHT0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.RIGHT1] = roomDesc2
			end
		end
		if index < 143 then
			local roomDesc = level:GetRoomByIdx(index +26)
			local roomDesc2 = level:GetRoomByIdx(index +27)
			if roomDesc.Data then
				tab[DoorSlot.DOWN0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.DOWN1] = roomDesc2
			end
		end

		return tab
	end,
	[RoomShape.ROOMSHAPE_LTL] = function(index)
		local tab = {}
		local level = game:GetLevel()

		if (index-1) % 13 ~= 0 then
			local roomDesc = level:GetRoomByIdx(index -1)
			local roomDesc2 = level:GetRoomByIdx(index +11 )
			if roomDesc.Data then
				tab[DoorSlot.LEFT0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.LEFT1] = roomDesc2
			end
		end
		if index > 12 then
			local roomDesc = level:GetRoomByIdx(index -1)
			local roomDesc2 = level:GetRoomByIdx(index -13)
			if roomDesc.Data then
				tab[DoorSlot.UP0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.UP1] = roomDesc2
			end
		end
		if (index+1) % 13 ~= 12 then
			local roomDesc = level:GetRoomByIdx(index +1)
			local roomDesc2 = level:GetRoomByIdx(index +14)
			if roomDesc.Data then
				tab[DoorSlot.RIGHT0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.RIGHT1] = roomDesc2
			end
		end
		if index < 143 then
			local roomDesc = level:GetRoomByIdx(index +25)
			local roomDesc2 = level:GetRoomByIdx(index +26)
			if roomDesc.Data then
				tab[DoorSlot.DOWN0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.DOWN1] = roomDesc2
			end
		end
		if (index-1) % 13 == 0 or index < 13 then
			local roomDesc = level:GetRoomByIdx(index -1)
			if roomDesc.Data then
				tab[DoorSlot.LEFT0] = roomDesc
				tab[DoorSlot.UP0] = roomDesc
			end
		end

		return tab
	end,
	[RoomShape.ROOMSHAPE_LTR] = function(index)
		local tab = {}
		local level = game:GetLevel()

		if index % 13 ~= 0 then
			local roomDesc = level:GetRoomByIdx(index -1)
			local roomDesc2 = level:GetRoomByIdx(index +12 )
			if roomDesc.Data then
				tab[DoorSlot.LEFT0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.LEFT1] = roomDesc2
			end
		end
		if index > 12 then
			local roomDesc = level:GetRoomByIdx(index -13)
			local roomDesc2 = level:GetRoomByIdx(index +1)
			if roomDesc.Data then
				tab[DoorSlot.UP0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.UP1] = roomDesc2
			end
		end
		if (index+1) % 13 ~= 12 then
			local roomDesc = level:GetRoomByIdx(index +1)
			local roomDesc2 = level:GetRoomByIdx(index +15)
			if roomDesc.Data then
				tab[DoorSlot.RIGHT0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.RIGHT1] = roomDesc2
			end
		end
		if index < 143 then
			local roomDesc = level:GetRoomByIdx(index +26)
			local roomDesc2 = level:GetRoomByIdx(index +27)
			if roomDesc.Data then
				tab[DoorSlot.DOWN0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.DOWN1] = roomDesc2
			end
		end

		if (index+1) % 13 == 12 or index < 13 then
			local roomDesc = level:GetRoomByIdx(index +1)
			if roomDesc.Data then
				tab[DoorSlot.UP1] = roomDesc
				tab[DoorSlot.RIGHT0] = roomDesc
			end
		end

		return tab
	end,
	[RoomShape.ROOMSHAPE_LBL] = function(index)
		local tab = {}
		local level = game:GetLevel()

		if index % 13 ~= 0 then
			local roomDesc = level:GetRoomByIdx(index -1)
			local roomDesc2 = level:GetRoomByIdx(index +13)
			if roomDesc.Data then
				tab[DoorSlot.LEFT0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.LEFT1] = roomDesc2
			end
		end
		if index > 12 then
			local roomDesc = level:GetRoomByIdx(index -13)
			local roomDesc2 = level:GetRoomByIdx(index -12)
			if roomDesc.Data then
				tab[DoorSlot.UP0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.UP1] = roomDesc2
			end
		end
		if (index+1) % 13 ~= 12 then
			local roomDesc = level:GetRoomByIdx(index +2)
			local roomDesc2 = level:GetRoomByIdx(index +15)
			if roomDesc.Data then
				tab[DoorSlot.RIGHT0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.RIGHT1] = roomDesc2
			end
		end
		if index < 143 then
			local roomDesc = level:GetRoomByIdx(index +13)
			local roomDesc2 = level:GetRoomByIdx(index +27)
			if roomDesc.Data then
				tab[DoorSlot.DOWN0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.DOWN1] = roomDesc2
			end
		end

		if index % 13 == 0 or index > 142 then
			local roomDesc = level:GetRoomByIdx(index +13)
			if roomDesc.Data then
				tab[DoorSlot.DOWN0] = roomDesc
				tab[DoorSlot.LEFT1] = roomDesc
			end
		end

		return tab
	end,
	[RoomShape.ROOMSHAPE_LBR] = function(index)
		local tab = {}
		local level = game:GetLevel()

		if index % 13 ~= 0 then
			local roomDesc = level:GetRoomByIdx(index -1)
			local roomDesc2 = level:GetRoomByIdx(index +12 )
			if roomDesc.Data then
				tab[DoorSlot.LEFT0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.LEFT1] = roomDesc2
			end
		end
		if index > 12 then
			local roomDesc = level:GetRoomByIdx(index -13)
			local roomDesc2 = level:GetRoomByIdx(index -12)
			if roomDesc.Data then
				tab[DoorSlot.UP0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.UP1] = roomDesc2
			end
		end
		if (index+1) % 13 ~= 12 then
			local roomDesc = level:GetRoomByIdx(index +2)
			local roomDesc2 = level:GetRoomByIdx(index +14)
			if roomDesc.Data then
				tab[DoorSlot.RIGHT0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.RIGHT1] = roomDesc2
			end
		end
		if index < 143 then
			local roomDesc = level:GetRoomByIdx(index +26)
			local roomDesc2 = level:GetRoomByIdx(index +14)
			if roomDesc.Data then
				tab[DoorSlot.DOWN0] = roomDesc
			end
			if roomDesc2.Data then
				tab[DoorSlot.DOWN1] = roomDesc2
			end
		end

		if (index+1) % 13 == 12 or index > 142 then
			local roomDesc = level:GetRoomByIdx(index +14)
			if roomDesc.Data then
				tab[DoorSlot.DOWN1] = roomDesc
				tab[DoorSlot.RIGHT1] = roomDesc
			end
		end

		return tab
	end,
}
function LevelTools.GetNeighboringRooms(roomIndex)
	local roomIndex = roomIndex or game:GetLevel():GetCurrentRoomIndex()
	if roomIndex < 0 or roomIndex > 168 then return {} end

	local roomDesc = game:GetLevel():GetRoomByIdx(roomIndex)
	if roomDesc.Data == nil then return {} end

	local roomShape = roomDesc.Data.Shape

	return tTools.Switch(roomShape, roomNeigFun, function() return {} end)(roomDesc.SafeGridIndex)
end


GelloCharMod.LevelTools = LevelTools