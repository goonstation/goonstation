//Warning! Do not animate to low alpha values unless you animate to a high non 255 value first. This breaks things for some bizzare reason.

// particle system states
#define PS_READY 1
#define PS_RUNNING 2
#define PS_ASLEEP 3
#define PS_FINISHED 0

// --------------------------------------------------------------------------------------------------------------------------------------
// Base object used for particles

/obj/particle
	name = ""
	desc = ""
	mouse_opacity = 0
	pass_unstable = FALSE
	anchored = 1
	density = 0
	opacity = 0
	layer = EFFECTS_LAYER_BASE
	animate_movement = NO_STEPS //Stop shifting around recycled particles.
	event_handler_flags = IMMUNE_MANTA_PUSH
	var/atom/target = null // target location for directional particles
	var/override_state = null
	var/death = 0

	disposing()
		particleMaster.active_particles -= src
		..()

// --------------------------------------------------------------------------------------------------------------------------------------
// Master particle datum, handles creating and recycling particles and particle systems

var/datum/particleMaster/particleMaster = new

/datum/particleMaster
	var/list/particleTypes = null
	var/list/particleSystems = null
	var/list/active_particles = list()
	var/allowed_particles_per_tick = 7

	New()
		..()
		particleTypes = list()
		particleSystems = list()
		for (var/ptype in childrentypesof(/datum/particleType))
			var/datum/particleType/typeDatum = new ptype()
			particleTypes[typeDatum.name] = typeDatum

	proc/SpawnSystem(var/datum/particleSystem/system)
		RETURN_TYPE(/datum/particleSystem)
		if (!istype(system))
			return

		particleSystems += system

		if (system.location)
			system.location.temp_flags |= HAS_PARTICLESYSTEM
		if (system.target)
			system.target.temp_flags |= HAS_PARTICLESYSTEM_TARGET

		return system

	// check if a particular location has a particle system running there
	proc/CheckSystemExists(var/systemType, var/atom/location)
		for (var/datum/particleSystem/system in particleSystems)
			if (system.type == systemType && system.location == location)
				return 1
		return 0

	//for clean gc
	proc/ClearSystemRefs(var/atom/location)
		for (var/datum/particleSystem/system in particleSystems)
			if (system.location == location)
				system.location = null
				system.target = null
		return 0

	// kill a particle system in progress
	proc/RemoveSystem(var/systemType, var/atom/location)
		var/count = 0
		for (var/datum/particleSystem/system in particleSystems)
			if (system.location == location)
				if (system.type == systemType)
					system.Die()
					particleSystems -= system
				else
					count++

		if (count <= 0)
			location?.temp_flags &= ~HAS_PARTICLESYSTEM
		//mbc : lazy remove location has_particlesystem_target flag below in particle system Die() proc. Not 100% reliable but i dont wanna do another search for target.


	// Called by the particle process loop in the game controller
	// Runs every effect that's ready to go and cleans up anything that's finished or in an invalid location
	proc/Tick()
		SPAWN(0)
			var/count = 1
			for (var/datum/particleSystem/system in particleSystems)
				if (!(count++ % allowed_particles_per_tick))
					sleep(0.1 SECONDS)

				if (!istype(system.location))
					system.state = PS_FINISHED
					particleSystems -= system
					continue

				switch(system.state)
					if (PS_FINISHED)
						particleSystems -= system
						continue

					if (PS_READY)
						system.Run()
						continue

					if (PS_ASLEEP)
						if (system.next_wake < ticker.round_elapsed_ticks)
							system.Run()
						continue


		var/time = world.time
		for (var/obj/particle/P in src.active_particles)
			if (P.death < time)
				src.active_particles -= P
				P.dispose() // skip the tiny qdel overhead
				P = null

	//Spawns specified particle. If type can be recycled, do that - else create new. After time is over, move particle to recycling to avoid del and new calls.
	proc/SpawnParticle(var/atom/location, var/particleTypeName, var/particleTime, var/particleColor, var/atom/target, var/particleSprite) //This should be the only thing you access from the outside.
		var/datum/particleType/pType = particleTypes[particleTypeName]

		if (istype(pType))
			var/obj/particle/p = new_particle(particleTime)
			var/turf/T = get_turf(location)
			T?.vis_contents += p
			p.color = particleColor
			if (particleSprite)
				p.override_state = particleSprite
			if (target)
				p.target = get_turf(target)
			pType.Apply(p)

			return p
		else
			return 0

	proc/new_particle(var/lifetime)
		var/obj/particle/P = new /obj/particle
		P.death = world.time + lifetime
		src.active_particles += P
		return P

// --------------------------------------------------------------------------------------------------------------------------------------
// These datums are used by the particle master datum to apply the various effects to the base particle object before use.

/datum/particleType
	var/name = null
	var/icon = null
	var/icon_state = null

	// ugly but fast
	var/matrix/first = null
	var/matrix/second = null
	var/matrix/third = null

	New()
		..()
		MatrixInit()

	proc/MatrixInit()
		return

	proc/Apply(var/obj/particle/par)
		if (istype(par))
			par.icon = icon
			par.icon_state = par.override_state ? par.override_state : icon_state
			return 1
		return 0


