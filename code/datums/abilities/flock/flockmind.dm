///////////////////////
// FLOCKMIND ABILITIES
///////////////////////

/datum/abilityHolder/flockmind
	tabName = "Flockmind"
	usesPoints = TRUE
	points = 0 //total compute - used compute
	var/totalCompute = 0
	regenRate = 0
	topBarRendered = TRUE
	rendered = TRUE
	notEnoughPointsMessage = "<span class='alert'>Insufficient available compute resources.</span>"
	var/datum/targetable/flockmindAbility/droneControl/drone_controller = null

	New()
		..()
		drone_controller = addAbility(/datum/targetable/flockmindAbility/droneControl)

/datum/abilityHolder/flockmind/proc/updateCompute(usedCompute, totalCompute)
	var/mob/living/intangible/flock/F = owner
	if(!F?.flock)
		return //someone made a flockmind or flocktrace without a flock, or gave this ability holder to something else.
	src.points = totalCompute - usedCompute
	src.totalCompute = totalCompute

/datum/abilityHolder/flockmind/onAbilityStat()
	..()
	.= list()
	.["Compute:"] = "[round(src.points)]/[round(src.totalCompute)]"
	//var/mob/living/intangible/flock/F = owner
	//if (!istype(F) || !F.flock)
	//	return
	//.["Traces:"] = "[length(F.flock.traces)]/[F.flock.max_trace_count]"

/atom/movable/screen/ability/topBar/flockmind
	tens_offset_x = 19
	tens_offset_y = 7
	secs_offset_x = 23
	secs_offset_y = 7

/////////////////////////////////////////

/datum/targetable/flockmindAbility
	icon = 'icons/mob/flock_ui.dmi'
	icon_state = "template"
	cooldown = 40
	last_cast = 0
	targeted = TRUE
	target_anything = TRUE
	preferred_holder_type = /datum/abilityHolder/flockmind
	theme = "flock"

/datum/targetable/flockmindAbility/New()
	var/atom/movable/screen/ability/topBar/flockmind/B = new /atom/movable/screen/ability/topBar/flockmind(null)
	B.icon = src.icon
	B.icon_state = src.icon_state
	B.owner = src
	B.name = src.name
	B.desc = src.desc
	src.object = B

/datum/targetable/flockmindAbility/cast(atom/target)
	if (!holder || !holder.owner)
		return TRUE
	return FALSE

/datum/targetable/flockmindAbility/doCooldown()
	if (!holder)
		return
	last_cast = world.time + cooldown
	holder.updateButtons()
	SPAWN(cooldown + 5)
		holder?.updateButtons()

/////////////////////////////////////////

/datum/targetable/flockmindAbility/spawnEgg
	name = "Spawn Rift"
	desc = "Spawn an rift where you are, and from there, begin."
	icon_state = "spawn_egg"
	targeted = FALSE
	cooldown = 0

/datum/targetable/flockmindAbility/spawnEgg/cast(atom/target)
	if(..())
		return TRUE

	var/mob/living/intangible/flock/flockmind/F = holder.owner

	var/turf/T = get_turf(F)

	if (!isadmin(F))
		if (istype(T, /turf/space/) || istype(T.loc, /area/station/solar) || istype(T.loc, /area/station/mining/magnet))
			boutput(F, "<span class='alert'>Space and exposed areas are unsuitable for rift placement!</span>")
			return TRUE

		if(IS_ARRIVALS(T.loc))
			boutput(F, "<spawn class='alert'>Your rift can't be placed inside arrivals!</span>")
			return TRUE

		if (!istype(T.loc, /area/station/))
			boutput(F, "<spawn class='alert'>Your rift needs to be placed on the [station_or_ship()]!</span>")
			return TRUE

		if (istype(T, /turf/unsimulated/))
			boutput(F, "<span class='alert'>This kind of tile cannot support rift placement.</span>")
			return TRUE

		if (T.density)
			boutput(F, "<span class='alert'>Your rift cannot be placed inside a wall!</span>")
			return TRUE

		for (var/atom/O in T.contents)
			if (O.density)
				boutput(F, "<span class='alert'>That tile is blocked by [O].</span>")
				return TRUE
	logTheThing(LOG_GAMEMODE, holder.get_controlling_mob(), "spawns a rift at [log_loc(src.holder.owner)].")
	F.spawnEgg()

