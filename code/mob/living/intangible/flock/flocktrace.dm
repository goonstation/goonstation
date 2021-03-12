/////////////////
// FLOCKTRACE
/////////////////
// Unlike the flockmind, when player drones exit their corporeal body to jump into another one,
// they're tiny little flickers of thought.
/mob/living/intangible/flock/trace
	name = "weird radio ghost bird"
	real_name = "Flocktrace"
	desc = "The representation of a partition of the will of the flockmind."
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "flocktrace"

/mob/living/intangible/flock/trace/New(atom/loc, datum/flock/F)
	..()

	src.abilityHolder = new /datum/abilityHolder/flockmind(src)

	src.real_name = "[pick(consonants_upper)][pick(vowels_lower)].[pick(vowels_lower)]"

	if(istype(F))
		src.flock = F
		src.flock.addTrace(src)
	else
		src.death() // f u
	src.abilityHolder.addAbility(/datum/targetable/flockmindAbility/createStructure)

/mob/living/intangible/flock/trace/proc/describe_state()
	var/state = list()
	state["update"] = "partition"
	state["ref"] = "\ref[src]"
	state["name"] = src.real_name
	var/mob/living/critter/flock/host = src.loc
	if(istype(host))
		state["host"] = host.real_name
		state["health"] = round(host.get_health_percentage()*100)
	else
		state["host"] = null
		state["health"] = 100
	. = state


/mob/living/intangible/flock/trace/special_desc(dist, mob/user)
  if(isflock(user))
    return {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
    <br><span class='bold'>ID:</span> [src.real_name]
    <br><span class='bold'>Flock:</span> [src.flock ? src.flock.name : "none, somehow"]
    <br><span class='bold'>Resources:</span> [src.flock.total_resources()]
    <br><span class='bold'>System Integrity:</span> [round(src.flock.total_health_percentage()*100)]%
    <br><span class='bold'>Cognition:</span> SYNAPTIC PROCESS
    <br>###=-</span></span>"}
  else
    return null // give the standard description

// TEMPORARY, I FUCKING HATE STAT PANELS
/mob/living/intangible/flock/trace/Stat()
	..()
	stat(null, " ")
	if(src.flock)
		stat("Flock:", src.flock.name)
		stat("Drones:", length(src.flock.units))
	else
		stat("Flock:", "none")
		stat("Drones:", 0)

/mob/living/intangible/flock/trace/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1
	if (src.flock && src.flock.units && src.flock.units.len <= 0)
		boutput(src, "<span class='alert'>There are no more drones left in the flock to compute your consciousness!</span>")
		src.death() // get rekt

/mob/living/intangible/flock/trace/death(gibbed)
	if(src.client)
		boutput(src, "<span class='alert'>You cease to exist abruptly.</span>")
	src.flock?.removeTrace(src)
	src.invisibility = 0
	src.icon_state = "blank"
	src.canmove = 0
	flick("flocktrace-death", src)
	src.ghostize()
	spawn(2 SECONDS) // wait for the animation to finish
		qdel(src)

/mob/living/intangible/flock/trace/ghostize()
	var/mob/dead/observer/O = ..()
	if (!O)
		return null

	O.icon = src.icon
	O.icon_state = "flocktrace-ghost"
	O.pixel_y = initial(O.pixel_y) // WHY DO I NEED TO DO THIS TOO I DON'T EVEN ANIMATE THE PIXEL_Y
	animate_bumble(O) // bob up and down
	O.alpha = 160
	return O
