local Mod = GelloCharMod


local function copy(tab)
	if type(tab) ~= "table" then return tab end

	local newTab = {}
	for tabName, tabData in pairs(tab) do
		if type(tabData) == "table" then
			newTab[tabName] = copy(tabData)
		else
			newTab[tabName] = tabData
		end
	end

	return newTab
end

local SaveHandler = {}
GelloCharMod.SaveHandler = SaveHandler


function SaveHandler.Data(dataType)
	local f = {}


	function f:Get(default)
		if default == nil then default = {} end
		GelloCharMod.Data = GelloCharMod.Data or {}
		local data = GelloCharMod.Data[dataType]

		return (data ~= nil and data or copy(default))
	end

	function f:Set(setData)
		GelloCharMod.Data = GelloCharMod.Data or {}
		GelloCharMod.Data[dataType] = setData
	end


	return f
end


function SaveHandler.Save(saveType)
	local f = {}


	function f:Get(default)
		if default == nil then default = {} end
		GelloCharMod.Data.Save = GelloCharMod.Data.Save or {}
		local save = GelloCharMod.Data.Save[saveType]

		return (save ~= nil and save or copy(default))
	end

	function f:Set(data)
		GelloCharMod.Data.Save = GelloCharMod.Data.Save or {}
		GelloCharMod.Data.Save[saveType] = data
	end


	return f
end


function SaveHandler.StaticSave(saveType)
	local f = {}


	function f:Get(default)
		if default == nil then default = {} end
		GelloCharMod.Data.StaticSave = GelloCharMod.Data.StaticSave or {}
		local save = GelloCharMod.Data.StaticSave[saveType]

		return (save ~= nil and save or copy(default))
	end

	function f:Set(data)
		GelloCharMod.Data.StaticSave = GelloCharMod.Data.StaticSave or {}
		GelloCharMod.Data.StaticSave[saveType] = data
	end


	return f
end


function SaveHandler.Player(saveType, player, justPlayers)
	if not type(player) == "userdata" or not player.ToPlayer or not player:ToPlayer() then Mod:Error("function SaveHandler.Player argument #2 is nil", 2) end

	local pSave = SaveHandler.Save("Player"):Get({})
	local index = Mod.PlayerTools.GetIndex(player, justPlayers)

	local f = {}


	function f:Get(default)
		if default == nil then default = {} end
		pSave[saveType] = pSave[saveType] or {}
		local save = pSave[saveType][index]

		return (save ~= nil and save or copy(default))
	end

	function f:Set(data)
		pSave[saveType] = pSave[saveType] or {}
		pSave[saveType][index] = data

		SaveHandler.Save("Player"):Set(pSave)
	end

	function f:ClearAll()
		pSave[saveType] = {}
		SaveHandler.Save("Player"):Set(pSave)
	end

	function f:ReloadAll()
		pSave[saveType] = pSave[saveType] or {}
		SaveHandler.Save("Player"):Set(pSave)
	end


	return f
end


function SaveHandler.Level(saveType)
	local f = {}


	function f:Get(default)
		local levelData = SaveHandler.Save("LevelData"):Get({})
		return (levelData[saveType] ~= nil and levelData[saveType] or copy(default))
	end

	function f:Set(data)
		local levelData = SaveHandler.Save("LevelData"):Get({})
		levelData[saveType] = data

		SaveHandler.Save("LevelData"):Set(levelData)
	end


	return f
end


function SaveHandler.Room(saveType, roomIndex)
	local roomIndex = tostring( (roomIndex or Mod.Game:GetLevel():GetCurrentRoomIndex()) )
	local f = {}


	function f:Get(default)
		local roomData = SaveHandler.Save("RoomData"):Get({})
		roomData[roomIndex] = roomData[roomIndex] or {}
		local save = roomData[roomIndex][saveType]

		return (save ~= nil and save or copy(default))
	end

	function f:Set(data)
		local roomData = SaveHandler.Save("RoomData"):Get({})
		roomData[roomIndex] = roomData[roomIndex] or {}

		roomData[roomIndex][saveType] = data
		SaveHandler.Save("RoomData"):Set(roomData)
	end


	return f
end
Mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, -200, function()
	SaveHandler.Save("RoomData"):Set({})
	SaveHandler.Save("LevelData"):Set({})
end)