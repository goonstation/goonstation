//shit used in surplus ops' loadouts
/obj/random_item_spawner/surplus //for sake of organization, extend the path


/////////////////Weapons- actual loadout spawners are in surplus_ops_items/////////////////
/obj/random_item_spawner/surplus/longgun //not necessarily 2 handed, but powerful. Very pricey.
	amt2spawn = 1
	items2spawn = list(
		/obj/item/gun/kinetic/spes,
		/obj/item/gun/kinetic/assault_rifle,
		/obj/item/gun/energy/egun,
		/obj/item/gun/kinetic/hunting_rifle,
		/obj/item/gun/energy/plasma_gun,
		/obj/item/gun/kinetic/riotgun, //sorta out of place but it's more out of place in the shortgun category
		/obj/item/gun/kinetic/single_action/mts_255, //ditto
		/obj/item/gun/energy/alastor,
		/obj/item/gun/energy/blaster_smg)

/obj/random_item_spawner/surplus/shortgun //YOU BEST PRAY TO RNJESUS, SONNY
	amt2spawn = 1
	rare_chance = 5
	items2spawn = list(/obj/item/gun/kinetic/riot40mm,
		/obj/item/gun/kinetic/pistol,
		/obj/item/gun/kinetic/sawnoff,
		/obj/item/gun/kinetic/silenced_22,
		/obj/item/gun/kinetic/pistol,
		/obj/item/gun/kinetic/clock_188,
		/obj/item/gun/kinetic/slamgun, //lol
		/obj/item/gun/kinetic/zipgun, //lmao, even
		/obj/item/gun/kinetic/detectiverevolver,
		/obj/item/gun/kinetic/single_action/colt_saa/detective,
		/obj/item/gun/kinetic/derringer,
		/obj/item/storage/rockit,
		/obj/item/gun/energy/laser_gun,
		/obj/item/gun/energy/phaser_gun,
		/obj/item/gun/energy/phaser_small,
		/obj/item/gun/reagent/syringe )//while the syringegun is capable, it'll be hard to find poison for it, hence shortgun status

	rare_items2spawn = list(
	/obj/item/gun/kinetic/revolver)

/obj/random_item_spawner/surplus/melee
	amt2spawn = 1
	items2spawn = list(/obj/item/ratstick,
		/obj/item/bat,
		/obj/item/katana_sheath/reverse,
		/obj/item/knife/butcher,
		/obj/item/clothing/gloves/bladed,
		/obj/item/breaching_hammer,
		/obj/item/experimental/melee/spear/plaswood,
		/obj/item/sword/discount,
		/obj/item/survival_machete/syndicate,
		/obj/item/dagger/syndicate,
		/obj/item/dagger/syndicate/specialist,
		/obj/item/deconstructor,
		/obj/item/circular_saw,
		/obj/item/wrench/battle,
		/obj/item/mining_tool/powerhammer,
		/obj/item/brick,
		/obj/item/rods/steel,
		/obj/item/fireaxe,
		/obj/item/quarterstaff,
		/obj/item/kitchen/utensil/knife/cleaver)

/////////////////Utilities/////////////////
/obj/random_item_spawner/surplus/grenades
	min_amt2spawn = 3
	max_amt2spawn = 4
	items2spawn = list(
		/obj/item/chem_grenade/incendiary,
		/obj/item/chem_grenade/very_incendiary,
		/obj/item/chem_grenade/flashbang,
		/obj/item/chem_grenade/napalm, //I am very much aware that this does nothing without a light, but that opens the door up for some truly gamer plays
		/obj/item/pipebomb/bomb/miniature_syndicate,
		/obj/item/old_grenade/stinger,
		/obj/item/old_grenade/high_explosive,
		/obj/item/old_grenade/high_explosive,
		/obj/item/old_grenade/stinger/frag,
		/obj/item/chem_grenade/shock,
		/obj/item/old_grenade/spawner/wasp,
		/obj/item/old_grenade/sawfly,
		/obj/item/chem_grenade/fcleaner,
		/obj/item/old_grenade/emp)

	rare_items2spawn = list(/obj/item/old_grenade/spawner/sawflycluster,
		/obj/item/chem_grenade/pepper,
		/obj/item/chem_grenade/fog,
		/obj/item/chem_grenade/sarin,
		/obj/item/gimmickbomb/butt)

