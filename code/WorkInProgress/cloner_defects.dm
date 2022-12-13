// WIP cloner defects

/// Concept: cloning you gives you wacky defects, which can be genetic, sci-fi, or just dumb space magic. If you're scanned while you have some cloner defects,
/// Those are also included in the scan, meaning after another cloning you'll be even more screwed up. However, curing defects before scanning (the curable ones, at least)
/// will mean they don't carry over.
/// Current concept is that defects will first be split into major/minor, and then weighted in those pools seperately.
///
/// Properties set in init() will only be ran/applied when the defect is initially added, not when the defect is applied after a later cloning.
/// Properties set in on_add() will be ran/applied on every further cloning, if not removed.
///
/// Applied when leaving the pod (via signal jank) rather than when starting the clone (to prevent us instantly botching the clone)
///
///
/// - This replaces the max health debuff, so the 'Quit Cloning Around' medal will need a new method. Maybe hitting a certain threshold of instability/defect score?


// OVERALL TODO

// --- CRUCIAL ---
// Actually tie this in to cloner code so people get cloner defects
// DONE - Implement random defect rolling (33% major 66% minor?)
// DONE - NO REMOVAL FOR NOW - Figure out where/how on_remove() will be called/how the conditions will be checked. Ton of new signals?
// DONE? - finish up cloner_defect_holder

// --- MINOR ---
// CURRENTLY UNNECESSARY Maybe add an on_life proc? Just using signals for now
// DONE Figure out how to make defects persist between clones; also, should it take defects at time of clone or at time of scan?
// PROBABLY NOT DOING THIS ACTUALLY - Add geometric dist for cloner defect add count with p=0.5

// --- BACKLOG ---


/mob/living/carbon/human/New()
	. = ..()
	cloner_defects  = new(src)

/mob/living/carbon/human/var/datum/cloner_defect_holder/cloner_defects

/// Holds all the cloner defects for a person, as well as the weighted list of possible defects
/datum/cloner_defect_holder
	/// Human this defect holder belongs to (thus, also the owner of all defects contained herewithin)
	var/mob/living/carbon/human/owner = null
	/// Cloner defects active on the owner of this holder
	var/list/datum/cloner_defect/active_cloner_defects
	/// 2D list, mapping severity to a list mapping defect type to weight
	var/static/list/weighted_defect_index

	New(mob/living/carbon/human/owner)
		. = ..()
		// null owner is fine (detached holder for cloning), human owner is fine (intended case), else error
		if (!isnull(owner) && !istype(owner))
			stack_trace("[identify_object(src)] passed nonhuman owner [identify_object(owner)], this won't work at all. Deleting.")
			qdel(src)
			return
		src.owner = owner // imjava

		if (!weighted_defect_index)
			weighted_defect_index = list()
			for (var/defect_type in concrete_typesof(/datum/cloner_defect))
				var/severity = initial(defect_type:severity)
				if (severity) // so we can use null severity as a blacklist
					LAZYLISTINIT(weighted_defect_index[severity])
					var/list/sublist = weighted_defect_index[severity]
					// lazylistassoc when (wici)
					sublist[defect_type] = initial(defect_type:weight) // we can use initial to get initial values of a type without an instance

	/// Add a cloner defect of the given severity
	proc/add_cloner_defect(severity)
		var/picked
		var/is_valid = FALSE
		while (!is_valid)
			picked = weighted_pick(weighted_defect_index[severity])
			// If the picked defect can stack, pass automatically. If it can't stack, check if we have it already; if not, pass.
			is_valid = initial(picked:stackable) || !src.has_defect(picked)
		LAZYLISTADD(src.active_cloner_defects, new picked(src.owner))
		logTheThing(LOG_COMBAT, src.owner, "gained the [picked] cloner defect.")

	/// Add a cloner defect, rolling severity according to weights
	proc/add_random_cloner_defect()
		var/static/list/severity_weights = list(CLONER_DEFECT_SEVERITY_MINOR=CLONER_DEFECT_PROB_MINOR,
												CLONER_DEFECT_SEVERITY_MAJOR=CLONER_DEFECT_PROB_MAJOR)
		src.add_cloner_defect(weighted_pick(severity_weights))

	/// Debug proc- add a cloner defect of a specific type.
	proc/add_specific_cloner_defect(type)
		if (!ispath(type, /datum/cloner_defect))
			CRASH("Tried to directly add a cloner defect of type [type], which isn't valid (has to be a child of /datum/cloner_defect)")
		LAZYLISTADD(src.active_cloner_defects, new type(src.owner))

	/// Copies all the defects on this holder, returns a new holder with those copied defects
	proc/copy()
		var/datum/cloner_defect_holder/holder_copy = new
		for (var/datum/cloner_defect/defect as anything in src.active_cloner_defects)
			var/datum/cloner_defect/copy = new defect.type(null, copy = TRUE)
			copy.data = defect.data
			LAZYLISTADD(holder_copy.active_cloner_defects, copy)
		return holder_copy

	/// Applies all the defects on this holder (which is assumed to be ownerless) to the target mob
	proc/apply_to(mob/living/carbon/human/target)
		if (!istype(target))
			CRASH("Tried to copy [identify_object(src)] to non-human thing [identify_object(target)]")
		target.cloner_defects = src
		for (var/datum/cloner_defect/defect as anything in src.active_cloner_defects)
			defect.apply_to(target)
		UnregisterSignal(target, COMSIG_MOVABLE_SET_LOC) // in case we used the proc below

	/// Performs the above function after the mob moves. Used for cloning (only apply)
	proc/apply_to_on_move(mob/living/carbon/human/target)
		RegisterSignal(target, COMSIG_MOVABLE_SET_LOC, .proc/apply_to)

	/// Returns TRUE if this holder contains the given defect type, FALSE otherwise
	proc/has_defect(defect_type)
		for (var/datum/cloner_defect as anything in src.active_cloner_defects)
			if (istype(cloner_defect, defect_type))
				return TRUE
		return FALSE



