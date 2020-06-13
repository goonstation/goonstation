/datum/abilityHolder
	var/help_mode = 0
	var/list/abilities = list()
	var/list/suspended = list()
	var/locked = 0

	var/topBarRendered = 1
	var/rendered = 1
	var/datum/targetable/shiftPower = null
	var/datum/targetable/ctrlPower = null
	var/datum/targetable/altPower = null

	var/usesPoints = 1
	var/pointName = ""
	var/notEnoughPointsMessage = "<span class='alert'>You do not have enough points to use that ability.</span>"
	var/points = 0 //starting points
	var/regenRate = 1 //starting regen
	var/bonus = 0
	var/lastBonus = 0
	var/tabName = "Spells"

	var/mob/owner = null

	var/x_occupied = 0
	var/y_occupied = 0
	var/datum/abilityHolder/composite_owner = 0
	var/any_abilities_displayed = 0

	var/cast_while_dead = 0

	// cirr's effort to make these work like normal huds, take 1
	var/datum/hud/hud

	var/next_update = 0

	New(var/mob/M)
		owner = M
		hud = new()
		if(owner)
			owner.attach_hud(hud)

	disposing()
		for (var/obj/screen/S in hud.objects)
			if (hasvar(S, "master") && S:master == src)
				S:master = null
		if (owner)
			owner.detach_hud(hud)
		hud.clear_master()
		hud.mobs -= src

		if (owner)
			owner.huds -= hud
			owner = null
		..()

	proc/onLife(var/mult = 1)
		.= 0

	proc/updateCounters()
		// this is probably dogshit but w/e
		if (!owner || !owner.client)
			return 0

		var/num = 0
		//Z_LOG_DEBUG("Abilities", "updateCounters: [src], owner: [src.owner]")
		for(var/datum/targetable/B in src.abilities)
			//if(istype(B.object, /obj/screen/ability) && !istype(B.object, /obj/screen/ability/topBar))
			if (istype(B.object, /obj/screen/ability/topBar))
				var/obj/screen/ability/topBar/A = B.object
				A.update_cooldown_cost()
				num++

		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			for(var/obj/screen/ability/topBar/genetics/G in H.hud.objects)
				G.update_cooldown_cost()
				num++

		return num


	proc/updateButtons(var/called_by_owner = 0, var/start_x = 1, var/start_y = 0)
		//MBC : sorry, but for things to work correctly in the case of composite with multiple holders (omnitraitor) we need to update via the composite holder only
		//note that the composite holder reads in x_occupied and y_occupied. that's important for positioning over multiple holders.
		if (composite_owner && !called_by_owner)
			composite_owner.updateButtons()
			return

		x_occupied = 0
		y_occupied = 0
		any_abilities_displayed = 0

		if (src.topBarRendered && src.rendered)

			if (!called_by_owner)
				for(var/obj/screen/ability/A in src.hud)
					src.hud -= A

			if (ishuman(owner))
				var/mob/living/carbon/human/H = owner
				// are we viewing genetic powers instead of our item abilities and other abilities?
				// if so, don't bother adding buttons back to hud, keep it empty
				if (H.hud.current_ability_set == 2)
					return

			var/pos_x = start_x
			var/pos_y = start_y
			for(var/datum/targetable/B in src.abilities)
				if (!istype(B.object, /obj/screen/ability/topBar))
					continue
				if (!B.display_available())
					B.object.screen_loc = null
					continue
				any_abilities_displayed = 1
				var/obj/screen/ability/topBar/button = B.object
				button.update_on_hud(pos_x,pos_y)
				button.icon = B.icon
				button.icon_state = B.icon_state
				if (!B.special_screen_loc)
					pos_x++
					if(pos_x > 15)
						pos_x = 1
						pos_y++

			x_occupied = pos_x
			y_occupied = pos_y
			return

		// legacy stat panel button rendering
		// hopefully one day we can just axe this completely
		// wouldn't that be a fuckin' dream come true
		if(src.rendered)
			if(!src.owner || !src.owner.client)
				return

			for(var/datum/targetable/B in src.abilities)
				if(istype(B.object, /obj/screen/ability) && !istype(B.object, /obj/screen/ability/topBar))
					B.object.updateIcon()
			return

	proc/deepCopy()
		var/datum/abilityHolder/copy = new src.type
		for (var/datum/targetable/T in src.suspended)
			if (!T.copiable)
				continue
			copy.addAbility(T.type)
		copy.suspendAllAbilities()
		for (var/datum/targetable/T in src.abilities)
			if (!T.copiable)
				continue
			copy.addAbility(T.type)
		return copy

	proc/addBonus(var/value)
		bonus += value

	proc/generatePoints(var/mult = 1)
		lastBonus = bonus
		points += bonus
		points += regenRate * mult
		bonus = 0

	proc/transferOwnership(var/newbody)
		if(owner)
			owner.detach_hud(hud)
		owner = newbody
		if(owner)
			owner.attach_hud(hud)

	proc/Stat()
		if (usesPoints && pointName != "" && rendered)
			stat(null, " ")
			stat("[src.pointName]:", src.points)
			if (src.regenRate || src.lastBonus)
				stat("Generation Rate:", "[src.regenRate] + [src.lastBonus]")

	proc/StatAbilities()
		if (!rendered)
			return

		if (topBarRendered) //Topbar shows abilities, just display the toplevel info in Status
			statpanel("Status")
			onAbilityStat()
			stat(null, " ")
		else
			statpanel(src.tabName)
			onAbilityStat()
			for (var/datum/targetable/spell in src.abilities)
				spell.Stat()

	proc/onAbilityStat()
		return

	proc/deductPoints(cost)
		if (!usesPoints || cost == 0)
			return

		points -= cost

	proc/suspendAllAbilities()
		src.suspended = src.abilities.Copy()
		src.abilities.len = 0
		src.updateButtons()

	proc/resumeAllAbilities()
		if (src.suspended && src.suspended.len)
			src.abilities = src.suspended
			src.suspended = list()
		src.updateButtons()

	proc/addAbility(var/abilityType)
		if (istext(abilityType))
			abilityType = text2path(abilityType)
		if (!ispath(abilityType))
			return
		if (src.abilities.Find(abilityType))
			return
		var/datum/targetable/A = new abilityType(src)
		A.holder = src // redundant but can't hurt I guess
		src.abilities += A
		A.onAttach(src)
		src.updateButtons()
		return A

	proc/removeAbility(var/abilityType)
		if (istext(abilityType))
			abilityType = text2path(abilityType)
		if (!ispath(abilityType))
			return
		for (var/datum/targetable/A in src.abilities)
			if (A.type == abilityType)
				src.abilities -= A
				if (A == src.altPower)
					src.altPower = null
				if (A == src.ctrlPower)
					src.ctrlPower = null
				if (A == src.shiftPower)
					src.shiftPower = null
				qdel(A)
				return
		src.updateButtons()

	proc/removeAbilityInstance(var/datum/targetable/A)
		if (!istype(A))
			return
		if (A in src.abilities)
			src.abilities -= A
			qdel(A)
			return
		src.updateButtons()

	proc/getAbility(var/abilityType)
		if (!ispath(abilityType))
			return null
		for (var/datum/targetable/A in src.abilities)
			if (A.type == abilityType)
				return A
		return null

	proc/pointCheck(cost)
		if (!usesPoints)
			return 1
		if (src.points < 0) // Just-in-case fallback.
			logTheThing("debug", usr, null, "'s ability holder ([src.type]) was set to an invalid value (points less than 0), resetting.")
			src.points = 0
		if (cost > points)
			boutput(owner, notEnoughPointsMessage)
			return 0
		return 1

	proc/click(atom/target, params)
		if (!owner)
			return 0
		if (params["alt"])
			if (altPower)
				if(!altPower.cooldowncheck())
					boutput(owner, "<span class='alert'>That ability is on cooldown for [round((altPower.last_cast - world.time) / 10)] seconds.</span>")
					return 0
				altPower.handleCast(target, params)
				return 1
			//else
			//	boutput(owner, "<span class='alert'>Nothing is bound to alt.</span>")
			return 0
		else if (params["ctrl"])
			if (ctrlPower)
				if(!ctrlPower.cooldowncheck())
					boutput(owner, "<span class='alert'>That ability is on cooldown for [round((ctrlPower.last_cast - world.time) / 10)] seconds.</span>")
					return 0
				ctrlPower.handleCast(target, params)
				return 1
			//else
			//	boutput(owner, "<span class='alert'>Nothing is bound to ctrl.</span>")
			return 0
		else if (params["shift"])
			if (shiftPower)
				if(!shiftPower.cooldowncheck())
					boutput(owner, "<span class='alert'>That ability is on cooldown for [round((shiftPower.last_cast - world.time) / 10)] seconds.</span>")
					return 0
				shiftPower.handleCast(target, params)
				return 1
			//else
			//	boutput(owner, "<span class='alert'>Nothing is bound to shift.</span>")
			return 0

	proc/actionKey(var/num)
		//Please make sure you return 1 if one of the holders/abilities handled the key.
		for (var/datum/targetable/T in src.abilities)
			if(T.waiting_for_hotkey)
				unbind_action_number(num)
				T.waiting_for_hotkey = 0
				T.action_key_number = num
				boutput(owner, "<span class='notice'>Bound [T.name] to [num].</span>")
				updateButtons()
				return 1

		updateButtons()

		for (var/datum/targetable/T in src.abilities)
			if (T.action_key_number < 0)
				continue
			if(T.action_key_number == num)
				if((T.ignore_sticky_cooldown && !T.cooldowncheck()) || T.cooldowncheck())
					if (!T.targeted)
						T.handleCast()
						return
					else
						if(usr.targeting_ability == T)
							usr.targeting_ability = null
						else
							usr.targeting_ability = T
						usr.update_cursor()
					T.holder.updateButtons()
					return 1
				else
					boutput(owner, "<span class='alert'>That ability is on cooldown for [round((T.last_cast - world.time) / 10)] seconds!</span>")
					return 1
		return 0

	proc/cancel_action_binding()
		for (var/datum/targetable/T in src.abilities)
			T.waiting_for_hotkey = 0
		updateButtons()

	proc/unbind_action_number(var/num)
		for (var/datum/targetable/T in src.abilities)
			if(T.action_key_number == num)
				T.action_key_number = -1
				boutput(owner, "<span class='alert'>Unbound [T.name] from [num].</span>")
		updateButtons()
		return 0

	proc/onAbilityHolderInstanceAdd()
		return 0

	proc/remove_unlocks()
		return 0

	proc/set_loc_callback(var/newloc)
		.=0

