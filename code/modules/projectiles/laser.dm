/datum/projectile/laser
	name = "laser"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "laser"

	virtual
		icon_state = "laser_virtual"

//How much of a punch this has, tends to be seconds/damage before any resist
	damage = 45
//How much ammo this costs
	cost = 31.25
//How fast the power goes away
	dissipation_rate = 5
//How many tiles till it starts to lose power
	dissipation_delay = 6
//name of the projectile setting, used when you change a guns setting
	sname = "laser"
//file location for the sound you want it to play
	shot_sound = 'sound/weapons/Taser.ogg'
//How many projectiles should be fired, each will cost the full cost
	shot_number = 1
	ie_type = "E"
//What is our damage type
/*
kinetic - raw power
piercing - punches though things
slashing - cuts things
energy - energy (stun)
laser - energy (laser)
burning - hot
radioactive - rips apart cells or some shit
toxic - poisons
*/
	damage_type = D_ENERGY // cogwerks - changed from piercing
	hit_type = DAMAGE_BURN
	//With what % do we hit mobs laying down
	hit_ground_chance = 50
	//Can we pass windows
	window_pass = 1
	brightness = 0.8
	color_red = 1
	color_green = 0
	color_blue = 0
	impact_image_state = "burn1"

	hit_mob_sound = 'sound/impact_sounds/burn_sizzle.ogg'
	hit_object_sound = 'sound/impact_sounds/burn_sizzle.ogg'
	has_impact_particles = TRUE

//Any special things when it hits shit?
	on_hit(atom/hit)
		if (!ismob(hit)) //I do not want to deal with players' bloodstreams boiling them alive, as metal as that would be
			//this isn't completely realistic, as lasers don't really have a temperature and so won't plateau like this buuut this works for now
			hit.temperature_expose(null, T0C + 100 + power * 20, 100, TRUE)

	tick(var/obj/projectile/P)
		if (istype(P.loc, /turf) && !(locate(/obj/blob/reflective) in get_turf(P.loc))) //eh, works for me:tm:
			var/turf/T = P.loc
			T.hotspot_expose(T0C + 100 + power*20, 5)

/datum/projectile/laser/quad
	name = "4 lasers"
	icon_state = "laser"
	damage = 240
	cost = 125
	dissipation_rate = 250
	dissipation_delay = 0

	on_launch(var/obj/projectile/P)
		if (!P)
			return
		var/datum/projectile/laser/L = new()
		var/turf/PT = get_turf(P)
		var/obj/projectile/P1 = initialize_projectile(PT, L, P.xo, P.yo, P.shooter)
		P1.rotateDirection(60)
		P1.launch()
		var/obj/projectile/P2 = initialize_projectile(PT, L, P.xo, P.yo, P.shooter)
		P2.rotateDirection(20)
		P2.launch()
		var/obj/projectile/P3 = initialize_projectile(PT, L, P.xo, P.yo, P.shooter)
		P3.rotateDirection(-20)
		P3.launch()
		var/obj/projectile/P4 = initialize_projectile(PT, L, P.xo, P.yo, P.shooter)
		P4.rotateDirection(-60)
		P4.launch()
		P.die()

/datum/projectile/laser/heavy
	name = "heavy laser"
	icon_state = "u_laser"
	damage = 80
	cost = 50
	dissipation_delay = 10
	brightness = 0
	sname = "heavy laser"
	shot_sound = 'sound/weapons/Laser.ogg'
	color_red = 0
	color_green = 0
	color_blue = 1

/datum/projectile/laser/heavy/law_safe //subclass of heavy laser that can't damage the law rack - for AI turrets
	name = "heavy laser"

/datum/projectile/laser/diffuse
	sname = "diffuse laser"
	cost = 30
	dissipation_delay = 1
	dissipation_rate = 8
	max_range = 7
	shot_number = 2

