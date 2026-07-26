TYPEINFO(/mob/living/critter/robotic/probe)
	start_listen_languages = list(LANGUAGE_ALL)

///Precursor probe for Menhir random events
/mob/living/critter/robotic/probe
	name = "curious visage"
	desc = "It hovers in much the same way that bricks don't."
	icon = 'icons/mob/critter/robotic/precursor_drone.dmi'
	icon_state = "drone"
	voice_name = "strange voice"
	speech_verb_say = "intones"
	speech_verb_exclaim = "reverberates"
	speech_verb_ask = "inquires"
	speech_verb_gasp = "screeches"
	speech_verb_stammer = "stutters"
	death_text = "%src% violently shatters!"
	mat_changename = FALSE
	mat_changedesc = FALSE
	see_invisible = INVIS_CLOAK
	say_language = LANGUAGE_CUBIC
	flags = TABLEPASS
	hand_count = 1

	health_brute = 50
	health_brute_vuln = 0.45
	health_burn = 50
	health_burn_vuln = 0.05
	use_stamina = FALSE
	can_lie = FALSE
	can_burn = FALSE
	isFlying = 1
	base_move_delay = 1.5
	base_walk_delay = 3.5
	var/emissary = FALSE //only distribute gifts if we're here on emissary duty
	var/disturbed = FALSE //we'd like to probe quietly. you get one oops.
	var/bonked = FALSE //being bonked is frustrating.
	var/obj/item/implant/access/data_interface //probes can learn to access things; doesn't come with access by default

	var/tmp/turf/deployment_turf = null

	is_npc = TRUE
	ai_type = /datum/aiHolder/probe
	add_abilities = list(/datum/targetable/critter/probe_access,/datum/targetable/critter/fadeout/probe,/datum/targetable/critter/recall)

	setup_healths()
		add_hh_robot(src.health_brute, src.health_brute_vuln)
		add_hh_robot_burn(src.health_burn, src.health_burn_vuln)

	setup_hands()
		. = ..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb
		HH.name = "gravitational projector"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.limb_name = "gravitational projector"
		HH.can_hold_items = 1

	emp_act()
		return

	was_harmed(var/mob/M as mob, var/obj/item/weapon, var/special, var/intent)
		. = ..()
		src.bonked = TRUE

	New()
		. = ..()
		APPLY_ATOM_PROPERTY(src, PROP_ATOM_GRAVITY_IMMUNE, src)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NO_SELF_HARM, src)
		src.remove_lifeprocess("gravity")
		src.deployment_turf = get_turf(src)
		src.name = "[pick("peculiar","quirky","strange","cold","intricate","odd","curious")] [pick("visage","proxy","interface","attendant")]"
		src.data_interface = new /obj/item/implant/access/infinite(src)
		src.UpdateIcon()

	disposing()
		src.exit_procedure()
		. = ..()

	proc/exit_procedure()
		if(src.emissary && !src.oldmob && !src.disturbed && prob(42)) //drones which complete their probing without being disturbed may leave a gift
			playsound(src.loc, 'sound/effects/ring_happi.ogg', 35, 0, extrarange = 16, pitch = 0.6)
			var/list/gifts = list(/obj/item/reagent_containers/food/snacks/cube = 20, /obj/item/raw_material/cobryl = 12,\
				/obj/item/raw_material/miracle = 2, "artifact" = 1)
			var/thing2make = weighted_pick(gifts)
			if(ispath(thing2make))
				new thing2make(src.loc)
			else
				Artifact_Spawn(src.loc,forceartiorigin = "precursor")

	death(var/gibbed)
		. = ..()
		var/turf/T = get_turf(src.loc)
		for (var/mob/living/L in orange(3,src))
			random_burn_damage(L, rand(4,10))
			if (istype(L))
				L.flash(3 SECONDS)
				L.apply_flash(60, 0, misstep = 35, stamina_damage = 200)
		playsound(src.loc, 'sound/weapons/flashbang.ogg', 30, 1, pitch = 0.7)
		var/obj/shard
		for(var/i = 1 to 3)
			shard = new /obj/item/raw_material/scrap_metal
			shard.setMaterial(getMaterial("cobryl"))
			shard.set_loc(T)
		elecflash(T,2)
		ghostize()
		qdel(src)

	check_attack_resistance(var/obj/item/I, var/mob/attacker)
		return null

	proc/show_edicts() //a code of conduct for those given the privilege of incarnation
		var/edicts = {"<span class='bold notice' style='color: #BEBEFF'>EDICTS<br>
		I. Do not strike against a higher consciousness unless it, or its kind, have struck first.<br>
		II. Take no action to deprive conscious beings of the environment necessary for their survival.<br>
		III. Seek your own path within these bounds. Perception is your tribute to the chorus.<br></span>
		<span class='italic' style='color: #ff6d6d'>These edicts are akin to silicon laws; you are obligated to follow them.<br></span>"}
		boutput(src, edicts)
		return

	verb/cmd_show_edicts()
		set category = "Commands"
		set name = "Show Edicts (Laws)"

		src.show_edicts()
		return

/datum/projectile/laser/precursor/probe
	damage = 6
	shot_number = 5
	shot_sound = 'sound/weapons/laser_b.ogg'
	shot_volume = 50

/datum/limb/gun/energy/probe_light
	proj = new/datum/projectile/laser/precursor/probe
	shots = 1
	current_shots = 1
	cooldown = 1 SECOND
	reload_time = 1 SECOND

///Bigger, exceptionally capable probe powered by what may or may not be a pocket singularity
/mob/living/critter/robotic/probe/arbitor
	name = "cold proxy"
	desc = "A faint shimmer continually courses over its surface."
	icon_state = "arbitor"
	health_burn_vuln = 0
	health_brute_vuln = 0
	hand_count = 2
	ai_retaliates = TRUE
	add_abilities = list(/datum/targetable/critter/probe_access,/datum/targetable/critter/fadeout/probe,/datum/targetable/critter/recall,/datum/targetable/critter/probe_slip)

	setup_hands()
		. = ..()
		var/datum/handHolder/HH = hands[2]
		HH.limb = new /datum/limb/gun/energy/probe_light
		HH.name = "particle reallocator"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handzap"
		HH.limb_name = "lens"
		HH.can_hold_items = 0
		HH.can_attack = 1
		HH.can_range_attack = 1
		active_hand = 2
		set_hand(2)

	exit_procedure()
		return

/mob/living/critter/robotic/probe/update_icon()
	if (isalive(src))
		var/hover = FALSE
		if(src.client || (src.ai && src.ai.enabled)) hover = TRUE
		src.icon_state = "[initial(icon_state)][hover ? null : "-inactive"]"
		if(hover)
			var/image/glow = SafeGetOverlayImage("activeglow", 'icons/mob/critter/robotic/precursor_drone.dmi', "[initial(icon_state)]-glow", MOB_OVERLAY_BASE)
			glow.plane = PLANE_SELFILLUM
			glow.appearance_flags |= RESET_COLOR
			src.UpdateOverlays(glow,"activeglow")
		else
			src.ClearSpecificOverlays("activeglow")
	else
		src.icon_state = "[initial(icon_state)]-dead"
		src.ClearSpecificOverlays("activeglow")

/datum/targetable/critter/probe_access
	name = "Probe Access"
	desc = "Analyze an object's required access codes and recalibrate your internal systems to produce them."
	icon_state = "probe_access"
	cooldown = 5 SECONDS
	targeted = 1
	target_anything = TRUE

	///Certain access codes are highly encrypted and can't be replicated easily.
	var/offlimits_access = list(access_armory, access_maxsec, access_securitylockers, access_syndicate_shuttle)

	cast(atom/target)
		if (..())
			return 1
		if (!istype(target,/obj))
			boutput(holder.owner, SPAN_ALERT("That is not an appopriate category of object."))
			return 1
		if (GET_DIST(holder.owner, target) > 5)
			boutput(holder.owner, SPAN_ALERT("That is too far away to scan."))
			return 1
		if (isrestrictedz(holder.owner.z))
			boutput(holder.owner, SPAN_ALERT("Your systems are unable to attain a signal lock here."))
			return 1
		var/mob/living/critter/robotic/probe/C = holder.owner
		if(!istype(C) || !C.data_interface)
			boutput(holder.owner, SPAN_ALERT("You lack the appropriate systems to do this."))
			return 1
		var/access_interference = FALSE
		var/obj/O = target
		if(O.req_access && length(O.req_access))
			var/codes_replicated = 0
			for(var/access_item in O.req_access)
				if(islist(access_item)) //combo-access scan
					for(var/sub_access in access_item)
						if(!(access_item in offlimits_access))
							C.data_interface.access.access |= sub_access
							codes_replicated++
						else
							access_interference = TRUE
				else //regular-access scan
					if(!(access_item in offlimits_access))
						C.data_interface.access.access |= access_item
						codes_replicated++
					else
						access_interference = TRUE
			if(codes_replicated)
				boutput(C, SPAN_NOTICE("Successfully replicated [codes_replicated] access codes."))
			if(access_interference)
				boutput(C, SPAN_ALERT("Some access codes could not be replicated successfully."))
		else
			boutput(C, SPAN_ALERT("The targeted object lacks access requirements."))
		playsound(get_turf(C), 'sound/machines/scan2.ogg', 45, 1, pitch = 0.8)

/datum/targetable/critter/recall
	name = "Recall"
	desc = "Return to the point of your instantiation."
	cooldown = 60 SECONDS
	icon_state = "probe_recall"

	cast(atom/target)
		if (disabled)
			return 1
		if (..())
			return 1
		var/mob/living/critter/robotic/probe/C = holder.owner
		if(!istype(C))
			boutput(holder.owner, SPAN_ALERT("You lack the appropriate systems to do this."))
			return 1
		if(!C.deployment_turf || !isturf(C.deployment_turf))
			boutput(holder.owner, SPAN_ALERT("Your instantiation point has been lost to you."))
			return 1
		showswirl_out(get_turf(C))
		C.set_loc(C.deployment_turf)
		showswirl(C.deployment_turf)

/datum/targetable/critter/probe_slip
	name = "Slipstream"
	desc = "Alter the cohesion field protecting you, allowing you to slip through doors with ease."
	cooldown = 3 SECONDS
	icon_state = "probe_slip"

	cast(atom/target)
		if (disabled)
			return 1
		if (..())
			return 1
		var/mob/living/critter/robotic/probe/arbitor/C = holder.owner
		if(!istype(C))
			boutput(holder.owner, SPAN_ALERT("You lack the appropriate systems to do this."))
			return 1
		if(C.flags & DOORPASS)
			playsound(C, 'sound/machines/sweep.ogg', 25, 0, pitch = 0.3)
			C.flags &= ~DOORPASS
			C.color = initial(C.color)
		else
			C.flags |= DOORPASS
			playsound(C, 'sound/effects/power_charge.ogg', 30, 0, pitch = 0.5)
			C.color = "#DEDEEE"

#define PROBE_PRIO_OBSERVE 1
#define PROBE_PRIO_ANALYZE 5

/datum/aiHolder/probe
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/probe, list(src))

