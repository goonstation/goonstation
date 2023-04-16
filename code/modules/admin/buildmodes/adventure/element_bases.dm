/datum/puzzlewizard
	var/name = "Generic Puzzle Element Wizard (YOU SHOULDN'T SEE THIS)"
	var/finished = 0

	proc/initialize()
		return

	proc/build_click(var/mob/user, var/datum/buildmode_holder/holder, pa, var/atom/object)
		return

var/global/list/adventure_elements_by_id = list()

/obj/adventurepuzzle
	icon = 'icons/obj/randompuzzles.dmi'
	name = "You shouldn't see this"
	desc = "AND YOU DAMN WELL SHOULDN'T EXAMINE IT"
	var/id = null

	New()
		if (src.opacity)
			src.set_opacity(0)
			RL_SetOpacity(1)
		if(!(src.id in adventure_elements_by_id))
			adventure_elements_by_id[src.id] = list(src)
		else
			adventure_elements_by_id[src.id] += src
		..()

	ex_act()
		return

	bullet_act()
		return

	blob_act(var/power)
		return

	meteorhit()
		return

	disposing()
		adventure_elements_by_id[src.id] -= src
		..()

/obj/adventurepuzzle/marker
	icon_state = "select_generic"
	name = "Selection Marker"
	desc = "Marks a selection in Adventure Mode."
	density = 0
	opacity = 0
	anchored = ANCHORED

	disposing()
		icon_state = null
		..()

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		return

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		qdel(src)

/obj/adventurepuzzle/triggerable
	proc/trigger(var/act)
		return

	proc/trigger_actions()
		return null

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].connected_id"] << "ser:\ref[src]"

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		F["[path].connected_id"] >> tag

	proc/setTarget(var/atom/A)
		return

	proc/reset()
		return

/obj/adventurepuzzle/triggerable/targetable
	var/obj/adventurepuzzle/invisible/target
	setTarget(var/atom/A)
		src.target = A

	New()
		. = ..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		. = ..()

// Hello, goonstation coder reading this piece of code below.
// I'd like to ask you to stop judging me. Yes, I can hear the thoughts formulating in your brain right now.
// "what the fuck marquesas. why. why do you do this. why. why is this here. why."
// I suggest that instead of having those thoughts, go and find some way to make this code less shit.
// Here's one way to do that: help the efforts to move this shit off byond.
// I'm serious.
// Why are you still reading?
// GO.
// GO AWAY.
// CHANGE THE WORLD.
// DO SOMETHING.
// LEAVE ME ALONE.
/obj/adventurepuzzle/triggerable/triggerer
	New()
		. = ..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		. = ..()

	var/list/triggered = list()

	proc/post_trigger()
		for (var/obj/adventurepuzzle/triggerable/T in src.triggered)
			var/act = src.triggered[T]
			SPAWN(0)
				T.trigger(act)

	proc/special_triggers_required()
		return null

	proc/special_trigger_set(var/obj/adventurepuzzle/triggerable/T, var/list/toset)
		return

	proc/special_trigger_input(var/obj/adventurepuzzle/triggerable/T)
		return

	proc/special_trigger_remove(var/obj/adventurepuzzle/triggerable/T)
		return

	proc/special_trigger_clear()
		return

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()

		F["[path].triggered.COUNT"] << length(triggered)
		for(var/i = 1, i <= triggered.len, i++)
			var/obj/adventurepuzzle/triggerable/target = triggered[i]
			var/act = triggered[target]
			F["[path].triggered.[i].TARGET"] << "ser:\ref[target]"
			F["[path].triggered.[i].ACTION"] << act

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		var/count
		F["[path].triggered.COUNT"] >> count
		for (var/i = 1, i <= count, i++)
			var/ref
			var/act
			F["[path].triggered.[i].TARGET"] >> ref
			F["[path].triggered.[i].ACTION"] >> act
			triggered += ref
			triggered[ref] = act

		return . | DESERIALIZE_NEED_POSTPROCESS

	deserialize_postprocess()
		..()
		var/list/triggered_actual = list()
		for (var/i = 1, i <= triggered.len, i++)
			var/target_tag = triggered[i]
			var/target_act = triggered[target_tag]
			var/obj/adventurepuzzle/triggerable/target = locate(target_tag)
			triggered_actual += target
			triggered_actual[target] = target_act
		triggered = triggered_actual

/obj/adventurepuzzle/triggerer
	var/list/triggered = list()

	proc/post_trigger()
		for (var/obj/adventurepuzzle/triggerable/T in src.triggered)
			var/act = src.triggered[T]
			SPAWN(0)
				T.trigger(act)

	proc/special_triggers_required()
		return null

	proc/special_trigger_set(var/obj/adventurepuzzle/triggerable/T, var/list/toset)
		return

	proc/special_trigger_input(var/obj/adventurepuzzle/triggerable/T)
		return

	proc/special_trigger_remove(var/obj/adventurepuzzle/triggerable/T)
		return

	proc/special_trigger_clear()
		return

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()

		F["[path].triggered.COUNT"] << length(triggered)
		for(var/i = 1, i <= triggered.len, i++)
			var/obj/adventurepuzzle/triggerable/target = triggered[i]
			var/act = triggered[target]
			F["[path].triggered.[i].TARGET"] << "ser:\ref[target]"
			F["[path].triggered.[i].ACTION"] << act

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		var/count
		F["[path].triggered.COUNT"] >> count
		for (var/i = 1, i <= count, i++)
			var/ref
			var/act
			F["[path].triggered.[i].TARGET"] >> ref
			F["[path].triggered.[i].ACTION"] >> act
			triggered += ref
			triggered[ref] = act

		return . | DESERIALIZE_NEED_POSTPROCESS

	deserialize_postprocess()
		..()
		var/list/triggered_actual = list()
		for (var/i = 1, i <= triggered.len, i++)
			var/target_tag = triggered[i]
			var/target_act = triggered[target_tag]
			var/obj/adventurepuzzle/triggerable/target = locate(target_tag)
			triggered_actual += target
			triggered_actual[target] = target_act
		triggered = triggered_actual

