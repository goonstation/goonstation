/datum/targetable/grinch/grinch_transform
	name = "Transform"
	desc = "Reveal your Grinchy self, this is permanant until you die."
	icon_state = "grinchcloak"  // No custom sprites yet.
	targeted = FALSE
	target_nodamage_check = FALSE
	max_range = 0
	cooldown = 90 SECONDS
	pointCost = 0
	when_stunned = TRUE
	not_when_handcuffed = FALSE
	grinch_only = FALSE

	cast(mob/target)
		if (!holder)
			return TRUE

		var/mob/living/M = holder.owner

		if (!M)
			return TRUE

		. = ..()
		actions.start(new/datum/action/bar/private/icon/grinch_transform(src), M)
		return FALSE

/datum/action/bar/private/icon/grinch_transform
	duration = 5 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ACTION
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"
	var/datum/targetable/grinch/grinch_transform/transform

	New(Transform)
		transform = Transform
		..()

	onStart()
		..()

		var/mob/living/carbon/human/M = owner

		if (M == null || !ishuman(M) || !isalive(M) || M.getStatusDuration("unconscious") || !transform)
			interrupt(INTERRUPT_ALWAYS)
			return

		M.visible_message(SPAN_ALERT("<b>[M].</b> is straining their whole body until they face goes red..."))

	onUpdate()
		..()

		var/mob/living/M = owner

		if (M == null || !ishuman(M) || !isalive(M) || M.getStatusDuration("unconscious") || !transform)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()

		var/mob/living/carbon/human/M = owner
		var/obj/effects/explosion/explo = /obj/effects/explosion/
		new explo (get_turf(M))
		M.set_mutantrace(/datum/mutantrace/grinch)
		M.unequip_all(throw_stuff=TRUE)

	onInterrupt()
		..()

		var/mob/living/M = owner
		boutput(M, SPAN_ALERT("Your transformation was interrupted!"))
		transform.last_cast = 0 //reset cooldown
