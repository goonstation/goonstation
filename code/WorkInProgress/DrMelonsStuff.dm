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
			src.visible_message(SPAN_ALERT("The <B>[src]</B> makes an odd sound, and releases a puff of green steam."))

		if(on == 1)
			if(length(reagents.reagent_list) < 1 || reagents.total_volume < 1)
				on = 0
				icon_state = "fogmachine0"

				src.visible_message(SPAN_ALERT("The <B>[src]</B> splutters to a halt."))
				playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
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



	attackby(var/obj/item/reagent_containers/C, var/mob/user)
		if(!istype(C, /obj/item/reagent_containers))
			return
		if(istype(C, /obj/item/reagent_containers/glass))
			if(length(C.reagents.reagent_list) < 1)
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
				playsound(src, 'sound/effects/bubbles.ogg', 50, TRUE)
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
			playsound(src, 'sound/effects/pop.ogg', 50, TRUE)
			return


	attack_hand(mob/user)
		if(on == 0)
			on = 1
			boutput(user, SPAN_NOTICE("You flip the switch on the FogMachine-3000 to the On position."))
			playsound(src, 'sound/machines/click.ogg', 50, TRUE)
			return
		if(on == 1)
			on = 0
			playsound(src, 'sound/machines/click.ogg', 50, TRUE)
			boutput(user, SPAN_NOTICE("You flip the switch on the FogMachine-3000 to the Off position."))
			return

