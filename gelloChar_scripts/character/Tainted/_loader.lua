--[[
hello modder :D
if you are searching for something in here, i wish you good luck! :)
              done - birthright
fighter    -   x   -   x   -
jester     -   x   -   x   -
tank       -   x   -   x   -
scout      -       -       -
singer     -   x   -   x   -
explosivo  -   x   -   x   -
gravediger -   x   -   x   -
merchant   -       -       -
healer     -   x   -   x   -
botanic    -   x   -   x   -
venom      -   x   -   x   -
geologist  -   x   -   x   -

]]

local rute = "character.Tainted."
local Mod = GelloCharMod
local SFX = Mod.SFX
local game = Mod.Game
local pTools = Mod.PlayerTools
local tTools = Mod.TableTools
local gTools = Mod.GridTools
local MenuData = Mod.SaveHandler.Save("MenuData")
local GelloSave = Mod.SaveHandler.Save("TaintedGelloSaveState")
local GelloPoints = Mod.SaveHandler.Save("GelloPoints")
local GelloObjectives = Mod.SaveHandler.Level("Gello Objetives")
local glitchClassSave = Mod.SaveHandler.Save("GelloGlitchClass")

local itemPool = game:GetItemPool()
local INNATE_GROUP = "GELLO_INNATE_ITEM"
local IsTaintedGelloPresent = false

local tGellos = {
	[Mod.Enum.Character.GELLO_B1] = true,
	[Mod.Enum.Character.GELLO_B2] = true,
	[Mod.Enum.Character.GELLO_B3] = true,
	[Mod.Enum.Character.GELLO_B4] = true,
	[Mod.Enum.Character.GELLO_B5] = true,
	[Mod.Enum.Character.GELLO_B6] = true,
	[Mod.Enum.Character.GELLO_B7] = true,
	[Mod.Enum.Character.GELLO_B8] = true,
	[Mod.Enum.Character.GELLO_B9] = true,
	[Mod.Enum.Character.GELLO_B10] = true,
	[Mod.Enum.Character.GELLO_B11] = true,
	[Mod.Enum.Character.GELLO_B12] = true,
	[Mod.Enum.Character.GELLO_B13] = true,
}

local classIDToString = {
	[Mod.Enum.Character.GELLO_B1] = "figther",
	[Mod.Enum.Character.GELLO_B2] = "jester",
	[Mod.Enum.Character.GELLO_B3] = "tank",
	[Mod.Enum.Character.GELLO_B4] = "scout",
	[Mod.Enum.Character.GELLO_B5] = "singer",
	[Mod.Enum.Character.GELLO_B6] = "explosivo",
	[Mod.Enum.Character.GELLO_B7] = "gravediger",
	[Mod.Enum.Character.GELLO_B8] = "merchant",
	[Mod.Enum.Character.GELLO_B9] = "healer",
	[Mod.Enum.Character.GELLO_B10] = "botanic",
	[Mod.Enum.Character.GELLO_B11] = "venom",
	[Mod.Enum.Character.GELLO_B12] = "geologist",
	[Mod.Enum.Character.GELLO_B13] = "none",
}

local classToID = {
	["figther"] = Mod.Enum.Character.GELLO_B1,
	["jester"] = Mod.Enum.Character.GELLO_B2,
	["tank"] = Mod.Enum.Character.GELLO_B3,
	["scout"] = Mod.Enum.Character.GELLO_B4,
	["singer"] = Mod.Enum.Character.GELLO_B5,
	["explosivo"] = Mod.Enum.Character.GELLO_B6,
	["gravediger"] = Mod.Enum.Character.GELLO_B7,
	["merchant"] = Mod.Enum.Character.GELLO_B8,
	["healer"] = Mod.Enum.Character.GELLO_B9,
	["botanic"] = Mod.Enum.Character.GELLO_B10,
	["venom"] = Mod.Enum.Character.GELLO_B11,
	["geologist"] = Mod.Enum.Character.GELLO_B12,
	["none"] = Mod.Enum.Character.GELLO_B13,
}


local classesDummy = {
	"figther",
	"jester",
	"tank",
	"scout",
	"singer",
	"explosivo",
	"gravediger",
	--"merchant",  not done
	"healer",
	"botanic",
	"venom",
	"geologist",
}

local CLASSES = {
	LOW = {
		"figther",
		"scout",
		"tank",
		"singer"
	},
	MEDIUM = {
		"explosivo",
		"jester",
		"healer",
		"botanic",
	},
	HIGH = {
		"geologist",
		"merchant",
		"gravediger",
		"venom"
	}
}



local Calls = {
	InitPlayer = {},
	UpdatePlayer = {},

	BombInit = {},
	TearUpdate = {},
	LaserUpdate = {},
	KnifeUpdate = {},

	NPCDeath = {},
	PostRoom = {},
}


local function SetupCallbacks(tab)
	local id = tab.Id
	for key, _ in pairs(Calls) do
		Calls[key][id] = tab[key]
	end
end

Calls.InitPlayer[Mod.Enum.Character.GELLO_B13] = function(player, init)
	local rng = RNG()
	local level = game:GetLevel()
	local seed = level:GetDungeonPlacementSeed() + player.InitSeed
	if seed == 0 then seed = player.InitSeed end
	rng:SetSeed(seed, player.InitSeed %30 +10 + level:GetStage() )

	if init then
		local health = {}
		local num = rng:RandomInt(100)
		local healthAmount = 0
		if num < 10 then     -- 10%
			healthAmount = 4
		elseif num < 30 then -- 20%
			healthAmount = 1
		elseif num < 60 then -- 30%
			healthAmount = 2
		else                 -- 40%
			healthAmount = 3
		end

		for _=1, healthAmount do
			if rng:RandomInt(3) == 0 then
				if rng:RandomInt(5) == 0 then
					health.Black = (health.Black or 0) +2
				else
					health.Soul = (health.Soul or 0) +2
				end
			else
				if rng:RandomInt(5) == 0 then
					health.Bone = (health.Bone or 0) +1
				else
					health.MaxHearts = (health.MaxHearts or 0) +1
				end
				health.Hearts = (health.Hearts or 0) +2
			end
		end

		pTools.ReplacePlayerHealth(player, health)
	end

	if rng:RandomInt(3) == 0 then
		local t = rng:RandomInt(3)
		if t == 0 then
			player:AddKeys(1)
		elseif t == 1 then
			player:AddBombs(1)
		else
			player:AddCoins(5)
		end
	end

	if rng:RandomInt(3) == 0 then
		if rng:RandomInt(3) == 0 then
			player:AddPill(itemPool:GetPill(seed))
		else
			if rng:RandomInt(3) == 0 then
				player:AddCard(itemPool:GetCard(seed, false, true, true))
			else
				player:AddCard(itemPool:GetCard(seed, true, false, false))
			end
		end
	end
end


for _, load in ipairs(classesDummy) do
	SetupCallbacks( Mod.Include(rute..load) )
end

local anm2path = "gfx/characters/"
local taintedCostumes = {
	[0] = {anm2path.."player_gello_b_12_5.anm2", {Isaac.GetCostumeIdByPath(anm2path.."character_gello_b_12_5_hair.anm2")} },
	{anm2path.."player_gello.anm2",      {Isaac.GetCostumeIdByPath(anm2path.."character_gello_hair.anm2")} },
	{anm2path.."player_gello_b_2.anm2",  {Isaac.GetCostumeIdByPath(anm2path.."character_gello_b_2_hair.anm2")} },
	{anm2path.."player_gello_b_3.anm2",  {Isaac.GetCostumeIdByPath(anm2path.."character_gello_b_3_hair.anm2")} },
	{anm2path.."player_gello_b_4.anm2",  {Isaac.GetCostumeIdByPath(anm2path.."character_gello_b_4_hair.anm2")} },
	{anm2path.."player_gello_b_5.anm2",  {Isaac.GetCostumeIdByPath(anm2path.."character_gello_b_5_hair.anm2")} },
	{anm2path.."player_gello_b_6.anm2",  {Isaac.GetCostumeIdByPath(anm2path.."character_gello_b_6_hair.anm2")} },
	{anm2path.."player_gello_b_7.anm2",  {Isaac.GetCostumeIdByPath(anm2path.."character_gello_b_7_hair.anm2")} },
	{anm2path.."player_gello_b_8.anm2",  {Isaac.GetCostumeIdByPath(anm2path.."character_gello_b_8_hair.anm2")} },
	{anm2path.."player_gello_b_9.anm2",  {Isaac.GetCostumeIdByPath(anm2path.."character_gello_b_9_hair.anm2")} },
	{anm2path.."player_gello_b_10.anm2", {Isaac.GetCostumeIdByPath(anm2path.."character_gello_b_10_hair.anm2")} },
	{anm2path.."player_gello_b_11.anm2", {Isaac.GetCostumeIdByPath(anm2path.."character_gello_b_11_hair.anm2")} },
	{anm2path.."player_gello_b_12.anm2", {Isaac.GetCostumeIdByPath(anm2path.."character_gello_b_12_hair.anm2")} },
}



local CharID = Mod.Enum.Character.GELLO_B13
Mod:AddCharacterForMarks(CharID)
if not Mod.RepentogonPlus then
	Mod:AddCharPauseScreenCompletionMarkAPI(CharID)
	ForcePlayerCostumeOrSomething:AddCharacterCostume(CharID,
		taintedCostumes[0][2],
		taintedCostumes[0][1])
