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
	compute = 10
	death_text = "%src% clatters into a heap of fragments."
	pet_text = list("taps", "pats", "drums on", "ruffles", "touches", "pokes", "prods")
	custom_brain_type = /obj/item/organ/brain/flockdrone
	custom_organHolder_type = /datum/organHolder/critter/flock // for organs that aren't brain
	custom_hud_type = /datum/hud/critter/flock/drone
	var/datum/equipmentHolder/flockAbsorption/absorber
	health_brute = 30
	health_burn = 30

	///Custom contextActions list so we can handle opening them ourselves
	var/list/datum/contextAction/contexts = list()

	var/damaged = 0 // used for state management for description showing, as well as preventing drones from screaming about being hit

	butcherable = TRUE

	var/health_absorb_rate = 2 // how much item health is removed per tick when absorbing
	var/resources_per_health = 4 // how much resources we get per item health

	var/floorrunning = FALSE
	var/can_floorrun = TRUE

	// antigrab powers
	var/antigrab_counter = 0
	var/antigrab_fires_at = 2

	var/glow_color = "#26ffe6a2"

/mob/living/critter/flock/drone/New(var/atom/location, var/datum/flock/F=null)
	src.ai = new /datum/aiHolder/flock/drone(src)

	..()
	abilityHolder = new /datum/abilityHolder/critter/flockdrone(src)

	SPAWN(3 SECONDS)
		//this is terrible, but diffracting a drone immediately causes a runtime
		src?.zone_sel?.change_hud_style('icons/mob/flock_ui.dmi')

	src.name = "[pick_string("flockmind.txt", "flockdrone_name_adj")] [pick_string("flockmind.txt", "flockdrone_name_noun")]"
	src.real_name = src.flock ? src.flock.pick_name("flockdrone") : src.name
	src.update_name_tag()

	if(!F || src.dormant) // we'be been flagged as dormant in the map editor or something
		src.dormantize()
	else
		src.add_simple_light("drone_light", rgb2num(glow_color))
		if(src.client)
			controller = new/mob/living/intangible/flock/trace(src, src.flock)
			src.is_npc = FALSE
		else
			emote("beep")
			say(pick_string("flockmind.txt", "flockdrone_created"))
	var/datum/contextLayout/experimentalcircle/layout = new
	layout.center = TRUE
	src.contextLayout = layout
	src.contexts += new /datum/contextAction/flockdrone/control
	for (var/type as anything in childrentypesof(/datum/contextAction/flockdrone))
		if (type == /datum/contextAction/flockdrone/control)
			continue
		src.contexts += new type
	APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOCK_THING, src)
	src.AddComponent(/datum/component/flock_protection, FALSE, FALSE, FALSE, FALSE)

/mob/living/critter/flock/drone/disposing()
	if (src.flock)
		if (controller)
			src.release_control_abrupt()
		flock_speak(null, "Connection to drone [src.real_name] lost.", src.flock)
	src.remove_simple_light("drone_light")
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
	else
		state["task"] = "controlled"
		state["controller_ref"] = "\ref[controller]"
	. = state


/mob/living/critter/flock/drone/Login()
	..()
	src.client?.color = null
	if(isnull(controller))
		controller = new/mob/living/intangible/flock/trace(src, src.flock)
		src.is_npc = FALSE

/mob/living/critter/flock/drone/proc/take_control(mob/living/intangible/flock/pilot, give_alert = TRUE)
	if(!pilot)
		return
	if(controller)
		boutput(pilot, "<span class='alert'>This drone is already being controlled.</span>")
		return
	src.controller = pilot
	src.ai.stop_move()
	src.is_npc = FALSE
	src.dormant = FALSE
	src.anchored = FALSE

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
	controller = pilot
	src.client?.color = null
	//hack to make night vision apply instantly
	var/datum/lifeprocess/sight/sight_process = src.lifeprocesses[/datum/lifeprocess/sight]
	sight_process?.Process()
	src.hud?.update_intent()
	if (istype(pilot, /mob/living/intangible/flock/flockmind))
		flock.addAnnotation(src, FLOCK_ANNOTATION_FLOCKMIND_CONTROL)
	else
		flock.addAnnotation(src, FLOCK_ANNOTATION_FLOCKTRACE_CONTROL)
	if (give_alert)
		boutput(src, "<span class='flocksay'><b>\[SYSTEM: Control of drone [src.real_name] established.\]</b></span>")

