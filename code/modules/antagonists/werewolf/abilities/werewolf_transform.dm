/datum/targetable/werewolf/werewolf_transform
	name = "Transform"
	desc = "Switch between human and wolf form, Takes a couple seconds to complete."
	icon_state = "transform"  // No custom sprites yet.
	targeted = FALSE
	target_nodamage_check = FALSE
	max_range = 0
	cooldown = 90 SECONDS
	pointCost = 0
	when_stunned = TRUE
	not_when_handcuffed = FALSE
	werewolf_only = FALSE

	cast(mob/target)
		if (!holder)
			return TRUE

		var/mob/living/M = holder.owner

		if (!M)
			return TRUE

		actions.start(new/datum/action/bar/private/icon/werewolf_transform(src), M)
		return FALSE

/datum/action/bar/private/icon/werewolf_transform
	duration = 5 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ACTION
	id = "werewolf_transform"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"
	var/datum/targetable/werewolf/werewolf_transform/transform

	New(Transform)
		transform = Transform
		..()

	onStart()
		..()

		var/mob/living/M = owner

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
		..()

		var/mob/living/M = owner
		M.werewolf_transform()

	onInterrupt()
		..()

		var/mob/living/M = owner
		boutput(M, "<span class='alert'>Your transformation was interrupted!</span>")
		transform.last_cast = 0 //reset cooldown
