/////////////////
// FLOCKMIND MOB
/////////////////
/mob/living/intangible/flock/flockmind
	name = "Flockmind"
	real_name = "Flockmind"
	desc = "The collective machine consciousness of a bunch of glass peacock things."
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "flockmind"

	var/started = FALSE
	///Pity respawn counter
	var/current_try = 1
	///Pity respawn max
	var/max_tries = 3


/mob/living/intangible/flock/flockmind/New(turf/newLoc, datum/flock/F = null)
	..()

	src.abilityHolder = new /datum/abilityHolder/flockmind(src)

	src.flock = F || new /datum/flock()
	src.real_name = "Flockmind [src.flock.name]"
	src.name = src.real_name
	src.update_name_tag()
	src.flock.registerFlockmind(src)
	if (!F)
		src.addAbility(/datum/targetable/flockmindAbility/spawnEgg)
		src.addAbility(/datum/targetable/flockmindAbility/ping)
	else
		src.started = TRUE
		src.addAllAbilities()

/mob/living/intangible/flock/flockmind/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	return {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
		<br><span class='bold'>ID:</span> [src.real_name]
		<br><span class='bold'>Flock:</span> [src.flock ? src.flock.name : "none, somehow"]
		<br><span class='bold'>Resources:</span> [src.flock.total_resources()]
		<br><span class='bold'>Total Compute:</span> [src.flock.total_compute()]
		<br><span class='bold'>System Integrity:</span> [round(src.flock.total_health_percentage()*100)]%
		<br><span class='bold'>Cognition:</span> COMPUTATIONAL NEXUS
		<br>###=-</span></span>"}

/mob/living/intangible/flock/flockmind/proc/getTraceToPromote()
	var/list/eligible_traces = src.flock.getActiveTraces()
	if (length(eligible_traces))
		return tgui_input_list(src, "Choose Flocktrace to promote to Flockmind", "Promotion", sortList(eligible_traces, /proc/cmp_text_asc))
	else
		return -1

/mob/living/intangible/flock/flockmind/Login()
	..()
	abilityHolder.updateButtons()

/mob/living/intangible/flock/flockmind/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return TRUE
	if (!src.flock)
		return
	src.flock.peak_compute = max(src.flock.peak_compute, src.flock.total_compute())
	if (src.afk_counter > FLOCK_AFK_COUNTER_THRESHOLD * 3 / 4)
		if (!ON_COOLDOWN(src, "afk_message", FLOCK_AFK_COUNTER_THRESHOLD))
			boutput(src, "<span class='flocksay'><b>\[SYSTEM: Sentience pause detected. Preparing promotion routines.\]</b></span>")
		if (src.afk_counter > FLOCK_AFK_COUNTER_THRESHOLD)
			var/list/traces = src.flock.getActiveTraces()
			if (length(traces))
				boutput(src, "<span class='flocksay'><b>\[SYSTEM: Lack of sentience confirmed. Self-programmed routines promoting new Flockmind.\]</b></span>")
				var/mob/living/intangible/flock/trace/chosen_trace = pick(traces)
				chosen_trace.promoteToFlockmind(FALSE)
			src.afk_counter = 0
	if (src.started)
		if (src.flock.getComplexDroneCount())
			return
		for (var/obj/flock_structure/s in src.flock.structures)
			if (istype(s, /obj/flock_structure/egg) || istype(s, /obj/flock_structure/rift))
				return
		src.death()

/mob/living/intangible/flock/flockmind/proc/spawnEgg()
	if(src.flock)
		new /obj/flock_structure/rift(get_turf(src), src.flock)
		playsound(src, 'sound/impact_sounds/Metal_Clang_1.ogg', 30, 1)
	else
		boutput(src, "<span class='alert'>You don't have a flock, it's not going to listen to you! Also call a coder, this should be impossible!</span>")
		return
	src.removeAbility(/datum/targetable/flockmindAbility/spawnEgg)
	src.addAllAbilities()

/mob/living/intangible/flock/flockmind/proc/addAllAbilities()
	src.addAbility(/datum/targetable/flockmindAbility/controlPanel)
	src.addAbility(/datum/targetable/flockmindAbility/designateTile)
	src.addAbility(/datum/targetable/flockmindAbility/designateEnemy)
	src.addAbility(/datum/targetable/flockmindAbility/designateAlly)
	src.addAbility(/datum/targetable/flockmindAbility/partitionMind)
	src.addAbility(/datum/targetable/flockmindAbility/splitDrone)
	src.addAbility(/datum/targetable/flockmindAbility/healDrone)
	src.addAbility(/datum/targetable/flockmindAbility/doorsOpen)
	src.addAbility(/datum/targetable/flockmindAbility/radioStun)
	src.addAbility(/datum/targetable/flockmindAbility/directSay)
	src.addAbility(/datum/targetable/flockmindAbility/createStructure)
	src.addAbility(/datum/targetable/flockmindAbility/deconstruct)

/mob/living/intangible/flock/flockmind/proc/reset()
	for (var/datum/targetable/ability in src.abilityHolder.abilities)
		//do not remove the hidden drone control ability
		if (istype(ability, /datum/targetable/flockmindAbility/droneControl))
			continue
		src.abilityHolder.removeAbilityInstance(ability)
	src.addAbility(/datum/targetable/flockmindAbility/spawnEgg)
	src.addAbility(/datum/targetable/flockmindAbility/ping)
	src.started = FALSE

/mob/living/intangible/flock/flockmind/death(gibbed, relay_destroyed = FALSE, suicide = FALSE)
	src.emote("scream")
	if (src.flock.peak_compute < 200 && src.current_try < src.max_tries)
		src.reset()
		src.flock?.perish(FALSE)
		src.current_try++
		boutput(src, "<span class='alert'><b>With no drones left in your Flock you retreat back into the Signal, ready to open another rift. You are now iteration [src.current_try].</b></span>")
		return
	. = ..()
	if(src.client)
		if (relay_destroyed)
			boutput(src, "<span class='alert'>With the destruction of the Relay, the Flock loses its strength, and you fade away.</span>")
		else if (!suicide)
			boutput(src, "<span class='alert'>With no drones left in your Flock, nothing is left to compute your consciousness. You abruptly cease to exist.</span>")
		else
			boutput(src, "<span class='alert'>You deactivate your Flock and abruptly cease to exist.</span>")
	src.flock?.perish()
	REMOVE_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src)
	src.icon_state = "blank"
	src.canmove = FALSE
	flick("flockmind-death", src)
	src.ghostize()
	spawn(2 SECONDS) // wait for the animation to finish
		qdel(src)

