local Mod = GelloCharMod
local Game = Mod.Game

local RunLater = {}

function GelloCharMod:RunLater(delay, func, ...)
	local _, err = pcall(error, "Error on running function;", 3)
	local args = {...} or {}
	table.insert(RunLater, {
		Wait = (delay or 0) + Game:GetFrameCount(),
		Run = func,
		Args = args,
		OnError = err
	})
end


Mod:AddPriorityCallback(ModCallbacks.MC_POST_UPDATE, 100, function()
	local timeCheck = Game:GetFrameCount()
	for i= #RunLater, 1, -1 do
		local runData = RunLater[i]
		if runData.Wait <= timeCheck then
			local status, ret = pcall(runData.Run, table.unpack(runData.Args) )
			table.remove(RunLater, i)
			if not status then
				local str = runData.OnError.." "..ret
				print(str)
				Isaac.DebugString(str)
			end
		end
	end
end)

Mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
	RunLater = {}
end)