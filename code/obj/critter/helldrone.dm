
//moved from halloween.dm

/obj/critter/ancient_repairbot/helldrone_guard
	name = "weird machine"
	desc = "A machine, of some sort.  It's probably off."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "drone_service_bot"
	density = 1
	health = 35
	aggressive = 1
	defensive = 0
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_ANY
	atkcarbon = 1
	atksilicon = 1
	atcritter = 0
	firevuln = 0.5
	brutevuln = 0.5
	sleeping_icon_state = "drone_service_bot_off"
	flying = 0
	generic = 0

	var/activated = 0

	New()
		..()
		SPAWN(2 SECONDS)
			if (!activated)
				src.icon_state = sleeping_icon_state

				src.name = initial(src.name)


	process()
		if (!activated)
			sleeping = 10
			on_sleep()
			if (sleeping_icon_state)
				src.icon_state = sleeping_icon_state
			task = "sleeping"
			return

		else
			return ..()

	attackby(obj/item/W, mob/user)
		if (!activated)
			return

		return ..()

	proc/wakeup()
		if (src.activated)
			return

		src.activated = 1
		src.icon_state = initial(src.icon_state)
		src.sleeping = 0
		src.task = "thinking"
		src.desc = "A machine.  Of some sort.  It looks mad"

		src.visible_message("<span class='combat'>[src] seems to power up!</span>")

var/helldrone_awake = 0
var/sound/helldrone_awake_sound = null
var/sound/helldrone_wakeup_sound = null

/proc/helldrone_wakeup()
	if (helldrone_awake == 2)
		return

	for (var/area/helldrone/drone_zone in world)
		LAGCHECK(LAG_LOW)
		helldrone_awake = 2
		for (var/mob/M in drone_zone)
			M << helldrone_wakeup_sound

		for (var/obj/decal/fakeobjects/drone_eye in drone_zone)
			if (drone_eye.icon_state == "eye_array")
				drone_eye.icon_state = "eye_array_on"

			else if (drone_eye.icon_state == "server0")
				drone_eye.desc = "A large rack of server modules."
				drone_eye.icon_state = "server"

		for (var/obj/critter/ancient_repairbot/helldrone_guard/grump_guard in drone_zone)
			grump_guard.wakeup()

	if (helldrone_awake != 2)
		logTheThing(LOG_DEBUG, null, "<b>Halloween Event Error</b>: Unable to locate helldrone areas.")
		return

	return
