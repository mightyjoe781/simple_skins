
-- Simple Skins mod for minetest
-- Adds a simple skin selector to the inventory by using
-- the default sfinv or inventory_plus when running.
-- Released by TenPlus1 and based on Zeg9's code under MIT license

skins = {
	skins = {}, list = {}, meta = {},
	modpath = minetest.get_modpath("simple_skins"),
	invplus = minetest.get_modpath("inventory_plus"),
	sfinv = minetest.get_modpath("sfinv"),
	file = minetest.get_worldpath() .. "/simple_skins.mt",
	formspec = {},
}


-- Load support for intllib.
local S, NS = dofile(skins.modpath .. "/intllib.lua")


-- load skin list and metadata
local id, f, data, skin = 1

while true do

	skin = "character_" .. id

	-- does skin file exist ?
	f = io.open(skins.modpath .. "/textures/" .. skin .. ".png")

	-- escape loop if not found and remove last entry
	if not f then
		skins.list[id] = nil
		id = id - 1
		break
	end

	f:close()
	table.insert(skins.list, skin)

	-- does metadata exist for that skin file ?
	f = io.open(skins.modpath .. "/meta/" .. skin .. ".txt")

	if f then
		data = minetest.deserialize("return {" .. f:read('*all') .. "}")
		f:close()
	end

	-- add metadata to list
	skins.meta[skin] = {
		name = data and data.name or "",
		author = data and data.author or "",
	}

	id = id + 1
end


-- load player skins file for backwards compatibility
local input = io.open(skins.file, "r")
local data = nil

if input then
	data = input:read('*all')
	io.close(input)
end

if data and data ~= "" then

	local lines = string.split(data, "\n")

	for _, line in pairs(lines) do
		data = string.split(line, " ", 2)
		skins.skins[data[1]] = data[2]
	end
end


-- create formspec for skin selection page
skins.formspec.main = function(name)

	local formspec = ""

	if skins.invplus then
		formspec = "size[8,8.6]"
			.. "bgcolor[#08080822;true]"
	end

	formspec = formspec .. "label[.5,2;" .. S("Select Player Skin:") .. "]"
		.. "textlist[.5,2.5;6.8,6;skins_set;"

	local meta
	local selected = 1

	for i = 1, #skins.list do

		formspec = formspec .. skins.meta[ skins.list[i] ].name

		if skins.skins[name] == skins.list[i] then
			selected = i
			meta = skins.meta[ skins.skins[name] ]
		end

		if i < #skins.list then
			formspec = formspec ..","
		end
	end

	if skins.invplus then
		formspec = formspec .. ";" .. selected .. ";true]"
	else
		formspec = formspec .. ";" .. selected .. ";false]"
	end

	if meta then
		if meta.name then
			formspec = formspec .. "label[2,.5;" .. S("Name: ") .. meta.name .. "]"
		end
		if meta.author then
			formspec = formspec .. "label[2,1;" .. S("Author: ") .. meta.author .. "]"
		end
	end

	return formspec
end


-- update player skin
skins.update_player_skin = function(player)

	if not player then
		return
	end

	local name = player:get_player_name()

	default.player_set_textures(player, skins.skins[name] .. ".png")
end


-- register sfinv tab when inv+ not active
if skins.sfinv and not skins.invplus then

sfinv.register_page("skins:skins", {title = "Skins",

	get = function(self, player, context)
		local name = player:get_player_name()
		return sfinv.make_formspec(player, context,skins.formspec.main(name))
	end,

	on_player_receive_fields = function(self, player, context, fields)

		local event = minetest.explode_textlist_event(fields["skins_set"])

		if event.type == "CHG" then

			local index = event.index

			if index > id then index = id end

			local name = player:get_player_name()

			skins.skins[name] = skins.list[index]

			skins.update_player_skin(player)

			player:set_attribute("simple_skins:skin", skins.skins[name])

			sfinv.override_page("skins:skins", {
				get = function(self, player, context)
					local name = player:get_player_name()
					return sfinv.make_formspec(player, context,
							skins.formspec.main(name))
				end,
			})

			sfinv.set_player_inventory_formspec(player)
		end
	end,
})

end


-- load player skin on join
minetest.register_on_joinplayer(function(player)

	local name = player:get_player_name()
	local skin = player:get_attribute("simple_skins:skin")

	-- do we already have a skin in player attributes?
	if skin then
		skins.skins[name] = skin

	-- otherwise use skin from simple_skins.mt file or default if not set
	elseif not skins.skins[name] then
		skins.skins[name] = "character_1"
	end

	skins.update_player_skin(player)

	if skins.invplus then
		inventory_plus.register_button(player,"skins", "Skin")
	end
end)


-- formspec control for inventory_plus
minetest.register_on_player_receive_fields(function(player, formname, fields)

	if skins.sfinv and not skins.invplus then
		return
	end

	local name = player:get_player_name()

	if fields.skins then
		inventory_plus.set_inventory_formspec(player,
				skins.formspec.main(name) .. "button[0,.75;2,.5;main;Back]")
	end

	local event = minetest.explode_textlist_event(fields["skins_set"])

	if event.type == "CHG" then

		local index = math.min(event.index, id)

		if not skins.list[index] then
			return -- Do not update wrong skin number
		end

		skins.skins[name] = skins.list[index]

		if skins.invplus then
			inventory_plus.set_inventory_formspec(player,
					skins.formspec.main(name) .. "button[0,.75;2,.5;main;Back]")
		end

		skins.update_player_skin(player)

		player:set_attribute("simple_skins:skin", skins.skins[name])
	end
end)


-- admin command to set player skin (usually for custom skins)
minetest.register_chatcommand("setskin", {
	params = "<player> <skin number>",
	description = S("Admin command to set player skin"),
	privs = {server = true},
	func = function(name, param)

		local playername, skin = string.match(param, "([^ ]+) (-?%d+)")

		if not playername or not skin then
			return false, S("** Insufficient or wrong parameters")
		end

		local player = minetest.get_player_by_name(playername)

		if not player then
			return false, S("** Player @1 not online!", playername)
		end

		-- this check is only used when custom skins aren't in use
--		if not skins.list[tonumber(skin)] then
--			return false, S("** Invalid skin number (max value is @1)", id)
--		end

		skins.skins[playername] = "character_" .. tonumber(skin)

		skins.update_player_skin(player)

		player:set_attribute("simple_skins:skin", skins.skins[playername])

		minetest.chat_send_player(playername,
				S("Your skin has been set to") .. " character_" .. skin)

		return true, "** " .. playername .. S("'s skin set to")
				.. " character_" .. skin .. ".png"
	end,
})


print (S("[MOD] Simple Skins loaded"))