end
	
--print(Mod.Enum.Character.GELLO_B1, Mod.Enum.Character.GELLO_B12)
for id = Mod.Enum.Character.GELLO_B12, Mod.Enum.Character.GELLO_B1 do
	Mod:SetParentMarks(id, CharID)
	if not Mod.RepentogonPlus then
		Mod:AddCharPauseScreenCompletionMarkAPI(id)
		local cost = taintedCostumes[Mod.Enum.Character.GELLO_B1 - id +1]
		ForcePlayerCostumeOrSomething:AddCharacterCostume(id, cost[2], cost[1])
	end
end


Mod:AddCharacterUnlock(CharID, "Lil Cow", MarksNAchievHelper.MarkType.DELIRIUM, MarksNAchievHelper.DifficultyType.NORMAL)

Mod:AddCharacterUnlock(CharID, "Sacrificial Dagger", MarksNAchievHelper.MarkType.ULTRA_GREED, MarksNAchievHelper.DifficultyType.HARD)
Mod:AddCharacterUnlock(CharID, "Soul of Gello", MarksNAchievHelper.MarkType.TAINTED_MARKS_SOUL_STONE, MarksNAchievHelper.DifficultyType.NORMAL)

Mod:AddCharacterUnlock(CharID, "Strange Stone", MarksNAchievHelper.MarkType.MOTHER, MarksNAchievHelper.DifficultyType.NORMAL)
Mod:AddCharacterUnlock(CharID, "Egg", MarksNAchievHelper.MarkType.TAINTED_MARKS_TRINKET, MarksNAchievHelper.DifficultyType.NORMAL)

Mod:AddCharacterUnlock(CharID, "Lil Biter", MarksNAchievHelper.MarkType.THE_BEAST, MarksNAchievHelper.DifficultyType.NORMAL)
Mod:AddCharacterUnlock(CharID, "Missing Post", MarksNAchievHelper.MarkType.MEGA_SATAN, MarksNAchievHelper.DifficultyType.NORMAL)



function GelloCharMod:IsTaintedGello(player)
	return tGellos[player:GetPlayerType()] == true
end

function GelloCharMod:GetGlitchClassCopyDMG(player)
	local pType = player:GetPlayerType()
	if pType ~= CharID then return pType end
	return glitchClassSave:Get({}).DMG or pType
end

function GelloCharMod:GetGlitchClassCopyTears(player)
	local pType = player:GetPlayerType()
	if pType ~= CharID then return pType end
	return glitchClassSave:Get({}).Tears or pType
end

function GelloCharMod:GetGlitchClassCopySpeed(player)
	local pType = player:GetPlayerType()
	if pType ~= CharID then return pType end
	return glitchClassSave:Get({}).Speed or pType
end

function GelloCharMod:GetGlitchClassCopyShotSpeed(player)
	local pType = player:GetPlayerType()
	if pType ~= CharID then return pType end
	return glitchClassSave:Get({}).ShotSpeed or pType
end

function GelloCharMod:GetGlitchClassCopySize(player)
	local pType = player:GetPlayerType()
	if pType ~= CharID then return pType end
	return glitchClassSave:Get({}).Size or pType
end

function GelloCharMod:GetGlitchClassCopyAbility(player)
	local pType = player:GetPlayerType()
	if pType ~= CharID then return pType end
	return glitchClassSave:Get({}).Ability or pType
end

local NoneClassRNG = RNG()
local function setClassNoneData()
	local seed = game:GetLevel():GetDungeonPlacementSeed()
	NoneClassRNG:SetSeed(seed, 20)

	local data = glitchClassSave:Get({})
	data.DMG =       Mod:RandomInt( Mod.Enum.Character.GELLO_B12, Mod.Enum.Character.GELLO_B1, NoneClassRNG)
	data.Tears =     Mod:RandomInt( Mod.Enum.Character.GELLO_B12, Mod.Enum.Character.GELLO_B1, NoneClassRNG)
	data.Speed =     Mod:RandomInt( Mod.Enum.Character.GELLO_B12, Mod.Enum.Character.GELLO_B1, NoneClassRNG)
	data.ShotSpeed = Mod:RandomInt( Mod.Enum.Character.GELLO_B12, Mod.Enum.Character.GELLO_B1, NoneClassRNG)
	data.Size =      Mod:RandomInt( Mod.Enum.Character.GELLO_B12, Mod.Enum.Character.GELLO_B1, NoneClassRNG)
	data.Ability =   Mod:RandomInt( Mod.Enum.Character.GELLO_B12, Mod.Enum.Character.GELLO_B1, NoneClassRNG)

	glitchClassSave:Set(data)
end



local RUTE = "gfx/ui_gello/selection/"
local MenuForcusIndex = 2

local ScreenCenter = Vector(0, 0)
local MENU = {
	Sprite = Sprite()
}
MENU.Sprite:Load(RUTE.."menu.anm2", true)

local MENU_STATES = {
	NONE = 0,
	APPEARING = 1,
	IDLE = 2,
	DISAPPEARING = 3,
}

local MENU_CARD_OFFSET = 84
local MENU_OBJECTS = {
	{
		Sprite = Sprite(),
		Class = 13,
		Offset = MENU_CARD_OFFSET
	},
	{
		Sprite = Sprite(),
		Class = 13,
		Offset = 0
	},
	{
		Sprite = Sprite(),
		Class = 13,
		Offset = MENU_CARD_OFFSET
	},
}

MENU_OBJECTS[1].Sprite:Load(RUTE.."menu.anm2", true)
MENU_OBJECTS[2].Sprite:Load(RUTE.."menu.anm2", true)
MENU_OBJECTS[3].Sprite:Load(RUTE.."menu.anm2", true)

local MenuFocusIndex = 2
local CACHE_PLAYER_GELLO_INITSEED = {}

local MENU_SAVEDATA = {
	Queue = {},
	ShowMenu = false,
	IsActive = false
}
local GELLO_SAVEDATA = {
	PrevClasses = {},
	CurrentClasses = {},
	RunClasses = {},
	Level = 0,
	InitPlayer = false
}


local RunClasses = {}


local function screenCenter() -- found it in epiphany
	local room = game:GetRoom()

	local pos = room:WorldToScreenPosition(Vector.Zero) - room:GetRenderScrollOffset() - game.ScreenShakeOffset

	local rx = pos.X + 60 * 26 / 40
	local ry = pos.Y + 140 * (26 / 40)

	return Vector(rx * 2 + 13 * 26, ry * 2 + 7 * 26) /2
end

local function checkIfWasAllreadyAdded(seed)
	local menuData = MenuData:Get(MENU_SAVEDATA)
	for idx =1, #menuData.Queue do
		if menuData.Queue[idx] == seed then return true end
	end
	return false
end


-------------------------------------------------------------------------------------------------------------
---                                SELECTION        MENU
-------------------------------------------------------------------------------------------------------------

local SelectionRNG = RNG()
local function GenerateRunClasses(max)
	SelectionRNG:SetSeed(game:GetSeeds():GetStartSeed(), 16)
	local max = Mod:Clamp(max or 6, 6, 12)
	local classes = tTools.Shuffle( tTools.Copy(classesDummy), SelectionRNG )

	local save = GelloSave:Get(GELLO_SAVEDATA)
	RunClasses = {}
	for i=1, max do
		table.insert(RunClasses, classes[i])
	end

	save.RunClasses = RunClasses
	GelloSave:Set(save)
end


