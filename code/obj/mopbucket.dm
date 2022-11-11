/obj/mopbucket
	desc = "Fill it with water, but don't forget a mop!"
	name = "mop bucket"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = 1
	flags = FPRINT
	pressure_resistance = ONE_ATMOSPHERE
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	var/rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO
	var/image/fluid_image
	p_class = 1.2

	New()
		. = ..()
		src.fluid_image = image(src.icon, "fluid", -1)

	update_icon()
		if (reagents.total_volume)
			var/datum/color/average = reagents.get_average_color()
			src.fluid_image.color = average.to_rgba()
			src.UpdateOverlays(src.fluid_image, "fluid")
		else
			src.ClearSpecificOverlays("fluid")

	on_reagent_change()
		..()
		src.UpdateIcon()

/obj/mopbucket/New()
	..()
	create_reagents(400)
	START_TRACKING

/obj/mopbucket/disposing()
	. = ..()
	STOP_TRACKING

/obj/mopbucket/get_desc(dist, mob/user)
	if (dist > 2)
		return
	if (!reagents)
		return
	. = "<br><span class='notice'>[reagents.get_description(user,rc_flags)]</span>"
	return

/obj/mopbucket/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/mop))
		if (src.reagents.total_volume >= 3)
			if (W.reagents)
				W.reagents.trans_to(src,W.reagents.total_volume)
			src.reagents.trans_to(W, W.reagents ? W.reagents.maximum_volume : 10)

			boutput(user, "<span class='notice'>You dunk the mop into [src].</span>")
			playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
		if (src.reagents.total_volume < 1)
			boutput(user, "<span class='notice'>[src] is empty!</span>")
	else
		return ..()

/obj/mopbucket/mouse_drop(atom/over_object as obj)
	if (!istype(over_object, /obj/item/reagent_containers/glass) && !istype(over_object, /obj/item/reagent_containers/food/drinks) && !istype(over_object, /obj/item/spraybottle) && !istype(over_object, /obj/machinery/plantpot) && !istype(over_object, /obj/mopbucket))
		return ..()

	if (BOUNDS_DIST(usr, src) > 0 || BOUNDS_DIST(usr, over_object) > 0)
		boutput(usr, "<span class='alert'>That's too far!</span>")
		return

	src.transfer_all_reagents(over_object, usr)

/obj/mopbucket/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if (!in_interact_range(user, src) || user.restrained() || user.getStatusDuration("paralysis") || user.sleeping || user.stat || user.lying || user.buckled)
		return

	if (O == user)
		//check to see if the user is trying to go through walls, etc.
		var/turf/T = get_turf(src)
		var/no_go = !T.Enter(user) ? T : null
		if(isnull(no_go))
			for(var/atom/A in T)
				if(A != src && !A.Cross(user))
					no_go = A
					break
		if(no_go)
			user.show_text("You bump into \the [no_go] as you try to scoot over \the [src].", "red")
			user.Bump(no_go)
			return

		if (iscarbon(O))
			var/mob/living/carbon/M = user
			if (M.bioHolder && M.bioHolder.HasEffect("clumsy") && prob(40))
				user.visible_message("<span class='alert'><b>[user]</b> trips over [src]!</span>",\
				"<span class='alert'>You trip over [src]!</span>")
				playsound(user.loc, 'sound/impact_sounds/Generic_Hit_2.ogg', 15, 1, -3)
				user.set_loc(src.loc)
				user.changeStatus("weakened", 1 SECOND)
				JOB_XP(user, "Clown", 1)
				return
			else
				user.show_text("You scoot around [src].")
				user.set_loc(src.loc)
				return

		if (issilicon(O))
			user.show_text("You scoot around [src].")
			user.set_loc(src.loc)
			return


/obj/mopbucket/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			if (prob(50))
				qdel(src)
				return
		if(3)
			if (prob(5))
				qdel(src)
				return
