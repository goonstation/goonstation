
/* ============================================== */
/* -------------------- Jars -------------------- */
/* ============================================== */

#define JARS_FILE "data/jars.sav"
#define JARS_VERSION 2
#define DEFAULT_JAR_COUNT 4
#define MAX_JAR_COUNT 32
#define JAR_MAX_ITEMS 16

/obj/item/reagent_containers/glass/jar
	name = "glass jar"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mason_jar"
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

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/toy) || istype(W, /obj/item/reagent_containers/glass) || istype(W, /obj/item/reagent_containers/food/drinks))
			return ..()

		if(W.two_handed || W.w_class >= W_CLASS_GIGANTIC)
			boutput(user, SPAN_ALERT("That's too large to fit into the jar."))
			return

		if(isgrab(W))
			var/obj/item/grab/grab = W
			boutput(user, SPAN_ALERT("You can't seem to fit [grab.affecting] into \the [src]."))
			return

		if(W.contraband)
			boutput(user, SPAN_ALERT("[W] is too illegal to fit into the jar."))
			return

		if(W.cant_drop)
			boutput(user, SPAN_ALERT("You can't put that in the jar."))
			return

		if (length(src.contents) > JAR_MAX_ITEMS || (locate(/mob/living) in src))
			boutput(user, SPAN_ALERT("There is no way that will fit into this jar.  This VERY FULL jar."))
			return

		user.drop_item()
		W.set_loc(src)
		user.visible_message(SPAN_NOTICE("<b>[user]</b> puts [W] into [src]."), SPAN_NOTICE("You stuff [W] into [src]."))
		src.UpdateIcon()
		src.update()

	proc/update()
		src.w_class = initial(src.w_class)
		for(var/obj/item/item in src)
			src.w_class = max(src.w_class, item.w_class)
		var/obj/loc_storage = src.loc
		if(loc_storage.storage)
			if(loc_storage.storage.max_wclass < src.w_class)
				var/turf/T = get_turf(src)
				src.set_loc(T)
				src.visible_message(SPAN_ALERT("[src] is too full to fit into [loc_storage] and tumbles onto [T]."))

	get_desc(dist, mob/user)
		. = ..()
		if(length(src.contents))
			var/list/stuff_inside = list()
			for(var/atom/movable/AM in src)
				stuff_inside += "\a [AM]"
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
			if(yoinked_out_thing)
				var/pronoun = "it"
				if(ismob(yoinked_out_thing))
					pronoun = he_or_she(yoinked_out_thing)
				boutput(user, SPAN_NOTICE("You try to pull [yoinked_out_thing] out of \the [src] but it seems like [pronoun] is stuck."))
			return FALSE
		user.put_in_hand_or_drop(yoinked_out_thing)
		user.visible_message(SPAN_NOTICE("<b>[user]</b> pulls [yoinked_out_thing] out of [src]."),SPAN_NOTICE("You pull [yoinked_out_thing] out of [src]."))
		src.UpdateIcon()
		src.update()
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

	suicide_in_hand = FALSE
	custom_suicide = TRUE
	suicide(mob/user)
		if(length(src.contents) > 0)
			boutput(user, SPAN_ALERT("You need to empty \the [src] first!"))
			return 0
		user.TakeDamage("chest", 100, 0)
		user.visible_message(SPAN_ALERT("<b>[user] somehow climbs into \the [src]! How is that even possible?!</b>"))
		user.u_equip(src)
		src.set_loc(user.loc)
		src.dropped(user)
		user.set_loc(src)
		src.UpdateIcon()
		return 1

	handle_internal_lifeform(mob/lifeform_inside_me, breath_request, mult)
		// no air inside
		return new/datum/gas_mixture

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
		for (var/atom/movable/AM in jar)
			var/atom/movable/pickled = AM.picklify(jar)
			if(pickled != AM)
				qdel(AM)
			if(isnull(pickled))
				continue
			if(pickled.material)
				pickled.removeMaterial()
			pickled.reagents?.clear_reagents()
			pickled.setMaterial(getMaterial("pickle"), setname=FALSE) // maybe picklify should be able to override this idk!!!
			jar_contents += pickled

		var/zname = global.zlevels[jar_turf.z].name
		jar_data_by_z[zname] += list(list(jar_turf.x, jar_turf.y, jar_contents))
		logTheThing(LOG_DEBUG, null, "<b>Pickle Jar:</b> Jar saved at [log_loc(jar)] ([zname]) containing [json_encode(jar_contents)]")

	for(var/zname in jar_data_by_z)
		var/list/jars_here = jar_data_by_z[zname]
		jar_save["zlevel/[zname]"] << jars_here
	jar_save.Flush()

