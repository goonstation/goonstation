/atom/movable/screen/ability/topBar/brain_slug
	clicked(params)
		if (!istype(owner, /datum/targetable/brain_slug))
			return
		if (!owner.holder)
			return
		..()

/datum/abilityHolder/brain_slug
	usesPoints = 1
	regenRate = 0
	pointName = "Stability"
	tabName = "Abilities"
	topBarRendered = 1
	rendered = 1
	points = 500
	var/harvest_count = 0
	onAbilityStat()
		..()
		.= list()
		.["Stability:"] = round(src.points)
		.["Harvests:"] = round(src.harvest_count)

/datum/abilityHolder/brain_slug_master
	usesPoints = 1
	regenRate = 0
	pointName = "Harvests"
	tabName = "Abilities"
	topBarRendered = 1
	rendered = 1
	points = 0
	onAbilityStat()
		..()
		.= list()
		.["Harvests:"] = round(src.points)

ABSTRACT_TYPE(/datum/targetable/brain_slug)
/datum/targetable/brain_slug
	icon = 'icons/mob/brainslug_ui.dmi'
	var/border_icon = 'icons/mob/brainslug_ui.dmi'
	var/border_state = "brain_slug_frame"
	var/while_restrained = TRUE

	onAttach(datum/abilityHolder/holder)
		..()
		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")

	cast(atom/target)
		if (holder.owner.hasStatus("handcuffed") && !src.while_restrained)
			boutput(holder.owner, "<span class='alert'>You cannot do this while handcuffed!</span>")
			return TRUE
		. = ..()

