/obj/item/artifact/combiner
	name = "artifact combiner"
	associated_datum = /datum/artifact/combiner

/datum/artifact/combiner
	associated_object = /obj/item/artifact/combiner
	type_name = "Combiner"
	type_size = ARTIFACT_SIZE_MEDIUM
	rarity_weight = 300
	validtypes = list("lattice")
	react_xray = list(7, 30, 95, 8, "ANOMALOUS")
	examine_hint = "Space is warping strangely around it."

	var/obj/first_art

	effect_attack_atom(obj/art, mob/living/user, atom/A)
		if (..())
			return
		if (!src.activated)
			return
		var/obj/O = A
		if (!istype(O) || !O.artifact)
			return
		if (!src.first_art)
			if (O.anchored != UNANCHORED)
				var/turf/T = get_turf(art)
				T.visible_message(SPAN_NOTICE("[art] glows yellow momentarily."))
				art.add_filter("yellow_error", 1, outline_filter(size = 1, color = "#fbff00"))
				SPAWN(0.5 SECONDS)
					art.remove_filter("yellow_error")
				playsound(T, 'sound/items/lattice_combiner_error.ogg', 50, TRUE)
				return
			src.first_art = A
			var/turf/T = get_turf(art)
			T.visible_message(SPAN_NOTICE("[art] glows green."))
			playsound(T, 'sound/items/lattice_combiner_transform_art.ogg', 50, TRUE)
			art.add_filter("first_art_picked", 1, outline_filter(size = 1, color = "#06b800"))
			return
		if (A == src.first_art)
			src.clear_first_art()
			return
		if (!src.try_combine_arts(A, src.first_art))
			return
		src.combine_arts(A, src.first_art)

	effect_attack_self(mob/user)
		if (..())
			return
		src.clear_first_art()

	proc/clear_first_art(play_fx = TRUE)
		if (!src.first_art)
			return
		src.first_art = null
		if (play_fx)
			var/turf/T = get_turf(src.associated_object)
			playsound(T, 'sound/items/lattice_combiner_transform_art.ogg', 50, TRUE)
			T.visible_message(SPAN_NOTICE("[src.associated_object] stops glowing green."))
		src.associated_object.remove_filter("first_art_picked")

	proc/try_combine_arts(obj/receiver, obj/to_merge)
		if (BOUNDS_DIST(receiver, to_merge) > 0)
			var/turf/T = get_turf(src.)
			T.visible_message(SPAN_NOTICE("[src.associated_object] glows yellow momentarily."))
			playsound(T, 'sound/items/lattice_combiner_error.ogg', 50, TRUE)
			src.clear_first_art(FALSE)
			src.associated_object.add_filter("yellow_error", 1, outline_filter(size = 1, color = "#fbff00"))
			SPAWN(0.5 SECONDS)
				src.associated_object.remove_filter("yellow_error")
			return FALSE
		if (!receiver.can_combine_artifact(to_merge))
			var/turf/T = get_turf(src.associated_object)
			T.visible_message(SPAN_NOTICE("[src.associated_object] glows red momentarily."))
			playsound(T, 'sound/items/lattice_combiner_error.ogg', 50, TRUE)
			src.clear_first_art(FALSE)
			src.associated_object.add_filter("red_error", 1, outline_filter(size = 1, color = "#ff0000"))
			SPAWN(0.5 SECONDS)
				src.associated_object.remove_filter("red_error")
			return FALSE
		return TRUE

	proc/combine_arts(obj/receiver, obj/to_merge)
		receiver.combine_artifact(to_merge)
		src.clear_first_art(FALSE)
		var/turf/T = get_turf(src.associated_object)
		playsound(T, pick(src.artitype.activation_sounds), 20, TRUE)
		T.visible_message(SPAN_NOTICE("[to_merge] fuses into [receiver]!"))
		if (receiver.get_filter("combined_arts"))
			return
		receiver.add_filter("combined_arts", 1, outline_filter(size = 1.5, color = random_color()))
