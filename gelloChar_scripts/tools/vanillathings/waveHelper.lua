local VERSION = 2.67
local YOUR_MOD = GelloCharMod
WaveHelper = WaveHelper or {}

if WaveHelper.Mod == nil then WaveHelper.Mod = YOUR_MOD end
if WaveHelper and WaveHelper.Version ~= nil and WaveHelper.Version >= VERSION then return end

WaveHelper.Version = VERSION
WaveHelper.RunData = WaveHelper.RunData or {}

local Mod = WaveHelper.Mod

if WaveHelper.Game == nil then WaveHelper.Game = Game() end
local game = WaveHelper.Game


WaveHelper.WaveType = {
	ALL_WAVES_NO_GIDEON = -2,
	ALL_WAVES = -1,
	WAVE_CHALLENGE = 0,
	WAVE_CHALLENGE_NORMAL = 1,
	WAVE_CHALLENGE_BOSS = 2,
	WAVE_BOSSRUSH = 10,
	WAVE_GREED = 20,
	WAVE_GREED_NORMAL = 21,
	WAVE_GREED_BOSS = 22,
	WAVE_GREED_EXTRABOSS = 23, WAVE_GREED_DEALBOSS = 23,-- extra boss fight in Greed mode
	WAVE_GIDEON = 30,
}

ModCallbacks.WC_WAVE_START = "WC_WAVE_START"
ModCallbacks.WC_WAVE_CHANGE = "WC_WAVE_CHANGE"
ModCallbacks.WC_WAVE_CLEAR = "WC_WAVE_CLEAR"
ModCallbacks.WC_WAVE_FINISH = "WC_WAVE_FINISH"

local WaveType = WaveHelper.WaveType


local function IsOldVersion() return VERSION < WaveHelper.Version end



local WaveGroupTypes = {
	[WaveType.WAVE_CHALLENGE] = {
		[WaveType.WAVE_CHALLENGE_NORMAL] = true,
		[WaveType.WAVE_CHALLENGE_BOSS] = true,
	},
	[WaveType.WAVE_CHALLENGE_NORMAL] = { [WaveType.WAVE_CHALLENGE] = true },
	[WaveType.WAVE_CHALLENGE_BOSS] = { [WaveType.WAVE_CHALLENGE] = true },
	[WaveType.WAVE_GREED] = {
		[WaveType.WAVE_GREED_NORMAL] = true,
		[WaveType.WAVE_GREED_BOSS] = true,
		[WaveType.WAVE_GREED_EXTRABOSS] = true,
	},
	[WaveType.WAVE_GREED_NORMAL] = { [WaveType.WAVE_GREED] = true},
	[WaveType.WAVE_GREED_BOSS] = {
		[WaveType.WAVE_GREED] = true,
		[WaveType.WAVE_GREED_EXTRABOSS] = true,
	},
	[WaveType.WAVE_GREED_EXTRABOSS] = { [WaveType.WAVE_GREED] = true },
}



local function CheckGroupType(callParam, param)
	if callParam == -2 or param == -2 or callParam == -1 or param == -1 or callParam == param then return true end
	if not WaveGroupTypes[callParam] then return false end
	return WaveGroupTypes[callParam][param] == true
end



function WaveHelper:LoadData(data)
	if type(data) == "nil" or type(data) == "table" then
		WaveHelper.RunData = data or {}
	else
		error("WaveHelper Save Data is not a table", 2)
	end
end
function WaveHelper:SaveData()
	return WaveHelper.RunData
end


function WaveHelper:GetVersion() return WaveHelper.Version end


function WaveHelper:GetWave()
	if game:IsGreedMode() then
		return game:GetLevel().GreedModeWave
	end
	return WaveHelper.RunData.WaveCount or 0
end

function WaveHelper:IsValidWaveRoom()
	if game:IsGreedMode() then return false end
	local roomData = game:GetLevel():GetCurrentRoomDesc().Data
	local rType = roomData.Type
	return (rType == RoomType.ROOM_CHALLENGE or
			rType == RoomType.ROOM_BOSSRUSH or
			(rType == RoomType.ROOM_BOSS and roomData.Subtype == 83))
end

function WaveHelper:IsGreedMainRoom()
	if game:GetLevel():GetStage() == 7 then return false end
	return game:IsGreedMode() and game:GetLevel():GetCurrentRoomDesc().SafeGridIndex == 84
end


local function CanRunFun(param, callParam)
	if param == WaveType.WAVE_GIDEON then
		return callParam and (param == callParam or callParam == -1)
	elseif callParam == WaveType.WAVE_GIDEON then return false
	elseif not callParam or not param or CheckGroupType(callParam, param) then
		return true
	end
	return false
end
local function CheckNRunCallback(callID, check, waveType, arg1, doAfter)
	if not check or not check() then return end
	for _, call in ipairs(Isaac.GetCallbacks(callID, true)) do
		if CanRunFun(waveType, call.Param) then
			call.Function(call.Mod, arg1, waveType)
		end
	end

	if doAfter then doAfter() end
