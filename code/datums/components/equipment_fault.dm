#define TOOL_TO_REPAIR_CONTEXT_IDX 1
#define TOOL_TO_REPAIR_TEXT_IDX 2
#define TOOL_TO_REPAIR_SOUND_IDX 3

/datum/component/equipment_fault
	//tool flags to clear
	var/interactions = 0
	var/fault_delay = 5 SECONDS
	var/static/list/tool_to_repair_type = list("[TOOL_CUTTING|TOOL_SNIPPING]"=list(/datum/contextAction/repair/cut, "You cut some vestigial wires from %target%.", 'sound/items/Wirecutter.ogg'),
											   "[TOOL_PRYING]"=list(/datum/contextAction/repair/pry, "You pry things back into place on %target% with all your might.", 'sound/items/Crowbar.ogg'),
											   "[TOOL_PULSING]"=list(/datum/contextAction/repair/pulse, "You pulse %target%. In a general sense.", 'sound/items/penclick.ogg'),
											   "[TOOL_SCREWING]"=list(/datum/contextAction/repair/screw, "You screw in some of the screws on %target%.", 'sound/items/Screwdriver.ogg'),
											   "[TOOL_WELDING]"=list(/datum/contextAction/repair/weld, "You weld %target% carefully.", null),
											   "[TOOL_WRENCHING]"=list(/datum/contextAction/repair/wrench, "You wrench %target%'s bolts. Nice and snug.", 'sound/items/Ratchet.ogg'),
											   "[TOOL_SOLDERING]"=list(/datum/contextAction/repair/solder, "You solder %target%'s loose connections.", 'sound/effects/tinyhiss.ogg'),
											   "[TOOL_WIRING]"=list(/datum/contextAction/repair/wire, "You replace damaged wires in %target%.", 'sound/items/Deconstruct.ogg')
											   )

TYPEINFO(/datum/component/equipment_fault)
	initialization_args = list(
		ARG_INFO("tool_flags", DATA_INPUT_BITFIELD, "Tools Required", TOOL_PULSING | TOOL_SCREWING),
	)

/datum/component/equipment_fault/Initialize(tool_flags)
	. = ..()
	if(!istype(parent, /obj/machinery) && !istype(parent, /obj/submachine))
		return COMPONENT_INCOMPATIBLE
	src.interactions = tool_flags & (TOOL_CUTTING|TOOL_PRYING|TOOL_PULSING|TOOL_SCREWING|TOOL_SNIPPING|TOOL_WELDING|TOOL_WRENCHING|TOOL_SOLDERING|TOOL_WIRING)
	if(!src.interactions)
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ATTACKBY, PROC_REF(ef_attackby))
	RegisterSignal(parent, COMSIG_ATTACKHAND, PROC_REF(ef_attackhand))
	if(istype(parent, /obj/machinery))
		RegisterSignal(parent, COMSIG_MACHINERY_PROCESS, PROC_REF(ef_process))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examined))

/datum/component/equipment_fault/RegisterWithParent()
	. = ..()
	var/atom/movable/object = src.parent
	RegisterHelpMessageHandler(object, PROC_REF(get_help_msg))

/datum/component/equipment_fault/proc/get_help_msg(atom/movable/parent, mob/user, list/lines)
	lines += "[parent] is broken and requires [english_list(src.tool_flags_to_list())] to be repaired."

/datum/component/equipment_fault/proc/tool_flags_to_list()
	var/tool_list = list()
	if (src.interactions & (TOOL_CUTTING|TOOL_SNIPPING))
		tool_list += "cutting"
	if (src.interactions & TOOL_PRYING)
		tool_list += "prying"
	if (src.interactions & TOOL_PULSING)
		tool_list += "pulsing"
	if (src.interactions & TOOL_SCREWING)
		tool_list += "screwing"
	if (src.interactions & TOOL_WELDING)
		tool_list += "welding"
	if (src.interactions & TOOL_WRENCHING)
		tool_list += "wrenching"
	if (src.interactions & TOOL_SOLDERING)
		tool_list += "soldering"
	if (src.interactions & TOOL_WIRING)
		tool_list += "wiring"
	return tool_list

/datum/component/equipment_fault/proc/examined(obj/O, mob/examiner, list/lines)
	lines += "This one looks broken, but it could be repaired."

/datum/component/equipment_fault/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATTACKBY, COMSIG_ATTACKHAND, COMSIG_MACHINERY_PROCESS, COMSIG_ATOM_EXAMINE))
	UnregisterHelpMessageHandler(parent)
	. = ..()

/datum/component/equipment_fault/proc/ef_process(obj/machinery/M, mult)
	ef_perform_fault(M)

