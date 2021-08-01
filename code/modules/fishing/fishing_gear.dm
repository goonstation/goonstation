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
	var/is_fishing = false

	//todo: attack particle?? some sort of indicator of where we're fishing
	afterattack(atom/target, mob/user)
		if (target && user && (src.last_fished < TIME + src.fishing_delay))
			var/datum/fishing_spot/fishing_spot = global.fishing_spots[target.type]
			if (fishing_spot)
				actions.start(new /datum/action/fishing(user, src, fishing_spot, target), user)

	proc/update_icon()
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
		if (!IN_RANGE(src.user, src.rod, 1) || !IN_RANGE(src.user, src.target, 1) || !src.user || !src.target || !src.rod || !src.fishing_spot)
			interrupt(INTERRUPT_ALWAYS)
			return

		src.duration = max(0.5 SECONDS, rod.fishing_speed + (pick(1, -1) * (rand(0,40) / 10) SECONDS)) //translates to rod duration +- (0,4) seconds, minimum of 0.5 seconds
		playsound(src.user, "sound/items/fishing_rod_cast.ogg", 50, 1)
		src.user.visible_message("[src.user] starts fishing.")
		src.rod.is_fishing = true
		src.rod.update_icon()
		src.user.update_inhands()

	onUpdate()
		..()
		if (!IN_RANGE(src.user, src.rod, 1) || !IN_RANGE(src.user, src.target, 1) || !src.user || !src.target || !src.rod || !src.fishing_spot)
			interrupt(INTERRUPT_ALWAYS)
			src.rod.is_fishing = false
			src.rod.update_icon()
			src.user.update_inhands()
			return

	onEnd()
		if (!IN_RANGE(src.user, src.rod, 1) || !IN_RANGE(src.user, src.target, 1) || !src.user || !src.target || !src.rod || !src.fishing_spot)
			..()
			interrupt(INTERRUPT_ALWAYS)
			src.rod.is_fishing = false
			src.rod.update_icon()
			src.user.update_inhands()
			return

		if (src.fishing_spot.try_fish(src.user, src.rod, target)) //if it returns one we successfully fished, otherwise lets restart the loop
			..()
			src.rod.is_fishing = false
			src.rod.update_icon()
			src.user.update_inhands()
			return

		else //lets restart the action
			src.onRestart()


