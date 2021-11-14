/datum/bioEffect/hemochromia_unknown
	name = "Hemochromia Type-U"
	desc = "A volatile mutation with 12 known stable alternatives. Will quickly break down into one of them if the subject exits the scanner."
	id = "hemochromia_unknown"
	probability = 111
	msgGain = "You feel like you're out of breath."
	msgLose = "You feel more stable."
	reclaim_fail = 10
	lockProb = 1
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("A","T","C","G")
	lockedTries = 12
	stability_loss = 0
	icon_state  = "hemochromia_unknown"

	OnLife(var/mult)
		if(..()) return
		var/mob/living/carbon/human/H = owner
		if(ishuman(owner) && probmult(12) && !istype(H.loc, /obj/machinery/genetics_scanner))
			if(holder.GetASubtypeEffect(/datum/bioEffect/hemochromia))
				holder.RemoveEffect(src.id)
				holder.RemovePoolEffect(src)
				return
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

			H.bioHolder.AddEffectInstance(NEW,1)
			holder.RemoveEffect(src.id)
			holder.RemovePoolEffect(src)

ABSTRACT_TYPE(/datum/bioEffect/hemochromia)

/datum/bioEffect/hemochromia
	name = "Hemochromia Type-A"
	desc = "An abstract mutation which is so much more unstable than Type-U that it shouldn't even be possible to observe with current technology."
	id = "hemochromia_abstract"
	probability = 0
	msgGain = "You feel a bit less soft."
	msgLose = "You feel lightheaded for a moment."
	reclaim_fail = 10
	lockProb = 1
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("A","T","C","G")
	lockedTries = 12
	stability_loss = 0
	icon_state  = "hemochromia_unknown"
	occur_in_genepools = 0
	acceptable_in_mutini = 0
	var/blood_color_R
	var/blood_color_G
	var/blood_color_B

	OnLife(var/mult)
		if(..()) return
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if(H.blood_volume < 500 && H.blood_volume > 0)
				H.blood_volume += 2*mult
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
		blood_color_R = rand(46, 254)
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
		blood_color_R = rand(68, 255)
		blood_color_G = rand(10, 122)
		blood_color_B = rand(0, 1)

/datum/bioEffect/hemochromia/gold
	name = "Hemochromia Type-G"
	desc = "Causes the subject's blood cells to take on a brass coloration. Also slightly increases blood viscosity."
	id = "hemochromia_gold"
	lockProb = 10
	lockedChars = list("T","A")
	icon_state  = "hemochromia_gold"

	OnAdd()
		..()
		blood_color_R = rand(101, 244)
		blood_color_G = rand(84, 218)
		blood_color_B = rand(4, 20)

/datum/bioEffect/hemochromia/lime
	name = "Hemochromia Type-L"
	desc = "Causes the subject's blood cells to take on a chartreuse coloration. Also slightly increases blood viscosity."
	id = "hemochromia_lime"
	lockProb = 15
	lockedChars = list("C","G")
	icon_state  = "hemochromia_lime"

	OnAdd()
		..()
		blood_color_R = rand(105, 135)
		blood_color_G = rand(153, 199)
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
		blood_color_R = rand(25, 112)
		blood_color_G = rand(35, 147)
		blood_color_B = rand(0, 5)

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
		blood_color_G = rand(56, 216)
		blood_color_B = rand(24, 105)

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
		blood_color_G = rand(82, 205)
		blood_color_B = rand(80, 200)

/datum/bioEffect/hemochromia/cobalt
	name = "Hemochromia Type-C"
	desc = "Causes the subject's blood cells to take on a cerulean coloration. Also slightly increases blood viscosity."
	id = "hemochromia_cobalt"
	lockProb = 35
	lockedChars = list("A","G")
	icon_state  = "hemochromia_cobalt"

	OnAdd()
		..()
		blood_color_R = rand(0, 29)
		blood_color_G = rand(24, 104)
		blood_color_B = rand(78, 255)

/datum/bioEffect/hemochromia/indigo
	name = "Hemochromia Type-I"
	desc = "Causes the subject's blood cells to take on an azure coloration. Also slightly increases blood viscosity."
	id = "hemochromia_indigo"
	lockProb = 40
	lockedChars = list("C","T")
	icon_state  = "hemochromia_indigo"

	OnAdd()
		..()
		blood_color_R = rand(14, 84)
		blood_color_G = rand(3, 25)
		blood_color_B = rand(69, 255)

/datum/bioEffect/hemochromia/purple
	name = "Hemochromia Type-P"
	desc = "Causes the subject's blood cells to take on a lavander coloration. Also slightly increases blood viscosity."
	id = "hemochromia_purple"
	lockProb = 45
	lockedChars = list("T","C")
	icon_state  = "hemochromia_purple"

	OnAdd()
		..()
		blood_color_R = rand(57, 136)
		blood_color_G = rand(1, 61)
		blood_color_B = rand(92, 214)

/datum/bioEffect/hemochromia/violet
	name = "Hemochromia Type-V"
	desc = "Causes the subject's blood cells to take on a plum coloration. Also slightly increases blood viscosity."
	id = "hemochromia_violet"
	lockProb = 50
	lockedChars = list("C","A")
	icon_state  = "hemochromia_violet"

	OnAdd()
		..()
		blood_color_R = rand(93, 208)
		blood_color_G = rand(0, 26)
		blood_color_B = rand(91, 206)

/datum/bioEffect/hemochromia/fuschia
	name = "Hemochromia Type-F"
	desc = "Causes the subject's blood cells to take on a magenta coloration. Also slightly increases blood viscosity."
	id = "hemochromia_fuschia"
	lockProb = 55
	lockedChars = list("C")
	icon_state  = "hemochromia_fuschia"

	OnAdd()
		..()
		blood_color_R = rand(91, 238)
		blood_color_G = rand(1, 15)
		blood_color_B = rand(52, 124)
