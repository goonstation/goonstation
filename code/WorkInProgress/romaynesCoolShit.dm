
/obj/item/devbutton
	name = "Romayne's Coding Button"
	desc = "What's it do? Who the fuck knows? Do you want to find out?"
	icon = 'icons/obj/items/bell.dmi'
	icon_state = "bell_kitchen"

/obj/item/devbutton/attack_self(mob/user)
	. = ..()
	playsound(src, 'sound/effects/bell_ring.ogg', 30, FALSE)
	// Code fuckery goes here
	src.explosion_data()

/// Used to get the data for a csv file of explosion ranges since thats cool.
/obj/item/devbutton/proc/explosion_data()

	// min_ / max_ : lowest / highest temp of a gas
	// step_ : increment of temperature per iteration
	// oxy: oxygen | tox: plasma
	// temp: temperature, NOT temporary

	var/min_oxy = 10
	var/max_oxy = 300
	var/step_oxy = 5

	var/min_tox = 10
	var/max_tox = 3000
	var/step_tox = 10

	var/step_total = (1 + ceil( (max_oxy - min_oxy) / step_oxy )) * (1 + ceil( (max_tox - min_tox) / step_tox ))
	var/oxy_temp = min_oxy
	var/tox_temp = min_tox

	var/list/bomb_data = new/list(step_total,3)
	var/list_iter = 1
	var/fname = "testing_[min_oxy]_[max_oxy]_[step_oxy]_[min_tox]_[max_tox]_[step_tox].csv"
	var/fpath = "data/[fname]"

	while(oxy_temp <= max_oxy)
		while(tox_temp <= max_tox)
			bomb_data[list_iter] = src.test_bomb(oxy_temp, tox_temp)
			list_iter += 1
			tox_temp += step_tox
		tox_temp = min_tox
		oxy_temp += step_oxy

	src.write_list_as_csv(fpath, list("oxy_temp", "tox_temp", "range"), bomb_data)

/// Write a list as a CSV with descriptors. Because I like it that way. WILL OVERWRITE EXISTING FILES
/obj/item/devbutton/proc/write_list_as_csv(var/fpath, var/list/descriptors, var/list/data)
	// Clear out / create file before appending
	rustg_file_write("",fpath)
	// Append csv's title
	var/descriptor_title = ""
	for (var/i in 1 to descriptors.len)
		descriptor_title += "[descriptors[i]]"
		if (i != descriptors.len)
			descriptor_title += ","
		else
			descriptor_title += "\n"

	rustg_file_append(descriptor_title,fpath)
	// Main bulk of it, append each line
	// byond no likey me get len of 2nd part of 2d list easily and me no want do big dumb
	// i expect csvs to populate all possible data if this isnt the case for what ur tryna do this is why
	var/length_inner = descriptors.len
	var/line_output
	for (var/i in 1 to data.len)
		line_output = ""
		for (var/j in 1 to length_inner)
			line_output += "[data[i][j]]"
			if (j != length_inner)
				line_output += ","
			else
				line_output += "\n"
		rustg_file_append(line_output,fpath)

/// Used to test a bomb safely and get the resultant explosion range
/obj/item/devbutton/proc/test_bomb(var/oxy_temp, var/tox_temp)
	return list(oxy_temp, tox_temp, 0) // stand-in value

/// Used to create tanks which react and explode at different speeds to test reaction speed shenanagains
/obj/item/devbutton/proc/mult_test(mob/user)

	var/obj/item/tank/imcoder/tank1 = new /obj/item/tank/imcoder()
	var/obj/item/tank/imcoder/tank2 = new /obj/item/tank/imcoder()
	var/obj/item/tank/imcoder/tank3 = new /obj/item/tank/imcoder()

	tank1.creator = user
	tank2.creator = user
	tank3.creator = user

	tank1.air_contents.toxins = 3 MOLES
	tank1.air_contents.oxygen = 24 MOLES
	tank1.air_contents.temperature = 500 KELVIN
	tank1.name = "Mult = 1"

	tank2.air_contents.toxins = 3 MOLES
	tank2.air_contents.oxygen = 24 MOLES
	tank2.air_contents.temperature = 500 KELVIN
	tank2.air_contents.test_mult = 2
	tank2.name = "Mult = 2"

	tank3.air_contents.toxins = 3 MOLES
	tank3.air_contents.oxygen = 24 MOLES
	tank3.air_contents.temperature = 500 KELVIN
	tank3.air_contents.test_mult = 0.5
	tank3.name = "Mult = 0.5"

	tank1.loc = user.loc
	tank2.loc = user.loc
	tank3.loc = user.loc
