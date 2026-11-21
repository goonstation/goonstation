/obj/item/clothing/glasses/classifier
	name = "RAT//SCAN janitorial visor"
	desc = "desc = "A janitorial visor with a milspec threat display and a dedicated pest-tracking coprocessor. The lenses are synthetic sapphire. The little box it draws around a mouse is pink."
	icon = 'icons/obj/clothing/classifier_glasses.dmi'
	icon_state = "visor"
	wear_image_icon = 'icons/mob/clothing/classifier_glasses.dmi'
	inhand_image_icon = 'icons/mob/clothing/classifier_glasses.dmi'
	item_state = "visor"
	abilities = list(/obj/ability_button/classifier_power, /obj/ability_button/classifier_focus, /obj/ability_button/classifier_filter)
	var/datum/component/visual_classifier/classifier
	var/classifier_type = /datum/component/visual_classifier/janitorial

	New()
		. = ..()
		src.RegisterSignal(src, COMSIG_COMPONENT_ADDED, PROC_REF(bind_classifier))
		src.RegisterSignal(src, COMSIG_COMPONENT_REMOVING, PROC_REF(unbind_classifier))
		src.AddComponent(src.classifier_type, SLOT_GLASSES)

	proc/bind_classifier(datum/source, datum/component/visual_classifier/scanner)
		if (!src.classifier && istype(scanner, src.classifier_type))
			src.classifier = scanner
			src.RegisterSignal(scanner, COMSIG_CLASSIFIER_CHANGED, PROC_REF(update_controls))
			src.update_controls(scanner)

	proc/unbind_classifier(datum/source, datum/component/scanner)
		if (scanner == src.classifier)
			src.UnregisterSignal(scanner, COMSIG_CLASSIFIER_CHANGED)
			src.classifier = null

	proc/update_controls(datum/component/visual_classifier/scanner, cancel_targeting)
		var/obj/ability_button/classifier_power/power = locate() in src.ability_buttons
		power?.set_icon_state(scanner.enabled ? "survey" : "standby")
		var/obj/ability_button/classifier_focus/focus = locate() in src.ability_buttons
		focus?.set_icon_state(scanner.focused_target ? "locked" : "focus")
		var/obj/ability_button/classifier_filter/filter = locate() in src.ability_buttons
		var/static/list/filter_icons = list("MESS" = "filter_mess", "SPILL" = "filter_spill", "PEST" = "filter_pest")
		filter?.set_icon_state(filter_icons[scanner.filter_class] || "filter_all")
		if (cancel_targeting && focus && scanner.wearer?.targeting_ability == focus)
			scanner.wearer.targeting_ability = null
			scanner.wearer.update_cursor()

/atom/movable/screen/classifier_boot
	name = "RAT//SCAN boot screen"
	icon = 'icons/effects/classifier_boot.dmi'
	icon_state = "boot"
	screen_loc = "CENTER-2,CENTER:-9"
	plane = PLANE_ABOVE_HUD
	layer = HUD_LAYER_3
	appearance_flags = PIXEL_SCALE | TILE_BOUND
	mouse_opacity = 0

/obj/ability_button/classifier_power
	name = "Toggle Survey"
	desc = "Run RAT//SCAN or put it on standby. Your eyeballs will be fine, probably."
	icon = 'icons/obj/clothing/classifier_glasses.dmi'
	icon_state = "survey"
	requires_equip = TRUE

	execute_ability()
		var/obj/item/clothing/glasses/classifier/visor = src.the_item
		if (visor?.classifier?.wearer == src.the_mob)
			visor.classifier.set_power(!visor.classifier.enabled)
			if (visor.classifier.enabled)
				boutput(src.the_mob, SPAN_NOTICE("RAT//SCAN online. Blink to accept the terms of service."))
			else
				boutput(src.the_mob, SPAN_NOTICE("RAT//SCAN on standby. Eyeballs restored to factory settings."))
		return ..()

/obj/ability_button/classifier_focus
	name = "Focus Classifier"
	desc = "Project a public marker on a mess, spill, or pest and highlight its class in your visor. Click again to dismiss it."
	icon = 'icons/obj/clothing/classifier_glasses.dmi'
	icon_state = "focus"
	requires_equip = TRUE
	targeted = TRUE
	target_anything = TRUE

	RawClick()
		var/obj/item/clothing/glasses/classifier/visor = src.the_item
		if (!visor?.classifier?.enabled)
			src.the_mob?.show_text("RAT//SCAN is on standby. Toggle Survey to wake it up.", "red")
			return
		if (visor.classifier.focused_target && src.ability_allowed())
			visor.classifier.set_filter(null)
			visor.classifier.refresh_callouts()
			return
		return ..()

	execute_ability(atom/target, params)
		var/obj/item/clothing/glasses/classifier/visor = src.the_item
		if (visor?.classifier?.wearer == src.the_mob)
			visor.classifier.focus_on(target)
		return ..()

/obj/ability_button/classifier_filter
	name = "Filter Class"
	desc = "Cycle between all cleanup targets, messes, spills, and pests."
	icon = 'icons/obj/clothing/classifier_glasses.dmi'
	icon_state = "filter_all"
	requires_equip = TRUE

	execute_ability()
		var/obj/item/clothing/glasses/classifier/visor = src.the_item
		if (!visor?.classifier?.enabled)
			src.the_mob?.show_text("RAT//SCAN is on standby. Toggle Survey to wake it up.", "red")
			return
		visor.classifier.cycle_filter(src.the_mob)
		return ..()
