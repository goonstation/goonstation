/obj/loadout_shortgun_spawner
	name = "shortgun loadout spawner"
	icon = 'icons/obj/objects.dmi'
	icon_state = "itemspawn"
	density = 0
	anchored = 1.0
	invisibility = INVIS_ALWAYS
	layer = 99

	New()
		..()
		SPAWN(1 DECI SECOND)
			new /obj/random_item_spawner/surplus/shortgun(src.loc)
			new /obj/random_item_spawner/surplus/melee(src.loc)
			new /obj/random_item_spawner/surplus/grenades(src.loc)
			qdel(src)