/obj/screen/ability
	var/datum/targetable/owner
	var/static/image/binding = image('icons/mob/spell_buttons.dmi',"binding")
	//*screams*
	var/static/image/one = image('icons/mob/spell_buttons.dmi',"1")
	var/static/image/two = image('icons/mob/spell_buttons.dmi',"2")
	var/static/image/three = image('icons/mob/spell_buttons.dmi',"3")
	var/static/image/four = image('icons/mob/spell_buttons.dmi',"4")
	var/static/image/five = image('icons/mob/spell_buttons.dmi',"5")
	var/static/image/six = image('icons/mob/spell_buttons.dmi',"6")
	var/static/image/seven = image('icons/mob/spell_buttons.dmi',"7")
	var/static/image/eight = image('icons/mob/spell_buttons.dmi',"8")
	var/static/image/nine = image('icons/mob/spell_buttons.dmi',"9")
	var/static/image/zero = image('icons/mob/spell_buttons.dmi',"0")

	disposing()
		src.screen_loc = null
		owner = null
		..()

	proc/updateIcon()
		src.overlays.Cut()
		if (owner.waiting_for_hotkey)
			src.overlays += src.binding
		if(owner.action_key_number > -1)
			set_number_overlay(owner.action_key_number)
		return

	proc/set_number_overlay(var/num)
		switch(num)
			if(1)
				src.overlays += src.one
			if(2)
				src.overlays += src.two
			if(3)
				src.overlays += src.three
			if(4)
				src.overlays += src.four
			if(5)
				src.overlays += src.five
			if(6)
				src.overlays += src.six
			if(7)
				src.overlays += src.seven
			if(8)
				src.overlays += src.eight
			if(9)
				src.overlays += src.nine
			if(0)
				src.overlays += src.zero
		return

	// Switch to targeted only if multiple mobs are in range. All screen abilities customize their clicked(),
	// and you have to call this proc there if you want to use it. You also need to set 'target_selection_check = 1'
	// for every spell that should function in this manner.
	// See /obj/screen/ability/wrestler/clicked() for a practical example (Convair880).
	proc/do_target_selection_check()
		var/datum/targetable/spell = owner
		var/use_targeted = 0

		if (!spell || !istype(spell))
			return 0
		if (!spell.holder)
			return 0

		if (spell.target_selection_check == 1)
			var/list/mob/targets = spell.target_reference_lookup()
			if (targets.len <= 0)
				boutput(owner.holder.owner, "<span class='alert'>There's nobody in range.</span>")
				use_targeted = 2 // Abort parent proc.
			else if (targets.len == 1) // Only one guy nearby, but we need the mob reference for handleCast() then.
				use_targeted = 0
				SPAWN_DBG(0)
					spell.handleCast(targets[1])
				use_targeted = 2 // Abort parent proc.
			else
				boutput(owner.holder.owner, "<span class='alert'><b>Multiple targets detected, switching to manual aiming.</b></span>")
				use_targeted = 1

		return use_targeted

	//WIRE TOOLTIPS
	MouseEntered(location, control, params)
		if (src && src.owner && usr.client.tooltipHolder && control == "mapwindow.map")
			usr.client.tooltipHolder.showHover(src, list(
				"params" = params,
				"title" = src.name,
				"content" = (src.desc ? src.desc : null),
				"theme" = src.owner.theme,
				"flags" = src.owner.tooltip_flags
			))

	MouseExited()
		if (usr.client.tooltipHolder)
			usr.client.tooltipHolder.hideHover()

