obj/effects/welding
	var/emitters = list(new/obj/spark_generator, new/obj/spark_generator/flame)
	New(var/atom/newloc, var/dirn)
		..()
		for(var/obj/E in emitters)
			E.mouse_opacity = 0
			vis_contents += E
		src.add_simple_light("welding", list(0.94 * 255, 0.94 * 255, 0.94 * 255, 0.7 * 255))
		animate(simple_light, alpha=(0.6*255), loop=-1, time=6)
		animate(alpha=(0.3*255), time=3, easing=ELASTIC_EASING)
		animate(alpha=(0.7*255), time=3, easing=CUBIC_EASING)
		animate(time=7)
		animate(alpha=(0.5*255), time=3, easing=ELASTIC_EASING)
		animate(alpha=(0.7*255), time=3, easing=CUBIC_EASING)

		if(dirn)
			src.Turn(dir2angle(dirn))

	directed
		emitters = list(new/obj/spark_generator/directed, new/obj/spark_generator/flame)

particles/spark
	width = 32     // 500 x 500 image to cover a moderately sized map
	height = 32
	count = 32    // 2500 particles
	spawning = 16
	bound1 = list(-40, -40, 0)
	bound2 = list(40, 40, 10)
	lifespan = 10  // live for 60s max
	fade = 5       // fade out over the last 3.5s if still on screen
	position = generator("sphere", 1, 2)
	gravity = list(0,0.2)
	friction = 0
	drift = generator("sphere", 1.5, 2, SQUARE_RAND)
	color = generator("color", "#ff5", "#f00")

	directed
		bound2 = list(40,5,10)

	flame
		lifespan = 5  // live for 60s max
		fade = 2      // fade out over the last 3.5s if still on screen
		bound1 = list(-32, -32, -5)   // end particles at Y=-300
		bound2 = list(32, 32, 10)   // end particles at Y=-300
		friction = 0.05
		position = list(0,0,0) // spawn within a certain x,y,z space
		color = generator("color", "#fff", "#ffb")
		drift = generator("sphere", 0.2, 1)


obj/spark_generator
	particles = new/particles/spark
	plane = PLANE_NOSHADOW_ABOVE
	alpha = 200

	filters = list(type="bloom", threshold="#000", size=3, offset=2, alpha=1)

	flame
		filters = null
		particles = new/particles/spark/flame

	directed
		particles = new/particles/spark/directed
