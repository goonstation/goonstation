/datum/targetable/critter/nascent
	border_icon = 'icons/mob/wraith_ui.dmi'
	border_icon_state = "harbinger_frame"

/datum/targetable/critter/nascent/become_commander
	name = "Become commander"
	desc = "Become a halberd-wielding skeleton and summon more bone rattlers."
	icon_state = "choose_skeleton"
	cooldown = 0
	targeted = 0

	cast()
		if (..())
			return TRUE
		var/mob/living/intangible/wraith/W = null
		var/mob/living/critter/wraith/nascent/N = holder.owner
		if(istype(N) && N.master)
			W = N.master
		boutput(holder.owner, SPAN_ALERT("<b>You become a skeleton commander! Swap intents and use your halberd arm to do sweeps and stabs!</b>"))
		var/mob/living/critter/wraith/skeleton_commander/S = new /mob/living/critter/wraith/skeleton_commander(get_turf(holder.owner), W)
		holder.owner.mind.transfer_to(S)
		holder.owner.unequip_all()
		animate_buff_in(S)
		qdel(N)

/datum/targetable/critter/nascent/become_voidhound
	name = "Become voidhound"
	desc = "Become a stealthy void hound and prey on people from the shadows."
	icon_state = "choose_hound"
	cooldown = 0
	targeted = 0

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
		boutput(holder.owner, SPAN_ALERT("<b>You become a voidhound! Stay in the shadows or cloak to heal and regain stamina!</b>"))
		holder.owner.mind.transfer_to(S)
		holder.owner.unequip_all()
		animate_buff_in(S)
		qdel(N)

/datum/targetable/critter/nascent/become_spiker
	name = "Become ranged"
	desc = "Become a long range battler able to hold victims down for your friends."
	icon_state = "choose_spiker"
	cooldown = 0
	targeted = 0

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
		boutput(holder.owner, SPAN_ALERT("<b>You become a tentacle fiend! Use your hook to bring people to you and lash at them, or shuffle away from danger!</b>"))
		holder.owner.mind.transfer_to(S)
		holder.owner.unequip_all()
		animate_buff_in(S)
		qdel(N)
