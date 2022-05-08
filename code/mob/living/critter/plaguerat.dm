//Todo Get buff from cheese
//Add death
//Add check for spawns if there's too much

/mob/living/critter/plaguerat
	name = "plague rat"
	real_name = "plague rat"
	desc = "A diseased looking rat."
	icon_state = "big_spide"
	density = 1
	hand_count = 2 // spiders!!!
	add_abilities = list(/datum/targetable/critter/plague_rat/eat_filth,
						/datum/targetable/critter/plague_rat/rat_bite)

	var/eaten_amount = 0
	var/amount_to_grow = 0
	var/feeding = 0
	var/venom = "venom"  // making these modular so i don't have to rewrite this gigantic goddamn section for all the subtypes
	var/adultpath = null
	var/bitesound = "sound/weapons/handcuffs.ogg"
	var/deathsound = "sound/impact_sounds/Generic_Snap_1.ogg"
	death_text = "%src% falls on its back!"
	pet_text = list("pets","hugs","snuggles","cuddles")

	var/health_brute = 50
	var/health_brute_vuln = 0.45
	var/health_burn = 50
	var/health_burn_vuln = 0.65
	var/obj/machinery/warren/linked_warren = null
	reagent_capacity = 100

	can_help = 1
	can_throw = 1
	can_grab = 1
	can_disarm = 1

	butcherable = 1
	max_skins = 1

	blood_id = "vomit"

	var/bite_transfer_amt = 3

	New()
		..()
		/*
		if (src.icon_state == "big_spide")
			src.icon_state = "big_spide[pick("", "-red", "-green", "-blue")]"
			src.icon_state_alive = src.icon_state
			src.icon_state_dead = "[src.icon_state]-dead"
			*/

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.can_hold_items = 0

	setup_healths()
		..()
		add_hh_flesh(health_brute, health_brute_vuln)
		add_hh_flesh_burn(health_burn, health_burn_vuln)
		add_health_holder(/datum/healthHolder/toxin)
		add_health_holder(/datum/healthHolder/brain)

	on_pet(mob/user)
		if (..())
			return 1
		if (prob(50))
			boutput(user, "As you approach your hand to pet [src], it snatches at you and bites your hand.")
			random_brute_damage(user, 5)
			user.emote("scream")
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.contract_disease(/datum/ailment/disease/space_plague, null, null, 1)
			//Add chance to catch disease
			/*
		if (prob(15) && !ON_COOLDOWN(src, "playsound", 3 SECONDS))
			playsound(src, "sound/voice/babynoise.ogg", 30, 1)
			src.visible_message("<span class='notice'><b>[src]</b> coos!</span>",\
			"<span class='notice'>You coo!</span>")*/

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, "sound/voice/animal/mouse_squeak.ogg", 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<span class='emote'><b>[src]</b> squeaks!</span>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","hiss")
				return 2
		return ..()

	death(var/gibbed)
		if (!gibbed)
			src.unequip_all()
			playsound(src, src.deathsound, 50, 0)
			src.reagents.add_reagent(venom, 50, null)
		return ..()

	proc/venom_bite(mob/M)
		if (src.reagents && istype(M) && M.reagents)
			playsound(src, src.bitesound, 50, 1)
			if (issilicon(M))
				var/mob/living/silicon/robot/R = M
				R.compborg_take_critter_damage("[pick("l","r")]_[pick("arm","leg")]", rand(2,4))
			else
				M.TakeDamageAccountArmor("All", rand(1,3), 0, 0, DAMAGE_STAB)
			// now spiders won't poison themselves - cirr
			M.reagents.add_reagent(src.venom, bite_transfer_amt)

	proc/grow_up()
		if (!ispath(src.adultpath))
			return 0
		src.unequip_all()
		src.visible_message("<span class='alert'><b>[src] grows up!</b></span>",\
		"<span class='notice'><b>You grow up!</b></span>")
		SPAWN(0)
			src.make_critter(src.adultpath)

/mob/living/critter/plaguerat/young
	name = "plague rat small"
	real_name = "plague rat small"
	desc = "A diseased looking rat."
	icon_state = "big_spide"
	amount_to_grow = 3
	feeding = 0
	venom = "venom"  // making these modular so i don't have to rewrite this gigantic goddamn section for all the subtypes
	bite_transfer_amt = 1
	flags = TABLEPASS | DOORPASS
	adultpath = /mob/living/critter/plaguerat/medium
	health_brute = 30
	health_brute_vuln = 0.45
	health_burn = 30
	health_burn_vuln = 0.65

	can_help = 1
	can_throw = 0
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
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.can_hold_items = 0

/mob/living/critter/plaguerat/medium
	name = "plague rat medium"
	real_name = "plague rat medium"
	desc = "A diseased looking rat."
	icon_state = "big_spide"
	feeding = 0
	amount_to_grow = 2
	flags = DOORPASS
	venom = "venom"  // making these modular so i don't have to rewrite this gigantic goddamn section for all the subtypes
	bite_transfer_amt = 2.5
	adultpath = /mob/living/critter/plaguerat/adult
	health_brute = 40
	health_brute_vuln = 0.45
	health_burn = 40
	health_burn_vuln = 0.65
	add_abilities = list(/datum/targetable/critter/plague_rat/eat_filth,
						/datum/targetable/critter/plague_rat/rat_bite,
						/datum/targetable/critter/plague_rat/spawn_warren)

	can_help = 1
	can_throw = 0
	can_grab = 0
	can_disarm = 1

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/med
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.can_hold_items = 0

/mob/living/critter/plaguerat/adult
	name = "plague rat adult"
	real_name = "plague rat adult"
	desc = "A diseased looking rat."
	icon_state = "big_spide"
	feeding = 0
	venom = "venom"  // making these modular so i don't have to rewrite this gigantic goddamn section for all the subtypes
	bite_transfer_amt = 4
	health_brute = 60
	health_brute_vuln = 0.45
	health_burn = 60
	health_burn_vuln = 0.65
	add_abilities = list(/datum/targetable/critter/plague_rat/eat_filth,
						/datum/targetable/critter/plague_rat/rat_bite,
						/datum/targetable/critter/plague_rat/spawn_warren,
						/datum/targetable/critter/slam,
						/datum/targetable/wraithAbility/make_plague_rat)

	can_help = 1
	can_throw = 1
	can_grab = 1
	can_disarm = 1

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.can_hold_items = 0
