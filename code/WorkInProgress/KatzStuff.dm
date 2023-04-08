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
	damage = 50
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

// SILLY ADMIN GIMMICK COMPONENT
/datum/component/mimic_item
	var/obj/item/source_item

TYPEINFO(/datum/component/mimic_item)
	initialization_args = list()

/datum/component/mimic_item/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	else
		source_item = parent
	. = ..()
	var/mob/living/critter/small_animal/item_mimic/our_mimic = new /mob/living/critter/small_animal/item_mimic
	our_mimic.name = source_item.name
	our_mimic.real_name = source_item.name
	our_mimic.desc = source_item.desc
	our_mimic.icon = getFlatIcon(source_item)
	our_mimic.set_dir(source_item.dir)
	our_mimic.set_loc(get_turf(source_item))
	source_item.set_loc(our_mimic)

/datum/component/mimic_item/UnregisterFromParent()
	. = ..()

/datum/targetable/gimmick/grow_legs_mimic
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "power_kick"
	name = "Toggle Legs"
	desc = "Toggle legs to run around with."
	targeted = FALSE
	cooldown = 0.2 SECONDS

	tryCast()
		if (is_incapacitated(holder.owner))
			boutput(holder.owner, "<span class='alert'>You cannot cast this ability while you are incapacitated.</span>")
			src.holder.locked = FALSE
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		. = ..()

	cast(atom/T)
		var/datum/component/C = usr.GetComponent(/datum/component/legs)
		if(!C)
			usr.AddComponent(/datum/component/legs)
		else
			C.RemoveComponent(/datum/component/legs)
		usr.update_canmove()

/mob/living/critter/small_animal/item_mimic
	name = "mimic"
	desc = "A real genuine item."
	icon = 'icons/misc/critter.dmi'
	icon_state = "snake"
	density = FALSE
	custom_gib_handler = /proc/gibs
	hand_count = 1
	can_help = TRUE
	can_throw = FALSE
	can_grab = TRUE
	can_disarm = FALSE
	butcherable = FALSE
	name_the_meat = FALSE
	max_skins = 0
	health_brute = 100
	health_burn = 100
	ai_type = /datum/aiHolder/spider_peaceful
	is_npc = FALSE
	flags = TABLEPASS
	add_abilities = list(/datum/targetable/critter/bite,
			/datum/targetable/gimmick/grow_legs_mimic,
			/datum/targetable/critter/fadeout,
			/datum/targetable/gimmick/reveal)
	var/critter_scream_sound = 'sound/voice/screams/fescream4.ogg'
	var/critter_scream_pitch = -2.5
	var/critter_fart_sound = 'sound/voice/farts/fart2.ogg'
	var/critter_fart_pitch = -2

	var/atom/movable/target_type = null

	New()
		..()

	setup_hands()
		..()

		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "teeth"
		HH.can_hold_items = 0
		HH.can_attack = 1

	update_canmove()
		var/datum/component/C = src.GetComponent(/datum/component/legs)
		if(C)
			src.canmove = TRUE
		else
			src.canmove = FALSE

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), critter_scream_sound , 80, 1, pitch = critter_scream_pitch, channel = VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> screams!"
			if ("fart")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), critter_fart_sound , 80, 1, pitch = critter_fart_pitch, channel = VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> farts!"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream", "fart")
				return 2
		return ..()

	death(var/gibbed)
		. = ..()
		if (!gibbed)
			ghostize()
			qdel(src)
