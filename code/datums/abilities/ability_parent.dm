/// A thing that holds abilities. Everything has a composite holder, containing all the specific subholders within it.
/// When an ability is added, if we don't have a subholder, we create one of the type specified on the ability's preferred_holder_type.

// A few paradigms around abilityHolders-
// An abilityHolder should (usually) function on every type of mob. It doesn't have to work perfectly, but it shouldn't runtime a lot.
// Thus, if your abilities need any specific vars or tracked state, put them on the holder instead of the mob type (WRAITHS!!!)
// or a mutantrace (THRALLS!!! and WEREWOLVES!!!) or whatever other nonsense. All ability-related state should be here.
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
	var/notEnoughPointsMessage = "<span class='alert'>You do not have enough points to use that ability.</span>"
	var/points = 0 //starting points
	var/regenRate = 0 //starting regen
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
		if (abilityType in src.abilities)
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

	proc/pointCheck(cost)
		if (!usesPoints)
			return 1
		if (src.points < 0) // Just-in-case fallback.
			logTheThing(LOG_DEBUG, usr, "'s ability holder ([src.type]) was set to an invalid value (points less than 0), resetting.")
			src.points = 0
		if (cost > points)
			boutput(owner, notEnoughPointsMessage)
			return 0
		return 1

	proc/click(atom/target, params)
		if (!owner)
			return 0
		var/static/list/params_to_vars = list("alt" = src.altPower,
											  "ctrl" = src.ctrlPower,
											  "shift" = src.shiftPower)

		for (var/param in params_to_vars)
			var/datum/targetable/casting = params_to_vars[params[param]] // lol
			if (casting)
				var/on_cooldown = casting.cooldowncheck()
				if(on_cooldown)
					boutput(owner, "<span class='alert'>That ability is on cooldown for [round(on_cooldown / (1 SECOND))] seconds.</span>")
					return FALSE
				altPower.handleCast(target, params)
				return TRUE
		return FALSE

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
				var/on_cooldown = T.cooldowncheck()
				if((T.ignore_sticky_cooldown && !on_cooldown) || on_cooldown)
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
					return TRUE
				else
					boutput(owner, "<span class='alert'>[T] is on cooldown for [round(on_cooldown)] seconds!</span>")
					return TRUE
		return FALSE

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
			UpdateOverlays(src.binding, "binding")
		else
			UpdateOverlays(null, "binding")

		if(owner.action_key_number > -1)
			UpdateOverlays(set_number_overlay(owner.action_key_number), "action_key_number")
		else
			UpdateOverlays(null, "action_key_number")

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

	//WIRE TOOLTIPS
	MouseEntered(location, control, params)
		if (src?.owner && usr.client.tooltipHolder && control == "mapwindow.map")
			usr.client.tooltipHolder.showHover(src, list(
				"params" = params,
				"title" = src.name,
				"content" = (src.desc || null),
				"theme" = src.owner.theme,
				"flags" = src.owner.tooltip_flags
			))

	MouseExited()
		if (usr.client.tooltipHolder)
			usr.client.tooltipHolder.hideHover()

	/// Immediately casts the spell if it's off cooldown and only has a single target in range, returning FALSE
	/// If there's more than 1 target, or no targets, does nothing and returns TRUE
	/// To use, ability must be targeted and have `shortcut_target_if_available` set to TRUE
	proc/do_target_selection_check()
		SHOULD_NOT_OVERRIDE(TRUE)
		var/datum/targetable/spell = owner
		. = TRUE

		var/list/mob/targets = spell.target_reference_lookup()
		if (length(targets) == 0)
			boutput(owner.holder.owner, "<span class='alert'>There's nobody in range.</span>")
		else if (length(targets) == 1) // Only one guy nearby, but we need the mob reference for handleCast() then.
			SPAWN(0)
				spell.handleCast(targets[1])
			return FALSE // Abort parent proc since we're casting from here instead
		else // >2 targets
			boutput(owner.holder.owner, "<span class='alert'><b>Multiple targets detected, switching to manual aiming.</b></span>")

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
				UpdateOverlays(src.shift_highlight, "shift_highlight")
			else
				UpdateOverlays(null, "shift_highlight")

			if (src.owner == owner.holder.ctrlPower)
				UpdateOverlays(src.ctrl_highlight, "ctrl_highlight")
			else
				UpdateOverlays(null, "ctrl_highlight")

			if (src.owner == owner.holder.altPower)
				UpdateOverlays(src.alt_highlight, "alt_highlight")
			else
				UpdateOverlays(null, "alt_highlight")

			if (owner.waiting_for_hotkey)
				UpdateOverlays(src.binding, "binding")
			else
				UpdateOverlays(null, "binding")

		if(owner.action_key_number > -1)
			UpdateOverlays(set_number_overlay(owner.action_key_number), "action_key_number")
		else
			UpdateOverlays(null, "action_key_number")

		update_cooldown_cost()
		return

	proc/get_controlling_mob()
		var/mob/M = owner.holder.get_controlling_mob()
		if (!istype(M) || !M.client)
			return null
		return M


	proc/update_cooldown_cost()

		var/newcolor = null

		var/on_cooldown = round(src.owner.cooldowncheck())

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
			cooldown_overlay.maptext = "<span class='sh vb c ps2p'>[min(999, round(on_cooldown/(1 SECOND)))]</span>" // on_cooldown is deciseconds, we display seconds
			point_overlay.alpha = 64
		else
			cooldown_overlay.alpha = 0
			point_overlay.alpha = 255

		if (newcolor != src.color)
			src.color = newcolor




	proc/update_on_hud(pos_x = 0, pos_y = 0)
		UpdateIcon()

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
		//SHOULD_CALL_PARENT(TRUE)
		if (!owner.holder || !owner.holder.owner || usr != owner.holder.get_controlling_mob())
			boutput(usr, "<span class='alert'>You do not own this ability.</span>")
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
					var/on_cooldown = owner.cooldowncheck()
					if (on_cooldown)
						boutput(holder.owner, "<span class='alert'>That ability is on cooldown for [round(on_cooldown) / (1 SECOND)] seconds.</span>")
						return

					if (!owner.targeted)
						owner.handleCast()
					else
						if (!owner.shortcut_target_if_available || src.do_target_selection_check())
							user.targeting_ability = owner
							user.update_cursor()
						// if we have shortcut_target_if_available set, and do_target_selection_check() returns FALSE, the spell is already cast in that proc
		else if(parameters["middle"])
			if(owner.waiting_for_hotkey)
				holder.cancel_action_binding()
			else
				owner.waiting_for_hotkey = TRUE
				boutput(usr, "<span class='notice'>Please press a number to bind this ability to...</span>")

		owner.holder.updateButtons()

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!owner || !owner.holder || !owner.holder.topBarRendered)
			return
		if (!istype(O,/atom/movable/screen/ability/topBar) || !owner.holder)
			return
		var/atom/movable/screen/ability/source = O
		if (!istype(src.owner) || !istype(source.owner))
			boutput(src.owner, "<span class='alert'>You may only switch the places of ability buttons.</span>")
			return

		var/index_source = owner.holder.abilities.Find(source.owner)
		var/index_target = owner.holder.abilities.Find(src.owner)
		owner.holder.abilities.Swap(index_source,index_target)
		owner.holder.updateButtons()

