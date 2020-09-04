ABSTRACT_TYPE(/datum/bioEffect/hemochromia)

/datum/bioEffect/hemochromia_unknown
	name = "Hemochromia Type-U"
	desc = "A volatile mutation with 12 known stable alternatives. Will quickly break down into one of them if the subject exits the scanner."
	id = "hemochromia_unknown"
	probability = 111
	effectType = EFFECT_TYPE_MUTANTRACE
	msgGain = "You feel like you're out of breath."
	msgLose = "You feel more stable."
	reclaim_fail = 10
	lockProb = 1
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("A","T","C","G")
	lockedTries = 12
	stability_loss = 5
	icon_state  = "hemochromia_unknown"

	OnLife()
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if(prob(12))
				if(!istype(H.loc, /obj/machinery/genetics_scanner))
					var/duplicateCheck = 0
					if(holder.GetASubtypeEffect(/datum/bioEffect/hemochromia))
						duplicateCheck = 1
						holder.RemoveEffect(src.id)
						holder.RemovePoolEffect(src)
					var/typeRange = 0
					if(rand(13) <= 4)
						switch(H.bioHolder.bloodType)
							if("A+")
								if(prob(50))
									typeRange = 1
								else
									typeRange = 2
							if("A-") typeRange = 3
							if("B+") typeRange = 4
							if("B-") typeRange = 5
							if("AB+") typeRange = 6
							if("O-") typeRange = 7
							if("O+") typeRange = 8
							if("AB-")
								if(prob(50))
									typeRange = 9
								else
									typeRange = 10
							else 
								if(prob(100/3))
									typeRange = 12
								else
									typeRange = 11
					else
						typeRange = rand(1,12)
					var/datum/bioEffect/NEW = null
					switch(typeRange)
						if(2) NEW = new /datum/bioEffect/hemochromia/bronze()
						if(3) NEW = new /datum/bioEffect/hemochromia/gold()
						if(4) NEW = new /datum/bioEffect/hemochromia/lime()
						if(5) NEW = new /datum/bioEffect/hemochromia/olive()
						if(6) NEW = new /datum/bioEffect/hemochromia/jade()
						if(7) NEW = new /datum/bioEffect/hemochromia/teal()
						if(8) NEW = new /datum/bioEffect/hemochromia/cobalt()
						if(9) NEW = new /datum/bioEffect/hemochromia/indigo()
						if(10) NEW = new /datum/bioEffect/hemochromia/purple()
						if(11) NEW = new /datum/bioEffect/hemochromia/violet()
						if(12) NEW = new /datum/bioEffect/hemochromia/fuschia()
						else NEW = new /datum/bioEffect/hemochromia/rust()

					if(duplicateCheck == 0)
						H.bioHolder.AddEffectInstance(NEW,1)
					holder.RemoveEffect(src.id)
					holder.RemovePoolEffect(src)

/datum/bioEffect/hemochromia
	name = "Hemochromia Type-A"
	desc = "An abstract mutation which is so much more unstable than Type-U that it shouldn't even be possible to observe with current technology."
	id = "hemochromia_abstract"
	probability = 0
	effectType = EFFECT_TYPE_MUTANTRACE
	msgGain = "You feel a bit less soft."
	msgLose = "You feel lightheaded for a moment."
	reclaim_fail = 10
	lockProb = 1
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("A","T","C","G")
	lockedTries = 12
	stability_loss = 5
	icon_state  = "hemochromia_unknown"
	research_level = EFFECT_RESEARCH_DONE
	occur_in_genepools = 0
	var/blood_color_R
	var/blood_color_G
	var/blood_color_B

	OnLife()
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if(H.blood_volume < 500 && H.blood_volume > 0)
				H.blood_volume += 2
			if(prob(12))
				H.blood_color = rgb(blood_color_R, blood_color_G, blood_color_B)

	OnRemove()
		..()
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.blood_color = DEFAULT_BLOOD_COLOR

/datum/bioEffect/hemochromia/rust
	name = "Hemochromia Type-R"
	desc = "Causes the subject's blood cells to take on a scarlet coloration. Also slightly increases blood viscosity."
	id = "hemochromia_rust"
	lockProb = 5
	lockedChars = list("A")
	icon_state  = "hemochromia_rust"

	OnAdd()
		..()
		blood_color_R = rand(254, 46)
		blood_color_G = rand(0, 0)
		blood_color_B = rand(0, 2)

/datum/bioEffect/hemochromia/bronze
	name = "Hemochromia Type-B"
	desc = "Causes the subject's blood cells to take on a copper coloration. Also slightly increases blood viscosity."
	id = "hemochromia_bronze"
	lockProb = 5
	lockedChars = list("A","T")
	icon_state  = "hemochromia_bronze"

	OnAdd()
		..()
		blood_color_R = rand(255, 68)
		blood_color_G = rand(122, 10)
		blood_color_B = rand(1, 0)

