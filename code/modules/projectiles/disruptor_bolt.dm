/datum/projectile/disruptor
	name = "disruptor"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "disrupt"
	damage = 10
//How much of a punch this has, tends to be seconds/damage before any resist
	power = 12.5
	stun = 12.5
//How much ammo this costs
	cost = 20
//How fast the power goes away
	dissipation_rate = 5
//How many tiles till it starts to lose power
	dissipation_delay = 8
//name of the projectile setting, used when you change a guns setting
	sname = "single shot stun"
//file location for the sound you want it to play
	shot_sound = 'sound/weapons/LaserOLD.ogg'
//volume the shot is played at, large pods double the gun and thus the shot sound!
	shot_volume = 30
//How many projectiles should be fired, each will cost the full cost
	shot_number = 1
	ie_type = "E"
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

	disruption = 12

	color_red = 0.2
	color_green = 0.2
	color_blue = 1
	has_impact_particles = TRUE

/datum/projectile/disruptor/burst
	icon_state = "disrupt"
	shot_sound = 'sound/weapons/rocket.ogg'
	shot_volume = 30
	cost = 60
	shot_number = 3
	damage_type = D_ENERGY
	sname = "burst stun"

/datum/projectile/disruptor/high
	damage = 57
	stun = 3
	shot_sound = 'sound/weapons/laserultra.ogg'
	shot_volume = 30
	icon_state = "disrupt_lethal"
	shot_number = 1
	cost = 30
	damage_type = D_ENERGY
	sname = "disruptor"

	disruption = 20

	on_hit(atom/hit)
		if(istype(hit, /obj/window))
			if(prob(80))
				var/obj/window/win = hit
				win.smash()

