/datum/projectile/rad_bolt
	name = "bolt"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "cbbolt" // changed from radbolt - cogwerks
//How much of a punch this has, tends to be seconds/damage before any resist
	power = 100
//How much ammo this costs
	cost = 40
//How fast the power goes away
	dissipation_rate = 1
//How many tiles till it starts to lose power
	dissipation_delay = 10
//Kill/Stun ratio
	ks_ratio = 0.8
//name of the projectile setting, used when you change a guns setting
	sname = "rad-poison bolt"
//file location for the sound you want it to play
	shot_sound = null // cogwerks edit to make this thing actually vaguely worthwhile
	//shot_sound = 'sound/weapons/radxbow.ogg'
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
	damage_type = D_RADIOACTIVE
	//With what % do we hit mobs laying down
	hit_ground_chance = 50
	//Can we pass windows
	window_pass = 1
	//no visible message upon bullet_act and no armor block message
	silentshot = 1
