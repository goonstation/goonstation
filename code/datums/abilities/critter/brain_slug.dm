/datum/targetable/critter/brain_slug/slither
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
		if (..())
			return TRUE
		holder.owner.AddComponent(/datum/component/floor_slime, "superlube", 50, 75)
		var/datum/component/C = holder.owner.GetComponent(/datum/component/floor_slime)
		spawn(7 SECONDS)
			C?.RemoveComponent(/datum/component/floor_slime)


	onAttach(datum/abilityHolder/holder)
		..()
		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")

/datum/targetable/critter/brain_slug/infest_host
	name = "Infest a host"
	desc = "Take control of an animal host or of a dead body."
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
		if (..())
			return FALSE
		if (target == holder.owner)
			return FALSE
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to infest.</span>")
			return FALSE
		//This is horribly inneficient, but i cant think of a better way to do this until obj/critters on station are replaced with mob critters..
		//This should be changed to use mob critters once the mobbening has happened..

		//Small animals are fair game except mentormice and adminmice for obvious reasons.
		if (istype(target, /mob/living/critter/small_animal) && !istype(target, /mob/living/critter/small_animal/mouse/weak/mentor) && !istype(target, /mob/living/critter/small_animal/mouse/weak/mentor/admin))
			var/mob/living/critter/small_animal/animal_target = target
			if (animal_target.mind == null)
				actions.start(new/datum/action/bar/private/icon/brain_slug_infest(animal_target, FALSE, src), holder.owner)
			else
				boutput(holder.owner, "<span class='notice'>This creature looks much too lively to infest.</span>")
		return 0

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
	var/mob/living/critter/small_animal/current_target = null
	var/mob/living/critter/brain_slug/the_slug = null
	var/is_transfer = FALSE

	New(var/mob/living/critter/small_animal/T, var/B = FALSE, source)
		is_transfer = B
		current_target = T
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
		caster.mind.transfer_to(current_target)
		current_target.slug = the_slug
		current_target.addAbility(/datum/targetable/critter/brain_slug/exit_host)
		current_target.addAbility(/datum/targetable/critter/brain_slug/transfer_host)
		//Todo add human corpses here
		//Todo add obj critters here
		logTheThing(LOG_COMBAT, caster, "[caster] has infested [current_target]")

		if (is_transfer) //Handle the old body
			if(istype(caster, /mob/living/critter/small_animal))
				var/mob/living/critter/small_animal/S = caster
				S.slug = null
				S.removeAbility(/datum/targetable/critter/brain_slug/exit_host)
				S.removeAbility(/datum/targetable/critter/brain_slug/transfer_host)

			spawn(5 SECONDS)
				caster.death(gibbed = FALSE)

	onInterrupt()
		..()

		var/mob/living/caster = owner
		boutput(caster, "<span class='alert'>You were interrupted!</span>")

/datum/targetable/critter/brain_slug/exit_host
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
		if (..())
			return FALSE
		if (!istype(holder.owner, /mob/living/critter/small_animal))
			boutput(holder.owner, "<span class='notice'>1.</span>")
			return FALSE
		var/mob/living/critter/small_animal/caster = holder.owner
		if (!caster.slug)
			boutput(holder.owner, "<span class='notice'>2</span>")
			return FALSE
		//Drop the slug on the floor and give it back its mind.
		caster.mind.transfer_to(caster.slug)
		caster.slug.changeStatus("slowed", 5 SECONDS, 2)
		caster.slug.set_loc(get_turf(caster))
		//Dont immediately infest something again.
		var/datum/targetable/ability = caster.slug.abilityHolder.getAbility(/datum/targetable/critter/brain_slug/infest_host)
		ability.doCooldown()
		caster.removeAbility(/datum/targetable/critter/brain_slug/exit_host)
		caster.removeAbility(/datum/targetable/critter/brain_slug/transfer_host)
		caster.slug = null
		spawn(5 SECONDS)	//It doesnt have much of a brain anymore
			caster.death(gibbed = FALSE)

	onAttach(datum/abilityHolder/holder)
		..()
		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")

/datum/targetable/critter/brain_slug/transfer_host
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
		if (..())
			return FALSE
		if (target == holder.owner)
			return FALSE
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to infest.</span>")
			return FALSE

		//Todo turn this into a proc call
		if (istype(target, /mob/living/critter/small_animal) && !istype(target, /mob/living/critter/small_animal/mouse/weak/mentor) && !istype(target, /mob/living/critter/small_animal/mouse/weak/mentor/admin))
			var/mob/living/critter/small_animal/animal_target = target
			if (animal_target.mind == null)
				actions.start(new/datum/action/bar/private/icon/brain_slug_infest(animal_target, TRUE, src), holder.owner)
			else
				boutput(holder.owner, "<span class='notice'>This creature looks much too lively to infest.</span>")
		return 0

	onAttach(datum/abilityHolder/holder)
		..()
		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")
