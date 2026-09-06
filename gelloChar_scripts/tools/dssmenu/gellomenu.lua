
local Mod = GelloCharMod
GelloCharMod.Data.DSS = GelloCharMod.Data.DSS or {}

local charEnum = Mod.Enum.Character

local function resyncUnlocksByMarks(charID)
    for name, marks in pairs(Mod:GetCharacterUnlocks(charID)) do
        local isUnlocked = true
        for mark, val in pairs(marks) do
            if Mod:GetMark(charID, mark) < val then
                isUnlocked = false
                break
            end
        end
        Mod:SetUnlock(name, isUnlocked)
    end
end

local function resyncMarksByUnlocks(charID)
    for _, mark in ipairs(MarksNAchievHelper.MarkType.ALL_MARKS) do
        Mod:SetMark(charID, mark, 0)
    end
    for name, marks in pairs(Mod:GetCharacterUnlocks(charID)) do
        if Mod:IsUnlock(name) then
            for mark, val in pairs(marks) do
                if Mod:GetMark(charID, mark) < val then Mod:SetMark(charID, mark, val) end
            end
        end
    end
end

local function charUpdateUnlock(state, charID, unlock)
    local val = 0
    if state then val = 2 end

    if not charID then
        for ID, charUnlocks in pairs(Mod.CharUnlocks) do
            for name, marks in pairs(charUnlocks) do
                Mod:SetUnlock(name, state)
            end
        end
    elseif not unlock then
        for name, marks in pairs( Mod:GetCharacterUnlocks(charID) ) do
            Mod:SetUnlock(name, state)
            if name == "Tainted Gello" and state == false then
                charUpdateUnlock(false, charEnum.GELLO_B13)
            end
        end
    elseif Mod.CharUnlocks[charID] and Mod.CharUnlocks[charID][unlock] then
        Mod:SetUnlock(unlock, state)
        if unlock == "Tainted Gello" and state == false then
            charUpdateUnlock(false, charEnum.GELLO_B13)
        end
    end
end

local UnlocksTable = {
    Gello = {
        ID = charEnum.GELLO,
        Unlocks = {
            {
                Name = "Lil Hamster",
                Tip = { 'unlocked by', 'defeating isaac' },
            },
            {
                Name = "Larry Jr Jr",
                Tip = { 'unlocked by', 'defeating ???' },
            },
            {
                Name = "Friendly Bite",
                Tip = { 'unlocked by', 'defeating satan' },
            },
            {
                Name = "Gallus",
                Tip = { 'unlocked by', 'defeating the lamb' },
            },
            {
                Name = "Weird Candy",
                Tip = { 'unlocked by', 'defeating', 'ultra greed' },
            },
            {
                Name = "Centepied",
                Tip = { 'unlocked by', 'defeating', 'ultra greedier' },
            },
            {
                Name = "Beelzebub",
                Tip = { 'unlocked by', 'compleating', 'boss rush' },
            },
            {
                Name = "Lil Embrion",
                Tip = { 'unlocked by', 'defeating hush' },
            },
            {
                Name = "Cursed Plushie",
                Tip = { 'unlocked by', 'defeating', 'mega satan' },
            },
            {
                Name = "Fetal Jar",
                Tip = { 'unlocked by', 'defeating delirium' },
            },
            {
                Name = "Motherly Chicken",
                Tip = { 'unlocked by', 'defeating mother' },
            },
            {
                Name = "Use Placenta",
                Tip = {'unlocked by', 'defeating', 'the beast'},
            },
            {
                Name = "Tainted Gello",
                Tip = {'unlocked by', 'opening the', 'secret closet', 'in home'},
            },
        }
    },
    GelloB = {
        ID = charEnum.GELLO_B13,
        Unlocks = {
            {
                Name = "Lil Cow",
                Tip = { 'unlocked by', 'defeating delirium' },
            },
            {
                Name = "Sacrificial Dagger",
                Tip = { 'unlocked by', 'defeating', 'ultra greedier' },
            },
            {
                Name = "Soul of Gello",
                Tip = { 'unlocked by', 'defeating hush', 'and compleating', 'boss rush' },
            },
            {
                Name = "Strange Stone",
                Tip = { 'unlocked by', 'defeating mother' },
            },
            {
                Name = "Egg",
                Tip = { 'unlocked by', 'defeating satan,', 'the lamb, isaac', 'and ???' },
            },
            {
                Name = "Lil Biter",
                Tip = { 'unlocked by', 'defeating', 'the beast' },
            },
            {
                Name = "Missing Post",
                Tip = { 'unlocked by', 'defeating', 'mega satan' },
            },
        }
    }
}

