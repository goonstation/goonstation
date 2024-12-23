/datum/abilityHolder
	var/help_mode = 0
	var/list/abilities = list()
	var/list/suspended = list()
	var/locked = 0

	var/topBarRendered = 1
	var/rendered = 1
	///Is this holder temporarily hidden
	var/hidden = FALSE
	var/datum/targetable/shiftPower = null
	var/datum/targetable/ctrlPower = null
	var/datum/targetable/altPower = null

	var/usesPoints = 1
	var/pointName = ""
	var/notEnoughPointsMessage = SPAN_ALERT("You do not have enough points to use that ability.")
	var/points = 0 //starting points
	var/regenRate = 1 //starting regen
	var/bonus = 0
	var/lastBonus = 0
	var/tabName = "Spells"

	var/mob/owner = null
	var/datum/abilityHolder/relay = null

	var/x_occupied = 0
	var/y_occupied = 0
	var/datum/abilityHolder/composite/composite_owner = null
	var/any_abilities_displayed = 0

	var/cast_while_dead = 0
	var/remove_on_clone = FALSE

	// cirr's effort to make these work like normal huds, take 1
	var/datum/hud/hud

	var/next_update = 0

	var/atom/movable/screen/abilitystat/abilitystat = null

	var/points_last = 0

#ifdef BONUS_POINTS
	points = 99999
