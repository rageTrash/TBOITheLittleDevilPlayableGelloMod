local VERSION = 1.24
local YOUR_MOD = GelloCharMod


MarksNAchievHelper = MarksNAchievHelper or {}
if MarksNAchievHelper and MarksNAchievHelper.Version and MarksNAchievHelper.Version >= VERSION then return end

MarksNAchievHelper.Version = VERSION

if MarksNAchievHelper.Mod and MarksNAchievHelper.__renderPaper ~= nil then
	local mod = MarksNAchievHelper.Mod
	mod:RemoveCallback(ModCallbacks.MC_POST_RENDER, MarksNAchievHelper.__renderPaper)
	mod:RemoveCallback(ModCallbacks.MC_POST_NPC_RENDER, MarksNAchievHelper.__endBossCheck)
	mod:RemoveCallback(ModCallbacks.MC_POST_UPDATE, MarksNAchievHelper.__updateMark)
	mod:RemoveCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, MarksNAchievHelper.__completeChallenge, PickupVariant.PICKUP_TROPHY)
	mod:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED, MarksNAchievHelper.__loaded)
	if REPENTOGON then
		mod:RemoveCallback(ModCallbacks.MC_POST_COMPLETION_MARK_GET, MarksNAchievHelper.__repentogonMarks)
	end
end
MarksNAchievHelper.Mod = YOUR_MOD
if not MarksNAchievHelper.Game then MarksNAchievHelper.Game = Game() end
if not MarksNAchievHelper.SFX then MarksNAchievHelper.SFX = SFXManager() end

local mod = MarksNAchievHelper.Mod
local game = MarksNAchievHelper.Game
local SFX = MarksNAchievHelper.SFX
MarksNAchievHelper.TriggerMark = false


MarksNAchievHelper.MarkType = {
	NULL = 0,
	MOMS_HEART = 1, IT_LIVE = 1,
	SATAN = 2,
	ISAAC = 3,
	THE_LAMB = 4,
	BLUE_BABY = 5,
	BOSS_RUSH = 6,
	MEGA_SATAN = 7,
	HUSH = 8,
	GREED = 9, ULTRA_GREED = 9, ULTRA_GREEDIER = 9,
	DELIRIUM = 10,
	MOTHER = 11,
	THE_BEAST = 12,

	TAINTED_MARKS_N1 = {2, 3, 4, 5}, TAINTED_MARKS_TRINKET = {2, 3, 4, 5},
	TAINTED_MARKS_N2 = {6, 8}, TAINTED_MARKS_SOUL_STONE = {6, 8},

	ALL_MARKS = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12},
}

MarksNAchievHelper.DifficultyType = {
	NONE = 0,
	NORMAL = 1,
	HARD = 2,
}



MarksNAchievHelper._marks = MarksNAchievHelper._marks or {}
MarksNAchievHelper._marksAchiev = MarksNAchievHelper._marksAchiev or {}
MarksNAchievHelper._charMarksParent = MarksNAchievHelper._charMarksParent or {}
MarksNAchievHelper._charOrigin = MarksNAchievHelper._charOrigin or {}
MarksNAchievHelper._renpentogonMod = MarksNAchievHelper._renpentogonMod or {}

MarksNAchievHelper._achievements = MarksNAchievHelper._achievements or {}
MarksNAchievHelper._achievData = MarksNAchievHelper._achievData or {}

MarksNAchievHelper._challenge = MarksNAchievHelper._challenge or {}
MarksNAchievHelper._challengeOrigin = MarksNAchievHelper._challengeOrigin or {}



function MarksNAchievHelper:SetModData(modName, saveData)
	if not saveData or type(saveData) ~= "table" then return end
	MarksNAchievHelper._achievements[modName] = saveData.Achievements or MarksNAchievHelper._achievements[modName] or {}
	MarksNAchievHelper._marks[modName] = saveData.Marks or MarksNAchievHelper._marks[modName] or {}
end

function MarksNAchievHelper:GetModData(modName)
	return {
		Achievements = MarksNAchievHelper._achievements[modName] or {},
		Marks = MarksNAchievHelper._marks[modName] or {},
	}
end


