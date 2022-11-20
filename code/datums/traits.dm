//Unlockable traits? tied to achievements?
#define TRAIT_STARTING_POINTS 1 //How many "free" points you get
#define TRAIT_MAX 7			    //How many traits people can select at most.

/proc/getTraitById(var/id)
	. = traitList[id]

/proc/traitCategoryAllowed(var/list/targetList, var/idToCheck)
	. = TRUE
	var/datum/trait/C = getTraitById(idToCheck)
	if(C.category == null)
		return TRUE
	for(var/A in targetList)
		var/datum/trait/T = getTraitById(A)
		for (var/cat in T.category)
			if (cat in C.category)
				return FALSE

/datum/traitPreferences
	var/list/traits_selected = list()

	var/point_total = TRAIT_STARTING_POINTS
	var/free_points = TRAIT_STARTING_POINTS
	var/max_traits = TRAIT_MAX
	var/list/hidden_categories = list(
		"nopug",
		"cloner_stuff",
		"hemophilia",
	)

	proc/selectTrait(var/id)
		var/list/future_selected = traits_selected.Copy()
		if (id in traitList)
			future_selected |= id

		if (!isValid(future_selected))
			return FALSE

		traits_selected = future_selected
		updateTotal()
		return TRUE

	proc/unselectTrait(var/id)
		var/list/future_selected = traits_selected.Copy()
		future_selected -= id

		if (!isValid(future_selected))
			return FALSE

		traits_selected = future_selected
		updateTotal()
		return TRUE

	proc/resetTraits()
		traits_selected = list()
		updateTotal()

	proc/calcTotal(var/list/selected = traits_selected)
		. = free_points
		for(var/T in selected)
			if(T in traitList)
				var/datum/trait/O = traitList[T]
				. += O.points

	proc/updateTotal()
		point_total = calcTotal()

	proc/isValid(var/list/selected = traits_selected)
		if (length(selected) > TRAIT_MAX)
			return FALSE

		var/list/categories = list()
		for(var/A in selected)
			var/datum/trait/T = getTraitById(A)
			if(T.unselectable) return 0

			if(islist(T.category))
				for (var/cat in T.category)
					if(cat in categories)
						return FALSE
					else
						categories.Add(cat)

		return (calcTotal(selected) >= 0)

	proc/isAvailableTrait(var/id, var/unselect = FALSE)
		var/list/future_selected = traits_selected.Copy()
		if (unselect)
			future_selected -= id
		else
			future_selected += id

		if (!isValid(future_selected))
			return FALSE

		return TRUE

	proc/getTraits(var/mob/user)
		. = list()

		var/skipUnlocks = 0
		for(var/X in traitList)
			var/datum/trait/C = getTraitById(X)

			if(C.unselectable) continue

			if(C.requiredUnlock != null && skipUnlocks) continue

			if(C.requiredUnlock != null && user.client) //If this needs an xp unlock, check against the pre-generated list of related xp unlocks for this person.
				if(!isnull(user.client.qualifiedXpRewards))
					if(!(C.requiredUnlock in user.client.qualifiedXpRewards))
						continue
				else
					boutput(user, "<span class='alert'><b>WARNING: XP unlocks failed to update. Some traits may not be available. Please try again in a moment.</b></span>")
					SPAWN(0)
						user.client.updateXpRewards()
					skipUnlocks = 1
					continue

			. += C

/datum/traitHolder
	var/list/traits = list()
	var/list/moveTraits = list() // differentiate movement traits for Move()
	var/mob/owner = null

	New(var/mob/ownerMob)
		owner = ownerMob
		return ..()

	proc/copy(mob/newMob)
		RETURN_TYPE(/datum/traitHolder)
		var/datum/traitHolder/traitHolder = new(newMob)
		for(var/id in traits)
			traitHolder.addTrait(id, traits[id])
		return traitHolder

	proc/copy_to(datum/traitHolder/other)
		other.removeAll()
		for(var/id in traits)
			other.addTrait(id, traits[id])

	proc/addTrait(id, datum/trait/trait_instance=null)
		if(!(id in traits))
			var/datum/trait/T = null
			if(isnull(trait_instance))
				var/traitType = traitList[id].type
				T = new traitType
			else
				T = trait_instance
			traits[id] = T
			if(!isnull(owner))
				if(T.isMoveTrait)
					moveTraits.Add(id)
				T.onAdd(owner)

	proc/removeTrait(id)
		if((id in traits))
			var/datum/trait/T = traits[id]
			traits.Remove(id)
			if(!isnull(owner))
				if(T.isMoveTrait)
					moveTraits.Remove(id)
				T.onRemove(owner)

	proc/removeAll()
		for (var/id in traits)
			var/datum/trait/T = traits[id]
			if(!isnull(owner))
				if(T.isMoveTrait)
					moveTraits.Remove(T.id)
				T.onRemove(owner)
		traits.Cut()

	proc/getTrait(id)
		RETURN_TYPE(/datum/trait)
		return traits[id]

	proc/hasTrait(var/id)
		. = (id in traits)

