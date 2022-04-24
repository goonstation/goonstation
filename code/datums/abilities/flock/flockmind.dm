///////////////////////
// FLOCKMIND ABILITIES
///////////////////////

/datum/abilityHolder/flockmind
	tabName = "Flockmind"
	usesPoints = 1
	points = 0 //total compute - used compute
	var/totalCompute = 0
	regenRate = 0
	topBarRendered = 1
	rendered = 1
	notEnoughPointsMessage = "<span class='alert'>Insufficient available compute resources.</span>"

/datum/abilityHolder/flockmind/proc/updateCompute()
	var/mob/living/intangible/flock/flockmind/F = owner
	if(!F?.flock)
		return //someone made a flockmind without a flock, or gave this ability holder to something else.
	src.totalCompute = F.flock.total_compute()
	var/usedCompute = F.flock.used_compute()
	src.points = src.totalCompute - usedCompute

/datum/abilityHolder/flockmind/onAbilityStat()
	..()
	.= list()
	.["Compute:"] = "[round(src.points)]/[round(src.totalCompute)]"
	//.["Total Compute:"] = round(F.flock?.total_compute())
	return

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
	targeted = 1
	target_anything = 1
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
		return 1
	return 0

/datum/targetable/flockmindAbility/doCooldown()
	if (!holder)
		return
	last_cast = world.time + cooldown
	holder.updateButtons()
	SPAWN(cooldown + 5)
		holder.updateButtons()

/////////////////////////////////////////

/datum/targetable/flockmindAbility/spawnEgg
	name = "Spawn Rift"
	desc = "Spawn an rift where you are, and from there, begin."
	icon_state = "spawn_egg"
	targeted = 0
	cooldown = 0

/datum/targetable/flockmindAbility/spawnEgg/cast(atom/target)
	if(..())
		return TRUE

	var/mob/living/intangible/flock/flockmind/F = holder.owner

	var/turf/T = get_turf(F)

	if (istype(T, /turf/space/) || istype(T.loc, /area/station/solar) || istype(T.loc, /area/station/mining/magnet))
		boutput(F, "<span class='alert'>Space and exposed areas are unsuitable for rift placement!</span>")
		return TRUE

	if (!isadmin(F))
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

	F.spawnEgg()

/////////////////////////////////////////

/datum/targetable/flockmindAbility/designateTile
	name = "Designate Priority Tile"
	desc = "Add or remove a tile to the urgent tiles the flock should claim."
	icon_state = "designate_tile"
	cooldown = 0
	sticky = 1

/datum/targetable/flockmindAbility/designateTile/cast(atom/target)
	if(..())
		return 1
	var/mob/living/intangible/flock/flockmind/F = holder.owner
	var/turf/T = get_turf(target)
	if(!(istype(T, /turf/simulated) || istype(T, /turf/space)))
		boutput(holder.owner, "<span class='alert'>The flock can't convert this.</span>")
		return 1
	if(isfeathertile(T))
		boutput(holder.owner, "<span class='alert'>This tile has already been converted.</span>")
		return 1
	if(F)
		var/datum/flock/flock = F.flock
		if(flock)
			flock.togglePriorityTurf(T)

/////////////////////////////////////////

/datum/targetable/flockmindAbility/designateEnemy
	name = "Designate Enemy"
	desc = "Mark or unmark someone as an enemy."
	icon_state = "designate_enemy"
	cooldown = 0
	//sticky = 1

/datum/targetable/flockmindAbility/designateEnemy/cast(atom/target)
	if(..())
		return TRUE

	var/M = target
	var/mob/living/intangible/flock/F = holder.owner

	if (!(isliving(M) || iscritter(M)) || isflock(M) || isintangible(M))
		boutput(F, "<span class='alert'>That isn't a valid target.</span>")
		return TRUE

	var/datum/flock/flock = F.flock

	if (!flock)
		return TRUE

	if (flock.isEnemy(M))
		flock.removeEnemy(M)
		return

	flock.updateEnemy(M)

/////////////////////////////////////////

/datum/targetable/flockmindAbility/partitionMind
	name = "Partition Mind"
	desc = "Divide and conquer."
	icon_state = "awaken_drone"
	cooldown = 60 SECONDS
	targeted = 0
	///Are we still waiting for ghosts to respond
	var/waiting = FALSE

/datum/targetable/flockmindAbility/partitionMind/cast(atom/target)
	if(waiting || ..())
		return TRUE

	if(!holder.pointCheck(100))
		return TRUE

	var/mob/living/intangible/flock/flockmind/F = holder.owner
	waiting = TRUE
	SPAWN(0)
		F.partition()
		waiting = FALSE

/////////////////////////////////////////

