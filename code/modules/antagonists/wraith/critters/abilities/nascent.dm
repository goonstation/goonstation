/datum/targetable/critter/nascent/become_commander
	name = "Become commander"
	desc = "Become a hallberd-wielding skeleton and summon more bone rattlers."
	icon_state = "choose_skeleton"
	cooldown = 0
	targeted = 0
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = "harbinger_frame"

	cast()
		if (..())
			return TRUE
		var/mob/living/intangible/wraith/W = null
		var/mob/living/critter/wraith/nascent/N = holder.owner
		if(istype(N) && N.master)
			W = N.master
		boutput(holder.owner, "<span class='alert'><b>You become a skeleton commander! Swap intents and use your hallberd arm to do sweeps and stabs!</b></span>")
		var/mob/living/critter/wraith/skeleton_commander/S = new /mob/living/critter/wraith/skeleton_commander(get_turf(holder.owner), W)
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
	desc = "Become a stealthy void hound and prey on people from the shadows."
	icon_state = "choose_hound"
	cooldown = 0
	targeted = 0
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = "harbinger_frame"

	cast()
		if (..())
			return TRUE
		var/mob/living/intangible/wraith/W = null
		if(istype(holder.owner, /mob/living/critter/wraith/nascent))
			var/mob/living/critter/wraith/nascent/N = holder.owner
			if(N.master != null)
				W = N.master
		var/mob/living/critter/wraith/voidhound/S = new /mob/living/critter/wraith/voidhound(get_turf(holder.owner), W)
		var/mob/living/critter/wraith/nascent/N = holder.owner
		boutput(holder.owner, "<span class='alert'><b>You become a voidhound! Stay in the shadows or cloak to heal and regain stamina!</b></span>")
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
	desc = "Become a long range battler able to hold victims down for your friends."
	icon_state = "choose_spiker"
	cooldown = 0
	targeted = 0
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = "harbinger_frame"

	cast()
		if (..())
			return TRUE
		var/mob/living/intangible/wraith/W = null
		if(istype(holder.owner, /mob/living/critter/wraith/nascent))
			var/mob/living/critter/wraith/nascent/N = holder.owner
			if(N.master != null)
				W = N.master
		var/mob/living/critter/wraith/spiker/S = new /mob/living/critter/wraith/spiker(get_turf(holder.owner), W)
		var/mob/living/critter/wraith/nascent/N = holder.owner
		boutput(holder.owner, "<span class='alert'><b>You become a tentacle fiend! Use your hook to bring people to you and lash at them, or shuffle away from danger!</b></span>")
		holder.owner.mind.transfer_to(S)
		holder.owner.unequip_all()
		animate_buff_in(S)
		qdel(N)

	onAttach(datum/abilityHolder/holder)
		..()

		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")
