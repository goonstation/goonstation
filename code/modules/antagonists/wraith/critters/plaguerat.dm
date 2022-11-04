//Add death
ABSTRACT_TYPE(/mob/living/critter/wraith/plaguerat)
/mob/living/critter/wraith/plaguerat
	name = "plague rat"
	real_name = "plague rat"
	desc = "Shouldnt be seeing this."
	icon = 'icons/mob/wraith_critters.dmi'
	icon_state = "smallRat"
	density = 1
	hand_count = 2
	custom_gib_handler = /proc/gibs
	var/eaten_amount = 0	//How much filth did we eat
	var/amount_to_grow = 0	//How much is needed to grow
	var/venom = "rat_spit"	//What are we injecting on bite
	var/adultpath = null	//What do we grow into
	var/bitesound = "sound/weapons/handcuffs.ogg"
	var/deathsound = "sound/impact_sounds/Generic_Snap_1.ogg"
	death_text = "%src% falls on its back!"
	pet_text = list("pets","hugs","snuggles","cuddles")
	add_abilities = list(/datum/targetable/critter/plague_rat/eat_filth,
						/datum/targetable/critter/plague_rat/rat_bite)

	health_brute = 50
	health_brute_vuln = 0.45
	health_burn = 50
	health_burn_vuln = 0.65
	var/obj/machinery/wraith/rat_den/linked_den = null
	reagent_capacity = 100
	var/master = null

	can_help = 1
	can_throw = 1
	can_grab = 0
	can_disarm = 1

	butcherable = 1
	max_skins = 1

	blood_id = "miasma"
	/// venom injected per bite
	var/bite_transfer_amt = 3

	New(var/turf/T, var/mob/wraith/M = null)
		..(T)
		START_TRACKING
		SPAWN(0)
			src.bioHolder.AddEffect("nightvision", 0, 0, 0, 1)
			if(M != null)
				src.master = M

				if (isnull(M.summons))
					M.summons = list()
				M.summons += src
	disposing()
		STOP_TRACKING
		. = ..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "teeth"
		HH.can_hold_items = 0

	setup_healths()
		..()
		add_hh_flesh(health_brute, health_brute_vuln)
		add_hh_flesh_burn(health_burn, health_burn_vuln)

	on_pet(mob/user)
		if (..())
			return 1
		if (prob(10))	//You probably shouldnt be petting them
			boutput(user, "As you approach to pet [src], it snaps at you and bites your hand.")
			random_brute_damage(user, 5)
			user.emote("scream")
			playsound(src.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 70, 1)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				if(H.clothing_protects_from_chems())
					boutput(H, "The bite is painful, but at least your biosuit protected you from the rat's diseases.")
				else
					boutput(H, "Your hand immediatly starts to painfully puff up, that can't be good.")
					H.contract_disease(/datum/ailment/disease/space_plague, null, null, 1)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/mouse_squeak.ogg', 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<span class='emote'><b>[src]</b> squeaks!</span>"
			if ("fart")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/farts/poo2.ogg', 40, 1, 0.1, 3, channel=VOLUME_CHANNEL_EMOTE)
					return "<span class='emote'><b>[src]</b> toots disgustingly!</span>"

	specific_emote_type(var/act)
		switch (act)
			if ("scream","hiss")
				return 2
		return ..()

	death(var/gibbed)
		if (!gibbed)
			src.unequip_all()
			playsound(src, src.deathsound, 50, 0)
			src.gib()
		return ..()

	proc/venom_bite(mob/M)
		if (src.reagents && istype(M) && M.reagents)
			playsound(src, src.bitesound, 50, 1)
			if (issilicon(M))
				var/mob/living/silicon/robot/R = M
				R.compborg_take_critter_damage("[pick("l","r")]_[pick("arm","leg")]", rand(2,4))
			else
				M.TakeDamageAccountArmor("All", rand(1,3), 0, 0, DAMAGE_STAB)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M

				if(H.clothing_protects_from_chems())
					boutput(H, "The bite hurts alot, but it didn't manage to pierce your protective suit.")
					return 1
			M.reagents.add_reagent(src.venom, src.bite_transfer_amt)

	proc/grow_up(var/mob/wraith/M = null)
		if (!ispath(src.adultpath))
			return 0
		src.unequip_all()
		src.visible_message("<span class='alert'><b>[src] bloats and grows up in size. The smell is utterly revolting!</b></span>",\
		"<span class='notice'><b>You grow up!</b></span>")
		SPAWN(0)
			var/mob/living/critter/wraith/plaguerat/new_rat = new adultpath(get_turf(src), master)
			var/mob/living/critter/wraith/plaguerat/old_rat = src
			src.mind.transfer_to(new_rat)
			animate_buff_in(new_rat)
			qdel(old_rat)

/mob/living/critter/wraith/plaguerat/young
	name = "diseased rat"
	real_name = "diseased rat"
	desc = "A diseased looking rat."
	icon_state = "smallRat"
	amount_to_grow = 4
	bite_transfer_amt = 1
	flags = TABLEPASS | DOORPASS
	adultpath = /mob/living/critter/wraith/plaguerat/medium
	health_brute = 15
	health_brute_vuln = 1
	health_burn = 15
	health_burn_vuln = 1.2

	can_help = 1
	can_throw = 1
	can_grab = 0
	can_disarm = 1

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "teeth"
		HH.can_hold_items = 0

/mob/living/critter/wraith/plaguerat/medium
	name = "plague-ridden rat"
	real_name = "plague ridden rat"
	desc = "A wretched, disgusting rat."
	icon_state = "mediumRat"
	amount_to_grow = 8
	flags = TABLEPASS
	bite_transfer_amt = 2.5
	adultpath = /mob/living/critter/wraith/plaguerat/adult
	health_brute = 25
	health_brute_vuln = 0.9
	health_burn = 25
	health_burn_vuln = 1.2
	can_help = 1
	can_throw = 0
	can_grab = 0
	can_disarm = 1
	add_abilities = list(/datum/targetable/critter/plague_rat/eat_filth,
						/datum/targetable/critter/plague_rat/rat_bite,
						/datum/targetable/critter/plague_rat/spawn_rat_den)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/med
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "teeth"
		HH.can_hold_items = 0

/mob/living/critter/wraith/plaguerat/adult
	name = "bloated rat mass"
	real_name = "bloated rat mass"
	desc = "A horrible mass of puss and warts, that once used to look like a rat."
	icon_state = "giantRat"
	bite_transfer_amt = 4
	health_brute = 40
	health_brute_vuln = 0.8
	health_burn = 40
	health_burn_vuln = 1.3
	can_help = 1
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	add_abilities = list(/datum/targetable/critter/plague_rat/eat_filth,
						/datum/targetable/critter/plague_rat/rat_bite,
						/datum/targetable/critter/plague_rat/spawn_rat_den,
						/datum/targetable/critter/slam/rat,
						/datum/targetable/wraithAbility/make_plague_rat)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "teeth"
		HH.can_hold_items = 0
