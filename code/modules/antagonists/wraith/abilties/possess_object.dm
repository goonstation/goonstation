/datum/targetable/wraithAbility/possessObject
	name = "Possess Object"
	icon_state = "possessobject"
	desc = "Possess and control an everyday object. Freakout level: high."
	targeted = 1
	target_anything = 1
	pointCost = 300
	cooldown = 150 SECONDS //Tweaked this down from 3 minutes to 2 1/2, let's see if that ruins anything

	cast(var/atom/target)
		if (..())
			return 1

		if (src.holder.owner.density)
			boutput(usr, "<span class='alert'>You cannot force your consciousness into a body while corporeal.</span>")
			return 1

		if (istype(target, /obj/item/storage/bible))
			boutput(holder.owner, "<span class='alert'><b>You feel rebuffed by a holy force!<b></span>")

		if (!isitem(target))
			boutput(holder.owner, "<span class='alert'>You cannot possess this!</span>")
			return 1

		boutput(holder.owner, "<span class='alert'><strong>[pick("You extend your will into [target].", "You force [target] to do your bidding.")]</strong></span>")
		usr.playsound_local(usr.loc, 'sound/voice/wraith/wraithpossesobject.ogg', 50, 0)
		var/mob/living/object/O = new/mob/living/object(get_turf(target), target, holder.owner)
		SPAWN(45 SECONDS)
			if (O)
				boutput(O, "<span class='alert'>You feel your control of this vessel slipping away!</span>")
		SPAWN(60 SECONDS) //time limit on possession: 1 minute
			if (O)
				boutput(O, "<span class='alert'><strong>Your control is wrested away! The item is no longer yours.</strong></span>")
				usr.playsound_local(usr.loc, 'sound/voice/wraith/wraithleaveobject.ogg', 50, 0)
				O.death(FALSE)
		return 0
