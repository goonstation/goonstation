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

// upgraded rods are unimplemented.
/obj/item/fishing_rod/upgraded
	name = "fishing rod"
	icon = 'icons/obj/items/fishing_gear.dmi'
	icon_state = "fishing_rod-inactive"
	inhand_image_icon = 'icons/mob/inhand/hand_fishing.dmi'
	item_state = "fishing_rod-inactive"

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
			boutput(user, "<span class='alert'>There is nothing in the upload terminal!</span>")
			return
		if (src.working == 1)
			boutput(user, "<span class='alert'>The terminal is busy!</span>")
			return
		src.icon_state = "processor-on"
		src.working = 1
		src.visible_message("The [src] begins uploading research data.")
		sleep(rand(30,70))
		// Dispense processed stuff
		for(var/obj/item/fish/P in src.contents)
			switch( P.value )
				if (FISH_RARITY_COMMON)
					new/obj/item/requisition_token/fishing/common(src.loc)
					qdel( P )
				if (FISH_RARITY_UNCOMMON)
					new/obj/item/requisition_token/fishing/uncommon(src.loc)
					qdel( P )
				if (FISH_RARITY_RARE)
					new/obj/item/requisition_token/fishing/rare(src.loc)
					qdel( P )
				if (FISH_RARITY_EPIC)
					new/obj/item/requisition_token/fishing/epic(src.loc)
					qdel( P )
				if (FISH_RARITY_LEGENDARY)
					new/obj/item/requisition_token/fishing/legendary(src.loc)
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
			boutput(user, "<span class='alert'>You can't put that in the upload terminal!</span>")
			return
		user.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>")
		user.u_equip(W)
		W.set_loc(src)
		W.dropped(user)
		return

/obj/submachine/fishing_upload_terminal/portable
	anchored = 0

/obj/item/storage/fish_box
	name = 	"Portable aquarium"
	desc = "A temporary solution for transporting fish."
	icon_state = "box"
	slots = 5
	can_hold = 	list(/obj/item/fish)