/mob/living/critter/flock/drone/proc/release_control(give_alerts = TRUE)
	src.flock?.hideAnnotations(src)
	src.is_npc = TRUE
	if (give_alerts && src.z == Z_LEVEL_STATION)
		emote("beep")
		say(pick_string("flockmind.txt", "flockdrone_player_kicked"))
	if(src.client && !controller)
		controller = new/mob/living/intangible/flock/trace(src, src.flock)
	if(controller)
		if (src.floorrunning)
			src.end_floorrunning(TRUE)

		if (src.z == Z_LEVEL_STATION)
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
		if (istype(controller, /mob/living/intangible/flock/flockmind))
			flock.removeAnnotation(src, FLOCK_ANNOTATION_FLOCKMIND_CONTROL)
		else
			flock.removeAnnotation(src, FLOCK_ANNOTATION_FLOCKTRACE_CONTROL)
		if (give_alerts && src.z == Z_LEVEL_STATION)
			flock_speak(null, "Control of drone [src.real_name] surrended.", src.flock)

		controller = null
		src.update_health_icon()

/mob/living/critter/flock/drone/proc/release_control_abrupt(give_alert = TRUE)
	src.flock?.hideAnnotations(src)
	src.is_npc = TRUE
	if(src.client && !controller)
		controller = new/mob/living/intangible/flock/trace(src, src.flock)
	if(!controller)
		return
	if (src.floorrunning)
		src.end_floorrunning(TRUE)
	if (src.z == Z_LEVEL_STATION)
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
	if (give_alert)
		boutput(controller, "<span class='flocksay'><b>\[SYSTEM: Control of drone [src.real_name] ended abruptly.\]</b></span>")
	if (istype(controller, /mob/living/intangible/flock/flockmind))
		flock.removeAnnotation(src, FLOCK_ANNOTATION_FLOCKMIND_CONTROL)
	else
		flock.removeAnnotation(src, FLOCK_ANNOTATION_FLOCKTRACE_CONTROL)
	controller = null
	src.update_health_icon()

/mob/living/critter/flock/drone/dormantize()
	src.icon_state = "drone-dormant"
	src.remove_simple_light("drone_light")

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
		boutput(controller, "<span class='flocksay'><b>\[SYSTEM: Connection to drone [src.real_name] lost.\]</b></span>")
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
	src.anchored = FALSE
	src.damaged = -1
	src.check_health() // handles updating the icon to something more appropriate
	src.visible_message("<span class='notice'><b>[src]</b> begins to glow and hover.</span>")
	src.set_a_intent(INTENT_HELP)
	src.add_simple_light("drone_light", rgb2num(glow_color))
	if(src.client)
		controller = new/mob/living/intangible/flock/trace(src, src.flock)
		src.is_npc = FALSE
	else
		src.is_npc = TRUE


