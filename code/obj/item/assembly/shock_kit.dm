/obj/item/shock_kit
	name = "Shock Kit"
	desc = "An assembly to create an electric chair with."
	icon = 'icons/obj/items/assemblies.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "assembly"
	icon_state = "shock_kit"
	var/obj/item/clothing/head/helmet/helmet_part = null
	var/obj/item/device/radio/electropack/electropack_part = null
	throwforce = 10
	throw_speed = 4
	throw_range = 10
	force = 2
	stamina_damage = 10
	stamina_cost = 10
	w_class = W_CLASS_HUGE
	flags = TABLEPASS | CONDUCT

/obj/item/shock_kit/New(var/atom/new_location, var/obj/item/clothing/head/helmet/new_helmet, var/obj/item/device/radio/electropack/new_electropack)
	..()
	//let's create the items if they aren't here already
	if(!new_helmet)
		new_helmet = new /obj/item/clothing/head/helmet
	src.helmet_part = new_helmet
	if(!new_electropack)
		new_electropack = new /obj/item/device/radio/electropack
	src.electropack_part = new_electropack
	//now, let's move them and set them up
	for(var/obj/item/affected_object in list(src.helmet_part, src.electropack_part))
		affected_object.set_loc(src)
		affected_object.master = src
	// Shock kit + wrench  -> deconstruction
	src.AddComponent(/datum/component/assembly, TOOL_WRENCHING, PROC_REF(deconstruction), FALSE, new /datum/assembly_comp_helper/consumes_self)
	// Shock kit + stool  -> electric chair
	src.AddComponent(/datum/component/assembly, /obj/stool/chair, PROC_REF(electric_chair_construction), TRUE, new /datum/assembly_comp_helper/consumes_all)

/obj/item/shock_kit/disposing()
	qdel(src.helmet_part)
	src.helmet_part = null
	qdel(src.electropack_part)
	src.electropack_part = null
	..()

/obj/item/shock_kit/attack_self(mob/user as mob)
	src.electropack_part.AttackSelf(user)
	src.add_fingerprint(user)
	return

/obj/item/shock_kit/receive_signal()
	if (src.master && istype(src.master, /obj/stool/chair/e_chair))
		var/obj/stool/chair/e_chair/C = src.master
		if (C.buckled_guy)
			logTheThing(LOG_SIGNALERS, usr, "signalled an electric chair (setting: [C.lethal ? "lethal" : "non-lethal"]), shocking [constructTarget(C.buckled_guy,"signalers")] at [log_loc(C)].") // Added (Convair880).
		C.shock()
	return


// ----------------------- Assembly-procs -----------------------

/// deconstruction
/obj/item/shock_kit/proc/deconstruction(var/atom/to_combine_atom, var/mob/user)
	src.electropack_part.master = null
	boutput(user, SPAN_NOTICE("You deconstruct the [src.name]."))
	var/turf/chosen_turf = get_turf(src)
	for(var/obj/item/affected_object in list(src.helmet_part, src.electropack_part))
		affected_object.set_loc(chosen_turf)
		affected_object.master = null
	src.helmet_part = null
	src.electropack_part = null
	user.u_equip(src)
	qdel(src)
	// Since the assembly was done, return TRUE
	return TRUE

/// electric chair construction
/obj/item/shock_kit/proc/electric_chair_construction(var/atom/to_combine_atom, var/mob/user)
	user.u_equip(src)
	var/obj/stool/to_combine_stool = to_combine_atom
	var/obj/stool/chair/e_chair/new_chair = new /obj/stool/chair/e_chair(to_combine_stool.loc, src)
	if (to_combine_stool.material)
		new_chair.setMaterial(to_combine_stool.material)
		playsound(to_combine_stool.loc, 'sound/items/Deconstruct.ogg', 50, 1)
	qdel(to_combine_atom)
	// Since the assembly was done, return TRUE
	return TRUE

// ----------------------- -------------- -----------------------