local function GenerateUnlockTable(key, tab)
    local charID = UnlocksTable[key].ID
    for _, data in ipairs(UnlocksTable[key].Unlocks) do
        local name = data.Name:lower()
        table.insert(tab.buttons, { str = "", nosel = true })
        
        table.insert(tab.buttons, {
            str = name, fsize = 2,
            tooltip = { strset = data.Tip },
            func = function()
                charUpdateUnlock(not Mod:IsUnlock(data.Name), charID, data.Name)
            end,
        })

        table.insert(tab.buttons, { str = "na", nosel = true, fsize = 2,
            update = function(b, i, t)
                if Mod:IsUnlock(data.Name) then
                    b.str = "unlocked"
                else
                    b.str = "locked"
                end
            end
        })
    end
end

-- Change this variable to match your mod. The standard is "Dead Sea Scrolls (Mod Name)"
local DSSModName = "Dead Sea Scrolls (Playable Gello)"

-- Every MenuProvider function below must have its own implementation in your mod, in order to
-- handle menu save data.
local MenuProvider = {}

function MenuProvider.SaveSaveData()
    Mod:SaveGameData()
end

function MenuProvider.GetPaletteSetting()
    return Mod.Data.DSS.MenuPalette
end

function MenuProvider.SavePaletteSetting(var)
    Mod.Data.DSS.MenuPalette = var
end

function MenuProvider.GetHudOffsetSetting()
    return Options.HUDOffset * 10
end

function MenuProvider.SaveHudOffsetSetting(var)
end

function MenuProvider.GetGamepadToggleSetting()
    return Mod.Data.DSS.GamepadToggle
end

function MenuProvider.SaveGamepadToggleSetting(var)
    Mod.Data.DSS.GamepadToggle = var
end

function MenuProvider.GetMenuKeybindSetting()
    return Mod.Data.DSS.MenuKeybind
end

function MenuProvider.SaveMenuKeybindSetting(var)
    Mod.Data.DSS.MenuKeybind = var
end

function MenuProvider.GetMenuHintSetting()
    return Mod.Data.DSS.MenuHint
end

function MenuProvider.SaveMenuHintSetting(var)
    Mod.Data.DSS.MenuHint = var
end

function MenuProvider.GetMenuBuzzerSetting()
    return Mod.Data.DSS.MenuBuzzer
end

function MenuProvider.SaveMenuBuzzerSetting(var)
    Mod.Data.DSS.MenuBuzzer = var
end

function MenuProvider.GetMenusNotified()
    return Mod.Data.DSS.MenusNotified
end

function MenuProvider.SaveMenusNotified(var)
    Mod.Data.DSS.MenusNotified = var
end

function MenuProvider.GetMenusPoppedUp()
    return Mod.Data.DSS.MenusPoppedUp
end

function MenuProvider.SaveMenusPoppedUp(var)
    Mod.Data.DSS.MenusPoppedUp = var
end

local dssmenucore = GelloCharMod.Include("tools.dssmenu.dssmenucore")

-- This function returns a table that some useful functions and defaults are stored on.
local dssmod = dssmenucore.init(DSSModName, MenuProvider)