/datum/particleType/elecpart
	name = "elecpart"
	icon = 'icons/effects/particles.dmi'
	icon_state = "electro"

	MatrixInit()
		first = matrix()
		second = matrix()
		third = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.blend_mode = BLEND_ADD
			par.pixel_x += rand(-3,3)
			par.pixel_y += rand(-3,3)

			first.Turn(rand(-90, 90))
			first.Scale(0.1,0.1)
			par.transform = first

			second = matrix(first, 20, MATRIX_SCALE)

			third.Scale(0.1,0.1)
			third.Turn(rand(-90, 90))

			var/move_x = rand(-96, 96)
			var/move_y = rand(-96, 96)

			animate(par,transform = second, time = 5, alpha = 100)
			animate(transform = third, time = 10, pixel_y = move_y, pixel_x = move_x, alpha = 1)

			MatrixInit()

/datum/particleType/elecpart_green
	name = "elecpart_green"

	MatrixInit()
		first = matrix()
		second = matrix()
		third = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.blend_mode = BLEND_ADD
			par.pixel_x += rand(-10,10)
			par.pixel_y += rand(-10,10)

			var/rot = rand(-90, 90)
			first.Turn(rot)
			first.Scale(0.1,0.1)
			par.transform = first

			second = matrix(first, 10, MATRIX_SCALE)

			third = matrix(matrix(first, rot, MATRIX_ROTATE), 0.1, MATRIX_SCALE)

			animate(par,transform = second, time = 5, alpha = 245)
			animate(transform = third, time = 5, alpha = 50)

			first.Reset()
			second.Reset()
			third.Reset()

var/matrix/MS0101 = matrix(0.1, 0, 0, 0, 0.1, 0)
/datum/particleType/glitter
	name = "glitter"
	icon = 'icons/effects/glitter.dmi'

	MatrixInit()
		first = matrix()
		second = matrix()
		third = matrix()

	Apply(var/obj/particle/par)
		if(..())
			var/rot = rand(-45, 45)
			var/matrix/first = turn(MS0101, rot)
			var/matrix/second = matrix(first, 12, MATRIX_SCALE)

			par.pixel_x += rand(-5,5)
			par.pixel_y += rand(-5,5)
			par.color = random_saturated_hex_color()
			par.icon_state = "glitter[rand(1,10)]"
			par.transform = first
			animate(par,transform = second, time = 10, alpha = 200)
			animate(transform = matrix(turn(second, rot), 0.1, MATRIX_SCALE), time = 10, alpha = 50)

/datum/particleType/sparkle
	name = "sparkle"
	icon = 'icons/effects/particles.dmi'
	icon_state = "sparkle"

	MatrixInit()
		first = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.pixel_x += rand(-10,10)
			par.pixel_y += rand(-10,10)

			var/rot = rand(-90, 90)
			first.Turn(rot)
			first.Scale(0.1,0.1)
			par.transform = first

			first.Scale(11)
			animate(par, transform = first, time = 5, alpha = 245)

			first.Scale(0.1 / 11)
			first.Turn(rot)
			animate(transform = first, time = 5, alpha = 50)
			first.Reset()

/datum/particleType/tpbeam
	name = "tpbeam"
	icon = 'icons/effects/particles.dmi'
	icon_state = "tpbeam"
	var/start_y = -16
	var/end_y = 32

	MatrixInit()
		first = matrix(1, 0.1, MATRIX_SCALE)
		second = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.pixel_x += rand (-10, 10)
			par.pixel_y = start_y
			par.alpha = 0

			par.transform = first

			animate(par, time = 3, alpha = 255)
			animate(transform = second, time = 2.2 SECONDS + rand(0,6), pixel_y = end_y, alpha = 0)

			MatrixInit()

/datum/particleType/tpbeam/down
	name = "tpbeamdown"
	start_y = 16
	end_y = -16

/datum/particleType/swoosh
	name = "swoosh"
	icon = 'icons/effects/particles.dmi'
	icon_state = "swoosh"

	MatrixInit()
		first = matrix()
		second = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.pixel_x += rand(-14,14)
			par.pixel_y = -16
			par.alpha = 200

			var/xflip = rand(100) > 50 ? -1 : 1
			first.Scale(xflip, 0.01)
			par.transform = first

			second.Scale(xflip, 1)

			animate(par,transform = second, time = 40, alpha = 0, pixel_y = 64)

			MatrixInit()

/datum/particleType/fireworks
	name = "fireworks"
	icon = 'icons/effects/effects.dmi'
	icon_state = "wpart"

	MatrixInit()
		first = matrix()
		second = matrix()
		third = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.blend_mode = BLEND_ADD
			par.color = rgb(rand(0, 255),rand(0, 255),rand(0, 255))

			first.Turn(rand(-180, 180))
			second.Turn(rand(-90, 90))
			second.Scale(0.5,0.5)
			third.Turn(rand(-90, 90))

			if(!istype(par)) return
			animate(par, time = 10, transform = first, pixel_y = 96, alpha = 250)
			animate(transform = second, time = 10, pixel_y = 96 + rand(-32, 32), pixel_x = rand(-32, 32) + par.pixel_x, easing = SINE_EASING, alpha = 200)
			animate(transform = third, time = 7, pixel_y = 0, easing = LINEAR_EASING|EASE_OUT, alpha = 0)

			MatrixInit()

