// Dummies so they can be put on the public maps
/obj/submachine/chicken_incubator
	name = "\improper Chicken Egg Incubator"

/obj/submachine/ranch_feed_grinder
	name = "feed grinder"

/obj/chicken_nesting_box
	name = "nesting box"

/obj/item/chicken_carrier
	name = "chicken carrier"

/mob/living/critter/small_animal/ranch_base/chicken

/obj/item/reagent_containers/food/snacks/ranch_feed_bag
	rand_pos = 0

/obj/dialogueobj/dreambee

/obj/item/old_grenade/chicken

/turf/unsimulated/floor/dream/beach

/turf/unsimulated/floor/dream/space

/obj/decal/fakeobjects/dreambeach/earth

/obj/decal/fakeobjects/dreambeach/biggest/big_palm_with_nuts

/obj/decal/fakeobjects/dreambeach/sticks

/obj/decal/fakeobjects/dreambeach/biggest/big_palm

/obj/decal/fakeobjects/dreambeach/mars

/obj/decal/fakeobjects/dreambeach/saturn

/obj/decal/fakeobjects/dreambeach/stones

/obj/decal/fakeobjects/dreambeach/seashells

/obj/decal/fakeobjects/dreambeach/big/palm1

/obj/decal/fakeobjects/dreambeach/palm_leaf

/obj/decal/fakeobjects/dreambeach/mercury

/obj/item/storage/box/knitting
	name = "\improper Knitting Supplies"

/mob/living/critter/small_animal/ranch_base/sheep/white/dolly/ai_controlled

/mob/living/critter/robotic/bot/engibot

/obj/overlay/simple_light/disco_lighting
	var/randomize_start = 0
	name = "disco_overlay"

/obj/overlay/simple_light/disco_lighting/rainbow
	New()
		. = ..()
		if(randomize_start)
			spawn(rand(0,13))
				animate_rainbow_glow(src)
		else
			animate_rainbow_glow(src)

	random_start
		randomize_start = 1

/obj/overlay/simple_light/disco_lighting/oscillator
	var/color_1 = "#FF0000"
	var/color_2 = "#0000FF"

	New()
		. = ..()
		if(randomize_start)
			spawn(rand(0,13))
				oscillate_colors(src,list(color_1,color_2))
		else
			oscillate_colors(src,list(color_1,color_2))

	random_start
		randomize_start = 1

	purple_white
		color_1 = "#AA00FF"
		color_2 = "#FFFFFF"

		random_start
			randomize_start = 1

	green_pink
		color_1 = "#00FF00"
		color_2 = "#FF55AA"

		random_start
			randomize_start = 1

	blue_orange
		color_1 = "#0000FF"
		color_2 = "#FF9900"

		random_start
			randomize_start = 1

	white_black
		color_1 = "#FFFFFF"
		color_2 = "#000000"

		random_start
			randomize_start = 1