/////////////////////////////////////////

/datum/targetable/flockmindAbility/designateTile
	name = "Designate Priority Tile"
	desc = "Add or remove a tile to the urgent tiles the flock should claim."
	icon_state = "designate_tile"
	cooldown = 0
	sticky = TRUE

/datum/targetable/flockmindAbility/designateTile/cast(atom/target)
	if(..())
		return TRUE
	var/mob/living/intangible/flock/F = holder.owner
	var/turf/T = get_turf(target)
	if(!(istype(T, /turf/simulated) || istype(T, /turf/space)) || !flockTurfAllowed(T))
		boutput(holder.get_controlling_mob(), "<span class='alert'>The flock can't convert this.</span>")
		return TRUE
	if(isfeathertile(T))
		boutput(holder.get_controlling_mob(), "<span class='alert'>This tile has already been converted.</span>")
		return TRUE
	if (!(T in F.flock.priority_tiles))
		for (var/name in F.flock.busy_tiles)
			if (T == F.flock.busy_tiles[name])
				boutput(holder.get_controlling_mob(), "<span class='alert'>This tile is already scheduled for conversion!</span>")
				return TRUE
	F.flock?.togglePriorityTurf(T)

/////////////////////////////////////////

/datum/targetable/flockmindAbility/designateEnemy
	name = "Designate Enemy"
	desc = "Mark or unmark someone as an enemy."
	icon_state = "designate_enemy"
	cooldown = 0

/datum/targetable/flockmindAbility/designateEnemy/cast(atom/target)
	if(..())
		return TRUE

	var/M = target
	var/mob/living/intangible/flock/F = holder.owner

	if (!(isliving(M) || iscritter(M) || isvehicle(M)) || isflockmob(M) || isintangible(M))
		boutput(F, "<span class='alert'>That isn't a valid target.</span>")
		return TRUE

	var/datum/flock/flock = F.flock

	if (!flock)
		return TRUE

	logTheThing(LOG_COMBAT, holder.get_controlling_mob(), "designates [constructTarget(M)] as [flock.isEnemy(M) ? "" : "not "]an enemy at [log_loc(src.holder.owner)].")

	if (flock.isEnemy(M))
		flock.removeEnemy(M)
		return

	flock.updateEnemy(M)

/////////////////////////////////////////

/datum/targetable/flockmindAbility/partitionMind
	name = "Partition Mind"
	icon_state = "awaken_drone"
	cooldown = 60 SECONDS
	targeted = FALSE
	///Are we still waiting for ghosts to respond
	var/waiting = FALSE

/datum/targetable/flockmindAbility/partitionMind/New()
	src.desc = "Create a Flocktrace. Requires [FLOCKTRACE_COMPUTE_COST] total compute per trace."
	..()

/datum/targetable/flockmindAbility/partitionMind/cast(atom/target)
	if(waiting || ..())
		return TRUE

	var/mob/living/intangible/flock/flockmind/F = holder.owner

	if(length(F.flock.traces) >= F.flock.max_trace_count)
		if (length(F.flock.traces) < round(FLOCK_RELAY_COMPUTE_COST / FLOCKTRACE_COMPUTE_COST))
			boutput(holder.get_controlling_mob(), "<span class='alert'>You cannot make any Flocktraces!</span>")
		else
			boutput(holder.get_controlling_mob(), "<span class='alert'>You cannot make any more Flocktraces!</span>")
		return TRUE

	waiting = TRUE
	SPAWN(0)
		F.partition()
		waiting = FALSE

/////////////////////////////////////////

/datum/targetable/flockmindAbility/healDrone
	name = "Concentrated Repair Burst"
	desc = "Accelerate the repair processes of all flock units in an area (maximum 4 drones)."
	icon_state = "heal_drone"
	cooldown = 30 SECONDS
	var/max_targets = 4 //maximum number of drones healed

