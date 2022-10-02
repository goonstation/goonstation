// gimme your guts
/obj/item/clothing/suit/space/repo
	name = "leather overcoat"
	desc = "Dark and mysterious..."
	icon_state = "repo"
	item_state = "repo"
	icon = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_hazard.dmi'
	item_function_flags = IMMUNE_TO_ACID
	contraband = 3
	body_parts_covered = TORSO|LEGS|ARMS
	wear_layer = MOB_OVERLAY_BASE

	setupProperties()
		..()
		setProperty("space_movespeed", 0)
		setProperty("exploprot", 10)
		setProperty("meleeprot", 4)
		setProperty("rangedprot", 1.5)
		setProperty("disorient_resist", 65)

/obj/item/clothing/head/helmet/space/repo
	name = "ominous helmet"
	desc = "How is the visor glowing like that?"
	icon_state = "repo"
	item_state = "repo"
	item_function_flags = IMMUNE_TO_ACID
	blocked_from_petasusaphilic = TRUE
	color_r = 0.7
	color_g = 0.7
	color_b = 0.9

// Komentaja
/mob/living/carbon/human/mari

	New()
		..()
		src.equip_new_if_possible(/obj/item/clothing/under/misc/syndicate, slot_w_uniform)
		src.equip_new_if_possible(/obj/item/clothing/shoes/swat, slot_shoes)
		src.equip_new_if_possible(/obj/item/clothing/glasses/sunglasses, slot_glasses)
		src.equip_new_if_possible(/obj/item/clothing/head/beret/syndie, slot_head)
		src.equip_new_if_possible(/obj/item/storage/backpack/satchel/syndie, slot_back)
		src.equip_new_if_possible(/obj/item/device/radio/headset/syndicate/leader, slot_ears)
		src.equip_new_if_possible(/obj/item/card/id/syndicate/commander, slot_wear_id)
		src.equip_new_if_possible(/obj/item/storage/belt/security/shoulder_holster/inspector, slot_belt)
		src.equip_new_if_possible(/obj/item/uplink/syndicate/alternate, slot_r_store)
		src.equip_new_if_possible(/obj/item/storage/pouch/flechette, slot_l_store)
		src.equip_new_if_possible(/obj/item/gun/kinetic/flechette_rifle, slot_l_hand)

	initializeBioholder()
		. = ..()
		src.real_name = "Mari Toivola"
		src.sound_list_laugh = list('sound/voice/felaugh1.ogg', 'sound/voice/felaugh2.ogg')
		src.sound_list_scream = list('sound/voice/screams/female_scream.ogg')

		bioHolder.age = 34
		bioHolder.bloodType = "O-"
		bioHolder.mobAppearance.customization_first = new /datum/customization_style/hair/hairup/fun_bun
		bioHolder.mobAppearance.customization_first_color = "#a06025"
		bioHolder.mobAppearance.s_tone = "#E4B6A7"
		bioHolder.mobAppearance.e_color = "#0a5834"
		bioHolder.mobAppearance.underwear = "braboy"
		bioHolder.mobAppearance.u_color = "#3d0808"
		bioHolder.mobAppearance.gender = "female"


/obj/item/clothing/head/beret/syndie
	name = "syndicate beret"
	desc = "A Syndicate officer's beret."
	icon_state = "beret_base"
	blocked_from_petasusaphilic = TRUE

	New()
		..()
		src.color = "#890000"

// pew pew
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
	amount_left = 40
	max_amount = 40
	ammo_cat = AMMO_FLECHETTE // the actual diameter of the flechette once free of the sabot
	sound_load = 'sound/weapons/gunload_hitek.ogg'

/datum/projectile/bullet/flechette
	name = "flechette"
	shot_sound = 'sound/weapons/fleshot.ogg'
	shot_volume = 70
	power = 25
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
	max_ammo_capacity = 40
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

/obj/item/gun/kinetic/sokk
	desc = "A familiar looking machine pistol."
	name = "\improper Sokk Taktische Maschinenpistole"
	icon_state = "glocksyn"
	item_state = "glocksyn"
	shoot_delay = 1
	w_class = W_CLASS_SMALL
	force = MELEE_DMG_PISTOL
	ammo_cats = list(AMMO_FLECHETTE)
	max_ammo_capacity = 21
	auto_eject = 1
	has_empty_state = 1
	gildable = 0
	fire_animation = TRUE
	default_magazine = /obj/item/ammo/bullets/sokk

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/sokk)
		projectiles = list(current_projectile,new/datum/projectile/bullet/sokk/burst)
		..()

	attack_self(mob/user as mob)
		..()	//burst shot has a slight spread.
		if (istype(current_projectile, /datum/projectile/bullet/sokk/burst/))
			spread_angle = 6
			shoot_delay = 3 DECI SECONDS
		else
			spread_angle = 0
			shoot_delay = 2 DECI SECONDS

/obj/item/ammo/bullets/sokk
	sname = "6.5×20mm AP"
	name = "6.5×20mm SOKK magazine"
	desc = "High-velocity pistol cartridges, loaded with armor-piercing bullets."
	icon_state = "pistol_clip"
	amount_left = 21
	max_amount = 21
	ammo_type = new/datum/projectile/bullet/sokk
	ammo_cat = AMMO_FLECHETTE

/datum/projectile/bullet/sokk
	name = "bullet"
	shot_sound = 'sound/weapons/9x19NATO.ogg'
	power = 15
	damage_type = D_PIERCING
	armor_ignored = 0.66
	hit_type = DAMAGE_STAB
	hit_ground_chance = 50
	projectile_speed = 60
	impact_image_state = "bhole-small"
	implanted = /obj/item/implant/projectile/bullet_flechette
	casing = /obj/item/casing/small

/datum/projectile/bullet/sokk/burst
	sname = "burst fire"
	power = 15
	cost = 3
	shot_number = 3
