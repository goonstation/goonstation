/datum/targetable/brain_slug/devolve
	name = "Devolve"
	desc = "Return to a lesser form."
	icon_state = "slimeshot"
	cooldown = 300 SECONDS
	targeted = 0
	start_on_cooldown = TRUE

	cast()
		if (!isturf(holder.owner.loc))
			boutput(holder.owner, "<span class='notice'>You cannot use that here!</span>")
			return TRUE
		var/choice = tgui_alert(holder.owner, "Are you sure you wish to return to a lesser form?", "Evolution", list("Yes", "No"))
		if (!choice || choice == "No")
			return TRUE
		if (choice == "Yes")
			actions.start(new/datum/action/bar/private/icon/devolve(src, holder.owner), holder.owner)
			holder.owner.visible_message("<span class='alert'><b>[holder.owner] appears to stand oddly still!</b></span>", "<span class='alert'>You begin to return to a lesser form.</span>")

/datum/action/bar/private/icon/devolve
	duration = 8 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT | INTERRUPT_ATTACKED
	id = "brain_slug_devolve"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"
	var/mob/living/casting_mob = null

	New(source, var/mob/living/caster)
		src.casting_mob = caster
		..()

	onStart()
		..()
		if (src.casting_mob == null || !isalive(src.casting_mob) || !can_act(src.casting_mob))
			interrupt(INTERRUPT_ALWAYS)
			return

	onUpdate()
		..()
		if (src.casting_mob == null || !isalive(src.casting_mob) || !can_act(src.casting_mob))
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		var/mob/living/critter/brain_slug/new_slug = new /mob/living/critter/brain_slug(src.casting_mob.loc)
		src.casting_mob.mind.transfer_to(new_slug)
		var/datum/abilityHolder/brain_slug_master/AH = new_slug.abilityHolder
		AH.points = 2
		new_slug.visible_message("<span class='alert'>A tiny slug bursts out of [src.casting_mob]!</span>", "<span class='alert'>You return to a lesser form!</span>")
		src.casting_mob.death()

	onInterrupt()
		..()
		boutput(src.casting_mob, "<span class='alert'>You were interrupted!</span>")