///TODO: add a var for that thing where some abilities find a valid target on a turf if a turf isn't provided (for wraiths mostly)
/// Allows me to put checks in castcheck() where they belong and avoid duplication
/datum/targetable

	var/name = null								//! Name, as appears on the ability button
	var/desc = null								//! Description, as appears on the ability button
	var/icon = 'icons/mob/spell_buttons.dmi'	//! Icon for the ability button
	var/icon_state = "blob-template"			//! icon_state for the ability button
	var/atom/movable/screen/ability/object		//! The ability button which appears on the HUD and is clicked to cast the ability

	var/max_range = 1							//! If this is a targetable ability, what is the max range we can target people at. Defaults to adjacent
	var/cooldown = 0							//! Time between ability uses
	var/start_on_cooldown = FALSE				//! If TRUE, ability is put on cooldown immediately after a mob gains it
	var/datum/abilityHolder/holder				//! Ability holder of this ability
	var/pointCost = 0							//! Cost of using this ability
	var/special_screen_loc = null				//! Overrides default positioning for this ability. Standard HUD positioning format
	var/helpable = TRUE							//! Should this ability be cast normally in help mode (FALSE) or should it display help text (TRUE)
	var/cd_text_color = "#FFFFFF"			   //! Color of the maptext placed on the button when the ability is on cooldown. so far unused
	var/copiable = TRUE							//! If this ability should be excluded when deep copying an abilityHolder

	var/disabled = FALSE						//! Ability is disabled and unusable
	var/toggled = FALSE							//! If this ability is a toggle (activating it switches between an on and an off state)
	var/is_on = FALSE							//! If this is a toggled ability, is it turned on?

	/// If this ability can be used while stunned/unconcious. Defaults to strict no for any stuns
	var/incapacitation_restriction = ABILITY_NO_INCAPACITATED_USE
	var/can_cast_while_cuffed = FALSE			//! If this ability can be used while cuffed or otherwise restrained.
	var/can_cast_from_container = TRUE			//! If this ability can be used while inside a non-turf

	var/targeted = FALSE						//! Does this need a target? If FALSE, ability is performed instantly
	var/shortcut_target_if_available = FALSE 	//! If this ability is targeted, should we cast it immediately if only one person is in range?
	var/target_anything = FALSE					//! Can we target things other than mobs?
	var/target_in_inventory = FALSE				//! Can we target items in our inventory?
	var/target_nodamage_check = FALSE 			//! Can we target godmoded mobs?
	var/target_ghosts = FALSE					//! Can we target observers if we see them (ectogoggles)?
	var/target_self = TRUE						//! Can we target ourselves? (to prevent misclicks with negative abilities, mostly)
	var/lock_holder = TRUE 						//! If FALSE, bypass holder lock when we cast this spell.
	var/ignore_holder_lock = FALSE				//! Can we cast this ability when the holder is locked?
	var/restricted_area_check = FALSE 			//! Are we prohibited from casting this spell in 1 (all of Z2) or 2 (only the VR)?
	var/check_range = TRUE						//! Does this check for range at all?
	var/sticky = FALSE 							//! Targeting stays active after using this ability if this is TRUE and the ability isn't on cooldown.
	var/ignore_sticky_cooldown = FALSE			//! If TRUE, Ability targeting will remain active even if ability goes on cooldown after first cast.
	var/interrupt_action_bars = TRUE 			//! If TRUE, we will interrupt any action bars running with the INTERRUPT_ACT flag
	var/cooldown_after_action = FALSE			//! If TRUE, cooldowns will be handled after action bars have ended. Needs action to call afterAction() on end.

	var/action_key_number = -1 					//! Number hotkey assigned to this ability. Only used if > 0
	var/waiting_for_hotkey = FALSE 				//! If TRUE, the next number hotkey pressed will be bound to this.
	var/list/cooldowns							//! Cooldowns list, used for the COOLDOWN macros. easily confused with `cooldown`, sorry
	/// Typepath of the button we want to use. Generic will work 90% of the time, but sometimes we need extra handling.
	var/button_type = /atom/movable/screen/ability/topBar

	/** When applied to a mob, this ability will either add to a holder
	 * 	of the preferred type, or create a new one and add it to the
	 * composite holder if no holder of the preferred type exists */
	var/preferred_holder_type = /datum/abilityHolder/generic

	var/theme = null 							//! Theme for tooltips
	var/tooltip_flags = null					//! Special tooltip flags for nonstandard UIs

	//DON'T OVERRIDE THIS. OVERRIDE onAttach()!
	// 38 types have overriden this.
	New(datum/abilityHolder/holder)
		SHOULD_CALL_PARENT(FALSE) // I hate this but refactoring /datum/targetable is a big project I'll do some other time
		..()
		src.cooldowns = list()
		src.holder = holder
		src.build_button()

	proc/build_button()
		if (src.icon && src.icon_state)
			var/atom/movable/screen/ability/topBar/button = new src.button_type()
			button.icon = src.icon
			button.icon_state = src.icon_state
			button.name = src.name
			button.desc = src.desc
			button.owner = src
			src.object = button
		else
			var/problem
			if (src.icon)
				problem = "no icon_state"
			else
				if (src.icon_state)
					problem = "no icon"
				else
					problem = "no icon and no icon_state"
			stack_trace("Targetable ability [identify_object(src)], owned by [identify_object(src.holder.owner)] being created with [problem].")
			qdel(src)

	disposing()
		if (object?.owner == src)
			if(src.holder?.hud)
				src.holder.hud.remove_object(object)
			qdel(object)
			src.object = null
			src.holder = null
		..()

	proc/handleCast(atom/target, params)
		//SHOULD_NOT_OVERRIDE(TRUE)
		var/datum/abilityHolder/localholder = src.holder
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
		if(!QDELETED(localholder))
			localholder.updateButtons()

	/// Where we actually do the ability effects. Don't put checks in here- that's all handled in tryCast().
	/// If you need additional restrictions on the ability use that the vars don't cover, override castcheck() with those.
	/// return FALSE to deduct points on successful cast, TRUE to not deduct points.
	/// Once again- ONCE THIS PROC IS CALLED, WE HAVE COMMITTED TO CASTING THE ABILITY
	proc/cast(atom/target)
		//SHOULD_CALL_PARENT(TRUE)
		if(interrupt_action_bars)
			actions.interrupt(holder.owner, INTERRUPT_ACT)
		if (!src.toggled) // don't need to know about toggles
			if (ismob(target))
				logTheThing(LOG_COMBAT, holder.owner, "used ability [log_object(src)] on [constructTarget(target,"combat")].")
			else if (target)
				logTheThing(LOG_COMBAT, holder.owner, "used ability [log_object(src)] on [target].")
			else
				logTheThing(LOG_COMBAT, holder.owner, "used ability [log_object(src)].")
		else // if we ARE toggled, then toggle
			src.is_on = !src.is_on
			src.updateObject()
		return FALSE

	//Use this when you need to do something at the start of the ability where you need the holder or the mob owner of the holder. DO NOT change New()
	proc/onAttach(var/datum/abilityHolder/H)
