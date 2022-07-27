//shit used in surplus ops' loadouts
/obj/random_item_spawner/surplus //for sake of organization, extend the path

/obj/surplus_spawner

//ammo!
/obj/random_item_spawner/surplus/shotgunshells
	min_amt2spawn = 4
	max_amt2spawn = 5
	items2spawn = list(/obj/item/ammo/bullets/buckshot_burst,
	/obj/item/ammo/bullets/pipeshot/scrap,
	/obj/item/ammo/bullets/a12,
	/obj/item/ammo/bullets/abg,
	/obj/item/ammo/bullets/flare,
	/obj/item/ammo/bullets/a12/weak)

/obj/random_item_spawner/surplus/plinkerrounds
	amt2spawn = 4
	items2spawn = list(/obj/item/ammo/bullets/bullet_22/smartgun,
	/obj/item/ammo/bullets/bullet_22, //repeats, as a hacky way to alter the weight of some items
	/obj/item/ammo/bullets/bullet_22,
	/obj/item/ammo/bullets/bullet_22HP)

/obj/random_item_spawner/surplus/pistolrounds
	amt2spawn = 4
	items2spawn = list(/obj/item/ammo/bullets/bullet_9mm,
	/obj/item/ammo/bullets/bullet_9mm,
	/obj/item/ammo/bullets/bullet_9mm,
	/obj/item/ammo/bullets/nine_mm_NATO)

/obj/random_item_spawner/surplus/revolverrounds
	amt2spawn = 3
	items2spawn = list(/obj/item/ammo/bullets/a357,
	/obj/item/ammo/bullets/a357/AP,
	/obj/item/ammo/bullets/a38,
	/obj/item/ammo/bullets/a38,
	/obj/item/ammo/bullets/a38/AP,
	/obj/item/ammo/bullets/a38/stun)

/obj/random_item_spawner/surplus/riflerounds
	min_amt2spawn = 4
	max_amt2spawn = 5
	items2spawn = list(/obj/item/ammo/bullets/assault_rifle,
	/obj/item/ammo/bullets/assault_rifle,
	/obj/item/ammo/bullets/assault_rifle/armor_piercing)

/obj/random_item_spawner/surplus/energycells
	amt2spawn = 2
	items2spawn = list(/obj/item/ammo/power_cell,
		/obj/item/ammo/power_cell,
		/obj/item/ammo/power_cell/med_power,
		/obj/item/ammo/power_cell/med_power,
		/obj/item/ammo/power_cell/self_charging/disruptor)
//weapons

/obj/random_item_spawner/surplus/longgun //not necessarily 2 handed, but powerful. Very pricey.
	amt2spawn = 1
	items2spawn = list(/obj/item/gun/kinetic/riotgun, //sorta out of place but it's more out of place in the shortguns
	/obj/item/gun/kinetic/spes,
	/obj/item/gun/kinetic/assault_rifle,
	/obj/item/gun/kinetic/grenade_launcher,
	/obj/item/gun/energy/egun,
	/obj/item/gun/energy/plasma_gun,
	/obj/item/gun/energy/alastor,
	/obj/item/gun/energy/blaster_smg)
/obj/random_item_spawner/surplus/shortgun //PRAY TO RNJESUS, SONNY
	amt2spawn = 1
	items2spawn = list(/obj/item/gun/kinetic/riot40mm,
	/obj/item/gun/kinetic/pistol,
	/obj/item/gun/kinetic/pistol/smart/mkII,
	/obj/item/gun/kinetic/sawnoff,
	/obj/item/gun/kinetic/silenced_22,
	/obj/item/gun/kinetic/clock_188,
	/obj/item/gun/kinetic/revolver,
	/obj/item/gun/kinetic/detectiverevolver,
	/obj/item/gun/kinetic/derringer,
	/obj/item/gun/kinetic/slamgun,//lol
	/obj/item/gun/kinetic/zipgun, //lmao, even
	/obj/item/gun/energy/laser_gun,
	/obj/item/gun/energy/phaser_gun)

