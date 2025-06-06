///////////////////////
// Totally Crippling //
///////////////////////

/datum/bioEffect/blind
	name = "Blindness"
	desc = "Disconnects the optic nerves from the brain, rendering the subject unable to see."
	id = "blind"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	probability = 33
	msgGain = "You can't seem to see anything!"
	msgLose = "Your vision returns!"
	reclaim_fail = 15
	stability_loss = -20
	lockProb = 50
	lockedGaps = 2
	lockedDiff = 4
	lockedChars = list("G","C","A","T")
	lockedTries = 10
	icon_state  = "bad"
	effect_group = "vision"


/datum/bioEffect/mute
	name = "Frontal Gyrus Suspension"
	desc = "Completely shuts down the speech center of the subject's brain."
	id = "mute"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	probability = 33
	msgGain = "You feel unable to express yourself at all."
	msgLose = "You feel able to speak freely again."
	reclaim_fail = 15
	stability_loss = -20
	lockProb = 50
	lockedGaps = 2
	lockedDiff = 4
	lockedChars = list("G","C","A","T")
	lockedTries = 10
	icon_state  = "speech_mime"

	OnAdd()
		. = ..()
		owner.ensure_speech_tree().AddSpeechModifier(SPEECH_MODIFIER_MUTE)

	OnRemove()
		owner.ensure_speech_tree().RemoveSpeechModifier(SPEECH_MODIFIER_MUTE)
		. = ..()

/datum/bioEffect/deaf
	name = "Deafness"
	desc = "Diminishes the subject's tympanic membrane, rendering them unable to hear."
	id = "deaf"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	probability = 33
	blockCount = 4
	msgGain = "It's quiet. Too quiet."
	msgLose = "You can hear again!"
	reclaim_fail = 15
	stability_loss = -20
	lockProb = 50
	lockedGaps = 2
	lockedDiff = 4
	lockedChars = list("G","C","A","T")
	lockedTries = 10
	icon_state  = "bad"

	OnAdd()
		..()
		owner.ear_disability = 1

	OnRemove()
		..()
		owner.ear_disability = 0


///////////////////////////
// Bad but not crippling //
///////////////////////////

/datum/bioEffect/clumsy
	name = "Dyspraxia"
	desc = "Hinders transmissions in the subject's nervous system, causing poor motor skills."
	id = "clumsy"
	effectType = EFFECT_TYPE_DISABILITY
	probability = 66
	isBad = 1
	msgGain = "You feel kind of off-balance and disoriented."
	msgLose = "You feel well co-ordinated again."
	reclaim_fail = 15
	stability_loss = -15
	icon_state  = "bad"

/datum/bioEffect/narcolepsy
	name = "Narcolepsy"
	desc = "Alters the sleep center of the subject's brain, causing bouts of involuntary sleepiness."
	id = "narcolepsy"
	effectType = EFFECT_TYPE_DISABILITY
	probability = 66
	isBad = 1
	msgGain = "You feel a bit sleepy."
	msgLose = "You feel wide awake."
	reclaim_fail = 15
	stability_loss = -15
	var/sleep_prob = 4
	icon_state  = "bad"

	OnLife(var/mult)
		if(..()) return
		var/mob/living/L = owner
		if (!L)
			return
		if (probmult(sleep_prob))
			L.sleeping = 1

/datum/bioEffect/narcolepsy/super
	name = "Extreme Narcolepsy"
	desc = "Like narcolepsy, but worse and incurable."
	id = "narcolepsy_super"
	msgGain = "You feel more tired than you've ever thought possible."
	msgLose = "You feel more awake than you've ever been in your whole life."
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0
	sleep_prob = 10 //reduced from 35
	icon_state  = "bad"

