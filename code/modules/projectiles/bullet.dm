ABSTRACT_TYPE(/datum/projectile/bullet)
/datum/projectile/bullet
//How much of a punch this has, tends to be seconds/damage before any resist
	damage = 45
//How much ammo this costs
	cost = 1
//How fast the power goes away
	dissipation_rate = 5
//How many tiles till it starts to lose power
	dissipation_delay = 5
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
	ie_type = "K"
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
	impact_image_state = "bullethole"

	hit_mob_sound = 'sound/impact_sounds/Flesh_Stab_2.ogg'

	has_impact_particles = TRUE

	/// can it ricochet off a wall?
	var/ricochets = FALSE

//no caliber
/datum/projectile/bullet/staple
	name = "staple"
	damage = 5
	damage_type = D_KINETIC // don't staple through armor
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/staple // HEH
	shot_sound = 'sound/impact_sounds/Generic_Snap_1.ogg'
	impact_image_state = "bullethole-staple"
	casing = null

/datum/projectile/bullet/vbullet
	name = "virtual bullet"
	shot_sound = 'sound/weapons/Gunshot.ogg'
	damage = 10
	cost = 1
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	implanted = null
	casing = null
	impact_image_state = null

//0.22
/datum/projectile/bullet/bullet_22
	name = "bullet"
	damage = 22
	shot_sound = 'sound/weapons/smallcaliber.ogg' //quieter when fired from a silenced weapon!
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/bullet_22
	casing = /obj/item/casing/small
	impact_image_state = "bullethole-small"
	silentshot = 1 // It's supposed to be a stealth weapon, right (Convair880)?
	ricochets = TRUE

	a180
		fullauto_valid = 1
		shot_number = 1
		damage = 18
		cost = 1
		shot_volume = 20
		sname = "full auto"
		casing = null
		on_pre_hit(atom/hit, angle, var/obj/projectile/O)
			if (isliving(hit))
				if (ON_COOLDOWN(hit, "american180_miss", 3 DECI SECONDS))
					return TRUE
				else
					return FALSE

		get_power(obj/projectile/P, atom/A)
			var/standard_damage = P.initial_power - max(0, (P.travelled/32 - src.dissipation_delay))*src.dissipation_rate
			if (isliving(A))
				return rand(standard_damage-5,standard_damage) //less accurate, hitting random parts instead of centre mass
			else
				return min(2,standard_damage) // dont break shit as hard

/datum/projectile/bullet/bullet_22/smartgun
	shot_sound = 'sound/weapons/smartgun.ogg'
	shot_volume = 70
	silentshot = 0

/datum/projectile/bullet/bullet_22/HP
	damage = 35
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/bullet_22HP
	ricochets = TRUE

/datum/projectile/bullet/bullet_22/match
	damage = 35
	armor_ignored = 0.33
	dissipation_delay = 15
	damage_type = D_PIERCING
	hit_type = DAMAGE_STAB
	shot_sound = 'sound/weapons/capella.ogg'
	silentshot = 0
	projectile_speed = 96
	shot_delay = 0.2
	ricochets = TRUE


/datum/projectile/bullet/custom
	name = "bullet"
	damage = 1
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/bullet_22
	casing = /obj/item/casing/small
	impact_image_state = "bullethole-small"

//0.223
/datum/projectile/bullet/assault_rifle
	name = "bullet"
	shot_sound = 'sound/weapons/assrifle.ogg'  // todo: single shot sound?
	damage = 45
	cost = 1
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	shot_number = 1
	impact_image_state = "bullethole-small"
	implanted = /obj/item/implant/projectile/bullet_308
	casing = /obj/item/casing/rifle
	ricochets = TRUE

	armor_piercing
		damage_type = D_PIERCING
		hit_type = DAMAGE_STAB
		armor_ignored = 0.66
	remington
		damage = 34

/datum/projectile/bullet/assault_rifle/burst
	sname = "burst fire"
	damage = 45
	cost = 2
	shot_number = 2

	armor_piercing
		damage_type = D_PIERCING
		hit_type = DAMAGE_STAB
		armor_ignored = 0.66
	remington
		damage = 26

//0.308
/datum/projectile/bullet/minigun
	name = "bullet"
	shot_sound = 'sound/weapons/minigunshot.ogg'
	damage = 10
	cost = 1
	shot_number = 1 //dont question it
	dissipation_delay = 7
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	impact_image_state = "bullethole-small"
	implanted = /obj/item/implant/projectile/bullet_308
	casing = /obj/item/casing/rifle
	fullauto_valid = 1
	ricochets = TRUE

/datum/projectile/bullet/minigun/turret
	damage = 15
	dissipation_delay = 8

/datum/projectile/bullet/akm
	name = "bullet"
	shot_sound = 'sound/weapons/akm.ogg'
	damage = 40  // BEFORE YOU TWEAK THESE VALUES: This projectile is also used by the Syndicate Ballistic Drone and Nukie NAS-T turret
	cost = 3
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	shot_number = 3
	shot_delay = 120 MILLI SECONDS
	impact_image_state = "bullethole-small"
	implanted = /obj/item/implant/projectile/bullet_308
	casing = /obj/item/casing/rifle
	ricochets = TRUE

/datum/projectile/bullet/akm/pod
	damage = 4
	shot_number = 1
	dissipation_delay = 7

/datum/projectile/bullet/draco
	name = "bullet"
	shot_sound = 'sound/weapons/akm.ogg'
	damage = 31
	cost = 1
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	shot_number = 1
	fullauto_valid = 1
	impact_image_state = "bullethole-small"
	implanted = /obj/item/implant/projectile/bullet_308
	casing = /obj/item/casing/rifle
	ricochets = TRUE

/datum/projectile/bullet/rifle_3006
	name = "bullet"
	damage = 85
	damage_type = D_PIERCING
	armor_ignored = 0.50
	hit_type = DAMAGE_STAB
	implanted = /obj/item/implant/projectile/bullet_308
	shot_sound = 'sound/weapons/railgun.ogg'
	shot_volume = 50 // holy fuck why was this so loud
	dissipation_rate = 0
	projectile_speed = 72
	max_range = 80
	casing = /obj/item/casing/rifle_loud
	impact_image_state = "bullethole-large"

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if(ishuman(hit))
			var/mob/living/carbon/human/M = hit
			if(proj.power > 40)
#ifdef USE_STAMINA_DISORIENT
				M.do_disorient(75, knockdown = 40, stunned = 40, disorient = 60, remove_stamina_below_zero = 0)
#else
				M.changeStatus("stunned", 4 SECONDS)
				M.changeStatus("knockdown", 3 SECONDS)
#endif
			if(proj.power > 80)
				var/turf/target = get_edge_target_turf(M, dirflag)
				M.throw_at(target, 2, 2, throw_type = THROW_GUNIMPACT)
		..()

/datum/projectile/bullet/rifle_762_NATO //like .308 but military
	name = "bullet"
	damage = 70
	icon_state = "sniper_bullet"
	damage_type = D_PIERCING
	armor_ignored = 0.66
	hit_type = DAMAGE_STAB
	implanted = /obj/item/implant/projectile/bullet_308
	shot_sound = 'sound/weapons/railgun.ogg'
	shot_volume = 50 //
	dissipation_delay = 10
	dissipation_rate = 0 //70 damage AP at all-ranges is fine, come to think of it
	projectile_speed = 72
	max_range = 100
	casing = /obj/item/casing/rifle_loud
	impact_image_state = "bullethole-large"
	on_launch(obj/projectile/O)
		O.AddComponent(/datum/component/sniper_wallpierce, 3, 20) //pierces 3 walls/lockers/doors/etc. Does not function on restriced Z, rwalls and blast doors use 2 pierces

	on_hit(atom/hit, dirflag, obj/projectile/P)
		if (ismob(hit))
			var/mob/M = hit
			if(ishuman(hit))
				var/mob/living/carbon/human/H = hit
				if(power > 40)
	#ifdef USE_STAMINA_DISORIENT
					H.do_disorient(50, knockdown = 2 SECONDS, stunned = 2 SECONDS, disorient = 0, remove_stamina_below_zero = FALSE)
	#else
					H.changeStatus("stunned", 4 SECONDS)
					H.changeStatus("knockdown", 3 SECONDS)
	#endif
			var/turf/target = get_edge_target_turf(hit, dirflag)
			M.throw_at(target, 1, 3, throw_type = THROW_GUNIMPACT)
		..()

