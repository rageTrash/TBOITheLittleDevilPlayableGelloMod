local Mod = GelloCharMod
local SaveHandler = Mod.SaveHandler
local TableTools = Mod.TableTools

local Save_Data = SaveHandler.Data("Save")
local PreSave_Data = SaveHandler.Data("PreSave")

local UseGlowingGlass = false
Mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
	local MagicTable = {}
	local PreSave = TableTools.Copy(Save_Data:Get())
	
	MagicTable = TableTools.Copy(PreSave) 

	Save_Data:Set(nil)
	Save_Data:Set(TableTools.Copy(PreSave_Data:Get()))

	PreSave_Data:Set(nil)
	PreSave_Data:Set(TableTools.Copy(MagicTable))

	UseGlowingGlass = true
end, CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)


local pTools = Mod.PlayerTools

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	if UseGlowingGlass then
		UseGlowingGlass = false
		
		pTools.ForEach(function(player) pTools.DoCache(player, CacheFlag.CACHE_ALL) end)
		return
	end
	local MagicTable = {}
	local PreSave = TableTools.Copy(Save_Data:Get())
	
	MagicTable = TableTools.Copy(PreSave)

	PreSave_Data:Set(nil)
	PreSave_Data:Set(TableTools.Copy(MagicTable))
end)