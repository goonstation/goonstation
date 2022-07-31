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
			new /obj/surplusopspawner/melee_item_spawner(src.loc)
			new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
			qdel(src)
/obj/surplusopspawner/melee_item_spawner
	name = "melee loadout spawner"
	var/list/items2spawn = list(/obj/item/ratstick,
		/obj/item/bat,
		/obj/item/katana_sheath/reverse,
		/obj/item/breaching_hammer,
		/obj/item/experimental/melee/spear/plaswood,
		/obj/item/sword/discount,
		/obj/item/survival_machete/syndicate,
		/obj/item/dagger/syndicate/specialist,
		/obj/item/deconstructor,
		/obj/item/circular_saw,
		/obj/item/wrench/battle,
		/obj/item/mining_tool/powerhammer,
		/obj/item/brick,
		/obj/item/rods/steel,
		/obj/item/fireaxe,
		/obj/item/quarterstaff)
	New()
		..()
		SPAWN(1 DECI SECOND)

			var/obj/new_item = pick(items2spawn)
			new new_item(src.loc)
			qdel(src)
/obj/surplusopspawner/melee_item_spawner/withcredits
	New()

		SPAWN(1 DECI SECOND)
			new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
			new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
			new /obj/item/requisition_token/syndicate/surplusutility(src.loc)
		..()
/obj/surplusopspawner/medical
	var/list/items2spawn = list(
	/obj/item/reagent_containers/food/snacks/donkpocket_w,
	/obj/item/storage/firstaid/crit,
	/obj/item/storage/firstaid/fire,
	/obj/item/storage/firstaid/brute,
	/obj/item/storage/firstaid/regular,
	/obj/item/storage/firstaid/regular/emergency,
	/obj/item/canned_laughter, //you know what they say about laughter and medicine
	/obj/item/canned_laughter,
	/obj/item/storage/firstaid/old,
	/obj/item/item_box/medical_patches/mini_synthflesh,
	/obj/item/item_box/medical_patches/mini_styptic,
	/obj/item/item_box/medical_patches/mini_silver_sulf,
	/obj/item/storage/pill_bottle/salicylic_acid,
	/obj/item/storage/pill_bottle/menthol
	//add funny hypospray here/nukie injectors
	)
	New()
		..()
		SPAWN(1 DECI SECOND)
			var/obj/new_item = pick(items2spawn)
			new new_item(src.loc)
			qdel(src)



/obj/surplusopspawner/
