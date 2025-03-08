/mob/living/critter/flock/drone
	name = "weird glowy thing"
	desc = "Is it broccoli? A glass chicken? A peacock? A green roomba? A shiny discobot? A crystal turkey? A bugbird? A radio pigeon??"
	icon_state = "drone"
	density = TRUE
	hand_count = 3
	can_throw = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	can_help = TRUE
	compute = FLOCK_DRONE_COMPUTE
	death_text = "%src% clatters into a heap of fragments."
	pet_text = list("taps", "pats", "drums on", "ruffles", "touches", "pokes", "prods")
	custom_brain_type = /obj/item/organ/brain/flockdrone
	custom_organHolder_type = /datum/organHolder/critter/flock // for organs that aren't brain
	custom_hud_type = /datum/hud/critter/flock/drone
	var/datum/equipmentHolder/flockAbsorption/absorber
	health_brute = 30
	health_burn = 30
	repair_per_resource = 2
	use_ai_toggle = FALSE

	var/damaged = 0 // used for state management for description showing, as well as preventing drones from screaming about being hit

	butcherable = BUTCHER_ALLOWED

	var/health_absorb_rate = 2 // how much item health is removed per tick when absorbing
	var/resources_per_health = 5 // how much resources we get per item health

	var/floorrunning = FALSE
	var/can_floorrun = TRUE

	var/mob/living/intangible/flock/selected_by = null

	var/glow_color = "#26ffe6a2"

	var/ai_paused = FALSE
	var/wander_count = 0
	var/obj/item/ammo/power_cell/self_charging/flockdrone/cell = null

/mob/living/critter/flock/drone/New(var/atom/location, var/datum/flock/F=null)
	src.ai = new /datum/aiHolder/flock/drone(src)
	..()
	src.add_ability_holder(/datum/abilityHolder/critter/flockdrone)

	SPAWN(3 SECONDS)
		//this is terrible, but diffracting a drone immediately causes a runtime
		src?.zone_sel?.change_hud_style('icons/mob/flock_ui.dmi')

	src.name = "[pick_string("flockmind.txt", "flockdrone_name_adj")] [pick_string("flockmind.txt", "flockdrone_name_noun")]"
	src.real_name = src.flock ? src.flock.pick_name("flockdrone") : src.name
	src.update_name_tag()
	src.flock_name_tag = new
	src.flock_name_tag.set_name(src.real_name)
	src.vis_contents += src.flock_name_tag

	src.RegisterSignal(src, COMSIG_MOB_GRABBED, PROC_REF(do_antigrab))
	if (!F)
		src.flock = get_default_flock()
	if(src.dormant) // we'be been flagged as dormant in the map editor or something
		src.dormantize()
	else
		src.add_simple_light("drone_light", rgb2num(glow_color))
		if(src.client)
			controller = new/mob/living/intangible/flock/trace(src, src.flock)
			src.is_npc = FALSE
		else
			emote("beep")
			say(pick_string("flockmind.txt", "flockdrone_created"), TRUE)
		if (src.flock) //can't do flock?.stats due to http://www.byond.com/forum/post/2841585
			src.flock.stats.drones_made++
	APPLY_ATOM_PROPERTY(src, PROP_MOB_EXAMINE_ALL_NAMES, src)
	APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOCK_THING, src)
	src.AddComponent(/datum/component/flock_protection, FALSE, TRUE, FALSE, FALSE)

/mob/living/critter/flock/drone/proc/do_antigrab(source, obj/item/grab/grab)
	if(src.ai_paused) //wake up when grabbed
		src.wake_from_ai_pause()
	SPAWN(1.5 SECONDS)
		if (QDELETED(src) || !isalive(src) || src.dormant || QDELETED(grab) || !grab.affecting || !grab.assailant)
			return
		if (istype(grab.assailant, /mob/living/critter/flock/drone))
			var/mob/living/critter/flock/drone/F = grab.assailant
			if (F.flock == src.flock)
				return
		playsound(src, 'sound/effects/electric_shock.ogg', 40, TRUE, -3)
		boutput(src, SPAN_FLOCKSAY("<b>\[SYSTEM: Anti-grapple countermeasures deployed.\]</b>"))
		var/mob/living/L = grab.assailant
		L.shock(src, 5000)
		qdel(grab) //in case they don't fall over from our shock

/mob/living/critter/flock/drone/gib()
	qdel(src.cell)
	..()

/mob/living/critter/flock/drone/disposing()
	if (src.flock)
		if (controller)
			src.release_control_abrupt()
		flock_speak(null, "Connection to drone [src.real_name] lost.", src.flock)
	if (src.selected_by)
		var/mob/living/intangible/flock/selector = src.selected_by
		var/datum/abilityHolder/flockmind/AH = selector.abilityHolder
		AH.drone_controller.cast(src)
	src.selected_by = null
	src.remove_simple_light("drone_light")
	qdel(src.cell)
	src.cell = null
	..()

/mob/living/critter/flock/drone/describe_state()
	var/list/state = ..()
	state["update"] = "drone"
	state["name"] = src.real_name
	if(src.is_npc)
		if(istype(src.ai.current_task))
			state["task"] = src.ai.current_task.name
		else
			state["task"] = ""
	else if(src.ai_paused)
		state["task"] = "hibernating"
	else
		state["task"] = "controlled"
		state["controller_ref"] = "\ref[controller]"
	. = state

/mob/living/critter/flock/drone/Login()
	..()
	src.client?.set_color()
	if(isnull(controller))
		if(src.flock)
			controller = new/mob/living/intangible/flock/trace(src, src.flock)
		src.is_npc = FALSE
	if(src.dormant)
		src.undormantize()
	if(src.ai_paused)
		src.wake_from_ai_pause()
	if(src.flock)
		src.flock.showAnnotations(src)

