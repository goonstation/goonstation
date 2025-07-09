
TYPEINFO(/obj/machinery/the_singularitygen)
	mats = 250

ADMIN_INTERACT_PROCS(/obj/machinery/the_singularitygen, proc/activate)

/obj/machinery/the_singularitygen
	name = "Gravitational Singularity Generator"
	desc = "An Odd Device which produces a Black Hole when set up."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "TheSingGen"
	anchored = UNANCHORED // so it can be moved around out of crates
	density = 1
	var/bhole = 0 // it is time. we can trust people to use the singularity For Good - cirr
	var/activating = FALSE

	HELP_MESSAGE_OVERRIDE({"Automatically creates a singularity when all surrounding containment fields are active.\
							Can be anchored/unanchored with a <b>wrench</b>"})

/obj/machinery/the_singularitygen/process()
	if (src.activating)
		return
	var/max_radius = singularity_containment_check(get_turf(src))
	if(isnull(max_radius))
		return

	logTheThing(LOG_BOMBING, src.fingerprintslast, "A [src.name] was activated, spawning a singularity at [log_loc(src)]. Last touched by: [src.fingerprintslast ? "[src.fingerprintslast]" : "*null*"]")
	message_admins("A [src.name] was activated, spawning a singularity at [log_loc(src)]. Last touched by: [key_name(src.fingerprintslast)]")

	var/turf/T = get_turf(src)
	if(isrestrictedz(T?.z))
		src.visible_message(SPAN_NOTICE("[src] refuses to activate in this place. Odd."))
		qdel(src)

	src.activate(max_radius)

/obj/machinery/the_singularitygen/proc/activate(max_radius = null)
	src.activating = TRUE
	var/turf/T = get_turf(src)
	playsound(T, 'sound/machines/singulo_start.ogg', 90, FALSE, 3, flags=SOUND_IGNORE_SPACE)
	src.icon_state = "TheSingGenOhNo"
	SPAWN(7 SECONDS)
		if (src.bhole)
			new /obj/bhole(T, 3000)
		else
			new /obj/machinery/the_singularity(T, 100,,max_radius)
		qdel(src)

/obj/machinery/the_singularitygen/attackby(obj/item/W, mob/user)
	src.add_fingerprint(user)
	if (iswrenchingtool(W))
		if (!anchored)
			anchored = ANCHORED
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
			boutput(user, "You secure the [src.name] to the floor.")
			src.anchored = ANCHORED
		else if (anchored)
			anchored = UNANCHORED
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
			boutput(user, "You unsecure the [src.name].")
			src.anchored = UNANCHORED

		logTheThing(LOG_STATION, user, "[src.anchored ? "bolts" : "unbolts"] a [src.name] [src.anchored ? "to" : "from"] the floor at [log_loc(src)].") // Ditto (Convair880).
		return
	else
		return ..()
