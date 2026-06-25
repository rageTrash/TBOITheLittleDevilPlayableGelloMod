local setttings = {}

local DEFAULT_SETTING = {
	--GelloFamiliarConsumeType = 1, -- 0 don't consume fams, 1 consumes when touching a fam, 2 consumes when bitting the fam
	--TainteGelloEatsFams = false,-- tainted gello eats familiars?
	LilCowDead = 0,             -- 0 random, 1 doom, 2 minecraft
	ChargeGFX = 0,              -- 0 vanilla, 1 improve charge bar
	FriendlyBiteAltMode = false -- is alt mode active (is an active item)
}

for key, val in pairs(DEFAULT_SETTING) do
	setttings[key] = val
end
GelloCharMod.Data.Settings = setttings

function GelloCharMod.GetDefaultSetting(key)
	return DEFAULT_SETTING[key]
end

function GelloCharMod.SyncSettings()
	GelloCharMod.Data.Settings = (GelloCharMod.Data.Settings or {})
	for k, v in pairs(DEFAULT_SETTING) do
		if GelloCharMod.Data.Settings[k] == nil then
			GelloCharMod.Data.Settings[k] = v
		end
	end
end

function GelloCharMod.GetSetting(key)
	return (GelloCharMod.Data.Settings or {})[key] or GelloCharMod.GetDefaultSetting(key)
end