local Mod = GelloCharMod

ForcePlayerCostumeOrSomething = ForcePlayerCostumeOrSomething or {}
ForcePlayerCostumeOrSomething.CostumeTable = ForcePlayerCostumeOrSomething.CostumeTable or {}
ForcePlayerCostumeOrSomething.SkinTable = ForcePlayerCostumeOrSomething.SkinTable or {}
ForcePlayerCostumeOrSomething.Mod = ForcePlayerCostumeOrSomething.Mod or Mod

if not ForcePlayerCostumeOrSomething.AddCharacterCostume then
	function ForcePlayerCostumeOrSomething:AddCharacterCostume(charID, costume, skin)
		ForcePlayerCostumeOrSomething.CostumeTable[charID] = ForcePlayerCostumeOrSomething.CostumeTable[charID] or {}
		if type(costume) ~= "table" then costume = {costume} end
		for _, c in pairs(costume) do
			table.insert(ForcePlayerCostumeOrSomething.CostumeTable[charID], c)
		end
		ForcePlayerCostumeOrSomething.SkinTable[charID] = skin
	end
end

if not ForcePlayerCostumeOrSomething.FunUpdate then---- base of Epiphany again ----

	function ForcePlayerCostumeOrSomething:FunUpdate(player)
		local SkinTable = ForcePlayerCostumeOrSomething.SkinTable
		local CostumeTable = ForcePlayerCostumeOrSomething.CostumeTable

		local pType = player:GetPlayerType()
		local sprite = player:GetSprite()
		local costumeData = player:GetData().ForcePlayerCostumeOrSomething_Data or {}
		local Last_pType = costumeData.Last_pType
		local coopGhost = costumeData.IsCoopGhost


		if Last_pType and pType ~= Last_pType and (SkinTable[pType] or SkinTable[Last_pType]) then
			player:ChangePlayerType(pType)
			local path = SkinTable[pType] or sprite:GetFilename()
			sprite:Load(path, true)

			costumeData.Update = true
		end
		costumeData.Last_pType = pType


		if coopGhost ~= player:IsCoopGhost() and SkinTable[pType] then costumeData.Update = true end
		if coopGhost and not player:IsCoopGhost() and SkinTable[pType] then sprite:Load(SkinTable[pType], true) end
		costumeData.IsCoopGhost = player:IsCoopGhost()


		if costumeData.Update then
			if CostumeTable[pType] ~= nil then
				for _, costume in pairs(CostumeTable[pType]) do
					player:TryRemoveNullCostume(costume)
				end
			end

			if CostumeTable[Last_pType] ~= nil then
				for _, costume in pairs(CostumeTable[Last_pType]) do
					player:TryRemoveNullCostume(costume)
				end
			end

			costumeData.Update = false
			costumeData.HasCostume = false
		end

		if CostumeTable[pType] ~= nil and not costumeData.HasCostume then
			for _, costume in pairs(CostumeTable[pType]) do
				player:AddNullCostume(costume)
			end

			costumeData.HasCostume = true
		end
		player:GetData().ForcePlayerCostumeOrSomething_Data = costumeData
	end

	Mod:AddPriorityCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, CallbackPriority.LATE, ForcePlayerCostumeOrSomething.FunUpdate)
end

if not ForcePlayerCostumeOrSomething.FunUseItem then
	function ForcePlayerCostumeOrSomething:FunUseItem(item, rng, player)
		local costumeData = player:GetData().ForcePlayerCostumeOrSomething_Data or {}
		costumeData.Update = true
		player:GetData().ForcePlayerCostumeOrSomething_Data = costumeData
	end
	Mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, ForcePlayerCostumeOrSomething.FunUseItem, CollectibleType.COLLECTIBLE_D4)
end


if not ForcePlayerCostumeOrSomething.FunNewRoom then
	function ForcePlayerCostumeOrSomething:FunNewRoom()
		Mod.PlayerTools.ForEach(function(player)
			local pType = player:GetPlayerType()
			local costumeData = player:GetData().ForcePlayerCostumeOrSomething_Data or {}
			costumeData.Update = true
			player:GetData().ForcePlayerCostumeOrSomething_Data = costumeData

			if player:HasCurseMistEffect() and ForcePlayerCostumeOrSomething.SkinTable[pType] then
				player:GetSprite():Load(ForcePlayerCostumeOrSomething.SkinTable[pType], true)
			end
		end)
	end
	Mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.LATE, ForcePlayerCostumeOrSomething.FunNewRoom)
end
