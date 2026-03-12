/datum/action/bar/hpd_exemption_failure
	var/atom/target
	var/mob/user
	var/obj/item/places_pipes/placer
	duration = 20 SECONDS

	New(atom/target, mob/user, obj/item/places_pipes/placer)
		..()
		src.target = target
		src.user = user
		src.placer = placer
		src.interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED | INTERRUPT_ACTION

	onEnd()
		..()
		boutput(user, SPAN_ALERT("The [src.placer] tries really hard, just EXTREMELY hard to remove \the [src.target], but it gives up with a sad little sigh."))
		playsound(src.placer, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		interrupt(INTERRUPT_ALWAYS)