/datum/projectile/bullet/tranq_dart
	name = "dart"
	damage = 10
	icon_state = "tranqdart_red"
	damage_type = D_TOXIC
	hit_type = DAMAGE_BLUNT
	implanted = /obj/item/implant/projectile/body_visible/dart/tranq_dart_sleepy
	shot_sound = 'sound/effects/syringeproj.ogg'
	dissipation_delay = 10
	reagent_payload = "haloperidol"
	casing = /obj/item/casing/rifle
	has_impact_particles = FALSE

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
	damage = 15
	cost = 8
	shot_number = 8
	shot_delay = 0.1 SECONDS
	dissipation_delay = 12
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	impact_image_state = "bullethole-small"
	implanted = /obj/item/implant/projectile/bullet_308
	casing = /obj/item/casing/rifle
	var/slow = 1
	ricochets = TRUE

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
	damage = 1
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
	damage = 30
	shot_sound = 'sound/weapons/smg_shot.ogg'
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/bullet_9mm
	casing = /obj/item/casing/small
	impact_image_state = "bullethole-small"
	ricochets = TRUE

	smg
		damage = 20
		cost = 3
		shot_number = 3

		auto
			fullauto_valid = 1
			cost = 1
			shot_number = 1


/datum/projectile/bullet/nine_mm_NATO
	name = "bullet"
	shot_sound = 'sound/weapons/9x19NATO.ogg'
	damage = 6
	stun = 4
	hit_ground_chance = 75
	dissipation_rate = 3
	dissipation_delay = 8
	projectile_speed = 48
	impact_image_state = "bullethole-small"
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



/datum/projectile/bullet/nine_mm_surplus
	name = "bullet"
	shot_sound = 'sound/weapons/9x19NATO.ogg'
	damage = 16
	shot_number = 1
	cost = 1
	hit_ground_chance = 75
	dissipation_rate = 3
	dissipation_delay = 8
	projectile_speed = 60
	impact_image_state = "bhole-small"
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/bullet_9mm
	casing = /obj/item/casing/small
/datum/projectile/bullet/nine_mm_surplus/burst
	shot_number = 3
	cost = 3
	sname = "burst fire"

/datum/projectile/bullet/nine_mm_surplus/auto
	fullauto_valid = 1
	shot_number = 1
	cost = 1
	shot_volume = 66
	sname = "full auto"

/datum/projectile/bullet/nine_mm_soviet
	name = "bullet"
	shot_sound = 'sound/weapons/9x19NATO.ogg'
	damage = 25
	impact_image_state = "bullethole-small"
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/bullet_9mm
	casing = /obj/item/casing/small

//medic primary
/datum/projectile/bullet/veritate
	name = "bullet"
	shot_sound = 'sound/weapons/9x19NATO.ogg'
	damage = 15
	damage_type = D_PIERCING
	armor_ignored = 0.66
	hit_type = DAMAGE_STAB
	hit_ground_chance = 50
	projectile_speed = 60
	impact_image_state = "bullethole-small"
	implanted = /obj/item/implant/projectile/bullet_9mm
	casing = /obj/item/casing/small
	ricochets = TRUE

/datum/projectile/bullet/veritate/burst
	sname = "burst fire"
	damage = 15
	cost = 3
	shot_number = 3


//0.357
/datum/projectile/bullet/revolver_357
	name = "bullet"
	damage = 60 // okay this can be made worse again now that crit isn't naptime
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/bullet_357
	impact_image_state = "bullethole-small"
	casing = /obj/item/casing/medium
	ricochets = TRUE

/datum/projectile/bullet/revolver_357/AP
	damage = 50
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
	damage = 35
	implanted = /obj/item/implant/projectile/bullet_38
	impact_image_state = "bullethole-small"
	casing = /obj/item/casing/medium
	ricochets = TRUE

/datum/projectile/bullet/revolver_38/lb
	shot_sound = 'sound/weapons/lb_execute.ogg'

/datum/projectile/bullet/revolver_38/AP//traitor det revolver
	damage = 35
	implanted = /obj/item/implant/projectile/bullet_38AP
	damage_type = D_PIERCING
	armor_ignored = 0.66
	hit_type = DAMAGE_STAB

/datum/projectile/bullet/revolver_38/stunners//energy bullet things so he can actually stun something
	name = "stun bullet"
	damage = 0
	stun = 20
	dissipation_delay = 6 //One more tick before falloff begins
	damage_type = D_ENERGY // FUCK YOU.
	ie_type = "T"
	hit_type = null
	impact_image_state = null // stun bullets shouldn't actually enter walls should they?
	ricochets = FALSE

//0.393
/datum/projectile/bullet/foamdart
	name = "foam dart"
	sname = "foam dart"
	icon_state = "foamdart"
	shot_sound = 'sound/effects/syringeproj.ogg'
	impact_image_state = null
	projectile_speed = 26
	implanted = null
	damage = 0
	damage_type = D_SPECIAL
	hit_type = DAMAGE_BLUNT
	max_range = 15
	dissipation_rate = 0
	ie_type = null
	smashes_glasses = FALSE //foam
	has_impact_particles = FALSE

	on_hit(atom/hit, direction, obj/projectile/P)
		..()
		var/turf/T = istype(hit, /mob) ? get_turf(hit) : get_turf(P) // drop on same tile if mob, drop 1 tile away otherwise
		drop_as_ammo(get_turf(T))
		qdel(P) // we dropped, don't keep going

	on_max_range_die(obj/projectile/P)
		..()
		drop_as_ammo(get_turf(P))

	proc/drop_as_ammo(turf/T)
		if(T)
			var/obj/item/ammo/bullets/foamdarts/ammo_dropped = new /obj/item/ammo/bullets/foamdarts (T)
			ammo_dropped.amount_left = 1
			ammo_dropped.UpdateIcon()
			ammo_dropped.pixel_x += rand(-12,12)
			ammo_dropped.pixel_y += rand(-12,12)
			. = ammo_dropped

/datum/projectile/bullet/foamdart/biodegradable
	name = "biodegradable CyberFoam dart"
	sname = "biodegradable CyberFoam dart"
	damage_type = D_KINETIC
	damage = 0
	stun = 2.5 // about 33 shots to down a full-stam person
	silentshot = TRUE

	drop_as_ammo(obj/projectile/P)
		var/obj/item/ammo/bullets/foamdarts/dropped = ..()
		if (dropped)
			dropped.changeStatus("acid", 3 SECONDS, list("message" = null)) // this will probably bug out if someone manages to load it into a gun. problem for later

//0.40
/datum/projectile/bullet/blow_dart
	name = "poison dart"
	damage = 5
	icon_state = "blowdart"
	damage_type = D_TOXIC
	hit_type = DAMAGE_STAB
	dissipation_delay = 10
	implanted = "blowdart"
	shot_sound = 'sound/effects/syringeproj.ogg'
	silentshot = 1
	casing = null
	reagent_payload = "curare"
	implanted = /obj/item/implant/projectile/body_visible/blowdart
	has_impact_particles = FALSE

	madness
		reagent_payload = "madness_toxin"

	ls_bee
		reagent_payload = "lsd_bee"

	ketamine
		reagent_payload = "ketamine"

//0.41
/datum/projectile/bullet/derringer
	name = "bullet"
	shot_sound = 'sound/weapons/derringer.ogg'
	damage = 80
	stun = 40
	dissipation_delay = 1
	dissipation_rate = 50
	damage_type = D_PIERCING
	armor_ignored = 0.66
	hit_type = DAMAGE_STAB
	hit_ground_chance = 100
	implanted = /obj/item/implant/projectile/bullet_41
	impact_image_state = "bullethole"
	casing = /obj/item/casing/derringer

//0.45
/datum/projectile/bullet/revolver_45
	name = "bullet"
	damage = 35
	hit_type = DAMAGE_CUT
	implanted = /obj/item/implant/projectile/bullet_45
	impact_image_state = "bullethole-small"
	casing = /obj/item/casing/medium
	ricochets = TRUE

