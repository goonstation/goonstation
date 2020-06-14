///////////////////////
// Totally Crippling //
///////////////////////

/datum/bioEffect/blind
	name = "Blindness"
	desc = "Disconnects the optic nerves from the brain, rendering the subject unable to see."
	id = "blind"
	effectType = effectTypeDisability
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


/datum/bioEffect/mute
	name = "Frontal Gyrus Suspension"
	desc = "Completely shuts down the speech center of the subject's brain."
	id = "mute"
	effectType = effectTypeDisability
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
	icon_state  = "bad"

/datum/bioEffect/deaf
	name = "Deafness"
	desc = "Diminishes the subject's tympanic membrane, rendering them unable to hear."
	id = "deaf"
	effectType = effectTypeDisability
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
	effectType = effectTypeDisability
	probability = 66
	isBad = 1
	msgGain = "You feel kind of off-balance and disoriented."
	msgLose = "You feel well co-ordinated again."
	reclaim_fail = 15
	stability_loss = -5
	icon_state  = "bad"

/datum/bioEffect/narcolepsy
	name = "Narcolepsy"
	desc = "Alters the sleep center of the subject's brain, causing bouts of involuntary sleepiness."
	id = "narcolepsy"
	effectType = effectTypeDisability
	probability = 66
	isBad = 1
	msgGain = "You feel a bit sleepy."
	msgLose = "You feel wide awake."
	reclaim_fail = 15
	stability_loss = -5
	var/sleep_prob = 4
	icon_state  = "bad"

	OnLife()
		if(..()) return
		var/mob/living/L = owner
		if (!L)
			return
		if (prob(sleep_prob))
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
	sleep_prob = 35
	icon_state  = "bad"

/datum/bioEffect/coprolalia
	name = "Coprolalia"
	desc = "Causes involuntary outbursts from the subject."
	id = "coprolalia"
	effectType = effectTypeDisability
	probability = 99
	isBad = 1
	msgGain = "You can't seem to shut up!"
	msgLose = "You feel more in control."
	reclaim_fail = 15
	var/talk_prob = 10
	var/list/talk_strings = list("PISS","FUCK","SHIT","DAMN","TITS","ARGH","WOOF","CRAP","BALLS")
	icon_state  = "bad"

	OnLife()
		if(..()) return
		var/mob/living/L = owner
		if (!L)
			return
		if (isdead(L))
			return
		if (prob(talk_prob))
			L.say(pick(talk_strings))

/datum/bioEffect/fat
	name = "Obesity"
	desc = "Greatly slows the subject's metabolism, enabling greater buildup of lipid tissue."
	id = "fat"
	probability = 99
	effectType = effectTypeDisability
	isBad = 1
	msgGain = "You feel blubbery and lethargic!"
	msgLose = "You feel fit!"
	reclaim_fail = 15
	stability_loss = -5
	icon_state  = "bad"

	OnAdd()
		..()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.set_body_icon_dirty()
			H.unlock_medal("Space Ham", 1)
			APPLY_MOVEMENT_MODIFIER(H, /datum/movement_modifier/spaceham, src.type)

	OnRemove()
		..()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.set_body_icon_dirty()
			REMOVE_MOVEMENT_MODIFIER(H, /datum/movement_modifier/spaceham, src.type)

	OnLife()
		if(..()) return
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (prob(1) && !H.find_ailment_by_type(/datum/ailment/malady/heartdisease))
				H.contract_disease(/datum/ailment/malady/heartdisease,null,null,1)
		return

/datum/bioEffect/shortsighted
	name = "Diminished Optic Nerves"
	desc = "Reduces the subject's ability to see clearly without glasses or other visual aids."
	id = "bad_eyesight"
	effectType = effectTypeDisability
	probability = 99
	isBad = 1
	msgGain = "Your vision blurs."
	msgLose = "Your vision is no longer blurry."
	reclaim_fail = 15
	stability_loss = -5
	var/datum/hud/vision_impair/hud = new
	var/applied = 1
	icon_state  = "bad"

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