/obj/screen/ability/topBar
	var/static/image/ctrl_highlight = image('icons/mob/spell_buttons.dmi',"ctrl")
	var/static/image/shift_highlight = image('icons/mob/spell_buttons.dmi',"shift")
	var/static/image/alt_highlight = image('icons/mob/spell_buttons.dmi',"alt")
	var/static/image/cooldown = image('icons/mob/spell_buttons.dmi',"cooldown")
	var/static/image/darkener = image('icons/mob/spell_buttons.dmi',"darkener")

	var/obj/screen/pseudo_overlay/cd_tens
	var/obj/screen/pseudo_overlay/cd_secs
	var/tens_offset_x = 19
	var/tens_offset_y = 7
	var/secs_offset_x = 23
	var/secs_offset_y = 7

	var/obj/screen/pseudo_overlay/point_overlay
	var/obj/screen/pseudo_overlay/cooldown_overlay


	//mbc : used for updates called without positioning - just use last poistion
	var/last_x = 0
	var/last_y = 0

	New()
		..()
		var/obj/screen/pseudo_overlay/T = new /obj/screen/pseudo_overlay(src)
		var/obj/screen/pseudo_overlay/S = new /obj/screen/pseudo_overlay(src)

		point_overlay = new /obj/screen/pseudo_overlay()
		cooldown_overlay = new /obj/screen/pseudo_overlay()
		src.vis_contents += point_overlay
		src.vis_contents += cooldown_overlay
		cooldown_overlay.icon = 'icons/mob/spell_buttons.dmi'
		cooldown_overlay.icon_state = "cooldown"
		cooldown_overlay.alpha = 0
		point_overlay.maptext_x = -2
		point_overlay.maptext_y = 2
		cooldown_overlay.pixel_y = 4
		cooldown_overlay.maptext_y = 1
		cooldown_overlay.maptext_x = 1

		T.icon = 'icons/effects/particles_characters.dmi'
		S.icon = 'icons/effects/particles_characters.dmi'
		T.x_offset = tens_offset_x
		T.y_offset = tens_offset_y
		S.x_offset = secs_offset_x
		S.y_offset = secs_offset_y
		cd_tens = T
		cd_secs = S
		if (isnull(darkener)) // fuck. -drsingh
			darkener = image('icons/mob/spell_buttons.dmi',"darkener")
		darkener.alpha = 100
		SPAWN_DBG(0)
			if(owner)
				T.color = owner.cd_text_color
				S.color = owner.cd_text_color

	disposing()
		qdel(point_overlay)
		point_overlay = null
		qdel(cooldown_overlay)
		cooldown_overlay = null
		cd_tens = null
		cd_secs = null
		..()


	updateIcon()
		var/mob/M = get_controlling_mob()
		if (!istype(M) || !M.client)
			return null

		src.overlays = list()
		if (owner.holder)
			if (src == owner.holder.shiftPower)
				src.overlays += src.shift_highlight
			if (src == owner.holder.ctrlPower)
				src.overlays += src.ctrl_highlight
			if (src == owner.holder.altPower)
				src.overlays += src.alt_highlight
			if (owner.waiting_for_hotkey)
				src.overlays += src.binding

		if(owner.action_key_number > -1)
			set_number_overlay(owner.action_key_number)

		update_cooldown_cost()
		return

	proc/get_controlling_mob()
		var/mob/M = owner.holder.owner
		if (!istype(M) || !M.client)
			return null
		return M


	proc/update_cooldown_cost()

		var/newcolor = null

		var/on_cooldown = round((owner.last_cast - world.time) / 10)

		if (owner.pointCost)
			if (owner.pointCost > owner.holder.points)
				newcolor = rgb(64, 64, 64)
				point_overlay.maptext = "<span class='sh vb r ps2p' style='color: #cc2222;'>[owner.pointCost]</span>"
			else
				point_overlay.maptext = "<span class='sh vb r ps2p'>[owner.pointCost]</span>"
		else
			src.maptext = null

		if (on_cooldown > 0)
			newcolor = rgb(96, 96, 96)
			cooldown_overlay.alpha = 255
			cooldown_overlay.maptext = "<span class='sh vb c ps2p'>[min(999, on_cooldown)]</span>"
			point_overlay.alpha = 64
		else
			cooldown_overlay.alpha = 0
			point_overlay.alpha = 255

		if (newcolor != src.color)
			src.color = newcolor




	proc/update_on_hud(var/pos_x = 0,var/pos_y = 0)

		updateIcon()

		if (owner.special_screen_loc)
			src.screen_loc = owner.special_screen_loc
		else
			src.screen_loc = "NORTH-[pos_y],[pos_x]"

		var/name = initial(owner.name)
		if (owner.holder)
			if (owner.holder.usesPoints && owner.pointCost)
				name += "<br> Cost: [owner.pointCost] [owner.holder.pointName]"
			if (owner.cooldown)
				name += "<br> Cooldown: [owner.cooldown / 10] s"
			src.name = name

		var/datum/hud/abilityHud
		if(owner.holder)
			// for nice, well-behaved abilities that live in a holder
			abilityHud = owner.holder.hud
		else
			// for fucking deviant genetics abilities that know neither ethics nor morality
			var/mob/M = get_controlling_mob()
			if(ishuman(M)) // they better fucking be human i'm not dealing with other things getting bioeffects
				var/mob/living/carbon/human/H = M
				abilityHud = H.hud

		abilityHud.add_object(src)
		/*
		abilityHud.remove_object(src.cd_tens)
		abilityHud.remove_object(src.cd_secs)

		var/on_cooldown = round((owner.last_cast - world.time) / 10)
		if (on_cooldown > 0)
			on_cooldown = min(on_cooldown,99)
			src.overlays += src.darkener
			src.overlays += src.cooldown
			if (on_cooldown >= 10)
				src.cd_tens.icon_state = "[get_digit_from_number(on_cooldown,2)]"
				src.cd_tens.screen_loc = "NORTH-[pos_y]:[src.tens_offset_y],[pos_x]:[src.tens_offset_x]"
				abilityHud.add_object(src.cd_tens)
			src.cd_secs.icon_state = "[get_digit_from_number(on_cooldown,1)]"
			src.cd_secs.screen_loc = "NORTH-[pos_y]:[src.secs_offset_y],[pos_x]:[src.secs_offset_x]"
			abilityHud.add_object(src.cd_secs)
		*/
		last_x = pos_x
		last_y = pos_y

	clicked(parameters)
		if (!owner.holder || !owner.holder.owner || usr != owner.holder.owner)
			boutput(usr, "<span class='alert'>You do not own this ability.</span>")
			return
		var/datum/abilityHolder/holder = owner.holder
		var/mob/user = holder.owner

		if(parameters["left"])
			if (owner.targeted && user.targeting_ability == owner)
				user.targeting_ability = null
				user.update_cursor()
				return

			if (parameters["ctrl"])
				if (owner == holder.altPower || owner == holder.shiftPower)
					boutput(user, "<span class='alert'>That ability is already bound to another key.</span>")
					return

				if (owner == holder.ctrlPower)
					holder.ctrlPower = null
					boutput(user, "<span class='notice'><b>[owner.name] has been unbound from Ctrl-Click.</b></span>")
					holder.updateButtons()
				else
					holder.ctrlPower = owner
					boutput(user, "<span class='notice'><b>[owner.name] is now bound to Ctrl-Click.</b></span>")

			else if (parameters["alt"])
				if (owner == holder.shiftPower || owner == holder.ctrlPower)
					boutput(user, "<span class='alert'>That ability is already bound to another key.</span>")
					return

				if (owner == holder.altPower)
					holder.altPower = null
					boutput(user, "<span class='notice'><b>[owner.name] has been unbound from Alt-Click.</b></span>")
					holder.updateButtons()
				else
					holder.altPower = owner
					boutput(user, "<span class='notice'><b>[owner.name] is now bound to Alt-Click.</b></span>")

			else if (parameters["shift"])
				if (owner == holder.altPower || owner == holder.ctrlPower)
					boutput(user, "<span class='alert'>That ability is already bound to another key.</span>")
					return

				if (owner == holder.shiftPower)
					holder.shiftPower = null
					boutput(user, "<span class='notice'><b>[owner.name] has been unbound from Shift-Click.</b></span>")
					holder.updateButtons()
				else
					holder.shiftPower = owner
					boutput(user, "<span class='notice'><b>[owner.name] is now bound to Shift-Click.</b></span>")

			else
				if (holder.help_mode && owner.helpable)
					boutput(user, "<span class='notice'><b>This is your [owner.name] ability.</b></span>")
					boutput(user, "<span class='notice'>[owner.desc]</span>")
					if (owner.holder.usesPoints)
						boutput(user, "<span class='notice'>Cost: <strong>[owner.pointCost]</strong></span>")
					if (owner.cooldown)
						boutput(user, "<span class='notice'>Cooldown: <strong>[owner.cooldown / 10] seconds</strong></span>")
				else
					if (!owner.cooldowncheck())
						boutput(holder.owner, "<span class='alert'>That ability is on cooldown for [round((owner.last_cast - world.time) / 10)] seconds.</span>")
						return

					if (!owner.targeted)
						owner.handleCast()
						return
					else
						user.targeting_ability = owner
						user.update_cursor()
		else if(parameters["middle"])
			if(owner.waiting_for_hotkey)
				holder.cancel_action_binding()
			else
				owner.waiting_for_hotkey = 1
				boutput(usr, "<span class='notice'>Please press a number to bind this ability to...</span>")

		owner.holder.updateButtons()

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!owner || !owner.holder || !owner.holder.topBarRendered)
			return
		if (!istype(O,/obj/screen/ability/topBar) || !owner.holder)
			return
		var/obj/screen/ability/source = O
		if (!istype(src.owner) || !istype(source.owner))
			boutput(src.owner, "<span class='alert'>You may only switch the places of ability buttons.</span>")
			return

		var/index_source = owner.holder.abilities.Find(source.owner)
		var/index_target = owner.holder.abilities.Find(src.owner)
		owner.holder.abilities.Swap(index_source,index_target)
		owner.holder.updateButtons()

