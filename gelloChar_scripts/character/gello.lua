local Mod = GelloCharMod

local CharID = Mod.Enum.Character.GELLO

Mod:AddCharacterForMarks(CharID)
Mod:AddCharPauseScreenCompletionMarkAPI(CharID)
Mod:AddCharacterUnlock(CharID, "Lil Hamster", MarksNAchievHelper.MarkType.ISAAC, MarksNAchievHelper.DifficultyType.NORMAL)
Mod:AddCharacterUnlock(CharID, "Larry Jr Jr", MarksNAchievHelper.MarkType.BLUE_BABY, MarksNAchievHelper.DifficultyType.NORMAL)

Mod:AddCharacterUnlock(CharID, "Friendly Bite", MarksNAchievHelper.MarkType.SATAN, MarksNAchievHelper.DifficultyType.NORMAL)
Mod:AddCharacterUnlock(CharID, "Gallus", MarksNAchievHelper.MarkType.THE_LAMB, MarksNAchievHelper.DifficultyType.NORMAL)

Mod:AddCharacterUnlock(CharID, "Weird Candy", MarksNAchievHelper.MarkType.ULTRA_GREED, MarksNAchievHelper.DifficultyType.NORMAL)
Mod:AddCharacterUnlock(CharID, "Centepied", MarksNAchievHelper.MarkType.ULTRA_GREED, MarksNAchievHelper.DifficultyType.HARD)

Mod:AddCharacterUnlock(CharID, "Beelzebub", MarksNAchievHelper.MarkType.BOSS_RUSH, MarksNAchievHelper.DifficultyType.NORMAL)
Mod:AddCharacterUnlock(CharID, "Lil Embrion", MarksNAchievHelper.MarkType.HUSH, MarksNAchievHelper.DifficultyType.NORMAL)

Mod:AddCharacterUnlock(CharID, "Cursed Plushie", MarksNAchievHelper.MarkType.MEGA_SATAN, MarksNAchievHelper.DifficultyType.NORMAL)
Mod:AddCharacterUnlock(CharID, "Fetal Jar", MarksNAchievHelper.MarkType.DELIRIUM, MarksNAchievHelper.DifficultyType.NORMAL)

Mod:AddCharacterUnlock(CharID, "Motherly Chicken", MarksNAchievHelper.MarkType.MOTHER, MarksNAchievHelper.DifficultyType.NORMAL)
Mod:AddCharacterUnlock(CharID, "Use Placenta", MarksNAchievHelper.MarkType.THE_BEAST, MarksNAchievHelper.DifficultyType.NORMAL)

Mod:AddCharacterUnlock(CharID, "Void Stomach", MarksNAchievHelper.MarkType.ALL_MARKS, MarksNAchievHelper.DifficultyType.HARD)
Mod:AddUnlock("Tainted Gello")
GelloCharMod.CharUnlocks[CharID]["Tainted Gello"] = {}

if not Mod.RepentogonPlus then
	ForcePlayerCostumeOrSomething:AddCharacterCostume(CharID, {Isaac.GetCostumeIdByPath("gfx/characters/character_gello_hair.anm2")}, "gfx/characters/player_gello.anm2")
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
	if player:GetPlayerType() ~= CharID then return end
	
	player:GetSprite():Load("gfx/characters/player_gello.anm2", true)
	if Mod.GetSetting("FriendlyBiteAltMode") then
		player:SetPocketActiveItem(Mod.Enum.Item.FRIENDLY_BITE_ALT, ActiveSlot.SLOT_POCKET)
	end
end)



local itemCon = Isaac.GetItemConfig()
local game = Mod.Game

local function UpdateChargebar(data)
	local sp = data.Sprite
	local charge = math.floor(data.Charge / data.MaxCharge *100)+1


	if charge == 101 then
		if not sp:IsPlaying("Charged") then sp:Play("Charged", true) end
		if not game:IsPaused() then sp:Update() end
	elseif charge > 0 and charge < 101 then
		if not sp:IsPlaying("Charging") then sp:Play("Charging") end
		sp:SetFrame("Charging", charge)
	elseif charge <= 0 then
		if not sp:IsPlaying("Disappear") and not sp:IsFinished("Disappear") then
			sp:Play("Disappear", true)
		elseif not game:IsPaused() then sp:Update() end
	end
end




