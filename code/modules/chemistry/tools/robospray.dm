/obj/item/robospray
	name = "cybernetic hypospray"
	desc = "An automated injector for cyborgs."
	icon = 'icons/obj/chemical.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "syringe_0"
	icon_state = "hypoborg"
	var/inj_amount = 5
	var/sound/sound_inject = 'sound/items/hypo.ogg'
	var/max_fill_amount = 25
	var/list/botreagents = list(
		"charcoal" = 25,
		"epinephrine" = 25,
		"mannitol" = 25,
		"anti_rad" = 25,
		"salbutamol" = 25,
		"saline" = 25
	)
	var/list/available_chems = null
	var/currentreagent = "epinephrine"
	var/propername = "epinephrine"
	var/image/fluid_image
	var/extra_refill = 0

	hide_attack = 2
	inventory_counter_enabled = 1

	New()
		..()
		processing_items.Add(src)
		src.update_icon()

	disposing()
		..()
		processing_items.Remove(src)

	proc/update_icon()
		if (botreagents[currentreagent] >= 1)
			if (!src.fluid_image)
				src.fluid_image = image(src.icon, "hypoover", -1)
			var/datum/reagent/R = reagents_cache[src.currentreagent]
			src.fluid_image.color = rgb(R.fluid_r, R.fluid_g, R.fluid_b, 255)
			src.UpdateOverlays(src.fluid_image, "fluid")
		else
			src.UpdateOverlays(null, "fluid")
		src.inventory_counter.update_number(botreagents[currentreagent])
		signal_event("icon_updated")

	attack_self(mob/user as mob)
		if (available_chems == null)
			available_chems = list()
			for (var/reagent in botreagents)
				available_chems += reagents_cache[reagent]
		var/holder = src.loc
		var/datum/reagent/pick = input(user, "Inject which chemical?", "Cybernetic Hypospray", null) in available_chems
		if (src.loc != holder)
			return
		currentreagent = pick.id
		propername = pick.name
		user.show_text("[src] is now injecting [propername], [botreagents[currentreagent]] units left.", "blue")
		update_icon()
		tooltip_rebuild = 1
		return

	get_desc(dist)
		. += "It is injecting [propername]. There are [botreagents[currentreagent]] units left."
		return

	attack(mob/M as mob, mob/user as mob, def_zone)
		if(ON_COOLDOWN(src, "injection_cooldown", 0.5 SECONDS))
			user.show_text("[src] is still recharging, give it a moment! ", "red")

		if (issilicon(M))
			user.show_text("[src] cannot be used on silicon lifeforms!", "red")
			return

		if (!isliving(M))
			user.show_text("[src] can only be used on the living!", "red")
			return

		if (botreagents[currentreagent] == 0)
			user.show_text("[src] is empty.", "red")
			return

		if(check_target_immunity(M))
			user.show_text("<span class='alert'>You can't seem to inject [M]!</span>")
			return

		var/amt_prop = min(inj_amount, botreagents[currentreagent])

		user.visible_message("<span class='notice'><B>[user] injects [M] with [amt_prop] units of [propername].</B></span>",\
		"<span class='notice'>You inject [amt_prop] units of [propername]. [src] now contains [botreagents[currentreagent] - amt_prop] units.</span>")
		logTheThing("combat", user, M, "uses a cybernetic hypospray to inject [constructTarget(M,"combat")] with [amt_prop] units of [propername] at [log_loc(user)].")

		M.reagents.add_reagent(currentreagent, amt_prop)
		botreagents[currentreagent] = botreagents[currentreagent] - amt_prop
		tooltip_rebuild = 1
		update_icon()
		playsound(M, src.sound_inject, 80, 0)
		return 0

	process()
		..()
		var/refill_amount = last_tick_duration + extra_refill
		extra_refill = refill_amount - round(refill_amount)
		refill_amount = round(refill_amount)

		for(var/reagent in botreagents)
			var/amt = botreagents[reagent]
			if(amt >= max_fill_amount)
				continue

			botreagents[reagent] = min(amt + refill_amount, max_fill_amount)
			if (reagent == currentreagent)
				tooltip_rebuild = 1
				update_icon()

		return 0

