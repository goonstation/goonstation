/////////////////
// FLOCKTRACE
/////////////////
// Unlike the flockmind, when player drones exit their corporeal body to jump into another one,
// they're tiny little flickers of thought.
/mob/living/intangible/flock/trace
	name = "Flocktrace"
	real_name = "Flocktrace"
	desc = "The representation of a partition of the will of the flockmind."
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "flocktrace"
	layer = NOLIGHT_EFFECTS_LAYER_BASE

	compute = -100 //it is expensive to run more threads

/mob/living/intangible/flock/trace/New(atom/loc, datum/flock/F)
	..()

	src.abilityHolder = new /datum/abilityHolder/flockmind(src)

	src.real_name = "[pick(consonants_upper)][pick(vowels_lower)].[pick(vowels_lower)]"
	src.name = src.real_name
	src.update_name_tag()

	if(istype(F))
		src.flock = F
		src.flock.addTrace(src)
	else
		src.death() // f u
	src.addAbility(/datum/targetable/flockmindAbility/designateEnemy)
	src.addAbility(/datum/targetable/flockmindAbility/ping)

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
	var/datum/abilityHolder/flockmind/aH = src.abilityHolder
	aH?.updateCompute()
	if (src.flock && src.flock.total_compute() < src.flock.used_compute())
		boutput(src, "<span class='alert'>The Flock has insufficient compute to sustain your consciousness!</span>")
		src.death() // get rekt

/mob/living/intangible/flock/trace/death(gibbed)
	if(src.client)
		boutput(src, "<span class='alert'>You cease to exist abruptly.</span>")
	src.flock?.removeTrace(src)
	REMOVE_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src)
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
