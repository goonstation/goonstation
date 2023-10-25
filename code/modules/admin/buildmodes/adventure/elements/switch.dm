/datum/puzzlewizard/switch
	name = "AB CREATE: Button (dual state)"
	var/color_rgb = ""
	var/button_type
	var/button_name
	var/button_density = ""
	var/list/selected_triggerable = list()
	var/list/selected_triggerable_untrigger = list()
	var/selection

	initialize()
		selection = new /obj/adventurepuzzle/marker
		button_type = input("Button type", "Button type", "ancient") in list("ancient", "red")
		color_rgb = input("Color", "Color", "#ffffff") as color
		button_name = input("Button name", "Button name", "button") as text
		var/bdstr = input("Is the button dense (impassable)?", "Passability", "yes") in list("yes", "no")
		button_density = (bdstr == "yes") ? 1 : 0
		boutput(usr, "<span class='notice'>Left click to place buttons, right click triggerables to (de)select them for automatic assignment to the buttons. Ctrl+click anywhere to finish.</span>")
		boutput(usr, "<span class='notice'>NOTE: Select stuff first, then make buttons for extra comfort!</span>")

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
				var/obj/adventurepuzzle/triggerer/twostate/switch/button = new /obj/adventurepuzzle/triggerer/twostate/switch(T)
				button.name = button_name
				button.icon_state = "button_[button_type]_unpressed"
				button.button_type = button_type
				button.set_density(button_density)
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

/obj/adventurepuzzle/triggerer/twostate/switch
	icon = 'icons/obj/randompuzzles.dmi'
	name = "switch"
	desc = "A two-state button. Perhaps it opens something? Or something worse?"
	icon_state = "button_red_unpressed"
	density = 0
	opacity = 0
	anchored = ANCHORED
	var/button_type
	var/pressed = 0

	attack_hand(var/mob/living/user)
		if (!istype(user))
			return
		if (!(user in range(1)))
			boutput(user, "<span class='alert'>You must go closer!</span>")
			return
		if (!pressed)
			pressed = 1
			icon_state = "button_[button_type]_pressed"
			post_trigger()
		else
			icon_state = "button_[button_type]_unpressed"
			pressed = 0
			post_untrigger()

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].button_type"] << button_type
		F["[path].pressed"] << pressed

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		F["[path].button_type"] >> button_type
		F["[path].pressed"] >> pressed
