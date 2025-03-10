TYPEINFO(/obj/item/device/multitool)
	mats = list("crystal" = 1,
				"conductive_high" = 1)
/obj/item/device/multitool
	name = "multitool"
	desc = "You can use this on airlocks or APCs to try to hack them without cutting wires."
	icon = 'icons/obj/items/tools/multitool.dmi'
	inhand_image_icon = 'icons/mob/inhand/tools/multitool.dmi'
	icon_state = "multitool"
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	tool_flags = TOOL_PULSING | TOOL_ASSEMBLY_APPLIER
	w_class = W_CLASS_SMALL
	force = 5
	throwforce = 5
	throw_range = 15
	throw_speed = 3
	desc = "An electrical multitool. It can generate small electrical pulses and read the wattage of power cables. It is most commonly used when interfacing with airlock and APC systems on the station."
	m_amt = 50
	g_amt = 20
	custom_suicide = TRUE

	New()
		..()
		src.setItemSpecial(/datum/item_special/elecflash)
		RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_APPLY, PROC_REF(assembly_application))
		RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP, PROC_REF(assembly_setup))
		RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_ON_TARGET_ADDITION, PROC_REF(assembly_target_addition))
		RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_ON_MISC_ADDITION, PROC_REF(assembly_component_addition))

	disposing()
		. = ..()
		UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_APPLY)
		UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP)
		UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_ON_TARGET_ADDITION)
		UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_ON_MISC_ADDITION)


	grey
		desc = "You can use this on airlocks or APCs to try to hack them without cutting wires. This one comes with a handy grey stripe."
		icon_state = "multitool-grey"

	orange
		desc = "You can use this on airlocks or APCs to try to hack them without cutting wires. This one comes with a nifty orange stripe."
		icon_state = "multitool-orange"

/obj/item/device/multitool/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return 0
	user.visible_message(SPAN_ALERT("<b>[user] connects the wires from the multitool onto [his_or_her(user)] tongue and presses pulse. It's pretty shocking to look at.</b>"))
	user.TakeDamage("head", 0, 160)
	return 1

/obj/item/device/multitool/afterattack(atom/target, mob/user , flag)
	. = ..()
	get_and_return_netid(target,user)

/// ----------- Trigger/Applier/Target-Assembly-Related Procs -----------

/obj/item/device/multitool/assembly_get_part_help_message(var/dist, var/mob/shown_user, var/obj/item/assembly/parent_assembly)
	if(!parent_assembly.target)
		return " You can add a plasma tank onto this assembly in order to modify it further."
	if(parent_assembly.special_construction_identifier == "canbomb")
		//when were at this stage, the igniter is inserted, so we need to check if either the cabling is in there or not
		var/is_cabled = FALSE
		for(var/obj/item/checked_item in parent_assembly.additional_components)
			if(istype(checked_item, /obj/item/cable_coil))
				is_cabled = TRUE
		if(is_cabled)
			return " You can use this on a canister to build a canbomb. You can use other items, like a signaler or atmospheric scanner, to modify this further"
		return " You can use 6 units of cable coils to continue to the construction of the canbomb detonator"
	// there is a target, the only one able at this point is the plasma tank
	if(istype(parent_assembly.trigger, /obj/item/device/timer))
		return " You can use an igniter to start the assembly of a canbomb detonator."


/obj/item/device/multitool/proc/assembly_setup(var/manipulated_multitool, var/obj/item/assembly/parent_assembly, var/mob/user, var/is_build_in)
	//since we have different multitools
	parent_assembly.applier_icon_prefix = "multitool"
	if (!parent_assembly.target)
		// trigger-multitool-Assembly + plasmatank -> trigger-multitool-plasmatank-bomb
		parent_assembly.AddComponent(/datum/component/assembly/consumes_other, list(/obj/item/tank/plasma), TYPE_PROC_REF(/obj/item/assembly, add_target_item), TRUE)

/obj/item/device/multitool/proc/assembly_application(var/manipulated_multitool, var/obj/item/assembly/parent_assembly, var/obj/assembly_target)
	if(!assembly_target)
		//if there is no target, we don't do anything
		return
	else
		if(istype(assembly_target, /obj/item/tank/plasma))
			var/obj/item/tank/plasma/manipulated_plasma_tank = assembly_target
			manipulated_plasma_tank.ignite()
			qdel(parent_assembly)
			return

/obj/item/device/multitool/proc/assembly_target_addition(var/manipulated_multitool, var/obj/item/assembly/parent_assembly, var/mob/user, var/obj/item/new_target)
	//canbomb require a specific assembly to be build
	if(istype(parent_assembly.trigger, /obj/item/device/timer) && istype(new_target, /obj/item/tank/plasma))
		// timer/multitool/plasmatank-assembly + igniter -> detonator-assembly
		parent_assembly.AddComponent(/datum/component/assembly/consumes_other, list(/obj/item/device/igniter), TYPE_PROC_REF(/obj/item/assembly, add_additional_component), TRUE)

