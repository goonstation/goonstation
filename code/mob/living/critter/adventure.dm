/* -For adventure zoneish mobs-
   -Most of these orginally made by cogwerks-
	whats here:
	- Transposed scientist
	- Shades
	- Repair bots
	- Town guards
	- Blob men
*/
/////////////// Transposed scientist ////////////////
TYPEINFO(/mob/living/critter/crunched)
	start_speech_modifiers = list(SPEECH_MODIFIER_MOB_MODIFIERS, SPEECH_MODIFIER_ACCENT_VOID)

/mob/living/critter/crunched
	name = "transposed scientist"
	desc = "A fellow who seems to have been shunted between dimensions. Not a good state to be in."
	icon = 'icons/mob/critter/humanoid/crunched.dmi'
	icon_state = "crunched"
	icon_state_dead = "crunched"
	hand_count = 2
	can_help = TRUE
	can_throw = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	health_brute = 25
	health_brute_vuln = 1
	health_burn = 25
	health_burn_vuln = 1
	faction = list(FACTION_DERELICT)
	ai_retaliates = TRUE
	ai_retaliate_patience = 3
	ai_retaliate_persistence = RETALIATE_ONCE // They don't really want to hurt you
	ai_type = /datum/aiHolder/aggressive
	is_npc = TRUE

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb/transposed
		HH.icon_state = "handl"				// the icon state of the hand UI background
		HH.limb_name = "left transposed arm"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb/transposed
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"				// the icon state of the hand UI background
		HH.limb_name = "right transposed arm"

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (src.ai?.enabled && prob(5))
			if (src.ai.current_task == "wandering")
				src.say(pick("Hey..you! Help! Help me please!","I need..a doctor...","Someone...new? Help me...please.","Are you real?"))
			else if (prob(50))
				src.say(pick("Cut the power! It's about to go critical, cut the power!","I warned them. I warned them the system wasn't ready.","Shut it down!","It hurts, oh God, oh God."))

	critter_basic_attack(var/mob/target)
		if (target.lying || is_incapacitated(target))
			src.set_a_intent(INTENT_HELP)
		else
			src.set_a_intent(INTENT_HARM)
		src.chase_lines(target)
		src.hand_attack(target)

	proc/chase_lines(var/mob/target)
		if(!ON_COOLDOWN(src, "chase_talk", 10 SECONDS))
			if (target.lying || is_incapacitated(target))
				src.say( pick("No! Get up! Please, get up!", "Not again! Not again! I need you!", "Please! Please get up! Please!", "I don't want to be alone again!") )
			else
				src.say( pick("Please! Help! I need help!", "Please...help me!", "Are you real? You're real! YOU'RE REAL", "Everything hurts! Everything hurts!", "Please, make the pain stop! MAKE IT STOP!") )

	seek_target(var/range = 5)
		.=..()

		if (length(.) && prob(5))
			src.say(pick("Please...help...it hurts...please", "I'm...sick...help","It went wrong.  It all went wrong.","I didn't mean for this to happen!", "I see everything twice!") )

	death()
		src.say( pick("There...is...nothing...","It's dark.  Oh god, oh god, it's dark.","Thank you.","Oh wow. Oh wow. Oh wow.") )
		..()
		SPAWN(1.5 SECONDS)
			qdel(src)

////////// Transposed limb ///////////
/datum/limb/transposed
	help(mob/target, var/mob/living/user)
		..()
		harm(target, user, 0)

	harm(mob/target, var/mob/living/user)
		if(check_target_immunity( target ))
			return FALSE

		var/datum/attackResults/msgs = user.calculate_melee_attack(target, 5, 15, 0, can_punch = FALSE, can_kick = FALSE)
		user.attack_effects(target, user.zone_sel?.selecting)
		var/action = "grab"
		msgs.base_attack_message = SPAN_ALERT("<b>[user] [action]s [target] with [src.holder]!</b>")
		msgs.played_sound = 'sound/impact_sounds/burn_sizzle.ogg'
		msgs.damage_type = DAMAGE_BURN
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = get_weakref(target)
		ON_COOLDOWN(src, "limb_cooldown", 3 SECONDS)

////////////// Shades ////////////////
TYPEINFO(/mob/living/critter/shade)
	start_speech_modifiers = list(SPEECH_MODIFIER_MOB_MODIFIERS, SPEECH_MODIFIER_ACCENT_VOID)

