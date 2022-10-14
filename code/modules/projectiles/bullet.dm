ABSTRACT_TYPE(/datum/projectile/bullet)
/datum/projectile/bullet
//How much of a punch this has, tends to be seconds/damage before any resist
	power = 45
//How much ammo this costs
	cost = 1
//How fast the power goes away
	dissipation_rate = 5
//How many tiles till it starts to lose power
	dissipation_delay = 5
//Kill/Stun ratio
	ks_ratio = 1
//name of the projectile setting, used when you change a guns setting
	sname = "single shot"
//file location for the sound you want it to play
	shot_sound = 'sound/weapons/Gunshot.ogg'
//How many projectiles should be fired, each will cost the full cost
	shot_number = 1

	// caliber list: update as needed
	// 0.22 pistol / zipgun
	// 0.308 - rifles
	// 0.357 - revolver
	// 0.38 - detective
	// 0.40 - blowgun darts
	// 0.41 - derringer
	// 0.72 - shotgun shell, 12ga
	// 1.57 - grenade shell, 40mm
	// 1.58 - RPG-7 (Tube is 40mm too, though warheads are usually larger in diameter.)

//What is our damage type
/*
kinetic - raw power
piercing - punches though things
slashing - cuts things
energy - energy
burning - hot
radioactive - rips apart cells or some shit
toxic - poisons
*/
	damage_type = D_KINETIC
// blood system damage type - DAMAGE_STAB, DAMAGE_CUT, DAMAGE_BLUNT
	hit_type = DAMAGE_CUT
	//With what % do we hit mobs laying down
	hit_ground_chance = 33
	//Can we pass windows
	window_pass = 0
	implanted = /obj/item/implant/projectile
	// we create this overlay on walls when we hit them
	impact_image_state = "bhole"

	hit_mob_sound = 'sound/impact_sounds/Flesh_Stab_2.ogg'

//Any special things when it hits shit?
	on_hit(atom/hit, direction, obj/projectile/P)
		if (ishuman(hit) && src.hit_type)
			if (hit_type != DAMAGE_BLUNT)
				take_bleeding_damage(hit, null, round(src.power / 3), src.hit_type) // oh god no why was the first var set to src what was I thinking
			hit.changeStatus("staggered", clamp(P.power/8, 5, 1) SECONDS)
		..()//uh, what the fuck, call your parent
		//return // BULLETS CANNOT BLEED, HAINE

//no caliber
/datum/projectile/bullet/staple
	name = "staple"
	power = 5
	damage_type = D_KINETIC // don't staple through armor
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/staple // HEH
	shot_sound = 'sound/impact_sounds/Generic_Snap_1.ogg'
	impact_image_state = "bhole-staple"
	casing = null

/datum/projectile/bullet/vbullet
	name = "virtual bullet"
	shot_sound = 'sound/weapons/Gunshot.ogg'
	power = 10
	cost = 1
	ks_ratio = 1
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	implanted = null
	casing = null
	impact_image_state = null

//0.22
/datum/projectile/bullet/bullet_22
	name = "bullet"
	power = 22
	shot_sound = 'sound/weapons/smallcaliber.ogg' //quieter when fired from a silenced weapon!
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/bullet_22
	casing = /obj/item/casing/small
	impact_image_state = "bhole-small"
	silentshot = 1 // It's supposed to be a stealth weapon, right (Convair880)?

/datum/projectile/bullet/bullet_22/smartgun
	shot_sound = 'sound/weapons/smartgun.ogg'
	shot_volume = 70
	silentshot = 0

/datum/projectile/bullet/bullet_22/HP
	power = 35
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/bullet_22HP

/datum/projectile/bullet/custom
	name = "bullet"
	power = 1
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/bullet_22
	casing = /obj/item/casing/small
	impact_image_state = "bhole-small"

//0.223
/datum/projectile/bullet/assault_rifle
	name = "bullet"
	shot_sound = 'sound/weapons/assrifle.ogg'  // todo: single shot sound?
	power = 45
	cost = 1
	ks_ratio = 1
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	shot_number = 1
	impact_image_state = "bhole-small"
	implanted = /obj/item/implant/projectile/bullet_308
	casing = /obj/item/casing/rifle

	armor_piercing
		damage_type = D_PIERCING
		hit_type = DAMAGE_STAB
		armor_ignored = 0.66

/datum/projectile/bullet/assault_rifle/burst
	sname = "burst fire"
	power = 45
	cost = 2
	shot_number = 2

	armor_piercing
		damage_type = D_PIERCING
		hit_type = DAMAGE_STAB
		armor_ignored = 0.66

//0.308
/datum/projectile/bullet/minigun
	name = "bullet"
	shot_sound = 'sound/weapons/minigunshot.ogg'
	power = 8
	cost = 10
	shot_number = 10
	shot_delay = 0.07 SECONDS
	dissipation_delay = 7
	ks_ratio = 1
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	impact_image_state = "bhole-small"
	implanted = /obj/item/implant/projectile/bullet_308
	casing = /obj/item/casing/rifle

/datum/projectile/bullet/minigun/turret
	power = 15
	dissipation_delay = 8

/datum/projectile/bullet/akm
	name = "bullet"
	shot_sound = 'sound/weapons/akm.ogg'
	power = 40  // BEFORE YOU TWEAK THESE VALUES: This projectile is also used by the Syndicate Ballistic Drone and Nukie NAS-T turret
	cost = 3
	ks_ratio = 1
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	shot_number = 3
	shot_delay = 120 MILLI SECONDS
	impact_image_state = "bhole-small"
	implanted = /obj/item/implant/projectile/bullet_308
	casing = /obj/item/casing/rifle

/datum/projectile/bullet/rifle_3006
	name = "bullet"
	power = 85
	damage_type = D_PIERCING
	armor_ignored = 0.66
	hit_type = DAMAGE_STAB
	implanted = /obj/item/implant/projectile/bullet_308
	shot_sound = 'sound/weapons/railgun.ogg'
	dissipation_delay = 10
	casing = /obj/item/casing/rifle_loud
	impact_image_state = "bhole-small"

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if(ishuman(hit))
			var/mob/living/carbon/human/M = hit
			if(proj.power > 40)
#ifdef USE_STAMINA_DISORIENT
				M.do_disorient(75, weakened = 40, stunned = 40, disorient = 60, remove_stamina_below_zero = 0)
#else
				M.changeStatus("stunned", 4 SECONDS)
				M.changeStatus("weakened", 3 SECONDS)
#endif
			if(proj.power > 80)
				var/turf/target = get_edge_target_turf(M, dirflag)
				M.throw_at(target, 2, 2, throw_type = THROW_GUNIMPACT)
		..()

