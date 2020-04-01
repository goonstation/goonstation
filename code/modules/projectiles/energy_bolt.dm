/datum/projectile/energy_bolt
	name = "energy bolt"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "taser_projectile"
//How much of a punch this has, tends to be seconds/damage before any resist
	power = 20
//How much ammo this costs
	cost = 15
//How fast the power goes away
	dissipation_rate = 2
//How many tiles till it starts to lose power
	dissipation_delay = 2
//Kill/Stun ratio
	ks_ratio = 0.0
//name of the projectile setting, used when you change a guns setting
	sname = "stun"
//file location for the sound you want it to play
	shot_sound = 'sound/weapons/Taser.ogg'
//How many projectiles should be fired, each will cost the full cost
	shot_number = 1
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
	damage_type = D_ENERGY
	//With what % do we hit mobs laying down
	hit_ground_chance = 0
	//Can we pass windows
	window_pass = 0
	brightness = 1
	color_red = 0.9
	color_green = 0.9
	color_blue = 0.1

	disruption = 8

	hit_mob_sound = 'sound/effects/sparks6.ogg'

	on_pointblank(var/obj/projectile/P, var/mob/living/M)
		stun_bullet_hit(P, M)


//Any special things when it hits shit?
	/* this is now handled in the projectile parent on_hit for all ks_ratio 0.0 weapons.
	on_hit(atom/hit)
		if (ishuman(hit))
			var/mob/living/carbon/human/H = hit
			H.changeStatus("slowed", power)
			H.change_misstep_chance(5)
			H.emote("twitch_v")
			if (H.getStatusDuration("slowed") > power)
				H.changeStatus("stunned", power)
		return*/

/datum/projectile/heavyion
	name = "ion bolt"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "heavyion"
	power = 20
	cost = 25
	dissipation_rate = 2
	dissipation_delay = 8
	ks_ratio = 1
	shot_sound = 'sound/weapons/heavyion.ogg'
	shot_number = 1
	damage_type = D_ENERGY
	hit_ground_chance = 0
	brightness = 0.8
	color_red = 0.2
	color_green = 0.6
	color_blue = 0.8

	on_hit(atom/hit)
		if (isliving(hit))
			var/mob/living/L = hit
			L.changeStatus("slowed", 2 SECONDS)
			L.change_misstep_chance(5)
			L.emote("twitch_v")
		impact_image_effect("E", hit)
		return

/datum/projectile/energy_bolt/robust
	power = 45
	dissipation_rate = 6

/datum/projectile/energy_bolt/burst
	shot_number = 3
	cost = 50
	sname = "burst stun"


/datum/projectile/energy_bolt/tiny
	power = 2.5
	cost = 10
	sname = "teeny bolt"


	on_pointblank(var/obj/projectile/P, var/mob/living/M)
		M.changeStatus("slowed", 2 SECONDS)
		M.change_misstep_chance(1)
		M.emote("twitch_v")

	on_hit(atom/hit)
		if (isliving(hit))
			var/mob/living/L = hit
			L.changeStatus("slowed", 1 SECOND)
			L.change_misstep_chance(1)
			L.emote("twitch_v")
		return

/datum/projectile/energy_bolt/tasershotgun //Projectile for Azungar's taser shotgun.
	power = 0
	dissipation_delay = 6
	icon_state = "spark"

	on_hit(atom/hit, angle, var/obj/projectile/O) //MBC : what the fuck shouldn't this all be in bullet_act on human in damage.dm?? this split is giving me bad vibes
		if(ks_ratio == 0) //stun projectiles only
			if (isliving(hit))
				var/mob/living/L = hit

#ifdef USE_STAMINA_DISORIENT
				L.do_disorient(stamina_damage = 45, weakened = 50, stunned = 80, disorient = 20, remove_stamina_below_zero = 0)
				L.emote("twitch_v")