/datum/bioEffect/coprolalia
	name = "Coprolalia"
	desc = "Causes involuntary outbursts from the subject."
	id = "coprolalia"
	effectType = EFFECT_TYPE_DISABILITY
	probability = 99
	isBad = 1
	msgGain = "You can't seem to shut up!"
	msgLose = "You feel more in control."
	reclaim_fail = 15
	var/talk_prob = 10
	var/list/talk_strings = list("PISS","FUCK","SHIT","DAMN","ARGH","WOOF","CRAP","HECK","FRICK","JESUS")
	icon_state  = "bad"

	OnLife(mult)
		if (..() || isdead(src.owner) || !probmult(talk_prob))
			return

		if(src.power > 1)
			src.owner.say(pick(talk_strings), message_params = list("maptext_css_values" = list("font-weight" = "bold")))
		else
			src.owner.say(pick(talk_strings))

/datum/bioEffect/shortsighted
	name = "Diminished Optic Nerves"
	desc = "Reduces the subject's ability to see clearly without glasses or other visual aids."
	id = "bad_eyesight"
	effectType = EFFECT_TYPE_DISABILITY
	probability = 99
	isBad = 1
	msgGain = "Your vision blurs."
	msgLose = "Your vision is no longer blurry."
	reclaim_fail = 15
	stability_loss = -5
	var/datum/hud/vision_impair/hud = new
	var/applied = 1
	icon_state  = "bad"
	effect_group = "vision"

	OnAdd()
		..()
		owner.attach_hud(src.hud)

	OnRemove()
		..()
		owner.detach_hud(src.hud)

	OnLife()
		if(..()) return
		if (owner.client && ishuman(owner) && owner.sight_check(1))
			var/mob/living/carbon/human/H = owner
			var/corrected_vision = 0
			if (H.glasses) // Marq fix for cannot read null.correct_bad_vision
				if (H.glasses.correct_bad_vision)
					corrected_vision = 1

			if (!corrected_vision)
				if (!applied)
					owner.attach_hud(src.hud)
					applied = 1
			else
				if (applied)
					owner.detach_hud(src.hud)
					applied = 0
		return

/datum/bioEffect/stupefaction
	name = "Stupefaction"
	desc = "Causes damage to the subject's brain structure, occassionally utterly stupefying and stunning them."
	id = "stupefaction"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	probability = 66
	blockCount = 3
	msgGain = "Your thoughts become disorderly and hard to control."
	msgLose = "Your mind regains its former clarity."
	reclaim_fail = 15
	stability_loss = -10
	icon_state  = "bad"

	OnLife(var/mult = 1)
		if(..()) return
		if (isdead(owner))
			return
		if (probmult(1) && !owner.getStatusDuration("unconscious"))
			owner:visible_message(SPAN_ALERT("<B>[owner] looks totally stupefied!"), SPAN_ALERT("You feel totally stupefied!"))
			owner.setStatusMin("unconscious", 2 SECONDS * mult)
		return

/datum/bioEffect/thermal_vuln
	name = "Thermal Vulnerability"
	desc = "Cripples the subject's thermoregulation, rendering them more vulnerable to abnormal temperatures."
	id = "thermal_vuln"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	probability = 40
	blockCount = 3
	msgGain = "You break out into a cold sweat."
	msgLose = "The air feels more comfortable again."
	reclaim_fail = 15
	stability_loss = -20
	icon_state  = "bad"
	effect_group = "thermal"

	OnAdd()
		..()
		owner.temp_tolerance *= 0.25
		owner.thermoregulation_mult *= 0.5
		owner.innate_temp_resistance *= 2

	OnRemove()
		..()
		owner.temp_tolerance *= 4
		owner.thermoregulation_mult *= 2
		owner.innate_temp_resistance *= 0.5

/datum/bioEffect/toxification
	name = "Blood Toxification"
	desc = "Impairs the subject's blood filtration, resulting in gradual toxic buildup that must be purged by outside assistance."
	id = "toxification"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	probability = 13
	blockCount = 3
	msgGain = "You feel really sick..."
	msgLose = "You don't feel sick any more."
	reclaim_fail = 30
	stability_loss = -15
	var/tox_amount = 1
	var/tox_prob = 25
	icon_state  = "bad"
	effect_group = "tox"

	OnLife(var/mult)
		if(..()) return
		if (iscarbon(owner))
			var/mob/living/carbon/C = owner
			if (prob(tox_prob))
				C.take_toxin_damage(tox_amount*mult)

