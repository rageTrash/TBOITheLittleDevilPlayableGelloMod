--[[
	Start:
		Health : R S
		Pocket : 1 Bomb

	Stats:
		+ 0.2 speed
		+ 0.2 tears
		- 1 damage
		- 0.3 size

	Ability:
		tapping the move direction will make a dash

	LV1:
		20% to shoot a tear with confusion

	LV2:
		start a dash cause a shock wave to close enemies

	LV3:
		35% to shoot a tear with confusion
		dashing atraves de los enemigos los daña
]]
local Mod = GelloCharMod
local game = Mod.Game
local pTools = Mod.PlayerTools

local DirEnumToString = {
	[Direction.LEFT] = "Left",
	[Direction.UP] = "Up",
	[Direction.RIGHT] = "Right",
	[Direction.DOWN] = "Down",
	[Direction.NO_DIRECTION] = "Down",
}

if not Mod.RepentogonPlus then
	Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
		local sp = eff:GetSprite()
		local frame = eff.FrameCount
		if frame == 1 then
			local spawner = eff.SpawnerEntity
			if spawner then
				local player = spawner:ToPlayer()
				if player == nil then return end
				local playerSprite = player:GetSprite()
				sp:Load(playerSprite:GetFilename(), true)

				sp:SetFrame("Head"..DirEnumToString[player:GetHeadDirection()], 0)
				sp:SetOverlayFrame("Walk"..DirEnumToString[player:GetMovementDirection()], 0)
				sp.Scale = playerSprite.Scale
			else
				sp:SetFrame("HeadDown", 0)
				sp:SetOverlayFrame("WalkDown", 0)
			end
		end

		if frame >= 15 then
			eff:Remove()
			return
		end

		eff.Color = Color(
			0.25,0.25,0.25,
			(128 - frame *8) / 255,
			0.7,0.7,0.7
		)
	end, Mod.Enum.Effect.DASH)
end

return {
	Id = Mod.Enum.Character.GELLO_B4,

	InitPlayer = function(player, init)
		if init then pTools.ReplacePlayerHealth(player, {MaxHearts = 1, Hearts = 2, Soul = 2}) end
		player:AddBombs(1)
	end,

}