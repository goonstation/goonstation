///////////////////////////////////
//	Nascent abilities, morph into other critters
///////////////////////////////////
/datum/targetable/critter/nascent/become_commander
	name = "Become commander"
	desc = "Become a commander"
	icon_state = "clown_spider_bite"
	cooldown = 0
	targeted = 0
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = "harbinger_frame"

	cast()
		if (..())
			return 1
		var/mob/wraith/W = null
		if(istype(holder.owner, /mob/living/critter/nascent))
			var/mob/living/critter/nascent/N = holder.owner
			if(N.master != null)
				W = N.master
		var/mob/living/critter/skeleton_commander/S = new /mob/living/critter/skeleton_commander(get_turf(holder.owner), W)
		var/mob/living/critter/nascent/N = holder.owner
		holder.owner.mind.transfer_to(S)
		holder.owner.unequip_all()
		animate_buff_in(S)
		qdel(N)

	onAttach(datum/abilityHolder/holder)
		..()

		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")

/datum/targetable/critter/nascent/become_voidhound
	name = "Become voidhound"
	desc = "Become a commander"
	icon_state = "clown_spider_bite"
	cooldown = 0
	targeted = 0
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = "harbinger_frame"

	cast()
		if (..())
			return 1
		var/mob/wraith/W = null
		if(istype(holder.owner, /mob/living/critter/nascent))
			var/mob/living/critter/nascent/N = holder.owner
			if(N.master != null)
				W = N.master
		var/mob/living/critter/voidhound/S = new /mob/living/critter/voidhound(get_turf(holder.owner), W)
		var/mob/living/critter/nascent/N = holder.owner
		holder.owner.mind.transfer_to(S)
		holder.owner.unequip_all()
		animate_buff_in(S)
		qdel(N)

	onAttach(datum/abilityHolder/holder)
		..()

		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")

/datum/targetable/critter/nascent/become_spiker
	name = "Become ranged"
	desc = "Become a commander"
	icon_state = "choose_spiker"
	cooldown = 0
	targeted = 0
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = "harbinger_frame"

	cast()
		if (..())
			return 1
		var/mob/wraith/W = null
		if(istype(holder.owner, /mob/living/critter/nascent))
			var/mob/living/critter/nascent/N = holder.owner
			if(N.master != null)
				W = N.master
		var/mob/living/critter/spiker/S = new /mob/living/critter/spiker(get_turf(holder.owner), W)
		var/mob/living/critter/nascent/N = holder.owner
		holder.owner.mind.transfer_to(S)
		holder.owner.unequip_all()
		animate_buff_in(S)
		qdel(N)

	onAttach(datum/abilityHolder/holder)
		..()

		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")