/mob/living/critter/flock/drone/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	var/special_desc = "<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received."
	if(src.controller)
		special_desc += "<br><span class='bold'>ID:</span> <b>[src.controller.real_name]</b> (controlling [src.real_name])"
	else
		special_desc += "<br><span class='bold'>ID:</span> [src.real_name]"
	special_desc += {"<br><span class='bold'>Flock:</span> [src.flock ? src.flock.name : "none"]
		<br><span class='bold'>Resources:</span> [src.resources]
		<br><span class='bold'>System Integrity:</span> [max(0, round(src.get_health_percentage() * 100))]%
		<br><span class='bold'>Cognition:</span> [isalive(src) && !dormant ? src.is_npc ? "TORPID" : "SAPIENT" : "ABSENT"]"}
	if (src.is_npc && istype(src.ai.current_task))
		special_desc += "<br><span class='bold'>Task:</span> [uppertext(src.ai.current_task.name)]"
	special_desc += "<br><span class='bold'>###=-</span></span>"
	return special_desc

/mob/living/critter/flock/drone/proc/changeFlock(var/flockName)
	src.flock?.removeDrone(src)
	if(flocks[flockName])
		src.flock = flocks[flockName]
		src.flock.registerUnit(src, TRUE)
	controller?.flock = flocks[flockName]
	boutput(src, "<span class='notice'>You are now part of the <span class='bold'>[src.flock.name]</span> flock.</span>")

/mob/living/critter/flock/drone/Login()
	..()
	if(src.dormant)
		src.undormantize()
	if(src.flock)
		src.flock.showAnnotations(src)

/mob/living/critter/flock/drone/is_spacefaring()
	return TRUE

/mob/living/critter/flock/drone/Cross(atom/movable/mover)
	if(isflockmob(mover))
		return TRUE
	else if (istype(mover, /obj/flock_structure/cage))
		animate_flock_passthrough(src)
		return TRUE
	else
		return ..()

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
	var/mob/living/intangible/flock/flock_controller = usr
	if (istype(usr, /mob/living/critter/flock))
		var/mob/living/critter/flock/flock_mob = usr
		flock_controller = flock_mob.controller
	if (!isalive(flock_controller))
		return // flock mind/trace is stunned or dead
	if (flock_controller.flock != src.flock)
		return // this isn't our drone
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
	HH.limb = new /datum/limb/gun/flock_stunner
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
				playsound(src, "sound/misc/flockmind/flockdrone_beep[pick("1","2","3","4")].ogg", 30, 1)
				return "<b>[src]</b> [act]s[(param ? " at [param]." : ".")]"
		if ("scream", "growl", "abeep", "grump")
			if (src.emote_check(voluntary, 50))
				playsound(src, "sound/misc/flockmind/flockdrone_grump[pick("1","2","3")].ogg", 30, 1)
				return "<b>[src]</b> beeps grumpily[(param? " at [param]!" : "!")]"
		if ("fart") // i cannot ignore my heritage any longer
			if (src.emote_check(voluntary, 50))
				var/fart_message = pick_string("flockmind.txt", "flockdrone_fart")
				playsound(src, "sound/misc/flockmind/flockdrone_fart.ogg", 60, 1, channel=VOLUME_CHANNEL_EMOTE)
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
		src.resources--
		if (src.resources < 1)
			src.end_floorrunning(TRUE)
	if (!src.dormant && src.z != Z_LEVEL_STATION && src.z != Z_LEVEL_NULL)
		src.dormantize()
		return
	if (src.dormant)
		return

	//if we're blocking that means we're not grabbed
	if (!length(src.grabbed_by) || src.find_type_in_hand(/obj/item/grab/block))
		src.antigrab_counter = 0
	else
		src.antigrab_counter++
		if (src.antigrab_counter >= src.antigrab_fires_at)
			playsound(src, "sound/effects/electric_shock.ogg", 40, 1, -3)
			boutput(src, "<span class='flocksay'><b>\[SYSTEM: Anti-grapple countermeasures deployed.\]</b></span>")
			for(var/obj/item/grab/G in src.grabbed_by)
				var/mob/living/L = G.assailant
				L.shock(src, 5000)
				qdel(G) //in case they don't fall over from our shock
			src.antigrab_counter = 0

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
	playsound(src, "sound/misc/flockmind/flockdrone_floorrun.ogg", 50, 1, -3)
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
	playsound(src, "sound/misc/flockmind/flockdrone_floorrun.ogg", 50, 1, -3)
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
					if (istype(O, /obj/grille/steel) || istype(O, /obj/window) || (istype(O, /obj/machinery/door) && O.density))
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
	. = ..()
	if (!M) return
	if (isflockmob(M)) return
	if (!isdead(src) && src.flock)
		if (!src.flock.isEnemy(M))
			emote("scream")
			say("[pick_string("flockmind.txt", "flockdrone_enemy")] [M]")
		src.flock.updateEnemy(M)

/mob/living/critter/flock/drone/bullet_act(var/obj/projectile/P)
	if(floorrunning)
		return FALSE
	if (!..())
		return
	var/attacker = P.shooter
	if(!(ismob(attacker) || iscritter(attacker) || isvehicle(attacker)))
		attacker = P.mob_shooter //shooter is updated on reflection, so we fall back to mob_shooter if it turns out to be a wall or something

/mob/living/critter/flock/drone/TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss)
	..()
	src.check_health()
	if (brute <= 0 && burn <= 0 && tox <= 0)
		return
	var/prev_damaged = src.damaged
	if(!isdead(src) && src.is_npc)
		if(prev_damaged != src.damaged && src.damaged > 0) // damaged to a new state
			src.emote("scream")
			say("[pick_string("flockmind.txt", "flockdrone_hurt")]")
			src.ai.interrupt()

