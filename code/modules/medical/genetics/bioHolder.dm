var/list/bioUids = new/list() //Global list of all uids and their respective mobs

var/numbersAndLetters = list("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q",
"r", "s", "t", "u", "v", "w", "x", "y", "z" , "0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
var/list/datum/bioEffect/bioEffectList = list()
var/list/datum/bioEffect/mutini_effects = list()

/datum/bioHolder
	//Holds the appearanceholder aswell as the effects. Controls adding and removing of effects.
	var/list/effects = new/list()
	var/list/effectPool = new/list()

	var/mob/owner = null
	var/ownerName = null
	var/ownerType = null //mostly meaningless for bioHolders created for mobs; only used for ownerless bioHolders in blood and such

	var/bloodType = "AB+-"
	var/bloodColor = null
	var/age = 30
	var/genetic_stability = 100
	var/clone_generation = 0 //Get this high enough and you can be like Arnold. Maybe. I found that movie fun. Don't judge me.

	var/datum/appearanceHolder/mobAppearance = null


	var/Uid = "not initialized" //Unique id for the mob. Used for fingerprints and whatnot.
	var/uid_hash
	var/fingerprints

	New(var/mob/owneri)
		owner = owneri
		Uid = CreateUid()
		bioUids[Uid] = null
		build_fingerprints()
		mobAppearance = new/datum/appearanceHolder()

		mobAppearance.owner = owner
		mobAppearance.parentHolder = src

		SPAWN(2 SECONDS) // fuck this shit
			if(owner)
				ownerName = owner.real_name
				ownerType = owner.type
				bioUids[Uid] = owner?.real_name ? owner.real_name : owner?.name

		BuildEffectPool()
		return ..()

	proc/build_fingerprints()
		uid_hash = md5(Uid)
		var/fprint_base = uppertext(md5_to_more_pronouncable(uid_hash))
		var/list/fprint_parts = list()
		for(var/i in 1 to length(fprint_base) step 6)
			if(i + 6 <= length(fprint_base) + 1)
				fprint_parts += copytext(fprint_base, i, i + 6)
		fingerprints = jointext(fprint_parts, "-")

	disposing()
		for(var/D in effects)
			var/datum/bioEffect/BE = effects[D]
			qdel(BE)
			BE?.owner = null
		for(var/D in effectPool)
			var/datum/bioEffect/BE = effectPool[D]
			qdel(BE)
			BE?.owner = null

		if(src.mobAppearance)
			src.mobAppearance.dispose()
			src.mobAppearance = null

		src.owner = null

		effects.len = 0
		effectPool.len = 0
		effects = null
		effectPool = null

		if (mobAppearance)
			mobAppearance.owner = null
			mobAppearance = null

		..()

	proc/OutputGainOrLoseMsg(var/datum/bioEffect/E, var/gain = TRUE)
		if (!E)
			return

		if (gain == TRUE)
			if (length(E.msgGain) > 0)
				if (E.isBad)
					boutput(owner, SPAN_ALERT("[E.msgGain]"))
				else
					boutput(owner, SPAN_NOTICE("[E.msgGain]"))
		else
			if (length(E.msgLose) > 0)
				if (E.isBad)
					boutput(owner, SPAN_NOTICE("[E.msgLose]"))
				else
					boutput(owner, SPAN_ALERT("[E.msgLose]"))

		return

	/// Deactivate effects that were activated from effectsPool and putting them back into effectsPool
	proc/DeactivateAllPoolEffects()
		if (length(src.effects) == 0)
			return

		for (var/datum/bioEffect/curr as anything in src.effects)
			var/datum/bioEffect/E = src.effects[curr]
			if (E.activated_from_pool == 1)
				DeactivatePoolEffect(E)

		return

	/// Deactivates a gene effect and inserts it back into the pool
	proc/DeactivatePoolEffect(var/datum/bioEffect/E)
		if (!E)
			return 0
		src.effects.Remove(E.id)
		src.effectPool[E.id] = E
		E.owner = null
		E.holder = null
		E.activated_from_pool = 0
		E.OnRemove()

		src.OutputGainOrLoseMsg(E, FALSE)

	proc/ActivatePoolEffect(var/datum/bioEffect/E, var/overrideDNA = 0, var/grant_research = 1)
		if(!E || !effectPool[E.id] || (!E.dnaBlocks.sequenceCorrect() && !overrideDNA) || HasEffect(E.id))
			return 0

		var/datum/bioEffect/global_BE = E.get_global_instance()
		if (grant_research)
			if (global_BE.research_level < EFFECT_RESEARCH_DONE)
				genResearch.mutations_researched++
				global_BE.onResearched()
			global_BE.research_level = max(global_BE.research_level, EFFECT_RESEARCH_ACTIVATED)

		if(E.get_global_instance() == E)
			CRASH("Cannot activate a global bioeffect on a mob!")
		if(E.owner && E.owner != owner)
			CRASH("BioEffect [E] [E.type] already has an owner [identify_object(E.owner)] but we activate it on [identify_object(src.owner)]!")
		if(effectPool[E.id] != E)
			CRASH("BioEffect [E] [E.type] is not in our effectPool but we activate it on [identify_object(src.owner)]!")

		//AddEffect(E.id)
		//effectPool.Remove(E)
		// changed this to transfer the instance across rather than add a copy
		// since some bioeffects have unique stuff
		effects[E.id] = E
		effectPool.Remove(E.id)
		E.owner = owner
		E.holder = src
		E.activated_from_pool = 1
		E.OnAdd()

		OutputGainOrLoseMsg(E, TRUE)

		mobAppearance.UpdateMob()
		return E

	proc/AddNewPoolEffect(var/idToAdd, var/scramble=FALSE)
		if(HasEffect(idToAdd) || HasEffectInPool(idToAdd))
			return 0

		var/datum/bioEffect/newEffect = bioEffectList[idToAdd]
		newEffect = newEffect.GetCopy()

		if (istype(newEffect))
			effectPool[newEffect.id] = newEffect
			if(scramble) newEffect.dnaBlocks.ModBlocks()
			newEffect.holder = src
			newEffect.owner = src.owner
			return 1

		return 0

	proc/AddRandomNewPoolEffect()
		var/list/filteredList = list()

		if (!bioEffectList || !length(bioEffectList))
			logTheThing(LOG_DEBUG, null, {"<b>Genetics:</b> Tried to add new random effect to pool for
			 [owner ? "\ref[owner] [owner.name]" : "*NULL*"], but bioEffectList is empty!"})
			return 0

		for(var/T in bioEffectList)
			var/datum/bioEffect/instance = bioEffectList[T]
			if(!instance || HasEffect(T) || HasEffectInPool(T) || !instance.occur_in_genepools)
				continue

			filteredList.Add(instance)
			filteredList[instance] = instance.probability

		if(!filteredList.len)
			logTheThing(LOG_DEBUG, null, {"<b>Genetics:</b> Unable to get effects for new random effect for
			 [owner ? "\ref[owner] [owner.name]" : "*NULL*"]. (filteredList.len = [filteredList.len])"})
			return 0

		var/datum/bioEffect/selectedG = weighted_pick(filteredList)
		var/datum/bioEffect/selectedNew = selectedG.GetCopy()
		selectedNew.dnaBlocks.ModBlocks() //Corrupt the local copy
		selectedNew.holder = src
		selectedNew.owner = src.owner
		effectPool[selectedNew.id] = selectedNew
		return 1

	proc/RemovePoolEffect(var/datum/bioEffect/E)
		if(!effectPool[E.id]) return 0
		effectPool.Remove(E.id)
		return 1

	proc/BuildEffectPool()
		var/list/filteredGood = new/list()
		var/list/filteredBad = new/list()
		var/list/filteredSecret = new/list()
		var/datum/bioEffect/selectedNew

		for(var/datum/bioEffect/BE in effectPool)
			qdel(BE)
		effectPool.Cut()

		if (!bioEffectList || !length(bioEffectList))
			logTheThing(LOG_DEBUG, null, {"<b>Genetics:</b> Tried to build effect pool for
			 [owner ? "\ref[owner] [owner.name]" : "*NULL*"], but bioEffectList is empty!"})

		var/mob/living/L = owner
		if(!istype(L))
			return
		var/good_genes = 0
		var/bad_genes = 0
		var/secret_genes = 0
		var/genetic_counts = L.get_genetic_traits()
		if(length(genetic_counts) == 3)
			good_genes = genetic_counts[1]
			bad_genes = genetic_counts[2]
			secret_genes = genetic_counts[3]

		if(!good_genes && !bad_genes && !secret_genes)
			return

		for(var/T in bioEffectList)
			var/datum/bioEffect/instance = bioEffectList[T]
			if(!instance || HasEffect(T) || !instance.occur_in_genepools) continue
			if(src.owner)
				if (src.owner.type in instance.mob_exclusion)
					continue
				if (instance.mob_exclusive && src.owner.type != instance.mob_exclusive)
					continue
			if(instance.secret)
				filteredSecret[instance] = instance.probability
			else
				if(instance.isBad)
					filteredBad[instance] = instance.probability
				else
					filteredGood[instance] = instance.probability

		if(!length(filteredGood) || !length(filteredBad))
			logTheThing(LOG_DEBUG, null, {"<b>Genetics:</b> Unable to build effect pool for
			 [owner ? "\ref[owner] [owner.name]" : "*NULL*"]. (filteredGood.len = [filteredGood.len],
			  filteredBad.len = [filteredBad.len])"})
			return

		for(var/g=0, g<good_genes, g++)
			var/datum/bioEffect/selectedG = weighted_pick(filteredGood)
			if(selectedG)
				selectedNew = selectedG.GetCopy()
				selectedNew.dnaBlocks.ModBlocks() //Corrupt the local copy
				selectedNew.holder = src
				selectedNew.owner = src.owner
				effectPool[selectedNew.id] = selectedNew
				filteredGood.Remove(selectedG)
			else
				break

		for(var/b=0, b<bad_genes, b++)
			var/datum/bioEffect/selectedB = weighted_pick(filteredBad)
			if(selectedB)
				selectedNew = selectedB.GetCopy()
				selectedNew.dnaBlocks.ModBlocks() //Corrupt the local copy
				selectedNew.holder = src
				selectedNew.owner = src.owner
				effectPool[selectedNew.id] = selectedNew
				filteredBad.Remove(selectedB)
			else
				break

		if (filteredSecret.len)
			for(var/s=0, s<secret_genes, s++)
				var/datum/bioEffect/selectedS = weighted_pick(filteredSecret)
				if(selectedS)
					selectedNew = selectedS.GetCopy()
					selectedNew.dnaBlocks.ModBlocks() //Corrupt the local copy
					selectedNew.holder = src
					selectedNew.owner = src.owner
					effectPool[selectedNew.id] = selectedNew
					filteredSecret.Remove(selectedS)
				else
					break

		shuffle_list(effectPool)

	proc/OnLife(var/mult)
		var/datum/bioEffect/BE
		for(var/curr in effects)
			BE = effects[curr]
			if (BE)
				BE.OnLife(mult)
				if(BE.timeLeft != -1)
					BE.timeLeft -= 1*mult
					if(BE.timeLeft <= 0)
						if(BE.degrade_after && BE.degrade_to)
							AddEffect(BE.degrade_to, do_stability = 0)
						RemoveEffect(BE.id)
		return

	proc/OnMobDraw()
		var/datum/bioEffect/BE
		for(var/curr in effects)
			BE = effects[curr]
			if (BE) //Wire: Fix for: Cannot execute null.OnMobDraw()
				BE.OnMobDraw()
		return

	proc/CreateUid() //Creates a new uid and returns it.
		var/newUid = ""

		do
			for(var/i = 1 to 20)
				newUid += "[pick(numbersAndLetters)]"
		while(newUid in bioUids)

		return newUid

	proc/CopyOther(var/datum/bioHolder/toCopy, var/copyAppearance = 1, var/copyPool = 1, var/copyEffectBlocks = 0, var/copyActiveEffects = 1)
		//Copies the settings of another given holder. Used for syringes, the dna spread virus and such things.
		if(copyAppearance)
			mobAppearance.CopyOther(toCopy.mobAppearance)
			mobAppearance.UpdateMob()

			age = toCopy.age
			bloodType = toCopy.bloodType
			bloodColor = toCopy.bloodColor
			clone_generation = toCopy.clone_generation
			ownerName = toCopy.ownerName || toCopy.owner.real_name // To quote line 386, "fuck this shit"
			Uid = toCopy.Uid
			uid_hash = md5(Uid)
			build_fingerprints()

		if (copyPool)
			src.RemoveAllPoolEffects()
			for (var/id in toCopy.effectPool)
				AddNewPoolEffect(id)

		if(copyActiveEffects)
			src.RemoveAllEffects()
			var/datum/bioEffect/BE
			for(var/curr in toCopy.effects)
				BE = toCopy.effects[curr]
				if (!BE.can_copy)
					continue

				var/datum/bioEffect/newCopy
				if(HasEffect(BE.id))
					newCopy = GetEffect(BE.id)
				else
					newCopy = AddEffect(BE.id, power = BE.power)

				if(!newCopy) //uh oh
					continue

				var/oldpower = newCopy.power
				newCopy.power = BE.power
				newCopy.safety = BE.safety
				newCopy.curable_by_mutadone = BE.curable_by_mutadone
				newCopy.timeLeft = BE.timeLeft
				newCopy.stability_loss = BE.stability_loss
				newCopy.data = BE.data
				if (oldpower != newCopy.power)
					newCopy.onPowerChange(oldpower, newCopy.power)

	proc/StaggeredCopyOther(var/datum/bioHolder/toCopy, progress = 1)
		if (progress > 10)
			src.CopyOther(toCopy)
			return

		if (mobAppearance)
			mobAppearance.StaggeredCopyOther(toCopy.mobAppearance, progress)
			mobAppearance.UpdateMob()

		if (progress >= 5)
			bloodType = toCopy.bloodType

		age += (toCopy.age - age) / (11 - progress)

	proc/AddEffect(var/idToAdd, var/power = 0, var/timeleft = 0, var/do_stability = 1, var/magical = 0, var/safety = 0, scannable=0, innate = 0)
		//Adds an effect to this holder. Returns the newly created effect if succesful else 0.
		if(issilicon(src.owner))
			return 0

		if(HasEffect(idToAdd))
			return 0

		var/datum/bioEffect/newEffect = bioEffectList[idToAdd]
		if(!newEffect)
			CRASH("Invalid bioEffect ID [idToAdd]")

		newEffect = new newEffect.type

		if(istype(newEffect))
			if(newEffect.effect_group)
				for(var/datum/bioEffect/curr_id as anything in effects)
					var/datum/bioEffect/curr = effects[curr_id]
					if(curr.effect_group == newEffect.effect_group)
						RemoveEffect(curr.id)
						break

			if(power) newEffect.power = power
			if(timeleft) newEffect.timeLeft = timeleft
			if(magical || innate)
				newEffect.curable_by_mutadone = FALSE
				newEffect.stability_loss = 0
				newEffect.can_scramble = FALSE
				newEffect.scanner_visibility = FALSE
				newEffect.can_reclaim = FALSE
				newEffect.degrade_to = null
				newEffect.can_copy = FALSE
				newEffect.is_magical = TRUE
			if(innate)
				newEffect.can_copy = TRUE
			if(scannable)
				newEffect.scanner_visibility = TRUE

			if(safety && istype(newEffect, /datum/bioEffect/power))
				// Only powers have safety ("synced" i.e. safe for user)
				var/datum/bioEffect/power/TEMP = newEffect
				TEMP.safety = safety

			effects[newEffect.id] = newEffect
			newEffect.owner = owner
			newEffect.holder = src
			if(owner)
				newEffect.OnAdd()

			if (do_stability)
				if(newEffect.degrade_to && !prob(lerp(clamp(src.genetic_stability+10, 0, 100), 100, 0.5)))
					newEffect.timeLeft = rand(20, 60)
					newEffect.degrade_after = TRUE

				src.genetic_stability -= newEffect.stability_loss
				src.genetic_stability = max(0,src.genetic_stability)

			if(owner)
				OutputGainOrLoseMsg(newEffect, TRUE)

			mobAppearance.UpdateMob()
			logTheThing(LOG_COMBAT, owner, "gains the [newEffect] mutation at [log_loc(owner)].")
			return newEffect

		return 0

	proc/AddEffectInstance(var/datum/bioEffect/BE,var/do_delay = 0,var/do_stability = 1)
		if (!istype(BE) || !owner || HasEffect(BE.id))
			return null

		if (do_delay && BE.add_delay > 0)
			sleep(BE.add_delay)

		src.AddEffectInstanceNoDelay(BE, do_stability)

	proc/AddEffectInstanceNoDelay(var/datum/bioEffect/BE,var/do_stability = 1)
		if (!istype(BE) || !owner || HasEffect(BE.id))
			return null

		if(BE.get_global_instance() == BE)
			CRASH("Cannot add a global bioEffect instance to a bioHolder!")
		if(BE.owner)
			CRASH("BioEffect [BE] [BE.type] already has an owner [identify_object(BE.owner)] but we attempted to add it to [identify_object(src.owner)]!")

		if(BE.effect_group)
			for(var/datum/bioEffect/curr_id as anything in effects)
				var/datum/bioEffect/curr = effects[curr_id]
				if(curr.effect_group == BE.effect_group)
					RemoveEffect(curr.id)
					break

		effects[BE.id] = BE
		BE.owner = owner
		BE.holder = src
		BE.OnAdd()

		if (do_stability)
			if(BE.degrade_to && !prob(lerp(clamp(src.genetic_stability+10, 0, 100), 100, 0.5)))
				BE.timeLeft = rand(20, 60)
				BE.degrade_after = TRUE

			src.genetic_stability -= BE.stability_loss
			src.genetic_stability = max(0,src.genetic_stability)

		OutputGainOrLoseMsg(BE, TRUE)
		mobAppearance.UpdateMob()
		logTheThing(LOG_COMBAT, owner, "gains the [BE] mutation at [log_loc(owner)].")
		return BE

	proc/RemoveEffect(var/id)
		//Removes an effect from this holder. Returns 1 on success else 0.
		if (src.disposed)
			return 0
		if (!HasEffect(id))
			return 0

		var/datum/bioEffect/D = effects[id]
		if (D && !D.removed)
			return src.RemoveEffectInstance(D)

		return 0

	proc/RemoveEffectInstance(var/datum/bioEffect/effect)
		effect.OnRemove()
		if (!effect.activated_from_pool)
			src.genetic_stability += effect.stability_loss
			src.genetic_stability = max(0,src.genetic_stability)
		effect.activated_from_pool = 0 //Fix for bug causing infinitely exploitable stability gain / loss

		if (owner)
			OutputGainOrLoseMsg(effect, FALSE)

		if (mobAppearance)
			mobAppearance.UpdateMob()
		logTheThing(LOG_COMBAT, owner, "loses the [effect] mutation at [log_loc(owner)].")
		return effects.Remove(effect.id)

	///ignoreMagic means "do not remove magical bioeffects"
	proc/RemoveAllEffects(var/type = null, var/ignoreMagic = FALSE)
		for(var/D as anything in effects)
			var/datum/bioEffect/BE = effects[D]
			if(BE && (isnull(type) || BE.effectType == type))
				if(!ignoreMagic || ignoreMagic && !BE.is_magical) // No removing hairy trait or job traits!
					RemoveEffect(BE.id)
					BE.owner = null
					BE.holder = null
					if(istype(BE, /datum/bioEffect/power))
						var/datum/bioEffect/power/BEP = BE
						BEP?.ability?.owner = null
		return 1

	proc/RemoveAllPoolEffects(var/type = null)
		for(var/D as anything in effectPool)
			var/datum/bioEffect/BE = effectPool[D]
			if(BE && (isnull(type) || BE.effectType == type))
				effectPool.Remove(D)
				BE.owner = null
				BE.holder = null
				if(istype(BE, /datum/bioEffect/power))
					var/datum/bioEffect/power/BEP = BE
					BEP?.ability?.owner = null
				//qdel(BE)
		return 1

	proc/HasAnyEffect(var/type = null)
		if(type)
			for(var/D as anything in effects)
				var/datum/bioEffect/BE = effects[D]
				if(BE && BE.effectType == type)
					return 1
		else
			return (effects.len ? 1 : 0)
		return 0

	proc/HasEffect(var/id)
		//Returns effect power if this holder has an effect with the given ID else 0.
		var/datum/bioEffect/B = effects[id]

		if(!B)
			.= 0
		else
			.= B.power

	proc/HasEffectInPool(var/id)
		return !isnull(effectPool[id])

	proc/HasEffectInEither(var/id)
		var/datum/bioEffect/B = effects[id]
		if(!B)
			B = effectPool[id]
		if (!B)
			return null
		else
			return 1

	proc/HasOneOfTheseEffects() //HasAnyEffect() was already taken :I
		var/list/temp = args & effects
		if(temp.len)
			var/datum/bioEffect/BE = effects[temp[1]]
			if(BE) return BE.power
		return 0

	proc/HasAllOfTheseEffects()
		var/tally = 0 //We cannot edit the args list directly, so just keep a count.
		for (var/datum/bioEffect/D as anything in effects)
			if (lowertext(D) in args)
				tally++

		return tally >= length(args)

	proc/GetASubtypeEffect(type)
		for(var/id as anything in effects)
			var/datum/bioEffect/BE = effects[id]
			if(istype(BE, type))
				return BE
		return null

	proc/GetEffect(var/id) //Returns the effect with the given ID if it exists else returns null.
		return effects[id]

	proc/GetEffectFromPool(var/id)
		return effectPool[id]

	proc/RandomEffect(var/type = "either", var/useProbability = 1, var/datum/dna_chromosome/toApply)
		//Adds a random effect to this holder. Argument controls which type. bad , good, either.
		if(check_target_immunity(owner, TRUE))
			return
		var/list/filtered = new/list()

		for(var/T in bioEffectList)
			var/datum/bioEffect/instance = bioEffectList[T]
			if(!instance || HasEffect(instance.id) || !instance.occur_in_genepools) continue
			switch(lowertext(type))
				if("good")
					if(instance.isBad)
						continue
				if("bad")
					if(!instance.isBad)
						continue
			filtered.Add(instance)
			filtered[instance] = instance.probability

		if(!filtered.len) return

		var/datum/bioEffect/E = null

		if(useProbability)
			E = weighted_pick(filtered)
		else
			E = pick(filtered)

		if (istype(toApply))
			E = E.GetCopy()
			toApply.apply(E)
			AddEffectInstance(E)
		else
			AddEffect(E.id)

		return E.id

	proc/DegradeRandomEffect()
		var/list/eligible_effects = list()
		var/datum/bioEffect/BE = null
		for (var/X as anything in effects)
			BE = effects[X]
			if (!BE.degrade_to) // doesn't turn into anything
				continue
			eligible_effects += BE

		if (!eligible_effects.len)
			// nothing to do
			return

		BE = pick(eligible_effects)
		AddEffect(BE.degrade_to, do_stability = 0)
		RemoveEffect(BE.id)

proc/GetBioeffectFromGlobalListByID(var/id)
	return bioEffectList[id]

proc/GetBioeffectResearchLevelFromGlobalListByID(var/id)
	if (!istext(id))
		return 0
	var/datum/bioEffect/BE = bioEffectList[id]

	if(istype(BE))
		. = BE.research_level
	else
		. = 0

///Bioholder type for when you need a bioholder that isn't strongly linked to an owner, uses a weakref to allow GC
/datum/bioHolder/unlinked
	var/datum/weakref/weak_owner = null
