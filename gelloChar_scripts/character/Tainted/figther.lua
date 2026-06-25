--[[
	Start:
		Health : R B B

	On Selection:
		Pocket : XV - The Devil

	Stats:
		+ 1.5 dmg
		+ 0.12 speed
		- 0.3 tears

	Ability:
		Fire Tap to Bite

	LV1:
		+ 1.5 damage
		x1.25 Bite Area

	LV2:
		bite timer halfed
		x1.15 base dmg

	LV3:
		x1.5 Bite Area
		x1.24 base dmg
	

	using this to render the menu
]]
local Mod = GelloCharMod
local game = Mod.Game
local pTools = Mod.PlayerTools

return {
	Id = Mod.Enum.Character.GELLO_B1,

	InitPlayer = function(player, init)
		if init then pTools.ReplacePlayerHealth(player, {MaxHearts = 1, Hearts = 2, Black = 4}) end
		--player:AddCard(Card.CARD_DEVIL)
		if Mod.GetSetting("FriendlyBiteAltMode") then
			player:SetPocketActiveItem(Mod.Enum.Item.FRIENDLY_BITE_ALT, ActiveSlot.SLOT_POCKET)
		end
	end
}