// attach this component only to things that have can_bouquet as a var.
// so far this includes /obj/item/clothing/head/flower and /obj/item/plant
// Actual bouquets are in 'code/obj/item/bouquet.dm'

/// the bouquet component, that allows flowers of various parentage to be wrapped into bouquets
/datum/component/bouquet

/datum/component/bouquet/Initialize()
	. = ..()
	RegisterSignal(parent, COMSIG_ATTACKBY, .proc/construct_bouquet)

/datum/component/bouquet/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATTACKBY)
	. = ..()

/datum/component/bouquet/proc/construct_bouquet(obj/item/source, obj/item/W, mob/user)
	// if it isnt paper, wrapping paper, or a bouquet, dont care
	if (!istype(W, /obj/item/paper) && !istype(W, /obj/item/wrapping_paper) && !istype(W, /obj/item/bouquet))
		return
	// certain paper subtypes not accepted
	if (istype(W, /obj/item/paper/fortune) || istype(W, /obj/item/paper/printout))
		return
	// this really shouldnt occur, but if the component is erronously attached to a non bouquetable flower...
	if (!src.can_bouquet)
		boutput("This flower can't be turned into a bouquet!")
		return
	// attacked by a wrapping, make new bouquet
	if (istype(W, /obj/item/paper || /obj/item/wrapping_paper))
		if (istype(W, /obj/item/paper/folded))
			boutput("You need to unfold this first!")
			return
		var/obj/item/bouquet/new_bouquet = new(user.loc)
		// drop both bits just in case
		W.force_drop(user)
		source.force_drop(user)
		// in case flower stacks become a thing, just put one single flower in
		if (source.amount > 1)
			var/obj/item/clothing/head/flower/allocated_flower = source.split_stack(1)
			allocated_flower.set_loc(new_bouquet)
		else
			source.set_loc(new_bouquet)
		// set the wrapstyle based on the wrap used
		if (istype(W, /obj/item/wrapping_paper))
			var/obj/item/wrapping_paper/dummy = W
			new_bouquet.wrapstyle = "gw_[dummy.style]"
		else if (istype(W, /obj/item/paper))
			new_bouquet.wrapstyle = "paper"
		// finish up
		W.set_loc(new_bouquet)
		new_bouquet.refresh()
		user.visible_message("[user] rolls up the [source.name] into a bouquet.", "You roll up the [source.name] into a bouquet.")
		user.put_in_hand_or_drop(new_bouquet)
	// hit the flower with the bouquet, i.e. add self to existing bouquet
	if (istype(W, /obj/item/bouquet))
		var/obj/item/bouquet/bouquet_holder = W
		bouquet_holder.add_to_bouquet(source, user)