/mob/living/critter/flock/drone/proc/take_control(mob/living/intangible/flock/pilot, give_alert = TRUE)
	if(!pilot)
		return
	if(controller)
		boutput(pilot, SPAN_ALERT("This drone is already being controlled."))
		return
	//if we are in the tutorial don't let traces take control, and for minds run the tutorial check
	if (src.flock.flockmind?.tutorial && (pilot != src.flock.flockmind || !src.flock.flockmind.tutorial.PerformAction(FLOCK_ACTION_DRONE_CONTROL, src)))
		return
	if (src.selected_by)
		if (src.selected_by != pilot)
			boutput(pilot, SPAN_ALERT("This drone is receiving a command!"))
			return
		var/datum/abilityHolder/flockmind/AH = src.selected_by.abilityHolder
		AH.drone_controller.cast(src)
	src.controller = pilot
	src.wake_from_ai_pause()
	src.ai.stop_move()
	src.is_npc = FALSE
	src.dormant = FALSE
	src.anchored = UNANCHORED
	pilot.atom_hovered_over = null

	var/datum/mind/mind = pilot.mind
	if (mind)
		mind.transfer_to(src)
	else
		if (pilot.client)
			var/key = pilot.client.key
			pilot.client.mob = src
			src.mind = new /datum/mind()
			src.mind.ckey = ckey
			src.mind.key = key
			src.mind.current = src
			ticker.minds += src.mind

	pilot.set_loc(src)
	pilot.boutput_relay_mob = src
	controller = pilot
	src.flock_name_tag.set_info_tag(src.controller.real_name)
	src.client?.set_color()
	//hack to make night vision apply instantly
	var/datum/lifeprocess/sight/sight_process = src.lifeprocesses[/datum/lifeprocess/sight]
	sight_process?.Process()
	src.hud?.update_intent()
	var/datum/abilityHolder/composite/composite = src.abilityHolder
	composite.addHolderInstance(pilot.abilityHolder, TRUE)
	if (istype(pilot, /mob/living/intangible/flock/flockmind))
		flock.addAnnotation(src, FLOCK_ANNOTATION_FLOCKMIND_CONTROL)
	else
		flock.addAnnotation(src, FLOCK_ANNOTATION_FLOCKTRACE_CONTROL)
		var/mob/living/intangible/flock/trace/flocktrace = pilot
		if (flocktrace.dying)
			src.addOverlayComposition(/datum/overlayComposition/flockmindcircuit/flocktrace_death)
			src.updateOverlaysClient(src.client)
	if (src.flock.relay_in_progress)
		var/obj/flock_structure/relay/relay = locate() in src.flock.structures
		if (relay)
			src.AddComponent(/datum/component/tracker_hud/flock, relay)
	if (give_alert)
		boutput(src, SPAN_FLOCKSAY("<b>\[SYSTEM: Control of drone [src.real_name] established.\]</b>"))

/mob/living/critter/flock/drone/proc/release_control(give_alerts = TRUE)
	src.flock?.hideAnnotations(src)
	src.is_npc = TRUE
	if (give_alerts && src.flock.z_level_check(src))
		emote("beep")
		say(pick_string("flockmind.txt", "flockdrone_player_kicked"), TRUE)
	if(src.client && !controller)
		if(src.flock)
			controller = new/mob/living/intangible/flock/trace(src, src.flock)
		else
			src.ghostize()
	if(controller)
		if (src.floorrunning)
			src.end_floorrunning(TRUE)

		if (src.flock.z_level_check(src))
			controller.set_loc(get_turf(src))
		else
			src.move_controller_to_station()

		var/datum/mind/mind = src.mind
		if (mind)
			mind.transfer_to(controller)
		else
			if (src.client)
				var/key = src.client.key
				src.client.mob = controller
				controller.mind = new /datum/mind()
				controller.mind.ckey = ckey
				controller.mind.key = key
				controller.mind.current = controller
				ticker.minds += controller.mind
		controller.boutput_relay_mob = null
		var/datum/abilityHolder/composite/composite = src.abilityHolder
		composite.removeHolder(/datum/abilityHolder/flockmind)
		var/datum/abilityHolder/flockmind/AH = src.controller.abilityHolder
		AH.updateText()
		if (istype(controller, /mob/living/intangible/flock/flockmind))
			flock?.removeAnnotation(src, FLOCK_ANNOTATION_FLOCKMIND_CONTROL)
		else
			flock?.removeAnnotation(src, FLOCK_ANNOTATION_FLOCKTRACE_CONTROL)
			var/mob/living/intangible/flock/trace/flocktrace = src.controller
			if (flocktrace.dying)
				src.removeOverlayComposition(/datum/overlayComposition/flockmindcircuit/flocktrace_death)
				src.updateOverlaysClient(src.client)
		if (give_alerts && src.flock.z_level_check(src))
			flock_speak(null, "Control of drone [src.real_name] surrendered.", src.flock)

		controller = null
		src.update_health_icon()
		src.flock_name_tag.set_info_tag(capitalize(src.ai.current_task?.name))
		var/datum/component/tracker_hud/flock/tracker = src.GetComponent(/datum/component/tracker_hud/flock)
		tracker?.RemoveComponent()
	if(!src.flock)
		src.dormantize()

/mob/living/critter/flock/drone/proc/release_control_abrupt(give_alert = TRUE)
	src.flock?.hideAnnotations(src)
	src.is_npc = TRUE
	if(src.client && !controller)
		if(src.flock)
			controller = new/mob/living/intangible/flock/trace(src, src.flock)
		else
			src.ghostize()
	if(!controller)
		return
	if (src.floorrunning)
		src.end_floorrunning(TRUE)
	if (src.flock.z_level_check(src))
		controller.set_loc(get_turf(src))
	else
		src.move_controller_to_station()
	var/datum/mind/mind = src.mind
	if (mind)
		mind.transfer_to(controller)
	else if (src.client)
		var/key = src.client.key
		src.client.mob = controller
		controller.mind = new /datum/mind()
		controller.mind.ckey = ckey
		controller.mind.key = key
		controller.mind.current = controller
		ticker.minds += controller.mind
	controller.boutput_relay_mob = null
	if (give_alert)
		boutput(controller, SPAN_FLOCKSAY("<b>\[SYSTEM: Control of drone [src.real_name] ended abruptly.\]</b>"))
	var/datum/abilityHolder/composite/composite = src.abilityHolder
	composite.removeHolder(/datum/abilityHolder/flockmind)
	var/datum/abilityHolder/flockmind/AH = src.controller.abilityHolder
	AH.updateText()
	if (istype(controller, /mob/living/intangible/flock/flockmind))
		flock?.removeAnnotation(src, FLOCK_ANNOTATION_FLOCKMIND_CONTROL)
	else
		flock?.removeAnnotation(src, FLOCK_ANNOTATION_FLOCKTRACE_CONTROL)
		var/mob/living/intangible/flock/trace/flocktrace = src.controller
		if (flocktrace.dying)
			src.removeOverlayComposition(/datum/overlayComposition/flockmindcircuit/flocktrace_death)
			src.updateOverlaysClient(src.client)
	controller = null
	src.update_health_icon()
	src.flock_name_tag.set_info_tag(capitalize(src.ai.current_task.name))
	if(!src.flock)
		src.dormantize()

/mob/living/critter/flock/drone/dormantize()
	src.icon_state = "drone-dormant"
	src.remove_simple_light("drone_light")
	src.UnregisterSignal(src, COMSIG_MOB_GRABBED)

	if (!src.flock)
		..()
		return

	src.flock.hideAnnotations(src)

	if (src.controller)
		src.move_controller_to_station()

		var/datum/mind/mind = src.mind
		if (mind)
			mind.transfer_to(controller)
		else
			if (src.client)
				var/key = src.client.key
				src.client.mob = controller
				controller.mind = new /datum/mind()
				controller.mind.ckey = ckey
				controller.mind.key = key
				controller.mind.current = controller
				ticker.minds += controller.mind
		controller.boutput_relay_mob = null
		boutput(controller, SPAN_FLOCKSAY("<b>\[SYSTEM: Connection to drone [src.real_name] lost.\]</b>"))
		controller = null
	src.is_npc = TRUE // to ensure right flock_speak message
	flock_speak(src, "Error: Out of signal range. Disconnecting.", src.flock)
	src.is_npc = FALSE // turns off ai
	..()

/mob/living/critter/flock/drone/proc/move_controller_to_station()
	if (src.flock?.getComplexDroneCount() > 1)
		for (var/mob/living/critter/flock/drone/F as anything in src.flock.units[/mob/living/critter/flock/drone])
			if (istype(F) && F != src)
				src.controller.set_loc(get_turf(F))
				break
	else
		src.controller.set_loc(pick_landmark(LANDMARK_LATEJOIN))