/datum/component/equipment_fault/proc/ef_perform_fault(obj/O)
	SHOULD_CALL_PARENT(TRUE)
	if(!ON_COOLDOWN(O, "equip_fault_[ref(src)]",src.fault_delay))
		. = TRUE

/datum/component/equipment_fault/proc/ef_attackby(obj/O, obj/item/I, mob/user = null)
	var/attempt = FALSE
	var/interaction_type = 0
	var/duration = 2 SECONDS
	if( (src.interactions & (TOOL_CUTTING | TOOL_SNIPPING) ) && (iscuttingtool(I) || issnippingtool(I)))
		attempt = TRUE
		interaction_type = TOOL_CUTTING | TOOL_SNIPPING
	else if((src.interactions & TOOL_PULSING) && ispulsingtool(I))
		attempt = TRUE
		interaction_type = TOOL_PULSING
	else if((src.interactions & TOOL_PRYING) && ispryingtool(I))
		attempt = TRUE
		interaction_type = TOOL_PRYING
	else if((src.interactions & TOOL_SCREWING) && isscrewingtool(I))
		attempt = TRUE
		interaction_type = TOOL_SCREWING
	else if((src.interactions & TOOL_WRENCHING) && iswrenchingtool(I))
		attempt = TRUE
		interaction_type = TOOL_WRENCHING
	else if((src.interactions & TOOL_WELDING) && isweldingtool(I))
		if(I:try_weld(user,1))
			attempt = TRUE
			interaction_type = TOOL_WELDING
	else if((src.interactions & TOOL_SOLDERING) && issolderingtool(I))
		attempt = TRUE
		interaction_type = TOOL_SOLDERING
	else if((src.interactions & TOOL_WIRING) && iswiringtool(I))
		attempt = TRUE
		interaction_type = TOOL_WIRING

	if(attempt)
		actions.start(new /datum/action/bar/icon/callback(user, O, duration, PROC_REF(complete_stage), list(user, I, interaction_type), I.icon, I.icon_state,
			null, null, src), user)
	else
		showContextActions(user)
		ef_perform_fault(O)

	return TRUE

/datum/component/equipment_fault/proc/ef_attackhand(obj/O, mob/user)
	if(showContextActions(user))
		boutput(user, SPAN_ALERT("You need to use some tools on \the [O] before it can be fixed."))
		ef_perform_fault(O)
	else
		boutput(user, SPAN_ALERT("You feel as though \the [O] isn't working right..."))
	return TRUE

/datum/component/equipment_fault/proc/showContextActions(mob/user)
	if(!istype(user))
		return
	var/decon_contexts = list()

	for(var/tool in tool_to_repair_type)
		if(src.interactions & text2num(tool) )
			var/datum/contextAction/repair/newcon = tool_to_repair_type[tool][TOOL_TO_REPAIR_CONTEXT_IDX]
			newcon = new newcon()
			decon_contexts += newcon

	. = length(decon_contexts)
	if(.)
		user.showContextActions(decon_contexts, src.parent)


/datum/component/equipment_fault/proc/complete_stage(mob/user as mob, obj/item/W as obj, interaction)
	//clear interaction
	var/interaction_lookup = src.tool_to_repair_type["[interaction]"]

	if(islist(interaction_lookup))
		src.interactions &= ~interaction

		user.removeContextAction(interaction_lookup[TOOL_TO_REPAIR_CONTEXT_IDX])
		user.show_text(replacetext(interaction_lookup[TOOL_TO_REPAIR_TEXT_IDX], "%target%", "\the [src.parent]"), "blue")
		if (interaction_lookup[TOOL_TO_REPAIR_SOUND_IDX])
			playsound(src.parent, interaction_lookup[TOOL_TO_REPAIR_SOUND_IDX], 50, TRUE)

		if(src.interactions == 0)
			UnregisterFromParent()
			boutput(user, SPAN_ALERT("You feel as though you have repaired [src.parent]. Job well done!"))
			if (istype(src.parent, /obj/machinery))
				var/obj/machinery/machine = src.parent
				machine.status &= ~BROKEN
				machine.power_change()
			user.closeContextActions()
			RemoveComponent()
			qdel(src)
		else
			showContextActions(user)

