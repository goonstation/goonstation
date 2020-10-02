/obj/item/robospray
	name = "cybernetic hypospray"
	desc = "An automated injector for cyborgs."
	icon = 'icons/obj/chemical.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "syringe_0"
	icon_state = "hypo0"
	var/inj_amount = 5
	var/picker = 1
	var/sound/sound_inject = 'sound/items/hypo.ogg'
	var/botreagents = list(
		"epinephrine" = 25,
		"charcoal" = 25,
		"anti_rad" = 25,
		"saline" = 25,
		"salicylic_acid" = 25,
		"salbutamol" = 25,
		"antihistamine" = 25,
		"mannitol" = 25,
		"proconvertin" = 25,
		"atropine" = 25
	)
	var/currentreagent = "epinephrine"

	hide_attack = 2
	inventory_counter_enabled = 1

	New()
		..()
		processing_items.Add(src)

	attack_self(mob/user as mob)
		picker = picker % length(botreagents) + 1
		currentreagent = botreagents[picker]
		user.show_text("[src] is now injecting [currentreagent], [botreagents[currentreagent]] units left.", "blue")
		return

	attack(mob/M as mob, mob/user as mob, def_zone)
		if(ON_COOLDOWN(src, "injection_cooldown", 0.5 SECONDS))
			user.show_text("[src] is still recharging, give it a moment! ", "red")

		var/datum/reagent/temp_reagent = reagents_cache[currentreagent]
		var/propername = temp_reagent.name

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

		M.reagents.add_reagent(botreagents[picker], amt_prop)
		botreagents[currentreagent] = botreagents[currentreagent] - amt_prop

		playsound(get_turf(M), src.sound_inject, 80, 0)

	process()
		..()
		for(var/reagent in botreagents)
			var/amt = botreagents[reagent]
			if(amt >= 25)
				continue
			if(prob(66))
				botreagents[reagent] += 1
