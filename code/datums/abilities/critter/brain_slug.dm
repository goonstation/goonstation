/atom/movable/screen/ability/topBar/brain_slug
	clicked(params)
		if (!istype(owner, /datum/targetable/brain_slug))
			return
		if (!owner.holder)
			return
		..()

/datum/abilityHolder/brain_slug
	usesPoints = 0
	regenRate = 0
	tabName = "Abilities"
	topBarRendered = 1
	rendered = 1

/datum/targetable/brain_slug/slither
	name = "Slither away"
	desc = "Expel some mucus from your body to trip threats."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "eat_filth"
	cooldown = 30 SECONDS
	targeted = 0
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = "plague_frame"
	//Todo add a sound
	cast()
		holder.owner.AddComponent(/datum/component/floor_slime, "superlube", 50, 75)
		var/datum/component/C = holder.owner.GetComponent(/datum/component/floor_slime)
		spawn(7 SECONDS)
			C?.RemoveComponent(/datum/component/floor_slime)


	onAttach(datum/abilityHolder/holder)
		..()
		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")

/datum/targetable/brain_slug/infest_host
	name = "Infest a host"
	desc = "Take control of a living animal host or a freshly dead human."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "ratbite"
	cooldown = 20 SECOND
	targeted = 1
	start_on_cooldown = 1
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = "plague_frame"
//Todo add small_animals mobs + critters. Make sure they can all die.
//Turn obj critters into mob critters, not gonna be pretty.
//Turn corpses back into a living thing and add counter + abilities. Kill the revived corpse when the counter ends.
//Abilities should cost the same points that keep the body alive.
//
//maybe ban boogiebots and morty?
//Ban mentormouse and adminmouse.
//Ability to spread? Think it over. Prolly not.
	cast(atom/target)
		if (target == holder.owner)
			return FALSE
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to infest.</span>")
			return FALSE
		if (!istype(target, /mob/living))
			boutput(holder.owner, "<span class='alert'>That isnt something you can possess.</span>")
			return FALSE
		var/mob/living/mob_target = target
		//This is horribly inneficient, but i cant think of a better way to do this until obj/critters on station are replaced with mob critters..
		//This should be changed to use mob critters once the mobbening has happened..

		//Small animals are fair game except mentormice and adminmice for obvious reasons.
		if (istype(mob_target, /mob/living/critter/small_animal) && !istype(mob_target, /mob/living/critter/small_animal/mouse/weak/mentor) && !istype(mob_target, /mob/living/critter/small_animal/mouse/weak/mentor/admin) && isalive(mob_target))
			var/mob/living/critter/small_animal/animal_target = mob_target
			if (animal_target.mind == null)
				actions.start(new/datum/action/bar/private/icon/brain_slug_infest(animal_target, FALSE, src), holder.owner)
			else
				boutput(holder.owner, "<span class='notice'>This creature looks much too lively to infest.</span>")

		//Todo, check if they still got a head
		else if (istype(mob_target, /mob/living/carbon/human))
			if(isalive(mob_target))
				boutput(holder.owner, "<span class='notice'>They are too twitchy to infest. It'd be much easier if they stopped moving. Permanently.</span>")
				return FALSE
			var/mob/living/carbon/human/human_target = mob_target
			if (human_target.decomp_stage >= DECOMP_STAGE_HIGHLY_DECAYED)
				boutput(holder.owner, "<span class='notice'>That body is sadly too decomposed to use.</span>")
				return FALSE
			//Todo check if they are a changeling or something, might be op if we take control of an antag body
			actions.start(new/datum/action/bar/private/icon/brain_slug_infest(human_target, FALSE, src), holder.owner)
		return FALSE

	onAttach(datum/abilityHolder/holder)
		..()
		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")


