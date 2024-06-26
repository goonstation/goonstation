//moved from halloween.dm

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

		for (var/obj/fakeobject/drone_eye in drone_zone)
			if (drone_eye.icon_state == "eye_array")
				drone_eye.icon_state = "eye_array_on"

			else if (drone_eye.icon_state == "server0")
				drone_eye.desc = "A large rack of server modules."
				drone_eye.icon_state = "server"

		for (var/mob/living/critter/robotic/repairbot/helldrone/grump_guard in drone_zone)
			grump_guard.wakeup()

	if (helldrone_awake != 2)
		logTheThing(LOG_DEBUG, null, "<b>Halloween Event Error</b>: Unable to locate helldrone areas.")
		return

	return