/obj/random_item_spawner/surplus/storage
	amt2spawn = 1
	items2spawn = list(/obj/item/storage/pouch/highcap,
		/obj/item/storage/fanny/funny,
		/obj/item/storage/fanny,
		/obj/item/storage/belt/utility,
		/obj/item/storage/belt/hunter, //can be gotten from space, no reason it can't show up here
		/obj/item/storage/belt/medical,
		/obj/item/storage/box/syndibox)

/obj/random_item_spawner/surplus/backup
	amt2spawn = 1
	items2spawn = list(
		/obj/item/remote/reinforcement_beacon,
		/obj/item/old_grenade/spawner/sawflycluster,
		/obj/item/storage/box/wasp_grenade_kit,
		/obj/item/spongecaps/syndicate,
		/obj/item/pipebomb/bomb/miniature_syndicate,
		/obj/item/gun/energy/wasp,
		/obj/item/implanter/mindhack,
		/obj/machinery/recharge_station/syndicate)

/obj/random_item_spawner/surplus/expensive
	amt2spawn = 1
	items2spawn = list(
		/obj/item/card/emag,
		/obj/item/storage/belt/wrestling,
		/obj/item/clothing/head/bighat/syndicate,
		/obj/item/implanter/super_mindhack,
		/obj/item/katana_sheath,
		/obj/item/sword,
		/obj/item/saw/syndie,
		/obj/item/storage/box/poison, //these two aren't super expensive but should be rarer
		/obj/item/storage/box/donkpocket_w_kit,
		/obj/storage/crate/syndicate_surplus/spawnable, //yo dawg, I heard you like surplus
		/obj/item/storage/box/mindhack_module_kit)

/obj/random_item_spawner/surplus/stealth
	amt2spawn = 1
	items2spawn = list(
		/obj/item/storage/backpack/chameleon,
		/obj/item/radiojammer,
		/obj/item/pen/sleepypen,
		/obj/item/device/chameleon,
		/obj/item/cigpacket/syndicate,
		/obj/item/voice_changer,
		/obj/item/clothing/suit/cardboard_box,
		/obj/item/device/powersink,
		/obj/item/dna_scrambler,
		/obj/item/cloak_gen,
		/obj/item/lightbreaker,
		/obj/item/storage/box/chameleonbomb,
		)

/obj/random_item_spawner/surplus/defensive

	amt2spawn = 1
	items2spawn = list(
		/obj/item/barrier,
		/obj/item/storage/beartrap_pouch,
		/obj/item/clothing/suit/armor/makeshift,
		/obj/item/clothing/suit/armor/vest,
		/obj/item/clothing/gloves/swat,
		/obj/item/storage/box/mousetraps, //solely to synergize with grenades
		/obj/item/device/flash,
		/obj/item/device/ocular_implanter,
		/obj/item/implanter/freedom,
		/obj/item/storage/box/stun_landmines,
		/obj/item/storage/landmine_pouch
		)


/obj/random_item_spawner/surplus/medical
	amt2spawn = 1
	items2spawn = list(
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
	/obj/item/storage/pill_bottle/menthol,
	/obj/item/reagent_containers/hypospray/emagged,
	/obj/item/reagent_containers/emergency_injector/methamphetamine,
	/obj/item/reagent_containers/glass/beaker/large/surplusmedical,
	/obj/item/reagent_containers/emergency_injector/high_capacity/cardiac,
	/obj/item/storage/firstaid/regular/doctor_spawn,
	/obj/item/reagent_containers/emergency_injector/high_capacity/donk_injector)