ABSTRACT_TYPE(/datum/cloner_defect)
/datum/cloner_defect
	var/mob/living/carbon/human/owner = null //! Who has this defect?
	var/weight = 100 //! Weight of this effect when rolled against other effects in the same pool (minor/major). Default is 100.
	var/name = "" //! Name of this defect for. medical scans or something, I dunno. Maybe let the geneticist's scanner thing see them?
	var/desc = "" //! Same as above- for scans or whatever
	var/stackable = TRUE //! Can we get this defect multiple times?
	var/severity = CLONER_DEFECT_SEVERITY_UNUSED //! How severe is this effect? (Currently just major and minor)
	/// Any data which should be maintained between clonings if the person is cloned multiple times.
	/// IF YOU WANT DATA TO BE TRANSFERRED BETWEEN BODIES, USE THIS INSTEAD OF MAKING A VAR
	var/data

	/// Owner is the mob who we're applying this defect to. 'copy' is true
	New(mob/living/carbon/human/owner, copy = FALSE)
		. = ..()
		if (!copy)
			src.init()
		if (!isnull(owner))
			src.apply_to(owner)


	proc/apply_to(mob/living/carbon/human/target)
		if (!istype(target))
			CRASH("Tried to apply [identify_object(src)] to non-human thing [identify_object(target)]")
		src.owner = target
		src.on_add()

	disposing()
		LAZYLISTREMOVE(src.owner?.cloner_defects, src)
		..()

	proc/on_add()
		SHOULD_CALL_PARENT(TRUE)
		if (!istype(owner))
			stack_trace("Cloner defect of type [src.type] added to non-human mob '[owner]' of type [owner.type].")
			src.on_remove()

	/// Called when this defect is removed by any means
	proc/on_remove()
		SHOULD_CALL_PARENT(TRUE)
		qdel(src)

	/// Called when this defect is created for the first time (ie not copying to a new body after cloning)
	/// Shouldn't depend on owner at all. Will be called with a null owner during clone scanning.
	proc/init()
		return

/// Some random brute/burn damage after cloning.
/datum/cloner_defect/ouch
	name = "Minor Flesh Abnormality"
	desc = "Subject's skin was not reconstructed exactly as planned; some superficial damage has resulted."
	severity = CLONER_DEFECT_SEVERITY_MINOR

	init()
		src.data = list("extra_variance" = 5, "damage_amount" = 40)

	on_add()
		..()
		var/brute = rand(src.data["damage_amount"])
		owner.TakeDamage("All", brute + rand(-data["extra_variance"], data["extra_variance"]), data["damage_amount"] - brute + rand(-data["extra_variance"], data["extra_variance"]))


