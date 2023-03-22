//file for da fishin gear

// rod flags are WIP, nonfunctional yet
#define ROD_WATER (1<<0) //can it fish in water?

/obj/item/fishing_rod
	name = "fishing rod"
	icon = 'icons/obj/items/fishing_gear.dmi'
	icon_state = "fishing_rod-inactive"
	inhand_image_icon = 'icons/mob/inhand/hand_fishing.dmi'
	item_state = "fishing_rod-inactive"
	/// average time to fish up something, in seconds - will vary on the upper and lower bounds by a maximum of 4 seconds, with a minimum time of 0.5 seconds.
	var/fishing_speed = 8 SECONDS
	/// how long to wait between casts in seconds - mainly so sounds dont overlap
	var/fishing_delay = 2 SECONDS
	/// set to TIME when fished, value is checked when deciding if the rod is currently on cooldown
	var/last_fished = 0
	/// true if the rod is currently "fishing", false if it isnt
	var/is_fishing = FALSE

	//todo: attack particle?? some sort of indicator of where we're fishing
	afterattack(atom/target, mob/user)
		if (target && user && (src.last_fished < TIME + src.fishing_delay))
			var/datum/fishing_spot/fishing_spot = global.fishing_spots[target.type]
			if (fishing_spot)
				actions.start(new /datum/action/fishing(user, src, fishing_spot, target), user)

	update_icon()
		//state for fishing
		if (src.is_fishing)
			src.icon_state = "fishing_rod-active"
			src.item_state = "fishing_rod-active"
		//state for not fishing
		else
			src.icon_state = "fishing_rod-inactive"
			src.item_state = "fishing_rod-inactive"

/// (invisible) action for timing out fishing. this is also what lets the fishing spot know that we fished
/datum/action/fishing
	var/mob/user = null
	/// the target of the action
	var/atom/target = null
	/// what fishing rod triggered this action
	var/obj/item/fishing_rod/rod = null
	/// the fishing spot that the rod is fishing from
	var/datum/fishing_spot/fishing_spot = null
	/// how long the fishing action loop will take in seconds, set on onStart(), varies by 4 seconds in either direction.
	duration = 0
	/// id for fishing action
	id = "fishing_for_fishies"

	New(var/user, var/rod, var/fishing_spot, var/target)
		..()
		src.user = user
		src.rod = rod
		src.fishing_spot = fishing_spot
		src.target = target

	onStart()
		..()
		if (!(BOUNDS_DIST(src.user, src.rod) == 0) || !(BOUNDS_DIST(src.user, src.target) == 0) || !src.user || !src.target || !src.rod || !src.fishing_spot)
			interrupt(INTERRUPT_ALWAYS)
			return

		src.duration = max(0.5 SECONDS, rod.fishing_speed + (pick(1, -1) * (rand(0,40) / 10) SECONDS)) //translates to rod duration +- (0,4) seconds, minimum of 0.5 seconds
		playsound(src.user, 'sound/items/fishing_rod_cast.ogg', 50, 1)
		src.user.visible_message("[src.user] starts fishing.")
		src.rod.is_fishing = TRUE
		src.rod.UpdateIcon()
		src.user.update_inhands()

	onUpdate()
		..()
		if (!(BOUNDS_DIST(src.user, src.rod) == 0) || !(BOUNDS_DIST(src.user, src.target) == 0) || !src.user || !src.target || !src.rod || !src.fishing_spot)
			interrupt(INTERRUPT_ALWAYS)
			src.rod.is_fishing = FALSE
			src.rod.UpdateIcon()
			src.user.update_inhands()
			return

	onEnd()
		if (!(BOUNDS_DIST(src.user, src.rod) == 0) || !(BOUNDS_DIST(src.user, src.target) == 0) || !src.user || !src.target || !src.rod || !src.fishing_spot)
			..()
			interrupt(INTERRUPT_ALWAYS)
			src.rod.is_fishing = FALSE
			src.rod.UpdateIcon()
			src.user.update_inhands()
			return

		if (src.fishing_spot.try_fish(src.user, src.rod, target)) //if it returns one we successfully fished, otherwise lets restart the loop
			..()
			src.rod.is_fishing = FALSE
			src.rod.UpdateIcon()
			src.user.update_inhands()
			return

		else //lets restart the action
			src.onRestart()

// portable fishing portal currently found in a prefab in space
TYPEINFO(/obj/item/fish_portal)
	mats = 11

/obj/item/fish_portal
	name = "Fishing Portal Generator"
	desc = "A small device that creates a portal you can fish in."
	icon = 'icons/obj/items/fishing_gear.dmi'
	icon_state = "fish_portal"

	attack_self(mob/user as mob)
		new /obj/machinery/active_fish_portal(get_turf(user))
		playsound(src.loc, 'sound/items/miningtool_on.ogg', 40)
		user.visible_message("[user] flips on the [src].", "You turn on the [src].")
		user.u_equip(src)
		qdel(src)