/datum/particleType/confetti
	name = "confetti"
	icon = 'icons/effects/effects.dmi'
	icon_state = "wpart"

	MatrixInit()
		first = matrix()
		second = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.blend_mode = BLEND_ADD
			var/r = 255
			var/g = 255
			var/b = 255
			switch (rand(1, 3))
				if (1)
					r = rand(0, 150)
				if (2)
					g = rand(0, 150)
				if (3)
					b = rand(0, 150)
			par.color = rgb(r, g, b)

			first.Turn(rand(-90, 90))
			first.Scale(0.5,0.5)
			second.Turn(rand(-90, 90))

			if(!istype(par)) return
			animate(par, transform = first, time = 4, pixel_y = rand(-32, 32) + par.pixel_y, pixel_x = rand(-32, 32) + par.pixel_x, easing = LINEAR_EASING)
			animate(transform = second, time = 5, alpha = 0, pixel_y = par.pixel_y - 5, easing = LINEAR_EASING|EASE_OUT)

			MatrixInit()

/datum/particleType/gravaccel
	name = "gravaccel"
	icon = 'icons/effects/effects.dmi'
	icon_state = "wpart"

	MatrixInit()
		first = matrix(0.25, MATRIX_SCALE)
		second = matrix(0.125, MATRIX_SCALE)
		third = matrix(0.1, MATRIX_SCALE)

	Apply(var/obj/particle/par)
		if(..())
			par.blend_mode = BLEND_ADD
			par.pixel_x = rand(-14, 14)
			par.pixel_y = rand(-14, 14)

			par.transform = first

			if(!length(par.vis_locs))
				return
			var/turf/T = par.vis_locs[1]

			var/move_x = ((par.target.x-T.x) * 2) * 32 + rand(-14, 14)
			var/move_y = ((par.target.y-T.y) * 2) * 32 + rand(-14, 14)

			animate(par,transform = second, time = 25, pixel_y = move_y,  pixel_x = move_x , easing = SINE_EASING)
			animate(transform = third, time = 5, easing = LINEAR_EASING|EASE_OUT)

/datum/particleType/cruiserSmoke
	name = "cruiserSmoke"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "smoke"

	MatrixInit()
		first = matrix()
		second = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.pixel_x += rand(0, 96)
			par.pixel_y += rand(0, 96)
			par.color = "#777777"

			first.Turn(rand(-90, 90))
			first.Scale(0.1, 0.1)
			par.transform = first

			second = first
			second.Scale(5,5)
			second.Turn(rand(-90, 90))

			animate(par,transform = second, time = 5, color="#dddddd", alpha = 120)
			animate(transform = third, time = 20, pixel_y = par.pixel_y+32,  alpha = 1)

			MatrixInit()

/datum/particleType/areaSmoke
	name = "areaSmoke"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "smoke"

	MatrixInit()
		first = matrix()
		second = matrix()
		third = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.pixel_x += -16 + rand(-112,122)
			par.pixel_y += -16 + rand(-112,122)

			first.Turn(rand(-90, 90))
			first.Scale(0.1, 0.1)
			par.transform = first

			second = first
			second.Scale(5,5)

			third.Scale(2,2)
			third.Turn(rand(-90, 90))

			animate(par,transform = second, time = 5, alpha = 250)
			animate(transform = third, time = 20, alpha = 1)

			MatrixInit()

/datum/particleType/chemSpray
	name = "chemSpray"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "smoke"

	MatrixInit()
		first = matrix(0.1, MATRIX_SCALE)
		second = matrix(0.3, MATRIX_SCALE)
		third = matrix(0.6, MATRIX_SCALE)


	Apply(var/obj/particle/par)
		if(..())
			par.alpha = 50

			par.transform = first

			var/move_x
			var/move_y

			if(!length(par.vis_locs))
				return
			var/turf/T = par.vis_locs[1]

			if (par.target)
				move_x = (par.target.x-T.x)*32 + rand(-32, 0)
				move_y = (par.target.y-T.y)*32 + rand(-32, 0)
			else
				move_x = rand(-64, 64)
				move_y = rand(-64, 64)

			animate(par,transform = second, time = 10, pixel_y = move_y, pixel_x = move_x, alpha = 25)
			animate(transform = third, time = 5, alpha = 1)

