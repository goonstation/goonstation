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
	var/mob/living/carbon/human/occupant = null
	var/default_reagent = "water"
	var/on = FALSE
	var/suffocation_volume = 200 // tracking fluid_core's drowning depth_level vOv

	New()
		..()
		src.create_reagents(500)
		if (prob(1))
			default_reagent = "sodawater"
			desc += " But, it's faintly fizzing?"

	disposing()
		if(src.occupant)
			src.occupant.set_loc(get_turf(src))
			src.occupant = null
		. = ..()

	mob_flip_inside(var/mob/user)
		if (src.reagents.total_volume)
			user.visible_message("<span class='notice'>[src.occupant] splish-splashes around.</span>", "<span class='alert'>You splash around enough to shake the tub!</span>", "<span class='notice'>You hear liquid splash on the ground.</span>")
			playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 25, 1)
			animate_wiggle_then_reset(src, 1, 3)
			src.reagents.trans_to(src.last_turf, 5)
		else
			..()

	// I Can't Believe It's Not Drowning!, a dirty copy/paste hack from breath & fluid_core
	handle_internal_lifeform(mob/lifeform_inside_me, breath_request)
		var/mob/M = lifeform_inside_me
		if (M.lying && M.get_oxygen_deprivation() > 40 && src.reagents.total_volume > suffocation_volume && breath_request > 0 )
			src.reagents.reaction(M, INGEST)
			src.reagents.trans_to(M, 5) // in addition to TOUCH in process()
			return null
		else
			. = ..()

	mouse_drop(obj/over_object as obj, src_location, over_location)
		if (src.occupant)
			eject_occupant(usr, over_object)
		else
			src.reagents.clear_reagents()
			src.on_reagent_change()

	get_desc(dist, mob/user)
		if (dist > 2)
			return
		if (!reagents)
			return
		. += "<br><span class='notice'>[reagents.get_description(user,RC_FULLNESS|RC_VISIBLE|RC_SPECTRO)]</span>"
		return

	// using overlay levels so it looks like you're in the bath
	// we don't use show_submerged_image since we want the head to poke out
	// MOB_LAYER(-0) =  all other mobs on top of us
	// MOB_LAYER-0.1 = Bath edge to trim feet
	// MOB_LAYER-0.2 = Water overlay
	// MOB_LAYER-0.3 = Occupant
	// MOB_LAYER-0.4 = Water underlay

	on_reagent_change()
		if(reagents.total_volume)
			var/image/new_underlay = src.SafeGetOverlayImage("fluid_underlay", 'icons/obj/stationobjs.dmi', "fluid_bathtub", MOB_LAYER - 0.4)
			var/datum/color/average = reagents.get_average_color()
			var/fill_ratio = reagents.total_volume / reagents.maximum_volume
			if (fill_ratio < 0.5)
				average.a = round(average.a * fill_ratio * 2)
			else
				average.a = average.a + round((255 - average.a) * (fill_ratio - 0.5) * 2)
			new_underlay.color = average.to_rgba()
			src.UpdateOverlays(new_underlay, "fluid_underlay")

			if (src.occupant) // only update the overlay if we have an occupant
				var/image/new_overlay = src.SafeGetOverlayImage("fluid_overlay", 'icons/obj/stationobjs.dmi', "fluid_bathtub", MOB_LAYER - 0.2)
				new_overlay.color = average.to_rgba()
				src.UpdateOverlays(new_overlay, "fluid_overlay")

				// I don't want to do this here but no where else feels right
				// maybe a new chem transfer instead? Could be a new knob to tweak for cyrox too?
				// #define SUBMERGED 4
				// it would also make future projects of mine easier, so both this is and i am a hack
				if(reagents.get_reagent_amount("blood") > 200) // arbitrary
					// reagents don't track DNA, so it's your own blood vOv
					src.occupant.shoes?.add_blood(src.occupant)
					src.occupant.gloves?.add_blood(src.occupant)
					if (src.occupant.wear_suit)
						src.occupant.wear_suit.add_blood(src.occupant)
					else if (src.occupant.w_uniform)
						src.occupant.w_uniform.add_blood(src.occupant)
					src.occupant.add_blood(src.occupant)
					src.occupant.update_clothing()
					src.occupant.update_body()

		else
			src.UpdateOverlays(null, "fluid_underlay")
			src.UpdateOverlays(null, "fluid_overlay")
		..()

	attack_hand(mob/user as mob)
		src.turn_tap(user)

	proc/enter_bathtub(mob/living/carbon/human/target)
		target.set_loc(src)
		src.occupant = target
		src.UpdateOverlays(src.SafeGetOverlayImage("bath_edge", 'icons/obj/stationobjs.dmi', "bath_edge", MOB_LAYER - 0.1), "bath_edge")
		src.on_reagent_change()
		target.layer = MOB_LAYER - 0.3
		src.vis_contents += target
		if (src.reagents.total_volume)
			playsound(src.loc, "sound/misc/splash_2.ogg", 70, 3)

	proc/eject_occupant(user)
		if (is_incapacitated(user)) return
		if (issilicon(user) || isAI(user))
			boutput("<span class='alert'>You can't quite lift [src.occupant] out of the tub!</span>")
			return
		if (!src.occupant)
			boutput("<span class='alert'>There's no one inside!</span>")
			return
		src.occupant.visible_message("<span class='notice'>[src.occupant] gets out of the bath.</span>", "<span class='notice'>You get out of the bath.</span>")
		src.occupant.pixel_y = 0
		src.occupant.layer = initial(occupant.layer)
		src.occupant.set_loc(get_turf(src))
		src.vis_contents -= src.occupant
		src.occupant = null
		src.UpdateOverlays(null, "fluid_overlay")
		src.UpdateOverlays(null, "bath_edge")
		src.on_reagent_change()
		if (src.reagents.total_volume)
			playsound(src.loc, "sound/misc/splash_1.ogg", 70, 3)

		for (var/obj/O in src)
			O.set_loc(get_turf(src))

	proc/turn_tap(mob/user as mob)
		src.add_fingerprint(user)
		if (on)
			user.visible_message("[user] turns off the bathtub's tap.", "You turn off the bathtub's tap.")
			playsound(src.loc, "sound/effects/valve_creak.ogg", 30, 2)
			on = FALSE
		else
			if(src.reagents.is_full())
				boutput(user, "<span class='alert'>The tub is already full!</alert>")
			else
				user.visible_message("[user] turns on the bathtub's tap.", "You turn on the bathtub's tap.")
				playsound(src.loc, "sound/misc/pourdrink.ogg", 60, 4)
				src.on_reagent_change()
				on = TRUE

	proc/drain_bathtub(mob/user as mob)
		src.add_fingerprint(user)
		if (get_dist(usr, src) <= 1 && !is_incapacitated(usr))
			if (src.reagents.total_volume)
				user.visible_message("<span class='notice'>[user] reaches into the bath and pulls the plug.", "<span class='notice'>You reach into the bath and pull the plug.</span>")
				if (ishuman(usr))
					var/mob/living/carbon/human/H = usr
					if(!H.gloves)
						reagents.reaction(H, TOUCH)
				playsound(src.loc, "sound/misc/drain_glug.ogg", 70, 1)
				src.reagents.clear_reagents()
				src.on_reagent_change()

				var/count = 0
				for (var/obj/O in src)
					count++
					qdel(O)
				if (count > 0)
					user.visible_message("<span class='alert'>...and something flushes down the drain. Damn!", "<span class='alert'>...and flush something down the drain. Damn!</span>")
			else
				boutput(usr, "<span class='notice'>The bathtub's already empty.</span>")

	relaymove(mob/user as mob, dir)
		src.eject_occupant(user)

	process()
		if (src.on)
			src.reagents.add_reagent(src.default_reagent, 100)
			src.on_reagent_change()
			if (src.reagents.is_full())
				src.visible_message("<span class='notice'>As the [src] finishes filling, the tap shuts off automatically.</span>")
				playsound(src.loc, "sound/misc/pourdrink2.ogg", 60, 5)
				src.on = FALSE
		if (src.occupant)
			if(src.occupant.loc != src)
				src.occupant.pixel_y = 0
				src.occupant = null
				src.on_reagent_change()
				return
			if(src.reagents.total_volume)
				src.reagents.reaction(src.occupant, TOUCH)
				src.reagents.trans_to(src.occupant, 5)

	MouseDrop_T(mob/living/carbon/human/target, mob/user)

		if (!istype(target) || target.buckled || LinkBlocked(target.loc,src.loc) || BOUNDS_DIST(user, src) > 1 || BOUNDS_DIST(user, target) > 1 || is_incapacitated(user) || isAI(user))
			return
		if (src.occupant)
			boutput(user, "<span class='alert'>Someone's already in the [src]!</span>")
			return

		if(target == user && !user.stat)
			target.visible_message("[user.name] climbs into the [src].", "You climb into the [src]")
		else if(target != user && !user.restrained())
			target.visible_message("<span class='alert'>[user.name] pushes [target.name] into the [src]!</alert>", "<span class='notice'>You push [target.name] into the [src]!</span>")
		else
			return

		src.add_fingerprint(user)
		src.enter_bathtub(target)

	is_open_container()
		return 1

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