/mob/living/critter/flock/drone/proc/undormantize()
	src.dormant = FALSE
	src.canmove = TRUE
	src.anchored = UNANCHORED
	src.damaged = -1
	src.check_health() // handles updating the icon to something more appropriate
	src.visible_message(SPAN_NOTICE("<b>[src]</b> begins to glow and hover."))
	src.set_a_intent(INTENT_HELP)
	src.add_simple_light("drone_light", rgb2num(glow_color))
	src.RegisterSignal(src, COMSIG_MOB_GRABBED, PROC_REF(do_antigrab))
	if(src.client)
		if(src.flock)
			controller = new/mob/living/intangible/flock/trace(src, src.flock)
		src.is_npc = FALSE
	else
		src.is_npc = TRUE

/mob/living/critter/flock/drone/proc/pause_ai()
	if(src.controller || src.dormant || !src.flock) //can't pause_ai when controlled or dormant, this shouldn't ever happen. Also can't pause without a flock.
		src.wander_count = 0
		return
	src.ai.stop_move()
	src.ai_paused = TRUE
	src.icon_state = "drone-dormant"
	src.remove_simple_light("drone_light")
	src.flock_name_tag.set_info_tag("Hibernating")
	flock_speak(src, "No tasks in queue. Allocating higher functions to compute generation.", src.flock)
	src.is_npc = FALSE
	src.compute = FLOCK_DRONE_COMPUTE_HIBERNATE
	src.flock.total_compute += src.compute - FLOCK_DRONE_COMPUTE
	src.flock.update_computes()
	src.flock.hideAnnotations(src)
	src.visible_message(SPAN_NOTICE("<b>[src]</b> goes dim and settles on the floor."))

/mob/living/critter/flock/drone/proc/wake_from_ai_pause()
	if(!src.ai_paused || src.dormant) //can't wake up if you're dormant
		return
	if (isdead(src) || isnull(src.flock)) //also can't wake up if you're dead
		return
	src.compute = FLOCK_DRONE_COMPUTE
	src.flock.total_compute -= FLOCK_DRONE_COMPUTE_HIBERNATE - src.compute
	src.flock.update_computes()
	src.ai_paused = FALSE
	src.anchored = UNANCHORED
	src.wander_count = 0
	src.damaged = -1 //force icon refresh
	src.check_health() // handles updating the icon to something more appropriate
	src.visible_message(SPAN_NOTICE("<b>[src]</b> begins to glow and hover."))
	src.add_simple_light("drone_light", rgb2num(glow_color))
	if(src.client && !src.controller)
		controller = new/mob/living/intangible/flock/trace(src, src.flock)
		src.flock_name_tag.set_info_tag(src.controller.real_name)
		src.is_npc = FALSE
	else if (!src.controller)
		src.is_npc = TRUE
		src.flock_name_tag.set_info_tag(capitalize(src.ai.current_task.name))
		flock_speak(src, "Awoken. Resuming task queue.", src.flock)

