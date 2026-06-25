local rute = "unlocks."


for _, load in ipairs ({
	"beelzebub",        -- done
	"centepied",        -- done
	"cursed_plushie",   -- done
	"fetal_jar",        -- done
	"friendly_bite",    -- done
	"gallus",           -- done
	"larry_jr_jr",      -- done
	"lil_embrion",      -- done
	"lil_hamster",      -- done
	"motherly_chicken", -- done
	"rare_candy",       -- done
	"use_placenta",     -- done
	"void_stomach",     -- 
}) do GelloCharMod.Include(rute.."normal."..load) end


for _, load in ipairs ({
	"egg",                -- done
	"sacrificial_dagger", -- done
	"lil_biter",          -- done
	"lil_cow",            -- done
	"missing_post",       -- done
	"soul_of_gello",      -- done
	"strange_stone",      -- done
}) do GelloCharMod.Include(rute.."tainted."..load) end
