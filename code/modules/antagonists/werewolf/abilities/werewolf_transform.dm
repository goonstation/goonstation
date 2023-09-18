/datum/targetable/werewolf/werewolf_transform
	name = "Transform"
	desc = "Switch between human and wolf form, Takes a couple seconds to complete."
	icon_state = "transform"
	cooldown = 90 SECONDS
	incapacitation_restriction = ABILITY_CAN_USE_WHEN_STUNNED
	can_cast_while_cuffed = TRUE

	cast(mob/target)
		. = ..()
		actions.start(new/datum/action/bar/private/icon/werewolf_transform(src), src.holder.owner)

/datum/action/bar/private/icon/werewolf_transform
	duration = 5 SECONDS
	interrupt_flags = INTERRUPT_ACT | INTERRUPT_ACTION
	id = "werewolf_transform"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"
	var/datum/targetable/werewolf/werewolf_transform/transform

	New(Transform)
		transform = Transform
		..()

	onStart()
		. = ..()

		var/mob/living/M = src.owner

		if (M == null || !ishuman(M) || !isalive(M) || M.getStatusDuration("paralysis") || !transform)
			interrupt(INTERRUPT_ALWAYS)
			return

		boutput(M, "<span class='alert'><B>You feel a strong burning sensation all over your body!</B></span>")

	onUpdate()
		..()
		var/mob/living/M = owner

		if (M == null || !ishuman(M) || !isalive(M) || M.getStatusDuration("paralysis") || !transform)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		. = ..()
		var/mob/living/M = owner
		M.werewolf_transform()

	onInterrupt()
		. = ..()
		var/mob/living/M = owner
		boutput(M, "<span class='alert'>Your transformation was interrupted!</span>")
		src.transform.resetCooldown()
