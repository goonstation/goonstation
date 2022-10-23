// a shared parent for changeling critters that need common functionality, like a master, DNA point store, hivemind, ability to wear hats, y'know, the real important stuff
//mbc : the indentation of this file got all fucked up somehow. That's why we work on different indentation levels depending on the proc. Have fun!

/mob/living/critter/changeling
	name = "fire me into the sun"
	real_name = "for this should not be seen"
	desc = "dial 555-imcoder now for prizes"
	density = 1
	custom_gib_handler = /proc/gibs
	can_throw = 0
	can_grab = 0
	can_disarm = 1
	blood_id = "bloodc"
	table_hide = 0
	meat_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/changeling
	butcherable = TRUE
	var/datum/abilityHolder/changeling/hivemind_owner = 0
	var/icon_prefix = ""
	/// Part this limb critter is based off of- i.e. a cow making a legworm would be a cow leg. Could also be an eye or butt, hence loose type
	var/obj/item/original_bodypart

	// IMPORTANT gimmick features
	var/obj/item/clothing/head/hat = null
	var/hat_shown = 0
	var/hat_icon = 'icons/obj/bots/aibots.dmi' //yeah just use the buddy hats whatever close enough
	var/hat_x_offset = -4
	var/hat_y_offset = -2

	New(loc, obj/item/bodypart)
		..()
		if (bodypart)
			bodypart.name = "mutagenic [initial(bodypart.name)]"
		src.original_bodypart = bodypart
		src.original_bodypart.set_loc(src)

	say(message, involuntary = 0)
		if (hivemind_owner)
			message = trim(copytext(strip_html(message), 1, MAX_MESSAGE_LEN))

			if (!message)
				return

			if (dd_hasprefix(message, "*"))
				return src.emote(copytext(message, 2),1)

			logTheThing(LOG_DIARY, src, "(HIVEMIND): [message]", "hivesay")

			if (src.client && src.client.ismuted())
				boutput(src, "You are currently muted and may not speak.")
				return

			. = src.say_hive(message, hivemind_owner)
		else
			..()

	canRideMailchutes()
		return 1

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/clothing/head))
			if(src.hat)
				boutput(user, "<span class='alert'>[src] is already wearing a hat!</span>")
				return
			if(!(W.icon_state in BUDDY_HATS))
				boutput(user, "<span class='alert'>It doesn't fit!</span>")
				return

			src.hat = W
			user.drop_item()
			W.set_loc(src)

			src.UpdateIcon()
			user.visible_message("<b>[user]</b> puts a hat on [src]!","You put a hat on [src]!")
			return
		..()

	update_icon()
		if (src.hat && !src.hat_shown)
			var/image/hat_image = image(src.hat_icon, "bhat-[src.hat.icon_state]",,layer = src.layer + 0.005)
			hat_image.pixel_x = hat_x_offset
			hat_image.pixel_y = hat_y_offset
			src.underlays = list(hat_image)
			src.hat_shown = 1
		else
			src.underlays = null

		return

	attack_hand(var/mob/living/M)
		switch (M.a_intent)
			if (INTENT_GRAB)
				if (hivemind_owner && M != src && M.get_ability_holder(/datum/abilityHolder/changeling) == hivemind_owner)
					return_to_master()
					return
		..()

	death(var/gibbed)
		if (hat)
			hat.set_loc(src.loc)
			hat = 0
			UpdateIcon()
		if (!gibbed)
			playsound(src, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1, 0.2, 1)
		death_effect()
		..()

	butcher(mob/user)
		src.original_bodypart?.set_loc(src.loc)
		src.original_bodypart = null
		return ..(user, FALSE)

	disposing()
		..()
		qdel(src.original_bodypart)
		src.original_bodypart = null

	// functionality here greatly differs between the changeling critters, but they still need it
	proc/return_to_master()
		return

/mob/living/critter/changeling/proc/death_effect()
	if (hivemind_owner)
		hivemind_owner.insert_into_hivemind(src)



///////////////////////////
// HANDSPIDER
///////////////////////////

/datum/abilityHolder/critter/handspider
	onAbilityStat()
		..()
		.= list()
		.["DNA Collected:"] = owner?:absorbed_dna


