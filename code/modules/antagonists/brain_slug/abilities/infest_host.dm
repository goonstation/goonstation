/datum/targetable/brain_slug/infest_host
	name = "Infest a host"
	desc = "Enter the body of a living animal host or a dead human."
	icon_state = "infest_host"
	cooldown = 30 SECOND
	targeted = 1
	start_on_cooldown = 1
	var/is_transfer = FALSE

	cast(atom/target)
		if (!isturf(holder.owner.loc))
			boutput(holder.owner, "<span class='notice'>You cannot use that here!</span>")
			return TRUE
		if (target == holder.owner)
			return TRUE
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to infest.</span>")
			return TRUE
		//If we're not a slug, we're already in a mob so it's a transfer and it'll take longer to perform
		if (!istype(holder.owner, /mob/living/critter/brain_slug))
			is_transfer = TRUE
		if (istype(target, /mob/living))
			var/mob/living/M = target
			if(check_host_eligibility(M, holder.owner))
				actions.start(new/datum/action/bar/private/icon/brain_slug_infest(target, is_transfer, src), holder.owner)
				return FALSE
			else
				return TRUE
		else
			boutput(holder.owner, "<span class='alert'>That's not something you can infest!</span>")
			return TRUE

/datum/action/bar/private/icon/brain_slug_infest
	duration = 4 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT | INTERRUPT_ATTACKED
	id = "brain_slug_infest"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"
	var/mob/current_target = null
	var/mob/living/critter/brain_slug/the_slug = null
	var/is_transfer = FALSE

	New(var/mob/M, var/transfer = FALSE, source)
		is_transfer = transfer
		current_target = M
		..()

	onStart()
		..()

		var/mob/living/caster = owner
		if (caster == null || !isalive(caster) || !can_act(caster) || current_target == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (istype(caster, /mob/living/critter/small_animal)) //We are inside a small animal and trying to transfer bodies
			var/mob/living/critter/small_animal/casting_animal = caster
			if (!casting_animal.slug) //sanity check
				boutput (caster, "Uh, we're not some horrible space parasite. What were we thinking?")
				return
			else
				the_slug = casting_animal.slug
		if (istype(caster, /mob/living/carbon/human)) //We are inside a human and trying to transfer bodies
			var/mob/living/carbon/human/casting_human = caster
			if (!casting_human.slug) //sanity check
				boutput (caster, "Uh, we're not some horrible space parasite. What were we thinking?")
				return
			else
				the_slug = casting_human.slug
		else if (istype(caster, /mob/living/critter/brain_slug))
			the_slug = caster
			duration = 2 SECONDS	//We dont have to wiggle out of an old body, get in there faster
		else
			boutput(caster, "<span class=notice>You're not a slug!</span>")
		boutput(caster, "<span class=notice>You begin to infest [current_target]!</span>")

	onUpdate()
		..()

		var/mob/living/caster = owner

		if (caster == null || !isalive(caster) || !can_act(caster) || current_target == null || BOUNDS_DIST(caster, current_target) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (istype(caster, /mob/living/critter/brain_slug))
			SPAWN(0.5 SECONDS)	//squishy
				eat_twitch(caster)

	onEnd()
		..()

		var/mob/living/caster = owner
		boutput(caster, "<span class=notice>You burrow inside [current_target]'s head and make yourself at home.</span>")
		the_slug.set_loc(current_target)
		if (istype(current_target, /mob/living/critter/small_animal))
			var/mob/living/critter/small_animal/T = current_target
			T.slug = the_slug
			T.add_basic_slug_abilities(the_slug)

		else if (istype(current_target, /mob/living/carbon/human))
			var/mob/living/carbon/human/T = current_target
			T.slug = the_slug
			T.add_advanced_slug_abilities(the_slug)
			//Add abilities to the host on infest if you unlocked them
			var/datum/abilityHolder/brain_slug/AH = null
			if (istype(T.abilityHolder, /datum/abilityHolder/brain_slug))
				AH = T.abilityHolder
			else if (istype(T.abilityHolder, /datum/abilityHolder/composite))
				var/datum/abilityHolder/composite/composite_holder = T.abilityHolder
				for (var/datum/holder in composite_holder.holders)
					if (istype(holder, /datum/abilityHolder/brain_slug))
						AH = holder
			if (AH?.harvest_count >= 2)
				if (!AH.getAbility(/datum/targetable/brain_slug/acidic_spit))
					AH.addAbility(/datum/targetable/brain_slug/acidic_spit)
			if (AH?.harvest_count >= 6)
				if (!AH.getAbility(/datum/targetable/brain_slug/sling_spit))
					AH.addAbility(/datum/targetable/brain_slug/sling_spit)
			if (AH?.harvest_count >= 12)
				if (!AH.getAbility(/datum/targetable/brain_slug/summon_brood))
					AH.addAbility(/datum/targetable/brain_slug/summon_brood)
			if (AH?.harvest_count >= 20)
				if (!AH.getAbility(/datum/targetable/brain_slug/pupate))
					AH.addAbility(/datum/targetable/brain_slug/pupate)

		hit_twitch(current_target)
		logTheThing(LOG_COMBAT, caster, "[caster] has infested [current_target]")

		if (is_transfer) //Handle the old body
			caster.mind.transfer_to(the_slug)	//Assume control of the slug again, use "take control" to start over.
			if(istype(caster, /mob/living/critter/small_animal))
				var/mob/living/critter/small_animal/old_host = caster
				old_host.slug = null
			if(istype(caster, /mob/living/carbon/human))
				var/mob/living/carbon/human/old_host = caster
				old_host.slug = null
			caster.remove_ability_holder(/datum/abilityHolder/brain_slug)
			spawn(5 SECONDS)
				caster?.death()

	onInterrupt()
		..()

		var/mob/living/caster = owner
		boutput(caster, "<span class='alert'>You were interrupted!</span>")
