/datum/targetable/spell/clairvoyance
	name = "Clairvoyance"
	desc = "Finds the location of a target."
	icon_state = "clairvoyance"
	targeted = 0
	cooldown = 600
	requires_robes = 1
	cooldown_staff = 1
	voice_grim = 'sound/voice/wizard/ClairvoyanceGrim.ogg'
	voice_fem = 'sound/voice/wizard/ClairvoyanceFem.ogg'
	voice_other = 'sound/voice/wizard/ClairvoyanceLoud.ogg'
	maptext_colors = list("#24639a", "#24bdc6", "#55eec2", "#24bdc6")

	cast()
		if(!holder)
			return
		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("HAIDAN SEEHQ", FALSE, maptext_style, maptext_colors)
		..()

		var/list/mob/targets = list()
		for (var/mob/living/carbon/human/H in mobs)
			LAGCHECK(LAG_LOW)
			targets += H
		if (!length(targets))
			return
		targets = sortNames(targets)
		var/input = tgui_input_list(holder.owner, "Select target", "Clairvoyance", targets)
		var/mob/M = targets[input]
		if (isnull(M) || !holder?.owner)
			return

		var/turf/T = get_turf(M)
		var/area/A = get_area(M)
		if (isnull(T))
			boutput(holder.owner, "<span class='alert'>[M] appears to be trapped in some sort of Schrödinger's cat-like existence neither truly residing in nor completely removed from the universe!</span>")
			return //oh shit they're in null space

		//immunity checks
		if (M.traitHolder.hasTrait("training_chaplain"))
			boutput(holder.owner, "<span class='alert'>[M] has divine protection. Your scrying spell fails!</span>")
			boutput(M, "<span class='alert'>You sense a Wizard's scrying spell!</span>")
			JOB_XP(M, "Chaplain", 2)
			return
		else if(check_target_immunity(M))
			boutput(holder.owner, "<span class='alert'>[M] seems to be warded from the effects!</span>" )
			return
		else if (A.name == "Chapel")
			boutput(holder.owner, "<span class='alert'>Your scrying spell fails! It just can't seem to find [M.real_name].</span>")
			boutput(M, "<span class='alert'>You sense a Wizard's scrying spell!</span>")
			return
		else if (isrestrictedz(M.z))
			boutput(holder.owner, "<span class='alert'><B>[M.real_name]</B> is in some strange place!</span>")
			return

		var/spellstring = "<B>[M.real_name]</B> is "
		if (M.loc != T) //inside something
			if(ismob(M.loc))
				spellstring += "somehow inside of <b>[M.loc]</b> in <b>[A]</b>."
			else
				spellstring += "inside \a <b>[M.loc]</b> in <b>[A]</b>."
		else
			spellstring += "in [A]."
		if (isdead(M))
			spellstring += " They also seem to be dead."

		boutput(holder.owner, "<span class='notice'>[spellstring]</span>")
		return
