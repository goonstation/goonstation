//////////////////////////
//Submerged overlay (MOB)/
//////////////////////////

//Ok, so what happens here is
//Every mob has a list of overlays for being submerged
//When the mob is created / changes their clothing, this list is updated. (This part does some icon blend operations so we wanna keep those down!)
//The submerged_images list is built by blending different submerged height graphics with the mob's clothing + body icons
//lastly we use show_submerged_image() as the mob enters and exits fluid tiles to add/remove a submerged image from the mob's overlays.
//Hopefully this operation (adding/removing overlays) isn't too costly - it doesn't seem like it is that bad so far? otherwise I can do the lame old pool overlays i guess


/mob/var/tmp/list/submerged_images = list()
/mob/var/tmp/is_submerged = 0

/mob/living/New()
	..()
	src.create_submerged_images()

//nah, i dont care anemore
///mob/living/carbon/human/update_clothing()
//	if ( clothing_dirty & (C_SUIT|C_BACK|C_HEAD) )
//		SPAWN(0) src.create_submerged_images()
//	..()


/mob/living/proc/create_submerged_images()
	submerged_images.len = 0
	for(var/i = 1, i <= 4, i++)
		var/icon/I = new /icon('icons/obj/fluid.dmi', "overlay_[i]")
		I.Blend(new /icon(src.icon, src.icon_state),ICON_MULTIPLY)

		var/image/submerged_image = image(I)
		submerged_image.layer = src.layer + 1
		submerged_image.appearance_flags = RESET_COLOR | PIXEL_SCALE
		submerged_image.icon = I
		submerged_image.blend_mode = BLEND_MULTIPLY
		submerged_images += submerged_image

/mob/living/carbon/human/create_submerged_images()
	submerged_images.len = 0

	var/mutable_appearance/ma

	for(var/i = 1, i <= 4, i++)
		var/icon/I = new /icon('icons/obj/fluid.dmi', "overlay_[i]")
		var/icon/body = new /icon('icons/mob/human.dmi', "submerged_fill")

		if (src.wear_suit)
			body.Blend(src.wear_suit.wear_image.icon,ICON_OVERLAY)
		if (src.back)
			body.Blend(src.back.wear_image.icon,ICON_OVERLAY)
		if (src.head)
			body.Blend(src.head.wear_image.icon,ICON_OVERLAY)

		I.Blend(body, ICON_MULTIPLY)

		var/image/submerged_image = image(I)
		ma = new(submerged_image)
		ma.layer = src.layer + 0.1
		ma.appearance_flags = RESET_COLOR | PIXEL_SCALE
		ma.icon = I
		ma.blend_mode = BLEND_MULTIPLY
		submerged_image.appearance = ma
		submerged_images += submerged_image



/mob/living/proc/show_submerged_image(var/depth) //depth from 0 - 4
	if (!submerged_images.len) return
	if (src.is_submerged == depth) return
	depth = min(depth,submerged_images.len)
	depth = max(0,depth)
	if (depth)
		//if (src.is_submerged)
		//	src.ClearSpecificOverlays("submerged_image")
		src.UpdateOverlays(submerged_images[depth], "submerged_image")
	else
		src.ClearSpecificOverlays("submerged_image")

	src.is_submerged = depth

/obj/var/tmp/list/submerged_images = 0
/obj/var/tmp/is_submerged = 0

//submachine - i cant find the parents for these. just define here ok
/obj/submachine/flags = FPRINT | FLUID_SUBMERGE


/obj/New()
	..()
	if (IS_VALID_SUBMERGE_OBJ(src))
		if (src.density)
			submerged_images = list()
			src.create_submerged_images()

/obj/proc/create_submerged_images()
	submerged_images.len = 0

	var/mutable_appearance/ma

	for(var/i = 1, i <= 4, i++)
		var/icon/I = new /icon('icons/obj/fluid.dmi', "overlay_[i]")
		I.Blend(new /icon(src.icon, src.icon_state),ICON_MULTIPLY)

		var/image/submerged_image = image(I)
		ma = new(submerged_image)
		ma.layer = src.layer + 1
		ma.appearance_flags = RESET_COLOR | PIXEL_SCALE
		ma.icon = I
		ma.blend_mode = BLEND_MULTIPLY
		submerged_image.appearance = ma
		submerged_images += submerged_image

/obj/proc/show_submerged_image(var/depth) //depth from 0 - 4
	if (depth == 1) depth = 0
	if (!submerged_images || !length(submerged_images)) return
	if (src.is_submerged == depth) return

	if (depth)
		//if (src.is_submerged)
		//	src.ClearSpecificOverlays("submerged_image")
		src.UpdateOverlays(submerged_images[depth], "submerged_image")
	else
		src.ClearSpecificOverlays("submerged_image")

	src.is_submerged = depth
