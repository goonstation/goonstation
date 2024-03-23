TYPEINFO(/datum/component/hattable) // Take a walk through my TWISTED mind.... I'm sorry
	initialization_args = list(
		ARG_INFO("death_remove", DATA_INPUT_TEXT, "Remove component and signals on death?", FALSE), // Use this for things that don't revive, or explode on death
		ARG_INFO("free_hat", DATA_INPUT_TEXT, "Should the parent get a free hat?", FALSE), // For AIs
	)

/datum/component/hattable  // Compatible stuff should be given hat_offset x and y vars in their own file
	dupe_mode = COMPONENT_DUPE_HIGHLANDER
	var/y_level = 0
	var/x_level = 0
	var/obj/item/hat = null
	var/death_throw = FALSE
	var/death_remove = FALSE
	var/free_hat = FALSE
	var/free_hat_lockout = FALSE

/datum/component/hattable/Initialize(death_remove, free_hat)
	. = ..()
	RegisterSignal(src.parent, COMSIG_ATTACKBY, PROC_REF(hat_on_obj), override = TRUE)
	src.death_throw = FALSE
	src.death_remove = death_remove
	src.free_hat = free_hat
	if (free_hat && !free_hat_lockout) // If the thing gets a free hat (currently just AIs with spacebux) and they haven't received it yet, do that
		var/free_hat_type = pick(childrentypesof(pick(childrentypesof(/obj/item/clothing/head))))
		hat_on_obj(src.parent, free_hat_type)


/datum/component/hattable/proc/hat_on_obj(mob/target as mob, obj/item/item as obj, mob/attacker)
	var/obj/item/H = null
	if (src.free_hat && !src.free_hat_lockout)
		item = new item(get_turf(src)) // Make a new item, lockout future free hats
		free_hat_lockout = TRUE
	H = item

	var/atom/movable/hatted = src.parent
	var/obj/item/hatted_offset = src.parent
	var/is_item_hat = FALSE
	if (istype(H, /obj/item/clothing/head/))
		is_item_hat = TRUE
		ADD_FLAG(H.appearance_flags, KEEP_TOGETHER) // Flags needed for wigs!
		ADD_FLAG(H.vis_flags, VIS_INHERIT_DIR)

	if (!src.hat && is_item_hat)
		if (attacker)
			attacker.drop_item()
		else
			target.drop_item(H) // you're going there whether you like it or not

		src.y_level = 0 // Make ABSOLUTE SURE we're not adding onto a previous offset
		src.x_level = 0
		src.y_level = hatted_offset.hat_offset_y + H.hat_offset_y // If a specific hat appears in a strange place, give it its own hat_offset vars to edit the offset by
		src.x_level = hatted_offset.hat_offset_x + H.hat_offset_x
		H.pixel_y = src.y_level
		H.pixel_x = src.x_level

		src.hat = H
		H.layer = hatted.layer + 7
		H.set_loc(src.parent)
		hatted.vis_contents += H
		if (src.death_remove)
			RegisterSignal(src.parent, COMSIG_MOB_DEATH, PROC_REF(die), override = TRUE)
		RegisterSignal(src.hat, COMSIG_ITEM_PICKUP, PROC_REF(take_hat_off), override = TRUE)
		return
	else
		return

/datum/component/hattable/proc/take_hat_off(mob/target, mob/user)
	var/obj/item/H = src.hat
	var/atom/movable/hatted = src.parent

	if (H)
		if (istype(user, /mob/living/silicon/ghostdrone))
			SPAWN(0) // Magtractors use an action bar until they do stuff, and then they'll clone a ghost image of the item that's on the floor. Drop that!
				var/mob/living/silicon/ghostdrone/drone = user
				var/obj/item/magtractor/mag = locate(/obj/item/magtractor) in drone.tools
				if (mag.holding)
					mag.dropItem(src)
		H.set_loc(get_turf(hatted))
		hatted.vis_contents -= H
		if(src.death_throw)
			var/turf/T = get_ranged_target_turf(H, pick(alldirs), 3)
			H.throw_at(T, 3, 1)
			SPAWN(10)
				UnregisterSignal(src.parent, list(COMSIG_MOB_DEATH, COMSIG_ATTACKBY))
				UnregisterSignal(H, COMSIG_ITEM_PICKUP)
				src.death_throw = FALSE
				return
		else
			UnregisterSignal(H, COMSIG_ITEM_PICKUP)
		H.pixel_y = 0
		H.pixel_x = 0
		src.y_level = 0
		src.x_level = 0
		src.hat = null
		return
	else
		return

/datum/component/hattable/proc/die()
	if (src.hat)
		src.death_throw = TRUE
		take_hat_off(src.parent)
	else
		return






