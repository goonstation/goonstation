//space is pretty dark, someone should probably turn on the lights
/obj/item/shipcomponent/pod_lights
	name = "Star Lights"
	desc = "A pair of standard pod lights."
	power_used = 30
	system = "Lights"
	//icon_state = "lights"
	var/datum/light/light1
	var/col_r = 0.9
	var/col_g = 0.8
	var/col_b = 0.7

	// base class for pod lights

	activate()
		..()

	deactivate()
		..()

	// pod_1x1 are the default lighting given to all pods, override this if you need to use a bigger pod
	pod_1x1

		New()
			..()
			light1 = new /datum/light/point
			light1.set_brightness(1)
			light1.set_color(col_r, col_g, col_b)

		// defined to have a single light point
		activate()
			..()
			light1.attach(ship)
			light1.enable()
			return

		deactivate()
			..()
			light1.disable()
			light1.detach(ship)
			return

	pod_2x2
		var/datum/light/light2
		var/datum/light/light3
		var/datum/light/light4

		// Turns on four lights because I can't figure out how to do two lights out front facing the direction the pod is heading
		New()
			..()
			var/brightness = 0.85
			light1 = new /datum/light/point
			light1.set_brightness(brightness)
			light1.set_color(col_r, col_g, col_b)
			light2 = new /datum/light/point
			light2.set_brightness(brightness)
			light2.set_color(col_r, col_g, col_b)
			light3 = new /datum/light/point
			light3.set_brightness(brightness)
			light3.set_color(col_r, col_g, col_b)
			light4 = new /datum/light/point
			light4.set_brightness(brightness)
			light4.set_color(col_r, col_g, col_b)

		activate()
			..()
			light1.attach(ship, 0, 0)	// attach bottom left
			light2.attach(ship, 0, 2)	// attach top left
			light3.attach(ship, 2, 2)	// attach top right
			light4.attach(ship, 2, 0)	// attach bottom right
			light1.enable()
			light2.enable()
			light3.enable()
			light4.enable()
			return

		deactivate()
			..()
			light1.disable()
			light2.disable()
			light3.disable()
			light4.disable()
			light1.detach()
			light2.detach()
			light3.detach()
			light4.detach()
			return

/obj/item/shipcomponent/pod_lights/police_siren
	name = "Police Lights"
	desc = "Wee woo."
	icon_state= "sec_system"

	var/weeoo_in_progress = 0

	New()
		..()
		light1 = new /datum/light/point
		light1.set_brightness(1)

	activate()
		..()
		weeoo()
		return

	deactivate()
		if (weeoo_in_progress)
			return
		..()

		return


	proc/weeoo()
		if (weeoo_in_progress)
			return

		weeoo_in_progress = 10
		SPAWN_DBG (0)
			playsound(src.loc, "sound/machines/siren_police.ogg", 50, 1)
			light1.attach(ship)
			light1.enable()
			while (weeoo_in_progress--)
				light1.set_color(0.9, 0.1, 0.1)
				sleep(0.3 SECONDS)
				light1.set_color(0.1, 0.1, 0.9)
				sleep(0.3 SECONDS)
			light1.disable()
			light1.detach(ship)
			weeoo_in_progress = 0
			src.deactivate()
