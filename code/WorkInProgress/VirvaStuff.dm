// flechette rifle stuff
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
	ammo_cat = AMMO_FLECHETTE
	sound_load = 'sound/weapons/gunload_hitek.ogg'

/datum/projectile/bullet/flechette
	name = "flechette"
	shot_sound = 'sound/weapons/fleshot.ogg'
	shot_volume = 70
	damage = 30
	cost = 2
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

// kuvalda stuff
/datum/projectile/bullet/kuvalda/barrikada
	name = "barrikada slug"
	icon_state = "trace"
	shot_sound = 'sound/weapons/kuvalda.ogg'
	damage = 110
	dissipation_delay = 2
	dissipation_rate = 5
	damage_type = D_KINETIC
	hit_type = DAMAGE_STAB
	impact_image_state = "bhole"
	hit_ground_chance = 25
	implanted = /obj/item/implant/projectile/shrapnel
	casing = /obj/item/casing/shotgun/orange

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if (ishuman(hit))
			var/mob/living/carbon/human/M = hit
			if(proj.power >= 30)
				M.do_disorient(75, weakened = 50, stunned = 50, disorient = 30, remove_stamina_below_zero = 0)

			if(proj.power >= 40)
				var/throw_range = (proj.power > 50) ? 6 : 3
				var/turf/target = get_edge_target_turf(M, dirflag)
				M.throw_at(target, throw_range, 1, throw_type = THROW_GUNIMPACT)
				M.update_canmove()
			if (M.organHolder)
				var/targetorgan
				for (var/i in 1 to (power/10)-2)
					targetorgan = pick("left_lung", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix", "tail")
					M.organHolder.damage_organ(proj.power/M.get_ranged_protection(), 0, 0, prob(5) ? "heart" : targetorgan)

			..()

/datum/projectile/bullet/kuvalda/shrapnel
	name = "shrapnel buckshot"
	sname = "shrapnel buckshot"
	icon_state = "trace"
	damage = 12
	dissipation_rate = 2
	dissipation_delay = 5
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	impact_image_state = "bhole"
	hit_ground_chance = 50
	implanted = null

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if (ishuman(hit))
			var/mob/living/carbon/human/M = hit

			if (M.organHolder)
				var/targetorgan
				for (var/i in 1 to (power/10)-2)
					targetorgan = pick("left_lung", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix", "tail")
					M.organHolder.damage_organ(proj.power/M.get_ranged_protection(), 0, 0, prob(5) ? "heart" : targetorgan)

			if(prob(proj.power/4) && power > 5)
				M.sever_limb(pick("l_arm","r_arm","l_leg","r_leg"))
			..()

/datum/projectile/special/spreader/buckshot_burst/kuvalda
	name = "shrapnel buckshot"
	sname = "shrapnel buckshot"
	cost = 1
	pellets_to_fire = 8
	spread_projectile_type = /datum/projectile/bullet/kuvalda/shrapnel
	casing = /obj/item/casing/shotgun/gray
	shot_sound = 'sound/weapons/kuvalda.ogg'
	speed_max = 50
	speed_min = 45
	spread_angle_variance = 7
	dissipation_variance = 3

/obj/item/ammo/bullets/barrikada
	sname = "Barrikada Slugs"
	name = "23mm barrikada slugs"
	desc = "Enormous 23mm shotgun shells, loaded with terrifying solid-steel slugs."
	ammo_type = new/datum/projectile/bullet/kuvalda/barrikada
	icon_state = "barrikada"
	amount_left = 4
	max_amount = 4
	ammo_cat = AMMO_KUVALDA
	icon_dynamic = 1
	sound_load = 'sound/weapons/gunload_heavy.ogg'
	delete_on_reload = TRUE
	w_class = W_CLASS_NORMAL

/obj/item/ammo/bullets/shrapnel
	sname = "Shrapnel Buckshot"
	name = "23mm shrapnel buckshot"
	desc = "Enormous 23mm shotgun shells, loaded with a spread of lethal buckshot."
	ammo_type = new/datum/projectile/special/spreader/buckshot_burst/kuvalda
	icon_state = "shrapnel"
	amount_left = 4
	max_amount = 4
	ammo_cat = AMMO_KUVALDA
	icon_dynamic = 1
	sound_load = 'sound/weapons/gunload_heavy.ogg'
	delete_on_reload = TRUE
	w_class = W_CLASS_NORMAL

// /obj/item/ammo/bullets/cheremukha

// /obj/item/ammo/bullets/zvezda

// /obj/item/ammo/bullets/grapple


/obj/item/gun/kinetic/kuvalda
	name = "\improper Karabin Kuvalda"
	desc = "A heavy pump-action carbine with a rifled 23mm bore, produced by the Zvezda Design Bureau. Issued to Soviet counter-boarding teams to dissuade nosey pod pilots."
	icon = 'icons/obj/large/48x32.dmi'
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	icon_state = "kuvalda"
	item_state = "kuvalda"
	wear_state = "kuvalda"
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | ONBACK
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD
	force = MELEE_DMG_RIFLE
	contraband = 10
	ammo_cats = list(AMMO_KUVALDA)
	max_ammo_capacity = 4
	auto_eject = 0
	can_dual_wield = 0
	two_handed = 1
	has_empty_state = 1
	gildable = 1
	default_magazine = /obj/item/ammo/bullets/shrapnel
	var/racked_slide = FALSE

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/special/spreader/buckshot_burst/kuvalda)
		..()

	update_icon()
		. = ..()
		src.icon_state = "kuvalda" + (gilded ? "-golden" : "") + (racked_slide ? "" : "-empty" )

	canshoot(mob/user)
		return(..() && src.racked_slide)

	shoot(var/target,var/start ,var/mob/user)
		if(ammo.amount_left > 0 && !racked_slide)
			boutput(user, "<span class='notice'>Pump that action, comrade!</span>")
		..()
		src.racked_slide = FALSE
		src.casings_to_eject = src.ammo.amount_left ? 1 : 0
		src.UpdateIcon()

	shoot_point_blank(atom/target, mob/user, second_shot)
		if(ammo.amount_left > 0 && !racked_slide)
			boutput(user, "<span class='notice'>Pump that action, comrade!</span>")
			return
		..()
		src.racked_slide = FALSE
		src.casings_to_eject = src.ammo.amount_left ? 1 : 0
		src.UpdateIcon()

	attack_self(mob/user as mob)
		..()
		src.rack(user)

	proc/rack(var/atom/movable/user)
		var/mob/mob_user = null
		if(ismob(user))
			mob_user = user
		if (!src.racked_slide)
			if (src.ammo.amount_left == 0)
				boutput(mob_user, "<span class ='notice'>Carbine is empty!</span>")
				UpdateIcon()
			else
				src.racked_slide = TRUE
				if (src.icon_state == "kuvalda[src.gilded ? "-golden" : ""]")
					src.icon_state = "kuvalda[src.gilded ? "-golden-empty" : "-empty"]"
					animate(src, time = 0.2 SECONDS)
					animate(icon_state = "kuvalda[gilded ? "-golden" : ""]")
				else
					UpdateIcon()
				boutput(mob_user, "<span class='notice'>You pump the action!</span>")
				playsound(user.loc, 'sound/weapons/kuvaldapump.ogg', 50, 1)
				src.casings_to_eject = 0
				if (src.ammo.amount_left < 4)
					var/turf/T = get_turf(src)
					if (T && src.current_projectile.casing)
						new src.current_projectile.casing(T, src.forensic_ID)

/obj/item/storage/pouch/kuvalda
	name = "kuvalda shell pouch"
	icon_state = "ammopouch-large"
	spawn_contents = list(/obj/item/ammo/bullets/shrapnel = 3, /obj/item/ammo/bullets/barrikada = 2)

// office stuff
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