/datum/targetable/flockmindAbility/healDrone/cast(atom/target)
	if(..())
		return TRUE
	var/mob/living/intangible/flock/flockowner = holder.owner
	var/healed = 0
	for (var/mob/living/critter/flock/flockcritter in range(3, target))
		var/health_ratio = flockcritter.get_health_percentage()
		if (isdead(flockcritter) || health_ratio >= 1 || flockcritter.flock != flockowner.flock)
			continue
		flockcritter.HealDamage("All", 30, 30) //half of a flockdrone's health
		var/particles/healing/flock/particles = new
		particles.spawning = 1 - health_ratio //more heal = more particles
		flockcritter.UpdateParticles(particles, "flockmind_heal")
		SPAWN(1.5 SECONDS)
			particles.spawning = 0
			sleep(1.5 SECONDS)
			flockcritter.ClearSpecificParticles("flockmind_heal")
		if (istype(flockcritter, /mob/living/critter/flock/drone))
			healed++
		if (healed >= src.max_targets)
			break

	playsound(holder.get_controlling_mob(), 'sound/misc/flockmind/flockmind_cast.ogg', 80, 1)
	boutput(holder.get_controlling_mob(), "<span class='notice'>You focus the flock's efforts on repairing nearby units.</span>")
	logTheThing(LOG_COMBAT, holder.get_controlling_mob(), "casts repair burst at [log_loc(src.holder.owner)].")

/////////////////////////////////////////

/datum/targetable/flockmindAbility/splitDrone
	name = "Diffract Drone"
	desc = "Split a drone into flockbits, mindless automata that only convert whatever they find."
	icon_state = "diffract"
	cooldown = 0

/datum/targetable/flockmindAbility/splitDrone/cast(mob/living/critter/flock/drone/target)
	if(..())
		return TRUE
	if(!istype(target))
		return TRUE
	var/mob/living/intangible/flock/flockmind/F = holder.owner
	if(!F.flock || F.flock != target.flock)
		boutput(F, "<span class='notice'>The drone does not respond to your command.</span>")
		return TRUE
	if (isdead(target))
		boutput(F, "<span class='notice'>That drone is dead.</span>")
		return TRUE
	if(F.flock.getComplexDroneCount() == 1)
		boutput(F, "<span class='alert'>That's your last complex drone. Diffracting it would be suicide.</span>")
		return TRUE
	boutput(F, "<span class='notice'>You diffract the drone.</span>")
	logTheThing(LOG_COMBAT, holder.get_controlling_mob(), "casts diffract drone on [constructTarget(target)] at [log_loc(src.holder.owner)].")
	target.split_into_bits()


/////////////////////////////////////////

/datum/targetable/flockmindAbility/doorsOpen
	name = "Gatecrash"
	desc = "Force open every door in radio range (if it can be opened by radio transmissions)."
	icon_state = "open_door"
	cooldown = 10 SECONDS
	targeted = 0

/datum/targetable/flockmindAbility/doorsOpen/cast(atom/target)
	if(..())
		return 1
	var/list/targets = list()
	for(var/obj/machinery/door/airlock/A in range(10, get_turf(holder.owner)))
		if(A.canAIControl())
			targets += A
	if(length(targets))
		playsound(holder.get_controlling_mob(), 'sound/misc/flockmind/flockmind_cast.ogg', 80, 1)
		boutput(holder.get_controlling_mob(), "<span class='notice'>You force open all the doors around you.</span>")
		logTheThing(LOG_COMBAT, holder.get_controlling_mob(), "casts gatecrash at [log_loc(src.holder.owner)].")
		sleep(1.5 SECONDS)
		for(var/obj/machinery/door/airlock/A in targets)
			A.open()
	else
		boutput(holder.get_controlling_mob(), "<span class='alert'>No targets in range that can be opened via radio.</span>")
		return TRUE

/////////////////////////////////////////

/datum/targetable/flockmindAbility/radioStun
	name = "Radio Stun Burst"
	desc = "Overwhelm the radio headsets of everyone nearby. Will not work on broken or non-existent headsets."
	icon_state = "radio_stun"
	cooldown = 20 SECONDS
	targeted = FALSE