/datum/cloner_defect/ouch/big
	name = "Significant Flesh Abnormality"
	desc = "Subject's skin condition has deviated from the expectation; significant damage has resulted."
	severity = CLONER_DEFECT_SEVERITY_MAJOR

	init()
		src.data = list("extra_variance" = 10, "damage_amount" = 120)

/// Lose a random limb after cloning
/datum/cloner_defect/missing_limb
	weight = 80
	name = "Failed Limb Reconstruction"
	desc = "One of the subject's limbs was not properly reconstructed, leaving them without it."
	severity = CLONER_DEFECT_SEVERITY_MINOR

	init()
		src.data = list("lost_limb_string" = pick("l_arm", "r_arm", "l_leg", "r_leg"))

	on_add()
		. = ..()
		var/obj/item/parts/lost_limb = src.owner.limbs.get_limb(data["lost_limb_string"])
		lost_limb.delete()

/// Get some histamine after cloning
/datum/cloner_defect/allergic
	name = "Allergic Reaction"
	desc = "Subject has experienced a minor allergic reaction to some compound used in the cloning process."
	severity = CLONER_DEFECT_SEVERITY_MINOR

	init()
		src.data = list("histamine_amt" = rand(30, 80))

	on_add()
		. = ..()
		src.owner.reagents.add_reagent("histamine", data["histamine_amt"])

/// Lose a random organ after cloning
ABSTRACT_TYPE(/datum/cloner_defect/missing_organ)
/datum/cloner_defect/missing_organ
	weight = 80
	name = "Failed Organ Reconstruction"
	desc = "One of the subject's organs was not properly reconstructed, leaving them without it."

	on_add()
		. = ..()
		qdel(src.owner.organHolder.organ_list[data["organ_string"]])

/datum/cloner_defect/missing_organ/minor
	severity = CLONER_DEFECT_SEVERITY_MINOR

	init()
		src.data = list("organ_string" = pick("tail", "left_kidney", "right_kidney", "stomach", "intestines", "appendix"))

/datum/cloner_defect/missing_organ/major
	severity = CLONER_DEFECT_SEVERITY_MAJOR

	init()
		src.data = list("organ_string" = pick("liver", "left_eye", "right_eye", "left_lung", "right_lung")) // no skull, head, brain; instant death sucks. also removed heart

/// Set to a random (safe) mutantrace after cloning
/datum/cloner_defect/random_mutantrace
	name = "Unexpected Genetic Development"
	desc = "Subject's DNA has mutated into that of a different species."
	severity = CLONER_DEFECT_SEVERITY_MINOR
	stackable = FALSE
	var/orig_mutantrace_type = null //! Holds their original mutantrace type so we can change them back if the defect is removed

	init()
		src.data = list("new_mutantrace_type" = null)
		while (!data["new_mutantrace_type"] || initial(data["new_mutantrace_type"]:dna_mutagen_banned))
			data["new_mutantrace_type"] = pick(concrete_typesof(/datum/mutantrace))

	on_add()
		. = ..()
		src.orig_mutantrace_type = src.owner.mutantrace?.type
		src.owner.set_mutantrace(data["new_mutantrace_type"])

// TODO abstract status effect defects more

/// Max health decrease
ABSTRACT_TYPE(/datum/cloner_defect/maxhealth_down)
/datum/cloner_defect/maxhealth_down
	name = "Buggy Wuggy Wuh Woh Coders"

	on_add()
		. = ..()
		var/datum/statusEffect/maxhealth/decreased/existing_status = src.owner.hasStatus("maxhealth-")
		if (existing_status)
			existing_status.change -= data["penalty"]
		else
			src.owner.setStatus("maxhealth-", INFINITE_STATUS, -data["penalty"])

/datum/cloner_defect/maxhealth_down/small
	name = "Minor Fortitude Decrease"
	desc = "Subject's endurance has been weakened by the cloning process."
	severity = CLONER_DEFECT_SEVERITY_MINOR

	init()
		src.data = list("penalty" = rand(5, 15))

/datum/cloner_defect/maxhealth_down/large
	name = "Major Fortitude Decrease"
	desc = "Subject's endurance has been significantly weakened by the cloning process."
	severity = CLONER_DEFECT_SEVERITY_MAJOR

	init()
		src.data = list("penalty" = rand(20, 30))

