/obj/machinery/fogmachine
	name = "FogMachine-3000"
	desc = "The FogMachine-3000 is guaranteed to suit all of your fog-filled needs. Just put the FogMaster FogFluid into the FogMachine-3000 Chemical Funnel Duct and then turn the FogMachine-3000. The FogMachine-3000 will cease to pump fog when the fluid resevoir is empty."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "fogmachine0"


	var/on = 0

	New()
		..()
		src.create_reagents(3000)

	process()
		if(reagents.has_reagent("radium"))
			src.reagents.clear_reagents()
			src.visible_message("<span class='alert'>The <B>[src]</B> makes an odd sound, and releases a puff of green steam.</span>")

		if(on == 1)
			if(reagents.reagent_list.len < 1 || reagents.total_volume < 1)
				on = 0
				icon_state = "fogmachine0"

				src.visible_message("<span class='alert'>The <B>[src]</B> splutters to a halt.</span>")
				playsound(src, 'sound/machines/ding.ogg', 50, 1)
			else
				SPAWN(5 SECONDS)
					var/datum/chemical_reaction/smoke/S = new
					S.on_reaction(reagents)
					reagents.total_volume -= 5
					if (reagents.total_volume < 5)
						reagents.total_volume = 0
						reagents.clear_reagents()
					return
		else
			return



	attackby(var/obj/item/reagent_containers/C as obj, var/mob/user as mob)
		if(!istype(C, /obj/item/reagent_containers))
			return
		if(istype(C, /obj/item/reagent_containers/glass))
			if(C.reagents.reagent_list.len < 1)
				boutput(user, "[C] is empty.")
				return
			else
				boutput(user, "You pour the contents of [C] into the funnel.")


				for(var/current_id in C.reagents.reagent_list)
					var/datum/reagent/current_reagent = C.reagents.reagent_list[current_id]

					if(current_reagent.id == "radium")
						C.reagents.del_reagent("radium")
						boutput(user, "The [src] vapourizes the radium.")
					else
						reagents.add_reagent(current_id, 10, null, null, 1)

				C.reagents.clear_reagents()
				playsound(src, 'sound/effects/bubbles.ogg', 50, 1)
				return
		else
			boutput(user, "You put [C] into the funnel.")

			for(var/current_id in C.reagents.reagent_list)
				var/datum/reagent/current_reagent = C.reagents.reagent_list[current_id]

				if(current_reagent.id == "radium")
					C.reagents.del_reagent("radium")
					boutput(user, "The [src] vapourizes the radium.")
				else
					reagents.add_reagent(current_id, 10, null, null, 1)

			qdel(C)
			playsound(src, 'sound/effects/pop.ogg', 50, 1)
			return


	attack_hand(mob/user as mob)
		if(on == 0)
			on = 1
			boutput(user, "<span class='notice'>You flip the switch on the FogMachine-3000 to the On position.</span>")
			playsound(src, 'sound/machines/click.ogg', 50, 1)
			return
		if(on == 1)
			on = 0
			playsound(src, 'sound/machines/click.ogg', 50, 1)
			boutput(user, "<span class='notice'>You flip the switch on the FogMachine-3000 to the Off position.</span>")
			return