/datum/projectile/bullet/rifle_762_NATO //like .308 but military
	name = "bullet"
	power = 70
	icon_state = "sniper_bullet"
	damage_type = D_PIERCING
	armor_ignored = 0.66
	hit_type = DAMAGE_STAB
	implanted = /obj/item/implant/projectile/bullet_308
	shot_sound = 'sound/weapons/railgun.ogg'
	dissipation_delay = 10
	dissipation_rate = 0 //70 damage AP at all-ranges is fine, come to think of it
	projectile_speed = 72
	max_range = 100
	casing = /obj/item/casing/rifle_loud
	impact_image_state = "bhole-small"
	on_launch(obj/projectile/O)
		O.AddComponent(/datum/component/sniper_wallpierce, 3, 20) //pierces 3 walls/lockers/doors/etc. Does not function on restriced Z, rwalls and blast doors use 2 pierces

	on_hit(atom/hit, dirflag, obj/projectile/P)
		if (ismob(hit))
			var/mob/M = hit
			if(ishuman(hit))
				var/mob/living/carbon/human/H = hit
				if(power > 40)
	#ifdef USE_STAMINA_DISORIENT
					H.do_disorient(50, weakened = 2 SECONDS, stunned = 2 SECONDS, disorient = 0, remove_stamina_below_zero = FALSE)
	#else
					H.changeStatus("stunned", 4 SECONDS)
					H.changeStatus("weakened", 3 SECONDS)
	#endif
			var/turf/target = get_edge_target_turf(hit, dirflag)
			M.throw_at(target, 1, 3, throw_type = THROW_GUNIMPACT)
		..()

/datum/projectile/bullet/tranq_dart
	name = "dart"
	power = 10
	icon_state = "tranqdart_red"
	damage_type = D_TOXIC
	hit_type = DAMAGE_BLUNT
	implanted = /obj/item/implant/projectile/body_visible/dart/tranq_dart_sleepy
	shot_sound = 'sound/effects/syringeproj.ogg'
	dissipation_delay = 10
	reagent_payload = "haloperidol"
	casing = /obj/item/casing/rifle

	syndicate
		reagent_payload = "sodium_thiopental" // HEH
		icon_state = "tranqdart_red_barbed"
		implanted = /obj/item/implant/projectile/body_visible/dart/tranq_dart_sleepy_barbed

		pistol
			casing = /obj/item/casing/small
			shot_sound = 'sound/weapons/tranq_pistol.ogg'
			shot_volume = 30
			silentshot = 1

	//haha gannets, fuck you I stole ur shit! - kyle
	law_giver
		sname = "knockout"
		casing = /obj/item/casing/small
		shot_sound = 'sound/weapons/tranq_pistol.ogg'

	anti_mutant
		reagent_payload = "mutadone" // HAH
		icon_state = "tranqdart_green"
		implanted = /obj/item/implant/projectile/body_visible/dart/tranq_dart_mutadone

/datum/projectile/bullet/lmg
	name = "bullet"
	sname = "8-shot burst"
	shot_sound = 'sound/weapons/minigunshot.ogg'
	power = 15
	cost = 8
	shot_number = 8
	shot_delay = 0.1 SECONDS
	dissipation_delay = 12
	ks_ratio = 1
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	impact_image_state = "bhole-small"
	implanted = /obj/item/implant/projectile/bullet_308
	casing = /obj/item/casing/rifle
	var/slow = 1

	on_hit(atom/hit, direction, obj/projectile/P)
		if(slow && ishuman(hit))
			var/mob/living/carbon/human/M = hit
			M.setStatus("slowed", 0.3 SECONDS, optional = 4)
			M.changeStatus("staggered", clamp(P.power/8, 5, 1) SECONDS)

	auto
		fullauto_valid = 1
		sname = "full auto"
		shot_volume = 66
		cost = 1
		shot_number = 1

/datum/projectile/bullet/lmg/weak
	power = 1
	cost = 2
	shot_number = 16
	shot_delay = 0.07 SECONDS
	dissipation_delay = 8
	silentshot = 1
	slow = 0
	implanted = null

//9mm/0.355
/datum/projectile/bullet/bullet_9mm
	name = "bullet"
	power = 30
	shot_sound = 'sound/weapons/smg_shot.ogg'
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/bullet_22
	casing = /obj/item/casing/small
	impact_image_state = "bhole-small"

	smg
		power = 20
		cost = 3
		shot_number = 3


/datum/projectile/bullet/nine_mm_NATO
	name = "bullet"
	shot_sound = 'sound/weapons/9x19NATO.ogg'
	power = 6
	ks_ratio = 0.9
	hit_ground_chance = 75
	dissipation_rate = 2
	dissipation_delay = 8
	projectile_speed = 48
	impact_image_state = "bhole-small"
	hit_type = DAMAGE_BLUNT
	implanted = /obj/item/implant/projectile/ninemmplastic
	casing = /obj/item/casing/small

	on_hit(atom/hit)
		..()
		if(ishuman(hit))
			var/mob/living/carbon/human/M = hit
			if(M.getStatusDuration("slowed") < 2.5 SECONDS)
				M.changeStatus("slowed", 1 SECOND, optional = 2)

/datum/projectile/bullet/nine_mm_NATO/burst
	shot_number = 3
	cost = 3
	sname = "burst fire"

/datum/projectile/bullet/nine_mm_NATO/auto
	fullauto_valid = 1
	shot_number = 1
	cost = 1
	shot_volume = 66
	sname = "full auto"

/datum/projectile/bullet/nine_mm_soviet
	name = "bullet"
	shot_sound = 'sound/weapons/smg_shot.ogg'
	power = 15
	impact_image_state = "bhole-small"
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/bullet_9mm
	casing = /obj/item/casing/small

//medic primary
/datum/projectile/bullet/veritate
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

/datum/projectile/bullet/veritate/burst
	sname = "burst fire"
	power = 15
	cost = 3
	shot_number = 3


//0.357
/datum/projectile/bullet/revolver_357
	name = "bullet"
	power = 60 // okay this can be made worse again now that crit isn't naptime
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/bullet_357
	impact_image_state = "bhole-small"
	casing = /obj/item/casing/medium

/datum/projectile/bullet/revolver_357/AP
	power = 50
	damage_type = D_PIERCING
	armor_ignored = 0.66
	hit_type = DAMAGE_STAB
	implanted = /obj/item/implant/projectile/bullet_357AP

