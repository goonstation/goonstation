//Effect type defines in _std/_defines/bioeffect.dm

/datum/bioEffect
	var/name = "" //Name of the effect.
	var/id = "goddamn_it"   //Internal ID of the effect.
	var/desc = "" //Visible description of the effect.
	var/researched_desc = null // You get this in mutation research if you've activated the effect
	var/datum/bioEffect/global_instance = null // bioeffectlist version of this effect
	var/datum/bioEffect/power/global_instance_power = null //just a power casted version of global instance
	var/research_level = EFFECT_RESEARCH_NONE
	var/research_finish_time = 0

	var/effectType = EFFECT_TYPE_DISABILITY //Used to categorize effects. Mostly used for MutantRaces to prevent the mob from getting more than one.
	var/mutantrace_option = null
	var/isBad = 0         //Is this a bad effect? Used to determine which effects to use for certain things (radiation etc).

	var/probability = 100 //The probability that this will be selected when building the effect pool. Works like the weights in pick()
	var/blockCount = 2    //Amount of blocks generated. More will make this take longer to activate.
	var/blockGaps = 2     //Amount of gaps in the sequence. More will make this more difficult to activate since it will require more guessing or cross-referencing.

	var/lockProb = 5    //How likely each block is to be locked when there's locks present
	var/lockedGaps = 1    //How many base pairs in this sequence will need unlocking
	var/lockedDiff = 2    //How many characters in the code?
	var/lockedTries = 3   //How many attempts before it rescrambles?
	var/list/lockedChars = list("G","C") // How many different characters are used

	var/occur_in_genepools = 1
	var/scanner_visibility = 1
	var/secret = 0 // requires a specific research tech to see in genepools
	var/list/mob_exclusion = list() // this bio-effect won't occur in the pools of mob types in this list
	var/mob_exclusive = null // bio-effect will only occur in this mob type

	var/mob/owner = null  //Mob that owns this effect.
	var/datum/bioHolder/holder = null //Holder that contains this effect.

	var/msgGain = "" //Message shown when effect is added.
	var/msgLose = "" //Message shown when effect is removed.

	var/timeLeft = -1//Time left for temporary effects.

	var/variant = 1  //For effects with different variants.
	var/cooldown = 0 //For effects that come with verbs
	var/can_reclaim = 1 // Can this gene be turned into mats with the reclaimer?
	var/can_scramble = 1 // Can this gene be scrambled with the emitter?
	var/can_copy = 1 //Is this gene copied over on bioHolder transfer (i.e. cloning?)
	var/can_research = 1 // If zero, it must be researched via brute force
	var/can_make_injector = 1 // Guess.
	var/req_mut_research = null // If set, need to research the mutation before you can do anything w/ this one
	var/reclaim_mats = 10 // Materials returned when this gene is reclaimed
	var/reclaim_fail = 5 // Chance % for a reclamation of this gene to fail
	var/curable_by_mutadone = 1
	var/stability_loss = 0
	var/activated_from_pool = 0
	var/altered = 0
	var/add_delay = 0
	var/wildcard = 0
	var/degrade_to = null // what this mutation turns into if stability is too low

	var/datum/dnaBlocks/dnaBlocks = null

	var/data = null //Should be used to hold custom user data or it might not be copied correctly with injectors and all these things.
	var/image/overlay_image = null
	var/acceptable_in_mutini = 1 // can this effect happen when someone drinks some mutini? we're gunna try this at

	var/removed = 0


	var/icon = 'icons/mob/genetics_powers.dmi'
	var/icon_state = "unknown"

	New(var/for_global_list = 0)
		if (!for_global_list)
			global_instance = bioEffectList[src.id]
			if (istype(global_instance, /datum/bioEffect/power))
				global_instance_power = global_instance
		dnaBlocks = new/datum/dnaBlocks(src)
		return ..()

	disposing()
		if(src.holder)
			src.holder.RemovePoolEffect(src)
			src.holder.RemoveEffect(src.id)
		if(!removed)
			src.OnRemove()
		holder = null
		owner = null
		if(dnaBlocks)
			dnaBlocks.dispose()
		dnaBlocks = null
		..()

	proc/OnAdd()     //Called when the effect is added.
		removed = 0
		if(overlay_image)
			if(isliving(owner))
				var/mob/living/L = owner
				L.UpdateOverlays(overlay_image, id)
		return

	proc/OnRemove()  //Called when the effect is removed.
		removed = 1
		if(overlay_image)
			if(isliving(owner))
				var/mob/living/L = owner
				L.UpdateOverlays(null, id)
		return

	proc/OnMobDraw() //Called when the overlays for the mob are drawn. Children should NOT run when this returns 1
		return removed

	proc/OnLife()    //Called when the life proc of the mob is called. Children should NOT run when this returns 1
		return removed

	proc/GetCopy()
		//Gets a copy of this effect. Used to build local effect pool from global instance list.
		//Please don't use this for anything else as it might not work as you think it should.
		var/datum/bioEffect/E = new src.type()
		E.dnaBlocks.blockList = src.dnaBlocks.blockList
		//Since we assume that the effect being copied is the one in the global pool we copy
		//a REFERENCE to its correct sequence into the new instance.
		return E

	proc/get_global_instance()
		if (istype(global_instance))
			return global_instance
		else
			var/datum/bioEffect/BE = bioEffectList[src.id]
			if (istype(BE))
				return BE
			else
				return null

