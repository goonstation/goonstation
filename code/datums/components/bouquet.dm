// WARNING: attach this component only to things that have can_bouquet as a var.
// so far this includes /obj/item/clothing/head/flower and /obj/item/plant
// Actual bouquets are in 'code/obj/item/bouquet.dm'

/* STEPS TO ADDING A NEW FLOWER TO BE BOUQUETABLE
1.	create three sprites for them in bouquets.dmi. names them name_l, name_m, and name_r for left middle and right.
	Visually, the middle ones cover the ones at the sides. Keep that in mind.
2.	Go to the flower involved and add the component in the New() proc. Look at lavender to see how it's done.
3. Optionally, at the bottom of code/obj/item/bouquet.dm, create a subtype of premade monotype bouquets
*/

TYPEINFO(/datum/component/bouquet)
	initialization_args = list()

/// the bouquet component, that allows flowers of various parentage to be wrapped into bouquets
/datum/component/bouquet

/datum/component/bouquet/Initialize()
	. = ..()
	if (isnull(parent))
		return COMPONENT_INCOMPATIBLE
	if (!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/W = parent
	if (!W.is_valid_icon_state("[W.icon_state]_l", 'icons/obj/items/bouquets.dmi'))
		return COMPONENT_INCOMPATIBLE // it doesn't a matching left icon
	if (!W.is_valid_icon_state("[W.icon_state]_m", 'icons/obj/items/bouquets.dmi'))
		return COMPONENT_INCOMPATIBLE // it doesn't a matching middle icon
	if (!W.is_valid_icon_state("[W.icon_state]_r", 'icons/obj/items/bouquets.dmi'))
		return COMPONENT_INCOMPATIBLE // it doesn't a matching right icon
	RegisterSignal(parent, COMSIG_ATTACKBY, .proc/attackby)
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, .proc/attack)

/datum/component/bouquet/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATTACKBY)
	UnregisterSignal(parent, COMSIG_ITEM_AFTERATTACK)
	. = ..()

/datum/component/bouquet/proc/attack(obj/item/source, atom/W, mob/user, reach, params)
	// if we attack a bouquet with a flower, add it.
	if (!istype(W, /obj/item/bouquet))
		return
	var/obj/item/bouquet/B = W
	if (B.flowernum >= B.max_flowers)
		boutput(user, "This bouquet is full!")
		return
	B.add_flower(source, user)
	return TRUE

/datum/component/bouquet/proc/attackby(obj/item/source, obj/item/W, mob/user)
	// if we attack a flower with a bouquet, add it
	if (istype(W, /obj/item/bouquet))
		var/obj/item/bouquet/B = W
		if (B.flowernum >= B.max_flowers)
			boutput(user, "This bouquet is full!")
			return
		B.add_flower(source, user)
	// if it isnt paper or wrapping paper, dont care
	if (!istype(W, /obj/item/paper) && !istype(W, /obj/item/wrapping_paper))
		return
	// certain paper subtypes not accepted
	if (istype(W, /obj/item/paper/fortune) || istype(W, /obj/item/paper/printout))
		return
	// attacked by a wrapping, make new bouquet
	if (istype(W, /obj/item/paper) || istype(W, /obj/item/wrapping_paper))
		if(istype(W, /obj/item/paper))
			if( tgui_alert(user, "How would you like to wrap \the [source]?", "Wrapping...", list("Bouquet", "Cigarette")) == "Cigarette" )
				//Let herb handling do its magic
				return

		if (istype(W, /obj/item/paper/folded))
			boutput("You need to unfold this first!")
			return
		var/obj/item/bouquet/new_bouquet = new(user.loc)
		// drop both bits just in case
		W.force_drop(user)
		source.force_drop(user)
		// now we add the flower to contents
		if (source.amount > 1)// in case flower stacks become a thing, just put one single flower in. Futureproofing.
			var/obj/item/clothing/head/flower/allocated_flower = source.split_stack(1)
			allocated_flower.set_loc(new_bouquet)
		else
			source.set_loc(new_bouquet)
		// set the wrapstyle based on the wrap used
		if (istype(W, /obj/item/wrapping_paper))
			var/obj/item/wrapping_paper/dummy = W
			new_bouquet.wrapstyle = "gw-[dummy.style]"
		else if (istype(W, /obj/item/paper))
			new_bouquet.wrapstyle = "paper"
		// finish up
		W.set_loc(new_bouquet)
		new_bouquet.refresh()
		new_bouquet.ruffle()
		user.visible_message("[user] rolls up \the [source.name] into a bouquet.", "You roll up \the [source.name] into a bouquet.")
		user.put_in_hand_or_drop(new_bouquet)
		return TRUE