ABSTRACT_TYPE(/datum/cloner_defect/stamregen_down)
/datum/cloner_defect/stamregen_down
	name = "broken"
	desc = "Subject's endurance has been decreased by the cloning process."

	on_add()
		. = ..()
		var/datum/statusEffect/staminaregen/clone/existing_status = src.owner.hasStatus("stamclone")
		if (existing_status)
			existing_status.change += data["penalty"]
		else
			src.owner.setStatus("stamclone", INFINITE_STATUS, data["penalty"])

/datum/cloner_defect/stamregen_down/minor
	name = "Minor Stamina Decrease"

	init()
		src.data = list("penalty" = -rand(0, 2))

// no /major currently because a few stacked would be miserable

ABSTRACT_TYPE(/datum/cloner_defect/brain_damage)
/datum/cloner_defect/brain_damage
	name = "Call Aloe Oh No"
	stackable = FALSE // until I add some way to remove these, stacking a few (2 of the major ones, even) would kill you instantly
	desc = "Subject has sustained a form of concussion during the cloning process."

	on_add()
		. = ..()
		src.owner.take_brain_damage(data["amount"])


/datum/cloner_defect/brain_damage/minor
	name = "Minor Concussive Complication"
	severity = CLONER_DEFECT_SEVERITY_MINOR

	init()
		src.data = list("amount" = rand(10, 40))

/datum/cloner_defect/brain_damage/major
	name = "Major Concussive Complication"
	severity = CLONER_DEFECT_SEVERITY_MAJOR

	init()
		src.data = list("amount" = rand(50, 90))

ABSTRACT_TYPE(/datum/cloner_defect/organ_damage)
/datum/cloner_defect/organ_damage
	name = "wee woo wee woo fucked up cloner defect"
	desc = "Some of the subject's organs were improperly reconstructed, causing a loss of functionality."

	init()
		src.data["targeted_organs"] = list()
		for (var/i in 1 to src.data["count"])
			data["targeted_organs"] += pick(src.owner.organHolder.organ_type_list - list("brain", "skull", "head", "butt"))


	on_add()
		. = ..()
		src.owner.organHolder.damage_organs(round(data["amount"]/3), round(data["amount"]/3), round(data["amount"]/3), data["targeted_organs"])

/datum/cloner_defect/organ_damage/minor
	name = "Minor Organ Aberration"
	severity = CLONER_DEFECT_SEVERITY_MINOR

	init()
		src.data = list("amount" = rand(10, 20),
						"count" = rand(1, 3))
		..()

/datum/cloner_defect/organ_damage/major
	name = "Major Organ Aberration"
	severity = CLONER_DEFECT_SEVERITY_MAJOR

	init()
		src.data = list("amount" = rand(20, 30),
						"count" = rand(3, 5))
		..()

/// You become a puritan- no more clonings for you! (unless the docs are really solid)
/datum/cloner_defect/puritan
	name = "Rapid-Onset Puritanism"
	desc = "Subject has developed an incompatibility to cloning methods."
	severity = CLONER_DEFECT_SEVERITY_MAJOR
	stackable = FALSE

	on_add()
		. = ..()
		owner.traitHolder.addTrait("puritan")


/datum/cloner_defect/arm_swap //! Left and right arms are swapped, making them both initially useless TODO actually implement
	name = "Limb Discombobulation"
	desc = "Subject's legs have been grown where their arms are supposed to be. Location of their arms is unknown."
	severity = CLONER_DEFECT_SEVERITY_MAJOR // could be minor I guess. Takes a lot of surgery to fix though
	stackable = FALSE
	weight = 15

	on_add()
		. = ..()
		src.owner.limbs.l_arm?.delete()
		src.owner.limbs.r_arm?.delete()
		var/obj/item/parts/l_leg = src.owner.limbs.l_leg
		var/obj/item/parts/r_leg = src.owner.limbs.r_leg
		// this sucks
		l_leg.sever()
		l_leg.set_loc(src.owner)
		var/obj/item/parts/human_parts/arm/left/item/l_item_arm = new(src.owner, l_leg)
		l_leg.cant_drop = TRUE
		src.owner.limbs.l_arm = l_item_arm
		l_item_arm.holder = src.owner

		r_leg.sever()
		r_leg.set_loc(src.owner)
		var/obj/item/parts/human_parts/arm/right/item/r_item_arm = new(src.owner, r_leg)
		r_leg.cant_drop = TRUE
		src.owner.limbs.r_arm = r_item_arm
		r_item_arm.holder = src.owner