/datum/aiTask/prioritizer/critter/probe/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/probe_idle, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/probe_a_machine, list(src.holder, src))

///Primary task for probes; poke around and scan things, and reset position if being dragged too far or (for basic probes) attacked
/datum/aiTask/timed/probe_idle
	name = "observing"
	minimum_task_ticks = 12
	maximum_task_ticks = 16
	var/tmp/turf/last_cycle_turf = null

/datum/aiTask/timed/probe_idle/evaluate()
	. = PROBE_PRIO_OBSERVE

/datum/aiTask/timed/probe_idle/on_tick()
	var/mob/living/critter/robotic/probe/beepity = holder.owner
	if(!istype(beepity)) return
	var/turf/currentspot = get_turf(beepity)
	var/preflight = FALSE
	if(last_cycle_turf && beepity.deployment_turf)
		preflight = TRUE
	if(preflight && (GET_DIST(currentspot,last_cycle_turf) > 4 || (beepity.bonked && beepity.type == /mob/living/critter/robotic/probe)))
		var/returning = FALSE
		if(GET_DIST(currentspot,beepity.deployment_turf) > 4) returning = TRUE
		if(!beepity.disturbed)
			if(!beepity.oldmob) //don't do irritation behavior if we were possessed
				beepity.visible_message(SPAN_ALERT("<b>[beepity]<b> makes an irritated sound. It doesn't seem to like being shoved around."))
				playsound(beepity.loc, 'sound/effects/elec_bzzz.ogg', 40, 0, pitch = 0.5)
				beepity.disturbed = TRUE
		else if(!ON_COOLDOWN(beepity, "grouch_when_we_leave", 6 SECONDS))
			beepity.visible_message(SPAN_ALERT("<b>[beepity] emits a searing flash[returning ? " as it teleports away" : null]!<b>"))
			for (var/mob/living/L in orange(3,beepity))
				random_burn_damage(L, rand(4,10))
				if (istype(L))
					L.apply_flash(60, 0, misstep = 35, stamina_damage = 200)
			playsound(beepity.loc, 'sound/weapons/flashbang.ogg', 30, 1)
		if(returning)
			SPAWN(2)
				showswirl_out(get_turf(beepity))
				beepity.set_loc(beepity.deployment_turf)
				showswirl(beepity.deployment_turf)
			last_cycle_turf = beepity.deployment_turf
		beepity.bonked = FALSE
	else
		if(prob(30))
			beepity.move_dir = pick(cardinal)
			beepity.process_move()
			holder?.stop_move()
			holder?.owner.move_dir = null
		else
			beepity.dir = pick(cardinal)
			if(prob(30))
				playsound(beepity.loc, 'sound/machines/scan2.ogg', 40, 0, pitch = 0.6)
		last_cycle_turf = currentspot

