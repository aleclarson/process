
### process-type v0.1.0

`process-type` analyzes the `process.argv` array and provides support for:

&nbsp;&nbsp;
• flags (eg: `-g` or `--global`)

&nbsp;&nbsp;
• arguments (eg: the `arvgsus` in `npm install process-type`)

&nbsp;&nbsp;
• actions (eg: the `install` in `npm install process-type`)

&nbsp;&nbsp;
• documentation (eg: the special `--help` flag displays examples and descriptions)

The exported types are `Process`, `Process.Action`, and `Process.Flag`.

```Javascript
var Process = require("process-type")
```

-

### Glossary

&nbsp;&nbsp;&nbsp;&nbsp;
[Example](#example)

&nbsp;&nbsp;&nbsp;&nbsp;
[Installing](#installing)

&nbsp;&nbsp;&nbsp;&nbsp;
[Testing](#testing)

&nbsp;&nbsp;&nbsp;&nbsp;
**Types**

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
[Process](#process)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
[Process.Action](#processaction)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
[Process.Flag](#processflag)

-

### Example

This is the terminal input:

```Bash
$ node path/to/npm/bin.js install --global --nodedir path/to/node --force process-type
```

This is what `path/to/npm/bin.js` looks like:

```Javascript
process.help = ["The package manager for Node."]

process.flags = {
	version: {
		short: "v",
		args: 0,
		help: "Echoes the current version of NPM."
	}
}

process.actions = {
	install: {
		short: "i",
		help: "Install the dependencies in the local node_modules folder.",
		flag: {
			global: {
				short: "g",
				args: 0,
				help: "Installs the given dependencies into the global node_modules folder."
			}
		}
	}
}

Process = require("process-type")

Process(process).parse()
```

These are the new properties available after `parse()` is called:

```Javascript
process.script = [
	"node",
	"path/to/npm/bin.js"
]

process.actions = [
	"npm", 
	"install"
]

process.flags = {
	global: true,
	nodedir: "path/to/node",
	force: true
}

process.args = [
	"process-type"
]
```

-

### Installing

```Bash
npm i --save process-type
```

-

### Testing

To run the tests:

```Bash
grunt test
```

-

### Process

#### parse()

Arguments: (`ArrayOf(String)` or `Undefined`)

Once you wrap your `process` object with `Process()`, call `process.parse()` and you'll have full access to the properties listed here.

Normally, you won't pass an array of strings to this. Instead, the `process.argv` array will be used.

Before you call this, make sure you have `process.flags`, `process.actions`, `process.action`, and `process.help` all set to your liking.

#### help

Type: `String` or `ArrayOf(String)`

A description of your script.

This is shown when the `--help` flag is passed.

If an array of strings is passed, it is joined with `"\n"`.

#### flags

Type: `Object`

Before `process.parse()`: 

&nbsp;&nbsp;
The valid flag names and their option objects.

After `process.parse()`:

&nbsp;&nbsp;
The passed flag names and their arguments.

Learn more about [Process.Flag](#processflag).

#### actions

Type: `Object`

Before `process.parse()`: 

&nbsp;&nbsp;
The valid action names and their option objects.

After `process.parse()`: 

&nbsp;&nbsp;
No value.

Learn more about [Process.Action](#processaction).

#### options

Type: `Object`

Contains the values of `process.flags` and `process.actions` before `process.parse()` was called.

#### command

Type: `ArrayOf(String)`

#### script

Type: `ArrayOf(String)`

The command used to run this script. (eg: `node path/to/my-module/index.js`)

-

### Process.Action

**Note:** You'll never have to construct one of these on your own. Instead, use `process.options.addAction` or define `process.actions` before `process.parse()`.

#### name

Type: `String`

The ID that must be specified to use this `Action`.

#### help

Type: `ArrayOf(String)`

Describes what this `Action` is used for.

#### example

Type: `String`

Describes how to use this `Action`.

#### action

Type: `Function`

Called when the `Action` is specified in the command.

This option is essential when separating `Action`s into their own modules.

#### actions

Type: `Object`

The actions that can be specified after this `Action`.

#### flags

Type: `Object`

The flags that can be specified with this `Action`.

#### default

**Note:** This is *implemented*, but not yet *documented*.

#### validate

**Note:** This is not yet *implemented*.

#### transform

**Note:** This is not yet *implemented*.

-

### Process.Flag

**Note:** You'll never have to construct one of these on your own. Instead, use `process.options.addFlag` or define `process.flags` before `process.parse()`.

#### name

Type: `String`

The ID that must be specified to use this `Flag`.

#### short

Type: `String`

Maps a single-letter flag (eg: `-f`) to a many-letter flag (eg: `--force`).

#### help

Type: `ArrayOf(String)`

Describes what this `Flag` is used for.

#### example

Type: `String`

Describes how to use this `Flag`.

#### default

Type: `Function`

Returns the default arguments for this `Flag`.

Called when this `Flag` has no specified arguments.

Can be `undefined`. 

#### validate

Type: `Function`

Verifies whether this `Flag`'s arguments are valid by returning `true` or `false`. 

Can be `undefined`.

**Note**: Called before the default value is applied to the `Flag`.

#### transform

Type: `Function`

Mutates this `Flag`'s arguments and returns a new value.

Can be `undefined`.

**Note**: Called after the default value is applied to this `Flag`.

#### args

Type: `Number`

The maximum number of arguments possibly associated with this `Flag`.