local CHARGE_GFX_PATH = "gfx/ui_gello/"
local CHARGE_GFX = {
	VANILLA = CHARGE_GFX_PATH .. "chargebar.png",
	IMPROVE = CHARGE_GFX_PATH .. "chargebar_improve.png"
}

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
	if player.Parent ~= nil or player:HasCurseMistEffect() or not (player:GetPlayerType() == Mod.Enum.Character.GELLO or Mod:IsTaintedGello(player)) then return end

	if Mod:GetEntityData(player, "Drop Being Press") then
		local data = Mod:GetEntityData(player, "Gellos Eating Chargebar")
		local pick = Mod:GetEntityData(player, "Target Pickup")
		local effEnt = Mod:GetEntityData(player, "Eat Entity Effect")


		if not Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
			--print("Gello has no target")
			if pick and effEnt ~= nil then
				local foodData = Mod:GetEntityData(effEnt, "Pickup Data")
				if foodData then
					if data and data.Charge == data.MaxCharge then
						if Mod:GelloTryConsumePickup(player, pick) then
							foodData.Eat = true
						end
					end
					foodData.Disappear = true
					Mod:SetEntityData(effEnt, "Pickup Data", foodData)
				end
				Mod:SetEntityData(player, "Target Pickup", nil)
			elseif effEnt ~= nil then
				local foodData = Mod:GetEntityData(effEnt, "Pickup Data")
				if foodData then
					foodData.Disappear = true
					Mod:SetEntityData(effEnt, "Pickup Data", foodData)
				end
			end

			Mod:SetEntityData(player, "Drop Being Press", nil)
			Mod:SetEntityData(player, "Gellos Eating Chargebar", nil)
			return
		end

		if pick == nil then
			if effEnt ~= nil then
				local foodData = Mod:GetEntityData(effEnt, "Pickup Data")
				if foodData then
					foodData.Disappear = true
					Mod:SetEntityData(effEnt, "Pickup Data", foodData)
				end
				Mod:SetEntityData(player, "Eat Entity Effect", nil)
			end
			return
		end
		if game:IsPaused() then return end

		if not data then
			data = {
				Sprite = Sprite(),
				Charge = -1,
				MaxCharge = 45 -- 1.5 seconds
			}

			local sp = data.Sprite
			sp:Load("gfx/ui_gello/chargebar.anm2", true)

			if Mod.GetSetting("ChargeGFX") == 1 then
				for i=0, 2 do
					sp:ReplaceSpritesheet(i, CHARGE_GFX.IMPROVE)
				end
			else
				for i=0, 2 do
					sp:ReplaceSpritesheet(i, CHARGE_GFX.VANILLA)
				end
			end
			sp:LoadGraphics()
		end

		
		if pick.SubType == 0 or pick.Position:Distance(player.Position) > 60 then
			data.Charge = -1
			
			if effEnt ~= nil then
				local foodData = Mod:GetEntityData(effEnt, "Pickup Data")
				if foodData then
					foodData.Disappear = true
					Mod:SetEntityData(effEnt, "Pickup Data", foodData)
				end
				Mod:SetEntityData(player, "Eat Entity Effect", nil)
			end
			Mod:SetEntityData(player, "Target Pickup", nil)
		else
			data.Charge = math.min(data.Charge+1, data.MaxCharge)
		end

		Mod:SetEntityData(player, "Gellos Eating Chargebar", data)

	elseif Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
		Mod:SetEntityData(player, "Drop Being Press", true)
		local items = Isaac.FindByType(5, 100)
		if #items <=0 then return end
		
		local pick
		local dis
		local pPos = player.Position
		for _, ent in ipairs(items) do
			if ent.Variant == 100 and ent.SubType ~= 0 and Mod:CanEatPickup(ent) then
				local pDist = ent.Position:Distance(pPos)
				if pDist <= 60 and ent.SubType ~= CollectibleType.COLLECTIBLE_DADS_NOTE and (dis == nil or pDist < dis) and Mod.PlayerTools.CanPlayerPayPickup(player, ent) then
					dis = pDist
					pick = ent
				end
			end
		end

		if pick then
			pick = pick:ToPickup()
			Mod:SetEntityData(player, "Target Pickup", pick)
			local ent = Mod:Spawn(1000, Mod.Enum.Effect.EAT, 0, pick.Position, nil, pick)
			Mod:SetEntityData(player, "Eat Entity Effect", ent)
		end
	end
end)




local CHARGEBAR_POS = Vector(-18.5, -54)
local function renderPlayerChargebar(player)
	if player.Parent ~= nil or not (player:GetPlayerType() == Mod.Enum.Character.GELLO or Mod:IsTaintedGello(player)) then return end

	local data = Mod:GetEntityData(player, "Gellos Eating Chargebar")
	if not data or player:IsDead() or player:IsCoopGhost() then return end

	if data.MaxCharge > 0 then
		local sp = data.Sprite
		UpdateChargebar(data)
		if sp:IsFinished("Disappear") then return end
		sp:Render(game:GetRoom():WorldToScreenPosition( (player:GetFlyingOffset() *1.5) + player.Position + CHARGEBAR_POS))
	end
end

local function renderChargeBars()
	if Mod:IsRenderingMenu() or not Options.ChargeBars then return end

	local renderMode = game:GetRoom():GetRenderMode()
	if not (renderMode == RenderMode.RENDER_NULL or renderMode == RenderMode.RENDER_NORMAL or renderMode == RenderMode.RENDER_WATER_ABOVE) then return end
	Mod.PlayerTools.ForEach(renderPlayerChargebar)
end

if REPENTOGON then
	Mod:AddPriorityCallback(ModCallbacks.MC_POST_ROOM_RENDER_ENTITIES, -300, renderChargeBars)
