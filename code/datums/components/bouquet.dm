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

/obj/item/bouquet
	name = "bouquet"
	desc = "A lovely arrangement of flowers."
	icon = 'icons/obj/items/bouquets.dmi'
	inhand_image_icon = 'icons/obj/items/bouquets.dmi'
	icon_state = "base"
	var/flowernum = 0
	var/wrapstyle = null
	var/max_flowers = 3
	var/min_flowers = 1 // can't have a bouquet with no flowers
	var/hiddenitem = FALSE
/*	So anywhere here's the naming convention for bouquet.dmi files
	for the paper, it's either item/paper or item/wrapping_paper
	so the naming for that is base_src.wrapstyle where wrapstyle is either 'paper' or the src.style of wrapping paper
	the flowers are named by src.name_number from 1-3
	the inhand versions are exactly the same except preceded by inhand_
 */
/obj/item/bouquet/attackby(obj/item/W, mob/user)
	// should give us back the paper and flowers when done with snipping tool
	if (issnippingtool(W))
		boutput(user, "<span class='notice'>You disassemble the [src].</span>")
		playsound(src.loc, 'sound/items/Scissor.ogg', 30, 1)
		qdel(src)
	else if (istype(W, /obj/item/plant/herb))
		var/obj/item/plant/herb/dummy_herb = W
		if (!dummy_herb.can_bouquet)
			boutput(user, "This herb can't be added into a bouquet!")
			return
		if (flowernum >= 3)
			boutput(user, "This bouquet is full!")
			return
		src.add_flower(W, user)
	else if (istype(W, /obj/item/clothing/head/flower))
		var/obj/item/clothing/head/flower/dummy_flower = W
		if (!dummy_flower.can_bouquet)
			boutput(user, "This flower can't be added into a bouquet!")
			return
		if (flowernum >= 3)
			boutput(user, "This bouquet is full!")
			return
		src.add_flower(W, user)
	else if (flowernum == 1)
		if (!hiddenitem) // only one hidden item allowed
			W.set_loc(src)
			src.hiddenitem = TRUE
		else
			boutput("This bouquet already has an item in it!")
/obj/item/bouquet/attack_self(mob/user)
	src.refresh()
/obj/item/bouquet/proc/add_flower(obj/item/W, mob/user)
	W.force_drop(user)
	src.force_drop(user)
	W.set_loc(src)
	user.visible_message("[user] adds a [W.name] to the bouquet.", "You add a [W.name] to the bouquet.")
	src.flowernum += 1
	src.refresh()
	user.put_in_hand_or_drop(src)

/obj/item/bouquet/proc/refresh()
	// overlays is for the icon, inhand_image is for, well, the inhand
	// updating the icon also randomises the order (non negotiable)
	// we'll also do the name and desc here because why not
	var/temporder = pick(list(1, 2, 3), list(1, 3, 2), list(2, 1, 3), list(2, 3, 1), list(3, 1, 2), list(3, 2, 1))
	var/flowernames = list()
	var/hiddentext = ""
	src.overlays = null
	src.inhand_image.overlays = null
	src.icon_state = "base_[src.wrapstyle]"
	src.inhand_image = image('icons/obj/items/bouquets.dmi', icon_state = "inhand_base_[src.wrapstyle]")
	for (var/obj/item/temp in src.contents)
		if (istype(temp, /obj/item/clothing/head/flower) || istype(temp, /obj/item/plant/herb))
			flowernames += temp.name
			src.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "[temp.name]_[temporder[length(flowernames)]]")
			src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_[temp.name]_[temporder[length(flowernames)]]")
		// if (!istype(temp, /obj/item/paper) && !istype(temp, /obj/item/wrapping_paper) && !istype(temp, /obj/item/clothing/head/flower) && flowernum == 1)
			// we want the hidden item to be toward the back, covered by other stuff
			// src.overlays += image(temp.icon, icon_state = temp.icon_state)
	src.name = "[flowernames[1]] bouquet"
	if (src.hiddenitem)
		hiddentext = " There seems to be something else inside it as well."
	if (flowernum == 1)
		src.desc = "A single [flowernames[1]] in a nice wrapping. Try adding more flowers to it![hiddentext]"
	else if (flowernum == 2)
		src.desc = "A bouquet of beautiful flowers. This one contains both a [flowernames[1]] and a [flowernames[2]].[hiddentext]"
	else if (flowernum == 3)
		src.desc = "A bouquet of beautiful flowers. This one contains a [flowernames[1]], [flowernames[2]] and [flowernames[3]].[hiddentext]"
