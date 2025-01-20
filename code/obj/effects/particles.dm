
/obj/effects/little_sparks
	var/obj/spark_generator/sparks = new/obj/spark_generator

	New()
		..()
		src.sparks.mouse_opacity = 0
		vis_contents += src.sparks

/obj/effects/little_sparks/lit
	New()
		..()
		src.add_simple_light("spark_light", list(0.94 * 255, 0.94 * 255, 0.94 * 255, 0.7 * 255))
		animate(simple_light, alpha=(0.5*255), loop=-1, time=6)
		animate(alpha=(0.3*255), time=3, easing=ELASTIC_EASING)
		animate(alpha=(0.7*255), time=3, easing=CUBIC_EASING)
		animate(time=7)
		animate(alpha=(0.5*255), time=3, easing=ELASTIC_EASING)
		animate(alpha=(0.7*255), time=3, easing=CUBIC_EASING)


/obj/effects/little_sparks/tatara
	New()
		..()
		src.sparks.particles.spawning = 0

	proc/spark_up()
		if(!ON_COOLDOWN(src,"spark_up",2 SECONDS))
			sparks.particles.spawning = 16
			playsound(src, 'sound/impact_sounds/burn_sizzle.ogg', 30)
			SPAWN(1 SECONDS)
				sparks.particles.spawning = 0

/obj/effects/welding
	appearance_flags = RESET_COLOR | RESET_ALPHA | PIXEL_SCALE
	vis_flags = VIS_INHERIT_DIR
	var/emitters = list(new/obj/spark_generator, new/obj/spark_generator/flame)
	icon = 'icons/effects/fire.dmi'
	icon_state = "fire1"
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


/obj/spark_generator
	particles = new/particles/spark
	plane = PLANE_NOSHADOW_ABOVE
	alpha = 200

	filters = list(type="bloom", threshold="#000", size=3, offset=2, alpha=1)

	flame
		filters = null
		particles = new/particles/spark/flame

	directed
		particles = new/particles/spark/directed


/particles/spark
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
		fadein = 6
		position = generator("sphere", 1, 2)
		icon = 'icons/effects/particles.dmi'
		icon_state = list("streak"=5, ""=2)
		rotation = generator("num", -45, 45)
		spin = generator("num", -5, 5)
		velocity = generator("box", list(-1,-1,0), list(1,1,0))
		color = generator("color", "#ff5", "#f77")
		drift = generator("sphere", 0, 1, SQUARE_RAND)


	flame
		lifespan = 5  // live for 60s max
		fade = 2      // fade out over the last 3.5s if still on screen
		bound1 = list(-32, -32, -5)   // end particles at Y=-300
		bound2 = list(32, 32, 10)   // end particles at Y=-300
		friction = 0.05
		position = list(0,0,0) // spawn within a certain x,y,z space
		color = generator("color", "#fff", "#ffb")
		drift = generator("sphere", 0.2, 1)

/// firey embers, for use with burning_barrel
/particles/barrel_embers
	color = generator("color", "#FF2200", "#FF9933", UNIFORM_RAND)
	spawning = 0.5
	count = 30
	lifespan = 30
	fade = 5
	position = generator("vector", list(-3,6,0), list(3,6,0), NORMAL_RAND)
	gravity = list(0, 0.2, 0)
	color_change = 0
	friction = 0.2
	drift = generator("vector", list(0.25,0,0), list(-0.25,0,0), UNIFORM_RAND)
	fadein = 10

/particles/barrel_smoke
	icon = 'icons/effects/64x64.dmi'
	icon_state = list("smoke_static")
	color = "#2222225A"
	height = 200
	spawning = 0.08
	count = 3
	lifespan = 2 SECONDS
	fade = 1 SECOND
	position = generator("vector", list(-2,8,0), list(2,8,0), NORMAL_RAND)
	gravity = list(0, 0.3, 0)
	scale = list(0.1, 0.1)
	rotation = generator("num", -90, 90, NORMAL_RAND)
	spin = generator("num", -5, 5, UNIFORM_RAND)
	grow = list(0.05, 0.05)
	fadein = 0.2 SECONDS

/particles/arcfiend
	color = generator("color", "#ff9900", "#ffff00", NORMAL_RAND)
	width = 200
	height = 200
	spawning = 5
	count = 200
	lifespan = 10
	fade = 10
	position = generator("circle", 0, 64, NORMAL_RAND)
	friction = generator("num", 0, 0, NORMAL_RAND)
	drift = generator("box", list(-0.1,-0.1,0), list(0.1,0.1,0), UNIFORM_RAND)