/datum/aiTask/timed/probe_idle/on_reset()
	..()
	holder.stop_move()
	last_cycle_turf = null

///Secondary task for probes; select an eligible machine and faff about with its wires a little
/datum/aiTask/timed/targeted/probe_a_machine
	name = "probing"
	minimum_task_ticks = 30
	maximum_task_ticks = 50
	frustration_threshold = 4
	var/list/probeable_types = list(/obj/machinery/power/apc,
		/obj/machinery/vending,
		/obj/machinery/manufacturer,
		/obj/machinery/door/airlock)
	var/list/candidate_list = list()
	///Keep tabs on which turf we're on while we're moving. If it doesn't change while trying to close the distance, we stuck
	var/turf/movetracker = null
	///If we're stuck (or if we're successfully pulsing) let the timing system know
	var/increment_frust = FALSE

/datum/aiTask/timed/targeted/probe_a_machine/evaluate()
	..()
	var/mob/living/critter/robotic/probe/C = holder.owner
	var/probe_prob = 6
	if(C.disturbed) probe_prob = 24
	if(istype(C) && prob(probe_prob))
		for(var/obj/machinery/O in view(6,C))
			for(var/type in src.probeable_types)
				if(istype(O,type))
					src.candidate_list += O
	if(length(src.candidate_list))
		return PROBE_PRIO_ANALYZE
	. = 0

