local Mod = GelloCharMod
GelloCharMod.CharUnlocks = {}
GelloCharMod.RegisterUnlocks = {}

local modName = Mod.Name

local MnAMarksToRepMark
if Mod.RepentogonPlus then
    MarksNAchievHelper:UseRepentogonFor(modName)
    MnAMarksToRepMark = {
		[MarksNAchievHelper.MarkType.MOMS_HEART] = CompletionType.MOMS_HEART,
		[MarksNAchievHelper.MarkType.SATAN] = CompletionType.SATAN,
		[MarksNAchievHelper.MarkType.ISAAC] = CompletionType.ISAAC,
		[MarksNAchievHelper.MarkType.THE_LAMB] = CompletionType.LAMB,
		[MarksNAchievHelper.MarkType.BLUE_BABY] = CompletionType.BLUE_BABY,
		[MarksNAchievHelper.MarkType.BOSS_RUSH] = CompletionType.BOSS_RUSH,
		[MarksNAchievHelper.MarkType.MEGA_SATAN] = CompletionType.MEGA_SATAN,
		[MarksNAchievHelper.MarkType.HUSH] = CompletionType.HUSH,
		[MarksNAchievHelper.MarkType.GREED] = CompletionType.ULTRA_GREED,
		[MarksNAchievHelper.MarkType.GREED] = CompletionType.ULTRA_GREEDIER,
		[MarksNAchievHelper.MarkType.DELIRIUM] = CompletionType.DELIRIUM,
		[MarksNAchievHelper.MarkType.MOTHER] = CompletionType.MOTHER,
		[MarksNAchievHelper.MarkType.THE_BEAST] = CompletionType.BEAST,
	}
end

function GelloCharMod:AddCharacterUnlock(charID, achievName, marks, diffType, achievFilePath, paperFilePath)
    local diffType = diffType or 1
    if diffType < 1 then diffType = 1 elseif diffType >2 then diffType = 2 end

    GelloCharMod:AddUnlock(achievName, achievFilePath, paperFilePath)
    MarksNAchievHelper:SetMarkAchievement(modName, charID, achievName, marks, diffType)
    
    marks = marks or {}
    if type(marks) ~= "table" then marks = {[marks] = diffType} end

    GelloCharMod.CharUnlocks[charID] = GelloCharMod.CharUnlocks[charID] or {}
    GelloCharMod.CharUnlocks[charID][achievName] = marks
end
function GelloCharMod:AddUnlock(achievName, achievFilePath, paperFilePath)
    MarksNAchievHelper:AddAchievement(modName, achievName, achievFilePath or ("gfx/ui/achievement/gelloCharacter/".. achievName ..".png") , paperFilePath)

    table.insert(GelloCharMod.RegisterUnlocks, achievName)
end


function GelloCharMod:IsUnlock(achievName)
    return MarksNAchievHelper:GetAchievementState(modName, achievName)
end
function GelloCharMod:SetUnlock(achievName, state)
    MarksNAchievHelper:SetAchievementState(modName, achievName, state)
end
function GelloCharMod:TriggerUnlock(achievName)
    return MarksNAchievHelper:TryUnlockAchievement(modName, achievName)
end


function GelloCharMod:GetCharacterUnlocks(charID)
    return GelloCharMod.CharUnlocks[charID] or {}
end
function GelloCharMod:GetAchievementSprites(achievName)
    return MarksNAchievHelper:GetAchievementData(modName, achievName)
end


function GelloCharMod:GetMark(charID, mark)
    return MarksNAchievHelper:GetCharacterMarks(modName, charID, mark)
end
function GelloCharMod:SetMark(charID, mark, diffType)
    MarksNAchievHelper:UpdateCharacterMarks(modName, charID, mark, diffType)
    if MnAMarksToRepMark then
        local mark = MnAMarksToRepMark[mark]
        if mark == nil then return end
        Isaac.SetCompletionMark(charID, mark, diffType)
    end
end
function GelloCharMod:CanCharacterMark(charID)
    return MarksNAchievHelper:CanCharacterHaveMarks(charID)
end
function GelloCharMod:AddCharacterForMarks(charID)
    MarksNAchievHelper:RegisterCharacterToHaveMarks(modName, charID)
end
function GelloCharMod:SetParentMarks(charID, parentID)
    MarksNAchievHelper:SetCharacterMarksParent(modName, charID, parentID)
end
function GelloCharMod:GetParentMarks(charID)
    return MarksNAchievHelper:GetCharacterMarksParent(modName, charID)
end