function MarksNAchievHelper:SetModAchievementData(modName, saveData)
	if not saveData or type(saveData) ~= "table" then return end
	MarksNAchievHelper._achievements[modName] = saveData or MarksNAchievHelper._achievements[modName] or {}
end

function MarksNAchievHelper:SetModCharacterMarksData(modName, charID, saveData)
	if not saveData or type(saveData) ~= "table" then return end
	local charID = tostring(MarksNAchievHelper:GetCharacterMarksParent(modName, charID) or charID)
	MarksNAchievHelper._marks[modName] = MarksNAchievHelper._marks[modName] or {}
	MarksNAchievHelper._marks[modName][charID] = saveData or MarksNAchievHelper._marks[modName][charID] or {}
end


function MarksNAchievHelper:GetModAchievementData(modName)
	return MarksNAchievHelper._achievements[modName] or {}
end

function MarksNAchievHelper:GetModCharacterMarksData(modName, charID)
	local charID = tostring(MarksNAchievHelper:GetCharacterMarksParent(modName, charID) or charID)
	MarksNAchievHelper._marks[modName] = MarksNAchievHelper._marks[modName] or {}
	return MarksNAchievHelper._marks[modName][charID] or {}
end


function MarksNAchievHelper:UseRepentogonFor(modName)
	MarksNAchievHelper._renpentogonMod[modName] = {}
end



function MarksNAchievHelper:AddAchievement(modName, achievName, achievFilePath, paperFilePath)
	MarksNAchievHelper._achievements[modName] = MarksNAchievHelper._achievements[modName] or {}
	MarksNAchievHelper._achievements[modName][achievName] = 0

	MarksNAchievHelper._achievData[modName] = MarksNAchievHelper._achievData[modName] or {}
	MarksNAchievHelper._achievData[modName][achievName] = MarksNAchievHelper._achievData[modName][achievName] or {}
	MarksNAchievHelper._achievData[modName][achievName].FilePath = achievFilePath or ("gfx/ui/achievement/".. achievName ..".png")
	MarksNAchievHelper._achievData[modName][achievName].PaperFilePath = paperFilePath or "gfx/ui/achievement/paper.png"

	if MarksNAchievHelper._renpentogonMod[modName] then
		MarksNAchievHelper._renpentogonMod[modName][achievName] = Isaac.GetAchievementIdByName(achievName)
	end
end

function MarksNAchievHelper:GetAchievementState(modName, achievName)
	MarksNAchievHelper._achievements[modName] = MarksNAchievHelper._achievements[modName] or {}
	if MarksNAchievHelper._achievements[modName][achievName] == nil then
		error("Achievement \""..tostring(achievName).."\" do not exist", 2)
		return false
	end
	if MarksNAchievHelper._renpentogonMod[modName] then
		return Isaac.GetPersistentGameData():Unlocked(MarksNAchievHelper._renpentogonMod[modName][achievName])
	end
	return (MarksNAchievHelper._achievements[modName][achievName] == 1)
end

function MarksNAchievHelper:SetAchievementState(modName, achievName, state)
	MarksNAchievHelper._achievements[modName] = MarksNAchievHelper._achievements[modName] or {}
	if MarksNAchievHelper._achievements[modName][achievName] == nil then
		error("Achievement \""..tostring(achievName).."\" do not exist", 2)
		return false
	end

	local val = 1
	if state == false then val = 0 end
	
	MarksNAchievHelper._achievements[modName][achievName] = val
	
	if MarksNAchievHelper._renpentogonMod[modName] then
		if state then
			Isaac.GetPersistentGameData():Unlock(MarksNAchievHelper._renpentogonMod[modName][achievName], true)
		else
			Isaac.ExecuteCommand("lockachievement "..MarksNAchievHelper._renpentogonMod[modName][achievName])
		end
	end
end

function MarksNAchievHelper:GetAchievementData(modName, achievName)
	MarksNAchievHelper._achievData[modName] = MarksNAchievHelper._achievData[modName] or {}
	if MarksNAchievHelper._achievData[modName][achievName] == nil then
		print("MarksNAchievHelper:GetAchievementFiles - Achievement \""..tostring(achievName).."\" do not exist")
		return { FilePath = "", PaperFilePath = "gfx/ui/achievement/paper.png"}
	end
	return MarksNAchievHelper._achievData[modName][achievName]