local exampledirectory = {
    -- The keys in this table are used to determine button destinations.
    main = {
        title = 'playable gello',
        buttons = {
            { str = 'resume game',    action = 'resume' },
            { str = 'manage unlocks', dest = "unlocks" },
            { str = 'settings',       dest = 'settings' }
        },
        tooltip = dssmod.menuOpenToolTip,
    },
    
    settings = {
        title = 'settings',
        buttons = {
            dssmod.gamepadToggleButton,
            dssmod.menuKeybindButton,
            dssmod.paletteButton,
            dssmod.menuHintButton,
            dssmod.menuBuzzerButton,
            --[[
            {
                str = 'gello eats familiars', fsize = 2,
                choices = {'no', 'on touch', 'on bite'},
                setting = 2,
                variable = "Data.Settings.GelloFamiliarConsumeType",
                load = function()
                    return GelloCharMod.Data.Settings.GelloFamiliarConsumeType +1
                end,
                store = function(var)
                    GelloCharMod.Data.Settings.GelloFamiliarConsumeType = var -1
                end,
                tooltip = { strset = { 'how familiars', 'are eated by', 'gello' } }
            },{ str = "", nosel = true },
            
            {
                str = 'tainted gello eat fams', fsize = 2,
                choices = {'no', 'yes'},
                setting = 1,
                variable = "Data.Settings.TainteGelloEatsFams",
                load = function()
                    return (GelloCharMod.Data.Settings.TainteGelloEatsFams and 2) or 1
                end,
                store = function(var)
                    GelloCharMod.Data.Settings.TainteGelloEatsFams = (var == 2)
                end,
                tooltip = { strset = { 'should tainted', 'gello eat', 'familiars' } }
            },{ str = "", nosel = true },]]

            {
                str = 'lil cow death anim', fsize = 2,
                choices = {'random', 'doom', 'minecraft'},
                setting = 1,
                variable = "Data.Settings.LilCowDead",
                load = function()
                    return (GelloCharMod.Data.Settings.LilCowDead or Mod.GetDefaultSetting("LilCowDead")) +1
                end,
                store = function(var)
                    GelloCharMod.Data.Settings.LilCowDead = var -1
                end,
                tooltip = { strset = { 'witch death', 'animation', 'lil cow do' } }
            },{ str = "", nosel = true },
            
            {
                str = 'chargebar gfx style', fsize = 2,
                choices = {'vanilla', 'improve'},
                setting = 1,
                variable = "Data.Settings.ChargeGFX",
                load = function()
                    return (GelloCharMod.Data.Settings.ChargeGFX or Mod.GetDefaultSetting("ChargeGFX")) +1
                end,
                store = function(var)
                    GelloCharMod.Data.Settings.ChargeGFX = var -1
                end,
                tooltip = { strset = { 'chargebar', 'gfx style' } }
            },{ str = "", nosel = true },
            
            {
                str = 'friendly bite alt', fsize = 2,
                choices = {'false', 'true'},
                setting = 1,
                variable = "Data.Settings.FriendlyBiteAltMode",
                load = function()
                    return (GelloCharMod.Data.Settings.FriendlyBiteAltMode or Mod.GetDefaultSetting("FriendlyBiteAltMode")) and 2 or 1
                end,
                store = function(var)
                    GelloCharMod.Data.Settings.FriendlyBiteAltMode = var == 2
                end,
                tooltip = { strset = { 'friendly bite', 'is an active', 'item' } }
            },{ str = "", nosel = true },
            
            {
                str = 'larry thematic drop', fsize = 2,
                choices = {'false', 'true'},
                setting = 1,
                variable = "Data.Settings.LarryJrJr_ThematicDrop",
                load = function()
                    return (GelloCharMod.Data.Settings.LarryJrJr_ThematicDrop or Mod.GetDefaultSetting("LarryJrJr_ThematicDrop")) and 2 or 1
                end,
                store = function(var)
                    GelloCharMod.Data.Settings.LarryJrJr_ThematicDrop = var == 2
                end,
                tooltip = { strset = { 'larry jr', 'thematic item', 'drop' } },
                displayif = function() return Mod.RepentogonPlus end
            }
        }
    },
    unlocks = {
        title = "unlocks",
        buttons = {
            dssmod.gamepadToggleButton,
            dssmod.menuKeybindButton,
            dssmod.paletteButton,
            dssmod.menuHintButton,
            dssmod.menuBuzzerButton,
            
            {
                str = "unlock all", fsize = 2,
                func = function()
                    charUpdateUnlock(true)
                end,
                tooltip = { strset = {"unlocks all", "achievements"} }
            },
            {
                str = "lock all", fsize = 2,
                func = function()
                    charUpdateUnlock(false)
                end,
                tooltip = { strset = {"locks all", "achievements"} }
            },

            { str = "", nosel = true },
            {
                str = "gello", fsize = 2, displayif = function() return Mod.RepentogonPlus end,
                func = function()
                    if not Mod.RepentogonPlus then return end
                    local persData = Isaac.GetPersistentGameData()
                    if persData:Unlocked(Mod.GelloCharAchievement) then
                        Isaac.ExecuteCommand("lockachievement "..Mod.GelloCharAchievement)
                    else
                        persData:Unlock(Mod.GelloCharAchievement, true)
                    end
                end,
                tooltip = { strset = {"unlocks", "gello"} }
            },
            { str = "na", nosel = true, fsize = 2, displayif = function() return Mod.RepentogonPlus end,
                update = function(b, i, t)
                    if not Mod.RepentogonPlus then return end
                    if Isaac.GetPersistentGameData():Unlocked(Mod.GelloCharAchievement) then
                        b.str = "unlocked"
                    else
                        b.str = "locked"
                    end
                end
            },
            { str = "", nosel = true, displayif = function() return Mod.RepentogonPlus end },

            { str = "gello unlocks", dest = "gello_unlocks", displayif = function()
                if not Mod.RepentogonPlus then return true end
                return Isaac.GetPersistentGameData():Unlocked(Mod.GelloCharAchievement)
            end, fsize = 2 },
            { str = "t. gello unlocks", dest = "gello_b_unlocks", displayif = function() return Mod:IsUnlock("Tainted Gello") end, fsize = 2 },
        },
    },
    gello_unlocks = {
        title = "unlocks of gello",
        generate = function(tab)
            tab.buttons = {
                dssmod.gamepadToggleButton,
                dssmod.menuKeybindButton,
                dssmod.paletteButton,
                dssmod.menuHintButton,
                dssmod.menuBuzzerButton,
                
                {
                    str = "unlock all", fsize = 2,
                    func = function() charUpdateUnlock(true, charEnum.GELLO) end,
                    tooltip = { strset = {"unlocks all", "gellos achievements"} }
                },
                {
                    str = "lock all", fsize = 2,
                    func = function() charUpdateUnlock(false, charEnum.GELLO) end,
                    tooltip = { strset = {"locks all", "gellos achievements"} }
                },{ str = "", nosel = true },
                {
                    str = "sync unlocks to marks", fsize = 2,
                    func = function() resyncUnlocksByMarks(charEnum.GELLO) end,
                    tooltip = { strset = {"sync the unlocks", "to gellos marks"} }
                },
                {
                    str = "sync marks to unlocks", fsize = 2,
                    func = function() resyncMarksByUnlocks(charEnum.GELLO) end,
                    tooltip = { strset = {"sync the marks to", "to gellos unlocks"} }
                },{ str = "", nosel = true },

                { str = "marks achievements", nosel = true },
            }
            GenerateUnlockTable("Gello", tab)
        end,
        buttons = {},
    },
    gello_b_unlocks = {
        title = "unlocks of t. gello",
        generate = function(tab)
            tab.buttons = {
                dssmod.gamepadToggleButton,
                dssmod.menuKeybindButton,
                dssmod.paletteButton,
                dssmod.menuHintButton,
                dssmod.menuBuzzerButton,
                
                {
                    str = "unlock all", fsize = 2,
                    func = function() charUpdateUnlock(true, charEnum.GELLO_B13) end,
                    tooltip = { strset = {"unlocks all", "t. gellos", "achievements"} }
                },
                {
                    str = "lock all", fsize = 2,
                    func = function() charUpdateUnlock(false, charEnum.GELLO_B13) end,
                    tooltip = { strset = {"locks all", "t. gellos", "achievements"} }
                },
                {
                    str = "sync unlocks to marks", fsize = 2,
                    func = function() resyncUnlocksByMarks(charEnum.GELLO) end,
                    tooltip = { strset = {"sync the unlocks", "to t. gellos marks"} }
                },
                {
                    str = "sync marks to unlocks", fsize = 2,
                    func = function() resyncMarksByUnlocks(charEnum.GELLO) end,
                    tooltip = { strset = {"sync the marks to", "to t. gellos unlocks"} }
                },
                { str = "", nosel = true },
                { str = "", nosel = true },

                { str = "marks achievements", nosel = true },
            }
            GenerateUnlockTable("GelloB", tab)
        end,
        buttons = {},
    },
}

