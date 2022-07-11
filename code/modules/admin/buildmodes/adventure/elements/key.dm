/datum/puzzlewizard/key
	name = "AB CREATE: Key"
	var/color_rgb = ""
	var/key_type
	var/key_name
	var/list/selected_triggerable = list()
	var/selection
	var/oneshot

	initialize()
		selection = new /obj/adventurepuzzle/marker
		key_type = input("Key type", "Key type", "key") in list("key", "keycard", "artifact", "chtonic")
		color_rgb = input("Color", "Color", "#ffffff") as color
		key_name = input("Key name", "Key name", "[key_type]") as text
		oneshot = alert("Is this key one use only?",,"Yes","No") == "Yes" ? 1 : 0
		boutput(usr, "<span class='notice'>Left click to place keys, right click triggerables to (de)select them for automatic assignment to the keys. Ctrl+click anywhere to finish.</span>")
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
				var/obj/item/adventurepuzzle/triggerer/key/key = new /obj/item/adventurepuzzle/triggerer/key(T)
				key.name = key_name
				key.icon_state = "key_[key_type]"
				key.triggered = selected_triggerable.Copy()
				key.oneshot = oneshot
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

/obj/item/adventurepuzzle/triggerer/key
	name = "key"
	desc = "A key. This might open some doors."
	var/oneshot = 0

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].oneshot"] << oneshot


	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		F ["[path].oneshot"] >> oneshot
		if (oneshot == null)
			oneshot = 0

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (disposed)
			return
		if (istype(target, /obj/adventurepuzzle/triggerable))
			if (target in src.triggered)
				boutput(user, "<span class='notice'>The key slides into [target]!</span>")
				target:trigger(src.triggered[target])
				if (oneshot)
					qdel(src)
			else
				boutput(user, "<span class='alert'>The key won't fit into [target]!</span>")
