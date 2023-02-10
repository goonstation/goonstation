/////////////////////////////////////////////
// Bad smoke
/////////////////////////////////////////////

//consider replacing with newsmoke + reagent

/obj/effects/bad_smoke
	name = "smoke"
	icon_state = "smoke"
	opacity = 1
	anchored = 0
	mouse_opacity = 0
	var/amount = 6
	//Remove this bit to use the old smoke
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32

/obj/effects/bad_smoke/Move()
	. = ..()
	for(var/mob/living/carbon/M in get_turf(src))
		if (issmokeimmune(M))
		else
			M.drop_item()
			if (prob(25))
				M.changeStatus("stunned", 1 SECOND)
			M.take_oxygen_deprivation(1)
			if(!ON_COOLDOWN(M, "bad_smoke_cough", 0.2 SECONDS))
				M.emote("cough")
	return

/obj/effects/bad_smoke/Crossed(atom/movable/AM)
	..()
	if(iscarbon(AM))
		var/mob/living/carbon/M = AM
		if (issmokeimmune(M))
			return
		else
			M.drop_item()
			if (prob(25))
				M.changeStatus("stunned", 1 SECOND)
			M.take_oxygen_deprivation(1)
			if(!ON_COOLDOWN(M, "bad_smoke_cough", 0.2 SECONDS))
				M.emote("cough")
	return