/*
/datum/projectile/bullet/revolver_357/AP
	power = 50
	damage_type = D_PIERCING
	armor_ignored = 0.66
	hit_type = DAMAGE_STAB
	implanted = /obj/item/implant/projectile/bullet_357AP
*/
//0.38
/datum/projectile/bullet/revolver_38
	name = "bullet"
	sname = "execute"
	power = 35
	ks_ratio = 1
	implanted = /obj/item/implant/projectile/bullet_38
	impact_image_state = "bhole-small"
	casing = /obj/item/casing/medium

/datum/projectile/bullet/revolver_38/lb
	shot_sound = 'sound/weapons/lb_execute.ogg'

/datum/projectile/bullet/revolver_38/AP//traitor det revolver
	power = 35
	implanted = /obj/item/implant/projectile/bullet_38AP
	damage_type = D_PIERCING
	armor_ignored = 0.66
	hit_type = DAMAGE_STAB

/datum/projectile/bullet/revolver_38/stunners//energy bullet things so he can actually stun something
	name = "stun bullet"
	power = 20
	ks_ratio = 0
	dissipation_delay = 6 //One more tick before falloff begins
	damage_type = D_ENERGY // FUCK YOU.
	ie_type = "T"
	hit_type = null
	impact_image_state = null // stun bullets shouldn't actually enter walls should they?

	/* this is now handled in the projectile parent on_hit for all ks_ratio 0.0 weapons.
	on_hit(atom/hit) // adding this so these work like taser shots I guess, if this sucks feel free to remove it
		if (ishuman(hit))
			var/mob/living/carbon/human/H = hit
			H.changeStatus("slowed", power)
			H.change_misstep_chance(5)
			H.emote("twitch_v")
			if (H.getStatusDuration("slowed") > power)
				H.changeStatus("stunned", power)
		return*/

//0.393
/datum/projectile/bullet/foamdart
	name = "foam dart"
	sname = "foam dart"
	icon_state = "foamdart"
	shot_sound = 'sound/effects/syringeproj.ogg'
	impact_image_state = null
	projectile_speed = 26
	implanted = null
	power = 0
	ks_ratio = 0
	damage_type = D_SPECIAL
	hit_type = DAMAGE_BLUNT
	max_range = 15
	dissipation_rate = 0
	ie_type = null

	on_hit(atom/hit, direction, obj/projectile/P)
		..()
		drop_as_ammo(P)

	on_max_range_die(obj/projectile/P)
		..()
		drop_as_ammo(P)

	proc/drop_as_ammo(obj/projectile/P)
		var/turf/T = get_turf(P)
		if(T)
			var/obj/item/ammo/bullets/foamdarts/ammo_dropped = new /obj/item/ammo/bullets/foamdarts (T)
			ammo_dropped.amount_left = 1
			ammo_dropped.UpdateIcon()
			ammo_dropped.pixel_x += rand(-12,12)
			ammo_dropped.pixel_y += rand(-12,12)

//0.40
/datum/projectile/bullet/blow_dart
	name = "poison dart"
	power = 5
	icon_state = "blowdart"
	damage_type = D_TOXIC
	hit_type = DAMAGE_STAB
	dissipation_delay = 10
	implanted = "blowdart"
	shot_sound = 'sound/effects/syringeproj.ogg'
	silentshot = 1
	casing = null
	reagent_payload = "curare"

	madness
		reagent_payload = "madness_toxin"

	ls_bee
		reagent_payload = "lsd_bee"

//0.41
/datum/projectile/bullet/derringer
	name = "bullet"
	shot_sound = 'sound/weapons/derringer.ogg'
	power = 120
	dissipation_delay = 1
	dissipation_rate = 50
	damage_type = D_PIERCING
	armor_ignored = 0.66
	hit_type = DAMAGE_STAB
	hit_ground_chance = 100
	implanted = /obj/item/implant/projectile/bullet_41
	ks_ratio = 0.66
	impact_image_state = "bhole"
	casing = /obj/item/casing/derringer

//0.45
/datum/projectile/bullet/revolver_45
	name = "bullet"
	power = 35
	ks_ratio = 1
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/bullet_45
	impact_image_state = "bhole-small"
	casing = /obj/item/casing/medium

//0.58
/datum/projectile/bullet/flintlock
	name = "bullet"
	power = 100
	damage_type = D_PIERCING
	armor_ignored = 0.66
	hit_type = DAMAGE_STAB
	implanted = /obj/item/implant/projectile/flintlock
	shot_sound = 'sound/weapons/flintlock.ogg'
	dissipation_delay = 10
	casing = null
	impact_image_state = "bhole-small"

	on_hit(atom/hit, dirflag)
		if(ishuman(hit))
			var/mob/living/carbon/human/M = hit
			if(power > 40)
#ifdef USE_STAMINA_DISORIENT
				M.do_disorient(75, weakened = 40, stunned = 40, disorient = 60, remove_stamina_below_zero = 0)
#else
				M.changeStatus("stunned", 4 SECONDS)
				M.changeStatus("weakened", 3 SECONDS)
#endif
			if(power > 80)
				var/turf/target = get_edge_target_turf(M, dirflag)
				M.throw_at(target, 2, 2, throw_type = THROW_GUNIMPACT)
		..()

