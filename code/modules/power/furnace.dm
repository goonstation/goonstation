TYPEINFO(/obj/machinery/power/furnace)
	mats = 20

/obj/machinery/power/furnace
	name = "Zaojun-2 5kW Furnace"
	desc = "The venerable XIANG|GIESEL model '灶君' combustion furnace with integrated 5 kilowatt thermocouple. A simple power solution for low-demand facilities and outposts."
	icon_state = "furnace"
	anchored = 1
	density = 1
	var/active = 0
	var/last_active = 0
	var/fuel = 0
	var/last_fuel_state = 0
	var/maxfuel = 1000
	var/genrate = 5000
	var/stoked = 0 // engine ungrump
	custom_suicide = 1
	event_handler_flags = NO_MOUSEDROP_QOL | USE_FLUID_ENTER
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER

	New(new_loc)
		..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

	process()
		if(status & BROKEN) return
		if(src.active)
			if(src.fuel)
				on_burn()
				fuel--
				if(stoked)
					stoked--
			if(!src.fuel)
				src.visible_message("<span class='alert'>[src] runs out of fuel and shuts down!</span>")
				src.active = 0
		else
			on_inactive()

		UpdateIcon()

	proc/on_burn()
		add_avail(src.genrate)

	proc/on_inactive()
		return

	update_icon()
		if(active != last_active)
			last_active = active
			if(src.active)
				var/image/I = GetOverlayImage("active")
				if(!I) I = image('icons/obj/power.dmi', "furn-burn")
				UpdateOverlays(I, "active")
			else
				UpdateOverlays(null, "active", 0, 1) //Keep it in cache for when it's toggled

		var/fuel_state = round(min((src.fuel / src.maxfuel) * 5, 4))
		//At max fuel, the state will be 4, aka all bars, then it will lower / increase as fuel is added
		if(fuel_state != last_fuel_state) //The fuel state has changed and we need to do an update
			last_fuel_state = fuel_state
			for(var/i in 1 to 4)
				var/okey = "fuel[i]"
				if(fuel_state >= i) //Add the overlay
					var/image/I = GetOverlayImage(okey)
					if(!I) I = image('icons/obj/power.dmi', "furn-c[i]")
					UpdateOverlays(I, okey)
				else //Clear the overlay
					UpdateOverlays(null, okey, 0, 1)


	was_deconstructed_to_frame(mob/user)
		src.active = 0

	attack_hand(var/mob/user)
		if (!src.fuel) boutput(user, "<span class='alert'>There is no fuel in the furnace!</span>")
		else
			src.active = !src.active
			boutput(user, "You switch [src.active ? "on" : "off"] the furnace.")

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/grab))
			if (!src.active)
				boutput(user, "<span class='alert'>It'd probably be easier to dispose of them while the furnace is active...</span>")
				return
			else
				var/obj/item/grab/grab = W
				var/mob/target = grab.affecting
				if (!isdead(grab.affecting))
					boutput(user, "<span class='alert'>[grab.affecting.name] needs to be dead first!</span>")
					return
				if(target?.buckled || target?.anchored)
					user.visible_message("<span class='alert'>[target] is stuck to something and can't be shoved into the furnace!</span>")
					return
				user.visible_message("<span class='alert'>[user] starts to shove [target] into the furnace!</span>")
				logTheThing(LOG_COMBAT, user, "attempted to force [constructTarget(target,"combat")] into a furnace at [log_loc(src)].")
				message_admins("[key_name(user)] is trying to force [key_name(target)] into a furnace at [log_loc(src)].")
				src.add_fingerprint(user)
				sleep(5 SECONDS)
				if(grab?.affecting && src.active && in_interact_range(src, user)) //ZeWaka: Fix for null.affecting
					var/mob/M = grab.affecting
					user.visible_message("<span class='alert'>[user] stuffs [M] into the furnace!</span>")
					logTheThing(LOG_COMBAT, user, "forced [constructTarget(M,"combat")] into a furnace at [log_loc(src)].")
					message_admins("[key_name(user)] forced [key_name(M)] into a furnace at [log_loc(src)].")
					M.death(TRUE)
					if (M.mind)
						M.ghostize()
					src.stoked += round(M.reagents?.get_reagent_amount("THC") / 5)
					qdel(M)
					qdel(W)
					src.fuel += 400
					src.stoked += 50
					if(src.fuel >= src.maxfuel)
						src.fuel = src.maxfuel
						boutput(user, "<span class='notice'>The furnace is now full!</span>")
					return
		else if(load_into_furnace(W, 1, user) == 0)
			..()
			return

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!in_interact_range(src, user)  || BOUNDS_DIST(O, user) > 0 || !can_act(user))
			return
		else
			if (src.fuel >= src.maxfuel)
				boutput(user, "<span class='alert'>The furnace is already full!</span>")
				return

			if (istype(O, /obj/storage/crate/))
				var/obj/storage/crate/crate = O
				if (crate.spawn_contents && crate.make_my_stuff()) //Ensure contents have been spawned properly
					crate.spawn_contents = null

				user.visible_message("<span class='notice'>[user] uses the [src]'s automatic ore loader on [crate]!</span>", "<span class='notice'>You use the [src]'s automatic ore loader on [crate].</span>")
				for (var/obj/item/I in crate.contents)
					load_into_furnace(I, 1, user)
					if (src.fuel >= src.maxfuel)
						src.fuel = src.maxfuel
						boutput(user, "<span class='notice'>The furnace is now full!</span>")
						break
				playsound(src, 'sound/machines/click.ogg', 50, 1)
				boutput(user, "<span class='notice'>You finish loading [crate] into [src]!</span>")
				return

			var/staystill = user.loc

			// else, just stuff
			for(var/obj/W in oview(1,user))
				if (!matches(W, O))
					continue
				load_into_furnace(W, 1, user)
				if (src.fuel >= src.maxfuel)
					src.fuel = src.maxfuel
					boutput(user, "<span class='notice'>The furnace is now full!</span>")
					break
				sleep(0.3 SECONDS)
				if (user.loc != staystill)
					break
			playsound(src, 'sound/machines/click.ogg', 50, 1)
			boutput(user, "<span class='notice'>You finish stuffing [O] into [src]!</span>")

		src.updateUsrDialog()

	proc/matches(atom/movable/inserted, atom/movable/template)
		. = istype(inserted, template.type)

	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] climbs into the furnace!</b></span>")
		user.death(TRUE)
		if (user.mind)
			user.ghostize()
			qdel(user)
		else qdel(user)
		src.fuel += 400
		src.stoked += 50
		if(src.fuel >= src.maxfuel)
			src.fuel = src.maxfuel
		return 1

	proc/handle_stacks(obj/item/F, fuel_value)
		var/amtload = 0
		if (istype(F))
			amtload = min( ceil( (src.maxfuel - src.fuel) / fuel_value ), F.amount )
			src.fuel += fuel_value * amtload
			F.amount -= amtload
			if (F.amount <= 0)
				qdel(F)
			else
				if(amtload && F.inventory_counter)
					F.inventory_counter.update_number(F.amount)
					F.update_stack_appearance()
		return amtload

	// this is run after it's checked a person isn't being loaded in with a grab
	// return value 0 means it can't be put it, 1 is loaded in
	// original is 1 only if it's the item a person directly puts in, so that putting in a
	// fried item doesn't say each item in it was put in
	proc/load_into_furnace(obj/item/W as obj, var/original, mob/user as mob)
		var/stacked = FALSE
		var/started_full = fuel == maxfuel
		var/fuel_name = initial(W.name)
		if (W.material)
			if (W.material.getProperty("flammable") <= 1)
				return 0
			else
				var/fuel_amount = (10 * (2 ** (W.material.getProperty("flammable") - 2)))
				if (W.amount == 1)
					fuel += fuel_amount
				else
					stacked = TRUE
					handle_stacks(W, fuel_amount)
		else if (istype(W, /obj/item/spacecash/))
			if (W.amount == 1)
				fuel_name = "a credit"
				fuel += 0.1
			else
				fuel_name = "credits"
				stacked = TRUE
				handle_stacks(W, 0.1)
		else if (istype(W, /obj/item/paper/)) fuel += 6
		else if (istype(W, /obj/item/clothing/gloves/)) fuel += 10
		else if (istype(W, /obj/item/clothing/head/)) fuel += 20
		else if (istype(W, /obj/item/clothing/mask/)) fuel += 10
		else if (istype(W, /obj/item/clothing/shoes/)) fuel += 10
		else if (istype(W, /obj/item/clothing/head/)) fuel += 20
		else if (istype(W, /obj/item/clothing/suit/)) fuel += 40
		else if (istype(W, /obj/item/clothing/under/)) fuel += 30
		else if (istype(W, /obj/item/plank)) fuel += 100
		else if (istype(W, /obj/item/reagent_containers/food/snacks/yuckburn)) fuel += 120
		else if (istype(W, /obj/critter))
			var/obj/critter/C = W
			if (C.alive)
				boutput(user, "<span class='alert'>This would work a lot better if you killed it first!</span>")
				return
			user.visible_message("<span class='notice'>[user] [pick("crams", "shoves", "pushes", "forces")] [W] into [src]!</span>")
			src.fuel += initial(C.health) * 8
			src.stoked += max(C.quality / 2, 0)
			src.stoked += round(C.reagents?.get_reagent_amount("THC") / 5)
		else if (istype(W, /obj/item/reagent_containers/food/snacks/shell))
			var/obj/item/reagent_containers/food/snacks/shell/F = W
			fuel += F.charcoaliness
			for(var/atom/movable/fried_content in W)
				if(ismob(fried_content))
					var/mob/M = fried_content
					M.death(TRUE)
					if (M.mind)
						M.ghostize()
					fuel += 400
					stoked += 50
					stoked += round(M.reagents?.get_reagent_amount("THC") / 5)
					qdel(M)
				else if(isitem(fried_content))
					var/obj/item/O = fried_content
					load_into_furnace(O, 0)
		else if (istype(W, /obj/item/plant/herb/cannabis))
			fuel += 30
			stoked += 5
		else
			return 0

		if(started_full )
			boutput(user, "<span class='alert'>The furnace is already full!</span>")
			return 1

		if(original == 1)
			if(!stacked)
				fuel_name = W.name
				user.u_equip(W)
				if(!iscritter(W))
					W.dropped(user)
			boutput(user, "<span class='notice'>You load [fuel_name] into [src]!</span>")

			if(src.fuel > src.maxfuel)
				src.fuel = src.maxfuel
				boutput(user, "<span class='notice'>The furnace is now full!</span>")

		if(!stacked)
			qdel(W)

		return 1