proc/generate_backup_jars()
	var/tries_left = 10
	while(length(by_type[/obj/item/reagent_containers/glass/jar]) < DEFAULT_JAR_COUNT && tries_left > 0)
		var/areatype = pick(prob(10); /area/diner/kitchen, /area/station/crew_quarters/kitchen)
		var/list/turf/turfs = get_area_turfs(areatype, 1)
		if(length(turfs))
			var/turf/T = pick(turfs)
			new/obj/item/reagent_containers/glass/jar(T)
			logTheThing(LOG_DEBUG, null, "<b>Pickle Jar:</b> New empty jar created at [log_loc(T)]")
		else
			tries_left--
	tries_left = 50
	while(length(by_type[/obj/item/reagent_containers/glass/jar]) < DEFAULT_JAR_COUNT && tries_left > 0)
		var/turf/simulated/floor/T = locate(rand(1, world.maxx), rand(1, world.maxy), Z_LEVEL_STATION)
		if(istype(T))
			new/obj/item/reagent_containers/glass/jar(T)
			logTheThing(LOG_DEBUG, null, "<b>Pickle Jar:</b> New empty jar created at [log_loc(T)]")
		else
			tries_left--

proc/load_intraround_jars()
	set background = 1

	fdel(JARS_FILE + ".lk") // force unlock. We don't share the file with other instances. However, server crashing doesn't clean up the lock leading to issues
	var/savefile/jar_save = new(JARS_FILE)
	var/version
	jar_save["version"] >> version
	if(version < JARS_VERSION)
		generate_backup_jars()
		fdel(JARS_FILE)
		return

	var/emitted_full_savefile = FALSE
	for(var/datum/zlevel/zlevel in global.zlevels)
		var/zname = zlevel.name
		var/list/jars_data
		try
			jar_save["zlevel/[zname]"] >> jars_data
		catch(var/exception/e)
			if(!emitted_full_savefile)
				logTheThing(LOG_DEBUG, null, "<b>Pickle Jar:</b> full savefile<br>[jar_save.ExportText()]")
				emitted_full_savefile = TRUE
			stack_trace("[e.name]\n[e.desc]")
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
				var/obj/item/reagent_containers/food/snacks/pickle_holder/pickled = I
				if(istype(pickled))
					pickled.pickle_age++
			jar.reagents.add_reagent("juice_pickle", 75)
			logTheThing(LOG_DEBUG, null, "<b>Pickle Jar:</b> Jar created at [log_loc(jar)] ([zname]) containing [json_encode(jar_contents)]")
			var/area/AR = get_area(jar)
			if(in_centcom(jar) || !istype(AR, /area/station) && !istype(AR, /area/diner) && prob(10))
				SPAWN(randfloat(5 MINUTES, 30 MINUTES))
					shippingmarket.receive_crate(jar)
			if(length(length(by_type[/obj/item/reagent_containers/glass/jar])) >= MAX_JAR_COUNT)
				logTheThing(LOG_DEBUG, null, "<b>Pickle Jar:</b> Jar creation process hit maximum limit of [MAX_JAR_COUNT], further jars are lost to time.")
				return

	// in case we have less than the required amount generate more
	generate_backup_jars()



// the food that represents the pickled object

/atom/movable/proc/picklify(atom/loc)
	RETURN_TYPE(/obj/item/reagent_containers/food/snacks/pickle_holder)
	return new/obj/item/reagent_containers/food/snacks/pickle_holder(loc, src)

/obj/item/reagent_containers/food/snacks/pickle_holder
	name = "ethereal pickle"
	desc = "You can't see anything, but there is an unmistakable presence of vinegar and spices here. Kosher dill."
	initial_volume = 0
	var/pickle_age

	New(newloc, atom/movable/pickled)
		..(newloc, null) // DO NOT PASS pickled AS THE SECOND VAR BECAUSE IT GETS STORED AS INITIAL REAGENTS AAA
		if (istype(pickled))
			src.icon = getFlatIcon(pickled, no_anim=TRUE)
			src.desc = "A pickled version of \a [pickled], it smells of vinegar."
			src.real_desc = src.desc
			src.name = "pickled [pickled.name]"
			src.pickle_age = 0

	get_desc(dist, mob/user)
		. = ..()
		if(src.pickle_age)
			. += " It has been [src.pickle_age] shift[src.pickle_age > 1 ? "s" : ""] since it was pickled."

	picklify(atom/loc)
		src.set_loc(loc)
		return src



