//file for da fishin gear

// rod flags are WIP, nonfunctional yet
#define ROD_WATER (1<<0) //can it fish in water?

/obj/item/fishing_rod
	name = "fishing rod"
	icon = 'icons/obj/items/fishing_gear.dmi'
	icon_state = "fishing_rod-inactive"
	inhand_image_icon = 'icons/mob/inhand/hand_fishing.dmi'
	item_state = "fishing_rod-inactive"
	c_flags = ONBELT
	/// average time to fish up something, in seconds - will vary on the upper and lower bounds by a maximum of 4 seconds, with a minimum time of 0.5 seconds.
	var/fishing_speed = 8 SECONDS
	/// how long to wait between casts in seconds - mainly so sounds dont overlap
	var/fishing_delay = 2 SECONDS
	/// set to TIME when fished, value is checked when deciding if the rod is currently on cooldown
	var/last_fished = 0
	/// true if the rod is currently "fishing", false if it isnt
	var/is_fishing = FALSE
	/// what tier of rod is this? can be 0, 1 or 2
	var/tier = 0

	New()
		..()
		RegisterSignal(src, COMSIG_ITEM_ATTACKBY_PRE, PROC_REF(attackby_pre))

	disposing()
		UnregisterSignal(src, COMSIG_ITEM_ATTACKBY_PRE)
		. = ..()

	//todo: attack particle?? some sort of indicator of where we're fishing
	proc/attackby_pre(source, atom/target, mob/user)
		if (target && user && (src.last_fished < TIME + src.fishing_delay))
			var/datum/fishing_spot/fishing_spot = null
			var/fishing_spot_type = target.type
			while (fishing_spot_type != null)
				fishing_spot = global.fishing_spots[fishing_spot_type]
				if (fishing_spot != null)
					break
				fishing_spot_type = type2parent(fishing_spot_type)
			if (fishing_spot)
				if (fishing_spot.rod_tier_required > src.tier)
					user.visible_message("<span class='alert'>You need a higher tier rod to fish here!</span>")
					return
				actions.start(new /datum/action/fishing(user, src, fishing_spot, target), user)
				return TRUE //cancel the attack because we're fishing now

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
	duration = 1 MINUTE
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
		if (src.rod.tier < fishing_spot.rod_tier_required)
			//user.visible_message("<span class='alert'>You need a higher tier rod to fish here!</span>")
			boutput(user, "<span class='notice'>You need a higher tier rod to fish here!.</span>")
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!(BOUNDS_DIST(src.user, src.rod) == 0) || !(BOUNDS_DIST(src.user, src.target) == 0) || !src.user || !src.target || !src.rod || !src.fishing_spot)
			interrupt(INTERRUPT_ALWAYS)
			return


		src.duration = max(0.5 SECONDS, rod.fishing_speed + (pick(1, -1) * (rand(0,40) / 10) SECONDS)) //translates to rod duration +- (0,4) seconds, minimum of 0.5 seconds
		playsound(src.user, 'sound/items/fishing_rod_cast.ogg', 50, 1)
		//src.user.visible_message("[src.user] starts fishing.")
		boutput(user, "<span class='notice'>You start fishing.</span>")
		src.rod.is_fishing = TRUE
		src.rod.UpdateIcon()
		src.user.update_inhands()
		JOB_XP(user, "Angler", 1)

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

/obj/item/fishing_rod/basic
	name = "basic fishing rod"
	icon_state = "fishing_rod-inactive"
	item_state = "fishing_rod-inactive"
	tier = 1

	update_icon()
		if (src.is_fishing)
			src.icon_state = "fishing_rod-active"
			src.item_state = "fishing_rod-active"
		else
			src.icon_state = "fishing_rod-inactive"
			src.item_state = "fishing_rod-inactive"

/obj/item/fishing_rod/upgraded
	name = "upgraded fishing rod"
	icon_state = "fishing_rod_2-inactive"
	item_state = "fishing_rod-inactive"
	tier = 2

	update_icon()
		if (src.is_fishing)
			src.icon_state = "fishing_rod_2-active"
			src.item_state = "fishing_rod-active"
		else
			src.icon_state = "fishing_rod_2-inactive"
			src.item_state = "fishing_rod-inactive"

/obj/item/fishing_rod/master
	name = "master fishing rod"
	icon_state = "fishing_rod_3-inactive"
	item_state = "fishing_rod-inactive"
	tier = 3

	update_icon()
		if (src.is_fishing)
			src.icon_state = "fishing_rod_3-active"
			src.item_state = "fishing_rod-active"
		else
			src.icon_state = "fishing_rod_3-inactive"
			src.item_state = "fishing_rod-inactive"

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
	anchored = ANCHORED
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
	density = 1
	anchored = 1
	icon = 'icons/obj/items/fishing_gear.dmi'
	icon_state = "fishing_pool"

	basic
		name = "basic pool"

	upgraded
		name = "upgraded pool"

	master
		name = "master pool"