#endif

	New(var/mob/M)
		..()
		owner = M
		hud = new()
		if(owner)
			onAttach(owner)

	disposing()
		for (var/atom/movable/screen/S in hud.objects)
			if (hasvar(S, "master") && S:master == src)
				S:master = null
		onRemove(owner)
		hud.clear_master()
		hud.mobs -= src

		if (owner)
			owner.huds -= hud
			owner = null

		if (abilitystat)
			qdel(abilitystat)
			abilitystat = null

		for(var/ability in src.abilities)
			qdel(ability)
		src.abilities = null
		..()

	proc/onLife(var/mult = 1) //failsafe for UI not doing its update correctly elsewhere
		.= 0
		if (points_last != points)
			points_last = points
			src.updateText(0, src.x_occupied, src.y_occupied)

	/// Called just before we're removed from a mob
	proc/onRemove(mob/from_who)
		SHOULD_CALL_PARENT(TRUE)
		from_who?.detach_hud(hud)

	proc/onAttach(mob/to_whom)
		SHOULD_CALL_PARENT(TRUE)
		to_whom.attach_hud(hud)
		if (ishuman(to_whom))
			var/mob/living/carbon/human/H = to_whom
			H.hud?.update_ability_hotbar()

	proc/updateCounters()
		// this is probably dogshit but w/e
		if (!owner || !owner.client)
			return 0

		var/num = 0
		//Z_LOG_DEBUG("Abilities", "updateCounters: [src], owner: [src.owner]")
		for(var/datum/targetable/B in src.abilities)
			//if(istype(B.object, /atom/movable/screen/ability) && !istype(B.object, /atom/movable/screen/ability/topBar))
			if (istype(B.object, /atom/movable/screen/ability/topBar))
				var/atom/movable/screen/ability/topBar/A = B.object
				A.update_cooldown_cost()
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

		if (src.topBarRendered && src.rendered && !src.hidden)

			if (!called_by_owner)
				for(var/atom/movable/screen/ability/A in src.hud.objects)
					src.hud.objects -= A

			var/pos_x = start_x
			var/pos_y = start_y
			for(var/datum/targetable/B in src.abilities)
				if (!istype(B.object, /atom/movable/screen/ability/topBar))
					continue
				if (!B.display_available())
					B.object.screen_loc = null
					continue
				any_abilities_displayed = 1
				var/atom/movable/screen/ability/topBar/button = B.object
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

			src.updateText(0, x_occupied, y_occupied)
			src.abilitystat?.update_on_hud(x_occupied,y_occupied)
			return

		if(src.rendered)
			if(!src.owner || !src.owner.client)
				return

			for(var/datum/targetable/B in src.abilities)
				if(istype(B.object, /atom/movable/screen/ability) && !istype(B.object, /atom/movable/screen/ability/topBar))
					B.object.UpdateIcon()
			return

	proc/updateText(var/called_by_owner = 0)
		if (composite_owner && !called_by_owner)
			composite_owner.updateText()
			return

		if (!abilitystat)
			abilitystat = new
			abilitystat.owner = src

		var/list/lines = list()

		var/i = 0
		var/longest_line = 0
		var/list/stats = onAbilityStat()
		for (var/x in stats)
			var/line_length = length(x) + 1 + max(length(num2text(stats[x])), length(stats[x]))
			longest_line = max(longest_line, line_length)
			lines += "[x] [stats[x]]"
			i++

		abilitystat.maptext = "<span class='vga l vt ol'>[lines.Join("<br>")]</span>"
		abilitystat.maptext_width = longest_line * 9 //font size is 9px

		if (i >= 2)
			abilitystat.maptext_height = i * 15
			abilitystat.maptext_y = -abilitystat.maptext_height + 32
		else
			abilitystat.maptext_height = initial(abilitystat.maptext_height)
			abilitystat.maptext_y = initial(abilitystat.maptext_y)

	proc/deepCopy()
		var/datum/abilityHolder/copy = new src.type
		copy.remove_on_clone = src.remove_on_clone
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
		onRemove(owner)
		owner = newbody
		onAttach(newbody)

	proc/StatAbilities()
		if (!rendered)
			return

		if (!topBarRendered) //Topbar shows abilities, just display the toplevel info in Status
			statpanel(src.tabName)

			var/list/stats = onAbilityStat()
			for (var/x in stats)
				stat(x, stats[x])

			for (var/datum/targetable/spell in src.abilities)
				spell.Stat()

	proc/onAbilityStat()
		return

	proc/deductPoints(cost, target_ah_type)
		if (!usesPoints || cost == 0)
			return

		points -= cost

	proc/addPoints(add_points, target_ah_type)
		if (!usesPoints)
			return

		points += add_points

	proc/suspendAllAbilities()
		src.suspended = src.abilities.Copy()
		src.abilities.len = 0
		src.updateButtons()

	proc/resumeAllAbilities()
		if (src.suspended && length(src.suspended))
			src.abilities = src.suspended
			src.suspended = list()
		src.updateButtons()

	proc/addAbility(var/abilityType)
		if (istext(abilityType))
			abilityType = text2path(abilityType)
		if (!ispath(abilityType))
			return
		if (locate(abilityType) in src.abilities)
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
			if (A == src.altPower)
				src.altPower = null
			if (A == src.ctrlPower)
				src.ctrlPower = null
			if (A == src.shiftPower)
				src.shiftPower = null
			qdel(A)
			return
		src.updateButtons()

	proc/getAbility(var/abilityType)
		RETURN_TYPE(/datum/targetable)
		if (!ispath(abilityType))
			return null
		for (var/datum/targetable/A in src.abilities)
			if (A.type == abilityType)
				return A
		return null

	proc/on_clone()
		if (src.remove_on_clone)
			if (src.composite_owner)
				src.composite_owner.removeHolder(src.type)
			else
				src.owner?.remove_ability_holder(src)

	proc/pointCheck(cost, quiet = FALSE)
		if (!usesPoints)
			return 1
		if (src.points < 0) // Just-in-case fallback.
			logTheThing(LOG_DEBUG, usr, "'s ability holder ([src.type]) was set to an invalid value (points less than 0), resetting.")
			src.points = 0
		if (cost > points)
			if (!quiet)
				boutput(owner, notEnoughPointsMessage)
			return 0
		return 1

	proc/click(atom/target, params)
		if (!owner)
			return 0
		if (params["alt"])
			if (altPower)
				if(!altPower.cooldowncheck())
					boutput(owner, SPAN_ALERT("That ability is on cooldown for [round((altPower.last_cast - world.time) / 10)] seconds."))
					return 0
				altPower.handleCast(target, params)
				return 1
			//else
			//	boutput(owner, SPAN_ALERT("Nothing is bound to alt."))
			return 0
		else if (params["ctrl"])
			if (ctrlPower)
				if(!ctrlPower.cooldowncheck())
					boutput(owner, SPAN_ALERT("That ability is on cooldown for [round((ctrlPower.last_cast - world.time) / 10)] seconds."))
					return 0
				ctrlPower.handleCast(target, params)
				return 1
			//else
			//	boutput(owner, SPAN_ALERT("Nothing is bound to ctrl."))
			return 0
		else if (params["shift"])
			if (shiftPower)
				if(!shiftPower.cooldowncheck())
					boutput(owner, SPAN_ALERT("That ability is on cooldown for [round((shiftPower.last_cast - world.time) / 10)] seconds."))
					return 0
				shiftPower.handleCast(target, params)
				return 1
			//else
			//	boutput(owner, SPAN_ALERT("Nothing is bound to shift."))
			return 0

	proc/actionKey(var/num)
		//Please make sure you return 1 if one of the holders/abilities handled the key.
		for (var/datum/targetable/T in src.abilities)
			if(T.waiting_for_hotkey)
				unbind_action_number(num)
				T.waiting_for_hotkey = 0
				T.action_key_number = num
				boutput(owner, SPAN_NOTICE("Bound [T.name] to [num]."))
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
					boutput(owner, SPAN_ALERT("That ability is on cooldown for [round((T.last_cast - world.time) / 10)] seconds!"))
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
				boutput(owner, SPAN_ALERT("Unbound [T.name] from [num]."))
		updateButtons()
		return 0

	proc/onAbilityHolderInstanceAdd()
		return 0

	proc/remove_unlocks()
		for (var/datum/targetable/geneticsAbility/ability in src.abilities)
			if (!ability.linked_power)
				src.removeAbilityInstance(ability)
		return 0

	proc/set_loc_callback(var/newloc)
		.=0

	///Returns the actual mob currently controlling this holder, in case src.owner and composite_owner.owner differ (eg flockmind in a drone)
	proc/get_controlling_mob()
		return src.composite_owner?.owner || src.owner