/////////////////Ammo/////////////////
/obj/random_item_spawner/surplus/plinkerrounds
	amt2spawn = 4
	rare_items2spawn = list(/obj/item/ammo/bullets/bullet_22)
	items2spawn = list(/obj/item/ammo/bullets/bullet_22/smartgun,
	/obj/item/ammo/bullets/bullet_22, //repeats, as a hacky way to alter the weight of some items without using rare_items2spawn
	/obj/item/ammo/bullets/bullet_22,
	/obj/item/ammo/bullets/bullet_22HP)

/obj/random_item_spawner/surplus/pistolrounds
	amt2spawn = 4
	rare_items2spawn = list(/obj/item/ammo/bullets/bullet_9mm)
	items2spawn = list(/obj/item/ammo/bullets/bullet_9mm,
	/obj/item/ammo/bullets/bullet_9mm,
	/obj/item/ammo/bullets/bullet_9mm,
	/obj/item/ammo/bullets/nine_mm_soviet,//no makarov due to ammo pain, but I am including the magazines to help dilute the brawnen clips
	/obj/item/ammo/bullets/nine_mm_NATO)

/obj/random_item_spawner/surplus/revolverrounds
	amt2spawn = 2
	guaranteed = list(/obj/item/ammo/bullets/a38)//always ensure they get at least some univeral ammo

	items2spawn = list(/obj/item/ammo/bullets/a357,
		/obj/item/ammo/bullets/a357/AP,
		/obj/item/ammo/bullets/a38,
		/obj/item/ammo/bullets/a38,
		/obj/item/ammo/bullets/a38/AP,
		/obj/item/ammo/bullets/a38/stun)

/obj/random_item_spawner/surplus/rifleroundslittle
	amt2spawn = 4
	rare_items2spawn = list(/obj/item/ammo/bullets/assault_rifle)
	items2spawn = list(/obj/item/ammo/bullets/assault_rifle,
		/obj/item/ammo/bullets/assault_rifle,
		/obj/item/ammo/bullets/assault_rifle/armor_piercing)

///obj/random_item_spawner/surplus/rifleroundsbig
//	amt2spawn = 2
//	rare_items2spawn = list(/obj/item/ammo/bullets/rifle_762_NATO)
//	items2spawn = list(
//		/obj/item/ammo/bullets/rifle_3006)

/obj/random_item_spawner/surplus/shotgunshells
	min_amt2spawn = 4
	max_amt2spawn = 5
	items2spawn = list(/obj/item/ammo/bullets/buckshot_burst,
	/obj/item/ammo/bullets/pipeshot/scrap,
	/obj/item/ammo/bullets/pipeshot/plasglass,
	/obj/item/ammo/bullets/abg,
	/obj/item/ammo/bullets/flare,
	/obj/item/ammo/bullets/a12/weak,
	/obj/item/ammo/bullets/a12)
	rare_items2spawn = list(/obj/item/ammo/bullets/pipeshot/scrap,
		/obj/item/ammo/bullets/aex)

/obj/random_item_spawner/surplus/grenadeshells
	amt2spawn = 3
	items2spawn = list(
		/obj/item/ammo/bullets/smoke,
		/obj/item/ammo/bullets/pbr/four,
		/obj/item/ammo/bullets/grenade_round/explosive,
		/obj/item/ammo/bullets/grenade_round/high_explosive,
		)

/obj/random_item_spawner/surplus/energycells
	amt2spawn = 2
	items2spawn = list(/obj/item/ammo/power_cell,
		/obj/item/ammo/power_cell,
		/obj/item/ammo/power_cell/med_power,
		/obj/item/ammo/power_cell/med_power,
		/obj/item/ammo/power_cell/self_charging/disruptor)
	rare_items2spawn = list(/obj/item/ammo/power_cell/high_power)