/obj/fishing_pool/portable
	anchored = 0

	attackby(obj/item/W, mob/user)
		if (istool(W, TOOL_SCREWING | TOOL_WRENCHING))
			user.visible_message("<b>[user]</b> [src.anchored ? "unanchors" : "anchors"] the [src].")
			playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)
			src.anchored = !(src.anchored)
			return
		else
			return ..()

// Gannets new fishing gear

/obj/submachine/fishing_upload_terminal
	name = "Aquatic Research Upload Terminal"
	desc = "Insert fish to recieve points to spend in the fishing vendor."
	icon = 'icons/obj/large/32x48.dmi'
	icon_state = "uploadterminal_open"
	anchored = ANCHORED
	density = 1
	layer = MOB_LAYER + 0.1
	var/working = FALSE
	var/allowed = list(/obj/item/reagent_containers/food/fish)

	attack_hand(var/mob/user)
		if (!length(src.contents))
			boutput(user, "<span class='alert'>There is nothing in the upload terminal!</span>")
			return
		if (src.working)
			boutput(user, "<span class='alert'>The terminal is busy!</span>")
			return
		src.icon_state = "uploadterminal_working"
		src.working = TRUE
		src.visible_message("The [src] begins uploading research data.")
		playsound(src.loc, 'sound/effects/fish_processing_alt.ogg', 100, 1)
		sleep(rand(3 SECONDS, 7 SECONDS))
		var/found_blacklisted_fish = FALSE
		// Dispense processed stuff
		for(var/obj/item/reagent_containers/food/fish/P in src)
			//No botany fish. Be a real angler and use that damn fishing rod
			if (P.fishing_upload_blacklisted)
				found_blacklisted_fish = TRUE
				P.set_loc(get_turf(src))
			else
				switch( P.rarity )
					if (ITEM_RARITY_COMMON)
						new/obj/item/currency/fishing(src.loc)
						JOB_XP(user, "Angler", 1)
						qdel( P )
					if (ITEM_RARITY_UNCOMMON)
						new/obj/item/currency/fishing/uncommon(src.loc)
						JOB_XP(user, "Angler", 2)
						qdel( P )
					if (ITEM_RARITY_RARE)
						new/obj/item/currency/fishing/rare(src.loc)
						JOB_XP(user, "Angler", 3)
						qdel( P )
					if (ITEM_RARITY_EPIC)
						new/obj/item/currency/fishing/epic(src.loc)
						JOB_XP(user, "Angler", 4)
						qdel( P )
					if (ITEM_RARITY_LEGENDARY)
						new/obj/item/currency/fishing/legendary(src.loc)
						JOB_XP(user, "Angler", 5)
						qdel( P )
		if (found_blacklisted_fish)
			src.visible_message("<span class='alert'>\The [src] ejects synthetical fish it was unable to do any research on!</span>")

		// Wind down
		for(var/obj/item/S in src)
			S.set_loc(get_turf(src))
		src.working = FALSE
		src.icon_state = "uploadterminal_open"
		playsound(src.loc, 'sound/effects/fish_processed_alt.ogg', 100, 1)

	attack_ai(var/mob/user as mob)
		return attack_hand(user)

	attackby(obj/item/W, mob/user)
		if (src.working)
			boutput(user, "<span class='alert'>The terminal is busy!</span>")
			return
		if (istype(W, /obj/item/storage/fish_box))
			var/obj/item/storage/fish_box/S = W
			if (length(S.contents) < 1) boutput(user, "<span class='alert'>There's no fish in the portable aquarium!</span>")
			else
				user.visible_message("<span class='notice'>[user] loads [S]'s contents into [src]!</span>")
				var/amtload = 0
				for (var/obj/item/reagent_containers/food/fish/F in S.contents)
					F.set_loc(src)
					amtload++
				S.UpdateIcon()
				boutput(user, "<span class='notice'>[amtload] fish loaded from the portable aquarium!</span>")
				S.tooltip_rebuild = 1
			return
		else
			var/proceed = FALSE
			for(var/check_path in src.allowed)
				if(istype(W, check_path))
					proceed = TRUE
					break
			if (!proceed)
				boutput(user, "<span class='alert'>You can't put that in the upload terminal!</span>")
				return
			user.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>")
			user.u_equip(W)
			W.set_loc(src)
			W.dropped(user)

/obj/submachine/fishing_upload_terminal/portable
	anchored = 0

	attackby(obj/item/W, mob/user)
		if (istool(W, TOOL_SCREWING | TOOL_WRENCHING))
			user.visible_message("<b>[user]</b> [src.anchored ? "unanchors" : "anchors"] the [src].")
			playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)
			src.anchored = !(src.anchored)
			return
		else
			return ..()

/obj/item/storage/fish_box
	name = 	"Portable aquarium"
	desc = "A temporary solution for transporting fish."
	icon = 'icons/obj/items/fishing_gear.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	icon_state = "aquarium"
	item_state = "aquarium"
	slots = 6
	can_hold = 	list(/obj/item/reagent_containers/food/fish)