/datum/particleType/fireSpray
	name = "fireSpray"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "smoke"

	MatrixInit()
		first = matrix(0.1, MATRIX_SCALE)
		second = matrix(0.3, MATRIX_SCALE)
		third = matrix(0.6, MATRIX_SCALE)

	Apply(var/obj/particle/par)
		if(..())
			par.color = "#FF0000"
			par.alpha = 50

			par.transform = first

			var/move_x
			var/move_y

			if(!length(par.vis_locs))
				return
			var/turf/T = par.vis_locs[1]

			if (par.target)
				move_x = (par.target.x-T.x)*32 + rand(-32, 0)
				move_y = (par.target.y-T.y)*32 + rand(-32, 0)
			else
				move_x = rand(-64, 64)
				move_y = rand(-64, 64)

			animate(par,transform = second, time = 20, color = "#FFFF00", pixel_y = move_y, pixel_x = move_x, alpha = 25)
			animate(transform = third, time = 10, color="#FFFFFF", alpha = 1)

/datum/particleType/localSmokeSmall
	name = "localSmokeSmall"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "smoke"

	MatrixInit()
		first = matrix()
		second = matrix()
		third = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.pixel_x += -16 + rand(-3,3)
			par.pixel_y += -16 + rand(-3,3)

			first = turn(first, rand(-90, 90))
			first.Scale(0.05, 0.05)
			par.transform = first

			second = first // assignment operator modifies an existing matrix
			second.Scale(2.5,2.5)

			third.Scale(1,1)
			third = turn(third, rand(-90, 90))

			animate(par,transform = second, time = 5, alpha = 200)
			animate(transform = third, time = 20, pixel_y = rand(-48, 48), pixel_x = rand(-48, 48), alpha = 1)

			MatrixInit()

/datum/particleType/localSmoke
	name = "localSmoke"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "smoke"

	MatrixInit()
		first = matrix()
		second = matrix()
		third = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.pixel_x += -16 + rand(-3,3)
			par.pixel_y += -16 + rand(-3,3)

			first = turn(first, rand(-90, 90))
			first.Scale(0.1, 0.1)
			par.transform = first

			second = first // assignment operator modifies an existing matrix
			second.Scale(5,5)

			third.Scale(2,2)
			third = turn(third, rand(-90, 90))

			animate(par,transform = second, time = 5, alpha = 200)
			animate(transform = third, time = 20, pixel_y = rand(-96, 96), pixel_x = rand(-96, 96), alpha = 1)

			MatrixInit()

/datum/particleType/radevent_warning
	name = "radevent_warning"
	icon = 'icons/effects/particles.dmi'
	icon_state = "8x8circle"

	MatrixInit()
		first = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.alpha = 250
			par.color = "#FF00FF"
			par.blend_mode = BLEND_SUBTRACT

			first = turn(first, rand(-360,360))
			first.Scale(rand(4,6))

			animate(par, transform = first, time = 50, alpha = 1, pixel_x = rand(-8,8), pixel_y = rand(-8,8), easing = LINEAR_EASING)

			first.Reset()

/datum/particleType/radevent_pulse
	name = "radevent_warning"
	icon = 'icons/effects/particles.dmi'
	icon_state = "8x8circle"

	MatrixInit()
		first = matrix(50, MATRIX_SCALE)

	Apply(var/obj/particle/par)
		if(..())
			par.alpha = 250
			par.color = "#00AA00"
			par.blend_mode = BLEND_ADD

			animate(par, transform = first, time = 7, alpha = 1, easing = LINEAR_EASING)

/datum/particleType/bhole_static
	name = "bhole_static"
	icon_state = "2x2square"

	Apply(var/obj/particle/par)
		if(..())
			par.blend_mode = BLEND_MULTIPLY
			par.alpha = 255
			par.color = "#7E52C4"
			par.pixel_x = rand(-128,128)
			par.pixel_y = rand(-128,128)

			animate(par, time = 100, alpha = 250, pixel_y = par.pixel_y + rand(64,256), easing = LINEAR_EASING)
			animate(time = 4, pixel_y = par.pixel_y + rand(64,256) + 4, alpha = 200,easing = LINEAR_EASING)
			animate(time = 4, pixel_y = par.pixel_y + rand(64,256) + 4, alpha = 1,easing = LINEAR_EASING)

/datum/particleType/soundwave
	name = "soundwave"
	icon = 'icons/effects/particles.dmi'
	icon_state = "8x8ring"

	MatrixInit()
		first = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.alpha = 255
			par.color = "#FFFFFF"

			first.Scale(rand(5,10))

			animate(par, transform = first, time = 6, alpha = 1, easing = LINEAR_EASING)

			first.Reset()

/datum/particleType/tele_wand
	name = "tele_wand"
	icon = 'icons/effects/particles.dmi'
	icon_state = "8x8circle"

	MatrixInit()
		first = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.alpha = 255
			par.pixel_x = rand(-16,16)
			par.pixel_y = rand(-16,16)

			first = turn(first, rand(-360,360))
			first.Scale(rand(0.25,0.75))

			animate(par, transform = first, time = 6, pixel_y = par.pixel_y + rand(8,16), alpha = 1, easing = LINEAR_EASING)

			first.Reset()

