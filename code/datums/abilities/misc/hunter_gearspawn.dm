/datum/targetable/hunter/hunter_gearspawn
	name = "Order hunting gear"
	desc = "Equip your hunting gear."
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

		actions.start(new/datum/action/bar/private/icon/hunter_transform(src), M)
		return 0

/datum/action/bar/private/icon/hunter_transform
	duration = 50
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ACTION
	id = "hunter_transform"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"
	var/datum/targetable/hunter/hunter_gearspawn/transform

	New(Transform)
		transform = Transform
		..()

	onStart()
		..()

		var/mob/living/M = owner

		if (M == null || !ishuman(M) || !isalive(M) || M.getStatusDuration("paralysis") > 0 || !transform)
			interrupt(INTERRUPT_ALWAYS)
			return

		boutput(M, "<span class='alert'><B>Request acknowledged. You must stand still.</B></span>")

	onUpdate()
		..()

		var/mob/living/M = owner

		if (M == null || !ishuman(M) || !isalive(M) || M.getStatusDuration("paralysis") > 0 || !transform)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()

		var/mob/living/carbon/human/M = owner
		var/datum/abilityHolder/H = transform.holder

		if (M.hunter_transform() != 1)
			boutput(M, "<span class='alert'>Gearspawn failed. Make sure you're a human and try again later.</span>")
		else
			H.removeAbility(/datum/targetable/hunter/hunter_gearspawn)

	onInterrupt()
		..()

		var/mob/living/M = owner
		boutput(M, "<span class='alert'>You were interrupted!</span>")