//0.58
/datum/projectile/bullet/flintlock
	name = "lead ball"
	icon_state = "bullet"
	damage = 40
	armor_ignored = 0.66
	hit_type = DAMAGE_STAB
	implanted = /obj/item/implant/projectile/flintlock
	shot_sound = 'sound/weapons/flintlock.ogg'
	dissipation_delay = 10
	hit_ground_chance = 50
	casing = null
	impact_image_state = "bullethole-small"

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if(ishuman(hit))
			var/mob/living/carbon/human/M = hit
			if(proj.power > 30)
				M.changeStatus("slowed", 3 SECONDS)
				M.changeStatus("knockdown", 2 SECONDS)
			if(proj.power > 60)
				var/turf/target = get_edge_target_turf(M, dirflag)
				M.throw_at(target, 3, 2, throw_type = THROW_GUNIMPACT)
				M.update_canmove()
		..()

	rifle
		damage = 70
		impact_image_state = "bullethole-large"

	mortar
		name = "mortar grenade"
		icon_state = "mortar"
		damage = 10 // The explosion should deal most of the damage.
		impact_image_state = "bullethole-large"
		damage_type = D_KINETIC
		hit_type = DAMAGE_BLUNT

		on_hit(atom/hit, dirflag, obj/projectile/proj)
			if(ishuman(hit))
				var/mob/living/carbon/human/M = hit

				M.do_disorient(75, knockdown = 50, stunned = 50, disorient = 30, remove_stamina_below_zero = 0)

				if(!M.stat)
					M.emote("scream")
				var/turf/target = get_edge_target_turf(M, dirflag)
				M.throw_at(target, 6, 2, throw_type = THROW_GUNIMPACT)
				M.update_canmove()
				SPAWN(0.5 SECONDS) // Wait until the target is at rest before exploding.
					explosion_new(proj, get_turf(hit), 4, 1.75)
			else
				explosion_new(proj, get_turf(hit), 4, 1.75)
			..()

		on_max_range_die(obj/projectile/O)
			explosion_new(O, get_turf(O), 4, 1.75)

//0.72
/datum/projectile/bullet/a12
	name = "buckshot"
	icon_state = "buckshot"
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	damage = 70
	dissipation_delay = 2//2
	dissipation_rate = 10
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	impact_image_state = "bullethole"
	hit_ground_chance = 100
	implanted = /obj/item/implant/projectile/bullet_12ga
	casing = /obj/item/casing/shotgun/red

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if (ishuman(hit))
			var/mob/living/carbon/human/M = hit
			if(proj.power >= 30)
				M.do_disorient(75, knockdown = 50, stunned = 50, disorient = 30, remove_stamina_below_zero = 0)

			if(proj.power >= 40)
				var/throw_range = (proj.power > 50) ? 6 : 3
				var/turf/target = get_edge_target_turf(M, dirflag)
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
		damage = 50 //can have a little throwing, as a treat

/datum/projectile/bullet/bird12 //birdshot, for gangs. just much worse overall
	icon_state = "birdshot1"
	hit_ground_chance = 66
	implanted = null
	damage = 13
	stun = 6
	hit_type = DAMAGE_CUT //birdshot mutilates your skin more, but doesnt hurt organs like shotties
	dissipation_rate = 4 //spread handles most of this
	shot_sound = 'sound/weapons/birdshot.ogg'
	dissipation_delay = 6
	casing = /obj/item/casing/shotgun/red
	on_launch(obj/projectile/O)
		icon_state = "birdshot[rand(1,3)]"
		. = ..()

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if (istype(hit, /mob/living/critter/small_animal/bird))
			var/mob/living/critter/small_animal/bird/M = hit
			M.TakeDamage("chest", proj.power * 3 / M.get_ranged_protection()) //it's in the name
			var/turf/target = get_edge_target_turf(M, dirflag)
			M.throw_at(target, 4, 1, throw_type = THROW_GUNIMPACT)
			M.update_canmove()
		if (ismob(hit) && prob(60))
			var/mob/M = hit
			take_bleeding_damage(M, proj.shooter, 3, DAMAGE_CUT, 1, override_bleed_level=rand(2,4))
		..()

/datum/projectile/bullet/kuvalda_slug //engine block destroying slug. not as fun as Buck, but longer range and AP.
	icon_state = "4gauge"
	hit_ground_chance = 66
	implanted = null
	damage = 65
	armor_ignored = 0.8
	stun = 10
	hit_type = DAMAGE_STAB
	dissipation_rate = 10
	shot_sound = 'sound/weapons/kuvalda.ogg'
	dissipation_delay = 6
	casing = /obj/item/casing/shotgun/gray
	on_launch(obj/projectile/P)
		P.AddComponent(/datum/component/nonwall_pierce)
		icon_state = "4gauge-slug"
		impact_image_state = "bullethole"
		var/image/blood_image = image('icons/obj/projectiles.dmi', icon_state+"-blood")
		blood_image.alpha = 0
		P.special_data["blood_image"] = blood_image
		P.special_data["bleeding"] = FALSE
		P.UpdateOverlays(P.special_data["blood_image"], "blood_image")
		. = ..()
	on_hit(atom/hit, dirflag, obj/projectile/P)
		if (isliving(hit) && !isrobot(hit))
			var/mob/living/M = hit
			take_bleeding_damage(M, P.shooter, 2, DAMAGE_CUT, 1)
			P.special_data["bleeding"] = FALSE
			P.special_data["last_projectile_loc"] = get_turf(P)
			P.special_data["unfortunate"] = M
			var/image/blood_image = P.special_data["blood_image"]
			blood_image?.color = M.blood_color
			blood_image?.alpha = 255
			P.UpdateOverlays(blood_image, "blood_image")
			for (var/x in 1 to 3)
				var/obj/decal/cleanable/blood/gibs/gib = make_cleanable(/obj/decal/cleanable/blood/gibs, get_turf(M) )
				gib.streak_cleanable(dirflag)
			var/turf/target = get_edge_target_turf(M, dirflag)
			M.throw_at(target, 3, 1, throw_type = THROW_GUNIMPACT)
		..()

	on_end(var/obj/projectile/P)
		if (P.special_data["bleeding"])
			bleed(P.special_data["unfortunate"],10,4,get_turf(P))
			playsound(P.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 30, 1)
		..()
	tick(var/obj/projectile/P)
		var/turf/last_projectile_loc = P.special_data["last_projectile_loc"]
		if (!P.special_data["bleeding"] || last_projectile_loc == get_turf(P))
			..()
			return
		if (P.special_data["bleeding"])
			last_projectile_loc = get_turf(P)
			bleed(P.special_data["unfortunate"],0,1,last_projectile_loc)
		..()


/datum/projectile/bullet/kuvalda_shrapnel //kuvalda shot
	icon_state = "4gauge"
	hit_ground_chance = 66
	implanted = null
	damage = 34
	stun = 6
	hit_type = DAMAGE_STAB
	dissipation_rate = 4 //spread handles most of this
	shot_sound = 'sound/weapons/kuvalda.ogg'
	dissipation_delay = 6
	casing = /obj/item/casing/shotgun/gray

	on_launch(obj/projectile/P)
		P.AddComponent(/datum/component/nonwall_pierce)
		icon_state = "4gauge[rand(1,3)]"
		impact_image_state = "bullethole-small-cluster-[rand(1,3)]"
		var/image/blood_image = image('icons/obj/projectiles.dmi', icon_state+"-blood")
		blood_image.alpha = 0
		P.special_data["blood_image"] = blood_image
		P.UpdateOverlays(blood_image, "blood_image")
		FLICK(icon_state,P) // this is a bit hacky - guarantees the full spread animation will play before swapping to bloodloop
		. = ..()
	on_hit(atom/hit, dirflag, obj/projectile/P)
		if (isliving(hit) && !isrobot(hit))
			var/mob/living/M = hit
			take_bleeding_damage(M, P.shooter, 2, DAMAGE_CUT, 1)
			P.special_data["bleeding"] = TRUE
			P.special_data["last_projectile_locs"] = get_turf(P)
			P.special_data["unfortunate"] = M
			P.icon_state  = icon_state+"-bloodloop"
			var/image/blood_image = P.special_data["blood_image"]
			blood_image?.color = M.blood_color
			blood_image?.alpha = 255
			P.color = M.blood_color
			P.UpdateOverlays(blood_image, "blood_image")
			//the poor sod who eats all 3 of these can lose some GORE
			if (ON_COOLDOWN(hit,"kuvalda_multihit", 2 DECI SECONDS))
				if (ON_COOLDOWN(hit,"kuvalda_multihit2", 2 DECI SECONDS))
					var/obj/decal/cleanable/blood/gibs/gib = make_cleanable(/obj/decal/cleanable/blood/gibs, get_turf(M) )
					gib.streak_cleanable(dirflag)
					if (ON_COOLDOWN(hit,"kuvalda_fullhit", 2 DECI SECONDS)) //owie
						var/turf/target = get_edge_target_turf(M, dirflag)
						M.throw_at(target, 3, 1, throw_type = THROW_GUNIMPACT)
		..()
	get_power(obj/projectile/P, atom/A)
		. = ..()
		if (isliving(A))
			if (ON_COOLDOWN(A,"kuvalda_multihit", 2 DECI SECONDS)) // er, cant blow more holes in existing ones?
				. *= 0.5


	on_end(var/obj/projectile/P)
		if (P.special_data["bleeding"])
			bleed(P.special_data["unfortunate"],10,4,get_turf(P))
			playsound(P.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 30, 1)
		..()
	tick(var/obj/projectile/P)
		if (!P.special_data["bleeding"] || P.special_data["last_projectile_locs"] == get_turf(P))
			..()
			return
		if (P.special_data["bleeding"])
			P.special_data["last_projectile_locs"] = get_turf(P)
			bleed(P.special_data["unfortunate"],0,1,P.special_data["last_projectile_locs"])
		..()

	burst
		shot_delay = 1
		shot_number = 4
		pierces = 2
		projectile_speed = 72
		dissipation_delay = 50
		armor_ignored = 0.5
		implanted = /obj/item/implant/projectile/shrapnel