/datum/action/bar/private/icon/brain_slug_infest
	duration = 4 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT | INTERRUPT_ATTACKED
	id = "brain_slug_infest"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"
	var/mob/current_target = null
	var/mob/living/critter/brain_slug/the_slug = null
	var/is_transfer = FALSE

	New(var/mob/M, var/B = FALSE, source)
		is_transfer = B
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

		if (caster == null || !isalive(caster) || !can_act(caster) || current_target == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (istype(caster, /mob/living/critter/brain_slug))
			SPAWN(0.5 SECONDS)	//squishy
				//Todo find a better animation
				eat_twitch(caster)

	onEnd()
		..()

		var/mob/living/caster = owner
		boutput(caster, "<span class=notice>You burrow inside [current_target]'s head and make yourself at home.</span>")
		the_slug.set_loc(current_target)
		if (istype(current_target, /mob/living/critter/small_animal))
			var/mob/living/critter/small_animal/T = current_target
			T.slug = the_slug
		else if (istype(current_target, /mob/living/carbon/human))
			var/mob/living/carbon/human/T = current_target
			T.slug = the_slug
		current_target.addAbility(/datum/targetable/brain_slug/exit_host)
		current_target.addAbility(/datum/targetable/brain_slug/transfer_host)
		hit_twitch(current_target)
		//Todo add human corpses here
		//Todo add obj critters here
		logTheThing(LOG_COMBAT, caster, "[caster] has infested [current_target]")

		if (is_transfer) //Handle the old body
			caster.mind.transfer_to(the_slug)	//Assume control of the slug again, use "take control" to start over.
			if(istype(caster, /mob/living/critter/small_animal))
				var/mob/living/critter/small_animal/S = caster
				S.slug = null
				S.removeAbility(/datum/targetable/brain_slug/exit_host)
				S.removeAbility(/datum/targetable/brain_slug/transfer_host)
			if(istype(caster, /mob/living/carbon/human))
				var/mob/living/carbon/human/S = caster
				S.slug = null
				S.removeAbility(/datum/targetable/brain_slug/exit_host)
				S.removeAbility(/datum/targetable/brain_slug/transfer_host)

			spawn(5 SECONDS)
				caster.death(gibbed = FALSE)

	onInterrupt()
		..()

		var/mob/living/caster = owner
		boutput(caster, "<span class='alert'>You were interrupted!</span>")

/datum/targetable/brain_slug/exit_host
	//todo exiting a human body should gib/make it unrecoverable/pop its fucking head off like some hellspawn
	name = "Dissociate"
	desc = "Leave behind this worthless body."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "eat_filth"
	cooldown = 1 SECONDS
	targeted = 0
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = "plague_frame"
	//Todo add a sound
	cast()
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
			caster.removeAbility(/datum/targetable/brain_slug/exit_host)
			caster.removeAbility(/datum/targetable/brain_slug/transfer_host)
			caster.slug = null
			spawn(5 SECONDS)	//It doesnt have much of a brain anymore
				caster.death(gibbed = FALSE)
		else if (istype(holder.owner, /mob/living/carbon/human))	//Todo add something to avoid it slithering out easily
			var/mob/living/carbon/human/human_host = holder.owner
			if (!human_host.slug)
				boutput(holder.owner, "<span class='notice'>You have no parasite to expel... uh.</span>")
				return TRUE
			human_host.mind.transfer_to(human_host.slug)
			human_host.slug.changeStatus("slowed", 5 SECONDS, 2)
			human_host.slug.set_loc(get_turf(human_host))
			//Dont immediately infest something again.
			var/datum/targetable/ability = human_host.slug.abilityHolder.getAbility(/datum/targetable/brain_slug/infest_host)
			ability.doCooldown()
			human_host.removeAbility(/datum/targetable/brain_slug/exit_host)
			human_host.removeAbility(/datum/targetable/brain_slug/transfer_host)
			human_host.slug = null
			spawn(5 SECONDS)	//It doesnt have much of a brain anymore
				human_host.death(gibbed = FALSE)
		else if (istype(holder.owner, /mob/living/critter/brain_slug))
			var/mob/living/critter/brain_slug/the_slug = holder.owner
			if (istype(the_slug.loc,/mob/))
				var/mob/containing_mob = the_slug.loc
				the_slug.set_loc(get_turf(containing_mob))
				return FALSE
			else
				boutput(the_slug, "<span class='notice'>You aren't in a host!</span>")
				return TRUE
		else
			boutput(holder.owner, "<span class='notice'>Something weird happened. Consider making a bug report with error code: 10.</span>")
			return TRUE


	onAttach(datum/abilityHolder/holder)
		..()
		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")

/datum/targetable/brain_slug/transfer_host
	name = "Transfer hosts"
	desc = "Exchange this body for another."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "eat_filth"
	cooldown = 50 SECONDS
	start_on_cooldown = 1
	targeted = 1
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = "plague_frame"

	cast(atom/target)
		if (target == holder.owner)
			return FALSE
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to infest.</span>")
			return FALSE
		if (!istype(target, /mob/living))
			boutput(holder.owner, "<span class='alert'>That isn't something you can infest.</span>")
			return FALSE
		var/mob/living/new_host = target
		//Todo turn this into a proc call
		if (istype(new_host, /mob/living/critter/small_animal) && !istype(new_host, /mob/living/critter/small_animal/mouse/weak/mentor) && !istype(new_host, /mob/living/critter/small_animal/mouse/weak/mentor/admin))
			var/mob/living/critter/small_animal/animal_target = new_host
			if (animal_target.mind == null)
				actions.start(new/datum/action/bar/private/icon/brain_slug_infest(animal_target, TRUE, src), holder.owner)
			else
				boutput(holder.owner, "<span class='notice'>This creature looks much too lively to infest.</span>")
		else if (istype(new_host, /mob/living/carbon/human))
			if(isalive(new_host))
				boutput(holder.owner, "<span class='notice'>They are too twitchy to infest. It'd be much easier if they stopped moving. Permanently.</span>")
				return FALSE
			var/mob/living/carbon/human/human_target = new_host
			if (human_target.decomp_stage >= DECOMP_STAGE_HIGHLY_DECAYED)
				boutput(holder.owner, "<span class='notice'>That body is sadly too decomposed to use.</span>")
				return FALSE
			//Todo check if they are a changeling or something, might be op if we take control of an antag body
			actions.start(new/datum/action/bar/private/icon/brain_slug_infest(human_target, FALSE, src), holder.owner)
		return 0

	onAttach(datum/abilityHolder/holder)
		..()
		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")

/datum/targetable/brain_slug/take_control
	name = "Assume control"
	desc = "Take full control of the being you infested along with healing any damage they may have."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "eat_filth"
	cooldown = 10 SECONDS
	targeted = 0
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = "plague_frame"

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
			spawn(3 SECONDS)
				violent_standup_twitch(the_mob)
				spawn(2 SECONDS)
					the_slug.mind.transfer_to(the_mob)
					the_mob.full_heal()
					violent_standup_twitch(the_mob)
					return FALSE
