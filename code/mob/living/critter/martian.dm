/* If anyone wants to make the martian gamemode again add subtypes for player martians which are beefier
	could also possibly use the martian mutantrace */

/mob/living/critter/martian
	name = "martian"
	real_name = "martian"
	var/martian_type = "basic"
	desc = "Murderous monsters from Mars."
	density = 1
	icon_state = "martian"
	icon_state_dead = "martian-dead"
	custom_gib_handler = /proc/martiangibs
	custom_brain_type = /obj/item/organ/brain/martian
	say_language = "martian"
	voice_name = "martian"
	blood_id = "iron" // alchemy - mars = iron
	hand_count = 2
	can_throw = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	can_help = TRUE
	health_brute = 50
	health_brute_vuln = 0.5
	health_burn = 50
	health_burn_vuln = 1.5
	speechverb_say = "burbles"
	speechverb_exclaim = "screeches"
	speechverb_ask = "warbles"
	speechverb_gasp = "gurgles"
	speechverb_stammer = "crackles"

	ai_type = /datum/aiHolder/aggressive
	ai_retaliate_patience = 3
	ai_retaliate_persistence = RETALIATE_ONCE
	ai_retaliates = TRUE
	is_npc = TRUE

	var/leader = FALSE
	var/telerange = 5

	understands_language(var/langname)
		if (langname == say_language || langname == "martian")
			return TRUE
		return FALSE

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/ears(src)
		equipment += new /datum/equipmentHolder/head(src)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.icon_state = "handl"
		HH.limb_name = "left tentacles"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.name = "right tentacles"
		HH.suffix = "-R"
		HH.icon_state = "handr"
		HH.limb_name = "right tentacles"

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)
		add_health_holder(/datum/healthHolder/toxin)
		//add_health_holder(/datum/healthHolder/suffocation) // this is broken as hell
		var/datum/healthHolder/Brain = add_health_holder(/datum/healthHolder/brain)
		Brain.maximum_value = 0
		Brain.value = 0
		Brain.minimum_value = -250
		Brain.depletion_threshold = -100
		Brain.last_value = 0

	New()
		..()
		abilityHolder.addAbility(/datum/targetable/artifact_limb_ability/martian_pull)
		abilityHolder.addAbility(/datum/targetable/critter/psyblast/martian)
		abilityHolder.addAbility(/datum/targetable/critter/teleport)

		// back once again to ruin the day, it's CIRR fucking up things
		/*SPAWN(0) // Commenting this out until martian gamemode is real again
			if (src.mind && src.ckey)
				var/randomname = pick(strings("martian_names.txt", "martianname"))
				var/newname = adminscrub(input(src,"You are a Martian. Would you like to change your name to something else?", "Name change", randomname) as text)

				if (length(ckey(newname)) == 0)
					newname = randomname

				if (newname)
					if (length(newname) >= 26) newname = copytext(newname, 1, 26)
					src.real_name = strip_html(newname)
					src.UpdateName() */

	valid_target(mob/living/C)
		if(ismartian(C)) return FALSE
		return ..()

	critter_retaliate(var/mob/target)
		var/datum/targetable/critter/psyblast/martian/blast = src.abilityHolder.getAbility(/datum/targetable/critter/psyblast/martian)
		var/datum/targetable/critter/teleport/teleport = src.abilityHolder.getAbility(/datum/targetable/critter/teleport)
		if (!blast.disabled && blast.cooldowncheck() && prob(50))
			blast.handleCast(target)
			. = TRUE
			if(!teleport.disabled && teleport.cooldowncheck())
				var/list/randomturfs = new/list()
				for(var/turf/T in orange(src, telerange))
					if(istype(T, /turf/space) || T.density)
						continue
					randomturfs.Add(T)
				teleport.handleCast(pick(randomturfs))

	say(message, involuntary = 0)
		message = trimtext(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

		..(message)

		if (involuntary || message == "" || stat)
			return
		if (dd_hasprefix(message, "*"))
			return

		// Strip the radio prefix (if it exists) and just get the message
		var/prefixAndMessage = separate_radio_prefix_and_message(message)
		message = prefixAndMessage[2]

		// martian telepathy to all martians
		// cirr edit: i have moved this to a proc at the bottom of this file
		// cirr TODO: move this to chatprocs.dm dammit
		martian_speak(src, message)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/screams/martian_screech.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> emits a psychic screech!"
			if ("growl")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/screams/martian_growl.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> gives a guttural psionic growl!"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream", "growl")
				return 2
		return ..()