// overrides of pickling for specific objects go here

/obj/item/paper/picklify(atom/loc)
	return new/obj/item/reagent_containers/food/snacks/pickle_holder/paper(loc, src)

/obj/item/reagent_containers/food/snacks/pickle_holder/paper
	flags = TABLEPASS | SUPPRESSATTACK | TGUI_INTERACTIVE
	var/sizex
	var/sizey
	var/info
	var/list/stamps
	var/list/form_fields
	var/field_counter

	New(newloc, obj/item/paper/pickled)
		..()
		if (istype(pickled))
			src.sizex = pickled.sizex
			src.sizey = pickled.sizey
			src.info = pickled.info
			src.stamps = pickled.stamps?.Copy()
			src.form_fields = pickled.form_fields?.Copy()
			src.field_counter = pickled.field_counter

			for(var/i in 1 to 3)
				if(prob(60))
					var/list/stain_info = list(list("stamp-stain-[i].png", rand(0, sizex || 400), rand(0, sizey || 500), rand(360)))
					LAZYLISTADD(src.stamps, stain_info)

	attack_self(mob/user)
		// show both the text and take a bite! consuming both information and food at the same time!
		ui_interact(user)
		. = ..()

	examine(mob/user)
		. = ..()
		ui_interact(user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "PaperSheet")
			ui.open()

	ui_status(mob/user, datum/ui_state/state)
		if(!user.literate)
			boutput(user, SPAN_ALERT("You don't know how to read."))
			return UI_CLOSE
		. = max(..(), UI_DISABLED)
		if(IN_RANGE(user, src, 8))
			. = max(., UI_UPDATE)

	ui_static_data(mob/user)
		. = list(
			"name" = src.name,
			"sizeX" = src.sizex,
			"sizeY" = src.sizey,
			"text" = src.info,
			"max_length" = 5000,
			"paperColor" = src.color || "white",	// color might not be set
			"stamps" = src.stamps,
			"stampable" = FALSE,
			"sealed" = TRUE,
		)

	ui_data(mob/user)
		. = list(
			"editUsr" = "[user]",
			"fieldCounter" = field_counter,
			"formFields" = form_fields,
			"editMode" = 0,
			"penFont" = "FAKE",
			"penColor" = "FAKE",
			"isCrayon" = FALSE,
			"stampClass" = "FAKE",
		)

#undef JARS_FILE
#undef JARS_VERSION
#undef DEFAULT_JAR_COUNT
#undef MAX_JAR_COUNT
#undef JAR_MAX_ITEMS

///unrelated funny jar
/obj/item/reagent_containers/glass/jar/extradimensional
	anchored = TRUE
	var/prefab_type = /datum/mapPrefab/allocated/jar

	New()
		. = ..()
		var/datum/mapPrefab/allocated/prefab = get_singleton(src.prefab_type)
		//heehee hooha component abuse (the alternative was worse sadly because we don't have anonymous functions)
		var/datum/component/extradimensional_storage/shrink/component = src.AddComponent(/datum/component/extradimensional_storage/shrink, prefab.prefabSizeX + 2, prefab.prefabSizeX + 2)
		prefab.applyTo(get_step(component.region.bottom_left, NORTHEAST), overwrite_args = DMM_OVERWRITE_MOBS | DMM_BESPOKE_AREAS)

		var/datum/allocated_region/region = component.region
		var/turf/exit = get_turf(src)
		//dumb copy paste to set up the warps
		for(var/x in 2 to region.width - 1)
			var/turf/T = region.turf_at(x, 2)
			T.warptarget = exit
			T = region.turf_at(x, region.height - 1)
			T.warptarget = exit

		for(var/y in 2 to region.height - 1)
			var/turf/T = region.turf_at(2, y)
			T.warptarget = exit
			T = region.turf_at(region.width - 1, y)
			T.warptarget = exit

	return_air(direct = FALSE)
		if (direct)
			return null
		var/turf/T = get_turf(src)
		return T?.return_air()
