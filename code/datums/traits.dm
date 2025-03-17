//Unlockable traits? tied to achievements?

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
		"nohair",
		"nowig",
		"infrared",
	)

	var/list/traitData = list()
	var/traitDataDirty = TRUE

	proc/selectTrait(var/id, var/list/parts_selected = null)
		var/list/future_selected = traits_selected.Copy()
		if (id in traitList)
			future_selected |= id

		if (!isValid(future_selected, parts_selected))
			return FALSE

		traits_selected = future_selected
		traitDataDirty = TRUE
		updateTotal()
		return TRUE

	proc/unselectTrait(var/id, var/list/parts_selected = null)
		var/list/future_selected = traits_selected.Copy()
		future_selected -= id

		if (!isValid(future_selected, parts_selected))
			return FALSE

		traits_selected = future_selected
		traitDataDirty = TRUE
		updateTotal()
		return TRUE

	proc/resetTraits()
		traitDataDirty = TRUE
		traits_selected = list()
		updateTotal()

	proc/calcTotal(var/list/selected = traits_selected, var/list/parts_selected = null)
		. = free_points
		for(var/T in selected)
			if(T in traitList)
				var/datum/trait/O = traitList[T]
				. += O.points
		for (var/slot_id in parts_selected)
			var/part_id = parts_selected[slot_id]
			var/datum/part_customization/customization = get_part_customization(part_id)
			. -= customization.trait_cost

	proc/updateTotal()
		point_total = calcTotal()

	proc/isValid(var/list/selected = traits_selected, var/list/parts_selected = null)
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

		return (calcTotal(selected, parts_selected) >= 0)

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
					boutput(user, SPAN_ALERT("<b>WARNING: XP unlocks failed to update. Some traits may not be available. Please try again in a moment.</b>"))
					SPAWN(0)
						user.client.updateXpRewards()
					skipUnlocks = 1
					continue

			. += C

	proc/generateTraitData(mob/user)
		if(traitDataDirty)
			traitData = list()
			for (var/datum/trait/trait as anything in src.getTraits(user))
				var/selected = (trait.id in src.traits_selected)
				traitData += list(list(
					"id" = trait.id,
					"selected" = selected,
					"available" = src.isAvailableTrait(trait.id, selected)
				))
			traitDataDirty = FALSE
		return traitData