/mob/living/critter/martian/warrior
	name = "martian warrior"
	real_name = "martian warrior"
	martian_type = "warrior"
	icon_state = "martianW"
	icon_state_dead = "martianW-dead"
	health_brute = 100
	health_burn = 100

	New()
		..()
		abilityHolder.addAbility(/datum/targetable/critter/slam)
		abilityHolder.addAbility(/datum/targetable/critter/tackle)


	critter_attack(var/mob/target)
		if (src.equipped())
			var/obj/item/grab/G = src.equipped()
			if (istype(G))
				if (G.state < GRAB_CHOKE)
					G.AttackSelf(src)
				else if (prob(20) || (target.get_oxygen_deprivation() < 60))
					src.drop_item()
					ON_COOLDOWN(src, "warrior_grab", 10 SECONDS)
			else
				src.drop_item()
		else if (is_incapacitated(target) && !length(target.grabbed_by) && !GET_COOLDOWN(src, "warrior_grab") && ishuman(target))
			src.set_a_intent(INTENT_GRAB)
			src.hand_attack(target)
		else
			src.set_a_intent(INTENT_HARM)
			src.hand_attack(target)

	was_harmed(var/mob/M, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
		if (src.equipped())
			src.drop_item()
		..()

/mob/living/critter/martian/soldier
	name = "martian soldier"
	real_name = "martian soldier"
	martian_type = "soldier"
	icon_state = "martianS"
	icon_state_dead = "martianS-dead"
	ai_type = /datum/aiHolder/ranged
	health_brute = 100
	health_burn = 100

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/hitscan
		HH.name = "Martian Psychokinetic Blaster"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "hand_martian"
		HH.limb_name = "Martian Psychokinetic Blaster"
		HH.can_hold_items = FALSE
		HH.can_attack = FALSE
		HH.can_range_attack = TRUE

/mob/living/critter/martian/mutant
	name = "martian mutant"
	real_name = "martian mutant"
	martian_type = "mutant"
	icon_state = "martianP"
	icon_state_dead = "martianP-dead"
	health_brute = 33
	health_burn = 33
	ai_type = /datum/aiHolder/ranged

	New()
		..()
		abilityHolder.addAbility(/datum/targetable/critter/gibstare)
		abilityHolder.addAbility(/datum/targetable/critter/telepathy)
		abilityHolder.addAbility(/datum/targetable/critter/scarylook)

	critter_attack(var/mob/target)
		var/datum/targetable/critter/gibstare/gib = src.abilityHolder.getAbility(/datum/targetable/critter/gibstare)
		if (!gib.disabled && gib.cooldowncheck())
			gib.handleCast(target)
			return TRUE

	can_critter_attack()
		var/datum/targetable/critter/gibstare/gib = src.abilityHolder.getAbility(/datum/targetable/critter/gibstare)
		return ..() && !gib.disabled

/mob/living/critter/martian/initiate
	name = "martian initiate"
	real_name = "martian initiate"
	martian_type = "initiate"
	icon_state = "martianP"
	icon_state_dead = "martianP-dead"
	health_brute = 25
	health_burn = 25

	New()
		..()
		abilityHolder.addAbility(/datum/targetable/critter/telepathy)
		abilityHolder.addAbility(/datum/targetable/critter/scarylook)

/mob/living/critter/martian/mortian
	name = "mortian"
	real_name = "mortian"
	martian_type = "mortian"
	icon_state = "martianM"
	icon_state_dead = "martianM-dead"
	health_brute = 100
	health_burn = 100

	New()
		..()
		abilityHolder.addAbility(/datum/targetable/critter/telepathy)
		abilityHolder.addAbility(/datum/targetable/critter/bholerip)
		abilityHolder.addAbility(/datum/targetable/critter/fadeout)
		abilityHolder.addAbility(/datum/targetable/critter/writhe)

// These were for a martian gamemode so im leaving them as non-npcs for now
/mob/living/critter/martian/sapper
	name = "martian sapper"
	real_name = "martian sapper"
	martian_type = "sapper"
	icon_state = "martianSP"
	icon_state_dead = "martianSP-dead"

	New()
		..()
		abilityHolder.addAbility(/datum/targetable/critter/zzzap)
		abilityHolder.addAbility(/datum/targetable/critter/bury_hide)


/mob/living/critter/martian/overseer
	name = "martian overseer"
	real_name = "martian overseer"
	martian_type = "overseer"
	icon_state = "martianL"
	icon_state_dead = "martianL-dead"
	health_brute = 200
	health_burn = 200
	leader = TRUE
	//is_npc = FALSE

	New()
		..()
		abilityHolder.addAbility(/datum/targetable/critter/summon)
		abilityHolder.addAbility(/datum/targetable/critter/telepathy)
		abilityHolder.addAbility(/datum/targetable/critter/mezzer)

// this is being copied and pasted more than once, this ends now
// merging in the admin verb stuff so we can display the appropriate stuff to admins when players speak, because knowing real names of martian babblers would be nice
// getting kinda tired of needing to use player options to distinguish between them
proc/martian_speak(var/mob/speaker, var/message as text, var/speak_as_admin=0)

	var/client/C = speaker.client

	var/rendered = ""
	var/adminrendered = ""
	if(C?.holder && speak_as_admin)
		// admin mode go
		var/show_other_key = 0
		if (C.stealth || C.alt_key)
			show_other_key = 1
		rendered = SPAN_MARTIANSAY("[SPAN_NAME("ADMIN([show_other_key ? C.fakekey : C.key])")] telepathically messages, [SPAN_MESSAGE("\"[message]\"")]")
		adminrendered = SPAN_MARTIANSAY("<span class='name' data-ctx='\ref[speaker.mind]'>[show_other_key ? "ADMIN([C.key] (as [C.fakekey])" : "ADMIN([C.key]"])</span> telepathically messages, [SPAN_MESSAGE("\"[message]\"")]")
	else
		var/class = "martiansay"
		if(ismartian(speaker))
			var/mob/living/critter/martian/M = speaker
			if(M.leader)
				class = "martianimperial"
		rendered = "<span class='[class]'>[SPAN_NAME("[speaker.real_name]")] telepathically messages, [SPAN_MESSAGE("\"[message]\"")]</span>"
		adminrendered = "<span class='[class]'><span class='name' data-ctx='\ref[speaker.mind]'>[speaker.real_name]</span> telepathically messages, [SPAN_MESSAGE("\"[message]\"")]</span>"

	for (var/client/CC)
		if (!CC.mob) continue
		if(istype(CC.mob, /mob/new_player))
			continue
		var/mob/M = CC.mob

		if ((ismartian(M)) || M.client.holder && !M.client.player_mode)
			var/thisR = rendered
			if ((istype(M, /mob/dead/observer)||M.client.holder) && speaker.mind)
				thisR = "<span class='adminHearing' data-ctx='[M.client.chatOutput.getContextFlags()]'>[adminrendered]</span>"
			M.show_message(thisR, 2)