//0.72
/datum/projectile/bullet/a12
	name = "buckshot"
	icon_state = "buckshot"
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	power = 70
	ks_ratio = 1
	dissipation_delay = 2//2
	dissipation_rate = 10
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	impact_image_state = "bhole"
	hit_ground_chance = 100
	implanted = /obj/item/implant/projectile/bullet_12ga
	casing = /obj/item/casing/shotgun/red

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if (ishuman(hit))
			var/mob/living/carbon/human/M = hit
			if(proj.power >= 30)
				M.do_disorient(75, weakened = 50, stunned = 50, disorient = 30, remove_stamina_below_zero = 0)

			if(proj.power >= 40)
				var/throw_range = (proj.power > 50) ? 6 : 3
				var/turf/target = get_edge_target_turf(M, dirflag)
				if(!M.stat) M.emote("scream")
				M.throw_at(target, throw_range, 1, throw_type = THROW_GUNIMPACT)
				M.update_canmove()
			if (M.organHolder)
				var/targetorgan
				for (var/i in 1 to (power/10)-2) //targets 5 organs for strong, 3 for weak
					targetorgan = pick("left_lung", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix", "tail")
					M.organHolder.damage_organ(proj.power/M.get_ranged_protection(), 0, 0, prob(5) ? "heart" : targetorgan) //5% chance to hit the heart

			if(prob(proj.power/4) && power > 50) //only for strong. Lowish chance
				M.sever_limb(pick("l_arm","r_arm","l_leg","r_leg"))
			..()

	weak
		power = 50 //can have a little throwing, as a treat

/datum/projectile/bullet/flak_chunk
	name = "flak chunk"
	sname = "flak chunk"
	icon_state = "trace"
	shot_sound = null
	power = 12
	dissipation_rate = 5
	dissipation_delay = 8
	damage_type = D_KINETIC

/datum/projectile/bullet/stinger_ball
	name = "rubber ball"
	sname = "rubber ball"
	icon_state = "rubberball"
	implanted = /obj/item/implant/projectile/stinger_ball
	shot_sound = null
	power = 12
	dissipation_rate = 5
	dissipation_delay = 8
	damage_type = D_KINETIC

/datum/projectile/bullet/grenade_fragment
	name = "grenade fragment"
	sname = "grenade fragment"
	icon_state = "grenadefragment"
	implanted = /obj/item/implant/projectile/grenade_fragment
	shot_sound = null
	power = 12
	dissipation_rate = 5
	dissipation_delay = 8
	damage_type = D_KINETIC

/datum/projectile/bullet/buckshot // buckshot pellets generates by shotguns
	name = "buckshot"
	sname = "buckshot"
	icon_state = "trace"
	power = 6
	dissipation_rate = 5
	dissipation_delay = 3
	damage_type = D_KINETIC

/datum/projectile/bullet/nails
	name = "nails"
	sname = "nails"
	icon_state = "trace"
	power = 4
	dissipation_rate = 3
	dissipation_delay = 4
	damage_type = D_SLASHING
	casing = /obj/item/casing/shotgun/gray

//for makeshift shotgun shells- don't ever use these directly, use the spreader projectiles in special.dm

/datum/projectile/bullet/improvplasglass
	name = "plasmaglass fragments"
	sname = "plasmaglass fragments"
	icon_state = "plasglass"
	dissipation_delay = 3
	dissipation_rate = 2
	damage_type = D_PIERCING
	armor_ignored = 0.66
	implanted = null
	power = 6

/datum/projectile/bullet/improvglass
	name = "glass"
	sname = "glass"
	icon_state = "glass"
	dissipation_delay = 2
	dissipation_rate = 2
	implanted = null
	power = 4

/datum/projectile/bullet/improvscrap
	name = "fragments"
	sname = "fragments"
	icon_state = "trace"
	dissipation_delay = 4
	dissipation_rate = 1
	implanted = /obj/item/implant/projectile/shrapnel
	power = 8

/datum/projectile/bullet/aex
	name = "explosive slug"
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	power = 25 // the damage should be more from the explosion
	ks_ratio = 1
	dissipation_delay = 6
	dissipation_rate = 10
	implanted = null
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	impact_image_state = "bhole"
	casing = /obj/item/casing/shotgun/orange

	on_hit(atom/hit)
		explosion_new(null, get_turf(hit), 2)

	on_max_range_die(obj/projectile/O)
		explosion_new(null, get_turf(O), 2)

	lawbringer
		name = "lawbringer"
		sname = "bigshot"
		power = 1
		cost = 150

		on_hit(atom/hit)
			explosion_new(null, get_turf(hit), 4)

		on_max_range_die(obj/projectile/O)
			explosion_new(null, get_turf(O), 4)

/datum/projectile/bullet/abg
	name = "rubber slug"
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	power = 24
	ks_ratio = 0.2
	dissipation_rate = 4
	dissipation_delay = 3
	implanted = null
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	impact_image_state = "bhole"
	casing = /obj/item/casing/shotgun/blue

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if (ishuman(hit))
			var/mob/living/carbon/human/M = hit
			if(proj.power >= 16)
				var/throw_range = (proj.power > 20) ? 5 : 3

				var/turf/target = get_edge_target_turf(M, dirflag)
				if(!M.stat) M.emote("scream")
				M.throw_at(target, throw_range, 1, throw_type = THROW_GUNIMPACT)
				M.update_canmove()
			hit.changeStatus("staggered", clamp(proj.power/8, 5, 1) SECONDS)
			//if (src.hit_type)
			// impact_image_effect("K", hit)
				//take_bleeding_damage(hit, null, round(src.power / 3), src.hit_type)

/datum/projectile/bullet/cryo
	name = "cryogenic slug"
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	power = 10
	ks_ratio = 1
	dissipation_rate = 2
	dissipation_delay = 1
	implanted = null
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	impact_image_state = null
	casing = /obj/item/casing/shotgun/blue

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		. = ..()
		if(isliving(hit))
			var/mob/living/L = hit
			L.bodytemperature = max(50, L.bodytemperature - proj.power * 5)
			if(L.getStatusDuration("shivering" < power))
				L.setStatus("shivering", power/2 SECONDS)
			var/obj/icecube/I = new/obj/icecube(get_turf(L), L)
			I.health = proj.power / 2

/datum/projectile/bullet/saltshot_pellet
	name = "rock salt"
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	icon_state = "trace"
	power = 3
	ks_ratio = 1
	dissipation_rate = 1
	dissipation_delay = 2
	implanted = null
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	impact_image_state = "bhole"
	casing = /obj/item/casing/shotgun/gray

	on_hit(atom/hit, direction, obj/projectile/P)
		. = ..()
		if(isliving(hit))
			var/mob/living/L = hit
			if(!ON_COOLDOWN(L, "saltshot_scream", 1 SECOND))
				L.emote("scream")
			L.take_eye_damage(P.power / 2)
			L.change_eye_blurry(P.power, 40)
			L.setStatus("salted", 15 SECONDS, P.power * 2)

/datum/projectile/special/spreader/buckshot_burst/salt
	name = "rock salt"
	sname = "rock salt"
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	power = 20
	implanted = null
	casing = /obj/item/casing/shotgun/gray
	spread_projectile_type = /datum/projectile/bullet/saltshot_pellet
	speed_min = 28
	speed_max = 36
	dissipation_variance = 64
	spread_angle_variance = 7.5
	pellets_to_fire = 4

/datum/projectile/bullet/flare
	name = "flare"
	sname = "hotshot"
	shot_sound = 'sound/weapons/flaregun.ogg'
	power = 20
	cost = 1
	ks_ratio = 1
	damage_type = D_BURNING
	hit_type = null
	brightness = 1
	color_red = 1
	color_green = 0.3
	color_blue = 0
	icon_state = "flare"
	implanted = null
	impact_image_state = "bhole"
	casing = /obj/item/casing/shotgun/orange

	on_hit(atom/hit, direction, obj/projectile/P)
		if (isliving(hit))
			fireflash(get_turf(hit), 0)
			hit.changeStatus("staggered", clamp(P.power/8, 5, 1) SECONDS)
		else if (isturf(hit))
			fireflash(hit, 0)
		else
			fireflash(get_turf(hit), 0)

/datum/projectile/bullet/flare/UFO
	name = "heat beam"
	window_pass = 1
	icon_state = "plasma"
	casing = null

//0.787
/datum/projectile/bullet/cannon // autocannon should probably be renamed next
	name = "cannon round"
	brightness = 0.7
	window_pass = 0
	icon_state = "20mmAPHE"
	damage_type = D_PIERCING
	armor_ignored = 0.66
	hit_type = DAMAGE_CUT
	power = 150
	dissipation_delay = 1
	dissipation_rate = 5
	cost = 1
	shot_sound = 'sound/weapons/20mm.ogg'
	shot_volume = 130
	implanted = null

	ks_ratio = 1
	impact_image_state = "bhole-large"
	casing = /obj/item/casing/cannon
	pierces = 4
	shot_sound_extrarange = 1



	on_launch(obj/projectile/proj)
		proj.AddComponent(/datum/component/sniper_wallpierce, 4) //pierces 4 walls/lockers/doors/etc. Does not function on restricted Z, rwalls and blast doors use 2 pierces
		for(var/mob/M in range(proj.loc, 5))
			shake_camera(M, 3, 8)

	on_hit(atom/hit, dirflag, obj/projectile/proj)

		..()

		SPAWN(0)
			//hit.setTexture()

			var/turf/T = get_turf(hit)
			new /obj/effects/rendersparks (T)
			var/impact = clamp(1,3, proj.pierces_left % 4)
			if(proj.pierces_left <= 1 )
				new /obj/effects/explosion/dangerous(T)
				new /obj/effects/explosion/dangerous(get_step(T, dirflag))
				new /obj/effects/explosion/dangerous(get_step(get_step(T, dirflag), dirflag))
				proj.die()
				return

			if(hit && ismob(hit))
				var/mob/living/M = hit
				var/throw_range = 10
				var/turf/target = get_edge_target_turf(M, dirflag)
				if(!M.stat)
					M.emote("scream")
				M.throw_at(target, throw_range, 2, throw_type = THROW_GUNIMPACT)

				if (ishuman(M) && M.organHolder)
					var/mob/living/carbon/human/H = M
					var/targetorgan
					for (var/i in 1 to 3)
						targetorgan = pick("left_lung", "heart", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix", "tail")
						H.organHolder.damage_organ(proj.power/H.get_ranged_protection(), 0, 0,  targetorgan)
				M.ex_act(impact)



			if(hit && isobj(hit))
				var/obj/O = hit
				O.throw_shrapnel(T, 1, 1)

				if(istype(hit, /obj/machinery/door))
					var/obj/machinery/door/D = hit
					if(!D.cant_emag)
						D.take_damage(D.health) //fuck up doors without needing ex_act(1)

				else if(istype(hit, /obj/window))
					var/obj/window/W = hit
					W.smash()

				else
					O.ex_act(impact)

			if(hit && isturf(hit))
				T.throw_shrapnel(T, 1, 1)
				T.ex_act(2)

//1.0
/datum/projectile/bullet/rod // for the coilgun
	name = "metal rod"
	power = 50
	damage_type = D_KINETIC
	hit_type = DAMAGE_STAB
	window_pass = 0
	icon_state = "rod_1"
	dissipation_delay = 25
	shot_sound = 'sound/weapons/ACgun2.ogg'
	casing = null
	impact_image_state = "bhole-large"

	on_hit(atom/hit)
		explosion_new(null, get_turf(hit), 5)

//1.57
datum/projectile/bullet/autocannon
	name = "HE grenade"
	window_pass = 0
	icon_state = "40mm_lethal"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	power = 25
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/rocket.ogg'
	ks_ratio = 1
	impact_image_state = "bhole-large"
	casing = /obj/item/casing/grenade

	on_hit(atom/hit)
		explosion_new(null, get_turf(hit), 12)

	knocker
		name = "breaching round"
		power = 10
		on_hit(atom/hit)
			if(istype(hit , /obj/machinery/door))
				var/obj/machinery/door/D = hit
				if(!D.cant_emag)
					D.take_damage(D.health/2) //fuck up doors without needing ex_act(1)
			explosion_new(null, get_turf(hit), 4, 1.75)

	plasma_orb
		name = "fusion orb"
		damage_type = D_BURNING
		hit_type = null
		icon_state = "fusionorb"
		implanted = null
		brightness = 0.8
		color_red = 1
		color_green = 0.6
		color_blue = 0.2
		power = 50
		shot_sound = 'sound/machines/engine_alert3.ogg'
		impact_image_state = null
		casing = null

	huge
		icon_state = "400mm"
		power = 100
		impact_image_state = "bhole-large"

		on_hit(atom/hit)
			explosion_new(null, get_turf(hit), 80)


	seeker
		name = "drone-seeking grenade"
		power = 50 //even if they don't explode, you FEEL this one
		var/max_turn_rate = 20
		var/type_to_seek = /obj/critter/gunbot/drone //what are we going to seek
		precalculated = 0
		disruption = INFINITY //disrupt every system at once
		on_hit(atom/hit, angle, var/obj/projectile/P)
			if (P.data)
				..()
			else
				new /obj/effects/rendersparks(hit.loc)
				if(ishuman(hit))//copypasted shamelessly from singbuster rockets
					var/mob/living/carbon/human/M = hit
					boutput(M, "<span class='alert'>You are struck by an autocannon round! Thankfully it was not armed.</span>")
					M.do_disorient(stunned = 40)
					if (!M.stat)
						M.emote("scream")


		on_launch(var/obj/projectile/P)
			var/D = locate(type_to_seek) in range(15, P)
			if (D)
				P.data = D

		tick(var/obj/projectile/P)
			if (!P)
				return
			if (!P.loc)
				return
			if (!P.data)
				return
			var/obj/D = P.data
			if (!istype(D))
				return
			var/turf/T = get_turf(D)
			var/turf/S = get_turf(P)

			if (!T || !S)
				return

			var/STx = T.x - S.x
			var/STy = T.y - S.y
			var/STlen = STx * STx + STy * STy
			if (!STlen)
				return
			STlen = sqrt(STlen)
			STx /= STlen
			STy /= STlen
			var/dot = STx * P.xo + STy * P.yo
			var/det = STx * P.yo - STy * P.xo
			var/sign = -1
			if (det <= 0)
				sign = 1

			var/relang = arccos(dot)
			P.rotateDirection(clamp(max_turn_rate, -max_turn_rate, sign * relang))

		pod_seeking
			name = "pod-seeking grenade"
			type_to_seek = /obj/machinery/vehicle
			on_hit(atom/hit)
				. = ..()
				if(istype(hit, /obj/machinery/vehicle))
					var/obj/machinery/vehicle/V = hit
					V.health -= V.maxhealth / 4 //a little extra punch in the face

		ghost
			name = "pod-seeking grenade"
			type_to_seek = /mob/dead/observer

/datum/projectile/bullet/grenade_round
	name = "40mm round"
	window_pass = 0
	icon_state = "40mm_lethal"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	power = 5
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/launcher.ogg'
	ks_ratio = 1
	impact_image_state = "bhole-large"
	casing = /obj/item/casing/grenade

	explosive
		name = "40mm HEDP round"

		on_hit(atom/hit)
			explosion_new(null, get_turf(hit), 2.5, 1.75)

	high_explosive //more powerful than HEDP
		name = "40mm HE round"
		power = 10

		on_hit(atom/hit)
			explosion_new(null,get_turf(hit), 8, 0.75)

/datum/projectile/bullet/smoke
	name = "smoke grenade"
	sname = "smokeshot"
	window_pass = 0
	icon_state = "40mm_smoke"
	damage_type = D_KINETIC
	power = 25
	dissipation_delay = 10
	cost = 1
	shot_sound = 'sound/weapons/launcher.ogg'
	ks_ratio = 1
	impact_image_state = "bhole-large"
	casing = /obj/item/casing/grenade
	implanted = null

	var/list/smokeLocs = list()
	var/smokeLength = 100

	proc/startSmoke(atom/hit, dirflag, atom/projectile)
		/*var/turf/trgloc = get_turf(projectile)
		var/list/affected = block(locate(trgloc.x - 3,trgloc.y - 3,trgloc.z), locate(trgloc.x + 3,trgloc.y + 3,trgloc.z))
		if(!affected.len) return
		var/list/centerview = view(world.view, trgloc)
		for(var/atom/A in affected)
			if(!(A in centerview)) continue
			var/obj/smokeDummy/D = new(A)
			smokeLocs.Add(D)
			SPAWN(smokeLength) qdel(D)
		particleMaster.SpawnSystem(new/datum/particleSystem/areaSmoke("#ffffff", smokeLength, trgloc))
		return*/

		// I'm so tired of overlays freezing my client, sorry. Get rid of the old smoke call here once
		// the performance and issues of full-screen overlays have been resolved, I guess (Convair880).
		var/turf/T = get_turf(projectile)
		if (T && isturf(T))
			var/datum/effects/system/bad_smoke_spread/S = new /datum/effects/system/bad_smoke_spread/(T)
			if (S)
				S.set_up(20, 0, T)
				S.start()
		return

	on_hit(atom/hit, dirflag, atom/projectile)
		startSmoke(hit, dirflag, projectile)
		return

/datum/projectile/bullet/marker
	name = "marker grenade"
	sname = "paint"
	window_pass = 0
	icon_state = "40mm_paint"
	damage_type = D_KINETIC
	power = 15
	dissipation_delay = 10
	cost = 1
	shot_sound = 'sound/weapons/launcher.ogg'
	ks_ratio = 1
	impact_image_state = "bhole-large"
	casing = /obj/item/casing/grenade
	hit_type = DAMAGE_BLUNT
	hit_mob_sound = 'sound/misc/splash_1.ogg'
	hit_object_sound = 'sound/misc/splash_1.ogg'
	implanted = null


	on_hit(atom/hit, dirflag, atom/projectile)
		..()
		hit.setStatus("marker_painted", 30 SECONDS)

/datum/projectile/bullet/pbr //direct less-lethal 40mm option
	name = "plastic baton round"
	icon_state = "40mm_nonlethal"
	shot_sound = 'sound/weapons/launcher.ogg'
	power = 50
	ks_ratio = 0.5
	dissipation_rate = 5
	dissipation_delay = 4
	max_range = 9
	implanted = null
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	impact_image_state = "bhole-large"
	casing = /obj/item/casing/grenade
	ie_type = null

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if (ishuman(hit))
			var/mob/living/carbon/human/M = hit
			if(proj.power >= 20)
				var/throw_range = (proj.power > 30) ? 5 : 3

				var/turf/target = get_edge_target_turf(M, dirflag)
				if(!M.stat) M.emote("scream")
				M.changeStatus("stunned", 1 SECONDS)
				M.changeStatus("weakened", 2 SECONDS)
				M.throw_at(target, throw_range, 1, throw_type = THROW_GUNIMPACT)
				M.update_canmove()
			hit.changeStatus("staggered", clamp(proj.power/8, 5, 1) SECONDS)
		if(!ismob(hit))
			shot_volume = 0
			var/obj/projectile/P = shoot_reflected_bounce(proj, hit, 1, PROJ_NO_HEADON_BOUNCE)
			shot_volume = 100
			if(P)
				P.travelled = max(proj.travelled, (max_range-2) * 32)

/datum/projectile/bullet/grenade_shell
	name = "40mm grenade conversion shell"
	window_pass = 0
	icon_state = "40mm_lethal"
	damage_type = D_KINETIC
	power = 25
	dissipation_delay = 20
	cost = 1
	shot_sound = 'sound/weapons/launcher.ogg'
	ks_ratio = 1
	impact_image_state = "bhole-large"
	casing = /obj/item/casing/grenade
	implanted = null

	var/has_grenade = 0
	var/obj/item/chem_grenade/CHEM = null
	var/obj/item/old_grenade/OLD = null
	var/has_det = 0 //have we detonated a grenade yet?

	proc/get_nade()
		RETURN_TYPE(/obj/item)
		if (src.has_grenade != 0)
			if (src.CHEM != null)
				return src.CHEM
			else if (src.OLD != null)
				return src.OLD
			else
				return null
		else
			return null

	proc/load_nade(var/obj/item/W)
		if (W)
			if (src.has_grenade == 0)
				if (istype(W,/obj/item/chem_grenade))
					src.CHEM = W
					src.has_grenade = 1
					return 1
				else if (istype(W, /obj/item/old_grenade))
					src.OLD = W
					src.has_grenade = 1
					return 1
				else
					return 0
			else
				return 0
		else
			return 0

	proc/unload_nade(var/turf/T)
		if (src.has_grenade !=0)
			if (src.CHEM != null)
				if (T)
					src.CHEM.set_loc(T)
				src.CHEM = null
				src.has_grenade = 0
				return 1
			else if (src.OLD != null)
				if (T)
					src.OLD.set_loc(T)
				src.OLD = null
				src.has_grenade = 0
				return 1
			else //how did this happen?
				return 0
		else
			return 0

	proc/det(var/turf/T)
		if (T && src.has_det == 0 && src.has_grenade != 0)
			if (src.CHEM != null)
				var/obj/item/chem_grenade/C = SEMI_DEEP_COPY(CHEM)
				C.set_loc(T)
				src.has_det = 1
				SPAWN(1 DECI SECOND)
					C.explode()
				return
			else if (src.OLD != null)
				var/obj/item/old_grenade/O = SEMI_DEEP_COPY(OLD)
				O.set_loc(T)
				src.has_det = 1
				SPAWN(1 DECI SECOND)
					O.prime()
				return
			else //what the hell happened
				return
		else
			return

	on_hit(atom/hit, angle, obj/projectile/O)
		var/turf/T = get_turf(hit)
		if (T)
			src.det(T)
		else if (O)
			var/turf/pT = get_turf(O)
			if (pT)
				src.det(pT)
		return ..()

	on_end(obj/projectile/O)
		if (O && src.has_det == 0)
			var/turf/T = get_turf(O)
			if (T)
				src.det(T)
		else if (O)
			src.has_det = 0


//1.58
// Ported from old, non-gun RPG-7 object class (Convair880).
/datum/projectile/bullet/rpg
	name = "MPRT rocket"
	window_pass = 0
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "rpg_rocket"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	power = 40
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/rocket.ogg'
	ks_ratio = 1
	impact_image_state = "bhole-large"

	on_hit(atom/hit)
		var/turf/T = get_turf(hit)
		if (T)
			for (var/mob/living/carbon/human/M in view(hit, 2))
				M.TakeDamage("chest", 15/M.get_ranged_protection(), 0)
				if (M.get_ranged_protection()>=1.5)
					boutput(M, "<span class='alert'>Your armor blocks the shrapnel!</span>")
				else
					var/obj/item/implant/projectile/shrapnel/implanted = new /obj/item/implant/projectile/shrapnel(M)
					implanted.owner = M
					M.implant += implanted
					implanted.implanted(M, null, 2)
					boutput(M, "<span class='alert'>You are struck by shrapnel!</span>")
					if (!M.stat)
						M.emote("scream")

			T.hotspot_expose(700,125)
			explosion_new(null, T, 36, 0.45)
		return

/datum/projectile/bullet/homing
    var/min_speed = 0
    var/max_speed = 2
    var/start_speed = 2
    var/easemult = 0.

    var/auto_find_targets = 1
    var/homing_active = 1

    var/desired_x = 0
    var/desired_y = 0

    var/rotate_proj = 1
    var/face_desired_dir = 0

    precalculated = FALSE

    on_launch(var/obj/projectile/P)
        ..()
        P.internal_speed = start_speed

        if (auto_find_targets)
            P.targets = list()
            for(var/mob/M in view(P,15))
                if (M == P.shooter) continue
                P.targets += M

    proc/calc_desired_x_y(var/obj/projectile/P)
        .= 0
        if (P.targets && P.targets.len && P.targets[1])
            var/atom/closest = P.targets[1]

            for (var/atom in P.targets)
                var/atom/A = atom
                if (A.disposed)
                    P.targets -= A
                if (GET_DIST(P,A) < GET_DIST(P,closest))
                    closest = A

            desired_x = closest.x - P.x - P.pixel_x/32
            desired_y = closest.y - P.y - P.pixel_y/32

            .= 1

    tick(var/obj/projectile/P)
        if (!P || !src.homing_active)
            return

        desired_x = 0
        desired_y = 0
        if (calc_desired_x_y(P))
            var/magnitude = vector_magnitude(desired_x,desired_y)
            if (magnitude != 0)
                var/angle_diff = arctan(desired_y, desired_x) - arctan(P.yo, P.xo)
                if (angle_diff > 180)
                    angle_diff -= 360
                else if (angle_diff < -180)
                    angle_diff += 360
                angle_diff = -clamp(angle_diff, -1, 1)
                P.rotateDirection(angle_diff)

        ..()

/datum/projectile/bullet/homing/mrl
	name = "MRL rocket"
	window_pass = 0
	icon = 'icons/obj/projectiles.dmi'
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	dissipation_delay = 30
	shot_sound = 'sound/weapons/rocket.ogg'
	ks_ratio = 1
	impact_image_state = "bhole-large"
	shot_number = 1
	cost = 1
	power = 15
	icon_state = "mininuke"
	max_speed = 10
	start_speed = 10
	shot_delay = 1 SECONDS

	on_hit(atom/hit)
		var/turf/T = get_turf(hit)
		if (T)
			for (var/mob/living/carbon/human/M in view(hit, 2))
				M.TakeDamage("chest", 15/M.get_ranged_protection(), 0)
				if (M.get_ranged_protection()>=1.5)
					boutput(M, "<span class='alert'>Your armor blocks the shrapnel!</span>")
				else
					var/obj/item/implant/projectile/shrapnel/implanted = new /obj/item/implant/projectile/shrapnel(M)
					implanted.owner = M
					M.implant += implanted
					implanted.implanted(M, null, 2)
					boutput(M, "<span class='alert'>You are struck by shrapnel!</span>")
					if (!M.stat)
						M.emote("scream")

			T.hotspot_expose(700,125)
			explosion_new(null, T, 15, 0.45)
		return

/datum/projectile/bullet/antisingularity
	name = "Singularity buster rocket"
	window_pass = 0
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "regrocket"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	power = 5
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/rocket.ogg'
	ks_ratio = 1
	impact_image_state = "bhole-large"
	implanted = null

	on_hit(atom/hit)
		var/obj/machinery/the_singularity/S = hit
		if(istype(S))
			new /obj/bhole(S.loc,rand(100,300))
			qdel(S)
		else
			new /obj/effects/rendersparks(hit.loc)
			if(ishuman(hit))
				var/mob/living/carbon/human/M = hit
				M.TakeDamage("chest", 15/M.get_ranged_protection(), 0)
				boutput(M, "<span class='alert'>You are struck by a big rocket! Thankfully it was not the exploding kind.</span>")
				M.do_disorient(stunned = 40)
				if (!M.stat)
					M.emote("scream")

/datum/projectile/bullet/mininuke //Assday only.
	name = "miniature nuclear warhead"
	window_pass = 0
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "mininuke"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	power = 120
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/rocket.ogg'
	ks_ratio = 1
	impact_image_state = "bhole-large"
	implanted = null

	on_hit(atom/hit)
		var/turf/T = get_turf(hit)
		if (T)
			T.hotspot_expose(700,125)
			explosion_new(null, T, 300, 1)
		return


//3.0 the gungun/briefcase of guns is in a different file.
//4.6
/datum/projectile/bullet/airzooka
	name = "airburst"
	shot_sound = 'sound/weapons/airzooka.ogg'
	power = 0
	ks_ratio = 1
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "crescent_white"
	dissipation_delay = 15
	dissipation_rate = 2
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	impact_image_state = "bhole"
	implanted = null
	casing = null
	cost = 1

	on_hit(atom/hit, dirflag)
		if (ishuman(hit))
			var/mob/living/carbon/human/M = hit
			var/turf/target = get_edge_target_turf(M, dirflag)
			if(!M.stat) M.emote("scream")
			M.do_disorient(15, weakened = 10)
			M.throw_at(target, 6, 3, throw_type = THROW_GUNIMPACT)

/datum/projectile/bullet/airzooka/bad
	name = "plasmaburst"
	shot_sound = 'sound/weapons/airzooka.ogg'
	power = 15
	ks_ratio = 1
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "40mmgatling"
	dissipation_delay = 15
	dissipation_rate = 4
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	impact_image_state = "bhole"
	implanted = null
	casing = null
	cost = 2

	on_hit(atom/hit, dirflag)
		fireflash(get_turf(hit), 1)
		if (ishuman(hit))
			var/mob/living/carbon/human/M = hit
			var/turf/target = get_edge_target_turf(M, dirflag)
			if(!M.stat) M.emote("scream")
			M.do_disorient(15, weakened = 25)
			M.throw_at(target, 12, 3, throw_type = THROW_GUNIMPACT)

//misc (i dont know where to place the rest)- owari
/datum/projectile/bullet/shrapnel // for explosions
	name = "shrapnel"
	power = 10
	damage_type = D_PIERCING
	armor_ignored = 0.66
	hit_type = DAMAGE_CUT
	window_pass = 0
	icon = 'icons/obj/scrap.dmi'
	icon_state = "2metal0"
	casing = null
	impact_image_state = "bhole-staple"

/datum/projectile/bullet/howitzer
	name = "howitzer round"
	brightness = 0.7
	window_pass = 0
	icon = 'icons/obj/large/bigprojectiles.dmi'
	icon_state = "152mm-shot"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	power = 400
	dissipation_delay = 300
	dissipation_rate = 5
	cost = 1
	shot_sound = 'sound/effects/explosion_new2.ogg'
	shot_volume = 90
	implanted = null

	ks_ratio = 0.5
	impact_image_state = "bhole-large"
	casing = /obj/item/casing/cannon
	shot_sound_extrarange = 1

	on_hit(atom/hit)
		for(var/turf/T in range(get_turf(hit), 4))
			new /obj/effects/explosion/dangerous(T)
		explosion_new(null, get_turf(hit), 100)

	on_launch(obj/projectile/proj)
		for(var/mob/M in range(proj.loc, 5))
			shake_camera(M, 3, 6)

/datum/projectile/bullet/glitch
	name = "bullet"
	window_pass = 1
	icon_state = "glitchproj"
	damage_type = D_KINETIC
	hit_type = null
	power = 30
	dissipation_delay = 12
	cost = 1
	shot_sound = 'sound/effects/glitchshot.ogg'
	ks_ratio = 1
	casing = null
	impact_image_state = null

	New()
		..()
		src.name = pick("weird", "puzzling", "odd", "strange", "baffling", "creepy", "unusual", "confusing", "discombobulating") + " bullet"
		src.name = corruptText(src.name, 66)

	on_hit(atom/hit)
		hit.icon_state = pick(icon_states(hit.icon))

		for(var/atom/a in hit)
			a.icon_state = pick(icon_states(a.icon))

		playsound(hit, 'sound/machines/glitch3.ogg', 50, 1)

/datum/projectile/bullet/glitch/gun
	power = 1

/datum/projectile/bullet/frog/ //sorry for making this, players -ZeWaka
	name = "green splat" //thanks aibm for wording this beautifully
	window_pass = 0
	icon_state = "acidspit"
	hit_type = null
	damage_type = 0
	power = 0
	dissipation_delay = 12
	sname = "Get In"
	shot_sound = 'sound/weapons/ribbit.ogg' //heh
	casing = null
	impact_image_state = null

	New()
		..()

	on_hit(atom/hit)
		hit.UpdateOverlays(image('icons/misc/frogs.dmi', "icon_state" = "getin"), "getin") //why did i code this

/datum/projectile/bullet/frog/getout
	sname = "Get Out"

	on_hit(atom/hit)
		hit.UpdateOverlays(image('icons/misc/frogs.dmi', "icon_state" = "getout"), "getout") //its like im trying to intentionally torture players

/datum/projectile/bullet/clownshot
	name = "clownshot"
	sname = "clownshot"
	power = 1
	cost = 15				//This should either cost a lot or a little I don't know. On one hand if it costs nothing you can truly tormet clowns with it, but on the other hand if it costs your full charge, then the clown will know how much you hate it because of how much you sacraficed to harm it. I settled for a med amount...
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	implanted = null
	shot_sound = 'sound/impact_sounds/Generic_Snap_1.ogg'
	impact_image_state = "bhole-staple"
	casing = null
	hit_ground_chance = 50
	icon_state = "random_thing"	//actually exists, looks funny enough to use as the projectile image for this

	on_hit(atom/hit, dirflag)
		if (ishuman(hit))
			var/mob/living/carbon/human/H = hit
			var/clown_tally = 0
			if(istype(H.w_uniform, /obj/item/clothing/under/misc/clown))
				clown_tally += 1
			if(istype(H.shoes, /obj/item/clothing/shoes/clown_shoes))
				clown_tally += 1
			if(istype(H.wear_mask, /obj/item/clothing/mask/clown_hat))
				clown_tally += 1
			if(clown_tally > 0)
				playsound(H, 'sound/musical_instruments/Bikehorn_1.ogg', 50, 1)

			if (H.job == "Clown" || clown_tally >= 2)
				H.drop_from_slot(H.shoes)
				H.throw_at(get_offset_target_turf(H, rand(5)-rand(5), rand(5)-rand(5)), rand(2,4), 2, throw_type = THROW_GUNIMPACT)
				H.emote("twitch_v")
				JOB_XP(H, "Clown", 1)
		return

/datum/projectile/bullet/spike
	name = "spike"
	sname = "spike"
	icon_state = "spike"
	power = 7.2
	dissipation_rate = 1
	dissipation_delay = 45
	damage_type = D_KINETIC
	hit_type = DAMAGE_STAB
	shot_sound = null
	projectile_speed = 12
	implanted = null