/datum/contextAction/repair
	icon = 'icons/ui/context16x16.dmi'
	name = "Repair with Tool"
	desc = "You shouldn't be reading this, bug."
	icon_state = "wrench"
	var/omni_mode
	var/omni_path
	var/success_text
	var/success_sound

	proc/success_feedback(atom/target, mob/user)
		user.show_text(replacetext(success_text, "%target%", target), "blue")
		if (success_sound)
			playsound(target, success_sound, 50, TRUE)

	proc/omnitool_swap(atom/target, mob/user, obj/item/tool/omnitool/omni)
		if (!(omni_mode in omni.modes))
			return FALSE
		omni.change_mode(omni_mode, user, omni_path)
		user.show_text("You flip [omni] to [name] mode.", "blue")
		sleep(0.5 SECONDS)
		return TRUE

	execute(atom/target, mob/user, obj/item/tool/I)
		if (isobj(target))
			target.Attackby(I, user, null)

	checkRequirements(atom/target, mob/user)
		if(!can_act(user) || !in_interact_range(target, user))
			return FALSE
		. = TRUE

	wrench
		name = "Wrench"
		desc = "Wrenching required to repair."
		icon_state = "wrench"
		omni_mode = OMNI_MODE_WRENCHING
		omni_path = /obj/item/wrench
		success_text = "You wrench %target%'s bolts. Nice and snug."
		success_sound = 'sound/items/Ratchet.ogg'

		execute(atom/target, mob/user)
			for (var/obj/item/I in user.equipped_list())
				if(istype(I, /obj/item/tool/omnitool))
					if(omnitool_swap(target, user, I))
						return ..(target, user, I)
				if (iswrenchingtool(I))
					return ..(target, user, I)

	cut
		name = "Cut"
		desc = "Cutting required to repair."
		icon_state = "cut"
		omni_mode = OMNI_MODE_SNIPPING
		omni_path = /obj/item/wirecutters
		success_text = "You cut some vestigial wires from %target%."
		success_sound = 'sound/items/Wirecutter.ogg'

		execute(atom/target, mob/user)
			for (var/obj/item/I in user.equipped_list())
				if(istype(I, /obj/item/tool/omnitool))
					if(omnitool_swap(target, user,I))
						return ..(target, user, I)
				if (iscuttingtool(I) || issnippingtool(I))
					return ..(target, user, I)
	weld
		name = "Weld"
		desc = "Welding required to repair."
		icon_state = "weld"
		omni_mode = OMNI_MODE_WELDING
		omni_path = /obj/item/weldingtool
		success_text = "You weld %target% carefully."
		success_sound = null // sound handled in try_weld

		execute(atom/target, mob/user)
			for (var/obj/item/I in user.equipped_list())
				if (isweldingtool(I))
					if (I:try_weld(user, 2))
						return ..(target, user, I)
				if(istype(I, /obj/item/tool/omnitool))
					var/obj/item/tool/omnitool/omni = I
					if(omnitool_swap(target, user,I))
						if (omni:try_weld(user, 2))
							return ..(target, user, I)

	pry
		name = "Pry"
		desc = "Prying required to repair. Try a crowbar."
		icon_state = "bar"
		omni_mode = OMNI_MODE_PRYING
		omni_path = /obj/item/crowbar
		success_text = "You pry things back into place on %target% with all your might."
		success_sound = 'sound/items/Crowbar.ogg'

		execute(atom/target, mob/user)
			for (var/obj/item/I in user.equipped_list())
				if(istype(I, /obj/item/tool/omnitool))
					if(omnitool_swap(target, user, I))
						return ..(target, user, I)
				if (ispryingtool(I))
					return ..(target, user, I)
	screw
		name = "Screw"
		desc = "Screwing required to repair."
		icon_state = "screw"
		omni_mode = OMNI_MODE_SCREWING
		omni_path = /obj/item/screwdriver
		success_text = "You screw in some of the screws on %target%."
		success_sound = 'sound/items/Screwdriver.ogg'

		execute(atom/target, mob/user)
			for (var/obj/item/I in user.equipped_list())
				if(istype(I, /obj/item/tool/omnitool))
					if(omnitool_swap(target, user, I))
						return ..(target, user, I)
				if (isscrewingtool(I))
					return ..(target, user, I)

	pulse
		name = "Pulse"
		desc = "Pulsing required to repair. Try a multitool."
		icon_state = "pulse"
		omni_mode = OMNI_MODE_PULSING
		omni_path = /obj/item/device/multitool
		success_text = "You pulse %target%. In a general sense."
		success_sound = 'sound/items/penclick.ogg'

		execute(atom/target, mob/user)
			for (var/obj/item/I in user.equipped_list())
				if(istype(I, /obj/item/tool/omnitool))
					if(omnitool_swap(target, user, I))
						return ..(target, user, I)
				if (ispulsingtool(I))
					return ..(target, user, I)

	solder
		name = "Solder"
		desc = "Soldering required to repair."
		icon_state = "solder"
		success_text = "You solder %target%'s loose connections."
		success_sound = 'sound/effects/tinyhiss.ogg'

		execute(atom/target, mob/user)
			for (var/obj/item/I in user.equipped_list())
				if (issolderingtool(I))
					return ..(target, user, I)

	wire
		name = "Wire"
		desc = "Wire cabling required to repair."
		icon_state = "tray_cable_on"
		success_text = "You replace damaged wires in %target%."
		success_sound = 'sound/items/Deconstruct.ogg'

		execute(atom/target, mob/user)
			for (var/obj/item/I in user.equipped_list())
				if (iswiringtool(I))
					return ..(target, user, I)

