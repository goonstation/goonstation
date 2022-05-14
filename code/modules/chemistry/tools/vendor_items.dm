
/* ======================================================= */
/* -------------------- Vendor Parent -------------------- */
/* ======================================================= */

/obj/item/reagent_containers/vending
	name = "chem vendor item"
	desc = "A generic parent item for the chemical vendor chem containers. You really shouldn't be able to see this thing!"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "vendvial"
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	initial_volume = 5
	amount_per_transfer_from_this = 5
	var/image/fluid_image
	rc_flags = RC_FULLNESS | RC_VISIBLE

/* ============================================== */
/* -------------------- Vial -------------------- */
/* ============================================== */

/obj/item/reagent_containers/vending/vial
	name = "small vial"
	desc = "A little vial. Can hold up to 5 units."
	icon_state = "minivial"
	rc_flags = RC_VISIBLE | RC_SPECTRO

	on_reagent_change()
		..()
		UpdateIcon()

	update_icon()
		src.underlays = null
		if (src.reagents.total_volume == 0)
			icon_state = "minivial"
		if (src.reagents.total_volume > 0)
			icon_state = "minivial1"
			if (!src.fluid_image)
				src.fluid_image = image('icons/obj/chemical.dmi', "minivial-fluid")
			var/datum/color/average = reagents.get_average_color()
			src.fluid_image.color = average.to_rgba()
			src.underlays += src.fluid_image
		return

	ex_act(severity)
		src.smash()

	proc/smash(var/turf/T)
		if (!T)
			T = src.loc
		src.reagents?.reaction(T)
		if (ismob(T)) // we've reacted with whatever we've hit, but if what we hit is a mob, let's not stick glass in their contents
			T = get_turf(T)
		T?.visible_message("<span class='alert'>[src] shatters!</span>")
		playsound(T, pick('sound/impact_sounds/Glass_Shatter_1.ogg','sound/impact_sounds/Glass_Shatter_2.ogg','sound/impact_sounds/Glass_Shatter_3.ogg'), 100, 1)
		var/obj/item/raw_material/shard/glass/G = new /obj/item/raw_material/shard/glass
		G.set_loc(src.loc)

		qdel(src)

	throw_impact(atom/A, datum/thrown_thing/thr)
		var/turf/T = get_turf(A)
		..()
		src.smash(T)

/* ============================================= */
/* -------------------- Bag -------------------- */
/* ============================================= */

/obj/item/reagent_containers/vending/bag
	name = "small bag"
	desc = "A little bag. Can hold up to 5 units."
	icon_state = "vendbag"

	on_reagent_change()
		..()
		UpdateIcon()

	update_icon()
		src.underlays = null
		if (src.reagents.total_volume == 0)
			icon_state = "vendbag"
		if (src.reagents.total_volume > 0)
			icon_state = "vendbag1"
			if (!src.fluid_image)
				src.fluid_image = image('icons/obj/chemical.dmi', "vendbag-fluid")
			var/datum/color/average = reagents.get_average_color()
			src.fluid_image.color = average.to_rgba()
			src.underlays += src.fluid_image
		return

	ex_act(severity)
		src.smash()

	proc/smash(var/turf/T)
		if (!T)
			T = src.loc
		src.reagents.reaction(T)
		if (ismob(T))
			T = get_turf(T)
		T.visible_message("<span class='alert'>[src] bursts!</span>")
		playsound(T, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
		qdel(src)

	throw_impact(atom/A, datum/thrown_thing/thr)
		var/turf/T = get_turf(A)
		..()
		src.smash(T)

/* =================================================== */
/* -------------------- Sub-Types -------------------- */
/* =================================================== */

/obj/item/reagent_containers/vending/bag/larger
	name = "bag"
	desc = "A bag. Can hold up to 50 units."
	initial_volume = 50

/obj/item/reagent_containers/vending/bag/random
	New()
		..()
		SPAWN(0)
			if (src.reagents)
				var/chem = null
				if (islist(all_functional_reagent_ids) && length(all_functional_reagent_ids))
					chem = pick(all_functional_reagent_ids)
				else
					chem = "water"
				src.reagents.add_reagent(chem, 5)

/obj/item/reagent_containers/vending/vial/random
	New()
		..()
		SPAWN(0)
			if (src.reagents)
				var/chem = null
				if (islist(all_functional_reagent_ids) && length(all_functional_reagent_ids))
					chem = pick(all_functional_reagent_ids)
				else
					chem = "water"
				src.reagents.add_reagent(chem, 5)