/datum/projectile/bullet/flak_chunk
	name = "flak chunk"
	sname = "flak chunk"
	icon_state = "trace"
	shot_sound = null
	damage = 12
	dissipation_rate = 5
	dissipation_delay = 8
	damage_type = D_KINETIC

	splinters
		name = "burning splinter"
		armor_ignored = 0.25
		brightness = 4
		icon_state = "flare"
		damage_type = D_BURNING
		hit_type = DAMAGE_STAB
		impact_image_state = "bullethole-small"
		ricochets = TRUE
		projectile_speed = 96
		implanted = /obj/item/implant/projectile/shrapnel

		on_launch(obj/projectile/O)
			O.AddComponent(/datum/component/sniper_wallpierce, 1, 0, TRUE)

		on_hit(atom/hit, direction, obj/projectile/P)
			var/turf/T = get_turf(hit)
			var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
			s.set_up(2, 1, T)
			s.start()
			..()

/datum/projectile/bullet/stinger_ball
	name = "rubber ball"
	sname = "rubber ball"
	icon_state = "rubberball"
	implanted = /obj/item/implant/projectile/stinger_ball
	shot_sound = null
	damage = 12
	dissipation_rate = 5
	dissipation_delay = 8
	damage_type = D_KINETIC
	ricochets = TRUE
	silentshot = TRUE

/datum/projectile/bullet/grenade_fragment
	name = "grenade fragment"
	sname = "grenade fragment"
	icon_state = "grenadefragment"
	implanted = /obj/item/implant/projectile/grenade_fragment
	shot_sound = null
	damage = 12
	dissipation_rate = 5
	dissipation_delay = 8
	damage_type = D_KINETIC
	ricochets = TRUE
	silentshot = TRUE

/datum/projectile/bullet/buckshot // buckshot pellets generates by shotguns
	name = "buckshot"
	sname = "buckshot"
	icon_state = "trace"
	damage = 6
	dissipation_rate = 5
	dissipation_delay = 3
	damage_type = D_KINETIC

/datum/projectile/bullet/nails
	name = "nails"
	sname = "nails"
	icon_state = "trace"
	damage = 4
	dissipation_rate = 3
	dissipation_delay = 4
	damage_type = D_SLASHING
	casing = /obj/item/casing/shotgun/gray
	ricochets = TRUE

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
	damage = 8

/datum/projectile/bullet/improvglass
	name = "glass"
	sname = "glass"
	icon_state = "glass"
	dissipation_delay = 2
	dissipation_rate = 2
	implanted = null
	damage = 6

/datum/projectile/bullet/improvscrap
	name = "fragments"
	sname = "fragments"
	icon_state = "metalproj"
	dissipation_delay = 4
	dissipation_rate = 1
	implanted = /obj/item/implant/projectile/shrapnel
	damage = 10

/datum/projectile/bullet/improvbone
	name = "bone"
	sname = "bone"
	icon_state = "boneproj"
	dissipation_delay = 1
	dissipation_rate = 3
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	implanted = null
	damage = 9
	hit_mob_sound = 'sound/effects/skeleton_break.ogg'
	impact_image_state = null // in my mind these are just literal bones fragments being thrown at people, wouldn't stick into walls
	has_impact_particles = FALSE

	on_hit(atom/hit)
		var/turf/T = get_turf(hit)
		T.fluid_react_single("calcium", 2) // Creates 5 units of calcium on hit
	on_max_range_die(obj/projectile/O)
		var/turf/T = get_turf(O)
		T.fluid_react_single("calcium", 2) // Creates 5 units of caclium once it reaches max range.

/datum/projectile/bullet/aex
	name = "explosive slug"
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	damage = 25 // the damage should be more from the explosion
	dissipation_delay = 6
	dissipation_rate = 10
	implanted = null
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	impact_image_state = "bullethole"
	casing = /obj/item/casing/shotgun/orange

	on_hit(atom/hit)
		explosion_new(null, get_turf(hit), 2)

	on_max_range_die(obj/projectile/O)
		explosion_new(null, get_turf(O), 2)

	lawbringer
		name = "lawbringer"
		sname = "bigshot"
		damage = 1
		cost = 150

		on_hit(atom/hit)
			explosion_new(null, get_turf(hit), 4)

		on_max_range_die(obj/projectile/O)
			explosion_new(null, get_turf(O), 4)

/datum/projectile/bullet/abg
	name = "rubber slug"
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	damage = 5
	stun = 25
	dissipation_rate = 5
	dissipation_delay = 3
	implanted = null
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	impact_image_state = "bullethole"
	casing = /obj/item/casing/shotgun/blue

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if (ishuman(hit))
			var/mob/living/carbon/human/M = hit
			if(proj.power >= 16)
				var/throw_range = (proj.power > 20) ? 5 : 3

				var/turf/target = get_edge_target_turf(M, dirflag)
				M.throw_at(target, throw_range, 1, throw_type = THROW_GUNIMPACT)
				M.update_canmove()
			hit.changeStatus("staggered", clamp(proj.power/8, 5, 1) SECONDS)

/datum/projectile/bullet/potatoslug		//Improvised slug
	name = "potato"
	icon_state = "potatoslug"
	shot_sound = 'sound/weapons/launcher.ogg'
	damage = 15
	stun = 20
	dissipation_rate = 7	//Potatoes aren't very aerodynamic
	dissipation_delay = 2
	implanted = null
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	impact_image_state = null
	casing = /obj/item/casing/shotgun/pipe

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if (ishuman(hit))
			var/mob/living/carbon/human/M = hit
			if(proj.power >= 16)
				var/throw_range = min(ceil(proj.power / 10), 3)

				var/turf/target = get_edge_target_turf(M, dirflag)
				M.throw_at(target, throw_range, 1, throw_type = THROW_GUNIMPACT)
				M.update_canmove()
			hit.changeStatus("staggered", clamp(proj.power/10, 5, 1) SECONDS)

		else
			var/turf/T = get_turf(hit)
			playsound(T, 'sound/impact_sounds/Slimy_Hit_1.ogg', 100, 1)
			make_cleanable(/obj/decal/cleanable/potatosplat, T)

	on_max_range_die(obj/projectile/O)
		var/turf/T = get_turf(O)
		playsound(T, 'sound/impact_sounds/Slimy_Hit_1.ogg', 100, 1)
		make_cleanable(/obj/decal/cleanable/potatosplat, T)


/datum/projectile/bullet/sledgehammer
	name = "\"sledgehammer\" round"
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	icon_state = "buckshot"
	damage = 20
	stun = 20
	dissipation_rate = 15
	dissipation_delay = 1
	implanted = null
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	impact_image_state = "bullethole"
	casing = /obj/item/casing/shotgun/gray

	on_hit(atom/hit)
		..()
		if(istype(hit , /obj/machinery/door))
			var/obj/machinery/door/D = hit
			if(!D.cant_emag)
				D.take_damage(D.health/2) //fuck up doors without needing ex_act(1)

