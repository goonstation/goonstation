// Sprite by Blackrep
/obj/item/gun/kinetic/ag3_rifle
	name = "AG3 battle rifle"
	desc = "A modern semi-automatic battle rifle manufactured by Almagest Weapons Fabrication. Rarely seen in space operations due to their bulk."
	icon = 'icons/obj/large/64x32.dmi'
	icon_state = "ag3_rifle"
	item_state = "assault_rifle"
	uses_multiple_icon_states = 1
	force = MELEE_DMG_RIFLE
	contraband = 8
	ammo_cats = list(AMMO_AUTO_308)
	max_ammo_capacity = 20
	can_dual_wield = 0
	two_handed = 1
	auto_eject = 1
	w_class = W_CLASS_NORMAL
	spread_angle = 3
	default_magazine = /obj/item/ammo/bullets/battle_rifle

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/battle_rifle)
		..()

/datum/projectile/bullet/battle_rifle
	name = "bullet"
	shot_sound = 'sound/weapons/ak47shot.ogg'
	power = 50
	ks_ratio = 1
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	impact_image_state = "bhole-small"
	implanted = /obj/item/implant/projectile/bullet_308
	casing = /obj/item/casing/rifle

/obj/item/ammo/bullets/battle_rifle
	sname = "7.62 Auto"
	name = "Battle Rifle magazine"
	desc = "A polymer magazine capable of holding 20 rounds of 7.62×51mm"
	ammo_type = new/datum/projectile/bullet/battle_rifle
	icon_state = "battle_mag"
	amount_left = 20
	max_amount = 20
	ammo_cat = AMMO_AUTO_308
	sound_load = 'sound/weapons/gunload_heavy.ogg'