/mob/living/critter/flock/drone/proc/check_health()
	if(isdead(src))
		return
	var/percent_damage = src.get_health_percentage() * 100
	switch(percent_damage)
		if(75 to 100)
			if(damaged == 0) return
			damaged = 0
			if(!dormant)
				src.icon_state = "drone"
		if(50 to 74)
			if(damaged == 1) return
			damaged = 1
			desc = "[initial(desc)]<br><span class='alert'>\The [src] looks lightly [pick("dented", "scratched", "beaten", "wobbly")].</span>"
			if(!dormant)
				src.icon_state = "drone-d1"
		if(25 to 49)
			if(damaged == 2) return
			damaged = 2
			desc = "[initial(desc)]<br><span class='alert'>\The [src] looks [pick("quite", "pretty", "rather")] [pick("dented", "busted", "messed up", "haggard")].</span>"
			if(!dormant)
				src.icon_state = "drone-d2"
		if(0 to 24)
			if(damaged == 3) return
			damaged = 3
			desc = "[initial(desc)]<br><span class='alert'>\The [src] looks [pick("really", "totally", "very", "all sorts of", "super")] [pick("mangled", "busted", "messed up", "broken", "haggard", "smashed up", "trashed")].</span>"
			if(!dormant)
				src.icon_state = "drone-d2"
	return

/mob/living/critter/flock/drone/proc/reduce_lifeprocess_on_death()
	remove_lifeprocess(/datum/lifeprocess/blood)
	remove_lifeprocess(/datum/lifeprocess/canmove)
	remove_lifeprocess(/datum/lifeprocess/disability)
	remove_lifeprocess(/datum/lifeprocess/fire)
	remove_lifeprocess(/datum/lifeprocess/hud)
	remove_lifeprocess(/datum/lifeprocess/mutations)
	remove_lifeprocess(/datum/lifeprocess/organs)
	remove_lifeprocess(/datum/lifeprocess/sight)
	remove_lifeprocess(/datum/lifeprocess/skin)
	remove_lifeprocess(/datum/lifeprocess/statusupdate)

/mob/living/critter/flock/drone/death(var/gibbed)
	if(src.controller)
		src.release_control()
	if(!src.dormant)
		if(src.is_npc)
			emote("scream")
			say(pick_string("flockmind.txt", "flockdrone_death"))
			src.is_npc = FALSE // stop ticking the AI for this mob
		else
			emote("scream")
			say("\[System notification: drone lost.\]")
	var/obj/item/organ/heart/flock/core = src.organHolder.get_organ("heart")
	if(core)
		core.resources = src.resources
		src.resources = 0 // just in case any weirdness happens let's pre-empt the dupe bug
	..()
	src.icon_state = "drone-dead"
	src.reduce_lifeprocess_on_death()
	src.set_density(FALSE)
	src.desc = "[initial(desc)]<br><span class='alert'>\The [src] is a dead, broken heap.</span>"
	src.remove_simple_light("drone_light")

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

	playsound(src, "sound/impact_sounds/Glass_Shatter_2.ogg", 50, 1)
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
	say("\[System notification: drone diffracting.\]")
	if(src.controller)
		src.release_control()
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
		B = new(T, src.flock)
		src.flock?.registerUnit(B)
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
		boutput(src, "<span class='alert'>You do not have flockmind authorization to synthesize eggs.</span>")
		return
	if(src.resources < FLOCK_LAY_EGG_COST)
		boutput(src, "<span class='alert'>Not enough resources (you need [FLOCK_LAY_EGG_COST]).</span>")
		return
	if(src.floorrunning)
		boutput(src, "<span class='alert'>You can't do that while floorrunning.</span>")
		return
	var/turf/simulated/floor/feather/nest = get_turf(src)
	if(!istype(nest, /turf/simulated/floor/feather))
		boutput(src, "<span class='alert'>The egg needs to be placed on flock tile.</span>")
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

/////////////////////////////////////////////////////////////////////////////////
// FLOCKDRONE SPECIFIC LIMBS AND EQUIPMENT SLOTS
/////////////////////////////////////////////////////////////////////////////////

/datum/limb/flock_grip // an ordinary hand but with some modified messages
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
		boutput(user, "<span class='alert'>The grip tool can't get a good grip on [target]!</span>")
		user.lastattacked = target

/datum/limb/flock_grip/harm(mob/target, var/mob/living/critter/flock/drone/user)
	if (!user || !target)
		return FALSE
	if (istype(target, /mob/living/critter/flock))
		boutput(user, "<span class='alert'>The grip tool refuses to harm this, jamming briefly.</span>")
	else
		if (!target.melee_attack_test(user))
			return
		if (prob(src.attack_hit_prob) || is_incapacitated(target)|| target.restrained())
			var/obj/item/affecting = target.get_affecting(user)
			var/datum/attackResults/msgs = user.calculate_melee_attack(target, affecting, dam_low, dam_high, 0)
			user.attack_effects(target, affecting)
			var/list/specific_attack_messages = pick(attack_messages)
			msgs.base_attack_message = "<span class='combat bold'>[user] [specific_attack_messages[1]] [target] [specific_attack_messages[2]]!</span>"
			msgs.flush(FALSE)
			user.lastattacked = target
		else
			user.visible_message("<span class='combat bold'>[user] attempts to prod [target] but misses!</span>")
			user.lastattacked = target