/atom/movable/screen/ability
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

	update_icon()
		if (owner.waiting_for_hotkey)
			AddOverlays(src.binding, "binding")
		else
			ClearSpecificOverlays("binding")

		if(owner.action_key_number > -1)
			AddOverlays(set_number_overlay(owner.action_key_number), "action_key_number")
		else
			ClearSpecificOverlays("action_key_number")
		return

	proc/set_number_overlay(var/num)

		switch(num)
			if(1)
				. = src.one
			if(2)
				. = src.two
			if(3)
				. = src.three
			if(4)
				. = src.four
			if(5)
				. = src.five
			if(6)
				. += src.six
			if(7)
				. = src.seven
			if(8)
				. = src.eight
			if(9)
				. = src.nine
			if(0)
				. = src.zero

	// Switch to targeted only if multiple mobs are in range. All screen abilities customize their clicked(),
	// and you have to call this proc there if you want to use it. You also need to set 'target_selection_check = 1'
	// for every spell that should function in this manner.
	// See /atom/movable/screen/ability/wrestler/clicked() for a practical example (Convair880).
	proc/do_target_selection_check()
		var/datum/targetable/spell = owner
		var/use_targeted = 0

		if (!spell || !istype(spell))
			return 0
		if (!spell.holder)
			return 0

		if (spell.target_selection_check == 1)
			var/list/mob/targets = spell.target_reference_lookup()
			if (length(targets) <= 0)
				boutput(owner.holder.owner, SPAN_ALERT("There's nobody in range."))
				use_targeted = 2 // Abort parent proc.
			else if (length(targets) == 1) // Only one guy nearby, but we need the mob reference for handleCast() then.
				use_targeted = 0
				SPAWN(0)
					spell.handleCast(targets[1])
				use_targeted = 2 // Abort parent proc.
			else
				boutput(owner.holder.owner, SPAN_ALERT("<b>Multiple targets detected, switching to manual aiming.</b>"))
				use_targeted = 1

		return use_targeted

	//WIRE TOOLTIPS
	MouseEntered(location, control, params)
		if (src?.owner && usr.client.tooltipHolder && control == "mapwindow.map")
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

/atom/movable/screen/abilitystat
	maptext_x = 6
	maptext_y = -7
	maptext_width = 120
	maptext_height = 32
	name = "Abilities Text"

	var/datum/abilityHolder/owner = null

	New()
		..()
		SPAWN(1 SECOND) //sorry, some race condition i couldt figure out
			if (ishuman(owner?.owner))
				var/mob/living/carbon/human/H = owner?.owner
				H.hud?.update_ability_hotbar()

	disposing()
		if(owner?.hud)
			owner.hud.remove_object(src)
		..()

	proc/get_controlling_mob()
		var/mob/M = owner.get_controlling_mob()
		if (!istype(M) || !M.client)
			return null
		return M

	proc/update_on_hud(var/pos_x = 0,var/pos_y = 0)
		src.screen_loc = "NORTH-[pos_y],[pos_x]"

		if(owner?.hud)
			owner.hud.remove_object(src)
			owner.hud.add_object(src, HUD_LAYER, src.screen_loc)


