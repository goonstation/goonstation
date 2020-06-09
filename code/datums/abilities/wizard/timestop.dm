#if ASS_JAM
/datum/targetable/spell/timestop
	name = "Timestop"
	desc = "Za warudo.(please use sparingly and try not to cause runtimes, thanks! -moon)"
	icon_state = "timestop"
	targeted = 0
	cooldown = 450
	requires_robes = 1
	cooldown_staff = 0

	cast()
		if(!holder)
			return
		var/protectuser = 1
		if (!holder.owner.wizard_spellpower())
			boutput(holder.owner, "<span style=\"color:red\">Without your staff to focus your spell, you might be affected!</span>")
			protectuser = 0
		holder.owner.visible_message("<span style=\"color:red\"><b>[holder.owner] begins to cast a spell!</b></span>")
		playsound(holder.owner.loc, "sound/effects/elec_bzzz.ogg", 25, 1, -1)
		if (do_mob(holder.owner, holder.owner, 20))
			holder.owner.say("ZA WARUDO, TOKI WO TOMARE!")
			if(prob(33) && !protectuser)
				timestop(null, 50, 4, FALSE)// does NOT unsub from loops n such. also affects user
			else
				timestop(holder.owner, 50, 4, FALSE)// does NOT unsub from loops n such
#endif