/mob/living/critter/flock/drone/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	var/special_desc = SPAN_FLOCKSAY(SPAN_BOLD("###=- Ident confirmed, data packet received."))
	if(src.controller)
		special_desc += "<br>[SPAN_BOLD("ID:")] <b>[src.controller.real_name]</b> (controlling [src.real_name])"
	else
		special_desc += "<br>[SPAN_BOLD("ID:")] [src.real_name]"
	var/cog_status = "" //this was becoming one of those long unreadable ternaries
	if(!isalive(src)) cog_status = "DEAD"
	else if(src.dormant) cog_status = "ABSENT"
	else if(src.is_npc) cog_status = "TORPID"
	else if(src.ai_paused) cog_status = "HIBERNATING"
	else cog_status = "SAPIENT"

	special_desc += {"<br>[SPAN_BOLD("Flock:")] [src.flock ? src.flock.name : "none"]
		<br>[SPAN_BOLD("Resources:")] [src.resources]
		<br>[SPAN_BOLD("System Integrity:")] [max(0, round(src.get_health_percentage() * 100))]%
		<br>[SPAN_BOLD("Cognition:")] [cog_status]"}
	if (src.is_npc && istype(src.ai.current_task))
		special_desc += "<br>[SPAN_BOLD("Task:")] [uppertext(src.ai.current_task.name)]"
	special_desc += "<br>[SPAN_BOLD("###=-")]</span>"
	return special_desc

/mob/living/critter/flock/drone/proc/changeFlock(var/flockName)
	src.flock?.removeDrone(src)
	if(flocks[flockName])
		src.flock = flocks[flockName]
		src.flock.registerUnit(src, TRUE)
	controller?.flock = flocks[flockName]
	boutput(src, SPAN_NOTICE("You are now part of the [SPAN_BOLD("[src.flock.name]")] flock."))

/mob/living/critter/flock/drone/is_spacefaring()
	return TRUE

/mob/living/critter/flock/drone/special_movedelay_mod(delay,space_movement,aquatic_movement)
	. = delay
	var/turf/T = get_turf(src)
	if (istype(T, /turf/space))
		. += 2

/mob/living/critter/flock/drone/Cross(atom/movable/mover)
	if(isflockmob(mover))
		return TRUE
	else if (istype(mover, /obj/flock_structure/cage))
		animate_flock_passthrough(src)
		return TRUE
	else
		return ..()

/mob/living/critter/flock/click(atom/target, list/params)
	. = ..()
	if (istype(target, /obj/machinery/door/feather) && !in_interact_range(target, src))
		var/obj/machinery/door/feather/door = target
		if (door.density)
			door.open()
		else
			door.close()

/mob/living/critter/flock/drone/DblClick(location, control, params)
	. = ..()
	var/mob/living/intangible/flock/F = usr
	if(istype(F) && F.flock && F.flock == src.flock)
		var/datum/abilityHolder/flockmind/holder = F.abilityHolder
		if(holder?.drone_controller.drone == src) //if click behaviour has highlighted this drone for control
			holder.drone_controller.cast(src, FALSE) //deselect it
		if (!isdead(src) && !src.controller && !src.selected_by) // second two checks are for preventing message spam
			src.take_control(usr)

/mob/living/critter/flock/drone/MouseDrop_T(mob/living/target, mob/user)
	if(!target || !user)
		return
	if(target == user)
		var/mob/living/intangible/flock/F = user
		if(istype(F) && F.flock && F.flock == src.flock)
			src.take_control(user)
		else
			..() // ghost observe
	else
		..()

/mob/living/critter/flock/drone/mouse_drop(atom/over_object, src_location, over_location, over_control, params)
	. = ..()
	if (isdead(src) || isnull(src.flock))
		return
	if (!isflockmob(usr))
		return
	if (src.selected_by)
		boutput(usr, SPAN_ALERT("This drone is receiving a command!"))
		return
	var/mob/living/intangible/flock/flock_controller = usr
	if (istype(usr, /mob/living/critter/flock))
		var/mob/living/critter/flock/flock_mob = usr
		flock_controller = flock_mob.controller
	if (!isalive(flock_controller))
		return // flock mind/trace is stunned or dead
	if (flock_controller.flock != src.flock)
		return // this isn't our drone
	if (istype(flock_controller, /mob/living/intangible/flock/trace) && flock_controller.flock?.flockmind?.tutorial)
		return
	src.flock.flockmind?.tutorial?.PerformSilentAction(FLOCK_ACTION_DRAGMOVE, src)
	src.rally(over_location)

/mob/living/critter/flock/drone/hotkey(var/name)
	switch (name)
		if("equip")
			src.equip_click(absorber)
		else
			return ..()

/mob/living/critter/flock/drone/setup_equipment_slots()
	absorber = new /datum/equipmentHolder/flockAbsorption(src)
	equipment += absorber

/mob/living/critter/flock/drone/setup_hands()
	..()
	var/datum/handHolder/HH = hands[1]
	HH.limb = new /datum/limb/flock_grip
	HH.name = "grip tool"
	HH.icon = 'icons/mob/flock_ui.dmi'
	HH.icon_state = "griptool"
	HH.limb_name = HH.name

	HH = hands[2]
	HH.limb = new /datum/limb/flock_converter
	HH.name = "nanite spray"
	HH.icon = 'icons/mob/flock_ui.dmi'
	HH.icon_state = "converter"
	HH.limb_name = HH.name
	HH.can_hold_items = FALSE

	HH = hands[3]
	HH.limb = new /datum/limb/gun/flock_stunner(hands[3])
	HH.name = "incapacitor"
	HH.icon = 'icons/mob/flock_ui.dmi'
	HH.icon_state = "incapacitor"
	HH.limb_name = HH.name
	HH.can_hold_items = FALSE
	HH.can_range_attack = TRUE

/mob/living/critter/flock/drone/specific_emotes(var/act, var/param = null, var/voluntary = FALSE)
	switch (act)
		if("stare")
			if (src.emote_check(voluntary, 50))
				return "<b>[src]</b> stares intently[(param ? " at [param]." : ".")]"
		if ("whistle", "beep", "burp")
			if (src.emote_check(voluntary, 50))
				playsound(src, "sound/misc/flockmind/flockdrone_beep[pick("1","2","3","4")].ogg", 30, 1, extrarange = (voluntary ? 0 : -10))
				return "<b>[src]</b> [act]s[(param ? " at [param]." : ".")]"
		if ("scream", "growl", "abeep", "grump")
			if (src.emote_check(voluntary, 50))
				playsound(src, "sound/misc/flockmind/flockdrone_grump[pick("1","2","3")].ogg", 30, 1, extrarange = (voluntary ? 0 : -10))
				return "<b>[src]</b> beeps grumpily[(param? " at [param]!" : "!")]"
		if ("fart") // i cannot ignore my heritage any longer
			if (src.emote_check(voluntary, 50))
				var/fart_message = pick_string("flockmind.txt", "flockdrone_fart")
				playsound(src, 'sound/misc/flockmind/flockdrone_fart.ogg', 60, TRUE, channel=VOLUME_CHANNEL_EMOTE)
				return "<b>[src]</b> [fart_message]"
		if ("laugh")
			if (src.emote_check(voluntary, 50))
				return "<b>[src]</b> caws heartily[(param? " at [param]!" : "!")]"
	return null

/mob/living/critter/flock/drone/specific_emote_type(var/act)
	switch (act)
		if ("whistle", "beep", "burp", "scream", "growl", "abeep", "grump", "fart")
			return 2
	return ..()

/mob/living/critter/flock/drone/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return TRUE
	if (src.floorrunning && src.resources >= 1)
		src.pay_resources(1)
		if (src.resources < 1)
			src.end_floorrunning(TRUE)
	if (!src.dormant && !src.flock?.z_level_check(src) && src.z != Z_LEVEL_NULL)
		if (src.flock || !src.client)
			src.dormantize()
			return
	if (src.dormant)
		return
	if(src.ai_paused)
		//wake up if you're on fire
		if(getStatusDuration("burning"))
			src.wake_from_ai_pause()
		//wake up if there are enemies in view
		if(src.flock) //if we have a flock, use the enemies list, otherwise just use non-flock mobs in view
			var/list/mob/nearby_enemies = viewers(src) // TODO: technically ignores pods here
			for(var/mob/enemy in src.flock.enemies)
				if(enemy in nearby_enemies)
					src.wake_from_ai_pause()
					break
		else
			for(var/mob/living/carbon/human/enemy in viewers(src))
				if(!isdead(enemy))
					src.wake_from_ai_pause()
					break
	else if(src.wander_count > FLOCK_DRONE_WANDER_PAUSE_COUNT && !src.absorber.item)
		src.pause_ai()

/mob/living/critter/flock/drone/process_move(keys)
	if(keys & KEY_RUN && src.resources >= 1)
		if(!src.floorrunning && isfeathertile(src.loc))
			if (length(src.grabbed_by))
				for(var/obj/item/grab/g in src.grabbed_by)
					if (!(g.state == GRAB_PASSIVE || g.state == GRAB_PIN)) // in the rare case you do pin a flockdrone
						src.can_floorrun = FALSE
						return ..()
			src.can_floorrun = TRUE

			if (istype(src.loc, /turf/simulated/floor/feather))
				var/turf/simulated/floor/feather/floor = src.loc
				if (floor.broken)
					return ..()
				if(!floor.on)
					floor.on()
			else
				var/turf/simulated/wall/auto/feather/wall = src.loc
				if (wall.broken)
					return ..()
				if (!wall.on)
					wall.on()

			src.start_floorrunning()
	else if(keys && src.floorrunning)
		src.end_floorrunning(TRUE)
	return ..()

/mob/living/critter/flock/drone/proc/start_floorrunning()
	if(src.floorrunning)
		return
	src.flock?.flockmind?.tutorial?.PerformSilentAction(FLOCK_ACTION_FLOORRUN, src)
	playsound(src, 'sound/misc/flockmind/flockdrone_floorrun.ogg', 30, TRUE, extrarange = -10)
	src.floorrunning = TRUE
	src.set_density(FALSE)
	src.throws_can_hit_me = FALSE
	src.set_pulling(null)
	src.can_throw = FALSE
	if (src.pulled_by)
		var/mob/M = src.pulled_by
		M.set_pulling(null)

	for (var/obj/item/grab/g in src.equipped_list())
		if (!istype(g, /obj/item/grab/block))
			qdel(g)

	if (length(src.grabbed_by))
		for(var/obj/item/grab/grab_grabbed_by in src.grabbed_by)
			if (!istype(grab_grabbed_by, /obj/item/grab/block))
				qdel(grab_grabbed_by)
	animate_flock_floorrun_start(src)

/mob/living/critter/flock/drone/proc/end_floorrunning(check_lights = FALSE)
	if(!src.floorrunning)
		return
	playsound(src, 'sound/misc/flockmind/flockdrone_floorrun.ogg', 30, TRUE, extrarange = -10)
	src.floorrunning = FALSE
	src.set_density(TRUE)
	src.throws_can_hit_me = TRUE
	src.can_throw = TRUE
	if (check_lights)
		if (istype(src.loc, /turf/simulated/floor/feather))
			var/turf/simulated/floor/feather/floor = src.loc
			if (floor.on && !floor.connected)
				floor.off()
		else if (istype(src.loc, /turf/simulated/wall/auto/feather))
			var/turf/simulated/wall/auto/feather/wall = src.loc
			if (wall.on)
				wall.off()
	animate_flock_floorrun_end(src)
	if (flock_is_blocked_turf(get_turf(src.loc)))
		for(var/turf/T in getneighbours(src.loc))
			if(!flock_is_blocked_turf(T))
				src.set_loc(T)
				return


/mob/living/critter/flock/drone/restrained()
	return ..() || src.floorrunning

/mob/living/critter/flock/drone/movement_delay()
	if(floorrunning)
		return 0.6
	else
		return ..()

/mob/living/critter/flock/drone/proc/add_resources(amount)
	src.resources += amount
	if (src.flock)
		src.flock.flockmind?.tutorial?.PerformSilentAction(FLOCK_ACTION_GAIN_RESOURCES, src.resources)
		src.flock.stats.resources_gained += amount
	var/datum/abilityHolder/composite/composite = src.abilityHolder
	var/datum/abilityHolder/critter/flockdrone/aH = composite.getHolder(/datum/abilityHolder/critter/flockdrone)
	aH.updateResources(src.resources)

/mob/living/critter/flock/drone/pay_resources(amount)
	..()
	var/datum/abilityHolder/composite/composite = src.abilityHolder
	var/datum/abilityHolder/critter/flockdrone/aH = composite.getHolder(/datum/abilityHolder/critter/flockdrone)
	aH.updateResources(src.resources)

/mob/living/critter/flock/drone/Cross(atom/movable/mover, turf/target, height=0, air_group=0)
	if(floorrunning)
		return TRUE
	else
		return ..()

/mob/living/critter/flock/drone/Move(turf/NewLoc, direct)
	if(!canmove) return
	if(floorrunning)
		// do our custom MOVE THROUGH ANYTHING stuff
		// copypasted from intangible.dm
		src.set_dir(get_dir(src, NewLoc))
		if(!isturf(src.loc))
			src.set_loc(get_turf(src))
		if(NewLoc)
			if (NewLoc.density)
				if (istype(NewLoc, /turf/simulated/wall/auto/feather))
					var/turf/simulated/wall/auto/feather/flockwall = NewLoc
					if (flockwall.broken)
						return
				else
					return
			if (!istype(NewLoc, /turf/simulated/floor/feather))
				for (var/obj/O in NewLoc.contents)
					if (istype(O, /obj/mesh/grille) || istype(O, /obj/window) || (istype(O, /obj/machinery/door) && O.density))
						return
			src.set_loc(NewLoc)
			return
		if((direct & NORTH) && src.y < world.maxy)
			src.y++
		if((direct & SOUTH) && src.y > 1)
			src.y--
		if((direct & EAST) && src.x < world.maxx)
			src.x++
		if((direct & WEST) && src.x > 1)
			src.x--
	else
		// do normal movement
		return ..(NewLoc, direct)

/mob/living/critter/flock/drone/was_harmed(mob/M, obj/item/weapon, special, intent)
	if (!M) return
	if(src.ai_paused)
		src.wake_from_ai_pause()
	if (isflockmob(M)) return
	if (!isdead(src) && src.flock)
		if (!src.flock.isEnemy(M))
			if (src.flock.isIgnored(M))
				say("[pick_string("flockmind.txt", "flockdrone_betrayal")] [M]", TRUE)
			else
				emote("scream")
				say("[pick_string("flockmind.txt", "flockdrone_enemy")] [M]", TRUE)
		src.flock.updateEnemy(M)
	. = ..()

/mob/living/critter/flock/drone/bullet_act(var/obj/projectile/P)
	if(floorrunning)
		return FALSE
	if (!..())
		return

/mob/living/critter/flock/drone/TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss)
	..()
	src.check_health()
	if (brute <= 0 && burn <= 0 && tox <= 0)
		return
	if(src.ai_paused)
		src.wake_from_ai_pause()
	var/prev_damaged = src.damaged
	if(!isdead(src) && src.is_npc)
		if(prev_damaged != src.damaged && src.damaged > 0) // damaged to a new state
			src.emote("scream")
			say("[pick_string("flockmind.txt", "flockdrone_hurt")]", TRUE)
			src.ai.interrupt()

