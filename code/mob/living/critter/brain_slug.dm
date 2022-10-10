/mob/living/critter/brain_slug
	name = "brain slug"
	desc = "A slithery thing."
	density = 1
	hand_count = 0
	custom_gib_handler = /proc/gibs
	icon = 'icons/mob/wraith_critters.dmi'
	icon_state = "smallRat"
	health_brute = 25
	health_burn = 20
	flags = TABLEPASS | DOORPASS
	var/deathsound = "sound/impact_sounds/Generic_Snap_1.ogg"
	pet_text = list("squishes","pokes","slaps", "prods cautiously")
	speechverb_say = "whispers"
	speechverb_exclaim = "squeals"
	add_abilities = list(/datum/targetable/critter/brain_slug/slither,
						/datum/targetable/critter/brain_slug/infest_host)
	can_throw = 0
	can_grab = 0
	can_disarm = 0
	can_help = 0


	//Makes its say not work.
	New(var/turf/T)
		..(T)
		src.bioHolder.AddEffect("nightvision", 0, 0, 0, 1)

	setup_healths()
		..()
		add_hh_flesh(health_brute, 1)
		add_hh_flesh_burn(health_burn, 1)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, "sound/voice/creepyshriek.ogg", 50, 1, 0.2, 1.7, channel=VOLUME_CHANNEL_EMOTE)
					return "<span class='emote'><b>[src]</b> lets out a horrific shriek!</span>"

	death(var/gibbed)
		if (!gibbed)
			src.unequip_all()
			playsound(src, src.deathsound, 50, 0)
			src.gib()
		return ..()
