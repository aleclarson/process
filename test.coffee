
domain = require("domain").create()

domain.on "error", (error) ->
	console.log "domain.on('error')"
	debugger

try
	domain.run ->
		jasmine = require "jasmine-node"
		jasmine.executeSpecsInFolder {
			specFolders: ["spec/"]
			regExpSpec: /\.(coffee)$/i
			isVerbose: true
			showColors: true
			includeStackTrace: true
			onComplete: ->
				console.log "jasmine.onComplete()"
				debugger
		}, (error) ->
			if error?
				console.log "jasmine.onError()"
				debugger
catch error
	console.log "try-catch()"
	debugger