local function GenerateSelection(offset)
	local offset = offset or 1
	local seed = game:GetLevel():GetDungeonPlacementSeed()
	SelectionRNG:SetSeed(seed, 15 *offset +1)

	local data = GelloSave:Get(GELLO_SAVEDATA)
	local classes = tTools.Copy(data.RunClasses)
	--local str = "- "
	--for className, levelPassed in pairs(data.PrevClasses) do
	--	str = str.. className .." " ..levelPassed.." - "
	--end
	--print("prev classes:", str)
	--str = "- "
	--for className, _ in pairs(data.CurrentClasses) do
	--	str = str.. className .." - "
	--end
	--print("current classes:", str)

	for i = #classes, 1, -1 do
		local class = classes[i]
		if (data.PrevClasses[class] and data.PrevClasses[class] > 0) or data.CurrentClasses[class] then
			table.remove(classes, i)
		end
	end

	--str = "- "
	--for _, className in pairs(classes) do
	--	str = str.. className .." - "
	--end
	--print("selectables classes:", str)

	local classes = tTools.Shuffle(classes, SelectionRNG)

	for i=1, 3 do
		MENU_OBJECTS[i].Class = classToID[(classes[i] or "none")]
	end

	if not ((data.PrevClasses.none and data.PrevClasses.none > 0) or data.CurrentClasses.none) and SelectionRNG:RandomInt(#classes+1) == 0 then
		local cardIdx = SelectionRNG:RandomInt(3)+1
		MENU_OBJECTS[ cardIdx ].Class = classToID["none"]
	end

	for i=1, 3 do
		local class = classIDToString[ MENU_OBJECTS[i].Class ]

		local sp = MENU_OBJECTS[i].Sprite
		sp:ReplaceSpritesheet(3, (RUTE.."portrait/"..class..".png"))
		sp:LoadGraphics()
	end

	GelloSave:Set(data)
end

function GelloCharMod:IsRenderingMenu() return MenuData:Get(MENU_SAVEDATA).IsActive end


local function noMoreControl(player) player.ControlsEnabled = false end
local function control(player) player.ControlsEnabled = true end
local function getPlayerIndex(seed)
	local controlIndex = -1
	pTools.ForEach(function(player)
		if seed == player.InitSeed and Mod:IsTaintedGello(player) then
			controlIndex = player.ControllerIndex
			return true
		end
	end)
	return controlIndex
end

Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, continued)
	if continued then
		local save = GelloSave:Get(GELLO_SAVEDATA)
		if save.RunClasses then
			RunClasses = save.RunClasses
		else
			local gellosNum = 0
			pTools.ForEach(function(player)
				if Mod:IsTaintedGello(player) then
					if not player.Parent then
						gellosNum = gellosNum +1
					end
				end
			end)

			GenerateRunClasses(6 + (gellosNum-1) *2)
		end
		GelloSave:Set(save)
	else
		CACHE_PLAYER_GELLO_INITSEED = {}
		local isTaintedGello = Mod:IsTaintedGello(Isaac.GetPlayer(0))
		--[[
		print(isTaintedGello,Mod:IsUnlock("Tainted Gello"))
		if isTaintedGello and not Mod:IsUnlock("Tainted Gello") then
			Isaac.ExecuteCommand("restart "..Mod.Enum.Character.GELLO)
			print("a")
			return
		end]]
		RunClasses = {}

		if isTaintedGello then
			MENU.Sprite:Play("MenuAppear", true)
			
			local level = game:GetLevel()
			if level:GetStage() == 1 and not Mod.LevelTools.IsAltPath() and not level:IsAscent() then
				local room = level:GetCurrentRoom()
				if room:IsFirstVisit() and level:GetCurrentRoomIndex() == level:GetStartingRoomIndex() then
					GenerateRunClasses(6) -- if the main player is gello we already know to load 6 classes

					local data = GelloSave:Get(GELLO_SAVEDATA)
					data.InitPlayer = true
					GelloSave:Set(data)
					
					local menuData = MenuData:Get(MENU_SAVEDATA)
					menuData.IsActive = true
					local initSeed = Isaac.GetPlayer(0).InitSeed
					--print("Game started with tainted gello. Player seed", initSeed)

					table.insert(menuData.Queue, initSeed)
					MenuData:Set(menuData)
				end
			end
		end
	end
	setClassNoneData()
	MenuFocusIndex = 2
end)
Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	if GelloCharMod.GameStart then
		local level = game:GetLevel()
		if level:IsAscent() then return end
		
		local gelloNum = 0
		pTools.ForEach(function(player)
			if Mod:IsTaintedGello(player) and player.Parent == nil then
				gelloNum = gelloNum +1
			end
		end)

		if gelloNum == 0 then return end
		setClassNoneData()

		local data = GelloSave:Get(GELLO_SAVEDATA)
		for className, levelPassed in pairs(data.PrevClasses) do
			if levelPassed == 1 then
				data.PrevClasses[className] = 2
			else
				data.PrevClasses[className] = 0
			end
		end
		for className, levelPassed in pairs(data.CurrentClasses) do
			data.PrevClasses[className] = 1
		end
		data.CurrentClasses = {}
		GelloSave:Set(data)

		local menuData = MenuData:Get(MENU_SAVEDATA)
		menuData.IsActive = true
		pTools.ForEach(function(player)
			if Mod:IsTaintedGello(player) and player.Parent == nil then
				local initSeed = player.InitSeed
				if not checkIfWasAllreadyAdded(initSeed) then
					table.insert(menuData.Queue, initSeed)
					MenuData:Set(menuData)
				end
			end
		end)

		if gelloNum > 0 then GenerateRunClasses( 6 + 2 *(gelloNum-1) ) end
	end
end)
Mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function ()
	local data = MenuData:Get(MENU_SAVEDATA)
	data.ShowMenu = false
	MenuData:Set(data)
end)



Mod:AddPriorityCallback(ModCallbacks.MC_POST_RENDER, 500, function()
	local data = MenuData:Get(MENU_SAVEDATA)
	if not data.IsActive then return end
	if ModConfigMenu and ModConfigMenu.IsVisible then ModConfigMenu.CloseConfigMenu() end
	if DeadSeaScrollsMenu and DeadSeaScrollsMenu.IsOpen and DeadSeaScrollsMenu.IsOpen() then DeadSeaScrollsMenu.CloseMenu(true, true) end

	local menuSprite = MENU.Sprite
	if not data.ShowMenu then
		if not data.Queue or data.Queue and data.Queue[1] == nil then return end
		GenerateSelection( getPlayerIndex(data.Queue[1]) +1)
		for i=1, 3 do
			MENU_OBJECTS[i].Sprite:Play( "CardNull", true)
			Mod:RunLater(4 *i, function(idx)
				MENU_OBJECTS[idx].Sprite:Play( "CardAppear", true)
			end, i)
		end
		menuSprite:Play("MenuAppear", true)
		data.ShowMenu = true
	end
	
	pTools.ForEach(noMoreControl)

	ScreenCenter = screenCenter()
	local room = game:GetRoom()

	if not data.Queue or (data.Queue and data.Queue[1] == nil) then
		if menuSprite:IsFinished("MenuDisappear") then
			data.ShowMenu = false
			data.IsActive = false
			data.Queue = {}
			MenuData:Set(data)
			pTools.ForEach(control)

			local gelloData = GelloSave:Get(GELLO_SAVEDATA)
			gelloData.InitPlayer = false
			GelloSave:Set(gelloData)
		end
	elseif not menuSprite:IsPlaying("MenuIdle") and menuSprite:IsFinished("MenuAppear") then
		menuSprite:Play("MenuIdle", true)
	elseif menuSprite:IsPlaying("MenuIdle") then
		for i=1, 3 do
			local sp = MENU_OBJECTS[i].Sprite
		end
	end

	menuSprite:Render( ScreenCenter )
	menuSprite:Update()
	
	local seed = data.Queue[1]
	local index = -1
	if seed ~= nil then
		if CACHE_PLAYER_GELLO_INITSEED[seed] then
			index = CACHE_PLAYER_GELLO_INITSEED[seed]
		else
			local gellosCount = 0
			pTools.ForEach(function(player)
				if Mod:IsTaintedGello(player) and player.Parent == nil then
					gellosCount = gellosCount +1
					if seed == player.InitSeed then
						index = gellosCount
					end
				end
			end)
		
			if index < 0 or gellosCount == 0 then
				error("Could not find player control index for tainted gello", 1)
				return
			end
			if gellosCount == 1 then index = 0 end
			CACHE_PLAYER_GELLO_INITSEED[seed] = index
		end
	end

	for i=1, 3 do
		local sp = MENU_OBJECTS[i].Sprite
		sp:ReplaceSpritesheet(3, (RUTE.."portrait/"..(classIDToString[ MENU_OBJECTS[i].Class ] or "")..".png"))
		sp:LoadGraphics()

		sp:SetOverlayRenderPriority(false)

		if not sp:IsPlaying("CardIdle") and sp:IsFinished("CardAppear") then
			sp:Play("CardIdle", true)
		elseif sp:IsPlaying("CardIdle") and MenuFocusIndex == i then
			if index >= 0 then
				sp:SetOverlayFrame("Select", index)
			end
		else
			sp:RemoveOverlay()
		end
		
		sp:Render( Vector(ScreenCenter.X + (-MENU_CARD_OFFSET + MENU_CARD_OFFSET*(i-1)), ScreenCenter.Y) )
		sp:Update()

	end
end)


Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
	if player.Variant == 1 or not Mod:IsTaintedGello(player) then return end
	if not Mod:IsUnlock("Tainted Gello") then
		player:ChangePlayerType(Mod.Enum.Character.GELLO)
		pTools.ReplacePlayerHealth(player, {MaxHearts = 2, Hearts = 4, Black = 2})
		player:GetSprite():Load("gfx/characters/player_gello.anm2", true)
		if GetPtrHash(Isaac.GetPlayer(0)) == GetPtrHash(player) then
			Isaac.ExecuteCommand("restart "..Mod.Enum.Character.GELLO)
		end
		return
	end

	local costID = Mod.Enum.Character.GELLO_B13 - player:GetPlayerType()
	player:GetSprite():Load(taintedCostumes[costID][1], true)
end)




function setUpCharacter(player, pType, init)
	Calls.InitPlayer[pType](player, init)
	local costID = Mod.Enum.Character.GELLO_B13 - pType
	player:GetSprite():Load(taintedCostumes[costID][1], true)
end

local function clampPos(pos)
	local x = pos.X % 40
	local y = pos.Y % 40
	if x >= 20 then
		pos.X = pos.X + (40- x)
	else pos.X = pos.X - x
	end
	if y >= 20 then
		pos.Y = pos.Y + (40- y)
	else pos.Y = pos.Y - y
	end

	return pos
end

