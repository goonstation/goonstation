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
///Gives a brain slug host transfer and basic abilities as well as an ability holder for them.
/mob/living/proc/add_basic_slug_abilities(var/mob/living/critter/brain_slug/slug = null)
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
/mob/living/proc/add_advanced_slug_abilities(var/mob/living/critter/brain_slug/the_slug = null)
	var/datum/abilityHolder/AH = null
	AH = src.add_basic_slug_abilities(the_slug)
	if (AH)
		AH.addAbility(/datum/targetable/brain_slug/restraining_spit)
		AH.addAbility(/datum/targetable/brain_slug/acidic_spit)
		AH.addAbility(/datum/targetable/brain_slug/sling_spit)
		AH.addAbility(/datum/targetable/brain_slug/summon_brood)