#else
				L.changeStatus("slowed", power)
				L.change_misstep_chance(5)
				L.emote("twitch_v")
			if (L.getStatusDuration("slowed") > power)
				L.changeStatus("stunned", power)
			if (L.getStatusDuration("weakened") > 0) //weaken from stamina does not stack, this allows it to for stun guns
				L.changeStatus("weakened", power)
#endif


//////////// VUVUZELA
/datum/projectile/energy_bolt_v
	name = "vuvuzela bolt"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "v_sound"
//How much of a punch this has, tends to be seconds/damage before any resist
	power = 50 // 100 was way too fucking long what the HECK
//How much ammo this costs
	cost = 25
//How fast the power goes away
	dissipation_rate = 5
//How many tiles till it starts to lose power
	dissipation_delay = 1
//Kill/Stun ratio
	ks_ratio = 0.0
//name of the projectile setting, used when you change a guns setting
	sname = "sonic wave"
//file location for the sound you want it to play
	shot_sound = 'sound/musical_instruments/Vuvuzela_1.ogg'
//How many projectiles should be fired, each will cost the full cost
	shot_number = 1
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
	damage_type = D_ENERGY
	//With what % do we hit mobs laying down
	hit_ground_chance = 0
	//Can we pass windows
	window_pass = 0

	disruption = 0

//Any special things when it hits shit?
	on_hit(atom/hit)
		if (isliving(hit))
			var/mob/living/L = hit
			L.apply_sonic_stun(1.5, 0, 25, 10, 0, rand(1, 3), stamina_damage = 80)
			impact_image_effect("T", hit)
		return

	on_pointblank(var/obj/projectile/P, var/mob/living/M)
		M.apply_sonic_stun(3, 0, 25, 20, 0, rand(2, 4), stamina_damage = 80)
		stun_bullet_hit(P, M)
		impact_image_effect("T", M)

//////////// Ghost Hunting for Halloween
/datum/projectile/energy_bolt_antighost
	name = "ectoplasmic bolt"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "green_spark"
//How much of a punch this has, tends to be seconds/damage before any resist
	power = 2
//How much ammo this costs
	cost = 25
//How fast the power goes away
	dissipation_rate = 2
//How many tiles till it starts to lose power
	dissipation_delay = 4
//Kill/Stun ratio
	ks_ratio = 0.0
//name of the projectile setting, used when you change a guns setting
	sname = "deghostify"
//file location for the sound you want it to play
	shot_sound = 'sound/weapons/Taser.ogg'
//How many projectiles should be fired, each will cost the full cost
	shot_number = 1

	damage_type = D_ENERGY
	//With what % do we hit mobs laying down
	hit_ground_chance = 0
	//Can we pass windows
	window_pass = 0
	brightness = 0.8
	color_red = 0.2
	color_green = 0.8
	color_blue = 0.2

	disruption = 0


//Projectile for Azungars NT gun.
/datum/projectile/energy_bolt/ntburst // fixed overlapping path - /datum/projectile/energy_bolt/burst already exists for taser burst fire
	shot_number = 1
	power = 15
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "minispark"
	cost = 5
	sname = "burst stun"