/mob/living/critter/flock/drone/proc/check_health()
	if(isdead(src))
		return
	var/percent_damage = src.get_health_percentage() * 100
	switch(percent_damage)
		if(75 to 100)
			if(damaged == 0) return
			damaged = 0
			if(!dormant && !ai_paused)
				src.icon_state = "drone"
		if(50 to 74)
			if(damaged == 1) return
			damaged = 1
			desc = "[initial(desc)]<br>[SPAN_ALERT("\The [src] looks lightly [pick("dented", "scratched", "beaten", "wobbly")].")]"
			if(!dormant && !ai_paused)
				src.icon_state = "drone-d1"
		if(25 to 49)
			if(damaged == 2) return
			damaged = 2
			desc = "[initial(desc)]<br>[SPAN_ALERT("\The [src] looks [pick("quite", "pretty", "rather")] [pick("dented", "busted", "messed up", "haggard")].")]"
			if(!dormant && !ai_paused)
				src.icon_state = "drone-d2"
		if(0 to 24)
			if(damaged == 3) return
			damaged = 3
			desc = "[initial(desc)]<br>[SPAN_ALERT("\The [src] looks [pick("really", "totally", "very", "all sorts of", "super")] [pick("mangled", "busted", "messed up", "broken", "haggard", "smashed up", "trashed")].")]"
			if(!dormant && !ai_paused)
				src.icon_state = "drone-d2"
	return

/mob/living/critter/flock/drone/get_tracked_examine_atoms()
	return ..() + src.flock.structures

/mob/living/critter/flock/drone/death(var/gibbed)
	if (src.selected_by)
		var/mob/living/intangible/flock/selector = src.selected_by
		var/datum/abilityHolder/flockmind/AH = selector.abilityHolder
		AH.drone_controller.cast(src)

	if(src.controller)
		src.release_control()
	if(!src.dormant)
		if(src.is_npc)
			emote("scream")
			say(pick_string("flockmind.txt", "flockdrone_death"), TRUE)
			src.is_npc = FALSE // stop ticking the AI for this mob
		else
			emote("scream")
			say("\[System notification: drone lost.\]", TRUE)
	var/obj/item/organ/heart/flock/core = src.organHolder.get_organ("heart")
	if(core)
		core.resources = src.resources
		src.pay_resources(src.resources) // just in case any weirdness happens let's pre-empt the dupe bug
	..()
	src.icon_state = "drone-dead"
	src.set_density(FALSE)
	src.desc = "[initial(desc)]<br>[SPAN_ALERT("\The [src] is a dead, broken heap.")]"
	src.remove_simple_light("drone_light")
	src.UnregisterSignal(src, COMSIG_MOB_GRABBED)

/mob/living/critter/flock/drone/ghostize()
	if(src.controller)
		src.release_control_abrupt()
	else
		..()

