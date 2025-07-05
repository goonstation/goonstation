/obj/item/artifact/combiner
	name = "artifact combiner"
	associated_datum = /datum/artifact/combiner
	var/obj/loaded_art

	afterattack(atom/target, mob/user)
		. = ..()
		if (!src.ArtifactSanityCheck())
			return
		var/datum/artifact/combiner/art = src.artifact
		if (!art.activated)
			return
		var/obj/O = target
		if (!istype(O))
			return
		if (!O.artifact || !O.artifact.activated)
			return
		if (!src.loaded_art)
			src.load_art(target)
			return
		if (!src.try_combine_arts(target, src.loaded_art))
			return
		src.combine_arts(target, src.loaded_art)

	attack_self(mob/user)
		. = ..()
		src.eject_art()

	proc/load_art(obj/O)
		O.set_loc(src)
		src.loaded_art = O
		var/turf/T = get_turf(src)
		T.visible_message(SPAN_NOTICE("[O] folds in on itself like paper and slips into [src]! Woah."))
		playsound(T, 'sound/items/lattice_combiner_transform_art.ogg', 50, TRUE)

	proc/eject_art()
		if (!src.loaded_art)
			return
		var/turf/T = get_turf(src)
		T.visible_message(SPAN_NOTICE("[src.loaded_art] slips out of [src] and unfolds itself back into space!"))
		playsound(T, 'sound/items/lattice_combiner_transform_art.ogg', 50, TRUE)
		src.loaded_art.set_loc(get_turf(src))
		src.loaded_art = null

	proc/try_combine_arts(obj/receiver, obj/to_merge)
		if (!receiver.can_combine_artifact(to_merge))
			var/turf/T = get_turf(src)
			T.visible_message(SPAN_NOTICE("[src] glows red momentarily."))
			playsound(T, 'sound/items/lattice_combiner_error.ogg', 50, TRUE)
			return FALSE
		return TRUE

	proc/combine_arts(obj/receiver, obj/to_merge)
		receiver.combine_artifact(to_merge)
		src.loaded_art = null
		var/turf/T = get_turf(src)
		playsound(T, pick(src.artifact.artitype.activation_sounds), 20, TRUE)
		T.visible_message(SPAN_NOTICE("The folded [to_merge] fuses into [receiver]!"))
		if (length(receiver.combined_artifacts) > 1)
			return
		receiver.name_prefix("fused")
		receiver.UpdateName()

/datum/artifact/combiner
	associated_object = /obj/item/artifact/combiner
	type_name = "Combiner"
	type_size = ARTIFACT_SIZE_MEDIUM
	rarity_weight = 300
	validtypes = list("lattice")
	react_xray = list(7, 30, 95, 8, "ANOMALOUS")
	examine_hint = "Space is warping strangely around it."
	combine_flags = ARTIFACT_DOES_NOT_COMBINE
