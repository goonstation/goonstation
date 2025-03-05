// note: bouquets work hand in hand with the bouquet component attached to flowers.
// accessible at 'code/datums/components/bouquet.dm'
// instructions on how to add new flowers are there

/obj/item/bouquet
	name = "bouquet"
	desc = "A lovely arrangement of flowers."
	icon = 'icons/obj/items/bouquets.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_bouquet.dmi'
	icon_state = "paper_back"
	item_state = "bouquet"
	w_class = W_CLASS_SMALL
	flags = SUPPRESSATTACK | TABLEPASS
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
	if (isnull(W))
		return
	if (W.w_class > W_CLASS_SMALL) // item too big
		boutput(user, SPAN_ALERT("That won't fit!"))
		return
	if (issnippingtool(W))// should give us back the paper and flowers when done with snipping tool
		boutput(user, SPAN_NOTICE("You disassemble the [src]."))
		playsound(src.loc, 'sound/items/Scissor.ogg', 30, 1)
		for (var/obj/content in src.contents)
			content.set_loc(get_turf(src))
		qdel(src)
		return
	if (W in src.contents)
		return // a flower may be put in before afterattack is called
	// try to hide an item inside
	if (hiddenitem) // only one hidden item allowed
		boutput(user, SPAN_NOTICE("This bouquet already has something hidden in it!"))
		return
	// successfully hide item
	SPAWN(1 DECI SECOND)
		user.u_equip(W)
		W.set_loc(src)
		src.hiddenitem = TRUE
		boutput(user, SPAN_NOTICE("You stuff \the [W.name] into \the [src.name]."))

/obj/item/bouquet/attack_self(mob/user)
	. = ..()
	src.refresh()
	src.ruffle()

/obj/item/bouquet/update_inhand(hand, hand_offset)
	. = ..()
	src.inhand_image.underlays = list(image(src.inhand_image_icon, "flower-[hand]"))


/obj/item/bouquet/proc/add_flower(obj/item/W, mob/user)
	W.force_drop(user)
	src.force_drop(user)
	W.set_loc(src)
	user.visible_message("[user] adds \the [W.name] to the bouquet.", "You add \the [W.name] to the bouquet.")
	src.flowernum += 1
	src.refresh()
	user.put_in_hand_or_drop(src)
	src.ruffle()

/obj/item/bouquet/proc/refresh()
	// overlays is for the icon, inhand_image is for, well, the inhand
	// updating the icon also randomises the order (non negotiable)
	// we'll also do the name and desc here because why not
	var/obj/item/flower1 = null
	var/obj/item/flower2 = null
	var/obj/item/flower3 = null
	/// random appearance order for the flowers when shuffling them
	var/list/frontflowerindex
	//src.inhand_image.overlays = null
	src.icon_state = "[src.wrapstyle]_back"
	src.item_state = "[src.wrapstyle]"
	//src.inhand_image = image('icons/obj/items/bouquets.dmi', icon_state = "inhand_base_[src.wrapstyle]")
	for (var/obj/item/temp in src.contents)
		if (istype(temp, /obj/item/clothing/head/flower) || istype(temp, /obj/item/plant))
			// this spritename nonsense is necessary because icon states cant have spaces
			if (isnull(flower1))
				flower1 = temp
				continue
			else if (isnull(flower2))
				flower2 = temp
				continue
			else if (isnull(flower3))
				flower3 = temp
				continue
			else
				CRASH("More than 3 flowers in bouquet: [get_turf(src)]") // this shouldnt happen but eh
	// note for the overlays: for appearance reasons, the middle flowers must always go on last
	switch (src.flowernum)
		if (1)
			UpdateOverlays(image('icons/obj/items/bouquets.dmi', icon_state = "[flower1.icon_state]_m"),"flower1")
			//src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_[flower1.icon_state]_m")
			src.name = "[flower1.name] bouquet"
			src.desc = "\A [flower1.name] in a nice wrapping. Try adding more flowers to it!"
		if (2)
			var/rightorleft = pick("r", "l")
			frontflowerindex = pick(list(flower1,flower2),list(flower2,flower1))
			var/counter = 0
			for (var/obj/item/flower in frontflowerindex)
				if (counter == 0)
					UpdateOverlays(image('icons/obj/items/bouquets.dmi', icon_state = "[flower.icon_state]_[rightorleft]"),"flower1")
					//src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_[flower.icon_state]_[rightorleft]")
				else
					UpdateOverlays(image('icons/obj/items/bouquets.dmi', icon_state = "[flower.icon_state]_m"), "flower2")
					//src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_[flower.icon_state]_m")
				counter += 1

			if (flower1 == flower2) // say its a bouquet with a single type of flower
				src.name = "[flower1.name] bouquet"
				src.desc = "A bouquet of beautiful flowers. This one contains [flower1.name]\s."
			else
				src.name = "mixed bouquet"
				src.desc = "A bouquet of beautiful flowers. This one contains [flower2.name]\s and [flower1.name]\s."
		if (3)
			frontflowerindex = pick(
				list(flower1, flower2, flower3), list(flower2, flower1, flower3),\
				list(flower1, flower3, flower2), list(flower2, flower3, flower1),\
				list(flower3, flower1, flower2), list(flower3, flower2, flower1))
			var/counter = 0
			for (var/obj/item/flower in frontflowerindex)
				if (counter == 0)
					UpdateOverlays(image('icons/obj/items/bouquets.dmi', icon_state = "[flower.icon_state]_r"), "flower1")
					//src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_[flower.icon_state]_r")
				else if (counter == 1)
					UpdateOverlays(image('icons/obj/items/bouquets.dmi', icon_state = "[flower.icon_state]_l"), "flower2")
					//src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_[flower.icon_state]_l")
				else
					UpdateOverlays(image('icons/obj/items/bouquets.dmi', icon_state = "[flower.icon_state]_m"), "flower3")
					//src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_[flower.icon_state]_m")
				counter += 1

			// all match
			if ((flower1.icon_state == flower2.icon_state) && (flower2.icon_state == flower3.icon_state))
				src.name = "[flower1.name] bouquet"
				src.desc = "A bouquet of beautiful flowers. This one contains [flower1.name]\s."
			// two match
			else if ((flower1.icon_state == flower2.icon_state) || (flower2.icon_state == flower3.icon_state) || (flower1.icon_state == flower3.icon_state))
				var/doubledflower = "" // the name of flower that matches
				var/otherflower = "" // the name of the one that doesn't
				if (flower1.icon_state == flower2.icon_state)
					doubledflower = flower1.name
					otherflower = flower3.name
				else if (flower1.icon_state == flower3.icon_state)
					doubledflower = flower1.name
					otherflower = flower2.name
				else if (flower2.icon_state == flower3.icon_state)
					doubledflower = flower2.name
					otherflower = flower1.name
				src.name = "mixed bouquet"
				src.desc = "A bouquet of beautiful flowers. This one contains [doubledflower]\s and [otherflower]\s."
			// all different
			else
				src.name = "mixed bouquet"
				src.desc = "A bouquet of beautiful flowers. This one contains [flower3.name]\s, [flower2.name]\s and [flower1.name]\s."
		if (4)
			CRASH("Bouquet at [get_turf(src)] somehow has 4 flowers in it")
	UpdateOverlays(image('icons/obj/items/bouquets.dmi', icon_state = "[src.wrapstyle]_front"), "wrap")
	//src.inhand_image.overlays += image('icons/obj/items/bouquets.dmi', icon_state = "inhand_[src.wrapstyle]_front")
	if (src.hiddenitem)
		src.desc += " There seems to be something else inside it as well."

