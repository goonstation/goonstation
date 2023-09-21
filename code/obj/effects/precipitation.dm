particles/rain
	width = 672
	height = 480
	count = 2500    // 2500 particles
	spawning = 48
	bound1 = list(-1000, -240, -1000)   // end particles at Y=-240
	lifespan = 600  // live for 60s max
	fade = 35       // fade out over the last 3.5s if still on screen
	// spawn within a certain x,y,z space
	icon = 'icons/effects/particles.dmi'
	icon_state = "starsmall"
	position = generator("box", list(-300,50,0), list(300,300,50))
	gravity = list(0, -3)
	friction = 0.05
	drift = generator("sphere", 0, 1)

	dense
		spawning = 60

		tile
			count = 10
			spawning = 1.2
			fade = 4
			fadein = 2
			lifespan = generator("num", 6, 8, LINEAR_RAND)
			position = generator("box", list(-32,32,0), list(32,40,50))
			bound1 = list(-32, -32, -1000)
			bound2 = list(40, 40, 1000)
			width = 96
			height = 96

	sideways
		rotation = generator("num", -10, -20 )
		gravity = list(0.4, -3)
		drift = generator("box", list(0.1, -1, 0), list(0.4, 0, 0))

		tile
			count = 10
			spawning = 0.6
			fade = 4
			fadein = 2
			lifespan = generator("num", 6, 8, LINEAR_RAND)
			position = generator("box", list(-32,32,0), list(32,40,50))
			bound1 = list(-32, -32, -1000)
			bound2 = list(40, 40, 1000)
			// Start up initial speed and gain for tile based emitter due to shorter travel (acceleration)
			gravity = list(0, 0, 0)
			velocity = list(3, -9, 0)
			drift = generator("box", list(0.1, -1*2, 0), list(0.4*2, 0, 0))
			width = 96
			height = 96


/datum/precipitation_controller
	var/name = "Precipitation Controller"
	var/list/obj/effects/precipitation/effects
	var/datum/reagents/reagents
	var/particles/shared_particle
	var/probability = 100
	var/cooldown = 5 SECONDS
	var/max_pool_depth = 0
	var/orig_color
	var/lock_deletion = FALSE

	New(obj/effects/precipitation/start)
		..()
		src.reagents = new/datum/reagents(100)
		LAZYLISTINIT(effects)
		if(start)
			propogate_controller(get_turf(start), start.type)
		START_TRACKING

	disposing()
		for(var/obj/effects/precipitation/P in effects )
			qdel(P)
		if (!isnull(reagents))
			qdel(reagents)
			reagents = null
		STOP_TRACKING
		..()

	proc/process()
		if(!src.reagents.total_volume) return
		var/datum/reagents/R = new
		for(var/obj/effects/precipitation/P in effects)
			var/turf/T = P.loc
			for(var/atom/movable/AM in T)
				if(!(AM.event_handler_flags & USE_FLUID_ENTER)) continue

				if(!ON_COOLDOWN(AM, "precipitation_cd_\ref[src]", src.cooldown))
					src.reagents.copy_to(R)
					R.reaction(AM, TOUCH)
			if(!ON_COOLDOWN(T, "precipitation_cd_\ref[src]", src.cooldown))
				var/fluid_ok = TRUE
				if(T.active_liquid?.group.amt_per_tile >= max_pool_depth)
					fluid_ok = FALSE
				src.reagents.copy_to(R)
				R.reaction(T, TOUCH, can_spawn_fluid = fluid_ok)
			LAGCHECK(LAG_REALTIME)

	proc/cross_check(atom/A)
		if(isintangible(A)) return
		if(prob(probability) && !ON_COOLDOWN(A, "precipitation_cd_\ref[src]", src.cooldown))
			if(src.reagents.total_volume)
				var/datum/reagents/R = new
				src.reagents.copy_to(R)
				R.reaction(A,TOUCH)

	proc/propogate_controller(turf/start, desired_type)
		var/list/nodes = list()
		var/index_open = 1
		var/list/open = list(start)
		var/list/next_open = list()

		var/obj/effects/precipitation/PE = locate() in start
		nodes[PE] = TRUE
		var/i = 0
		while (index_open <= length(open) || length(next_open))
			if(i++ % 500 == 0)
				LAGCHECK(LAG_HIGH)
			if(index_open > length(open))
				open = next_open
				next_open = list()
				index_open = 1
			var/turf/T = open[index_open++]
			for (var/dir in alldirs)
				var/turf/target = get_step(T, dir)
				if (!target) continue // map edge
				PE = locate() in target
				if(!PE) continue
				if(nodes[PE]) continue
				if(PE.type != desired_type) continue
				nodes[PE] = TRUE
				next_open[target] = TRUE

		for (PE as anything in nodes)
			add_effect(PE)

	proc/add_effect(obj/effects/precipitation/PE)
		if(!src.shared_particle)
			src.shared_particle = new PE.particles.type()
			src.orig_color = shared_particle.color
		PE.particles = src.shared_particle
		PE.PC = src
		PE.PC.effects += PE

	proc/add_turfs(list/turf/turfs, type)
		if(!ispath(type, /obj/effects/precipitation))
			return
		for(var/turf/T in turfs)
			var/obj/effects/precipitation/PE = new type(T)
			add_effect(PE)

	proc/remove(obj/effects/precipitation/P)
		effects -= P
		if(!length(effects) && !src.lock_deletion)
			qdel(src)

	proc/clear_active_effects()
		lock_deletion = TRUE
		for(var/obj/effects/precipitation/P in effects)
			qdel(P)
		lock_deletion = FALSE

	proc/update()
		if(shared_particle)
			if(reagents.total_volume)
				var/datum/color/C = reagents.get_average_color()
				shared_particle.color = rgb(C.r, C.g, C.b)
			else
				if(src.orig_color)
					shared_particle.color = src.orig_color
				else
					shared_particle.color = "#fff"