else
	Mod:AddPriorityCallback(ModCallbacks.MC_POST_RENDER, -300, renderChargeBars)
end



Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, eff)
	local pickup = eff.SpawnerEntity
	if pickup == nil or pickup.Type ~= 5 or pickup.Variant ~= 100 or pickup.SubType == 0 then eff:Remove(); return end
	pickup = pickup:ToPickup()
	eff.DepthOffset = 1
	local data = {
		SubType = pickup.SubType,
		Priced = pickup.Price ~=0,
		Disappear = eff.SubType == 1,
	}
	eff:FollowParent(pickup)

	local animPrefix = (data.Priced and "Shop" or "")

	local sp = eff:GetSprite()
	if eff.SubType == 1 then
		sp:Play(animPrefix.."Void", true)
		if data.SubType then
			sp:ReplaceSpritesheet(2, itemCon:GetCollectible(data.SubType).GfxFileName)
			sp:LoadGraphics()
		end
	else
		sp:Play(animPrefix.."Appear", true)
	end

	Mod:SetEntityData(eff, "Pickup Data", data)
end, Mod.Enum.Effect.EAT)

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
	local data = Mod:GetEntityData(eff, "Pickup Data")
	if not data then eff:Remove(); return end
	local animPrefix = (data.Priced and "Shop" or "")
	local sp = eff:GetSprite()

	if data.Disappear or eff.SpawnerEntity == nil then
		if sp:IsPlaying(animPrefix.."Disappear") or sp:IsPlaying(animPrefix.."Eat") or sp:IsPlaying(animPrefix.."Void") then return end
		if sp:IsFinished(animPrefix.."Disappear") or sp:IsFinished(animPrefix.."Eat") or sp:IsFinished(animPrefix.."Void") then
			eff:Remove()
			return
		end

		if data.Eat then
			sp:Play(animPrefix.. "Eat", true)
			sp:ReplaceSpritesheet(2, itemCon:GetCollectible(data.SubType).GfxFileName)
			sp:LoadGraphics()
		else
			if eff.SubType ~= 1 then sp:Play(animPrefix.. "Disappear", true) end
		end
	end

	if eff.SpawnerEntity == nil then
		Mod:SetEntityData(eff, "Pickup Data", data)
		return
	end
	local pickup = eff.SpawnerEntity:ToPickup()
	if pickup == nil then eff.SpawnerEntity = nil; return end

	data.Priced = pickup.Price ~= 0
	if pickup.SubType >0 then
		data.SubType = pickup.SubType
	else
		data.Disappear = true
	end
	animPrefix = (data.Priced and "Shop" or "")
	
	local frame = pickup:GetSprite():GetFrame()
	if sp:IsFinished(animPrefix.. "Appear") then
		sp:SetFrame(animPrefix.."Idle", frame)
		
	elseif sp:GetAnimation():match("Idle") and sp:GetFrame() ~= frame then
		sp:SetFrame(animPrefix.."Idle", frame)
	end
	Mod:SetEntityData(eff, "Pickup Data", data)

end, Mod.Enum.Effect.EAT)


if Mod.RepentogonPlus then
	local GELLO_ACHIEVEMENT_ID = Isaac.GetAchievementIdByName("Gello")
	GelloCharMod.GelloCharAchievement = GELLO_ACHIEVEMENT_ID -- only doing it this because im lazy :ppppp

	local promp = GenericPrompt()
	promp:Initialize()
	promp:SetText("Would you like", "have Gello locked")
	--Mod:AddCallback(ModCallbacks.MC_POST_SAVESLOT_LOAD, function()
	--	if not Isaac.GetPersistentGameData():Unlocked(GELLO_ACHIEVEMENT_ID) then
	--	end
	--end)
	local prompChoices = false
	Mod:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, function()
		local persData = Isaac.GetPersistentGameData()
		if persData:GetBestiaryEncounterCount(EntityType.ENTITY_MOM, 0) == 0 then
			Mod.SaveHandler.Data("Gello Promp"):Set(false)
			return
		end
		if MenuManager.GetActiveMenu() == MainMenuType.GAME and not Mod.SaveHandler.Data("Gello Promp"):Get(false) then
			if prompChoices then
				promp:Update(true)
				promp:Render()
				if not promp:IsActive() then
					if promp:GetSubmittedSelection() ~= 1 then
						persData:Unlock(GELLO_ACHIEVEMENT_ID, true)
					end
					Mod.SaveHandler.Data("Gello Promp"):Set(true)
					prompChoices = false
				end
			elseif not persData:Unlocked(GELLO_ACHIEVEMENT_ID) then
				prompChoices = true
				promp:Show()
			end
		end
	end)

	Mod:AddCallback(ModCallbacks.MC_POST_COMPLETION_EVENT, function(_, compleationMark)
		if compleationMark ~= CompletionType.LAMB or Isaac.GetPersistentGameData():Unlocked(GELLO_ACHIEVEMENT_ID) then return end
		Isaac.GetPersistentGameData():TryUnlock(GELLO_ACHIEVEMENT_ID)
	end)
	
end