/datum/projectile/bullet/cryo
	name = "cryogenic slug"
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	damage = 10
	dissipation_rate = 2
	dissipation_delay = 1
	implanted = null
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	impact_image_state = null
	casing = /obj/item/casing/shotgun/blue
	has_impact_particles = FALSE

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		. = ..()
		if(isliving(hit))
			var/mob/living/L = hit
			L.bodytemperature = max(50, L.bodytemperature - proj.power * 5)
			if(L.getStatusDuration("shivering") < power)
				L.setStatus("shivering", power/2 SECONDS)
			var/obj/icecube/I = new/obj/icecube(get_turf(L), L)
			I.health = proj.power / 2

/datum/projectile/bullet/saltshot_pellet
	name = "rock salt"
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	icon_state = "trace"
	damage = 4
	dissipation_rate = 1
	dissipation_delay = 2
	implanted = null
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	impact_image_state = "bullethole"
	casing = /obj/item/casing/shotgun/gray

	on_hit(atom/hit, direction, obj/projectile/P)
		. = ..()
		if(isliving(hit))
			var/mob/living/L = hit
			L.take_eye_damage(P.power / 2)
			L.change_eye_blurry(P.power, 40)
			L.setStatus("salted", 15 SECONDS, P.power * 2)

/datum/projectile/special/spreader/buckshot_burst/salt
	name = "rock salt"
	sname = "rock salt"
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	damage = 20
	implanted = null
	casing = /obj/item/casing/shotgun/gray
	spread_projectile_type = /datum/projectile/bullet/saltshot_pellet
	speed_min = 28
	speed_max = 36
	dissipation_variance = 64
	spread_angle_variance = 7.5
	pellets_to_fire = 7
	has_impact_particles = TRUE

/datum/projectile/bullet/flare
	name = "flare"
	sname = "hotshot"
	shot_sound = 'sound/weapons/flaregun.ogg'
	damage = 20
	cost = 1
	damage_type = D_BURNING
	hit_type = null
	brightness = 1
	color_red = 1
	color_green = 0.3
	color_blue = 0
	icon_state = "flare"
	implanted = null
	impact_image_state = "bullethole"
	casing = /obj/item/casing/shotgun/orange

	on_hit(atom/hit, direction, obj/projectile/P)
		if (isliving(hit))
			fireflash(get_turf(hit) || get_turf(P), 0, chemfire = CHEM_FIRE_RED)
			hit.changeStatus("staggered", clamp(P.power/8, 5, 1) SECONDS)
		else if (isturf(hit))
			fireflash(hit, 0, chemfire = CHEM_FIRE_RED)
		else
			fireflash(get_turf(hit) || get_turf(P), 0, chemfire = CHEM_FIRE_RED)

/datum/projectile/bullet/space_phoenix_icicle
	name = "ice feather"
	sname = "ice feather"
	icon_state = "laser_anim_blue"
	damage = 0.0001 // unique effect per atom hit, but set to non-zero to bypass 0 power/damage checks
	damage_type = D_PIERCING
	hit_type = DAMAGE_STAB
	armor_ignored = 1
	disruption = 0
	dissipation_delay = 6
	shot_sound = 'sound/effects/swoosh2.ogg'
	shot_volume = 50
	implanted = /obj/item/implant/projectile/ice_feather

	on_pre_hit(atom/hit, angle, obj/projectile/P)
		. = ..()
		if (istype(hit, /mob/living) && !istype(hit, /mob/living/critter/space_phoenix))
			var/mob/living/L = hit
			L.TakeDamage("All", 2.5, 5, damage_type = src.damage_type)
			L.bodytemperature -= 3
			L.changeStatus("shivering", 3 SECONDS * (1 - 0.75 * L.get_cold_protection() / 100), TRUE)
		else if (isvehicle(hit))
			src.damage = 25
			src.disruption = 5
			var/turf/T = get_turf(hit)
			if (!istype(T, /turf/space))
				src.damage = 5
				src.disruption = 0
				hit.visible_message(SPAN_ALERT("[P] hits [hit] with almost no effect! The phoenix's power is too weak with [hit] not in space!"))
			else
				if (P.shooter.hasStatus("phoenix_empowered_feather"))
					P.shooter.delStatus("phoenix_empowered_feather")
					SPAWN(10 SECONDS)
						P.shooter.setStatus("phoenix_empowered_feather", INFINITE_STATUS)
					var/obj/machinery/vehicle/vehicle = hit
					if (istype(vehicle))
						src.damage += vehicle.health * 0.1
						src.disruption = 25
		src.generate_stats()
		P.initial_power = src.power

	on_hit(atom/hit, direction, obj/projectile/P)
		if (istype(hit, /obj/window))
			hit.visible_message(SPAN_ALERT("[P] uselessly clunks off [hit]!"))
			playsound(hit, 'sound/impact_sounds/Glass_Hit_1.ogg', 75, TRUE)
		. = ..()

	on_end(obj/projectile/P)
		src.damage = initial(src.damage)
		src.disruption = initial(src.disruption)
		src.generate_stats()
		P.initial_power = src.power
		..()

/datum/projectile/bullet/flare/UFO
	name = "heat beam"
	window_pass = 1
	icon_state = "plasma"
	casing = null

//0.787
/datum/projectile/bullet/cannon // autocannon should probably be renamed next
	name = "20mm AP round"
	brightness = 0.7
	window_pass = 0
	icon_state = "20mm"
	damage_type = D_PIERCING
	armor_ignored = 0.8
	hit_type = DAMAGE_STAB
	damage = 100
	dissipation_delay = 30
	dissipation_rate = 5
	cost = 1
	shot_sound = 'sound/weapons/20mm.ogg'
	shot_volume = 100
	implanted = null
	projectile_speed = 128

	impact_image_state = "bullethole-large"
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
			new /obj/effects/explosion/smoky(T)
			var/impact = clamp(1,3, proj.pierces_left % 4)

			if(hit && ismob(hit))
				var/mob/living/M = hit
				var/throw_range = 10
				var/turf/target = get_edge_target_turf(M, dirflag)
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
				O.meteorhit()

			if(hit && isturf(hit))
				T.throw_shrapnel(T, 1, 1)
				T.meteorhit()

	antiair_burst
		shot_number = 4

//1.0
/datum/projectile/bullet/rod // for the coilgun
	name = "metal rod"
	damage = 50
	damage_type = D_KINETIC
	hit_type = DAMAGE_STAB
	window_pass = 0
	icon_state = "rod_1"
	dissipation_delay = 25
	shot_sound = 'sound/weapons/ACgun2.ogg'
	casing = null
	impact_image_state = "bullethole-large"

	on_hit(atom/hit)
		explosion_new(null, get_turf(hit), 5)

/datum/projectile/bullet/four_bore
	name = "termination round"
	sname = "terminate"
	icon_state = "20mm"
	shot_sound = 'sound/weapons/fourboreshot.ogg'
	damage = 95
	dissipation_rate = 8
	dissipation_delay = 10
	armor_ignored = 0.4
	cost = 1
	projectile_speed = 72
	implanted = null
	hit_type = DAMAGE_STAB
	damage_type = D_PIERCING
	impact_image_state = "bullethole-large"
	casing = /obj/item/casing/cannon
	ricochets = FALSE
	hit_ground_chance = 50
	shot_volume = 130
	shot_sound_extrarange = 1

	on_launch(obj/projectile/proj)
		proj.AddComponent(/datum/component/sniper_wallpierce, 1) //pierces 1 walls/lockers/doors/etc. Does not function on restricted Z, rwalls and blast doors use 2 pierces
		for(var/mob/M in range(proj.loc, 2))
			shake_camera(M, 3, 4)

	on_hit(atom/hit, dirflag, obj/projectile/P)
		var/turf/T = get_turf(hit)

		if(hit && isobj(hit))
			new /obj/effects/rendersparks (T)
			var/obj/O = hit
			O.throw_shrapnel(T, 1, 1)

			if(istype(hit, /obj/machinery/door))
				var/obj/machinery/door/D = hit
				if(!D.cant_emag)
					D.take_damage(P.power * 2.5) //mess up doors a ton

			else if(istype(hit, /obj/window))
				var/obj/window/W = hit
				W.damage_blunt(P.power * 1.75) //and windows too, but maybe a bit less

		if (hit && ismob(hit))
			var/mob/M = hit
			if(ishuman(hit))
				var/mob/living/carbon/human/H = hit
				#ifdef USE_STAMINA_DISORIENT
				H.do_disorient(max(P.power,10), knockdown = 2 SECONDS, stunned = 2 SECONDS, disorient = 0, remove_stamina_below_zero = FALSE)
				#else
				H.changeStatus("stunned", 4 SECONDS)
				H.changeStatus("knockdown", 3 SECONDS)
				#endif
			var/turf/target = get_edge_target_turf(hit, dirflag)
			M.throw_at(target, max(round(P.power / 20), 0), 3, throw_type = THROW_GUNIMPACT)

		if(hit && isturf(hit))
			new /obj/effects/rendersparks (T)
			T.throw_shrapnel(T, 1, 1)

		..()