/datum/particleType/blob_attack
	name = "blob_attack"
	icon = 'icons/effects/particles.dmi'
	icon_state = "splatter1"

	MatrixInit()
		first = matrix(0.2, 0.5, MATRIX_SCALE)

	Apply(var/obj/particle/par)
		if(..())
			par.icon_state = pick("splatter1", "splatter2", "splatter3")
			par.alpha = 220
			par.pixel_x = rand(-12,12)
			par.pixel_y = rand(-12,12)

			animate(par, transform = first, pixel_y = par.pixel_y - rand(12,32), time = 20, alpha = 1, easing = SINE_EASING)

/datum/particleType/blob_heal
	name = "blob_heal"
	icon = 'icons/effects/particles.dmi'
	icon_state = "bubble"

	Apply(var/obj/particle/par)
		if(..())
			par.alpha = 220
			par.pixel_x = rand(-8,8)
			par.pixel_y = rand(-8,8)

			animate(par, pixel_x = par.pixel_x + rand(-6,6), pixel_y = par.pixel_y + rand(32,64), time = 30, alpha = 1, easing = SINE_EASING)

/datum/particleType/warp_star
	name = "warp_star"
	icon = 'icons/effects/particles.dmi'
	icon_state = "starsmall"
	var/star_direction = NORTH // the direction the stars travel to

	MatrixInit()
		first = matrix()
		second = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.set_dir(src.star_direction)
			if (prob(40))
				par.icon_state = "starlarge"

			if (src.star_direction & NORTH|SOUTH)
				par.pixel_x += rand(-240,240)
			if (src.star_direction & EAST|WEST)
				par.pixel_y += rand(-240,240)
			//par.pixel_y += rand(-96,0)

			par.transform = first

			second = first

			animate(par,transform = second, time = 1, alpha = 255)
			switch (src.star_direction)
				if (NORTH)
					animate(transform = third, time = rand(1,25), pixel_y = 800, alpha = 25)
				if (SOUTH)
					animate(transform = third, time = rand(1,25), pixel_y = -800, alpha = 25)
				if (EAST)
					animate(transform = third, time = rand(1,25), pixel_x = 800, alpha = 25)
				if (WEST)
					animate(transform = third, time = rand(1,25), pixel_x = -800, alpha = 25)

			MatrixInit()

/datum/particleType/warp_star/warp_star_s
	name = "warp_star_s"
	star_direction = SOUTH

/datum/particleType/warp_star/warp_star_e
	name = "warp_star_e"
	star_direction = EAST

/datum/particleType/warp_star/warp_star_w
	name = "warp_star_w"
	star_direction = WEST

/datum/particleType/blow_cig_smoke
	name = "blow_cig_smoke_n"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "smoke"
	var/blow_direction = NORTH
	var/pixel_travel = 42

	MatrixInit()
		first = matrix()
		second = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.pixel_x += -18
			par.pixel_y -= 7
			if (src.blow_direction == EAST)
				par.pixel_x += 5
			if (src.blow_direction == WEST)
				par.pixel_x -= 5
			par.color = "#DBDBDB"

			first.Turn(rand(-90, 90))
			first.Scale(0.1, 0.1)
			par.transform = first

			second = first
			second.Scale(3,3)
			second.Turn(rand(-90, 90))

			animate(par,transform = second, time = 1, alpha = 220)
			switch (src.blow_direction)
				if (NORTH)
					animate(transform = third, time = rand(18,25), pixel_y = par.pixel_y + pixel_travel, alpha = 1)
				if (SOUTH)
					animate(transform = third, time = rand(18,25), pixel_y = par.pixel_y - pixel_travel, alpha = 1)
				if (EAST)
					animate(transform = third, time = rand(18,25), pixel_x = par.pixel_x + pixel_travel, alpha = 1)
				if (WEST)
					animate(transform = third, time = rand(18,25), pixel_x = par.pixel_x - pixel_travel, alpha = 1)


			MatrixInit()

/datum/particleType/blow_cig_smoke/blow_cig_smoke_s
	name = "blow_cig_smoke_s"
	blow_direction = SOUTH

/datum/particleType/blow_cig_smoke/blow_cig_smoke_e
	name = "blow_cig_smoke_e"
	blow_direction = EAST

/datum/particleType/blow_cig_smoke/blow_cig_smoke_w
	name = "blow_cig_smoke_w"
	blow_direction = WEST

/datum/particleType/glow_stick_dance
	name = "glow_stick_dance"
	icon = 'icons/effects/particles.dmi'
	icon_state = "sparkle"

	MatrixInit()
		first = matrix()
		second = matrix()
		third = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.pixel_x += rand(-6,6)
			par.pixel_y += rand(-6,6)
			par.alpha = 0
			par.transform = first
			first.Turn(rand(-90, 90))
			second = first
			second.Turn(rand(-90, 90))
			second.Scale(2,2)
			third = first
			third.Turn(rand(-180,180))
			third.Scale(0.7,0.7)

			var/x1 = rand(-12,12)
			var/y1 = rand(-12,12)
			var/x2 = rand(-12,12)
			var/y2 = rand(-12,12)
			var/x3 = rand(-12,12)
			var/y3 = rand(-12,12)
			var/x4 = rand(-12,12)
			var/y4 = rand(-12,12)

			animate(par, time = 2.5, pixel_x = x1, pixel_y = y1, alpha = 230)
			animate(transform = second, time = 2.5, pixel_x = x2, pixel_y = y2)
			animate(time = 2.5, pixel_x = x3, pixel_y = y3)
			animate(transform = third, time = 2.5, pixel_x = x4, pixel_y = y4, alpha = 0)

			MatrixInit()

