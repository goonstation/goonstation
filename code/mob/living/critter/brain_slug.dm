/mob/living/critter/brain_slug
	name = "brain slug"
	desc = "A space parasite known to take control of feeble minds."
	hand_count = 0
	custom_gib_handler = /proc/gibs
	icon = 'icons/misc/critter.dmi'
	icon_state = "brain_slug"
	health_brute = 50
	health_burn = 40
	flags = TABLEPASS | DOORPASS
	var/deathsound = "sound/impact_sounds/Generic_Snap_1.ogg"
	pet_text = list("squishes","pokes","slaps","prods curiously")
	speechverb_say = "whispers"
	speechverb_exclaim = "squeals"
	can_throw = 0
	can_grab = 0
	can_disarm = 0
	can_help = 0

	New(var/turf/T)
		..(T)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		src.abilityHolder = new /datum/abilityHolder/brain_slug_master(src)
		src.abilityHolder.addAbility(/datum/targetable/brain_slug/slither)
		src.abilityHolder.addAbility(/datum/targetable/brain_slug/infest_host)
		src.abilityHolder.addAbility(/datum/targetable/brain_slug/exit_host)
		src.abilityHolder.addAbility(/datum/targetable/brain_slug/take_control)

	setup_healths()
		..()
		add_hh_flesh(health_brute, 1)
		add_hh_flesh_burn(health_burn, 1)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/creepyshriek.ogg', 50, 1, 0.2, 1.7, channel=VOLUME_CHANNEL_EMOTE)
					return "<span class='emote'><b>[src]</b> lets out a high pitched shriek!</span>"

	death(var/gibbed)
		if (istype(src.loc, /mob/living/carbon/human))
			var/mob/living/carbon/human/host = src.loc
			host.slug = null
			host.remove_ability_holder(/datum/abilityHolder/brain_slug)
		if (istype(src.loc, /mob/living/critter/small_animal))
			var/mob/living/critter/small_animal/host = src.loc
			host.slug = null
			host.removeAbility(/datum/targetable/brain_slug/exit_host)
			host.removeAbility(/datum/targetable/brain_slug/infest_host)
		if (!gibbed)
			src.unequip_all()
			playsound(src, src.deathsound, 50, 0)
			src.gib()
		return ..()

	disposing()
		if (istype(src.loc, /mob/living/carbon/human))
			var/mob/living/carbon/human/host = src.loc
			host.slug = null
			host.remove_ability_holder(/datum/abilityHolder/brain_slug)
		if (istype(src.loc, /mob/living/critter/small_animal))
			var/mob/living/critter/small_animal/host = src.loc
			host.slug = null
			host.removeAbility(/datum/targetable/brain_slug/exit_host)
			host.removeAbility(/datum/targetable/brain_slug/infest_host)
		. = ..()

/mob/living/critter/brain_slug/is_spacefaring()
	return TRUE

///Gives a brain slug host transfer and basic abilities as well as an ability holder for them.
/mob/proc/add_basic_slug_abilities(var/mob/living/critter/brain_slug/slug = null)
	var/datum/abilityHolder/brain_slug/AH = null
	//Check if they already have a brain slug holder
	if (istype(src.abilityHolder, /datum/abilityHolder/brain_slug))
		AH = src.abilityHolder
	else if (istype(src.abilityHolder, /datum/abilityHolder/composite))
		var/datum/abilityHolder/composite/composite_holder = src.abilityHolder
		for (var/datum/holder in composite_holder.holders)
			if (istype(holder, /datum/abilityHolder/brain_slug))
				AH = holder
	//If they do not, give them one
	if (!AH)
		AH = src.add_ability_holder(/datum/abilityHolder/brain_slug)
	//Set the points to a lower amount if they are a critter
	if (istype(src, /mob/living/critter/small_animal))
		AH.points = 350
	//Then add the abilities
	AH.addAbility(/datum/targetable/brain_slug/exit_host)
	AH.addAbility(/datum/targetable/brain_slug/infest_host)
	AH.addAbility(/datum/targetable/brain_slug/spit_slime)
	AH.addAbility(/datum/targetable/brain_slug/glue_spit)
	AH.addAbility(/datum/targetable/brain_slug/neural_detection)
	//Then set the infestation count to the slug's to keep track
	if (slug)
		AH.infestation_count = slug.abilityHolder.points
	return AH

///Gives a brain slug host dangerous abilities. Used on humans.
/mob/proc/add_advanced_slug_abilities(var/mob/living/critter/brain_slug/the_slug = null)
	var/datum/abilityHolder/AH = null
	AH = src.add_basic_slug_abilities(the_slug)
	if (AH)
		AH.addAbility(/datum/targetable/brain_slug/restraining_spit)
		AH.addAbility(/datum/targetable/brain_slug/acidic_spit)
		AH.addAbility(/datum/targetable/brain_slug/sling_spit)
		AH.addAbility(/datum/targetable/brain_slug/summon_brood)