/datum/targetable/flockmindAbility/healDrone
	name = "Concentrated Repair Burst"
	desc = "Fully heal a drone through acceleration of its repair processes."
	icon_state = "heal_drone"
	cooldown = 20 SECONDS

/datum/targetable/flockmindAbility/healDrone/cast(mob/living/critter/flock/drone/target)
	if(..())
		return TRUE
	if(!istype(target))
		return TRUE
	if (target.get_health_percentage() >= 1)
		boutput(holder.owner, "<span class='notice'>[target.real_name] has no damage!</span>")
		return TRUE
	if (isdead(target))
		return TRUE

	playsound(holder.owner, "sound/misc/flockmind/flockmind_cast.ogg", 80, 1)
	boutput(holder.owner, "<span class='notice'>You focus the flock's efforts on fixing [target.real_name]</span>")
	sleep(1.5 SECONDS)
	target.HealDamage("All", 200, 200)
	target.visible_message("<span class='notice'><b>[target]</b> suddenly reforms its broken parts into a solid whole!</span>", "<span class='notice'>The flockmind has restored you to full health!</span>")

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
		return TRUE
	if(F.flock.getComplexDroneCount() == 1)
		boutput(F, "<span class='alert'>That's your last complex drone. Diffracting it would be suicide.</span>")
		return TRUE
	boutput(F, "<span class='notice'>You diffract the drone.</span>")
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
	for(var/obj/machinery/door/airlock/A in range(10, holder.owner))
		if(A.canAIControl())
			targets += A
	if(targets.len > 1)
		// do casty stuff here
		playsound(holder.owner, "sound/misc/flockmind/flockmind_cast.ogg", 80, 1)
		boutput(holder.owner, "<span class='notice'>You force open all the doors around you.</span>")
		sleep(1.5 SECONDS)
		for(var/obj/machinery/door/airlock/A in targets)
			// open the door
			SPAWN(1 DECI SECOND)
				A.open()
	else
		boutput(holder.owner, "<span class='alert'>No targets in range that can be opened via radio.</span>")
		return 1

/////////////////////////////////////////

/datum/targetable/flockmindAbility/radioStun
	name = "Radio Stun Burst"
	desc = "Overwhelm the radio headsets of everyone nearby. Will not work on broken or non-existent headsets."
	icon_state = "radio_stun"
	cooldown = 20 SECONDS
	targeted = 0

/datum/targetable/flockmindAbility/radioStun/cast(atom/target)
	if(..())
		return 1
	var/list/targets = list()
	for(var/mob/living/M in range(10, holder.owner))
		if(isflock(M))
			continue // don't affect us or our flockdrones, yeesh
		if(M.ear_disability)
			// skip this one
			continue
		var/obj/item/device/radio/R = M.ears
		if(istype(R) && R.listening)
			// your headset's on, you're fair game!!
			targets += M
	if(targets.len >= 1)
		playsound(holder.owner, "sound/misc/flockmind/flockmind_cast.ogg", 80, 1)
		boutput(holder.owner, "<span class='notice'>You transmit the worst static you can weave into the headsets around you.</span>")
		for(var/mob/living/M in targets)
			playsound(M, "sound/effects/radio_sweep[rand(1,5)].ogg", 100, 1)
			boutput(M, "<span class='alert'>Horrifying static bursts into your headset, disorienting you severely!</span>")
			M.apply_sonic_stun(3, 6, 60, 0, 0, rand(1, 3), rand(1, 3))
	else
		boutput(holder.owner, "<span class='alert'>No targets in range with active radio headsets.</span>")
		return 1

/////////////////////////////////////////

/datum/targetable/flockmindAbility/directSay
	name = "Narrowbeam Transmission"
	desc = "Directly send a transmission to a target's radio headset, or send a transmission to a radio to broadcast."
	icon_state = "talk"
	cooldown = 0

/datum/targetable/flockmindAbility/directSay/cast(atom/target)
	if(..())
		return 1
	var/obj/item/device/radio/R
	var/message
	if(ismob(target))
		var/mob/living/M = target
		// RADIO CHECK
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
			logTheThing("say", usr, target, "Narrowbeam Transmission to [constructTarget(target,"say")]: [message]")
			message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
			var/flockName = "--.--"
			var/mob/living/intangible/flock/flockmind/F = holder.owner
			if(F)
				var/datum/flock/flock = F.flock
				if(flock)
					flockName = flock.name
			R.audible_message("<span class='radio' style='color: [R.device_color]'><span class='name'>Unknown</span><b> [bicon(R)]\[[flockName]\]</b> <span class='message'>crackles, \"[message]\"</span></span>")
			boutput(holder.owner, "<span class='flocksay'>You transmit to [M.name], \"[message]\"</span>")
		else
			boutput(holder.owner, "<span class='alert'>They don't have any compatible radio devices that you can find.</span>")
			return 1
	else if(istype(target, /obj/item/device/radio))
		R = target
		message = html_encode(input("What would you like to broadcast to [R]?", "Transmission", "") as text)
		logTheThing("say", usr, target, "Narrowbeam Transmission to [constructTarget(target,"say")]: [message]")
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

		//set up message
		var/datum/language/L = languages.language_cache["english"]
		var/list/messages = L.get_messages(radioGarbleText(message, 10))
		// temporarily swap names about
		var/name = holder.owner.name
		holder.owner.name = "Unknown"
		R.talk_into(holder.owner, messages, 0, "Unknown")
		holder.owner.name = name
	else
		boutput(holder.owner, "<span class='alert'>That isn't a valid target.</span>")
		return 1

