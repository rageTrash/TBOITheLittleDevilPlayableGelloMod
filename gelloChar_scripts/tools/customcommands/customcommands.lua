local VERSION = 2.32
local YOUR_MOD = GelloCharMod
---- Custom commands Library
CustomCommands = CustomCommands or {}



if CustomCommands.Mod == nil then CustomCommands.Mod = YOUR_MOD end
-- Check if was already loaded
if CustomCommands.Version and CustomCommands.Version <= VERSION then return end




CustomCommands.Version = VERSION
CustomCommands.Table = CustomCommands.Table or {}

CustomCommands.ArgType = CustomCommands.ArgType or { ["String"] = "string", ["Number"] = "num", ["Boolean"] = "bool" }
CustomCommands.OptArg = CustomCommands.OptArg or true


local function trueArgs(args)
    local arg_table = {}
    
    for i in string.gmatch(args, "%S+") do
        table.insert(arg_table, i)
    end
    
    return arg_table
end


---@param modName		- string 	- mod name
---@param name 			- string 	- command name
---@param args 			- table 	- types of arguments - arguments can be set to be optional
---@param func 			- function 	- what execute the command
---@param description 	- string 	- description of the command (optional)
---@param parent 		- string 	- parent command (optional)
function CustomCommands:AddCommand(modName, name, args, func, description, parent)
	CustomCommands.Table[modName] = CustomCommands.Table[modName] or {}

	local parent = parent or ""
	local parent_name = parent
	if parent ~= "" then
		if CustomCommands.Table[modName][parent] == nil then
			local errorString = "Parent command "..parent.." for ".. name.." doesn't exist"
			print(errorString)
			Isaac.DebugString(errorString)
			return
		end
		table.insert(CustomCommands.Table[modName][parent].childs, {name = name, arguments = args, description = description})
		parent = parent .. "."
	end

	CustomCommands.Table[modName][parent..name] = {
		name = name,
		arguments = args,
		execute = func,
		description = description,
		parent = parent_name,
		childs = {},
	}
end


---@param modName		- string 	- mod name
---@return table ( List of Commands ), bool ( It has Commands? )
function CustomCommands:GetModCommands(modName)
	return CustomCommands.Table[modName] or {}, CustomCommands.Table[modName] ~= nil
end


---@param modName		- string 	- mod name
---@param modName		- string 	- mod name
---@return table or nil ( Command info ), bool ( It exists? )
function CustomCommands:GetCommand(modName, name)
	return CustomCommands:GetModCommands(modName)[name], CustomCommands:GetModCommands(modName)[name] ~= nil
end


CustomCommands:AddCommand("CustomCommand", "Help",
	{	
		{CustomCommands.ArgType.String},
		{
			CustomCommands.ArgType.String,
			opt = "true"
		},
	},
	function(modName, name)
		local helpString = "Need help on a command?. use : CustomCommand Help + 'Mod name' + 'Command name' to get more information"
		local modName, Exists = CustomCommands:GetModCommands(ModName)
		if not Exists then
			for modName,_ in pairs(CustomCommands.Table) do
				print(modName)
			end
			print(helpString)
			return
		end
		if name == nil then
			for i, command in pairs(CustomCommands:GetModCommands(modName)) do
				if command.parent == "" then
					print(command.name)
				end
			end
			print(helpString)
			return
		end

		local command = CustomCommands:GetCommand(modName, name)
		if command == nil then
			print("Error Command doesn't exits")
			return
		end

		local command_args = command.arguments
		local print_desc = ""
		local command_childs = command.childs

		if command.description ~= nil then
			print_desc = command.description
		end

		print("Name: ".. command.name)
		
		if #command_args > 0 then
			print("Arguments:")
			for i = 1, #command_args do
				local is_optional = ""
				if command_args[i].opt == true or command_args[i].opt == "true" then
					is_optional = "(opt)"
				end
				print("   "..command_args[i].type .. is_optional) 
			end
		end
		
		if print_desc ~= "" then
			print("Description: ".. print_desc)
		end

		if command.parent ~= "" then
			print("Parent Command: "..command.parent)
		end

		if #command_childs > 0 then
			print("Childs Command:")
			for i, command_child in pairs(command_childs) do
				print("   "..command_child.name)
			end
		end
	end,
	"Returns Command info"
)

