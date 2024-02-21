/datum/puzzlewizard/door/multiactivated
	name = "AB CREATE: Door (requiring multiple triggers)"
	var/act_needed = 0

	initialize()
		act_needed = input("Number of activations to open the door?", "Activation count", 1) as num
		..()

	build_click(var/mob/user, var/datum/buildmode_holder/holder, var/list/pa, var/atom/object)
		if ("left" in pa)
			var/turf/T = get_turf(object)
			if ("ctrl" in pa)
				finished = 1
				return
			if (T)
				var/obj/adventurepuzzle/triggerable/door/multiactivated/door = new /obj/adventurepuzzle/triggerable/door/multiactivated(T)
				door.name = door_name
				door.icon_state = "door_[door_type]_closed"
				door.door_type = door_type
				door.act_needed = act_needed
				if (door_type == "glass" || door_type == "runes")
					door.set_opacity(0)
				SPAWN(1 SECOND)
					door.color = color_rgb
		else if ("right" in pa)
			if (istype(object, /obj/adventurepuzzle/triggerable/door))
				object:toggle()

/obj/adventurepuzzle/triggerable/door/multiactivated
	var/act_count = 0
	var/act_needed = 1
	var/allow_negative = 0
	var/static/list/triggeracts_multi = list("Close" = "close", "Decrease activation count" = "dec", "Do nothing" = "nop", "Increase activation count" = "inc", "Lock open" = "secopen", "Open" = "open", "Toggle" = "toggle")

	attackby(C, mob/user)
		return

	trigger_actions()
		return triggeracts_multi

	trigger(var/act)
		if (act == "dec")
			if(allow_negative)
				act_count = act_count - 1
			else if (act_count > 0)
				act_count--
			if (act_count < act_needed)
				close()
		else if (act == "inc")
			act_count++
			if (act_count >= act_needed)
				open()
		else ..()

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].act_count"] << act_count
		F["[path].act_needed"] << act_needed

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		F["[path].act_count"] >> act_count
		F["[path].act_needed"] >> act_needed
