// -------------------------
// Martian psychic mindblast
// -------------------------
/datum/targetable/critter/psyblast
	name = "Psyblast"
	desc = "Unleash a powerful psychic blast at a human, knocking them out for a while."
	cooldown = 300
	targeted = 1
	target_anything = 1

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living/carbon/human) in target
			if (!target)
				boutput(holder.owner, SPAN_ALERT("Nothing to psyblast there."))
				return 1
		if (target == holder.owner)
			return 1
		var/mob/living/carbon/human/MT = target
		if (!istype(MT))
			boutput(holder.owner, SPAN_ALERT("Nothing to psyblast there."))
			return 1
		playsound(MT.loc, 'sound/effects/ghost2.ogg', 100, 1)
		if (istype(MT.head, /obj/item/clothing/head/tinfoil_hat) || MT.bioHolder?.HasEffect("psy_resist") == 2)
			if(istype(MT.head, /obj/item/clothing/head/tinfoil_hat))
				boutput(MT, SPAN_NOTICE("Your tinfoil hat protects you from the psyblast!"))
			else
				boutput(MT, SPAN_NOTICE("The psyblast bounces off you harmlessly!"))
			boutput(holder.owner, SPAN_ALERT("That target is protected against psyblasts."))
		else
			boutput(MT, SPAN_ALERT("You are blasted by psychic energy!"))
			MT.changeStatus("unconscious", 7 SECONDS)
			MT.stuttering += 60
			MT.take_brain_damage(20)
			MT.TakeDamage("head", 0, 5, 0, DAMAGE_BURN)
		return 0

	martian
		cast(atom/target)
			if (..())
				return 1
			holder.owner.say("PSYBLAST!", flags = SAYFLAG_IGNORE_STAMINA)
			return 0