local exampledirectorykey = {
    -- This is the initial item of the menu, generally you want to set it to your main item
    Item = exampledirectory.main,
    -- The main item of the menu is the item that gets opened first when opening your mod's menu.
    Main = 'main',
    -- These are default state variables for the menu; they're important to have in here, but you
    -- don't need to change them at all.
    Idle = false,
    MaskAlpha = 1,
    Settings = {},
    SettingsChanged = false,
    Path = {},
}

DeadSeaScrollsMenu.AddMenu("Playable Gello", {
    -- The Run, Close, and Open functions define the core loop of your menu. Once your menu is
    -- opened, all the work is shifted off to your mod running these functions, so each mod can have
    -- its own independently functioning menu. The `init` function returns a table with defaults
    -- defined for each function, as "runMenu", "openMenu", and "closeMenu". Using these defaults
    -- will get you the same menu you see in Bertran and most other mods that use DSS. But, if you
    -- did want a completely custom menu, this would be the way to do it!

    -- This function runs every render frame while your menu is open, it handles everything!
    -- Drawing, inputs, etc.
    Run = dssmod.runMenu,
    -- This function runs when the menu is opened, and generally initializes the menu.
    Open = dssmod.openMenu,
    -- This function runs when the menu is closed, and generally handles storing of save data /
    -- general shut down.
    Close = dssmod.closeMenu,
    -- If UseSubMenu is set to true, when other mods with UseSubMenu set to false / nil are enabled,
    -- your menu will be hidden behind an "Other Mods" button.
    -- A good idea to use to help keep menus clean if you don't expect players to use your menu very
    -- often!
    UseSubMenu = false,
    Directory = exampledirectory,
    DirectoryKey = exampledirectorykey
})

-- There are a lot more features that DSS supports not covered here, like sprite insertion and
-- scroller menus, that you'll have to look at other mods for reference to use. But, this should be
-- everything you need to create a simple menu for configuration or other simple use cases!