/mob/living/critter/flock/drone/butcher(var/mob/M)
	var/num_pieces = rand(3, 6)
	var/my_turf = get_turf(src)
	var/atom/movable/B
	for(var/i=1 to num_pieces)
		switch(rand(100))
			if(0 to 45)
				B = new /obj/item/raw_material/scrap_metal
				B.set_loc(my_turf)
				B.setMaterial(getMaterial("gnesis"))
			if(46 to 90)
				B = new /obj/item/raw_material/shard
				B.set_loc(my_turf)
				B.setMaterial(getMaterial("gnesisglass"))
			if(91 to 100)
				B = new /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/flock(my_turf)

	playsound(src, 'sound/impact_sounds/Glass_Shatter_2.ogg', 30, TRUE, extrarange = -10)
	if (src.organHolder)
		src.organHolder.drop_organ("brain",src.loc)
		src.organHolder.drop_organ("heart",src.loc)
	src.ghostize()
	qdel(src)

/mob/living/critter/flock/drone/proc/split_into_bits()
	var/num_bits = 3

	walk(src, 0)
	if(src.floorrunning)
		src.end_floorrunning()
	src.ai?.die()
	emote("scream")
	say("\[System notification: drone diffracting.\]", TRUE)
	if(src.controller)
		src.release_control()
	var/datum/flock/F = src.flock
	src.flock?.removeDrone(src)

	var/turf/T = get_turf(src)

	// get possible turfs to move flockbits, to create a spread out effect
	var/list/candidate_turfs = getneighbours(src)
	for(var/turf/n in candidate_turfs)
		if(flock_is_blocked_turf(n))
			candidate_turfs -= n
	candidate_turfs += T //ensure there's always at least the turf we're stood on

	animate_flock_drone_split(src)

	var/mob/living/critter/flock/bit/B
	for(var/i=1 to num_bits)
		B = new(T, F)
		SPAWN(0.2 SECONDS)
			B.set_loc(pick(candidate_turfs))

	// so that drone's resources aren't lost
	if (src.resources > 0)
		var/obj/item/flockcache/cache = new(T)
		cache.resources = src.resources

	SPAWN(0.1 SECONDS) // make sure the animation finishes
		src.ghostize()
		qdel(src)


/mob/living/critter/flock/drone/update_inhands()
	return

/mob/living/critter/flock/drone/proc/create_egg()
	if(isnull(src.flock))
		boutput(src, SPAN_ALERT("You do not have flockmind authorization to synthesize eggs."))
		return
	if(src.flock.getComplexDroneCount() >= FLOCK_DRONE_LIMIT)
		boutput(src, SPAN_ALERT("Flock complexity too high, unable to support additional drones."))
		return
	if(src.resources < src.flock.current_egg_cost)
		boutput(src, SPAN_ALERT("Not enough resources (you need [src.flock.current_egg_cost])."))
		return
	if(src.floorrunning)
		boutput(src, SPAN_ALERT("You can't do that while floorrunning."))
		return
	var/turf/simulated/floor/feather/nest = get_turf(src)
	if(!istype(nest, /turf/simulated/floor/feather))
		boutput(src, SPAN_ALERT("The egg needs to be placed on flock tile."))
		return
	actions.start(new/datum/action/bar/flock_egg(), src)

/mob/living/critter/flock/drone/list_ejectables()
	. = list()
	if(src.organHolder)
		var/obj/item/organ/brain/B = src.organHolder.get_organ("brain")
		if(B)
			. += B // always drop brain
	// handle our contents, such as whatever item we're trying to eat or what we're holding
	for(var/atom/movable/O in src.contents)
		if(istype(O, /atom/movable/screen))
			continue // no UI elements please
		. += O

/mob/living/critter/flock/drone/message_admin_on_attack()
	return

// TODO: do this better
/mob/living/critter/flock/drone/change_eye_blurry(var/amount, var/cap = 0)
	if (amount < 0)
		return ..()
	else
		return TRUE

/mob/living/critter/flock/drone/take_eye_damage(var/amount, var/tempblind = 0)
	if (amount < 0)
		return ..()
	else
		return TRUE

/mob/living/critter/flock/drone/take_ear_damage(var/amount, var/tempdeaf = 0)
	if (amount < 0)
		return ..()
	else
		return TRUE

/// Sets the AI to tutorial mode, disabling all tasks except manual orders
/mob/living/critter/flock/drone/proc/set_tutorial_ai(value)
	if (value)
		src.ai = new /datum/aiHolder/flock/drone/tutorial(src)
	else
		src.ai = new /datum/aiHolder/flock/drone(src)

/mob/living/critter/flock/drone/emp_act()
	SEND_SIGNAL(src.cell, COMSIG_CELL_USE, src.cell.max_charge/2)

/////////////////////////////////////////////////////////////////////////////////
// FLOCKDRONE SPECIFIC LIMBS AND EQUIPMENT SLOTS
/////////////////////////////////////////////////////////////////////////////////

/datum/limb/flock_grip // an ordinary hand but with some modified messages
	attack_strength_modifier = 0.2
	can_gun_grab = FALSE
	var/attack_hit_prob = 50
	var/grab_mob_hit_prob = 30
	var/dam_low = 4 // 2 is human baseline
	var/dam_high = 7 // 9 is human baseline

	var/list/attack_messages = list(\
		list("prods", "with a pointy spike"),\
		list("jabs", "with a sharp instrument"),\
		list("pinches", "with a pair of spikes"),\
		list("smacks", "with an array of cylinders"),\
		list("pecks", "with an oversized beak-like structure"),\
		list("thwaps", "with a glowy mesh of fibres"),\
		list("whips", "with its elaborate sensory tail mesh"),\
		list("clobbers", "with a flurry of blunt instruments"),\
		)

/datum/limb/flock_grip/grab(mob/target, var/mob/living/critter/flock/drone/user)
	if (!user || !target)
		return FALSE
	if (isintangible(target))
		return FALSE
	if(prob(grab_mob_hit_prob))
		..()
	else
		boutput(user, SPAN_ALERT("The grip tool can't get a good grip on [target]!"))
		user.lastattacked = get_weakref(target)

/datum/limb/flock_grip/harm(mob/target, var/mob/living/critter/flock/drone/user)
	if (!user || !target)
		return FALSE
	if (istype(target, /mob/living/critter/flock))
		boutput(user, SPAN_ALERT("The grip tool refuses to harm this, jamming briefly."))
	else
		if (!target.melee_attack_test(user))
			return
		if (prob(src.attack_hit_prob) || is_incapacitated(target)|| target.restrained())
			var/datum/attackResults/msgs = user.calculate_melee_attack(target, dam_low, dam_high, 0, can_punch = 0, can_kick = 0)
			user.attack_effects(target, user.zone_sel?.selecting)
			var/list/specific_attack_messages = pick(attack_messages)
			msgs.base_attack_message = "<span class='combat bold'>[user] [specific_attack_messages[1]] [target] [specific_attack_messages[2]]!</span>"
			msgs.flush(FALSE)
			user.lastattacked = get_weakref(target)
		else
			user.visible_message("<span class='combat bold'>[user] attempts to prod [target] but misses!</span>")
			user.lastattacked = get_weakref(target)
