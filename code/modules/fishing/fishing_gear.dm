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

	//todo: attack particle?? some sort of indicator of where we're fishing
	afterattack(atom/target, mob/user)
		if (target && user && (src.last_fished < TIME + src.fishing_delay))
			var/datum/fishing_spot/fishing_spot = global.fishing_spots[target.type]
			if (fishing_spot && !src.is_fishing)
				if (fishing_spot.rod_tier_required > src.tier)
					user.visible_message("<span class='alert'>You need a higher tier rod to fish here!</span>")
					return
				actions.start(new /datum/action/fishing(user, src, fishing_spot, target), user)
//				AddComponent(/datum/component/holdertargeting/fishing_game, user)


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
	duration = -1
	/// id for fishing action
	id = "fishing_for_fishies"
	var/obj/actions/border/border
	var/obj/actions/border/block
	var/acceleration = 0
	var/stopping = FALSE
	var/is_mouse_down = FALSE
	var/list/atom/movable/screen/fullautoAimHUD/hudSquares = list()

	New(var/user, var/rod, var/fishing_spot, var/target)
		..()
		src.user = user
		src.rod = rod
		src.fishing_spot = fishing_spot
		src.target = target
		for(var/x in 1 to WIDE_TILE_WIDTH)
			for(var/y in 1 to 15)
				var/atom/movable/screen/fullautoAimHUD/hudSquare = new /atom/movable/screen/fullautoAimHUD
				hudSquare.screen_loc = "[x],[y]"
				hudSquare.xOffset = x
				hudSquare.yOffset = y
				src.hudSquares["[x],[y]"] = hudSquare

	onStart()
		..()
		if (src.rod.tier < fishing_spot.rod_tier_required)
			user.visible_message("<span class='alert'>You need a higher tier rod to fish here!</span>")
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!(BOUNDS_DIST(src.user, src.rod) == 0) || !(BOUNDS_DIST(src.user, src.target) == 0) || !src.user || !src.target || !src.rod || !src.fishing_spot)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/client/C = src.user.client
		for (var/x in 1 to istext(C.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH)
			for (var/y in 1 to 15)
				C.screen += src.hudSquares["[x],[y]"]

		RegisterSignal(user, COMSIG_FULLAUTO_MOUSEDOWN, .proc/mouse_down)
		RegisterSignal(user, COMSIG_MOB_MOUSEUP, .proc/mouse_up)
		border = new /obj/actions/border
		border.set_icon_state("border-fish")
		block = new /obj/actions/border
		block.set_icon_state("fish-block")
		block.color = "#00CC00"
		border.pixel_x = -5
		block.pixel_x = -5
		user.vis_contents += border
		user.vis_contents += block
		src.move_loop()
		playsound(src.user, 'sound/items/fishing_rod_cast.ogg', 50, 1)
		src.user.visible_message("[src.user] starts fishing.")
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
			src.stopping = TRUE
			src.remove_hud_squares()
			return

	onEnd()
		if (!(BOUNDS_DIST(src.user, src.rod) == 0) || !(BOUNDS_DIST(src.user, src.target) == 0) || !src.user || !src.target || !src.rod || !src.fishing_spot)
			..()
			interrupt(INTERRUPT_ALWAYS)
			src.rod.is_fishing = FALSE
			src.rod.UpdateIcon()
			src.user.update_inhands()
			src.stopping = TRUE
			src.remove_hud_squares()
			return

		if (src.fishing_spot.try_fish(src.user, src.rod, target)) //if it returns one we successfully fished, otherwise lets restart the loop
			..()
			src.rod.is_fishing = FALSE
			src.rod.UpdateIcon()
			src.user.update_inhands()
			src.stopping = TRUE
			src.remove_hud_squares()
			return

		else //lets restart the action
			src.onRestart()

	onDelete()
		..()
		//from my experience none of the onUpdate or onEnd blocks get triggered when you just walk away, so just putting this here too
		src.stopping = TRUE
		src.rod.is_fishing = FALSE
		src.rod.UpdateIcon()
		src.user.update_inhands()
		src.rod = null
		if (src.user)
			src.user.vis_contents -= src.border
			src.border.set_loc(null)
			qdel(src.border)
			src.border = null
			src.user.vis_contents -= src.block
			src.block.set_loc(null)
			qdel(src.block)
			src.block = null
		src.remove_hud_squares() //in case it somehow didnt get removed beforehand
		UnregisterSignal(user, COMSIG_FULLAUTO_MOUSEDOWN)
		UnregisterSignal(user, COMSIG_MOB_MOUSEUP)
		src.user = null
		for(var/hudSquare in src.hudSquares)
			qdel(src.hudSquares[hudSquare])


/datum/action/fishing/proc/move_loop()
	set waitfor = 0

	while (!src.stopping)

		if (src.is_mouse_down)
			src.acceleration += 1
		else
			src.acceleration -= 1

		var/endpoint = src.block.pixel_y + src.acceleration

		if (endpoint < -32)
			src.acceleration = ((endpoint + 32)*-1)/2
			endpoint = -32
		else if (endpoint > 32)
			src.acceleration = ((endpoint - 32)*-1)/2
			endpoint = 32

		animate(src.block, pixel_y=endpoint, time=1 DECI SECOND)

		sleep(1 DECI SECOND)

/datum/action/fishing/proc/mouse_down()
	src.is_mouse_down = TRUE

/datum/action/fishing/proc/mouse_up()
	src.is_mouse_down = FALSE

/datum/action/fishing/proc/remove_hud_squares()
	var/client/C = src.user.client
	for (var/hudSquare in src.hudSquares)
		C.screen -= src.hudSquares[hudSquare]

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
	var/allowed = list(/obj/item/fish)

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
		sleep(rand(3 SECONDS, 7 SECONDS))
		var/found_blacklisted_fish = FALSE
		// Dispense processed stuff
		for(var/obj/item/fish/P in src)
			//No botany fish. Be a real angler and use that damn fishing rod
			if (P.fishing_upload_blacklisted)
				found_blacklisted_fish = TRUE
				P.set_loc(get_turf(src))
			else
				switch( P.value )
					if (FISH_RARITY_COMMON)
						new/obj/item/requisition_token/fishing/common(src.loc)
						JOB_XP(user, "Angler", 1)
						qdel( P )
					if (FISH_RARITY_UNCOMMON)
						new/obj/item/requisition_token/fishing/uncommon(src.loc)
						JOB_XP(user, "Angler", 2)
						qdel( P )
					if (FISH_RARITY_RARE)
						new/obj/item/requisition_token/fishing/rare(src.loc)
						JOB_XP(user, "Angler", 3)
						qdel( P )
					if (FISH_RARITY_EPIC)
						new/obj/item/requisition_token/fishing/epic(src.loc)
						JOB_XP(user, "Angler", 4)
						qdel( P )
					if (FISH_RARITY_LEGENDARY)
						new/obj/item/requisition_token/fishing/legendary(src.loc)
						JOB_XP(user, "Angler", 5)
						qdel( P )
		if (found_blacklisted_fish)
			src.visible_message("<span class='alert'>\The [src] ejects synthetical fish it was unable to do any research on!</span>")

		// Wind down
		for(var/obj/item/S in src)
			S.set_loc(get_turf(src))
		src.working = FALSE
		src.icon_state = "uploadterminal_open"
		playsound(src.loc, 'sound/machines/ding.ogg', 100, 1)

	attack_ai(var/mob/user as mob)
		return attack_hand(user)

	attackby(obj/item/W, mob/user)
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
	can_hold = 	list(/obj/item/fish)
