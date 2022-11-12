/datum/targetable/brain_slug/harvest
	name = "Harvest"
	desc = "Steal some organs from someone to sustain your body and evolve."
	icon_state = "harvest"
	cooldown = 60 SECOND
	targeted = 1

	cast(atom/target)
		if (!isturf(holder.owner.loc))
			boutput(holder.owner, "<span class='notice'>You cannot use that here!</span>")
			return TRUE
		if (target == holder.owner)
			return TRUE
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to harvest.</span>")
			return TRUE
		if (!istype(target, /mob/living/carbon/human))
			boutput(holder.owner, "<span class='alert'>That doesn't have any organs to harvest!</span>")
			return TRUE
		var/mob/living/carbon/human/H = target
		if (isnpc(H) || isnpcmonkey(H))
			boutput(holder.owner, "<span class='alert'>That body doesn't have enough life for you to steal!</span>")
			return TRUE
		if (isdead(H))
			boutput(holder.owner, "<span class='alert'>That one is already dead! You need fresh meat!</span>")
			return TRUE
		actions.start(new/datum/action/bar/icon/slug_harvest(H, 2, holder.owner), holder.owner)
		return FALSE

/datum/action/bar/icon/slug_harvest
	duration = 8 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT | INTERRUPT_ATTACKED
	id = "brain_slug_devour"
	icon = 'icons/mob/brainslug_ui.dmi'
	icon_state = "action_harvest"
	var/mob/living/carbon/human/current_target = null
	var/mob/living/caster = null
	var/organ_target = null
	var/recast = 0

	New(var/mob/living/carbon/human/M, var/repeats, var/mob/living/host)
		src.current_target = M
		src.caster = host
		src.recast = repeats
		//Get all the organs inside the person
		if (!src.current_target.organHolder)
			boutput(src.caster, "<span class='notice'>There isn't anything to steal here!</span>")
			interrupt(INTERRUPT_ALWAYS)
		var/list/targets = list()
		if (src.current_target.organHolder.appendix)
			targets += src.current_target.organHolder.appendix
		if (src.current_target.organHolder.left_kidney)
			targets += src.current_target.organHolder.left_kidney
		if (src.current_target.organHolder.left_lung)
			targets += src.current_target.organHolder.left_lung
		if (src.current_target.organHolder.right_kidney)
			targets += src.current_target.organHolder.right_kidney
		if (src.current_target.organHolder.right_lung)
			targets += src.current_target.organHolder.right_lung
		if (src.current_target.organHolder.spleen)
			targets += src.current_target.organHolder.spleen
		if (src.current_target.organHolder.pancreas)
			targets += src.current_target.organHolder.pancreas
		if (src.current_target.organHolder.intestines)
			targets += src.current_target.organHolder.intestines
		if (src.current_target.organHolder.stomach)
			targets += src.current_target.organHolder.stomach
		//No organs left? Go for the heart
		if (!length(targets))
			if (src.current_target.organHolder.heart)
				targets += src.current_target.organHolder.heart
		if (!length(targets))
			boutput(src.caster, "<span class='notice'>There isn't anything to steal here!</span>")
			interrupt(INTERRUPT_ALWAYS)
		src.organ_target = pick(targets)
		..()

	onStart()
		..()
		if (src.caster == null || !isalive(src.caster) || !can_act(src.caster) || src.current_target == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		src.caster.visible_message("<span class='alert'><b>[src.caster] jabs their hands forward into [src.current_target]'s chest and begins grasping inside!</b></span>", "<span class='notice'>You begin to harvest [src.organ_target].</span>")
		playsound(src.caster.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50)
		bleed(src.current_target, 10, 5)
		hit_twitch(src.current_target)
		SPAWN(3 SECONDS)
			if (src.caster != null && isalive(src.caster) && can_act(src.caster) && src.current_target != null && BOUNDS_DIST(src.caster, src.current_target) <= 0)
				src.current_target.setStatus("weakened", 10 SECONDS)

	onUpdate()
		..()
		if (src.caster == null || !isalive(src.caster) || !can_act(src.caster) || src.current_target == null || BOUNDS_DIST(src.caster, src.current_target) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		random_brute_damage(src.current_target, 12)
		playsound(src.current_target, 'sound/impact_sounds/Slimy_Hit_3.ogg', 50)
		SPAWN(0.5 SECONDS)
			playsound(src.current_target, 'sound/impact_sounds/Flesh_Break_1.ogg', 50)
		if (src.organ_target)
			src.caster.visible_message("<span class='alert'>[src.caster] pulls out [src.organ_target] and gulps it all in one piece! [pick("FUCK!", "WHAT THE HELL?", "You're going to puke.")]</span>", "<span class='alert'>You harvest [src.organ_target]! [pick("Delicious!", "Scrumptious!", "Delectable!")]</span>")
			qdel(src.organ_target)
		if (prob(40))
			src.current_target.emote("scream")
		bleed(current_target, 10, 2)
		if (istype(src.caster, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = src.caster
			//We do have a slug inside, yeah?
			if (H.slug)
				var/mob/living/critter/brain_slug/the_slug = H.slug
				the_slug.abilityHolder.points ++
				//Add the new tally to our point counter
				var/datum/abilityHolder/brain_slug/AH = null
				if (istype(H.abilityHolder, /datum/abilityHolder/brain_slug))
					AH = H.abilityHolder
				else if (istype(H.abilityHolder, /datum/abilityHolder/composite))
					var/datum/abilityHolder/composite/composite_holder = H.abilityHolder
					for (var/datum/holder in composite_holder.holders)
						if (istype(holder, /datum/abilityHolder/brain_slug))
							AH = holder
				if (AH)
					AH.harvest_count = the_slug.abilityHolder.points
				//Then reward abilities if we crossed the threshold
					if (AH.harvest_count >= 1)
						if (!AH.getAbility(/datum/targetable/brain_slug/acidic_spit))
							AH.addAbility(/datum/targetable/brain_slug/acidic_spit)
					if (AH.harvest_count >= 6)
						if (!AH.getAbility(/datum/targetable/brain_slug/sling_spit))
							AH.addAbility(/datum/targetable/brain_slug/sling_spit)
					if (AH.harvest_count >= 9)
						if (!AH.getAbility(/datum/targetable/brain_slug/summon_brood))
							AH.addAbility(/datum/targetable/brain_slug/summon_brood)
					if (AH.harvest_count >= 15)
						if (!AH.getAbility(/datum/targetable/brain_slug/pupate))
							AH.addAbility(/datum/targetable/brain_slug/pupate)
					//Refund a bit of stability for doing well
					if ((AH.points + 30) > 500)
						AH.points = 500
					else
						AH.points += 30
					AH.updateButtons()

		if (src.recast > 0)
			actions.start(new/datum/action/bar/icon/slug_harvest(src.current_target, (src.recast -1), src.caster), src.caster)
		..()

	onInterrupt()
		boutput(src.caster, "<span class='alert'>You were interrupted!</span>")
		..()