local Botanicfuns = {WaveCool = 3}
function Botanicfuns.ChargeAbility(pos, dir, player)
	local nextPos
	pos = clampPos(pos)
	
	if dir == 0 then
		nextPos = Vector(pos.X +40,     pos.Y)
	elseif dir == 1 then
		nextPos = Vector(pos.X +40, pos.Y +40)
	elseif dir == 2 then
		nextPos = Vector(pos.X,     pos.Y +40)
	elseif dir == 3 then
		nextPos = Vector(pos.X -40, pos.Y +40)
	elseif dir == 4 then
		nextPos = Vector(pos.X -40,     pos.Y)
	elseif dir == 5 then
		nextPos = Vector(pos.X -40, pos.Y -40)
	elseif dir == 6 then
		nextPos = Vector(pos.X,     pos.Y -40)
	elseif dir == 7 then
		nextPos = Vector(pos.X +40, pos.Y -40)
	end
	local eff = Mod:Spawn(1000, Mod.Enum.Effect.PLANT, 0, pos, nil, player):ToEffect()
	eff:SetTimeout(30)

	if nextPos and game:GetRoom():CheckLine(pos, nextPos, 1, 900) then
		Mod:RunLater(Botanicfuns.WaveCool, Botanicfuns.ChargeAbility, nextPos, dir, player)
	end
end

function Botanicfuns.VecToInt(vec)
	if vec:Length() == 0 then return -1 end
	local angle = (vec:GetAngleDegrees() + 360) % 360 -- making it positive
	if angle >= 22.5 and angle <= 67.5 then
		return 1
	elseif angle > 67.5 and angle < 112.5 then
		return 2
	elseif angle >= 112.5 and angle <= 157.5 then
		return 3
	elseif angle > 157.5 and angle < 202.5 then
		return 4
	elseif angle >= 202.5 and angle <= 247.5 then
		return 5
	elseif angle > 247.5 and angle < 292.5 then
		return 6
	elseif angle >= 292.5 and angle <= 337.5 then
		return 7
	end
	return 0
end


--- start of gello charge bar

local CHARGE_GFX_PATH = "gfx/ui_gello/"
local CHARGE_GFX = {
	VANILLA = CHARGE_GFX_PATH .. "chargebar.png",
	IMPROVE = CHARGE_GFX_PATH .. "chargebar_improve.png"
}


local function UpdateChargebar(data)
	local sp = data.Sprite

	local chargingAnim
	local chargedAnim
	local charge

	if data.CurrentAnm2 == 2 then
		local currentCharge = data.Charge
		if currentCharge > 300 then
			chargingAnim = "Charging3"
			chargedAnim = "Charged3"
			currentCharge = currentCharge -300
		elseif currentCharge > 150 then
			chargingAnim = "Charging2"
			chargedAnim = "Charged2"
			currentCharge = currentCharge -150
		else
			chargingAnim = "Charging"
			chargedAnim = "Charged"
		end
		charge = math.floor(currentCharge /150 *100)+1
	elseif data.CurrentAnm2 == 3 then

		if data.Charge > 60 then
			charge = -1
		elseif data.Charge >= 30 and data.Charge <= 60 then
			chargingAnim = "Charging2"
			chargedAnim = "Charged2"
			charge = math.floor( (data.Charge-30) / 30 *100 )+1
		else
			chargingAnim = "Charging"
			chargedAnim = "Charged"
			charge = math.floor( data.Charge / 30 *100 )+1
		end

	else
		chargingAnim = "Charging"
		chargedAnim = "Charged"
		charge = math.floor(data.Charge / data.MaxCharge *100)+1
	end


	if charge == 101 then
		if not sp:IsPlaying(chargedAnim) then sp:Play(chargedAnim, true) end
		if not game:IsPaused() then sp:Update() end
	elseif charge > 0 and charge < 101 then
		if not sp:IsPlaying(chargingAnim) then sp:Play(chargingAnim) end
		sp:SetFrame(chargingAnim, charge)
	elseif charge <= 0 then
		if not sp:IsPlaying("Disappear") and not sp:IsFinished("Disappear") then
			sp:Play("Disappear", true)
		elseif not game:IsPaused() then sp:Update() end
	end
end


local function setChargebarAnm2(data, t)
	local rute = "gfx/ui_gello/"
	
	if t == 2 then
		rute = rute .. "chargebar_ex.anm2"
	elseif t == 3 then
		rute = rute .. "chargebar_sc.anm2"
	else
		rute = rute .. "chargebar.anm2"
	end

	local sp = data.Sprite
	sp:Load(rute, true)
	data.CurrentAnm2 = t

	if Mod.GetSetting("ChargeGFX") == 1 then
		if t ~= 1 then
			for i=0, 4 do
				sp:ReplaceSpritesheet(i, CHARGE_GFX.IMPROVE)
			end
		else
			for i=0, 2 do
				sp:ReplaceSpritesheet(i, CHARGE_GFX.IMPROVE)
			end
		end
	else
		if t ~= 1 then
			for i=0, 4 do
				sp:ReplaceSpritesheet(i, CHARGE_GFX.VANILLA)
			end
		else
			for i=0, 2 do
				sp:ReplaceSpritesheet(i, CHARGE_GFX.VANILLA)
			end
		end
	end
	sp:LoadGraphics()
end