/datum/projectile/bullet/four_bore_stunners //behavior is distinct enough to not be a child of four_bore lethals
	name = "roundhouse slug"
	sname = "roundhouse"
	icon_state = "20mm"
	shot_sound = 'sound/weapons/fourboreshot.ogg'
	damage = 15
	stun = 105
	dissipation_rate = 12
	dissipation_delay = 10
	cost = 1
	projectile_speed = 54
	implanted = null
	hit_type = DAMAGE_BLUNT
	damage_type = D_KINETIC
	impact_image_state = null
	casing = /obj/item/casing/cannon
	ricochets = TRUE

	on_launch(obj/projectile/proj)
		for(var/mob/M in range(proj.loc, 2))
			shake_camera(M, 2, 4)

	on_hit(atom/hit, dirflag, obj/projectile/P)
		if(hit && isobj(hit) && istype(hit, /obj/window))
			var/obj/window/W = hit
			W.damage_blunt(P.power / 2.5) //even if it aint metal, its gonna crack a window

		if (hit && ismob(hit))
			var/mob/M = hit
			var/turf/target = get_edge_target_turf(hit, dirflag)
			M.throw_at(target, max(round(P.power / 35), 0), 3, throw_type = THROW_GUNIMPACT)
		..()

//1.57
datum/projectile/bullet/autocannon
	name = "HE grenade"
	window_pass = 0
	icon_state = "40mm_lethal"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	damage = 25
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/rocket.ogg'
	impact_image_state = "bullethole-large"
	casing = /obj/item/casing/grenade

	on_hit(atom/hit)
		explosion_new(null, get_turf(hit), 12)


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
		damage = 50
		shot_sound = 'sound/machines/engine_alert3.ogg'
		impact_image_state = null
		casing = null

	huge
		icon_state = "400mm"
		damage = 100
		impact_image_state = "bullethole-large"

		on_hit(atom/hit)
			explosion_new(null, get_turf(hit), 80)


	seeker
		name = "drone-seeking grenade"
		damage = 50 //even if they don't explode, you FEEL this one
		var/max_turn_rate = 20
		var/type_to_seek = /obj/critter/gunbot/drone //what are we going to seek
		precalculated = 0
		on_hit(atom/hit, angle, obj/projectile/P)
			if (P.data)
				..()
			else
				new /obj/effects/rendersparks(hit.loc)
				if(ishuman(hit))//copypasted shamelessly from singbuster rockets
					var/mob/living/carbon/human/M = hit
					boutput(M, SPAN_ALERT("You are struck by an autocannon round! Thankfully it was not armed."))
					M.do_disorient(stunned = 40)


		on_launch(obj/projectile/P)
			var/D = locate(type_to_seek) in range(15, P)
			if (D)
				P.data = D

		tick(obj/projectile/P)
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
	damage = 5
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/launcher.ogg'
	impact_image_state = "bullethole-large"
	casing = /obj/item/casing/grenade

	explosive
		name = "40mm HEDP round"

		on_hit(atom/hit)
			explosion_new(null, get_turf(hit), 2.5, 1.75)

	high_explosive //more powerful than HEDP
		name = "40mm HE round"
		damage = 10

		on_hit(atom/hit)
			explosion_new(null,get_turf(hit), 8, 0.75)

		double
			shot_delay = 0.20 SECONDS
			shot_number = 2
			damage = 50
			shot_sound = 'sound/effects/exlow.ogg'

/datum/projectile/bullet/smoke
	name = "smoke grenade"
	sname = "smokeshot"
	window_pass = 0
	icon_state = "40mm_smoke"
	damage_type = D_KINETIC
	damage = 25
	dissipation_delay = 10
	cost = 1
	shot_sound = 'sound/weapons/launcher.ogg'
	impact_image_state = "bullethole-large"
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
	damage = 15
	dissipation_delay = 10
	cost = 1
	shot_sound = 'sound/weapons/launcher.ogg'
	impact_image_state = "bullethole-large"
	casing = /obj/item/casing/grenade
	hit_type = DAMAGE_BLUNT
	hit_mob_sound = 'sound/misc/splash_1.ogg'
	hit_object_sound = 'sound/misc/splash_1.ogg'
	implanted = null
	has_impact_particles = FALSE


	on_hit(atom/hit, dirflag, atom/projectile)
		..()
		hit.setStatus("marker_painted", 30 SECONDS)

/datum/projectile/bullet/pbr //direct less-lethal 40mm option
	name = "plastic baton round"
	icon_state = "40mm_nonlethal"
	shot_sound = 'sound/weapons/launcher.ogg'
	damage = 25
	stun = 50
	dissipation_rate = 5
	dissipation_delay = 4
	max_range = 9
	implanted = null
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	impact_image_state = "bullethole-large"
	casing = /obj/item/casing/grenade
	ie_type = null

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if (ishuman(hit))
			var/mob/living/carbon/human/M = hit
			if(proj.power >= 20)
				var/throw_range = (proj.power > 30) ? 5 : 3

				var/turf/target = get_edge_target_turf(M, dirflag)
				M.changeStatus("stunned", 1 SECONDS)
				M.changeStatus("knockdown", 2 SECONDS)
				M.throw_at(target, throw_range, 1, throw_type = THROW_GUNIMPACT)
				M.update_canmove()
			hit.changeStatus("staggered", clamp(proj.power/8, 5, 1) SECONDS)
		if(!ismob(hit))
			shot_volume = 0
			var/obj/projectile/P = shoot_reflected_bounce(proj, hit, 1, PROJ_NO_HEADON_BOUNCE)
			shot_volume = 100
			if(P)
				P.travelled = max(proj.travelled, (max_range-2) * 32)

/datum/projectile/bullet/stunbaton //direct less-lethal 40mm option
	name = "stun baton round"
	icon_state = "stunbaton"
	shot_sound = 'sound/weapons/launcher.ogg'
	damage = 0
	stun = 50
	dissipation_rate = 0
	dissipation_delay = 4
	max_range = 12
	implanted = null
	damage_type = D_SPECIAL
	hit_type = DAMAGE_BLUNT
	hit_mob_sound = 'sound/impact_sounds/Energy_Hit_3.ogg'
	impact_image_state = "bullethole-large"
	casing = /obj/item/casing/grenade
	ie_type = null

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if (isliving(hit))
			var/mob/living/L = hit
			L.do_disorient(130, knockdown = 15 SECONDS, disorient = 6 SECONDS)

			L.Virus_ShockCure(33)
			L.shock_cyberheart(33)


/datum/projectile/bullet/grenade_shell
	name = "40mm grenade conversion shell"
	window_pass = 0
	icon_state = "40mm_lethal"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	damage = 25
	dissipation_delay = 20
	cost = 1
	shot_sound = 'sound/weapons/launcher.ogg'
	impact_image_state = "bullethole-large"
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
					src.damage = CHEM.launcher_damage
					src.has_grenade = 1
					return 1
				else if (istype(W, /obj/item/old_grenade))
					src.OLD = W
					src.damage = OLD.launcher_damage
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
				var/obj/item/chem_grenade/C = CHEM.launcher_clone()
				C.invisibility = INVIS_ALWAYS
				C.set_loc(T)
				src.has_det = 1
				SPAWN(1 DECI SECOND)
					C.explode()
				return
			else if (src.OLD != null)
				var/obj/item/old_grenade/O = OLD.launcher_clone()
				O.invisibility = INVIS_ALWAYS
				O.set_loc(T)
				src.has_det = 1
				SPAWN(1 DECI SECOND)
					O.detonate()
				return
			else //what the hell happened
				return
		else
			return

	on_hit(atom/hit, angle, obj/projectile/O)
		var/turf/T = get_turf(hit)
		if (T)
			if (T.density) // hit previous (non-dense) turf to spread chems/effects better
				T = get_turf(get_step(T, turn(angle, 180)))
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

