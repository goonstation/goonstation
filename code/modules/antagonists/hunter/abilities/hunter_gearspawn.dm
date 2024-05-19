/datum/targetable/hunter/hunter_gearspawn
	name = "Order hunting gear"
	desc = "Equip your hunting gear."
	icon_state = "gearspawn"
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 0
	pointCost = 0
	when_stunned = 1
	not_when_handcuffed = 0
	hunter_only = 0

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M || !ishuman(M))
			return 1

		. = ..()
		actions.start(new/datum/action/bar/private/icon/hunter_transform(src), M)
		return 0

/datum/action/bar/private/icon/hunter_transform
	duration = 50
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ACTION
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"
	var/datum/targetable/hunter/hunter_gearspawn/transform

	New(Transform)
		transform = Transform
		..()

	onStart()
		..()

		var/mob/living/M = owner

		if (M == null || !ishuman(M) || !isalive(M) || M.getStatusDuration("unconscious") > 0 || !transform)
			interrupt(INTERRUPT_ALWAYS)
			return

		boutput(M, SPAN_ALERT("<B>Request acknowledged. You must stand still.</B>"))

	onUpdate()
		..()

		var/mob/living/M = owner

		if (M == null || !ishuman(M) || !isalive(M) || M.getStatusDuration("unconscious") > 0 || !transform)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()

		var/mob/living/carbon/human/M = owner
		M.hunter_transform()

	onInterrupt()
		..()

		var/mob/living/M = owner
		boutput(M, SPAN_ALERT("You were interrupted!"))