function GelloCharMod:GetMarkNAchievementsData()
    return {
        Achievements = MarksNAchievHelper:GetModAchievementData(modName),
        Marks = {
            GELLO = MarksNAchievHelper:GetModCharacterMarksData(modName, Mod.Enum.Character.GELLO),
            GELLO_B = MarksNAchievHelper:GetModCharacterMarksData(modName, Mod.Enum.Character.GELLO_B13),
        }
    }
end
-- this is to not save using the character id
function GelloCharMod:SetMarkNAchievementsData(data)
    MarksNAchievHelper:SetModData(modName, {
        Achievements = data.Achievements,
        Marks = {
            [tostring(Mod.Enum.Character.GELLO)] = data.Marks.GELLO,
            [tostring(Mod.Enum.Character.GELLO_B13)] = data.Marks.GELLO_B,
        },
    })
    if Mod.RepentogonPlus and not GelloCharMod.Init then -- syncing the old data to repentogon
        local GelloMarks = {
            PlayerType = Mod.Enum.Character.GELLO,
            MomsHeart  = 0,
            Isaac      = 0,
            Satan      = 0,
            BossRush   = 0,
            BlueBaby   = 0,
            Lamb       = 0,
            MegaSatan  = 0,
            UltraGreed = 0,
            Hush       = 0,
            Delirium   = 0,
            Mother     = 0,
            Beast      = 0,
        }
        if data.Marks.GELLO then
            GelloMarks.MomsHeart  = (data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.MOMS_HEART )] or 0)
            GelloMarks.Isaac      = (data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.ISAAC )] or 0)
            GelloMarks.Satan      = (data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.SATAN )] or 0)
            GelloMarks.BossRush   = (data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.BOSS_RUSH )] or 0)
            GelloMarks.BlueBaby   = (data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.BLUE_BABY )] or 0)
            GelloMarks.Lamb       = (data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.THE_LAMB )] or 0)
            GelloMarks.MegaSatan  = (data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.MEGA_SATAN )] or 0)
            GelloMarks.UltraGreed = (data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.ULTRA_GREED )] or 0)
            GelloMarks.Hush       = (data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.HUSH )] or 0)
            GelloMarks.Delirium   = (data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.DELIRIUM )] or 0)
            GelloMarks.Mother     = (data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.MOTHER )] or 0)
            GelloMarks.Beast      = (data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.THE_BEAST )] or 0)
        end
        Isaac.SetCompletionMarks(GelloMarks)

        local TaintedGelloMarks = {
            PlayerType = Mod.Enum.Character.GELLO_B13,
            MomsHeart  = 0,
            Isaac      = 0,
            Satan      = 0,
            BossRush   = 0,
            BlueBaby   = 0,
            Lamb       = 0,
            MegaSatan  = 0,
            UltraGreed = 0,
            Hush       = 0,
            Delirium   = 0,
            Mother     = 0,
            Beast      = 0,
        }
        if data.Marks.GELLO_B then
            TaintedGelloMarks.MomsHeart  = (data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.MOMS_HEART )] or 0)
            TaintedGelloMarks.Isaac      = (data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.ISAAC )] or 0)
            TaintedGelloMarks.Satan      = (data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.SATAN )] or 0)
            TaintedGelloMarks.BossRush   = (data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.BOSS_RUSH )] or 0)
            TaintedGelloMarks.BlueBaby   = (data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.BLUE_BABY )] or 0)
            TaintedGelloMarks.Lamb       = (data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.THE_LAMB )] or 0)
            TaintedGelloMarks.MegaSatan  = (data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.MEGA_SATAN )] or 0)
            TaintedGelloMarks.UltraGreed = (data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.ULTRA_GREED )] or 0)
            TaintedGelloMarks.Hush       = (data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.HUSH )] or 0)
            TaintedGelloMarks.Delirium   = (data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.DELIRIUM )] or 0)
            TaintedGelloMarks.Mother     = (data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.MOTHER )] or 0)
            TaintedGelloMarks.Beast      = (data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.THE_BEAST )] or 0)
        end
        Isaac.SetCompletionMarks(TaintedGelloMarks)


        local persistData = Isaac.GetPersistentGameData()
        if data.Marks.GELLO and not persistData:Unlocked(GelloCharMod.GelloCharAchievement) then
            for _, val in pairs(data.Marks.GELLO) do
                if val > 0 then
                    Mod.SaveHandler.Data("Gello Promp"):Set(true)
                    persistData:Unlock(GelloCharMod.GelloCharAchievement, true)
                    break
                end
            end
        end

        for achievName, val in pairs(data.Achievements) do
            GelloCharMod:SetUnlock(achievName, val >0)
        end
    end
end



function GelloCharMod:RegenerateAchievements(achievSave)
    for _, achiev in pairs(GelloCharMod.RegisterUnlocks) do
        if achievSave[achiev] == nil then
            achievSave[achiev] = 0
        end
    end

    return achievSave
end