/mob/living/critter/changeling/handspider
	name = "handspider"
	real_name = "handspider"
	desc = "It's a living disembodied hand with shifting flesh... Disgusting!"
	icon_state = "handspider"
	icon_state_dead = "handspider-dead"
	abilityHolder
	can_grab = 1
	can_disarm = 1
	hand_count = 1
	var/absorbed_dna = 0

	New()
		..()
		abilityHolder = new /datum/abilityHolder/critter/handspider(src)
		//todo : move to add_abilities list because its cleaner that way
		abilityHolder.addAbility(/datum/targetable/critter/dna_gnaw)
		abilityHolder.addAbility(/datum/targetable/critter/boilgib)
		abilityHolder.updateButtons()
		src.flags ^= TABLEPASS

		RegisterSignal(src, COMSIG_MOB_PICKUP, .proc/stop_sprint)
		RegisterSignal(src, COMSIG_MOB_DROPPED, .proc/enable_sprint)

	disposing()
		UnregisterSignal(src, list(COMSIG_ITEM_PICKUP, COMSIG_ITEM_DROPPED))
		..()

	proc/stop_sprint()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_CANTSPRINT, src.type)

	proc/enable_sprint()
		REMOVE_ATOM_PROPERTY(src, PROP_MOB_CANTSPRINT, src.type)

	special_movedelay_mod(delay,space_movement,aquatic_movement)
		.= delay
		if (src.lying)
			. += 14
		if (HAS_ATOM_PROPERTY(src, PROP_MOB_CANTSPRINT))
			. += 7

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/creepyshriek.ogg', 50, 1, 0, 2.1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b><span class='alert'>[src] screams!</span></b>"
			if("flip")
				if(src.emote_check(voluntary, 50))
					var/list/mob/living/possible_targets = list()
					var/message
					//Check if we have any nearby mobs
					for(var/mob/living/L in oview(1))
						possible_targets += L

					if(possible_targets.len)
						var/mob/living/L = pick(possible_targets)
						var/dir = get_dir(L, src)
						if(dir & (EAST | WEST))
							src.set_dir(dir)
						else if (dir & (NORTH | SOUTH))
							src.set_dir(get_dir(src,L))

						src.icon_state = "[icon_prefix]handspider-flip"
						animate_handspider_flipoff(src, prob(50) ? "L" : "R", 1, 0)
						SPAWN(0.7 SECONDS)
							//Adding check for icon_state in case they die mid-flipoff (heck)
							if(!isdead(src)) src.icon_state = "[icon_prefix]handspider"
						//Flipoff
						message = "<B>[src]</B> flips off [L.name]!"
					else
						//No flipoff
						animate_spin(src, prob(50) ? "L" : "R", 1, 0)
						message = "<B>[src]</B> does a flip!"

					return message
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	update_icon()
		..()
		src.icon_state = "[icon_prefix]handspider"
		src.icon_state_dead = "[icon_prefix]handspider-dead"

	hand_attack(atom/target)
		if (hivemind_owner && ismob(target) && target:get_ability_holder(/datum/abilityHolder/changeling) == hivemind_owner)
			return_to_master()
			return

		..()

		if(istype(target, /obj/machinery/optable/) || istype(target, /obj/table/) || istype(target, /obj/stool/bed/))
			step(src, get_dir(src, target))
			if (src.loc == target.loc)
				if (table_hide)
					table_hide = 0
					src.layer = MOB_LAYER
					src.visible_message("[src] crawls on top of [target]!")
				else
					table_hide = 1
					src.layer = target.layer - 0.01
					src.visible_message("[src] hides under [target]!")
				src.hat_shown = 0
				UpdateIcon()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.name = "mouth"				 // designation of the hand - purely for show
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"			 // the icon state of the hand UI background
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.limb = new /datum/limb
		HH.can_hold_items = 1

	setup_healths()
		add_hh_flesh(5, 1)
		add_hh_flesh_burn(4, 1.25)
		add_health_holder(/datum/healthHolder/toxin)


	//Give master the DNA we collected, the DNA points it cost to create us, and their arm back!
	return_to_master()
		if (ishuman(hivemind_owner.owner))
			var/mob/living/carbon/human/C = hivemind_owner.owner
			if(!C.limbs.l_arm || !C.limbs.r_arm)
				if(!C.limbs.l_arm)
					if (isabomination(C))
						C.limbs.l_arm = new /obj/item/parts/human_parts/arm/left/abomination(C)
					else //mbc todo : use type of handspider to get diff arms
						C.limbs.l_arm = new /obj/item/parts/human_parts/arm/left(C)
					C.limbs.l_arm.holder = C
					C.limbs.l_arm:original_holder = C
					C.limbs.l_arm:set_skin_tone()
					C.set_body_icon_dirty()
				else if(!C.limbs.r_arm)
					if (isabomination(C))
						C.limbs.r_arm = new /obj/item/parts/human_parts/arm/right/abomination(C)
					else
						C.limbs.r_arm = new /obj/item/parts/human_parts/arm/right(C)
					C.limbs.r_arm.holder = C
					C.limbs.r_arm:original_holder = C
					C.limbs.r_arm:set_skin_tone()
					C.set_body_icon_dirty()
				if (isdead(src))
					hivemind_owner.owner.visible_message(text("<span class='alert'><B>[hivemind_owner.owner] grabs on to [src] and attaches it to their own body!</B></span>"))
				else
					hivemind_owner.owner.visible_message(text("<span class='alert'><B>[src] climbs on to [hivemind_owner.owner] and attaches itself to their arm stump!</B></span>"))

		var/dna_gain = absorbed_dna
		if (isdead(src))	//if the handspider is dead, the changeling can only gain half of what they collected
			dna_gain = dna_gain / 2
		dna_gain += 4
		boutput(hivemind_owner.owner, "<span class='notice'>A handspider has returned to your body! You gain <B>[dna_gain]</B> DNA points from the spider!</span>")
		hivemind_owner.points += (dna_gain)
		hivemind_owner.insert_into_hivemind(src)
		qdel(src)