/particles/arcfiend/robojumper
	spawning = 2
	count = 10
	position = generator("circle", -20, 20, NORMAL_RAND)

/particles/stink_lines
	icon = 'icons/effects/particles.dmi'
	icon_state = list("line")
	color = generator("color", "#808000", "#806900", NORMAL_RAND)
	spawning = 0.3
	lifespan = 30
	fade = 10
	fadein = 10
	position = generator("circle", 10, 12, NORMAL_RAND)
	friction = generator("num", 0.1, 0.3, NORMAL_RAND)
	drift = generator("box", list(0.1,0.05,0), list(-0.1,0,0), UNIFORM_RAND)
	rotation = generator("num", -45, 45, UNIFORM_RAND)

/// Used for bloodlings, maybe would be cool for other stuff!
/particles/bloody_aura
	icon = 'icons/effects/particles.dmi'
	icon_state = list("8x8circle")
	color = generator("color", "#440020", "#86090B", UNIFORM_RAND)
	spawning = 0.5
	count = 40
	lifespan = 15
	fade = 6
	fadein = 2
	position = generator("circle", 6, 8, NORMAL_RAND)
	scale = list(1.2, 1.2)
	grow = list(-0.05, -0.05)
	gravity = list(0, 1, 0)
	friction = 0.5
	drift = generator("vector", list(0.25,0,0), list(-0.25,0,0), UNIFORM_RAND)

/particles/healing
	icon = 'icons/effects/particles.dmi'
	icon_state = list("plus")
	color = generator("color", "#63c94e", "#368826", UNIFORM_RAND)
	spawning = 0.75
	lifespan = 15
	fade = 6
	fadein = 2
	position = generator("circle", 6, 8, NORMAL_RAND)
	scale = list(1.2, 1.2)
	grow = list(-0.05, -0.05)
	gravity = list(0, 1, 0)
	friction = 0.5
	drift = generator("vector", list(0.25,0,0), list(-0.25,0,0), UNIFORM_RAND)

/particles/healing/flock
	color = generator("color", "#89e2b8", "#5aeeb0", UNIFORM_RAND)

/// Used for Lavender reagent
/particles/petals
	icon = 'icons/effects/particles.dmi'
	icon_state = list("petal")
	color = generator("color", "#e268ff", "#9a68ff", UNIFORM_RAND)
	spawning = 0.2
	count = 40
	lifespan = 12
	fade = 6
	fadein = 2
	position = generator("box", list(-15,15,0), list(12,-12,0), NORMAL_RAND)
	scale = list(1.2, 1.2)
	grow = list(-0.05, -0.05)
	gravity = list(0, 1, 0)
	spin =  generator("num", 10, -10, NORMAL_RAND)
	friction = 0.5
	drift = generator("vector", list(0.25,0,0), list(-0.25,0,0), UNIFORM_RAND)

/particles/flintlock_smoke
	icon = 'icons/effects/64x64.dmi'
	icon_state = "smoke"
	color = "#ffffff"
	width = 200
	height = 200
	spawning = 10
	count = 10
	lifespan = 50
	fade = 50
	position = list(0, 0, 0)
	friction = generator("num", 0.9, 0.4, UNIFORM_RAND)
	drift = generator("box", list(1,1,0), list(-1,-1,0), UNIFORM_RAND)
	scale = list(0.15, 0.15)
	rotation = generator("num", 0, 360, UNIFORM_RAND)
	grow = generator("vector", list(0.08,0.08,0), list(0.03,0.03,0), UNIFORM_RAND)
	fadein = 5
	spawning = 20

/obj/effects/flintlock_smoke
	plane = PLANE_NOSHADOW_ABOVE
	particles = new/particles/flintlock_smoke

	New()
		..()
		SPAWN(0.5 SECONDS)
			src.particles?.spawning = 0
			sleep(src.particles?.lifespan)
			qdel(src)

	// Takes x and y of a normalised vector to set direction of smoke.
	proc/setdir(var/dir_x, var/dir_y)
		particles.velocity = generator("box", list(50*dir_x - 0.5, 50*dir_y - 0.5, 0), list(40*dir_x + 0.5, 40*dir_y + 0.5, 0), UNIFORM_RAND)

/particles/sprinkle
	color = "#3399ff"
	spawning = 3
	count = 30
	lifespan = 4.5
	position = generator("box", list(-6,-5,0), list(6,20,0), UNIFORM_RAND)
	gravity = list(0, -1, 0)
	scale = list(1.5, 1.5)

