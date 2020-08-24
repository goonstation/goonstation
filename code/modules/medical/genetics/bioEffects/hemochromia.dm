/datum/bioEffect/hemochromia
	name = "Hemochromia Type-U"
	desc = "A volatile mutation with 12 known stable alternatives. Will quickly break down into one of them if the subject exits the scanner."
	id = "hemochromia_unknown"
	probability = 44
	effectType = effectTypeMutantRace
	msgGain = "You feel like you're out of breath."
	msgLose = "You feel more stable."
	reclaim_fail = 10
	lockProb = 1
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("A","T","C","G")
	lockedTries = 12
	stability_loss = 5
	var/datum/bioEffect/BE = null
	var/typeRange = 0

	OnLife()
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner

			if(prob(12))
				if(!istype(H.loc, /obj/machinery/genetics_scanner))
					if(H.bioHolder.HasEffectInEither(var/datum/bioEffect/hemochromia))
						boutput(owner, "<span class='alert'>You already have hemochromia! Deleting Type-U instance.</span>") //Debug message. Delete it later, future me.
						qdel(src)
					if(4 => rand(13))
						typeRange = 8 //Placeholder for the name-based thing. Delete later.
						//Name-based thing here.
						boutput(owner, "<span class='alert'>Fate remembers your assigned color.</span>") //Debug message. Delete it later, future me.
					else
						typeRange = rand(1,12)
						boutput(owner, "<span class='alert'>Fate is blind sometimes.</span>") //Debug message. Delete it later, future me.
					switch(typeRange)
						if(2) var/datum/bioEffect/NEW = new BE.type(hemochromia/bronze)					
						if(3) var/datum/bioEffect/NEW = new BE.type(hemochromia/gold)					
						if(4) var/datum/bioEffect/NEW = new BE.type(hemochromia/lime)					
						if(5) var/datum/bioEffect/NEW = new BE.type(hemochromia/olive)					
						if(6) var/datum/bioEffect/NEW = new BE.type(hemochromia/jade)					
						if(7) var/datum/bioEffect/NEW = new BE.type(hemochromia/teal)					
						if(8) var/datum/bioEffect/NEW = new BE.type(hemochromia/cobalt)					
						if(9) var/datum/bioEffect/NEW = new BE.type(hemochromia/indigo)					
						if(10) var/datum/bioEffect/NEW = new BE.type(hemochromia/purple)					
						if(11) var/datum/bioEffect/NEW = new BE.type(hemochromia/violet)					
						if(12) var/datum/bioEffect/NEW = new BE.type(hemochromia/fuschia)
						else var/datum/bioEffect/NEW = new BE.type(hemochromia/rust)

					boutput(owner, "<span class='alert'>Stable hemochromia instance applied. Type number: [typeRange].</span>") //Debug message. Delete it later, future me.
					H.bioHolder.AddEffectInstance(NEW,1)
					boutput(owner, "<span class='alert'>Breakdown complete! Deleting Type-U instance.</span>") //Debug message. Delete it later, future me.
					qdel(src)

/datum/bioEffect/hemochromia/rust
	name = "Hemochromia Type-R"
	desc = "Causes the subject's blood cells to take on a scarlet coloration. Also slightly increases blood viscosity."
	id = "hemochromia_rust"
	effectType = effectTypeMutantRace
	msgLose = "You feel lightheaded for a moment."
	reclaim_fail = 10
	lockProb = 5
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("A")
	lockedTries = 12
	stability_loss = 5

/datum/bioEffect/hemochromia/bronze
	name = "Hemochromia Type-B"
	desc = "Causes the subject's blood cells to take on a copper coloration. Also slightly increases blood viscosity."
	id = "hemochromia_bronze"
	effectType = effectTypeMutantRace
	msgLose = "You feel lightheaded for a moment."
	reclaim_fail = 10
	lockProb = 5
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("A","T")
	lockedTries = 12
	stability_loss = 5

/datum/bioEffect/hemochromia/gold
	name = "Hemochromia Type-G"
	desc = "Causes the subject's blood cells to take on a brass coloration. Also slightly increases blood viscosity."
	id = "hemochromia_gold"
	effectType = effectTypeMutantRace
	msgLose = "You feel lightheaded for a moment."
	reclaim_fail = 10
	lockProb = 10
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("T","A")
	lockedTries = 12
	stability_loss = 5

