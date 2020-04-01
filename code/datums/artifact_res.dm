// Artifact Research

/datum/artiresearch/
	var/name = "artifact research"
	var/bonustype = null // What kind of artifact it gives a bonus to identifying
	var/bonusamtO = 0    // Bonus % to identifying origin
	var/bonusamtT = 0    // Bonus % to identifying trigger
	var/bonusamtE = 0    // Bonus % to identifying effect/range
	var/bonusTime = 0    // Seconds reduced from analysis time

/datum/artiresearch/ancient1
	name = "Ancient Artifacts"
	bonustype = "ancient"
	bonusamtO = 75
	bonusamtT = 5
	bonusamtE = 5

/datum/artiresearch/martian1
	name = "Martian Artifacts"
	bonustype = "martian"
	bonusamtO = 75
	bonusamtT = 5
	bonusamtE = 5

/datum/artiresearch/crystal1
	name = "Wizard Artifacts"
	bonustype = "wizard"
	bonusamtO = 75
	bonusamtT = 5
	bonusamtE = 5

/datum/artiresearch/eldritch1
	name = "Eldritch Artifacts"
	bonustype = "eldritch"
	bonusamtO = 75
	bonusamtT = 5
	bonusamtE = 5

/datum/artiresearch/precursor1
	name = "Precursor Artifacts"
	bonustype = "precursor"
	bonusamtO = 75
	bonusamtT = 5
	bonusamtE = 5

/datum/artiresearch/general1
	name = "General Artifacts"
	bonustype = "all"
	bonusamtO = 15
	bonusamtT = 5
	bonusamtE = 5

/datum/artiresearch/analyser1
	name = "Analysis Algorithms"
	bonustype = "analyser"
	bonusTime = 10

/datum/artiresearch/ancient2
	name = "Ancient Mechanisms"
	bonustype = "ancient"
	bonusamtO = 10
	bonusamtT = 75
	bonusamtE = 5

/datum/artiresearch/martian2
	name = "Martian Bio-triggers"
	bonustype = "martian"
	bonusamtO = 10
	bonusamtT = 75
	bonusamtE = 5

/datum/artiresearch/crystal2
	name = "Wizard Rituals"
	bonustype = "wizard"
	bonusamtO = 10
	bonusamtT = 75
	bonusamtE = 5

/datum/artiresearch/eldritch2
	name = "Eldritch Invocations"
	bonustype = "eldritch"
	bonusamtO = 10
	bonusamtT = 75
	bonusamtE = 5

/datum/artiresearch/precursor2
	name = "Precursor Sequencing"
	bonustype = "precursor"
	bonusamtO = 10
	bonusamtT = 75
	bonusamtE = 5

/datum/artiresearch/general2
	name = "General Activation Procedure"
	bonustype = "all"
	bonusamtO = 5
	bonusamtT = 15
	bonusamtE = 5

/datum/artiresearch/analyser2
	name = "Advanced Analysis Software"
	bonustype = "analyser"
	bonusTime = 10

/datum/artiresearch/ancient3
	name = "Ancient Technology"
	bonustype = "ancient"
	bonusamtO = 10
	bonusamtT = 15
	bonusamtE = 80

/datum/artiresearch/martian3
	name = "Martian Bioengineering"
	bonustype = "martian"
	bonusamtO = 10
	bonusamtT = 15
	bonusamtE = 80

/datum/artiresearch/crystal3
	name = "Wizard Enchantments"
	bonustype = "wizard"
	bonusamtO = 10
	bonusamtT = 15
	bonusamtE = 80

/datum/artiresearch/eldritch3
	name = "Eldritch Curses"
	bonustype = "eldritch"
	bonusamtO = 10
	bonusamtT = 15
	bonusamtE = 80

/datum/artiresearch/precursor3
	name = "Precursor Circuits"
	bonustype = "precursor"
	bonusamtO = 10
	bonusamtT = 15
	bonusamtE = 80

/datum/artiresearch/general3
	name = "General Power Capacity"
	bonustype = "all"
	bonusamtO = 5
	bonusamtT = 5
	bonusamtE = 15

/datum/artiresearch/analyser3
	name = "High-Grade Analysis Process"
	bonustype = "analyser"
	bonusTime = 15