/datum/projectile/laser/asslaser // heh
	name = "assault laser"
	icon_state = "u_laser"
	damage = 50
	cost = 65
	dissipation_delay = 5
	dissipation_rate = 0
	max_range = 30
	projectile_speed = 20
	sname = "assault laser"
	shot_sound = 'sound/weapons/asslaser.ogg'
	color_red = 0
	color_green = 0
	color_blue = 1
	always_hits_structures = TRUE

	on_hit(atom/hit, dir, obj/projectile/P)
		fireflash(get_turf(hit), 0, chemfire = CHEM_FIRE_BLUE)
		if(!ismob(hit))
			hit.ex_act(2)
		else
			hit.ex_act(3, src, 1.5) //don't stun humans nearly as much
		P.die() //explicitly kill projectile - not a mining laser

/datum/projectile/laser/cruiser
	name = "obsidio beam"
	icon_state = "elecorb"
	damage = 100
	cost = 65
	dissipation_delay = 100
	dissipation_rate = 0
	max_range = 300
	projectile_speed = 32
	sname = "pulsed gigawatt beam"
	shot_sound = 'sound/weapons/Laser.ogg'
	color_red = 0
	color_green = 0
	color_blue = 1
	brightness = 4
	shot_number = 5
	window_pass = 0

	tick(var/obj/projectile/P)
		var/T1 = get_turf(P)
		if(!istype(T1,/turf/space))
			fireflash_melting(T1, 0, rand(50000, 100000), 0, TRUE, CHEM_FIRE_BLUE, TRUE, FALSE)

	on_hit(atom/hit)
		var/turf/T = get_turf(hit)
		elecflash(T,radius=2, power=500000, exclude_center = 0)
		fireflash_melting(T, 1, rand(50000, 100000), 0, TRUE, CHEM_FIRE_BLUE, FALSE, TRUE)
		hit.meteorhit()