//lawgiver detain
/datum/projectile/energy_bolt/aoe
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "detain-projectile"
	power = 20
	cost = 50
	dissipation_rate = 6
	color_red = 255
	color_green = 165
	color_blue = 0
	var/distance = 6		//Distance needs to be explicitly set before usage. in shoot// currently only used for the Lawgiver
	var/hit = 0				//This hit var and the on_hit on_end nonsense was to make it so that if it hits a guy, the explosion starts on them and not one tile before, but if it hits a wall, it explodes on the floor tile in front of it

	//die/detonate when you go the required distance
	tick(var/obj/projectile/O)
		if (distance <= 0)
			O.die()
		distance--

	on_hit(atom/O)

		//lets make getting hit by the projectile a bit worse than getting the shockwave
		//tasers have changed in production code, I'm not really sure what value is good to give it here...
		if (isliving(O))
			var/mob/living/L = O
			L.changeStatus("slowed", 2 SECONDS)
			L.do_disorient(stamina_damage = 45, weakened = 50, stunned = 80, disorient = 20, remove_stamina_below_zero = 0)

			L.emote("twitch_v")


		hit = 1

		detonate(O)

	//do AOE stuff. This is not on on_hit because this effect should trigger when the projectile reaches the end of its distance OR hits things.
	on_end(var/obj/projectile/O)
		distance = 6		//reset distance for next shot
		//if we hit a mob or something, that will handle the detonation, we don't need to do it on_end
		if (!hit)
			detonate(O)
		hit = 0

	proc/detonate(atom/O)
		if (istype(O, /obj/projectile))
			var/obj/projectile/proj = O
			new /obj/effects/energy_bolt_aoe_burst(get_turf(proj), x_val = proj.xo, y_val = proj.yo)
		else
			new /obj/effects/energy_bolt_aoe_burst(get_turf(O))

		for (var/mob/M in orange(1, O))
			if (isliving(M))
				var/mob/living/L = M
				L.changeStatus("slowed", 2 SECONDS)
				L.do_disorient(stamina_damage = 45, weakened = 50, stunned = 80, disorient = 20, remove_stamina_below_zero = 0)
				L.emote("twitch_v")



/obj/effects/energy_bolt_aoe_burst
	name = "shockwave"
	desc = ""
	density = 0
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "shockwave"

	New(var/x_val, var/y_val)
		pixel_x = x_val
		pixel_y = y_val
		src.Scale(0.4,0.4)
		animate(src, matrix(2, MATRIX_SCALE), time = 6, color = "#ffdddd", easing = LINEAR_EASING)
		var/matrix/m1 = transform
		var/matrix/m2 = transform
		m1.Scale(7,7)
		m2.Scale(0.4,0.4)
		transform = m2
		animate(src,transform=m1,time=3)
		animate(transform=m2,time=5)


		SPAWN_DBG(7 DECI SECONDS) qdel(src)

/datum/projectile/energy_bolt/pulse
	name = "pulse"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "pulse"
	power = 20
	cost = 35
	sname = "pulse"
	shot_sound = 'sound/weapons/Taser.ogg'
	damage_type = D_ENERGY
	hit_ground_chance = 30
	brightness = 0
	disruption = 8

	hit_mob_sound = 'sound/effects/sparks6.ogg'

	on_pointblank(var/obj/projectile/P, var/mob/living/M)
		// var/dir = angle2dir(angle)
		M.throw_at(get_edge_target_turf(M, get_dir(P, M)),7,1, throw_type = THROW_GUNIMPACT)

		//When it hits a mob or such should anything special happen
	on_hit(atom/hit, angle, var/obj/projectile/O)
		// var/dir = angle2dir(angle)
		var/dir = get_dir(O.shooter, hit)
		if (ishuman(hit))
			var/mob/living/carbon/human/H = hit
			H.do_disorient(stamina_damage = 60, weakened = 0, stunned = 0, disorient = 80, remove_stamina_below_zero = 0)
			H.throw_at(get_edge_target_turf(hit, dir),7,1, throw_type = THROW_GUNIMPACT)
			H.emote("twitch_v")
			H.changeStatus("slowed", 3 SECONDS)
		return

	impact_image_effect(var/type, atom/hit, angle, var/obj/projectile/O)
		return


/datum/projectile/energybolt/reliquary_burst
	name = "energy"
	shot_sound = null
	power = 1
	cost = 2
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "relibullet"
	shot_number = 16
	shot_delay = 0.7
	dissipation_delay = 8
	damage_type = D_ENERGY
	hit_ground_chance = 30
	brightness = 1
	disruption = 8
	icon_turf_hit = "bhole-small"

	on_hit(atom/hit, dirflag)
		if(ishuman(hit))
			var/mob/living/carbon/human/M = hit
			M.changeStatus("slowed", 1.5 SECONDS)

