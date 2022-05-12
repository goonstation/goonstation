TYPEINFO(/datum/component/floor_slime)
	initialization_args = list(
		ARG_INFO("reagent_id", DATA_INPUT_TEXT, "ID of the reagent that the slime puddles contain", "badgrease"),
		ARG_INFO("slime_prob", DATA_INPUT_NUM, "Probability per move that slime is dripped on the floor", 11)
	)

/datum/component/floor_slime
	var/reagent_id = "badgrease"
	var/slime_prob = 11

/datum/component/floor_slime/Initialize(var/reagent_id, var/slime_prob)
	if (!ismovable(src.parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(src.parent, COMSIG_MOVABLE_MOVED, .proc/slime)
	if (reagent_id)
		src.reagent_id = reagent_id
	if (slime_prob)
		src.slime_prob = slime_prob

/datum/component/floor_slime/proc/slime()
	if (prob(slime_prob))
		var/turf/T = get_turf(src.parent)
		if (!T || locate(/obj/decal/cleanable/slime) in T)
			return
		var/obj/decal/cleanable/slime/decal = make_cleanable(/obj/decal/cleanable/slime, T)
		decal.sample_reagent = src.reagent_id

/datum/component/floor_slime/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