/atom/movable/screen/ability/topBar
	var/static/image/ctrl_highlight = image('icons/mob/spell_buttons.dmi',"ctrl")
	var/static/image/shift_highlight = image('icons/mob/spell_buttons.dmi',"shift")
	var/static/image/alt_highlight = image('icons/mob/spell_buttons.dmi',"alt")
	var/static/image/cooldown = image('icons/mob/spell_buttons.dmi',"cooldown")
	var/static/image/darkener = image('icons/mob/spell_buttons.dmi',"darkener")

	var/atom/movable/screen/pseudo_overlay/cd_tens
	var/atom/movable/screen/pseudo_overlay/cd_secs
	var/tens_offset_x = 19
	var/tens_offset_y = 7
	var/secs_offset_x = 23
	var/secs_offset_y = 7

	var/atom/movable/screen/pseudo_overlay/point_overlay
	var/atom/movable/screen/pseudo_overlay/cooldown_overlay


	//mbc : used for updates called without positioning - just use last poistion
	var/last_x = 0
	var/last_y = 0

	New()
		..()
		var/atom/movable/screen/pseudo_overlay/T = new /atom/movable/screen/pseudo_overlay(src)
		var/atom/movable/screen/pseudo_overlay/S = new /atom/movable/screen/pseudo_overlay(src)

		point_overlay = new /atom/movable/screen/pseudo_overlay()
		cooldown_overlay = new /atom/movable/screen/pseudo_overlay()
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
		SPAWN(0)
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


	update_icon()
		var/mob/M = get_controlling_mob()
		if (!istype(M) || !M.client)
			return null

		if (owner.holder)
			if (src.owner == src.owner.holder.shiftPower)
				AddOverlays(src.shift_highlight, "shift_highlight")
			else
				ClearSpecificOverlays("shift_highlight")

			if (src.owner == owner.holder.ctrlPower)
				AddOverlays(src.ctrl_highlight, "ctrl_highlight")
			else
				ClearSpecificOverlays("ctrl_highlight")

			if (src.owner == owner.holder.altPower)
				AddOverlays(src.alt_highlight, "alt_highlight")
			else
				ClearSpecificOverlays("alt_highlight")

			if (owner.waiting_for_hotkey)
				AddOverlays(src.binding, "binding")
			else
				ClearSpecificOverlays("binding")

		if(owner.action_key_number > -1)
			AddOverlays(set_number_overlay(owner.action_key_number), "action_key_number")
		else
			ClearSpecificOverlays("action_key_number")

		update_cooldown_cost()
		return

	proc/get_controlling_mob()
		var/mob/M = owner.holder.get_controlling_mob()
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
			point_overlay.maptext = null

		if (!owner.allowcast())
			newcolor = rgb(64, 64, 64)
			point_overlay.maptext = "<span class='sh vb r ps2p' style='color: #cc2222;'>X</span>"
			point_overlay.alpha = 255
		else if (on_cooldown > 0)
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

		UpdateIcon()

		if (owner.special_screen_loc)
			src.screen_loc = owner.special_screen_loc
		else
			src.screen_loc = "NORTH-[pos_y],[pos_x]"

		var/name = owner.name
		if (owner.holder)
			if (owner.holder.usesPoints && owner.pointCost)
				name += "<br> Cost: [owner.pointCost] [owner.holder.pointName]"
			if (owner.cooldown)
				name += "<br> Cooldown: [owner.cooldown / 10] s"
			src.name = name

		var/datum/hud/abilityHud
		if(owner.holder)
			// for nice, well-behaved abilities that live in a holder
			abilityHud = owner.holder.composite_owner?.hud || owner.holder.hud
		else
			// for fucking deviant genetics abilities that know neither ethics nor morality
			var/mob/M = get_controlling_mob()
			if(ishuman(M)) // they better fucking be human i'm not dealing with other things getting bioeffects
				var/mob/living/carbon/human/H = M
				abilityHud = H.hud

		if (abilityHud) //BAD BAD, this shouldnt happen but somehow it do
			abilityHud.add_object(src)
		last_x = pos_x
		last_y = pos_y

	clicked(parameters)
		if (!owner.holder || !owner.holder.owner || usr != owner.holder.get_controlling_mob())
			boutput(usr, SPAN_ALERT("You do not own this ability."))
			return
		var/datum/abilityHolder/holder = owner.holder
		var/mob/user = holder.composite_owner?.owner || holder.owner

		if(parameters["left"])
			if (owner.targeted && user.targeting_ability == owner)
				user.targeting_ability = null
				user.update_cursor()
				return

			if (parameters["ctrl"])
				if (owner == holder.altPower || owner == holder.shiftPower)
					boutput(user, SPAN_ALERT("That ability is already bound to another key."))
					return

				if (owner == holder.ctrlPower)
					holder.ctrlPower = null
					boutput(user, SPAN_NOTICE("<b>[owner.name] has been unbound from Ctrl-Click.</b>"))
					holder.updateButtons()
				else
					holder.ctrlPower = owner
					boutput(user, SPAN_NOTICE("<b>[owner.name] is now bound to Ctrl-Click.</b>"))

			else if (parameters["alt"])
				if (owner == holder.shiftPower || owner == holder.ctrlPower)
					boutput(user, SPAN_ALERT("That ability is already bound to another key."))
					return

				if (owner == holder.altPower)
					holder.altPower = null
					boutput(user, SPAN_NOTICE("<b>[owner.name] has been unbound from Alt-Click.</b>"))
					holder.updateButtons()
				else
					holder.altPower = owner
					boutput(user, SPAN_NOTICE("<b>[owner.name] is now bound to Alt-Click.</b>"))

			else if (parameters["shift"])
				if (owner == holder.altPower || owner == holder.ctrlPower)
					boutput(user, SPAN_ALERT("That ability is already bound to another key."))
					return

				if (owner == holder.shiftPower)
					holder.shiftPower = null
					boutput(user, SPAN_NOTICE("<b>[owner.name] has been unbound from Shift-Click.</b>"))
					holder.updateButtons()
				else
					holder.shiftPower = owner
					boutput(user, SPAN_NOTICE("<b>[owner.name] is now bound to Shift-Click.</b>"))

			else
				if (holder.help_mode && owner.helpable)
					boutput(user, SPAN_NOTICE("<b>This is your [owner.name] ability.</b>"))
					boutput(user, SPAN_NOTICE("[owner.desc]"))
					if (owner.holder.usesPoints)
						boutput(user, SPAN_NOTICE("Cost: <strong>[owner.pointCost]</strong>"))
					if (owner.cooldown)
						boutput(user, SPAN_NOTICE("Cooldown: <strong>[owner.cooldown / 10] seconds</strong>"))
				else
					if (!owner.cooldowncheck())
						boutput(holder.owner, SPAN_ALERT("That ability is on cooldown for [round((owner.last_cast - world.time) / 10)] seconds."))
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
				boutput(usr, SPAN_NOTICE("Please press a number to bind this ability to..."))

		owner.holder.updateButtons()

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!owner || !owner.holder || !owner.holder.topBarRendered)
			return
		if (!istype(O,/atom/movable/screen/ability/topBar) || !owner.holder)
			return
		var/atom/movable/screen/ability/source = O
		if (!istype(src.owner) || !istype(source.owner))
			boutput(src.owner, SPAN_ALERT("You may only switch the places of ability buttons."))
			return

		var/index_source = owner.holder.abilities.Find(source.owner)
		var/index_target = owner.holder.abilities.Find(src.owner)
		owner.holder.abilities.Swap(index_source,index_target)
		owner.holder.updateButtons()