/datum/bioEffect/hemochromia/lime
	name = "Hemochromia Type-L"
	desc = "Causes the subject's blood cells to take on a chartreuse coloration. Also slightly increases blood viscosity."
	id = "hemochromia_lime"
	effectType = effectTypeMutantRace
	msgLose = "You feel lightheaded for a moment."
	reclaim_fail = 10
	lockProb = 15
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("C","G")
	lockedTries = 12
	stability_loss = 5

/datum/bioEffect/hemochromia/olive
	name = "Hemochromia Type-O"
	desc = "Causes the subject's blood cells to take on a verdant coloration. Also slightly increases blood viscosity."
	id = "hemochromia_olive"
	effectType = effectTypeMutantRace
	msgLose = "You feel lightheaded for a moment."
	reclaim_fail = 10
	lockProb = 20
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("A","C")
	lockedTries = 12
	stability_loss = 5

/datum/bioEffect/hemochromia/jade
	name = "Hemochromia Type-J"
	desc = "Causes the subject's blood cells to take on an emerald coloration. Also slightly increases blood viscosity."
	id = "hemochromia_jade"
	effectType = effectTypeMutantRace
	msgLose = "You feel lightheaded for a moment."
	reclaim_fail = 10
	lockProb = 25
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","A")
	lockedTries = 12
	stability_loss = 5

/datum/bioEffect/hemochromia/teal
	name = "Hemochromia Type-T"
	desc = "Causes the subject's blood cells to take on a cyan coloration. Also slightly increases blood viscosity."
	id = "hemochromia_teal"
	effectType = effectTypeMutantRace
	msgLose = "You feel lightheaded for a moment."
	reclaim_fail = 10
	lockProb = 30
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("G","C")
	lockedTries = 12
	stability_loss = 5

/datum/bioEffect/hemochromia/cobalt
	name = "Hemochromia Type-C"
	desc = "Causes the subject's blood cells to take on a cerulean coloration. Also slightly increases blood viscosity."
	id = "hemochromia_cobalt"
	effectType = effectTypeMutantRace
	msgLose = "You feel lightheaded for a moment."
	reclaim_fail = 10
	lockProb = 35
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("A","G")
	lockedTries = 12
	stability_loss = 5

/datum/bioEffect/hemochromia/indigo
	name = "Hemochromia Type-I"
	desc = "Causes the subject's blood cells to take on an azure coloration. Also slightly increases blood viscosity."
	id = "hemochromia_indigo"
	effectType = effectTypeMutantRace
	msgLose = "You feel lightheaded for a moment."
	reclaim_fail = 10
	lockProb = 40
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("C","T")
	lockedTries = 12
	stability_loss = 5

/datum/bioEffect/hemochromia/purple
	name = "Hemochromia Type-P"
	desc = "Causes the subject's blood cells to take on a lavander coloration. Also slightly increases blood viscosity."
	id = "hemochromia_purple"
	effectType = effectTypeMutantRace
	msgLose = "You feel lightheaded for a moment."
	reclaim_fail = 10
	lockProb = 45
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("T","C")
	lockedTries = 12
	stability_loss = 5

/datum/bioEffect/hemochromia/violet
	name = "Hemochromia Type-V"
	desc = "Causes the subject's blood cells to take on a plum coloration. Also slightly increases blood viscosity."
	id = "hemochromia_violet"
	effectType = effectTypeMutantRace
	msgLose = "You feel lightheaded for a moment."
	reclaim_fail = 10
	lockProb = 50
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("C","A")
	lockedTries = 12
	stability_loss = 5

/datum/bioEffect/hemochromia/fuschia
	name = "Hemochromia Type-F"
	desc = "Causes the subject's blood cells to take on a magenta coloration. Also slightly increases blood viscosity."
	id = "hemochromia_fuschia"
	effectType = effectTypeMutantRace
	msgLose = "You feel lightheaded for a moment."
	reclaim_fail = 10
	lockProb = 55
	lockedGaps = 2
	lockedDiff = 2
	lockedChars = list("C")
	lockedTries = 12
	stability_loss = 5