///////////////////////////
// EYESPIDER
///////////////////////////
/datum/abilityHolder/critter/eyespider
	onAbilityStat()
		..()
		.= list()
		var/mob/T = owner:marked_target
		if(istype(T))
			.["Mark:"] = T
			// let's stop eyespiders from helping their masters game the adventure zone (taken from clairvoyance)
			var/atom/target_loc = T.loc
			var/locName = ""
			if (isrestrictedz(owner.z))
				if (!isrestrictedz(T.z))
					locName = "In [target_loc.loc]"
				else
					locName = "In ???"
			else if(!istype(target_loc, /turf))
				if(istype(target_loc, /obj))
					locName = "In a [target_loc.name] in [target_loc.loc.loc]" // .loc.loc.loc.loc master mover master mover
				else if(istype(target_loc, /mob))
					locName = "Inside [target_loc.name], somehow, in [target_loc.loc.loc]"
				else
					locName = "No longer confined to this world we understand"
			else
				locName = "In [target_loc.loc]"
			.["Location:"] = locName
		else
			.["Mark:"] = "None"

/mob/living/critter/changeling/eyespider
	name = "eyespider"
	real_name = "eyespider"
	desc = "It's a living disembodied eye with freaky spindly legs... That's messed up!"
	density = 0
	icon_state = "eyespider"
	icon_state_dead = "eyespider-dead"
	abilityHolder
	var/marked_target = null
	base_move_delay = 1.65
	base_walk_delay = 3
	layer = 2.89

	New()
		..()
		abilityHolder = new /datum/abilityHolder/critter/eyespider(src)
		// TODO: ACTUAL ABILITIES
		abilityHolder.addAbility(/datum/targetable/critter/mark)
		abilityHolder.addAbility(/datum/targetable/critter/boilgib)
		abilityHolder.addAbility(/datum/targetable/critter/shedtears)
		abilityHolder.updateButtons()
		src.flags ^= TABLEPASS | DOORPASS

		// EYE CAN SEE FOREVERRRR
		src.sight |= SEE_MOBS | SEE_TURFS | SEE_OBJS
		src.see_in_dark = SEE_DARK_FULL
		src.see_invisible = INVIS_CLOAK

	// a slight breeze will kill these guys, such is life as a squishy li'l eye
	setup_healths()
		add_hh_flesh(3, 1)
		add_hh_flesh_burn(2, 1.25)
		add_health_holder(/datum/healthHolder/toxin)

	return_to_master()
		var/dna_gain = 0
		if (ishuman(hivemind_owner.owner))
			// if they have no eyes, add an eye
			// otherwise, give them a couple dna points for their troubles
			// i doubt this will be farmable given the cooldowns involved but let's see if a player is awful enough to prove me wrong
			var/mob/living/carbon/human/C = hivemind_owner.owner
			if(!C.organHolder.left_eye || !C.organHolder.right_eye)
				var/obj/item/organ/eye/E = new /obj/item/organ/eye()
				E.donor = C
				if(!C.organHolder.left_eye)
					C.organHolder.receive_organ(E, "left_eye", 2)
					C.update_body()
				else
					C.organHolder.receive_organ(E, "right_eye", 2)
					C.update_body()
			else
				dna_gain = 2 // bad_ideas.txt

		boutput(hivemind_owner.owner, "<span class='notice'>An eyespider has returned to your body![dna_gain > 0 ? " You gain <B>[dna_gain]</B> DNA points from the spider!" : ""]</span>")
		hivemind_owner.points += dna_gain
		hivemind_owner.insert_into_hivemind(src)
		qdel(src)

	Life(datum/controller/process/mobs/parent)
		. = ..()
		if(src.marked_target && src.client)
			var/image/arrow = image(icon = 'icons/mob/screen1.dmi', icon_state = "arrow", loc = src, layer = HUD_LAYER)
			arrow.color = "#ff0000ff"
			arrow.transform = matrix(arrow.transform, -2, -2, MATRIX_SCALE)
			var/angle = get_angle(src, src.marked_target)
			arrow.transform = matrix(arrow.transform, angle, MATRIX_ROTATE)
			arrow.transform = matrix(arrow.transform, sin(angle)*40, cos(angle)*40, MATRIX_TRANSLATE)
			src.client.images += arrow
			animate(arrow, time = 3 SECONDS, alpha = 0)
			SPAWN(3 SECONDS)
				src.client?.images -= arrow
				qdel(arrow)

