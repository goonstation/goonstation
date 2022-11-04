/datum/targetable/brain_slug/devolve
	name = "Devolve"
	desc = "Return to a lesser form."
	icon_state = "slimeshot"
	cooldown = 300 SECONDS
	targeted = 0
	start_on_cooldown = TRUE

	cast()
		if (!istype(holder.owner.loc, /turf))
			boutput(holder.owner, "<span class='notice'>You cannot do this here!</span>")
		var/choice = tgui_alert(holder.owner, "Are you sure you wish to devolve?", "Evolution", list("Yes", "No"))
		if (!choice || choice == "No")
			return TRUE
		if (choice == "Yes")
			actions.start(new/datum/action/bar/private/icon/devolve(src), holder.owner)
			holder.owner.visible_message("<span class='alert'>[holder.owner] appears to stand oddly still!</span>", "<span class='alert'>You begin to return to a lesser form.</span>")

/datum/action/bar/private/icon/devolve
	duration = 8 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT | INTERRUPT_ATTACKED
	id = "brain_slug_devolve"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"

	New(source)
		..()

	onStart()
		..()
		var/mob/living/caster = owner
		if (caster == null || !isalive(caster) || !can_act(caster))
			interrupt(INTERRUPT_ALWAYS)
			return

	onUpdate()
		..()
		var/mob/living/caster = owner

		if (caster == null || !isalive(caster) || !can_act(caster))
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		var/mob/living/caster = owner
		var/mob/living/critter/brain_slug/new_slug = new /mob/living/critter/brain_slug(caster.loc)
		caster.mind.transfer_to(new_slug)
		var/datum/abilityHolder/brain_slug_master/AH = new_slug.abilityHolder
		AH.points = 2
		new_slug.visible_message("<span class='alert'>A tiny slug bursts out of [caster]!</span>", "<span class='alert'>You return to a lesser form!</span>")
		caster.death()

	onInterrupt()
		..()
		var/mob/living/caster = owner
		boutput(caster, "<span class='alert'>You were interrupted!</span>")
