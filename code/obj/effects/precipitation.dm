particles/snow
	width = 300     // 500 x 500 image to cover a moderately sized map
	height = 300
	count = 2500    // 2500 particles
	spawning = 12    // 12 new particles per 0.1s
	bound1 = list(-1000, -100, -1000)   // end particles at Y=-300
	lifespan = 600  // live for 60s max
	fade = 50       // fade out over the last 5s if still on screen
	// spawn within a certain x,y,z space
	position = generator("box", list(-300,50,0), list(300,300,50))
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

	rain
		spawning = 48
		gravity = list(0, -3)
		friction = 0.01
		fade = 35

obj/snow_generator
	icon = 'icons/obj/objects.dmi'
	icon_state = "shieldoff"
	particles = new/particles/snow
	plane = PLANE_NOSHADOW_ABOVE

	player_attached
		screen_loc = "CENTER"

	dense
		particles = new/particles/snow/dense

	mega_dense
		particles = new/particles/snow/mega_dense

	grey
		particles = new/particles/snow/grey

	rain
		particles = new/particles/snow/rain
		alpha = 200
		color = "#aaf"


particles/rain
	width = 300     // 500 x 500 image to cover a moderately sized map
	height = 300
	count = 2500    // 2500 particles
	spawning = 48
	bound1 = list(-1000, -100, -1000)   // end particles at Y=-300
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

	mega_dense
		spawning = 100
		count = 5000

	sideways
		rotation = generator("num", -10, -20 )
		gravity = list(0.4, -3)
		drift = generator("box", list(0.1, -1, 0), list(0.4, 0, 0))


obj/rain_generator
	icon = 'icons/obj/objects.dmi'
	icon_state = "shieldoff"
	particles = new/particles/rain
	plane = PLANE_NOSHADOW_ABOVE
	alpha = 200

	player_attached
		screen_loc = "CENTER"

	dense
		particles = new/particles/rain/dense

	mega_dense
		particles = new/particles/rain/mega_dense

	sideways
		particles = new/particles/rain/sideways



mob
	proc/CreateRain()
		client?.screen += new/obj/rain_generator