/////////////////////////////////////////////////////////////////////////////////

/datum/limb/flock_converter

/datum/limb/flock_converter/attack_hand(atom/target, var/mob/living/critter/flock/drone/user, var/reach, params, location, control)
	if (!holder)
		return
	if(check_target_immunity( target ))
		return
	if (!istype(user))
		return

	if (user.flock?.flockmind?.tutorial && !user.flock.flockmind?.tutorial.PerformAction(FLOCK_ACTION_START_CONVERSION, target))
		return
	if(ismob(target) || iscritter(target)) //gods how I hate /obj/critter
		if (!isflockmob(target))
			src.try_cage(target, user)
			return

	if(user.a_intent == INTENT_HARM)
		if(HAS_ATOM_PROPERTY(target,PROP_ATOM_FLOCK_THING))
			if(!isflockdeconimmune(target))
				actions.start(new /datum/action/bar/flock_decon(target), user)
				return

	// CONVERT TURF
	if(!isturf(target) && (!HAS_ATOM_PROPERTY(target,PROP_ATOM_FLOCK_THING) || istype(target, /obj/lattice/flock)))
		target = get_turf(target)

	if(istype(target, /turf) && !istype(target, /turf/simulated) && !istype(target, /turf/space))
		boutput(user, SPAN_ALERT("Something about this structure prevents it from being assimilated."))
	else if(isfeathertile(target))
		if(istype(target, /turf/simulated/floor/feather))
			if(user.a_intent == INTENT_DISARM)
				var/turf/simulated/floor/feather/flocktarget = target
				for (var/atom/O in flocktarget.contents)
					if (istype(O, /obj/mesh/flock/barricade))
						boutput(user, SPAN_ALERT("There's already a barricade here."))
						return
					if ((O.density && !isflockmob(O)) || istype(O, /obj/flock_structure/ghost))
						boutput(user, SPAN_ALERT("This tile has something that blocks barricade construction!"))
						return
				if (user.resources < FLOCK_BARRICADE_COST)
					boutput(user, SPAN_ALERT("Not enough resources to construct a barricade (you need [FLOCK_BARRICADE_COST])."))
				else
					actions.start(new/datum/action/bar/flock_construct(target), user)
	else if(user.resources < FLOCK_CONVERT_COST && istype(target, /turf))
		boutput(user, SPAN_ALERT("Not enough resources to convert (you need [FLOCK_CONVERT_COST])."))
	else
		if(istype(target, /turf))
			if (!flockTurfAllowed(target))
				boutput(user, SPAN_ALERT("Something about this area resists your attempt to convert it"))
				return
			if (user.flock)
				for (var/name in user.flock.busy_tiles)
					if (user.flock.busy_tiles[name] == target && name != user.real_name)
						boutput(user, SPAN_ALERT("This tile has already been reserved!"))
						return
				actions.start(new/datum/action/bar/flock_convert(target), user)
			else
				actions.start(new/datum/action/bar/flock_convert(target), user)

	//depositing
	if (istype(target, /obj/flock_structure/ghost))
		if (user.resources <= 0)
			boutput(user, SPAN_ALERT("No resources available for construction."))
		else
			actions.start(new /datum/action/bar/flock_deposit(target), user)
		return
//help intent actions
	if(user.a_intent == INTENT_HELP)
		if (!HAS_ATOM_PROPERTY(target, PROP_ATOM_FLOCK_THING) && !istype(target, /turf/simulated/floor/feather))
			return
		var/found_target = FALSE
		if (istype(target, /obj/flock_structure))
			var/obj/flock_structure/structure = target
			if (structure.health < structure.health_max)
				found_target = TRUE
		else
			switch(target.type)
				if (/obj/machinery/door/feather)
					var/obj/machinery/door/feather/flockdoor = target
					if(flockdoor.health < flockdoor.health_max)
						found_target = TRUE
				if (/turf/simulated/floor/feather)
					var/turf/simulated/floor/feather/floor = target
					if (floor.health < initial(floor.health))
						found_target = TRUE
				if (/turf/simulated/wall/auto/feather)
					var/turf/simulated/wall/auto/feather/wall = target
					if (wall.health < wall.max_health)
						found_target = TRUE
				if (/obj/window/feather)
					var/obj/window/feather/window = target
					if (window.health < window.health_max)
						found_target = TRUE
				if (/obj/window/auto/feather)
					var/obj/window/auto/feather/window = target
					if (window.health < window.health_max)
						found_target = TRUE
				if (/obj/mesh/flock/barricade)
					var/obj/mesh/flock/barricade/barricade = target
					if (barricade.health < barricade.health_max)
						found_target = TRUE
				if (/obj/storage/closet/flock)
					var/obj/storage/closet/flock/closet = target
					if (closet.health_attack < closet.health_max)
						found_target = TRUE
		if (!found_target)
			boutput(user, SPAN_ALERT("The target is in perfect condition!"))
		else
			if(user.resources <= 0)
				boutput(user, SPAN_ALERT("You have no resources available for repairing."))
			else
				actions.start(new /datum/action/bar/flock_repair(target), user)

/datum/limb/flock_converter/help(mob/target, var/mob/living/critter/flock/drone/user)
	if(!target || !user)
		return
	var/mob/living/critter/flock/F = target
	if(istype(F))
		if(F.get_health_percentage() >= 1.0)
			boutput(user, SPAN_ALERT("[capitalize(he_or_she_dont_or_doesnt(F))] need to be repaired, [hes_or_shes(F)] in perfect condition."))
			return
		if (isdead(F))
			return
		if(user.resources <= 0)
			boutput(user, SPAN_ALERT("You have no resources available for repairing."))
		else
			actions.start(new/datum/action/bar/flock_repair(F), user)
	else
		src.attack_hand(target, user)

//why doesn't attack_hand trigger on mobs aaa
/datum/limb/flock_converter/disarm(atom/target, var/mob/living/critter/flock/drone/user)
	src.attack_hand(target, user)

/datum/limb/flock_converter/grab(atom/target, var/mob/living/critter/flock/drone/user)
	src.attack_hand(target, user)

/datum/limb/flock_converter/proc/try_cage(atom/target, var/mob/living/critter/flock/drone/user)
	if(!target || !user)
		return
	if(!(isliving(target) || iscritter(target)))
		return
	if(isintangible(target))
		return
	// IMPRISON TARGET
	if(isflockmob(target))
		boutput(user, SPAN_ALERT("The imprisonment matrix doesn't work on flockdrones."))
		return
	else if(istype(target.loc, /obj/flock_structure/cage))
		boutput(user, SPAN_ALERT("[hes_or_shes(target)] already imprisoned, you can't double-imprison [him_or_her(target)]!"))
	else
		actions.start(new/datum/action/bar/flock_entomb(target), user)
		return TRUE

/datum/limb/flock_converter/harm(atom/target, var/mob/living/critter/flock/drone/user)
	if(!target || !user)
		return
	if(istype(target, /mob/living/critter/flock/drone))
		var/mob/living/critter/flock/drone/f = target
		if(isdead(f))
			actions.start(new/datum/action/bar/icon/butcher_living_critter(f,f.butcher_time), user)
		else
			boutput(user, SPAN_ALERT("You can't butcher a living flockdrone!"))
	else
		src.attack_hand(target, user)

