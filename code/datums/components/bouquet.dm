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
	icon_state = "bqwrap_back"
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
	. = ..()
	src.refresh()
/obj/item/bouquet/attack_hand(mob/user)
	. = ..()
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
	var/obj/item/flower1 = null
	var/obj/item/flower2 = null
	var/obj/item/flower3 = null
	src.overlays = null
	src.inhand_image.overlays = null
	src.icon_state = "bqwrap_back"
	src.inhand_image = image('icons/obj/items/bouquets.dmi', icon_state = "inhand_base_[src.wrapstyle]")
	for (var/obj/item/temp in src.contents)
		if (istype(temp, /obj/item/clothing/head/flower) || istype(temp, /obj/item/plant))
			if (isnull(flower1))
				flower1 = temp.name
				continue
			else if (isnull(flower2))
				flower2 = temp.name
				continue
			else if (isnull(flower3))
				flower3 = temp.name
				continue
			else
				CRASH("More than 3 flowers in bouquet: [get_turf(src)]") // this shouldnt happen but eh
	switch (src.flowernum)
		if (1)
			src.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "[flower1]_m")
			src.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "bqwrap_front")
			src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_[flower1]_m")
			src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_bqwrap_front")
			src.name = "[flower1] bouquet"
			src.desc = "A [flower1] in a nice wrapping. Try adding more flowers to it!"
		if (2)
			var/rightorleft = pick("r", "l")
			var/list/frontflowerindex = pick(list(flower1,flower2),list(flower2,flower1)) //picks a order for the flowers
			src.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "[frontflowerindex[1]]_[rightorleft]")
			src.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "[frontflowerindex[2]]_m")
			src.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "bqwrap_front")
			src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_[frontflowerindex[1]]_[rightorleft]")
			src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_[frontflowerindex[2]]_m")
			src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_bqwrap_front")
			src.desc = "A bouquet of beautiful flowers. This one contains both [flower2] and [flower1]."
		if (3)
			var/list/frontflowerindex = pick(
				list(flower1, flower2, flower3), list(flower2, flower1, flower3),
				list(flower1, flower3, flower2), list(flower2, flower3, flower1),
				list(flower3, flower1, flower2), list(flower3, flower2, flower1)
			) // pick a random order for the three to appear in.
			src.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "[frontflowerindex[1]]_r")
			src.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "[frontflowerindex[2]]_l")
			src.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "[frontflowerindex[3]]_m")
			src.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "bqwrap_front")
			src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_[frontflowerindex[1]]_r")
			src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_[frontflowerindex[2]]_l")
			src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_[frontflowerindex[3]]_m")
			src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_bqwrap_front")
			src.desc = "A bouquet of beautiful flowers. This one contains [flower3], [flower2] and [flower1]."
	if (src.hiddenitem)
		src.desc += " There seems to be something else inside it as well."