// --------------------------------------------------------------------------------------------------------------------------------------
// Each particle system datum represents one effect happening in the world.

/datum/particleSystem
	var/state = PS_READY
	var/next_wake = 0
	var/sleepCounter = 0
	var/particleTypeName = null
	var/particleTime = 0
	var/particleColor = null
	var/particleSprite = null
	var/atom/location = null
	var/atom/target = null

	New(var/atom/location = null, var/particleTypeName = null, var/particleTime = null, var/particleColor = null, var/atom/target = null, particleSprite = null)
		..()
		if (location && particleTypeName)
			src.location = location
			src.particleTypeName = particleTypeName
			src.particleTime = particleTime
			src.particleColor = particleColor
			src.particleSprite = particleSprite
			src.target = target
			InitPar()
		else
			Die()

	proc/InitPar()
		sleepCounter = 1

	proc/Run()
		if (state == PS_RUNNING)
			return 0
		state = PS_RUNNING
		if (!istype(location) || !particleTypeName)
			Die()
		return state != PS_FINISHED

	// time to sleep is in 1/10th seconds, this works off timeofday
	proc/Sleep(var/time)
		time = min(time, 0)
		state = PS_ASLEEP
		next_wake = ticker.round_elapsed_ticks + time

	proc/Die()
		state = PS_FINISHED
		location = null
		if (target)	//mbc : lazy remove location has_particlesystem_target flag below. Not 100% reliable but i dont wanna do another search for target.
			target.temp_flags &= ~HAS_PARTICLESYSTEM_TARGET
		target = null
		particleTypeName = null

	proc/SpawnParticle()
		. = 0
		if (location && particleTypeName)
			var/obj/particle/par = particleMaster.SpawnParticle(get_turf(location), particleTypeName, particleTime, particleColor, target, particleSprite)
			if (!istype(par))
				Die()
			else
				. = par
		else
			Die()

/datum/particleSystem/sparkles
	New(var/atom/location = null)
		..(location, "sparkle", 10, "#FFFFDD")
	Run()
		if (..())
			if (prob(35))
				SpawnParticle()
			Sleep(1)

/datum/particleSystem/sparklesagentb
	New(var/atom/location = null)
		..(location, "sparkle", 10, "#ff0000")

	InitPar()
		sleepCounter = 3

	Run()
		if (..())
			if (sleepCounter > 0)
				sleepCounter--
				SpawnParticle()
				Sleep(1)
			else
				Die()

/datum/particleSystem/sparkles_disco
	New(var/atom/location = null)
		..(location, "sparkle", 10, "#FFFFFF")
	Run()
		if (..())
			SpawnParticle()
			if (prob(40))
				SpawnParticle()
			if (prob(20))
				SpawnParticle()
			Sleep(1)

/datum/particleSystem/glitter
	New(var/atom/location = null)
		..(location, "glitter", 10)
	Run()
		if (..())
			if (prob(35))
				SpawnParticle()
			Sleep(1)

/datum/particleSystem/swoosh/endless
	Run()
		if (..())
			SpawnParticle()
			Sleep(4)

/datum/particleSystem/swoosh
	New(var/atom/location = null)
		..(location, "swoosh", 45, "#5C0E80")

	InitPar()
		sleepCounter = 30

	Run()
		if (..())
			if (sleepCounter > 0)
				sleepCounter--
				SpawnParticle()
				Sleep(4)
			else
				Die()

/datum/particleSystem/elecburst
	New(var/atom/location = null)
		..(location, "elecpart", 15, "#5577CC")

	InitPar()
		sleepCounter = 10

	Run()
		if (..())
			if (sleepCounter > 0)
				sleepCounter--
				for(var/i=0, i<rand(5,9), i++)
					SpawnParticle()
				Sleep(1)
			else
				Die()

/datum/particleSystem/firespray
	New(var/atom/location, var/atom/destination)
		..(location, "fireSpray", 10, null, destination)

	InitPar()
		sleepCounter = 10

	Run()
		if (..())
			if (sleepCounter > 0)
				sleepCounter--
				for(var/i=0, i<rand(5,14), i++)
					SpawnParticle()
				Sleep(1)
			else
				Die()

/datum/particleSystem/localSmoke
	New(var/col = "#ffffff", var/duration = 20, var/atom/location = null)
		..(location, "localSmoke", 26, col)
		sleepCounter = duration

	Run()
		if (..())
			if (sleepCounter > 0)
				sleepCounter--
				for(var/i=0, i<rand(2,6), i++)
					SpawnParticle()
				Sleep(1)
			else
				Die()

/datum/particleSystem/cruiserSmoke
	New(var/atom/location = null)
		..(location, "cruiserSmoke", 26, "#777777")

	Run()
		if (..())
			for(var/i=0, i<rand(2,6), i++)
				SpawnParticle()
			Sleep(1)