/datum/bioEffect/hemochromia/gold
	name = "Hemochromia Type-G"
	desc = "Causes the subject's blood cells to take on a brass coloration. Also slightly increases blood viscosity."
	id = "hemochromia_gold"
	lockProb = 10
	lockedChars = list("T","A")
	icon_state  = "hemochromia_gold"

	OnAdd()
		..()
		blood_color_R = rand(244, 101)
		blood_color_G = rand(218, 84)
		blood_color_B = rand(20, 4)

/datum/bioEffect/hemochromia/lime
	name = "Hemochromia Type-L"
	desc = "Causes the subject's blood cells to take on a chartreuse coloration. Also slightly increases blood viscosity."
	id = "hemochromia_lime"
	lockProb = 15
	lockedChars = list("C","G")
	icon_state  = "hemochromia_lime"

	OnAdd()
		..()
		blood_color_R = rand(135, 105)
		blood_color_G = rand(199, 153)
		blood_color_B = rand(0, 0)

/datum/bioEffect/hemochromia/olive
	name = "Hemochromia Type-O"
	desc = "Causes the subject's blood cells to take on a verdant coloration. Also slightly increases blood viscosity."
	id = "hemochromia_olive"
	lockProb = 20
	lockedChars = list("A","C")
	icon_state  = "hemochromia_olive"

	OnAdd()
		..()
		blood_color_R = rand(112, 25)
		blood_color_G = rand(147, 35)
		blood_color_B = rand(5, 0)

/datum/bioEffect/hemochromia/jade
	name = "Hemochromia Type-J"
	desc = "Causes the subject's blood cells to take on an emerald coloration. Also slightly increases blood viscosity."
	id = "hemochromia_jade"
	lockProb = 25
	lockedChars = list("G","A")
	icon_state  = "hemochromia_jade"

	OnAdd()
		..()
		blood_color_R = rand(0, 1)
		blood_color_G = rand(216, 56)
		blood_color_B = rand(105, 24)

/datum/bioEffect/hemochromia/teal
	name = "Hemochromia Type-T"
	desc = "Causes the subject's blood cells to take on a cyan coloration. Also slightly increases blood viscosity."
	id = "hemochromia_teal"
	lockProb = 30
	lockedChars = list("G","C")
	icon_state  = "hemochromia_teal"

	OnAdd()
		..()
		blood_color_R = rand(0, 0)
		blood_color_G = rand(205, 82)
		blood_color_B = rand(200, 80)

/datum/bioEffect/hemochromia/cobalt
	name = "Hemochromia Type-C"
	desc = "Causes the subject's blood cells to take on a cerulean coloration. Also slightly increases blood viscosity."
	id = "hemochromia_cobalt"
	lockProb = 35
	lockedChars = list("A","G")
	icon_state  = "hemochromia_cobalt"

	OnAdd()
		..()
		blood_color_R = rand(29, 0)
		blood_color_G = rand(104, 24)
		blood_color_B = rand(255, 78)

/datum/bioEffect/hemochromia/indigo
	name = "Hemochromia Type-I"
	desc = "Causes the subject's blood cells to take on an azure coloration. Also slightly increases blood viscosity."
	id = "hemochromia_indigo"
	lockProb = 40
	lockedChars = list("C","T")
	icon_state  = "hemochromia_indigo"

	OnAdd()
		..()
		blood_color_R = rand(84, 14)
		blood_color_G = rand(25, 3)
		blood_color_B = rand(255, 69)

/datum/bioEffect/hemochromia/purple
	name = "Hemochromia Type-P"
	desc = "Causes the subject's blood cells to take on a lavander coloration. Also slightly increases blood viscosity."
	id = "hemochromia_purple"
	lockProb = 45
	lockedChars = list("T","C")
	icon_state  = "hemochromia_purple"

	OnAdd()
		..()
		blood_color_R = rand(136, 57)
		blood_color_G = rand(61, 1)
		blood_color_B = rand(214, 92)

/datum/bioEffect/hemochromia/violet
	name = "Hemochromia Type-V"
	desc = "Causes the subject's blood cells to take on a plum coloration. Also slightly increases blood viscosity."
	id = "hemochromia_violet"
	lockProb = 50
	lockedChars = list("C","A")
	icon_state  = "hemochromia_violet"

	OnAdd()
		..()
		blood_color_R = rand(208, 93)
		blood_color_G = rand(26, 0)
		blood_color_B = rand(206, 91)

/datum/bioEffect/hemochromia/fuschia
	name = "Hemochromia Type-F"
	desc = "Causes the subject's blood cells to take on a magenta coloration. Also slightly increases blood viscosity."
	id = "hemochromia_fuschia"
	lockProb = 55
	lockedChars = list("C")
	icon_state  = "hemochromia_fuschia"

	OnAdd()
		..()
		blood_color_R = rand(238, 91)
		blood_color_G = rand(15, 1)
		blood_color_B = rand(124, 52)