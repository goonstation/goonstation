// so many things can become bouqueted smh
TYPEINFO(/datum/component/bouquet)
	initialization_args = list(
		ARG_INFO("can_bouquet", DATA_INPUT_BOOL, "Whether this item can be turned into a bouquet.", FALSE)
	)
/datum/component/bouquet
	var/can_bouquet = FALSE
/datum/component/bouquet/Initialize()
	. = ..()
	src.can_bouquet = can_bouquet
	RegisterSignal(parent, COMSIG_ATTACKBY, .proc/construct_bouquet)
/datum/component/bouquet/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATTACKBY)
	. = ..()
/datum/component/bouquet/proc/construct_bouquet(obj/item/source, obj/item/W, mob/user)
	if (istype(W, /obj/item/paper/fortune) || istype(W, /obj/item/paper/printout))
		// i feel like fortune cookie wrap is a little small, and printouts probably need a new texture
		return
	if (can_bouquet)
		boutput("This flower can't be turned into a bouquet!")
		return
	if (istype(W, /obj/item/paper || /obj/item/wrapping_paper))
		if (istype(W, /obj/item/paper/folded))
			boutput("You need to unfold this first!")
		else
			var/obj/item/bouquet/new_bouquet = new(user.loc)
			W.force_drop(user)
			source.force_drop(user)
			new_bouquet.flowernum += 1
			if (source.amount > 1)
				var/obj/item/clothing/head/flower/allocated_flower = source.split_stack(1)
				allocated_flower.set_loc(new_bouquet)
			else
				source.set_loc(new_bouquet)
			if (istype(W, /obj/item/wrapping_paper))
				var/obj/item/wrapping_paper/dummy = W
				new_bouquet.wrapstyle = "gw_[dummy.style]"
			if (istype(W, /obj/item/paper))
				new_bouquet.wrapstyle = "paper"
			W.set_loc(new_bouquet)
			new_bouquet.refresh()
			user.visible_message("[user] rolls up a [source.name] into a bouquet.", "You roll up the [source.name] into a bouquet.")
			user.put_in_hand_or_drop(new_bouquet)

