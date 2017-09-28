package = "interlu"
version = "scm-1"
source = {
	url = "git+https://github.com/raingloom/interlu.git"
}
description = {
	summary = "A (mostly) pure Lua REPL that replicates (pun intended) the one by PUC Rio.",
	homepage = "https://github.com/raingloom/interlu",
	license = "MIT",
	detailed = [[interlu is a simple module that provides you with a REPL that works like the one the terrific guys at PUC Rio made, while being more dynamic. interlu lets you do things like wrap it in a custom environment, include it in an existing application or set a custom error handler, which was my original reason for writing it.]],
	maintainer = "github.com/raingloom",
	issues_url = "https://github.com/raingloom/interlu/issues",
	labels = { "repl", "readline", "command line", "cli" },
}
dependencies = {
	"lua >= 5.3",
	"readline",
}
build = {
	type = "builtin",
	modules = {
		interlu = "init.lua",
	},
}
