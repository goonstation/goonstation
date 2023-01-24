/mob/living/critter/martian
	name = "martian"
	real_name = "martian"
	var/martian_type = "basic"
	desc = "Genocidal monsters from Mars."
	density = 1
	icon_state = "martian"
	icon_state_dead = "martian-dead"
	custom_gib_handler = /proc/martiangibs
	custom_brain_type = /obj/item/organ/brain/martian
	say_language = "martian"
	voice_name = "martian"
	blood_id = "iron" // alchemy - mars = iron
	hand_count = 1
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	can_help = 1
	speechverb_say = "screeches"
	speechverb_exclaim = "screeches"
	speechverb_ask = "screeches"
	speechverb_gasp = "screeches"
	speechverb_stammer = "screeches"
	var/leader = 0

	understands_language(var/langname)
		if (langname == say_language || langname == "martian")
			return 1
		return 0

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/ears(src)
		equipment += new /datum/equipmentHolder/head(src)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.name = "tentacles"

	setup_healths()
		add_hh_flesh(35, 0.5)
		add_hh_flesh_burn(35, 1)
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
		abilityHolder.addAbility(/datum/targetable/critter/psyblast/martian)
		abilityHolder.addAbility(/datum/targetable/critter/teleport)

		// back once again to ruin the day, it's CIRR fucking up things
		SPAWN(0)
			var/randomname = pick(strings("martian_names.txt", "martianname"))
			var/newname = adminscrub(input(src,"You are a Martian. Would you like to change your name to something else?", "Name change", randomname) as text)

			if (length(ckey(newname)) == 0)
				newname = randomname

			if (newname)
				if (length(newname) >= 26) newname = copytext(newname, 1, 26)
				src.real_name = strip_html(newname)
				src.UpdateName()

	say(message, involuntary = 0)
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

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
					playsound(src, 'sound/voice/screams/martian_screech.ogg', 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> emits a psychic screech!"
			if ("growl")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/screams/martian_growl.ogg', 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> gives a guttural psionic growl!"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream", "growl")
				return 2
		return ..()

	warrior
		name = "martian warrior"
		real_name = "martian warrior"
		martian_type = "warrior"
		icon_state = "martianW"
		icon_state_dead = "martianW-dead"
		hand_count = 2

		setup_hands()
			..()
			var/datum/handHolder/HH = hands[1]
			HH.icon = 'icons/mob/hud_human.dmi'
			HH.icon_state = "handl"
			HH.limb_name = "left tentacles"

			HH = hands[2]
			HH.name = "right tentacles"
			HH.suffix = "-R"
			HH.icon_state = "handr"
			HH.limb_name = "right tentacles"

	soldier
		name = "martian soldier"
		real_name = "martian soldier"
		martian_type = "soldier"
		icon_state = "martianS"
		icon_state_dead = "martianS-dead"
		hand_count = 2

		setup_hands()
			..()

			var/datum/handHolder/HH = hands[2]
			HH.limb = new /datum/limb/hitscan
			HH.name = "Martian Psychokinetic Blaster"
			HH.icon = 'icons/mob/critter_ui.dmi'
			HH.icon_state = "hand_martian"
			HH.limb_name = "Martian Psychokinetic Blaster"
			HH.can_hold_items = 0
			HH.can_attack = 0
			HH.can_range_attack = 1

			HH = hands[1]
			HH.name = "right tentacles"
			HH.suffix = "-R"
			HH.icon_state = "handr"
			HH.limb_name = "right tentacles"

	mutant
		name = "martian mutant"
		real_name = "martian mutant"
		martian_type = "mutant"
		icon_state = "martianP"
		icon_state_dead = "martianP-dead"

		New()
			..()
			abilityHolder.addAbility(/datum/targetable/critter/gibstare)
			abilityHolder.addAbility(/datum/targetable/critter/telepathy)

	mutant/weak

		name = "martian initiate"
		real_name = "martian initiate"
		martian_type = "initiate"

		New()
			..()
			abilityHolder.removeAbility(/datum/targetable/critter/gibstare) // enough is enough

	sapper
		name = "martian sapper"
		real_name = "martian sapper"
		martian_type = "sapper"
		icon_state = "martianSP"
		icon_state_dead = "martianSP-dead"

	overseer
		name = "martian overseer"
		real_name = "martian overseer"
		martian_type = "overseer"
		icon_state = "martianL"
		icon_state_dead = "martianL-dead"
		leader = 1

		New()
			..()
			abilityHolder.addAbility(/datum/targetable/critter/summon)
			abilityHolder.addAbility(/datum/targetable/critter/telepathy)

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
		rendered = "<span class='game martiansay'><span class='name'>ADMIN([show_other_key ? C.fakekey : C.key])</span> telepathically messages, <span class='message'>\"[message]\"</span></span>"
		adminrendered = "<span class='game martiansay'><span class='name' data-ctx='\ref[speaker.mind]'>[show_other_key ? "ADMIN([C.key] (as [C.fakekey])" : "ADMIN([C.key]"])</span> telepathically messages, <span class='message'>\"[message]\"</span></span>"
	else
		var/class = "martiansay"
		if(ismartian(speaker))
			var/mob/living/critter/martian/M = speaker
			if(M.leader)
				class = "martianimperial"
		rendered = "<span class='game [class]'><span class='name'>[speaker.real_name]</span> telepathically messages, <span class='message'>\"[message]\"</span></span>"
		adminrendered = "<span class='game [class]'><span class='name' data-ctx='\ref[speaker.mind]'>[speaker.real_name]</span> telepathically messages, <span class='message'>\"[message]\"</span></span>"



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
	hand_count = 2

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/ears(src)
		equipment += new /datum/equipmentHolder/head(src)
		//equipment += new /datum/equipmentHolder/

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.icon_state = "handl"
		HH.limb_name = "left tentacles"

		HH = hands[2]
		HH.name = "right tentacles"
		HH.suffix = "-R"
		HH.icon_state = "handr"
		HH.limb_name = "right tentacles"

	setup_healths()
		add_hh_flesh(50, 0.5)
		add_hh_flesh_burn(50, 1)
		add_health_holder(/datum/healthHolder/toxin)
		var/datum/healthHolder/Brain = add_health_holder(/datum/healthHolder/brain)
		Brain.maximum_value = 0
		Brain.value = 0
		Brain.minimum_value = -250
		Brain.depletion_threshold = -100
		Brain.last_value = 0

	New()
		..()
		// TEMPORARY THING TO ESTABLISH THESE DUDES AS EXPLICITLY ANTAGS OK
		SPAWN(1 DECI SECOND)
			src.show_antag_popup("martian")
			boutput(src, "<h2><font color=red>You are a Martian Infiltrator!</font></h2>")
			boutput(src, "<font color=red>Find a safe place to start building a base with your teammates!</font>")
			if(src.leader)
				boutput(src, "<font color=red>You are the leader of your infiltration group, and have additional abilities they do not.</font>")
				boutput(src, "<font color=red>You start with a biotech seed that can be used to start a base. It will spawn a seed grower. Plant it somewhere safe!</font>")
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
	leader = 1

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