/////////////////////////////////////////////////////////////////////////////////

/datum/limb/flock_converter

/datum/limb/flock_converter/attack_hand(atom/target, var/mob/living/critter/flock/drone/user, var/reach, params, location, control)
	if (!holder)
		return
	if(check_target_immunity( target ))
		return
	if (!istype(user))
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
		boutput(user, "<span class='alert'>Something about this structure prevents it from being assimilated.</span>")
	else if(isfeathertile(target))
		if(istype(target, /turf/simulated/floor/feather))
			if(user.a_intent == INTENT_DISARM)
				var/turf/simulated/floor/feather/flocktarget = target
				for (var/atom/O in flocktarget.contents)
					if (istype(O, /obj/grille/flock))
						boutput(user, "<span class='alert'>There's already a barricade here.</span>")
						return
					if ((O.density && !isflockmob(O)) || istype(O, /obj/flock_structure/ghost))
						boutput(user, "<span class='alert'>This tile has something that blocks barricade construction!</span>")
						return
				if (user.resources < FLOCK_BARRICADE_COST)
					boutput(user, "<span class='alert'>Not enough resources to construct a barricade (you need [FLOCK_BARRICADE_COST]).</span>")
				else
					actions.start(new/datum/action/bar/flock_construct(target), user)
	else if(user.resources < FLOCK_CONVERT_COST && istype(target, /turf))
		boutput(user, "<span class='alert'>Not enough resources to convert (you need [FLOCK_CONVERT_COST]).</span>")
	else
		if(istype(target, /turf))
			if (user.flock)
				for (var/name in user.flock.busy_tiles)
					if (user.flock.busy_tiles[name] == target && name != user.real_name)
						boutput(user, "<span class='alert'>This tile has already been reserved!</span>")
						return
				actions.start(new/datum/action/bar/flock_convert(target), user)
			else
				actions.start(new/datum/action/bar/flock_convert(target), user)

	//depositing
	if (istype(target, /obj/flock_structure/ghost))
		if (user.resources <= 0)
			boutput(user, "<span class='alert'>No resources available for construction.</span>")
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
				if (/obj/grille/flock)
					var/obj/grille/flock/barricade = target
					if (barricade.health < barricade.health_max)
						found_target = TRUE
				if (/obj/storage/closet/flock)
					var/obj/storage/closet/flock/closet = target
					if (closet.health_attack < closet.health_max)
						found_target = TRUE
		if (!found_target)
			boutput(user, "<span class='alert'>The target is in perfect condition!</span>")
		else
			if(user.resources < FLOCK_REPAIR_COST)
				boutput(user, "<span class='alert'>Not enough resources to repair (you need [FLOCK_REPAIR_COST]).</span>")
			else
				actions.start(new /datum/action/bar/flock_repair(target), user)

/datum/limb/flock_converter/help(mob/target, var/mob/living/critter/flock/drone/user)
	if(!target || !user)
		return
	var/mob/living/critter/flock/F = target
	if(istype(F))
		if(F.get_health_percentage() >= 1.0)
			boutput(user, "<span class='alert'>They don't need to be repaired, they're in perfect condition.</span>")
			return
		if (isdead(F))
			return
		if(user.resources < FLOCK_REPAIR_COST)
			boutput(user, "<span class='alert'>Not enough resources to repair (you need [FLOCK_REPAIR_COST]).</span>")
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
	if (!user.flock)
		boutput(user, "<span class='alert'>You do not have access to the imprisonment matrix without flockmind authorization.</span>")
		return
	// IMPRISON TARGET
	if(isflockmob(target))
		boutput(user, "<span class='alert'>The imprisonment matrix doesn't work on flockdrones.</span>")
		return
	else if(istype(target.loc, /obj/flock_structure/cage))
		boutput(user, "<span class='alert'>They're already imprisoned, you can't double-imprison them!</span>")
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
			boutput(user, "<span class='alert'>You can't butcher a living flockdrone!</span>")
	else
		src.attack_hand(target, user)

