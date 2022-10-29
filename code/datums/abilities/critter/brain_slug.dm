/atom/movable/screen/ability/topBar/brain_slug
	clicked(params)
		if (!istype(owner, /datum/targetable/brain_slug))
			return
		if (!owner.holder)
			return
		..()
	tens_offset_x = 19
	tens_offset_y = 7
	secs_offset_x = 23
	secs_offset_y = 7

/datum/abilityHolder/brain_slug
	usesPoints = 1
	regenRate = 0
	pointName = "Stability"
	tabName = "Abilities"
	topBarRendered = 1
	rendered = 1
	points = 700
	onAbilityStat()
		..()
		.= list()
		.["Stability:"] = round(src.points)

ABSTRACT_TYPE(/datum/targetable/brain_slug)
/datum/targetable/brain_slug
	icon = 'icons/mob/critter_ui.dmi'
	var/border_icon = 'icons/mob/critter_ui.dmi'
	var/border_state = "brain_slug_frame"

	onAttach(datum/abilityHolder/holder)
		..()
		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")

/datum/targetable/brain_slug/slither
	name = "Slither away"
	desc = "Expel some mucus from your body to trip threats."
	icon_state = "slither"
	cooldown = 30 SECONDS
	targeted = 0
	cast()
		playsound(holder.owner.loc, 'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 30, 1, 1, 1.2)
		holder.owner.AddComponent(/datum/component/floor_slime, "superlube", 50, 75)
		var/datum/component/C = holder.owner.GetComponent(/datum/component/floor_slime)
		holder.owner.visible_message("<span class='alert'>[holder.owner] begins leaving a trail of slippery slime behind itself!</span>", "<span class='notice'>You expel some slime out of your body.</span>")
		spawn(7 SECONDS)
			C?.RemoveComponent(/datum/component/floor_slime)

/datum/targetable/brain_slug/infest_host
	name = "Infest a host"
	desc = "Enter the body of a living animal host or a freshly dead human."
	icon_state = "infest_host"
	cooldown = 30 SECOND
	targeted = 1
	start_on_cooldown = 1
	var/is_transfer = FALSE

	cast(atom/target)
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
			T.add_basic_slug_abilities()

		else if (istype(current_target, /mob/living/carbon/human))
			var/mob/living/carbon/human/T = current_target
			T.slug = the_slug
			T.add_advanced_slug_abilities()

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

/datum/targetable/brain_slug/exit_host
	name = "Exit host"
	desc = "Leave behind this worthless body."
	icon_state = "exit_host"
	cooldown = 8 SECONDS
	targeted = 0

	cast()
		if (holder.owner.reagents)
			var/volume_passed = holder.owner.reagents.get_reagent_amount("synaptizine") //Some counterplay to avoid the slug just ditching the body the second it is caught out
			if (volume_passed)
				holder.owner.visible_message("<span class='notice'>[holder.owner] contorts for an instant then straightens back up, visibly pained.'</span>",\
											"<span class='alert'>You try to exit this host but you can't concentrate enough with this poison in you!</span>")
				holder.owner.emote("scream")
				return FALSE
		if (istype(holder.owner, /mob/living/critter/small_animal))
			var/mob/living/critter/small_animal/caster = holder.owner
			if (!caster.slug)
				boutput(holder.owner, "<span class='notice'>You have no parasite to expel... uh.</span>")
				return TRUE
			//Drop the slug on the floor and give it back its mind.
			caster.mind.transfer_to(caster.slug)
			caster.slug.changeStatus("slowed", 5 SECONDS, 2)
			caster.slug.set_loc(get_turf(caster))
			//Dont immediately infest something again.
			var/datum/targetable/ability = caster.slug.abilityHolder.getAbility(/datum/targetable/brain_slug/infest_host)
			ability.doCooldown()
			caster.remove_ability_holder(/datum/abilityHolder/brain_slug)
			caster.slug = null
			spawn(5 SECONDS)	//It doesnt have much of a brain anymore
				caster?.death()
		else if (ishuman(holder.owner))
			var/mob/living/carbon/human/human_host = holder.owner
			if (!human_host.slug)
				boutput(holder.owner, "<span class='notice'>You have no parasite to expel... uh.</span>")
				return TRUE
			human_host.make_jittery(20)
			human_host.emote("scream")
			human_host.setStatus("stunned", 10 SECONDS)
			spawn(3 SECONDS)
				if (!human_host || !human_host.slug) return
				//Drop the slug on the floor and control it again
				human_host.mind?.transfer_to(human_host.slug)
				human_host.slug.changeStatus("slowed", 5 SECONDS, 2)
				human_host.slug.set_loc(get_turf(human_host))
				//Dont immediately infest something again.
				var/datum/targetable/ability = human_host.slug.abilityHolder.getAbility(/datum/targetable/brain_slug/infest_host)
				ability.doCooldown()
				if (human_host.organHolder.head) //sanity check in case you somehow lost your head but didnt die yet.
					var/obj/head = human_host.organHolder.drop_organ("head")
					qdel(head)
					make_cleanable( /obj/decal/cleanable/blood/gibs,human_host.loc)
					playsound(human_host.loc, 'sound/impact_sounds/Flesh_Break_2.ogg', 50)
					gibs(human_host.loc, headbits = 0)
					human_host.visible_message("<span class='alert'>[human_host]'s head suddenly explodes in a shower of gore! Some horrific space slug jumps out of the horrible mess.</span>", "<span class='alert'>You leave [human_host]'s head in a delightfully horrific manner.</span>")
				//Cleanup
				human_host.slug = null
				human_host.remove_ability_holder(/datum/abilityHolder/brain_slug)
				human_host.death()
		else if (istype(holder.owner, /mob/living/critter/brain_slug))
			var/mob/living/critter/brain_slug/the_slug = holder.owner
			if (istype(the_slug.loc,/mob/))
				var/mob/containing_mob = the_slug.loc
				the_slug.set_loc(get_turf(containing_mob))
				if (ishuman(containing_mob))
					var/mob/living/carbon/human/old_host = containing_mob
					old_host.slug = null
				if (istype(containing_mob, /mob/living/critter/small_animal))
					var/mob/living/critter/small_animal/old_host = containing_mob
					old_host.slug = null
				containing_mob.remove_ability_holder(/datum/abilityHolder/brain_slug)
				return FALSE
			else
				boutput(the_slug, "<span class='notice'>You aren't in a host!</span>")
				return TRUE
		else
			boutput(holder.owner, "<span class='notice'>Something weird happened. Consider making a bug report.</span>")
			return TRUE

/datum/targetable/brain_slug/take_control
	name = "Assume control"
	desc = "Take full control of the being you infested along with healing any damage they may have."
	icon_state = "control_host"
	cooldown = 10 SECONDS
	targeted = 0

	cast()
		var/mob/M = holder.owner
		if (!istype(M, /mob/living/critter/brain_slug))
			boutput(M, "<span class='notice'>You arent enough of a slug to do that.</span>")
			return TRUE
		var/mob/living/critter/brain_slug/the_slug = M
		if (istype(the_slug.loc,/mob/))	//Check you're in a mob and not like, a locker or something. Though a brain possessed locker would be kinda funny.
			var/mob/the_mob = the_slug.loc
			//Begin the sluggening
			hit_twitch(the_mob)
			boutput(M, "<span class='notice'>You begin to take over [the_mob].</span>")
			spawn(3 SECONDS)
				if (!the_mob || !the_slug) return
				if (the_slug.loc != the_mob) return
				violent_standup_twitch(the_mob)
				playsound(M.loc, 'sound/effects/bones_break.ogg', 30, 1)
				spawn(2 SECONDS)
					if (!the_mob || !the_slug) return
					if (the_slug.loc != the_mob) return
					the_slug.mind?.transfer_to(the_mob)
					the_mob.full_heal()
		else
			boutput(M, "<span class='notice'>You arent inside something you can possess.</span>")
			return TRUE


///Checks if a thing can be infested by a brain slug and returns false if it cant be.
proc/check_host_eligibility(var/mob/living/mob_target, var/mob/caster)
	//Small animals are fair game except mentormice and adminmice for obvious reasons.
	if (istype(mob_target, /mob/living/critter/small_animal) && !istype(mob_target, /mob/living/critter/small_animal/mouse/weak/mentor) && !istype(mob_target, /mob/living/critter/small_animal/mouse/weak/mentor/admin))
		var/mob/living/critter/small_animal/animal_target = mob_target
		if (!isalive(animal_target))
			boutput(caster, "<span class='notice'>You got here a bit late. [animal_target] is already dead.</span>")
			return FALSE
		if (animal_target.mind == null)
			return TRUE
		else
			boutput(caster, "<span class='notice'>This creature looks much too resilient to infest.</span>")
			return FALSE

	//Human corpses are also prime targets, if they are fresh
	else if (ishuman(mob_target))
		if (isalive(mob_target))
			boutput(caster, "<span class='notice'>They are too twitchy to infest. It'd be much easier if they stopped moving. Permanently.</span>")
			return FALSE
		var/mob/living/carbon/human/human_target = mob_target
		if (!mob_target.organHolder.head)
			boutput(caster, "<span class='notice'>Try as you might, you just can't find a head to crawl into.</span>")
			return FALSE
		if (human_target.decomp_stage >= DECOMP_STAGE_BLOATED)
			boutput(caster, "<span class='notice'>That body is sadly too decomposed to use.</span>")
			return FALSE

		if (human_target.abilityHolder)
			if (istype(human_target.abilityHolder,/datum/abilityHolder/changeling))
				boutput(caster, "<span class='notice'>That one's insides are all... wrong. You can't seem to make sense of it, much less so control it.</span>")
				return FALSE
			if (istype(human_target.abilityHolder,/datum/abilityHolder/werewolf))
				boutput(caster, "<span class='notice'>This body doesnt look normal. You decide to leave it alone.</span>")
				return FALSE
			if (istype(human_target.abilityHolder,/datum/abilityHolder/arcfiend))
				boutput(caster, "<span class='notice'>This body crackles faintly with electricity. You'd get zapped if you decided to control it.</span>")
				return FALSE
			if (istype(human_target.abilityHolder,/datum/abilityHolder/vampire))
				boutput(caster, "<span class='notice'>This body's blood smells like poison and it emanates ominous dark magic. Best not to mess with it</span>")
				return FALSE
			if (istype(human_target.abilityHolder,/datum/abilityHolder/vampiric_thrall))
				boutput(caster, "<span class='notice'>This body's insides are all messed up and it seems to be leaking blood at an alarming rate. Best to leave it there.</span>")
				return FALSE
			if (istype(human_target.abilityHolder,/datum/abilityHolder/wizard))
				boutput(caster, "<span class='notice'>Some residual magical energy resists your attempt to invade this body.</span>")
				return FALSE
			if (istype(human_target.abilityHolder,/datum/abilityHolder/composite))
				var/datum/abilityHolder/composite/composite_holder = human_target.abilityHolder
				for (var/datum/holder in composite_holder.holders)
					if (istype(holder,/datum/abilityHolder/changeling))
						boutput(caster, "<span class='notice'>That one's insides are all... wrong. You can't seem to make sense of it, much less so control it.</span>")
						return FALSE
					if (istype(holder,/datum/abilityHolder/werewolf))
						boutput(caster, "<span class='notice'>This body doesnt look normal. You decide to leave it alone.</span>")
						return FALSE
					if (istype(holder,/datum/abilityHolder/arcfiend))
						boutput(caster, "<span class='notice'>This body crackles faintly with electricity. You'd get zapped if you decided to control it.</span>")
						return FALSE
					if (istype(holder,/datum/abilityHolder/vampire))
						boutput(caster, "<span class='notice'>This body's blood smells like poison and it emanates ominous dark magic. Best not to mess with it</span>")
						return FALSE
					if (istype(holder,/datum/abilityHolder/vampiric_thrall))
						boutput(caster, "<span class='notice'>This body's insides are all messed up and it seems to be leaking blood at an alarming rate. Best to leave it there.</span>")
						return FALSE
					if (istype(holder,/datum/abilityHolder/wizard))
						boutput(caster, "<span class='notice'>Some residual magical energy resists your attempt to invade this body.</span>")
						return FALSE
		return TRUE

	return FALSE

/datum/targetable/brain_slug/spit_slime
	name = "Spit slime"
	desc = "Turn some of your host's insides into slime, locking down doors or debilitating attackers. Costs stability to use."
	icon_state = "slimeshot"
	cooldown = 20 SECONDS
	targeted = 1
	target_anything = 1
	pointCost = 40

	cast(atom/target)
		if (..())
			return 1

		var/mob/shooter = holder.owner
		var/obj/projectile/proj = initialize_projectile_ST(shooter, new/datum/projectile/special/slug_slime, get_turf(target))
		while (!proj || proj.disposed)
			proj = initialize_projectile_ST(shooter, new/datum/projectile/special/slug_slime, get_turf(target))

		proj.targets = list(target)

		proj.launch()

/datum/targetable/brain_slug/restraining_spit
	name = "Restraining Spit"
	desc = "Horfs some movement impairing goo at someone close to you."
	icon_state = "slimeshot"
	cooldown = 50 SECONDS
	targeted = 1
	target_anything = 0
	pointCost = 40

	cast(atom/target)
		if (target == holder.owner)
			return TRUE
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to restrain.</span>")
			return TRUE
		new /obj/machinery/brain_slug/restraining_goo(target.loc, target)
		//Todo add a sound
		holder.owner.visible_message("<span class='alert'>[holder.owner] spews a revolting stream of slime at [target]'s legs!</span>", "<span class='alert'>You spit restraining slime at [target] to hold them in place.</span>")
		return FALSE