/datum/projectile/laser/light // for the drones
	name = "phaser bolt"
	icon_state = "phaser_energy"
	damage = 20
	cost = 25
	sname = "phaser bolt"
	dissipation_delay = 5
	shot_sound = 'sound/weapons/laserlight.ogg'
	color_red = 1
	color_green = 0.2
	color_blue = 0.2

	tiny
		name = "micro phaser bolt"
		icon_state = "phaser_light"
		sname = "micro phaser bolt"
		damage = 10
		cost = 10
		shot_sound = 'sound/weapons/energy/phaser_tiny.ogg'
		color_red = 1
		color_green = 0.2
		color_blue = 0.2

	huge // yes laser/light/huge is pretty dumb
		name = "macro phaser blast"
		icon_state = "phaser_heavy"
		sname = "macro phaser blast"
		damage = 50
		cost = 62.5
		shot_sound = 'sound/weapons/energy/phaser_huge.ogg'
		color_red = 1
		color_green = 0.2
		color_blue = 0.2

		on_hit(atom/hit, dir, obj/projectile/P)
			hit.ex_act(3, src, 1.5)
			P.die()


	mining
		name = "mining phaser bolt"
		damage = 5
		cost = 5
		dissipation_delay = 3
		icon_state = "blue_spark"

		color_red = 0.4
		color_green = 0.4
		color_blue = 1

		on_launch(obj/projectile/O)
			. = ..()
			O.AddComponent(/datum/component/proj_mining, 0.2, 5)

		on_hit(atom/hit)
			if (istype(hit,/obj/critter)) //MBC : if there was a cleaner way to do this, I couldn't find it.
				var/obj/critter/C = hit
				C.health -= power * 2
				C.on_damaged()
				if (C.health <= 0)
					C.CritterDeath()
			..()

	longrange
		icon_state = "red_bolt"
		dissipation_delay = 10
		shot_sound = 'sound/weapons/laser_b.ogg'
		color_red = 1
		color_green = 0.2
		color_blue = 0.2

	split
		dissipation_rate = 100
		damage = 120
		dissipation_delay = 2

		on_launch(var/obj/projectile/P)
			if (!P)
				return
			var/datum/projectile/laser/light/L = new()
			L.power = 40
			var/turf/PT = get_turf(P)
			var/obj/projectile/P1 = initialize_projectile(PT, L, P.xo, P.yo, P.shooter)
			P1.launch()
			var/obj/projectile/P2 = initialize_projectile(PT, L, P.xo, P.yo, P.shooter)
			P2.rotateDirection(30)
			P2.launch()
			var/obj/projectile/P3 = initialize_projectile(PT, L, P.xo, P.yo, P.shooter)
			P3.rotateDirection(-30)
			P3.launch()
			P.die()

	curver
		tick(var/obj/projectile/P)
			if (!P)
				return
			P.rotateDirection(20)
			..()

	spiral
		tick(var/obj/projectile/P)
			if (!P)
				return
			if (P.special_data["angle"] == 0)
				return
			if (!("angle" in P.special_data))
				P.special_data["angle"] = 35
			P.rotateDirection(P.special_data["angle"])
			P.special_data["angle"] /= 1.1
			if (P.special_data["angle"] < 2)
				P.special_data["angle"] = 0
			..()

	maser
		name = "maser ray"
		icon_state = "sinebeam1"
		sname = "maser ray"
		damage = 0.0001 /// to bypass 0 damage checks
		dissipation_delay = 8
		color_red = 1
		color_green = 1
		color_blue = 1
		has_impact_particles = FALSE
		var/pilot_dmg = 20
		disruption = 5

		on_hit(atom/hit)
			if (istype(hit, /mob))
				var/mob/M = hit
				M.TakeDamage("All", burn = src.pilot_dmg, damage_type = DAMAGE_BURN)
			else if (istype(hit, /obj/machinery/vehicle))
				var/obj/machinery/vehicle/vehicle = hit
				var/mob/M = vehicle.pilot
				if (istype(M))
					var/damage_pilot = TRUE
					if (istype(vehicle.sec_system, /obj/item/shipcomponent/secondary_system/shielding))
						var/obj/item/shipcomponent/secondary_system/shielding/shielding = vehicle.sec_system
						if (shielding.active)
							damage_pilot = FALSE
					if (damage_pilot)
						M.TakeDamage("All", burn = src.pilot_dmg, damage_type = DAMAGE_BURN)
			..()

		pod
			pilot_dmg = 10

	upgradeable
		icon_state = "phaser_light"
		var/datum/projectile/laser/light/launched = new/datum/projectile/laser/light
		var/count = 1

		on_launch(var/obj/projectile/P)
			launched.power = src.power
			launched.ks_ratio = src.ks_ratio
			launched.generate_inverse_stats()
			launched.icon_state = icon_state
			if (count > 1)
				var/turf/PT = get_turf(P)
				if (count == 2)
					var/obj/projectile/P1 = initialize_projectile(PT, launched, P.xo, P.yo, P.shooter)
					P1.rotateDirection(30)
					var/obj/projectile/P2 = initialize_projectile(PT, launched, P.xo, P.yo, P.shooter)
					P2.rotateDirection(-30)
					P1.launch()
					P2.launch()
				else
					var/cangle = -60
					var/angle_step = 120 / (count - 1)
					for (var/i = 0, i < count, i++)
						var/obj/projectile/PN = initialize_projectile(PT, launched, P.xo, P.yo, P.shooter)
						if (cangle != 0)
							PN.rotateDirection(cangle)
						PN.launch()
						cangle += angle_step
				P.die()

		proc/UpdateIcon()
			if (power >= 75)
				icon_state = "phaser_ultra"
			else if (power >= 50)
				icon_state = "phaser_heavy"
			else if (power >= 35)
				icon_state = "phaser_med"
			else
				icon_state = "phaser_light"

/datum/projectile/laser/glitter // for the russian pod
	name = "prismatic laser"
	icon_state = "eyebeam"
	damage = 25
	cost = 20
	sname = "phaser bolt"
	dissipation_delay = 10
	shot_sound = 'sound/weapons/TaserOLD.ogg'
	color_red = 1
	color_green = 0
	color_blue = 1
	impact_image_state = "burn2"
	projectile_speed = 42

	burst
		cost = 50
		shot_number = 3

/datum/projectile/laser/precursor // for precursor traps
	name = "rydberg-matter bolt"
	icon_state = "disrupt"
	damage = 24
	stun = 6
	cost = 30
	sname = "rydberg-matter bolt"
	dissipation_delay = 10
	shot_sound = 'sound/weapons/LaserOLD.ogg'
	color_red = 0.1
	color_green = 0.3
	color_blue = 1