/datum/bioEffect/cough
	name = "Chronic Cough"
	desc = "Enhances the sensitivity of nerves in the subject's throat, causing periodic coughing fits."
	id = "cough"
	probability = 99
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "You feel an irritating itch in your throat."
	msgLose = "Your throat clears up."
	reclaim_fail = 15
	stability_loss = -5
	icon_state  = "bad"

	OnLife(var/mult)
		if(..()) return
		if (isdead(owner))
			return
		if ((probmult(5) && !owner.getStatusDuration("unconscious")))
			owner:drop_item()
			SPAWN(0)
				owner:emote("cough")
				return
		return

#define LIMB_IS_ARM 1
#define LIMB_IS_LEG 2
/datum/bioEffect/funky_limb
	name = "Motor Neuron Signal Enhancement" // heh
	desc = "Causes involuntary muscle contractions in limbs, due to a loss of inhibition of motor neurons."
	id = "funky_limb"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	probability = 33
	blockCount = 4
	msgGain = "One of your limbs feels a bit strange and twitchy."
	msgLose = "Your limb feels fine again."
	reclaim_fail = 15
	stability_loss = -20
	lockProb = 50
	lockedGaps = 2
	lockedDiff = 4
	lockedChars = list("G","C","A","T")
	lockedTries = 10
	var/obj/item/parts/limb = null
	var/limb_type = LIMB_IS_ARM
	icon_state  = "bad"

	OnAdd()
		..()
		src.pick_limb()

	OnLife(var/mult)
		if(..()) return
		if ((!src.limb || (src.limb.loc != src.owner)) && !src.pick_limb())
			return
		if (owner.stat)
			return

		if (src.limb_type == LIMB_IS_ARM)
			if (probmult(5))
				owner.visible_message(SPAN_ALERT("[owner.name]'s [src.limb] makes a [pick("rude", "funny", "weird", "strange", "offensive", "cruel", "furious")] gesture!"))
			else if (probmult(2))
				owner.emote("slap")
			else if (probmult(2))
				owner.visible_message(SPAN_ALERT("<B>[owner.name]'s [src.limb] punches [him_or_her(owner)] in the face!</B>"))
				owner.changeStatus("knockdown", 5 SECONDS)
				owner.TakeDamageAccountArmor("head", rand(2,5), 0, 0, DAMAGE_BLUNT)
			else if (probmult(1))
				owner.visible_message(SPAN_ALERT("[owner.name]'s [src.limb] tries to strangle [him_or_her(owner)]!"))
				while (prob(80) && owner.bioHolder.HasEffect("funky_limb"))
					owner.losebreath = max(owner.losebreath, 2)
					sleep(1 SECOND)
				owner.visible_message(SPAN_ALERT("[owner.name]'s [src.limb] stops trying to strangle [him_or_her(owner)]."))
			return

		else if (src.limb_type == LIMB_IS_LEG)
			if (probmult(5))
				owner.visible_message(SPAN_ALERT("[owner.name]'s [src.limb] twitches [pick("rudely", "awkwardly", "weirdly", "strangely", "offensively", "cruelly", "furiously")]!"))
			else if (probmult(3))
				owner.visible_message(SPAN_ALERT("<B>[owner.name] trips over [his_or_her(owner)] own [src.limb]!</B>"))
				owner.changeStatus("knockdown", 2 SECONDS)
			else if (probmult(2))
				owner.visible_message(SPAN_ALERT("<B>[owner.name]'s [src.limb] kicks [him_or_her(owner)] in the head somehow!</B>"))
				owner.changeStatus("unconscious", 7 SECONDS)
				owner.TakeDamageAccountArmor("head", rand(5,10), 0, 0, DAMAGE_BLUNT)
			else if (probmult(2))
				owner.visible_message(SPAN_ALERT("<B>[owner.name] can't seem to control [his_or_her(owner)] [src.limb]!</B>"))
				owner.change_misstep_chance(10)
			return

	proc/pick_limb()
		. = 0
		if (!ishuman(owner))
			return
		var/mob/living/carbon/human/H = owner
		var/list/possible_limbs = list()
		if (H.limbs.l_arm)
			possible_limbs += H.limbs.l_arm
		if (H.limbs.r_arm)
			possible_limbs += H.limbs.r_arm
		if (H.limbs.l_leg)
			possible_limbs += H.limbs.l_leg
		if (H.limbs.r_leg)
			possible_limbs += H.limbs.r_leg
		if (!possible_limbs.len)
			return

		src.limb = pick(possible_limbs)

		if (istype(src.limb, /obj/item/parts/human_parts/arm) || istype(src.limb, /obj/item/parts/robot_parts/arm))
			src.limb_type = LIMB_IS_ARM
			return 1
		else if (istype(src.limb, /obj/item/parts/human_parts/leg) || istype(src.limb, /obj/item/parts/robot_parts/leg))
			src.limb_type = LIMB_IS_LEG
			return 1

