local Mod = GelloCharMod
local path = "compat."

local loadTable = {}
local earlyLoadTable = {}
local WasLoaded = false
local WasEarlyLoaded = false

function GelloCharMod.AddModPath(globalName, compatFun, loadEarly)
	if loadEarly then
		table.insert(earlyLoadTable, {Global = globalName, Fun = compatFun})
		return
	end
	table.insert(loadTable, {Global = globalName, Fun = compatFun})
end


for _, load in ipairs({
	"_vanilla",
	"eid",
	
	"encyclopedia.items",
	"encyclopedia.trinkets",
	"encyclopedia.characters",
	"encyclopedia.consumables",
	
	"stageapi",
	"minimapapi",

	"fiendFolio",
	"thefuture",
	"runeTablet",
	"epiphany",
}) do
	Mod.Include(path..load)
end



Mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, -100, function(_, continued)
	if WasEarlyLoaded then return end

	for _, patch in ipairs(earlyLoadTable) do
		local mod

		if type(patch.Global) == "function" then
			mod = patch.Global()
		else
			mod = _G[patch.Global]
		end

		if mod then
			patch.Fun()
		end
	end

	WasEarlyLoaded = true
end)

Mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, 200, function(_, continued)
	if WasLoaded then return end

	for _, patch in ipairs(loadTable) do
		local mod

		if type(patch.Global) == "function" then
			mod = patch.Global()
		else
			mod = _G[patch.Global]
		end

		if mod then
			patch.Fun()
		end
	end

	WasLoaded = true
end)