/datum/projectile/laser/plasma //mostly just a reskin
	icon_state = "phaser_med"
	name = "plasma bolt"
	sname = "plasma bolt"
	shot_sound = 'sound/weapons/plasma_gun.ogg'
	dissipation_delay = 8
	dissipation_rate = 5
	cost = 25
	damage = 35
	color_red = 0.4
	color_green = 0.5
	color_blue = 0.7

// These are for custom antique laser guns repaired with high-quality components.
// See displaycase.dm for details (Convair880).
/datum/projectile/laser/old
	icon_state = "proj_thermal"
	name = "pulse laser"
	sname = "pulse laser"
	shot_sound = 'sound/weapons/snipershot.ogg'
	dissipation_delay = 7.5
	dissipation_rate = 8
	cost = 40
	damage = 70
	color_red = 1
	color_green = 0.3
	color_blue = 0

/datum/projectile/laser/old_burst
	icon_state = "proj_sing"
	name = "burst laser"
	sname = "burst laser"
	shot_sound = 'sound/weapons/snipershot.ogg'
	shot_number = 3
	cost = 100
	damage = 35
	color_red = 0.4
	color_green = 0
	color_blue = 0.7


//Projectile for Azungars NT gun.
/datum/projectile/laser/ntburst
	icon_state = "miniphaser_med"
	name = "plasma bolt"
	sname = "plasma boltburst"
	shot_sound = 'sound/weapons/lasersound.ogg'
	dissipation_delay = 8
	dissipation_rate = 5
	cost = 5
	damage = 15
	color_red = 0.4
	color_green = 0.5
	color_blue = 0.7
	shot_number = 1


// blaster projectiles


/datum/projectile/laser/blaster
	icon_state = "bolt"
	name = "blaster bolt"
	sname = "blaster"
	shot_sound = 'sound/weapons/laser_a.ogg'
	dissipation_delay = 6
	dissipation_rate = 5
	cost = 20
	damage = 33
	color_icon = "#3d9cff"
	color_red = 0.2
	color_green = 0.5
	color_blue = 1
	brightness = 1.2
	shot_number = 1

	on_launch(var/obj/projectile/P)
		. = ..()
		P.AddComponent(/datum/component/radioactive, 33, FALSE, FALSE, 2)

	/*tick(var/obj/projectile/P)
		var/obj/effects/ion_trails/I = new /obj/effects/ion_trails
		I.set_loc(get_turf(P))
		I.set_dir(P.dir)
		flick("ion_fade", I)
		I.icon_state = "blank"
		I.pixel_x = P.pixel_x
		I.pixel_y = P.pixel_y
		SPAWN( 20 )
			if (I && !I.disposed) qdel(I)*/

	lawbringer
		color_icon = "#00FFFF"
		shot_sound = 'sound/weapons/laser_b.ogg'
		projectile_speed = 46 //it's not quite the carbine but let's make it a little faster to go with the ANGRY shot sound
		shot_pitch = 0.8

	burst
		damage = 15
		cost = 30
		shot_number = 3
		icon_state = "bolt_burst"
		shot_sound = 'sound/weapons/laser_c.ogg'
		fullauto_valid = 1

	blast
		shot_sound = 'sound/weapons/laser_e.ogg'
		damage = 30
		cost = 100
		icon_state = "crescent_white"
		shot_number = 1

	cannon
		shot_sound = 'sound/weapons/energy/howitzer_shot.ogg'
		damage = 100
		cost = 200
		icon_state = "crescent"

	carbine
		shot_sound = 'sound/weapons/laser_b.ogg'
		icon_state = "bolt_long"
		dissipation_delay = 12
		dissipation_rate = 5
		projectile_speed = 56


/datum/projectile/laser/blaster/pod_pilot
	cost = 20
	damage = 33
	color_red = 0
	color_green = 0
	color_blue = 0
	override_color = 0
	icon_state = "bolt"
	damage_type = D_ENERGY
	var/turret = 0		//have turret shots do less damage, but slow mobs it hits...
	var/team_num = 0	//1 for NT, 2 for SY

	on_hit(atom/hit)
		..()
		//have turret shots slow mobs it hits...
		if (turret && isliving(hit))
			var/mob/living/L = hit
			L.changeStatus("slowed", 2 SECONDS)

	//lower power when they hit vehicles by half
	get_power(obj/projectile/P, atom/A)
		var/mult = 1
		if (!turret && istype(A, /obj/machinery/vehicle))
			mult = 0.5
		return ..(P, A) * mult