///////////////////////////
// LEGWORM
///////////////////////////

/mob/living/critter/changeling/legworm
	name = "legworm"
	real_name = "legworm"
	desc = "A writhing, angry disembodied leg!"
	icon_state = "legworm"
	icon_state_dead = "legworm-dead"
	hand_count = 1
	base_move_delay = 4
	base_walk_delay = 5
	hat_y_offset = 5

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/creepyshriek.ogg', 50, 1, 0.2, 1.7, channel=VOLUME_CHANNEL_EMOTE)
					return "<b><span class='alert'>[src] screams!</span></b>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	Move(var/atom/NewLoc, direct)
		.=..()
		if (!isdead(src))
			var/opy = pixel_y
			animate( src )
			animate( src, pixel_y = 6, easing = SINE_EASING, time = ((NewLoc.y-y)>0)?3:1 )
			animate( pixel_y = opy, easing = SINE_EASING, time = 3 )
			playsound( get_turf(src), "sound/misc/footstep[rand(1,2)].ogg", 20, 1, 0.1, 0.6)

	hand_attack(atom/target)
		if (hivemind_owner && ismob(target) && target:get_ability_holder(/datum/abilityHolder/changeling) == hivemind_owner)
			return_to_master()
			return

		..()


		if(istype(target, /obj/machinery/optable/) || istype(target, /obj/table/) || istype(target, /obj/stool/bed/))
			//src.visible_message("[src] tries to squeeze under [target], but they are too large!")
			//return

			step(src, get_dir(src, target))
			if (src.loc == target.loc)
				if (table_hide)
					table_hide = 0
					src.layer = MOB_LAYER
					src.visible_message("[src] crawls on top of [target]!")
				else
					table_hide = 1
					src.layer = target.layer - 0.01
					src.visible_message("[src] hides under [target]!")
				src.hat_shown = 0
				UpdateIcon()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.name = "mouth"				 // designation of the hand - purely for show
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"			 // the icon state of the hand UI background
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.limb = new /datum/limb/leg_hand
		HH.can_hold_items = 0

	New()
		..()
		abilityHolder.addAbility(/datum/targetable/critter/powerkick)
		abilityHolder.addAbility(/datum/targetable/critter/writhe)
		abilityHolder.addAbility(/datum/targetable/critter/boilgib)
		abilityHolder.updateButtons()
		src.flags ^= TABLEPASS
		src.add_stam_mod_max("small_animal", 25)

	setup_healths()
		add_hh_flesh(16, 1)
		add_hh_flesh_burn(5, 1.25)
		add_health_holder(/datum/healthHolder/toxin)


	return_to_master()
		if (ishuman(hivemind_owner.owner))
			var/mob/living/carbon/human/C = hivemind_owner.owner
			if(!C.limbs.l_leg || !C.limbs.r_leg)
				if(!C.limbs.l_leg)
					C.limbs.l_leg = new /obj/item/parts/human_parts/leg/left(C)
					C.limbs.l_leg.holder = C
					C.limbs.l_leg:original_holder = C
					C.limbs.l_leg:set_skin_tone()
					C.set_body_icon_dirty()
				else if(!C.limbs.r_leg)
					C.limbs.r_leg = new /obj/item/parts/human_parts/leg/right(C)
					C.limbs.r_leg.holder = C
					C.limbs.r_leg:original_holder = C
					C.limbs.r_leg:set_skin_tone()
					C.set_body_icon_dirty()
				if (isdead(src))
					hivemind_owner.owner.visible_message(text("<span class='alert'><B>[hivemind_owner.owner] grabs on to [src] and attaches it to their own body!</B></span>"))
				else
					hivemind_owner.owner.visible_message(text("<span class='alert'><B>[src] climbs on to [hivemind_owner.owner] and attaches itself to their leg stump!</B></span>"))

		var/dna_gain = 6 //spend dna
		boutput(hivemind_owner.owner, "<span class='notice'>A legworm has returned to your body! You gain <B>[dna_gain]</B> DNA points from the leg!</span>")
		hivemind_owner.points += (dna_gain)
		hivemind_owner.insert_into_hivemind(src)
		qdel(src)


