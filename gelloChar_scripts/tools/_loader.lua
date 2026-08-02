local rute = "tools."
--[[
GelloCharMod.Include(rute.."customcommands.customcommands")
CustomCommands:AddCommand(
	"GelloMod",
	"Debug",
	{},
	function() end,
	"This command does nothing. Only use for grouping commands"
)]]

if not GelloCharMod.RepentogonPlus then
	GelloCharMod.Include(rute.."completion_marks_api.pause_screen_completion_marks_api")
	GelloCharMod.Include(rute.."completion_marks_api.add_character_mark_api")
end

GelloCharMod.Include(rute.."dssmenu.gellomenu")

GelloCharMod.HiddenItemManager = GelloCharMod.Include(rute .. "innate_items_manager.hidden_item_manager")
GelloCharMod.HiddenItemManager:Init(GelloCharMod)
--GelloCharMod.Include(rute.."innate_items_manager.manager")

--GelloCharMod.Include(rute.."hud_helper.hud_helper")
GelloCharMod.Include(rute.."vanillathings._loader")
GelloCharMod.Include(rute.."run_later")

GelloCharMod.Include(rute.."table")
GelloCharMod.Include(rute.."general")
GelloCharMod.Include(rute.."save")
GelloCharMod.Include(rute.."player")
GelloCharMod.Include(rute.."items")
GelloCharMod.Include(rute.."level")
GelloCharMod.Include(rute.."grid")
GelloCharMod.Include(rute.."familiar")
GelloCharMod.Include(rute.."effects")
GelloCharMod.Include(rute.."knife")

GelloCharMod.Include(rute.."do_cache")
GelloCharMod.Include(rute.."unlocks_fun")
GelloCharMod.Include(rute.."unlocks_handler")

GelloCharMod.Include(rute.."CustomReviveLibThing")(GelloCharMod)
GelloCharMod.Include(rute.."rewind")