obj/effects/precipitation
	anchored = ANCHORED_ALWAYS
	var/datum/precipitation_controller/PC
	event_handler_flags = 0

	Crossed(var/atom/A)
		..()
		if(PC)
			PC.cross_check(A)

	proc/generate_controller()
		PC = new(src)

	disposing()
		if(PC)
			PC.remove(src)
			PC = null
		..()

obj/effects/precipitation/rain
	particles = new/particles/rain
	plane = PLANE_NOSHADOW_ABOVE
	alpha = 200
	var/static/list/particles/z_particles

	client_attach
		screen_loc = "CENTER"

	dense
		particles = new/particles/rain/dense

		tile
			particles = new/particles/rain/dense/tile

	sideways
		particles = new/particles/rain/sideways

		tile
			particles = null
			// Offset pixel position to align bounding boxes and visual area
			pixel_y = 16
			pixel_x = -16
			var/particle_type = /particles/rain/sideways/tile

			New()
				..()

				LAZYLISTINIT(z_particles)

				var/z_level_str = "\"[src.loc.z]_[particle_type]\""
				if(!z_particles[z_level_str])
					z_particles[z_level_str] = new particle_type
				particles = z_particles[z_level_str]

particles/snow
	width = 672
	height = 480
	count = 2500    // 2500 particles
	spawning = 12    // 12 new particles per 0.1s
	bound1 = list(-1000, -240, -1000)   // end particles at Y=-240
	lifespan = 600  // live for 60s max
	fade = 50       // fade out over the last 5s if still on screen
	// spawn within a certain x,y,z space
	position = generator("box", list(-350,50,0), list(300,350,50))
	// control how the snow falls
	gravity = list(0, -1)
	friction = 0.3  // shed 30% of velocity and drift every 0.1s
	drift = generator("sphere", 0, 2)

	dense
		spawning = 48

	mega_dense
		spawning = 100
		count = 5000

	grey
		color = generator("color", "#FFF", "#AAA")
		spawning = 100
		count = 5000
		tile
			count = 10
			spawning = 0.6
			fade = 4
			fadein = 2
			lifespan = generator("num", 10, 30, LINEAR_RAND)
			position = generator("box", list(-32,32,0), list(32,48,50))
			bound1 = list(-32, -48, -500)
			bound2 = list(32, 64, 60)
			width = 96
			height = 96

			light
				count = 3
				spawning = 0.05
				friction = 0.2
				gravity = list(0, -0.1)
				drift = generator("box", list(-0.5,-0.1,0), list(0.5,0,0))
				lifespan = generator("num", 20, 90, LINEAR_RAND)


obj/effects/precipitation/snow
	particles = new/particles/snow
	plane = PLANE_NOSHADOW_ABOVE
	var/static/list/particles/z_particles

	client_attach
		screen_loc = "CENTER"
	dense
		particles = new/particles/snow/dense
	mega_dense
		particles = new/particles/snow/mega_dense
	grey
		particles = new/particles/snow/grey

		tile
			var/particle_type = /particles/snow/grey/tile

			New()
				..()

				LAZYLISTINIT(z_particles)

				var/z_level_str = "\"[src.loc.z]_[particle_type]\""
				if(!z_particles[z_level_str])
					z_particles[z_level_str] = new particle_type
				particles = z_particles[z_level_str]


			light
				particle_type = /particles/snow/grey/tile/light




