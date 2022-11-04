// Not all that crazy shit

ABSTRACT_TYPE(/datum/projectile/special)
/datum/projectile/special
	name = "special"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "laser"
	damage = 15
	cost = 25
	dissipation_rate = 1
	dissipation_delay = 0
	sname = "laser"
	shot_sound = 'sound/weapons/Taser.ogg'
	shot_number = 1
	damage_type = D_SPECIAL
	hit_ground_chance = 50
	window_pass = 0

	on_hit(atom/hit, direction, projectile)
		return

/datum/projectile/special/kiss
	name = "kiss"
	icon_state = "kiss"
	damage = 0
	sname = "kiss"
	shot_sound = 'sound/voice/gasps/gasp.ogg'

	on_hit(atom/hit, direction, var/obj/projectile/projectile)
		if(istype(hit, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = hit
			boutput(H, "<span class='alert'><B>You catch the kiss and save it for later.</B></span>")

/datum/projectile/special/acid
	name = "acid"
	icon_state = "radbolt"
	damage = 45
	dissipation_rate = 30
	dissipation_delay = 10
	sname = "acid"

	on_hit(atom/hit, direction, var/obj/projectile/projectile)
		var/power = projectile.power
		hit.damage_corrosive(power)

	potent
		damage = 100

	weak
		damage = 15

/datum/projectile/special/acidspit
	name = "acid splash"
	icon_state = "acidspit"
	damage = 0.8
	dissipation_rate = 20
	dissipation_delay = 10
	sname = "acid"
	damage_type = D_TOXIC
	hit_mob_sound = 'sound/impact_sounds/burn_sizzle.ogg'
	hit_object_sound = 'sound/impact_sounds/burn_sizzle.ogg'
	shot_sound = null

	on_launch(var/obj/projectile/projectile)
		projectile.Scale(0.5, 0.5)

	on_hit(atom/hit, direction, var/obj/projectile/projectile)
		..()
		var/power = projectile.power
		hit.damage_corrosive(power)


/datum/projectile/special/ice
	name = "ice"
	icon_state = "ice"
	damage = 120
	dissipation_rate = 10
	dissipation_delay = 3
	sname = "ice"

	on_hit(atom/hit, direction, var/obj/projectile/projectile)
		hit.damage_cold(projectile.power / 10)
		if (ishuman(hit))
			var/mob/living/L = hit
			L.bodytemperature -= projectile.power

/datum/projectile/special/material_changer
	name = "transmutation bolt"
	icon_state = "ice"
	damage = 1
	dissipation_rate = 1
	dissipation_delay = 25
	sname = "ice"
	color_icon = "#aaff00"
	var/material_to_make = "gold"

	tick(var/obj/projectile/P)
		var/turf/T = get_turf(P)
		if (T)
			T.setMaterial(getMaterial("gold"))

	on_hit(var/atom/A)
		A.setMaterial(getMaterial("gold"))

/datum/projectile/special/piercing
	name = "focused beam"
	sname = "focused beam"
	icon_state = "laser_white"
	window_pass = 1
	damage = 30
	dissipation_rate = 1
	dissipation_delay = 3
	damage_type = D_ENERGY
	pierces = -1
	ticks_between_mob_hits = 10

/datum/projectile/special/wallhax
	name = "phased beam"
	sname = "phased beam"
	icon_state = "crescent_white"
	window_pass = 1
	damage = 30
	dissipation_rate = 1
	dissipation_delay = 3
	damage_type = D_ENERGY
	goes_through_walls = 1

// Mildly crazy shit

/datum/projectile/special/spreader
	name = "spread shot"
	sname = "spread shot"
	shot_sound = 'sound/weapons/grenade.ogg'
	var/pellets_to_fire = 15
	var/spread_projectile_type = /datum/projectile/bullet/flak_chunk
	var/split_type = 0
	var/pellet_shot_volume = 0
	silentshot = 1
	// 0 = on spawn
	// 1 = on impact

	on_launch(var/obj/projectile/P)
		if(split_type == 0)
			split(P)

	on_hit(var/atom/A,var/dir,var/obj/projectile/P)
		if(split_type == 1)
			split(P)

	on_pointblank(obj/projectile/O, mob/target)
		if(split_type) //don't multihit on pointblank unless we'd be splitting on launch
			return
		var/datum/projectile/F = new spread_projectile_type()
		F.shot_volume = pellet_shot_volume //optional anti-ear destruction
		var/turf/PT = get_turf(O)
		var/pellets = pellets_to_fire
		while (pellets > 0)
			pellets--
			var/obj/projectile/FC = initialize_projectile(PT, F, O.xo, O.yo, O.shooter)
			hit_with_existing_projectile(FC, target)


	proc/new_pellet(var/obj/projectile/P, var/turf/PT, var/datum/projectile/F)
		return

	proc/split(var/obj/projectile/P)
		var/datum/projectile/F = new spread_projectile_type()
		F.shot_volume = pellet_shot_volume //optional anti-ear destruction
		var/turf/PT = get_turf(P)
		var/pellets = pellets_to_fire
		while (pellets > 0)
			pellets--
			new_pellet(P,PT,F)
		P.die()

/datum/projectile/special/spreader/uniform_burst
	name = "uniform spread"
	sname = "uniform spread"
	var/spread_angle = 45
	var/current_angle = 0
	var/angle_adjust_per_pellet = 0
	var/initial_angle_offset_mult = 0.5

	on_launch(var/obj/projectile/P)
		angle_adjust_per_pellet = ((spread_angle * 2) / pellets_to_fire)
		current_angle = (0 - spread_angle) + (angle_adjust_per_pellet * initial_angle_offset_mult)
		..()

	new_pellet(var/obj/projectile/P, var/turf/PT, var/datum/projectile/F)
		var/obj/projectile/FC = initialize_projectile(PT, F, P.xo, P.yo, P.shooter)
		FC.rotateDirection(current_angle)
		FC.launch()
		current_angle += angle_adjust_per_pellet

/datum/projectile/special/spreader/buckshot_burst
	name = "buckshot"
	sname = "buckshot"
	cost = 1
	pellets_to_fire = 10
	spread_projectile_type = /datum/projectile/bullet/buckshot
	casing = /obj/item/casing/shotgun/red
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	var/speed_max = 5
	var/speed_min = 60
	var/spread_angle_variance = 5
	var/dissipation_variance = 32

	new_pellet(var/obj/projectile/P, var/turf/PT, var/datum/projectile/F)
		var/obj/projectile/FC = initialize_projectile(PT, F, P.xo, P.yo, P.shooter)
		FC.rotateDirection(rand(0-spread_angle_variance,spread_angle_variance))
		FC.internal_speed = rand(speed_min,speed_max)
		FC.travelled = rand(0,dissipation_variance)
		FC.launch()
/datum/projectile/special/spreader/buckshot_burst/plasglass
	name = "fragments"
	sname = "fragments"
	cost = 1
	pellets_to_fire = 4
	casing = /obj/item/casing/shotgun/pipe
	spread_projectile_type = /datum/projectile/bullet/improvplasglass
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	speed_max = 40
	speed_min = 34
	spread_angle_variance = 15
	dissipation_variance = 10

/datum/projectile/special/spreader/buckshot_burst/glass
	spread_projectile_type = /datum/projectile/bullet/improvglass
	name = "glass"
	sname = "glass"
	cost = 1
	pellets_to_fire = 6
	casing = /obj/item/casing/shotgun/pipe
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	speed_max = 36
	speed_min = 28
	spread_angle_variance = 30
	dissipation_variance = 40

/datum/projectile/special/spreader/buckshot_burst/scrap
	spread_projectile_type = /datum/projectile/bullet/improvscrap
	name = "fragments"
	sname = "fragments"
	cost = 1
	pellets_to_fire = 3
	casing = /obj/item/casing/shotgun/pipe
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	speed_max = 40
	speed_min = 34
	spread_angle_variance = 10
	dissipation_variance = 10

/datum/projectile/special/spreader/buckshot_burst/nails
	name = "nails"
	sname = "nails"
	cost = 1
	pellets_to_fire = 8
	spread_projectile_type = /datum/projectile/bullet/nails
	casing = /obj/item/casing/shotgun/gray
	spread_angle_variance = 10
	damage_type = D_SPECIAL
	power = 32

/datum/projectile/special/spreader/uniform_burst/circle
	name = "circular spread"
	sname = "circular spread"
	spread_angle = 180
	pellets_to_fire = 20

/datum/projectile/special/spreader/uniform_burst/blaster
	name = "blaster wave"
	sname = "wave fire"
	spread_angle = 33
	cost = 200
	pellets_to_fire = 5
	spread_projectile_type = /datum/projectile/laser/blaster/blast
	shot_sound = 'sound/weapons/laser_f.ogg'


/datum/projectile/special/spreader/uniform_burst/spikes
	name = "spike wave"
	sname = "spike wave"
	spread_angle = 65
	cost = 200
	pellets_to_fire = 7
	spread_projectile_type = /datum/projectile/bullet/spike
	shot_sound = 'sound/weapons/radxbow.ogg'



// Really crazy shit

/datum/projectile/special/shock_orb
	name = "rydberg-matter orb"
	sname = "rydberg-matter orb"
	icon_state = "elecorb"
	shot_sound = 'sound/weapons/energy/LightningCannon.ogg'
	damage = 60
	stun = 15
	cost = 75
	damage_type = D_ENERGY
	dissipation_delay = 15
	color_red = 0.1
	color_green = 0.3
	color_blue = 1

	var/arc_chance_per_tick = 33
	var/max_arcs_per_tick = 3
	var/min_arcs_per_tick = 1
	var/arcs_on_hit = 8
	var/shock_range = 3
	var/wattage = 5000

	tick(var/obj/projectile/P)
		if (prob(arc_chance_per_tick))
			var/list/sfloors = list()
			for (var/turf/T in view(shock_range, P))
				if (!T.density)
					sfloors += T
			var/shocks = rand(min_arcs_per_tick, max_arcs_per_tick)
			while (shocks > 0 && length(sfloors))
				shocks--
				var/turf/Q = pick(sfloors)
				arcFlashTurf(P, Q, wattage)
				sfloors -= Q

	on_hit(var/atom/A)
		playsound(A, 'sound/weapons/energy/LightningCannonImpact.ogg', 50, 1)
		var/list/sfloors = list()
		for (var/turf/T in view(shock_range, A))
			if (!T.density)
				sfloors += T
		var/arcs = arcs_on_hit
		while (arcs > 0 && length(sfloors))
			arcs--
			var/turf/Q = pick(sfloors)
			arcFlashTurf(A, Q, wattage)
			sfloors -= Q

	always_mob

		tick(var/obj/projectile/P)
			if (prob(arc_chance_per_tick))
				var/list/smobs = list()
				for (var/mob/M in view(shock_range, P))
					smobs += M
				var/shocks = rand(min_arcs_per_tick, max_arcs_per_tick)
				while (shocks > 0 && length(smobs))
					shocks--
					var/mob/Q = pick(smobs)
					arcFlash(P, Q, wattage)
					smobs -= Q

/datum/projectile/special/inferno
	name = "inferno bomb"
	sname = "inferno bomb"
	icon_state = "fusionorb"
	shot_sound = 'sound/weapons/energy/InfernoCannon.ogg'
	damage = 60
	stun = 15//yassTODO
	cost = 75
	damage_type = D_BURNING
	dissipation_delay = 15

	var/burn_range = 1
	var/blast_size = 3
	var/temperature = 800

	tick(var/obj/projectile/P)
		fireflash_sm(get_turf(P), burn_range, temperature)

	on_hit(var/atom/A)
		playsound(A, 'sound/effects/ExplosionFirey.ogg', 100, 1)
		fireflash_sm(get_turf(A), blast_size, temperature)

/datum/projectile/special/howitzer
	name = "plasma howitzer"
	sname = "plasma howitzer"
	icon = 'icons/obj/large/32x96.dmi'
	icon_state = "howitzer-shot"
	shot_sound = 'sound/weapons/energy/howitzer_shot.ogg'
	damage = 8000 // blam = INF
	stun = 2000 // blam = INF
	cost = 2500
	damage_type = D_BURNING
	dissipation_delay = 75
	dissipation_rate = 300
	brightness = 2
	projectile_speed = 32
	impact_range = 32
	pierces = -1
	goes_through_walls = 1
	color_red = 1
	color_green = 1
	color_blue = 0
	var/burn_range = 1
	var/blast_size = 2
	var/temperature = 5000
	var/impacted = 0

	tick(var/obj/projectile/P)
		var/T1 = get_turf(P)
		if((!istype(T1,/turf/space))) // so uh yeah this will be pretty mean
			fireflash_sm(T1, burn_range, temperature)
			new /obj/effects/explosion/dangerous(get_step(P.loc,P.dir))



	on_launch(var/obj/projectile/P)
		for(var/mob/M in range(P.loc, 6))
			shake_camera(M, 3, 1)


	on_hit(var/atom/A)
		var/turf/T = get_turf(A)
		playsound(A, 'sound/effects/ExplosionFirey.ogg', 60, 1)
		if(!src.impacted)
			playsound_global(world, 'sound/weapons/energy/howitzer_impact.ogg', 60)
			src.impacted = 1
			SPAWN(1 DECI SECOND)
				for(var/mob/living/M in mobs)
					shake_camera(M, 2, 1)

		SPAWN(0)
			explosion_new(null, T, 30, 1)
		if(prob(10))
			playsound_global(world, 'sound/effects/creaking_metal1.ogg', 40)

// A weapon by Sovexe
/datum/projectile/special/meowitzer //what have I done
	shot_sound = 'sound/misc/boing/6.ogg'
	name  = "meowitzer"
	sname  = "meowitzer"
	icon = 'icons/misc/critter.dmi'
	icon_state = "cat1"
	dissipation_delay = 75
	dissipation_rate = 300
	projectile_speed = 26
	cost = 1

	var/explosive_hits = 1
	var/explosion_power = 30
	var/hit_sound = 'sound/voice/animal/cat.ogg'
	var/last_sound_time = 0 // anti-ear destruction
	var/max_bounce_count = 50

	on_hit(atom/A, direction, projectile)
		shoot_reflected_bounce(projectile, A, max_bounce_count, PROJ_RAPID_HEADON_BOUNCE)
		var/turf/T = get_turf(A)

		//prevent playing all 50 sounds at once on rapid bounce
		if(world.time >= last_sound_time + 1 DECI SECOND)
			last_sound_time = world.time
			playsound(A, hit_sound, 60, 1)

		if (explosive_hits)
			SPAWN(0)
				explosion_new(projectile, T, explosion_power, 1)
		return

/datum/projectile/special/meowitzer/inert
	explosive_hits = 0

/datum/projectile/special/spewer
	name = "volatile bolt"
	sname = "volatile bolt"
	icon_state = "orb_white"
	shot_sound = 'sound/weapons/laserultra.ogg'
	damage = 80
	stun = 80//yassTODO
	cost = 75
	damage_type = D_BURNING
	dissipation_delay = 0
	dissipation_rate = 5

	var/bolt_type = /datum/projectile/laser/spewer_bolt
	var/datum/projectile/bolt_instance = null
	var/bolt_chance_per_tick = 50

	on_launch(var/obj/projectile/P)
		bolt_instance = new bolt_type()

	tick(var/obj/projectile/P)
		if (prob(bolt_chance_per_tick) && istype(bolt_instance))
			var/list/sfloors = list()
			for (var/turf/T in view(7, P))
				if (!T.density)
					sfloors += T
			new_bolt(P, get_turf(P), bolt_instance)

	proc/new_bolt(var/obj/projectile/P, var/turf/PT, var/datum/projectile/F)
		var/obj/projectile/FC = initialize_projectile(PT, F, rand(-projectile_speed,projectile_speed), rand(-projectile_speed,projectile_speed), P.shooter)
		FC.launch()

/datum/projectile/laser/spewer_bolt
	name = "volatile bolt fragment"
	sname = "volatile bolt fragment"
	icon_state = "ball_white"
	shot_sound = 'sound/weapons/blaster_a.ogg'
	damage = 5
	dissipation_delay = 15
	dissipation_rate = 1

/datum/projectile/laser/punch // yep :I
	name = "punch"
	window_pass = 0
	icon_state = "punch"
	damage_type = D_KINETIC
	damage = 0
	cost = 1
	brightness = 0
	sname = "punch"
	shot_sound = 'sound/impact_sounds/Generic_Swing_1.ogg'
	dissipation_delay = 1
	dissipation_rate = 35
	impact_image_state = null

	on_hit(atom/hit)
		if (usr && hit)
			hit.Attackhand(usr)

//mbc : hey i know homing projectiles exist already as 'seeker', but i like mine better
/datum/projectile/special/homing
	name = "homing"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "laser"
	damage = 1
	cost = 1
	dissipation_rate = 0
	dissipation_delay = 0
	shot_sound = 'sound/weapons/Taser.ogg'
	shot_number = 1
	damage_type = D_SPECIAL
	hit_ground_chance = 100
	window_pass = 0

	precalculated = 0

	var/min_speed = 0
	var/max_speed = 23
	var/start_speed = 6
	var/easemult = 0.1

	var/auto_find_targets = 1
	var/homing_active = 1

	var/desired_x = 0
	var/desired_y = 0

	var/rotate_proj = 1
	var/face_desired_dir = 0

	goes_through_walls = 1

	on_launch(var/obj/projectile/P)
		..()
		P.internal_speed = start_speed

		if (auto_find_targets)
			P.targets = list()
			for(var/mob/M in view(P,15))
				P.targets += M

	on_hit(atom/hit, direction, projectile)
		return

	proc/calc_desired_x_y(var/obj/projectile/P)
		.= 0

		//if (auto_find_targets) //prob expensive
		//	P.targets = list()
		//	for(var/mob/M in view(P,6))
		//		P.targets += M

		if (P.targets && P.targets.len && P.targets[1])

			var/atom/closest = P.targets[1]

			for (var/atom in P.targets)
				var/atom/A = atom
				if (A == P.shooter) continue
				if (GET_DIST(P,A) < GET_DIST(P,closest))
					closest = A

			desired_x = closest.x - P.x
			desired_y = closest.y - P.y

			.= 1

	tick(var/obj/projectile/P)
		if (!P || !src.homing_active)
			return

		desired_x = 0
		desired_y = 0
		if (calc_desired_x_y(P))
			var/magnitude = vector_magnitude(desired_x,desired_y)
			if (magnitude != 0)
				desired_x /= magnitude
				desired_y /= magnitude

				desired_x *= max_speed
				desired_y *= max_speed

				var/xchanged = P.xo + ((desired_x - P.xo) * easemult)
				var/ychanged = P.yo + ((desired_y - P.yo) * easemult)

				var/setangle = 0
				if (face_desired_dir)
					setangle = arctan(desired_y,desired_x)

				P.setDirection(xchanged,ychanged, do_turn = rotate_proj, angle_override = setangle)
				P.internal_speed = clamp(magnitude, min_speed, max_speed)

		desired_x = 0
		desired_y = 0

		..()

/datum/projectile/special/homing/slow
	max_speed = 1


//vamp bail out travel
/datum/projectile/special/homing/travel
	name = "mysterious mystery mist"
	icon_state = "vamp_travel"
	auto_find_targets = 0
	max_speed = 6
	start_speed = 0.1


	shot_sound = 'sound/effects/mag_phase.ogg'
	goes_through_walls = 1
	goes_through_mobs = 1

	silentshot = 1


	on_hit(atom/hit, direction, var/obj/projectile/P)
		..()
		if (istype(hit, /obj/storage/closet/coffin/vampire))
			P.special_data["insert_owner"] = hit
			P.die()

	on_launch(var/obj/projectile/P)
		..()
		if (!("owner" in P.special_data))
			P.die()
			return
		var/mob/carryme = P.special_data["owner"]
		carryme.set_loc(P)

	tick(var/obj/projectile/P)
		..()

		if (!(P.targets && P.targets.len && P.targets[1] && !(P.targets[1]:disposed)))
			P.die()

	on_end(var/obj/projectile/P)
		if (("owner" in P.special_data) && P.proj_data == src)
			var/mob/dropme = P.special_data["owner"]

			if (("insert_owner" in P.special_data) && P.special_data["insert_owner"])
				dropme.set_loc(P.special_data["insert_owner"])
			else
				if (dropme.loc == P)
					dropme.set_loc(get_turf(P))
					boutput(dropme, "<span class='alert'>Your coffin was lost or destroyed! Oh no!!!</span>")
		..()

/datum/projectile/special/homing/magicmissile
	name = "magic missile"
	sname = "magic missile"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "magicm"
	shot_sound = null
	damage = 15
	cost = 1
	damage_type = D_KINETIC
	dissipation_delay = 0
	dissipation_rate = 0
	brightness = 2
	projectile_speed = 2
	is_magical = 1 // It passes right through them, but just for consistency
	auto_find_targets = 0
	min_speed = 2
	max_speed = 2
	goes_through_walls = 0 // It'll stop homing when it hits something, then go bouncy
	var/max_bounce_count = 3 // putting the I in ICEE BEEYEM
	var/weaken_length = 4 SECONDS
	var/slam_text = "The magic missile SLAMS into you!"
	var/hit_sound = 'sound/effects/mag_magmisimpact_bounce.ogg'
	var/cat_sound = 'sound/voice/animal/cat.ogg'
	var/last_sound_time = 0

	on_pre_hit(var/atom/hit, var/angle, var/obj/projectile/O)
		if(istype(O) && !(hit in O.hitlist))
			if(ismob(hit))
				var/mob/M = hit
				if(iswizard(M) || M.traitHolder?.hasTrait("training_chaplain"))
					boutput(M, "The magic missile passes right through you!")
					. = TRUE
				else if(ON_COOLDOWN(M, "magic_missiled", 1 SECOND))
					boutput(M, "The magic missile passes right through you, not wishing to add insult to injury!")
					. = TRUE
					O.targets -= M //Stop tracking whoever we hit to prevent the projectiles orbiting them

			if(isobj(hit) || (isturf(hit) && !hit.density))
				. = TRUE

			if(.)
				O.hitlist += hit

			// Missiles home into their targets until they hit a wall. Then they forget their target and just bounce around
			else if(length(O.targets) && isturf(hit) && hit?.density)
				O.targets = list()

	on_hit(atom/A, direction, var/obj/projectile/projectile)
		. = ..()
		if(isliving(A)) // pre_hit should filter out any spacemagic people
			var/mob/living/M = A
			M.changeStatus("weakened", src.weaken_length)
			M.force_laydown_standup()
			boutput(M, text("<span class='notice'>[slam_text]</span>"))
			playsound(M.loc, 'sound/effects/mag_magmisimpact.ogg', 25, 1, -1)
			M.lastattacker = src.master?.shooter
			M.lastattackertime = TIME
		else if(projectile.reflectcount < src.max_bounce_count)
			shoot_reflected_bounce(projectile, A, src.max_bounce_count, PROJ_RAPID_HEADON_BOUNCE)
			var/turf/T = get_turf(A)
			if(TIME >= last_sound_time + 1 DECI SECOND)
				last_sound_time = TIME
				if(prob(1))
					playsound(T, src.cat_sound, 60, 1)
				else
					playsound(T, src.hit_sound, 60, 1)
		else
			playsound(A, 'sound/effects/mag_magmisimpact.ogg', 25, 1, -1)

/datum/projectile/special/homing/magicmissile/weak
	name = "magic minimissile"
	sname = "magic minimissile"
	damage = 10
	projectile_speed = 1.5
	min_speed = 2
	max_speed = 2
	max_bounce_count = 2 // putting the Y in ICEE BEEYEM
	weaken_length = 2 SECONDS
	slam_text = "The magic missile bumps into you!"

/datum/projectile/special/homing/orbiter
	icon_state = "bloodproj"
	easemult = 0.3

	rotate_proj = 1
	face_desired_dir = 1

	goes_through_walls = 1

	var/radius = 1.4
	var/ang_inc = 15


	on_launch(var/obj/projectile/P)
		..()
		P.special_data["orbit_angle"] = 0
		P.special_data["diss_count"] = 0


	calc_desired_x_y(var/obj/projectile/P)
		.= 0

		if (P.targets && P.targets.len && P.targets[1])
			P.special_data["orbit_angle"] += ang_inc
			if (P.special_data["orbit_angle"] > 360)
				P.special_data["orbit_angle"] -= 360

			var/atom/target = P.targets[1]

			//var/ang_between = get_angle(target,P)
			var/tx = target.x + cos(P.special_data["orbit_angle"])
			var/ty = target.y + sin(P.special_data["orbit_angle"])

			desired_x = (tx - P.x)
			desired_y = (ty - P.y)

			.= 1
		else
			P.special_data["diss_count"] += 1
			if (P.special_data["diss_count"] > 40)
				P.die()


/datum/projectile/special/homing/orbiter/spiritbat
	name = "frost bat"
	icon = 'icons/misc/critter.dmi'
	icon_state = "spiritbat"
	rotate_proj = 0
	face_desired_dir = 1
	goes_through_walls = 1
	is_magical = 1

	shot_sound = 0
	hit_mob_sound = 'sound/effects/mag_iceburstimpact_high.ogg'
	hit_object_sound = 'sound/effects/mag_iceburstimpact_high.ogg'

	var/temp_reduc = 80

	on_launch(var/obj/projectile/P)
		..()
		P.collide_with_other_projectiles = 1
		//P.transform = matrix()

	on_hit(atom/hit, direction, var/obj/projectile/P)
		..()

		if (istype(hit, /obj/projectile))
			var/obj/projectile/pass_proj = hit
			if (pass_proj.proj_data.hit_object_sound)
				playsound(pass_proj.loc, pass_proj.proj_data.hit_object_sound, 60, 0.5)
			if (pass_proj.proj_data.name != src.name)
				pass_proj.die()
			return

		hit.damage_cold(temp_reduc / 10)
		if (isliving(hit))
			var/mob/living/L = hit
			L.bodytemperature -= temp_reduc
			L.TakeDamage("All", 3, 1, 0, 0)//magic

			var/atom/targetTurf = 0
			if (P.shooter)
				var/dir = get_dir(P.shooter, P.dir)
				targetTurf = get_edge_target_turf(hit, dir ? dir : P.dir)
			else
				targetTurf = get_edge_target_turf(hit, P.dir)

			L.changeStatus("weakened", 2 SECONDS)
			L.force_laydown_standup()
			L.throw_at(targetTurf, rand(5,7), rand(1,2), throw_type = THROW_GUNIMPACT)

	on_canpass(var/obj/projectile/P, atom/movable/passing_thing)
		if (P != passing_thing)
			if (istype(passing_thing, /obj/projectile))
				var/obj/projectile/pass_proj = passing_thing
				return (istype(pass_proj.proj_data, src.type) || pass_proj.goes_through_walls)

			if (isitem(passing_thing))
				var/obj/item/I = passing_thing
				if (I.throwing)
					return 0
		.= 1

//place coffin. then, we travel to it in prjoectile form and it heals us while people can beat it
//cofin is anchored, rises outta ground at spot

/datum/projectile/special/spreader/tasershotgunspread //Used in Azungar's taser shotgun.
	name = "energy bolt"
	sname = "shotgun spread"
	cost = 25
	stun = 45 //a chunky pointblank
	damage_type = D_SPECIAL
	pellets_to_fire = 3
	spread_projectile_type = /datum/projectile/energy_bolt/tasershotgun
	split_type = 0
	shot_sound = 'sound/weapons/Taser.ogg'
	hit_mob_sound = 'sound/effects/sparks6.ogg'
	var/spread_angle = 10
	var/current_angle = 0
	var/angle_adjust_per_pellet = 0
	var/initial_angle_offset_mult = 0.5

	on_launch(var/obj/projectile/P)
		angle_adjust_per_pellet = ((spread_angle * 2) / pellets_to_fire)
		current_angle = (0 - spread_angle) + (angle_adjust_per_pellet * initial_angle_offset_mult)
		..()

	new_pellet(var/obj/projectile/P, var/turf/PT, var/datum/projectile/F)
		var/obj/projectile/FC = initialize_projectile(PT, F, P.xo, P.yo, P.shooter)
		FC.rotateDirection(current_angle)
		FC.launch()
		current_angle += angle_adjust_per_pellet


/datum/projectile/special/spreader/quadwasp
	name = "4 space wasp eggs"
	icon = 'icons/obj/foodNdrink/food_ingredient.dmi'
	icon_state = "critter_egg"
	brightness = 0
	sname = "4 space wasp eggs"
	shot_sound = null
	shot_number = 1
	silentshot = 1 //any noise will be handled by the egg splattering anyway
	damage = 60
	cost = 40
	dissipation_rate = 70
	dissipation_delay = 0
	window_pass = 0
	spread_projectile_type = /datum/projectile/special/spawner/wasp
	pellets_to_fire = 4
	var/spread_angle = 60
	var/current_angle = 0
	var/angle_adjust_per_pellet = 0
	var/initial_angle_offset_mult = 0


	on_launch(var/obj/projectile/P)
		angle_adjust_per_pellet = ((spread_angle * 2) / pellets_to_fire)
		current_angle = (0 - spread_angle) + (angle_adjust_per_pellet * initial_angle_offset_mult)
		..()

	new_pellet(var/obj/projectile/P, var/turf/PT, var/datum/projectile/F)
		var/obj/projectile/FC = initialize_projectile(PT, F, P.xo, P.yo, P.shooter)
		FC.rotateDirection(current_angle)
		FC.launch()
		current_angle += angle_adjust_per_pellet

/datum/projectile/special/spawner //shoot stuff
	name = "dimensional pocket"
	damage = 1
	dissipation_rate = 0
	max_range = 10
	cost = 1
	shot_sound = 'sound/weapons/rocket.ogg'
	icon_state = "bullet"
	implanted= null
	casing = null
	impact_image_state = null
	var/typetospawn = null
	var/hasspawned = null
	var/hit_sound = null

	on_hit(atom/hit, direction, projectile)
		if(src.hit_sound)
			playsound(hit, src.hit_sound, 50, 1)
		if(ismob(hit) && typetospawn)
			hasspawned = TRUE
			. = new typetospawn(get_turf(hit))
		return


	on_end(obj/projectile/O)
		if(!hasspawned && typetospawn)
			. = new typetospawn(get_turf(O))
			hasspawned = TRUE
		else
			hasspawned = null
		return

/datum/projectile/special/spawner/gun //shoot guns
	name = "gun"
	damage = 20 //20 damage from getting beaned with a gun idk
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	shot_sound = 'sound/weapons/rocket.ogg'
	icon_state = "gun"
	implanted= null
	casing = null
	impact_image_state = null
	typetospawn = /obj/item/gun/kinetic/derringer


/datum/projectile/special/spawner/wasp //shoot wasps
	icon = 'icons/obj/foodNdrink/food_ingredient.dmi'
	icon_state = "critter_egg"
	name = "space wasp egg"
	brightness = 0
	sname = "space wasp egg"
	shot_sound = null
	shot_number = 1
	silentshot = 1 //any noise will be handled by the egg splattering anyway
	hit_ground_chance = 0
	damage_type = D_KINETIC
	damage = 15
	dissipation_delay = 30
	dissipation_rate = 1
	cost = 10
	window_pass = 0
	typetospawn = /obj/item/reagent_containers/food/snacks/ingredient/egg/critter/wasp/angry

	on_hit(atom/hit, direction, projectile)
		var/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/wasp/angry/W = ..()
		if(istype(W))
			W.throw_impact(get_turf(hit))

	on_end(obj/projectile/O)
		var/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/wasp/angry/W = ..()
		if(istype(W))
			W.throw_impact(get_turf(O))

/datum/projectile/special/spawner/beepsky
	name = "Beepsky"
	window_pass = 0
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "secbot1"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	damage = 5
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/rocket.ogg'
	ks_ratio = 1
	impact_image_state = "secbot1-wild"
	implanted = null
	typetospawn = /obj/machinery/bot/secbot

	on_hit(atom/hit)
		var/obj/machinery/bot/secbot/beepsky = ..()
		if(istype(beepsky) && ismob(hit))
			var/mob/hitguy = hit
			hitguy.do_disorient(15, weakened = 20 * 10, disorient = 80)
			beepsky.emagged = 1
			if(istype(hitguy, /mob/living/carbon))
				beepsky.target = hitguy

	on_end(obj/projectile/O)
		var/obj/machinery/bot/secbot/beepsky = ..()
		if(istype(beepsky))
			beepsky.emagged = 1

/datum/projectile/special/spawner/battlecrate
	name = "Battlecrate"
	damage = 100
	max_range = 30
	cost = 0
	shot_sound = 'sound/weapons/rocket.ogg'
	icon = 'icons/obj/large_storage.dmi'
	icon_state = "attachecase"
	typetospawn = /obj/lootbox
	var/explosion_power = 15

	on_hit(atom/hit, direction, projectile)
		explosion_new(projectile, get_turf(hit), explosion_power, 1)
		..()

/datum/projectile/special/shotchem // how do i shot chem
	name = "chemical bolt"
	sname = "chembolt"
	icon = 'icons/effects/effects.dmi'
	icon_state = "extinguish"
	shot_sound = 'sound/weapons/flamethrower.ogg'
	stun = 0
	cost = 1
	damage_type = D_SPECIAL
	shot_delay = 0.1 SECONDS
	dissipation_rate = 0
	dissipation_delay = 0
	hit_ground_chance = 0 // burn right over em
	max_range = 10
	silentshot = 1 // Mr. Muggles is hit by the chemical bolt x99999
	fullauto_valid = 0


	/// Releases some of the projectile's gas into the turf
	proc/emit_gas(turf/T, all_of_it = 0)
		if(!src.master || !src.master.special_data)
			return
		var/datum/gas_mixture/airgas = src.master.special_data["airgas"]
		T?.assume_air(airgas.remove_ratio(all_of_it ? 1 : src.master.special_data["chem_pct_app_tile"]))

	/// Sprays some of the chems in the projectile onto everything on hit's turf
	/// Try not to pass it something with an organholder, acid-throwers will disintigrate all their organs
	proc/emit_chems(atom/hit, obj/projectile/O, angle)
		if(!O.special_data || !length(O.special_data) || !istype(hit) || !O.reagents)
			return

		var/turf/T = get_turf(hit)
		var/datum/reagents/chemR = O.reagents
		var/chem_amt = chemR.total_volume
		if(chem_amt <= 0)
			return
		/// If there's just a little bit left, use the rest of it
		var/amt_to_emit = (chem_amt <= 0.1) ? chem_amt : (chemR.maximum_volume * O.special_data["chem_pct_app_tile"])

		var/datum/reagents/copied = new/datum/reagents(amt_to_emit)
		copied = chemR.copy_to(copied, amt_to_emit/chemR.total_volume, copy_temperature = 1)

		if(!T.reagents) // first get the turf
			T.create_reagents(100)
		copied.copy_to(T.reagents, 1, copy_temperature = 1)
		copied.reaction(T, TOUCH, 0, 0)
		if(O.special_data["IS_LIT"]) // Heat if needed
			T.reagents?.set_reagent_temp(O.special_data["burn_temp"], TRUE)
		for(var/atom/A in T.contents) // then all the stuff in the turf
			if(istype(A, /obj/overlay) || istype(A, /obj/projectile))
				continue
			copied.reaction(A, TOUCH, 0, 0)
		if(O.special_data["IS_LIT"]) // Reduce the temperature per turf crossed
			O.special_data["burn_temp"] -= O.special_data["burn_temp"] * O.special_data["temp_pct_loss_atom"]
			O.special_data["burn_temp"] = max(O.special_data["burn_temp"], T0C)
		chemR.remove_any(amt_to_emit)

	post_setup(obj/projectile/P)
		var/list/cross2 = list()
		for(var/turf/T in P.crossing)
			cross2[T] = P.crossing[T]
		P.special_data["projcross"] = cross2

	on_launch(obj/projectile/O)
		if(length(O.special_data))
			O.internal_speed = src.projectile_speed * O.special_data["speed_mult"]
			src.color_icon = O.special_data["proj_color"]
		O.AddComponent(/datum/component/gaseous_projectile) // Pierce anything that doesn't block LoS - if you can see it you can burn it

	on_hit(atom/hit, angle, var/obj/projectile/O)
		var/turf/T = get_turf(hit)
		var/list/cross2 = O.special_data["projcross"]
		if(T in cross2)
			cross2 -= T
			src.emit_chems(T, O)
			src.emit_gas(T, 1)

	tick(var/obj/projectile/O)
		var/list/cross2 = O.special_data["projcross"]
		for (var/i = 1, i < cross2.len, i++)
			var/turf/T = cross2[i]
			if (cross2[T] < O.curr_t)
				src.emit_chems(T, O)
				src.emit_gas(T, 0)
				if(O.reagents?.total_volume < 0.01)
					O.die()
				cross2.Cut(1,2)
				i--
			else
				break

	on_pointblank(var/obj/projectile/O, var/mob/target)
		var/turf/T = get_turf(O)
		src.emit_chems(target, O)
		src.emit_gas(T, 1)
	on_max_range_die(obj/projectile/O)
		if(O.reagents?.total_volume < 0.01)
			return
		var/turf/T = get_turf(O)
		src.emit_chems(T, O)
		src.emit_gas(T, 1)
