/obj/item/pen/blood_chalk
	name = "blood chalk"
	desc = "A stick of chalk that appears to be made from a waxy blood-like compound."
	icon_state = "chalk-9"
	color = "#FF0000"
	font_color = "#FF0000"
	color_name = "red"
	clicknoise = FALSE

/obj/item/pen/blood_chalk/write_on_turf(turf/T, mob/user, params)
	if (!T || !user || src.in_use || (BOUNDS_DIST(T, user) > 0))
		return

	if (!user.mind?.get_antagonist(ROLE_COVEN_VAMPIRE) && !isadmin(user))
		return

	actions.start(new /datum/action/bar/icon/draw_ritual_circle(T), user)





/datum/action/bar/icon/draw_ritual_circle
	icon = 'icons/obj/writing_animated_blood.dmi'
	icon_state = "Pentagram"
	duration = 10 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED | INTERRUPT_ACTION | INTERRUPT_ACT
	var/turf/turf = null

/datum/action/bar/icon/draw_ritual_circle/New(turf/turf)
	. = ..()
	src.turf = turf

/datum/action/bar/icon/draw_ritual_circle/onUpdate()
	. = ..()
	if (!istype(src.turf) || (BOUNDS_DIST(src.owner, src.turf) > 0))
		src.interrupt(INTERRUPT_ALWAYS)
		return

/datum/action/bar/icon/draw_ritual_circle/onStart()
	. = ..()
	if (!istype(src.turf) || (BOUNDS_DIST(src.owner, src.turf) > 0))
		src.interrupt(INTERRUPT_ALWAYS)
		return

	for (var/turf/T as anything in block(locate(src.turf.x - 1, src.turf.y - 1, src.turf.z), locate(src.turf.x + 1, src.turf.y + 1, src.turf.z)))
		if (locate(/obj/decal/cleanable/vampire_ritual_circle) in T)
			boutput(src.owner, SPAN_ALERT("There is already a ritual circle on this turf!"))
			src.interrupt(INTERRUPT_ALWAYS)
			return

	src.owner.visible_message(SPAN_NOTICE("[src.owner] starts drawing a ritual circle!"))
	src.play_drawing_sound()

/datum/action/bar/icon/draw_ritual_circle/onEnd()
	. = ..()
	if (!istype(src.turf) || (BOUNDS_DIST(src.owner, src.turf) > 0))
		src.interrupt(INTERRUPT_ALWAYS)
		return

	src.owner.visible_message(SPAN_NOTICE("[src.owner] finishes drawing a ritual circle!"))
	new /obj/decal/cleanable/vampire_ritual_circle(src.turf)

/datum/action/bar/icon/draw_ritual_circle/proc/play_drawing_sound()
	if (src.state != ACTIONSTATE_RUNNING)
		return

	var/sound = pick('sound/effects/chalk1.ogg', 'sound/effects/chalk2.ogg', 'sound/effects/chalk3.ogg')
	playsound(src.turf, sound, 50, TRUE, 0.3)

	SPAWN(rand(20, 30))
		src.play_drawing_sound()