//Yes these are objs because grid control. Shut up. I don't like it either.
/datum/trait
	var/name
	var/desc
	var/icon = 'icons/ui/traits.dmi'
	var/icon_state = "placeholder"
	var/id = ""        //Unique ID
	var/points = 0	   //The change in points when this is selected.
	var/list/category = null //If set to a non-null string, People will only be able to pick one trait of any given category
	var/unselectable = FALSE //If TRUE, trait can not be select at char setup
	var/requiredUnlock = null //If set to a string, the xp unlock of that name is required for this to be selectable.
	var/isMoveTrait = FALSE // If TRUE, onMove will be called each movement step from the holder's mob
	var/datum/mutantrace/mutantRace = null //If set, should be in the "species" category.

	New()
		ASSERT(src.name)
		..()

	proc/onAdd(var/mob/owner)
		if(mutantRace && ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.mutantrace?.origAH.CopyOther(H.bioHolder.mobAppearance)
			H.set_mutantrace(mutantRace)
		return

	proc/onRemove(var/mob/owner)
		return

	proc/onLife(var/mob/owner, var/mult)
		return

	proc/onMove(var/mob/owner)
		return

// BODY - Red Border

/datum/trait/roboarms
	name = "Robotic arms"
	desc = "Your arms have been replaced with light robotic arms."
	id = "roboarms"
	icon_state = "robotarmsR"
	points = 0
	category = list("body")

	onAdd(var/mob/owner)
		SPAWN(4 SECONDS) //Fuck this. Fuck the way limbs are added with a delay. FUCK IT
			if(ishuman(owner))
				var/mob/living/carbon/human/H = owner
				if(H.limbs != null)
					H.limbs.replace_with("l_arm", /obj/item/parts/robot_parts/arm/left/light, null , 0, TRUE)
					H.limbs.replace_with("r_arm", /obj/item/parts/robot_parts/arm/right/light, null , 0, TRUE)
					H.limbs.l_arm.holder = H
					H.limbs.r_arm.holder = H
					H.update_body()

/datum/trait/syntharms
	name = "Green Fingers"
	desc = "Excess exposure to radiation, mutagen and gardening have turned your arms into plants. The horror!"
	id = "syntharms"
	icon_state = "robotarmsR"
	points = -2
	category = list("body")

	onAdd(var/mob/owner)
		SPAWN(4 SECONDS)
			if(ishuman(owner))
				var/mob/living/carbon/human/H = owner
				if(H.limbs != null)
					H.limbs.replace_with("l_arm", pick(/obj/item/parts/human_parts/arm/left/synth/bloom, /obj/item/parts/human_parts/arm/left/synth), null , 0, TRUE)
					H.limbs.replace_with("r_arm", pick(/obj/item/parts/human_parts/arm/right/synth/bloom, /obj/item/parts/human_parts/arm/right/synth), null , 0, TRUE)
					H.limbs.l_arm.holder = H
					H.limbs.r_arm.holder = H
					H.update_body()

/datum/trait/explolimbs
	name = "Adamantium Skeleton"
	desc = "Halves the chance that an explosion will blow off your limbs."
	id = "explolimbs"
	category = list("body")
	points = -2

/datum/trait/deaf
	name = "Deaf"
	desc = "Spawn with permanent deafness and an auditory headset."
	id = "deaf"
	icon_state = "deaf"
	category = list("body")
	points = 1

	onAdd(var/mob/owner)
		if(owner.bioHolder)
			if(ishuman(owner))
				owner.bioHolder.AddEffect("deaf", 0, 0, 0, 1)

	onLife(var/mob/owner) //Just to be super safe.
		if(!owner.ear_disability)
			owner.bioHolder.AddEffect("deaf", 0, 0, 0, 1)

/datum/trait/nolegs
	name = "Stumped"
	desc = "Because of a freak accident involving a piano, a forklift, and lots of vodka, both of your legs had to be amputated. Fortunately, NT has kindly supplied you with a wheelchair out of the goodness of their heart. (due to regulations)"
	id = "nolegs"
	icon_state = "placeholder"
	category = list("body")
	points = 0
// LANGUAGE - Yellow Border

/datum/trait/swedish
	name = "Swedish"
	desc = "You are from sweden. Meat balls and so on."
	id = "swedish"
	icon_state = "swedenY"
	points = 0
	category = list("language")

	onAdd(var/mob/owner)
		owner.bioHolder?.AddEffect("accent_swedish", 0, 0, 0, 1)

/datum/trait/french
	name = "French"
	desc = "You are from Quebec. y'know, the other Canada."
	id = "french"
	icon_state = "frY"
	points = 0
	category = list("language")

	onAdd(var/mob/owner)
		owner.bioHolder?.AddEffect("accent_french", 0, 0, 0, 1)

/datum/trait/scots
	name = "Scottish"
	desc = "Hear the pipes are calling, down thro' the glen. Och aye!"
	id = "scottish"
	icon_state = "scott"
	points = 0
	category = list("language")

	onAdd(var/mob/owner)
		owner.bioHolder?.AddEffect("accent_scots", 0, 0, 0, 1)

/datum/trait/chav
	name = "Chav"
	desc = "U wot m8? I sware i'll fite u."
	id = "chav"
	icon_state = "ukY"
	points = 0
	category = list("language")

	onAdd(var/mob/owner)
		owner.bioHolder?.AddEffect("accent_chav", 0, 0, 0, 1)

/datum/trait/elvis
	name = "Funky Accent"
	desc = "Give a man a banana and he will clown for a day. Teach a man to clown and he will live in a cold dark corner of a space station for the rest of his days. - Elvis, probably."
	id = "elvis"
	icon_state = "elvis"
	points = 0
	category = list("language")

	onAdd(var/mob/owner)
		owner.bioHolder?.AddEffect("accent_elvis", 0, 0, 0, 1)

/datum/trait/tommy // please do not re-enable this without talking to spy tia
	name = "New Jersey Accent"
	desc = "Ha ha ha. What a story, Mark."
	id = "tommy"
	icon_state = "whatY"
	points = 0
	category = list("language")
	unselectable = TRUE // this was not supposed to be a common thing!!
/*
	onAdd(var/mob/owner)
		owner.bioHolder?.AddEffect("accent_tommy")
		return
*/

/datum/trait/finnish
	name = "Finnish Accent"
	desc = "...and you thought space didn't have Finns?"
	id = "finnish"
	icon_state = "finnish"
	points = 0
	category = list("language")

	onAdd(var/mob/owner)
		owner.bioHolder?.AddEffect("accent_finnish", 0, 0, 0, 1)

/datum/trait/tyke
	name = "Tyke"
	desc = "You're from Oop North in Yorkshire, and don't let anyone forget it!"
	id = "tyke"
	icon_state = "yorkshire"
	points = 0
	category = list("language")

	onAdd(var/mob/owner)
		owner.bioHolder?.AddEffect("accent_tyke")

// VISION/SENSES - Green Border

/datum/trait/cateyes
	name = "Cat eyes"
	desc = "You can see 2 tiles further in the dark."
	id = "cateyes"
	icon_state = "catseyeG"
	points = -1
	category = list("vision")

/datum/trait/infravision
	name = "Infravision"
	desc = "You can always see messages written in infra-red ink."
	id = "infravision"
	icon_state = "infravisionG"
	points = -1
	category = list("vision")

/datum/trait/shortsighted
	name = "Short-sighted"
	desc = "Spawn with permanent short-sightedness and glasses."
	id = "shortsighted"
	icon_state = "glassesG"
	category = list("vision")
	points = 1

	onAdd(var/mob/owner)
		if(owner.bioHolder)
			if(ishuman(owner))
				owner.bioHolder.AddEffect("bad_eyesight", 0, 0, 0, 1)

	onLife(var/mob/owner) //Just to be super safe.
		if(owner.bioHolder && !owner.bioHolder.HasEffect("bad_eyesight"))
			owner.bioHolder.AddEffect("bad_eyesight", 0, 0, 0, 1)

/datum/trait/blind
	name = "Blind"
	desc = "Spawn with permanent blindness and a VISOR."
	icon_state = "blind"
	id = "blind"
	category = list("vision")
	points = 2

	onAdd(var/mob/owner)
		if(owner.bioHolder)
			if(istype(owner, /mob/living/carbon/human))
				owner.bioHolder.AddEffect("blind", 0, 0, 0, 1)

	onLife(var/mob/owner) //Just to be safe.
		if(owner.bioHolder && !owner.bioHolder.HasEffect("blind"))
			owner.bioHolder.AddEffect("blind", 0, 0, 0, 1)

// GENETICS - Blue Border

/datum/trait/mildly_mutated
	name = "Mildly Mutated"
	desc = "A random mutation in your gene pool starts activated."
	id = "mildly_mutated"
	icon_state = "mildly_mutatedB"
	points = 0
	category = list("genetics")

	onAdd(var/mob/owner)
		var/datum/bioHolder/B = owner.bioHolder
		var/datum/bioEffect/E = pick(B.effectPool)
		B.ActivatePoolEffect(B.effectPool[E], 1, 0)
		SPAWN (1 SECOND) // This DOES NOT WORK at round start unless delayed but somehow the trait part is logged??
			logTheThing(LOG_COMBAT, owner, "gets the bioeffect [E] from the trait [name].")

/datum/trait/stablegenes
	name = "Stable Genes"
	desc = "You are less likely to mutate from radiation or mutagens."
	id = "stablegenes"
	icon_state = "dontmutateB"
	points = -2
	category = list("genetics")

// TRINKETS/ITEMS - Purple Border

/datum/trait/loyalist
	name = "NT loyalist"
	desc = "Start with a Nanotrasen Beret as your trinket."
	id = "loyalist"
	icon_state = "beretP"
	points = -1
	category = list("trinkets")

/datum/trait/petasusaphilic
	name = "Petasusaphilic"
	desc = "Start with a random hat as your trinket."
	id = "petasusaphilic"
	icon_state = "hatP"
	points = -1
	category = list("trinkets")

/datum/trait/conspiracytheorist
	name = "Conspiracy Theorist"
	desc = "Start with a tin foil hat as your trinket."
	id = "conspiracytheorist"
	icon_state = "conspP"
	points = -1
	category = list("trinkets")

/datum/trait/pawnstar
	name = "Pawn Star"
	desc = "You sold your trinket before you departed for the station. You start with a bonus of 25% of your starting cash in your inventory."
	id = "pawnstar"
	icon_state = "pawnP"
	points = 0
	category = list("trinkets")

/datum/trait/beestfriend
	name = "BEEst friend"
	desc = "Start with a bee egg as your trinket."
	id = "beestfriend"
	icon_state = "bee"
	points = -1
	category = list("trinkets")

/datum/trait/lunchbox
	name = "Lunchbox"
	desc = "Start your shift with a cute little lunchbox, packed with all your favourite foods!"
	id = "lunchbox"
	icon_state = "lunchbox"
	points = -1
	category = list("trinkets")

/datum/trait/bald
	name = "Bald"
	desc = "Start your shift with a wig instead of hair. I'm sure no one will be able to tell."
	id = "bald"
	icon_state = "placeholder"
	points = 0
	category = list("trinkets", "nopug")

/datum/trait/one_armed
	name = "One Armed Spaceman"
	desc = "You only have one arm. But which one? It's a mystery... or is it a thriller?"
	id = "onearmed"
	icon_state = "placeholder"
	points = 0



// Skill - White Border

/datum/trait/smoothtalker
	name = "Smooth talker"
	desc = "Traders will tolerate 50% more when you are haggling with them."
	id = "smoothtalker"
	category = list("skill")
	points = -1

/datum/trait/matrixflopout
	name = "Matrix Flopout"
	desc = "Flipping lets you dodge bullets and attacks for a higher stamina cost!"
	id = "matrixflopout"
	category = list("skill")
	points = -2

/datum/trait/happyfeet
	name = "Happyfeet"
	desc = "Sometimes people can't help but dance along with you."
	id = "happyfeet"
	category = list("skill")
	points = -1

/datum/trait/claw
	name = "Claw School Graduate"
	desc = "Your skill at claw machines is unparalleled."
	id = "claw"
	icon_state = "claw"
	category = list("skill")
	points = -1

/* Hey dudes, I moved these over from the old bioEffect/Genetics system so they work on clone */

ABSTRACT_TYPE(/datum/trait/job)
/datum/trait/job
	desc = "This is an error! Please report this to coders. May cause pointed questions towards the affected!"
	id = "error"
	points = 0
	unselectable = TRUE
	category = list("job")

	onAdd(mob/owner)
		return

	onLife(mob/owner) //Just to be safe.
		return

/datum/trait/job/chaplain
	name = "Chaplain Training"
	desc = "Subject is trained in cultural and psychological matters."
	id = "training_chaplain"

/datum/trait/job/medical
	name = "Medical Training"
	desc = "Subject is a proficient surgeon."
	id = "training_medical"

/datum/trait/job/headsurgeon
	name = "Party Surgeon"
	desc = "Subject was a blast at med-school parties."
	id = "training_partysurgeon"

/datum/trait/job/engineer
	name = "Engineering Training"
	desc = "Subject is trained in engineering."
	id = "training_engineer"

/datum/trait/job/security
	name = "Security Training"
	desc = "Subject is trained in generalized robustness and asskicking."
	id = "training_security"

/datum/trait/job/quartermaster
	name = "Quartermaster Training"
	desc = "Subject is proficent at haggling."
	id = "training_quartermaster"

/datum/trait/job/chef
	name = "Kitchen Training"
	desc = "Subject is experienced in foodstuffs and their effects."
	id = "training_chef"

// bartender, detective, HoS
/datum/trait/job/drinker
	name = "Professional Drinker"
	desc = "Sometimes you drink on the job, sometimes drinking is the job."
	id = "training_drinker"

// Stats - Undetermined Border
/datum/trait/athletic
	name = "Athletic"
	desc = "Great stamina! Frail body."
	id = "athletic"
	category = list("stats")
	points = -2

	onAdd(var/mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.add_stam_mod_max("trait", STAMINA_MAX * 0.1)
			APPLY_ATOM_PROPERTY(H, PROP_MOB_STAMINA_REGEN_BONUS, "trait", STAMINA_REGEN * 0.1)

/datum/trait/bigbruiser
	name = "Big Bruiser"
	desc = "Stronger punches but higher stamina cost!"
	id = "bigbruiser"
	category = list("stats")
	points = -2

//Category: Background.

/datum/trait/immigrant
	name = "Stowaway"
	desc = "You spawn hidden away on-station without an ID, PDA, or entry in NT records."
	id = "immigrant"
	icon_state = "stowaway"
	category = list("background")
	points = 1

/datum/trait/pilot
	name = "Pilot"
	desc = "You spawn in a pod off-station with a Space GPS, Emergency Oxygen Tank, Breath Mask and proper protection, but you have no PDA and your pod cannot open wormholes."
	id = "pilot"
	icon_state = "pilot"
	category = list("background")
	points = 0


/datum/trait/sleepy
	name = "Heavy Sleeper"
	desc = "You always sleep through the start of the shift, and wake up in a random bed."
	id = "sleepy"
	category = list("background")
	points = 0

// NO CATEGORY - Grey Border

/datum/trait/hemo
	name = "Hemophilia"
	desc = "You bleed more easily and you bleed more."
	id = "hemophilia"
	points = 1
	category = list("hemophilia")

/datum/trait/weakorgans
	name = "Frail Constitution"
	desc = "Your internal organs (brain included) are extremely vulnerable to damage."
	id = "weakorgans"
	points = 2

/datum/trait/slowmetabolism
	name = "Slow Metabolism"
	desc = "Any chemicals in you body deplete much more slowly."
	id = "slowmetabolism"
	points = 0

/datum/trait/alcoholic
	name = "Career alcoholic"
	desc = "You gain alcohol resistance but your speech is permanently slurred."
	id = "alcoholic"
	icon_state = "beer"
	points = 0

	onAdd(var/mob/owner)
		owner.bioHolder?.AddEffect("resist_alcohol", 0, 0, 0, 1)

/datum/trait/random_allergy
	name = "Allergy"
	desc = "You're allergic to... something. You can't quite remember, but how bad could it possibly be?"
	id = "randomallergy"
	points = 0
	category = list("allergy")

	var/allergen = null

	var/list/allergen_id_list = list("spaceacillin","morphine","teporone","salicylic_acid","calomel","synthflesh","omnizine","saline","anti_rad","smelling_salt",\
	"haloperidol","epinephrine","insulin","silver_sulfadiazine","mutadone","ephedrine","penteticacid","antihistamine","styptic_powder","cryoxadone","atropine",\
	"salbutamol","perfluorodecalin","mannitol","charcoal","antihol","ethanol","iron","mercury","oxygen","plasma","sugar","radium","water","bathsalts","jenkem","crank",\
	"LSD","space_drugs","THC","nicotine","krokodil","catdrugs","triplemeth","methamphetamine","mutagen","neurotoxin","sarin","smokepowder","infernite","phlogiston","fuel",\
	"anti_fart","lube","ectoplasm","cryostylane","oil","sewage","ants","spiders","poo","love","hugs","fartonium","blood","bloodc","vomit","urine","capsaicin","cheese",\
	"coffee","chocolate","chickensoup","salt","grease","badgrease","msg","egg")

	New()
		..()
		allergen = pick(allergen_id_list)

	onAdd(var/mob/owner)
		SPAWN (1 SECOND) // This DOES NOT WORK at round start unless delayed but somehow the trait part is logged??
			logTheThing(LOG_COMBAT, owner, "gains an allergy to [allergen] from the trait [name].")

	onLife(var/mob/owner)
		if (owner?.reagents?.has_reagent(allergen))
			owner.reagents.add_reagent("histamine", min(1.4 / (owner.reagents.has_reagent("antihistamine") ? 2 : 1), 120-owner.reagents.get_reagent_amount("histamine"))) //1.4 units of histamine per life cycle, halved with antihistamine and capped at 120u

/datum/trait/random_allergy/medical_allergy
	name = "Medical Allergy"
	desc = "You're allergic to some medical chemical... but you can't remember which."
	id = "medicalallergy"
	points = 1
	category = list("allergy")

	allergen_id_list = list("spaceacillin","morphine","teporone","salicylic_acid","calomel","synthflesh","omnizine","saline","anti_rad","smelling_salt",\
	"haloperidol","epinephrine","insulin","silver_sulfadiazine","mutadone","ephedrine","penteticacid","antihistamine","styptic_powder","cryoxadone","atropine",\
	"salbutamol","perfluorodecalin","mannitol","charcoal","antihol")

/datum/trait/addict
	name = "Addict"
	desc = "You spawn with a random addiction. Once cured there is a small chance that you will suffer a relapse."
	id = "addict"
	icon_state = "syringe"
	points = 2
	var/selected_reagent = "ethanol"
	var/addictive_reagents = list("bath salts", "lysergic acid diethylamide", "space drugs", "psilocybin", "cat drugs", "methamphetamine", "ethanol", "nicotine")
	var/do_addiction = FALSE

	New()
		..()
		selected_reagent = pick(addictive_reagents)

	onAdd(var/mob/owner)
		if(isliving(owner))
			SPAWN(rand(4 MINUTES, 8 MINUTES))
				addAddiction(owner)
				do_addiction = TRUE

	onLife(var/mob/owner, var/mult) //Just to be safe.
		if(isliving(owner) && do_addiction && probmult(1))
			var/mob/living/M = owner
			for(var/datum/ailment_data/addiction/A in M.ailments)
				if(istype(A, /datum/ailment_data/addiction))
					if(A.associated_reagent == selected_reagent) return
			addAddiction(owner)

	proc/addAddiction(var/mob/owner)
		var/mob/living/M = owner
		var/datum/ailment_data/addiction/AD = new
		AD.associated_reagent = selected_reagent
		AD.last_reagent_dose = world.timeofday
		AD.name = "[selected_reagent] addiction"
		AD.affected_mob = M
		M.ailments += AD

/datum/trait/strongwilled
	name = "Strong willed"
	desc = "You are more resistant to addiction."
	id = "strongwilled"
	icon_state = "nosmoking"
	points = -1

/datum/trait/addictive_personality // different than addict because you just have a general weakness to addictions instead of starting with a specific one
	name = "Addictive Personality"
	desc = "You are less resistant to addiction."
	id = "addictive_personality"
	icon_state = "syringe"
	points = 1

/datum/trait/clown_disbelief
	name = "Clown Disbelief"
	desc = "You refuse to acknowledge that clowns could exist on a space station."
	id = "clown_disbelief"
	icon_state = "clown_disbelief"
	points = 0

	onAdd(mob/owner)
		OTHER_START_TRACKING_CAT(owner, TR_CAT_CLOWN_DISBELIEF_MOBS)
		if(owner.client)
			src.turnOn(owner)
		src.RegisterSignal(owner, COMSIG_MOB_LOGIN, .proc/turnOn)
		src.RegisterSignal(owner, COMSIG_MOB_LOGOUT, .proc/turnOff)
		src.RegisterSignal(owner, COMSIG_ATOM_EXAMINE, .proc/examined)

	proc/turnOn(mob/owner)
		for(var/image/I as anything in global.clown_disbelief_images)
			owner.client.images += I

	proc/examined(mob/owner, mob/examiner, list/lines)
		if(examiner.job == "Clown")
			lines += "<br>[capitalize(he_or_she(owner))] doesn't seem to notice you."

	onRemove(mob/owner)
		OTHER_STOP_TRACKING_CAT(owner, TR_CAT_CLOWN_DISBELIEF_MOBS)
		if(owner.client)
			src.turnOff(owner)
		src.UnregisterSignal(owner, list(COMSIG_MOB_LOGIN, COMSIG_MOB_LOGOUT, COMSIG_ATOM_EXAMINE))

	proc/turnOff(mob/owner)
		for(var/image/I as anything in global.clown_disbelief_images)
			owner.last_client.images -= I


/datum/trait/unionized
	name = "Unionized"
	desc = "You start with a higher paycheck than normal."
	id = "unionized"
	icon_state = "handshake"
	points = -1

/datum/trait/jailbird
	name = "Jailbird"
	desc = "You have a criminal record and are currently on the run!"
	id = "jailbird"
	icon_state = "jail"
	points = -1

/datum/trait/clericalerror
	name = "Clerical Error"
	desc = "The name on your starting ID is misspelled."
	id = "clericalerror"
	icon_state = "spellingerror"
	points = 0

/datum/trait/chemresist
	name = "Chem resistant"
	desc = "You are more resistant to chem overdoses."
	id = "chemresist"
	points = -2

/datum/trait/puritan
	name = "Puritan"
	desc = "You can not be cloned or revived except by cyborgification. Any attempt will end badly."
	id = "puritan"
	points = 2
	category = list("cloner_stuff")


/datum/trait/survivalist
	name = "Survivalist"
	desc = "Food will heal you even if you are badly injured."
	id = "survivalist"
	points = -1

/datum/trait/smoker
	name = "Smoker"
	desc = "You will not absorb any chemicals from smoking cigarettes."
	id = "smoker"
	icon_state = "smoker"
	points = -1

/datum/trait/nervous
	name = "Nervous"
	desc = "Witnessing injuries or violence will sometimes make you freak out."
	id = "nervous"
	icon_state = "nervous"
	points = 1

	onAdd(var/mob/owner)
		..()
		OTHER_START_TRACKING_CAT(owner, TR_CAT_NERVOUS_MOBS)

	onRemove(var/mob/owner)
		..()
		OTHER_STOP_TRACKING_CAT(owner, TR_CAT_NERVOUS_MOBS)

/datum/trait/burning
	name = "Human Torch"
	desc = "Fire no longer slowly peters out when you're burning."
	id = "burning"
	icon_state = "onfire"
	points = 2

/datum/trait/carpenter
	name = "Carpenter"
	desc = "You can construct things more quickly than other people."
	icon_state = "carpenter"
	id = "carpenter"
	points = -1

/datum/trait/kleptomaniac
	name = "Kleptomaniac"
	desc = "You will sometimes randomly pick up nearby items."
	id = "kleptomaniac"
	points = 1

	onLife(var/mob/owner, var/mult)
		if(!owner.stat && !owner.lying && can_act(owner) && !owner.equipped() && probmult(6))
			for(var/obj/item/I in view(1, owner))
				if(!I.anchored && !I.cant_drop && isturf(I.loc) && can_reach(owner, I))
					I.Attackhand(owner)
					owner.emote(pick("grin", "smirk", "chuckle", "smug"))
					break

/datum/trait/clutz
	name = "Clutz"
	desc = "When interacting with anything you have a chance to interact with something different instead."
	id = "clutz"
	points = 2

/datum/trait/leftfeet
	name = "Two left feet"
	desc = "Every now and then you'll stumble in a random direction."
	id = "leftfeet"
	points = 1

/datum/trait/scaredshitless
	name = "Scared Shitless"
	desc = "Literally. When you scream, you fart. Be careful around Bibles!"
	id = "scaredshitless"
	icon_state = "poo"
	points = 0

/datum/trait/allergic
	name = "Hyperallergic"
	desc = "You have a severe sensitivity to allergens and are liable to slip into anaphylactic shock upon exposure."
	id = "allergic"
	icon_state = "placeholder"
	points = 1
	category = list("allergy")

/datum/trait/allears
	name="All ears"
	desc = "You lost your headset on the way to work."
	id = "allears"
	points = 0

/datum/trait/atheist
	name = "Atheist"
	desc = "In this moment, you are euphoric. You cannot receive faith healing, and prayer makes you feel silly."
	id = "atheist"
	points = 0

/datum/trait/lizard
	name = "Reptilian"
	icon_state = "lizardT"
	desc = "You are an abhorrent humanoid reptile, cold-blooded and ssssibilant."
	id = "lizard"
	points = -1
	category = list("species")
	mutantRace = /datum/mutantrace/lizard

/datum/trait/cow
	name = "Bovine"
	icon_state = "cowT"
	desc = "You are a hummman, always have been, always will be, and any claimmms to the contrary are mmmoooonstrous lies."
	id = "cow"
	points = -1
	category = list("species", "hemophilia")
	mutantRace = /datum/mutantrace/cow

/datum/trait/skeleton
	name = "Skeleton"
	icon_state = "skeletonT"
	desc = "Compress all of your skin and flesh into your bones, making you resemble a skeleton. Not as uncomfortable as it sounds."
	id = "skeleton"
	points = -1
	category = list("species", "cloner_stuff")
	mutantRace = /datum/mutantrace/skeleton

/datum/trait/roach
	name = "Roach"
	icon_state = "roachT"
	desc = "One space-morning, on the shuttle-ride to the station, you found yourself transformed in your seat into a horrible vermin. A cockroach, specifically."
	id = "roach"
	points = -1
	category = list("species")
	mutantRace = /datum/mutantrace/roach

/datum/trait/pug
	name = "Pug"
	icon_state = "pug"
	desc = "Should a pug really be on a space station? They aren't suited for space at all. They're practically a liability to the compan... Aw, look at those little ears!"
	id = "pug"
	points = -4 //Subject to change- -3 feels too low as puritan is relatively common. Though Puritan Pug DOES make for a special sort of Hard Modes
	category = list("species", "nopug")
	mutantRace = /datum/mutantrace/pug

/datum/trait/super_slips
	name = "Slipping Hazard"
	id = "super_slips"
	desc = "You never were good at managing yourself slipping."
	points = 1

//Infernal Contract Traits
/datum/trait/hair
	name = "Wickedly Good Hair"
	desc = "Sold your soul for the best hair around"
	id = "contract_hair"
	points = 0
	unselectable = TRUE

	onAdd(var/mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			omega_hairgrownium_grow_hair(H, 1)
		return

	onLife(var/mob/owner) //Just to be safe.
		if(ishuman(owner) && prob(35))
			var/mob/living/carbon/human/H = owner
			omega_hairgrownium_grow_hair(H, 1)

/datum/trait/contractlimbs
	name = "Wacky Waving Limbs"
	desc = "Sold your soul for ever shifting limbs"
	id = "contract_limbs"
	points = 0
	unselectable = TRUE

	onAdd(var/mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			randomize_mob_limbs(H)
		return

	onLife(var/mob/owner) //Just to be safe.
		if(ishuman(owner) && prob(10))
			var/mob/living/carbon/human/H = owner
			randomize_mob_limbs(H)
