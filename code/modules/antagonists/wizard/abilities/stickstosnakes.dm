/datum/targetable/spell/stickstosnakes
	name = "Sticks to Snakes"
	desc = "Turns an item into a snake."
	icon_state = "snakes"
	targeted = 1
	cooldown = 150 // TODO
	requires_robes = 1
	offensive = 1
	target_anything = 1
	target_in_inventory = 1
	/*
	voice_grim = 'sound/voice/wizard/weneed.ogg'
	voice_fem = 'sound/voice/wizard/someoneto.ogg'
	voice_other = 'sound/voice/wizard/recordthese.ogg'
	*/
	maptext_colors = list("#ee59e3", "#ee59e3", "#b320c3", "#e59e3", "#b320c3", "#ee59e3")

	cast(atom/target)
		if(!holder)
			return

		. = ..()
		var/has_spellpower = holder.owner.wizard_spellpower(src) // we track spellpower *before* we turn our staff into a snake

		var/atom/movable/stick = null
		if(istype(target, /obj/item) || istype(target, /obj/railing)) // railings are stick-y enough, so
			stick = target
		else if(istype(target, /mob/living/critter/small_animal/snake))
			var/mob/living/critter/small_animal/snake/snek = target
			if(snek.double)
				boutput(holder.owner, SPAN_ALERT("Your wizarding skills are not up to the legendary Triplesnake technique."))
				return 1
			stick = target
		else if(istype(target, /mob))
			var/mob/living/carbon/human/M = target
			stick = M.equipped()
			if(!M.drop_item()) // if drop was unsuccessful
				stick = null
		else if(istype(target, /turf))
			var/list/items = list()
			for(var/obj/item/thing in target.contents)
				items.Add(thing)
			if(items.len)
				stick = pick(items)
		else if(istype(target, /obj/critter/domestic_bee))
			stick = target

		if (ismob(target.loc))
			var/mob/HH = target.loc
			HH.u_equip(target)
			var/atom/movable/AM = target
			AM.set_loc(get_turf(target))
		if (istype(target, /obj/item))
			var/obj/item/I = target
			I.stored?.transfer_stored_item(I, get_turf(I))

		if(!stick)
			boutput(holder.owner, SPAN_ALERT("You must target an item or a person holding one."))
			return 1 // No cooldown when it fails.
		if(!istype(stick.loc, /turf))
			boutput(holder.owner, SPAN_ALERT("It wasn't possible to remove the item from its container, oh no."))
			return 1 // No cooldown when it fails.

		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("STYX TUSNEKS", flags = SAYFLAG_IGNORE_STAMINA, message_params = list("maptext_css_values" = src.maptext_style, "maptext_animation_colours" = src.maptext_colors))
        //..() uncomment this when we have voice files

		var/mob/living/critter/small_animal/snake/snake = new(stick.loc, stick)

		if (!has_spellpower)
			snake.aggressive = 0

		snake.start_expiration(2 MINUTES)

		holder.owner.visible_message(SPAN_ALERT("[holder.owner] turns [stick] into [snake]!"))
		logTheThing(LOG_COMBAT, holder.owner, "casts Sticks to Snakes on [constructTarget(stick,"combat")] turning it into [snake] at [log_loc(snake)].")
		playsound(holder.owner.loc, 'sound/effects/mag_golem.ogg', 25, 1, -1)

	logCast(atom/target)
		return