#undef LIMB_IS_ARM
#undef LIMB_IS_LEG

///////////////////////////////////////
// Harmful to others as well as self //
///////////////////////////////////////

/datum/bioEffect/radioactive
	name = "Radioactive"
	desc = "The subject suffers from constant radiation sickness and causes the same on nearby organics."
	id = "radioactive"
	effectType = EFFECT_TYPE_DISABILITY
	probability = 66
	blockCount = 3
	blockGaps = 3
	isBad = 1
	stability_loss = 10
	msgGain = "You feel a strange sickness permeate your whole body."
	msgLose = "You no longer feel awful and sick all over."
	reclaim_fail = 15
	icon_state  = "bad"
	effect_group = "rad"

	OnAdd()
		if (ishuman(owner))
			overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "aurapulse", layer = MOB_LIMB_LAYER)
			overlay_image.color = "#BBD90F"
		owner.AddComponent(/datum/component/radioactive, 50, FALSE, FALSE)
		..()

	OnRemove()
		. = ..()
		var/datum/component/radioactive/R = owner.GetComponent(/datum/component/radioactive)
		R?.RemoveComponent()

/datum/bioEffect/radioactive_farts
	name = "Radioactive Farts"
	desc = "The subject's flatulence is contaminated with radioactive isotopes."
	id = "radioactive_farts"
	effectType = EFFECT_TYPE_DISABILITY
	probability = 66
	blockCount = 3
	blockGaps = 3
	isBad = 1
	stability_loss = 10
	msgGain = "You feel a strange energy radiate from your bowels."
	msgLose = "Your intestines are no longer glowing."
	reclaim_fail = 15
	icon_state  = "bad"
	effect_group = "rad"

/datum/bioEffect/mutagenic_field
	name = "Mutagenic Field"
	desc = "The subject emits low-level radiation that may cause themselves to mutate."
	id = "mutagenic_field"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	probability = 33
	blockCount = 3
	blockGaps = 4
	msgGain = "Your flesh begins to warp and contort weirdly!"
	msgLose = "You stop warping and contorting. Phew, what a relief..."
	reclaim_fail = 50
	lockProb = 50
	lockedGaps = 2
	lockedDiff = 4
	lockedChars = list("G","C","A","T")
	lockedTries = 10
	stability_loss = 35
	var/affect_others = 0
	var/field_range = 2
	var/proc_prob = 5
	var/mutation_type = "either"
	icon_state  = "bad"

	New()
		..()
		if (prob(25))
			mutation_type = "bad"
			if (prob(5))
				mutation_type = "good"

	OnLife(var/mult)
		if(..()) return
		if (probmult(proc_prob))
			owner.bioHolder.RandomEffect(mutation_type,1)
			if (affect_others)
				for(var/mob/living/L in range(field_range, get_turf(owner)))
					if (!L.bioHolder)
						continue
					L.bioHolder.RandomEffect(mutation_type,1)
				return