/// gently shakes the bouquet to indicate shuffling. mostly taken from hit_twitch()
/obj/item/bouquet/proc/ruffle()
	if (ON_COOLDOWN(src, "ruffle", 4 DECI SECONDS))
		return
	var/movepx
	var/movepy
	var/matrix/M1 = src.transform
	var/matrix/M2 = src.transform
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
		if (SOUTHEAST)
			movepx = 2
			movepy = -2
		if (SOUTHWEST)
			movepx = -2
			movepy = -2
		else
			return

	M1.Translate(movepx, movepy)

	animate(src, transform = M1, time = 2 DECI SECONDS, easing = EASE_IN, flags = ANIMATION_PARALLEL)
	animate(transform = M2, time = 2 DECI SECONDS, easing = EASE_IN)

// pre prepared ones, for mapping
// this one shouldn't be used btw
/obj/item/bouquet/premade
	flowernum = 3
	var/flowertype = null
	wrapstyle = "paper"
	New()
		. = ..()
		for (var/i in 1 to 3)
			new flowertype(src)
		src.refresh()

/obj/item/bouquet/premade/rose
	flowertype = /obj/item/plant/flower/rose

/obj/item/bouquet/premade/rose/holo
	flowertype = /obj/item/plant/flower/rose/holorose

/obj/item/bouquet/premade/lavender
	flowertype = /obj/item/clothing/head/flower/lavender

/obj/item/bouquet/premade/bird_of_paradise
	flowertype = /obj/item/clothing/head/flower/bird_of_paradise

/obj/item/bouquet/premade/gardenia
	flowertype = /obj/item/clothing/head/flower/gardenia

/obj/item/bouquet/premade/hydrangea
	flowertype = /obj/item/clothing/head/flower/hydrangea

/obj/item/bouquet/premade/hydrangea/blue
	flowertype = /obj/item/clothing/head/flower/hydrangea/blue

/obj/item/bouquet/premade/hydrangea/pink
	flowertype = /obj/item/clothing/head/flower/hydrangea/pink

/obj/item/bouquet/premade/hydrangea/purple
	flowertype = /obj/item/clothing/head/flower/hydrangea/purple

/obj/item/bouquet/premade/poppy
	flowertype = /obj/item/plant/herb/poppy

/obj/item/bouquet/premade/wheat
	flowertype = /obj/item/plant/wheat

/obj/item/bouquet/premade/wheat/metal
	flowertype = /obj/item/plant/wheat/metal

/obj/item/bouquet/premade/oat
	flowertype = /obj/item/plant/oat

/obj/item/bouquet/premade/oat/salt
	flowertype = /obj/item/plant/oat/salt

/obj/item/bouquet/premade/catnip
	flowertype = /obj/item/plant/herb/catnip

/obj/item/bouquet/premade/grass
	flowertype = /obj/item/plant/herb/grass
