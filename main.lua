GelloCharMod = RegisterMod("Gello Character", 1)
GelloCharMod.Version = 1.203


GelloCharMod.Data = {}
GelloCharMod.Data.Save = {}
GelloCharMod.Data.PreSave = {}
GelloCharMod.Data.StaticSave = {}
GelloCharMod.RNG = RNG()
GelloCharMod.json = require("json")
GelloCharMod.SFX = SFXManager()
GelloCharMod.Game = Game()


function GelloCharMod.Include(rute)
	return require("gelloChar_scripts."..rute)
end
--[[
local oldAddCall = GelloCharMod.AddCallback
local oldAddProiCall = GelloCharMod.AddPriorityCallback

local wrongFun = {}
local funLocation = {}

local function warpFun(fun)
	return function(self, ...)
		local status, ret = pcall(fun, self, ...)
		if not status then
			if not wrongFun[tostring(fun)] then
				print(funLocation[tostring(fun)])
				wrongFun[tostring(fun)] = true
			end
		else
			return ret
		end
	end
end

function GelloCharMod:AddCallback(callID, fun, param)
	local _, ret = pcall(error, "aaaaa", 3)
	funLocation[tostring(fun)] = ret
	oldAddCall(self, callID, warpFun(fun), param)
end

function GelloCharMod:AddPriorityCallback(callID, priority, fun, param)
	local _, ret = pcall(error, "aaaaa", 3)
	funLocation[tostring(fun)] = ret
	oldAddProiCall(self, callID, priority, warpFun(fun), param)
end
]]

local function clearData()
	GelloCharMod.Data.Save = {}
	GelloCharMod.Data.PreSave = {}
	GelloCharMod.Data.StaticSave = {}
end

local function setupData()
	if GelloCharMod:HasData() then GelloCharMod.Data = GelloCharMod.json.decode(GelloCharMod:LoadData()) end

	local mnaData = GelloCharMod.SaveHandler.Data("MarksNAchievements"):Get({Achievements = {}, Marks = {}})
	mnaData.Achievements = GelloCharMod:RegenerateAchievements(mnaData.Achievements)
	if mnaData.Achievements.VOID_STOMACH == 0 then
		local allMarks = true
		local count = 0
		for _, val in pairs(mnaData.Marks.GELLO) do
			if val ~= 2 then allMarks = false; break end
			count = count+1
		end
		if count == #MarksNAchievHelper.MarkType.ALL_MARKS and allMarks then mnaData.Achievements.VOID_STOMACH = 1 end
	end
		
	GelloCharMod.SyncSettings()
	local settings =GelloCharMod.Data and GelloCharMod.Data.Settings
	if settings then
		settings.SemiClassicGello = nil
		settings.GelloFamiliarConsumeType = nil
		settings.TainteGelloEatsFams = nil
	end
	GelloCharMod.SaveHandler.Data("MarksNAchievements"):Set(mnaData)
	GelloCharMod:SetMarkNAchievementsData(mnaData)
	GelloCharMod:SaveData(GelloCharMod.json.encode(GelloCharMod.Data))
end



GelloCharMod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, -200, function (_, continued)
	GelloCharMod.RunSeed = GelloCharMod.Game:GetSeeds():GetStartSeed()
	GelloCharMod.RNG:SetSeed(GelloCharMod.RunSeed, 35)

	if GelloCharMod:HasData() then
		--GelloCharMod.Data = GelloCharMod.json.decode(GelloCharMod:LoadData())

		--local mnaData = GelloCharMod.SaveHandler.Data("MarksNAchievements"):Get({Achievements = {}, Marks = {}})
		--GelloCharMod:SetMarkNAchievementsData(mnaData)

		if continued then
        	WaveHelper:LoadData(GelloCharMod.SaveHandler.Save("WaveHelper"):Get({}))
        else clearData()
        end
    else
		setupData()
		if GelloCharMod:IsTaintedGello(Isaac.GetPlayer(0)) then
			Isaac.ExecuteCommand("restart")
		end
    end
    GelloCharMod.GameStart = true
end)
--
GelloCharMod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, -200, function() -- we have to load the achievements really really early
	if GelloCharMod.Init then return end
	setupData()
	
	GelloCharMod.Init = true
end)

GelloCharMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, continued)
	if continued then
		GelloCharMod.HiddenItemManager:LoadData(GelloCharMod.SaveHandler.Save("HiddenItemManager"):Get(nil))
	else
		GelloCharMod.HiddenItemManager:LoadData(nil)
	end
end)

function GelloCharMod:SaveGameData()
	if GelloCharMod.GameStart ~= true then return end
	GelloCharMod.SaveHandler.Data("MarksNAchievements"):Set( GelloCharMod:GetMarkNAchievementsData() )
	GelloCharMod.SaveHandler.Save("WaveHelper"):Set(WaveHelper:SaveData())
	GelloCharMod.SaveHandler.Save("HiddenItemManager"):Set(GelloCharMod.HiddenItemManager:GetSaveData())
	
	GelloCharMod:SaveData(GelloCharMod.json.encode(GelloCharMod.Data))
end

GelloCharMod:AddPriorityCallback(ModCallbacks.MC_PRE_GAME_EXIT, 200, function ()
	GelloCharMod:SaveGameData()
	GelloCharMod.GameStart = false
end)

GelloCharMod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, 200, GelloCharMod.SaveGameData)

GelloCharMod.Include("_loader")


Isaac.DebugString("Playable Gello - ReFed - v"..GelloCharMod.Version.." Loaded")