///Checks if a thing can be infested by a brain slug and returns false if it cant be.
proc/check_host_eligibility(var/mob/living/mob_target, var/mob/caster)
	//Small animals are fair game except mentormice and adminmice for obvious reasons.
	if (istype(mob_target, /mob/living/critter/small_animal) && !istype(mob_target, /mob/living/critter/small_animal/mouse/weak/mentor) && !istype(mob_target, /mob/living/critter/small_animal/mouse/weak/mentor/admin))
		var/mob/living/critter/small_animal/animal_target = mob_target
		if (!isalive(animal_target))
			boutput(caster, "<span class='notice'>You got here a bit late. [animal_target] is already dead.</span>")
			return FALSE
		if (animal_target.mind == null)
			return TRUE
		else
			boutput(caster, "<span class='notice'>This creature looks much too resilient to infest.</span>")
			return FALSE

	//Human corpses are also prime targets, if they are fresh
	else if (ishuman(mob_target))
		if (isalive(mob_target))
			boutput(caster, "<span class='notice'>They are too twitchy to infest. It'd be much easier if they stopped moving. Permanently.</span>")
			return FALSE
		var/mob/living/carbon/human/human_target = mob_target
		if (!mob_target.organHolder.head)
			boutput(caster, "<span class='notice'>Try as you might, you just can't find a head to crawl into.</span>")
			return FALSE
		if (human_target.decomp_stage >= DECOMP_STAGE_BLOATED)
			boutput(caster, "<span class='notice'>That body is sadly too decomposed to use.</span>")
			return FALSE

		if (human_target.abilityHolder)
			if (istype(human_target.abilityHolder,/datum/abilityHolder/changeling))
				boutput(caster, "<span class='notice'>That one's insides are all... wrong. You can't seem to make sense of it, much less so control it.</span>")
				return FALSE
			if (istype(human_target.abilityHolder,/datum/abilityHolder/werewolf))
				boutput(caster, "<span class='notice'>This body doesnt look normal. You decide to leave it alone.</span>")
				return FALSE
			if (istype(human_target.abilityHolder,/datum/abilityHolder/arcfiend))
				boutput(caster, "<span class='notice'>This body crackles faintly with electricity. You'd get zapped if you decided to control it.</span>")
				return FALSE
			if (istype(human_target.abilityHolder,/datum/abilityHolder/vampire))
				boutput(caster, "<span class='notice'>This body's blood smells like poison and it emanates ominous dark magic. Best not to mess with it</span>")
				return FALSE
			if (istype(human_target.abilityHolder,/datum/abilityHolder/vampiric_thrall))
				boutput(caster, "<span class='notice'>This body's insides are all messed up and it seems to be leaking blood at an alarming rate. Best to leave it there.</span>")
				return FALSE
			if (istype(human_target.abilityHolder,/datum/abilityHolder/wizard))
				boutput(caster, "<span class='notice'>Some residual magical energy resists your attempt to invade this body.</span>")
				return FALSE
			if (istype(human_target.abilityHolder,/datum/abilityHolder/composite))
				var/datum/abilityHolder/composite/composite_holder = human_target.abilityHolder
				for (var/datum/holder in composite_holder.holders)
					if (istype(holder,/datum/abilityHolder/changeling))
						boutput(caster, "<span class='notice'>That one's insides are all... wrong. You can't seem to make sense of it, much less so control it.</span>")
						return FALSE
					if (istype(holder,/datum/abilityHolder/werewolf))
						boutput(caster, "<span class='notice'>This body doesnt look normal. You decide to leave it alone.</span>")
						return FALSE
					if (istype(holder,/datum/abilityHolder/arcfiend))
						boutput(caster, "<span class='notice'>This body crackles faintly with electricity. You'd get zapped if you decided to control it.</span>")
						return FALSE
					if (istype(holder,/datum/abilityHolder/vampire))
						boutput(caster, "<span class='notice'>This body's blood smells like poison and it emanates ominous dark magic. Best not to mess with it</span>")
						return FALSE
					if (istype(holder,/datum/abilityHolder/vampiric_thrall))
						boutput(caster, "<span class='notice'>This body's insides are all messed up and it seems to be leaking blood at an alarming rate. Best to leave it there.</span>")
						return FALSE
					if (istype(holder,/datum/abilityHolder/wizard))
						boutput(caster, "<span class='notice'>Some residual magical energy resists your attempt to invade this body.</span>")
						return FALSE
		return TRUE

	return FALSE

/mob/proc/make_brainslug()
	if (ishuman(src))
		var/mob/living/carbon/human/H = src
		var/mob/living/critter/brain_slug/the_slug = new /mob/living/critter/brain_slug(src)
		H.slug = the_slug
		src.add_advanced_slug_abilities(the_slug)
		src.show_antag_popup("brainslug")
	else return