/////////////////////////////////////////////////////////////////////////////////

/datum/limb/gun/flock_stunner // fires a stunning bolt on a cooldown which doesn't affect flockdrones
	proj = new/datum/projectile/energy_bolt/flockdrone
	shots = 1
	current_shots = 1
	cooldown = 12
	reload_time = 12
	reloading_str = "recharging"
	var/cost = 10
	var/obj/item/ammo/power_cell/self_charging/flockdrone/cell = new

/datum/limb/gun/flock_stunner/New()
	..()
	src.cell.set_loc(src.holder.holder)
	var/mob/living/critter/flock/drone/drone = src.holder.holder
	if (istype(drone))
		drone.cell = src.cell
	src.holder.holder.contents |= cell
	RegisterSignal(src.cell, COMSIG_UPDATE_ICON, PROC_REF(update_overlay))

/datum/limb/gun/flock_stunner/proc/update_overlay()
	var/mob/living/critter/flock/drone/flockdrone = holder.holder
	var/datum/hud/critter/flock/drone/flockhud = flockdrone.hud
	flockhud.set_stunner_charge(src.cell.get_charge() / src.cell.max_charge)

/datum/limb/gun/flock_stunner/shoot(mob/living/target, mob/living/user, point_blank = FALSE)
	if(!target || !user)
		return
	if (isflockmob(target) && point_blank)
		return
	if (src.cell.get_charge() < src.cost)
		return
	. = ..()
	if (.)
		SEND_SIGNAL(src.cell, COMSIG_CELL_USE, src.cost)

/datum/limb/gun/flock_stunner/help(mob/living/target, mob/living/user)
	src.point_blank(target, user)

/datum/limb/gun/flock_stunner/grab(mob/living/target, mob/living/user)
	src.point_blank(target, user)

/datum/projectile/energy_bolt/flockdrone
	name = "incapacitor bolt"
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "stunbolt"
	cost = 20
	stun = 25
	damage = 4
	dissipation_rate = 3
	dissipation_delay = 4
	sname = "stunbolt"
	shot_sound = 'sound/weapons/laser_f.ogg'
	shot_number = 1
	window_pass = TRUE
	brightness = 1
	color_red = 0.5
	color_green = 0.9
	color_blue = 0.8
	disruption = 10
	hit_ground_chance = 50
/////////////////////////////////////////////////////////////////////////////////

/datum/equipmentHolder/flockAbsorption
	show_on_holder = 0
	name = "disintegration reclaimer"
	type_filters = list(/obj/item)
	icon = 'icons/mob/flock_ui.dmi'
	icon_state = "absorber"
	var/instant_absorb = FALSE
	var/ignore_amount = FALSE

/datum/equipmentHolder/flockAbsorption/can_equip(var/obj/item/I)
	if (istype(I, /obj/item/grab) || istype(I, /obj/item/currency/spacebux))
		return FALSE
	return ..()

/datum/equipmentHolder/flockAbsorption/on_equip()
	if (item.burning)
		item.combust_ended()

	var/mob/living/critter/flock/drone/F = holder
	src.instant_absorb = item.amount > 1 && round(F.resources_per_health * item.health) == 0
	src.ignore_amount = istype(item, /obj/item/currency/spacecash)

	item.inventory_counter?.show_count()

	holder.visible_message(SPAN_ALERT("[holder] starts absorbing [item]!"), SPAN_NOTICE("You place [item] into [src.name] and begin breaking it down."))
	animate_flockdrone_item_absorb(item)
	src.holder.changeStatus("flock_absorbing", item.health/F.health_absorb_rate SECONDS)

/datum/equipmentHolder/flockAbsorption/on_unequip()
	src.holder.delStatus("flock_absorbing")
	if(item)
		animate(item)
		if(item.material)
			item.setMaterialAppearance(item.material)
	..()

/datum/equipmentHolder/flockAbsorption/proc/tick(mult)
	var/mob/living/critter/flock/drone/flock_owner = holder
	if (!istype(flock_owner)) return
	var/obj/item/I = flock_owner.absorber.item
	if (!I)
		return
	var/health_absorbed = min((flock_owner.health_absorb_rate * mult), I.health)
	var/resources_to_gain = flock_owner.resources_per_health * health_absorbed
	if (I.max_stack > 1)
		resources_to_gain /= (I.max_stack / 10)
	resources_to_gain = max(1, resources_to_gain)
	resources_to_gain = round(resources_to_gain)
	if (flock_owner.absorber.instant_absorb && !flock_owner.absorber.ignore_amount)
		boutput(flock_owner, SPAN_ALERT("[I] is weak enough that it breaks apart instantly!"))
		flock_owner.add_resources(resources_to_gain * I.amount)
	else
		I.health -= health_absorbed
		flock_owner.add_resources(resources_to_gain)
		if (I.health > 0 || (I.health == 0 && I.amount > 1 && !flock_owner.absorber.ignore_amount))
			if (!ON_COOLDOWN(src.holder, "absorber_noise", 1 SECOND))
				playsound(flock_owner, "sound/effects/sparks[rand(1, 6)].ogg", 30, 1, extrarange = -10)
		if (I.health > 0)
			return
		if (I.amount > 1 && !flock_owner.absorber.ignore_amount)
			I.health = get_initial_item_health(I.type)
			I.change_stack_amount(-1)
			return

	playsound(flock_owner, 'sound/impact_sounds/Energy_Hit_1.ogg', 30, TRUE, extrarange = -10)

	if(length(I.contents))
		var/anything_tumbled = FALSE
		for (var/obj/item/W as anything in I.storage?.get_contents())
			I.storage.transfer_stored_item(W, get_turf(flock_owner), user = flock_owner)
		for(var/obj/O in I.contents)
			if(istype(O, /obj/item))
				O.set_loc(flock_owner.loc)
				anything_tumbled = TRUE
			else
				qdel(O)
		if(anything_tumbled)
			flock_owner.visible_message(SPAN_ALERT("The contents of [I] tumble out of [flock_owner]."),
				SPAN_ALERT("The contents of [I] tumble out of you."),
				SPAN_ALERT("You hear things fall onto the floor."))

	if (istype(I, /obj/item/flockcache))
		var/obj/item/flockcache/C = I
		flock_owner.add_resources(C.resources)
		boutput(flock_owner, SPAN_NOTICE("You break down the resource cache, adding [SPAN_BOLD("[C.resources]")] resource[C.resources > 1 ? "s" : null] to your own. "))
	else if(istype(I, /obj/item/organ/heart/flock))
		var/obj/item/organ/heart/flock/F = I
		if (F.resources == 0)
			boutput(flock_owner, SPAN_NOTICE("[F]'s resource cache is assimilated, but contains no resources."))
		else
			flock_owner.add_resources(F.resources)
			boutput(flock_owner, SPAN_NOTICE("You assimilate [F]'s resource cache, adding [SPAN_BOLD("[F.resources]")] resource[F.resources > 1 ? "s" : null] to your own."))
	else
		boutput(flock_owner, SPAN_NOTICE("You finish converting [I] into resources."))
	qdel(I)
	flock_owner.absorber.item = null
