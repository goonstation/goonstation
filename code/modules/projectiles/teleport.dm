/datum/projectile/tele_bolt
	name = "space-time disruption"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "disrupt"
//How much of a punch this has, tends to be seconds/damage before any resist
	stun = 10
//How much ammo this costs
	cost = 50
//How fast the power goes away
	dissipation_rate = 1
//How many tiles till it starts to lose power
	dissipation_delay = 10
//name of the projectile setting, used when you change a guns setting
	sname = "teleport blast"
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

	color_red = 0.2
	color_green = 0.2
	color_blue = 1

	has_impact_particles = TRUE
	kinetic_impact = FALSE

	var/obj/item/target = null
	var/failchance = 5

	on_hit(atom/hit)
		if (!target)
			return

		if(istype(hit, /obj/effects)) //sparks don't teleport
			return
		if (istype(hit, /atom/movable))
			if (hit:anchored)
				return
			if(!target || prob(failchance)) //Just like portals!
				do_teleport(hit, locate(rand(5, world.maxx - 5), rand(5, world.maxy -5), 3), 0)
			else
				var/turf/destination = get_turf(src.target) // Beacons and tracking implant might have been moved.
				if (destination)
					do_teleport(hit, destination, 1) ///You will appear adjacent to the beacon
				else
					return
