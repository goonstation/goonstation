
/* ============================================== */
/* -------------------- Jars -------------------- */
/* ============================================== */

#define JARS_FILE "data/jars.sav"
#define JARS_VERSION 1
#define DEFAULT_JAR_COUNT 3

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
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

	attackby(obj/item/W as obj, mob/user as mob)
		if (length(src.contents) > 16)
			boutput(user, "<span class='alert'>There is no way that will fit into this jar.  This VERY FULL jar.</span>")
			return

		user.drop_item()
		W.set_loc(src)
		user.visible_message("<span class='notice'><b>[user]</b> puts [W] into [src].</span>", "<span class='notice'>You stuff [W] into [src].</span>")
		src.UpdateIcon()

	get_desc(dist, mob/user)
		. = ..()
		if(length(src.contents))
			var/list/stuff_inside = list()
			for(var/obj/item/I in src)
				stuff_inside += "\a [I]"
			var/obj/item/last = stuff_inside[length(stuff_inside)]
			stuff_inside.len--
			if(length(stuff_inside))
				. += "It contains [jointext(stuff_inside, ", ")], and [last]."
			else
				. += "It contains [last]."
		else
			. += "It is empty."

	attack_self(mob/user as mob)
		if (src.contents.len)
			yoink(user)
		else
			. = ..()

	attack_hand(mob/user)
		if(length(src.contents) && (src in user.equipped_list()))
			yoink(user)
		else
			. = ..()

	proc/yoink(mob/user)
		if(!length(src.contents))
			return FALSE
		var/obj/item/yoinked_out_thing = pick(src.contents)
		if(!istype(yoinked_out_thing))
			return FALSE
		user.put_in_hand_or_drop(yoinked_out_thing)
		user.visible_message("<span class='notice'><b>[user]</b> pulls [yoinked_out_thing] out of [src].</span>","<span class='notice'>You pull [yoinked_out_thing] out of [src].</span>")
		src.UpdateIcon()
		return TRUE

	on_reagent_change()
		..()
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

proc/save_intraround_jars()
	var/savefile/jar_save = new(JARS_FILE)
	jar_save["version"] << JARS_VERSION
	var/list/jar_data_by_z = list()
	for(var/datum/zlevel/zlevel in global.zlevels)
		jar_data_by_z[zlevel.name] = list()
	for_by_tcl(jar, /obj/item/reagent_containers/glass/jar)
		var/turf/jar_turf = get_turf(jar)
		if (!jar_turf)
			continue

		var/list/jar_contents = list()
		for (var/obj/item/I in jar)
			var/obj/item/reagent_containers/food/snacks/pickle_holder/pickled = I
			if(!istype(I, /obj/item/reagent_containers/food/snacks/pickle_holder))
				pickled = new(jar, I)
				qdel(I)
			pickled.removeMaterial()
			if(istype(pickled))
				pickled.paint_pickly_color()
			jar_contents += pickled

		var/zname = global.zlevels[jar_turf.z].name
		jar_data_by_z[zname] += list(list(jar_turf.x, jar_turf.y, jar_contents))

	for(var/zname in jar_data_by_z)
		var/list/jars_here = jar_data_by_z[zname]
		jar_save["zlevel/[zname]"] << jars_here
	jar_save.Flush()

proc/generate_backup_jars()
	while(length(by_type[/obj/item/reagent_containers/glass/jar]) < DEFAULT_JAR_COUNT)
		var/areatype = pick(/area/diner/kitchen, /area/station/crew_quarters/kitchen)
		var/list/turf/turfs = get_area_turfs(areatype, 1)
		if(length(turfs))
			new/obj/item/reagent_containers/glass/jar(pick(turfs))

proc/load_intraround_jars()
	set background = 1

	fdel(JARS_FILE + ".lk") // force unlock. We don't share the file with other instances. However, server crashing doesn't clean up the lock leading to issues
	var/savefile/jar_save = new(JARS_FILE)
	var/version
	jar_save["version"] >> version
	if(isnull(version))
		generate_backup_jars()
		fdel(JARS_FILE)
		return

	var/emitted_full_savefile = FALSE
	for(var/datum/zlevel/zlevel in global.zlevels)
		var/zname = zlevel.name
		var/list/jars_data
		jar_save["zlevel/[zname]"] >> jars_data
		for(var/list/jar_data in jars_data)
			var/x = jar_data[1]
			var/y = jar_data[2]
			var/z = zlevel.z
			var/turf/jar_turf = locate(x, y, z)
			if(isnull(jar_turf))
				continue
			var/obj/item/reagent_containers/glass/jar/jar = new(jar_turf)
			var/list/jar_contents = jar_data[3]
			for(var/obj/item/I in jar_contents)
				I.set_loc(jar)
				I.reagents?.trans_to(jar, 100)
				var/obj/item/reagent_containers/food/snacks/pickle_holder/pickled = I
				if(istype(pickled))
					pickled.pickle_age++
				else
					stack_trace("Unpickled item [I] of type [I.type] found in pickle jar on [x],[y],[z]")
					if(!emitted_full_savefile)
						logTheThing("debug", null, null, "<b>Pickle Jar:</b> full savefile<br>[jar_save.ExportText()]")
						emitted_full_savefile = TRUE
			jar.reagents.add_reagent("juice_pickle", 75)
			logTheThing("debug", null, null, "<b>Pickle Jar:</b> Jar created at [log_loc(jar)] containing [json_encode(jar_contents)]")

/obj/item/reagent_containers/food/snacks/pickle_holder
	name = "ethereal pickle"
	desc = "You can't see anything, but there is an unmistakable presence of vinegar and spices here. Kosher dill."
	var/pickle_age

	New(newloc, obj/item/pickled)
		..(newloc)
		if (istype(pickled))
			src.icon = getFlatIcon(pickled, no_anim=TRUE)
			src.paint_pickly_color()
			src.desc = "A pickled version of \a [pickled], it smells of vinegar."
			src.real_desc = src.desc
			src.name = "pickled [pickled.name]"
			src.pickle_age = 0

	proc/paint_pickly_color()
		src.color = rgb(63,103,24)

	get_desc(dist, mob/user)
		. = ..()
		if(src.pickle_age)
			. += " It has been [src.pickle_age] shift[src.pickle_age > 1 ? "s" : ""] since it was pickled."

#undef JARS_FILE
#undef JARS_VERSION
#undef DEFAULT_JAR_COUNT
