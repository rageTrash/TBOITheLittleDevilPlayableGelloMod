local enum = {}
GelloCharMod.Enum = enum



enum.Character = {
	GELLO = Isaac.GetPlayerTypeByName("Gello"),

	GELLO_B1 =  Isaac.GetPlayerTypeByName("Gello", true)-1,     -- figther
	GELLO_B2 =  Isaac.GetPlayerTypeByName("Gello", true)-2,     -- jester
	GELLO_B3 =  Isaac.GetPlayerTypeByName("Gello", true)-3,     -- tank
	GELLO_B4 =  Isaac.GetPlayerTypeByName("Gello", true)-4,     -- scout
	GELLO_B5 =  Isaac.GetPlayerTypeByName("Gello", true)-5,     -- singer
	GELLO_B6 =  Isaac.GetPlayerTypeByName("Gello", true)-6,     -- explosivo
	GELLO_B7 =  Isaac.GetPlayerTypeByName("Gello", true)-7,     -- gravediger
	GELLO_B8 =  Isaac.GetPlayerTypeByName("Gello", true)-8,     -- merchant
	GELLO_B9 =  Isaac.GetPlayerTypeByName("Gello", true)-9,     -- healer
	GELLO_B10 = Isaac.GetPlayerTypeByName("Gello", true)-10,    -- botanic
	GELLO_B11 = Isaac.GetPlayerTypeByName("Gello", true)-11,    -- venom
	GELLO_B12 = Isaac.GetPlayerTypeByName("Gello", true)-12,    -- geologist
	GELLO_B13 = Isaac.GetPlayerTypeByName("Gello", true),       -- "none"

	--GELLO_C = Isaac.GetPlayerTypeByName(" Gello"),
}

enum.Item = {
	-- Gello unlocks
	LIL_HAMSTER =      Isaac.GetItemIdByName("Lil Hamster"),  -- damage all enemies in the room
	LIL_HAMSTER_2 =    Isaac.GetItemIdByName("Lil Hamster")-1,-- applys uranus like effect to all enemies in the room for 5 seconds
	LIL_HAMSTER_3 =    Isaac.GetItemIdByName("Lil Hamster")-2,-- burn all enemies in the room for 5 seconds
	LIL_HAMSTER_4 =    Isaac.GetItemIdByName("Lil Hamster")-3,-- heals the player

	BEELZEBUB =        Isaac.GetItemIdByName("Beelzebub"),
	FETAL_JAR =        Isaac.GetItemIdByName("Fetal Jar"),
	MOTHERLY_CHICKEN = Isaac.GetItemIdByName("Motherly Chicken"),
	USE_PLACENTA =     Isaac.GetItemIdByName("Use Placenta"),
	CURSED_PLUSHIE =   Isaac.GetItemIdByName("Cursed Plushie"),
	GALLUS =           Isaac.GetItemIdByName("Gallus"),
	LARRY_JR_JR =      Isaac.GetItemIdByName("Larry Jr Jr"),
	CENTEPIED =        Isaac.GetItemIdByName("Centepied"),
	LIL_EMBRION =      Isaac.GetItemIdByName("Lil Embrion"),

	FRIENDLY_BITE =    Isaac.GetItemIdByName("Friendly Bite"),
	FRIENDLY_BITE_ALT= Isaac.GetItemIdByName("Friendly Bite") -1, -- active version

	VOID_STOMACH =    Isaac.GetItemIdByName("Void Stomach"),

	-- T Gello unlocks
	LIL_BITER =        Isaac.GetItemIdByName("Lil Biter"),
	LIL_COW =          Isaac.GetItemIdByName("Lil Cow"),

	-- Misc items
	MISSING_HANDLER =  Isaac.GetItemIdByName("MISSING_POST_FAMILIAR_HANDLER"),
	TEMP_DMG =         Isaac.GetItemIdByName("GELLO_TEMP_DAMAGE_HANDLER"),
	TEMP_DMG_SLOW =    Isaac.GetItemIdByName("GELLO_SLOW_TEMP_DAMAGE_HANDLER"),
}

enum.Trinket = {
	-- Gello unlocks
	WEIRD_CANDY =   Isaac.GetTrinketIdByName("Weird Candy"),
	
	-- T Gello unlocks
	EGG =           Isaac.GetTrinketIdByName("Egg"),
	STRANGE_STONE = Isaac.GetTrinketIdByName("Strange Stone"),
}

enum.Card = {
	-- T Gello unlocks
	SACRIFICIAL_DAGGER = Isaac.GetCardIdByName("SacrificialDagger_Gello"),
	SOUL_OF_GELLO =      Isaac.GetCardIdByName("SoulofGello"),
}

enum.Slot = {
	-- T Gello unlocks
	MISSING_POSTER = Isaac.GetEntityVariantByName("Missing Post (Slot)"),
}

enum.Familiar = {
	BEELZEBUB =       Isaac.GetEntityVariantByName("Beelzebub (Familiar)"),        -- Beelzebub (item)
	LIL_EMBRION_FAM = Isaac.GetEntityVariantByName("Lil Embrion (Familiar)"),      -- Lil Embrion (trinket)
	LARRY_JR_JR =     Isaac.GetEntityVariantByName("Larry Jr Jr (Familiar)"),      -- Larry Jr Jr (item)

	LIL_BITER =       Isaac.GetEntityVariantByName("Lil Biter (Familiar)"),        -- Lil Biter (item)
	LIL_COW =         Isaac.GetEntityVariantByName("Lil Cow (Familiar)"),          -- Lil Cow (item)
	MISSING_FAM =     Isaac.GetEntityVariantByName("Missing Post Familiar Helper"),-- Missing Poster (slot) quest familiar
}

enum.Effect = {
	BITE =       Isaac.GetEntityVariantByName("Gello Bite Effect"),
	CENTEPIED =  Isaac.GetEntityVariantByName("Centepied Shield"),
	FAM_RENDER = Isaac.GetEntityVariantByName("Missing Post Fam Render"),
	PLANT =      Isaac.GetEntityVariantByName("Gellos plant"),
	DASH =       Isaac.GetEntityVariantByName("Gellos dash"),
	EAT =       Isaac.GetEntityVariantByName("Gellos Eat Effect"),
}

enum.Sound = {
	BITE = Isaac.GetSoundIdByName("GelloBiteSoundEffect")
}

enum.NPC ={
	MISSING_NPC = Isaac.GetEntityVariantByName("Missing Familiar Enemy")
}
