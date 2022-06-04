/obj/item/chem_pill_bottle
	name = "Pill bottle"
	icon_state = "pill_canister"
	icon = 'icons/obj/chemical.dmi'
	w_class = W_CLASS_SMALL
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 1
	rand_pos = 1
	inventory_counter_enabled = 1
	event_handler_flags = NO_MOUSEDROP_QOL | USE_FLUID_ENTER
	var/pname
	var/pvol
	var/pcount
	var/datum/reagents/reagents_internal
	var/average

	// setup this pill bottle from some reagents
	proc/create_from_reagents(var/datum/reagents/R, var/pillname, var/pillvol, var/pillcount)
		var/volume = pillcount * pillvol

		reagents_internal = new/datum/reagents(volume)
		reagents_internal.my_atom = src

		R.trans_to_direct(reagents_internal,volume)

		src.average = reagents_internal.get_average_color().to_rgb()

		src.name = "[pillname] pill bottle"
		src.desc = "Contains [pillcount] [pillname] pills."
		src.pname = pillname
		src.pvol = pillvol
		src.pcount = pillcount

	// spawn a pill, returns a pill or null if there aren't any left in the bottle
	proc/create_pill()
		var/totalpills = src.pcount + length(src.contents)

		if(totalpills <= 0)
			return null

		var/obj/item/reagent_containers/pill/P = null

		// give back stored pills first
		if (src.contents.len)
			P = src.contents[src.contents.len]

		// otherwise create a new one from the reagent holder
		else if (pcount)
			LAGCHECK(LAG_LOW)
			if (src)
				if (src.reagents_internal.total_volume < src.pvol)
					src.pcount = 0
				else
					P = new /obj/item/reagent_containers/pill
					P.set_loc(src)
					P.name = "[pname] pill"

					src.reagents_internal.trans_to(P,src.pvol)
					if (P?.reagents)
						P.color_overlay = image('icons/obj/items/pills.dmi', "pill0")
						P.color_overlay.color = src.average
						P.color_overlay.alpha = P.color_overlay_alpha
						P.overlays += P.color_overlay
					src.pcount--
		// else return null

		return P

	proc/rebuild_desc()
		var/totalpills = src.pcount + length(src.contents)
		if(totalpills > 15)
			src.desc = "A [src.pname] pill bottle. There are too many to count."
			src.inventory_counter.update_text("**")
		else if (totalpills <= 0)
			src.desc = "A [src.pname] pill bottle. It looks empty."
			src.inventory_counter.update_number(0)
		else
			src.desc = "A [src.pname] pill bottle. There [totalpills==1? "is [totalpills] pill." : "are [totalpills] pills." ]"
			src.inventory_counter.update_number(totalpills)

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/reagent_containers/pill))
			user.u_equip(W)
			W.set_loc(src)
			W.dropped(user)
			boutput(user, "<span class='notice'>You put [W] in [src].</span>")
			rebuild_desc()
		else ..()

	attack_self(var/mob/user as mob)
		var/obj/item/reagent_containers/pill/P = src.create_pill()
		if (istype(P))
			var/i = rand(3,8)
			var/turf/T = user.loc
			while(istype(P) && i > 0 && user.loc == T)
				P.set_loc(T)
				P = src.create_pill()
				i--
			if (src.pcount + src.contents.len > 0)
				boutput(user, "<span class='notice'>You tip out a bunch of pills from [src] into [T].</span>")
			else
				boutput(user, "<span class='notice'>You tip out all the pills from [src] into [T].</span>")
			rebuild_desc()
		else
			boutput(user, "<span class='alert'>It's empty.</span>")
			return

	attack_hand(mob/user)
		if(user.r_hand == src || user.l_hand == src)
			var/obj/item/reagent_containers/pill/P = src.create_pill()
			if(istype(P))
				user.put_in_hand_or_drop(P)
				boutput(user, "You take [P] from [src].")
				rebuild_desc()
			else
				boutput(user, "<span class='alert'>It's empty.</span>")
				return

		else
			return ..()

	MouseDrop_T(atom/movable/O as obj, mob/user as mob)
		if (user.restrained() || user.getStatusDuration("paralysis") || user.sleeping || user.stat || user.lying)
			return
		if (!in_interact_range(user, src) || !in_interact_range(user, O))
			user.show_text("That's too far away!", "red")
			return
		if (!istype(O, /obj/item/reagent_containers/pill))
			user.show_text("\The [src] can't hold anything but pills!", "red")
			return

		user.visible_message("<span class='notice'>[user] begins quickly filling [src]!</span>")
		var/staystill = user.loc
		for (var/obj/item/reagent_containers/pill/P in view(1,user))
			if (P in user)
				continue
			P.set_loc(src)
			P.dropped(user)
			src.rebuild_desc()
			sleep(0.2 SECONDS)
			if (user.loc != staystill)
				break
		boutput(user, "<span class='notice'>You finish filling [src]!</span>")
