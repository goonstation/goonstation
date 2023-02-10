// these are all faults that only work on items
#define ITEM_ONLY_FAULTS /datum/artifact_fault/grow, /datum/artifact_fault/shrink
// these are all faults that only make sense on artifacts that people touch
#define TOUCH_ONLY_FAULTS /datum/artifact_fault/poison

// FAULTS
ABSTRACT_TYPE(/datum/artifact_fault/)
/datum/artifact_fault
	// these are booby traps, self-defense mechanisms, hardware faults or just other nasty shit that can fuck you up when you
	// use the artifact for anything
	var/type_name = "bad artifact code"
	var/trigger_prob = 0
	var/tmp/datum/artifact/holder = null
	var/halt_loop = 0

	proc/deploy(var/obj/O,var/mob/living/user,var/atom/cosmeticSource)
		if (!O || !user)
			return 1
		return 0

/datum/artifact_fault/burn
	// sets the victim on fire
	type_name = "Fire"
	trigger_prob = 8
	var/burn_amount = 40

	deploy(var/obj/O,var/mob/living/user,var/atom/cosmeticSource)
		if (..())
			return
		var/turf/T = get_turf(user)
		T.visible_message("<span class='alert'>The [cosmeticSource.name] suddenly emits a burst of flame!</span>")
		fireflash(T, 0)
		playsound(T, 'sound/effects/bamf.ogg', 100, 1)

/datum/artifact_fault/irradiate
	// irradiates the victim
	type_name = "Radiation"
	trigger_prob = 8
	var/rads_amount = 2 SIEVERTS

	deploy(var/obj/O,var/mob/living/user,var/atom/cosmeticSource)
		if (..())
			return
		boutput(user, "<span class='alert'>You feel strange.</span>")
		user.take_radiation_dose(src.rads_amount)

/datum/artifact_fault/shutdown
	// deactivates the artifact
	type_name = "Deactivation"
	trigger_prob = 10
	halt_loop = 1

	deploy(var/obj/O,var/mob/living/user,var/atom/cosmeticSource)
		if (..())
			return
		var/turf/T = get_turf(O)
		T.visible_message("<span class='alert'>The [O.name] suddenly deactivates!</span>")
		playsound(T, 'sound/effects/shielddown2.ogg', 100, 1)
		O.ArtifactDeactivated()

/datum/artifact_fault/warp
	// warps the user off somewhere random
	type_name = "Teleportation"
	trigger_prob = 15

	deploy(var/obj/O,var/mob/living/user,var/atom/cosmeticSource)
		if (..())
			return
		var/turf/T = get_turf(O)
		T.visible_message("<span class='alert'>The [cosmeticSource.name] warps [user.name] away!</span>")
		playsound(T, 'sound/effects/mag_warp.ogg', 100, 1)
		user.set_loc(pick(random_floor_turfs))

/datum/artifact_fault/grow
	// embiggens the artifact
	type_name = "Growth"
	trigger_prob = 10

	deploy(var/obj/O,var/mob/living/user,var/atom/cosmeticSource)
		if (..())
			return
		if (!isitem(O))
			return
		var/obj/item/I = O
		if(I.w_class > W_CLASS_GIGANTIC)
			return

		boutput(user, "<span class='alert'>The [I.name] grows in size!</span>")
		I.transform = matrix(I.transform, 1.1, 1.1, MATRIX_SCALE)
		I.w_class++
		if (I.loc == user && I.w_class > W_CLASS_BULKY)
			boutput(user, "<span class='alert'>You can't maintain a grip due to its excessive girth!</span>")
			user.u_equip(I)
			I.set_loc(user.loc)

/datum/artifact_fault/shrink
	// ensmallens the artifact
	type_name = "Shrinkage"
	trigger_prob = 10

	deploy(var/obj/O,var/mob/living/user,var/atom/cosmeticSource)
		if (..())
			return
		if (!isitem(O))
			return
		var/obj/item/I = O

		boutput(user, "<span class='alert'>The [I.name] shrinks in size!</span>")
		I.transform = matrix(I.transform, 0.9, 0.9, MATRIX_SCALE)
		I.w_class--
		if (I.w_class < W_CLASS_TINY)
			boutput(user, "<span class='alert'>The artifact shrinks away into nothingness!</span>")
			user.u_equip(I)
			I.set_loc(user.loc)
			I.invisibility = INVIS_ALWAYS_ISH

/datum/artifact_fault/murder
	// gibs the user
	type_name = "Vaporization"
	trigger_prob = 1
	halt_loop = 1

	deploy(var/obj/O,var/mob/living/user,var/atom/cosmeticSource)
		if (..())
			return
		if (isitem(O))
			var/obj/item/I = O
			if (I.loc == user)
				user.u_equip(I)
				I.dropped(user)
		var/turf/T = get_turf(O)
		T.visible_message("<span class='alert'><b>The [cosmeticSource.name] utterly annihilates [user.name]!</b></span>")
		playsound(T, 'sound/effects/elec_bigzap.ogg', 40, 1) // seriously 100 volume on this file? Are you trying to deafen players?
		logTheThing(LOG_COMBAT, user, "was elecgibbed by an artifact fault from [O] at [log_loc(user)].")
		user.elecgib()

