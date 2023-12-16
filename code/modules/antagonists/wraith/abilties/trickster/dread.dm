/datum/targetable/wraithAbility/dread
	name = "Creeping dread"
	icon_state = "dread"
	desc = "Instill a fear of the dark in a human's mind, causing terror and heart attacks if they do not stay in the light."
	target_anything = FALSE
	pointCost = 80
	cooldown = 1 MINUTE

	cast(mob/living/carbon/human/target)
		. = ..()
		if (target.traitHolder.hasTrait("training_chaplain"))
			boutput(src.holder.owner, SPAN_NOTICE("This one does not fear what lurks in the dark. Your effort is wasted."))
		boutput(src.holder.owner, SPAN_NOTICE("We curse this being with a creeping feeling of dread."))
		target.setStatus("creeping_dread", 30 SECONDS)
		src.holder.owner.playsound_local(holder.owner, "sound/voice/wraith/wraithspook[pick("1","2")].ogg", 60)

	castcheck(mob/living/target)
		. = ..()
		if (!ishuman(target) || isdead(target))
			boutput(src.holder.owner, SPAN_ALERT("We can only instill dread in living humans."))
			return FALSE