///////////////////////////
// BUTTCRABS
///////////////////////////


// Yyyyup.

/mob/living/critter/changeling/buttcrab
	name = "buttcrab"
	real_name = "buttcrab"
	desc = "Well. OK then. Thats a thing."
	icon_state = "buttcrab"
	icon_state_dead = "buttcrab-dead"
	hand_count = 0
	base_move_delay = 4
	base_walk_delay = 5
	hat_y_offset = -2

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("fart")
				if (src.emote_check(voluntary, 50))
					playsound(src,"sound/voice/farts/fart[rand(1,6)].ogg", 50, 1, 0.2, 1.7, channel=VOLUME_CHANNEL_EMOTE)
					var/turf/fart_turf = get_turf(src)
					fart_turf.fluid_react_single("[prob(20)?"very_":""]toxic_fart",1,airborne = 1)
					return "<b><span class='alert'>[src] farts!</span></b>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("fart")
				return 2
		return ..()

	New()
		..()
		abilityHolder.addAbility(/datum/targetable/changeling/sting/fartonium)
		abilityHolder.addAbility(/datum/targetable/changeling/sting/simethicone)
		abilityHolder.updateButtons()
		src.flags ^= TABLEPASS

	setup_healths()
		add_hh_flesh(16, 1)
		add_hh_flesh_burn(5, 1.25)



	return_to_master()
		if (ishuman(hivemind_owner.owner))
			var/mob/living/carbon/human/C = hivemind_owner.owner
			if(!C.organHolder.butt)
				var/obj/item/organ/eye/E = new /obj/item/clothing/head/butt()
				C.organHolder.receive_organ(E,"butt",0)
				C.update_body()
				if (isdead(src))
					hivemind_owner.owner.visible_message(text("<span class='alert'><B>[hivemind_owner.owner] grabs on to [src] and.. JESUS FUCKING CHRIST LOOK AWAY OH GOD!</B></span>"))
				else
					hivemind_owner.owner.visible_message(text("<span class='alert'><B>[src] climbs on to [hivemind_owner.owner] and... oh. Oh my. You really wish you hadnt seen that.</B></span>"))

		var/dna_gain = 1 //spend dna
		boutput(hivemind_owner.owner, "<span class='notice'>A buttcrab has returned to your body! You gain <B>[dna_gain]</B> DNA points from the butt!</span>")
		hivemind_owner.points += (dna_gain)
		hivemind_owner.insert_into_hivemind(src)
		qdel(src)



