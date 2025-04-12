/datum/abilityHolder/wraith
	topBarRendered = 1
	pointName = "Wraith Points"
	cast_while_dead = 1
	/// total souls absorbed by this wraith so far
	var/corpsecount = 0
	var/possession_points = 0
	/// number of souls required to evolve into a specialized wraith subclass
	var/absorbs_to_evolve = 3
#ifdef BONUS_POINTS
	corpsecount = 9999
	possession_points = 9999
#endif
	onAbilityStat()
		..()
		.= list()
		.["Points:"] = round(src.points)
		.["Gen. rate:"] = round(src.regenRate + src.lastBonus)
		var/mob/living/intangible/wraith/wraith_trickster/W
		if (istype(owner, /mob/living/intangible/wraith/wraith_trickster))
			W = owner
		else if (istype(owner, /mob/living/critter/wraith/trickster_puppet))
			var/mob/living/critter/wraith/trickster_puppet/TP = owner
			W = TP.master
		if (W != null)
			if (src.possession_points >= W.points_to_possess)
				.["Possess:"] = "<font color=#88ff88>READY</font>"
			else
				.["Possess:"] = "[round(src.possession_points)]/[W.points_to_possess]"

/atom/movable/screen/ability/topBar/wraith
	tens_offset_x = 19
	tens_offset_y = 7
	secs_offset_x = 23
	secs_offset_y = 7

/datum/targetable/wraithAbility
	icon = 'icons/mob/wraith_ui.dmi'
	icon_state = "template"
	cooldown = 0
	last_cast = 0
	targeted = 1
	target_anything = 1
	preferred_holder_type = /datum/abilityHolder/wraith
	ignore_holder_lock = 1 //So we can still do things while our summons are coming
	theme = "wraith"
	show_tooltip = FALSE
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = null
	var/min_req_dist = INFINITY		//What minimum distance from your power well (marker/wraith master) the poltergeist needs to case this spell.

	New()
		var/atom/movable/screen/ability/topBar/wraith/B = new /atom/movable/screen/ability/topBar/wraith(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B

	allowcast()
		var/mob/living/intangible/wraith/W = holder.owner
		if (istype(W) && W.forced_manifest)
			return
		return ..()

	cast(atom/target)
		. = ..()
		if (ispoltergeist(src.holder.owner))
			var/mob/living/intangible/wraith/poltergeist/P = src.holder.owner
			if (src.min_req_dist <= P.power_well_dist)
				boutput(src.holder.owner, SPAN_ALERT("You must be within [min_req_dist] tiles from a well of power to perform this task."))
				return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if (iswraith(src.holder.owner))
			var/mob/living/intangible/wraith/W = src.holder.owner
			if (W.forced_manifest == TRUE)
				boutput(W, SPAN_ALERT("You have been forced to manifest! You can't use any abilities for now!"))
				return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		return CAST_ATTEMPT_SUCCESS

	doCooldown()
		if (!holder)
			return
		last_cast = world.time + cooldown
		holder.updateButtons()
		SPAWN(cooldown + 5)
			holder?.updateButtons()

	onAttach(datum/abilityHolder/holder)
		..()
		if (istype(holder.owner, /mob/living/intangible/wraith/wraith_decay) || istype(holder.owner, /mob/living/critter/wraith/plaguerat))
			border_state = "plague_frame"
		else if (istype(holder.owner, /mob/living/intangible/wraith/wraith_harbinger))
			border_state = "harbinger_frame"
		else if (istype(holder.owner, /mob/living/intangible/wraith/wraith_trickster) || istype(holder.owner, /mob/living/critter/wraith/trickster_puppet))
			border_state = "trickster_frame"

		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")

/datum/targetable/wraithAbility/help
	name = "Toggle Help Mode"
	desc = "Enter or exit help mode."
	icon_state = "help0"
	targeted = 0
	cooldown = 0
	helpable = 0
	special_screen_loc = "SOUTH,EAST"
	tooltip_options = list("align" = TOOLTIP_TOP | TOOLTIP_RIGHT)

	cast(atom/target)
		if (..())
			return 1
		if (holder.help_mode)
			holder.help_mode = 0
			boutput(holder.owner, SPAN_NOTICE("<strong>Help Mode has been deactivated.</strong>"))
		else
			holder.help_mode = 1
			boutput(holder.owner, SPAN_NOTICE("<strong>Help Mode has been activated. To disable it, click on this button again.</strong>"))
			boutput(holder.owner, SPAN_NOTICE("Hold down Shift, Ctrl or Alt while clicking the button to set it to that key."))
			boutput(holder.owner, SPAN_NOTICE("You will then be able to use it freely by holding that button and left-clicking a tile."))
			boutput(holder.owner, SPAN_NOTICE("Alternatively, you can click with your middle mouse button to use the ability on your current tile."))
		src.object.icon_state = "help[holder.help_mode]"
		holder.updateButtons()

/datum/targetable/wraithAbility/toggle_deadchat
	name = "Toggle deadchat"
	desc = "Silences or re-enables the whispers of the dead."
	icon_state = "hide_chat"
	targeted = 0
	cooldown = 0
	pointCost = 0
	do_logs = FALSE
	interrupt_action_bars = FALSE

	cast(mob/target)
		if (!holder)
			return TRUE

		var/mob/living/intangible/wraith/W = holder.owner

		if (!W)
			return TRUE

		. = ..()
		//hearghosts is checked in deadsay.dm and chatprocs.dm
		W.hearghosts = !W.hearghosts
		if (W.hearghosts)
			src.icon_state = "hide_chat"
			boutput(W, SPAN_NOTICE("Now listening to the dead again."))
		else
			src.icon_state = "show_chat"
			boutput(W, SPAN_NOTICE("No longer listening to the dead."))
		return FALSE

/obj/spookMarker
	name = "Spooky Marker"
	desc = "What is this? You feel like you shouldn't be able to see it, but it has an ominous and slightly mischievous aura."
	icon = 'icons/effects/wraitheffects.dmi'
	icon_state = "acursed"
	// invisibility = INVIS_ALWAYS
	invisibility = INVIS_GHOST
	anchored = ANCHORED
	density = 0
	opacity = 0
	mouse_opacity = 0
	alpha = 100

	New()
		..()
		var/matrix/M = matrix()
		M.Scale(0.75,0.75)
		animate(src, transform = M, time = 3 SECONDS, loop = -1,easing = ELASTIC_EASING)
