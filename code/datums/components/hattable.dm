TYPEINFO(/datum/component/hattable) // Take a walk through my TWISTED mind.... I'm sorry
	initialization_args = list(
		ARG_INFO("death_remove", DATA_INPUT_BOOL, "Remove component and signals on death?", FALSE), // Use this for things that don't revive, or explode on death
		ARG_INFO("free_hat", DATA_INPUT_BOOL, "Should the parent get a free hat?", FALSE), // For AIs
		ARG_INFO("default_hat_y", DATA_INPUT_NUM, "Y offset to start with", 0),
		ARG_INFO("default_hat_x", DATA_INPUT_NUM, "X offset to start with", 0),
		ARG_INFO("scale_amount", DATA_INPUT_NUM, "Amount to change the size of the hat by", 0)
	)

/datum/component/hattable  // Compatible stuff should be given hat_offset x and y vars in their own file
	dupe_mode = COMPONENT_DUPE_HIGHLANDER
	var/default_hat_y = 0
	var/default_hat_x = 0
	var/obj/item/hat = null
	var/death_throw = FALSE
	var/death_remove = FALSE
	var/free_hat = FALSE
	var/scale_amount = 0

/datum/component/hattable/Initialize(death_remove, free_hat, default_hat_y, default_hat_x, scale_amount)
	. = ..()
	RegisterSignal(src.parent, COMSIG_ATTACKBY, PROC_REF(hat_on_thing), override = TRUE)
	src.death_throw = FALSE
	src.death_remove = death_remove
	src.default_hat_y = default_hat_y
	src.default_hat_x = default_hat_x
	src.scale_amount = scale_amount
	if (free_hat) // If the thing gets a free hat (currently just AIs with spacebux) and they haven't received it yet, do that
		var/free_hat_type = pick(filtered_concrete_typesof(/obj/item/clothing/head, /proc/filter_trait_hats))
		free_hat_type = new free_hat_type(get_turf(src))
		hat_on_thing(src.parent, free_hat_type)


/datum/component/hattable/proc/hat_on_thing(mob/target as mob, obj/item/item as obj, mob/attacker)
	if (src.hat)
		return

	var/atom/movable/hatted = src.parent
	var/offsetBy_y = 0
	var/offsetBy_x = 0


	if (istype(item, /obj/item/clothing/head/))
		src.hat = item
		ADD_FLAG(src.hat.appearance_flags, KEEP_TOGETHER) // Flags needed for wigs!
		ADD_FLAG(src.hat.vis_flags, VIS_INHERIT_DIR)
	else
		return
	if (attacker)
		attacker.drop_item()

	offsetBy_y = src.default_hat_y + src.hat.hat_offset_y // Add a hat's own offsets if they have them
	offsetBy_x = src.default_hat_x + src.hat.hat_offset_x
	src.hat.pixel_y = offsetBy_y
	src.hat.pixel_x = offsetBy_x

	src.hat.transform *= src.scale_amount
	src.hat.layer = hatted.layer + 1
	src.hat.set_loc(src.parent)
	hatted.vis_contents += src.hat

	if (src.death_remove)
		RegisterSignal(src.parent, COMSIG_MOB_DEATH, PROC_REF(die), override = TRUE)
	RegisterSignal(src.hat, COMSIG_ITEM_PICKUP, PROC_REF(take_hat_off), override = TRUE)
	UnregisterSignal(src.parent, COMSIG_ATTACKBY)

	if (istype(item, /obj/item/clothing/head/butt) && isAI(target))
		var/obj/item/clothing/head/butt/butt = item
		if (butt.donor == attacker)
			attacker.unlock_medal("Law 1: Don't be an asshat", TRUE)

	return TRUE

/datum/component/hattable/proc/take_hat_off(mob/target, mob/user)
	if (!src.hat)
		return
	var/atom/movable/hatted = src.parent

	src.hat.set_loc(get_turf(hatted))
	hatted.vis_contents -= src.hat
	src.hat.layer = OBJ_LAYER
	src.hat.transform = 1
	src.hat.pixel_y = 0
	src.hat.pixel_x = 0

	if(src.death_throw) // If the thing dies, this proc is called and death_throw is set to true, then false
		var/turf/T = get_ranged_target_turf(src.hat, pick(alldirs), 3)
		src.hat.throw_at(T, 3, 1)
		UnregisterSignal(src.parent, list(COMSIG_MOB_DEATH, COMSIG_ATTACKBY))
		UnregisterSignal(src.hat, COMSIG_ITEM_PICKUP)
		src.death_throw = FALSE
		return
	else
		UnregisterSignal(src.hat, COMSIG_ITEM_PICKUP)
		RegisterSignal(src.parent, COMSIG_ATTACKBY, PROC_REF(hat_on_thing), override = TRUE)

	if (istype(user, /mob/living/silicon/ghostdrone))
		SPAWN(0) // Magtractors use an action bar until they do stuff, and then they'll clone a ghost image of the item that's on the floor. Drop that!
			var/mob/living/silicon/ghostdrone/drone = user
			var/obj/item/magtractor/mag = locate(/obj/item/magtractor) in drone.tools
			if (mag.holding)
				mag.dropItem(src)

	src.hat = null

/datum/component/hattable/proc/die()
	if (src.hat)
		src.death_throw = TRUE
		take_hat_off(src.parent)






