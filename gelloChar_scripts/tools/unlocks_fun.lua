local Mod = GelloCharMod
GelloCharMod.CharUnlocks = {}
GelloCharMod.RegisterUnlocks = {}

local modName = Mod.Name

if Mod.RepentogonPlus then
    MarksNAchievHelper:UseRepentogonFor(modName)
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
    if Mod.RepentogonPlus and not GelloCharMod.Init then -- syncing the vanilla data to repentogon
        Isaac.SetCompletionMarks({
            PlayerType = Mod.Enum.Character.GELLO,
            MomsHeart  = data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.MOMS_HEART )],
            Isaac      = data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.ISAAC )],
            Satan      = data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.SATAN )],
            BossRush   = data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.BOSS_RUSH )],
            BlueBaby   = data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.BLUE_BABY )],
            Lamb       = data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.THE_LAMB )],
            MegaSatan  = data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.MEGA_SATAN )],
            UltraGreed = data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.ULTRA_GREED )],
            Hush       = data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.HUSH )],
            Delirium   = data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.DELIRIUM )],
            Mother     = data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.MOTHER )],
            Beast      = data.Marks.GELLO[tostring( MarksNAchievHelper.MarkType.THE_BEAST )],
        })
        Isaac.SetCompletionMarks({
            PlayerType = Mod.Enum.Character.GELLO_B13,
            MomsHeart  = data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.MOMS_HEART )],
            Isaac      = data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.ISAAC )],
            Satan      = data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.SATAN )],
            BossRush   = data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.BOSS_RUSH )],
            BlueBaby   = data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.BLUE_BABY )],
            Lamb       = data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.THE_LAMB )],
            MegaSatan  = data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.MEGA_SATAN )],
            UltraGreed = data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.ULTRA_GREED )],
            Hush       = data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.HUSH )],
            Delirium   = data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.DELIRIUM )],
            Mother     = data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.MOTHER )],
            Beast      = data.Marks.GELLO_B[tostring( MarksNAchievHelper.MarkType.THE_BEAST )],
        })

        local persistData = Isaac.GetPersistentGameData()
        if not persistData:Unlocked(GelloCharMod.GelloCharAchievement) then
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