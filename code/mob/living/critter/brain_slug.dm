/mob/living/critter/brain_slug
	name = "brain slug"
	desc = "A space parasite known to take control of feeble minds."
	hand_count = 0
	custom_gib_handler = /proc/gibs
	icon = 'icons/misc/critter.dmi'
	icon_state = "brain_slug"
	health_brute = 25
	health_burn = 25
	flags = TABLEPASS | DOORPASS
	var/deathsound = "sound/impact_sounds/Generic_Snap_1.ogg"
	pet_text = list("squishes","pokes","slaps","prods curiously")
	speechverb_say = "whispers"
	speechverb_exclaim = "squeals"
	add_abilities = list(/datum/targetable/brain_slug/slither,
						/datum/targetable/brain_slug/infest_host,
						/datum/targetable/brain_slug/exit_host,
						/datum/targetable/brain_slug/take_control)
	can_throw = 0
	can_grab = 0
	can_disarm = 0
	can_help = 0

	New(var/turf/T)
		..(T)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)

	setup_healths()
		..()
		add_hh_flesh(health_brute, 1)
		add_hh_flesh_burn(health_burn, 1)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, "sound/voice/creepyshriek.ogg", 50, 1, 0.2, 1.7, channel=VOLUME_CHANNEL_EMOTE)
					return "<span class='emote'><b>[src]</b> lets out a high pitched shriek!</span>"

	death(var/gibbed)
		if (!gibbed)
			src.unequip_all()
			playsound(src, src.deathsound, 50, 0)
			src.gib()
		return ..()