end




function MarksNAchievHelper:RegisterCharacterToHaveMarks(modName, charID)
	local charID = tostring(charID)

	if MarksNAchievHelper:GetCharacterMarksParent(modName, charID) then return end

	MarksNAchievHelper._marks[modName] = MarksNAchievHelper._marks[modName] or {}
	MarksNAchievHelper._marks[modName][charID] = {}
	MarksNAchievHelper._charOrigin[charID] = modName
end

function MarksNAchievHelper:CanCharacterHaveMarks(charID)
	local charID = tostring(charID)
	if MarksNAchievHelper._charOrigin[charID] == nil then return false end
	return true
end

function MarksNAchievHelper:SetCharacterMarksParent(modName, charID, parentID)
	MarksNAchievHelper._charOrigin[charID] = modName
	MarksNAchievHelper._charMarksParent[modName] = MarksNAchievHelper._charMarksParent[modName] or {}
	MarksNAchievHelper._charMarksParent[modName][tostring(charID)] = tonumber(parentID)
end

function MarksNAchievHelper:GetCharacterMarksParent(modName, charID)
	MarksNAchievHelper._charMarksParent[modName] = MarksNAchievHelper._charMarksParent[modName] or {}
	return MarksNAchievHelper._charMarksParent[modName][tostring(charID)]
end

function MarksNAchievHelper:GetCharacterMarks(modName, charID, mark)
	local charID = tostring(MarksNAchievHelper:GetCharacterMarksParent(modName, charID) or charID)
	local mark = tonumber(mark) or 0

	MarksNAchievHelper._marks[modName] = MarksNAchievHelper._marks[modName] or {}
	if not MarksNAchievHelper:CanCharacterHaveMarks(charID) then
		print("MarksNAchievHelper:GetCharacterMarks - Character \""..charID.."\" can't have marks")
		if mark then return MarksNAchievHelper.DifficultyType.NONE end
		return {}
	end
	if not mark or mark > MarksNAchievHelper.MarkType.THE_BEAST or mark < MarksNAchievHelper.MarkType.MOMS_HEART then
		print("MarksNAchievHelper:GetCharacterMarks - Mark Type is invalid")
		return MarksNAchievHelper.DifficultyType.NONE
	end
	if mark then
		MarksNAchievHelper._marks[modName][charID] = MarksNAchievHelper._marks[modName][charID] or {}
		return MarksNAchievHelper._marks[modName][charID][tostring(mark)] or MarksNAchievHelper.DifficultyType.NONE
	end

	return MarksNAchievHelper._marks[modName][charID] or {}
end

function MarksNAchievHelper:UpdateCharacterMarks(modName, charID, mark, diffType)
	local charID = tostring(MarksNAchievHelper:GetCharacterMarksParent(modName, charID) or charID)
	local mark = tonumber(mark) or 0
	local diffType = diffType or MarksNAchievHelper.DifficultyType.NORMAL

	MarksNAchievHelper._marks[modName] = MarksNAchievHelper._marks[modName] or {}
	if not MarksNAchievHelper:CanCharacterHaveMarks(charID) then
		print("MarksNAchievHelper:UpdateCharacterMarks - Character \""..charID.."\" can't have marks")
		return
	end
	if not mark or mark > MarksNAchievHelper.MarkType.THE_BEAST or mark < MarksNAchievHelper.MarkType.MOMS_HEART then
		print("MarksNAchievHelper:UpdateCharacterMarks - Mark Type is invalid")
		return
	end

	MarksNAchievHelper._marks[modName][charID] = MarksNAchievHelper._marks[modName][charID] or {}
	MarksNAchievHelper._marks[modName][charID][tostring(mark)] = diffType
	--if MarksNAchievHelper._renpentogonMod[modName] then
	--	Isaac.SetCompletionMark(charID, , diffType)
	--end
end




