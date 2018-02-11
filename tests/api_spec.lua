package.path = '../../?.lua;' .. -- tests root
			   '../?.lua;' .. -- mod root
			   package.path

require("crafting/tests/dummy")
require("crafting/api")
local crafting = _G.crafting -- Suppress mutating global warning

local recipe1 = {
	type   = "test",
	output = "default:torch",
	items  = { "default:stick", "default:coal" },
	always_known = true,
}

local recipe2 = {
	type   = "test",
	output = "default:stone",
	items  = { "default:cobble" },
	always_known = true,
}

describe("Recipes and types", function()
	crafting.recipes = {}

	it("can register type", function()
		assert.is_nil(crafting.recipes["test"])
		crafting.register_type("test")
		assert.is_not_nil(crafting.recipes["test"])
	end)

	it("can register type", function()
		assert(not crafting.recipes["test"][1])
		crafting.register_recipe(recipe1)
		assert.is_not_nil(crafting.recipes["test"][1])
		assert.equals(crafting.recipes["test"][1].output, recipe1.output)
	end)
end)


describe("Getting all outputs", function()
	crafting.recipes = {}
	crafting.register_type("test")

	-- Recipe 1
	crafting.register_recipe(recipe1)
	assert.equals(#crafting.recipes["test"], 1)
	assert.equals(crafting.recipes["test"][1].output, recipe1.output)

	-- Recipe 2
	crafting.register_recipe(recipe2)
	assert.equals(#crafting.recipes["test"], 2)
	assert.equals(crafting.recipes["test"][1].output, recipe1.output)
	assert.equals(crafting.recipes["test"][2].output, recipe2.output)

	it("get with no items", function()
		local craftable, uncraftable = crafting.get_all("test", {}, {})
		assert.equals(0, #craftable)
		assert.equals(2, #uncraftable)

		assert.equals(recipe1, uncraftable[1])
		assert.equals(recipe2, uncraftable[2])
	end)

	it("get with right for one", function()
		local items_hash = {}
		items_hash["default:cobble"] = 1

		local craftable, uncraftable = crafting.get_all("test", items_hash, {})
		assert.equals(1, #craftable)
		assert.equals(1, #uncraftable)

		assert.equals(recipe2, craftable[1])
		assert.equals(recipe1, uncraftable[1])
	end)
end)