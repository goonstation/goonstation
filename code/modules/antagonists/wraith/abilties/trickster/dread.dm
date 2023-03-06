/datum/targetable/wraithAbility/dread
	name = "Creeping dread"
	icon_state = "dread"
	desc = "Instill a fear of the dark in a human's mind, causing terror and heart attacks if they do not stay in the light."
	pointCost = 80
	targeted = 1
	cooldown = 1 MINUTE

	cast(mob/target)
		if (..())
			return 1

		if (ishuman(target) && !isdead(target))
			var/mob/living/carbon/human/H = target
			if (H.traitHolder.hasTrait("training_chaplain"))
				boutput(holder.owner, "<span class='notice'>This one does not fear what lurks in the dark. Your effort is wasted.</span>")
				return 0
			boutput(holder.owner, "<span class='notice'>We curse this being with a creeping feeling of dread.</span>")
			H.setStatus("creeping_dread", 30 SECONDS)
			holder.owner.playsound_local(holder.owner, "sound/voice/wraith/wraithspook[pick("1","2")].ogg", 60)
			return 0

		return 1
