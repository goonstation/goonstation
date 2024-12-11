/obj/eva_suit_spawner
	name = "EVA suit spawner"
	icon = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
	icon_state = "space"
	density = FALSE
	anchored = ANCHORED_ALWAYS
	invisibility = INVIS_ALWAYS

	New()
		..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

	proc/spawn_gear(datum/terrainify/terrainify_option)
		if (terrainify_option == /datum/terrainify/winterify)
			new/obj/item/clothing/suit/snow/grey(get_turf(src))
		else
			new/obj/item/clothing/suit/space(get_turf(src))
			new/obj/item/clothing/head/helmet/space(get_turf(src))
		qdel(src)
