ABSTRACT_TYPE(/datum/projectile/bullet)
/datum/projectile/bullet
	ammo_ID = "abstract_bullet"
	ammo_name = "Abstract bullet"
	///How much of a punch this has, tends to be seconds/damage before any resist
	power = 45
	///How much ammo this costs
	cost = 1
	///How fast the power goes away
	dissipation_rate = 5
	///How many tiles till it starts to lose power
	dissipation_delay = 5
	///Kill/Stun ratio
	ks_ratio = 1.0
	//name of the projectile setting, used when you change a guns setting
	sname = "single shot"
	///file location for the sound you want it to play
	shot_sound = 'sound/weapons/Gunshot.ogg'
	///How many projectiles should be fired, each will cost the full cost
	shot_number = 1

	// caliber list: update as needed
	// see defines/item.dm for caliber defs!

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
	icon_turf_hit = "bhole"

	hit_mob_sound = 'sound/impact_sounds/Flesh_Stab_2.ogg'

//Any special things when it hits shit?
	on_hit(atom/hit, direction, obj/projectile/P)
		if (ishuman(hit) && src.hit_type)
			if (hit_type != DAMAGE_BLUNT)
				take_bleeding_damage(hit, null, round(src.power / 3), src.hit_type) // oh god no why was the first var set to src what was I thinking
			hit.changeStatus("staggered", clamp(P.power/8, 5, 1) SECONDS)
		..()//uh, what the fuck, call your parent
		//return // BULLETS CANNOT BLEED, HAINE

/datum/projectile/bullet/bullet_22
	name = "bullet"
	ammo_ID = "bullet_22"
	ammo_name = ".22 bullet"
	power = 22
	shot_sound = "sound/weapons/smallcaliber.ogg" //quieter when fired from a silenced weapon!
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/bullet_22
	casing = /obj/item/casing/small
	caliber = CALIBER_PISTOL_SMALL
	icon_turf_hit = "bhole-small"
	silentshot = 1 // It's supposed to be a stealth weapon, right (Convair880)?

/datum/projectile/bullet/bullet_22/HP
	ammo_ID = "bullet_22_HP"
	ammo_name = ".22 hollow-point bullet"
	power = 35
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/bullet_22HP

/datum/projectile/bullet/bullet_9mm // little bigboy syndie pistol bullets
	ammo_ID = "bullet_9mm"
	ammo_name = "9mm JHP +P+ bullet"
	name = "bullet"
	power = 25
	shot_sound = 'sound/weapons/smg_shot.ogg'
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/bullet_22
	casing = /obj/item/casing/small
	caliber = CALIBER_PISTOL
	icon_turf_hit = "bhole-small"

	smg
		ammo_ID = "bullet_9mm_smg"
		ammo_name = "9mm JHP bullet"
		power = 20

/datum/projectile/bullet/custom
	name = "bullet"
	ammo_ID = "bullet_22_custom"
	ammo_name = "custom-made .22 bullet"
	power = 1
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/bullet_22
	casing = /obj/item/casing/small
	caliber = CALIBER_PISTOL_SMALL
	icon_turf_hit = "bhole-small"

/datum/projectile/bullet/revolver_357
	name = "bullet"
	ammo_ID = "bullet_357"
	ammo_name = ".357 magnum JHP bullet"
	power = 60 // okay this can be made worse again now that crit isn't naptime
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/bullet_357
	caliber = CALIBER_REVOLVER_MAGNUM
	icon_turf_hit = "bhole-small"
	casing = /obj/item/casing/medium

/datum/projectile/bullet/revolver_357/AP
	ammo_ID = "bullet_357_AP"
	ammo_name = ".357 magnum AP bullet"
	power = 50
	damage_type = D_PIERCING
	hit_type = DAMAGE_STAB
	implanted = /obj/item/implant/projectile/bullet_357AP

/datum/projectile/bullet/staple
	name = "staple"
	ammo_ID = "bullet_staple"
	ammo_name = "15mm 18gauge all-purpose staple"
	power = 5
	damage_type = D_KINETIC // don't staple through armor
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/staple // HEH
	shot_sound = 'sound/impact_sounds/Generic_Snap_1.ogg'
	icon_turf_hit = "bhole-staple"
	casing = null

/datum/projectile/bullet/revolver_38
	name = "bullet"
	sname = "execute"
	ammo_ID = "bullet_38"
	ammo_name = ".38 JHP bullet"
	power = 35
	ks_ratio = 1.0
	implanted = /obj/item/implant/projectile/bullet_38
	caliber = CALIBER_REVOLVER
	icon_turf_hit = "bhole-small"
	casing = /obj/item/casing/medium

/datum/projectile/bullet/revolver_38/lawbringer
	ammo_ID = "bullet_38_lawbringer"
	ammo_name = ".38 electro-lawslug"
	cost = 30
	shot_sound = 'sound/weapons/lb_execute.ogg'

/datum/projectile/bullet/revolver_38/AP//traitor det revolver
	ammo_ID = "bullet_38_AP"
	ammo_name = ".38 AP bullet"
	power = 35
	implanted = /obj/item/implant/projectile/bullet_38AP
	damage_type = D_PIERCING
	hit_type = DAMAGE_STAB

