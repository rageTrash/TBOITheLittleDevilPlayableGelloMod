
for _, load in ipairs ({
	"enum",
	"settings",
	"tools._loader",
	"specialFamiliarEffects",
	"api",
	"character._loader",
	"unlocks._loader",
	"stats",
	"compat._loader",
}) do GelloCharMod.Include(load) end