#ifndef NO_COOLDOWNS
		if (src.start_on_cooldown)
			doCooldown()
#endif
		return

	// Don't remove the holder.locked checks, as lots of people used lag and click-spamming
	// to execute one ability multiple times. The checks hopefully make it a bit more difficult.
	proc/tryCast(atom/target, params)
		// SHOULD_CALL_PARENT(TRUE)
		. = CAST_ATTEMPT_SUCCESS
		if (!holder?.owner)
			stack_trace("Orphaned ability used: [identify_object(src)] by [identify_object(usr)]. Issue: ([holder ? "no owning mob" : "no abilityHolder"].)")
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		if (src.holder.locked && !src.ignore_holder_lock)
			boutput(src.holder.owner, "<span class='alert'>You're already casting an ability.</span>")
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN

		if (src.lock_holder)
			src.holder.locked = TRUE

		// Check we have enough points
		if (!src.holder.pointCheck(pointCost))
			boutput(src.holder.owner, "<span class='alert'>You don't have enough points to cast [src.name].</span>")
			. = CAST_ATTEMPT_FAIL_NO_COOLDOWN
		// Check if we're allowed to cast this while dead, if we're dead
		else if (!src.holder.cast_while_dead && isdead(holder.owner))
			boutput(holder.owner, "<span class='alert'>You cannot cast [src.name] while you are dead.</span>")
			. = CAST_ATTEMPT_FAIL_NO_COOLDOWN
		// Check if this ability is disabled for some reason
		else if (src.disabled)
			boutput(holder.owner, "<span class='alert'>[src.name] is disabled.</span>")
			. = CAST_ATTEMPT_FAIL_NO_COOLDOWN
		// Check if we're allowed to cast this while cuffed/restrained, if we're restrained
		else if (!src.can_cast_while_cuffed && src.holder.owner.restrained())
			boutput(src.holder.owner, "<span class='alert'>You cannot cast [src.name] while you're restrained.</span>")
			. = CAST_ATTEMPT_FAIL_NO_COOLDOWN
		// Check if we're allowed to cast this from inside a container.
		else if (!src.can_cast_from_container && !isturf(src.holder.owner.loc))
			boutput(src.holder.owner, "<span class='alert'>You cannot cast [src.name] while inside something else.</span>")
		// Check if the ability is on cooldown
		else if (src.cooldowncheck())
			boutput(src.holder.owner, "<span class='alert'>[src.name] is on cooldown for [src.cooldowncheck() / (1 SECOND)] seconds.</span>")
			. = CAST_ATTEMPT_FAIL_NO_COOLDOWN
		// Check if we're in range
		else if (src.check_range && src.targeted && src.max_range > 0 && GET_DIST(holder.owner, target) > src.max_range)
			boutput(src.holder.owner, "<span class='alert'>[target] is too far away.</span>")
			. = CAST_ATTEMPT_FAIL_NO_COOLDOWN
		// Check if we're allowed to cast on ourselves, if relevant
		else if (!src.target_self && target == src.holder.owner)
			boutput(src.holder.owner, "<span class='alert'>You can't use [src.name] on yourself.</span>")
			. = CAST_ATTEMPT_FAIL_NO_COOLDOWN
		// Check if we're actionable enough to cast this
		else if (!incapacitation_check(src.incapacitation_restriction))
			boutput(src.holder.owner, "<span class='alert'>You can't use [src.name] while incapacitated!</span>")
			. = CAST_ATTEMPT_FAIL_NO_COOLDOWN
		// Check if we're allowed to cast this in a restricted area, if we're in one
		else if (src.restricted_area_check)
			// TODO maybe move to its own proc? bit out of place here
			var/turf/T = get_turf(src.holder.owner)
			if (!isturf(T))
				boutput(src.holder.owner, "<span class='alert'>[src.name] doesn't seem to work here.</span>")
				. = CAST_ATTEMPT_FAIL_NO_COOLDOWN
			else
				switch (src.restricted_area_check)
					if (ABILITY_AREA_CHECK_ALL_RESTRICTED_Z)
						if (isrestrictedz(T.z))
							boutput(holder.owner, "<span class='alert'>[src.name] doesn't seem to work here.</span>")
							. = CAST_ATTEMPT_FAIL_NO_COOLDOWN
					if (ABILITY_AREA_CHECK_VR_ONLY)
						var/area/A = get_area(T)
						if (istype(A, /area/sim))
							boutput(holder.owner, "<span class='alert'>You can't use [src.name] in virtual reality.</span>")
							. = CAST_ATTEMPT_FAIL_NO_COOLDOWN
		// Custom checks by subtypes
		else if (!castcheck(target))
			. = CAST_ATTEMPT_FAIL_NO_COOLDOWN
		// Casting on godmode/immune mob
		else if (src.targeted && src.target_nodamage_check && (target && target != holder.owner && check_target_immunity(target)))
			target.visible_message("<span class='alert'><B>[src.holder.owner]'s attack has no effect on [target] whatsoever!</B></span>")
			. = CAST_ATTEMPT_FAIL_DO_COOLDOWN

		if (. != CAST_ATTEMPT_SUCCESS)
			src.holder.locked = FALSE
			return

		var/datum/abilityHolder/localholder = src.holder
		. = cast(target, params)
		if(!QDELETED(localholder))
			localholder.locked = FALSE
			if (!.)
				localholder.deductPoints(pointCost)

	/// Updates the sprite of the button linked to this ability.
	proc/updateObject()
		if (!src.object)
			stack_trace("Ability [identify_object(src)], owned by [identify_object(src.holder.owner)], lost its ability button. Remaking.")
			src.build_button()
		var/on_cooldown = src.cooldowncheck()
		var/pttxt = ""
		if (src.pointCost)
			pttxt = " \[[src.pointCost]\]"

		if (src.disabled)
			src.object.name = "[src.name] (unavailable)"
			src.object.icon_state = src.icon_state + "_cd"
		else if (on_cooldown)
			src.object.name = "[src.name][pttxt] ([round(on_cooldown)])"
			src.object.icon_state = src.icon_state + "_cd"
		else if (src.toggled)
			if (src.is_on)
				src.object.name = "[src.name][pttxt] (on)"
				src.object.icon_state = src.icon_state
			else
				src.object.name = "[src.name][pttxt] (off)"
				src.object.icon_state = src.icon_state + "_cd"
		else
			if (src.pointCost)
				pttxt = " \[[pointCost]\]"
			src.object.name = "[src.name][pttxt]"
			src.object.icon_state = src.icon_state

	/// Apply the cooldown of this ability- resets cooldown to src.cooldown (or provided number) even if ability is on cooldown already.
	/// 0 is a valid argument so we check for null specifically
	proc/doCooldown(customCooldown)
		SHOULD_CALL_PARENT(TRUE)
		// TODO see if this is actually needed?
		src.holder.updateButtons()
		SPAWN(src.cooldown + 0.5 SECONDS)
			src.holder?.updateButtons()
		return OVERRIDE_COOLDOWN(src, "cast", isnull(customCooldown) ? src.cooldown : customCooldown)

	/// Helper to set an ability's cooldown to 0 (ie make it usable again)
	proc/resetCooldown()
		SHOULD_NOT_OVERRIDE(TRUE)
		return src.doCooldown(0)

	/// Override this proc with any custom casting rules you want, i.e. only casting in certain areas. Return FALSE to prevent cast.
	/// Neat idea- add  a castcheck proc to *abilityHolders* so they can use generic abilities, move holder-wide checks for there.
	/// Call the abilityHolder thing in here, and leave the ability-specific checks with the abilities.
	/// TODO ABILITYHOLDER CASTCHECK
	proc/castcheck(atom/target)
		return TRUE

	/// Checks the cooldown on this ability.
	/// returns FALSE if off cooldown, positive float of time remaining if on cooldown.
	proc/cooldowncheck()
		SHOULD_NOT_OVERRIDE(TRUE)
		return GET_COOLDOWN(src, "cast")

	/// Things we want to do after an ability is cast.
	proc/afterCast()
		return

	/// Used for abilities with action bars which don't want to do cooldowns until after
	proc/afterAction()
		SHOULD_CALL_PARENT(TRUE)
		doCooldown()
		afterCast()

	proc/Stat()
		updateObject(holder.owner)
		stat(null, object)

	/// Grab check for abilities. returns the grab we're using, or FALSE if we don't have a valid or strong enough grab.
	/// Works for off hand and active hand
	proc/grab_check(var/min_state = GRAB_STRONG)
		var/mob/living/user = holder.owner
		if (!isliving(user))
			return FALSE

		var/obj/item/grab/G = user.equipped()
		if (!istype(G))
			// missed active hand, check off hand
			G = user.hand ? user.r_hand : user.l_hand
			if (!istype(G))
				boutput(user, "<span class='alert'>You need to grab hold of the target first!</span>")
				return FALSE

		var/mob/living/L = G.affecting
		if (istype(L) && L != user)
			if (G.state >= min_state)
				return G
			else
				boutput(user, "<span class='alert'>You need a tighter grip!</span>")
				return FALSE
		else
			boutput(user, "<span class='alert'>You need to grab hold of the target first!</span>")
			return FALSE

	/// Check for incapacitation status of the user, with the strictness determined by the arg. Returns FALSE if we can't act, TRUE if we can.
	proc/incapacitation_check(strictness)
		var/mob/living/M = src.holder.owner
		if (!istype(M))
			return TRUE // if you're already dead or some other bizarre thing, then go right ahead
		if (!isalive(M))
			return FALSE
		// If we don't care about stuns, then skip this block and return TRUE right away
		if (strictness != ABILITY_CAN_USE_ALWAYS)
			// If we're stunned or weakened and we're at max stictness, fail and return FALSE
			if (M.hasStatus(list("stunned", "weakened")) && strictness == ABILITY_NO_INCAPACITATED_USE)
				return FALSE
			// Finally, if we're at medium strictness and we don't care about stuns or weakened, only paralysis, just check that one
			if (M.hasStatus("paralysis") && strictness == ABILITY_CAN_USE_WHEN_STUNNED) // this could be an 'else', keeping in case more levels are added later
				return FALSE
		// If we get here, we can cast the ability
		return TRUE

	// See comment in /atom/movable/screen/ability (Convair880).
	proc/target_reference_lookup()
		var/list/mob/targets = list()
		for (var/mob/living/L in oview(src.max_range, src.holder.owner))
			targets.Add(L)

		return targets

	proc/display_available()
		. = (src.icon && src.icon_state)

	proc/flip_callback()
		. = 0

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

		x_occupied = 1
		y_occupied = 0
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