local renderGelloCharges ={
	[Mod.Enum.Character.GELLO_B3] = true,  -- tank
	[Mod.Enum.Character.GELLO_B4] = true,  -- scout not done
	[Mod.Enum.Character.GELLO_B5] = true,  -- singer
	[Mod.Enum.Character.GELLO_B6] = true,  -- explosivo
	[Mod.Enum.Character.GELLO_B10] = true, -- botanic
	[Mod.Enum.Character.GELLO_B11] = true, -- venom
}
local SCOUT_DISTANCE = Vector(40 * 3, 0) -- 3 tiles to the right
local function gelloChargebarUpdate(player, pType)
	if game:IsPaused() then return end
	local data = Mod:GetEntityData(player, "GelloFuckassCharge")
	if not data then
		data = {
			Sprite = Sprite(),
			Charge = -1,
			CurrentAnm2 = 0,
			MaxCharge = -1
		}
	end
	local hasBirtright = player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
	local isShooting = player:GetFireDirection() >= 0

	if Mod.Enum.Character.GELLO_B3 == pType then -- tank
		if data.CurrentAnm2 ~= 1 then
			setChargebarAnm2(data, 1)
		end

		data.MaxCharge = 90 -- 3 sec
		if isShooting then
			data.Charge = math.min(data.Charge +1, data.MaxCharge)
		elseif not isShooting then
			if data.MaxCharge == data.Charge then
				local pos = player.Position
				game:MakeShockwave(pos, 0.02, 0.075, 5)
				local pSource = EntityRef(player)
				local scale = player.SpriteScale
				local dmg = 10 * ((scale.X + scale.Y) /2)
				if hasBirtright then dmg = dmg *1.33 end

				for _, e in ipairs(Isaac.FindInRadius(pos, 160, EntityPartition.ENEMY)) do
					if not e:IsDead() then
						local mult = math.min( (160 - e.Position:Distance(pos))/100 , 1.25 )
						if not (e:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) or e:IsBoss()) then
							e:AddConfusion(pSource, math.ceil(120 *mult), true)
						end
						e:TakeDamage(dmg * mult, DamageFlag.DAMAGE_IGNORE_ARMOR, pSource, 0)
					end
				end
				game:UpdateStrangeAttractor(pos, -300, 220)
			end
			data.Charge = -1
		end

	elseif Mod.Enum.Character.GELLO_B4 == pType then -- scout
		if data.CurrentAnm2 ~= 3 then
			setChargebarAnm2(data, 3)
		end
		local cooldown = Mod:GetEntityData( player, "Scout dash cooldown", -1)
		if cooldown >= game:GetFrameCount() then return
		elseif cooldown > 0 then
			local color = player.Color
			color:SetColorize(1, 1, 1, 1)
			player:SetColor(color, 2, -1, true, false)
			SFX:Play(SoundEffect.SOUND_BEEP)
			Mod:SetEntityData( player, "Scout dash cooldown", -1 )
		end

		data.MaxCharge = 60 -- 2 sec
		if isShooting then
			data.Charge = math.min(data.Charge +1, data.MaxCharge +1)
			if data.Charge >= 29 and data.Charge <= data.MaxCharge then
				Mod:SetEntityData( player, "Scout last shooting direction", { Shooting = player:GetShootingJoystick(), Movement = player:GetMovementJoystick() })
			end
		elseif not isShooting then
			if data.Charge < data.MaxCharge +1 and data.Charge >= 30 then
				local dirTab = Mod:GetEntityData(player, "Scout last shooting direction")
				if dirTab == nil then return end
				local room = game:GetRoom()
				local pos = player.Position
				local lastDir = ( dirTab.Movement:Length() <= 0.5 and dirTab.Shooting or dirTab.Movement )
				local _, newPos = room:CheckLine(pos, pos + SCOUT_DISTANCE:Rotated(lastDir:GetAngleDegrees()), (player.CanFly and 3 or 0))
				newPos = clampPos(newPos)
				local dis = newPos:Distance(pos)
				if dis > 20 then
					local trailAmount = (dis *1.1) // 40
					for i=1, trailAmount do
						if Mod.RepentogonPlus then
			            	player:CreateAfterimage(15, Mod:Lerp(pos, newPos, i / trailAmount))
						else
							local ent = Mod:Spawn(1000, Mod.Enum.Effect.DASH, 0, Mod:Lerp(pos, newPos, i / trailAmount), Vector.Zero, player)
							ent.SpawnerEntity = player
						end
					end
					player.Position = newPos
					player.Velocity = player.Velocity *1.5
					if player:GetDamageCooldown() < 30 then
						--player:ResetDamageCooldown()
						player:SetMinDamageCooldown(30)
					end

					Mod:SetEntityData( player, "Scout dash cooldown", game:GetFrameCount() + 150 )

					if hasBirtright then
						local damageEnemiesList = {}
						local dmg = player.Damage *1.33 +2.5
						local ref = EntityRef(player)
						for i=1, trailAmount*2 do
							for _, e in ipairs(Isaac.FindInRadius(Mod:Lerp(pos, newPos, i / (trailAmount*2) ), 10, EntityPartition.ENEMY)) do
								local ptr = GetPtrHash(e)
								if not damageEnemiesList[ptr] then
									if not e:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and e:IsVulnerableEnemy() then
										e:TakeDamage(dmg, 0, ref, 0)
									end
									damageEnemiesList[ptr] = true
								end
							end
						end
					end

				end
			end
			data.Charge = -1
		end

	elseif Mod.Enum.Character.GELLO_B5 == pType then -- singer
		if data.CurrentAnm2 ~= 1 then
			setChargebarAnm2(data, 1)
		end

		data.MaxCharge = 120 -- 4 sec
		if isShooting then
			data.Charge = math.min(data.Charge +1, data.MaxCharge)
		elseif not isShooting then
			if data.MaxCharge == data.Charge then
				local pSource = EntityRef(player)
				for _, e in ipairs(Isaac.FindInRadius(player.Position, 120, EntityPartition.ENEMY)) do
					if not (e:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) or e:IsBoss() or e:IsDead()) then
						local dis = e.Position:Distance(player.Position)
						--e:AddCharmed(pSource, math.ceil(300 * (120/dis+74) -180) )
						e:AddCharmed(pSource, math.ceil(320 - dis *2.4) )
					end
				end
			end
			data.Charge = -1
		end

	elseif Mod.Enum.Character.GELLO_B6 == pType then -- explosivo
		if data.CurrentAnm2 ~= 2 then
			setChargebarAnm2(data, 2)
		end

		data.MaxCharge = 300 -- 10s :: 5 sec(first explosion) + 5 sec(second explosion)
		if hasBirtright then data.MaxCharge = 450 end -- 15s :: 5 sec(first explosion) + 5 sec(second explosion) + 5 sec(mama mega explosion)

		if isShooting then
			data.Charge = math.min(data.Charge +1, data.MaxCharge)
		elseif not isShooting then
			if hasBirtright and data.Charge >= 450 then
				player:ResetDamageCooldown()
				player:TakeDamage(8, DamageFlag.DAMAGE_NO_MODIFIERS | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_INVINCIBLE, EntityRef(player), 30)
				game:GetRoom():MamaMegaExplosion(player.Position)
				
				data.Charge = -1
			elseif data.Charge >= 300 then
				player:ResetDamageCooldown()
				player:TakeDamage(2, DamageFlag.DAMAGE_NO_MODIFIERS | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_INVINCIBLE, EntityRef(player), 30)
				game:BombDamage(player.Position, 100, 80, true, player, nil, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_IGNORE_ARMOR, true)
				
				Mod:Spawn(1000, EffectVariant.BOMB_EXPLOSION, 0, player.Position, Vector.Zero, player)
				SFX:Play(SoundEffect.SOUND_BOSS1_EXPLOSIONS, 1, 0)

				data.Charge = -1
			elseif data.Charge >= 150 then
				local pSource = EntityRef(player)
				for _, e in ipairs(Isaac.FindInRadius(player.Position, 60, EntityPartition.ENEMY)) do
					if not e:IsDead() then
						e:TakeDamage(60, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_IGNORE_ARMOR, pSource, 0)
					end
				end
				game:UpdateStrangeAttractor(player.Position, -160, 75)
				Mod:Spawn(1000, EffectVariant.BOMB_EXPLOSION, 0, player.Position, Vector.Zero, player)
				SFX:Play(SoundEffect.SOUND_EXPLOSION_WEAK, 1, 0)

				data.Charge = -1
			else
				data.Charge = math.max(data.Charge-3, -1)
			end
		end

	elseif Mod.Enum.Character.GELLO_B10 == pType then -- botanic
		if data.CurrentAnm2 ~= 1 then
			setChargebarAnm2(data, 1)
		end

		data.MaxCharge = 195 -- 6.5 sec
		if isShooting then
			data.Charge = math.min(data.Charge +1, data.MaxCharge)
			Mod:SetEntityData(player, "Botanic last shooting direction", player:GetShootingJoystick())
		elseif not isShooting then
			if data.MaxCharge == data.Charge then
				Mod:RunLater(Botanicfuns.WaveCool,
					Botanicfuns.ChargeAbility,
					player.Position, Botanicfuns.VecToInt( Mod:GetEntityData(player, "Botanic last shooting direction") ), player)
				data.Charge = -1
			else
				data.Charge = math.max(data.Charge -2, -1)
			end
		end

	elseif Mod.Enum.Character.GELLO_B11 == pType then -- venom
		if data.CurrentAnm2 ~= 1 then
			setChargebarAnm2(data, 1)
		end

		data.MaxCharge = 210 -- 7 sec
		if hasBirtright then data.MaxCharge = 300 end -- 10 sec
		
		if isShooting and Mod:GetEntityData(player, "GelloVomitVenomTime") == nil then
			data.Charge = math.min(data.Charge +1, data.MaxCharge)
		elseif not isShooting then
			if data.MaxCharge == data.Charge then
				local time = 90
				if hasBirtright then time = 145 end
				Mod:SetEntityData(player, "GelloVomitVenomTime", game:GetFrameCount() + time)
				data.Charge = -1
			else
				data.Charge = math.max(data.Charge -2, -1)
			end
		end
	end

	Mod:SetEntityData(player, "GelloFuckassCharge", data)
end


local CHARGEBAR_OFFSET = {
	Vector(18.5, -54), -- main position of the charge bar
	-- vanilla offset positions of the charge bars
	Vector(11,    17),
	Vector(21.5,   0),
	Vector(33,    17),
	
	-- for fun
	Vector(42,     0),
	Vector(11,   -17),
}
local function getChargebarRenderOffset(player)
	local chargesCount = 1
	if player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) or
		player:HasWeaponType(WeaponType.WEAPON_KNIFE) or
		player:HasWeaponType(WeaponType.WEAPON_MONSTROS_LUNGS) or
		player:HasWeaponType(WeaponType.WEAPON_BONE) or
		player:HasWeaponType(WeaponType.WEAPON_SPIRIT_SWORD) or
		player:HasWeaponType(WeaponType.WEAPON_FETUS) then chargesCount = chargesCount +1
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_MAW_OF_THE_VOID) then chargesCount = chargesCount +1
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_REVELATION) then chargesCount = chargesCount +1
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_MONTEZUMAS_REVENGE) then chargesCount = chargesCount +1
	end
	local spScale = player.SpriteScale
	local copyVector = CHARGEBAR_OFFSET[1] * spScale
	if chargesCount > 1 then
		return copyVector + CHARGEBAR_OFFSET[6]
		--[[
		if chargesCount % 2 == 0 then
			copyVector.Y = copyVector.Y +17
			copyVector.X = copyVector.X + 11 * (chargesCount-1)
		else
			copyVector.X = copyVector.X + 21.5 * (chargesCount-1)
		end

		return copyVector + CHARGEBAR_OFFSET[chargesCount] ]]
	end
	return copyVector
end

local function renderPlayerChargebar(player)
	local pType = Mod:GetGlitchClassCopyAbility(player)
	if not renderGelloCharges[ pType ] then return end

	local data = Mod:GetEntityData(player, "GelloFuckassCharge")
	if not data or player:IsDead() or player:IsCoopGhost() then return end

	if data.MaxCharge > 0 then
		local sp = data.Sprite
		UpdateChargebar(data)
		if sp:IsFinished("Disappear") then return end
		sp:Render(game:GetRoom():WorldToScreenPosition( (player:GetFlyingOffset() *1.5) + player.Position + getChargebarRenderOffset(player) ))
	end
end

local function renderChargeBars()
	if Mod:IsRenderingMenu() or not Options.ChargeBars then return end

	local renderMode = game:GetRoom():GetRenderMode()
	if not (renderMode == RenderMode.RENDER_NULL or renderMode == RenderMode.RENDER_NORMAL or renderMode == RenderMode.RENDER_WATER_ABOVE) then return end
	pTools.ForEach(renderPlayerChargebar)
end

if REPENTOGON then
	Mod:AddPriorityCallback(ModCallbacks.MC_POST_ROOM_RENDER_ENTITIES, -300, renderChargeBars)
else
	Mod:AddPriorityCallback(ModCallbacks.MC_POST_RENDER, -300, renderChargeBars)
end --- end gello charge bar




local config = Isaac.GetItemConfig()
local configNancyBombs =       config:GetCollectible(CollectibleType.COLLECTIBLE_NANCY_BOMBS)
local configWafer =            config:GetCollectible(CollectibleType.COLLECTIBLE_WAFER)
local configMoneyEqualsPower = config:GetCollectible(CollectibleType.COLLECTIBLE_MONEY_EQUALS_POWER)
local configTerra =            config:GetCollectible(CollectibleType.COLLECTIBLE_TERRA)