/datum/targetable
	var
		name = null
		desc = null

		max_range = 10
		targeted = 0
		target_anything = 0
		target_in_inventory = 0
		last_cast = 0
		cooldown = 100
		start_on_cooldown = 0
		datum/abilityHolder/holder
		obj/screen/ability/object
		pointCost = 0
		special_screen_loc = null
		helpable = 1
		cd_text_color = "#FFFFFF"
		copiable = 1
		target_nodamage_check = 0
		target_selection_check = 0 // See comment in /obj/screen/ability.
		dont_lock_holder = 0 // Bypass holder lock when we cast this spell.
		ignore_holder_lock = 0 // Can we cast this spell when the holder is locked?
		restricted_area_check = 0 // Are we prohibited from casting this spell in 1 (all of Z2) or 2 (only the VR)?
		can_target_ghosts = 0 // Can we target observers if we see them (ectogoggles)?
		check_range = 1 //Does this check for range at all?
		sticky = 0 //Targeting stays active after using spell if this is 1. click button again to disable the active spell.
		ignore_sticky_cooldown = 0 //if 1, Ability will stick to cursor even if ability goes on cooldown after first cast.
		interrupt_action_bars = 1 //if 1, we will interrupt any action bars running with the INTERRUPT_ACT flag

		action_key_number = -1 //Number hotkey assigned to this ability. Only used if > 0
		waiting_for_hotkey = 0 //If 1, the next number hotkey pressed will be bound to this.

		preferred_holder_type = /datum/abilityHolder

		icon = 'icons/mob/spell_buttons.dmi'
		icon_state = "blob-template"

		theme = null // for wire's tooltips, it's about time this got varized
		tooltip_flags = null

	New(datum/abilityHolder/holder)
		..()
		src.holder = holder
		if (src.icon && src.icon_state)
			var/obj/screen/ability/topBar/B = new /obj/screen/ability/topBar(null)
			B.icon = src.icon
			B.icon_state = src.icon_state
			B.owner = src
			B.name = src.name
			B.desc = src.desc
			src.object = B

	disposing()
		if (object && object.owner == src)
			if(src.holder?.hud)
				src.holder.hud.remove_object(object)
			object.owner = null
			qdel(object)
			src.object = null
		..()

	proc
		handleCast(atom/target, params)
			var/result = tryCast(target, params)
			if (result && result != 999)
				last_cast = 0 // reset cooldown
			else if (result != 999)
				doCooldown()
			afterCast()
			holder.updateButtons()

		cast(atom/target)
			if(interrupt_action_bars) actions.interrupt(holder.owner, INTERRUPT_ACT)
			return

		onAttach(var/datum/abilityHolder/H)
			if (src.start_on_cooldown)
				doCooldown()
			return

		// Don't remove the holder.locked checks, as lots of people used lag and click-spamming
		// to execute one ability multiple times. The checks hopefully make it a bit more difficult.
		tryCast(atom/target, params)
			if (!holder || !holder.owner)
				logTheThing("debug", usr, null, "orphaned ability clicked: [name]. ([holder ? "no owner" : "no holder"])")
				return 1
			if (src.holder.locked == 1 && src.ignore_holder_lock != 1)
				boutput(holder.owner, "<span class='alert'>You're already casting an ability.</span>")
				return 999
			if (src.dont_lock_holder != 1)
				src.holder.locked = 1
			if (!holder.pointCheck(pointCost))
				src.holder.locked = 0
				return 1000
			if (!holder.cast_while_dead && isdead(holder.owner))
				boutput(holder.owner, "<span class='alert'>You cannot cast this ability while you are dead.</span>")
				src.holder.locked = 0
				return 999
			if (last_cast > world.time)
				boutput(holder.owner, "<span class='alert'>That ability is on cooldown for [round((last_cast - world.time) / 10)] seconds.</span>")
				src.holder.locked = 0
				return 999
			if (src.restricted_area_check)
				var/turf/T = get_turf(holder.owner)
				if (!T || !isturf(T))
					boutput(holder.owner, "<span class='alert'>That ability doesn't seem to work here.</span>")
					src.holder.locked = 0
					return 999
				switch (src.restricted_area_check)
					if (1)
						if (isrestrictedz(T.z))
							boutput(holder.owner, "<span class='alert'>That ability doesn't seem to work here.</span>")
							src.holder.locked = 0
							return 999
					if (2)
						var/area/A = get_area(T)
						if (A && istype(A, /area/sim))
							boutput(holder.owner, "<span class='alert'>You can't use this ability in virtual reality.</span>")
							src.holder.locked = 0
							return 999
			if (src.targeted && src.target_nodamage_check && (target && target != holder.owner && check_target_immunity(target) == 1))
				target.visible_message("<span class='alert'><B>[src.holder.owner]'s attack has no effect on [target] whatsoever!</B></span>")
				src.holder.locked = 0
				return 998
			if (!castcheck())
				src.holder.locked = 0
				return 998
			. = cast(target, params)
			src.holder.locked = 0
			if (!.)
				holder.deductPoints(pointCost)

		updateObject()
			return

		doCooldown()
			src.last_cast = world.time + src.cooldown

		castcheck()
			return 1

		cooldowncheck()
			if (src.last_cast > world.time)
				return 0
			return 1

		afterCast()
			return

		Stat()
			updateObject(holder.owner)
			stat(null, object)

		// Universal grab check you can use (Convair880).
		grab_check(var/mob/target, var/state = 1, var/dirty = 0)
			if (!holder || state < 1)
				return 0

			var/mob/living/M = holder.owner
			if (!M || !ismob(M))
				return 0

			var/obj/item/grab/G = null

			if (dirty == 1)
				var/obj/item/grab/GD = M.equipped()

				if (!GD || !istype(GD) || (!GD.affecting || !ismob(GD.affecting)))
					boutput(M, __red("You need to grab hold of the target with your active hand first!"))
					return 0

				var/mob/living/L = GD.affecting
				if (L && ismob(L) && L != M)
					if (GD.state >= state)
						G = GD
					else
						boutput(M, __red("You need a tighter grip!"))
				else
					boutput(M, __red("You need to grab hold of the target with your active hand first!"))

				return G

			else
				if (!target || !ismob(target))
					return 0

				if (src.targeted)
					for (var/obj/item/grab/G2 in M)
						if (G2.affecting)
							if (G2.affecting != target)
								continue
							if (G2.affecting == M)
								continue
							if (G2.state >= state)
								G = G2
								break
							else
								boutput(M, __red("You need a tighter grip!"))
								return 0
					if (isnull(G) || !istype(G))
						boutput(M, __red("You need to grab hold of [target] first!"))
						return 0
					else
						return G

			return 0

		// See comment in /obj/screen/ability (Convair880).
		target_reference_lookup()
			var/list/mob/targets = list()

			if (!holder)
				return targets

			var/mob/living/M = holder.owner
			if (!M || !ismob(M))
				return targets

			for (var/mob/living/L in oview(src.max_range, M))
				targets.Add(L)

			return targets

		display_available()
			.= (src.icon && src.icon_state)

		flip_callback()
			.= 0

