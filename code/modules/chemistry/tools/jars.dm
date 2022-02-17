
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
	var/jar_count = 0
	var/savefile/jar_save = new("data/jars.sav")
	jar_save.Lock()
	for_by_tcl(jar, /obj/item/reagent_containers/glass/jar)
		var/turf/jar_turf = get_turf(jar)
		if (!jar_turf)
			continue
		jar_count++
		jar_save["jar[jar_count]/loc"] << list(jar_turf.x, jar_turf.y, jar_turf.z)

		var/list/jar_contents = list()
		for (var/obj/item/I in jar)
			if(!istype(I, /obj/item/reagent_containers/food/snacks/pickle_holder))
				var/obj/item/reagent_containers/food/snacks/pickle_holder/pickled = new(jar, I)
				qdel(I)
				I = pickled
			I.removeMaterial()
			jar_contents += I

		jar_save["jar[jar_count]/contents"] << jar_contents
	jar_save.Flush()
	jar_save.Unlock()

proc/load_intraround_jars()
	set background = 1

	var/savefile/jar_save = new("data/jars.sav")
	jar_save.Lock()
	var/emitted_full_savefile = FALSE
	for(var/jarname in jar_save.dir)
		var/list/coords
		jar_save["[jarname]/loc"] >> coords
		var/turf/jar_turf = locate(coords[1], coords[2], coords[3])
		if(isnull(jar_turf))
			continue
		var/obj/item/reagent_containers/glass/jar/jar = new(jar_turf)
		var/list/jar_contents
		jar_save["[jarname]/contents"] >> jar_contents
		for(var/obj/item/I in jar_contents)
			I.set_loc(jar)
			I.reagents?.trans_to(jar, 100)
			var/obj/item/reagent_containers/food/snacks/pickle_holder/pickled = I
			if(istype(pickled))
				pickled.pickle_age++
			else
				stack_trace("Unpickled item [I] of type [I.type] found in pickle jar [jarname]")
				if(!emitted_full_savefile)
					logTheThing("debug", null, null, "<b>Pickle Jar:</b> full savefile<br>[jar_save.ExportText()]")
					emitted_full_savefile = TRUE
		jar.reagents.add_reagent("juice_pickle", 75)
		logTheThing("debug", null, null, "<b>Pickle Jar:</b> Jar created at [log_loc(jar)] containing [json_encode(jar_contents)]")
	jar_save.Unlock()

/obj/item/reagent_containers/food/snacks/pickle_holder
	name = "ethereal pickle"
	desc = "You can't see anything, but there is an unmistakable presence of vinegar and spices here. Kosher dill."
	var/pickle_age

	New(newloc, obj/item/pickled)
		..(newloc)
		if (istype(pickled))
			src.icon = getFlatIcon(pickled, no_anim=TRUE)
			src.color = rgb(63,103,24)
			src.desc = "A pickled version of \a [pickled], it smells of vinegar."
			src.name = "pickled [pickled.name]"
			src.pickle_age = 0

	get_desc(dist, mob/user)
		. = ..()
		if(src.pickle_age)
			. += " It has been [src.pickle_age] shift[src.pickle_age > 1 ? "s" : ""] since it was pickled."