/obj/item/adventurepuzzle
	icon = 'icons/obj/randompuzzles.dmi'
	name = "You shouldn't see this"
	desc = "AND YOU DAMN WELL SHOULDN'T EXAMINE IT"
	var/id = null

	New()
		if(!(src.id in adventure_elements_by_id))
			adventure_elements_by_id[src.id] = list(src)
		else
			adventure_elements_by_id[src.id] += src
		..()

	disposing()
		adventure_elements_by_id[src.id] -= src
		..()

// WOULDN'T IT BE NICE TO HAVE TRAITS???
/obj/item/adventurepuzzle/triggerer
	var/list/triggered = list()

	proc/post_trigger()
		for (var/obj/adventurepuzzle/triggerable/T in src.triggered)
			var/act = src.triggered[T]
			SPAWN(0)
				T.trigger(act)

	proc/special_triggers_required()
		return null

	proc/special_trigger_set(var/obj/adventurepuzzle/triggerable/T, var/list/toset)
		return

	proc/special_trigger_input(var/obj/adventurepuzzle/triggerable/T)
		return

	proc/special_trigger_remove(var/obj/adventurepuzzle/triggerable/T)
		return

	proc/special_trigger_clear()
		return

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()

		F["[path].triggered.COUNT"] << length(triggered)
		for(var/i = 1, i <= triggered.len, i++)
			var/obj/adventurepuzzle/triggerable/target = triggered[i]
			var/act = triggered[target]
			F["[path].triggered.[i].TARGET"] << "ser:\ref[target]"
			F["[path].triggered.[i].ACTION"] << act

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		var/count
		F["[path].triggered.COUNT"] >> count
		for (var/i = 1, i <= count, i++)
			var/ref
			var/act
			F["[path].triggered.[i].TARGET"] >> ref
			F["[path].triggered.[i].ACTION"] >> act
			triggered += ref
			triggered[ref] = act

		return . | DESERIALIZE_NEED_POSTPROCESS

	deserialize_postprocess()
		..()
		var/list/triggered_actual = list()
		for (var/i = 1, i <= triggered.len, i++)
			var/target_tag = triggered[i]
			var/target_act = triggered[target_tag]
			var/obj/adventurepuzzle/triggerable/target = locate(target_tag)
			triggered_actual += target
			triggered_actual[target] = target_act
		triggered = triggered_actual

/obj/adventurepuzzle/triggerer/twostate
	var/is_pressed = 0

	var/list/triggered_unpress = list()

	proc/post_untrigger()
		for (var/obj/adventurepuzzle/triggerable/T in src.triggered_unpress)
			var/act = src.triggered_unpress[T]
			SPAWN(0)
				T.trigger(act)

	special_triggers_required()
		return list("untrigger")

	special_trigger_set(var/obj/adventurepuzzle/triggerable/T, var/list/toset)
		if (T in src.triggered_unpress)
			src.triggered_unpress[T] = toset[1]
		else
			src.triggered_unpress += T
			src.triggered_unpress[T] = toset[1]

	special_trigger_input(var/obj/adventurepuzzle/triggerable/T)
		if (T in src.triggered_unpress)
			var/act = src.triggered_unpress[T]
			var/list/acts = T.trigger_actions()
			var/newname = input("Modify untrigger action for [src] on [T].", "Modify action", act) in acts
			src.triggered_unpress[T] = acts[newname]
		else
			var/act = src.triggered_unpress[T]
			var/list/acts = T.trigger_actions()
			var/newname = input("Set untrigger action for [src] on [T].", "Set action", act) in acts
			src.triggered_unpress += T
			src.triggered_unpress[T] = acts[newname]

	special_trigger_remove(var/obj/adventurepuzzle/triggerable/T)
		if (T in src.triggered_unpress)
			src.triggered_unpress -= T

	special_trigger_clear()
		src.triggered_unpress.len = 0

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()

		F["[path].triggered_unpress.COUNT"] << length(triggered_unpress)
		for(var/i = 1, i <= triggered_unpress.len, i++)
			var/obj/adventurepuzzle/triggerable/target = triggered_unpress[i]
			var/act = triggered_unpress[target]
			F["[path].triggered_unpress.[i].TARGET"] << "ser:\ref[target]"
			F["[path].triggered_unpress.[i].ACTION"] << act

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		var/count
		F["[path].triggered_unpress.COUNT"] >> count
		for (var/i = 1, i <= count, i++)
			var/ref
			var/act
			F["[path].triggered_unpress.[i].TARGET"] >> ref
			F["[path].triggered_unpress.[i].ACTION"] >> act
			triggered_unpress += ref
			triggered_unpress[ref] = act

		return . | DESERIALIZE_NEED_POSTPROCESS

	deserialize_postprocess()
		..()
		var/list/untriggered_actual = list()
		for (var/i = 1, i <= triggered_unpress.len, i++)
			var/target_tag = triggered_unpress[i]
			var/target_act = triggered_unpress[target_tag]
			var/obj/adventurepuzzle/triggerable/target = locate(target_tag)
			untriggered_actual += target
			untriggered_actual[target] = target_act
		triggered_unpress = untriggered_actual

/obj/adventurepuzzle/invisible
	name = "target marker"
	invisibility = INVIS_ALWAYS_ISH
	density = 0
	opacity = 0
	anchored = ANCHORED

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].connected_id"] << "ser:\ref[src]"

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		F["[path].connected_id"] >> tag
