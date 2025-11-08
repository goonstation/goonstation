TYPEINFO(/obj/item/device/igniter)
	mats = 2

/obj/item/device/igniter
	name = "igniter"
	desc = "A small electronic device can be paired with other electronics, or used to heat chemicals directly."
	icon_state = "igniter"
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
	RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_APPLY, PROC_REF(assembly_application))
	RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP, PROC_REF(assembly_setup))
	RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_OVERLAY_ADDITIONS, PROC_REF(assembly_overlay_addition))

/obj/item/device/igniter/disposing()
	UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_APPLY)
	UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP)
	UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_OVERLAY_ADDITIONS)
	..()

/// ----------- Trigger/Applier-Assembly-Related Procs -----------


/obj/item/device/igniter/assembly_get_part_help_message(var/dist, var/mob/shown_user, var/obj/item/assembly/parent_assembly)
	if(!parent_assembly.target)
		return " You can add a plasma tank, pipebomb or beaker onto this assembly in order to modify it further."

/obj/item/device/igniter/proc/assembly_application(var/manipulated_igniter, var/obj/item/assembly/parent_assembly, var/obj/assembly_target)
	if(!assembly_target)
		//if there is no target, we just heat the tile we are on
		src.ignite()
	else
		if(istype(assembly_target, /obj/item/pipebomb/bomb))
			playsound(get_turf(parent_assembly), 'sound/weapons/armbomb.ogg', 50, TRUE)
			var/obj/item/pipebomb/bomb/manipulated_pipebomb = assembly_target
			manipulated_pipebomb.do_explode()
			SEND_SIGNAL(parent_assembly, COMSIG_ITEM_CONVERTED, manipulated_pipebomb)
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
			SEND_SIGNAL(parent_assembly, COMSIG_ITEM_CONVERTED, manipulated_plasma_tank)
			qdel(parent_assembly)
			return
		if(istype(assembly_target, /obj/item/clothing/head/butt))
			var/obj/item/clothing/head/butt/manipulated_butt = assembly_target
			manipulated_butt.explode_butt()
			SEND_SIGNAL(parent_assembly, COMSIG_ITEM_CONVERTED, manipulated_butt)
			qdel(parent_assembly)
			return

/obj/item/device/igniter/proc/assembly_setup(var/manipulated_igniter, var/obj/item/assembly/parent_assembly, var/mob/user, var/is_build_in)
	if(parent_assembly.applier == src)
		// trigger-igniter- Assembly + wired pipebomb/pipebomb-frame/beaker/butt -> trigger-igniter pipebomb/beakerbomb/buttbomb
		parent_assembly.AddComponent(/datum/component/assembly, list(/obj/item/tank/plasma, /obj/item/clothing/head/butt, /obj/item/pipebomb/bomb, /obj/item/reagent_containers/glass/beaker), TYPE_PROC_REF(/obj/item/assembly, add_target_item), TRUE)
	if(istype(parent_assembly.applier, /obj/item/device/multitool) && (src in parent_assembly.additional_components))
		//were on the way to blow everything up, so lets lock in!
		parent_assembly.special_construction_identifier = "canbomb"
		//the rest of the assembly will be handled in obj/item/device/multitool

/obj/item/device/igniter/proc/assembly_overlay_addition(var/manipulated_igniter, var/obj/item/assembly/parent_assembly, var/passed_overlay_offset)
	if(parent_assembly.special_construction_identifier == "canbomb")
		var/image/temp_image = image('icons/obj/items/assemblies.dmi', parent_assembly, "igniter_canbomb")
		parent_assembly.overlays += temp_image
/// ----------------------------------------------


/obj/item/device/igniter/attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	if (ishuman(target))
		var/mob/living/carbon/human/H = target
		if (H:bleeding || (H.organHolder.back_op_stage > BACK_SURGERY_CLOSED && user.zone_sel.selecting == "chest"))
			if (is_special || !src.cautery_surgery(target, user, 15))
				return ..()
		else return ..()
	else return ..()

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
		FLICK("igniter_light", src)
		boutput(user, SPAN_NOTICE("You heat \the [target.name]."))
		target.reagents.temperature_reagents(4000,400)
		last_ignite = world.time

/obj/item/device/igniter/proc/ignite()
	if (src.can_ignite())
		var/turf/location = src.loc

		if (src.master)
			location = src.master.loc

		FLICK("igniter_light", src)
		location = get_turf(location)
		location?.hotspot_expose((isturf(location) ? 3000 : 4000),2000)
		last_ignite = world.time

	return

