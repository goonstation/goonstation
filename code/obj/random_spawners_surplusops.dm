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

/obj/random_item_spawner/surplus/22rounds
	amt2spawn = 4
	items2spawn = list(/obj/item/ammo/bullets/bullet_22/smartgun,
	/obj/item/ammo/bullets/bullet_22, //repeats, as a hacky way to alter the weight of some items
	/obj/item/ammo/bullets/bullet_22,
	/obj/item/ammo/bullets/bullet_22HP)

/obj/random_item_spawner/surplus/9mmrounds
	amt2spawn = 4
	items2spawn = list(/obj/item/ammo/bullets/bullet_9mm,
	/obj/item/ammo/bullets/bullet_9mm,
	/obj/item/ammo/bullets/nine_mm_NATO,
	/obj/item/ammo/bullets/bullet_9mm/smg)

/obj/random_item_spawner/surplus/revolverrounds
	amt2spawn = 4
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

