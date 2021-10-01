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

	sideways
		rotation = generator("num", -10, -20 )
		gravity = list(0.4, -3)
		drift = generator("box", list(0.1, -1, 0), list(0.4, 0, 0))

		tile
			count = 5
			spawning = 1.1
			fade = 5
			lifespan = generator("num", 4, 6, LINEAR_RAND)
			position = generator("box", list(-96,32,0), list(300,64,50))
			bound1 = list(-32, -48, -1000)
			bound2 = list(32, 64, 1000)
			// Start up initial speed and gain for tile based emitter due to shorter travel (acceleration)
			gravity = list(0.4*3, -3*3)
			drift = generator("box", list(0.1, -1*2, 0), list(0.4*2, 0, 0))
			width = 96
			height = 96


obj/effects/rain
	particles = new/particles/rain
	plane = PLANE_NOSHADOW_ABOVE
	alpha = 200
	var/static/list/particles/z_particles

	client_attach
		screen_loc = "CENTER"

	dense
		particles = new/particles/rain/dense

	sideways
		particles = new/particles/rain/sideways

		tile
			particles = null
			// Offset pixel position to align bounding boxes and visual area
			pixel_y = 16
			pixel_x = -16

			New()
				..()
				LAZYLISTINIT(z_particles)
				var/z_level_str = "\"[src.loc.z]\""
				if(!z_particles[z_level_str])
					z_particles[z_level_str] = new/particles/rain/sideways/tile
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
			count = 5
			spawning = 1.1
			fade = 5
			lifespan = generator("num", 10, 30, LINEAR_RAND)
			position = generator("box", list(-96,32,0), list(96,64,50))
			bound1 = list(-32, -48, -500)
			bound2 = list(32, 64, 60)
			width = 96
			height = 96


obj/effects/snow
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
			particles = null

			New()
				..()
				LAZYLISTINIT(z_particles)
				var/z_level_str = "\"[src.loc.z]\""
				if(!z_particles[z_level_str])
					z_particles[z_level_str] = new/particles/snow/grey/tile
				particles = z_particles[z_level_str]