/mob/living/critter/shade
	name = "darkness"
	desc = "Oh god."
	icon = 'icons/mob/critter/humanoid/shade.dmi'
	icon_state = "shade"
	icon_state_dead = "shade" //doesn't have a dead icon, just fades away
	death_text = null //has special spooky voice lines
	hand_count = 2
	can_lie = FALSE
	can_throw = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	health_brute = 10
	health_brute_vuln = 0.5
	health_burn = 10
	health_burn_vuln = 0
	faction = list(FACTION_DERELICT)
	ai_retaliates = TRUE
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	ai_type = /datum/aiHolder/aggressive
	is_npc = TRUE
	voice_sound_override = list('sound/voice/creepywhisper_1.ogg', 'sound/voice/creepywhisper_2.ogg', 'sound/voice/creepywhisper_3.ogg')

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb/transposed
		HH.icon_state = "handl"				// the icon state of the hand UI background
		HH.limb_name = "left transposed arm"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb/transposed
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"				// the icon state of the hand UI background
		HH.limb_name = "right transposed arm"

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (src.ai?.enabled && prob(5))
			if (src.ai.current_task == "wandering")
				src.say(pick("namlugallu ha-lam ina lugal-šaà-lá-sù...","ù da-rí-sè šeš...","á-e-me-en ìri-zé-er igi-bad!","inim...kí ina ki-dul, ina e-ùr, ina ki-bad-rá, hé-àm-me-àm...", "ìri-kúr...díb, ìri...ar, e-zé...", "galam, gamar ganzer, gíbil píri! ul, ul! súkud..."))
				// mankind destroyed the merciful king // sleep forever, brethren // i am one who lost my footing and opened my eyes // to seek or find the right words, the armor, the secret point, the distant places, that is our wish // to ascend, overwhelming darkness, burning bright! shine! shine! shine brightly!
			else if (prob(50))
				src.say(pick("ina urudu e-re-sì-ki-in kala libir arza ina SÚKUD ZAL.", "i.menden ina nam-ab-ba issa, nam-nu-tar  nam-diir, i.menden lúní-áa...","bar...gub ina bàd-šul-hi...","šidim ak ina libir išgal, diir ak ina agrun, ul-šár-ra, zà-mí!", "ùru pàd gíg, ina gidim niin!"))
				// the copper servant mends the rights of the FLASH OF DAWN // we are the elder shades, ill-fated divinities, we are the temple servants..., step outside the outer wall
				// architect of the ancient throne, god of the inner sanctuary, jubilation, praise! // watchfire reveals night, the darkened monstrosity

	critter_basic_attack(var/mob/target)
		src.chase_lines(target)
		..()

	proc/chase_lines(var/mob/target)
		if(!ON_COOLDOWN(src, "chase_talk", 10 SECONDS))
			if (target.lying || is_incapacitated(target))
				src.say(pick("me-àm ina men-an-uras-a?", "e-zé ina gu-sum... e-zé ina gú-ri-ta!", "e-zé ní-gig, e-zé ní-dím-dím-ma, e-zé šu...bar ina libir lugar!", "namlugallu-zu-ne-ne inim-dirig, namgallu-zu-ne-ne inim-búr-ra, izi te-en ina an!", "ri azag, ri azag, ri azag, ri érim, ri e-zé!", "e-zé, érim diir-da...nu-me-a."))
				// where is the crown of heaven and earth // you are from the writing... you are from the other side // you abominations, created creatures, you let loose the ancient king
				// mankind's hubris, mankind's breach of treaty extinguished the heavens // banish the taboo, banish the taboo, banish you // you, enemy, without a god
			else
				src.say(pick("an-zà, bar ina ká, ina ká! ina ká-bar-ra!", "hul-ál. lúír-lá-ene ina im-dugud-ene. n-ene. e-zé.", "ki-lul-la, ki-in-dar, é-a-nir-ra: urudu e-re-sì-ki-in ina úmun, en-nu-ùa-ak ina lúír-lá-ene", "lú-kúr-ra! lú-ní-zuh! lú-ru-gú!"))
				// where heaven ends, the gate, the gate! the outer door! // the evil ones, the butchers on the lumps of stone. humans. you. // in the place of murder, in the crevice, in the house of mourning: the copper servant formed of thought guards against the butchers //
				// stranger! thief! recalcitrant one! // you don't exist, human!

	death()
		src.say(pick("šìr...áa ina šìr-kug záh-bi!", "éd, èd, šu...bar...", "ní-nam-nu-kal...", "lugal-me taru, lugal-me galam!", "me-li-e-a..."))
		..()
		// sing the sacred song to the bitter end // go out, exit, release // nothing is precious // our king will return, our king will ascend // woe is me
		SPAWN(1.5 SECONDS)
			qdel(src)

	valid_target(mob/living/C)
		if (istype(C, /mob/living/critter/shade)) return FALSE
		return ..()

	seek_target(var/range = 5)
		. = ..()

		if (length(.) && prob(5))
			src.say(pick("siskur, siskur ina na sukkal...","ára ina gíg, úš ina ur zal...","lú-érim! lú-érim!","áš á-zi-ga...bal, na, e-zé ha-lam ina é si-ga..."))
			// sacrifice, sacrifice the human envoy! // praise the night, kill the servant of light // enemy! enemy! // cursed with violence, human, you ruin the quiet house

