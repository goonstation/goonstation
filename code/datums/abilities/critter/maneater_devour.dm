/datum/action/bar/icon/maneater_devour
	duration = 8 SECONDS
	//no cancelling by moving the maneater. You gotta rip the person right out of their hands!
	interrupt_flags =  INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "devour_over"
	bar_icon_state = "bar"
	border_icon_state = "border"
	color_active = "#d73715"
	color_success = "#3fb54f"
	color_failure = "#8d1422"
	var/mob/living/target
	var/datum/targetable/critter/maneater_devour/originating_ability

/datum/action/bar/icon/maneater_devour/New(victim, devour_ability)
	src.target = victim
	src.originating_ability = devour_ability
	..()

/datum/action/bar/icon/maneater_devour/onUpdate()
	..()

	if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || !originating_ability)
		interrupt(INTERRUPT_ALWAYS)
		return

	var/mob/ownerMob = owner
	var/obj/item/grab/G = ownerMob.equipped()

	if (!istype(G) || G.affecting != target || G.state == GRAB_PASSIVE)
		interrupt(INTERRUPT_ALWAYS)
		return

/datum/action/bar/icon/maneater_devour/onStart()
	..()
	if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || !originating_ability)
		interrupt(INTERRUPT_ALWAYS)
		return

	var/mob/ownerMob = owner
	ownerMob.show_message(SPAN_NOTICE("We must hold still for a moment..."), 1)

/datum/action/bar/icon/maneater_devour/onEnd()
	..()

	var/mob/ownerMob = owner
	if(owner && ownerMob && target && BOUNDS_DIST(owner, target) == 0 && originating_ability)
		boutput(ownerMob, SPAN_NOTICE("You devour [target]!"))
		ownerMob.visible_message(SPAN_ALERT("<B>[ownerMob] hungrily devours [target]!</B>"))
		playsound(ownerMob.loc, 'sound/voice/burp_alien.ogg', 50, 1)
		logTheThing(LOG_COMBAT, ownerMob, "devours [constructTarget(target,"combat")] whole at [log_loc(owner)].")
		//if we got a maneater as a user, we store it because of its unique behaviour
		var/mob/living/critter/plant/maneater/eating_maneater = null
		if (istype(ownerMob, /mob/living/critter/plant/maneater))
			eating_maneater = ownerMob
			//we suppress item vomiting for a bit so it does not start directly
			ON_COOLDOWN(eating_maneater, "item_vomiting", 20 SECONDS)

		//handcuffs have special handling for zipties and such, remove them properly first.
		//kinda creepy to have all that's left of the target be handcuffs, huh
		if(target.hasStatus("handcuffed"))
			target.handcuffs.drop_handcuffs(target)

		//now we take all the other items of the target and move them onto the ground or into the maneater, if it is one

		var/list/obj/item/to_unequip = target.get_unequippable()
		if(length(to_unequip) > 0)
			for (var/obj/item/handled_item in to_unequip)
				target.remove_item(handled_item)
				if (handled_item)
					if (eating_maneater)
						//let's add the devoured item into the maneater to have it spit them out later
						eating_maneater.devoured_items += handled_item
						handled_item.set_loc(eating_maneater)
					else
						handled_item.set_loc(get_turf(ownerMob))
					handled_item.dropped(target)
					handled_item.layer = initial(handled_item.layer)

		//Now, if a maneater has eaten someone, we will boost its stats the same way like it would be if it was fed a human in a tray
		if (eating_maneater)
			var/endurance_bonus = rand(30, 40)
			//now we check if the target has any preferred spices in it and increase the endurance gain accordingly
			if (target.reagents && length(eating_maneater.preferred_spices))
				for (var/spice in eating_maneater.preferred_spices)
					if (target.reagents.has_reagent(spice))
						endurance_bonus += rand(3,8)
			eating_maneater.plantgenes.endurance += min(endurance_bonus, 60)
			eating_maneater.update_health_by_endurance(eating_maneater.plantgenes?.get_effective_value("endurance"), FALSE)


		//Now, once we have all that together, kill the target

		target.ghostize()
		qdel(target)

/datum/action/bar/icon/maneater_devour/onInterrupt()
	..()
	boutput(owner, SPAN_ALERT("Our feasting on [target] has been interrupted!"))

/datum/targetable/critter/maneater_devour
	name = "Devour"
	desc = "Almost instantly devour a human."
	icon_state = "maneater_munch"
	cooldown = 20 SECONDS
	targeted = 1
	target_anything = 1

/datum/targetable/critter/maneater_devour/cast(atom/target)
	if (..())
		return 1
	var/mob/living/caster = holder.owner

	var/obj/item/grab/G = src.grab_check(null, 1, 1)
	if (!G || !istype(G))
		return 1
	var/mob/living/carbon/human/victim = G.affecting

	if (!istype(victim))
		boutput(caster, SPAN_ALERT("This creature isn't suitable for your stomach."))
		return 1

	actions.start(new/datum/action/bar/icon/maneater_devour(victim, src), caster)
	return 0