/datum/bioEffect/epilepsy
	name = "Epilepsy"
	desc = "Causes damage to the subject's brain structure, resulting in occasional siezures from brain misfires."
	id = "epilepsy"
	effectType = effectTypeDisability
	isBad = 1
	probability = 66
	blockCount = 3
	msgGain = "Your thoughts become disorderly and hard to control."
	msgLose = "Your mind regains its former clarity."
	reclaim_fail = 15
	stability_loss = -10
	icon_state  = "bad"

	OnLife()
		if(..()) return
		if (isdead(owner))
			return
		if (prob(1) && !owner.getStatusDuration("paralysis"))
			owner:visible_message("<span class='alert'><B>[owner] starts having a seizure!</span>", "<span class='alert'>You have a seizure!</span>")
			owner.setStatus("paralysis", max(owner.getStatusDuration("paralysis"), 20))
			owner:make_jittery(100)
		return

/datum/bioEffect/thermal_vuln
	name = "Thermal Vulnerability"
	desc = "Cripples the subject's thermoregulation, rendering them more vulnerable to abnormal temperatures."
	id = "thermal_vuln"
	effectType = effectTypeDisability
	isBad = 1
	probability = 40
	blockCount = 3
	msgGain = "You break out into a cold sweat."
	msgLose = "The air feels more comfortable again."
	reclaim_fail = 15
	stability_loss = -20
	icon_state  = "bad"

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
	effectType = effectTypeDisability
	isBad = 1
	probability = 13
	blockCount = 3
	msgGain = "You feel really sick..."
	msgLose = "You don't feel sick any more."
	reclaim_fail = 30
	stability_loss = -20
	var/tox_amount = 1
	var/tox_prob = 10
	icon_state  = "bad"

	OnLife()
		if(..()) return
		if (iscarbon(owner))
			var/mob/living/carbon/C = owner
			if (prob(tox_prob))
				C.toxloss += tox_amount

/datum/bioEffect/tourettes
	name = "Tourettes"
	desc = "Alters the subject's brain structure, causing periodic involuntary movements and outbursts."
	id = "tourettes"
	effectType = effectTypeDisability
	isBad = 1
	probability = 66
	msgGain = "You feel like you can't control your actions fully."
	msgLose = "You feel in full control of yourself once again."
	reclaim_fail = 15
	stability_loss = -5
	icon_state  = "bad"

	OnLife()
		if(..()) return
		if (isdead(owner))
			return
		if ((prob(10) && !owner.getStatusDuration("paralysis")))
			owner.changeStatus("stunned", 3 SECONDS)
			SPAWN_DBG( 0 )
				switch(rand(1, 3))
					if (1 to 2)
						owner.emote("twitch")
					if (3)
						if (owner.client)
							var/enteredtext = winget(owner, "mainwindow.input", "text")
							if ((copytext(enteredtext,1,6) == "say \"") && length(enteredtext) > 5)
								winset(owner, "mainwindow.input", "text=\"\"")
								if (prob(50))
									owner.say(uppertext(copytext(enteredtext,6,0)))
								else
									owner.say(copytext(enteredtext,6,0))
		return

/datum/bioEffect/cough
	name = "Chronic Cough"
	desc = "Enhances the sensitivity of nerves in the subject's throat, causing periodic coughing fits."
	id = "cough"
	probability = 99
	effectType = effectTypeDisability
	isBad = 1
	msgGain = "You feel an irritating itch in your throat."
	msgLose = "Your throat clears up."
	reclaim_fail = 15
	icon_state  = "bad"

	OnLife()
		if(..()) return
		if (isdead(owner))
			return
		if ((prob(5) && !owner.getStatusDuration("paralysis")))
			owner:drop_item()
			SPAWN_DBG (0)
				owner:emote("cough")
				return
		return