/datum/targetable

	var/name = null
	var/desc = null

	var/max_range = 10
	var/disabled = FALSE // For actionbars or sustained actions
	var/last_cast = 0
	var/cooldown = 0
	var/start_on_cooldown = FALSE
	var/datum/abilityHolder/holder
	var/atom/movable/screen/ability/object
	var/pointCost = 0
	var/special_screen_loc = null
	var/helpable = TRUE
	var/cd_text_color = "#FFFFFF"
	var/copiable = TRUE

	var/targeted = FALSE					//! Does this need a target? If FALSE, ability is performed instantly
	var/target_anything = FALSE				//! Can we target absolutely anything?
	var/target_in_inventory = FALSE			//! Can we target items in our inventory?
	var/target_nodamage_check = FALSE 		//! Can we target godmoded mobs?
	var/target_ghosts = FALSE				//! Can we target observers if we see them (ectogoggles)?
	var/target_selection_check = FALSE 		//! See comment in /atom/movable/screen/ability.
	var/lock_holder = TRUE 					//! If FALSE, bypass holder lock when we cast this spell.
	var/ignore_holder_lock = FALSE			//! Can we cast this spell when the holder is locked?
	var/restricted_area_check = FALSE 		//! Are we prohibited from casting this spell in 1 (all of Z2) or 2 (only the VR)?
	var/check_range = TRUE					//! Does this check for range at all?
	var/sticky = FALSE 						//! Targeting stays active after using spell if this is 1. click button again to disable the active spell.
	var/ignore_sticky_cooldown = FALSE		//! If TRUE, Ability will stick to cursor even if ability goes on cooldown after first cast.
	var/interrupt_action_bars = TRUE 		//! If TRUE, we will interrupt any action bars running with the INTERRUPT_ACT flag
	var/cooldown_after_action = FALSE		//! if TRUE, cooldowns will be handled after action bars have ended. Needs action to call afterAction() on end.

	var/action_key_number = -1 //Number hotkey assigned to this ability. Only used if > 0
	var/waiting_for_hotkey = FALSE //If TRUE, the next number hotkey pressed will be bound to this.

	var/preferred_holder_type = /datum/abilityHolder/generic

	var/icon = 'icons/mob/spell_buttons.dmi'
	var/icon_state = "blob-template"

	var/theme = null // for wire's tooltips, it's about time this got varized
	var/tooltip_flags = null

	///do we log casting this action? set false for stuff that doesn't need to be logged, like dancing
	var/do_logs = TRUE

	//DON'T OVERRIDE THIS. OVERRIDE onAttach()!
	// 38 types have overriden this.
	New(datum/abilityHolder/holder)
		SHOULD_CALL_PARENT(FALSE) // I hate this but refactoring /datum/targetable is a big project I'll do some other time
		..()
		src.holder = holder
		if (src.icon && src.icon_state)
			var/atom/movable/screen/ability/topBar/button = new /atom/movable/screen/ability/topBar()
			button.icon = src.icon
			button.icon_state = src.icon_state
			button.owner = src
			button.name = src.name
			button.desc = src.desc
			src.object = button

	disposing()
		if(src.holder?.owner?.targeting_ability == src)
			src.holder.owner.targeting_ability = null
			src.holder.owner.update_cursor()
		if (object?.owner == src)
			if(src.holder?.hud)
				src.holder.hud.remove_object(object)
			qdel(object)
			src.object = null
			src.holder = null
		..()

	proc
		handleCast(atom/target, params)
			var/result = tryCast(target, params)