local INPUT_COOLDOWN = 4
local PlantPosRNG = RNG()
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
	
	if not Mod:IsTaintedGello(player) then
		if #Mod.HiddenItemManager:GetStacks(player, INNATE_GROUP) > 0 then Mod.HiddenItemManager:RemoveAll(player, INNATE_GROUP) end
		return
	elseif player.FrameCount == 1 and player.Parent == nil and not checkIfWasAllreadyAdded(player.InitSeed) then
		local level = game:GetLevel()
		if level:GetStage() == 1 and not Mod.LevelTools.IsAltPath() and not level:IsAscent() and Mod:IsTaintedGello(player) then
			local room = level:GetCurrentRoom()
			if room:IsFirstVisit() and level:GetCurrentRoomIndex() == level:GetStartingRoomIndex() then
				CACHE_PLAYER_GELLO_INITSEED = {}

				local gellosNum = 0
				pTools.ForEach(function(player)
					if Mod:IsTaintedGello(player) then
						if not player.Parent then
							gellosNum = gellosNum +1
						end
					end
				end)

				GenerateRunClasses(6 + (gellosNum-1) * 2)
				--print("total gello classes amount", 6 + (gellosNum-1) * 2)

				local data = GelloSave:Get(GELLO_SAVEDATA)
				data.InitPlayer = true
				GelloSave:Set(data)

				local menuData = MenuData:Get(MENU_SAVEDATA)
				menuData.IsActive = true

				local initSeed = player.InitSeed
				--print("New tainted gello player detected. Player seed", initSeed)

				table.insert(menuData.Queue, initSeed)
				MenuData:Set(menuData)
			end
		end
	end

	if Mod:IsRenderingMenu() then
		local seed = player.InitSeed
		local menuData = MenuData:Get(MENU_SAVEDATA)
		if not menuData.Queue or menuData.Queue[1] == nil or menuData.Queue[1] ~= seed or Mod:GetEntityData(player, "Gello menu ignore input") then return end
		local index = player.ControllerIndex

		local frameCount = game:GetFrameCount()
		local inputCooldown = Mod:GetEntityData(player, "Gello menu input cooldown", -1)
		if inputCooldown >= frameCount then return end
		if not MENU_OBJECTS[MenuFocusIndex].Sprite:IsPlaying("CardIdle") then return end
		
		if Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, index) then
			MenuFocusIndex = MenuFocusIndex -1
			if MenuFocusIndex < 1 then
				MenuFocusIndex = 3
			end
			Mod:SetEntityData(player, "Gello menu input cooldown", frameCount + INPUT_COOLDOWN)
		elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, index) then
			MenuFocusIndex = MenuFocusIndex +1
			if MenuFocusIndex > 3 then
				MenuFocusIndex = 1
			end
			Mod:SetEntityData(player, "Gello menu input cooldown", frameCount + INPUT_COOLDOWN)
		elseif Input.IsActionPressed(ButtonAction.ACTION_ITEM, index) then
			Mod:SetEntityData(player, "Gello menu ignore input", true)
			Mod:RunLater(30, function(p) Mod:SetEntityData(p, "Gello menu ignore input", false) end, player)

			local newType = MENU_OBJECTS[MenuFocusIndex].Class
			player:ChangePlayerType(newType)
			
			MENU_OBJECTS[MenuFocusIndex].Sprite:Play("CardDisappear", true)
			
			for i=1, 2 do
				MenuFocusIndex = MenuFocusIndex +1; if MenuFocusIndex > 3 then MenuFocusIndex = 1 end
				Mod:RunLater(3 *i, function(idx) MENU_OBJECTS[idx].Sprite:Play("CardDisappear", true) end, MenuFocusIndex)
			end

			table.remove(menuData.Queue, 1)
			--menuData.Queue = sanityIndex(menuData.Queue)
			
			if menuData.Queue[1] == nil then
				Mod:RunLater(12, function() MENU.Sprite:Play("MenuDisappear", true) end)
			else
				GenerateSelection( getPlayerIndex(menuData.Queue[1]) +1)
				for i=1, 3 do
					MenuFocusIndex = MenuFocusIndex +1; if MenuFocusIndex > 3 then MenuFocusIndex = 1 end
					
					Mod:RunLater(9 + 3 *i, function(idx) MENU_OBJECTS[idx].Sprite:Play("CardAppear", true) end, MenuFocusIndex)
				end
			end
			MenuData:Set(menuData)

			local data = GelloSave:Get(GELLO_SAVEDATA)
			data.CurrentClasses[classIDToString[newType]] = 1
			Calls.InitPlayer[newType](player, data.InitPlayer)
			if Mod.GetSetting("FriendlyBiteAltMode") and newType == Mod.Enum.Character.GELLO_B13 and Mod:GetGlitchClassCopyAbility(player) == Mod.Enum.Character.GELLO_B1 then
				player:SetPocketActiveItem(Mod.Enum.Item.FRIENDLY_BITE_ALT, ActiveSlot.SLOT_POCKET)
			end
			--[[Mod:RunLater(1,
				setUpCharacter,
				player, newType, data.InitPlayer)
]]
			GelloSave:Set(data)
			MenuFocusIndex = 2
		end
		return
	end -------------------------- End of Selection menu



	local pType = Mod:GetGlitchClassCopyAbility(player)
	if not player:HasCurseMistEffect() then
		-- jester innate item
		if pType == Mod.Enum.Character.GELLO_B2 then
			if not Mod.HiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_NANCY_BOMBS, INNATE_GROUP) then
				Mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_NANCY_BOMBS, 1, INNATE_GROUP)
			end
			if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_NANCY_BOMBS) <= 1 then player:RemoveCostume(configNancyBombs) end
		elseif pType ~= Mod.Enum.Character.GELLO_B2 and Mod.HiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_NANCY_BOMBS, INNATE_GROUP) then
			Mod.HiddenItemManager:RemoveStack(player, CollectibleType.COLLECTIBLE_NANCY_BOMBS, INNATE_GROUP)
		end

		-- tank innate item
		if pType == Mod.Enum.Character.GELLO_B3 then
			if not Mod.HiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_WAFER, INNATE_GROUP) then
				Mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_WAFER, 1, INNATE_GROUP)
			end
			if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_WAFER) <= 1 then player:RemoveCostume(configWafer) end
		elseif pType ~= Mod.Enum.Character.GELLO_B3 and Mod.HiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_WAFER, INNATE_GROUP) then
			Mod.HiddenItemManager:RemoveStack(player, CollectibleType.COLLECTIBLE_WAFER, INNATE_GROUP)
		end

		-- merchant innate item
		if pType == Mod.Enum.Character.GELLO_B8 then
			if not Mod.HiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_MONEY_EQUALS_POWER, INNATE_GROUP) then
				Mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_MONEY_EQUALS_POWER, 1, INNATE_GROUP)
			end
			if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MONEY_EQUALS_POWER) <= 1 then player:RemoveCostume(configMoneyEqualsPower) end
		elseif pType ~= Mod.Enum.Character.GELLO_B8 and Mod.HiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_MONEY_EQUALS_POWER, INNATE_GROUP) then
			Mod.HiddenItemManager:RemoveStack(player, CollectibleType.COLLECTIBLE_MONEY_EQUALS_POWER, INNATE_GROUP)
		end

		-- geologist birthright innate item
		if pType == Mod.Enum.Character.GELLO_B12 and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
			if not Mod.HiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_TERRA, INNATE_GROUP) then
				Mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_TERRA, 1, INNATE_GROUP)
			end
			if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_TERRA) <= 1 then player:RemoveCostume(configTerra) end
		elseif pType ~= Mod.Enum.Character.GELLO_B12 and Mod.HiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_TERRA, INNATE_GROUP) then
			Mod.HiddenItemManager:RemoveStack(player, CollectibleType.COLLECTIBLE_TERRA, INNATE_GROUP)
		end
	end

	if player:IsDead() or player:IsCoopGhost() then return end
	gelloChargebarUpdate(player, pType)

	
	local updateFun = Calls.UpdatePlayer[pType]
	if updateFun then updateFun(player) end

	if pType == Mod.Enum.Character.GELLO_B10 then
		local room = game:GetRoom()
		if room:IsClear() then return end
		if room:GetFrameCount() % 90 == 30 then -- every 3 sec spawns a plant but the first one spawns in 1 sec
			
			for i=1, 10 do
				local gridIdx = room:GetRandomTileIndex(PlantPosRNG:Next())
				if room:GetGridEntity(gridIdx) == nil then
					Mod:Spawn(1000, Mod.Enum.Effect.PLANT, 0, room:GetGridPosition(gridIdx), Vector.Zero, player):ToEffect():SetTimeout(30)
					break
				end
			end
		end
	end

end, 0)



