local GelloMenu = {}
local Mod = GelloCharMod
local sfx = Mod.SFX
local game = Mod.Game


local pTools = Mod.PlayerTools
local tTools = Mod.TableTools
local gTools = Mod.GridTools
local MenuData = Mod.SaveHandler.Save("MenuData")
local GelloSave = Mod.SaveHandler.Save("TaintedGelloSaveState")
local GelloPoints = Mod.SaveHandler.Save("GelloPoints")




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


local MenuFocusIndex = 2
local RUTE = "gfx/ui_gello/selection/"

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



function GelloMenu.IsActive() return MenuData:Get(MENU_SAVEDATA).IsActive end

function GelloMenu.GetIndex()
    if not GelloMenu.IsActive() then return -1 end
    return MenuFocusIndex
end
function GelloMenu.SetIndex(index)
    MenuFocusIndex = GelloCharMod:Clamp(index, 1, 3)
end

--function GelloCharMod:IsRenderingMenu() return MenuData:Get(MENU_SAVEDATA).IsActive end


local function screenCenter() -- found it in epiphany
    local room = game:GetRoom()

    local pos = room:WorldToScreenPosition(Vector.Zero) - room:GetRenderScrollOffset() - game.ScreenShakeOffset

    local rx = pos.X + 60 * 26 / 40
    local ry = pos.Y + 140 * (26 / 40)

    return Vector(rx * 2 + 13 * 26, ry * 2 + 7 * 26) /2
end

function GelloMenu.CheckIfPlayerWasAdded(player)
    local menuData = MenuData:Get(MENU_SAVEDATA)
    local seed = player.InitSeed
    for idx =1, #menuData.Queue do
        if menuData.Queue[idx] == seed then return true end
    end
    return false
end

function GelloMenu.AddPlayerToQueue(player)
    local menuData = MenuData:Get(MENU_SAVEDATA)
    local seed = player.InitSeed
    table.insert(menuData.Queue, seed)
    MenuData:Set(menuData)
end


-------------------------------------------------------------------------------------------------------------
---                                SELECTION        MENU
-------------------------------------------------------------------------------------------------------------

local SelectionRNG = RNG()
function GelloMenu.GenerateRunClasses(max)
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


function GelloMenu.GenerateSelection(offset)
    local offset = offset or 1
    local seed = game:GetLevel():GetDungeonPlacementSeed()
    SelectionRNG:SetSeed(seed, 15 *offset +1)

    local data = GelloSave:Get(GELLO_SAVEDATA)
    local classes = tTools.Copy(data.RunClasses)
    --local str = "- "
    --for className, levelPassed in pairs(data.PrevClasses) do
    --    str = str.. className .." " ..levelPassed.." - "
    --end
    --print("prev classes:", str)
    --str = "- "
    --for className, _ in pairs(data.CurrentClasses) do
    --    str = str.. className .." - "
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
    --    str = str.. className .." - "
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

            GelloMenu.GenerateRunClasses(6 + (gellosNum-1) *2)
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
                    GelloMenu.GenerateRunClasses(6) -- if the main player is gello we already know to load 6 classes

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
        MenuData:Set(menuData)
        pTools.ForEach(function(player)
            if Mod:IsTaintedGello(player) and player.Parent == nil and not GelloMenu.CheckIfWasAllreadyAdded(player) then
                GelloMenu.AddPlayerToQueue(player)
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
        GelloMenu.GenerateSelection( getPlayerIndex(data.Queue[1]) +1)
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