/datum/projectile/bullet/breach_flashbang
	name = "door-breaching flashbang"
	window_pass = 0
	icon_state = "40mm_lethal"
	damage_type = D_KINETIC
	damage = 20
	dissipation_delay = 20
	cost = 1
	shot_sound = 'sound/weapons/launcher.ogg'
	impact_image_state = "bullethole-large"
	casing = /obj/item/casing/grenade
	implanted = null
	has_impact_particles = FALSE

	on_launch(obj/projectile/O)
		. = ..()
		O.AddComponent(/datum/component/proj_door_breach)

	on_end(obj/projectile/O)
		var/obj/machinery/door/breached = O.special_data["door_hit"]
		if(istype(breached) && !QDELETED(breached) && !breached.cant_emag)
			var/turf/T = get_turf(O)
			flashpowder_reaction(T, 50)
			sonicpowder_reaction(T, 50)
			breached.open()
		. = ..()

//1.58
// Ported from old, non-gun RPG-7 object class (Convair880).
/datum/projectile/bullet/rpg
	name = "MPRT rocket"
	window_pass = 0
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "rpg_rocket"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	damage = 40
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/rocket.ogg'
	impact_image_state = "bullethole-large"

	on_hit(atom/hit)
		var/turf/T = get_turf(hit)
		if (T)
			for (var/mob/living/carbon/human/M in view(hit, 2))
				M.TakeDamage("chest", 15/M.get_ranged_protection(), 0)
				if (M.get_ranged_protection()>=1.5)
					boutput(M, SPAN_ALERT("Your armor blocks the shrapnel!"))
				else
					var/obj/item/implant/projectile/shrapnel/implanted = new /obj/item/implant/projectile/shrapnel
					implanted.implanted(M, null, 2)
					boutput(M, SPAN_ALERT("You are struck by shrapnel!"))

			T.hotspot_expose(700,125)
			explosion_new(null, T, 36, range_cutoff_fraction = 0.45)
		return

/datum/projectile/bullet/homing
	var/min_speed = 0
	var/max_speed = 2
	var/start_speed = 2
	var/easemult = 0.

	var/auto_find_targets = 1
	var/list/targets = list()
	var/homing_active = 1

	var/desired_x = 0
	var/desired_y = 0

	var/rotate_proj = 1
	var/max_rotation_rate = 1
	var/face_desired_dir = 0

	precalculated = FALSE

	on_launch(var/obj/projectile/P)
		..()
		P.internal_speed = start_speed

		if (auto_find_targets)
			P.targets = list()
			for(var/atom/A as anything in view(P,15))
				if (!is_valid_target(A, P)) continue
				P.targets += A

		if (length(src.targets))
			P.targets = src.targets
			src.targets = list()

	proc/is_valid_target(atom/A, obj/projectile/P)
		return (A != P.shooter && A != P.mob_shooter)

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

			if(ismovable(closest))
				var/atom/movable/AM = closest
				if(AM.bound_width > 32)
					desired_x += AM.bound_width / 64 - 0.5
				if(AM.bound_height > 32)
					desired_y += AM.bound_height / 64 - 0.5

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
				angle_diff = -clamp(angle_diff, -src.max_rotation_rate, src.max_rotation_rate)
				P.rotateDirection(angle_diff)

		..()

ABSTRACT_TYPE(/datum/projectile/bullet/homing/rocket)
/datum/projectile/bullet/homing/rocket
	name = "Rocket"
	window_pass = 0
	icon = 'icons/obj/projectiles.dmi'
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	dissipation_delay = 30
	shot_sound = 'sound/weapons/rocket.ogg'
	impact_image_state = "bullethole-large"
	shot_number = 1
	cost = 1
	damage = 15
	icon_state = "mininuke"
	max_speed = 10
	start_speed = 10
	shot_delay = 1 SECONDS
	var/explosion_power = 15

	on_hit(atom/hit, angle, obj/projectile/P)
		var/turf/T = get_turf(hit)
		if (T)
			for (var/mob/living/carbon/human/M in view(hit, 2))
				M.TakeDamage("chest", 15/M.get_ranged_protection(), 0)
				if (M.get_ranged_protection()>=1.5)
					boutput(M, SPAN_ALERT("Your armor blocks the shrapnel!"))
				else
					var/obj/item/implant/projectile/shrapnel/implanted = new /obj/item/implant/projectile/shrapnel
					implanted.implanted(M, null, 2)
					boutput(M, SPAN_ALERT("You are struck by shrapnel!"))

			T.hotspot_expose(700,125)
			explosion_new(null, T, src.explosion_power, range_cutoff_fraction = 0.45)
			P.die()

/datum/projectile/bullet/homing/rocket/gunbot_drone
	max_rotation_rate = 5
	dissipation_delay = 15
	start_speed = 15
	explosion_power = 5

	is_valid_target(atom/A, obj/projectile/P)
		. = ..()
		return . && (isvehicle(A) || isliving(A) && !isintangible(A))

/datum/projectile/bullet/homing/rocket/mrl
	name = "MRL rocket"

	is_valid_target(mob/M, obj/projectile/P)
		. = ..()
		return . && isliving(M) && !isintangible(M)

/datum/projectile/bullet/homing/rocket/salvo
	name = "Salvo Rocket"
	max_rotation_rate = 5
	dissipation_delay = 30
	start_speed = 15
	explosion_power = 1
	shot_delay = 0.3 SECONDS
	var/initial_projectile = TRUE

	is_valid_target(atom/A, obj/projectile/P)
		. = ..()
		return . && (isvehicle(A) || isliving(A) && !isintangible(A))

/datum/projectile/bullet/homing/pod_seeking_missile
	name = "pod-seeking missile"
	window_pass = 0
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "pod_seeking_missile"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	damage = 15
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/rocket.ogg'
	impact_image_state = "bullethole-large"

	max_rotation_rate = 7
	max_speed = 30
	start_speed = 30
	shot_delay = 1 SECONDS
	auto_find_targets = FALSE

	on_launch()
		..()
		for (var/obj/machinery/vehicle/pod in src.targets)
			var/message = "Pod-seeking missile lock-on detected!"
			for(var/mob/M in pod)
				M.playsound_local(src, 'sound/machines/whistlealert.ogg', 25)
				boutput(M, pod.ship_message(message))

	on_hit(atom/hit, angle, obj/projectile/O)
		if (istype(hit, /obj/critter/gunbot/drone) || istype(hit, /obj/machinery/vehicle/miniputt) || istype(hit, /obj/machinery/vehicle/pod_smooth)|| istype(hit, /obj/machinery/vehicle/tank) || istype(hit, /mob/living/critter/space_phoenix))
			explosion_new(null, get_turf(O), 12)

			if(istype(hit, /obj/machinery/vehicle))
				var/obj/machinery/vehicle/vehicle = hit
				vehicle.health -= vehicle.maxhealth / 4

		else
			new /obj/effects/rendersparks(hit.loc)
			if(ishuman(hit))
				var/mob/living/carbon/human/M = hit
				boutput(M, SPAN_ALERT("You are struck by a [src.name]! Thankfully it was not armed."))
				M.do_disorient(stunned = 40)

/datum/projectile/bullet/antisingularity
	name = "Singularity buster rocket"
	window_pass = 0
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "regrocket"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	damage = 5
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/rocket.ogg'
	impact_image_state = "bullethole-large"
	implanted = null

	on_hit(atom/hit, dirflag)
		var/obj/machinery/the_singularity/S = hit
		if(istype(S))
			new /obj/whitehole(S.loc, 0 SECONDS, 30 SECONDS)
			qdel(S)
		else
			new /obj/effects/rendersparks(hit.loc)
			if(ishuman(hit))
				var/mob/living/carbon/human/M = hit
				M.TakeDamage("chest", 15/M.get_ranged_protection(), 0)
				var/turf/target = get_edge_target_turf(M, dirflag)
				M.throw_at(target, 8, 1, throw_type = THROW_GUNIMPACT)
				M.update_canmove()
				boutput(M, SPAN_ALERT("You are struck by a big rocket! Thankfully it was not the exploding kind."))
				M.do_disorient(stunned = 40)

