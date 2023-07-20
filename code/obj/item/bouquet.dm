// note: bouquets work hand in hand with the bouquet component attached to flowers.
// accessible at 'code/datums/components/bouquet.dm'

/obj/item/bouquet
	name = "bouquet"
	desc = "A lovely arrangement of flowers."
	icon = 'icons/obj/items/bouquets.dmi'
	inhand_image_icon = 'icons/obj/items/bouquets.dmi'
	icon_state = "paper_back"
	w_class = W_CLASS_SMALL
	flags = SUPPRESSATTACK | TABLEPASS | FPRINT
	/// how many flowers are there in the bouquet?
	var/flowernum = 1
	/// what kind of wrap is used in the bouquet?
	var/wrapstyle = null
	/// this is locked at 3 for sprite reasons
	var/max_flowers = 3
	/// is there a hidden item in the bouquet?
	var/hiddenitem = FALSE

/*	So anyway here's the naming convention for bouquet.dmi files
	for the paper, it's either item/paper or item/wrapping_paper
	so the naming for that is (src.wrapstyle)_back/front where wrapstyle is either 'paper' or the src.style of wrapping paper
	the flowers are named by (flower.name)_X, where name is the name and X is the position, r l or m
	the inhand versions are exactly the same except preceded by inhand_
 */
/obj/item/bouquet/attackby(obj/item/W, mob/user)
	// should give us back the paper and flowers when done with snipping tool
	if (issnippingtool(W))
		boutput(user, "<span class='notice'>You disassemble the [src].</span>")
		playsound(src.loc, 'sound/items/Scissor.ogg', 30, 1)
		var/tempfloor = get_turf(src)
		for (var/obj/content in src.contents)
			content.set_loc(tempfloor)
		qdel(src)
		return
	else
		src.add_to_bouquet(W, user)

/obj/item/bouquet/attack_self(mob/user)
	. = ..()
	src.refresh()

/// attempts to add a flower or item to the bouquet, with error handling
/obj/item/bouquet/proc/add_to_bouquet(obj/item/W, mob/user)
	// first check plants (i.e. for roses)
	if (istype(W, /obj/item/plant))
		var/obj/item/plant/dummy = W
		if (!dummy.can_bouquet)
			boutput(user, "This can't be added into a bouquet!")
			return
		if (flowernum >= src.max_flowers)
			boutput(user, "This bouquet is full!")
			return
		src.add_flower(W, user)
	// most flowers are under this subtyping, so check this too
	else if (istype(W, /obj/item/clothing/head/flower))
		var/obj/item/clothing/head/flower/dummy_flower = W
		if (!dummy_flower.can_bouquet)
			boutput(user, "This can't be added into a bouquet!")
			return
		if (flowernum >= src.max_flowers)
			boutput(user, "This bouquet is full!")
			return
		src.add_flower(W, user)
	// if its not a flower we know of, try to hide an item inside
	else if (hiddenitem) // only one hidden item allowed
		boutput("This bouquet already has something hidden in it!")
		return
	else if (W.w_class > W_CLASS_SMALL) // item too big
		boutput("That won't fit!")
		return
	else // successfully hide item
		src.flags |= SUPPRESSATTACK
		W.set_loc(src)
		src.hiddenitem = TRUE