/datum/bioEffect/involuntary_teleporting
	name = "Spatial Destabilization"
	desc = "Causes the subject's molecular structure to become partially unstuck in space."
	id = "involuntary_teleporting"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	probability = 33
	blockCount = 3
	blockGaps = 4
	msgGain = "You feel a bit out of place."
	msgLose = "You feel firmly rooted in place again."
	lockProb = 40
	lockedGaps = 1
	lockedDiff = 3
	lockedChars = list("G","C","A","T")
	lockedTries = 8
	stability_loss = 10
	var/tele_prob = 5
	icon_state  = "bad"

	OnLife(var/mult)
		if(..()) return
		var/mob/living/L = owner
		if (!isturf(L.loc))
			return

		if (isrestrictedz(L.z))
			boutput(L, SPAN_NOTICE("You feel quite strange. Almost as if you're not supposed to be here."))
			return

		if (probmult(tele_prob))
			var/list/randomturfs = new/list()
			for(var/turf/simulated/floor/T in orange(L, 10))
				randomturfs.Add(T)

			if (length(randomturfs) > 0)
				L.emote("hiccup")
				var/turf/destination = pick(randomturfs)
				logTheThing(LOG_COMBAT, L, "was teleported by Spatial Destabilization from [log_loc(L)] to [log_loc(destination)].")
				L.set_loc(pick(destination))

//////////////
// Annoying //
//////////////

/datum/bioEffect/emoter
	name = "Irritable Bowels"
	desc = "Causes the subject to experience frequent involuntary flatus."
	id = "farty"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "Your guts are rumbling."
	msgLose = "Your guts settle down."
	probability = 99
	var/emote_prob = 15
	var/emote_type = "fart"
	icon_state  = "bad"

	OnLife(var/mult)
		if(..()) return
		var/mob/living/L = owner
		if (!L)
			return
		if (isdead(L))
			return
		if (probmult(emote_prob))
			L.emote(emote_type)

/datum/bioEffect/colorblindness
	name = "Protanopia"
	desc = "Selectively inhibits the L-cones in the subject's eyes, causing red-green colorblindness."
	id = "protanopia"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "Everything starts looking a lot more yellow."
	msgLose = "You notice a few extra colors."
	probability = 99
	icon_state  = "bad"

	OnAdd()
		owner.apply_color_matrix(COLOR_MATRIX_PROTANOPIA, COLOR_MATRIX_PROTANOPIA_LABEL)
		. = ..()

	OnRemove()
		. = ..()
		owner.remove_color_matrix(COLOR_MATRIX_PROTANOPIA_LABEL)

/datum/bioEffect/colorblindness/greenblind
	name = "Deuteranopia"
	desc = "Selectively inhibits the L-cones in the subject's eyes, causing green to be indistinguishable from red."
	id = "deuteranopia"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "Everything starts looking a lot less green."
	msgLose = "You notice a few extra colors."
	probability = 99
	icon_state  = "bad"

	OnAdd()
		owner.apply_color_matrix(COLOR_MATRIX_DEUTERANOPIA, COLOR_MATRIX_DEUTERANOPIA_LABEL)
		. = ..()

	OnRemove()
		. = ..()
		owner.remove_color_matrix(COLOR_MATRIX_DEUTERANOPIA_LABEL)

/datum/bioEffect/colorblindness/blueblind
	name = "Tritanopia"
	desc = "Selectively inhibits the L-cones in the subject's eyes, causing blue colorblindness."
	id = "tritanopia"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "Everything starts looking a lot less blue."
	msgLose = "You notice a few extra colors."
	probability = 99
	icon_state  = "bad"

	OnAdd()
		owner.apply_color_matrix(COLOR_MATRIX_TRITANOPIA, COLOR_MATRIX_TRITANOPIA_LABEL)
		. = ..()

	OnRemove()
		. = ..()
		owner.remove_color_matrix(COLOR_MATRIX_TRITANOPIA_LABEL)

/datum/bioEffect/emoter/screamer
	name = "Paranoia"
	desc = "Causes the subject to become easily startled."
	id = "screamer"
	msgGain = "They're gonna get you!!!!!"
	msgLose = "You calm down."
	emote_type = "scream"
	emote_prob = 10