/datum/projectile/bullet/mininuke //Assday only.
	name = "miniature nuclear warhead"
	window_pass = 0
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "mininuke"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	damage = 120
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/rocket.ogg'
	impact_image_state = "bullethole-large"
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
	damage = 0
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "crescent_white"
	dissipation_delay = 15
	dissipation_rate = 2
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	impact_image_state = "bullethole"
	implanted = null
	casing = null
	cost = 1
	has_impact_particles = FALSE

	on_hit(atom/hit, dirflag)
		if (ishuman(hit))
			var/mob/living/carbon/human/M = hit
			var/turf/target = get_edge_target_turf(M, dirflag)
			M.do_disorient(15, knockdown = 10)
			M.throw_at(target, 6, 3, throw_type = THROW_GUNIMPACT)

/datum/projectile/bullet/airzooka/bad
	name = "plasmaburst"
	shot_sound = 'sound/weapons/airzooka.ogg'
	damage = 15
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "40mmgatling"
	dissipation_delay = 15
	dissipation_rate = 4
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	impact_image_state = "bullethole"
	implanted = null
	casing = null
	cost = 2

	on_hit(atom/hit, dirflag)
		fireflash(get_turf(hit), 1, chemfire = CHEM_FIRE_RED)
		if (ishuman(hit))
			var/mob/living/carbon/human/M = hit
			var/turf/target = get_edge_target_turf(M, dirflag)
			M.do_disorient(15, knockdown = 25)
			M.throw_at(target, 12, 3, throw_type = THROW_GUNIMPACT)

//misc (i dont know where to place the rest)- owari
/datum/projectile/bullet/shrapnel // for explosions
	name = "shrapnel"
	damage = 10
	damage_type = D_PIERCING
	armor_ignored = 0.66
	hit_type = DAMAGE_CUT
	window_pass = 0
	icon = 'icons/obj/scrap.dmi'
	icon_state = "2metal0"
	casing = null
	impact_image_state = "bullethole-staple"

	shrapnel_implant
		implanted = /obj/item/implant/projectile/shrapnel

/datum/projectile/bullet/glass_shard // for explosions of glass
	name = "glass"
	damage_type = D_PIERCING
	icon_state = "glass"
	implanted = /obj/item/implant/projectile/glass_shard
	window_pass = FALSE
	damage = 6

/datum/projectile/bullet/howitzer
	name = "high explosive round"
	brightness = 0.7
	window_pass = 0
	icon_state = "120mm"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	damage = 200
	stun = 200
	dissipation_delay = 300
	dissipation_rate = 5
	cost = 1
	shot_sound = 'sound/effects/explosion_new2.ogg'
	shot_volume = 90
	implanted = null

	impact_image_state = "bullethole-large"
	casing = /obj/item/casing/cannon
	shot_sound_extrarange = 1
	projectile_speed = 48

	on_hit(atom/hit, obj/projectile/P)
		var/turf/T = get_turf(hit)
		explosion_new(null, T, 40)
		for(var/turf/T2 in range(hit, 3))
			spawn(rand(1,2))
				new /obj/effects/explosion/dangerous(T2)

	on_launch(obj/projectile/proj)
		for(var/mob/M in range(proj.loc, 2))
			shake_camera(M, 2, 4)

	siege
		name = "siege round"
		icon_state = "305mm"
		damage = 1600
		projectile_speed = 24
		shot_sound = 'sound/effects/explosion_new1.ogg'

		on_hit(atom/hit, obj/projectile/P)
			var/turf/T = get_turf(hit)
			explosion_new(null, T, 80)
			for(var/turf/T2 in range(hit, 4))
				spawn(rand(1,2))
					new /obj/effects/explosion/dangerous(T2)


/datum/projectile/bullet/glitch
	name = "bullet"
	window_pass = 1
	icon_state = "glitchproj"
	damage_type = D_KINETIC
	hit_type = null
	damage = 30
	dissipation_delay = 12
	cost = 1
	shot_sound = 'sound/effects/glitchshot.ogg'
	casing = null
	impact_image_state = null

	New()
		..()
		src.name = pick("weird", "puzzling", "odd", "strange", "baffling", "creepy", "unusual", "confusing", "discombobulating") + " bullet"
		src.name = corruptText(src.name, 66)

	on_hit(atom/hit)
		hit.icon_state = pick(get_icon_states(hit.icon))

		for(var/atom/a in hit)
			a.icon_state = pick(get_icon_states(a.icon))

		playsound(hit, 'sound/machines/glitch3.ogg', 50, TRUE)

/datum/projectile/bullet/glitch/gun
	damage = 1

/datum/projectile/bullet/frog/ //sorry for making this, players -ZeWaka
	name = "green splat" //thanks aibm for wording this beautifully
	window_pass = 0
	icon_state = "acidspit"
	hit_type = null
	damage_type = 0
	damage = 0
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
	damage = 1
	cost = 15				//This should either cost a lot or a little I don't know. On one hand if it costs nothing you can truly tormet clowns with it, but on the other hand if it costs your full charge, then the clown will know how much you hate it because of how much you sacraficed to harm it. I settled for a med amount...
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	implanted = null
	shot_sound = 'sound/impact_sounds/Generic_Snap_1.ogg'
	impact_image_state = "bullethole-staple"
	casing = null
	hit_ground_chance = 50
	icon_state = "random_thing"	//actually exists, looks funny enough to use as the projectile image for this
	has_impact_particles = FALSE

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
				playsound(H, 'sound/musical_instruments/Bikehorn_1.ogg', 50, TRUE)

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
	damage = 7.2
	dissipation_rate = 1
	dissipation_delay = 45
	damage_type = D_KINETIC
	hit_type = DAMAGE_STAB
	shot_sound = null
	projectile_speed = 12
	implanted = null

/datum/projectile/bullet/wall_buster_shrapnel // for nuclear meltdowns
	name = "shrapnel"
	damage = 70
	damage_type = D_PIERCING
	armor_ignored = 0.66
	hit_type = DAMAGE_CUT
	window_pass = 0
	icon = 'icons/obj/scrap.dmi'
	icon_state = "2metal0"
	casing = null
	impact_image_state = "bullethole-staple"
	implanted = /obj/item/implant/projectile/shrapnel/radioactive

	on_hit(atom/hit, angle, obj/projectile/O)
		if(!ismob(hit))
			//I'm onto you with your stacks of thindows
			var/turf/hitloc = hit.loc
			if(isturf(hit)) //did you know that turf.loc is /area? because I didn't
				hitloc = hit
			for(var/obj/window/maybe_thindow in hitloc)
				maybe_thindow.ex_act(2)
			for(var/obj/structure/girder/girderstack in hitloc)
				girderstack.ex_act(2)
			//let's pretend these walls/objects were destroyed in the explosion
			hit.ex_act(pick(1,2))
		. = ..()

/datum/projectile/bullet/wall_buster_shrapnel/turbine_blade
	name = "turbine blade"
	implanted = null //just delimbs mobs, doesn't stick in them
	damage = 100

	on_hit(atom/hit, angle, obj/projectile/O)
		if(istype(hit, /obj/machinery/atmospherics/binary/nuclear_reactor))
			return FALSE //the turbine blades sail gracefully over the reactor
		if(istype(hit, /mob/living/carbon/human)) //run a chance to cut off a limb or head
			var/mob/living/carbon/human/H = hit
			if(prob(65))
				H.sever_limb(pick("l_arm","r_arm","l_leg","r_leg"))
			else
				var/obj/item/organ/head = H.organHolder.drop_organ("head")
				head.splat(get_turf(H))
			return TRUE //keep going
		. = ..() //else do normal collisions, this will kill most non-human mobs in one hit


/datum/projectile/bullet/webley
	name = "bullet"
	damage = 45
	stun = 7
	damage_type = D_PIERCING
	armor_ignored = 0.5 //just enough to get past gang vests in 3 shots
	implanted = /obj/item/implant/projectile/bullet_455
	impact_image_state = "bullethole-small"
	casing = /obj/item/casing/medium
	ricochets = TRUE

/datum/projectile/bullet/hammer_railgun
	name = "metallic projectile"
	damage = 25
	icon_state = "sniper_bullet"
	damage_type = D_PIERCING
	hit_type = DAMAGE_STAB
	shot_sound = 'sound/weapons/railgun.ogg'
	shot_volume = 50
	dissipation_delay = 10
	dissipation_rate = 10
	impact_image_state = "bullethole-small"
	ricochets = TRUE

	on_launch(obj/projectile/O)
		O.AddComponent(/datum/component/sniper_wallpierce, 3, 0, TRUE)