function MarksNAchievHelper:SetMarkAchievement(modName, charID, achievName, marks, diffType)
	local charID = tostring(MarksNAchievHelper:GetCharacterMarksParent(modName, charID) or charID)
	if diffType < 1 or diffType > 2 then
		if diffType == 0 then
			print("MarksNAchievHelper:SetMarkAchievement - Difficulty Type must be 1 or greater")
		else
			print("MarksNAchievHelper:SetMarkAchievement - Argument #5 is an invalid Difficulty Type")
		end
		return
	end
	local diffType = diffType or MarksNAchievHelper.DifficultyType.NORMAL
	local marks = marks or {}
	local marksTable = {}
	if type(marks) ~= "table" then marks = {marks} end
	for _, markType in ipairs(marks) do
		local markType = tonumber(markType)

		if not markType or markType > MarksNAchievHelper.MarkType.THE_BEAST or markType < MarksNAchievHelper.MarkType.MOMS_HEART then
			print("MarksNAchievHelper:SetMarkAchievement - Argument #5 contains an invalid Mark Type")
			return
		end
		local markType = tostring(markType)
		marksTable[markType] = diffType
	end

	MarksNAchievHelper._marksAchiev[modName] = MarksNAchievHelper._marksAchiev[modName] or {}
	MarksNAchievHelper._marksAchiev[modName][charID] = MarksNAchievHelper._marksAchiev[modName][charID] or {}
	MarksNAchievHelper._marksAchiev[modName][charID][achievName] = marksTable
end

function MarksNAchievHelper:SetChallengeAchievement(modName, challengeID, achievName)
	MarksNAchievHelper._challenge[modName] = MarksNAchievHelper._challenge[modName] or {}
	MarksNAchievHelper._challenge[modName][challengeID] = MarksNAchievHelper._challenge[modName][challengeID] or {}

	table.insert(MarksNAchievHelper._challenge[modName][challengeID], achievName)

	MarksNAchievHelper._challengeOrigin[challengeID] = modName
end

function MarksNAchievHelper:IsAchievementsEnable(includeChallenge)
	return not ( game:GetVictoryLap() ~= 0 or game:GetSeeds():IsCustomRun() or (includeChallenge and Isaac.GetChallenge() ~= 0) )
end

function MarksNAchievHelper:TryUnlockAchievement(modName, achievName, noPaperAnim)
	MarksNAchievHelper._achievements[modName] = MarksNAchievHelper._achievements[modName] or {}
	if MarksNAchievHelper._achievements[modName][achievName] == nil then return false end
	if MarksNAchievHelper:GetAchievementState(modName, achievName) then return false end

	if not noPaperAnim then
		if MarksNAchievHelper._renpentogonMod[modName] then
			MarksNAchievHelper._achievements[modName][achievName] = 1
			Isaac.GetPersistentGameData():Unlock(MarksNAchievHelper._renpentogonMod[modName][achievName])
		else
			MarksNAchievHelper:SetAchievementState(modName, achievName, true)

			local data = MarksNAchievHelper:GetAchievementData(modName, achievName)
			MarksNAchievHelper:QueuePaperUnlock(data.FilePath, data.PaperFilePath)
		end
	elseif MarksNAchievHelper._renpentogonMod[modName] then
		MarksNAchievHelper._achievements[modName][achievName] = 1
		Isaac.GetPersistentGameData():Unlock(MarksNAchievHelper._renpentogonMod[modName][achievName], true)
	end
	return true
end

function MarksNAchievHelper:GetDifficulty() return (game.Difficulty & 1)+1 end



local AchievementQueue = {}
function MarksNAchievHelper:QueuePaperUnlock(filePath, paperFilePath)

	local sprite = Sprite()
	local paperFilePath = paperFilePath or "gfx/ui/achievement/paper.png"

	sprite:Load("gfx/ui/achievement/achievements.anm2", false)
	sprite:ReplaceSpritesheet(2, paperFilePath)
	sprite:ReplaceSpritesheet(3, filePath)
	sprite:LoadGraphics()

	table.insert(AchievementQueue, sprite)
end


