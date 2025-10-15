/obj/item/artifact/combiner
	name = "artifact combiner"
	associated_datum = /datum/artifact/combiner
	var/obj/first_art

	afterattack(atom/target, mob/user)
		. = ..()
		if (!src.ArtifactSanityCheck())
			return
		var/datum/artifact/combiner/art = src.artifact
		if (!art.activated)
			return
		var/obj/O = target
		if (!istype(O) || !O.artifact)
			return
		if (!src.first_art)
			if (O.anchored != UNANCHORED)
				var/turf/T = get_turf(src)
				T.visible_message(SPAN_NOTICE("[src] glows yellow momentarily."))
				src.add_filter("yellow_error", 1, outline_filter(size = 1, color = "#fbff00"))
				SPAWN(0.5 SECONDS)
					src.remove_filter("yellow_error")
				playsound(T, 'sound/items/lattice_combiner_error.ogg', 50, TRUE)
				return
			src.first_art = target
			var/turf/T = get_turf(src)
			T.visible_message(SPAN_NOTICE("[src] glows green."))
			playsound(T, 'sound/items/lattice_combiner_transform_art.ogg', 50, TRUE)
			src.add_filter("first_art_picked", 1, outline_filter(size = 1, color = "#06b800"))
			return
		if (target == src.first_art)
			src.clear_first_art()
			return
		if (!src.try_combine_arts(target, src.first_art))
			return
		src.combine_arts(target, src.first_art)

	attack_self(mob/user)
		. = ..()
		src.clear_first_art()

	proc/clear_first_art(play_fx = TRUE)
		if (!src.first_art)
			return
		src.first_art = null
		if (play_fx)
			var/turf/T = get_turf(src)
			playsound(T, 'sound/items/lattice_combiner_transform_art.ogg', 50, TRUE)
			T.visible_message(SPAN_NOTICE("[src] stops glowing green."))
		src.remove_filter("first_art_picked")

	proc/try_combine_arts(obj/receiver, obj/to_merge)
		if (BOUNDS_DIST(receiver, to_merge) > 0)
			var/turf/T = get_turf(src)
			T.visible_message(SPAN_NOTICE("[src] glows yellow momentarily."))
			playsound(T, 'sound/items/lattice_combiner_error.ogg', 50, TRUE)
			src.clear_first_art(FALSE)
			src.add_filter("yellow_error", 1, outline_filter(size = 1, color = "#fbff00"))
			SPAWN(0.5 SECONDS)
				src.remove_filter("yellow_error")
			return FALSE
		if (!receiver.can_combine_artifact(to_merge))
			var/turf/T = get_turf(src)
			T.visible_message(SPAN_NOTICE("[src] glows red momentarily."))
			playsound(T, 'sound/items/lattice_combiner_error.ogg', 50, TRUE)
			src.clear_first_art(FALSE)
			src.add_filter("red_error", 1, outline_filter(size = 1, color = "#ff0000"))
			SPAWN(0.5 SECONDS)
				src.remove_filter("red_error")
			return FALSE
		return TRUE

	proc/combine_arts(obj/receiver, obj/to_merge)
		receiver.combine_artifact(to_merge)
		src.clear_first_art(FALSE)
		var/turf/T = get_turf(src)
		playsound(T, pick(src.artifact.artitype.activation_sounds), 20, TRUE)
		T.visible_message(SPAN_NOTICE("[to_merge] fuses into [receiver]!"))
		if (receiver.get_filter("combined_arts"))
			return
		receiver.add_filter("combined_arts", 1, outline_filter(size = 1.5, color = random_color()))

/datum/artifact/combiner
	associated_object = /obj/item/artifact/combiner
	type_name = "Combiner"
	type_size = ARTIFACT_SIZE_MEDIUM
	rarity_weight = 300
	validtypes = list("lattice")
	react_xray = list(7, 30, 95, 8, "ANOMALOUS")
	examine_hint = "Space is warping strangely around it."