/datum/projectile/bullet/revolver_45
	name = "bullet"
	ammo_ID = "bullet_45"
	ammo_name = ".45 FMJ bullet"
	power = 35
	ks_ratio = 1.0
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/bullet_45
	caliber = CALIBER_REVOLVER_OLDTIMEY
	icon_turf_hit = "bhole-small"
	casing = /obj/item/casing/medium

/datum/projectile/bullet/nine_mm_NATO // littleboy NTSO Clock-shot
	name = "bullet"
	ammo_ID = "bullet_9mm_ntso"
	ammo_name = "9x19mm NTAO bullet"
	shot_sound = 'sound/weapons/9x19NATO.ogg'
	power = 6
	ks_ratio = 0.9
	hit_ground_chance = 75
	dissipation_rate = 2
	dissipation_delay = 8
	projectile_speed = 36
	caliber = CALIBER_PISTOL
	icon_turf_hit = "bhole-small"
	hit_type = DAMAGE_BLUNT
	implanted = /obj/item/implant/projectile/bullet_nine_mm_NATO
	casing = /obj/item/casing/small

	on_hit(atom/hit)
		..()
		if(ishuman(hit))
			var/mob/living/carbon/human/M = hit
			if(M.getStatusDuration("slowed") < 2.5 SECONDS)
				M.changeStatus("slowed", 1 SECOND, optional = 2)


// /datum/projectile/bullet/nine_mm_NATO/burst
// 	shot_number = 3
// 	cost = 3
// 	sname = "burst fire"

/datum/projectile/bullet/nine_mm_NATO/auto
	fullauto_valid = 1
	shot_number = 1
	cost = 1
	shot_volume = 66
	sname = "full auto"

/datum/projectile/bullet/rifle_3006
	name = "bullet"
	ammo_ID = "bullet_3006_rifle"
	ammo_name = ".30-06 magnum bullet"
	power = 85
	damage_type = D_PIERCING
	hit_type = DAMAGE_STAB
	implanted = /obj/item/implant/projectile/bullet_308
	shot_sound = 'sound/weapons/railgun.ogg'
	dissipation_delay = 10
	casing = /obj/item/casing/rifle_loud
	caliber = CALIBER_RIFLE_HEAVY
	icon_turf_hit = "bhole-small"

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
	ammo_ID = "bullet_3006_sniper"
	ammo_name = ".30-06 match bullet"
	power = 70
	icon_state = "sniper_bullet"
	damage_type = D_PIERCING
	hit_type = DAMAGE_STAB
	implanted = /obj/item/implant/projectile/bullet_308
	shot_sound = 'sound/weapons/railgun.ogg'
	dissipation_delay = 10
	dissipation_rate = 0 //70 damage AP at all-ranges is fine, come to think of it
	projectile_speed = 56
	max_range = 100
	casing = /obj/item/casing/rifle_loud
	caliber = CALIBER_RIFLE_HEAVY
	icon_turf_hit = "bhole-small"
	on_launch(obj/projectile/O)
		O.AddComponent(/datum/component/sniper_wallpierce, 2) //pierces 2 walls/lockers/doors/etc. Does not function on restriced Z, rwalls and blast doors use both pierces

	on_hit(atom/hit, dirflag, obj/projectile/P)
		if(ishuman(hit))
			var/mob/living/carbon/human/M = hit
			if(power > 40)
#ifdef USE_STAMINA_DISORIENT
				M.do_disorient(75, weakened = 40, stunned = 40, disorient = 60, remove_stamina_below_zero = 0)
#else
				M.changeStatus("stunned", 4 SECONDS)
				M.changeStatus("weakened", 3 SECONDS)
#endif
			if(power > 60)
				var/turf/target = get_edge_target_turf(M, dirflag)
				M.throw_at(target, 3, 3, throw_type = THROW_GUNIMPACT)
		..()

/datum/projectile/bullet/tranq_dart
	name = "dart"
	ammo_ID = "bullet_dart"
	ammo_name = ".308 haloperidol dart cartridge"
	power = 10
	icon = 'icons/obj/chemical.dmi'
	icon_state = "syringeproj"
	damage_type = D_TOXIC
	hit_type = DAMAGE_BLUNT
	implanted = null
	shot_sound = 'sound/effects/syringeproj.ogg'
	dissipation_delay = 10
	caliber = CALIBER_RIFLE_HEAVY
	reagent_payload = "haloperidol"
	casing = /obj/item/casing/rifle

	on_hit(atom/hit, dirflag)
		return

	syndicate
		ammo_ID = "bullet_dart_thiopentol"
		ammo_name = ".308 sodium thiopental dart cartridge"
		reagent_payload = "sodium_thiopental" // HEH

		pistol
			ammo_ID = "bullet_dart_thiopental_355"
			ammo_name = ".355 sodium thopental dart cartridge"
			caliber = CALIBER_PISTOL
			casing = /obj/item/casing/small
			shot_sound = 'sound/weapons/tranq_pistol.ogg'

	//haha gannets, fuck you I stole ur shit! - kyle
	lawbringer
		ammo_ID = "bullet_dart_lawbringer"
		ammo_name = ".355 haloperidol electro-lawdart"
		sname = "knockout"
		cost = 60
		caliber = CALIBER_REVOLVER
		casing = /obj/item/casing/small
		shot_sound = 'sound/weapons/tranq_pistol.ogg'

	anti_mutant
		ammo_ID = "bullet_dart_mutadone"
		ammo_name = ".308 mutadone dart cartridge"
		reagent_payload = "mutadone" // HAH