/datum/targetable/flockmindAbility/radioStun/cast(atom/target)
	if(..())
		return TRUE
	var/list/targets = list()
	for(var/mob/living/M in range(10, holder.get_controlling_mob()))
		if(M.ear_disability)
			continue
		var/obj/item/device/radio/R = M.ears // wont work on flock as they have no slot for this
		if(istype(R) && R.listening) // working and toggled on
			targets += M
	if(length(targets))
		playsound(holder.get_controlling_mob(), 'sound/misc/flockmind/flockmind_cast.ogg', 80, 1)
		boutput(holder.get_controlling_mob(), "<span class='notice'>You transmit the worst static you can weave into the headsets around you.</span>")
		logTheThing(LOG_COMBAT, holder.get_controlling_mob(), "casts radio stun burst at [log_loc(src.holder.owner)].")
		for(var/mob/living/M in targets)
			playsound(M, "sound/effects/radio_sweep[rand(1,5)].ogg", 70, 1)
			boutput(M, "<span class='alert'>Horrifying static bursts into your headset, disorienting you severely!</span>")
			M.apply_sonic_stun(3, 6, 30, 0, 0, rand(1, 3), rand(1, 3))
	else
		boutput(holder.get_controlling_mob(), "<span class='alert'>No targets in range with active radio headsets.</span>")
		return TRUE

/////////////////////////////////////////

/datum/targetable/flockmindAbility/directSay
	name = "Narrowbeam Transmission"
	desc = "Directly send a transmission to a target's radio headset, or send a transmission to a radio to broadcast."
	icon_state = "talk"
	cooldown = 0

/datum/targetable/flockmindAbility/directSay/cast(atom/target)
	if(..())
		return TRUE
	var/obj/item/device/radio/R
	var/message
	if(ismob(target))
		var/mob/living/M = target
		if(istype(M.ears, /obj/item/device/radio))
			R = M.ears
		else
			// search for any radio device, starting with hands and then equipment
			// anything else is arbitrarily too deeply hidden and stowed away to get the signal
			// (more practically, they won't hear it)
			R = M.find_type_in_hand(/obj/item/device/radio)
			if(!R)
				R = M.find_in_equipment(/obj/item/device/radio)
		if(R)
			message = html_encode(input("What would you like to transmit to [M.name]?", "Transmission", "") as text)
			logTheThing(LOG_SAY, usr, "Narrowbeam Transmission to [constructTarget(target,"say")]: [message]")
			message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
			var/flockName = "--.--"
			var/mob/living/intangible/flock/F = holder.owner
			var/datum/flock/flock = F.flock
			if(flock)
				flockName = flock.name
			R.audible_message("<span class='radio' style='color: [R.device_color]'><span class='name'>Unknown</span><b> [bicon(R)]\[[flockName]\]</b> <span class='message'>crackles, \"[message]\"</span></span>")
			boutput(holder.get_controlling_mob(), "<span class='flocksay'>You transmit to [M.name], \"[message]\"</span>")
		else
			boutput(holder.get_controlling_mob(), "<span class='alert'>They don't have any compatible radio devices that you can find.</span>")
			return TRUE
	else if(istype(target, /obj/item/device/radio))
		R = target
		message = html_encode(input("What would you like to broadcast to [R]?", "Transmission", "") as text)
		logTheThing(LOG_SAY, usr, "Narrowbeam Transmission to [constructTarget(target,"say")]: [message]")
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

		//set up message
		var/datum/language/L = languages.language_cache["english"]
		var/list/messages = L.get_messages(radioGarbleText(message, 10))
		// temporarily swap names about
		var/name = holder.owner.name
		holder.owner.name = "Unknown"
		R.talk_into(holder.owner, messages, 0, "Unknown")
		holder.owner.name = name
	if (!R)
		boutput(holder.get_controlling_mob(), "<span class='alert'>That isn't a valid target.</span>")
		return TRUE
	logTheThing(LOG_COMBAT, holder.get_controlling_mob(), "casts narrowbeam transmission on radio [constructTarget(R)][ismob(target) ? " worn by [constructTarget(target)]" : ""] with message [message] at [log_loc(src.holder.owner)].")

/////////////////////////////////////////

/datum/targetable/flockmindAbility/controlPanel
	name = "Flock Control Panel"
	desc = "Open the Flock control panel."
	icon_state = "radio_stun"
	targeted = FALSE
	cooldown = 0

