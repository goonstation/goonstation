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

/obj/random_item_spawner/surplus/melee/withcredits
	New()

		SPAWN(1 DECI SECOND)
			new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
			new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
			new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
		..()
/obj/item/reagent_containers/glass/beaker/large/surplusmedical
	name = "Beaker- Jungle Juice"
	desc = "A beaker full of an odd-smelling medical cocktail."
	initial_reagents = list("ephedrine"=30, "saline"= 30, "synaptizine" = 30, "omnizine" = 9)

/obj/item/experimental/melee/spear/plaswood
	New()
		..()
		setHeadMaterial(getMaterial("plasmaglass"))
		setShaftMaterial(getMaterial("wood"))
		buildOverlays()


