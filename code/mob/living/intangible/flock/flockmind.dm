/////////////////
// FLOCKMIND MOB
/////////////////
/mob/living/intangible/flock/flockmind
	name = "Flockmind"
	real_name = "Flockmind"
	desc = "The collective machine consciousness of a bunch of glass peacock things."
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "flockmind"

	var/started = 0
	var/last_time // when i say per second I MEAN PER SECOND DAMMIT

/mob/living/intangible/flock/flockmind/New()
	..()

	src.abilityHolder = new /datum/abilityHolder/flockmind(src)
	src.last_time = world.timeofday

	src.flock = new /datum/flock()
	src.real_name = "Flockmind [src.flock.name]"
	src.name = src.real_name
	src.flock.registerFlockmind(src)
	src.flock.showAnnotations(src)
	src.addAbility(/datum/targetable/flockmindAbility/controlPanel)
	src.addAbility(/datum/targetable/flockmindAbility/spawnEgg)

/mob/living/intangible/flock/flockmind/special_desc(dist, mob/user)
  if(isflock(user))
    return {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
    <br><span class='bold'>ID:</span> [src.real_name]
    <br><span class='bold'>Flock:</span> [src.flock ? src.flock.name : "none, somehow"]
    <br><span class='bold'>Resources:</span> [src.flock.total_resources()]
    <br><span class='bold'>System Integrity:</span> [round(src.flock.total_health_percentage()*100)]%
    <br><span class='bold'>Cognition:</span> COMPUTATIONAL NEXUS
    <br>###=-</span></span>"}
  else
    return null // give the standard description

// TEMPORARY, I FUCKING HATE STAT PANELS
/mob/living/intangible/flock/flockmind/Stat()
	..()
	stat(null, " ")
	if(src.flock)
		stat("Flock:", src.flock.name)
		stat("Drones:", src.flock.units.len)
	else
		stat("Flock:", "none")
		stat("Drones:", 0)

/mob/living/intangible/flock/flockmind/Login()
	..()
	abilityHolder.updateButtons()

/mob/living/intangible/flock/flockmind/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1
	if (src.started && src.flock && src.flock.units && src.flock.units.len <= 0)
		src.death() // get rekt

/mob/living/intangible/flock/flockmind/proc/spawnEgg()
	if(src.flock)
		var/obj/flock_structure/rift/r = new(get_turf(src), src.flock)
		r.mainflock = src.flock
		playsound(get_turf(src), "sound/impact_sounds/Metal_Clang_1.ogg", 30, 1)
	else
		boutput(src, "<span class='alert'>You don't have a flock, it's not going to listen to you! Also call a coder, this should be impossible!</span>")
		return
	src.started = 1
	src.removeAbility(/datum/targetable/flockmindAbility/spawnEgg)
	src.addAllAbilities()

/mob/living/intangible/flock/flockmind/proc/addAllAbilities()
	src.addAbility(/datum/targetable/flockmindAbility/designateTile)
	src.addAbility(/datum/targetable/flockmindAbility/designateEnemy)
	src.addAbility(/datum/targetable/flockmindAbility/partitionMind)
	src.addAbility(/datum/targetable/flockmindAbility/splitDrone)
	src.addAbility(/datum/targetable/flockmindAbility/healDrone)
	src.addAbility(/datum/targetable/flockmindAbility/doorsOpen)
	src.addAbility(/datum/targetable/flockmindAbility/radioStun)
	src.addAbility(/datum/targetable/flockmindAbility/directSay)
	src.addAbility(/datum/targetable/flockmindAbility/createStructure)

/mob/living/intangible/flock/flockmind/proc/addAbility(var/abilityType)
	src.abilityHolder.addAbility(abilityType)

/mob/living/intangible/flock/flockmind/proc/removeAbility(var/abilityType)
	src.abilityHolder.removeAbility(abilityType)

/mob/living/intangible/flock/flockmind/death(gibbed)
	if(src.client)
		boutput(src, "<span class='alert'>With the last of your drones dying, nothing is left to compute your consciousness. You abruptly cease to exist.</span>")
	src.flock?.perish()
	src.invisibility = 0
	src.icon_state = "blank"
	src.canmove = 0
	flick("flockmind-death", src)
	src.ghostize()
	spawn(2 SECONDS) // wait for the animation to finish
		qdel(src)

/mob/living/intangible/flock/flockmind/ghostize()
	var/mob/dead/observer/O = ..()
	if (!O)
		return null

	O.icon = src.icon
	O.icon_state = "flockmind-ghost"
	O.pixel_y = initial(O.pixel_y) // WHY DO I NEED TO DO THIS TOO I DON'T EVEN ANIMATE THE PIXEL_Y
	animate_bumble(O) // bob up and down
	O.alpha = 160
	return O

/mob/living/intangible/flock/flockmind/Topic(href, href_list)
	if(href_list["origin"])
		var/atom/movable/origin = locate(href_list["origin"])
		if(origin)
			src.set_loc(get_turf(origin))

// receive volunteers to be a promoted flockdrone
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
		SPAWN_DBG(1 SECOND)
			boutput(src, "<span class='alert'>Unable to partition, please try again later.</span>")
		return
	// pick a random ghost
	var/mob/dead/observer/winner = valid_ghosts[rand(1, valid_ghosts.len)]
	if(winner) // probably a paranoid check
		var/mob/living/trace = winner.make_flocktrace(get_turf(src), src.flock)
		message_admins("[key_name(src)] made [key_name(trace)] a flocktrace via ghost volunteer respawn.")
		logTheThing("admin", src, trace, "made [key_name(trace)] a flocktrace via ghost volunteer respawn.")
		flock_speak(null, "Trace partition \[ [trace.real_name] \] has been instantiated.", src.flock)

/mob/living/intangible/flock/flockmind/proc/partition()
	// send out a request to ghosts
	ghost_notifier.send_notification(src, src, /datum/ghost_notification/respawn/flockdrone)
	boutput(src, "<span class='notice'>Partitioning initiated. Stand by.</span>")

