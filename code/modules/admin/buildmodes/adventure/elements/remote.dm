/datum/puzzlewizard/remotecontrol
	name = "AB CREATE: Remote control"
	var/key_name
	var/color_rgb
	var/list/selected_triggerable = list()
	var/selection

	initialize()
		selection = new /obj/adventurepuzzle/marker
		color_rgb = input("Color", "Color", "#ffffff") as color
		key_name = input("Remote name", "Remote name", "remote control") as text
		boutput(usr, "<span class='notice'>Left click to place remotes, right click triggerables to (de)select them for automatic assignment to the keys. Ctrl+click anywhere to finish.</span>")
		boutput(usr, "<span class='notice'>NOTE: Select stuff first, then make keys for extra comfort!</span>")

	proc/clear_selections()
		for (var/obj/O in selected_triggerable)
			O.overlays -= selection
		selected_triggerable.len = 0

	disposing()
		clear_selections()
		qdel(selection)
		..()

	build_click(var/mob/user, var/datum/buildmode_holder/holder, var/list/pa, var/atom/object)
		if ("left" in pa)
			var/turf/T = get_turf(object)
			if ("ctrl" in pa)
				finished = 1
				clear_selections()
				return
			if (T)
				var/obj/item/adventurepuzzle/triggerer/remotecontrol/key = new /obj/item/adventurepuzzle/triggerer/remotecontrol(T)
				key.name = key_name
				key.triggered = selected_triggerable.Copy()
				SPAWN(1 SECOND)
					key.color = color_rgb
		else if ("right" in pa)
			if (istype(object, /obj/adventurepuzzle/triggerable))
				if (object in selected_triggerable)
					object.overlays -= selection
					selected_triggerable -= object
				else
					var/list/actions = object:trigger_actions()
					if (islist(actions) && length(actions))
						var/act_name = input("Do what?", "Do what?", actions[1]) in actions
						var/act = actions[act_name]
						object.overlays += selection
						selected_triggerable += object
						selected_triggerable[object] = act
					else
						boutput(user, "<span class='alert'>ERROR: Missing actions definition for triggerable [object].</span>")

/obj/item/adventurepuzzle/triggerer/remotecontrol
	name = "remote control"
	desc = "A remove control device."
	icon = 'icons/obj/porters.dmi'
	icon_state = "remote"
	var/use_delay = 20
	var/next_use = 0

	attack_self(var/mob/user)
		if (next_use <= world.time)
			post_trigger()
			next_use = world.time + use_delay

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].use_delay"] << use_delay

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		F["[path].use_delay"] >> use_delay
