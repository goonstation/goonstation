/obj/surplusopspawner/
	name = "gungus spawner"
	icon = 'icons/obj/objects.dmi'
	icon_state = "itemspawn"
	density = 0
	anchored = 1.0
	invisibility = INVIS_ALWAYS
	layer = 99

/obj/surplusopspawner/loadout_shortgun_spawner
	name = "shortgun loadout spawner"

	New()
		..()
		SPAWN(1 DECI SECOND)
			new /obj/random_item_spawner/surplus/shortgun(src.loc)
			new /obj/random_item_spawner/surplus/melee(src.loc)
			new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
			qdel(src)
/obj/surplusopspawner/loadout_melee_spawner
	name = "melee loadout spawner"
	New()
		..()
		SPAWN(1 DECI SECOND)

			new /obj/random_item_spawner/surplus/melee(src.loc)
			new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
			new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
			new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
			qdel(src)