#ifdef NO_COOLDOWNS
			result = TRUE
#endif
			if (src.cooldown_after_action)
				return // We call afterAction() when ending our action
			// Do cooldown unless we explicitly say not to, OR there was a failure somewhere in the cast() proc which we relay
			if (result != CAST_ATTEMPT_FAIL_NO_COOLDOWN && result != CAST_ATTEMPT_FAIL_CAST_FAILURE)
				doCooldown()
			afterCast()

		/// Handle actual ability effects. This is the one you want to override.
		/// Returns for this proc can be found in defines/abilities.dm.
		cast(atom/target)
			SHOULD_CALL_PARENT(TRUE)
			if (do_logs)
				logCast(target)
			if(interrupt_action_bars)
				actions.interrupt(holder.owner, INTERRUPT_ACT)

		//Use this when you need to do something at the start of the ability where you need the holder or the mob owner of the holder. DO NOT change New()
		onAttach(var/datum/abilityHolder/H)
#ifndef NO_COOLDOWNS
			if (src.start_on_cooldown)
				doCooldown()
#endif
			return

		// Don't remove the holder.locked checks, as lots of people used lag and click-spamming
		// to execute one ability multiple times. The checks hopefully make it a bit more difficult.
		tryCast(atom/target, params)
			if (!holder?.owner)
				logTheThing(LOG_DEBUG, usr, "orphaned ability clicked: [name]. ([holder ? "no owner" : "no holder"])")
				return CAST_ATTEMPT_FAIL_CAST_FAILURE
			if (src.holder.locked && !src.ignore_holder_lock)
				boutput(holder.owner, SPAN_ALERT("You're already casting an ability."))
				return CAST_ATTEMPT_FAIL_NO_COOLDOWN
			if (src.lock_holder)
				src.holder.locked = TRUE
			if (!src.holder.pointCheck(pointCost))
				src.holder.locked = FALSE
				return CAST_ATTEMPT_FAIL_NO_COOLDOWN
			if (!src.holder.cast_while_dead && isdead(holder.owner))
				boutput(holder.owner, SPAN_ALERT("You cannot cast this ability while you are dead."))
				src.holder.locked = FALSE
				return CAST_ATTEMPT_FAIL_NO_COOLDOWN
			if (last_cast > world.time)
				boutput(holder.owner, SPAN_ALERT("That ability is on cooldown for [round((last_cast - world.time) / 10)] seconds."))
				src.holder.locked = FALSE
				return CAST_ATTEMPT_FAIL_NO_COOLDOWN
			if (src.restricted_area_check)
				var/turf/T = get_turf(holder.owner)
				if (!T || !isturf(T))
					boutput(holder.owner, SPAN_ALERT("That ability doesn't seem to work here."))
					src.holder.locked = FALSE
					return CAST_ATTEMPT_FAIL_NO_COOLDOWN
				switch (src.restricted_area_check)
					if (ABILITY_AREA_CHECK_ALL_RESTRICTED_Z)
						if (isrestrictedz(T.z))
							boutput(holder.owner, SPAN_ALERT("That ability doesn't seem to work here."))
							src.holder.locked = FALSE
							return CAST_ATTEMPT_FAIL_NO_COOLDOWN
					if (ABILITY_AREA_CHECK_VR_ONLY)
						var/area/A = get_area(T)
						if (A && istype(A, /area/sim))
							boutput(holder.owner, SPAN_ALERT("You can't use this ability in virtual reality."))
							src.holder.locked = FALSE
							return CAST_ATTEMPT_FAIL_NO_COOLDOWN
			if (src.targeted && src.target_nodamage_check && (target && target != holder.owner && check_target_immunity(target)))
				target.visible_message(SPAN_ALERT("<B>[src.holder.owner]'s attack has no effect on [target] whatsoever!</B>"))
				src.holder.locked = FALSE
				return CAST_ATTEMPT_FAIL_DO_COOLDOWN
			if (!castcheck(target))
				src.holder.locked = FALSE
				return CAST_ATTEMPT_FAIL_NO_COOLDOWN
			var/datum/abilityHolder/localholder = src.holder
			. = cast(target, params)
			if(!QDELETED(localholder))
				localholder.locked = FALSE
				if (!.)
					localholder.deductPoints(pointCost)

		logCast(atom/target)
			if (src.targeted)
				if (!isnull(target))
					logTheThing(LOG_COMBAT, src.holder?.owner, "uses [src.name] on [constructTarget(target, "combat")] at [log_loc(target)]")
			else
				logTheThing(LOG_COMBAT, src.holder?.owner, "uses [src.name] at [log_loc(src.holder?.owner)]")

		updateObject()
			return

		doCooldown()
			var/datum/abilityHolder/localholder = src.holder
			src.last_cast = world.time + src.cooldown
			if(!QDELETED(localholder))
				localholder.updateButtons()

		/// Passive cast checking. Returns TRUE if the cast can proceed.
		/// This fires every update, and is currently only used to gray out buttons/indicate to players that the ability is unusable.
		/// Useful for things like different point requirements or only allowing casts under certain conditions.
		/// Actual logic to prevent the cast from firing should be done in the cast() override too!
		allowcast()
			return 1

		castcheck(atom/target)
			return 1

		cooldowncheck()
			if (src.last_cast > world.time)
				return 0
			return 1

		afterCast()
			return

		/// Used for abilities with action bars which don't want to do cooldowns until after
		afterAction()
			doCooldown()
			afterCast()

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
					boutput(M, SPAN_ALERT("You need to grab hold of the target with your active hand first!"))
					return 0

				var/mob/living/L = GD.affecting
				if (L && ismob(L) && L != M)
					if (GD.state >= state)
						G = GD
					else
						boutput(M, SPAN_ALERT("You need a tighter grip!"))
				else
					boutput(M, SPAN_ALERT("You need to grab hold of the target with your active hand first!"))

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
								boutput(M, SPAN_ALERT("You need a tighter grip!"))
								return 0
					if (isnull(G) || !istype(G))
						boutput(M, SPAN_ALERT("You need to grab hold of [target] first!"))
						return 0
					else
						return G

			return 0

		// See comment in /atom/movable/screen/ability (Convair880).
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

