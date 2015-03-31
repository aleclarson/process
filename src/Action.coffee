
Flag = require "./Flag"

Action = module.exports = (opts) ->
	action = {}
	action.__proto__ = Action.prototype
	action.name = opts.name
	action.action = opts.action
	action.actions = {}
	action.flags = {}
	Object.defineProperty action.flags, "__short__", { value: {} }
	action.help = opts.help
	action.example = opts.example
	action.default = opts.default
	# action.validate = opts.validate
	# action.transform = opts.transform
	action.addFlags opts.flags if opts.flags instanceof Object
	action.addActions opts.actions if opts.actions instanceof Object
	return action

Action.prototype =

	__proto__: Object.prototype

	addFlag: (name, options) ->
		options.name = name
		@flags[name] = Flag options
		if options.short? then @flags.__short__[options.short] = name
		return

	addFlags: (flags) ->
		@addFlag name, flag for name, flag of flags
		return

	addAction: (name, options) ->
		@actions[name] = Action options
		return

	addActions: (actions) ->
		@addAction name, action for name, action of actions
		return

	# Perform validation, apply default values, and transform final values.
	finalizeFlags: (process) ->
		flag.finalize process for name, flag of @flags
		return