/datum/bioEffect/emoter/linkedfart
	name = "Psychic Fart Link"
	desc = "Creates a neural fart linkage between all life-forms within 15 kilometers"
	id = "linkedfart"
	msgGain = "You feel the gas of a thousand souls"
	msgLose = "You no longer feel so gassy."
	emote_type = "fart"
	emote_prob = 20
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0

/datum/bioEffect/emoter/juggler
	name = "Jugglemancer's Curse"
	desc = "Places a mystical hex upon the subject that compels the subject to juggle."
	id = "juggler"
	msgGain = "You feel the need to juggle"
	msgLose = "You no longer feel the need to juggle."
	emote_type = "juggle"
	emote_prob = 35
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0

	OnAdd()
		..()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.can_juggle++

	OnRemove()
		. = ..()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.can_juggle--
			if (H.can_juggle < 0)
				H.can_juggle = 0

/datum/bioEffect/buzz
	name = "Nectar Perspiration"
	desc = "Causes the subject to perspire nectar that attracts abnormally small bees."
	id = "buzz"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "Your guts are rumbling."
	msgLose = "Your guts settle down."
	probability = 70
	stability_loss = -10	//maybe 5
	var/prob_sting = 10;
	icon_state  = "bad"
	var/obj/effects/bees/effect

	OnAdd()
		if (isliving(owner))
			effect = new/obj/effects/bees(owner)
		. = ..()

	OnRemove()
		. = ..()
		qdel(effect)

	OnLife(var/mult)
		if (..())
			return
		var/mob/living/L = owner
		if (!istype(L) || (isdead(L)))
			return
		if (probmult(prob_sting))
			if (ishuman(L))
				var/mob/living/carbon/human/H = L
				if (prob(50))
					if (istype(H.wear_suit, /obj/item/clothing/suit/hazard/beekeeper))
						boutput(owner, SPAN_SUBTLE("A bee in your cloud tries to sting you, but your suit protects you."))
						return
				else if (istype(H.head, /obj/item/clothing/head/bio_hood/beekeeper))
					boutput(owner, SPAN_SUBTLE("A bee in your cloud tries to sting you, but your hood protects you."))
					return
			boutput(owner, SPAN_ALERT("A bee in your cloud stung you! How rude!"))
			L.reagents.add_reagent("histamine", 2)

/datum/bioEffect/emp_field
	name = "Electromagnetic Field"
	desc = "The subject produces small, random electromagnetic pulses around it."
	id = "emp_field"
	effectType = EFFECT_TYPE_DISABILITY
	msgGain = "You feel more connected to electromagnetic fields."
	msgLose = "You feel less connected to electromagnetic fields."
	blockCount = 1
	probability = 20
	isBad = 1
	reclaim_fail = 15
	stability_loss = -10
	var/const/radius = 2
	icon_state  = "bad"
	var/roundedmultremainder

	OnLife(var/mult)
		..()
		if (probmult(50))
			var/turf/T
			//don't really need this but to make it more harmful to the user.
			if (prob(5))
				T = get_turf(owner)
			else
				T = locate(owner.x + rand(-radius/2,radius+2), owner.y+rand(-radius/2,radius/2), 1)

			var/obj/overlay/pulse = new/obj/overlay(T)
			pulse.icon = 'icons/effects/effects.dmi'
			pulse.icon_state = "emppulse"
			pulse.name = "emp pulse"
			pulse.anchored = ANCHORED
			SPAWN(2 SECONDS)
				if (pulse) qdel(pulse)

			//maybe have this only emp some things on the tile.
			if(istype(T))
				for (var/atom/O in T.contents)
					O.emp_act()

