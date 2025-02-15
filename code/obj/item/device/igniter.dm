TYPEINFO(/obj/item/device/igniter)
	mats = 2

/obj/item/device/igniter
	name = "igniter"
	desc = "A small electronic device can be paired with other electronics, or used to heat chemicals directly."
	icon_state = "igniter"
	var/status = 1
	flags = TABLEPASS | CONDUCT | USEDELAY
	c_flags = ONBELT
	tool_flags = TOOL_ASSEMBLY_APPLIER
	item_state = "electronic"
	m_amt = 100
	throwforce = 5
	w_class = W_CLASS_TINY
	throw_speed = 3
	throw_range = 10
	firesource = FIRESOURCE_IGNITER

	//blcok spamming shit because inventory uncaps click speed and kinda makes this an exploit
	//its still a bit stronger than non-inventory interactions, why not
	var/last_ignite = 0

/obj/item/device/igniter/New()
	..()
	RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_COMBINATION_CHECK, PROC_REF(assembly_check))
	RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_APPLY, PROC_REF(assembly_application))
	RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP, PROC_REF(assembly_setup))
	RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_OVERLAY_ADDITIONS, PROC_REF(assembly_overlay_addition))

/obj/item/device/igniter/disposing()
	UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_COMBINATION_CHECK)
	UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_APPLY)
	UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP)
	UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_OVERLAY_ADDITIONS)
	..()

/// ----------- Trigger/Applier-Assembly-Related Procs -----------

/obj/item/device/igniter/proc/assembly_check(var/manipulated_igniter, var/obj/item/second_part, var/mob/user)
	//if secured, we return TRUE and prevent the combination
	if (src.status)
		boutput(user, SPAN_NOTICE("You need to unsecure the igniter to attach it to that."))
	return src.status

/obj/item/device/igniter/proc/assembly_application(var/manipulated_igniter, var/obj/item/assembly/complete/parent_assembly, var/obj/assembly_target)
	if(!assembly_target)
		//if there is no target, we just heat the tile we are on
		src.ignite()
	else
		if(istype(assembly_target, /obj/item/pipebomb/frame))
			//fuck pipebomb-code
			playsound(get_turf(parent_assembly), 'sound/weapons/armbomb.ogg', 50, TRUE)
			SPAWN(1 SECONDS)
				var/obj/item/pipebomb/frame/manipulated_pipebomb = assembly_target
				var/obj/item/pipebomb/bomb/the_real_bomb = new /obj/item/pipebomb/bomb
				the_real_bomb.master = parent_assembly
				the_real_bomb.set_loc(src)
				the_real_bomb.strength = manipulated_pipebomb.strength
				if (manipulated_pipebomb.material)
					the_real_bomb.setMaterial(manipulated_pipebomb.material)
				//add properties from item mods to the finished pipe bomb
				the_real_bomb.set_up_special_ingredients(manipulated_pipebomb.item_mods)
				//And now after we build a real pipebomb inside of an assembly, lets set ot up properly blow it up!
				qdel(manipulated_pipebomb)
				parent_assembly.target = the_real_bomb
				the_real_bomb.do_explode()
				qdel(parent_assembly)
			return
		if(istype(assembly_target, /obj/item/pipebomb/bomb))
			playsound(get_turf(parent_assembly), 'sound/weapons/armbomb.ogg', 50, TRUE)
			SPAWN(1 SECONDS)
				var/obj/item/pipebomb/bomb/manipulated_pipebomb = assembly_target
				manipulated_pipebomb.do_explode()
				qdel(parent_assembly)
			return
		if(istype(assembly_target, /obj/item/reagent_containers/glass/beaker))
			var/obj/item/reagent_containers/glass/beaker/manipulated_beaker = assembly_target
			manipulated_beaker.reagents.temperature_reagents(4000, 400)
			manipulated_beaker.reagents.temperature_reagents(4000, 400)
			return
		if(istype(assembly_target, /obj/item/tank/plasma))
			var/obj/item/tank/plasma/manipulated_plasma_tank = assembly_target
			manipulated_plasma_tank.ignite()
			qdel(parent_assembly)
			return


/obj/item/device/igniter/proc/assembly_setup(var/manipulated_igniter, var/obj/item/assembly/complete/parent_assembly, var/mob/user, var/is_build_in)
	//once integrated in the assembly, we secure the igniter
	src.status = 1
	if(parent_assembly.applier == src)
		// trigger-igniter- Assembly + wired pipebomb/pipebomb-frame/beaker -> trigger-igniter pipebomb/beakerbomb
		parent_assembly.AddComponent(/datum/component/assembly, list(/obj/item/tank/plasma, /obj/item/pipebomb/frame, /obj/item/pipebomb/bomb, /obj/item/reagent_containers/glass/beaker), TYPE_PROC_REF(/obj/item/assembly/complete, add_target_item), TRUE)
	if(istype(parent_assembly.applier, /obj/item/device/multitool) && (src in parent_assembly.additional_components))
		//were on the way to blow everything up, so lets lock in!
		parent_assembly.special_construction_identifier = "canbomb"


/obj/item/device/igniter/proc/assembly_overlay_addition(var/manipulated_igniter, var/obj/item/assembly/complete/parent_assembly, var/passed_overlay_offset)
	if(parent_assembly.special_construction_identifier == "canbomb")
		parent_assembly.overlays += image('icons/obj/items/assemblies.dmi', parent_assembly, "igniter_canbomb")

/// ----------------------------------------------


/obj/item/device/igniter/attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	if (ishuman(target))
		var/mob/living/carbon/human/H = target
		if (H:bleeding || (H.organHolder.back_op_stage > BACK_SURGERY_CLOSED && user.zone_sel.selecting == "chest"))
			if (is_special || !src.cautery_surgery(target, user, 15))
				return ..()
		else return ..()
	else return ..()

/obj/item/device/igniter/attackby(obj/item/W, mob/user)
	if (isscrewingtool(W))
		src.status = !(src.status)
		if (src.status)
			user.show_message(SPAN_NOTICE("The igniter is ready!"))
		else
			user.show_message(SPAN_NOTICE("The igniter can now be attached!"))
		src.add_fingerprint(user)

	return

/obj/item/device/igniter/attack_self(mob/user as mob)

	src.add_fingerprint(user)
	SPAWN( 5 )
		ignite()
		return
	return

/obj/item/device/igniter/proc/can_ignite()
	return (world.time >= last_ignite + src.combat_click_delay/2)

/obj/item/device/igniter/afterattack(atom/target, mob/user as mob)
	if (!ismob(target) && target.reagents && can_ignite())
		flick("igniter_light", src)
		boutput(user, SPAN_NOTICE("You heat \the [target.name]."))
		target.reagents.temperature_reagents(4000,400)
		last_ignite = world.time

/obj/item/device/igniter/proc/ignite()
	if (src.status && can_ignite())
		var/turf/location = src.loc

		if (src.master)
			location = src.master.loc

		flick("igniter_light", src)
		location = get_turf(location)
		location?.hotspot_expose((isturf(location) ? 3000 : 4000),2000)
		last_ignite = world.time

	return

/obj/item/device/igniter/examine(mob/user)
	. = ..()
	if ((in_interact_range(src, user) || src.loc == user))
		if (src.status)
			. += "The igniter is ready!"
		else
			. += "The igniter can be attached!"