/////////////////////////////////////////////////////////////////////////////////////////////////////////

// sticking this here for now

/mob/living/critter/martian/infiltrator
	name = "martian infiltrator"
	real_name = "martian infiltrator"
	martian_type = "infiltrator"
	icon_state = "martianI"
	icon_state_dead = "martianI-dead"
	health_brute = 75
	health_burn = 75
	is_npc = FALSE

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/ears(src)
		equipment += new /datum/equipmentHolder/head(src)
		//equipment += new /datum/equipmentHolder

	New()
		..()
		// TEMPORARY THING TO ESTABLISH THESE DUDES AS EXPLICITLY ANTAGS OK
		SPAWN(1 DECI SECOND)
			src.show_antag_popup("martian")
			boutput(src, "<h2>[SPAN_ALERT("You are a Martian Infiltrator!")]</h2>")
			boutput(src, SPAN_ALERT("Find a safe place to start building a base with your teammates!"))
			if(src.leader)
				boutput(src, SPAN_ALERT("You are the leader of your infiltration group, and have additional abilities they do not."))
				boutput(src, SPAN_ALERT("You start with a biotech seed that can be used to start a base. It will spawn a seed grower. Plant it somewhere safe!"))
			if (src.mind && ticker.mode)
				if (!src.mind.special_role)
					src.mind.special_role = "martian"
				if (!(src.mind in ticker.mode.Agimmicks))
					ticker.mode.Agimmicks += src.mind