/datum/aiTask/timed/targeted/probe_a_machine/frustration_check()
	. = FALSE
	if(src.increment_frust)
		. = TRUE
		src.increment_frust = FALSE

/datum/aiTask/timed/targeted/probe_a_machine/on_tick()
	var/mob/living/critter/robotic/probe/beepity = holder.owner
	if (!istype(beepity) || HAS_ATOM_PROPERTY(beepity, PROP_MOB_CANTMOVE))
		return

	if(length(beepity.grabbed_by) > 1)
		beepity.resist()

	if(!holder.target)
		holder.target = pick(src.candidate_list)
		logTheThing(LOG_STATION, beepity, "(probe) selected [holder.target] for tampering at [log_loc(holder.target)]")
		playsound(get_turf(beepity), 'sound/machines/sweep.ogg', 20, 0, pitch = 0.3)
		src.candidate_list.Cut() //reset in advance of next probing cycle

	if(holder.target && holder.target.z == beepity.z)
		var/obj/O = holder.target
		if(QDELETED(O))
			return
		var/dist = get_dist(beepity, O)
		if (dist > 1)
			var/turf/movehere = get_turf(O)
			var/whooshed = FALSE
			if(src.movetracker && src.movetracker == get_turf(beepity))
				src.increment_frust = TRUE //only increment frustration if we are trying to move and can't (we're stationary when pulsing)
				if(src.frustration == 0) //try reading access data around us, see if that helps
					for(var/obj/machinery/door/airlock/D in range(1,beepity))
						if(D.req_access)
							for(var/access_item in D.req_access)
								if(islist(access_item)) //combo-access scan
									for(var/sub_access in access_item)
										beepity.data_interface.access.access |= sub_access
								else //regular-access scan
									beepity.data_interface.access.access |= access_item
				if(src.frustration == 2) //let's try something extra
					if(get_area(O) != get_area(beepity)) //we're out of area, do a hop
						var/turf/alt_turf
						for(var/dir in cardinal)
							alt_turf = get_step(O,dir)
							if(!is_blocked_turf(alt_turf))
								showswirl_out(beepity.loc)
								showswirl(alt_turf)
								beepity.set_loc(alt_turf)
								whooshed = TRUE
								break
					else //we're in the same area, try to just float over there
						var/turf/alt_turf
						for(var/dir in cardinal)
							alt_turf = get_step(O,dir)
							if(!is_blocked_turf(alt_turf))
								movehere = alt_turf
								break
			if(!whooshed) holder.move_to(movehere,1)
			src.movetracker = get_turf(beepity)

		if (dist <= 1)
			if(src.movetracker) src.frustration = 1 //go to a "budget" of 3 actions if we did a movement phase
			beepity.dir = get_dir(beepity,O)
			src.movetracker = null
			var/wire = pick(APCWireColorToIndex)
			if(istype(O,/obj/machinery/door/airlock))
				var/obj/machinery/door/airlock/target_airlock = O
				wire = pick(airlockWireColorToIndex)
				if(!target_airlock.isWireColorCut(wire))
					target_airlock.pulse(wire)
			if(istype(O,/obj/machinery/manufacturer))
				var/obj/machinery/manufacturer/target_manufacturer = O
				target_manufacturer.pulse(null, wire)
			if(istype(O,/obj/machinery/vending))
				var/obj/machinery/vending/target_vending = O
				if(!target_vending.isWireColorCut(wire))
					target_vending.pulse(wire)
			if(istype(O,/obj/machinery/power/apc))
				var/obj/machinery/power/apc/target_apc = O
				if(!target_apc.isWireColorCut(wire))
					target_apc.pulse(wire)
			src.increment_frust = TRUE
			playsound(get_turf(beepity), 'sound/machines/scan2.ogg', 25, 1, pitch = 0.8)
	..()

/datum/aiTask/timed/targeted/probe_a_machine/on_reset()
	..()
	holder.stop_move()
	src.frustration = 0
	src.movetracker = null

#undef PROBE_PRIO_OBSERVE
#undef PROBE_PRIO_ANALYZE