/datum/traitHolder
	var/list/traits = list()
	var/list/moveTraits = list() // differentiate movement traits for Move()
	var/mob/owner = null
	/// Role used to prevent addition of specific traits, in case of owner not (yet?) having a mind
	var/mind_role_fallback = null

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

	proc/addTrait(id, datum/trait/trait_instance=null, force_trait=FALSE)
		if(!(id in traits))
			var/datum/trait/T = null
			if(isnull(trait_instance))
				var/traitType = traitList[id].type
				T = new traitType
			else
				T = trait_instance
			if(T.afterlife_blacklisted && inafterlifebar(owner))
				return
			var/resolved_role = owner?.mind?.assigned_role || src.mind_role_fallback
			if (T.preventAddTrait(owner, resolved_role) && force_trait==FALSE)
				return
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

	proc/getTraitWithCategory(var/cat)
		for(var/id in traits)
			var/datum/trait/T = traits[id]
			for (var/heldcat in T.category)
				if (heldcat == cat)
					return T

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
	var/afterlife_blacklisted = FALSE // If TRUE, trait will not be added in the Afterlife Bar
	var/disability_type = TRAIT_DISABILITY_NONE //! Is this a major/minor/not a disability
	var/disability_name = "" //! Name of the disability for medical records
	var/disability_desc = "" //! Description of the disability for medical records
	var/spawn_delay = 0 // To avoid ugly hardcoded spawn delay

	New()
		ASSERT(src.name)
		..()

	proc/preventAddTrait(mob/owner, var/resolved_role)
		. = FALSE

	proc/onAdd(var/mob/owner)
		if(mutantRace && ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.default_mutantrace = mutantRace
			H.set_mutantrace(mutantRace)
		return

	proc/onRemove(var/mob/owner)
		if(mutantRace && ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.default_mutantrace = /datum/mutantrace/human
			H.set_mutantrace(H.default_mutantrace)
		return

	proc/onLife(var/mob/owner, var/mult)
		return

	proc/onMove(var/mob/owner)
		return

// BODY - Red Border

/datum/trait/explolimbs
	name = "Adamantium Skeleton"
	desc = "Halves the chance that an explosion will blow off your limbs."
	id = "explolimbs"
	icon_state = "adskeleton"
	category = list("body")
	points = -2

/datum/trait/deaf
	name = "Deaf"
	desc = "Spawn with permanent deafness and an auditory headset."
	id = "deaf"
	icon_state = "deaf"
	category = list("body")
	points = 1
	afterlife_blacklisted = TRUE
	disability_type = TRAIT_DISABILITY_MAJOR
	disability_name = "Deaf"
	disability_desc = "Permanent hearing loss"

	onAdd(var/mob/owner)
		if(owner.bioHolder)
			if(ishuman(owner))
				owner.bioHolder.AddEffect("deaf", 0, 0, 0, 1)

	onLife(var/mob/owner) //Just to be super safe.
		if(!owner.ear_disability)
			owner.bioHolder.AddEffect("deaf", 0, 0, 0, 1)

	onRemove(mob/owner)
		owner.bioHolder?.RemoveEffect("deaf")

/datum/trait/plasmalungs
	name = "Plasma Lungs"
	desc = "You signed up for a maintenance experiment involving someone who was definitely a scientist and your lungs are now only capable of breathing in plasma. At least they gave you a free tank to breathe from."
	id = "plasmalungs"
	icon_state = "plasmalungs"
	category = list("body")
	points = 2
	afterlife_blacklisted = TRUE
	disability_type = TRAIT_DISABILITY_MAJOR
	disability_name = "Plasma Lungs"
	disability_desc = "Only capable of breathing plasma in a gaseous state"

	onAdd(mob/living/carbon/human/owner)
		if (!istype(owner))
			return
		var/obj/item/organ/created_organ
		var/obj/item/organ/lung/left = owner?.organHolder?.left_lung
		var/obj/item/organ/lung/right = owner?.organHolder?.right_lung
		if(istype(left) && istype(right))
			created_organ = new /obj/item/organ/lung/plasmatoid/left()
			owner.organHolder.drop_organ(left.organ_holder_name)
			qdel(left)

			created_organ.donor = owner
			owner.organHolder.receive_organ(created_organ, created_organ.organ_holder_name)

			created_organ = new /obj/item/organ/lung/plasmatoid/right()
			owner.organHolder.drop_organ(right.organ_holder_name)
			qdel(right)

			created_organ.donor = owner
			owner.organHolder.receive_organ(created_organ, created_organ.organ_holder_name)

	onRemove(mob/living/carbon/human/owner)
		if (!istype(owner))
			return
		var/obj/item/organ/created_organ
		var/obj/item/organ/lung/plasmatoid/left = owner?.organHolder?.left_lung
		var/obj/item/organ/lung/plasmatoid/right = owner?.organHolder?.right_lung
		if(istype(left))
			created_organ = new /obj/item/organ/lung/left()
			owner.organHolder.drop_organ(left.organ_holder_name)
			qdel(left)

			created_organ.donor = owner
			owner.organHolder.receive_organ(created_organ, created_organ.organ_holder_name)

		if(istype(right))
			created_organ = new /obj/item/organ/lung/right()
			owner.organHolder.drop_organ(right.organ_holder_name)
			qdel(right)

			created_organ.donor = owner
			owner.organHolder.receive_organ(created_organ, created_organ.organ_holder_name)

/datum/trait/stinky
	name = "Stinky"
	desc = "Your body has exceedingly sensitive sweat glands that overproduce, causing you to become stinky unless frequently showered."
	id = "stinky"
	icon_state = "stinky"
	category = list("body")
	points = 1

	onAdd(var/mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (!H.sims)
				H.sims = new /datum/simsHolder(H)
			H.sims.addMotive(/datum/simsMotive/hygiene)
			H.sims.add_hud() // ensure hud has hygiene motive

	onRemove(var/mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (!H.sims)
				H.sims = new /datum/simsHolder(H)
			H.sims.removeMotive("Hygiene")

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

/datum/trait/german
	name = "German"
	desc = "You're from somewhere in the middle of Texas. Prost y'all."
	id = "german"
	icon_state = "german"
	points = 0
	category =  list("language")

	onAdd(var/mob/owner)
		owner.bioHolder?.AddEffect("accent_german")

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
	category = list("vision", "infrared")

/datum/trait/wasitsomethingisaid
	name = "Was It Something I Said?"
	desc = "You did something to attract their ire, and the small robots of the station hate your guts!"
	id = "wasitsomethingisaid"
	icon_state = "wasitsomethingisaid"
	points = 2

/datum/trait/shortsighted
	name = "Short-sighted"
	desc = "Spawn with permanent short-sightedness and glasses."
	id = "shortsighted"
	icon_state = "glassesG"
	category = list("vision")
	points = 1
	afterlife_blacklisted = TRUE
	disability_type = TRAIT_DISABILITY_MINOR
	disability_name = "Myopic"
	disability_desc = "Requires glasses for visual acuity"

	onAdd(var/mob/owner)
		if(owner.bioHolder)
			if(ishuman(owner))
				owner.bioHolder.AddEffect("bad_eyesight", 0, 0, 0, 1)

	onLife(var/mob/owner) //Just to be super safe.
		if(owner.bioHolder && !owner.bioHolder.HasEffect("bad_eyesight"))
			owner.bioHolder.AddEffect("bad_eyesight", 0, 0, 0, 1)

	onRemove(mob/owner)
		owner.bioHolder?.RemoveEffect("bad_eyesight")

/datum/trait/blind
	name = "Blind"
	desc = "Spawn with permanent blindness and a VISOR."
	icon_state = "blind"
	id = "blind"
	category = list("vision")
	points = 2
	afterlife_blacklisted = TRUE
	disability_type = TRAIT_DISABILITY_MAJOR
	disability_name = "Blind"
	disability_desc = "Permanent vision loss"

	onAdd(var/mob/owner)
		if(owner.bioHolder)
			if(istype(owner, /mob/living/carbon/human))
				owner.bioHolder.AddEffect("blind", 0, 0, 0, 1)

	onLife(var/mob/owner) //Just to be safe.
		if(owner.bioHolder && !owner.bioHolder.HasEffect("blind"))
			owner.bioHolder.AddEffect("blind", 0, 0, 0, 1)

	onRemove(mob/owner)
		owner.bioHolder?.RemoveEffect("blind")

// GENETICS - Blue Border

/datum/trait/mildly_mutated
	name = "Mildly Mutated"
	desc = "A random mutation in your gene pool starts activated and immune to mutadone."
	id = "mildly_mutated"
	icon_state = "mildly_mutatedB"
	points = 1
	category = list("genetics")
	afterlife_blacklisted = TRUE
	disability_type = TRAIT_DISABILITY_MINOR
	disability_name = "Genetic Deviation"
	disability_desc = "Minor reinforced alteration from baseline genetic sequence"

	preventAddTrait(mob/owner, resolved_role)
		. = ..()
		if (.)
			return
		if (resolved_role == "MODE")
			logTheThing(LOG_COMBAT, owner, "prevented from being mildly mutated from the trait [name]: not for game mode roles.")
			return TRUE

	onAdd(var/mob/owner)
		var/datum/bioHolder/B = owner.bioHolder
		var/bioEffectId = pick(B.effectPool)
		var/datum/bioEffect/E = B.effectPool[bioEffectId]
		B.ActivatePoolEffect(E, 1, 0)
		SPAWN (1 SECOND) // This DOES NOT WORK at round start unless delayed but somehow the trait part is logged??
			if (E)
				E.curable_by_mutadone = FALSE
				E.name = "Reinforced " + E.name
				E.altered = 1 //don't let them combine the reinforced gene with another one
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

/datum/trait/petperson
	name = "Pet Person"
	desc = "Start with your (possibly lovable) pet!"
	id = "petperson"
	icon_state = "petperson"
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
	icon_state = "bald"
	points = 0
	category = list("trinkets", "nopug","nowig")

/datum/trait/wheelchair
	name = "Wheelchair"
	desc = "Because of a freak accident involving a piano, a forklift, and lots of vodka, you have been placed on the disability list. Fortunately, NT has kindly supplied you with a wheelchair out of the goodness of their heart. (due to regulations)"
	id = "wheelchair"
	icon_state = "stumped"
	category = list("trinkets")
	points = 0

// Skill - White Border

/datum/trait/smoothtalker
	name = "Smooth talker"
	desc = "Traders will tolerate 50% more when you are haggling with them."
	id = "smoothtalker"
	icon_state = "sale"
	category = list("skill")
	points = -1

/datum/trait/matrixflopout
	name = "Matrix Flopout"
	desc = "Flipping lets you dodge bullets and attacks for a higher stamina cost!"
	id = "matrixflopout"
	icon_state = "matrix"
	category = list("skill")
	points = -2

/datum/trait/martyrdom
	name = "Martyrdom"
	id = "martyrdom"
	desc = "If you have a grenade in-hand, arm it on death"
	icon_state = "no"
	category = list("skill")
	points = -1

/datum/trait/happyfeet
	name = "Happyfeet"
	desc = "Sometimes people can't help but dance along with you."
	id = "happyfeet"
	icon_state = "dance"
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

	var/faith = FAITH_STARTING
	///multiplier for faith gain only - faith losses ignore this
	var/faith_mult = 1

	New()
		..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

	onAdd(mob/living/owner)
		if(owner.traitHolder?.hasTrait("atheist"))
			src.faith_mult = 0.2

/datum/trait/job/medical
	name = "Medical Training"
	desc = "Subject is a proficient surgeon."
	id = "training_medical"

/datum/trait/job/scientist
	name = "Scientist Training."
	desc = "Subject is a experienced researcher."
	id = "training_scientist"

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
	desc = "Subject is proficient at haggling."
	id = "training_quartermaster"

/datum/trait/job/chef
	name = "Kitchen Training"
	desc = "Subject is experienced in foodstuffs and their effects."
	id = "training_chef"

/datum/trait/job/bartender
	name = "Bartender Training"
	desc = "Subject has a keen mind for all things alcoholic."
	id = "training_bartender"

// bartender, detective, HoS
/datum/trait/job/drinker
	name = "Professional Drinker"
	desc = "Sometimes you drink on the job, sometimes drinking is the job."
	id = "training_drinker"

/datum/trait/job/clown
	name = "Clown Training"
	desc = "Subject is trained at being a clumsy buffoon."
	id = "training_clown"

	onAdd(var/mob/owner)
		owner.AddComponent(/datum/component/death_confetti)
		owner.bioHolder?.AddEffect("accent_comic", innate = TRUE)
		owner.bioHolder?.AddEffect("clumsy", innate = TRUE)

/datum/trait/job/mime
	name = "Mime Training"
	desc = "..."
	id = "training_mime"

	onAdd(var/mob/owner)
		owner.bioHolder?.AddEffect("mute", innate = TRUE)
		owner.bioHolder?.AddEffect("blankman", innate = TRUE)

/datum/trait/job/miner
	name = "Miner Training"
	desc = "Subject is trained at carving out asteroids."
	id = "training_miner"

// Stats - Undetermined Border
/datum/trait/athletic
	name = "Athletic"
	desc = "Great stamina! Frail body."
	id = "athletic"
	icon_state = "athletic"
	category = list("stats")
	points = -2

	onAdd(var/mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.add_stam_mod_max("trait", STAMINA_MAX * 0.1)
			APPLY_ATOM_PROPERTY(H, PROP_MOB_STAMINA_REGEN_BONUS, "trait", STAMINA_REGEN * 0.1)

	onRemove(mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.remove_stam_mod_max("trait", STAMINA_MAX * 0.1)
			REMOVE_ATOM_PROPERTY(H, PROP_MOB_STAMINA_REGEN_BONUS, "trait")

/datum/trait/bigbruiser
	name = "Big Bruiser"
	desc = "Stronger punches but higher stamina cost!"
	id = "bigbruiser"
	icon_state = "bruiser"
	category = list("stats")
	points = -2

/datum/trait/slowstrider
	name = "Slow Strider"
	desc = "What's the rush? You can't sprint anymore."
	id = "slowstrider"
	icon_state = "slow"
	category = list("stats")
	points = 2
	afterlife_blacklisted = TRUE

	onAdd(var/mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			APPLY_ATOM_PROPERTY(H, PROP_MOB_CANTSPRINT, "trait")

	onRemove(mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			REMOVE_ATOM_PROPERTY(H, PROP_MOB_CANTSPRINT, "trait")

//Category: Background.

/datum/trait/stowaway
	name = "Stowaway"
	desc = "You spawn hidden away on-station without an ID, PDA, or entry in NT records."
	id = "stowaway"
	icon_state = "stowaway"
	category = list("background")
	points = 0
	unselectable = TRUE

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
	icon_state = "sleepy"
	category = list("background")
	points = 0
	spawn_delay = 10 SECONDS

TYPEINFO(/datum/trait/partyanimal)
	var/list/allowed_items = list(
		/obj/item/clothing/head/party/random,
		/obj/item/balloon_animal/random,
		/obj/item/reagent_containers/balloon,
		/obj/item/reagent_containers/food/drinks/bottle,
		/obj/item/clothing/head/party/birthday,
		/obj/random_item_spawner/hat/one,
		/obj/random_item_spawner/snacks/one,
		/obj/random_item_spawner/junk/one,
		/obj/random_item_spawner/mask/one,
		/obj/random_item_spawner/pizza/one,
		/obj/random_item_spawner/cola/one
	)
	var/list/allowed_debris = list(
		/obj/decal/cleanable/balloon,
		/obj/decal/cleanable/vomit,
		/obj/decal/cleanable/paper,
		/obj/decal/cleanable/eggsplat,
		/obj/decal/cleanable/generic
	)
	var/num_bar_turfs = null
	var/clutter_count = 0
/datum/trait/partyanimal
	name = "Party Animal"
	desc = "You don't remember much about last night, but you know you had a good time."
	id = "partyanimal"
	icon_state = "partyanimal"
	category = list("background")
	points = 0
	spawn_delay = 3 SECONDS

// NO CATEGORY - Grey Border

/datum/trait/hemo
	name = "Hemophilia"
	desc = "You bleed more easily and you bleed more."
	id = "hemophilia"
	icon_state = "hemophilia"
	points = 1
	category = list("hemophilia")
	disability_type = TRAIT_DISABILITY_MINOR
	disability_name = "Hemophilia"
	disability_desc = "Prone to blood loss"

/datum/trait/weakorgans
	name = "Frail Constitution"
	desc = "Your internal organs (brain included) are extremely vulnerable to damage."
	id = "weakorgans"
	icon_state = "frailc"
	points = 2
	disability_type = TRAIT_DISABILITY_MINOR
	disability_name = "Organ Sensitivity"
	disability_desc = "Organs prone to damage"

/datum/trait/slowmetabolism
	name = "Slow Metabolism"
	desc = "Any chemicals in you body deplete much more slowly."
	id = "slowmetabolism"
	icon_state = "slowm"
	points = 0

/datum/trait/alcoholic
	name = "Career alcoholic"
	desc = "You gain alcohol resistance but your speech is permanently slurred."
	id = "alcoholic"
	icon_state = "beer"
	points = 0

	onAdd(var/mob/owner)
		owner.bioHolder?.AddEffect("resist_alcohol", 0, 0, 0, 1)

	onRemove(mob/owner)
		owner.bioHolder?.RemoveEffect("resist_alcohol")


/datum/trait/random_allergy
	name = "Allergy"
	desc = "You're allergic to... something. You can't quite remember, but how bad could it possibly be?"
	id = "randomallergy"
	icon_state = "allergy"
	points = 0
	afterlife_blacklisted = TRUE

	var/allergen = null

	var/list/allergen_id_list = list("spaceacillin","morphine","teporone","salicylic_acid","calomel","synthflesh","omnizine","saline","anti_rad","smelling_salt",\
	"haloperidol","epinephrine","insulin","silver_sulfadiazine","mutadone","ephedrine","penteticacid","antihistamine","styptic_powder","cryoxadone","atropine",\
	"salbutamol","perfluorodecalin","mannitol","charcoal","antihol","ethanol","iron","mercury","oxygen","plasma","sugar","radium","water","bathsalts","crank",\
	"LSD","space_drugs","THC","nicotine","krokodil","catdrugs","triplemeth","methamphetamine","mutagen","neurotoxin","saxitoxin","smokepowder","infernite","phlogiston","fuel",\
	"anti_fart","lube","ectoplasm","cryostylane","oil","sewage","ants","spiders","poo","love","hugs","fartonium","blood","bloodc","vomit","capsaicin","cheese",\
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
	icon_state = "medallergy"
	points = 1
	afterlife_blacklisted = TRUE

	allergen_id_list = list("spaceacillin","morphine","teporone","salicylic_acid","calomel","synthflesh","omnizine","saline","anti_rad","smelling_salt",\
	"haloperidol","epinephrine","insulin","silver_sulfadiazine","mutadone","ephedrine","penteticacid","antihistamine","styptic_powder","cryoxadone","atropine",\
	"salbutamol","perfluorodecalin","mannitol","charcoal","antihol")

/datum/trait/addict
	name = "Addict"
	desc = "You spawn with a random addiction. Once cured there is a small chance that you will suffer a relapse."
	id = "addict"
	icon_state = "addict"
	points = 2
	afterlife_blacklisted = TRUE
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

	proc/addAddiction(var/mob/living/owner)
		var/datum/ailment_data/addiction/AD = get_disease_from_path(/datum/ailment/addiction).setup_strain()
		AD.associated_reagent = selected_reagent
		AD.last_reagent_dose = world.timeofday
		AD.name = "[selected_reagent] addiction"
		AD.affected_mob = owner
		owner.contract_disease(/datum/ailment/addiction, null, AD, TRUE)

	onRemove(mob/owner)
		for(var/datum/ailment_data/addiction/AD in owner.ailments)
			if(AD.associated_reagent == selected_reagent)
				owner.ailments -= AD

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
		src.RegisterSignal(owner, COMSIG_MOB_LOGIN, PROC_REF(turnOn))
		src.RegisterSignal(owner, COMSIG_MOB_LOGOUT, PROC_REF(turnOff))
		src.RegisterSignal(owner, COMSIG_ATOM_EXAMINE, PROC_REF(examined))

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
	icon_state = "chemresist"
	points = -2

/datum/trait/puritan
	name = "Puritan"
	desc = "You can not be cloned or revived except by cyborgification. Any attempt will end badly."
	id = "puritan"
	icon_state = "puritan"
	points = 2
	category = list("cloner_stuff")
	disability_type = TRAIT_DISABILITY_MAJOR
	disability_name = "Clone Instability"
	disability_desc = "Genetic structure incompatible with cloning"

/datum/trait/survivalist
	name = "Survivalist"
	desc = "Food will heal you even if you are badly injured."
	id = "survivalist"
	icon_state = "survivalist"
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

/datum/trait/spontaneous_combustion
	name = "Spontaneous Combustion"
	desc = "You very, VERY rarely spontaneously light on fire."
	id = "spontaneous_combustion"
	icon_state = "onfire"
	points = 0

	onLife(mob/owner, mult)
		. = ..()
		if(probmult(0.01))
			owner.setStatus("burning", 100 SECONDS, 60 SECONDS)
			playsound(owner.loc, 'sound/effects/mag_fireballlaunch.ogg', 50, 0)
			logTheThing(LOG_COMBAT, owner, "gets set on fire by their spontaneous combustion trait")
			owner.visible_message(SPAN_ALERT("<b>[owner.name]</b> suddenly bursts into flames!"))

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
	icon_state = "klepto"
	points = 1
	afterlife_blacklisted = TRUE

	onLife(var/mob/owner, var/mult)
		if(!owner.stat && !owner.lying && can_act(owner) && !owner.equipped() && probmult(6))
			if(istype(owner, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = owner
				if (H.hand == LEFT_HAND)
					if (H.limbs?.l_arm && !H.limbs.l_arm.can_hold_items)
						return
				else
					if (H.limbs?.r_arm && !H.limbs.r_arm.can_hold_items)
						return
			for(var/obj/item/I in oview(1, owner))
				if(!I.anchored && !I.cant_drop && isturf(I.loc) && can_reach(owner, I) && !HAS_ATOM_PROPERTY(I, PROP_MOVABLE_KLEPTO_IGNORE))
					I.Attackhand(owner)
					owner.emote(pick("grin", "smirk", "chuckle", "smug"))
					break

/datum/trait/clutz
	name = "Clutz"
	desc = "When interacting with anything you have a chance to interact with something different instead."
	id = "clutz"
	icon_state = "clutz"
	points = 2
	afterlife_blacklisted = TRUE

/datum/trait/leftfeet
	name = "Two left feet"
	desc = "Every now and then you'll stumble in a random direction."
	id = "leftfeet"
	icon_state = "twoleft"
	points = 1
	afterlife_blacklisted = TRUE

/datum/trait/trippy
	name = "Trippy"
	desc = "You have a tendency to randomly trip while moving."
	id = "trippy"
	icon_state = "trip"
	points = 1
	afterlife_blacklisted = TRUE

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
	icon_state = "hypeallergy"
	points = 1
	disability_type = TRAIT_DISABILITY_MINOR
	disability_name = "Anaphylactic"
	disability_desc = "Acute response to allergens"

/datum/trait/allears
	name="All ears"
	desc = "You lost your headset on the way to work."
	id = "allears"
	icon_state = "allears"
	points = 0

/datum/trait/atheist
	name = "Atheist"
	desc = "In this moment, you are euphoric. You cannot receive faith healing, and prayer makes you feel silly."
	id = "atheist"
	icon_state = "atheist"
	points = 0

	onAdd(mob/living/owner)
		if (istype(owner))
			owner.remove_lifeprocess(/datum/lifeprocess/faith)
		var/datum/trait/job/chaplain/chap_trait = owner.traitHolder?.getTrait("training_chaplain")
		chap_trait?.faith_mult = 0.2

	onRemove(mob/living/owner)
		if (istype(owner))
			owner.add_lifeprocess(/datum/lifeprocess/faith)
		var/datum/trait/job/chaplain/chap_trait = owner.traitHolder?.getTrait("training_chaplain")
		chap_trait?.faith_mult = 1


/datum/trait/lizard
	name = "Reptilian"
	icon_state = "lizardT"
	desc = "You are an abhorrent humanoid reptile, cold-blooded and ssssibilant."
	id = "lizard"
	points = -1
	category = list("species", "infrared")
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
	category = list("species", "cloner_stuff", "nohair")
	mutantRace = /datum/mutantrace/skeleton

/datum/trait/roach
	name = "Roach"
	icon_state = "roachT"
	desc = "One space-morning, on the shuttle-ride to the station, you found yourself transformed in your seat into a horrible vermin. A cockroach, specifically."
	id = "roach"
	points = -1
	category = list("species", "infrared")
	mutantRace = /datum/mutantrace/roach

/datum/trait/pug
	name = "Pug"
	icon_state = "pug"
	desc = "Should a pug really be on a space station? They aren't suited for space at all. They're practically a liability to the compan... Aw, look at those little ears!"
	id = "pug"
	points = -4 //Subject to change- -3 feels too low as puritan is relatively common. Though Puritan Pug DOES make for a special sort of Hard Modes
	category = list("species", "nopug", "nohair")
	mutantRace = /datum/mutantrace/pug

/datum/trait/random_species
	name = "Random Species"
	icon_state = "randomspecies"
	desc = "You feel like something's different today, but you can't quite put your finger/tail/hoof/antennae on it."
	id = "random_species"
	points = -1
	category = list("species", "infrared", "cloner_stuff", "nohair", "hemophilia")

	onAdd(mob/owner)
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			var/list/datum/mutantrace/default_species = list(
						/datum/mutantrace/lizard,
						/datum/mutantrace/cow,
						/datum/mutantrace/skeleton,
						/datum/mutantrace/roach,
					)
			var/datum/mutantrace/new_mutantrace_type = null
			if (prob(1) && prob(1)) // 0.01% chance of a non-dna mutagen banned mutrace that *isn't* a -1 point mutrace
				var/max_iterations = 50 // safety
				var/iteration = 0
				while ( \
					isnull(new_mutantrace_type) || \
					initial(new_mutantrace_type:dna_mutagen_banned) || \
					(new_mutantrace_type in default_species) || \
					(iteration < max_iterations) \
				)
					iteration += 1
					new_mutantrace_type = pick(concrete_typesof(/datum/mutantrace))
			else // otherwise, pick any -1 point mutrace
				new_mutantrace_type = pick(default_species)
			if (isnull(new_mutantrace_type))
				new_mutantrace_type = /datum/mutantrace/human
			H.default_mutantrace = new_mutantrace_type
			H.set_mutantrace(H.default_mutantrace)

	onRemove(mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.default_mutantrace = /datum/mutantrace/human
			H.set_mutantrace(H.default_mutantrace)

/datum/trait/super_slips
	name = "Slipping Hazard"
	id = "super_slips"
	icon_state = "slip"
	desc = "You never were good at managing yourself slipping."
	points = 1

/datum/trait/picky_eater
	name = "Picky eater"
	icon_state = "foodstuff"
	id = "picky_eater"
	desc = "Your refined palate only tolerates a handful of foods."
	points = 0
	var/list/fav_foods = list()
	var/explanation_text = null

	onAdd(var/mob/owner)
		if (length(fav_foods) <= 0 && ishuman(owner))
			var/mob/living/carbon/human/H = owner
			var/choices[5]
			var/list/names[5]
			var/i = 0
			var/max_rolls = 30
			var/current_rolls = 0
			while (i < 5)
				i++
				choices[i] = pick(allowed_favorite_ingredients)
				var/choiceType = choices[i]
				var/obj/item/reagent_containers/food/snacks/instance =  new choiceType
				if(instance.custom_food)
					fav_foods += choiceType
					names[i] = instance.name
				else
					i--
				current_rolls++
				if (current_rolls > max_rolls)
					stack_trace("Failed to generate a foodlist for picky eater [H]. Aborting.")
					return
			explanation_text = "<b>Your favorite foods are : </b>"
			for (var/ingredient in names)
				if (ingredient != names[5])
					explanation_text += "[ingredient], "
				else
					explanation_text += "and [ingredient]<br/>"

/datum/trait/mutant_hair
	name = "Hairy"
	desc = "You will grow hair even if you usually would not (due to being a lizard or something)."
	id = "mutant_hair"
	points = 0
	category = list("body", "nohair","nowig")
	icon_state = "hair"

	onAdd(mob/owner)
		owner.bioHolder.AddEffect("hair_growth", innate = TRUE)

	onRemove(mob/owner)
		owner.bioHolder.RemoveEffect("hair_growth")

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
