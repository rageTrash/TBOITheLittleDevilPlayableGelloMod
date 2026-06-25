local Mod = GelloCharMod


local game = Mod.Game
local GridTools = {}
GelloCharMod.GridTools = GridTools



GelloCharMod.RockVariant = {
	ROCK_NORMAL = 0,
	ROCK_EVENT = 1,
}

GelloCharMod.PoopVariant = {
	POOP_NORMAL = 0,
	POOP_RED = 1,
	POOP_CORN = 2, POOP_CHUNKY = 2,
	POOP_GOLDEN = 3,
	POOP_RAINBOW = 4,
	POOP_BLACK = 5,
	POOP_WHITE = 6,
	POOP_GIANT_TL = 7,
	POOP_GIANT_TR = 8,
	POOP_GIANT_BL = 9,
	POOP_GIANT_BR = 10,
	POOP_CHARMING = 11,
}

GelloCharMod.TrapDoorVariant = {
	TRAPDOOR_NORMAL = 0,
	TRAPDOOR_VOID = 1,
}

GelloCharMod.PressurePlateVariant = {
	PRESSURE_PLATE_NORMAL = 0,
	PRESSURE_PLATE_REWARD = 1,
	PRESSURE_PLATE_WAVE = 2, PRESSURE_PLATE_GREEDMODE = 2,
	PRESSURE_PLATE_MINES = 3, PRESSURE_PLATE_KNIFE_PIECE_2 = 3,
	PRESSURE_PLATE_KILL_ALL_ENEMIES = 9, PRESSURE_PLATE_CLEAR_ROOM = 9,
	PRESSURE_PLATE_SPAWN_GRID = 10,
}

GelloCharMod.StairsVariant = {
	STAIRS_NORMAL = 0,
	STAIRS_GIDEON = 1,
	STAIRS_SECRET_SHOP = 2,
	STAIRS_ALT_PATH = 4,
}

GelloCharMod.StatueVariant = {
	STATUE_DEVIL = 0,
	STATUE_ANGEL = 1,
}


GelloCharMod.GridEntityState = {
	ROCK_IDLE = 1,
	ROCK_BROKEN = 2,
	ROCK_EXPLODING = 3,
	ROCK_DAMAGE = 4,

	LOCK_CLOSE = 0,
	LOCK_OPEN = 1,

	POOP_IDLE = 0,
	POOP_KINDA_DAMAGE = 250, POOP_LITTLE_DAMAGE = 250,
	POOP_DAMAGE = 500,
	POOP_VERY_DAMAGE = 750,
	POOP_BROKEN = 1000,

	TNT_IDLE = 0,
	TNT_KINDA_DAMAGE = 1, TNT_LITTLE_DAMAGE = 1,
	TNT_DAMAGE = 2,
	TNT_VERY_DAMAGE = 3,
	TNT_BROKEN = 4,

	SPIDERWEB_IDLE = 0,
	SPIDERWEB_BROKEN = 1,
}



function GridTools.TrySpawnGrid(pos, gridType, gridVariant)
	local room = game:GetRoom()
	local idx = room:GetGridIndex(pos)

	if idx == -1 then return end
	local gridPos = room:GetGridPosition(idx)
	local freePos = room:FindFreeTilePosition(gridPos, 0)

	if gridPos.X ~= freePos.X or gridPos.Y ~= freePos.Y then return end

	return Isaac.GridSpawn(gridType, (gridVariant or 0), gridPos, true)
end


function GridTools.FindGridByType(gridType)
	local list = {}
	local room = game:GetRoom()

	for idx =0, room:GetGridSize()-1 do
		local grid = room:GetGridEntity(idx)
		if grid and grid:GetType() == gridType then
			table.insert(list, grid)
		end
	end

	return list
end


function GridTools.GetGridFromTileToTile(startTile, endTile)
	local list = {}
	local room = game:GetRoom()

	for idx =startTile, endTile do
		local grid = room:GetGridEntity(idx)
		if grid and grid:GetType() == gridType then
			table.insert(list, grid)
		end
	end

	return list
end


local getGridPosVector = Vector(0,0)
local gridRadiusCapVector = Vector(0,0)
function GridTools.FindGridInRadius(pos, tileRadius, fromCenter,  squareRadius)
	local tab = {}
	local tileRadius = math.max(tileRadius, 0)
	local room = game:GetRoom()

	if squareRadius then
		for x = -tileRadius, tileRadius do
			getGridPosVector.X = pos.X + x *40
			for y = -tileRadius, tileRadius do
				getGridPosVector.Y = pos.Y + y *40
				local grid = room:GetGridEntityFromPos(getGridPosVector)
				if grid then
					table.insert(tab, grid)
				end
			end
		end
	else
		gridRadiusCapVector.X = pos.X + tileRadius*40
		gridRadiusCapVector.Y = pos.Y

		if not fromCenter then gridRadiusCapVector.X = gridRadiusCapVector.X +20 end -- taking the full grid end


		local cap = gridRadiusCapVector:Distance(pos)

		local angle = 0
		for x = -tileRadius, tileRadius do
			getGridPosVector.X = pos.X + x *40
			for y = -tileRadius, tileRadius do
				getGridPosVector.Y = pos.Y + y *40
				
				local grid = room:GetGridEntityFromPos(getGridPosVector)

				if grid and getGridPosVector:Distance(pos) <= cap then
					table.insert(tab, grid)
				end
			end
		end
	end

	return tab
end


