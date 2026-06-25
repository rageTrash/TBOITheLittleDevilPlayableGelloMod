local Mod = GelloCharMod


function GelloCharMod:AddCharPauseScreenCompletionMarkAPI(charID)
	PauseScreenCompletionMarksAPI:AddModCharacterCallback(charID, function()
		return {
			["DELIRIUM"] 	= Mod:GetMark(charID, MarksNAchievHelper.MarkType.DELIRIUM),
			["HEART"] 		= Mod:GetMark(charID, MarksNAchievHelper.MarkType.MOMS_HEART),
			["ISAAC"] 		= Mod:GetMark(charID, MarksNAchievHelper.MarkType.ISAAC),
			["SATAN"] 		= Mod:GetMark(charID, MarksNAchievHelper.MarkType.SATAN),
			["BOSSRUSH"] 	= Mod:GetMark(charID, MarksNAchievHelper.MarkType.BOSS_RUSH),
			["BLUEBABY"] 	= Mod:GetMark(charID, MarksNAchievHelper.MarkType.BLUE_BABY),
			["LAMB"] 		= Mod:GetMark(charID, MarksNAchievHelper.MarkType.THE_LAMB),
			["MEGASATAN"] 	= Mod:GetMark(charID, MarksNAchievHelper.MarkType.MEGA_SATAN),
			["ULTRAGREED"] 	= Mod:GetMark(charID, MarksNAchievHelper.MarkType.ULTRA_GREED),
			["HUSH"] 		= Mod:GetMark(charID, MarksNAchievHelper.MarkType.HUSH),
			["MOTHER"] 		= Mod:GetMark(charID, MarksNAchievHelper.MarkType.MOTHER),
			["BEAST"] 		= Mod:GetMark(charID, MarksNAchievHelper.MarkType.THE_BEAST),
		}
	end)
end