#define LIMB_IS_ARM 1
#define LIMB_IS_LEG 2
/datum/bioEffect/funky_limb
	name = "Motor Neuron Signal Enhancement" // heh
	desc = "Causes involuntary muscle contractions in limbs, due to a loss of inhibition of motor neurons."
	id = "funky_limb"
	effectType = effectTypeDisability
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
			return
		else if (istype(src.limb, /obj/item/parts/human_parts/leg) || istype(src.limb, /obj/item/parts/robot_parts/leg))
			src.limb_type = LIMB_IS_LEG
			return

	OnLife()
		if(..()) return
		if (!src.limb || (src.limb.loc != src.owner))
			return
		if (owner.stat)
			return

		if (src.limb_type == LIMB_IS_ARM)
			if (prob(5))
				owner.visible_message("<span class='alert'>[owner.name]'s [src.limb] makes a [pick("rude", "funny", "weird", "lewd", "strange", "offensive", "cruel", "furious")] gesture!</span>")
			else if (prob(2))
				owner.emote("slap")
			else if (prob(2))
				owner.visible_message("<span class='alert'><B>[owner.name]'s [src.limb] punches [him_or_her(owner)] in the face!</B></span>")
				owner.TakeDamageAccountArmor("head", rand(2,5), 0, 0, DAMAGE_BLUNT)
			else if (prob(1))
				owner.visible_message("<span class='alert'>[owner.name]'s [src.limb] tries to strangle [him_or_her(owner)]!</span>")
				while (prob(80) && owner.bioHolder.HasEffect("funky_limb"))
					owner.losebreath = max(owner.losebreath, 2)
					sleep(1 SECOND)
				owner.visible_message("<span class='alert'>[owner.name]'s [src.limb] stops trying to strangle [him_or_her(owner)].</span>")
			return

		else if (src.limb_type == LIMB_IS_LEG)
			if (prob(5))
				owner.visible_message("<span class='alert'>[owner.name]'s [src.limb] twitches [pick("rudely", "awkwardly", "weirdly", "lewdly", "strangely", "offensively", "cruelly", "furiously")]!</span>")
			else if (prob(3))
				owner.visible_message("<span class='alert'><B>[owner.name] trips over [his_or_her(owner)] own [src.limb]!</B></span>")
				owner.changeStatus("weakened", 2 SECONDS)
			else if (prob(2))
				owner.visible_message("<span class='alert'><B>[owner.name]'s [src.limb] kicks [him_or_her(owner)] in the head somehow!</B></span>")
				owner.changeStatus("paralysis", 70)
				owner.TakeDamageAccountArmor("head", rand(5,10), 0, 0, DAMAGE_BLUNT)
			else if (prob(2))
				owner.visible_message("<span class='alert'><B>[owner.name] can't seem to control [his_or_her(owner)] [src.limb]!</B></span>")
				owner.change_misstep_chance(10)
			return

#undef LIMB_IS_ARM
#undef LIMB_IS_LEG

///////////////////////////////////////
// Harmful to others as well as self //
///////////////////////////////////////

/datum/bioEffect/radioactive
	name = "Radioactive"
	desc = "The subject suffers from constant radiation sickness and causes the same on nearby organics."
	id = "radioactive"
	effectType = effectTypeDisability
	probability = 66
	blockCount = 3
	blockGaps = 3
	isBad = 1
	stability_loss = 10
	msgGain = "You feel a strange sickness permeate your whole body."
	msgLose = "You no longer feel awful and sick all over."
	reclaim_fail = 15
	icon_state  = "bad"

	OnAdd()
		if (ishuman(owner))
			overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "aurapulse", layer = MOB_LIMB_LAYER)
			overlay_image.color = "#BBD90F"
		..()

	OnLife()
		if(..()) return
		owner.changeStatus("radiation", 30, 1)
		for(var/mob/living/L in range(1, owner))
			if (L == owner)
				continue
			boutput(L, "<span class='alert'>You are enveloped by a soft green glow emanating from [owner].</span>")
			L.changeStatus("radiation", 50, 1)
		return