/mob/living/critter/shade/crew
	name = "faded scientist"
	desc = "Something is terribly wrong with them."
	icon = 'icons/mob/human.dmi'
	icon_state = "body_m"
	icon_state_dead = "body_m" //doesn't have a dead icon
	alpha = 192
	color = "#676767"
	health_brute = 30
	health_brute_vuln = 1
	health_burn = 30
	health_burn_vuln = 1
	var/image/jumpsuit = null
	var/image/oversuit = null
	var/jumppath = "scientist-alt"
	var/overpath = null
	var/armourpath = null

	New()
		..()
		if(jumppath)
			ENSURE_IMAGE(src.jumpsuit, 'icons/mob/clothing/jumpsuits/worn_js_rank.dmi', src.jumppath)
			src.UpdateOverlays(src.jumpsuit, "jumpsuit")
		if(overpath)
			ENSURE_IMAGE(src.oversuit,'icons/mob/clothing/overcoats/worn_suit.dmi', src.overpath)
			src.UpdateOverlays(src.oversuit, "oversuit")
		if(armourpath)
			ENSURE_IMAGE(src.oversuit,'icons/mob/clothing/overcoats/worn_suit_armor.dmi', src.armourpath)
			src.UpdateOverlays(src.oversuit, "oversuit")

	death()
		particleMaster.SpawnSystem(new /datum/particleSystem/localSmoke("#000000", 5, get_turf(src)))
		..()
		qdel(src)

	lost
		desc = "Huh? What is this guy doing here?"

		death()
			new /obj/item/paper/otp(get_turf(src))
			..()

	researcher
		name = "faded researcher"
		jumppath = "robotics-alt"
		overpath = "ROlabcoat"

	security
		name = "faded officer"
		desc = "Their armor still seems surprisingly functional."
		health_brute = 50
		health_brute_vuln = 1
		health_burn = 50
		health_burn_vuln = 1
		jumppath = "security"
		armourpath = "heavy"

		get_melee_protection(zone, damage_type)
			return 4

		get_ranged_protection()
			return 1.5

////////////// Repair bots ////////////////
TYPEINFO(/mob/living/critter/robotic/repairbot)
	start_listen_languages = list(LANGUAGE_ENGLISH, LANGUAGE_SILICON, LANGUAGE_BINARY)