/datum/projectile/laser/blaster/pod_pilot/blue_NT
	name = "blue blaster bolt"
	color_icon = "#3d9cff"
	color_red = 0.05
	color_green = 0.28
	color_blue = 0.51
	team_num = 1

	turret
		turret = 1
		damage = 15

/datum/projectile/laser/blaster/pod_pilot/red_SY
	name = "red blaster bolt"
	color_icon = "#ff4043"
	color_red = 0.51
	color_green = 0.05
	color_blue = 0.28
	team_num = 2

	turret
		turret = 1
		damage = 15

/datum/projectile/laser/blaster/pod_pilot/blue_NT/smg
	name = "blue blaster bolt"
	color_icon = "#3d9cff"
	color_red = 0.05
	color_green = 0.28
	color_blue = 0.51
	cost = 10
	damage = 12.5
	fullauto_valid = 1
	icon_state = "bolt_burst"
	shot_sound = 'sound/weapons/laser_c.ogg'

/datum/projectile/laser/blaster/pod_pilot/red_SY/smg
	name = "red blaster bolt"
	color_icon = "#ff4043"
	color_red = 0.51
	color_green = 0.05
	color_blue = 0.28
	cost = 10
	damage = 12.5
	fullauto_valid = 1
	icon_state = "bolt_burst"
	shot_sound = 'sound/weapons/laser_c.ogg'

/datum/projectile/laser/blaster/pod_pilot/blue_NT/shotgun
	name = "blue blaster bolt"
	color_icon = "#3d9cff"
	color_red = 0.05
	color_green = 0.28
	color_blue = 0.51
	cost = 10
	damage = 15

/datum/projectile/laser/blaster/pod_pilot/red_SY/shotgun
	name = "red blaster bolt"
	color_icon = "#ff4043"
	color_red = 0.51
	color_green = 0.05
	color_blue = 0.28
	cost = 10
	damage = 15

// cogwerks- mining laser, first attempt




/datum/projectile/laser/mining
	name = "Plasma Cutter Bolt"
	icon_state = "40mmgatling"
	damage = 40
	cost = 40
	dissipation_delay = 1
	dissipation_rate = 8
	sname = "mining laser"
	shot_sound = 'sound/weapons/cutter.ogg'
	shot_volume = 30
	damage_type = D_BURNING
	brightness = 0.8
	window_pass = 0
	color_red = 0.9
	color_green = 0.6
	color_blue = 0

	on_launch(obj/projectile/O)
		. = ..()
		O.AddComponent(/datum/component/proj_mining, 0.2, 2)

/datum/projectile/laser/drill
	name = "drill bit"
	window_pass = 0
	icon_state = ""
	damage_type = D_SLASHING
	hit_type = DAMAGE_STAB
	damage = 45
	cost = 1
	brightness = 0
	sname = "drill bit"
	shot_sound = 'sound/machines/rock_drill.ogg'
	shot_volume = 20
	dissipation_delay = 1
	dissipation_rate = 45
	impact_image_state = null
	energy_particles_override = TRUE
	var/damtype = DAMAGE_STAB

	var/hit_human_sound = 'sound/impact_sounds/Slimy_Splat_1.ogg'
	on_launch(obj/projectile/O)
		. = ..()
		O.AddComponent(/datum/component/proj_mining, 0.15, 0)

	on_hit(atom/hit)
		if (ishuman(hit))
			var/mob/living/carbon/human/M = hit
			playsound(M.loc, hit_human_sound, 50, 1)
			take_bleeding_damage(M, null, 1, damtype)

	cutter
		name = "cutter blade"
		damage = 30
		dissipation_rate = 30
		sname = "scrap cutter"

	saw_teeth
		name = "saw teeth"
		damage = 5
		dissipation_rate = 5
		sname = "saw teeth"
		shot_sound = 'sound/machines/chainsaw.ogg'
		hit_human_sound = 'sound/impact_sounds/Flesh_Tear_1.ogg'
		damtype = DAMAGE_CUT
		hit_type = DAMAGE_CUT

		on_hit(atom/hit) //do extra damage to pod
			..()
			if (istype(hit,/obj/machinery/vehicle))
				var/obj/machinery/vehicle/V = hit
				V.health -= power * 1.8
				V.checkhealth()