/// Just fucking explode. probably a bad idea. TODO maybe make it so if they're healed to max they don't explode?
/// CURRENTLY DISABLED
/datum/cloner_defect/explosive
	weight = 10
	name = "Subj- OH GOD RUN"
	//desc set below
	severity = CLONER_DEFECT_SEVERITY_UNUSED
	stackable = FALSE

	New()
		. = ..()
		desc = "THERE'S NO TIME [uppertext(he_or_she(src.owner))]'S GONNA BLOW"

	on_add()
		. = ..()
		src.owner.make_jittery(20 SECONDS) //mimics puritanism kinda
		src.owner.visible_message("<span class='alert'>[src.owner] is going critical!</span>", "<span class='alert'>You feel like you're about to explode!")
		SPAWN(20 SECONDS)
			src.owner.blowthefuckup(strength = 15) //probably gibs you?

	// TODO if I add a way out- remove defect after SPAWN so the desc doesn't persist (falsely)


/// Add some kind of 'clumsy' mutation/trait
/datum/cloner_defect/clumsy
	name = "Motor Control Impairment"
	desc = "Subject has sustained nerve damage, resulting in some impairments to motor control."
	severity = CLONER_DEFECT_SEVERITY_MINOR
	stackable = FALSE // can be TRUE if I make it so it can't give you the same thing multiple times.
	var/static/list/effect_type_pool = list(/datum/trait/leftfeet, /datum/trait/clutz, /datum/bioEffect/funky_limb, /datum/bioEffect/clumsy) // Pool of effects to pick from (traits and bioeffects)

	init()
		src.data = list("trait_id" = null,
					"bioeffect_id" = null)
		var/effect_type = pick(effect_type_pool)
		if (ispath(effect_type, /datum/trait))
			data["trait_id"] = initial(effect_type:id)
		else
			data["bioeffect_id"] = initial(effect_type:id)

	on_add()
		. = ..()
		if (data["trait_id"])
			src.owner.traitHolder.addTrait(data["trait_id"])
		else
			src.owner.bioHolder.AddEffect(data["bioeffect_id"])
			var/datum/bioEffect/effect = src.owner.bioHolder.GetEffect(data["bioeffect_id"]) // this suuuucks
			effect.curable_by_mutadone = FALSE


/// Sets seen name to 'unknown' (until repaired with synthflesh)
/datum/cloner_defect/face_disfigured
	name = "Facial Disfiguration"
	desc = "Subject's face has been disfigured during the cloning process, rendering them unrecognizable."
	severity = CLONER_DEFECT_SEVERITY_MAJOR

	on_add()
		. = ..()
		src.owner.disfigured = TRUE
		src.owner.UpdateName()

/// Sets heard voice to 'unknown' (until repaired with synthflesh)
/datum/cloner_defect/voice_disfigured
	name = "Vocal Chord Disfiguration"
	desc = "Subject's vocal chords were improperly reconstructed, making their voice unrecognizable."
	severity = CLONER_DEFECT_SEVERITY_MINOR

	on_add()
		. = ..()
		src.owner.vdisfigured = TRUE

/// Makes you fall over when you sprint too hard (pug thing)
/datum/cloner_defect/sprint_flop
	name = "Poor Muscular Regulation"
	desc = "Certain nerves within the legs have failed, making the subject prone to running until they fall on their face."
	severity = CLONER_DEFECT_SEVERITY_MINOR

	on_add()
		. = ..()
		APPLY_ATOM_PROPERTY(src.mob, PROP_MOB_FAILED_SPRINT_FLOP, src)

/datum/cloner_defect/overdose_weakness
	name = "Chemical Weakness"
	desc = "Subject's renal system has been weakened by the cloning process, making them more vulnerable to chemical overdoses."
	severity = CLONER_DEFECT_SEVERITY_MINOR

	on_add()
		. = ..()
		APPLY_ATOM_PROPERTY(src.mob, PROP_MOB_OVERDOSE_WEAKNESS, src)