/obj/item/bouquet/proc/add_flower(obj/item/W, mob/user)
	src.flags |= SUPPRESSATTACK
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
	var/list/flower1 = null
	var/list/flower2 = null
	var/list/flower3 = null
	/// random appearance order for the flowers when shuffling them
	var/list/frontflowerindex
	src.overlays = null
	src.inhand_image.overlays = null
	src.icon_state = "paper_back"
	src.inhand_image = image('icons/obj/items/bouquets.dmi', icon_state = "inhand_base_[src.wrapstyle]")
	for (var/obj/item/temp in src.contents)
		if (istype(temp, /obj/item/clothing/head/flower) || istype(temp, /obj/item/plant))
			// this spritename nonsense is necessary because icon states cant have spaces
			var/spritename = temp.name
			switch (temp.name) // future proofing
				if ("bird of paradise")
					spritename = "bop"
			if (isnull(flower1))
				flower1 = list(spritename, temp.name)
				continue
			else if (isnull(flower2))
				flower2 = list(spritename, temp.name)
				continue
			else if (isnull(flower3))
				flower3 = list(spritename, temp.name)
				continue
			else
				CRASH("More than 3 flowers in bouquet: [get_turf(src)]") // this shouldnt happen but eh
	// note for the overlays: for appearance reasons, the middle flowers must always go on last
	switch (src.flowernum)
		if (1)
			src.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "[flower1[1]]_m")
			src.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "[src.wrapstyle]_front")
			src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_[flower1[1]]_m")
			src.name = "[flower1[2]] bouquet"
			src.desc = "A [flower1[2]] in a nice wrapping. Try adding more flowers to it!"
		if (2)
			var/rightorleft = pick("r", "l")
			frontflowerindex = pick(list(flower1,flower2),list(flower2,flower1))
			src.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "[frontflowerindex[1][1]]_[rightorleft]")
			src.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "[frontflowerindex[2][1]]_m")
			src.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "[src.wrapstyle]_front")
			src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_[frontflowerindex[1][1]]_[rightorleft]")
			src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_[frontflowerindex[2][1]]_m")
			if (flower1[1] == flower2[1]) // say its a bouquet with a single type of flower
				src.name = "[flower1[2]] bouquet"
				src.desc = "A bouquet of beautiful flowers. This one contains [flower1[2]]."
			else
				src.name = "mixed bouquet"
				src.desc = "A bouquet of beautiful flowers. This one contains [flower2[2]] and [flower1[2]]."
		if (3)
			frontflowerindex = pick(
				list(flower1, flower2, flower3), list(flower2, flower1, flower3),\
				list(flower1, flower3, flower2), list(flower2, flower3, flower1),\
				list(flower3, flower1, flower2), list(flower3, flower2, flower1))
			src.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "[frontflowerindex[1][1]]_r")
			src.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "[frontflowerindex[2][1]]_l")
			src.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "[frontflowerindex[3][1]]_m")
			src.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "[src.wrapstyle]_front")
			src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_[frontflowerindex[1][1]]_r")
			src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_[frontflowerindex[2][1]]_l")
			src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_[frontflowerindex[3][1]]_m")
			// all match
			if ((flower1[1] == flower2[1]) && (flower2[1] == flower3[1]))
				src.name = "[flower1[2]] bouquet"
				src.desc = "A bouquet of beautiful flowers. This one contains [flower1[2]]."
			// two match
			else if ((flower1[1] == flower2[1]) || (flower2[1] == flower3[1]) || (flower1[1] == flower3[1]))
				var/doubledflower = "" // the name of flower that matches
				var/otherflower = "" // the name of the one that doesn't
				if (flower1[1] == flower2[1])
					doubledflower = flower1[2]
					otherflower = flower3[2]
				else if (flower1[1] == flower3[1])
					doubledflower = flower1[2]
					otherflower = flower2[2]
				else if (flower2[1] == flower3[1])
					doubledflower = flower2[2]
					otherflower = flower1[2]
				src.name = "mixed bouquet"
				src.desc = "A bouquet of beautiful flowers. This one contains [doubledflower] and [otherflower]."
			// all different
			else
				src.name = "mixed bouquet"
				src.desc = "A bouquet of beautiful flowers. This one contains [flower3[2]], [flower2[2]] and [flower1[2]]."
		if (4)
			CRASH("Bouquet at [get_turf(src)] somehow has 4 flowers in it")
	src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_[src.wrapstyle]_front")
	if (src.hiddenitem)
		src.desc += " There seems to be something else inside it as well."
	src.ruffle()

/// gently shakes the bouquet to indicate shuffling. mostly taken from hit_twitch()
/obj/item/bouquet/proc/ruffle()
	var/movepx = 0
	var/movepy = 0
	switch(pick(alldirs))
		if (NORTH)
			movepy = 3
		if (WEST)
			movepx = -3
		if (SOUTH)
			movepy = -3
		if (EAST)
			movepx = 3
		if (NORTHEAST)
			movepx = 2
			movepy = 2
		if (NORTHWEST)
			movepx = -2
			movepy = 2
			movepy = -2
		if (SOUTHEAST)
			movepx = 2
			movepy = -2
		if (SOUTHWEST)
			movepx = -2
			movepy = -2
		else
			return
	animate(src, pixel_x = movepx, pixel_y = movepy, time = 2, easing = EASE_IN, flags = ANIMATION_PARALLEL)
	animate(pixel_x = movepx, pixel_y = movepy, time = 2, easing = EASE_IN)
