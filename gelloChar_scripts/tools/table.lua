local Mod = GelloCharMod

local TableTools = {}
GelloCharMod.TableTools = TableTools



function TableTools.Add(tab1, tab2)
	local tab1 = tab1 or {}
	local tab2 = tab2 or {}
	if type(tab1) ~= "table" then tab1 = {tab1} end
	if type(tab2) ~= "table" then tab2 = {tab2} end

	local newTab = {}
	for k, v in pairs({tab1, tab2}) do
		
	end
end


function TableTools.TableToArray(tab)
	local arr = {}
	for _, tabData in pairs(tab) do
		table.insert(arr, tabData)
	end
	return arr
end


function TableTools.Set(tab, value)
	local value = value or true
	if type(tab) ~= "table" then
		Mod:Error("in function : Set - argument 1 is not a table", 2)
		return {}
	end

	local newTab = {}
	for _, var in pairs(tab) do
		newTab[var] = value
	end
	return newTab
end

function TableTools.AddToSet(tab, tab2)
	if type(tab) ~= "table" then
		Mod:Error("in function : Set - argument 1 is not a table", 2)
		return {}
	end
	
	local value = true
	for _, v in pairs(tab) do
		value = v
		break
	end

	for _, var in pairs(tab2) do
		tab[var] = value
	end
	return tab
end



---@param arg		- number, string or function( )[return number or string]
---@param case		- table
---@param default	- nil, string, number or function
function TableTools.Switch(arg, case, default)
	if type(arg) == "function" then arg = arg() end
	if type(arg) ~= "number" and type(arg) ~= "string" then
		Mod:Error("Switch - argument 1 expected to be number or string not "..type(case), 2)
		return default or nil
	end
	if type(case) ~= "table" then
		Mod:Error("Switch - argument 2 expected to be table not "..type(case), 2)
		return default or nil
	end

	for c, ret in pairs(case) do
		if arg == c then
			return ret
		end
	end
	return default or nil
end



function TableTools.Copy(tab)
	local newTab = {}
	for tabName, tabData in pairs(tab) do
		if type(tabData) == "table" then
			newTab[tabName] = TableTools.Copy(tabData)
		else
			newTab[tabName] = tabData
		end
	end

	return newTab
end

function TableTools.CopyLite(tab)
	local newTab = {}
	for tabName, tabData in pairs(tab) do
		newTab[tabName] = tabData
	end

	return newTab
end

function TableTools.Remove(tab, remove)
	local newTab = {}
	local remove = remove
	if type(remove) ~= "table" then remove = {[remove] = true} end

	for tabName, tabData in pairs(tab) do
		if not remove[tabName] then
			if type(tabData) == "table" then
				newTab[tabName] = TableTools.Copy(tabData)
			else
				newTab[tabName] = tabData
			end
		end
	end

	return newTab
end



function TableTools.Map(tab, fun)
	local newTab = {}

	for tabName, tabData in pairs(tab) do
		if type(tabData) == "table" then
			newTab[tabName] = TableTools.Map(tabData, fun)
		elseif type(tabData) == "function" then
			newTab[tabName] = tabData
		else
			newTab[tabName] = fun(tabData)
		end
	end

	return newTab
end



function TableTools.GetRandomContent(content, RNG)
	local totalArr = 0
	local arr = {}
	for _, v in ipairs(content) do
		
		if type(v) == "table" then
			local w = (v.weight or v.Weight or 1)
			totalArr = totalArr + w

			table.insert(arr, { (v[1] or v["1"]), Weight = w})
		else
			totalArr = totalArr + 1
			table.insert(arr, { v, Weight = 1})
		end
	end

	local random
	if RNG then
		random = RNG:RandomFloat() * totalArr
	else
		random = Mod.RNG:RandomFloat() * totalArr
	end

	for i = 1, #arr do
		if arr[i].Weight >= random then
			return arr[i][1], i
		end
		random = random - arr[i].Weight
	end
	return arr[#arr][1], #arr
end


local SpecialTypes = {
	["int"] = function(number) return math.type(number) == "integer" end
}
local function check(varType, targetType, value)
	return SpecialTypes[targetType] and SpecialTypes[targetType](value) or varType == targetType
end
function TableTools.CheckTypes(tab, checkTab, throwError, errLvl)
	for key, value in pairs(tab) do
		local targetType = checkTab[key]
		local varType = type(value)
		local success = true

		if type(targetType) == "table" then
			local wasBreaked = false
			for _, tType in pairs(targetType) do
				targetType = tType
				if check(varType, targetType, value) then
					wasBreaked = true
					break
				end
			end

			if not wasBreaked then success = false end
		elseif targetType and not check(varType, targetType, value) then
			success = false
		end

		if not success then
			if type(targetType) == "table" then
				local strTargetType = ""
				for idx, str in pairs(targetType) do
					if idx == #targetType then
						strTargetType = strTargetType .." or ".. str
					elseif idx == 1 then
						strTargetType = str
					else
						strTargetType = strTargetType ..", ".. str
					end
				end
			end
			if throwError then
				Mod:Error("Key ".. tostring(key) .." expected type(s) (".. targetType .. ") got (".. varType ..")", (errLvl or 1)+1)
			end
			return false, {Key = key, TargetType = targetType, VarType = varType}
		end
	end
	return true
end



function TableTools.ToString(tab, separation)
	local newStr = ""
	local separation = separation or " "
	for i, str in pairs(tab) do
		if type(str) == "function" then
			str = tostring(str())
		end
		if type(str) == "table" then
			str = TableTools.ToString(str)
		end
		if type(str) ~= "string" then
			str = tostring(str)
		end
		
		newStr = newStr .. (i > 1 and separation or "") .. str
	end
	return newStr
end



function TableTools.Join(tab1, tab2)
	local tab = {}
	for _, cont in ipairs(tab1) do
		table.insert(tab, cont)
	end
	for _, cont in ipairs(tab2) do
		table.insert(tab, cont)
	end

	return tab
end

function TableTools.InnerJoin(tab1, tab2, fun)
	local checkTab = {}
	local tab = {}

	for _, cont in ipairs(tab1) do
		for _, cont2 in ipairs(tab2) do
			if not checkTab[cont] and cont == cont2 then
				checkTab[cont] = true
			end
		end
	end
	for cont, _ in pairs(checkTab) do
		table.insert(tab, cont)
	end

	return tab
end

function TableTools.JoinWithCond(tab1, tab2, fun)
	local tab = {}
	for _, cont in ipairs(tab1) do
		if fun(cont, tab1) then
			table.insert(tab, cont)
		end
	end
	for _, cont in ipairs(tab2) do
		if fun(cont, tab2) then
			table.insert(tab, cont)
		end
	end

	return tab
end

function TableTools.Exclude(tab1, fun)
	local tab = {}
	for _, cont in ipairs(tab1) do
		if fun(cont) then
			table.insert(tab, cont)
		end
	end

	return tab
end



function TableTools.ForEach(tab, fun)
	for i = 1, #tab do
		fun(tab[i], i)
	end
end

function TableTools.InvertedForEach(tab, fun)
	for i = #tab, 1, -1 do
		fun(tab[i], i)
	end
end



function TableTools.Shuffle(tab, rng)
	local newTab = TableTools.Copy(tab)
	if rng == nil then
		Mod:Error("Shuffle - argument 2 is nil", 2)
		return {}
	end

	for i = #newTab, 2, -1 do
		local j = rng:RandomInt(i) + 1
		newTab[i], newTab[j] = newTab[j], newTab[i]
	end
	return newTab
end