/datum/projectile/laser/alastor
	name = "laser"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "alastor"

	damage = 35
	cost = 25
	sname = "laser"
	shot_sound = 'sound/weapons/energy/laser_alastor.ogg'
	brightness = 1
	impact_image_state = "burn1"

	on_hit(atom/hit)
		var/mob/living/L = hit
		if (!istype(L))
			return
		if(L.getStatusDuration("burning"))
			L.changeStatus("burning", 7 SECONDS)
		else
			L.changeStatus("burning", 3.5 SECONDS)

/datum/projectile/laser/signifer_lethal
	name = "signifer bolt"
	icon = 'icons/obj/projectiles.dmi'
	damage = 15
	cost = 40
	sname = "lethal"
	shot_sound = 'sound/weapons/SigLethal.ogg'
	hit_ground_chance = 30
	brightness = 1
	icon_state = "signifer2_burn"
	damage_type = D_ENERGY
	color_red = 0.1
	color_green = 0.1
	color_blue = 0.8

	disruption = 8

	shot_number = 2
	ie_type = "E"
	hit_mob_sound = 'sound/effects/sparks6.ogg'


	on_hit(atom/hit, angle, var/obj/projectile/O)
		hit.setStatus("signified")
		..()

	brute
		icon_state = "signifer2_brute"
		damage_type = D_KINETIC
		energy_particles_override = TRUE
		color_red = 0.8
		color_green = 0.1
		color_blue = 0.1

		on_hit(var/atom/hit)
			if(hit.hasStatus("signified"))
				elecflash(get_turf(hit),radius=0, power=4, exclude_center = 0)
				random_brute_damage(hit, rand(5,10), 0)
				hit.delStatus("signified")
			..()


/datum/projectile/laser/plasma/auto
	icon_state = "miniphaser_med"
	shot_sound = 'sound/weapons/lasersound.ogg'
	dissipation_delay = 4
	dissipation_rate = 2
	cost = 10
	damage = 15
	fullauto_valid = 1
	shot_volume = 75

/datum/projectile/laser/plasma/burst
	cost = 60
	damage = 20
	shot_number = 4
	shot_delay = 1
	shot_volume = 75
	projectile_speed = 42

	on_hit(atom/movable/hit, dir, datum/projectile/P)
		. = ..()
		if(hit.hasStatus("cornicened2"))
			elecflash(get_turf(hit),radius=0, power=6, exclude_center = 0)
			random_brute_damage(hit, rand(10,20), 0)
			hit.delStatus("cornicened")
			hit.delStatus("cornicened2")
		else
			hit.setStatus("cornicened")

/datum/projectile/laser/ntso_cannon
	name = "heavy assault laser"
	icon_state = "u_laser"
	damage = 80
	cost = 65
	dissipation_delay = 10
	brightness = 0
	sname = "heavy laser"
	shot_sound = 'sound/weapons/Laser.ogg'
	color_red = 0
	color_green = 0
	color_blue = 1

	on_hit(atom/hit, dir, obj/projectile/P)
		elecflash(get_turf(hit),radius=0, power=10, exclude_center = 0)
		hit.ex_act(2)
		P.die() //explicitly kill projectile - not a mining laser


/datum/projectile/laser/makeshift
	cost = 1250
	shot_sound = 'sound/weapons/laserlight.ogg'
	icon_state = "laser_tiny"
	damage = 20
	/// lower bounds of heat added to the makeshift laser rifle this was fired from
	var/heat_low = 10
	/// higher bounds of heat added to the makeshift laser rifle this was fired from
	var/heat_high = 12
/datum/projectile/laser/lasergat
	cost = 5
	shot_sound = 'sound/weapons/laser_a.ogg'
	icon_state = "lasergat_laser"
	shot_volume = 50
	dissipation_rate = 2
	name = "single"
	sname = "single"
	damage = 10

/datum/projectile/laser/lasergat/burst
	name = "burst laser"
	sname = "burst laser"
	cost = 15
	shot_number = 3
