/datum/abilityHolder/wraith
	pointName = "Wraith Points"
	cast_while_dead = 1
	/// total souls absorbed by this wraith so far
	var/corpsecount = 0
	var/possession_points = 0
	/// number of souls required to evolve into a specialized wraith subclass
	var/absorbs_to_evolve = 3
	onAbilityStat()
		..()
		.= list()
		.["Points:"] = round(src.points)
		.["Gen. rate:"] = round(src.regenRate + src.lastBonus)
		if(istype(owner, /mob/living/intangible/wraith/wraith_trickster) || istype(owner, /mob/living/critter/wraith/trickster_puppet))
			.["Possess:"] = round(src.possession_points)

/atom/movable/screen/ability/topBar/wraith
	tens_offset_x = 19
	tens_offset_y = 7
	secs_offset_x = 23
	secs_offset_y = 7

	MouseEntered(location, control, params)
		if (usr.client.tooltipHolder && control == "mapwindow.map")
			if (!istype(owner, /datum/targetable/wraithAbility/spook))
				var/theme = src.owner.theme

				usr.client.tooltipHolder.showHover(src, list(
					"params" = params,
					"title" = src.name,
					"content" = (src.desc ? src.desc : null),
					"theme" = theme
				))

/datum/targetable/wraithAbility
	icon = 'icons/mob/wraith_ui.dmi'
	icon_state = "template"
	targeted = TRUE
	target_anything = TRUE
	preferred_holder_type = /datum/abilityHolder/wraith
	ignore_holder_lock = TRUE //So we can still do things while our summons are coming
	check_range = FALSE
	theme = "wraith"
	button_type = /atom/movable/screen/ability/topBar/wraith
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = null
	var/min_req_dist = INFINITY		//What minimum distance from your power well (marker/wraith master) the poltergeist needs to case this spell.

	doCooldown(customCooldown)
		. = ..()
		holder.updateButtons()
		SPAWN(cooldown + 0.5 SECONDS)
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

	castcheck(atom/target)
		. = ..()
		if (ispoltergeist(holder.owner))
			var/mob/living/intangible/wraith/poltergeist/P = holder.owner
			if (src.min_req_dist <= P.power_well_dist)
				boutput(holder.owner, "<span class='alert'>You must be within [min_req_dist] tiles from a well of power to perform this task.</span>")
				return FALSE
		if (istype(holder.owner, /mob/living/intangible/wraith))
			var/mob/living/intangible/wraith/W = holder.owner
			if (W.forced_manifest)
				boutput(W, "<span class='alert'>You have been forced to manifest! You can't use any abilities for now!</span>")
				return FALSE

/datum/targetable/wraithAbility/help
	name = "Toggle Help Mode"
	desc = "Enter or exit help mode."
	icon_state = "help0"
	helpable = FALSE
	toggled = TRUE
	special_screen_loc = "SOUTH,EAST"

	cast(atom/target)
		. = ..()
		if (holder.help_mode)
			holder.help_mode = FALSE
			boutput(holder.owner, "<span class='notice'><strong>Help Mode has been deactivated.</strong></span>")
		else
			holder.help_mode = TRUE
			boutput(holder.owner, "<span class='notice'><strong>Help Mode has been activated. To disable it, click on this button again.</strong></span>")
			boutput(holder.owner, "<span class='notice'>Hold down Shift, Ctrl or Alt while clicking the button to set it to that key.</span>")
			boutput(holder.owner, "<span class='notice'>You will then be able to use it freely by holding that button and left-clicking a tile.</span>")
			boutput(holder.owner, "<span class='notice'>Alternatively, you can click with your middle mouse button to use the ability on your current tile.</span>")
		src.object.icon_state = "help[holder.help_mode]"
		holder.updateButtons()

/datum/targetable/wraithAbility/toggle_deadchat
	name = "Toggle deadchat"
	desc = "Silences or re-enables the whispers of the dead."
	icon_state = "hide_chat"
	targeted = FALSE

	cast(mob/target)
		. = ..()
		var/mob/living/intangible/wraith/W = holder.owner

		//hearghosts is checked in deadsay.dm and chatprocs.dm
		W.hearghosts = !W.hearghosts
		if (W.hearghosts)
			src.icon_state = "hide_chat"
			boutput(W, "<span class='notice'>Now listening to the dead again.</span>")
		else
			src.icon_state = "show_chat"
			boutput(W, "<span class='notice'>No longer listening to the dead.</span>")
		return FALSE

/obj/spookMarker
	name = "Spooky Marker"
	desc = "What is this? You feel like you shouldn't be able to see it, but it has an ominous and slightly mischevious aura."
	icon = 'icons/effects/wraitheffects.dmi'
	icon_state = "acursed"
	invisibility = INVIS_SPOOKY
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