/atom/movable/screen/pseudo_overlay
	// this is hack as all get out
	// but since i cant directly alter the pixel offset of a screen overlay it'll have to do
	name = ""
	mouse_opacity = 0
	layer = 61
	var/x_offset = 0
	var/y_offset = 0
	appearance_flags = RESET_COLOR | LONG_GLIDE | PIXEL_SCALE
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

	on_clone()
		for (var/datum/abilityHolder/H in src.holders)
			H.composite_owner = src
			H.on_clone()
		. = ..()

	//return holder on success, null on fail
	proc/addHolder(holderType)
		for (var/datum/abilityHolder/H in holders)
			if (H.type == holderType)
				return
		holders += new holderType(owner)
		holders[holders.len].composite_owner = src
		updateButtons()

		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.hud?.update_ability_hotbar()
		return holders[holders.len]

	//return holder on success, null on fail
	proc/addHolderInstance(var/datum/abilityHolder/N, keep_owner = FALSE)
		for (var/datum/abilityHolder/H in holders)
			if (H == N)
				return
		holders += N
		N.composite_owner = src
		if (N.owner != owner && !keep_owner)
			N.owner = owner
		N.onAbilityHolderInstanceAdd()
		updateButtons()

		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.hud?.update_ability_hotbar()
		return holders[holders.len]

	proc/removeHolder(holderType)
		for (var/datum/abilityHolder/H in holders)
			if (H.type == holderType)
				H.composite_owner = null
				H.onRemove(src.owner)
				holders -= H
		updateButtons()

		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.hud?.update_ability_hotbar()

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
			for(var/atom/movable/screen/ability/A in src.hud.objects)
				src.hud.remove_object(A)

		x_occupied = start_x
		y_occupied = start_y
		any_abilities_displayed = 0
		if (!src.hidden)
			for (var/datum/abilityHolder/H in holders)
				if (H.topBarRendered || H.rendered)
					H.updateButtons(called_by_owner = 1, start_x = x_occupied, start_y = y_occupied)
					x_occupied = H.x_occupied
					y_occupied = H.y_occupied
					any_abilities_displayed = any_abilities_displayed || H.any_abilities_displayed


		if (src.topBarRendered)
			src.updateText(0, x_occupied, y_occupied)
			src.abilitystat?.update_on_hud(x_occupied,y_occupied)

	onAbilityStat()
		. = list()
		for (var/datum/abilityHolder/H in holders)
			if (H.topBarRendered && H.rendered)
				. += H.onAbilityStat()

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

	StatAbilities()
		for (var/datum/abilityHolder/H in holders)
			H.StatAbilities()

	deductPoints(cost, target_ah_type)
		for (var/datum/abilityHolder/H in holders)
			if (target_ah_type && !istype(H, target_ah_type))
				continue
			H.deductPoints(cost)

	addPoints(add_points, target_ah_type)
		for (var/datum/abilityHolder/H in holders)
			if (target_ah_type && !istype(H, target_ah_type))
				continue
			H.addPoints(add_points)

	suspendAllAbilities()
		for (var/datum/abilityHolder/H in holders)
			H.suspendAllAbilities()

	resumeAllAbilities()
		for (var/datum/abilityHolder/H in holders)
			H.resumeAllAbilities()

	addAbility(var/abilityType)
		if (istext(abilityType))
			abilityType = text2path(abilityType)
		if (!ispath(abilityType))
			return

		var/datum/targetable/tmp_A = abilityType
		var/preferred_holder_type = initial(tmp_A.preferred_holder_type)
		if (holders.len)
			for (var/datum/abilityHolder/H in holders)
				if (istype(H, preferred_holder_type))
					return H.addAbility(abilityType)

		var/datum/abilityHolder/holder
		if (length(src.holders) && (!istype(src.holders[1], /datum/abilityHolder/hidden) || ispath(preferred_holder_type, /datum/abilityHolder/hidden)))
			holder = holders[1]
		else
			holder = src.addHolder(preferred_holder_type)
		var/datum/targetable/ability = holder.addAbility(abilityType)

		src.updateButtons()
		return ability

	removeAbility(var/abilityType)
		if (istext(abilityType))
			abilityType = text2path(abilityType)
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

	pointCheck(cost, quiet = FALSE)
		return 1

	deepCopy()
		var/datum/abilityHolder/composite/copy = new src.type(src.owner)
		for (var/datum/abilityHolder/H in holders)
			copy.holders += H.deepCopy()
		return copy

	transferOwnership(var/newbody)
		for (var/datum/abilityHolder/H in holders)
			H.transferOwnership(newbody)
		..()

	remove_unlocks()
		for (var/datum/abilityHolder/H in holders)
			H.remove_unlocks()

	onLife(var/mult = 1)
		for (var/datum/abilityHolder/H in holders)
			H.onLife(mult)

	set_loc_callback(var/newloc)
		for (var/datum/abilityHolder/H in holders)
			H.set_loc_callback(newloc)