local paperTimeIdle = 30
local paperIdleWay = 0
local playPaperIn = true
local playPaperOut = true
function MarksNAchievHelper.__renderPaper()
	if game:IsPaused() or (ModConfigMenu and ModConfigMenu.IsVisible)then
		return
	end
	
	if #AchievementQueue <= 0 then return end


	local sprite = AchievementQueue[1]
	local screenCenter = Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight()) / 2
	local gameFrame = game:GetFrameCount()

	if playPaperIn then
		if playPaperIn then
			SFX:Play(17, 1.0)
			playPaperIn = false
		end
		sprite:Play("Appear", true)
		paperIdleWay = paperTimeIdle
	elseif sprite:IsPlaying("Idle") and paperIdleWay <= 0 then
		if playPaperOut then
			SFX:Play(18, 1.0)
			playPaperOut = false
		end
		sprite:Play("Dissapear", true)

	elseif sprite:IsFinished("Appear") and not sprite:IsPlaying("Dissapear") then
		sprite:Play("Idle", true)
	end

	sprite:Render(screenCenter, Vector(0,0), Vector(0,0))
	if gameFrame % 2 == 0 then
		if sprite:IsPlaying("Idle") then paperIdleWay = paperIdleWay -1 end
		sprite:Update()
	end

	if sprite:IsFinished("Dissapear") then
		table.remove(AchievementQueue, 1)

		playPaperIn = true
		playPaperOut = true
	end
end





function MarksNAchievHelper.__UpdateCharacterMarks(markType, diff)
	local markType = tostring(markType)
	for i = 0, game:GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)
		if player.Parent ~= nil then goto skip end

		local charID = tostring(player:GetPlayerType())
		local modName = MarksNAchievHelper._charOrigin[charID]
		if not modName or MarksNAchievHelper._renpentogonMod[modName] then goto skip end
		charID = tostring(MarksNAchievHelper:GetCharacterMarksParent(modName, charID) or charID)

		if MarksNAchievHelper:GetCharacterMarks(modName, charID, markType) < diff then
			MarksNAchievHelper:UpdateCharacterMarks(modName, charID, markType, diff)
		end

		local Achiev = MarksNAchievHelper._marksAchiev[modName] or {}
		local unlocks = Achiev[charID] or {}

		for name, marks in pairs(unlocks) do
			if not MarksNAchievHelper:GetAchievementState(modName, name) and marks[markType] then
			
				local triggerUnlock = true
				
				for mType, mVal in pairs(marks) do
					if MarksNAchievHelper:GetCharacterMarks(modName, charID, mType) < mVal then
						triggerUnlock = false
						break
					end
				end

				if triggerUnlock then MarksNAchievHelper:TryUnlockAchievement(modName, name) end
			end
		end

		::skip::
	end
end

function MarksNAchievHelper.__UpdateChallengeUnlocks()
	local challengeID = Isaac.GetChallenge()
	local modName = MarksNAchievHelper._challengeOrigin[challengeID]
	if not modName or MarksNAchievHelper._renpentogonMod[modName] then return end

	for _, achievName in pairs(MarksNAchievHelper._challenge[modName][challengeID] or {}) do
		if not MarksNAchievHelper:GetAchievementState(modName, achievName) then
			MarksNAchievHelper:TryUnlockAchievement(modName, achievName)
		end
	end
end

function MarksNAchievHelper.__UpdateUnlocks(markType, diff)
	if not MarksNAchievHelper.TriggerMark then return end
	MarksNAchievHelper.TriggerMark = false

	MarksNAchievHelper.__UpdateCharacterMarks(markType, diff)
end


