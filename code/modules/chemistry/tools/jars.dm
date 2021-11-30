
/* ============================================== */
/* -------------------- Jars -------------------- */
/* ============================================== */

/obj/item/reagent_containers/glass/jar
	name = "glass jar"

	icon = 'icons/obj/chemical.dmi'
	icon_state = "mason_jar"
	uses_multiple_icon_states = 1
	item_state = "beaker"
	initial_volume = 75
	var/image/color_underlay = null
	rc_flags = 0

	New()
		..()
		jars += src

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/reagent_containers/food/snacks))
			if (src.contents.len > 16)
				boutput(user, "<span class='alert'>There is no way that will fit into this jar.  This VERY FULL jar.</span>")
				return

			user.drop_item()
			W.set_loc(src)
			user.visible_message("<b>[user]</b> puts [W] into [src].", "You stuff [W] into [src].")
			src.UpdateIcon()

		else
			..()

	attack_self(mob/user as mob)
		if (src.contents.len)
			var/obj/item/yoinked_out_thing = pick(src.contents)
			if (istype(yoinked_out_thing))
				user.put_in_hand_or_drop(yoinked_out_thing)
				user.visible_message("<b>[user]</b> pulls [yoinked_out_thing] out of [src]","You pull [yoinked_out_thing] out of [src]")
				src.UpdateIcon()

	on_reagent_change()
		if (!color_underlay)
			color_underlay = image(src.icon, "mason_jar_brine")

		if (!src.reagents || !src.reagents.total_volume)
			src.underlays = list()

		else
			src.underlays = null
			color_underlay.color = src.reagents.get_master_color()
			src.underlays = list(color_underlay)

		UpdateIcon()

	update_icon()
		if (src.contents.len)
			src.icon_state = "mason_jar_green"

		else
			src.icon_state = "mason_jar"

var/list/jars = list()
proc/save_intraround_jars()
	. = ""
	var/jarCount = 0
	var/jar_innard_string = ""
	for (var/obj/item/reagent_containers/glass/jar/jar in jars)

		var/turf/jarTurf = get_turf(jar)
		if (!jarTurf)
			continue

		jar_innard_string = ""
		for (var/obj/item/I in jar)
			jar_innard_string += ",[I.type]"

		. += "Jar[++jarCount]=[jarTurf.x],[jarTurf.y],[jarTurf.z][jar_innard_string];"

		if (jarCount >= 32)
			break

	world.save_intra_round_value("Jars", .)

proc/load_intraround_jars()
	set background = 1
	var/list/jars_encoded = params2list(world.load_intra_round_value("Jars"))
	var/jarX = 0
	var/jarY = 0
	var/jarZ = 0
	for (var/jar_entry in jars_encoded)
		//boutput(world, "[jar_entry] = [jars_encoded[jar_entry]]")
		var/list/decode_list = splittext(jars_encoded[jar_entry], ",")
		if (!decode_list || decode_list.len < 3)
			continue

		jarX = text2num(decode_list[1])
		jarY = text2num(decode_list[2])
		jarZ = text2num(decode_list[3])
		//boutput(world, "[jarX] [jarY] [jarZ]")

		var/obj/item/reagent_containers/glass/jar/newJar = new /obj/item/reagent_containers/glass/jar (locate(jarX,jarY,jarZ))
		var/potential_new_item_path
		var/obj/item/potential_new_item
		var/obj/item/reagent_containers/food/snacks/pickle_holder/new_pickle
		. = ""
		for (var/i = 4, i <= decode_list.len && i <= 20, i++)
			potential_new_item_path = text2path(decode_list[i])
			//boutput(world, "[decode_list[i]], [potential_new_item_path]")
			if (ispath(potential_new_item_path, /obj/item/reagent_containers/food))
				potential_new_item = new potential_new_item_path //Isn't this ugly?  This is ugly.
				//todo
				new_pickle = new /obj/item/reagent_containers/food/snacks/pickle_holder (null, potential_new_item)
				new_pickle.set_loc( newJar )
				if (potential_new_item.reagents)
					potential_new_item.reagents.trans_to(new_pickle, 100)

				. += "[decode_list[i]] "
				potential_new_item.dispose()

		if (newJar.reagents)
			newJar.reagents.add_reagent("juice_pickle", 75)

		logTheThing("debug", null, null, "<b>Pickle Jar:</b> Jar created at \[[jarX],[jarY],[jarZ]\] containing [.]")

	world.save_intra_round_value("Jars","")

/obj/item/reagent_containers/food/snacks/pickle_holder
	name = "ethereal pickle"
	desc = "You can't see anything, but there is an unmistakable presence of vinegar and spices here.  Kosher dill."

	New(newloc, var/obj/item/reagent_containers/pickled)
		..(newloc)
		if (istype(pickled))

			src.icon = pickled.icon
			src.icon_state = pickled.icon_state
			src.overlays = pickled.overlays
			src.underlays = pickled.underlays

			src.color = rgb(63,103,24)

			src.desc = "A pickled version of \a [pickled], It smells of vinegar."
			src.name = "pickled [pickled.name]"
