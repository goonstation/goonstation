/obj/item/clothing/glasses/classifier
	name = "RAT//SCAN janitorial visor"
	desc = "A janitorial visor with a milspec threat display and a dedicated pest-tracking coprocessor. The lenses are synthetic sapphire. The little box it draws around a mouse is pink."
	icon = 'icons/obj/clothing/classifier_glasses.dmi'
	icon_state = "visor"
	wear_image_icon = 'icons/mob/clothing/classifier_glasses.dmi'
	inhand_image_icon = 'icons/mob/clothing/classifier_glasses.dmi'
	item_state = "visor"
	var/datum/component/visual_classifier/classifier
	var/classifier_type = /datum/component/visual_classifier/janitorial

	New()
		. = ..()
		src.RegisterSignal(src, COMSIG_COMPONENT_ADDED, PROC_REF(bind_classifier))
		src.RegisterSignal(src, COMSIG_COMPONENT_REMOVING, PROC_REF(unbind_classifier))
		src.AddComponent(src.classifier_type)

	proc/bind_classifier(datum/source, datum/component/visual_classifier/scanner)
		if (!src.classifier && istype(scanner, src.classifier_type))
			src.classifier = scanner

	proc/unbind_classifier(datum/source, datum/component/scanner)
		if (scanner == src.classifier)
			src.classifier = null

/atom/movable/screen/classifier_boot
	name = "RAT//SCAN boot screen"
	icon = 'icons/effects/classifier_boot.dmi'
	icon_state = "boot"
	screen_loc = "CENTER-2,CENTER:-9"
	plane = PLANE_ABOVE_HUD
	layer = HUD_LAYER_3
	appearance_flags = PIXEL_SCALE | TILE_BOUND
	mouse_opacity = 0