/obj/item/device/multitool/proc/assembly_component_addition(var/manipulated_multitool, var/obj/item/assembly/parent_assembly, var/mob/user, var/obj/item/new_component)
	var/list/canbomb_valid_additions = list(/obj/item/instrument/bikehorn,
											/obj/item/instrument/vuvuzela,
											/obj/item/cell,
											/obj/item/device/brainjar,
											/obj/item/device/flash,
											/obj/item/device/analyzer/atmospheric)
	var/max_amount_of_canbomb_attachments = 3
	if(parent_assembly.special_construction_identifier == "canbomb")
		if(istype(new_component, /obj/item/device/igniter))
			// detonator assembly + cable -> cabled detonator assembly
			parent_assembly.AddComponent(/datum/component/assembly/consumes_other, list(/obj/item/cable_coil), TYPE_PROC_REF(/obj/item/assembly, add_additional_component), TRUE)
		else
			//in any other case, since we locked canbomb assembly, it's either the cable coil, some canbomb specifics or paper
			//so we add the components for the complete assembly accordingly
			parent_assembly.AddComponent(/datum/component/assembly, list(/obj/machinery/portable_atmospherics/canister), TYPE_PROC_REF(/obj/item/assembly, create_canbomb), TRUE)
			//now we build a list of stuff we can add to the canbomb as additions
			var/has_paper = FALSE
			var/has_signaler = FALSE
			var/amount_of_attachments = 0
			for(var/obj/item/checked_item in parent_assembly.additional_components)
				if(istype(checked_item, /obj/item/paper))
					has_paper = TRUE
				if(istype(checked_item, /obj/item/device/radio/signaler))
					has_signaler = TRUE
				for(var/checked_type in canbomb_valid_additions)
					if(istype(checked_item, checked_type))
						amount_of_attachments += 1
			var/list/potential_additions = list()
			if(!has_paper)
				potential_additions += /obj/item/paper
			if(!has_signaler)
				potential_additions += /obj/item/device/radio/signaler
			if(amount_of_attachments < max_amount_of_canbomb_attachments)
				potential_additions |= canbomb_valid_additions
			if(length(potential_additions) > 0)
				parent_assembly.AddComponent(/datum/component/assembly/consumes_other, potential_additions, TYPE_PROC_REF(/obj/item/assembly, add_additional_component), TRUE)


/// ----------------------------------------------


/proc/get_and_return_netid(atom/target, mob/user)
	//Get the NETID from bots/computers/everything else
	//There's a lot of local vars so this is somewhat evil code
	//Tried to keep it self contained, read only, and tried to do the appropriate checks
	var/net_id
	//And the wifi frequency
	var/frequency
	//turf and data_terminal for powernet check
	var/turf/T = get_turf(target.loc)
	var/obj/machinery/power/data_terminal/test_link = locate() in T
	var/obj/item/implant/tracking/targetimplant = locate() in target.contents
	//net_id block, except computers, where we do it all in one go
	if (hasvar(target, "net_id"))
		net_id = target:net_id
	else if (hasvar(target, "botnet_id"))
		net_id = target:botnet_id
	else if (istype(target,/obj/machinery/computer3))
		var/obj/computer = target
		var/obj/item/peripheral/network/peripheral = locate(/obj/item/peripheral/network) in computer.contents
		var/obj/item/peripheral/network/radio/radioperipheral = locate(/obj/item/peripheral/network/radio) in computer.contents
		var/obj/item/peripheral/network/omni/omniperipheral = locate(/obj/item/peripheral/network/omni) in computer.contents
		if (peripheral)
			net_id = peripheral.net_id
		if (radioperipheral)
			frequency = radioperipheral.frequency
		//laptops are special too!
		if(omniperipheral)
			frequency = omniperipheral.frequency
	else if (targetimplant)
		net_id = targetimplant.net_id
		frequency = targetimplant.pda_alert_frequency

	if(net_id)
		boutput(user, SPAN_ALERT("NETID#[net_id]"))

	//frequencies
	var/freq_num = 1
	for(var/datum/component/packet_connected/radio/comp as anything in target.GetComponents(/datum/component/packet_connected/radio))
		frequency = comp.get_frequency()
		var/freq_name = comp.connection_id ? uppertext(comp.connection_id + "_FREQ") : "FREQ[freq_num++]"
		var/RX = comp.send_only ? "" : " RX"
		boutput(user, SPAN_ALERT("[freq_name]#[frequency] TX[RX]"))

	//Powernet Test Block
	//If we have a net_id but no wireless frequency, we're probably a powernet device
	if(isturf(T) && net_id && !frequency)
		if(!test_link || !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
			boutput(user, SPAN_ALERT("ERR#NOLINK"))
	if (test_link)
		if (length(test_link.powernet?.cables) < 1)
			boutput(user, SPAN_ALERT("ERR#NOTATERM"))