/mob/living/critter/martian/infiltrator/specialist
	name = "martian specialist"
	real_name = "martian specialist"
	martian_type = "specialist"
	icon_state = "martianST"
	icon_state_dead = "martianST-dead"
	leader = TRUE
	is_npc = FALSE

	New()
		..()
		abilityHolder.addAbility(/datum/targetable/critter/summon)
		abilityHolder.addAbility(/datum/targetable/critter/telepathy)

// TODO: a reason for this dude
///mob/living/critter/martian/infiltrator/mancer
//	name = "martian mancer"
//	real_name = "martian mancer"
//	martian_type = "mancer"
//	icon_state = "martianM"
//	icon_state_dead = "martianM-dead"

/obj/machinery/martianbomb
	name = "martian bomb"
	desc = "You'd best destroy this thing fast."
	icon = 'icons/obj/martian.dmi'
	icon_state = "mbomb-off"
	anchored = ANCHORED
	density = 1
	var/health = 100
	var/active = 0
	var/timeleft = 300

	process()
		if (src.active)
			src.icon_state = "mbomb-timing"
			src.timeleft -= 1
			if (src.timeleft <= 30) src.icon_state = "mbomb-det"
			if (src.timeleft == 0)
				explosion_new(src, src.loc, 62)
				qdel (src)
			//proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range)
		else
			src.icon_state = "mbomb-off"

	ex_act(severity)
		if(severity)
			src.visible_message(SPAN_NOTICE("<B>[src]</B> crumbles away into dust!"))
			qdel (src)
		return

	bullet_act(var/obj/projectile/P)
		var/damage = 0
		damage = round((P.power*P.proj_data.ks_ratio), 1.0)

		if(src.material) src.material.triggerOnBullet(src, src, P)

		if(P.proj_data.damage_type == D_KINETIC)
			if(damage >= 20)
				src.health -= damage
			else
				damage = 0
		else if(P.proj_data.damage_type == D_PIERCING)
			src.health -= (damage*2)
		else if(P.proj_data.damage_type == D_ENERGY)
			src.health -= damage
		else
			damage = 0

		if(damage >= 15)
			if (src.active && src.timeleft > 10)
				for(var/mob/O in hearers(src, null))
					O.show_message(SPAN_ALERT("<B>[src]</B> begins buzzing loudly!"), 1)
				src.timeleft = 10

		if (src.health <= 0)
			src.visible_message(SPAN_NOTICE("<B>[src]</B> crumbles away into dust!"))
			qdel (src)

	attackby(obj/item/W, mob/user)
		..()
		src.health -= W.force
		if (src.active && src.timeleft > 10)
			for(var/mob/O in hearers(src, null))
				O.show_message(SPAN_ALERT("<B>[src]</B> begins buzzing loudly!"), 1)
			src.timeleft = 10
		if (src.health <= 0)
			src.visible_message(SPAN_NOTICE("<B>[src]</B> crumbles away into dust!"))
			qdel (src)