/mob/living/intangible/flock/flockmind/ghostize()
	var/mob/dead/observer/O = ..()
	if (!O)
		return null

	// manual ghost icon creation
	O.icon = src.icon
	O.icon_state = "flockmind-ghost"
	O.pixel_y = initial(O.pixel_y) // WHY DO I NEED TO DO THIS TOO I DON'T EVEN ANIMATE THE PIXEL_Y
	animate_bumble(O)
	O.alpha = 160
	return O


/mob/living/intangible/flock/flockmind/proc/partition(free = FALSE)
	boutput(src, "<span class='flocksay'>Partitioning initiated. Stand by.</span>")

	var/ghost_confirmation_delay = 30 SECONDS

	var/list/text_messages = list()
	text_messages.Add("Would you like to respawn as a Flocktrace? Your name will be added to the list of eligible candidates.")
	text_messages.Add("You are eligible to be respawned as a Flocktrace. You have [ghost_confirmation_delay / 10] seconds to respond to the offer.")
	text_messages.Add("You have been added to the list of eligible candidates. The game will pick a player soon. Good luck!")

	message_admins("Sending Flocktrace offer to eligible ghosts. They have [ghost_confirmation_delay / 10] seconds to respond.")
	var/list/candidates = dead_player_list(FALSE, ghost_confirmation_delay, text_messages, TRUE)

	if (src.disposed)
		message_admins("[src.real_name] has died during a Flocktrace respawn offer event.")
		logTheThing(LOG_ADMIN, null, "No Flocktraces were created for [src.real_name] due to their death.")
		return TRUE

	if (!length(candidates))
		message_admins("No ghosts responded to a Flocktrace offer from [src.real_name]")
		logTheThing(LOG_ADMIN, null, "No ghosts responded to Flocktrace offer from [src.real_name]")
		boutput(src, "<span class='flocksay'>Partition failure: unable to coalesce sentience.</span>")
		return TRUE

	if (!free && !src.abilityHolder.pointCheck(FLOCKTRACE_COMPUTE_COST))
		message_admins("A Flocktrace offer from [src.real_name] was sent but failed due to lack of compute.")
		logTheThing(LOG_ADMIN, null, "Flocktrace offer from [src.real_name] failed due to lack of compute.")
		boutput(src, "<span class='flocksay'>Partition failure: Compute required unavailable.</span>")
		return TRUE

	var/mob/picked = pick(candidates)

	message_admins("[picked.key] respawned as a Flocktrace under [src.real_name].")
	logTheThing(LOG_ADMIN, picked.key, "respawned as a Flocktrace under [src.real_name].")

	picked.make_flocktrace(get_turf(src), src.flock, free)

// old code for flocktrace respawns
/datum/ghost_notification/respawn/flockdrone
	respawn_explanation = "flockmind partition"
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "flocktrace"

/mob/living/intangible/flock/flockmind/proc/receive_ghosts(var/list/ghosts)
	if(!ghosts || ghosts.len <= 0)
		boutput(src, "<span class='alert'>Unable to partition, please try again later.</span>")
		return
	var/list/valid_ghosts = list()
	for(var/mob/dead/observer/O in ghosts)
		if(O?.client)
			valid_ghosts |= O
	if(valid_ghosts.len <= 0)
		SPAWN(1 SECOND)
			boutput(src, "<span class='alert'>Unable to partition, please try again later.</span>")
		return
	// pick a random ghost
	var/mob/dead/observer/winner = valid_ghosts[rand(1, valid_ghosts.len)]
	if(winner) // probably a paranoid check
		var/mob/living/trace = winner.make_flocktrace(get_turf(src), src.flock)
		message_admins("[key_name(src)] made [key_name(trace)] a flocktrace via ghost volunteer respawn.")
		logTheThing(LOG_ADMIN, src, "made [key_name(trace)] a flocktrace via ghost volunteer respawn.")
		flock_speak(null, "Trace partition \[ [trace.real_name] \] has been instantiated.", src.flock)
