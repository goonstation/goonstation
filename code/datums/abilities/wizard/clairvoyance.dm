/datum/targetable/spell/clairvoyance
	name = "Clairvoyance"
	desc = "Finds the location of a target."
	icon_state = "clairvoyance"
	targeted = 0
	cooldown = 600
	requires_robes = 1
	cooldown_staff = 1
	voice_grim = "sound/voice/wizard/ClairvoyanceGrim.ogg"
	voice_fem = "sound/voice/wizard/ClairvoyanceFem.ogg"
	voice_other = "sound/voice/wizard/ClairvoyanceLoud.ogg"

	cast()
		if(!holder)
			return
		holder.owner.say("HAIDAN SEEHQ")
		..()

		var/list/mob/targets = list()
		for (var/mob/living/carbon/human/H in mobs)
			LAGCHECK(LAG_LOW)
			targets += H

		if (targets.len > 1)
			targets = sortNames(targets)

		var/t1 = input(holder.owner, "Select target", "Clairvoyance") as null|anything in targets
		if (!t1)
			return 1

		var/mob/M = targets[t1]
		if (!M || !ismob(M))
			return 1

		var/atom/target_loc = M.loc
		if (isrestrictedz(holder.owner.z))
			if (!isrestrictedz(M.z))
				boutput(holder.owner, "<span class='notice'><B>[M.real_name]</B> is in [target_loc.loc].</span>")
				return
			else
				boutput(holder.owner, "<span class='alert'><B>[M.real_name]</B> is in some strange place!</span>")
				return
		if (M.traitHolder.hasTrait("training_chaplain"))
			boutput(holder.owner, "<span class='alert'>[M] has divine protection. Your scrying spell fails!</span>")
			boutput(M, "<span class='alert'>You sense a Wizard's scrying spell!</span>")
		else if(check_target_immunity( M ))
			boutput( holder.owner, "<span class='alert'>[M] seems to be warded from the effects!</span>" )
			return 1
		else
			var/spellstring = "<B>[M.real_name]</B> is "
			if (!istype(target_loc, /turf))
				if (target_loc.loc.name == "Chapel")
					spellstring = "<span class='alert'>Your scrying spell fails! It just can't seem to find [M.real_name].</span>"
					boutput(M, "<span class='alert'>You sense a Wizard's scrying spell!</span>")
					return
				if(ismob(target_loc))
					spellstring += "somehow inside <b>[target_loc.name]</b> in <b>[target_loc.loc.loc]</b>."
				else if(istype(target_loc, /obj))
					spellstring += "inside \a <b>[target_loc.name]</b> in <b>[target_loc.loc.loc]</b>."
			else
				spellstring += "in [target_loc.loc]."
			if (isdead(M))
				spellstring += " They also seem to be dead."

			boutput(holder.owner, "<span class='notice'>[spellstring]</span>")