/datum/bioEffect/fitness_debuff
	name = "Physically Unfit"
	desc = "Causes the subject to be naturally less physically fit than the average spaceman."
	id = "fitness_debuff"
	probability = 60
	isBad = 1
	effectType = EFFECT_TYPE_POWER
	blockCount = 2
	blockGaps = 3
	reclaim_mats = 30
	msgGain = "You feel slightly less energetic."
	msgLose = "You feel slightly more energetic."
	lockProb = 20
	lockedGaps = 1
	lockedDiff = 3
	lockedTries = 8
	stability_loss = -10
	icon_state  = "bad"
	effect_group = "fit"

	OnAdd()
		APPLY_ATOM_PROPERTY(src.owner, PROP_MOB_STAMINA_REGEN_BONUS, "g-fitness-debuff", -2)
		src.owner.add_stam_mod_max("g-fitness-debuff", -30)
		. = ..()

	OnRemove()
		. = ..()
		REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_STAMINA_REGEN_BONUS, "g-fitness-debuff")
		src.owner.remove_stam_mod_max("g-fitness-debuff")

/datum/bioEffect/tinnitus
	name = "Tinnitus"
	desc = "Causes the subject to almost constantly hear a terrible/annoying ringing in their ears."
	id = "tinnitus"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "You hear a ringing in your ears."
	msgLose = "The ringing has stopped...Finally. Thank the Space-Gods."
	stability_loss = 0
	probability = 99
	var/ring_prob = 6
	icon_state  = "bad"

	OnLife(var/mult)
		if (..())
			return
		if (probmult(ring_prob) && owner.client)
			owner.playsound_local(owner.loc, 'sound/machines/phones/ring_incoming.ogg', 40, 1)

/datum/bioEffect/anemia
	name = "Anemia"
	desc = "Subject has an abnormally low amount of red blood cells."
	id = "anemia"
	probability = 55
	isBad = 1
	effectType = EFFECT_TYPE_POWER
	msgGain = "You feel lightheaded."
	msgLose = "Your lightheadedness fades."
	stability_loss = -10
	var/run = 1
	icon_state  = "bad"
	effect_group = "blood"

	OnLife(var/mult)
		if (..())
			return
		if (isliving(owner))
			var/mob/living/L = owner

			if (L.blood_volume > 4 / 5 * initial(L.blood_volume) && L.blood_volume > 0)
				L.blood_volume -= 2*mult

/datum/bioEffect/polycythemia
	name = "Polycythemia"
	desc = "Subject has an abnormally high amount of red blood cells."
	id = "polycythemia"
	probability = 45
	isBad = 1
	effectType = EFFECT_TYPE_POWER
	msgGain = "Your breathing quickens."
	msgLose = "Your breathing returns to normal."
	stability_loss = -10
	var/run = 1
	icon_state  = "bad"
	effect_group = "blood"

	OnLife(var/mult)
		if (..())
			return
		if (isliving(owner))
			var/mob/living/L = owner
			if (L.blood_volume < 6 / 5 * initial(L.blood_volume) && L.blood_volume > 0)
				L.blood_volume += 2*mult


////////////////////////////
// Disabled for *Reasons* //
////////////////////////////

/datum/bioEffect/mind_jockey
	name = "Meta-Neural Transferral"
	desc = "The subject's brainwaves will occasionally involuntarily switch with those of another near them."
	id = "mind_jockey"
	effectType = EFFECT_TYPE_DISABILITY
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	isBad = 1
	msgGain = "You wanna be somebody else."
	msgLose = "You're happy with yourself."
	var/proc_prob = 5
	icon_state  = "bad"

	OnLife(var/mult)
		if(..()) return
		var/turf/T = get_turf(owner)
		if(isrestrictedz(T?.z))
			return
		if (probmult(proc_prob))
			var/list/potential_victims = list()
			for(var/mob/living/carbon/human/H in range(7,owner))
				if (!H.client || H.stat)
					continue
				potential_victims += H
			if (potential_victims.len)
				var/mob/living/carbon/human/this_one = pick(potential_victims)
				boutput(src, SPAN_ALERT("Your mind twangs uncomfortably!"))
				boutput(this_one, SPAN_ALERT("Your mind twangs uncomfortably!"))
				logTheThing(LOG_COMBAT, owner, "swapped minds with [this_one] via Meta-Neural Transferral gene.")
				owner.mind.swap_with(this_one)

