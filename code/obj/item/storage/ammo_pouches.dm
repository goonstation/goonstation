/* 	Small storage ammo pouches for storing multiple magazines on your person.
	Can fit in pockets allowing folks to carry more ammo at the expense of taking a little longer to acces it.
	Less messy than having people spawn with 5 magazines in their backpack.	*/


/obj/item/storage/pouch
	name = "ammo pouch"
	icon_state = "ammopouch"
	desc = "A sturdy fabric pouch designed for carrying ammunition. Can be attatched to the webbing of a uniform to allow for quick access during combat."
	w_class = W_CLASS_TINY
	max_wclass = 1
	slots = 5
	does_not_open_in_pocket = 0
	can_hold = list(/obj/item/ammo)

	assault_rifle
		name = "rifle magazine pouch"
		icon_state = "ammopouch-large"
		spawn_contents = list(/obj/item/ammo/bullets/assault_rifle = 5)

		mixed
			spawn_contents = list(/obj/item/ammo/bullets/assault_rifle = 3, /obj/item/ammo/bullets/assault_rifle/armor_piercing = 2)

	bullet_9mm
		name = "pistol magazine pouch"
		icon_state = "ammopouch-double"
		spawn_contents = list(/obj/item/ammo/bullets/bullet_9mm = 5)

		small
			name = "small pistol magazine pouch"
			spawn_contents = list(/obj/item/ammo/bullets/bullet_9mm = 2)

		smg
			name = "smg magazine pouch"
			spawn_contents = list(/obj/item/ammo/bullets/bullet_9mm/smg = 5)

	tranq_pistol_dart
		name = "tranq pistol dart pouch"
		icon_state = "ammopouch-double"
		spawn_contents = list(/obj/item/ammo/bullets/tranq_darts/syndicate/pistol = 5)

	det_38
		name = ".38 rounds pouch"
		icon_state = "ammopouch-double"
		spawn_contents = list(/obj/item/ammo/bullets/a38/stun = 3)

	clock
		name = "9mm rounds pouch"
		icon_state = "ammopouch-double"
		spawn_contents = list(/obj/item/ammo/bullets/nine_mm_NATO = 5)


	powercell_medium
		name = "power cell pouch"
		icon_state = "ammopouch-cell"
		spawn_contents = list(/obj/item/ammo/power_cell/med_power = 5)

	sniper
		name = "sniper magazine pouch"
		icon_state = "ammopouch-double"
		slots = 5
		spawn_contents = list(/obj/item/ammo/bullets/rifle_762_NATO = 5)

	shotgun
		name = "shotgun shell pouch"
		icon_state = "ammopouch-large"
		spawn_contents = list(/obj/item/ammo/bullets/a12 = 5)

		weak
			spawn_contents = list(/obj/item/ammo/bullets/a12/weak = 5)

	revolver
		name = "revolver speedloader pouch"
		icon_state = "ammopouch-double"
		spawn_contents = list(/obj/item/ammo/bullets/a357=5)

	grenade_round
		name = "grenade round pouch"
		slots = 4
		spawn_contents = list(/obj/item/ammo/bullets/grenade_round/explosive = 2,
		/obj/item/ammo/bullets/grenade_round/high_explosive = 2)

	rpg
		name = "MPRT rocket pouch"
		slots = 4
		spawn_contents = list(/obj/item/ammo/bullets/rpg = 2)

/obj/item/storage/grenade_pouch
	name = "grenade pouch"
	icon_state = "ammopouch"
	desc = "A sturdy fabric pouch used to carry several grenades."
	w_class = W_CLASS_TINY
	slots = 6
	can_hold = list(/obj/item/old_grenade, /obj/item/chem_grenade)
	does_not_open_in_pocket = 0

	frag
		name = "frag grenade pouch"
		spawn_contents = list(/obj/item/old_grenade/stinger/frag = 6)

	stinger
		name = "stinger grenade pouch"
		spawn_contents = list(/obj/item/old_grenade/stinger = 6)

	incendiary
		name = "incendiary grenade pouch"
		spawn_contents = list(/obj/item/chem_grenade/incendiary = 6)

	high_explosive
		name = "high explosive grenade pouch"
		spawn_contents = list(/obj/item/old_grenade/high_explosive = 6)

	smoke
		name = "smoke grenade pouch"
		spawn_contents = list(/obj/item/old_grenade/smoke = 6)

	mixed_standard
		name = "mixed grenade pouch"
		spawn_contents = list(/obj/item/chem_grenade/flashbang = 2,
		/obj/item/old_grenade/stinger/frag = 2,
		/obj/item/old_grenade/stinger = 2)

	mixed_explosive
		name = "mixed grenade pouch"
		spawn_contents = list(/obj/item/old_grenade/stinger/frag = 3,
		/obj/item/old_grenade/stinger = 3)

// dumb idiot gannets shouldn't have called these "ammo_pouches" if he was gonna make pouches for non-ammo things. wow.

/obj/item/storage/medical_pouch
	name = "trauma field kit"
	icon_state = "ammopouch-medic"
	w_class = W_CLASS_TINY
	slots = 4
	does_not_open_in_pocket = 0
	spawn_contents = list(/obj/item/reagent_containers/mender/brute/high_capacity,
	/obj/item/reagent_containers/mender/burn/high_capacity)

/obj/item/storage/security_pouch
	name = "security pouch"
	desc = "A small pouch containing some essential security supplies. Keep out of reach of the clown."
	icon_state = "ammopouch-sec"
	w_class = W_CLASS_SMALL
	slots = 6
	does_not_open_in_pocket = 0
	spawn_contents = list(/obj/item/handcuffs = 3,\
	/obj/item/ammo/power_cell/high_power,\
	/obj/item/device/flash,\
	/obj/item/instrument/whistle)

/obj/item/storage/security_pouch/assistant
	spawn_contents = list(/obj/item/handcuffs = 2,\
	/obj/item/device/flash = 2,\
	/obj/item/instrument/whistle,\
	/obj/item/reagent_containers/food/snacks/donut/custom/frosted)

/obj/item/storage/ntso_pouch
	name = "tacticool pouch"
	desc = "A dump pouch for various security accessories, partially-loaded magazines, or maybe even a snack! Attaches to virtually any webbing system through an incredibly complex and very patented Nanotrasen design."
	icon_state = "ammopouch-large"
	w_class = W_CLASS_SMALL
	slots = 5
	does_not_open_in_pocket = 0
	spawn_contents = list(/obj/item/handcuffs/ = 1,
	/obj/item/handcuffs/guardbot = 2,
	/obj/item/device/flash,
	/obj/item/reagent_containers/food/snacks/candy/candyheart)