local font = Font()
font:Load("font/pftempestasevencondensed.fnt")
local pointsHUDIcon = Sprite()
pointsHUDIcon:Load("gfx/ui_gello/pointsIcon_ui.anm2", true)
function renderPointsIcon()
	if not pointsHUDIcon:IsLoaded() or not IsTaintedGelloPresent then return end
	local points = GelloPoints:Get(0)
	if game:GetRoom():HasCurseMist() then points = 0 end

	local hudOffset = Options.HUDOffset * 10
	local xPos = 11 + 5 *2
	local yPos = 32
	local alpha = game:GetRoom():HasCurseMist() and 0.5 or 1

	local mainPlayer = Isaac.GetPlayer(0):GetPlayerType()
	local pType = mainPlayer

	if pType == PlayerType.PLAYER_ISAAC_B then
		yPos = yPos + 24
	elseif REPENTOGON then
		local maxCoins = mainPlayer:GetMaxCoins()
		local count = 0
		while maxCoins >1 do
			maxCoins = maxCoins /10
			count = count+1
		end
		xPos = 11 + 5 *count
	elseif pTools.AnyPlayerHasCollectible(CollectibleType.COLLECTIBLE_DEEP_POCKETS) then
		xPos = xPos +5
	end
	xPos = xPos + hudOffset *2 +6
	yPos = yPos + hudOffset *1.2
	if pType == PlayerType.PLAYER_JACOB then yPos = yPos +14 end

	local color = pointsHUDIcon.Color
	color.A = alpha
	pointsHUDIcon.Color = color
	pointsHUDIcon:Render( Vector(xPos, yPos) )

	font:DrawString(string.format("%02d", points), xPos, yPos, KColor(1, 1, 1, alpha))
end
if REPENTOGON then
	Mod:AddPriorityCallback(ModCallbacks.MC_POST_HUD_RENDER, -10000, function()
		renderPointsIcon()
	end)
else
	Mod:AddPriorityCallback(ModCallbacks.MC_GET_SHADER_PARAMS, -10000, function(_, shaderName)
		if shaderName ~= "RenderGelloHUD" then return end
		renderPointsIcon()
	end)
end


-------------------------------------------------------------------------------------------
---                  WHATEVER
-------------------------------------------------------------------------------------------




local function TearBombKnifeLaser_effect(_, ent)
	local eType = ent.Type

	if eType == 2 then
		local parent = ent.Parent
		if not parent then return end
		local fam = parent:ToFamiliar()
		local player = parent:ToPlayer()

		if fam then
			if not Mod:IsFamiliarCopyPlayerTears(fam) then return end
			player = fam.Player
		end
		if not player then return end

		local pType = Mod:GetGlitchClassCopyAbility(player)
		if ent:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
			local shot = false
			if parent.Type == 1 then
				shot = math.floor(ent.FrameCount / player.MaxFireDelay) ~= math.floor((ent.FrameCount - 1) / player.MaxFireDelay)
			elseif parent.Type == 3 then
				local fam = parent:ToFamiliar()

				local hasShoot = Mod:GetEntityData(fam, "Familiar has shoot", false)
				if not hasShoot and fam.FireCooldown > 0 then
					shot = true
					Mod:GetEntityData(fam, "Familiar has shoot", true)
				elseif hasShoot and fam.FireCooldown == 1 then
					Mod:GetEntityData(fam, "Familiar has shoot", false)
				end
			end
			if shot and Calls.TearUpdate[pType] then
				Calls.TearUpdate[pType](ent, ent:GetDropRNG(), parent)
			end
			return
		end
		
		if Calls.TearUpdate[pType] then
			Calls.TearUpdate[pType](ent, ent:GetDropRNG(), parent)
		end

	elseif eType == 4 then
		if not ent.IsFetus then return end

		local parent = ent.Parent
		if not parent then return end
		local fam = parent:ToFamiliar()
		local player = parent:ToPlayer()
		if fam then
			if not Mod:IsFamiliarCopyPlayerTears(fam) then return end
			player = fam.Player
		end
		if not player then return end
		local pType = Mod:GetGlitchClassCopyAbility(player)
		
		if Calls.BombInit[pType] then
			Calls.BombInit[pType](ent, ent:GetDropRNG(), parent)
		end

	elseif eType == 7 then
		local eVar = ent.Variant
		if eVar == LaserVariant.PRIDE or eVar == LaserVariant.TRACTOR_BEAM or eVar == LaserVariant.LIGHT_RING or eVar == LaserVariant.BEAST then return end
		local parent = ent.Parent
		local fam = parent and parent:ToFamiliar()
		local player = parent and parent:ToPlayer()

		if not parent and (
			eVar == LaserVariant.SHOOP or ent.SubType == LaserSubType.LASER_SUBTYPE_RING_PROJECTILE or ent.SubType == LaserSubType.LASER_SUBTYPE_RING_LUDOVICO) then
				local spawner = ent.SpawnerEntity
				fam = spawner and spawner:ToFamiliar()
				player = spawner and spawner:ToPlayer()
		end

		if fam then
			if not Mod:IsFamiliarCopyPlayerTears(fam) then return end
			player = fam.Player
		end

		if not player then return end
		local pType = Mod:GetGlitchClassCopyAbility(player)
		
		if ent.SubType == LaserSubType.LASER_SUBTYPE_RING_LUDOVICO then
			local spawner = ent.SpawnerEntity
			local shot = false

			if spawner.Type == 1 then
				shot = math.floor(ent.FrameCount / player.MaxFireDelay) ~= math.floor((ent.FrameCount - 1) / player.MaxFireDelay)
			elseif spawner.Type == 3 then
				local fam = spawner:ToFamiliar()

				local hasShoot = Mod:GetEntityData(fam, "Familiar has shoot", false)
				if not hasShoot and fam.FireCooldown > 0 then
					shot = true
					Mod:GetEntityData(fam, "Familiar has shoot", true)
				elseif hasShoot and fam.FireCooldown == 1 then
					Mod:GetEntityData(fam, "Familiar has shoot", false)
				end
			end
			if shot and Calls.LaserUpdate[pType] then
				Calls.LaserUpdate[pType](ent, ent:GetDropRNG(), parent)
			end
			return
		end

		if Calls.LaserUpdate[pType] then
			Calls.LaserUpdate[pType](ent, ent:GetDropRNG(), parent)
		end

	elseif eType == 8 then
		if ent.Variant == Mod.KnifeVariant.BAG_OF_CRAFTING or ent.Variant == Mod.KnifeVariant.NOTCHED_AXE then return end

		local parent = ent.Parent
		if not parent then return end
		local fam = parent:ToFamiliar()
		local player = parent:ToPlayer()

		if fam then
			if not Mod:IsFamiliarCopyPlayerTears(fam) then return end
			player = fam.Player
		end

		if not player then return end
		local pType = Mod:GetGlitchClassCopyAbility(player)
		
		if Calls.KnifeUpdate[pType] then
			Calls.KnifeUpdate[pType](ent, ent:GetDropRNG(), parent)
		end
	end

end
Mod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, TearBombKnifeLaser_effect)
Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, TearBombKnifeLaser_effect)
Mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, TearBombKnifeLaser_effect)
Mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, TearBombKnifeLaser_effect)


Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
	if npc:GetEntityFlags() & (EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_NO_QUERY) > 0 or npc:IsBoss() or not npc.CanShutDoors then return end
	local rng = npc:GetDropRNG()

	local calls = tTools.CopyLite(Calls.NPCDeath)

	pTools.ForEach(function(player)
		local pType = Mod:GetGlitchClassCopyAbility(player)
		if calls[pType] then
			calls[pType](npc, rng, firstPlayer)
			calls[pType] = nil
		end
	end)
end)


local FirstDirWithShovel = Mod.SaveHandler.Level
local roomGridSave = Mod.SaveHandler.Room
local function removeTrapdoor(gridIdx)
	local room = game:GetRoom()
	room:RemoveGridEntity(gridIdx, 0, false)
end
Mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function(_, itemID, _, player, flags, slot)
	if itemID == CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER then
		if slot < 3 then return end
		local pType = Mod:GetGlitchClassCopyAbility(player)

		local room = game:GetRoom()
		local gridIdx = room:GetGridIndex(player.Position)
		local grid = room:GetGridEntity(gridIdx)
		--print("pre use",gridIdx, grid ~= nil, grid ~= nil and grid:GetType() or 0)

		if gridIdx < 0 or not grid or grid:GetType() ~= GridEntityType.GRID_DECORATION then return end
		local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER)

		if pType == Mod.Enum.Character.GELLO_B7 then -- Gravediger

			if rng:RandomInt(2) ~= 0 then return end
			local t = EntityType.ENTITY_BONY
			if rng:RandomInt(EXPLOSIVE_SKELY_CHANCE) == 0 then
				t = EntityType.ENTITY_BLACK_BONY
			elseif rng:RandomInt(REVENANT_SKELY_CHANCE) == 0 then
				t = EntityType.ENTITY_REVENANT
			end

			local skely = Mod:Spawn(t, 0, 0, grid.Position, Vector.Zero, player)
			skely:AddCharmed(EntityRef(player), -1)
			skely:AddEntityFlags(EntityFlag.FLAG_PERSISTENT | EntityFlag.FLAG_NO_SPIKE_DAMAGE)
			skely:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

		elseif pType == Mod.Enum.Character.GELLO_B12 then -- Geologist
			local chance = rng:RandomInt(100)

			if chance >= 70 then -- 30%
				if rng:RandomInt(3) == 0 then
					Mod:Spawn(5, 60, 0, grid.Position, Mod:RandomVector(-5, 5, rng), nil)
				else
					Mod:Spawn(5, 50, 0, grid.Position, Mod:RandomVector(-5, 5, rng), nil)
				end
			elseif chance >= 60 then -- 10%
				for i=0, rng:RandomInt(2) do
					Mod:Spawn(5, 300, 0, grid.Position, Mod:RandomVector(-4, 4, rng), nil)
				end
			else -- 60%
				for i=1, Mod:RandomInt(1, 3, rng) do
					Mod:Spawn(5, 0, 4, grid.Position, Mod:RandomVector(-4, 4, rng), nil) -- spawns a random pickup that it is not a chest or item
				end
			end
		end
	end