/particles/gunshot_impact_dust
	icon = 'icons/effects/particles.dmi'
	icon_state = list(""=1, "2x2square"=1)
	width = 256
	height = 256
	color = "#ddcea2"
	spawning = 10
	count = 10
	lifespan = 2.5 SECONDS
	fade = 2.5 SECONDS
	position = list(0, 0, 0)
	gravity = list(0, 0, 0)
	spin = generator("num", 5, -5, NORMAL_RAND)
	friction = generator("num", 0.4, 0.2, UNIFORM_RAND)

/particles/gunshot_impact_smoke
	icon = 'icons/effects/particles.dmi'
	icon_state = list("impact_smoke")
	width = 256
	height = 256
	color = "#e6e6e613"
	spawning = 5
	count = 5
	lifespan = 1.5 SECONDS
	fade = 1.5 SECONDS
	position = list(0, 0, 0)
	gravity = list(0, 0, 0)
	scale = list(0.7, 1)
	grow = list(0.04, 0.08)
	spin = generator("num", 5, -5, NORMAL_RAND)
	friction = generator("num", 0.4, 0.3, UNIFORM_RAND)
	drift = generator("vector", list(3,3,0), list(-3,-3,0), UNIFORM_RAND)

/particles/gunshot_impact_sparks
	icon = 'icons/effects/particles.dmi'
	icon_state = list("")
	width = 256
	height = 256
	color = "#d1bb77"
	spawning = 5
	count = 5
	lifespan = 1 SECOND
	fade = 1 SECOND
	position = list(0, 0, 0)
	gravity = list(0, 0, 0)
	spin = generator("num", 5, -5, NORMAL_RAND)
	friction = generator("num", 0.3, 0.2, UNIFORM_RAND)
	drift = generator("vector", list(8,8,0), list(-8,-8,0), UNIFORM_RAND)

/particles/gunshot_impact_bubble
	icon = 'icons/effects/particles.dmi'
	icon_state = list("bubble")
	width = 256
	height = 256
	color = "#ffffff"
	spawning = 6
	count = 6
	lifespan = 2 SECONDS
	fade = 2 SECONDS
	scale = list(0.7, 0.7)
	position = list(0, 0, 0)
	gravity = list(0, 0, 0)
	spin = generator("num", 5, -5, NORMAL_RAND)
	friction = generator("num", 0.5, 0.3, UNIFORM_RAND)

/obj/effects/gunshot_impact
	plane = PLANE_NOSHADOW_ABOVE
	particles = null
	var/base_amt = 0

	New(loc, var/dir_x = 0, var/dir_y = 0, var/damage = 0, var/color_avrg = null, var/impact_icon = null, var/impact_icon_state = null)
		if (damage <= 5)
			particles.count = 0
			particles.spawning = 0
		else if (damage > 5 && damage <= 35)
			var/new_amt = round(src.base_amt / 2.5)
			particles.count = new_amt
			particles.spawning = new_amt
			particles.velocity = generator("box", list(20*dir_x, 20*dir_y, 0), list(7*dir_x, 7*dir_y, 0), UNIFORM_RAND)
		else if (damage > 35 && damage <= 60)
			particles.velocity = generator("box", list(40*dir_x, 40*dir_y, 0), list(15*dir_x, 15*dir_y, 0), UNIFORM_RAND)
		else if (damage > 60)
			var/new_amt = round(src.base_amt * 2)
			particles.count = new_amt
			particles.spawning = new_amt
			particles.velocity = generator("box", list(60*dir_x, 60*dir_y, 0), list(20*dir_x, 20*dir_y, 0), UNIFORM_RAND)
		if (color_avrg)
			particles.color = color_avrg
		if (impact_icon && impact_icon_state)
			particles.icon = impact_icon
			particles.icon_state = impact_icon_state
		..()
		SPAWN(2 DECI SECOND)
			src.particles?.spawning = 0
			sleep(src.particles?.lifespan)
			qdel(src)

/obj/effects/gunshot_impact/dust
	base_amt = 10
	particles = new/particles/gunshot_impact_dust
	plane = PLANE_NOSHADOW_BELOW

/obj/effects/gunshot_impact/smoke
	base_amt = 5
	particles = new/particles/gunshot_impact_smoke

/obj/effects/gunshot_impact/sparks
	base_amt = 5
	particles = new/particles/gunshot_impact_sparks

/obj/effects/gunshot_impact/bubble
	base_amt = 6
	particles = new/particles/gunshot_impact_bubble
