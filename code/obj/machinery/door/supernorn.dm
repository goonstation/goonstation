/obj/machinery/door/supernorn
	icon = 'icons/Testing/newicons/obj/NEWdoors/door_generic.dmi'
	icon_state = "closed"
	var/welded = 0
	var/panel = 0
	var/vertical = 0
	var/autoclose_delay = 150 // ugh, lets not use the autoclose built into the door type due to autoclose, for now, give doors proper functionality for this later
	density = 1
	opacity = 1

/obj/machinery/door/supernorn/command
	name = "Command"
	icon = 'icons/Testing/newicons/obj/NEWdoors/door_command.dmi'
	req_access = list(access_heads)

/obj/machinery/door/supernorn/security
	name = "Security"
	icon = 'icons/Testing/newicons/obj/NEWdoors/door_security.dmi'
	req_access = list(access_security)


/obj/machinery/door/supernorn/engineering
	name = "Engineering"
	icon = 'icons/Testing/newicons/obj/NEWdoors/door_engineering.dmi'
	req_access = list(access_engineering)

/*/obj/machinery/door/supernorn/medical
	name = "Medical"
	icon = 'door_medical.dmi'
	req_access = list(access_medical)

/obj/machinery/door/supernorn/maintenance
	name = "Maintenance Access"
	icon = 'icons/Testing/newicons/obj/NEWdoors/door_maintenance.dmi'
	req_access = list(access_maint_tunnels*/

/obj/machinery/door/supernorn/update_icon(toggling, override_parent = TRUE)
	if (src.vertical)
		src.icon_state = src.panel_open ? "vopened" : "vclosed"
	else
		src.icon_state = src.panel_open ? "opened" : "closed"

/obj/machinery/door/supernorn/open()
	if (src.panel_open || src.welded || src.locked || src.operating || (src.status & NOPOWER))
		return
	src.operating = 1
	if (src.ignore_light_or_cam_opacity)
		src.set_opacity(0)
	else
		src.RL_SetOpacity(0)
	src.panel_open = 1
	src.play_animation("opening")
	src.UpdateIcon()
	playsound(src, 'sound/machines/airlock_swoosh_temp.ogg', 100, 0)
	SPAWN(2.5)
		set_density(0) // let them through halfway through the anim
	SPAWN(0.5 SECONDS)
		src.operating = 0
	if (src.autoclose_delay)
		SPAWN(src.autoclose_delay)
			src.try_autoclose()

/obj/machinery/door/supernorn/close()
	if (!src.panel_open || src.locked || src.operating || (src.status & NOPOWER))
		return
	if (!src.check_safeties())
		return
	src.operating = 1
	src.panel_open = 0
	src.play_animation("closing")
	src.UpdateIcon()
	playsound(src, 'sound/machines/airlock_swoosh_temp.ogg', 100, 0)
	SPAWN(2.5)
		src.set_density(1)
	SPAWN(0.5 SECONDS)
		src.operating = 0
		if (src.ignore_light_or_cam_opacity)
			src.set_opacity(1)
		else
			src.RL_SetOpacity(1)

/obj/machinery/door/supernorn/play_animation(animation)
	switch(animation)
		if("opening")
			if (src.vertical)
				flick("vopen", src)
			else
				flick("open", src)
		if("closing")
			if (src.vertical)
				flick("vclose", src)
			else
				flick("close", src)
		if("deny")
			if (!src.panel_open)
				if (src.vertical)
					flick("vdeny", src)
				else
					flick("deny", src)
				playsound(src, 'sound/machines/airlock_deny_temp.ogg', 100, 0) // kinda hacky, oh well
	src.UpdateIcon()

/obj/machinery/door/supernorn/proc/check_safeties()
	if (locate(/mob/living) in src.loc)
		return 0
	return 1

/obj/machinery/door/supernorn/proc/try_autoclose()
	if (src.check_safeties())
		src.close()
	else
		SPAWN(1 SECOND) // something was in the way
			src.try_autoclose()

/obj/machinery/door/tempfiredoor
	icon = 'icons/Testing/newicons/obj/NEWdoors/door_fire.dmi'
	icon_state = "opened"
	layer = 2.99
	opacity = 0
	density = 0

	play_animation()
	open()
	close()
