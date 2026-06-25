
for _, load in ipairs ({
	"enum",
	"settings",
	"tools._loader",
	"api",
	"character._loader",
	"unlocks._loader",
	"stats",
	"specialFamiliarEffects",
	"compat._loader",
}) do GelloCharMod.Include(load) end