local CheckForEnt = {
	[EntityType.ENTITY_BEAST] = function (ent)
		if ent.Variant == 0 and ent.HitPoints <= 0 then
			local level = game:GetLevel()
			if level:GetStage() ~= LevelStage.STAGE8 then return end
			local roomDesc = level:GetCurrentRoomDesc()
			if roomDesc.Data == nil or roomDesc.SafeGridIndex == GridRooms.ROOM_DEBUG_IDX or roomDesc.Data.Type ~= RoomType.ROOM_DUNGEON and roomDesc.Data.SubType ~= 4 then return end
			MarksNAchievHelper.TriggerMark = true
			MarksNAchievHelper.__UpdateUnlocks(MarksNAchievHelper.MarkType.THE_BEAST, MarksNAchievHelper:GetDifficulty())
		end
	end,
	--[[ [EntityType.ENTITY_MOTHER] = function (ent)
		if not game:GetRoom():IsClear() then return end

		MarksNAchievHelper.TriggerMark = true
		MarksNAchievHelper.__UpdateUnlocks(MarksNAchievHelper.MarkType.MOTHER, MarksNAchievHelper:GetDifficulty())
	end,]]
	[EntityType.ENTITY_MEGA_SATAN_2] = function (ent)
		local sp = ent:GetSprite()
		if not (not sp:IsPlaying("Appear") and sp:IsPlaying("Death") and sp:GetFrame() == 110) then return end

		if game:GetLevel():GetStage() ~= LevelStage.STAGE6 then return end

		MarksNAchievHelper.TriggerMark = true
		MarksNAchievHelper.__UpdateUnlocks(MarksNAchievHelper.MarkType.MEGA_SATAN, MarksNAchievHelper:GetDifficulty())
	end
}
function MarksNAchievHelper:__endBossCheck(ent)
	local fun = CheckForEnt[ent.Type]
	if fun == nil or not MarksNAchievHelper:IsAchievementsEnable(true) then return end
	fun(ent)
end


function MarksNAchievHelper.__updateMark()
	if not MarksNAchievHelper:IsAchievementsEnable(true) then return end
	if not (game:GetRoom():IsClear() and MarksNAchievHelper.TriggerMark) then
		MarksNAchievHelper.TriggerMark = (not game:GetRoom():IsClear())
		return
	end

	local level = game:GetLevel()
	local stageType = level:GetStageType()
	local stage = level:GetStage()
	local hasCurseOfLabyrinth = level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH > 0
	local room = game:GetRoom()


	local diff = MarksNAchievHelper:GetDifficulty()


	if room:GetType() == RoomType.ROOM_BOSS then

		if stage == LevelStage.STAGE7_GREED and game:IsGreedMode() and room:GetRoomShape() == RoomShape.ROOMSHAPE_1x2 then
			MarksNAchievHelper.__UpdateUnlocks(MarksNAchievHelper.MarkType.GREED, diff)

		elseif stage == LevelStage.STAGE4_2 or 
			(stage == LevelStage.STAGE4_1 and hasCurseOfLabyrinth and room:IsCurrentRoomLastBoss()) then
			if stageType < StageType.STAGETYPE_REPENTANCE then
				MarksNAchievHelper.__UpdateUnlocks(MarksNAchievHelper.MarkType.MOMS_HEART, diff)
			elseif room:GetRoomShape() == RoomShape.ROOMSHAPE_1x2 then
				MarksNAchievHelper.__UpdateUnlocks(MarksNAchievHelper.MarkType.MOTHER, diff)
			end

		elseif stage == LevelStage.STAGE4_3 then
			MarksNAchievHelper.__UpdateUnlocks(MarksNAchievHelper.MarkType.HUSH, diff)

		elseif stage == LevelStage.STAGE5 and stageType == StageType.STAGETYPE_WOTL then
			MarksNAchievHelper.__UpdateUnlocks(MarksNAchievHelper.MarkType.ISAAC, diff)

		elseif stage == LevelStage.STAGE5 then
			MarksNAchievHelper.__UpdateUnlocks(MarksNAchievHelper.MarkType.SATAN, diff)

		elseif stage == LevelStage.STAGE6 and stageType == StageType.STAGETYPE_WOTL then
			MarksNAchievHelper.__UpdateUnlocks(MarksNAchievHelper.MarkType.BLUE_BABY, diff)

		elseif stage == LevelStage.STAGE6 then
			MarksNAchievHelper.__UpdateUnlocks(MarksNAchievHelper.MarkType.THE_LAMB, diff)

		elseif stage == LevelStage.STAGE7 and room:GetRoomShape() == RoomShape.ROOMSHAPE_2x2 then
			MarksNAchievHelper.__UpdateUnlocks(MarksNAchievHelper.MarkType.DELIRIUM, diff)

		end

	elseif game:GetStateFlag(GameStateFlag.STATE_BOSSRUSH_DONE) and 
		(stage == LevelStage.STAGE3_2 or (stage == LevelStage.STAGE3_1 and hasCurseOfLabyrinth))
		and room:IsAmbushDone() then
		MarksNAchievHelper.__UpdateUnlocks(MarksNAchievHelper.MarkType.BOSS_RUSH, diff)
	end