//daddy

/mob/living/critter/changeling/headspider
	name = "headspider"
	real_name = "headspider"
	desc = "Oh my god!"
	icon_state = "headspider"
	icon_state_dead = "headspider-dead"
	hand_count = 1
	hat_y_offset = 5


	var/datum/abilityHolder/changeling/changeling = null

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/creepyshriek.ogg', 50, 1, 0.2, 1.7, channel=VOLUME_CHANNEL_EMOTE)
					return "<b><span class='alert'>[src] screams!</span></b>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.name = "mouth"				 // designation of the hand - purely for show
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"			 // the icon state of the hand UI background
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.limb = new /datum/limb
		HH.can_hold_items = 0

	New()
		..()
		abilityHolder.addAbility(/datum/targetable/critter/slam)
		abilityHolder.updateButtons()
		src.flags ^= TABLEPASS | DOORPASS

	setup_healths()
		add_hh_flesh(40, 1)
		add_hh_flesh_burn(20, 1.25)
		add_health_holder(/datum/healthHolder/toxin)


/mob/living/critter/changeling/headspider/proc/filter_target(var/mob/living/C)
		//Don't want a dead mob or a nonliving mob
		return istype(C) && !isdead(C) && src.loc != C

/mob/living/critter/changeling/headspider/proc/infect_target(mob/M)
	if(ishuman(M) && isalive(M))
		var/mob/living/carbon/human/H = M
		random_brute_damage(H, 10)
		src.visible_message("<font color='#FF0000'><B>\The [src]</B> crawls down [H.name]'s throat!</font>")
		playsound(src, 'sound/misc/headspiderability.ogg', 60)
		src.set_loc(H)
		H.setStatusMin("paralysis", 10 SECONDS)

		var/datum/ailment_data/parasite/HS = new /datum/ailment_data/parasite
		HS.master = get_disease_from_path(/datum/ailment/parasite/headspider)
		HS.affected_mob = H
		HS.source = src.mind
		var/datum/ailment/parasite/headspider/HSD = HS.master
		HSD.changeling = changeling
		H.ailments += HS

		logTheThing(LOG_COMBAT, src.mind, "'s headspider enters [constructTarget(H,"combat")] at [log_loc(src)].")

/mob/living/critter/changeling/headspider/hand_attack(atom/target)
	if (filter_target(target))
		infect_target(target)
		return

	..()

	if(istype(target, /obj/machinery/optable/) || istype(target, /obj/table/) || istype(target, /obj/stool/bed/))
		step(src, get_dir(src, target))
		if (src.loc == target.loc)
			if (table_hide)
				table_hide = 0
				src.layer = MOB_LAYER
				src.visible_message("[src] crawls on top of [target]!")
			else
				table_hide = 1
				src.layer = target.layer - 0.01
				src.visible_message("[src] hides under [target]!")
			src.hat_shown = 0
			UpdateIcon()

/mob/living/critter/changeling/headspider/death_effect()
	if (changeling) // don't do this if we're an empty headspider (already took control of a body)
		for (var/mob/living/critter/changeling/spider in changeling.hivemind)
			boutput(spider, "<span class='alert'>Your telepathic link to your master has been destroyed!</span>")
			spider.hivemind_owner = 0
		for (var/mob/dead/target_observer/hivemind_observer/obs in changeling.hivemind)
			boutput(obs, "<span class='alert'>Your telepathic link to your master has been destroyed!</span>")
			obs.boot()
		changeling.hivemind.Cut()