/datum/dnaBlocks
	var/datum/bioEffect/owner = null
	var/list/blockList = new/list()
	//List of CORRECT blocks for this mutation. This is global and should not be modified since it represents the correct solution.
	var/list/blockListCurr = new/list()
	// List of CURRENT blocks for this mutation. This is local and represents the research people are doing.

	New(var/holder)
		owner = holder
		return ..()

	disposing()
		owner = null
		blockList = null
		blockListCurr = null
		..()

	proc/sequenceCorrect()
		if(blockList.len != blockListCurr.len)
			//Things went completely and entirely wrong and everything is broken HALP.
			//Some dickwad probably messed with the global sequence.
			return 0
		for(var/i=0, i < blockList.len, i++)
			var/datum/basePair/correct = blockList[i+1]
			var/datum/basePair/current = blockListCurr[i+1]
			if(correct.bpp1 != current.bpp1 || correct.bpp2 != current.bpp2) //NOPE
				return 0
		return 1

	proc/pairCorrect(var/pair_index)
		if(blockList.len != blockListCurr.len || !pair_index)
			return 0
		var/datum/basePair/correct = blockList[pair_index]
		var/datum/basePair/current = blockListCurr[pair_index]
		if(correct.bpp1 != current.bpp1 || correct.bpp2 != current.bpp2) //NOPE
			return 0
		return 1

	proc/ModBlocks() //Gets the normal sequence for this mutation and then "corrupts" it locally.
		for(var/datum/basePair/bp in blockList)
			var/datum/basePair/bpNew = new()
			bpNew.bpp1 = bp.bpp1
			bpNew.bpp2 = bp.bpp2
			blockListCurr.Add(bpNew)

		for(var/datum/basePair/bp in blockListCurr)
			if(prob(33))
				if(prob(50))
					bp.bpp1 = "?"
				else
					bp.bpp2 = "?"
				bp.style = "X"


		var/list/gapList = new/list()
		//Make sure you don't have more gaps than basepairs or youll get an error.
		//But at that point the mutation would be unsolvable.

		for(var/i=0, i<owner.blockGaps, i++)
			var/datum/basePair/bp = pick(blockListCurr - gapList)
			gapList.Add(bp)
			bp.bpp1 = "?"
			bp.bpp2 = "?"
			bp.style = "X"

		for(var/i=0, i<owner.lockedGaps, i++)
			if (!prob(owner.lockProb))
				continue
			var/datum/basePair/bp = pick(blockListCurr - gapList)
			gapList.Add(bp)

			bp.lockcode = ""
			for (var/c = owner.lockedDiff, c > 0, c--)
				bp.lockcode += pick(owner.lockedChars)
			bp.locktries = owner.lockedTries

			var/diff = 1
			if (owner.req_mut_research)
				diff = 0
			else
				var/difficulty = round((owner.lockedDiff ** owner.lockedChars.len) / owner.lockedTries)
				switch(difficulty)
					if(11 to 20) diff = 2
					if(21 to 30) diff = 3
					if(31 to 50) diff = 4
					if(51 to INFINITY) diff = 5

			bp.bpp1 = "?"
			bp.bpp2 = "?"
			bp.style = "[diff]"
			bp.marker = "locked"

		return sequenceCorrect()

	proc/GenerateBlocks() //Generate DNA blocks. This sequence will be used globally.
		for(var/i=0, i < owner.blockCount, i++)
			for(var/a=0, a < 4, a++) //4 pairs per block.
				var/S = pick("G", "T", "C" , "A")
				var/datum/basePair/B = new()
				B.bpp1 = S
				switch(S)
					if("G")
						B.bpp2 = "C"
					if("C")
						B.bpp2 = "G"
					if("T")
						B.bpp2 = "A"
					if("A")
						B.bpp2 = "T"
				blockList.Add(B)
		return

	proc/ChangeAllMarkers(var/sprite_state)
		if(!istext(sprite_state))
			sprite_state = "white"
		for(var/datum/basePair/bp in blockListCurr)
			bp.marker = sprite_state
			bp.style = ""
		return

