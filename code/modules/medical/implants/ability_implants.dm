// ----------------------------------------
// Ability implant parent
// ----------------------------------------

/obj/item/implant/ability
	abilities = list(/obj/ability_button/implant)
	var/ability_icon_state = null //Override the icon state on the granted ability button to this

	New()
		. = ..()
		if(!isnull(src.ability_icon_state))
			for(var/obj/ability_button/implant/implant_ability in src.ability_buttons)
				implant_ability.icon_state = src.ability_icon_state

	implanted(mob/M, mob/I)
		. = ..()
		src.set_mob(M)
		src.show_buttons()

	on_remove(mob/M)
		src.hide_buttons()
		. = ..()

	proc/trigger(mob/source)
		return

/obj/ability_button/implant
	name = "Activate Implant"
	icon_state = "implant"
	flags = parent_type::flags | ALLOW_CUFFED_CLICKS

	ability_allowed()
		if (!src.the_item || !src.the_mob)
			return FALSE
		if (is_incapacitated(src.the_mob))
			return FALSE
		if((src.the_item.loc != src.the_mob) || (the_item in the_mob.get_equipped_items()) || the_mob.find_in_hand(the_item))  // If the implant actually implanted in the user
			boutput(src.the_mob, SPAN_ALERT("You need to implant that in yourself to use it!"))
			return FALSE
		if (src.last_use_time && src.cooldown && ( src.last_use_time + cooldown ) > TIME)
			boutput(src.the_mob, SPAN_ALERT("This ability is recharging. ([round((src.cooldown/10)-((TIME - src.last_use_time)/10))] seconds left)"))
			return FALSE
		return TRUE

	execute_ability()
		var/obj/item/implant/ability/ability_implant = src.the_item
		ability_implant.trigger(src.the_mob)
		..()

// ----------------------------------------
// Ability implants
// ----------------------------------------

/obj/item/implant/ability/freedom
	name = "freedom implant"
	icon_state = "implant-r"
	ability_icon_state = "freedom"
	var/uses = 1
	impcolor = "r"
	scan_category = IMPLANT_SCAN_CATEGORY_SYNDICATE

	New()
		src.uses = rand(3, 5)
		..()
		return

	trigger(mob/source)
		if (src.uses < 1)
			return 0

		var/activated = FALSE

		if (source.hasStatus("handcuffed"))
			source.handcuffs.drop_handcuffs(source)
			activated = TRUE

		// Added shackles here (Convair880).
		if (ishuman(source))
			var/mob/living/carbon/human/H = source
			if (H.shoes && H.shoes.chained)
				activated = TRUE
				var/obj/item/clothing/shoes/SH = H.shoes
				H.u_equip(SH)
				SH.set_loc(H.loc)
				H.update_clothing()
				if (SH)
					SH.layer = initial(SH.layer)

		if (activated)
			src.uses--
			boutput(source, "You feel a faint click.")

/obj/item/implant/ability/signaler
	name = "signaler implant"
	icon_state = "implant-r"
	ability_icon_state = "signaler"
	impcolor = "r"
	scan_category = IMPLANT_SCAN_CATEGORY_SYNDICATE
	var/obj/item/device/radio/signaler/signaler = null

	New()
		..()
		src.signaler = new(src)

	implanted(mob/M, mob/I)
		. = ..()
		tgui_process.close_uis(src.signaler)

	attack_self(mob/user)
		return src.signaler.AttackSelf(user)

	trigger(mob/source, emote)
		boutput(source, "You hear a faint beep.")
		signaler.send_signal()
