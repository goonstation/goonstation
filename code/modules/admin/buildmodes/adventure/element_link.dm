/obj/adventurepuzzle/element_link

	var/triggerer_id = null
	var/triggerable_id = null
	var/act_type = null
	var/triggerer = null
	var/triggerable = null
	var/is_unpress = 0

	New()
		..()
		if(triggerer) // accidentally setting these ids on the map is so common that i'm gonna cry
			triggerer_id = triggerer
			triggerer = null
		if(triggerable)
			triggerable_id = triggerable
			triggerable = null
		if(current_state > GAME_STATE_PREGAME)
			SPAWN(0.1 SECONDS)
				src.initialize()

	initialize()
		src.link_elements()
		..()
		qdel(src)

	proc/link_elements()

		if(length(adventure_elements_by_id[src.triggerer_id]))
			src.triggerer = adventure_elements_by_id[src.triggerer_id][1]

		if(length(adventure_elements_by_id[src.triggerable_id]))
			src.triggerable = adventure_elements_by_id[src.triggerable_id][1]

		if(src.triggerer && src.triggerable)

			if(istype(src.triggerable,/obj/adventurepuzzle/triggerable))

				var/obj/adventurepuzzle/triggerable/Y = src.triggerable

				if(istype(src.triggerer,/obj/adventurepuzzle/triggerer/twostate))

					var/obj/adventurepuzzle/triggerer/twostate/X = src.triggerer

					if(is_unpress)
						X.triggered_unpress += Y
						X.triggered_unpress[Y] = act_type

					else
						X.triggered += Y
						X.triggered[Y] = act_type

				else if(istype(src.triggerer,/obj/adventurepuzzle/triggerer))

					var/obj/adventurepuzzle/triggerer/X = src.triggerer

					X.triggered += Y
					X.triggered[Y] = act_type

				else if(istype(src.triggerer,/obj/adventurepuzzle/triggerable/triggerer))

					var/obj/adventurepuzzle/triggerable/triggerer/X = src.triggerer

					X.triggered += Y
					X.triggered[Y] = act_type

				else if(istype(src.triggerer,/obj/item/adventurepuzzle/triggerer))

					var/obj/item/adventurepuzzle/triggerer/X = src.triggerer

					X.triggered += Y
					X.triggered[Y] = act_type
