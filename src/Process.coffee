
{ EventEmitter } = require "events"

Action = require "./Action"

Process = module.exports = (process) ->
	process ?= {}
	process.__proto__ = Process.prototype
	process.options = Action
		action: steal(process, "action")
		flags: steal(process, "flags") ? {}
		actions: steal(process, "actions") ? {}
	return process

Process.prototype =

	__proto__: EventEmitter.prototype

	stdout:
		write: ->

	exit: -> 
		throw Error "premature exit"

	parse: (argv) ->
		@flags = {}
		@args = []

		argv = Array::slice.call (argv ? @argv)
		
		@script = argv.splice 0, 2
		
		@actions = @_parseActions argv

		@_parseArgv argv

		action = @_currentAction ? @options

		if action.default? and @args.length is 0
			@args = action.default()

		action.finalizeFlags this

		action.action.call this if typeof action.action is "function"

		return this

	fatal: (message) ->
		@_write LINE, "Fatal Error".bold.red.underline, LINE, message, LINE, LINE
		@exit 1

Process.hidden =

	_currentAction: null

	_currentFlag: null

	_parseActions: (argv) ->
		# The command (script + actions...)
		command = []

		# The script
		script = @script[1]
		name = Path.basename script, Path.extname script
		if genericBasenames.indexOf(name) >= 0
			dir = Path.dirname script
			name = dir.slice dir.lastIndexOf("/") + 1
		command.push name if name.length > 0

		# The nested actions
		while argv.length > 0
			actionName = argv[0]
			{ error } = @_validateFlag actionName
			break unless error is "argument"
			action = (@_currentAction ? @options).actions[actionName]
			break if action is undefined
			@_currentAction = action
			command.push actionName
			argv.shift()

		return command

	_parseArgv: (argv) ->
		for arg in argv
			{ flagName, flag, error } = @_validateFlag arg
			switch error
				when "help" then @_giveHelp()
				when "argument" then @_handleArgument arg
				when undefined then @_handleFlag flagName, flag
		return

	_validateFlag: (flagName) ->

		@fatal "Invalid flag: null" if !flagName?
		action = @_currentAction ? @options
		flag = null

		if flagName.indexOf("--") is 0
			flagName = flagName.slice 2
			flag = action.flags[flagName]
			return { error: flagName } if flagName is "help"
			@fatal "Invalid flag: --#{flagName}" if !flag?
		
		else if flagName.indexOf("-") is 0
			shortFlag = flagName.slice 1
			flagName = action.flags.__short__[shortFlag]
			@fatal "Invalid flag: -#{shortFlag}" if !flagName?
			flag = action.flags[flagName]
			@fatal "Invalid flag: --#{flagName} (mapped from -#{shortFlag})" if !flag?

		else
			return { error: "argument" }

		return { flag, flagName }

	_handleFlag: (flagName, flag) ->
		if flag.args < 1
			@_currentFlag = null
			@flags[flagName] = true
		else
			@_currentFlag = flagName
			@flags[flagName] = [] if flag.args > 1

	_handleArgument: (arg) ->

		action = @_currentAction ? @options
		flagArgs = if @_currentFlag is null then 0 else action.flags[@_currentFlag].args

		switch flagArgs
			when 0
				@args.push arg
			when 1
				@flags[@_currentFlag] = arg
				@_currentFlag = null 
			else 
				@flags[@_currentFlag].push arg

		return

	_write: (messages...) ->
		@stdout.write messages.join ""

	_writeActionHelp: ->
		action = @options.actions[@actions[1]]
		@_write LINE, (SPACE 2), @actions.join(SPACE 1).bold, LINE
		@_writeHelp action.help, (SPACE 4)
		@_writeFlagsHelp action.flags, (SPACE 4)

	_writeModuleHelp: ->
		@_write LINE, @actions[0].bold.cyan, LINE
		@_writeHelp @help.cyan
		@_writeFlagsHelp @options.flags
		@_writeActionsHelp @options.actions

	_writeFlagsHelp: (flags, indent) ->
		indent = new Indentation indent
		indent.add (SPACE 4)
		@_write indent.value, "Valid flags:"
		indent.add (SPACE 4)
		if Object.keys(flags).length > 0
			@_writeFlagHelp flagName, flag, indent.initial for flagName, flag of flags
		else
			@_write LINE, indent.value, "No flags are supported.".cyan.dim, LINE

	_writeActionsHelp: (actions) ->
		@_write LINE, (SPACE 4), "Valid actions:", LINE, LINE
		if Object.keys(actions).length > 0
			@_writeActionHelp action, flags, (SPACE 4) for action, flags of actions
		else
			@_write LINE, (SPACE 6), "No actions are supported.".cyan.dim, LINE

	_writeActionHelp: (name, action, indent) ->
		indent = new Indentation indent
		indent.add (SPACE 4)
		@_write indent.value, name.bold.cyan, LINE
		hasHelp = false
		if action.help isnt undefined
			hasHelp = true
			@_writeHelp action.help.cyan, indent.value
		if Object.keys(action.flags).length > 0
			hasHelp = true
			@_writeFlagsHelp action.flags, indent.value
		if Object.keys(action.actions).length > 0
			hasHelp = true
			@_writeActionsHelp action.actions, indent.value

	_writeFlagHelp: (flagName, flag, indent) ->
		indent = new Indentation indent
		indent.add (SPACE 6)
		@_write LINE, indent.value, ("--" + flagName).bold.green
		@_write (", -" + flag.short).bold.green unless flag.short is undefined
		@_write LINE
		hasHelp = false
		indent.add (SPACE 2)
		if flag.help isnt undefined
			hasHelp = true
			@_writeHelp flag.help, indent.value
		if flag.example isnt undefined
			hasHelp = true
			@_write indent.value, "Example: ".dim, flag.example, LINE, LINE
		if flag.default isnt undefined
			hasHelp = true
			defalt = flag.default
			defalt = defalt.join " " if defalt instanceof Array
			@_write indent.value, "Default: ".dim, defalt, LINE
		if !hasHelp
			@_write indent.value, "This flag is undocumented. :(".dim

	_writeHelp: (help, indent) ->
		return if help is undefined
		indent ?= ""
		prefix = "\n" + indent
		help = help.join prefix if help instanceof Array
		@_write prefix, help.dim, LINE, LINE

	_giveHelp: ->
		{ actions } = @_currentAction ? @options
		commandCount = @actions.length
		action = @actions[commandCount > 1 ? commandCount : 1]
		if action? then @_writeActionHelp action, actions[action]
		else @_writeModuleHelp()
		@_write LINE
		@exit 1

#
# Internal
#

require "colors"

Path = require "path"

LINE = "\n"

SPACE = (x) -> 
	return "" if x < 1
	return [0..x].map((x) -> " ").join("")

genericBasenames = ["index", "bin"]

Indentation = (@initial) ->
	@initial ?= ""
	@value = @initial
	@add = -> @value += arguments[0]
	return this

addHiddenProperty = (obj, key, value) ->
	Object.defineProperty obj, key,
		value: value
		writable: true
		configurable: true
	return

addHiddenProperties = (obj, props) ->
	addHiddenProperty obj, key, prop for key, prop of props
	return

steal = (obj, key) ->
	value = obj[key]
	delete obj[key]
	return value

addHiddenProperties Process.prototype, steal(Process, "hidden")
