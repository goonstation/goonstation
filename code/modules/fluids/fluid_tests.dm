/*
 * Include this file in the .dme if you want to test fluids with these commands!
 */


/mob/living/proc/ttt()//just flicker images as a test
	src.show_submerged_image(rand(0,4))
	SPAWN(1 DECI SECOND)
		src.ttt()


/obj/proc/ttt()//just flicker images as a test
	src.show_submerged_image(rand(0,4))
	SPAWN(1 DECI SECOND)
		src.ttt()