CustomCommands:AddCommand("CustomCommand", "Description",
	{
		{CustomCommands.ArgType.String},
		{CustomCommands.ArgType.String},
	},
	function(modName, name)
		local modName, Exists = CustomCommands:GetModCommands(ModName)
		if not Exists then
			print("Error Mod Name is invalid")
			return
		end

		local command = CustomCommands:GetCommand(modName, name)
		if command.description == nil then
			print("Error Command has no description")
			return
		end
		print(command.description)
	end,
	"Returns Command description",
	"Help"
)

CustomCommands:AddCommand("CustomCommand", "Arguments",
	{
		{CustomCommands.ArgType.String},
		{CustomCommands.ArgType.String},
	},
	function(modName, name)
		local modName, Exists = CustomCommands:GetModCommands(ModName)
		if not Exists then
			print("Error Mod Name is invalid")
			return
		end

		local command = CustomCommands:GetCommand(modName, name)
		if command.type == nil then
			print("Command has no arguments")
			return
		end
		local command_args = command.arguments
		local print_arg = ""
		for i = 1, #command_args do
			print_arg = tostring(print_arg .. command_args[i].type .. " ") 
		end
		print(print_arg)
	end,
	"Returns the Command arguments",
	"Help"
)

CustomCommands:AddCommand("CustomCommand", "ChildCommands",
	{},
	function ()
		print("Childs Command are command that are atach to other commands")
		print("You used like this:")
		print("     'Mod Name' Help.Arguments Help")
		print("This command will return the arguments of the command 'Help'")
	end,
	"Explains what is Childs Command"
)

CustomCommands:AddCommand("CustomCommand", "OptionalArguments",
	{},
	function ()
		print("Optional Arguments (or opt args), are arguments that aren't obligatory to make the command funtional")
		print("This Argument are marked in 'Help.Arguments' or in 'Help' like (opt)")
	end,
	"Explains what is Optional Arguments"
)

CustomCommands:AddCommand("CustomCommand", "CommandsList",
	{
		{CustomCommands.ArgType.String},
	},
	function(modName)
		local commands = CustomCommands:GetModCommands(modName)
		if not commands then
			print(modName.." is not registed")
			return
		end

		for i, command in pairs(commands) do
			if command.parent == "" then
				print(command.name)
			end
		end
	end,
	"Give a list of the main commands"
)

CustomCommands:AddCommand("CustomCommand", "RegisterMods",
	{},
	function()
		for i, command in pairs(CustomCommands) do
			print(command.name)
		end
	end,
	"Give a list of all the mods that have commands"
)


local function RunCommands(_, ModName, args)
	if CustomCommands.Version < VERSION then
		CustomCommands.Mod:RemoveCallback(ModCallbacks.MC_EXECUTE_CMD, RunCommands)
		return
	end
	
	local args = trueArgs(args)
	local run_command = true
	local count = 1

	
	local ModCommands, Exists = CustomCommands:GetModCommands(ModName)

	if not Exists then return end

	local CommandName = args[1]
	table.remove(args, 1)
	local Command, Exists = CustomCommands:GetCommand(ModName, CommandName)

	if not Exists then
		print("Command "..ModName.." "..CommandName.." doesn't exits")
		print("If you need help type 'CustomCommand Help' for more information")
		return
	end


	local min_args = 0
	if Command.arguments then
		for i, arg in pairs(Command.arguments) do
			if not (arg.opt == true or arg.opt == "true") then
				min_args = min_args +1
			end
		end
	end

	if min_args > #args then
		print("To little arguments")
		return
	elseif #Command.arguments < #args then
		print("To many arguments")
		return
	end



	for i, arg in pairs(args) do
		
		if arg ~= nil and (Command.arguments[i][1] == "bool" or Command.arguments[i][1] == "boolean") then
			if arg == "true" or arg == true then
				arg = true
			elseif arg == "false" or arg == false then
				arg = false
			else
				arg = nil
			end
		elseif arg ~= nil and (Command.arguments[i][1] == "num" or Command.arguments[i][1] == "number") then
			arg = tonumber(arg)
		elseif arg ~= nil and Command.arguments[i][1] == "string" then
			arg = tostring(arg)
		elseif Command.arguments[i].opt ~= true or Command.arguments[i].opt ~= "true" then
			arg = nil
		end
		
		if arg == nil then
			print("Error running Command ["..Command.name.."]: Argument #"..i.." is invalid")
			return
		end

		args[i] = arg
	end

	Command.execute(table.unpack(args))
end
CustomCommands.Mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, RunCommands)

---- why i put much effort in this :skul: ----