-- Crafting Mod - semi-realistic crafting in minetest
-- Copyright (C) 2018 rubenwardy <rw@rubenwardy.com>
--
-- This library is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- This library is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA


crafting = {
	recipes = {},
	recipes_by_id = {},
}

function crafting.register_type(name)
	crafting.recipes[name] = {}
end

local recipe_counter = 0
function crafting.register_recipe(def)
	assert(def.output, "Output needed in recipe definition")
	assert(def.type,   "Type needed in recipe definition")
	assert(def.items,  "Items needed in recipe definition")

	local tab = crafting.recipes[def.type]
	assert(tab,        "Unknown craft type " .. def.type)

	recipe_counter = recipe_counter + 1
	def.id = recipe_counter
	crafting.recipes_by_id[recipe_counter] = def
	tab[#tab + 1] = def
end

function crafting.get_recipe(id)
	return crafting.recipes_by_id[id]
end

function crafting.get_all(type, item_hash, unlocked)
	assert(crafting.recipes[type], "No such craft type!")

	local ret_craftable   = {}
	local ret_uncraftable = {}

	for _, recipe in pairs(crafting.recipes[type]) do
		local craftable = true

		if recipe.always_known or unlocked[recipe.output] then
			-- Check all ingredients are available
			local items = {}
			for _, item in pairs(recipe.items) do
				item = ItemStack(item)
				local needed_count = item:get_count()

				local available_count = item_hash[item:get_name()] or 0
				if available_count < needed_count then
					craftable = false
				end

				items[#items + 1] = {
					name = item:get_name(),
					have = available_count,
					need = needed_count,
				}
			end

			if craftable then
				ret_craftable[#ret_craftable + 1] = {
					recipe = recipe,
					items  = items,
				}
			else
				ret_uncraftable[#ret_uncraftable + 1] = {
					recipe = recipe,
					items  = items,
				}
			end
		end
	end

	return ret_craftable, ret_uncraftable
end

function crafting.get_all_for_player(player, type)
	local unlocked = {}   -- TODO

	-- Get items hashed
	local item_hash = {}
	local inv = player:get_inventory()
	for _, stack in pairs(inv:get_list("main")) do
		if not stack:is_empty() then
			local itemname = stack:get_name()
			item_hash[itemname] = (item_hash[itemname] or 0) + stack:get_count()

			local def = minetest.registered_items[itemname]
			if def.groups then
				for _, group in pairs(def.groups) do
					local groupname = "group:" .. group
					item_hash[groupname] = (item_hash[groupname] or 0) + stack:get_count()
				end
			end
		end
	end

	return crafting.get_all(type, item_hash, unlocked)
end

local function give_all_to_player(inv, list)
	for _, item in pairs(list) do
		inv:add_item("main", item)
	end
end

function crafting.has_required_items(inv, recipe)
	for _, item in pairs(recipe.items) do
		item = ItemStack(item)
		if item:get_name():sub(1, 6) == "group:" then
			minetest.log("error", "Unimplemented: group support")
			return false
		else
			if not inv:contains_item("main", item) then
				return false
			end
		end
	end

	return true
end

function crafting.perform_craft(inv, recipe)
	-- Take items
	local taken = {}
	for _, item in pairs(recipe.items) do
		item = ItemStack(item)
		if item:get_name():sub(1, 6) == "group:" then
			minetest.log("error", "Unimplemented: group support")
			give_all_to_player(inv, taken)
			return false
		else
			local took = inv:remove_item("main", item)
			if took:get_count() ~= item:get_count() then
				minetest.log("error", "Unexpected lack of items in inventory")
				give_all_to_player(inv, taken)
				return false
			end
		end
	end

	-- Add output
	inv:add_item("main", recipe.output)

	return true
end