/obj/machinery/bathtub
	name = "bathtub"
	desc = "Now, that looks cosy!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "bathtub"
	flags = OPENCONTAINER | ACCEPTS_MOUSEDROP_REAGENTS
	var/mob/living/carbon/human/occupant = null
	var/default_reagent = "water"
	var/on = FALSE
	var/suffocation_volume = 100 // drowning while laying down depth from breath.dm

	New()
		..()
		src.create_reagents(500)
		if (prob(1))
			default_reagent = "sodawater"
			desc += " But, it's faintly fizzing?"

	disposing()
		src.occupant?.set_loc(get_turf(src))
		for (var/obj/O in src)
			O.set_loc(get_turf(src))
		src.occupant = null
		..()

	mob_flip_inside(var/mob/user)
		if (src.reagents.total_volume)
			user.visible_message(SPAN_NOTICE("[src.occupant] splish-splashes around."), SPAN_ALERT("You splash around enough to shake the tub!"), SPAN_NOTICE("You hear liquid splash on the ground."))
			playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
			animate_wiggle_then_reset(src, 1, 3)
			src.reagents.trans_to(src.last_turf, 5)
		else
			..()

	handle_internal_lifeform(mob/lifeform_inside_me, breath_request, mult)
		var/mob/M = lifeform_inside_me
		if (breath_request > 0 && M.lying && src.reagents.total_volume > suffocation_volume) // drowning
			// mimics `force_mob_to_ingest` in fluid_core.dm
			// we can skip some checks due to obj handling in breath.dm
			if (M.get_oxygen_deprivation() > 40)
				var/react_volume = src.reagents.total_volume > 10 ? (src.reagents.total_volume / 2) : (src.reagents.total_volume)
				react_volume = min(react_volume, 20) * mult
				if (M.reagents)
					react_volume = min(react_volume, abs(M.reagents.maximum_volume - M.reagents.total_volume)) //don't push out other reagents if we are full
				src.reagents.reaction(M, INGEST, react_volume, 1, src.reagents.reagent_list.len)
				src.reagents.trans_to(M, react_volume)
			return new/datum/gas_mixture
		else
			. = ..()

	Click(location, control, params)
		if(!src.ghost_observe_occupant(usr, src.occupant))
			. = ..()

	mouse_drop(obj/over_object, src_location, over_location)
		if (isintangible(usr))
			return
		if (usr.stat || usr.getStatusDuration("knockdown") || BOUNDS_DIST(usr, src) > 0 || BOUNDS_DIST(usr, over_object) > 0)
			boutput(usr, SPAN_ALERT("That's too far!"))
			return
		if (src.occupant)
			eject_occupant(usr, over_object)
			return
		else if (istype(over_object, /turf))
			drain_bathtub(usr)
			return
		if (!(over_object.flags & ACCEPTS_MOUSEDROP_REAGENTS))
			return ..()
		src.transfer_all_reagents(over_object, usr)

	get_desc(dist, mob/user)
		if (dist > 2)
			return
		if (!reagents)
			return
		. += "<br>[SPAN_NOTICE("[reagents.get_description(user,RC_FULLNESS|RC_VISIBLE|RC_SPECTRO)]")]"
		return

	// using overlay levels so it looks like you're in the bath
	// we don't use show_submerged_image since we want the head to poke out
	// MOB_LAYER(-0) = Other mobs render on top
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
		else
			src.UpdateOverlays(null, "fluid_underlay")
			src.UpdateOverlays(null, "fluid_overlay")
		..()

	attack_hand(mob/user)
		src.turn_tap(user)

	proc/enter_bathtub(mob/living/carbon/human/target)
		src.occupant = target
		src.occupant.set_loc(src)
		if (src.reagents?.total_volume)
			playsound(src.loc, 'sound/misc/splash_2.ogg', 70, 3)
			src.blood_bath(src.occupant)
		src.UpdateOverlays(src.SafeGetOverlayImage("bath_edge", 'icons/obj/stationobjs.dmi', "bath_edge", MOB_LAYER - 0.1), "bath_edge")
		src.on_reagent_change()
		src.occupant.layer = MOB_LAYER - 0.3
		src.vis_contents += src.occupant

	proc/eject_occupant(mob/user)
		if (isintangible(user))
			return
		if (is_incapacitated(user))
			return
		if (issilicon(user) || isAI(user))
			boutput(user, SPAN_ALERT("You can't quite lift [src.occupant] out of the tub!"))
			return
		if (!src.occupant)
			boutput(user, SPAN_ALERT("There's no one inside!"))
			return
		src.occupant.set_loc(get_turf(src))

	proc/blood_bath(var/mob/living/carbon/human/H)
		// hacky, but cool effect
		// Stop spamming expensive calls
		if (src.reagents.has_reagent("blood", suffocation_volume))
			var/dna = null
			var/datum/reagent/blood/sample = reagents.get_reagent("blood")
			if (sample && istype(sample.data, /datum/bioHolder))
				var/datum/bioHolder/tocopy = sample.data
				dna = tocopy.owner
			if (!dna)
				dna = H
			H.add_blood(dna)
			if (H.gloves)
				H.gloves.add_blood(dna)
				H.update_bloody_gloves()
			else
				H.update_bloody_hands()
			if (H.wear_suit)
				H.wear_suit.add_blood(dna)
				H.update_bloody_suit()
			else if (H.w_uniform)
				H.w_uniform.add_blood(dna)
				H.update_bloody_uniform()
			if (H.shoes)
				H.shoes.add_blood(dna)
				H.update_bloody_shoes()

	proc/turn_tap(mob/user)
		src.add_fingerprint(user)
		if (on)
			user.visible_message(SPAN_NOTICE("[user] turns off the bathtub's tap."), SPAN_NOTICE("You turn off the bathtub's tap."))
			playsound(src.loc, 'sound/effects/valve_creak.ogg', 30, 2)
			on = FALSE
		else
			if(src.reagents.is_full())
				boutput(user, SPAN_NOTICE("The tub is already full!</alert>"))
			else
				user.visible_message(SPAN_NOTICE("[user] turns on the bathtub's tap."), SPAN_NOTICE("You turn on the bathtub's tap."))
				playsound(src.loc, 'sound/misc/pourdrink.ogg', 60, 4)
				src.on_reagent_change()
				on = TRUE

	proc/drain_bathtub(mob/user)
		src.add_fingerprint(user)
		if (GET_DIST(user, src) <= 1 && !is_incapacitated(user))
			if (src.reagents.total_volume)
				user.visible_message(SPAN_NOTICE("[user] reaches into the bath and pulls the plug."), SPAN_NOTICE("You reach into the bath and pull the plug."))
				if (ishuman(user))
					var/mob/living/carbon/human/H = user
					if(!H.gloves)
						reagents.reaction(H, TOUCH, 5)
				playsound(src.loc, 'sound/misc/drain_glug.ogg', 70, 1)
				src.reagents.clear_reagents()
				src.on_reagent_change()

				var/count = 0
				for (var/obj/O in src)
					count++
					qdel(O)
				if (count > 0)
					user.visible_message(SPAN_ALERT("...and something flushes down the drain. Damn!"), SPAN_ALERT("...and flushes something down the drain. Damn!"))
			else
				boutput(user, SPAN_NOTICE("The bathtub's already empty."))

	relaymove(mob/user)
		user.set_loc(src.loc)

	process()
		if (src.on)
			src.reagents.add_reagent(src.default_reagent, 100)
			src.on_reagent_change()
			if (src.reagents.is_full())
				src.visible_message(SPAN_NOTICE("As the [src] finishes filling, the tap shuts off automatically."))
				playsound(src.loc, 'sound/misc/pourdrink2.ogg', 60, 5)
				src.on = FALSE
		if (src.occupant)
			if(src.occupant.loc != src)
				src.occupant.pixel_y = 0
				src.occupant = null
				src.on_reagent_change()
				return
			if(src.reagents.total_volume)
				// copied from fluid_core.dm
				var/react_volume = src.reagents.total_volume > 10 ? (src.reagents.total_volume / 2) : (src.reagents.total_volume)
				react_volume = min(react_volume, 100) //capping the react amt
				var/list/reacted_ids = src.reagents.reaction(src.occupant, TOUCH, react_volume)
				var/volume_fraction = src.reagents.total_volume ? (react_volume / src.reagents.total_volume) : 0

				for(var/current_id in reacted_ids)
					var/datum/reagent/current_reagent = src.reagents.reagent_list[current_id]
					if (!current_reagent)
						continue
					src.reagents.remove_reagent(current_id, current_reagent.volume * volume_fraction)

	Exited(atom/movable/Obj, loc)
		..()
		if (Obj == src.occupant)
			var/mob/M = Obj
			src.visible_message(SPAN_NOTICE("[M] gets out of the bath."), SPAN_NOTICE("You get out of the bath."))
			if (src.reagents?.total_volume)
				playsound(src.loc, 'sound/misc/splash_1.ogg', 70, 3)
				src.blood_bath(M)
			M.set_loc(loc)
			M.layer = initial(M.layer)
			src.vis_contents -= M
			src.occupant = null
			src.UpdateOverlays(null, "fluid_overlay")
			src.UpdateOverlays(null, "bath_edge")
			src.on_reagent_change()
			for (var/obj/O in src)
				O.set_loc(get_turf(src))

	MouseDrop_T(mob/living/carbon/human/target, mob/user)
		if (!istype(target) || target.buckled || LinkBlocked(target.loc,src.loc) || BOUNDS_DIST(user, src) > 1 || BOUNDS_DIST(user, target) > 1 || is_incapacitated(user) || isAI(user))
			return
		if (src.occupant)
			boutput(user, SPAN_ALERT("Someone's already in the [src]!"))
			return

		if(target == user && !user.stat)
			target.visible_message("[user.name] climbs into the [src].", "You climb into the [src]")
		else if(target != user && !user.restrained())
			target.visible_message(SPAN_ALERT("[user.name] pushes [target.name] into the [src]!"), SPAN_NOTICE("[user.name] pushes you into the [src]!"))
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
				src.visible_message(SPAN_ALERT("[src] begins to twitch and move!"))
				var/moveto = locate(M.x + rand(-1,1),M.y + rand(-1, 1),src.z)
				//make the mops move
				if (istype(moveto, /turf/simulated/floor) || istype(moveto, /turf/simulated/floor/shuttle) || istype(moveto, /turf/simulated/aprilfools/floor) || istype(moveto, /turf/unsimulated/floor) || istype(moveto, /turf/unsimulated/aprilfools)) step_towards(M, moveto)
				SPAWN(5 SECONDS)
					src.visible_message(SPAN_NOTICE("Thankfully, [src] settles down."))
		else
			for (var/obj/item/mop/M in orange(5,src))
				src.visible_message(SPAN_ALERT("[src] begins to twitch and mov- oh. No. No it doesn't."))

/obj/item/clothing/head/apprentice/equipped(var/mob/user, var/slot)
	boutput(user, SPAN_NOTICE("Your head tingles with magic! Or asbestos. Probably asbestos."))
	src.fantasia()
	..()
