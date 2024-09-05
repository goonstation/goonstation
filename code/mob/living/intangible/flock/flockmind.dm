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
	///Pity respawn max
	var/max_respawns = 1

	var/datum/tutorial_base/regional/flock/tutorial = null


/mob/living/intangible/flock/flockmind/New(turf/newLoc, datum/flock/F = null)
	src.flock = F || new /datum/flock()
	..()

	src.abilityHolder = new /datum/abilityHolder/flockmind(src)

	src.real_name = "Flockmind [src.flock.name]"
	src.name = src.real_name
	if(src.flock.name == "ba.ba") //this easteregg used with permission from Hempuli. Thanks Hempuli!
		src.icon_state = "baba"
	src.update_name_tag()
	src.flock.registerFlockmind(src)
	if (!F)
		src.addAbility(/datum/targetable/flockmindAbility/spawnEgg)
		src.addAbility(/datum/targetable/flockmindAbility/ping)
		src.addAbility(/datum/targetable/flockmindAbility/tutorial)
	else
		src.started = TRUE
		src.addAllAbilities()

/mob/living/intangible/flock/flockmind/proc/start_tutorial()
	if (src.tutorial)
		return
	src.tutorial = new(src)
	if (src.tutorial.initial_turf)
		src.tutorial.Start()
	else
		boutput(src, SPAN_ALERT("Could not start tutorial! Please try again later or call Wire."))
		logTheThing(LOG_GAMEMODE, src, "Failed to set up flock tutorial, something went very wrong.")
		src.tutorial = null

/mob/living/intangible/flock/flockmind/select_drone(mob/living/critter/flock/drone/drone)
	if(src.tutorial && !src.tutorial.PerformAction(FLOCK_ACTION_DRONE_SELECT))
		return
	..()

/mob/living/intangible/flock/flockmind/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	return {"[SPAN_FLOCKSAY("[SPAN_BOLD("###=- Ident confirmed, data packet received.")]<br>\
		[SPAN_BOLD("ID:")] [src.real_name]<br>\
		[SPAN_BOLD("Flock:")] [src.flock ? src.flock.name : "none, somehow"]<br>\
		[SPAN_BOLD("Resources:")] [src.flock.total_resources()]<br>\
		[SPAN_BOLD("Total Compute:")] [src.flock.total_compute()]<br>\
		[SPAN_BOLD("System Integrity:")] [round(src.flock.total_health_percentage()*100)]%<br>\
		[SPAN_BOLD("Cognition:")] COMPUTATIONAL NEXUS<br>\
		[SPAN_BOLD("###=-")]")]"}

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
	if (!src.flock || src.flock.dead)
		return
	src.flock.stats.peak_compute = max(src.flock.stats.peak_compute, src.flock.total_compute())
	if (src.afk_counter > FLOCK_AFK_COUNTER_THRESHOLD * 3 / 4)
		if (!ON_COOLDOWN(src, "afk_message", FLOCK_AFK_COUNTER_THRESHOLD))
			boutput(src, SPAN_FLOCKSAY("<b>\[SYSTEM: Sentience pause detected. Preparing promotion routines.\]</b>"))
		if (src.afk_counter > FLOCK_AFK_COUNTER_THRESHOLD)
			var/list/traces = src.flock.getActiveTraces()
			if (length(traces))
				boutput(src, SPAN_FLOCKSAY("<b>\[SYSTEM: Lack of sentience confirmed. Self-programmed routines promoting new Flockmind.\]</b>"))
				var/mob/living/intangible/flock/trace/chosen_trace = pick(traces)
				chosen_trace.promoteToFlockmind(FALSE)
			src.afk_counter = 0
	if (src.started)
		if (src.flock.getComplexDroneCount())
			return
		for (var/obj/flock_structure/s as anything in src.flock.structures)
			if (istype(s, /obj/flock_structure/egg) || istype(s, /obj/flock_structure/rift))
				return
		src.death()

/mob/living/intangible/flock/flockmind/proc/spawnEgg()
	if(src.flock)
		new /obj/flock_structure/rift(get_turf(src), src.flock)
		playsound(src, 'sound/impact_sounds/Metal_Clang_1.ogg', 30, TRUE)
	else
		boutput(src, SPAN_ALERT("You don't have a flock, it's not going to listen to you! Also call a coder, this should be impossible!"))
		return
	src.removeAbility(/datum/targetable/flockmindAbility/spawnEgg)
	src.removeAbility(/datum/targetable/flockmindAbility/tutorial)
	src.addAllAbilities()