/datum/particleSystem/areaSmoke

	New(var/col = "#ffffff", var/duration = 10, var/atom/location = null)
		..(location, "areaSmoke", 26, col)
		sleepCounter = duration

	Run()
		if (..())
			if (sleepCounter > 0)
				sleepCounter--
				for(var/i=0, i<rand(2,6), i++)
					SpawnParticle()
				Sleep(1)
			else
				Die()

/datum/particleSystem/areaSmoke/blueTest
	New(var/atom/location = null)
		..("#3333ff", 1000, location)

/datum/particleSystem/fireworks
	New(var/atom/location = null)
		..(location, "fireworks", 35)

	Run()
		if (..())
			for(var/i=0, i<rand(40,50), i++)
				SpawnParticle()
			Die()

/datum/particleSystem/confetti
	New(var/atom/location = null)
		..(location, "confetti", 35)

	Run()
		if (..())
			for(var/i=0, i<rand(40,50), i++)
				SpawnParticle()
			Die()

/datum/particleSystem/confetti_more
	New(var/atom/location = null)
		..(location, "confetti", 35)

	Run()
		if (..())
			for(var/i=0, i<rand(60,80), i++)
				SpawnParticle()
			Die()

/datum/particleSystem/explosion
	New(var/atom/location = null)
		..(location, "exppart", 25)

	Run()
		if (..())
			for(var/i=0, i<45, i++)
				SpawnParticle()
			Die()

/datum/particleSystem/tpbeam
	New(var/atom/location = null)
		..(location, "tpbeam", 28)

	InitPar()
		sleepCounter = 6

	Run()
		if (..())
			if (sleepCounter > 0)
				sleepCounter--
				for(var/i=0, i<rand(1,4), i++)
					SpawnParticle()
				Sleep(1)
			else
				Die()

/datum/particleSystem/tpbeamdown
	New(var/atom/location = null)
		..(location, "tpbeamdown", 28)

	InitPar()
		sleepCounter = 6

	Run()
		if (..())
			if (sleepCounter > 0)
				sleepCounter--
				for(var/i=0, i<rand(1,4), i++)
					SpawnParticle()
				Sleep(1)
			else
				Die()

/datum/particleSystem/fireTest
	New(var/atom/location = null)
		..(location, "fireTest", 21)

	InitPar()
		sleepCounter = 1000

	Run()
		if (..())
			if (sleepCounter > 0)
				sleepCounter--
				for(var/i=0, i<rand(2,10), i++)
					SpawnParticle()
				Sleep(1)
			else
				Die()

/datum/particleSystem/stinkTest
	New(var/atom/location = null)
		..(location, "stink", 21)

	Run()
		if (..())
			SpawnParticle()
			Sleep(1)

/datum/particleSystem/radevent_warning
	New(var/atom/location = null)
		..(location, "radevent_warning", 50)

	InitPar()
		sleepCounter = 20

	Run()
		if (..())
			if (sleepCounter > 0)
				sleepCounter--
				SpawnParticle()
				Sleep(0.5)
			else
				Die()

/datum/particleSystem/radevent_pulse
	New(var/atom/location = null)
		..(location, "radevent_pulse", 7)

	InitPar()
		sleepCounter = 20

	Run()
		if (..())
			if (sleepCounter > 0)
				sleepCounter--
				SpawnParticle()
				Sleep(0.2)
			else
				Die()

/datum/particleSystem/bhole_warning
	New(var/atom/location = null)
		..(location, "bhole_warning", 108)

	InitPar()
		sleepCounter = 100

	Run()
		if (..())
			if (sleepCounter > 0)
				sleepCounter--
				SpawnParticle()
				Sleep(1)
			else
				Die()

/datum/particleSystem/sonic_burst
	New(var/atom/location = null)
		..(location, "soundwave", 4)

	InitPar()
		sleepCounter = rand(5,12)

	Run()
		if (..())
			if (sleepCounter > 0)
				sleepCounter--
				SpawnParticle()
				Sleep(1)
			else
				Die()

/datum/particleSystem/tele_wand
	var/particle_sprite = null

	New(var/atom/location,var/p_sprite,var/p_color)
		..(location, "tele_wand", 6, p_color, null, p_sprite)

	Run()
		if (..())
			for(var/i=0, i < rand(5,12), i++)
				SpawnParticle()
			Die()


/datum/particleSystem/blobattack
	New(var/atom/location = null, var/color)
		..(location, "blob_attack", 70, color)

	InitPar()
		sleepCounter = rand(2,5)

	Run()
		if (..())
			if (sleepCounter > 0)
				sleepCounter--
				SpawnParticle()
				Sleep(0.2)
			else
				Die()

/datum/particleSystem/blobheal
	New(var/atom/location = null, var/color)
		..(location, "blob_heal", 60, color)

	InitPar()
		sleepCounter = rand(3,4)

	Run()
		if (..())
			if (sleepCounter > 0)
				sleepCounter--
				SpawnParticle()
				Sleep(0.2)
			else
				Die()

