/datum/projectile/wavegun
	name = "energy wave"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "wave-r"
//How much of a punch this has, tends to be seconds/damage before any resist
	power = 12.5
//How much ammo this costs
	cost = 30
//How fast the power goes away
	dissipation_rate = 0 //doesn't use standard falloff
	max_range = 24 //Range/time limiter for non-standard dissipation - long range, but not infinite
//Kill/Stun ratio
	ks_ratio = 0.0
//name of the projectile setting, used when you change a guns setting
	sname = "inversion wave"
//file location for the sound you want it to play
	shot_sound = 'sound/weapons/wavegun.ogg'
//How many projectiles should be fired, each will cost the full cost
	shot_number = 1
	damage_type = D_ENERGY
	//With what % do we hit mobs laying down
	hit_ground_chance = 0
	//Can we pass windows
	window_pass = 0

	projectile_speed = 42

	brightness = 1
	color_red = 1
	color_green = 0
	color_blue = 0

	get_power(obj/projectile/P, atom/A)
		return 12.5 + 2.5 * clamp(get_dist(A, P.orig_turf) - 4, 0, 7)


/datum/projectile/wavegun/transverse //expensive taser shots that go through /everything/
	shot_number = 1
	power = 10 //half the power of a taser at range 1-3, delivers a nasty punch at the 4-tile sweetspot
	max_range = 5 //super short. about 4 tile max range
	projectile_speed = 28
	cost = 50
	hit_ground_chance = 100 //no escape
	pierces = -1 //no limits
	goes_through_walls = 1
	window_pass = 1
	ticks_between_mob_hits = 1
	damage_type = D_ENERGY
	sname = "transverse wave"
	icon_state = "wave-g"
	color_red = 0
	color_green = 1
	color_blue = 0

	get_power(obj/projectile/P, atom/A)
		return 10 + 30 * (P.travelled >= 128)

/datum/projectile/wavegun/bouncy
	sname = "reflection wave"
	power = 10
	projectile_speed = 28
	cost = 50
	max_range = 7
	icon_state = "wave-emp"


	color_red = 0
	color_green = 0
	color_blue = 1

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if(!ismob(hit))
			shot_volume = 0
			shoot_reflected_bounce(proj, hit, 2, PROJ_NO_HEADON_BOUNCE)
			shot_volume = 100
		if(proj.reflectcount >= 2)
			elecflash(get_turf(hit),radius=0, power=3, exclude_center = 0)


	get_power(obj/projectile/P, atom/A)
		return 10 + 15 * P.reflectcount
