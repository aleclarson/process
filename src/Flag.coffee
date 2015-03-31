
Flag = module.exports = (opts) ->
	flag = {}
	flag.__proto__ = Flag.prototype
	flag.name = opts.name
	flag.short = opts.short
	flag.help = opts.help
	flag.example = opts.example
	flag.default = opts.default
	flag.validate = opts.validate
	flag.transform = opts.transform
	flag.args = opts.args ? Infinity
	return flag

Flag.prototype =

	__proto__: Object.prototype

	finalize: (process) ->
		
		# Validate value
		if typeof @validate is "function"
			result = @validate process.flags[@name]
			if result isnt true
				message = "Validation failed:".yellow.dim + "--#{@name}".bold
				message += "\n#{result}".gray if typeof result is "string"
				process.fatal message

		# Default value
		if @default? and process.flags[@name] is undefined
			process.flags[@name] = @default()
		
		# Transform value
		if typeof @transform is "function"
			process.flags[@name] = @transform process.flags[@name]

		return
