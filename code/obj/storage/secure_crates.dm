/obj/storage/secure/crate
	desc = "A secure crate."
	name = "Secure crate"
	icon_state = "securecrate"
	icon_opened = "securecrateopen"
	icon_closed = "securecrate"
	icon_redlight = "securecrater"
	icon_greenlight = "securecrateg"
	icon_sparks = "securecratesparks"
	//var/emag = "securecrateemag"
	density = 1
	always_display_locks = 1
	throwforce = 50
	can_flip_bust = 1

/obj/storage/secure/crate/weapon
	desc = "A secure weapons crate."
	name = "Weapons crate"
	icon_state = "weaponcrate"
	density = 1
	icon_opened = "weaponcrateopen"
	icon_closed = "weaponcrate"

	confiscated_items
		name = "confiscated items crate"
		desc = "Secure storage for confiscated contraband."
		req_access_txt = "2"

	armory
		name = "secure weapons crate"
		req_access = list(access_maxsec)

		tranquilizer
			name = "tranquilizer crate"
			spawn_contents = list(/obj/item/gun/kinetic/dart_rifle = 2,\
			/obj/item/ammo/bullets/tranq_darts = 2,\
			/obj/item/ammo/bullets/tranq_darts/anti_mutant)

		phaser
			name = "phaser crate"
			spawn_contents = list(/obj/item/gun/energy/phaser_gun = 4)

		shotgun
			name = "shotgun crate"
			spawn_contents = list(/obj/item/gun/kinetic/riotgun = 4,\
			/obj/item/ammo/bullets/abg = 4)

		pod_weapons
			name = "pod weapons crate"
			spawn_contents = list(/obj/item/shipcomponent/mainweapon/disruptor_light = 2,\
			/obj/item/shipcomponent/mainweapon/laser = 2,\
			/obj/item/ammo/bullets/autocannon/seeker = 2)

/obj/storage/secure/crate/plasma
	desc = "A secure plasma crate."
	name = "Plasma crate"
	icon_state = "plasmacrate"
	density = 1
	icon_opened = "plasmacrateopen"
	icon_closed = "plasmacrate"

	armory
		name = "secure weapons crate"
		req_access = list(access_maxsec)

		anti_biological
			name = "anti-biological crate"
			spawn_contents = list(/obj/item/storage/box/flaregun = 2,\
			/obj/item/flamethrower/assembled/loaded = 2)

/obj/storage/secure/crate/gear
	desc = "A secure gear crate."
	name = "Gear crate"
	icon_state = "secgearcrate"
	density = 1
	icon_opened = "secgearcrateopen"
	icon_closed = "secgearcrate"

	armory
		name = "secure weapons crate"
		req_access = list(access_maxsec)

		grenades
			name = "special grenades crate"
			spawn_contents = list(/obj/item/storage/box/QM_grenadekit_security = 2,\
			/obj/item/storage/box/QM_grenadekit_experimentalweapons)

	sarin_grenades
		name = "nerve agent crate (DANGER)"
		req_access_txt = "52"
		spawn_contents = list(/obj/item/reagent_containers/syringe/atropine = 3,\
		/obj/item/chem_grenade/sarin = 3)

/obj/storage/secure/crate/bee
	name = "Secure Bee crate"
	desc = "A secure crate with a picture of a bee on it. Buzz."
	icon_state = "beecrate"
	density = 1
	icon_opened = "beecrateopen-secure"
	icon_closed = "beecrate-secure"

	loaded
		req_access = list(access_hydro)
		spawn_contents = list(/obj/item/bee_egg_carton = 5)

		var/blog = ""

		make_my_stuff()
			.=..()
			if (.)
				for(var/obj/item/bee_egg_carton/carton in src)
					carton.ourEgg.blog += blog
				return 1

/obj/storage/secure/crate/eng
	name = "Engineering crate"
	desc = "A yellow crate."
	icon_state = "engcrate"
	density = 1
	icon_opened = "engcrate-open"
	icon_closed = "engcrate"

	explosives
		name = "engineering explosive crate"
		desc = "Contains controlled explosives designed for trench use."
		req_access = list(access_engineering)
		spawn_contents = list(/obj/item/pipebomb/bomb/engineering = 6)
