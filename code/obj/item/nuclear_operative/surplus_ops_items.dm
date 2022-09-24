//miscellaneous surplus objects
//Contents:
//loadout spawners
//prefab plasmaglass/wood spear
//surplus medical beaker
//surplus deployment computer and teleporter

/obj/surplusopspawner //object that decays into spawners
	name = "surplus spawner"
	icon = 'icons/obj/objects.dmi'
	icon_state = "itemspawn"
	density = 0
	anchored = 1.0
	invisibility = INVIS_ALWAYS
	layer = 99

	New()
		..()
		qdel(src)

/obj/surplusopspawner/loadout_shortgun_spawner
	name = "shortgun loadout spawner"
	New()
		new /obj/random_item_spawner/surplus/shortgun(src.loc)
		new /obj/random_item_spawner/surplus/melee(src.loc)
		new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
		new /obj/surplusopspawner/suitandhelm(src.loc)
		new /obj/item/card/id/syndicate(src.loc)
		..()

/obj/random_item_spawner/surplus/melee/loadout
	New()
		SPAWN(1 DECI SECOND)
			new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
			new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
			new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
			new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
			new /obj/surplusopspawner/suitandhelm(src.loc)
			new /obj/item/card/id/syndicate(src.loc)
		..()


/obj/random_item_spawner/surplus/longgun/loadout
	New()

		new /obj/surplusopspawner/suitandhelm(src.loc)
		new /obj/item/card/id/syndicate(src.loc)
		..()

/obj/surplusopspawner/suitandhelm
	var/helmetlist = list(/obj/item/clothing/head/emerg,  //We want to heaviliy skew this towards more common helmets, so include repeats
		/obj/item/clothing/head/emerg,
		/obj/item/clothing/head/helmet/space/soviet,
		/obj/item/clothing/head/helmet/space/engineer,
		/obj/item/clothing/head/helmet/space/engineer,
		/obj/item/clothing/head/helmet/space,
		/obj/item/clothing/head/helmet/space,
		/obj/item/clothing/head/helmet/space/engineer/diving/civilian,
		/obj/item/clothing/head/helmet/space/replica,
		/obj/item/clothing/head/helmet/space/old,
		)
	var/suitlist = list(/obj/item/clothing/suit/space/emerg, //ditto
		/obj/item/clothing/suit/space/emerg,
		/obj/item/clothing/suit/space/soviet,
		/obj/item/clothing/suit/space/syndicate,
		/obj/item/clothing/suit/space/engineer,
		/obj/item/clothing/suit/space/engineer,
		/obj/item/clothing/suit/space,
		/obj/item/clothing/suit/space,
		/obj/item/clothing/suit/space/replica)


	New()

		SPAWN(1 DECI SECOND)
			var/helm = pick(helmetlist)
			var/suit = pick(suitlist)
			new suit(src.loc)
			new helm(src.loc)
			..()



//Items for surplusops that don't belogn anywhere else
/obj/item/reagent_containers/glass/beaker/large/surplusmedical
	name = "Doctor Schmidt's Super Mega Restoration Jungle Juice"
	desc = "A beaker containing a supposed panacea. It smells weird and the glass feels sticky."
	initial_reagents = list("ephedrine"=30, "saline"= 30, "synaptizine" = 30, "omnizine" = 9)

/obj/item/experimental/melee/spear/plaswood
	New()
		..()
		setHeadMaterial(getMaterial("plasmaglass"))
		setShaftMaterial(getMaterial("wood"))
		buildOverlays()