// always c
/datum/particleSystem/chemSmoke
	var/datum/reagents/copied
	var/list/affected
	var/list/banned_reagents = list("smokepowder", "propellant", "pyrosium", "fluorosurfactant", "salt", "poor_concrete", "okay_concrete", "good_concrete", "perfect_concrete")
	var/smoke_size = 3

	New(var/atom/location = null, var/datum/reagents/source, var/duration = 20, var/size = 3)
		smoke_size = size
		var/part_id = "localSmoke"
		if (size < 3)
			part_id = "localSmokeSmall"
		..(location, part_id, 26)
		if(source)
			affected = list()
			copied = new/datum/reagents(source.maximum_volume)
			copied.inert = 1 //No reactions inside the metaphysical concept of smoke thanks.
			source.copy_to(copied, 1, 1)
			source.clear_reagents()
			for (var/banned in banned_reagents)
				copied.del_reagent("[banned]")
			particleColor = copied.get_master_color(1)
			sleepCounter = duration
		else
			Die()

	Die()
		..()
		if (affected)
			affected.Cut()
		affected = null
		if (copied)
			copied.dispose()
		copied = null

	Run()
		if (..())
			if (sleepCounter > 0)
				if(sleepCounter % 5 == 0) //Once every 5 ticks.
					DoEffect()

				sleepCounter--
				for(var/i=0, i<rand(2,6), i++)
					SpawnParticle()

				Sleep(1)
			else
				Die()

	proc/DoEffect()
		if (!location)
			Die()
			return

		for(var/atom/A in view(smoke_size, get_turf(location)))
			if(istype(A, /obj/particle) || istype(A, /obj/overlay/tile_effect/))
				continue
			if(A in affected) continue
			affected += A
			if(!can_line(location, A, smoke_size)) continue
			if(!istype(A,/obj/particle) && !istype(A,/obj/effects/foam))
				copied.reaction(A, TOUCH, 0, 0)
			if(isliving(A))
				var/mob/living/L = A
				if(!issmokeimmune(L))
					logTheThing(LOG_COMBAT, A, "is hit by chemical smoke [log_reagents(copied)] at [log_loc(A)].")
					if(L.reagents)
						copied.copy_to(L.reagents, 1 / max((GET_DIST(A, location)+1)/2, 1)**2) //applies an adjusted inverse-square falloff to amount inhaled - 100% at center and adjacent tiles, then 44%, 25%, 16%, 11%, etc.

/datum/particleSystem/chemspray
	var/datum/reagents/copied = null

	New(var/atom/location, var/atom/destination, var/datum/reagents/source)
		..(location, "chemSpray", 10, null, destination)
		copied = new/datum/reagents(source.maximum_volume)
		source.copy_to(copied)
		particleColor = copied.get_master_color(1)

	InitPar()
		sleepCounter = 2

	Die()
		..()
		copied.dispose()
		copied = null

	Run()
		if (..())
			if (sleepCounter > 0)
				sleepCounter--
				for(var/i=0, i<rand(2,6), i++)
					SpawnParticle()
				Sleep(1)
			else
				Die()

/datum/particleSystem/mechanic
	New(var/atom/location, var/atom/destination)
		..(location, "mechpart", GET_DIST(location, destination) * 5,  "#00FF00", destination)

	InitPar()
		sleepCounter = 10

	Run()
		if (..())
			if (sleepCounter > 0)
				sleepCounter--
				SpawnParticle()
				Sleep(2)
			else
				state = PS_READY

/datum/particleSystem/gravaccel
	New(var/atom/location, var/direction)
		..(location, "gravaccel", 25, "#1155ff", get_step(location, direction))

	InitPar()
		sleepCounter = 30

	Run()
		if (..())
			if (sleepCounter > 0)
				sleepCounter--
				for(var/x=0, x<3, x++)
					SpawnParticle()
				Sleep(1)
			else
				Die()

/datum/particleSystem/warp_star
	New(var/atom/location = null, var/star_dir = null)
		..(location, "warp_star[star_dir]", 35, "#FFFFFF")

	Run()
		if (..())
			SpawnParticle()
			Sleep(1)

/datum/particleSystem/blow_cig_smoke
	New(var/atom/location = null, var/blow_dir = null)
		var/dir_append = "_n"
		switch(blow_dir)
			if (EAST)
				dir_append = "_e"
			if (WEST)
				dir_append = "_w"
			if(SOUTH)
				dir_append = "_s"

		..(location, "blow_cig_smoke[dir_append]", 25, "#DBDBDB")
		SpawnParticle()	//want this particle system to display asap - needs to show up at the same time as its flavor text, not after


	InitPar()
		sleepCounter = 2

	Run()
		if (..())
			if (sleepCounter > 0)
				sleepCounter--
				SpawnParticle()
				Sleep(0.1)
			else
				Die()

/datum/particleSystem/glow_stick_dance
	New(var/atom/location = null)
		..(location, "glow_stick_dance", 9.9, "#66ff33")
		SpawnParticle()