/datum/projectile/bullet/revolver_38/stunners//energy bullet things so he can actually stun something
	name = "stun bullet"
	ammo_ID = "bullet_38_stun"
	ammo_name = ".38 Shok-Mastr stun cartridge"
	power = 20
	ks_ratio = 0.0
	dissipation_delay = 6 //One more tick before falloff begins
	damage_type = D_ENERGY // FUCK YOU.
	hit_type = null
	icon_turf_hit = null // stun bullets shouldn't actually enter walls should they?

/datum/projectile/bullet/derringer
	name = "bullet"
	ammo_ID = "bullet_41_derringer"
	ammo_name = ".41 magnum shell"
	shot_sound = 'sound/weapons/derringer.ogg'
	power = 120
	dissipation_delay = 1
	dissipation_rate = 50
	damage_type = D_PIERCING
	hit_type = DAMAGE_STAB
	hit_ground_chance = 100
	implanted = /obj/item/implant/projectile/bullet_41
	ks_ratio = 0.66
	caliber = CALIBER_DERRINGER
	icon_turf_hit = "bhole"
	casing = /obj/item/casing/derringer

	on_hit(atom/hit)
		if(ismob(hit) && hasvar(hit, "stunned"))
			hit:stunned += 5
		..()

/datum/projectile/bullet/a12
	name = "buckshot"
	ammo_ID = "bullet_shotgun_magnum"
	ammo_name = "12 gauge space-bearshot shell"
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	power = 70
	ks_ratio = 1.0
	dissipation_delay = 2//2
	dissipation_rate = 10
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	caliber = CALIBER_SHOTGUN // roughly
	icon_turf_hit = "bhole"
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
		ammo_ID = "bullet_shotgun_short"
		ammo_name = "12 gauge space-birdshot shell"
		power = 50 //can have a little throwing, as a treat


/datum/projectile/bullet/airzooka
	name = "airburst"
	ammo_ID = "bullet_airzooka"
	ammo_name = "Jannie's Choice (TM) 5-gallon trashbag"
	shot_sound = 'sound/weapons/airzooka.ogg'
	power = 0
	ks_ratio = 1.0
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "crescent_white"
	dissipation_delay = 15
	dissipation_rate = 2
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	icon_turf_hit = "bhole"
	implanted = null
	casing = null
	caliber = CALIBER_TRASHBAG // I rolled a dice
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
	ammo_ID = "bullet_airzooka_bad"
	ammo_name = "Flubberized plasmatex sheet"
	shot_sound = 'sound/weapons/airzooka.ogg'
	power = 15
	ks_ratio = 1.0
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "40mmgatling"
	dissipation_delay = 15
	dissipation_rate = 4
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	icon_turf_hit = "bhole"
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


/datum/projectile/bullet/aex
	name = "explosive slug"
	ammo_ID = "bullet_shotgun_explosive"
	ammo_name = "12 gauge space-yetishot explosive slug"
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	power = 25 // the damage should be more from the explosion
	ks_ratio = 1.0
	dissipation_delay = 6
	dissipation_rate = 10
	implanted = null
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	caliber = CALIBER_SHOTGUN
	icon_turf_hit = "bhole"
	casing = /obj/item/casing/shotgun/orange

	on_hit(atom/hit)
		explosion_new(null, get_turf(hit), 2)

	on_max_range_die(obj/projectile/O)
		explosion_new(null, get_turf(O), 2)

	lawbringer
		name = "lawbringer"
		sname = "bigshot"
		ammo_ID = "bullet_shotgun_explosive_lawbringer"
		ammo_name = ".38 space-tidershot explosive electroslug"
		power = 1
		caliber = CALIBER_REVOLVER
		cost = 150

		on_hit(atom/hit)
			explosion_new(null, get_turf(hit), 4)

		on_max_range_die(obj/projectile/O)
			explosion_new(null, get_turf(O), 4)

/datum/projectile/bullet/abg
	name = "rubber slug"
	ammo_ID = "bullet_shotgun_rubber"
	ammo_name = "12 gauge space-clownshot riotslug"
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	power = 24
	ks_ratio = 0.2
	dissipation_rate = 4
	dissipation_delay = 3
	implanted = null
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	caliber = CALIBER_SHOTGUN
	icon_turf_hit = "bhole"
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