/datum/bioEffect/mutagenic_field
	name = "Mutagenic Field"
	desc = "The subject emits low-level radiation that may cause everyone in range to mutate."
	id = "mutagenic_field"
	effectType = effectTypeDisability
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
	stability_loss = 50
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

	OnLife()
		if(..()) return
		if (prob(proc_prob))
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
	effectType = effectTypeDisability
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
	stability_loss = 15
	var/tele_prob = 5
	icon_state  = "bad"

	OnLife()
		if(..()) return
		var/mob/living/L = owner
		if (!isturf(L.loc))
			return

		if (isrestrictedz(L.z))
			boutput(L, "<span class='notice'>You feel quite strange. Almost as if you're not supposed to be here.</span>")
			return

		if (prob(tele_prob))
			var/list/randomturfs = new/list()
			for(var/turf/simulated/floor/T in orange(L, 10))
				randomturfs.Add(T)

			if (randomturfs.len > 0)
				L.emote("hiccup")
				L.set_loc(pick(randomturfs))

//////////////
// Annoying //
//////////////

/datum/bioEffect/emoter
	name = "Irritable Bowels"
	desc = "Causes the subject to experience frequent involuntary flatus."
	id = "farty"
	effectType = effectTypeDisability
	isBad = 1
	msgGain = "Your guts are rumbling."
	msgLose = "Your guts settle down."
	probability = 99
	var/emote_prob = 15
	var/emote_type = "fart"
	icon_state  = "bad"

	OnLife()
		if(..()) return
		var/mob/living/L = owner
		if (!L)
			return
		if (isdead(L))
			return
		if (prob(emote_prob))
			L.emote(emote_type)

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
	emote_type = "twirl"
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
		var/mob/living/L = owner
		if (ishuman(L))
			L:can_juggle = 1

/datum/bioEffect/buzz
	name = "Nectar Perspiration"
	desc = "Causes the subject to perspire nectar that attracts abnormally small bees."
	id = "buzz"
	effectType = effectTypeDisability
	isBad = 1
	msgGain = "Your guts are rumbling."
	msgLose = "Your guts settle down."
	probability = 70
	stability_loss = -10	//maybe 5
	var/prob_sting = 10;
	icon_state  = "bad"

	OnAdd()
		if (ishuman(owner))
			overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "buzz", layer = MOB_EFFECT_LAYER)
		..()

	OnLife()
		var/mob/living/L = owner
		if (!istype(L) || (L.stat == 2))
			return
		if (prob(prob_sting))
			boutput(src, "<span class='alert'>A bee in your cloud stung you! How rude!</span>")
			L.reagents.add_reagent("histamine", 2)

/datum/bioEffect/emp_field
	name = "Electromagnetic Field"
	desc = "The subject produces small, random electromagnetic pulses around it."
	id = "emp_field"
	effectType = effectTypeDisability
	msgGain = "You feel more connected to electromagnetic fields."
	msgLose = "You feel less connected to electromagnetic fields."
	blockCount = 1
	probability = 20
	isBad = 1
	reclaim_fail = 15
	stability_loss = -10
	var/const/radius = 2
	icon_state  = "bad"

	OnLife()
		..()
		if (prob(50))
			return

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
		pulse.anchored = 1
		SPAWN_DBG (20)
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
	effectType = effectTypePower
	blockCount = 2
	blockGaps = 3
	reclaim_mats = 30
	msgGain = "You feel slightly less energetic."
	msgLose = "You feel slightly more energetic."
	lockProb = 20
	lockedGaps = 1
	lockedDiff = 3
	lockedTries = 8
	stability_loss = 5
	icon_state  = "bad"

	OnAdd()
		src.owner.add_stam_mod_regen("g-fitness-debuff", -2)
		src.owner.add_stam_mod_max("g-fitness-debuff", -30)

	OnRemove()
		src.owner.remove_stam_mod_regen("g-fitness-debuff")
		src.owner.remove_stam_mod_max("g-fitness-debuff")

/datum/bioEffect/tinnitus
	name = "Tinnitus"
	desc = "Causes the subject to almost constantly hear a terrible/annoying ringing in their ears."
	id = "tinnitus"
	effectType = effectTypeDisability
	isBad = 1
	msgGain = "You hear a ringing in your ears."
	msgLose = "The ringing has stopped...Finally. Thank the Space-Gods."
	stability_loss = -5
	probability = 99
	var/ring_prob = 6
	icon_state  = "bad"

	OnLife()
		if (prob(ring_prob) && owner.client)
			// owner.client << sound("phone-ringing.wav")		//play sound only for client. Untested, don't know the sound
			owner.client << sound("sound/machines/phones/ring_incoming.ogg")		//play sound only for client. Untested, don't know the sound