/datum/artifact_fault/explode
	// causes an explosion and destroys the artifact
	type_name = "Explosion"
	trigger_prob = 1
	halt_loop = 1

	deploy(var/obj/O,var/mob/living/user,var/atom/cosmeticSource)
		if (..())
			return
		var/turf/T = get_turf(O)
		T.visible_message("<span class='alert'>The [cosmeticSource.name] suddenly explodes!</span>")
		if (isitem(O))
			var/obj/item/I = O
			user.u_equip(I)
			I.dropped(user)
		explosion(O, T, 0, 1, 2, 4)
		O.ArtifactDestroyed()

/datum/artifact_fault/zap
	// electrocutes the user
	type_name = "Electricity"
	trigger_prob = 6

	deploy(var/obj/O,var/mob/living/user,var/atom/cosmeticSource)
		if (..())
			return
		var/turf/T = get_turf(O)
		T.visible_message("<span class='alert'><b>[user.name]</b> is shocked by a surge of energy from [cosmeticSource.name]!</span>")
		var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
		s.set_up(4, 1, user)
		s.start()
		elecflash(user,power = 6, exclude_center = 0)
		user.stuttering += 30

ABSTRACT_TYPE(/datum/artifact_fault/messager/)
/datum/artifact_fault/messager
	trigger_prob = 30
	var/say_instead = FALSE
	var/text_style = null
	var/list/messages = list()

	New()
		. = ..()
		if(prob(25))
			src.say_instead = TRUE

	proc/generate_message(obj/O, mob/living/user,var/atom/cosmeticSource)
		if(length(messages))
			return pick(messages)
		return "😱"

	deploy(var/obj/O,var/mob/living/user,var/atom/cosmeticSource)
		if (..())
			return
		if(src.say_instead)
			var/msg = "[prob(20)?"":";"][generate_message(O, user)]"
			if(prob(20))
				user.say(";[generate_message(O, user)]")
			else
				user.say(generate_message(O, user))
			var/datum/artifact/A = O.artifact
			logTheThing(LOG_SAY, src, "SAY: [html_encode(msg)] [log_loc(user)] (was forced to speak by artifact of type [A.type] due to fault [src.type])")
			return
		switch(text_style)
			if ("small")
				boutput(user, "<small>[generate_message(O, user, cosmeticSource)]</small>")
			if ("big")
				boutput(user, "<big>[generate_message(O, user, cosmeticSource)]</big>")
			if ("red")
				boutput(user, "<span class='alert'>[generate_message(O, user, cosmeticSource)]</span>")
			if ("blue")
				boutput(user, "<span class='notice'>[generate_message(O, user, cosmeticSource)]</span>")
			if ("monospace")
				boutput(user, "<span style='font-family: monospace;'>[generate_message(O, user, cosmeticSource)]</span>")
			else
				boutput(user, "[generate_message(O, user, cosmeticSource)]")

/datum/artifact_fault/messager/creepy_whispers
	type_name = "Unsettling messages"
	text_style = "small"
	messages = list("its your fault","theyre going to get you","no escape","youre going to die here","no hope",
	"die","stop","give up","no","theyre watching you","theres nothing you can do","you have failed","run","i see you",
	"surrender","its hopeless","you are in hell","its all lies","hate","there is only despair","your heart will stop",
	"they will all forget you","they have abandoned you","please stop","no one will mourn you")

/datum/artifact_fault/messager/comforting_whispers
	type_name = "Comforting messages"
	text_style = "small"
	messages = list("it's not your fault", "believe in yourself", "you are strong", "you can do it!", "keep on trying",
	"life is beautiful", "you are important", "this station relies on you", "you can do anything", "follow your dreams",
	"success awaits", "your friends think you are very cool", "be yourself", "everything is fine", "there's still hope",
	"nothing is impossible", "don't stop trying", "you are smart", "love", "today is your lucky day", "I'll always be there for you")

/datum/artifact_fault/messager/what_people_said
	type_name = "Capricious messages"
	text_style = "small"
	generate_message(obj/O, mob/living/user,var/atom/cosmeticSource)
		return phrase_log.random_phrase("say")

/datum/artifact_fault/messager/what_dead_people_said
	type_name = "Postmortal messages"
	text_style = "small"
	generate_message(obj/O, mob/living/user,var/atom/cosmeticSource)
		return phrase_log.random_phrase("deadsay")

/datum/artifact_fault/messager/ai_laws
	type_name = "Machine messages"
	trigger_prob = 15
	text_style = "monospace"
	generate_message(obj/O, mob/living/user,var/atom/cosmeticSource)
		return phrase_log.random_phrase("ailaw")

/datum/artifact_fault/messager/emoji
	type_name = "Alien messages"
	var/list/allowed_emoji = null
	New()
		..()
		if(prob(70))
			allowed_emoji = list()
			for(var/i in 1 to rand(1, 10))
				allowed_emoji += random_emoji()

	generate_message(obj/O, mob/living/user)
		. = list()
		for(var/i in 1 to rand(1, 10))
			if(!length(src.allowed_emoji) || prob(2))
				. += random_emoji()
			else
				. += pick(src.allowed_emoji)
		return jointext(., "")

/datum/artifact_fault/poison
	type_name = "Toxins"
	trigger_prob = 8
	var/poison_type = "toxin"
	var/poison_amount = 10

	deploy(var/obj/O,var/mob/living/user,var/atom/cosmeticSource)
		if (..())
			return
		boutput(user, "<span class='alert'>The [cosmeticSource.name] stings you!</span>")
		if (user.reagents)
			user.reagents.add_reagent(poison_type,poison_amount)