end


local EnemieCount = 0
local function Waves()
	local room = game:GetRoom()
	local rType = room:GetType()
	local IsGideon = false
	local wType = 0
	local conEnemies = 0


	if rType == RoomType.ROOM_CHALLENGE then
		wType = WaveType.WAVE_CHALLENGE_NORMAL
		if game:GetLevel():HasBossChallenge() then wType = WaveType.WAVE_CHALLENGE_BOSS end

		conEnemies = Isaac.CountEnemies()

	elseif rType == RoomType.ROOM_BOSSRUSH then
		wType = WaveType.WAVE_BOSSRUSH
		conEnemies = Isaac.CountBosses()

	elseif rType == RoomType.ROOM_BOSS and game:GetLevel():GetCurrentRoomDesc().Data.Subtype == 83 then
		wType = WaveType.WAVE_GIDEON
		conEnemies = Isaac.CountEnemies() - #Isaac.FindByType(EntityType.ENTITY_GIDEON)
		IsGideon = true
	end


	local WaveNum = WaveHelper.RunData.WaveCount or 0
	CheckNRunCallback(ModCallbacks.WC_WAVE_START,
		function()
			if IsGideon then
				return not WaveHelper.RunData.WaveStarted and not room:IsClear()
			end
			return not WaveHelper.RunData.WaveStarted and room:IsAmbushActive()
		end,
		wType,
		WaveNum,
		function()
			WaveHelper.RunData.WaveStarted = true
			WaveHelper.RunData.WaveCount = WaveNum +1
		end)

	CheckNRunCallback(ModCallbacks.WC_WAVE_CLEAR,
		function() return conEnemies == 0 and EnemieCount > conEnemies end,
		wType,
		WaveNum-1)

	CheckNRunCallback(ModCallbacks.WC_WAVE_CHANGE,
		function() return EnemieCount == 0 and EnemieCount < conEnemies end,
		wType,
		WaveNum,
		function()
			WaveHelper.RunData.WaveCount = WaveNum +1
		end)

	CheckNRunCallback(ModCallbacks.WC_WAVE_FINISH,
		function()
			if IsGideon then
				return WaveHelper.RunData.WaveStarted and room:IsClear()
			end
			return WaveHelper.RunData.WaveStarted and room:IsAmbushDone()
		end,
		wType,
		WaveNum-1,
		function()
			WaveHelper.RunData = {}
		end)

	EnemieCount = conEnemies
end

local GreedLastWave = 0
local lastRoomClearState = true
local function WavesGreed()
	local conGreedWave = game:GetLevel().GreedModeWave
	local wType = WaveType.WAVE_GREED_NORMAL

	if conGreedWave >= game:GetGreedBossWaveNum() then
		if conGreedWave == game:GetGreedBossWaveNum() +2 then
			wType = WaveType.WAVE_GREED_EXTRABOSS
		else
			wType = WaveType.WAVE_GREED_BOSS
		end
	end

	local conRoomClear = game:GetRoom():IsClear()

	CheckNRunCallback(ModCallbacks.WC_WAVE_START,
		function() return lastRoomClearState and not conRoomClear end,
		wType,
		conGreedWave)

	CheckNRunCallback(ModCallbacks.WC_WAVE_CLEAR,
		function() return not lastRoomClearState and conRoomClear and conGreedWave == GreedLastWave end,
		wType,
		conGreedWave)

	CheckNRunCallback(ModCallbacks.WC_WAVE_CHANGE,
		function() return not conRoomClear and conGreedWave > GreedLastWave end,
		wType,
		conGreedWave,
		function() GreedLastWave = conGreedWave end)

	CheckNRunCallback(ModCallbacks.WC_WAVE_FINISH,
		function() return not lastRoomClearState and conRoomClear end,
		wType,
		conGreedWave)

	lastRoomClearState = conRoomClear
end


local function WaveUpdate()
	if WaveHelper:IsGreedMainRoom() then WavesGreed()
	elseif WaveHelper:IsValidWaveRoom() then Waves()
	end
end

local function OnNewRoom()
	if game:IsGreedMode() then
		lastRoomClearState = true
		return
	end
	if not WaveHelper:IsValidWaveRoom() then return end
	LastWave = 0
	EnemieCount = 0
	WaveHelper.RunData = {}
end

local function ResetWaveGreed()
	GreedLastWave = 0
	lastRoomClearState = true
end


local function PostLoad()
	if IsOldVersion() then return end
	if not WaveHelper.Init then
		print( ("WaveHelper Version ".. WaveHelper.Version.." has been set up") )
		OnNewRoom()
		ResetWaveGreed()

		Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, WaveUpdate)
		Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, OnNewRoom)
		Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, ResetWaveGreed)
	end
	WaveHelper.Init = true
end
Mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, 2^16, PostLoad)

