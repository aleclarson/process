
describe "Process", ->

	{ Process } = require "./../index"

	Argv = (args...) -> ["karma", "npm/bin.js"].concat args

	test = (result) -> expect(result).toBe(true)

	describe "parse()", ->

		it "supports long flags", ->
			process = Process
				argv: Argv "--foo"
				flags:
					foo: {}
			process.parse()
			test process.flags instanceof Object
			test process.flags.foo?

		it "supports arguments without flags", ->
			process = Process
				argv: Argv "a", "b", "c"
			process.parse()
			test process.args instanceof Array
			expect(process.args).toEqual(process.argv.slice 2)

		it "supports short flags", ->
			process = Process
				argv: Argv "-f"
				flags:
					force:
						short: "f"
			process.parse()
			test process.flags.force?

		it "throws an error if short flag does not exist", ->
			try
				Process().parse Argv "-f"
			catch error
				test error?

		it "throws an error if long flag does not exist", ->
			try 
				Process().parse Argv "--force"
			catch error
				test error?

		it "supports flags without arguments", ->
			process = Process
				argv: Argv "--global", "Process"
				flags:
					global:
						args: 0
			process.parse()
			test process.flags.global is true
			test process.args[0] is process.argv[3]

		it "supports flags with one argument", ->
			process = Process
				argv: Argv "--nodedir", "path/to/node", "Process"
				flags:
					nodedir:
						args: 1
			process.parse()
			test typeof process.flags.nodedir is "string"

		it "supports flags with multiple arguments", ->
			process = Process
				argv: Argv "--exclude", "**/*.js", "**/*-test.coffee", "--global"
				flags:
					exclude: {}
					global: {}
			process.parse()
			test process.flags.exclude instanceof Array
			test process.flags.exclude.length is 2

		it "supports actions", ->
			process = Process
				argv: Argv "install"
				actions:
					install: {}
			process.parse()
			test process.actions[1] is process.argv[2]

		it "supports actions with flags", ->
			process = Process
				argv: Argv("install", "--global")
				actions:
					install:
						flags:
							global: {}
			process.parse()
			test process.actions[1] is process.argv[2]

		it "supports actions with arguments", ->
			process = Process
				argv: Argv("install", "Process")
				actions:
					install: {}
			process.parse()
			test process.actions.length is 2
			test process.args.length is 1

		it "supports nested actions", ->
			process = Process
				argv: Argv "remote", "add"
				actions:
					remote:
						actions:
							add: {}
			process.parse()
			test process.actions[1] is process.argv[2]
			test process.actions[2] is process.argv[3]

		it "supports action callbacks", ->
			process = Process
				argv: Argv()
				action: ->
			spyOn process.options, "action"
			process.parse()
			test process.options.action.calls.any()

		it "supports default values for flag arguments", ->
			process = Process
				argv: Argv()
				flags:
					directory:
						default: -> "/"
			process.parse()
			test process.flags.directory is process.options.flags.directory.default()

		it "supports default values for action arguments", ->
			process = Process
				argv: Argv "install"
				actions:
					install:
						flags:
							directory:
								default: -> "/"
			process.parse()
			test process.flags.directory is process.options.actions.install.flags.directory.default()
