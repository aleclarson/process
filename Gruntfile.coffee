
grunt = null

tasks = {}

tasks.default = ["test", "watch"]



tasks.test = ->
	testers = []

	Tester = (opts) ->

		args = ["/usr/local/bin/coffee", "test.coffee"]

		args.unshift "--debug-brk" unless opts.debug?

		tester = grunt.util.spawn
			cmd: "node"
			args: args
			opts: if opts.debug? then { stdio: "inherit" } else undefined

		process.on "exit", tester.kill

	Tester { debug: true }
	Tester { debug: false }


	process.on "SIGINT", -> 
		process.exit 1

config =

	shell:
		test:
			command: "node --debug "

	watch:
		coffee:
			files: ["src/**", "spec/**"]
			tasks: ["test"]

module.exports = ->
	grunt = arguments[0]
	grunt.option "stack", true
	require("load-grunt-tasks") grunt
	grunt.initConfig config
	grunt.registerTask name, subtasks for name, subtasks of tasks
	return
