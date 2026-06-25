local api = {}
GelloCharMod.API = api

local tTools = GelloCharMod.TableTools

local CUSTOM_TEAR_LIST = {
	--function(tear, rng, ludo) tear:AddTearFlags(TearFlags.TEAR_SPECTRAL) end,
}
local CUSTOM_LASER_LIST = {
	--function(ent, rng, ludo) end
}
local CUSTOM_KNIFE_LIST = {
	--function(ent, rng) end
}
local CUSTOM_BOMB_LIST = {
	--function(ent, rng) end
}

---@param effectFun :: function (ent, rng, isLudo[boolean]) -> void
---@param data      :: table { Laser = [boolean] , Knife = [boolean] , Bomb = [boolean] }
function api.RegisterCustomTearEffect(effectFun, data)
	if type(effectFun) ~= "function" then
		GelloCharMod:Error("Argument #1 is not a function")
		return
	end
	table.insert(CUSTOM_TEAR_LIST, effectFun)

	if data then
		if data.Laser then
			table.insert(CUSTOM_LASER_LIST, effectFun)
		end
		if data.Knife then
			table.insert(CUSTOM_KNIFE_LIST, effectFun)
		end
		if data.Bomb then
			table.insert(CUSTOM_BOMB_LIST, effectFun)
		end
	end
end

function api.AddRandomTearEffect(ent, amount, rng, isludo)
	local tear = ent:ToTear()
	if not tear or amount <= 0 then return end

	local tab = tTools.CopyLite(CUSTOM_TEAR_LIST)
	tab = tTools.Shuffle(tab, rng)
	for i=1, math.min(amount, #tab) do
		tab[i](tear, rng, isludo)
	end
end

function api.AddRandomLaserEffect(ent, amount, rng, isludo)
	local laser = ent:ToLaser()
	if not laser or amount <= 0 then return end

	local tab = tTools.CopyLite(CUSTOM_TEAR_LIST)
	tab = tTools.Shuffle(tab, rng)
	for i=1, math.min(amount, #tab) do
		tab[i](laser, rng, isludo)
	end
end

function api.AddRandomKnifeEffect(ent, amount, rng)
	local knife = ent:ToKnife()
	if not knife or amount <= 0 then return end
	
	local tab = tTools.CopyLite(CUSTOM_TEAR_LIST)
	tab = tTools.Shuffle(tab, rng)
	for i=1, math.min(amount, #tab) do
		tab[i](knife, rng)
	end
end

function api.AddRandomBombEffect(ent, amount, rng)
	local bomb = ent:ToBomb()
	if not bomb or amount <= 0 then return end
	
	local tab = tTools.CopyLite(CUSTOM_TEAR_LIST)
	tab = tTools.Shuffle(tab, rng)
	for i=1, math.min(amount, #tab) do
		tab[i](bomb, rng)
	end
end




for _, data in ipairs({
	{TearFlags.TEAR_SPECTRAL, {Laser = true, Bomb = true}},
	{TearFlags.TEAR_PIERCING, {Laser = true, Bomb = true}},
	{TearFlags.TEAR_HOMING,   {Laser = true, Bomb = true, Knife = true}},
	{TearFlags.TEAR_SLOW,     {Laser = true, Bomb = true, Knife = true}},
	{TearFlags.TEAR_POISON,   {Laser = true, Bomb = true, Knife = true}},
	{TearFlags.TEAR_FREEZE,   {Laser = true, Knife = true}},
	{TearFlags.TEAR_SPLIT,    {Laser = true, Bomb = true, Knife = true}},
	{TearFlags.TEAR_GROW,     {Laser = true, Bomb = true, Knife = true}},
	{TearFlags.TEAR_BOOMERANG,{Laser = true, Knife = true}},
	{TearFlags.TEAR_WIGGLE,   {Laser = true, Knife = true}},
	{TearFlags.TEAR_MULLIGAN, {Laser = true, Bomb = true, Knife = true}},
	{TearFlags.TEAR_EXPLOSIVE,{Laser = true, Bomb = true, Knife = true}},
	{TearFlags.TEAR_CHARM,    {Laser = true, Bomb = true, Knife = true}},
	{TearFlags.TEAR_CONFUSION,{Laser = true, Bomb = true, Knife = true}},
	{TearFlags.TEAR_QUADSPLIT,{Laser = true, Bomb = true, Knife = true}},
	{TearFlags.TEAR_FEAR,     {Laser = true, Bomb = true, Knife = true}},
	{TearFlags.TEAR_BURN,     {Laser = true, Bomb = true, Knife = true}},
	{TearFlags.TEAR_GLOW,     {}},
	{TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP,{Laser = true, Bomb = true, Knife = true}},
	{TearFlags.TEAR_SHIELDED, {Laser = true, Bomb = true, Knife = true}},
	{TearFlags.TEAR_EGG,      {Knife = true}},
	{TearFlags.TEAR_ACID,     {Laser = true, Bomb = true, Knife = true}},
	{TearFlags.TEAR_BONE,     {}},
	{TearFlags.TEAR_BELIAL,   {}},
	{TearFlags.TEAR_JACOBS,   {Laser = true, Bomb = true, Knife = true}},
	{TearFlags.TEAR_HORN,     {Laser = true, Bomb = true, Knife = true}},
	{TearFlags.TEAR_HYDROBOUNCE,{}},
	{TearFlags.TEAR_BURSTSPLIT,{}},
	{TearFlags.TEAR_ICE,      {Laser = true, Bomb = true, Knife = true}},
	{TearFlags.TEAR_MAGNETIZE,{Laser = true, Bomb = true, Knife = true}},
	{TearFlags.TEAR_ROCK,     {Laser = true, Bomb = true, Knife = true}},
	{TearFlags.TEAR_RIFT,     {Laser = true, Bomb = true, Knife = true}},
	{TearFlags.TEAR_SPORE,    {Laser = true, Bomb = true, Knife = true}},
}) do
	api.RegisterCustomTearEffect(function(ent) ent:AddTearFlags(data[1]) end, data[2])
end