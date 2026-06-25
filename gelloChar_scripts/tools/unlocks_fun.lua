local Mod = GelloCharMod
GelloCharMod.CharUnlocks = {}
GelloCharMod.RegisterUnlocks = {}

local modName = Mod.Name


function GelloCharMod:AddCharacterUnlock(charID, achievName, marks, diffType, achievFilePath, paperFilePath)
	local diffType = diffType or 1
	if diffType < 1 then diffType = 1 elseif diffType >2 then diffType = 2 end

	GelloCharMod:AddUnlock(achievName, achievFilePath, paperFilePath)
	MarksNAchievHelper:SetMarkAchievement(modName, charID, achievName, marks, diffType)
	
	local marks = marks or {}
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
end



function GelloCharMod:RegenerateAchievements(achievSave)
	for _, achiev in pairs(GelloCharMod.RegisterUnlocks) do
		if achievSave[achiev] == nil then
			achievSave[achiev] = 0
		end
	end

	return achievSave
end