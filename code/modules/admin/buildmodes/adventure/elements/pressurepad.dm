/datum/puzzlewizard/pressurepad
	name = "AB CREATE: Pressure pad"
	var/color_rgb = ""
	var/button_type
	var/button_name
	var/button_density = ""
	var/list/selected_triggerable = list()
	var/list/selected_triggerable_untrigger = list()
	var/selection

	initialize()
		selection = new /obj/adventurepuzzle/marker
		button_type = input("Pad type", "Pad type", "ancient") in list("ancient", "runes")
		color_rgb = input("Color", "Color", "#ffffff") as color
		button_name = input("Pressure pad name", "Pressure pad name", "pressure pad") as text
		boutput(usr, "<span class='notice'>Left click to place pressure pads, right click triggerables to (de)select them for automatic assignment to the pressure pads. Ctrl+click anywhere to finish.</span>")
		boutput(usr, "<span class='notice'>NOTE: Select stuff first, then make pressure pads for extra comfort!</span>")

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
				var/obj/adventurepuzzle/triggerer/twostate/pressurepad/button = new /obj/adventurepuzzle/triggerer/twostate/pressurepad(T)
				button.name = button_name
				button.icon_state = "pressure_[button_type]_unpressed"
				button.pad_type = button_type
				button.triggered = selected_triggerable.Copy()
				button.triggered_unpress = selected_triggerable_untrigger.Copy()
				SPAWN(1 SECOND)
					button.color = color_rgb
		else if ("right" in pa)
			if (istype(object, /obj/adventurepuzzle/triggerable))
				if (object in selected_triggerable)
					object.overlays -= selection
					selected_triggerable -= object
					selected_triggerable_untrigger -= object
				else
					var/list/actions = object:trigger_actions()
					if (islist(actions) && length(actions))
						var/act_name = input("Do what on press?", "Do what?", actions[1]) in actions
						var/act = actions[act_name]
						var/unact_name = input("Do what on unpress?", "Do what?", actions[1]) in actions
						var/unact = actions[unact_name]
						object.overlays += selection
						selected_triggerable += object
						selected_triggerable[object] = act
						selected_triggerable_untrigger += object
						selected_triggerable_untrigger[object] = unact
					else
						boutput(user, "<span class='alert'>ERROR: Missing actions definition for triggerable [object].</span>")

/obj/adventurepuzzle/triggerer/twostate/pressurepad
	icon = 'icons/obj/randompuzzles.dmi'
	name = "pressure pad"
	desc = "A pressure pad. Ominous."
	icon_state = "pressure_ancient_unpressed"
	density = 0
	opacity = 0
	anchored = ANCHORED
	layer = 2
	var/pad_type
	var/pressed = 0
	var/list/pressing = list()

	Crossed(atom/movable/O)
		..()
		if (isliving(O) && !(O in pressing) && O.loc == loc)
			pressing += O
			press()
		else if (istype(O, /obj) && !(O in pressing) && O.loc == loc)
			if (O.density || istype(O, /obj/critter) || istype(O, /obj/machinery/bot))
				pressing += O
				press()

	Uncrossed(atom/movable/O)
		..()
		if (O in pressing)
			pressing -= O
			for (var/atom/movable/Q in pressing)
				if (Q.loc != src.loc)
					pressing -= Q
			if (pressing.len == 0)
				unpress()

	proc/press()
		if (pressed)
			return
		pressed = 1
		flick("pressure_[pad_type]_pressing", src)
		SPAWN(0.5 SECONDS)
			icon_state = "pressure_[pad_type]_pressed"
			post_trigger()

	proc/unpress()
		if (!pressed)
			return
		pressed = 0
		flick("pressure_[pad_type]_unpressing", src)
		SPAWN(0.5 SECONDS)
			icon_state = "pressure_[pad_type]_unpressed"
			post_untrigger()

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].pad_type"] << pad_type

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		F["[path].pad_type"] >> pad_type
		return . | DESERIALIZE_NEED_POSTPROCESS

	deserialize_postprocess()
		..()
		for (var/atom/A as obj|mob in src.loc)
			if (A == src)
				continue
			if (isliving(A) && A.density)
				src.pressing += A
			else if (isobj(A) && A.density)
				src.pressing += A
		if (src.pressing.len)
			icon_state = "pressure_[pad_type]_pressed"