/datum/bioEffect/mutagenic_field/prenerf
	name = "High-Power Mutagenic Field"
	desc = "The subject emits powerful radiation that may cause everyone in range to mutate."
	id = "mutagenic_field_prenerf"
	affect_others = 1
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	icon_state  = "bad"

/datum/bioEffect/randomeffects
	name = "Booster Gene Q"
	desc = "This function of this gene is not well-researched."
	researched_desc = "This gene has random, unpredictable effects on the subject."
	id = "randomeffects"
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	curable_by_mutadone = 0
	blockCount = 2
	blockGaps = 4
	lockProb = 66
	lockedGaps = 1
	lockedDiff = 4
	lockedChars = list("G","C","A","T")
	lockedTries = 10
	stability_loss = 15
	var/prob_per_tick = 15
	var/list/emotes = list("slap","snap","hiccup","burp","fart","dance","tantrum","flipoff","flip","boggle")
	var/list/noises = list('sound/musical_instruments/WeirdHorn_0.ogg','sound/voice/animal/cat.ogg','sound/musical_instruments/piano/furelise.ogg',
	'sound/machines/engine_alert3.ogg','sound/machines/fortune_riff.ogg','sound/misc/ancientbot_grump2.ogg',
	'sound/voice/farts/diarrhea.ogg','sound/misc/sad_server_death.ogg','sound/voice/animal/werewolf_howl.ogg',
	'sound/voice/MEruncoward.ogg','sound/voice/macho/macho_become_enraged01.ogg',
	'sound/voice/macho/macho_rage_81.ogg','sound/voice/macho/macho_rage_73.ogg','sound/weapons/male_cswordturnon.ogg')
	icon_state  = "bad"

	New(var/for_global_list = 0)
		..()
		if (!for_global_list)
			name = "Booster Gene"

	OnLife(var/mult)
		if(..()) return
		if (probmult(prob_per_tick))
			var/mob/living/L = owner
			var/picker = rand(1,5)
			switch(picker)
				if (1)
					L.HealDamage("All",10,0)
				if (2)

					if (isrestrictedz(L.z))
						boutput(L, SPAN_NOTICE("You feel your genes tingling inside you. Strange."))
						return

					var/list/randomturfs = new/list()
					for(var/turf/simulated/floor/T in orange(L, 10))
						randomturfs.Add(T)

					if (length(randomturfs) > 0)
						L.emote("hiccup")
						L.set_loc(pick(randomturfs))
				if (3)
					L.emote(pick(emotes))
				if (4)
					L.color = random_color()
					var/turf/T = get_turf(L)
					T.color = random_color()
				if (5)
					L.visible_message(SPAN_ALERT("<b>[L.name]</b> makes a weird noise!"))
					playsound(L.loc, pick(noises), 50, 0)

/datum/bioEffect/sneeze
	name = "Chronic Sneezing"
	desc = "Enhances the sensitivity of nerves in the subject's nose, causing periodic sneezing."
	id = "sneeze"
	probability = 66
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "You feel an irritating itch in your nose."
	msgLose = "Your nose clears up."
	reclaim_fail = 15
	icon_state  = "bad"

	OnLife(var/mult)
		if (..())
			return
		if (probmult(5))
			if (isdead(owner))
				return
			else
				owner:emote("sneeze")

/datum/bioEffect/lazy_eye
	name = "Ego Dislocation"
	desc = "The subject's sense of self may not always align with their physical location."
	id = "lazy_eye"
	effectType = EFFECT_TYPE_DISABILITY
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	msgGain = "You feel strangly disjointed."
	msgLose = "You feel grounded."
	isBad = 1
	icon_state  = "bad"

	OnAdd()
		. = ..()
		src.owner.client?.lazy_eye = 5

	OnRemove()
		. = ..()
		src.owner.client?.lazy_eye = 0

	OnLife(mult)
		if(..()) return
		src.owner.client?.lazy_eye = 5