/datum/component/equipment_fault/grumble
	var/static/list/sounds_malfunction = list('sound/machines/engine_grump1.ogg','sound/machines/engine_grump2.ogg','sound/machines/engine_grump3.ogg',
	'sound/machines/glitch1.ogg','sound/machines/glitch2.ogg','sound/machines/glitch3.ogg','sound/impact_sounds/Metal_Clang_1.ogg','sound/impact_sounds/Metal_Hit_Heavy_1.ogg','sound/machines/romhack1.ogg','sound/machines/romhack3.ogg')
	var/static/list/text_flipout_adjective = list("an awful","a terrible","a loud","a horrible","a nasty","a horrendous")
	var/static/list/text_flipout_noun = list("noise","racket","ruckus","clatter","commotion","din")

/datum/component/equipment_fault/grumble/ef_perform_fault(obj/O, mult)
	if(..())
		animate_shake(O, 5, rand(3,8),rand(3,8))
		O.visible_message(SPAN_ALERT("[O] makes [pick(src.text_flipout_adjective)] [pick(src.text_flipout_noun)]!"))
		playsound(O, pick(src.sounds_malfunction), 50, 2)

/datum/component/equipment_fault/elecflash
/datum/component/equipment_fault/elecflash/ef_perform_fault(obj/O, mult)
	if(..())
		elecflash(O)

/datum/component/equipment_fault/smoke
/datum/component/equipment_fault/smoke/ef_perform_fault(obj/O, mult)
	if(..())
		var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
		smoke.set_up(1, 0, O.loc)
		smoke.start()


/datum/component/equipment_fault/shorted

/datum/component/equipment_fault/shorted/Initialize(tool_flags)
	. = COMPONENT_INCOMPATIBLE
	if(istype(parent, /obj/machinery))
		. = ..()

/datum/component/equipment_fault/shorted/ef_process(obj/machinery/M, mult)
	. = TRUE
	animate_little_spark(M)
	if (M.power_usage)
		if (machines_may_use_wired_power)
			M.power_change()
			if (!(M.status & NOPOWER) && M.wire_powered)
				M.use_power(M.power_usage, M.power_channel)
				M.power_credit = M.power_usage
				if (zamus_dumb_power_popups)
					new /obj/maptext_junk/power(get_turf(M), change = -M.power_usage * mult, channel = M.power_channel)

				return
		if (!(M.status & NOPOWER))
			M.use_power(M.power_usage * mult, M.power_channel)
			if (zamus_dumb_power_popups)
				new /obj/maptext_junk/power(get_turf(M), change = -M.power_usage * mult, channel = M.power_channel)


/datum/component/equipment_fault/faulty_wiring
	fault_delay = 45 SECONDS
	var/static/list/supported_types = list(/obj/machinery/door/airlock,
										   /obj/machinery/manufacturer,
										   /obj/machinery/vending,
										   /obj/machinery/weapon_stand,
										   /obj/submachine/seed_vendor,
										   /obj/machinery/power/apc)

/datum/component/equipment_fault/faulty_wiring/Initialize(tool_flags)
	. = COMPONENT_INCOMPATIBLE
	for(var/type in src.supported_types)
		if(istype(parent, type))
			. = ..()

/datum/component/equipment_fault/faulty_wiring/ef_perform_fault(obj/O, mult)
	var/wire = pick(APCWireColorToIndex)
	if(..())
		animate_little_spark(O)

		if(istype(O, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/target_airlock = O
			wire = pick(airlockWireColorToIndex)
			if(!target_airlock.isWireColorCut(wire))
				target_airlock.pulse(wire)
		else if(istype(O, /obj/machinery/manufacturer))
			var/obj/machinery/manufacturer/target_manufacturer = O
			target_manufacturer.pulse(null, wire)
		else if(istype(O, /obj/machinery/vending))
			var/obj/machinery/vending/target_vending = O
			if(target_vending.isWireColorCut(wire))
				target_vending.pulse(wire)
		else if(istype(O, /obj/machinery/weapon_stand))
			var/obj/machinery/weapon_stand/target_weapon_stand = O
			if(!target_weapon_stand.isWireColorCut(wire))
				target_weapon_stand.pulse(wire)
		else if(istype(O, /obj/submachine/seed_vendor))
			var/obj/submachine/seed_vendor/target_seed_vendor = O
			if(!target_seed_vendor.isWireColorCut(wire))
				target_seed_vendor.pulse(wire, null)
		else if(istype(O, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/target_apc = O
			if(!target_apc.isWireColorCut(wire))
				target_apc.pulse(wire)
