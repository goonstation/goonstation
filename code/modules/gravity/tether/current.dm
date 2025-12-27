TYPEINFO(/obj/machinery/gravity_tether/current_area)
	mats = list("metal" = 30,
				"crystal_dense" = 10,
				"metal_superdense" = 10,
				"energy_extreme" = 5,
				)
/obj/machinery/gravity_tether/current_area
	name = "local-area gravity tether"
	// TODO: Power balancing, UX
	passive_wattage_per_g = 10 WATTS
	intensity = 0
	target_intensity = 0
	anchored = UNANCHORED
	always_slow_pull = TRUE
	p_class = 10

/obj/machinery/gravity_tether/current_area/New()
	. = ..()
	src.desc += " This one covers a small area."

/obj/machinery/gravity_tether/current_area/attempt_gravity_change(new_intensity)
	var/area/A = get_area(src)
	if (!A || !A.area_apc)
		return FALSE
	// lockdown on attempting gravity change
	if (src.intensity == 0 && new_intensity > 0)
		src.activate(A)
	. = ..()
	// but if we fail to start the gravity, unlock
	if (!src.changing_gravity)
		src.deactivate(A)

/obj/machinery/gravity_tether/current_area/attackby(obj/item/I, mob/user)
	var/duration = 10 SECONDS
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
			duration = duration / 2
	if (src.is_broken() && ispulsingtool(I))
		SETUP_GENERIC_ACTIONBAR_WIDE(user, src, duration, /obj/machinery/gravity_tether/proc/reset_broken, list(I, user), \
		I.icon, I.icon_state, null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION)
		return
	. = ..()

/obj/machinery/gravity_tether/current_area/shake_affected()
	var/area/A = get_area(src)
	for (var/mob/M in A)
		if (M.client)
			shake_camera(M, 5, 32, 0.2)

/obj/machinery/gravity_tether/current_area/change_intensity(new_intensity)
	. = ..()
	if (.)
		return .
	var/area/A = get_area(src)
	if (src.intensity > 0)
		src.activate(A)
	else
		src.deactivate(A)

/obj/machinery/gravity_tether/current_area/proc/activate(area/A)
	src.anchored = ANCHORED_ALWAYS
	src.target_area_refs = list(A)
	A.register_tether(src)

/obj/machinery/gravity_tether/current_area/proc/deactivate(area/A)
	for (var/area/target_area in src.target_area_refs)
		target_area.unregister_tether(src)
	src.target_area_refs = list()

/obj/machinery/gravity_tether/proc/reset_broken(obj/item/I, mob/user)
	src.set_fixed()
