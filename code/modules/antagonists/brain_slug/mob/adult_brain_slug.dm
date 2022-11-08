/mob/living/critter/adult_brain_slug
	name = "adult brain slug"
	desc = "A slimy, huge space parasite that is no longer content to feed on just brains."
	hand_count = 1
	custom_gib_handler = /proc/gibs
	icon = 'icons/mob/brainslug.dmi'
	icon_state = "adult_brainslug"
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
	add_abilities = list(/datum/targetable/brain_slug/slug_burrow,
						/datum/targetable/brain_slug/slug_molt,
						/datum/targetable/brain_slug/neural_detection,
						/datum/targetable/brain_slug/acid_slither,
						/datum/targetable/brain_slug/inject_brood,
						/datum/targetable/brain_slug/glue_spit,
						/datum/targetable/brain_slug/restraining_spit,
						/datum/targetable/brain_slug/slug_devour,
						/datum/targetable/brain_slug/devolve)
	var/bullet_reflect = FALSE

	New(var/turf/T)
		..(T)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION, src)
		src.add_stam_mod_max("slug", 50)


	setup_healths()
		..()
		add_hh_flesh(health_brute, 1)
		add_hh_flesh_burn(health_burn, 1)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/slug_mouth
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "Mouth"
		HH.limb_name = "Mouth"

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

	bullet_act(var/obj/projectile/P)
		if(!src.bullet_reflect)
			..()
		if (!P.goes_through_mobs)
			var/obj/projectile/Q = shoot_reflected_to_sender(P, src)
			P.die()

			src.visible_message("<span class='alert'>[Q.name] is reflected by [src]'s sticky mucus!</span>")
			playsound(src.loc, 'sound/impact_sounds/Energy_Hit_1.ogg', 40, 0.1, 0, 2.6)

			return
		else
			..()

/mob/living/critter/adult_brain_slug/is_spacefaring()
	return TRUE