/////////////////////////////////////////////////////////////////////////////////

/datum/limb/gun/flock_stunner // fires a stunning bolt on a cooldown which doesn't affect flockdrones
	proj = new/datum/projectile/energy_bolt/flockdrone
	shots = 1
	current_shots = 1
	cooldown = 15
	reload_time = 15
	reloading_str = "recharging"

/datum/limb/gun/flock_stunner/point_blank(mob/living/target, mob/living/user)
	if (isflockmob(target))
		return
	return ..()

/datum/limb/gun/flock_stunner/attack_range(atom/target, var/mob/living/critter/flock/drone/user, params)
	if(!target || !user)
		return
	return ..()

/datum/limb/gun/flock_stunner/help(mob/living/target, mob/living/user)
	src.point_blank(target, user)

/datum/limb/gun/flock_stunner/grab(mob/living/target, mob/living/user)
	src.point_blank(target, user)

/datum/projectile/energy_bolt/flockdrone
	name = "incapacitor bolt"
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "stunbolt"
	cost = 20
	power = 44
	dissipation_rate = 1
	dissipation_delay = 3
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
	ks_ratio = 0.1
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
	if (istype(I, /obj/item/grab))
		return FALSE
	return ..()

/datum/equipmentHolder/flockAbsorption/on_equip()
	if (item.burning)
		item.combust_ended()

	var/mob/living/critter/flock/drone/F = holder
	src.instant_absorb = item.amount > 1 && round(F.resources_per_health * item.health) == 0
	src.ignore_amount = istype(item, /obj/item/spacecash)

	item.inventory_counter?.show_count()

	holder.visible_message("<span class='alert'>[holder] starts absorbing [item]!</span>", "<span class='notice'>You place [item] into [src.name] and begin breaking it down.</span>")
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
	if (flock_owner.absorber.instant_absorb && !flock_owner.absorber.ignore_amount)
		boutput(flock_owner, "<span class='alert'>[I] is weak enough that it breaks apart instantly!</span>")
		flock_owner.resources += round(flock_owner.resources_per_health * health_absorbed * I.amount)
	else
		I.health -= health_absorbed
		flock_owner.resources += round(flock_owner.resources_per_health * health_absorbed)
		if (I.health > 0 || (I.health == 0 && I.amount > 1 && !flock_owner.absorber.ignore_amount))
			if (!ON_COOLDOWN(src.holder, "absorber_noise", 1 SECOND))
				playsound(flock_owner, "sound/effects/sparks[rand(1, 6)].ogg", 50, 1)
		if (I.health > 0)
			return
		if (I.amount > 1 && !flock_owner.absorber.ignore_amount)
			if (initial(I.health))
				I.health = initial(I.health)
			else
				I.set_health()
			I.change_stack_amount(-1)
			return

	playsound(flock_owner, "sound/impact_sounds/Energy_Hit_1.ogg", 50, 1)

	if(length(I.contents))
		var/anything_tumbled = FALSE
		for(var/obj/O in I.contents)
			if(istype(O, /obj/item))
				O.set_loc(flock_owner.loc)
				anything_tumbled = TRUE
			else
				qdel(O)
		if(anything_tumbled)
			flock_owner.visible_message("<span class='alert'>The contents of [I] tumble out of [flock_owner].</span>",
				"<span class='alert'>The contents of [I] tumble out of you.</span>",
				"<span class='alert'>You hear things fall onto the floor.</span")

	if (istype(I, /obj/item/flockcache))
		var/obj/item/flockcache/C = I
		flock_owner.resources += C.resources
		boutput(flock_owner, "<span class='notice'>You break down the resource cache, adding <span class='bold'>[C.resources]</span> resource[C.resources > 1 ? "s" : null] to your own. </span>")
	else if(istype(I, /obj/item/organ/heart/flock))
		var/obj/item/organ/heart/flock/F = I
		if (F.resources == 0)
			boutput(flock_owner, "<span class='notice'>[F]'s resource cache is assimilated, but contains no resources.</span>")
		else
			flock_owner.resources += F.resources
			boutput(flock_owner, "<span class='notice'>You assimilate [F]'s resource cache, adding <span class='bold'>[F.resources]</span> resource[F.resources > 1 ? "s" : null] to your own.</span>")
	else
		boutput(flock_owner, "<span class='notice'>You finish converting [I] into resources.</span>")
	qdel(I)
	flock_owner.absorber.item = null
