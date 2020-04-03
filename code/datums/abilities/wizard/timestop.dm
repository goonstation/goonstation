/datum/targetable/spell/timestop // admin only spell example of how time stop could be used
	name = "Timestop"
	desc = "Za warudo."
	icon_state = "phaseshift"
	targeted = 0
	cooldown = 450
	requires_robes = 1
	cooldown_staff = 1
//	restricted_area_check = 1 // fuckin z level fuckery uncomment this when merging if merging thanks.

	cast()
		if(!holder)
			return
		holder.owner.visible_message("<span style=\"color:red\"><b>[holder.owner] begins to cast a spell!</b></span>")
		playsound(holder.owner.loc, "sound/effects/elec_bzzz.ogg", 25, 1, -1)
		if (do_mob(holder.owner, holder.owner, 20))
			holder.owner.say("ZA WARUDO!")
			timestop(holder.owner, 50, 4, FALSE)// does NOT unsub from loops n such