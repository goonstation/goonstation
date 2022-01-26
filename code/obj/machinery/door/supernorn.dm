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
	if (vertical)
		icon_state = p_open ? "vopened" : "vclosed"
	else
		icon_state = p_open ? "opened" : "closed"

/obj/machinery/door/supernorn/open()
	if (p_open || welded || locked || operating || (status & NOPOWER))
		return
	operating = 1
	if (ignore_light_or_cam_opacity)
		src.opacity = 0
	else
		src.RL_SetOpacity(0)
	p_open = 1
	play_animation("opening")
	UpdateIcon()
	playsound(src, "sound/machines/airlock_swoosh_temp.ogg", 100, 0)
	SPAWN_DBG(2.5)
		set_density(0) // let them through halfway through the anim
	SPAWN_DBG(0.5 SECONDS)
		operating = 0
	if (autoclose_delay)
		SPAWN_DBG(autoclose_delay)
			try_autoclose()

/obj/machinery/door/supernorn/close()
	if (!p_open || locked || operating || (status & NOPOWER))
		return
	if (!check_safeties())
		return
	operating = 1
	p_open = 0
	play_animation("closing")
	UpdateIcon()
	playsound(src, "sound/machines/airlock_swoosh_temp.ogg", 100, 0)
	SPAWN_DBG(2.5)
		set_density(1)
	SPAWN_DBG(0.5 SECONDS)
		operating = 0
		if (ignore_light_or_cam_opacity)
			src.opacity = 1
		else
			src.RL_SetOpacity(1)

/obj/machinery/door/supernorn/play_animation(animation)
	switch(animation)
		if("opening")
			if (vertical)
				flick("vopen", src)
			else
				flick("open", src)
		if("closing")
			if (vertical)
				flick("vclose", src)
			else
				flick("close", src)
		if("deny")
			if (!p_open)
				if (vertical)
					flick("vdeny", src)
				else
					flick("deny", src)
				playsound(src, "sound/machines/airlock_deny_temp.ogg", 100, 0) // kinda hacky, oh well
	UpdateIcon()

/obj/machinery/door/supernorn/proc/check_safeties()
	if (locate(/mob/living) in src.loc)
		return 0
	return 1

/obj/machinery/door/supernorn/proc/try_autoclose()
	if (check_safeties())
		close()
	else
		SPAWN_DBG(1 SECOND) // something was in the way
			try_autoclose()

/obj/machinery/door/tempfiredoor
	icon = 'icons/Testing/newicons/obj/NEWdoors/door_fire.dmi'
	icon_state = "opened"
	layer = 2.99
	opacity = 0
	density = 0

	play_animation()
	open()
	close()
