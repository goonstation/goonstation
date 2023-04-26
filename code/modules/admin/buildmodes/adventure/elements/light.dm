/obj/adventurepuzzle/triggerable/light
	icon_state = "light_emitter"
	name = "Light emitter"
	desc = "Light is emitted out of this point."
	density = 0
	opacity = 0
	anchored = ANCHORED
	invisibility = INVIS_ADVENTURE

	var/is_on = 0

	var/on_brig = 5
	var/on_cred = 1
	var/on_cgreen = 1
	var/on_cblue = 1
	var/datum/light/light

	var/static/list/triggeracts = list("Do nothing" = "nop", "Toggle" = "toggle", "Turn on" = "on", "Turn off" = "off")

	New()
		..()
		src.light = new /datum/light/point
		src.light.attach(src)
		src.light.set_color(on_cred,on_cgreen,on_cblue)
		src.light.set_brightness(on_brig)
		if(src.is_on)
			src.light.enable()
			blink(src.loc)

	proc/on()
		if (!is_on)
			light.enable()
			is_on = 1

	proc/off()
		if (is_on)
			light.disable()
			is_on = 0

	proc/toggle()
		if (is_on)
			off()
		else
			on()

	trigger_actions()
		return triggeracts

	trigger(var/act)
		switch (act)
			if ("on")
				src.on()
				return
			if ("off")
				src.off()
				return
			if ("toggle")
				src.toggle()
				return

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].is_on"] << is_on
		F["[path].on_brig"] << on_brig
		F["[path].on_cred"] << on_cred
		F["[path].on_cgreen"] << on_cgreen
		F["[path].on_cblue"] << on_cblue

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		F["[path].is_on"] >> is_on
		F["[path].on_brig"] >> on_brig
		F["[path].on_cred"] >> on_cred
		F["[path].on_cgreen"] >> on_cgreen
		F["[path].on_cblue"] >> on_cblue

		return . | DESERIALIZE_NEED_POSTPROCESS

	proc/setup_light()
		light.set_color(on_cred, on_cgreen, on_cblue)
		light.set_brightness(on_brig)
		if (is_on)
			is_on = 0
			on()

	deserialize_postprocess()
		..()
		setup_light()