/mob/living/intangible/flock/flockmind/proc/addAllAbilities()
	src.addAbility(/datum/targetable/flockmindAbility/controlPanel)
	src.addAbility(/datum/targetable/flockmindAbility/designateTile)
	src.addAbility(/datum/targetable/flockmindAbility/designateEnemy)
	src.addAbility(/datum/targetable/flockmindAbility/designateIgnore)
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
	src.addAbility(/datum/targetable/flockmindAbility/tutorial)
	src.started = FALSE

/mob/living/intangible/flock/flockmind/death(gibbed, relay_destroyed = FALSE, suicide = FALSE)
	if (src.tutorial && !suicide)
		return
	src.emote("scream")
	if (src.flock && src.flock.stats.peak_compute < 200 && src.flock.stats.respawns < src.max_respawns)
		src.reset()
		src.flock.perish(FALSE)
		src.flock.stats.respawns++
		logTheThing(LOG_GAMEMODE, src, "respawns using pity respawn number [src.flock.stats.respawns]")
		boutput(src, SPAN_ALERT("<b>With no drones left in your Flock you retreat back into the Signal, ready to open another rift. You are now iteration [src.flock.stats.respawns + 1].</b>"))
		return
	. = ..()
	if(src.client)
		if (relay_destroyed)
			boutput(src, SPAN_ALERT("With the destruction of the Relay, the Flock loses its strength, and you fade away."))
		else if (!suicide)
			boutput(src, SPAN_ALERT("With no drones left in your Flock, nothing is left to compute your consciousness. You abruptly cease to exist."))
		else
			boutput(src, SPAN_ALERT("You deactivate your Flock and abruptly cease to exist."))
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


/mob/living/intangible/flock/flockmind/proc/partition(antagonist_source = ANTAGONIST_SOURCE_SUMMONED)
	boutput(src, SPAN_FLOCKSAY("Partitioning initiated. Stand by."))

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
		boutput(src, SPAN_FLOCKSAY("Partition failure: unable to coalesce sentience."))
		return TRUE

	if ((antagonist_source == ANTAGONIST_SOURCE_SUMMONED) && !src.abilityHolder.pointCheck(FLOCKTRACE_COMPUTE_COST))
		message_admins("A Flocktrace offer from [src.real_name] was sent but failed due to lack of compute.")
		logTheThing(LOG_ADMIN, null, "Flocktrace offer from [src.real_name] failed due to lack of compute.")
		boutput(src, SPAN_FLOCKSAY("Partition failure: Compute required unavailable."))
		return TRUE

	var/mob/picked = candidates[1]

	message_admins("[key_name(picked)] respawned as a Flocktrace under [src.real_name].")
	log_respawn_event(picked.mind, "Flocktrace", src.real_name)

	if (!istype(picked, /mob/dead))
		picked = picked.ghostize() //apparently corpses were being deleted here?

	if (!picked.mind?.add_subordinate_antagonist(ROLE_FLOCKTRACE, source = antagonist_source, master = src.flock.flockmind_mind))
		logTheThing(LOG_DEBUG, "Failed to add flocktrace antagonist role to [key_name(picked)] during partition. THIS IS VERY BAD GO YELL AT A FLOCK CODER.")

// old code for flocktrace respawns
/datum/ghost_notification/respawn/flockdrone
	respawn_explanation = "flockmind partition"
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "flocktrace"

/mob/living/intangible/flock/flockmind/proc/receive_ghosts(var/list/ghosts)
	if(!ghosts || length(ghosts) <= 0)
		boutput(src, SPAN_ALERT("Unable to partition, please try again later."))
		return
	var/list/valid_ghosts = list()
	for(var/mob/dead/observer/O in ghosts)
		if(O?.client)
			valid_ghosts |= O
	if(length(valid_ghosts) <= 0)
		SPAWN(1 SECOND)
			boutput(src, SPAN_ALERT("Unable to partition, please try again later."))
		return
	// pick a random ghost
	var/mob/dead/observer/winner = valid_ghosts[rand(1, valid_ghosts.len)]
	if(winner) // probably a paranoid check
		winner.mind?.add_subordinate_antagonist(ROLE_FLOCKTRACE, master = src.mind)
		var/mob/living/trace = winner.mind.current
		message_admins("[key_name(src)] made [key_name(trace)] a flocktrace via ghost volunteer respawn.")
		logTheThing(LOG_ADMIN, src, "made [key_name(trace)] a flocktrace via ghost volunteer respawn.")
		flock_speak(null, "Trace partition \[ [trace.real_name] \] has been instantiated.", src.flock)