/////////////////////////////////////////

/datum/targetable/flockmindAbility/controlPanel
	name = "Flock Control Panel"
	desc = "Open the Flock control panel."
	icon_state = "radio_stun"
	targeted = 0
	cooldown = 0

/datum/targetable/flockmindAbility/controlPanel/cast(atom/target)
	if(..())
		return TRUE
	var/mob/living/intangible/flock/flockmind/F = holder.owner
	F.flock.ui_interact(F, F.flock.flockpanel)

////////////////////////////////

/datum/targetable/flockmindAbility/createStructure
	name = "Fabricate Structure"
	desc = "Create a structure tealprint for your drones to construct onto."
	icon_state = "fabstructure"
	cooldown = 0
	targeted = 0

/datum/targetable/flockmindAbility/createStructure/cast()
	var/turf/T = get_turf(holder.owner)
	if(!istype(T, /turf/simulated/floor/feather))
		boutput(holder.owner, "<span class='alert'>You aren't above a flocktile.</span>")//todo maybe make this flock themed?
		return TRUE
	if(locate(/obj/flock_structure/ghost) in T)
		boutput(holder.owner, "<span class='alert'>A tealprint has already been scheduled here!</span>")
		return TRUE
	if(locate(/obj/flock_structure) in T)
		boutput(holder.owner, "<span class='alert'>There is already a flock structure on this flocktile!</span>")
		return TRUE

	var/list/friendlyNames = list()
	var/mob/living/intangible/flock/flockmind/F = holder.owner
	for(var/datum/unlockable_flock_structure/ufs as anything in F.flock.unlockableStructures)
		if(ufs.check_unlocked())
			friendlyNames += ufs.friendly_name


	//todo: replace with FANCY tgui/chui window with WHEELS and ICONS and stuff!
	var/structurewanted = tgui_input_list(holder.owner, "Select which structure you would like to create", "Tealprint selection", friendlyNames)

	if (!structurewanted)
		return TRUE
	var/obj/flock_structure/structurewantedtype = null
	for(var/datum/unlockable_flock_structure/ufs as anything in F.flock.unlockableStructures)
		if(ufs.friendly_name == structurewanted)
			structurewantedtype = ufs.structType
			break

	if(structurewantedtype)
		return F.createstructure(structurewantedtype, initial(structurewantedtype.resourcecost))

/////////////////////////////////////////

/datum/targetable/flockmindAbility/ping
	name = "Ping"
	desc = "Request attention from other elements of the flock."
	icon_state = "ping"
	cooldown = 0.1 SECONDS

/datum/targetable/flockmindAbility/ping/cast(atom/target)
	if(..())
		return TRUE
	var/mob/living/intangible/flock/F = holder.owner
	if (!isturf(target.loc) && !isturf(target))
		return TRUE
	if(F)
		var/datum/flock/flock = F.flock
		flock?.ping(target, holder.owner)

/////////////////////////////////////////

/datum/targetable/flockmindAbility/deconstruct
	name = "Mark for Deconstruction"
	desc = "Mark an existing flock structure for deconstruction, refunding some resources."
	icon_state = "ping"
	cooldown = 0.1 SECONDS

/datum/targetable/flockmindAbility/deconstruct/cast(atom/target)
	if(..())
		return TRUE
	var/mob/living/intangible/flock/F = holder.owner
	//special handling for building ghosts
	if(istype(target,/obj/flock_structure/ghost))
		//do the tgui window instead
		//this actually doesn't need bonus behaviour because the cancelbuild is on click, but will need to fix this if we change that in future
		return TRUE
	else if(HAS_ATOM_PROPERTY(target,PROP_ATOM_FLOCK_THING)) //it's a thing we've converted, we can deconstruct it
		F.flock.deconstruct_targets += target
		F.flock.updateAnnotations()
		return FALSE
	else if(istype(target,/obj/structure/girder)) //special handling for partially decon'd walls - gnesis mats means its ours
		if(target?.material.mat_id == "gnesis")
			F.flock.deconstruct_targets += target
			F.flock.updateAnnotations()
			return FALSE

	return TRUE