/obj/machinery/bathtub
	name = "bathtub"
	desc = "Now, that looks cosy!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "bathtub"
	flags = OPENCONTAINER
	var/mob/living/carbon/human/myuser = null
	var/default_reagent = "water"

	New()
		..()
		src.create_reagents(500)

	get_desc(dist, mob/user)
		if (dist > 2)
			return
		if (!reagents)
			return
		. += "<br><span class='notice'>[reagents.get_description(user,RC_FULLNESS|RC_VISIBLE|RC_SPECTRO)]</span>"
		return

	// using overlay levels so it looks like you're in the bath
	// MOB_LEVEL(-0) =  all other mobs on top of us
	// MOB_LEVEL-0.1 = Bath edge to trim feet
	// MOB_LEVEL-0.2 = Water overlay
	// MOB_LEVEL-0.3 = Mob who is riding
	// MOB_LEVEL-0.4 = Water underlay

	on_reagent_change()
		if(reagents.total_volume)
			var/image/new_underlay = src.SafeGetOverlayImage("fluid_underlay", 'icons/obj/stationobjs.dmi', "fluid_bathtub", MOB_LAYER - 0.4)
			var/datum/color/average = reagents.get_average_color()
			// average.a = round(reagents.total_volume / reagents.maximum_volume) * 255 // alpha layer based on volume
			new_underlay.color = average.to_rgba()
			src.UpdateOverlays(new_underlay, "fluid_underlay")

			if (src.myuser) // only update the overlay if we have a user
				var/image/new_overlay = src.SafeGetOverlayImage("fluid_overlay", 'icons/obj/stationobjs.dmi', "fluid_bathtub", MOB_LAYER - 0.2)
				new_overlay.color = average.to_rgba()
				src.UpdateOverlays(new_overlay, "fluid_overlay")
		else
			src.UpdateOverlays(null, "fluid_underlay")
			src.UpdateOverlays(null, "fluid_overlay")
		..()

	attack_hand(mob/user as mob)
		if (is_incapacitated(user) || isAI(user)) return
		if (src.myuser)
			boutput(user, "<span class='alert'>You pull [src.myuser] out of the bath!</span>")
			src.eject_user()
		else
			boutput(user, "<span class='notice'>You pull the plug.</span>")
			src.reagents.clear_reagents()
			src.on_reagent_change()
			var/count = 0
			for (var/obj/O in src)
				count++
				qdel(O)
			if (count > 0)
				boutput(user, "<span class='alert'>...and flush something down the drain. Damn!</span>")
		return

	proc/eject_user()
		if (src.myuser)
			src.myuser.pixel_y = 0
			src.myuser.set_loc(get_turf(src))
			src.myuser = null
			src.UpdateOverlays(null, "fluid_overlay")
			src.UpdateOverlays(null, "bath_edge")
			src.UpdateOverlays(null, "rider")
			src.on_reagent_change()

			for (var/obj/O in src)
				O.set_loc(get_turf(src))
		return

	relaymove(mob/user as mob, dir)
		src.eject_user()
		boutput(user, "<span class='notice'>You get out of the bath.</span>")


	process()
		if (src.myuser)
			if(src.myuser.loc != src)
				src.myuser.pixel_y = 0
				src.myuser = null
				on_reagent_change()
				return
			if(src.reagents.total_volume > 5)
				reagents.reaction(src.myuser, TOUCH)
				src.reagents.trans_to(src.myuser,5,1)
			else
				src.reagents.clear_reagents()
				on_reagent_change()

		return

	MouseDrop_T(mob/living/carbon/human/target, mob/user)
		if (src.myuser || !istype(target) || target.buckled || LinkBlocked(target.loc,src.loc) || get_dist(user, src) > 1 || get_dist(user, target) > 1 || is_incapacitated(user) || isAI(user))
			return

		var/msg

		if(target == user && !user.stat)	// if drop self, then climbed in
			msg = "[user.name] climbs into [src]."
			boutput(user, "<span class='notice'>You climb into [src].</span>")

		else if(target != user && !user.restrained())
			msg = "[user.name] push [target.name] into the [src]!"
			boutput(user, "<span class='notice'>You push [target.name] into the [src]!</span>")

		else
			return

		target.set_loc(src)
		src.myuser = target
		src.myuser.pixel_y += 5
		src.UpdateOverlays(src.SafeGetOverlayImage("rider", getFlatIcon(src.myuser.appearance), , MOB_LAYER - 0.3), "rider") // get in nerd
		src.UpdateOverlays(src.SafeGetOverlayImage("bath_edge", 'icons/obj/stationobjs.dmi', "bath_edge", MOB_LAYER - 0.1), "bath_edge")
		src.on_reagent_change()

		for (var/mob/C in viewers(src))
			if(C == user)
				continue
			C.show_message(msg, 3)
		return

	is_open_container()
		return 1

/obj/machinery/bathtub/verb/draw_bath()
    set name = "Draw A Bath" // idea: emagging bathtub makes the bath spit out a photo of itself when you draw a bath?
    set src in oview(1)
    set category = "Local"
    if (get_dist(usr, src) <= 1 && !usr.stat)
        src.reagents.add_reagent(default_reagent,120)
        usr.visible_message("<span class='notice'>[usr] draws a bath.</span>",\
        "<span class='success'>You draw a nice bath!</span>")

/obj/item/clothing/head/apprentice
	proc/fantasia()
		if(ticker?.mode && istype(ticker.mode, /datum/game_mode/wizard))
			for (var/obj/item/mop/M in orange(5,src))
				src.visible_message("<span class='alert'>[src] begins to twitch and move!</span>")
				var/moveto = locate(M.x + rand(-1,1),M.y + rand(-1, 1),src.z)
				//make the mops move
				if (istype(moveto, /turf/simulated/floor) || istype(moveto, /turf/simulated/floor/shuttle) || istype(moveto, /turf/simulated/aprilfools/floor) || istype(moveto, /turf/unsimulated/floor) || istype(moveto, /turf/unsimulated/aprilfools)) step_towards(M, moveto)
				SPAWN(5 SECONDS)
					src.visible_message("<span class='notice'>Thankfully, [src] settles down.</span>")
		else
			for (var/obj/item/mop/M in orange(5,src))
				src.visible_message("<span class='alert'>[src] begins to twitch and mov- oh. No. No it doesn't.</span>")

/obj/item/clothing/head/apprentice/equipped(var/mob/user, var/slot)
	boutput(user, "<span class='notice'>Your head tingles with magic! Or asbestos. Probably asbestos.</span>")
	src.fantasia()
	..()