/obj/machinery/active_fish_portal
	name = "Fishing Portal"
	desc = "A portal you can fish in. It's not big enough to go through."
	anchored = 1
	icon = 'icons/obj/items/fishing_gear.dmi'
	icon_state = "fish_portal-active"

	attack_hand(mob/user)
		new /obj/item/fish_portal(get_turf(src))
		playsound(src.loc, 'sound/items/miningtool_off.ogg', 40)
		user.visible_message("[user] flips off the [src].", "You turn off the [src].")
		qdel(src)

/obj/fishing_pool
	name = "Aquatic Research Pool"
	desc = "A small bulky pool that you can fish in. It has a low probability of containing various low-rarity fish."
	anchored = 1
	icon = 'icons/obj/hydroponics/machines_hydroponics.dmi'
	icon_state = "tray"

// Gannets new fishing gear

/obj/submachine/fishing_upload_terminal
	name = "Aquatic Research Upload Terminal"
	desc = "Insert fish to recieve points to spend in the fishing vendor."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "processor-off"
	anchored = 1
	density = 1
	layer = OBJ_LAYER - 0.1
	var/working = 0
	var/allowed = list(/obj/item/fish)

	attack_hand(var/mob/user)
		if (src.contents.len < 1)
			boutput(user, "<span class='alert'>There is nothing in the terminal!</span>")
			return
		if (src.working == 1)
			boutput(user, "<span class='alert'>The terminal is busy!</span>")
			return
		src.icon_state = "processor-on"
		src.working = 1
		src.visible_message("The [src] begins processing its contents.")
		sleep(rand(30,70))
		// Dispense processed stuff
		for(var/obj/item/P in src.contents)
			new/obj/item/requisition_token/fishing(src.loc)
			qdel( P )

		// Wind down
		for(var/obj/item/S in src.contents)
			S.set_loc(get_turf(src))
		src.working = 0
		src.icon_state = "processor-off"
		playsound(src.loc, 'sound/machines/ding.ogg', 100, 1)
		return

	attack_ai(var/mob/user as mob)
		return attack_hand(user)

	attackby(obj/item/W, mob/user)
		var/proceed = 0
		for(var/check_path in src.allowed)
			if(istype(W, check_path))
				proceed = 1
				break
		if (!proceed)
			boutput(user, "<span class='alert'>You can't put that in the terminal!</span>")
			return
		user.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>")
		user.u_equip(W)
		W.set_loc(src)
		W.dropped(user)
		return
/*
		mouse_drop(over_object, src_location, over_location)
			..()
			if (BOUNDS_DIST(src, usr) > 0 || !isliving(usr) || iswraith(usr) || isintangible(usr))
				return
			if (is_incapacitated(usr) || usr.restrained())
				return
			if (over_object == usr && (in_interact_range(src, usr) || usr.contents.Find(src)))
				for(var/obj/item/P in src.contents)
					P.set_loc(get_turf(src))
				for(var/mob/O in AIviewers(usr, null))
					O.show_message("<span class='notice'>[usr] empties the [src].</span>")
				return

		MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
			if (BOUNDS_DIST(src, user) > 0 || !isliving(user) || iswraith(user) || isintangible(user) || !isalive(user) || isintangible(user))
				return
			if (is_incapacitated(user) || user.restrained())
				return

			if (istype(O, /obj/storage))
				if (O:locked)
					boutput(user, "<span class='alert'>You need to unlock it first!</span>")
					return
				user.visible_message("<span class='notice'>[user] loads [O]'s contents into [src]!</span>")
				var/amtload = 0
				for (var/obj/item/reagent_containers/food/M in O.contents)
					M.set_loc(src)
					amtload++
				for (var/obj/item/plant/P in O.contents)
					P.set_loc(src)
					amtload++
				if (amtload) boutput(user, "<span class='notice'>[amtload] items of food loaded from [O]!</span>")
				else boutput(user, "<span class='alert'>No food loaded!</span>")
			else if (istype(O, /obj/item/reagent_containers/food/) || istype(O, /obj/item/plant/))
				user.visible_message("<span class='notice'>[user] begins quickly stuffing food into [src]!</span>")
				var/staystill = user.loc
				for(var/obj/item/reagent_containers/food/M in view(1,user))
					M.set_loc(src)
					sleep(0.3 SECONDS)
					if (user.loc != staystill) break
				for(var/obj/item/plant/P in view(1,user))
					P.set_loc(src)
					sleep(0.3 SECONDS)
					if (user.loc != staystill) break
				boutput(user, "<span class='notice'>You finish stuffing food into [src]!</span>")
			else ..()
			src.updateUsrDialog()
*/
