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


sfinv.override_page("sfinv:crafting", {
	get = function(self, player, context)
		local formspec = crafting.make_result_selector(player, "inv", 1, { x = 8, y = 3 }, context)
		formspec = formspec .. "list[detached:creative_trash;main;0,3.4;1,1;]" ..
				"image[0.05,3.5;0.8,0.8;creative_trash_icon.png]"
		return sfinv.make_formspec(player, context, formspec, true)
	end,
	on_player_receive_fields = function(self, player, context, fields)
		if crafting.result_select_on_receive_results(player, "inv", 1, context, fields) then
			sfinv.set_player_inventory_formspec(player)
		end
		return true
	end
})

minetest.register_node("crafting:work_bench", {
	description = "Work Bench",
	groups = { snappy = 1 },
	on_rightclick = crafting.make_on_rightclick("inv", 2, { x = 8, y = 3 }),
})