end)
Mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, itemID, _, player, flags, slot)
	if itemID == CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER then
		if slot < 3 then return end
		local pType = Mod:GetGlitchClassCopyAbility(player)
		local room = game:GetRoom()
		local gridIdx = room:GetGridIndex(player.Position)
		--print("use",gridIdx, grid ~= nil, grid ~= nil and grid:GetType() or 0)

		if pType == Mod.Enum.Character.GELLO_B7 or pType == Mod.Enum.Character.GELLO_B12 then -- Geologist and Gravedigger
			removeTrapdoor(gridIdx)
		end

	elseif itemID == CollectibleType.COLLECTIBLE_D12 then
		roomGridSave("SpecialGridSave"):Set(nil) -- clearing grids
	end
end)


local roomRNG = RNG()
local RockPositionsToCheck = {
	Vector(40,0),
	Vector(0,40),
	Vector(-40,0),
	Vector(0,-40),
}
local UpdateBigRock
UpdateBigRock = function(gridEnt, checkList) --- base from epiphany
	local room = game:GetRoom()
	for i = 1, 4 do
		local position = gridEnt.Position + RockPositionsToCheck[i]
		local neighborGrid = room:GetGridEntityFromPos(position)
		if neighborGrid and not checkList[neighborGrid:GetGridIndex()] then
			local rock = neighborGrid:ToRock()
			if rock and rock.State ~= 2 and rock:GetBigRockFrame() ~= -1 then
				rock:SetBigRockFrame(-1)
				rock:UpdateAnimFrame()
				checkList[rock:GetGridIndex()] = true

				UpdateBigRock(rock, checkList)
			end
		end
	end
end
local SPAWN_RANGE_PER_ROOM = {
	[RoomShape.ROOMSHAPE_1x1] =  {Min =1, Max = 2},
	[RoomShape.ROOMSHAPE_IH] =   {Min =0, Max = 1},
	[RoomShape.ROOMSHAPE_IV] =   {Min =0, Max = 1},
	[RoomShape.ROOMSHAPE_1x2] =  {Min =2, Max = 3},
	[RoomShape.ROOMSHAPE_IIV] =  {Min =1, Max = 3},
	[RoomShape.ROOMSHAPE_2x1] =  {Min =2, Max = 3},
	[RoomShape.ROOMSHAPE_IIH] =  {Min =1, Max = 3},
	[RoomShape.ROOMSHAPE_2x2] =  {Min =3, Max = 6},
	[RoomShape.ROOMSHAPE_LTL] =  {Min =2, Max = 4},
	[RoomShape.ROOMSHAPE_LTR] =  {Min =2, Max = 4},
	[RoomShape.ROOMSHAPE_LBL] =  {Min =2, Max = 4},
	[RoomShape.ROOMSHAPE_LBR] =  {Min =2, Max = 4},
}

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	local level = game:GetLevel()
	if level:GetCurrentRoomIndex() == level:GetStartingRoomIndex() then return end
	local roomDesc = level:GetCurrentRoomDesc()
	PlantPosRNG:SetSeed(roomDesc.DecorationSeed, roomDesc.VisitedCount % 80 +1)
	local room = level:GetCurrentRoom()

	local geologistPresent = false
	pTools.ForEach(function(player)
		local pType = Mod:GetGlitchClassCopyAbility(player)
		if Calls.PostRoom[pType] then Calls.PostRoom[pType](player) end
		if not geologistPresent then geologistPresent = (pType == Mod.Enum.Character.GELLO_B12) end
	end)

	if room:IsFirstVisit() and geologistPresent then
		local gridList = gTools.FindGridByType(GridEntityType.GRID_ROCK)
		if #gridList > 5 then
			roomRNG:SetSeed(room:GetDecorationSeed(), 35)
			gridList = tTools.Shuffle(gridList, roomRNG)

			local range = SPAWN_RANGE_PER_ROOM[room:GetRoomShape()]
			local maxTaintedRocks = Mod:RandomInt(range.Min,range.Max, roomRNG)
			
			local checkGrids = {}
			local taintedMake = 0
			for i=1, #gridList do
				if taintedMake >= maxTaintedRocks then break end
				
				local gridEnt = gridList[i]
				if gridEnt.State == Mod.GridEntityState.ROCK_IDLE then
					checkGrids[i] = gridEnt:GetGridIndex()
					taintedMake = taintedMake +1
					UpdateBigRock(gridEnt, {})
				end
			end
			roomGridSave("SpecialGridSave"):Set(checkGrids)
		end
	end
end)




local gridRNG = RNG()
local function gridGeologistDrop(gridEnt)
	local seed =  gridEnt:GetSaveState().SpawnSeed
	gridRNG:SetSeed(seed, 35)
	local pos = gridEnt.Position

	local drop = gridRNG:RandomInt(100)
	if drop < 35 then -- 35%
		if Isaac.GetPlayer(0):GetNumKeys() > 0 and gridRNG:RandomInt(3) == 0 then
			Mod:Spawn(5, 60, 0, pos, Mod:RandomVector(-4.5, 4.5, gridRNG), nil)
		else
			Mod:Spawn(5, 50, 0, pos, Mod:RandomVector(-4.5, 4.5, gridRNG), nil)
		end
	elseif drop < 55 then -- 20%
		for i=0, gridRNG:RandomInt(2) do
			Mod:Spawn(5, 300, itemPool:GetCard(gridRNG:Next(), false, true, true), pos, Mod:RandomVector(-3, 3, gridRNG), nil)
		end
	else -- 45%
		for i=1, Mod:RandomInt(2, 3, gridRNG) do
			Mod:Spawn(5, 0, 4, pos, Mod:RandomVector(-3, 3, gridRNG), nil)
		end
	end
end
local function doGridDrops(tab)
	for i=1, #tab do
		gridGeologistDrop(tab[i])
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	local checkGrids = roomGridSave("SpecialGridSave"):Get()
	if checkGrids then
		local room = game:GetRoom()
		local dropGridTab = {}
		for i = #checkGrids, 1, -1 do
			local gridEnt = room:GetGridEntity(checkGrids[i])
			if gridEnt and gridEnt:GetType() == GridEntityType.GRID_ROCK then
				if gridEnt.State == Mod.GridEntityState.ROCK_BROKEN then
					dropGridTab[#dropGridTab+1] = gridEnt
					table.remove(checkGrids, i)
				end
			else
				table.remove(checkGrids, i)
			end
		end

		if #dropGridTab then Mod:RunLater(1, doGridDrops, dropGridTab) end
		if #checkGrids > 0 then
			roomGridSave("SpecialGridSave"):Set(checkGrids)
		else
			roomGridSave("SpecialGridSave"):Set(nil)
		end
	end
end)



local recurtion = false
local POISON_DURATION = 200
Mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -200, function(_, ent, dmgAmount, flags, src, coolFrames)
	if recurtion then return end

	local player = ent:ToPlayer()
	if player then
		if Mod:GetGlitchClassCopyAbility(player) == Mod.Enum.Character.GELLO_B6 and flags & DamageFlag.DAMAGE_FIRE > 0 then --- explosivo class. fire immunity
			return false
		elseif Mod:GetGlitchClassCopyAbility(player) == Mod.Enum.Character.GELLO_B11 then -- vemon
			local npc = src.Entity and src.Entity:ToNPC()
			if npc ~= nil and npc.CanShutDoors and npc:IsActiveEnemy() then
				local duration = ( npc:IsBoss() and (POISON_DURATION / 2) or POISON_DURATION )
				npc:AddPoison(EntityRef(player), duration, 2.75)
			end
		end
	--[[elseif ent:ToNPC() and Mod:GetEntityData(ent, "Grabed By Plant") and (not src.Entity or not (src.Type == 1000 and src.Variant == Mod.Enum.Effect.PLANT)) then
		if REPENTOGON then
			return {Damage = dmgAmount *1.25}
		else
			recurtion = true
			ent:TakeDamage(dmgAmount * 1.25, flags, src, coolFrames)
			recurtion = false
			return false
		end]]
	end

end)


Mod:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, -100, function()
	local healerPresent = false
	pTools.ForEach(function(player)
		local pType = Mod:GetGlitchClassCopyAbility(player)
		if not healerPresent then
			healerPresent = (pType == Mod.Enum.Character.GELLO_B9)
			return true
		end
	end)

	if healerPresent then
		for _, e in ipairs(Isaac.GetRoomEntities()) do
			if e:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
				local maxHitPoints = e.MaxHitPoints
				if e.HitPoints < maxHitPoints then
					e.HitPoints = math.min(maxHitPoints, e.HitPoints + e.MaxHitPoints / 20)
					local effect = Mod:Spawn(1000, EffectVariant.HEART, 0, e.Position, Vector.Zero, nil):ToEffect()
					effect:GetSprite().Offset = HEART_OFFSET
					effect:FollowParent(e)

					SFX:Play(SoundEffect.SOUND_VAMP_GULP, 1)
				end
			end
		end
	end
end)
