/obj/religious_cross
	name = "cross"
	desc = "Built in honor of the messaih himself, probably"
	icon = 'icons/obj/furniture/cross.dmi'
	icon_state = "cross"
	anchored = UNANCHORED
	density = 0
	mat_appearances_to_ignore = list("wood")

	New()
		..()

	attackby(obj/item/I, mob/user)  //placeholder put up on cross test

		user.pixel_y = 15 //placeholder put up on cross test
		user.loc = src.loc //placeholder put up on cross test
		user.dir = SOUTH //placeholder put up on cross test
		user.dir_locked = TRUE //placeholder put up on cross test
		user.buckled = TRUE

		..()