/mob/living/critter/robotic/repairbot
	name = "strange robot"
	desc = "It looks like some sort of floating repair bot or something?"
	icon = 'icons/mob/critter/robotic/ancient/repairbot.dmi'
	icon_state = "ancient_repairbot"
	hand_count = 1
	can_throw = FALSE
	can_grab = FALSE
	can_disarm = FALSE
	health_brute = 10
	health_brute_vuln = 0.8
	health_burn = 10
	health_burn_vuln = 0.4
	use_stamina = FALSE
	ai_retaliates = TRUE
	ai_retaliate_patience = 2
	ai_retaliate_persistence = RETALIATE_UNTIL_INCAP
	faction = list(FACTION_DERELICT)
	ai_type = /datum/aiHolder/ranged
	is_npc = TRUE
	death_text = "%src% blows apart!"
	custom_gib_handler = /proc/robogibs
	voice_name = "synthesized voice"

	speech_verb_say = "beeps"
	speech_verb_gasp = "chirps"
	speech_verb_stammer = "beeps"
	speech_verb_exclaim = "beeps"
	speech_verb_ask = "beeps"
	say_language = LANGUAGE_BINARY

	nice
		ai_type = /datum/aiHolder/wanderer

	New()
		..()
		src.name = "[pick("strange","weird","odd","bizarre","quirky","antique")] [pick("robot","automaton","machine","gizmo","thingmabob","doodad","widget")]"
		src.real_name = src.name
		APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOATING, src)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION, src)

	death(var/gibbed)
		elecflash(src, power = 3)
		..(gibbed, 0)
		ghostize()
		qdel(src)

	do_disorient(stamina_damage, knockdown, stunned, unconscious, disorient = 60, remove_stamina_below_zero = 0, target_type = DISORIENT_BODY, stack_stuns = 1)
		return

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/screams/robot_scream.ogg' , 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> screams!"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/ears/intercom(src)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/arcflash
		HH.name = "Electric Intruder Countermeasure"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handzap"
		HH.limb_name = "Electric Intruder Countermeasure"
		HH.can_hold_items = FALSE
		HH.can_attack = FALSE
		HH.can_range_attack = TRUE

	setup_healths()
		add_hh_robot(src.health_brute, src.health_brute_vuln)
		add_hh_robot_burn(src.health_burn, src.health_burn_vuln)

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (src.ai?.enabled && prob(5))
			playsound(src.loc,pick('sound/misc/ancientbot_beep1.ogg','sound/misc/ancientbot_beep2.ogg','sound/misc/ancientbot_beep3.ogg'), 50, 1)

	valid_target(var/mob/living/C)
		if (isrobot(C)) return FALSE
		if (is_incapacitated(C)) return FALSE
		if (istype(C, /mob/living/critter/robotic/repairbot)) return FALSE
		return ..()

	critter_basic_attack(var/mob/target)
		if(prob(30))
			playsound(src.loc, pick('sound/misc/ancientbot_grump.ogg','sound/misc/ancientbot_grump2.ogg'), 50, 1)
		var/list/params = list()
		params["left"] = TRUE
		params["ai"] = TRUE
		src.hand_range_attack(target, params)

/mob/living/critter/robotic/repairbot/security
	name = "strange robot"
	desc = "A Security Robot, something seems a bit off."
	icon_state = "ancient_guardbot"
	health_brute = 15
	health_brute_vuln = 0.8
	health_burn = 15
	health_burn_vuln = 0.2

/mob/living/critter/robotic/repairbot/helldrone
	name = "weird machine"
	desc = "A machine, of some sort. It's probably off."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "drone_service_bot_off"
	health_brute = 20
	health_brute_vuln = 0.8
	health_burn = 20
	health_burn_vuln = 0.6
	var/activated = FALSE

	faction = list(FACTION_SYNDICATE)

	active
		New()
			..()
			SPAWN(2 SECONDS)
				src.wakeup()

	New()
		..()
		REMOVE_ATOM_PROPERTY(src, PROP_ATOM_FLOATING, src)
		src.ai.disable()

	attackby(obj/item/W, mob/user)
		if (!activated)
			return
		return ..()

	proc/wakeup()
		if (src.activated)
			return
		src.ai.enable()
		src.activated = TRUE
		src.icon_state = "drone_service_bot"
		src.desc = "A machine. Of some sort. It looks mad"
		src.visible_message(SPAN_COMBAT("[src] seems to power up!"))

////////////// Town guards ////////////////
/mob/living/critter/townguard
	name = "town guard"
	desc = "An angry man dressed in medieval armor."
	icon = 'icons/mob/critter/humanoid/town_guard.dmi'
	icon_state = "townguard"
	icon_state_dead = "townguard-dead"
	hand_count = 2
	can_throw = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	health_brute = 50
	health_brute_vuln = 1
	health_burn = 50
	health_burn_vuln = 1
	death_text = "%src% seizes up and falls limp, his eyes dead and lifeless..."
	ai_retaliates = TRUE
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	ai_type = /datum/aiHolder/aggressive
	is_npc = TRUE
	var/halt_cooldown = 3 SECONDS

	passive
		desc = "A strange man dressed in medieval armor."
		ai_retaliate_patience = 2
		ai_retaliate_persistence = RETALIATE_UNTIL_INCAP
		ai_type = /datum/aiHolder/wanderer

	seek_target()
		. = ..()

		if (length(.) && prob(10))
			HALT()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","halt")
				if (src.emote_check(voluntary, 50))
					HALT()
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","halt")
				return 2
		return ..()

	get_melee_protection(zone, damage_type)
		return 4

	get_ranged_protection()
		return 1.5

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/ears(src)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb
		HH.icon_state = "handl"
		HH.limb_name = "left arm"

		HH = hands[2]
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.limb = new /datum/limb/sword
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "blade"
		HH.limb_name = "sword"
		HH.can_hold_items = FALSE

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	critter_basic_attack(mob/target)
		HALT()
		// Hand 2 = SWORD Hand 1 = ARM
		if (is_incapacitated(target))
			src.set_a_intent(INTENT_HARM)
			set_hand(1)
			return ..() // Punch / Kick them
		if (prob(30))
			src.set_a_intent(INTENT_DISARM)
			src.set_hand(1)
			return src.hand_attack(target) // Disarm them
		src.set_a_intent(INTENT_HARM)
		set_hand(2)
		return ..() // Stab them

	proc/HALT()
		if(!ON_COOLDOWN(src, "say_HALT!", src.halt_cooldown))
			src.say("HALT!")
			playsound(src.loc, 'sound/voice/guard_halt.ogg', 50, 0)

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/townguard
	name = "\improper Town Guard egg"
	desc = "This is not how humans reproduce. They do not lay eggs. <i>What the hell is this?</i>"
	critter_type = /mob/living/critter/townguard
	warm_count = 75

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/townguard/passive
	critter_type = /mob/living/critter/townguard/passive

