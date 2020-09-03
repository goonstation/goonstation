//Unlockable traits? tied to achievements?
#define TRAIT_STARTING_POINTS 1 //How many "free" points you get
#define TRAIT_MAX 6			    //How many traits people can select at most.

/proc/getTraitById(var/id)
	return traitList[id]

/proc/traitCategoryAllowed(var/list/targetList, var/idToCheck)
	var/obj/trait/C = getTraitById(idToCheck)
	if(C.category == null) return 1
	for(var/A in targetList)
		var/obj/trait/T = getTraitById(A)
		if(T.category == C.category) return 0
	return 1

/datum/traitPreferences
	var/list/traits_selected = list()

	var/point_total = TRAIT_STARTING_POINTS
	var/free_points = TRAIT_STARTING_POINTS

	proc/selectTrait(var/id)
		if(!traits_selected.Find(id) && traitList.Find(id))
			traits_selected.Add(id)
		calcTotal()
		return 1

	proc/unselectTrait(var/id)
		if(traits_selected.Find(id))
			traits_selected.Remove(id)
		calcTotal()
		return 1

	proc/calcTotal()
		var/sum = free_points
		for(var/T in traits_selected)
			if(traitList.Find(T))
				var/obj/trait/O = traitList[T]
				sum += O.points
		point_total = sum
		return sum

	proc/isValid()
		var/list/categories = list()
		for(var/A in traits_selected)
			var/obj/trait/T = getTraitById(A)
			if(T.unselectable) return 0
			//if(T.requiredUnlock != null && usr.client)  //This will likely fail since the unlocks will not have loaded by the time the trait preferences are created. getscores is too slow.
			//	if(usr.client.qualifiedXpRewards != null)
			//		if(!usr.client.qualifiedXpRewards.Find(T.requiredUnlock))
			//			return 0
			if(T.category != null)
				if(categories.Find(T.category)) return 0
				else categories.Add(T.category)
		return (calcTotal() >= 0)

	proc/updateTraits(var/mob/user)

		// Not passed a user, try to gracefully recover.
		if (!user)
			user = usr
			if (!user)
				return

		if(!winexists(user, "traitssetup_[user.ckey]"))
			winclone(user, "traitssetup", "traitssetup_[user.ckey]")

		var/list/selected = list()
		var/list/available = list()

		var/skipUnlocks = 0
		for(var/X in traitList)
			var/obj/trait/C = getTraitById(X)
			if(C.unselectable) continue
			if(C.requiredUnlock != null && skipUnlocks) continue
			if(C.requiredUnlock != null && user.client) //If this needs an xp unlock, check against the pre-generated list of related xp unlocks for this person.
				if(user.client.qualifiedXpRewards != null)
					if(!user.client.qualifiedXpRewards.Find(C.requiredUnlock))
						continue
				else
					boutput(user, "<span class='alert'><b>WARNING: XP unlocks failed to update. Some traits may not be available. Please try again in a moment.</b></span>")
					SPAWN_DBG(0) user.client.updateXpRewards()
					skipUnlocks = 1
					continue

			if(traits_selected.Find(X)) selected += X
			else available += X

		winset(user, "traitssetup_[user.ckey].traitsSelected", "cells=\"1x[selected.len]\"")
		var/countSel = 0
		for(var/S in selected)
			winset(user, "traitssetup_[user.ckey].traitsSelected", "current-cell=1,[++countSel]")
			user << output(traitList[S], "traitssetup_[user.ckey].traitsSelected")

		winset(user, "traitssetup_[user.ckey].traitsAvailable", "cells=\"1x[available.len]\"")
		var/countAvail = 0
		for(var/A in available)
			winset(user, "traitssetup_[user.ckey].traitsAvailable", "current-cell=1,[++countAvail]")
			user << output(traitList[A], "traitssetup_[user.ckey].traitsAvailable")

		winset(user, "traitssetup_[user.ckey].traitPoints", "text=\"Points left : [calcTotal()]\"&text-color=\"[calcTotal() > 0 ? "#00AA00" : "#AA0000"]\"")
		return

	proc/showTraits(var/mob/user)
		if(!winexists(user, "traitssetup_[user.ckey]"))
			winclone(user, "traitssetup", "traitssetup_[user.ckey]")

		winshow(user, "traitssetup_[user.ckey]")
		updateTraits(user)

		user.Browse(null, "window=preferences")
		return


/datum/traitHolder
	var/list/traits = list()
	var/list/moveTraits = list() // differentiate movement traits for Move()
	var/mob/owner = null

	New(var/mob/ownerMob)
		owner = ownerMob
		return ..()

	proc/addTrait(id)
		if(!traits.Find(id) && owner)
			traits.Add(id)
			var/obj/trait/T = traitList[id]
			if(T.isMoveTrait)
				moveTraits.Add(id)
			T.onAdd(owner)
		return

	proc/removeTrait(id)
		if(traits.Find(id) && owner)
			traits.Remove(id)
			var/obj/trait/T = traitList[id]
			if(T.isMoveTrait)
				moveTraits.Remove(id)
			T.onRemove(owner)
		return

	proc/removeAll()
		for (var/obj/trait/T in traits)
			traits.Remove(T.id)
			if(T.isMoveTrait)
				moveTraits.Remove(T.id)
			T.onRemove(owner)

	proc/hasTrait(var/id)
		return traits.Find(id)

//Yes these are objs because grid control. Shut up. I don't like it either.
/obj/trait
	icon = 'icons/ui/traits.dmi'
	icon_state = "placeholder"
	var/id = ""        //Unique ID
	var/points = 0	   //The change in points when this is selected.
	var/isPositive = 1 //Is this a positive, good effect or a bad one.
	var/category = null //If set to a non-null string, People will only be able to pick one trait of any given category
	var/unselectable = 0 //If 1 , trait can not be select at char setup
	var/requiredUnlock = null //If set to a string, the xp unlock of that name is required for this to be selectable.
	var/cleanName = ""   //Name without any additional information.
	var/isMoveTrait = 0 // If 1, onMove will be called each movement step from the holder's mob

	proc/onAdd(var/mob/owner)
		return

	proc/onRemove(var/mob/owner)
		return

	proc/onLife(var/mob/owner)
		return

	proc/onMove(var/mob/owner)
		return

	Click(location,control,params)
		if(!usr)
			return
		if(control)
			if(control == "traitssetup_[usr.ckey].traitsAvailable")
				if(!usr.client.preferences.traitPreferences.traits_selected.Find(id))
					if(traitCategoryAllowed(usr.client.preferences.traitPreferences.traits_selected, id))
						if(usr.client.preferences.traitPreferences.traits_selected.len >= TRAIT_MAX)
							alert(usr, "You can not select more than [TRAIT_MAX] traits.")
						else
							if(((usr.client.preferences.traitPreferences.calcTotal()) + points) < 0)
								alert(usr, "You do not have enough points available to select this trait.")
							else
								usr.client.preferences.traitPreferences.selectTrait(id)
					else
						alert(usr, "You can only select one trait of this category.")
			else if (control == "traitssetup_[usr.ckey].traitsSelected")
				if(usr.client.preferences.traitPreferences.traits_selected.Find(id))
					if(((usr.client.preferences.traitPreferences.calcTotal()) - points) < 0)
						alert(usr, "Removing this trait would leave you with less than 0 points. Please remove a different trait.")
					else
						usr.client.preferences.traitPreferences.unselectTrait(id)

			usr.client.preferences.traitPreferences.updateTraits(usr)
		return

	MouseEntered(location,control,params)
		if(winexists(usr, "traitssetup_[usr.ckey]"))
			winset(usr, "traitssetup_[usr.ckey].traitName", "text=\"[name]\"")
			winset(usr, "traitssetup_[usr.ckey].traitDesc", "text=\"[desc]\"")
		return

// BODY - Red Border

/obj/trait/roboarms
	name = "Robotic arms (0) \[Body\]"
	cleanName = "Robotic arms"
	desc = "Your arms have been replaced with light robotic arms."
	id = "roboarms"
	icon_state = "robotarmsR"
	points = 0
	isPositive = 1
	category = "body"

	onAdd(var/mob/owner)
		SPAWN_DBG(4 SECONDS) //Fuck this. Fuck the way limbs are added with a delay. FUCK IT
			if(ishuman(owner))
				var/mob/living/carbon/human/H = owner
				if(H.limbs != null)
					H.limbs.replace_with("l_arm", /obj/item/parts/robot_parts/arm/left/light, null , 0)
					H.limbs.replace_with("r_arm", /obj/item/parts/robot_parts/arm/right/light, null , 0)
					H.limbs.l_arm.holder = H
					H.limbs.r_arm.holder = H
					H.update_body()
		return

/obj/trait/syntharms
	name = "Green Fingers (-2) \[Body\]"
	cleanName = "Green Fingers"
	desc = "Excess exposure to radiation, mutagen and gardening have turned your arms into plants. The horror!"
	id = "syntharms"
	icon_state = "robotarmsR"
	points = -2
	isPositive = 0
	category = "body"

	onAdd(var/mob/owner)
		SPAWN_DBG(4 SECONDS)
			if(ishuman(owner))
				var/mob/living/carbon/human/H = owner
				if(H.limbs != null)
					H.limbs.replace_with("l_arm", pick(/obj/item/parts/human_parts/arm/left/synth/bloom, /obj/item/parts/human_parts/arm/left/synth), null , 0)
					H.limbs.replace_with("r_arm", pick(/obj/item/parts/human_parts/arm/right/synth/bloom, /obj/item/parts/human_parts/arm/right/synth), null , 0)
					H.limbs.l_arm.holder = H
					H.limbs.r_arm.holder = H
					H.update_body()
		return

/obj/trait/explolimbs
	name = "Adamantium Skeleton (-2) \[Body\]"
	cleanName = "Adamantium Skeleton"
	desc = "Halves the chance that an explosion will blow off your limbs."
	id = "explolimbs"
	category = "body"
	points = -2
	isPositive = 1

/obj/trait/deaf
	name = "Deaf (+1) \[Body\]"
	cleanName = "Deaf"
	desc = "Spawn with permanent deafness and an auditory headset."
	id = "deaf"
	category = "body"
	points = 1
	isPositive = 0

	onAdd(var/mob/owner)
		if(owner.bioHolder)
			if(ishuman(owner))
				var/mob/living/carbon/human/H = owner
				owner.bioHolder.AddEffect("deaf", 0, 0, 0, 1)
				H.equip_new_if_possible(/obj/item/device/radio/headset/deaf, H.slot_ears)
		return

	onLife(var/mob/owner) //Just to be super safe.
		if(!owner.ear_disability)
			owner.bioHolder.AddEffect("deaf", 0, 0, 0, 1)
		return

// LANGUAGE - Yellow Border

/obj/trait/swedish
	name = "Swedish (0) \[Language\]"
	cleanName = "Swedish"
	desc = "You are from sweden. Meat balls and so on."
	id = "swedish"
	icon_state = "swedenY"
	points = 0
	isPositive = 1
	category = "language"

	onAdd(var/mob/owner)
		if(owner.bioHolder)
			owner.bioHolder.AddEffect("accent_swedish", 0, 0, 0, 1)
		return

/obj/trait/french
	name = "French (0) \[Language\]"
	cleanName = "French"
	desc = "You are from Quebec. y'know, the other Canada."
	id = "french"
	icon_state = "frY"
	points = 0
	isPositive = 1
	category = "language"

	onAdd(var/mob/owner)
		if(owner.bioHolder)
			owner.bioHolder.AddEffect("accent_french", 0, 0, 0, 1)
		return

/obj/trait/scots
	name = "Scots (0) \[Language\]"
	cleanName = "Scottish"
	desc = "Hear the pipes are calling, down thro' the glen. Och aye!"
	id = "scottish"
	points = 0
	isPositive = 1
	category = "language"

	onAdd(var/mob/owner)
		if(owner.bioHolder)
			owner.bioHolder.AddEffect("accent_scots", 0, 0, 0, 1)
		return

/obj/trait/chav
	name = "Chav (0) \[Language\]"
	cleanName = "Chav"
	desc = "U wot m8? I sware i'll fite u."
	id = "chav"
	icon_state = "ukY"
	points = 0
	isPositive = 1
	category = "language"

	onAdd(var/mob/owner)
		if(owner.bioHolder)
			owner.bioHolder.AddEffect("accent_chav", 0, 0, 0, 1)
		return

/obj/trait/elvis
	name = "Funky Accent (0) \[Language\]"
	cleanName = "Funky Accent"
	desc = "Give a man a banana and he will clown for a day. Teach a man to clown and he will live in a cold dark corner of a space station for the rest of his days. - Elvis, probably."
	id = "elvis"
	points = 0
	isPositive = 1
	category = "language"

	onAdd(var/mob/owner)
		if(owner.bioHolder)
			owner.bioHolder.AddEffect("accent_elvis", 0, 0, 0, 1)
		return

/obj/trait/tommy // please do not re-enable this without talking to spy tia
	name = "New Jersey Accent (0) \[Language\]"
	cleanName = "New Jersey Accent"
	desc = "Ha ha ha. What a story, Mark."
	id = "tommy"
	icon_state = "whatY"
	points = 0
//	isPositive = 1
	category = "language"
	unselectable = 1 // this was not supposed to be a common thing!!
/*
	onAdd(var/mob/owner)
		if(owner.bioHolder)
			owner.bioHolder.AddEffect("accent_tommy")
		return
*/

/obj/trait/finnish
	name = "Finnish Accent (0) \[Language\]"
	cleanName = "Finnish Accent"
	desc = "...and you thought space didn't have Finns?"
	id = "finnish"
	icon_state = "finnish"
	points = 0
	isPositive = 1
	category = "language"

	onAdd(var/mob/owner)
		if(owner.bioHolder)
			owner.bioHolder.AddEffect("accent_finnish", 0, 0, 0, 1)
		return

/obj/trait/tyke
	name = "Tyke (0) \[Language\]"
	cleanName = "Tyke"
	desc = "You're from Oop North in Yorkshire, and don't let anyone forget it!"
	id = "tyke"
	icon_state = "yorkshire"
	points = 0
	isPositive = 1
	category = "language"

	onAdd(var/mob/owner)
		if(owner.bioHolder)
			owner.bioHolder.AddEffect("accent_tyke")
		return

// VISION/SENSES - Green Border

/obj/trait/cateyes
	name = "Cat eyes (-1) \[Vision\]"
	cleanName = "Cat eyes"
	desc = "You can see 2 tiles further in the dark."
	id = "cateyes"
	icon_state = "catseyeG"
	points = -1
	isPositive = 1
	category = "vision"

/obj/trait/infravision
	name = "Infravision (-1) \[Vision\]"
	cleanName = "Infravision"
	desc = "You can always see messages written in infra-red ink."
	id = "infravision"
	icon_state = "infravisionG"
	points = -1
	isPositive = 0
	category = "vision"

/obj/trait/shortsighted
	name = "Short-sighted (+1) \[Vision\]"
	cleanName = "Short-sighted"
	desc = "Spawn with permanent short-sightedness and glasses."
	id = "shortsighted"
	icon_state = "glassesG"
	category = "vision"
	points = 1
	isPositive = 0

	onAdd(var/mob/owner)
		if(owner.bioHolder)
			if(ishuman(owner))
				var/mob/living/carbon/human/H = owner
				owner.bioHolder.AddEffect("bad_eyesight", 0, 0, 0, 1)
				H.equip_if_possible(new /obj/item/clothing/glasses/regular(H), H.slot_glasses)
		return

	onLife(var/mob/owner) //Just to be super safe.
		if(owner.bioHolder && !owner.bioHolder.HasEffect("bad_eyesight"))
			owner.bioHolder.AddEffect("bad_eyesight", 0, 0, 0, 1)
		return

/obj/trait/blind
	name = "Blind (+2)"
	cleanName = "Blind"
	desc = "Spawn with permanent blindness and a VISOR."
	id = "blind"
	category = "vision"
	points = 2
	isPositive = 0

	onAdd(var/mob/owner)
		if(owner.bioHolder)
			if(istype(owner, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = owner
				owner.bioHolder.AddEffect("blind", 0, 0, 0, 1)
				H.equip_if_possible(new /obj/item/clothing/glasses/visor(H), H.slot_glasses)
		return

	onLife(var/mob/owner) //Just to be safe.
		if(owner.bioHolder && !owner.bioHolder.HasEffect("blind"))
			owner.bioHolder.AddEffect("blind", 0, 0, 0, 1)
		return

// GENETICS - Blue Border

/obj/trait/robustgenetics
	name = "Robust Genetics (-2) \[Genetics\]"
	cleanName = "Robust Genetics"
	desc = "You gain an additional 20 genetic stability."
	id = "robustgenetics"
	icon_state = "stablegenesB"
	points = -2
	isPositive = 0
	category = "genetics"

	onAdd(var/mob/owner)
		if(owner.bioHolder)
			owner.bioHolder.genetic_stability = 120
		return

/obj/trait/stablegenes
	name = "Stable Genes (-2) \[Genetics\]"
	cleanName = "Stable Genes"
	desc = "You are less likely to mutate from radiation or mutagens."
	id = "stablegenes"
	icon_state = "dontmutateB"
	points = -2
	isPositive = 0
	category = "genetics"

// TRINKETS/ITEMS - Purple Border

/obj/trait/loyalist
	name = "NT loyalist (-1) \[Trinkets\]"
	cleanName = "NT loyalist"
	desc = "Start with a Nanotrasen Beret as your trinket."
	id = "loyalist"
	icon_state = "beretP"
	points = -1
	isPositive = 1
	category = "trinkets"

/obj/trait/petasusaphilic
	name = "Petasusaphilic (-1) \[Trinkets\]"
	cleanName = "Petasusaphilic"
	desc = "Start with a random hat as your trinket."
	id = "petasusaphilic"
	icon_state = "hatP"
	points = -1
	isPositive = 1
	category = "trinkets"

/obj/trait/conspiracytheorist
	name = "Conspiracy Theorist (-1) \[Trinkets\]"
	cleanName = "Conspiracy Theorist"
	desc = "Start with a tin foil hat as your trinket."
	id = "conspiracytheorist"
	icon_state = "conspP"
	points = -1
	isPositive = 1
	category = "trinkets"

/obj/trait/pawnstar
	name = "Pawn Star (-1) \[Trinkets\]"
	cleanName = "Pawn Star"
	desc = "You sold your trinket before you departed for the station. You start with a bonus of 25% of your starting cash in your inventory."
	id = "pawnstar"
	icon_state = "pawnP"
	points = -1
	isPositive = 1
	category = "trinkets"

/obj/trait/beestfriend
	name = "BEEst friend (-1) \[Trinkets\]"
	cleanName = "BEEst friend"
	desc = "Start with a bee egg as your trinket."
	id = "beestfriend"
	points = -1
	isPositive = 1
	category = "trinkets"

/obj/trait/lunchbox
	name = "Lunchbox (-1) \[Trinkets\]"
	cleanName = "Lunchbox"
	desc = "Start your shift with a cute little lunchbox, packed with all your favourite foods!"
	id = "lunchbox"
	points = -1
	isPositive = 1
	category = "trinkets"

// Skill - Undetermined Border

/obj/trait/smoothtalker
	name = "Smooth talker (-1) \[Skill\]"
	cleanName = "Smooth talker"
	desc = "Traders will tolerate 50% more when you are haggling with them."
	id = "smoothtalker"
	category = "skill"
	points = -1
	isPositive = 1

/obj/trait/matrixflopout
	name = "Matrix Flopout (-2) \[Skill\]"
	cleanName = "Matrix Flopout"
	desc = "Flipping lets you dodge bullets and attacks for a higher stamina cost!"
	id = "matrixflopout"
	category = "skill"
	points = -2
	isPositive = 1

/obj/trait/happyfeet
	name = "Happyfeet (-1) \[Skill\]"
	cleanName = "Happyfeet"
	desc = "Sometimes people can't help but dance along with you."
	id = "happyfeet"
	category = "skill"
	points = -1
	isPositive = 1

/* Hey dudes, I moved these over from the old bioEffect/Genetics system so they work on clone */

/obj/trait/job
	name = "hi yes I'm a bug"
	desc = "This is an error! Please report this to coders. May cause pointed questions towards the affected!"
	id = "error"
	points = 0
	isPositive = 1
	unselectable = 1
	category = "job"

	onAdd(var/mob/owner)
		return

	onLife(var/mob/owner) //Just to be safe.
		return

/obj/trait/job/chaplain
	name = "Chaplain Training"
	cleanName = "Chaplain Training"
	desc = "Subject is trained in cultural and psychological matters."
	id = "training_chaplain"

/obj/trait/job/medical
	name = "Medical Training"
	cleanName = "Medical Training"
	desc = "Subject is a proficient surgeon."
	id = "training_medical"

/obj/trait/job/security
	name = "Security Training"
	cleanName = "Security Training"
	desc = "Subject is trained in generalized robustness and asskicking."
	id = "training_security"

// barman, detective, HoS
/obj/trait/job/drinker
	name = "Professional Drinker"
	cleanName = "Professional Drinker"
	desc = "Sometimes you drink on the job, sometimes drinking is the job."
	id = "training_drinker"

// Phobias - Undetermined Border

/obj/trait/phobia
	name = "Phobias suck"
	desc = "Wow, phobias are no fun! Report this to a coder please."
	unselectable = 1

/obj/trait/phobia/space
	name = "Spacephobia (+1) \[Phobia\]"
	cleanName = "Spacephobia"
	desc = "Being in space scares you. A lot. While in space you might panic or faint."
	id = "spacephobia"
	points = 1
	isPositive = 0

	onLife(var/mob/owner)
		if(!owner.stat && can_act(owner) && istype(owner.loc, /turf/space))
			if(prob(2))
				owner.emote("faint")
				owner.changeStatus("paralysis", 80)
			else if (prob(8))
				owner.emote("scream")
				owner.changeStatus("stunned", 2 SECONDS)
		return

// Stats - Undetermined Border

/obj/trait/meathead
	name = "Meathead (-1) \[Stats\]"
	cleanName = "Meathead"
	desc = "You can take quite a beating! You suffer from brain trauma, though."
	id = "meathead"
	category = "stats"
	points = -1
	isPositive = 1

	onAdd(var/mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.max_health = 150
			H.health = 150
			H.take_brain_damage(60)
		return

	onLife(var/mob/owner) //Just to be safe.
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if(H.get_brain_damage() < 60)
				H.take_brain_damage(60-H.get_brain_damage())
		return

/obj/trait/athletic
	name = "Athletic (-2) \[Stats\]"
	cleanName = "Athletic"
	desc = "Great stamina! Frail body."
	id = "athletic"
	category = "stats"
	points = -2
	isPositive = 1

	onAdd(var/mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.add_stam_mod_max("trait", STAMINA_MAX * 0.1)
			H.add_stam_mod_regen("trait", STAMINA_REGEN * 0.1)
			H.max_health = 60
			H.health = 60
		return

/obj/trait/bigbruiser
	name = "Big Bruiser (-2) \[Stats\]"
	cleanName = "Big Bruiser"
	desc = "Stronger punches but higher stamina cost!"
	id = "bigbruiser"
	category = "stats"
	points = -2
	isPositive = 1

// NO CATEGORY - Grey Border

/obj/trait/hemo
	name = "Hemophilia (+1)"
	cleanName = "Hemophilia"
	desc = "You bleed more easily and you bleed more."
	id = "hemophilia"
	points = 1
	isPositive = 0

/obj/trait/slowmetabolism
	name = "Slow Metabolism (0)"
	cleanName = "Slow Metabolism"
	desc = "Any chemicals in you body deplete much more slowly."
	id = "slowmetabolism"
	points = 0
	isPositive = 1

/obj/trait/alcoholic
	name = "Career alcoholic (0)"
	cleanName = "Career alcoholic"
	desc = "You gain alcohol resistance but your speech is permanently slurred."
	id = "alcoholic"
	icon_state = "beer"
	points = 0
	isPositive = 1

	onAdd(var/mob/owner)
		if(owner.bioHolder)
			owner.bioHolder.AddEffect("resist_alcohol", 0, 0, 0, 1)
		return


/obj/trait/random_allergy
	name = "Allergy (+0)"
	cleanName = "Allergy"
	desc = "You're allergic to... something. You can't quite remember, but how bad could it possibly be?"
	id = "randomallergy"
	points = 0
	isPositive = 0

	var/allergen = ""
	var/allergen_name = ""

	var/list/allergen_id_list = list("spaceacillin","morphine","teporone","salicylic_acid","calomel","synthflesh","omnizine","saline","anti_rad","smelling_salt",\
	"haloperidol","epinephrine","insulin","silver_sulfadiazine","mutadone","ephedrine","penteticacid","antihistamine","styptic_powder","cryoxadone","atropine",\
	"salbutamol","perfluorodecalin","mannitol","charcoal","antihol","ethanol","iron","mercury","oxygen","plasma","sugar","radium","water","bathsalts","jenkem","crank",\
	"LSD","space_drugs","THC","nicotine","krokodil","catdrugs","triplemeth","methamphetamine","mutagen","neurotoxin","sarin","smokepowder","infernite","napalm", "fuel",\
	"anti_fart","lube","ectoplasm","cryostylane","oil","sewage","ants","spiders","poo","love","hugs","fartonium","blood","bloodc","vomit","urine","capsaicin","cheese",\
	"coffee","chocolate","chickensoup","salt","grease","badgrease","msg","egg")

	onAdd(var/mob/owner)
		allergen = pick(allergen_id_list)
		if (reagents_cache.len <= 0)
			build_reagent_cache()
		var/datum/reagent/R = reagents_cache[allergen]
		if(R)
			allergen_name = R.name
		else
			throw EXCEPTION("Could not find reagent for id:[allergen]")

	onLife(var/mob/owner)
		if (owner?.reagents?.has_reagent(allergen))
			owner.reagents.add_reagent("histamine", 1.4) //1.4 units of histamine per life cycle? is that too much?

/obj/trait/random_allergy/medical_allergy
	name = "Medical Allergy (+1)"
	cleanName = "Medical Allergy"
	desc = "You're allergic to some medical chemical... but you can't remember which."
	id = "medicalallergy"
	points = 1

	allergen_id_list = list("spaceacillin","morphine","teporone","salicylic_acid","calomel","synthflesh","omnizine","saline","anti_rad","smelling_salt",\
	"haloperidol","epinephrine","insulin","silver_sulfadiazine","mutadone","ephedrine","penteticacid","antihistamine","styptic_powder","cryoxadone","atropine",\
	"salbutamol","perfluorodecalin","mannitol","charcoal","antihol")

/obj/trait/addict
	name = "Addict (+2)"
	cleanName = "Addict"
	desc = "You spawn with a random addiction. Once cured there is a small chance that you will suffer a relapse."
	id = "addict"
	icon_state = "syringe"
	points = 2
	isPositive = 0
	var/selected_reagent = "ethanol"

	New()
		selected_reagent = pick("bath salts", "lysergic acid diethylamide", "space drugs", "psilocybin", "cat drugs", "methamphetamine")
		. = ..()

	onAdd(var/mob/owner)
		if(isliving(owner))
			addAddiction(owner)
		return

	onLife(var/mob/owner) //Just to be safe.
		if(isliving(owner) && prob(1))
			var/mob/living/M = owner
			for(var/datum/ailment_data/addiction/A in M.ailments)
				if(istype(A, /datum/ailment_data/addiction))
					if(A.associated_reagent == selected_reagent) return
			addAddiction(owner)
		return

	proc/addAddiction(var/mob/owner)
		var/mob/living/M = owner
		var/datum/ailment_data/addiction/AD = new
		AD.associated_reagent = selected_reagent
		AD.last_reagent_dose = world.timeofday
		AD.name = "[selected_reagent] addiction"
		AD.affected_mob = M
		M.ailments += AD
		return

/obj/trait/strongwilled
	name = "Strong willed (-1)"
	cleanName = "Strong willed"
	desc = "You are more resistant to addiction."
	id = "strongwilled"
	icon_state = "nosmoking"
	points = -1
	isPositive = 1

/obj/trait/addictive_personality // different than addict because you just have a general weakness to addictions instead of starting with a specific one
	name = "Addictive Personality (+1)"
	cleanName = "Addictive Personality"
	desc = "You are less resistant to addiction."
	id = "addictive_personality"
	icon_state = "syringe"
	points = 1
	isPositive = 0

/obj/trait/unionized
	name = "Unionized (-1)"
	cleanName = "Unionized"
	desc = "You start with a higher paycheck than normal."
	id = "unionized"
	icon_state = "handshake"
	points = -1
	isPositive = 1

/obj/trait/jailbird
	name = "Jailbird (0)"
	cleanName = "Jailbird"
	desc = "You have a criminal record and are currently on the run!"
	id = "jailbird"
	points = 0
	isPositive = 0

/obj/trait/clericalerror
	name = "Clerical Error (0)"
	cleanName = "Clerical Error"
	desc = "The name on your starting ID is misspelled."
	id = "clericalerror"
	icon_state = "spellingerror"
	points = 0
	isPositive = 1

/obj/trait/chemresist
	name = "Chem resistant (-2)"
	cleanName = "Chem resistant"
	desc = "You are more resistant to chem overdoses."
	id = "chemresist"
	points = -2
	isPositive = 1

/obj/trait/puritan
	name = "Puritan (+2)"
	cleanName = "Puritan"
	desc = "You can not be cloned. Any attempt will end badly."
	id = "puritan"
	points = 2
	isPositive = 0

/obj/trait/survivalist
	name = "Survivalist (-1)"
	cleanName = "Survivalist"
	desc = "Food will heal you even if you are badly injured."
	id = "survivalist"
	points = -1
	isPositive = 1

/obj/trait/smoker
	name = "Smoker (-1)"
	cleanName = "Smoker"
	desc = "You will not absorb any chemicals from smoking cigarettes."
	id = "smoker"
	icon_state = "smoker"
	points = -1
	isPositive = 1

/obj/trait/immigrant
	name = "Stowaway (+1)"
	cleanName = "Stowaway"
	desc = "You spawn hidden away on-station without an ID or PDA."
	id = "immigrant"
	points = 1
	isPositive = 0

/obj/trait/nervous
	name = "Nervous (+1)"
	cleanName = "Nervous"
	desc = "Witnessing injuries or violence will sometimes make you freak out."
	id = "nervous"
	icon_state = "nervous"
	points = 1
	isPositive = 0

	onAdd(var/mob/owner)
		..()
		nervous_mobs += owner

	onRemove(var/mob/owner)
		..()
		nervous_mobs -= owner

/obj/trait/burning
	name = "Human Torch (+1)"
	cleanName = "Human Torch"
	desc = "Extends the time that you remain on fire for, when burning."
	id = "burning"
	icon_state = "onfire"
	points = 1
	isPositive = 0

/obj/trait/carpenter
	name = "Carpenter (-1)"
	cleanName = "Carpenter"
	desc = "You can construct things more quickly than other people."
	id = "carpenter"
	points = -1
	isPositive = 1

/obj/trait/kleptomaniac
	name = "Kleptomaniac (+1)"
	cleanName = "Kleptomaniac"
	desc = "You will sometimes randomly pick up nearby items."
	id = "kleptomaniac"
	points = 1
	isPositive = 0

	onLife(var/mob/owner)
		if(!owner.stat && can_act(owner) && prob(9))
			if(!owner.equipped())
				for(var/obj/item/I in view(1, owner))
					if(!I.anchored && isturf(I.loc))
						I.attack_hand(owner)
						if(prob(12))
							owner.emote(pick("grin", "smirk", "chuckle", "smug"))
						break
		return

/obj/trait/clutz
	name = "Clutz (+2)"
	cleanName = "Clutz"
	desc = "When interacting with anything you have a chance to interact with something different instead."
	id = "clutz"
	points = 2
	isPositive = 0

/obj/trait/leftfeet
	name = "Two left feet (+1)"
	cleanName = "Two left feet"
	desc = "Every now and then you'll stumble in a random direction."
	id = "leftfeet"
	points = 1
	isPositive = 0

/obj/trait/scaredshitless
	name = "Scared Shitless (0)"
	cleanName = "Scared Shitless"
	desc = "Literally. When you scream, you fart. Be careful around Bibles!"
	id = "scaredshitless"
	icon_state = "poo"
	points = 0
	isPositive = 0

/obj/trait/allergic
	name = "Hyperallergic (+1)"
	cleanName = "Hyperallergic"
	desc = "You have a severe sensitivity to allergens and are liable to slip into anaphylactic shock upon exposure."
	id = "allergic"
	icon_state = "placeholder"
	points = 1
	isPositive = 0

/obj/trait/allears
	name = "All Ears (+1) \[Trinkets\]"
	cleanName="All ears"
	desc = "You lost your headset on the way to work."
	category = "trinkets"
	id = "allears"
	points = 1
	isPositive = 0

