/datum/puzzlewizard/door
	name = "AB CREATE: Door"
	var/door_name = ""
	var/door_type
	var/color_rgb = ""

	initialize()
		door_type = input("Door type", "Door type", "normal") in list("normal", "glass", "ancient", "shuttle", "wall", "runes")
		color_rgb = input("Color", "Color", "#ffffff") as color
		door_name = input("Door name", "Door name", "[door_type] door") as text
		boutput(usr, "<span class='notice'>Left click to place doors, right click doors to toggle state. Ctrl+click anywhere to finish.</span>")

	build_click(var/mob/user, var/datum/buildmode_holder/holder, var/list/pa, var/atom/object)
		if (pa.Find("left"))
			var/turf/T = get_turf(object)
			if (pa.Find("ctrl"))
				finished = 1
				return
			if (T)
				var/obj/adventurepuzzle/triggerable/door/door = new /obj/adventurepuzzle/triggerable/door(T)
				door.name = door_name
				door.icon_state = "door_[door_type]_closed"
				door.set_dir(holder.dir)
				door.door_type = door_type
				if (door_type == "glass" || door_type == "runes")
					door.RL_SetOpacity(0)
				SPAWN_DBG(1 SECOND)
					door.color = color_rgb
		else if (pa.Find("right"))
			if (istype(object, /obj/adventurepuzzle/triggerable/door))
				object:toggle()

/obj/adventurepuzzle/triggerable/door
	name = "door"
	desc = "A doorway that seems to be blocking your path."
	density = 1
	opacity = 1
	var/orig_opacity = 1
	var/secured_open = 0
	var/secured_closed = 0
	anchored = 1
	icon_state = "door_normal_closed"
	var/opening = 0
	var/door_type = "normal"

	var/static/list/triggeracts = list("Close" = "close", "Do nothing" = "nop", "Lock closed" = "secclose", "Lock open" = "secopen", "Open" = "open", "Toggle" = "toggle", "Unlock" = "unlock")

	trigger_actions()
		return triggeracts

	trigger(var/act)
		switch (act)
			if ("open")
				src.open()
			if ("close")
				src.close()
			if ("toggle")
				src.toggle()
			if ("secclose")
				secured_closed = 1
				src.close()
			if ("secopen")
				secured_open = 1
				src.open()
			if ("unlock")
				secured_open = 0
				secured_closed = 0
			else
				return

	Bump(var/atom/A)
		if (ismob(A))
			flick("door_[door_type]_deny", src)

	proc/toggle()
		if (src.opening)
			return
		if (src.density)
			src.open()
		else
			src.close()

	proc/close()
		if (secured_open)
			return
		if (density)
			return
		if (opening == -1)
			return
		src.opening = -1
		if (src.opacity != orig_opacity)
			src.RL_SetOpacity(orig_opacity)
		src.set_density(1)
		flick("door_[door_type]_closing", src)
		src.icon_state = "door_[door_type]_closed"
		SPAWN_DBG(1 SECOND)
			src.opening = 0

	proc/open()
		if (secured_closed)
			return
		if (!density)
			return
		if (opening == 1)
			return
		src.opening = 1
		flick("door_[door_type]_opening", src)
		SPAWN_DBG(1 SECOND)
			src.set_density(0)
			if (opacity != 0)
				orig_opacity = opacity
				src.RL_SetOpacity(0)
			src.icon_state = "door_[door_type]_open"
			src.opening = 0

	attack_hand(mob/user as mob)
		if (src.density)
			usr.show_message("<span class='alert'>[src] won't open. Perhaps you need a key?</span>")
		flick("door_[door_type]_deny", src)

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].orig_opacity"] << orig_opacity
		F["[path].door_type"] << door_type

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		F["[path].orig_opacity"] >> orig_opacity
		F["[path].door_type"] >> door_type