/datum/projectile/bullet/minigun
	name = "bullet"
	ammo_ID = "bullet_minigun"
	ammo_name = ".308 ultralow-pressure \"Wrist-Saver\" bullet"
	shot_sound = 'sound/weapons/minigunshot.ogg'
	power = 8
	cost = 10
	shot_delay = 0.7
	dissipation_delay = 7
	ks_ratio = 1.0
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	caliber = CALIBER_MINIGUN
	icon_turf_hit = "bhole-small"
	implanted = /obj/item/implant/projectile/bullet_308
	casing = /obj/item/casing/rifle

/datum/projectile/bullet/minigun/turret
	ammo_ID = "bullet_minigun_turret"
	ammo_name = ".308 low-pressure \"Weld-Saver\" bullet"
	power = 15
	dissipation_delay = 8

/datum/projectile/bullet/lmg
	name = "bullet"
	ammo_ID = "bullet_lmg"
	ammo_name = ".308 lmg bullet"
	shot_sound = 'sound/weapons/minigunshot.ogg'
	power = 12
	shot_delay = 0.7
	dissipation_delay = 12
	ks_ratio = 1.0
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	caliber = CALIBER_RIFLE_HEAVY
	icon_turf_hit = "bhole-small"
	implanted = /obj/item/implant/projectile/bullet_308
	casing = /obj/item/casing/rifle
	var/slow = 1

	on_hit(atom/hit, direction, obj/projectile/P)
		if(slow && ishuman(hit))
			var/mob/living/carbon/human/M = hit
			M.changeStatus("slowed", 0.5 SECONDS)
			M.changeStatus("staggered", clamp(P.power/8, 5, 1) SECONDS)

	auto
		fullauto_valid = 1
		sname = "full auto"
		shot_volume = 66
		cost = 1
		shot_number = 1

/datum/projectile/bullet/lmg/weak
	ammo_ID = "bullet_lmg_weak"
	ammo_name = ".308 \"Blood-Driver\" flechette"
	power = 1
	shot_delay = 0.7
	dissipation_delay = 8
	silentshot = 1
	slow = 0
	implanted = null

/datum/projectile/bullet/ak47
	name = "bullet"
	ammo_ID = "bullet_ak"
	ammo_name = "7.62x39mm FMJ bullet"
	shot_sound = 'sound/weapons/ak47shot.ogg'
	power = 40
	cost = 3
	ks_ratio = 1.0
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	caliber = CALIBER_RIFLE_HEAVY
	icon_turf_hit = "bhole-small"
	implanted = /obj/item/implant/projectile/bullet_308
	casing = /obj/item/casing/rifle

/datum/projectile/bullet/assault_rifle
	name = "bullet"
	ammo_ID = "bullet_ar"
	ammo_name = ".221 FMJ bullet"
	shot_sound = 'sound/weapons/ak47shot.ogg'  // todo: single shot sound?
	power = 30
	cost = 1
	ks_ratio = 1.0
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	caliber = CALIBER_RIFLE_ASSAULT
	icon_turf_hit = "bhole-small"
	implanted = /obj/item/implant/projectile/bullet_308
	casing = /obj/item/casing/rifle

	armor_piercing
		ammo_ID = "bullet_ar_ap"
		ammo_name = ".221 AP bullet"
		damage_type = D_PIERCING
		hit_type = DAMAGE_STAB

/datum/projectile/bullet/vbullet
	name = "virtual bullet"
	ammo_ID = "bullet_vr"
	ammo_name = "Virtual Bullet"
	shot_sound = 'sound/weapons/Gunshot.ogg'
	power = 10
	cost = 1
	ks_ratio = 1.0
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	implanted = null
	casing = null
	icon_turf_hit = null

/datum/projectile/bullet/flare
	name = "flare"
	ammo_ID = "bullet_shotgun_flare"
	ammo_name = "12 gauge incendiary space-wendigo slug"
	sname = "hotshot"
	shot_sound = 'sound/weapons/flaregun.ogg'
	power = 20
	cost = 1
	ks_ratio = 1.0
	damage_type = D_BURNING
	hit_type = null
	brightness = 1
	color_red = 1
	color_green = 0.3
	color_blue = 0
	icon_state = "flare"
	implanted = null
	caliber = CALIBER_SHOTGUN // 12 guage
	icon_turf_hit = "bhole"
	casing = /obj/item/casing/shotgun/orange

	on_hit(atom/hit, direction, obj/projectile/P)
		if (isliving(hit))
			fireflash(get_turf(hit), 0)
			hit.changeStatus("staggered", clamp(P.power/8, 5, 1) SECONDS)
		else if (isturf(hit))
			fireflash(hit, 0)
		else
			fireflash(get_turf(hit), 0)

/datum/projectile/bullet/flare/lawbringer
	name = "flare"
	ammo_ID = "bullet_shotgun_flare_lawbringer"
	ammo_name = ".38 incendiary electro-lawslug"
	sname = "hotshot"
	caliber = CALIBER_REVOLVER
	shot_sound = 'sound/weapons/flaregun.ogg'
	power = 20
	cost = 60

/datum/projectile/bullet/flare/UFO
	name = "heat beam"
	ammo_ID = "bullet_shotgun_flare_ufo"
	ammo_name = "UFO plasma cell"
	window_pass = 1
	icon_state = "plasma"
	casing = null

