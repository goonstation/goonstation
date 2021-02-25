/obj/machinery/power/furnace
	name = "Furnace"
	desc = "An inefficient method of powering the station. Generates 5000 units of power while active."
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
	mats = 20
	event_handler_flags = NO_MOUSEDROP_QOL | USE_FLUID_ENTER
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER

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

		//src.overlays = null
		//if (src.active) src.overlays += image('icons/obj/power.dmi', "furn-burn")
		//if (fuelperc >= 20) src.overlays += image('icons/obj/power.dmi', "furn-c1")
		//if (fuelperc >= 40) src.overlays += image('icons/obj/power.dmi', "furn-c2")
		//if (fuelperc >= 60) src.overlays += image('icons/obj/power.dmi', "furn-c3")
		//if (fuelperc >= 80) src.overlays += image('icons/obj/power.dmi', "furn-c4")
		update_icon()

	proc/on_burn()
		add_avail(src.genrate)

	proc/on_inactive()
		return

	proc/update_icon()
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
			for(var/i = 1; i <= 4; i++)
				var/okey = "fuel[i]"
				if(fuel_state >= i) //Add the overlay
					var/image/I = GetOverlayImage(okey)
					if(!I) I = image('icons/obj/power.dmi', "furn-c[i]")
					UpdateOverlays(I, okey)
				else //Clear the overlay
					UpdateOverlays(null, okey, 0, 1)


	attack_hand(var/mob/user as mob)
		if (!src.fuel) boutput(user, "<span class='alert'>There is no fuel in the furnace!</span>")
		else
			src.active = !src.active
			boutput(user, "You switch [src.active ? "on" : "off"] the furnace.")

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/grab))
			if (!src.active)
				boutput(user, "<span class='alert'>It'd probably be easier to dispose of them while the furnace is active...</span>")
				return
			else
				user.visible_message("<span class='alert'>[user] starts to shove [W:affecting] into the furnace!</span>")
				logTheThing("combat", user, W:affecting, "attempted to force [constructTarget(W:affecting,"combat")] into a furnace at [log_loc(src)].")
				message_admins("[key_name(user)] is trying to force [key_name(W:affecting)] into a furnace at [log_loc(src)].")
				src.add_fingerprint(user)
				sleep(5 SECONDS)
				if(W && W:affecting && src.active) //ZeWaka: Fix for null.affecting
					user.visible_message("<span class='alert'>[user] stuffs [W:affecting] into the furnace!</span>")
					var/mob/M = W:affecting
					logTheThing("combat", user, M, "forced [constructTarget(M,"combat")] into a furnace at [log_loc(src)].")
					message_admins("[key_name(user)] forced [key_name(M)] into a furnace at [log_loc(src)].")
					M.death(1)
					if (M.mind)
						M.ghostize()
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
		if (get_dist(src,user) > 1)
			boutput(user, "<span class='alert'>You are too far away to do that.</span>")
			return

		if (get_dist(src,O) > 1)
			boutput(user, "<span class='alert'>[O] is too far away to do that.</span>")
			return

		if (istype(O, /obj/storage/crate/))
			var/obj/storage/crate/C = O
			if (C.spawn_contents && C.make_my_stuff()) //Ensure contents have been spawned properly
				C.spawn_contents = null
			if (src.fuel >= src.maxfuel)
				boutput(user, "<span class='alert'>The furnace is already full!</span>")
				return
			user.visible_message("<span class='notice'>[user] uses the [src]'s automatic ore loader on [O]!</span>", "<span class='notice'>You use the [src]'s automatic ore loader on [O].</span>")
			var/amtload = 0
			for (var/obj/item/raw_material/M in O.contents)
				if (istype(M,/obj/item/raw_material/char))
					amtload += load_fuel_and_pool(M, 60)
				else if (istype(M,/obj/item/raw_material/plasmastone))
					amtload += load_fuel_and_pool(M, 800)
				if (src.fuel >= src.maxfuel)
					src.fuel = src.maxfuel
					boutput(user, "<span class='notice'>The furnace is now full!</span>")
					break
			if (amtload) boutput(user, "<span class='notice'>[amtload] pieces of ore loaded from [O]!</span>")
			else boutput(user, "<span class='alert'>No ore loaded!</span>")

		else if (istype(O, /obj/item/raw_material/char))
			if (src.fuel >= src.maxfuel)
				boutput(user, "<span class='alert'>The furnace is already full!</span>")
				return
			user.visible_message("<span class='notice'>[user] begins quickly stuffing ore into [src]!</span>")
			var/staystill = user.loc
			for(var/obj/item/raw_material/char/M in view(1,user))
				load_fuel_and_pool(M, 60)
				if (src.fuel >= src.maxfuel)
					src.fuel = src.maxfuel
					boutput(user, "<span class='notice'>The furnace is now full!</span>")
					break
				sleep(0.3 SECONDS)
				if (user.loc != staystill) break
			boutput(user, "<span class='notice'>You finish stuffing ore into [src]!</span>")

		else if (istype(O, /obj/item/plant/herb/cannabis))
			if (src.fuel >= src.maxfuel)
				boutput(user, "<span class='alert'>The furnace is already full!</span>")
				return
			user.visible_message("<span class='notice'>[user] begins quickly stuffing weed into [src]!</span>") // four fuckin twenty all day
			var/staystill = user.loc
			for(var/obj/item/plant/herb/cannabis/M in view(1,user))
				load_fuel_and_pool(M, 30, 10)
				if (src.fuel >= src.maxfuel)
					src.fuel = src.maxfuel
					boutput(user, "<span class='notice'>The furnace is now full!</span>")
					break
				sleep(0.3 SECONDS)
				if (user.loc != staystill) break
			boutput(user, "<span class='notice'>You finish stuffing weed into [src]!</span>")

		else if (istype(O, /obj/item/raw_material/plasmastone))
			if (src.fuel >= src.maxfuel)
				boutput(user, "<span class='alert'>The furnace is already full!</span>")
				return
			user.visible_message("<span class='notice'>[user] begins quickly stuffing ore into [src]!</span>")
			var/staystill = user.loc
			for(var/obj/item/raw_material/plasmastone/M in view(1,user))
				load_fuel_and_pool(M, 800)
				if (src.fuel >= src.maxfuel)
					src.fuel = src.maxfuel
					boutput(user, "<span class='notice'>The furnace is now full!</span>")
					break
				sleep(0.3 SECONDS)
				if (user.loc != staystill) break
			boutput(user, "<span class='notice'>You finish stuffing ore into [src]!</span>")

		else if (istype(O, /obj/critter))
			if (src.fuel >= src.maxfuel)
				boutput(user, "<span class='alert'>The furnace is already full!</span>")
				return
			var/obj/critter/C = O
			if (C.alive)
				boutput(user, "<span class='alert'>This would work a lot better if you killed it first!</span>")
				return
			user.visible_message("<span class='notice'>[user] [pick("crams", "shoves", "pushes", "forces")] [O] into [src]!</span>")
			src.fuel += initial(C.health) * 8
			src.stoked += max(C.quality / 2, 0)
			qdel(O)
		else ..()
		src.updateUsrDialog()

	// Loads items into furnace with provided fuel and stoked values
	// Returns number of items loaded
	proc/load_fuel_and_pool(obj/item/F, fuel_value, stoked_value=0)
		var/amtload = 0
		if (istype(F))
			amtload = min( ceil( (src.maxfuel - src.fuel) / fuel_value ), F.amount )
			src.fuel += fuel_value * amtload
			src.stoked += stoked_value * amtload
			F.amount -= amtload
			if (F.amount <= 0)
				pool(F)
			else
				if(amtload && F.inventory_counter)
					F.inventory_counter.update_number(F.amount)
					F.update_stack_appearance()
		return amtload

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] climbs into the furnace!</b></span>")
		user.death(1)
		if (user.mind)
			user.ghostize()
			qdel(user)
		else qdel(user)
		src.fuel += 400
		src.stoked += 50
		if(src.fuel >= src.maxfuel)
			src.fuel = src.maxfuel
		return 1

	// this is run after it's checked a person isn't being loaded in with a grab
	// return value 0 means it can't be put it, 1 is loaded in
	// original is 1 only if it's the item a person directly puts in, so that putting in a
	// fried item doesn't say each item in it was put in
	proc/load_into_furnace(obj/item/W as obj, var/original, mob/user as mob)
		var/pooled_type = FALSE
		var/started_full = fuel == maxfuel
		var/fuel_name = initial(W.name)
		if (istype(W, /obj/item/raw_material/char))
			load_fuel_and_pool(W, 60)
			pooled_type = TRUE
		else if (istype(W, /obj/item/raw_material/plasmastone))
			load_fuel_and_pool(W, 800)
			pooled_type = TRUE
		else if (istype(W, /obj/item/paper/))
			load_fuel_and_pool(W, 6)
			pooled_type = TRUE
		else if (istype(W, /obj/item/spacecash/))
			if( load_fuel_and_pool(W, 2) > 1)
				fuel_name = "credits"
			else
				fuel_name = "a credit"
			pooled_type = TRUE
		else if (istype(W, /obj/item/clothing/gloves/)) fuel += 10
		else if (istype(W, /obj/item/clothing/head/)) fuel += 20
		else if (istype(W, /obj/item/clothing/mask/)) fuel += 10
		else if (istype(W, /obj/item/clothing/shoes/)) fuel += 10
		else if (istype(W, /obj/item/clothing/head/)) fuel += 20
		else if (istype(W, /obj/item/clothing/suit/)) fuel += 40
		else if (istype(W, /obj/item/clothing/under/)) fuel += 30
		else if (istype(W, /obj/item/plank)) fuel += 100
		else if (istype(W, /obj/item/reagent_containers/food/snacks/yuckburn)) fuel += 120
		else if (istype(W, /obj/item/reagent_containers/food/snacks/shell))
			var/obj/item/reagent_containers/food/snacks/shell/F = W
			fuel += F.charcoaliness
			for(var/atom/movable/fried_content in W)
				if(ismob(fried_content))
					var/mob/M = fried_content
					M.death(1)
					if (M.mind)
						M.ghostize()
					qdel(M)
					fuel += 400
					stoked += 50
				else if(isitem(fried_content))
					var/obj/item/O = fried_content
					load_into_furnace(O, 0)
		else if (istype(W, /obj/item/plant/herb/cannabis))
			load_fuel_and_pool(W, 30, 10)
			pooled_type = TRUE
		else
			return 0

		if( started_full )
			boutput(user, "<span class='alert'>The furnace is already full!</span>")
			return 1

		if (original == 1)
			if(!pooled_type)
				fuel_name = W.name
				user.u_equip(W)
				W.dropped()
			boutput(user, "<span class='notice'>You load [fuel_name] into [src]!</span>")

			if(src.fuel > src.maxfuel)
				src.fuel = src.maxfuel
				boutput(user, "<span class='notice'>The furnace is now full!</span>")

		if (!pooled_type)
			qdel(W)

		return 1