////////////// Blobman ////////////////
/mob/living/critter/blobman
	name = "mutant"
	desc = "Some sort of horrific, pulsating blob of flesh."
	icon_state = "blobman"
	icon_state_dead = "blobman-dead"
	density = TRUE
	hand_count = 2
	health_brute = 10
	health_brute_vuln = 0.5
	health_burn = 10
	health_burn_vuln = 0.75
	death_text = "%src% collapses into viscera."
	ai_retaliates = TRUE
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	ai_type = /datum/aiHolder/aggressive
	is_npc = TRUE
	ai_attacks_per_ability = 4
	add_abilities = list(/datum/targetable/critter/tackle)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.icon_state = "handl"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	critter_ability_attack(var/target)
		var/datum/targetable/critter/tackle = src.abilityHolder.getAbility(/datum/targetable/critter/tackle)
		if (!tackle.disabled && tackle.cooldowncheck())
			tackle.handleCast(target)
			return TRUE

/mob/living/critter/blobman/meat
	real_name = "meaty martha" //keeping this because it made me laugh. Overridden by New() anyway
	death_text = null
	ai_attacks_per_ability = 3

	New()
		..()
		src.name = "[pick("grody", "clotty", "greasy", "meaty", "fleshy", "vile", "chunky", "putrid")] [pick("nugget", "bloblet", "pustule", "corpuscle", "viscera")]"
		src.real_name = src.name
		src.icon_state = pick("meaty_mouth", "polyp", "goop")

	critter_ability_attack(var/target) // Kinda hacky
		var/missing_arm = target_missing_limb(target)
		if ((missing_arm == "r_arm" || missing_arm == "l_arm") && ishuman(target))
			var/mob/living/carbon/human/H = target
			src.visible_message(SPAN_ALERT("<b>[src] latches onto [H]'s stump!!</b>"))
			boutput(H, SPAN_ALERT("OH FUCK OH FUCK GET IT OFF GET IT OFF IT STINGS!"))
			playsound(src.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
			H.emote("scream")
			H.changeStatus("stunned", 2 SECONDS)
			random_brute_damage(H, 5)
			switch (missing_arm)
				if ("r_arm")
					var/obj/item/parts/human_parts/arm/meat_mutant/part = new /obj/item/parts/human_parts/arm/meat_mutant/right {remove_stage = 2;} (H)
					H.limbs.vars["r_arm"] = part
					part.holder = H

				if ("l_arm")
					var/obj/item/parts/human_parts/arm/meat_mutant/part = new /obj/item/parts/human_parts/arm/meat_mutant/left {remove_stage = 2;} (H)
					H.limbs.vars["l_arm"] = part
					part.holder = H

			H.update_body()
			H.update_clothing()
			H.unlock_medal("My Bologna Has A First Name",1)
			qdel(src)
		else
			..()

	death(var/gibbed)
		..()
		if (!gibbed)
			src.visible_message(SPAN_ALERT("[src] explodes into viscera!"))
			src.unequip_all()
			src.gib()

	proc/update_meat_head_dialog(var/new_text)
		if (!new_text || !length(ckey(new_text)))
			return
		var/obj/critter/monster_door/meat_head/main_meat_head = by_type[/obj/critter/monster_door/meat_head][1]
		main_meat_head.update_meat_head_dialog(new_text)

	proc/target_missing_limb(var/mob/living/carbon/human/testhuman)
		if (!istype(testhuman) || !testhuman.limbs)
			return null

		if (!testhuman.limbs.l_arm)
			return "l_arm"
		else if (!testhuman.limbs.r_arm)
			return "r_arm"

		return null

