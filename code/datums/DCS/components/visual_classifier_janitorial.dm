#define CLASSIFIER_PEST "PEST"
#define CLASSIFIER_SPILL "SPILL"
#define CLASSIFIER_MESS "MESS"

/datum/component/visual_classifier/janitorial
	display_name = "RAT//SCAN"
	boot_duration = 3 SECONDS
	boot_banner_type = /atom/movable/screen/classifier_boot
	boot_sound = 'sound/items/ratscan_startup.ogg'
	priority_category = CLASSIFIER_PEST
	category_types = list(
		CLASSIFIER_MESS = list(/obj/decal/cleanable),
		CLASSIFIER_PEST = list(
			/mob/living/critter/small_animal,
			/mob/living/critter/spider,
			/mob/living/critter/wraith/plaguerat,
			/obj/critter/bat,
			/obj/critter/raccoon,
			/obj/critter/crow,
			/obj/critter/seagull,
			/obj/critter/fake_bee,
		),
		CLASSIFIER_SPILL = list(/obj/fluid, /obj/decal/cleanable/water),
	)
	filter_order = list(CLASSIFIER_MESS, CLASSIFIER_SPILL, CLASSIFIER_PEST)
	projection_types = list(
		CLASSIFIER_MESS = /obj/overlay/classifier_projection,
		CLASSIFIER_SPILL = /obj/overlay/classifier_projection,
		CLASSIFIER_PEST = /obj/overlay/classifier_projection/pest,
	)
	category_colors = list(CLASSIFIER_MESS = "#d1ff47", CLASSIFIER_SPILL = "#4df5ff", CLASSIFIER_PEST = "#ff269d")
	excluded_types = list(
		/mob/living/critter/small_animal/cat,
		/mob/living/critter/small_animal/dog,
		/mob/living/critter/small_animal/ranch_base,
		/mob/living/critter/small_animal/bee,
		/mob/living/critter/small_animal/boogiebot,
		/mob/living/critter/small_animal/plush,
		/mob/living/critter/small_animal/figure,
	)
	flavor_labels = list(
		/mob/living/critter/small_animal/cockroach = "TENANT",
		/obj/decal/cleanable/blood = "EVIDENCE",
	)
	var/mentor_mouse_label = "FRIEND"
	var/admin_mouse_label = "HAZARD"
	var/admin_mouse_glitch_chance = 100

	caption_for(atom/movable/target, category)
		var/mob/living/critter/small_animal/mouse/weak/mentor/mouse = target
		if (istype(mouse))
			return mouse.is_admin ? src.admin_mouse_label : src.mentor_mouse_label
		return ..()

	glitch_chance_for(atom/movable/target)
		var/mob/living/critter/small_animal/mouse/weak/mentor/mouse = target
		if (istype(mouse) && mouse.is_admin)
			return src.admin_mouse_glitch_chance
		return ..()

#undef CLASSIFIER_MESS
#undef CLASSIFIER_PEST
#undef CLASSIFIER_SPILL

/obj/overlay/classifier_projection
	name = "projected classifier callout"
	icon = null
	mouse_opacity = 0
	var/duration = 0
	var/datum/component/visual_classifier/scanner
	var/atom/movable/subject

	New(loc, datum/component/visual_classifier/scanner, atom/movable/subject)
		. = ..()
		if (!scanner || !subject)
			qdel(src)
			return
		src.scanner = scanner
		src.subject = subject
		subject.vis_contents += src
		src.RegisterSignal(subject, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(expire))
		if (src.duration > 0)
			SPAWN(src.duration)
				if (!QDELETED(src))
					src.expire()

	proc/expire()
		if (src.scanner?.projection == src)
			src.scanner.set_filter(src.scanner.filter_class)

	disposing()
		if (src.subject)
			src.UnregisterSignal(src.subject, COMSIG_PARENT_PRE_DISPOSING)
			src.subject.vis_contents -= src
			src.subject = null
		if (src.scanner?.projection == src)
			src.scanner.projection = null
		src.scanner = null
		. = ..()

/obj/overlay/classifier_projection/pest
	duration = 10 SECONDS