/datum/projectile/bullet/shrapnel // for explosions
	name = "shrapnel"
	ammo_ID = "bullet_shrapnel"
	ammo_name = "jagged piece of metal"
	ammo_name_plural = "jagged pieces of metal"
	power = 10
	caliber = CALIBER_PISTOL_SMALL
	damage_type = D_PIERCING
	hit_type = DAMAGE_CUT
	window_pass = 0
	icon = 'icons/obj/scrap.dmi'
	icon_state = "2metal0"
	casing = null
	icon_turf_hit = "bhole-staple"

/datum/projectile/bullet/cannon // autocannon should probably be renamed next
	name = "cannon round"
	ammo_ID = "bullet_cannon"
	ammo_name = "20mm armor-piercing high-explosive \"Badman\" shell"
	brightness = 0.7
	window_pass = 0
	icon_state = "20mmAPHE"
	damage_type = D_PIERCING
	hit_type = DAMAGE_CUT
	power = 150
	dissipation_delay = 1
	dissipation_rate = 5
	cost = 1
	shot_sound = 'sound/weapons/20mm.ogg'
	shot_volume = 130
	implanted = null

	ks_ratio = 1.0
	caliber = CALIBER_CANNON //20mm
	icon_turf_hit = "bhole-large"
	casing = /obj/item/casing/cannon
	pierces = 4
	shot_sound_extrarange = 1



	on_launch(obj/projectile/proj)
		proj.AddComponent(/datum/component/sniper_wallpierce, 4) //pierces 4 walls/lockers/doors/etc. Does not function on restricted Z, rwalls and blast doors use 2 pierces
		for(var/mob/M in range(proj.loc, 5))
			shake_camera(M, 3, 8)



	on_hit(atom/hit, dirflag, obj/projectile/proj)

		..()

		SPAWN_DBG(0)
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
						targetorgan = pick("left_lung", "heart", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix")
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

/datum/projectile/bullet/autocannon
	name = "HE grenade"
	ammo_ID = "bullet_grenade_he"
	ammo_name = "40mm high-explosive grenade cartridge"
	window_pass = 0
	icon_state = "40mmR"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	power = 25
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/rocket.ogg'
	ks_ratio = 1.0
	caliber = CALIBER_GRENADE // 40mm grenade shell
	icon_turf_hit = "bhole-large"
	casing = /obj/item/casing/grenade

	on_hit(atom/hit)
		explosion_new(null, get_turf(hit), 12)

	knocker
		name = "breaching round"
		ammo_ID = "bullet_grenade_breaching"
		ammo_name = "40mm \"All-Access\" door-breaching grenade cartridge"
		power = 10
		on_hit(atom/hit)
			if(istype(hit , /obj/machinery/door))
				var/obj/machinery/door/D = hit
				if(!D.cant_emag)
					D.take_damage(D.health/2) //fuck up doors without needing ex_act(1)
			explosion_new(null, get_turf(hit), 4, 1.75)

	plasma_orb
		ammo_ID = "bullet_autocannon_fusion"
		ammo_name = "40mm plasma autocannon shell"
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
		icon_turf_hit = null
		casing = null

	huge
		ammo_ID = "bullet_autocannon_huge"
		ammo_name = "400mm \"Shuttle-Call\" higher-explosive autocannon shell"
		icon_state = "400mm"
		power = 100
		caliber = CALIBER_CANNON_MASSIVE
		icon_turf_hit = "bhole-large"

		on_hit(atom/hit)
			explosion_new(null, get_turf(hit), 80)

	seeker
		ammo_ID = "bullet_grenade_droneseeker"
		ammo_name = "40mm \"X-Dead\" drone-seeking grenade cartridge"
		name = "drone-seeking grenade"
		power = 50 //even if they don't explode, you FEEL this one
		var/max_turn_rate = 20
		var/type_to_seek = /obj/critter/gunbot/drone //what are we going to seek
		precalculated = 0
		disruption = INFINITY //distrupt every system at once
		on_hit(atom/hit, angle, var/obj/projectile/P)
			if (P.data || prob(10))
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
			P.rotateDirection(max(-max_turn_rate, min(max_turn_rate, sign * relang)))

		pod_seeking
			ammo_ID = "bullet_grenade_podseeker"
			ammo_name = "40mm \"Putt-Driver\" pod-seeking grenade cartridge"
			name = "pod-seeking grenade"
			type_to_seek = /obj/machinery/vehicle
			on_hit(atom/hit)
				. = ..()
				if(istype(hit, /obj/machinery/vehicle))
					var/obj/machinery/vehicle/V = hit
					V.health -= V.maxhealth / 4 //a little extra punch in the face

		ghost
			ammo_ID = "bullet_grenade_ghostseeker"
			ammo_name = "40mm \"Diablo\" soul-seeking grenade cartridge" // not even death can save you from me
			name = "pod-seeking grenade"
			type_to_seek = /mob/dead/observer

/datum/projectile/bullet/grenade_round
	name = "40mm round"
	ammo_ID = "bullet_grenade_nonexplosive"
	ammo_name = "40mm \"Dummy\" slug cartridge"
	window_pass = 0
	icon_state = "40mmR"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	power = 5
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/launcher.ogg'
	ks_ratio = 1.0
	caliber = CALIBER_GRENADE
	icon_turf_hit = "bhole-large"
	casing = /obj/item/casing/grenade

	explosive
		name = "40mm HEDP round"
		ammo_ID = "bullet_grenade_hedp"
		ammo_name = "40mm \"Sensible\" HEDP grenade cartridge"

		on_hit(atom/hit)
			explosion_new(null, get_turf(hit), 2.5, 1.75)

	high_explosive //more powerful than HEDP
		ammo_ID = "bullet_grenade_he2"
		ammo_name = "40mm \"Reasonable\" higher-explosive grenade cartridge"
		name = "40mm HE round"
		power = 10

		on_hit(atom/hit)
			explosion_new(null,get_turf(hit), 8, 0.75)

// Ported from old, non-gun RPG-7 object class (Convair880).
/datum/projectile/bullet/rpg
	name = "MPRT rocket"
	ammo_ID = "bullet_rpg"
	ammo_name = "MPRT \"Fluke\" rocket-propelled grenade"
	window_pass = 0
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "rpg_rocket"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	power = 40
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/rocket.ogg'
	ks_ratio = 1.0
	caliber = CALIBER_RPG
	icon_turf_hit = "bhole-large"

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

/obj/smokeDummy
	name = ""
	desc = ""
	invisibility = 101
	anchored = 1
	density = 0
	opacity = 0
	var/list/affected = list()

	disposing()
		remove()
		return ..()

	New(var/atom/sloc)
		if(!sloc) return
		src.set_loc(sloc)
		for(var/mob/M in src.loc)
			Crossed(M)
		return ..()

	proc/remove()
		for(var/mob/M in affected)
			M.removeOverlayComposition(/datum/overlayComposition/smoke)
			M.updateOverlaysClient(M.client)
		affected.Cut()
		return

	Crossed(atom/movable/O)
		if(ishuman(O) && prob(30))
			var/mob/living/carbon/human/H = O
			if (H.internal != null && H.wear_mask && (H.wear_mask.c_flags & MASKINTERNALS))
			else
				H.emote("cough")
				if (prob(20))	//remove this maybe. it shoudla been stunning, but has been broken since the status system updates.
					H.setStatus("stunned",max(H.getStatusDuration("stunned"), 20))

		if(ismob(O))
			var/mob/M = O
			if (M.client && !isobserver(M) && !iswraith(M) && !isintangible(M)) // fuck you stop affecting ghosts FUCK YOU
				M.addOverlayComposition(/datum/overlayComposition/smoke)
				M.updateOverlaysClient(M.client)
				affected.Add(O)
		return ..()

	Uncrossed(atom/movable/O)
		if(ismob(O))
			var/mob/M = O
			if (M.client && !isobserver(M) && !iswraith(M) && !isintangible(M)) // FUCK YOU
				if(!(locate(/obj/smokeDummy) in M.loc))
					M.removeOverlayComposition(/datum/overlayComposition/smoke)
					M.updateOverlaysClient(M.client)
					affected.Remove(M)
		return ..()

/datum/projectile/bullet/smoke
	ammo_ID = "bullet_grenade_smoke"
	ammo_name = "40mm smoke grenade cartridge"
	name = "smoke grenade"
	sname = "smokeshot"
	window_pass = 0
	icon_state = "40mmB"
	damage_type = D_KINETIC
	power = 25
	dissipation_delay = 10
	cost = 1
	shot_sound = 'sound/weapons/launcher.ogg'
	ks_ratio = 1.0
	caliber = CALIBER_GRENADE // 40mm grenade shell
	icon_turf_hit = "bhole-large"
	casing = /obj/item/casing/grenade

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
			SPAWN_DBG(smokeLength) qdel(D)
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

/datum/projectile/bullet/smoke/lawbringer
	ammo_ID = "bullet_grenade_smoke_lawbringer"
	ammo_name = ".38 smoke electro-lawslug"
	name = "smoke slug"
	sname = "smokeshot"
	cost = 50
	caliber = CALIBER_REVOLVER

/datum/projectile/bullet/pbr //direct less-lethal 40mm option
	name = "plastic baton round"
	ammo_ID = "bullet_grenade_baton"
	ammo_name = "40mm plastic baton cartridge"
	shot_sound = 'sound/weapons/launcher.ogg'
	power = 50
	ks_ratio = 0.5
	dissipation_rate = 5
	dissipation_delay = 4
	max_range = 9
	implanted = null
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	caliber = CALIBER_GRENADE
	icon_turf_hit = "bhole-large"
	casing = /obj/item/casing/grenade

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

/datum/projectile/bullet/glitch
	name = "bullet"
	ammo_ID = "bullet_glitch"
	ammo_name = "src.die()"
	window_pass = 1
	icon_state = "glitchproj"
	damage_type = D_KINETIC
	hit_type = null
	power = 30
	dissipation_delay = 12
	cost = 1
	shot_sound = 'sound/effects/glitchshot.ogg'
	ks_ratio = 1.0
	casing = null
	icon_turf_hit = null

	New()
		..()
		src.name = pick("weird", "puzzling", "odd", "strange", "baffling", "creepy", "unusual", "confusing", "discombobulating") + " bullet"
		src.name = corruptText(src.name, 66)

	on_hit(atom/hit)
		hit.icon_state = pick(icon_states(hit.icon))

		for(var/atom/a in hit)
			a.icon_state = pick(icon_states(a.icon))

		playsound(hit, "sound/machines/glitch3.ogg", 50, 1)

/datum/projectile/bullet/glitch/gun
	ammo_ID = "bullet_glitch_gun"
	ammo_name = "src.text += \"\[DEAD\]\""
	power = 1

/datum/projectile/bullet/rod // for the coilgun
	name = "metal rod"
	ammo_ID = "bullet_metal_rod"
	ammo_name = "inanimate conductive rod"
	power = 50
	damage_type = D_KINETIC
	hit_type = DAMAGE_STAB
	window_pass = 0
	icon_state = "rod_1"
	dissipation_delay = 25
	caliber = CALIBER_ROD
	shot_sound = 'sound/weapons/ACgun2.ogg'
	casing = null
	icon_turf_hit = "bhole-large"

	on_hit(atom/hit)
		explosion_new(null, get_turf(hit), 5)

/datum/projectile/bullet/frog/ //sorry for making this, players -ZeWaka
	name = "green splat" //thanks aibm for wording this beautifully
	ammo_ID = "bullet_frog"
	ammo_name = "welcoming frog"
	window_pass = 0
	icon_state = "acidspit"
	hit_type = null
	damage_type = 0
	power = 0
	dissipation_delay = 12
	caliber = CALIBER_FROG
	sname = "Get In"
	shot_sound = 'sound/weapons/ribbit.ogg' //heh
	casing = null
	icon_turf_hit = null

	New()
		..()

	on_hit(atom/hit)
		hit.UpdateOverlays(image('icons/misc/frogs.dmi', "icon_state" = "getin"), "getin") //why did i code this

/datum/projectile/bullet/frog/getout
	ammo_ID = "bullet_frog_out"
	ammo_name = "not-so-welcoming frog"
	sname = "Get Out"

	on_hit(atom/hit)
		hit.UpdateOverlays(image('icons/misc/frogs.dmi', "icon_state" = "getout"), "getout") //its like im trying to intentionally torture players


/datum/projectile/bullet/flak_chunk
	name = "flak chunk"
	ammo_ID = "bullet_flak_chunk"
	ammo_name = "flak chunk"
	sname = "flak chunk"
	icon_state = "trace"
	shot_sound = null
	power = 12
	caliber = CALIBER_PISTOL_SMALL
	dissipation_rate = 5
	dissipation_delay = 8
	damage_type = D_KINETIC

/datum/projectile/bullet/buckshot // buckshot pellets generates by shotguns
	name = "buckshot"
	ammo_ID = "bullet_shotgun_pellet"
	ammo_name = "12 gauge pellet"
	sname = "buckshot"
	icon_state = "trace"
	power = 6
	caliber = CALIBER_PISTOL_SMALL
	dissipation_rate = 5
	dissipation_delay = 3
	damage_type = D_KINETIC

/datum/projectile/bullet/nails
	name = "nails"
	ammo_ID = "bullet_nail"
	ammo_name = "18 gauge brad nail"
	sname = "nails"
	icon_state = "trace"
	power = 4
	caliber = CALIBER_PISTOL_SMALL
	dissipation_rate = 3
	dissipation_delay = 4
	damage_type = D_SLASHING
	casing = /obj/item/casing/shotgun/gray

/// While any other projectile'll work to hold a grenade, this one works best
/datum/projectile/bullet/grenade_shell
	name = "40mm grenade conversion shell"
	ammo_ID = "bullet_grenade_conversion"
	ammo_name = "40mm grenade conversion shell"
	window_pass = 0
	icon_state = "40mmR"
	damage_type = D_KINETIC
	power = 25
	dissipation_delay = 20
	cost = 1
	shot_sound = 'sound/weapons/rocket.ogg'
	ks_ratio = 1.0
	caliber = CALIBER_GRENADE // 40mm grenade shell
	icon_turf_hit = "bhole-large"
	casing = /obj/item/casing/grenade
	/// This projectile holds a grenade. It'll call its prime() on impact!
	var/obj/item/grenade/internal_grenade
	/// And/or a chem grenade
	var/obj/item/chem_grenade/internal_chem_grenade

	/// When an object is put into this projectile, do this
	proc/on_object_insertion(var/obj/I)
		if(!istype(I)) return
		if(I.name)
			src.name = "[I.name] shell"
			src.ammo_ID = "[ckey(I.name)]_shell"
			src.ammo_name = "[ckey(I.name)]_shell"
		src.icon = I.icon
		if(istype(I, /obj/item/grenade))
			var/obj/item/grenade/GG = I
			if(GG.icon_state_exploding)
				src.icon_state = GG.icon_state_exploding
			else if(GG.icon_state_armed)
				src.icon_state = GG.icon_state_armed
			else
				src.icon_state = GG.icon_state
		if(istype(I, /obj/item/chem_grenade))
			var/obj/item/chem_grenade/CG = I
			if(CG.icon_state_armed)
				src.icon_state = CG.icon_state_armed
			else
				src.icon_state = CG.icon_state
		else
			src.icon_state = I.icon_state

	on_hit(atom/hit, angle, var/obj/projectile/O)
		if(istype(src.internal_grenade) || istype(src.internal_chem_grenade))
			var/turf/T = get_turf(hit)
			if (T)
				if(T.density)
					var/anti_angle = turn(angle2dir(angle), 180)
					for(var/i in 1 to 10)
						T = get_step(T, anti_angle)
						if(!T.density)
							break
				src.internal_grenade?.set_loc(T)
				src.internal_grenade?.prime()
				src.internal_chem_grenade?.set_loc(T)
				src.internal_chem_grenade?.explode()
			else if (O)
				var/turf/pT = get_turf(O)
				if (pT)
					src.internal_grenade?.set_loc(T)
					src.internal_grenade?.prime()
					src.internal_chem_grenade?.set_loc(T)
					src.internal_chem_grenade?.explode()
			src.internal_grenade = null

	on_end(var/obj/projectile/O)
		if(istype(src.internal_grenade) || istype(src.internal_chem_grenade))
			if (O)
				var/turf/pT = get_turf(O)
				if (pT)
					src.internal_grenade?.set_loc(O)
					src.internal_grenade?.prime()
					src.internal_chem_grenade?.set_loc(O)
					src.internal_chem_grenade?.explode()
			src.internal_grenade = null

/datum/projectile/bullet/flintlock
	name = "bullet"
	ammo_ID = "bullet_flintlock"
	ammo_name = ".58 blackpowder cartridge"
	power = 100
	damage_type = D_PIERCING
	hit_type = DAMAGE_STAB
	implanted = /obj/item/implant/projectile/flintlock
	shot_sound = 'sound/weapons/flintlock.ogg'
	dissipation_delay = 10
	casing = null
	caliber = CALIBER_PISTOL_FLINTLOCK
	icon_turf_hit = "bhole-small"

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

/datum/projectile/bullet/antisingularity
	name = "Singularity buster rocket"
	ammo_ID = "bullet_rpg_antisingulo"
	ammo_name = "rocket-propelled quantum multiplicity field generator"
	window_pass = 0
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "regrocket"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	power = 5
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/rocket.ogg'
	ks_ratio = 1.0
	caliber = CALIBER_ROCKET
	icon_turf_hit = "bhole-large"
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

/datum/projectile/bullet/clownshot
	name = "clownshot"
	ammo_ID = "bullet_clownshot_lawbringer"
	ammo_name = ".42 merriment-suppression device"
	sname = "clownshot"
	power = 1
	caliber = CALIBER_REVOLVER
	cost = 15				//This should either cost a lot or a little I don't know. On one hand if it costs nothing you can truly tormet clowns with it, but on the other hand if it costs your full charge, then the clown will know how much you hate it because of how much you sacraficed to harm it. I settled for a med amount...
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	implanted = null
	shot_sound = 'sound/impact_sounds/Generic_Snap_1.ogg'
	icon_turf_hit = "bhole-staple"
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
				playsound(H, "sound/musical_instruments/Bikehorn_1.ogg", 50, 1)

			if (H.job == "Clown" || clown_tally >= 2)
				H.drop_from_slot(H.shoes)
				H.throw_at(get_offset_target_turf(H, rand(5)-rand(5), rand(5)-rand(5)), rand(2,4), 2, throw_type = THROW_GUNIMPACT)
				H.emote("twitch_v")
				JOB_XP(H, "Clown", 1)
		return

/datum/projectile/bullet/mininuke //Assday only.
	name = "miniature nuclear warhead"
	ammo_ID = "bullet_mininuke"
	ammo_name = "M68 \"Popey Crunchett\" tactical thermonuclear device"
	window_pass = 0
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "mininuke"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	power = 120
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/rocket.ogg'
	ks_ratio = 1.0
	caliber = CALIBER_ROCKET
	icon_turf_hit = "bhole-large"
	implanted = null

	on_hit(atom/hit)
		var/turf/T = get_turf(hit)
		if (T)
			T.hotspot_expose(700,125)
			explosion_new(null, T, 300, 1)
		return

/datum/projectile/bullet/spike
	name = "spike"
	ammo_ID = "bullet_spike"
	ammo_name = "spike"
	sname = "spike"
	icon_state = "spike"
	power = 7.2
	caliber = CALIBER_PISTOL_SMALL
	dissipation_rate = 1
	dissipation_delay = 45
	damage_type = D_KINETIC
	hit_type = DAMAGE_STAB
	shot_sound = null
	projectile_speed = 8
	implanted = null