end

function MarksNAchievHelper:__completeChallenge(_, coll)
	if coll:ToPlayer() and Isaac.GetChallenge() ~= 0 then
		MarksNAchievHelper.__UpdateChallengeUnlocks()
	end
end


if REPENTOGON then
	local repMarkToMnAMarks = {
		[CompletionType.MOMS_HEART] = MarksNAchievHelper.MarkType.MOMS_HEART,
		[CompletionType.SATAN] = MarksNAchievHelper.MarkType.SATAN,
		[CompletionType.ISAAC] = MarksNAchievHelper.MarkType.ISAAC,
		[CompletionType.LAMB] = MarksNAchievHelper.MarkType.THE_LAMB,
		[CompletionType.BLUE_BABY] = MarksNAchievHelper.MarkType.BLUE_BABY,
		[CompletionType.BOSS_RUSH] = MarksNAchievHelper.MarkType.BOSS_RUSH,
		[CompletionType.MEGA_SATAN] = MarksNAchievHelper.MarkType.MEGA_SATAN,
		[CompletionType.HUSH] = MarksNAchievHelper.MarkType.HUSH,
		[CompletionType.ULTRA_GREED] = MarksNAchievHelper.MarkType.GREED,
		[CompletionType.ULTRA_GREEDIER] = MarksNAchievHelper.MarkType.GREED,
		[CompletionType.DELIRIUM] = MarksNAchievHelper.MarkType.DELIRIUM,
		[CompletionType.MOTHER] = MarksNAchievHelper.MarkType.MOTHER,
		[CompletionType.BEAST] = MarksNAchievHelper.MarkType.THE_BEAST,
	}
	function MarksNAchievHelper:__repentogonMarks(mark, charID)
		local markType = repMarkToMnAMarks[mark]
		if markType == nil then return end
		markType = tostring(markType)
		local diff = MarksNAchievHelper:GetDifficulty()

		charID = tostring(charID)
		local modName = MarksNAchievHelper._charOrigin[charID]
		if not modName or not MarksNAchievHelper._renpentogonMod[modName] then return end
		charID = tostring(MarksNAchievHelper:GetCharacterMarksParent(modName, charID) or charID)

		if MarksNAchievHelper:GetCharacterMarks(modName, charID, markType) < diff then
			MarksNAchievHelper:UpdateCharacterMarks(modName, charID, markType, diff)
		end

		local Achiev = MarksNAchievHelper._marksAchiev[modName] or {}
		local unlocks = Achiev[charID] or {}

		for name, marks in pairs(unlocks) do
			if not MarksNAchievHelper:GetAchievementState(modName, name) and marks[markType] then
			
				local triggerUnlock = true
				for mType, mVal in pairs(marks) do
					if MarksNAchievHelper:GetCharacterMarks(modName, charID, mType) < mVal then
						triggerUnlock = false
						break
					end
				end

				if triggerUnlock then
					MarksNAchievHelper._achievements[modName][name] = 1
					Isaac.GetPersistentGameData():Unlock(MarksNAchievHelper._renpentogonMod[modName][name])
				end
			end
		end
	end
	mod:AddCallback(ModCallbacks.MC_POST_COMPLETION_MARK_GET, MarksNAchievHelper.__repentogonMarks)
end


function MarksNAchievHelper.__loaded()
	if VERSION < MarksNAchievHelper.Version or MarksNAchievHelper.HasLoaded then return end
	print( ("Marks & Achievement Helper Version ".. MarksNAchievHelper.Version .." has been set up") )
	
	MarksNAchievHelper.HasLoaded = true
end



mod:AddCallback(ModCallbacks.MC_POST_RENDER, MarksNAchievHelper.__renderPaper)
mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, MarksNAchievHelper.__endBossCheck)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, MarksNAchievHelper.__updateMark)
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, MarksNAchievHelper.__completeChallenge, PickupVariant.PICKUP_TROPHY)
mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, 2^16 *-1, MarksNAchievHelper.__loaded)