/datum/bioEffect/anemia
	name = "Anemia"
	desc = "Subject has an abnormally low amount of red blood cells."
	id = "anemia"
	probability = 55
	isBad = 1
	effectType = effectTypePower
	msgGain = "You feel lightheaded."
	msgLose = "Your lightheadedness fades."
	stability_loss = -5
	var/run = 1
	icon_state  = "bad"

	OnLife()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner

			if (H.blood_volume > 400 && H.blood_volume > 0)
				H.blood_volume -= 2

/datum/bioEffect/polycythemia
	name = "Polycythemia"
	desc = "Subject has an abnormally high amount of red blood cells."
	id = "polycythemia"
	probability = 45
	isBad = 1
	effectType = effectTypePower
	msgGain = "Your breathing quickens."
	msgLose = "Your breathing returns to normal."
	stability_loss = -5
	var/run = 1
	icon_state  = "bad"

	OnLife()

		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner

			if (H.blood_volume < 600 && H.blood_volume > 0)
				H.blood_volume += 2


////////////////////////////
// Disabled for *Reasons* //
////////////////////////////

/datum/bioEffect/mind_jockey
	name = "Meta-Neural Transferral"
	desc = "The subject's brainwaves will occasionally involuntarily switch with those of another near them."
	id = "mind_jockey"
	effectType = effectTypeDisability
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

	OnLife()
		if(..()) return
		if (prob(proc_prob))
			var/list/potential_victims = list()
			for(var/mob/living/carbon/human/H in range(7,owner))
				if (!H.client || H.stat)
					continue
				potential_victims += H
			if (potential_victims.len)
				var/mob/living/carbon/human/this_one = pick(potential_victims)
				boutput(src, "<span class='alert'>Your mind twangs uncomfortably!</span>")
				boutput(this_one, "<span class='alert'>Your mind twangs uncomfortably!</span>")
				owner.mind.swap_with(this_one)

/datum/bioEffect/mutagenic_field/prenerf
	name = "High-Power Mutagenic Field"
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
	'sound/voice/macho/macho_rage_81.ogg','sound/voice/macho/macho_rage_73.ogg','sound/weapons/male_cswordstart.ogg')
	icon_state  = "bad"

	New(var/for_global_list = 0)
		..()
		if (!for_global_list)
			name = "Booster Gene"

	OnLife()
		if(..()) return
		if (prob(prob_per_tick))
			var/mob/living/L = owner
			var/picker = rand(1,5)
			switch(picker)
				if (1)
					L.HealDamage("All",10,0)
				if (2)

					if (isrestrictedz(L.z))
						boutput(L, "<span class='notice'>You feel your genes tingling inside you. Strange.</span>")
						return

					var/list/randomturfs = new/list()
					for(var/turf/simulated/floor/T in orange(L, 10))
						randomturfs.Add(T)

					if (randomturfs.len > 0)
						L.emote("hiccup")
						L.set_loc(pick(randomturfs))
				if (3)
					L.emote(pick(emotes))
				if (4)
					L.color = random_color()
					var/turf/T = get_turf(L)
					T.color = random_color()
				if (5)
					L.visible_message("<span class='alert'><b>[L.name]</b> makes a weird noise!</span>")
					playsound(L.loc, pick(noises), 50, 0)

/datum/bioEffect/sneeze
	name = "Chronic Sneezing"
	desc = "Enhances the sensitivity of nerves in the subject's nose, causing periodic sneezing."
	id = "sneeze"
	probability = 66
	effectType = effectTypeDisability
	isBad = 1
	msgGain = "You feel an irritating itch in your nose."
	msgLose = "Your nose clears up."
	reclaim_fail = 15
	icon_state  = "bad"

	OnLife()
		if (prob(5))
			if (isdead(owner))
				return
			else
				owner:emote("sneeze")
		return
