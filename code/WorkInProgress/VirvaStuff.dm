/obj/item/implant/projectile/bullet_flechette
	name = "flechette"
	desc = "A small, nasty-looking steel dart designed to pierce through armor and space suits."

/obj/item/casing/polymer
	icon_state = "polymer"
	desc = "An odd plastic casing, entirely hollow and slightly melted."
	New()
		..()
		SPAWN(rand(1, 3))
			playsound(src.loc, "sound/weapons/casings/casing-shell-0[rand(1,7)].ogg", 15, 0.1, 0, 0.7)

obj/item/ammo/bullets/flechette_mag
	sname = "5x40mm SCF" // note this is the whole telescoped cartridge size, SCF: synthetic case flechette
	name = "Flechette magazine"
	ammo_type = new/datum/projectile/bullet/flechette
	icon_state = "flech_mag"
	amount_left = 20
	max_amount = 20
	ammo_cat = AMMO_FLECHETTE // the actual diameter of the flechette once free of the sabot
	sound_load = 'sound/weapons/gunload_hitek.ogg'

/datum/projectile/bullet/flechette
	name = "flechette"
	shot_sound = 'sound/weapons/fleshot.ogg'
	shot_volume = 70
	power = 30
	cost = 2
	ks_ratio = 1
	hit_ground_chance = 100
	damage_type = D_PIERCING
	armor_ignored = 0.66
	hit_type = DAMAGE_STAB
	shot_number = 2
	shot_delay = 70 MILLI SECONDS
	dissipation_delay = 10
	dissipation_rate = 3
	projectile_speed = 56
	impact_image_state = "bhole-small"
	implanted = /obj/item/implant/projectile/bullet_flechette
	casing = /obj/item/casing/polymer

/obj/item/gun/kinetic/flechette_rifle
	name = "Tikari flechette rifle"
	desc = "A bullpup assault rifle chambered in a proprietary flechette cartridge. Issued to Syndicate counter-boarding teams and outpost security."
	icon = 'icons/obj/large/48x32.dmi'
	icon_state = "flech"
	item_state = "assault_rifle"
	has_empty_state = 1
	uses_multiple_icon_states = 1
	force = MELEE_DMG_RIFLE
	contraband = 8
	ammo_cats = list(AMMO_FLECHETTE)
	max_ammo_capacity = 20
	can_dual_wield = 0
	two_handed = 1
	auto_eject = 1
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | ONBACK
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD
	w_class = W_CLASS_NORMAL
	spread_angle = 3
	default_magazine = /obj/item/ammo/bullets/flechette_mag
	ammobag_magazines = list(/obj/item/ammo/bullets/flechette_mag)

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/flechette)
		..()

/obj/item/storage/pouch/flechette
	name = "flechette magazine pouch"
	icon_state = "ammopouch-double"
	spawn_contents = list(/obj/item/ammo/bullets/flechette_mag = 5)

// Office
/obj/item/reagent_containers/food/drinks/flask/taskumatti
	name = "taskumatti"
	desc = "Korpikuusen kyynel...? "
	icon = 'icons/obj/foodNdrink/bottle.dmi'
	icon_state = "taskumatti"
	item_state = "taskumatti"
	initial_reagents = list("enriched_msg"=10,"energydrink"=10,"royal_jelly"=10,"hard_punch"=10)

/obj/item/decoration/virvase
	name = "pretty purple hibiscus"
	desc = "A lovely flower from a dear friend."
	icon_state = "virvase"
