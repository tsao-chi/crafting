unused_args = false
allow_defined_top = true

globals = {
	"crafting",
}

read_globals = {
	"minetest",
	string = {fields = {"split"}},
	table = {fields = {"copy", "getn"}},
	"vector", "default",
	"ItemStack",

	"sfinv",

	-- Testing
	"describe",
	"it",
}
