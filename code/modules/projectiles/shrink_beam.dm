/datum/projectile/shrink_beam
	name = "space-time disruption"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "sinebeam3"
	brightness = 1
//How much of a punch this has, tends to be seconds/damage before any resist
	stun = 0
//How much ammo this costs
	cost = 50
//How fast the power goes away
	dissipation_rate = 1
//How many tiles till it starts to lose power
	dissipation_delay = 10
//name of the projectile setting, used when you change a guns setting
	sname = "shrink beam"
//file location for the sound you want it to play
	shot_sound = 'sound/effects/warp1.ogg'
//How many projectiles should be fired, each will cost the full cost
	shot_number = 1
//What is our damage type
	damage_type = 0
	//With what % do we hit mobs laying down
	hit_ground_chance = 10
	//Can we pass windows
	window_pass = 0
	projectile_speed = 20

	var/turf/target = null
	var/failchance = 5

	var/shrunk_max = 2
	var/shrunk_min = -4
	var/shrunk_change = 1

	var/mobs_only = 1

	on_hit(atom/hit)
		// if it's a mob, or we're not mobs-only and it's /atom/movable, ...
		if (ismob(hit) || (!mobs_only && istype(hit, /atom/movable)))
			// if it results in no change it's arleady at the limit so just skip it
			if (clamp(hit.shrunk + shrunk_change, shrunk_min, shrunk_max) == hit.shrunk)
				return

			if (hit.shrunk != 0)
				// crappy attempt to return to normal size w/o fucking up other transforms
				// basically, try to undo what the current shrink state did
				hit.Scale(1 / (0.75 ** hit.shrunk), 1 / (0.75 ** hit.shrunk))
			hit.shrunk += shrunk_change
			hit.Scale(0.75 ** hit.shrunk, 0.75 ** hit.shrunk)
		return

	unsafe
		mobs_only = 0

/datum/projectile/shrink_beam/grow
	name = "time-space disruption"
	sname = "grow beam"
	shrunk_change = -1

	unsafe
		mobs_only = 0