/datum/targetable/flockmindAbility/controlPanel/cast(atom/target)
	if(..())
		return TRUE
	var/mob/living/intangible/flock/flockmind/F = holder.owner
	F.flock.ui_interact(holder.get_controlling_mob(), F.flock.flockpanel)

////////////////////////////////

/datum/targetable/flockmindAbility/createStructure
	name = "Fabricate Structure"
	desc = "Create a structure tealprint for your drones to construct onto."
	icon_state = "fabstructure"
	cooldown = 0
	targeted = 0

/datum/targetable/flockmindAbility/createStructure/cast()
	var/turf/simulated/floor/feather/T = get_turf(holder.owner)
	if(!istype(T))
		boutput(holder.get_controlling_mob(), "<span class='alert'>You aren't above a flocktile.</span>")//todo maybe make this flock themed?
		return TRUE
	if (T.broken)
		boutput(holder.get_controlling_mob(), "<span class='alert'>The flocktile you're above is broken!</span>")
		return TRUE
	if(locate(/obj/flock_structure/ghost) in T)
		boutput(holder.get_controlling_mob(), "<span class='alert'>A tealprint has already been scheduled here!</span>")
		return TRUE
	if(locate(/obj/flock_structure) in T)
		boutput(holder.get_controlling_mob(), "<span class='alert'>There is already a flock structure on this flocktile!</span>")
		return TRUE

	var/list/friendlyNames = list()
	var/mob/living/intangible/flock/flockmind/F = holder.owner
	for(var/datum/unlockable_flock_structure/ufs as anything in F.flock.unlockableStructures)
		if(ufs.check_unlocked())
			friendlyNames[ufs.friendly_name] = ufs


	//todo: replace with FANCY tgui/chui window with WHEELS and ICONS and stuff!

	var/structurewanted = tgui_input_list(holder.get_controlling_mob(), "Select which structure you would like to create", "Tealprint selection", friendlyNames)

	if (!structurewanted)
		return TRUE
	var/datum/unlockable_flock_structure/ufs = friendlyNames[structurewanted]
	var/obj/flock_structure/structurewantedtype = ufs.structType //this is a mildly cursed abuse of type paths, where you can cast a type path to a typed var to get access to its members

	if(structurewantedtype)
		logTheThing(LOG_STATION, holder.owner, "queues a [initial(structurewantedtype.flock_id)] tealprint ([log_loc(T)])")
		return F.createstructure(structurewantedtype, initial(structurewantedtype.resourcecost))

/////////////////////////////////////////

/datum/targetable/flockmindAbility/ping
	name = "Ping"
	desc = "Request attention from other elements of the flock."
	icon_state = "ping"
	cooldown = 0.3 SECONDS

/datum/targetable/flockmindAbility/ping/cast(atom/target)
	if(..())
		return TRUE
	if (!isturf(target.loc) && !isturf(target))
		return TRUE
	var/mob/living/intangible/flock/F = holder.owner
	F.flock?.ping(target, holder.owner)

/////////////////////////////////////////

/datum/targetable/flockmindAbility/deconstruct
	name = "Mark for Deconstruction"
	desc = "Mark an existing flock structure for deconstruction, refunding some resources."
	icon_state = "destroystructure"
	cooldown = 0.1 SECONDS

/datum/targetable/flockmindAbility/deconstruct/cast(atom/target)
	if(..())
		return TRUE
	if(HAS_ATOM_PROPERTY(target,PROP_ATOM_FLOCK_THING))
		if (isflockdeconimmune(target)) // ghost structure on click opens tgui window
			return TRUE
		var/mob/living/intangible/flock/F = holder.owner
		F.flock.toggleDeconstructionFlag(target)
		return FALSE
	return TRUE



/datum/targetable/flockmindAbility/droneControl
	cooldown = 0
	icon = null
	var/task_type
	var/mob/living/critter/flock/drone/drone = null

/datum/targetable/flockmindAbility/droneControl/cast(atom/target)
	var/datum/aiTask/task = drone.ai.get_instance(task_type, list(drone.ai, drone.ai.default_task))
	task.target = target
	drone.ai.priority_tasks += task
	if(drone.ai_paused)
		drone.wake_from_ai_pause()
	drone.ai.interrupt()
