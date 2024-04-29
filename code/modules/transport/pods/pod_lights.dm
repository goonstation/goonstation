//space is pretty dark, someone should probably turn on the lights
/obj/item/shipcomponent/pod_lights
	name = "Star Lights"
	desc = "A pair of standard pod lights."
	power_used = 30
	system = "Lights"
	icon_state = "star_lights"
	var/hud_state = "lights"

	var/col_r = 0.9
	var/col_g = 0.8
	var/col_b = 0.7

	// base class for pod lights

	activate()
		return ..()

	deactivate()
		..()

	// pod_1x1 are the default lighting given to all pods, override this if you need to use a bigger pod
	pod_1x1

		// defined to have a single light point
		activate()
			if(..())
				ship.add_sm_light("pod_lights\ref[src]", list(col_r*255,col_g*255,col_b*255,255), directional = 1)
				ship.toggle_sm_light(1)
				return TRUE
			return FALSE

		deactivate()
			..()
			ship.toggle_sm_light(0)
			return

	pod_2x2
		var/datum/light/light1
		var/datum/light/light2
		var/datum/light/light3
		var/datum/light/light4

		// Turns on four lights because I can't figure out how to do two lights out front facing the direction the pod is heading
		// TODO : fix this, it's 2x the load than we need out of this
		New()
			..()
			var/brightness = 2
			light1 = new /datum/light/line
			light1.set_brightness(brightness)
			light1.set_color(col_r, col_g, col_b)
			light2 = new /datum/light/line
			light2.set_brightness(brightness)
			light2.set_color(col_r, col_g, col_b)
			light3 = new /datum/light/line
			light3.set_brightness(brightness)
			light3.set_color(col_r, col_g, col_b)
			light4 = new /datum/light/line
			light4.set_brightness(brightness)
			light4.set_color(col_r, col_g, col_b)

		activate()
			if(..())
				light1.attach(ship, 0, 0)	// attach bottom left
				light2.attach(ship, 0, 2)	// attach top left
				light3.attach(ship, 2, 2)	// attach top right
				light4.attach(ship, 2, 0)	// attach bottom right
				light1.enable()
				light2.enable()
				light3.enable()
				light4.enable()
				return TRUE
			return FALSE

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
	icon_state = "police_siren"
	hud_state = "siren"

	var/weeoo_in_progress = 0


	activate()
		if(..())
			weeoo()
			return TRUE
		return FALSE

	deactivate()
		if (weeoo_in_progress)
			return
		..()

		return


	proc/weeoo()
		if (weeoo_in_progress)
			return

		weeoo_in_progress = 10
		SPAWN(0)
			playsound(src.loc, 'sound/machines/siren_police.ogg', 50, 1)

			ship.add_sm_light("pod_lights\ref[src]", list(0.1*255,0.1*255,0.9*255,200), directional = 1)
			src.toggle_sm_light(1)

			while (weeoo_in_progress--)
				ship.add_sm_light("pod_lights\ref[src]", list(0.9*255,0.1*255,0.1*255,200), directional = 1)
				sleep(0.3 SECONDS)
				ship.add_sm_light("pod_lights\ref[src]", list(0.1*255,0.1*255,0.9*255,200), directional = 1)
				sleep(0.3 SECONDS)
			src.toggle_sm_light(0)
			weeoo_in_progress = 0
			src.deactivate()

