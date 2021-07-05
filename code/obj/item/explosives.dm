/obj/item/explosive_telecrystal
	name = "pure telecrystal"
	desc = "A pure Telecrystal, useful for creating small, precise warps in space."
	icon = 'icons/obj/materials.dmi'
	icon_state = "telecrystal_pure"
	/*pickup(mob/user)
		boutput(user, "<span class='alert'>The [src] explodes!</span>")
		var/turf/T = get_turf(src.loc)
		if(T)
			T.hotspot_expose(700,125)
			explosion(src, T, -1, -1, 2, 3) //about equal to a PDA bomb
		src.set_loc(user.loc)
		qdel(src)*/
