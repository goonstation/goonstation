/mob/living/critter/adult_brain_slug
	name = "adult brain slug"
	desc = "A slimy, huge space parasite that is no longer content to feed on just brains."
	hand_count = 1
	custom_gib_handler = /proc/gibs
	icon = 'icons/misc/critter.dmi'
	icon_state = "brain_slug"
	//todo death icon
	health_brute = 160
	health_burn = 90
	var/deathsound = "sound/impact_sounds/Generic_Snap_1.ogg"
	pet_text = list("squishes","pokes","slaps","prods curiously")
	speechverb_say = "gurgles"
	speechverb_exclaim = "roars"
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	can_help = 1

	New(var/turf/T)
		..(T)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION, src)
		src.add_stam_mod_max("slug", 50)


	setup_healths()
		..()
		add_hh_flesh(health_brute, 1)
		add_hh_flesh_burn(health_burn, 1)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/creepyshriek.ogg', 70, 1, 0.4, 1.3, channel=VOLUME_CHANNEL_EMOTE)
					return "<span class='emote'><b>[src]</b> lets out a high pitched shriek!</span>"

	death(var/gibbed)
		if (!gibbed)
			src.unequip_all()
			playsound(src, src.deathsound, 50, 0)
		return ..()

/mob/living/critter/adult_brain_slug/is_spacefaring()
	return TRUE