/datum/basePair
	var/bpp1 = ""
	var/bpp2 = ""
	var/marker = "green"
	var/style = ""
	var/lockcode = ""
	var/locktries = 0

/obj/screen/ability/topBar/genetics
	tens_offset_x = 19
	tens_offset_y = 7
	secs_offset_x = 23
	secs_offset_y = 7

	clicked(parameters)
		var/mob/living/user = usr

		if (!istype(user) || !istype(owner))
			boutput(user, "<span class='alert'>Oh christ something's gone completely batshit. Report this to a coder.</span>")
			return

		if (!owner.cooldowncheck())
			boutput(user, "<span class='alert'>That ability is on cooldown for [round((owner.last_cast - world.time) / 10)] seconds.</span>")
			return

		if (!owner.targeted)
			owner.handleCast()
			return
		else
			user.targeting_ability = owner
			user.update_cursor()

	get_controlling_mob()
		if (!istype(owner,/datum/targetable/geneticsAbility/))
			return null
		var/datum/targetable/geneticsAbility/GA = owner
		var/mob/M = GA.owner
		if (!istype(M) || !M.client)
			return null
		return M

/datum/targetable/geneticsAbility
	icon = 'icons/mob/genetics_powers.dmi'
	icon_state = "template"
	last_cast = 0
	targeted = 1
	target_anything = 1
	var/has_misfire = 1
	var/success_prob_min_cap = 30
	var/can_act_check = 1
	var/needs_hands = 1
	var/datum/bioEffect/power/linked_power = null
	var/mob/living/owner = null

	New()
		var/obj/screen/ability/topBar/genetics/B = new /obj/screen/ability/topBar/genetics(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.name = src.name
		B.desc = src.desc
		B.owner = src
		src.object = B

	disposing()
		owner = null
		linked_power = null
		..()

	doCooldown()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			last_cast = world.time + linked_power.cooldown
			if (linked_power.cooldown > 0)
				SPAWN_DBG(linked_power.cooldown)
					if (src && H && H.hud)
						H.hud.update_ability_hotbar()

	tryCast(atom/target)
		if (can_act_check && !can_act(owner, needs_hands))
			return 999
		if (last_cast > world.time)
			boutput(holder.owner, "<span class='alert'>That ability is on cooldown for [round((last_cast - world.time) / 10)] seconds.</span>")
			return 999

		if (has_misfire)
			var/success_prob = 100
			if (ishuman(owner))
				var/mob/living/carbon/human/H = owner
				if (H.bioHolder)
					var/datum/bioHolder/BH = H.bioHolder
					success_prob = BH.genetic_stability
					success_prob = max(success_prob_min_cap,min(success_prob,100))

			if (prob(success_prob))
				. = cast(target)
			else
				. = cast_misfire(target)
		else
			. = cast(target)

	handleCast(atom/target)
		var/result = tryCast(target)
		if (result && result != 999)
			last_cast = 0 // reset cooldown
		else if (result != 999)
			doCooldown()
		afterCast()

	cast(atom/target)
		if (!owner)
			return 1
		if (!linked_power)
			return 1
		if (ismob(target))
			logTheThing("combat", owner, target, "used the [linked_power.name] power on [constructTarget(target,"combat")].")
		else if (target)
			logTheThing("combat", owner, null, "used the [linked_power.name] power on [target].")
		else
			logTheThing("combat", owner, null, "used the [linked_power.name] power.")
		return 0

	proc/cast_misfire(atom/target)
		if (!owner)
			return 1
		if (!linked_power)
			return 1
		if (ismob(target))
			logTheThing("combat", owner, target, "misfired the [linked_power.name] power on [constructTarget(target,"combat")].")
		else if (target)
			logTheThing("combat", owner, null, "misfired the [linked_power.name] power on [target].")
		else
			logTheThing("combat", owner, null, "misfired the [linked_power.name] power.")
		return 0

	afterCast()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H && H.hud)
				H.hud.update_ability_hotbar()
		return 0