/obj/screen/pseudo_overlay
	// this is hack as all get out
	// but since i cant directly alter the pixel offset of a screen overlay it'll have to do
	name = ""
	mouse_opacity = 0
	layer = 61
	var/x_offset = 0
	var/y_offset = 0
	appearance_flags = RESET_COLOR
	vis_flags = VIS_INHERIT_ID

/datum/abilityHolder/composite
	var/list/datum/abilityHolder/holders = list()
	rendered = 1
	topBarRendered = 1


	disposing()
		for (var/datum/abilityHolder/H in holders)
			H.dispose()
			H.owner = null
		holders.len = 0
		holders = null
		..()

	proc/addHolder(holderType)
		for (var/datum/abilityHolder/H in holders)
			if (H.type == holderType)
				return
		holders += new holderType(owner)
		holders[holders.len].composite_owner = src
		updateButtons()

	proc/addHolderInstance(var/datum/abilityHolder/N)
		for (var/datum/abilityHolder/H in holders)
			if (H == N)
				return
		holders += N
		if (N.owner != owner)
			N.owner = owner
		N.onAbilityHolderInstanceAdd()
		updateButtons()

	proc/removeHolder(holderType)
		for (var/datum/abilityHolder/H in holders)
			if (H.type == holderType)
				H.composite_owner = 0
				holders -= H
		updateButtons()

	proc/getHolder(holderType)
		for (var/datum/abilityHolder/H in holders)
			if (H.type == holderType)
				return H

	cancel_action_binding()
		for (var/datum/abilityHolder/H in holders)
			H.cancel_action_binding()

	unbind_action_number(var/num)
		for (var/datum/abilityHolder/H in holders)
			H.unbind_action_number(num)
		return 0

	actionKey(var/num)
		var/used = 0

		//2 Steps avoid binding problems with more than 2 holders.
		for (var/datum/abilityHolder/H in holders)
			for (var/datum/targetable/T in H.abilities)
				if(T.waiting_for_hotkey)
					used = H.actionKey(num)
					break
			if(used) return used

		for (var/datum/abilityHolder/H in holders)
			used = H.actionKey(num)
			if(used) return used
		return 0

	updateCounters()
		var/num = 0
		for (var/datum/abilityHolder/H in holders)
			H.updateCounters()
			num++
		return num

	updateButtons(var/called_by_owner = 0, var/start_x = 1, var/start_y = 0)
		if (src.topBarRendered && src.rendered && src.hud)
			for(var/obj/screen/ability/A in src.hud)
				src.hud -= A

		x_occupied = 1
		y_occupied = 0
		any_abilities_displayed = 0
		for (var/datum/abilityHolder/H in holders)
			if (H.topBarRendered || H.rendered)
				H.updateButtons(called_by_owner = 1, start_x = x_occupied, start_y = y_occupied)
				x_occupied = H.x_occupied
				y_occupied = H.y_occupied
				any_abilities_displayed = any_abilities_displayed || H.any_abilities_displayed

	click(atom/target, params)
		// ok, this is not ideal since each ability holder has its own keybinds. That sucks and should be reworked
		. = 0
		for (var/datum/abilityHolder/H in holders)
			. |= H.click(target, params)

	addBonus(var/value)
		for (var/datum/abilityHolder/H in holders)
			H.addBonus(value)

	generatePoints(var/mult = 1)
		for (var/datum/abilityHolder/H in holders)
			H.generatePoints(mult)

	Stat()
		for (var/datum/abilityHolder/H in holders)
			H.Stat()

	StatAbilities()
		for (var/datum/abilityHolder/H in holders)
			H.StatAbilities()

	deductPoints(cost)
		for (var/datum/abilityHolder/H in holders)
			H.deductPoints(cost)

	suspendAllAbilities()
		for (var/datum/abilityHolder/H in holders)
			H.suspendAllAbilities()

	resumeAllAbilities()
		for (var/datum/abilityHolder/H in holders)
			H.resumeAllAbilities()

	addAbility(var/abilityType)
		if (!holders.len)
			return
		if (istext(abilityType))
			abilityType = text2path(abilityType)
		if (!ispath(abilityType))
			return
		var/datum/targetable/A = new abilityType
		for (var/datum/abilityHolder/H in holders)
			if (istype(H, A.preferred_holder_type))
				A.holder = H
				H.abilities += A
				A.onAttach(H)
				//H.updateButtons()
				return A
		var/datum/abilityHolder/X = holders[1]
		A.holder = X
		X.abilities += A
		//X.updateButtons()
		A.onAttach(X)

		src.updateButtons()
		return A

	removeAbility(var/abilityType)
		if (!ispath(abilityType))
			return
		for (var/datum/abilityHolder/H in holders)
			H.removeAbility(abilityType)
		src.updateButtons()

	removeAbilityInstance(var/datum/targetable/A)
		if (!istype(A))
			return
		for (var/datum/abilityHolder/H in holders)
			H.removeAbilityInstance(A)
		src.updateButtons()

	getAbility(var/abilityType)
		if (!ispath(abilityType))
			return null
		for (var/datum/abilityHolder/H in holders)
			var/R = H.getAbility(abilityType)
			if (R)
				return R
		return null

	pointCheck(cost)
		return 1

	deepCopy()
		var/datum/abilityHolder/composite/copy = new src.type(src.owner)
		for (var/datum/abilityHolder/H in holders)
			copy.holders += H.deepCopy()
		return copy

	transferOwnership(var/newbody)
		for (var/datum/abilityHolder/H in holders)
			H.transferOwnership(newbody)
		owner = newbody

	remove_unlocks()
		for (var/datum/abilityHolder/H in holders)
			H.remove_unlocks()

	onLife(var/mult = 1)
		for (var/datum/abilityHolder/H in holders)
			H.onLife(mult)

	set_loc_callback(var/newloc)
		for (var/datum/abilityHolder/H in holders)
			H.set_loc_callback(newloc)
