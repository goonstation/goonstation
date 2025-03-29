//Effect type defines in _std/_defines/bioeffect.dm

//If the icon sprite sheet is changed, also update:
// tgui/packages/tgui/assets/genetics_powers.png
// tgui/packages/tgui/components/GeneIcon.scss

ABSTRACT_TYPE(/datum/bioEffect)
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

	var/tmp/mob/owner = null  //Mob that owns this effect.
	var/tmp/datum/bioHolder/holder = null //Holder that contains this effect.

	var/msgGain = "" //Message shown when effect is added.
	var/msgLose = "" //Message shown when effect is removed.

	var/timeLeft = -1//Time left for temporary effects.

	var/cooldown = 0 //For effects that come with verbs
	var/can_reclaim = 1 // Can this gene be turned into mats with the reclaimer?
	var/can_scramble = 1 // Can this gene be scrambled with the emitter?
	var/can_copy = 1 //Is this gene copied over on bioHolder transfer (i.e. cloning?)
	var/can_research = 1 // If zero, it must be researched via brute force
	var/can_make_injector = 1 // Guess.
	var/req_mut_research = null // If set, need to research the mutation before you can do anything w/ this one
	var/reclaim_mats = 10 // Materials returned when this gene is reclaimed
	var/reclaim_fail = 5 // Chance % for a reclamation of this gene to fail
	var/curable_by_mutadone = TRUE //! if 0/FALSE, we cant mutadone this - reinforced, magic genes and anti-toxins use this
	var/is_magical = FALSE //! only for trait genes/similar, we really dont want to lose this
	var/stability_loss = 0
	var/tmp/activated_from_pool = 0
	var/altered = 0
	var/add_delay = 0
	var/wildcard = 0
	var/power = 1
	var/safety = 0
	var/degrade_to = null // what this mutation turns into if stability is too low
	///if this mutation should degrade after timing out
	var/degrade_after = FALSE

	///groups of mutually exclusive bioeffects
	var/effect_group = null

	var/datum/dnaBlocks/dnaBlocks = null

	var/data = null //Should be used to hold custom user data or it might not be copied correctly with injectors and all these things.
	var/image/overlay_image = null
	var/acceptable_in_mutini = 1 // can this effect happen when someone drinks some mutini? we're gunna try this at

	var/removed = 0

	var/icon = 'icons/mob/genetics_powers.dmi'
	var/icon_state = "unknown"

	New(for_global_list = 0)
		if (!for_global_list)
			global_instance = bioEffectList[src.id]
			if (istype(global_instance, /datum/bioEffect/power))
				global_instance_power = global_instance
		dnaBlocks = new/datum/dnaBlocks(src)
		. = ..()

	disposing()
		src.global_instance = null
		src.global_instance_power = null
		if(src.holder)
			src.holder.RemovePoolEffect(src)
			src.holder.RemoveEffect(src.id)
		if(!removed && src.owner)
			src.OnRemove()
		QDEL_NULL(src.dnaBlocks)
		holder = null
		owner = null
		..()

	/// Called when the effect is added.
	proc/OnAdd()
		SHOULD_CALL_PARENT(TRUE)
		removed = 0
		if(overlay_image)
			if(isliving(owner))
				var/mob/living/L = owner
				L.AddOverlays(overlay_image, id)

	/// Called when the effect is removed.
	/// Returns FALSE if the holder is being deleted, TRUE otherwise.
	proc/OnRemove()
		SHOULD_CALL_PARENT(TRUE)
		. = TRUE
		removed = 1
		if(overlay_image)
			if(isliving(owner))
				var/mob/living/L = owner
				L.ClearSpecificOverlays(id)
		if (QDELETED(src.holder))
			return FALSE

	/// Called when the overlays for the mob are drawn. Children should NOT run when this returns 1
	proc/OnMobDraw()
		SHOULD_CALL_PARENT(TRUE)
		return removed

	/// Called when the life proc of the mob is called. Children should NOT run when this returns 1
	proc/OnLife(var/mult)
		SHOULD_CALL_PARENT(TRUE)
		return removed || QDELETED(owner)

	/// Gets a copy of this effect. Used to build local effect pool from global instance list.
	/// Please don't use this for anything else as it might not work as you think it should.
	proc/GetCopy()

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

	proc/onPowerChange(oldval, newval)
		return

	onVarChanged(variable, oldval, newval)
		. = ..()
		if(variable == "power")
			src.onPowerChange(oldval, newval)

/datum/dnaBlocks
	var/datum/bioEffect/owner = null
	/// List of CORRECT blocks for this mutation. This is global and should not be modified since it represents the correct solution.
	var/list/datum/basePair/blockList = list()
	/// List of CURRENT blocks for this mutation. This is local and represents the research people are doing.
	var/list/datum/basePair/blockListCurr = list()

	New(holder)
		owner = holder
		return ..()

	disposing()
		owner = null
		blockList = null
		blockListCurr = null
		..()

	proc/sequenceCorrect()
		if(length(blockList) != length(blockListCurr))
			//Things went completely and entirely wrong and everything is broken HALP.
			//Some dickwad probably messed with the global sequence.
			return 0
		for(var/i=0, i < blockList.len, i++)
			var/datum/basePair/correct = blockList[i+1]
			var/datum/basePair/current = blockListCurr[i+1]
			if(correct.bpp1 != current.bpp1 || correct.bpp2 != current.bpp2) //NOPE
				return FALSE
		return TRUE

	proc/pairCorrect(var/pair_index)
		if(blockList.len != blockListCurr.len || !pair_index)
			return FALSE
		var/datum/basePair/correct = blockList[pair_index]
		var/datum/basePair/current = blockListCurr[pair_index]
		if(correct.bpp1 != current.bpp1 || correct.bpp2 != current.bpp2) //NOPE
			return FALSE
		return TRUE

	proc/ModBlocks() //Gets the normal sequence for this mutation and then "corrupts" it locally.
		for(var/datum/basePair/bp as anything in blockList)
			var/datum/basePair/bpNew = new()
			bpNew.bpp1 = bp.bpp1
			bpNew.bpp2 = bp.bpp2
			blockListCurr.Add(bpNew)

		for(var/datum/basePair/bp as anything in blockListCurr)
			if(prob(33))
				if(prob(50))
					bp.bpp1 = "?"
				else
					bp.bpp2 = "?"
				bp.style = "X"


		var/list/gapList = new/list()
		//Make sure you don't have more gaps than basepairs or youll get an error.
		//But at that point the mutation would be unsolvable.

		if(src.owner.blockGaps > length(src.blockListCurr))
			CRASH("bioEffect [owner.name] has [owner.blockGaps] block gaps but only [length(blockListCurr)] blocks ([json_encode(blockListCurr)])")

		for(var/i=0, i < owner.blockGaps, i++)
			var/datum/basePair/bp = pick(blockListCurr - gapList)
			gapList.Add(bp)
			bp.bpp1 = "?"
			bp.bpp2 = "?"
			bp.style = "X"

		for(var/i=0, i < owner.lockedGaps, i++)
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

	/// Generate DNA blocks. This sequence will be used globally.
	proc/GenerateBlocks()
		for(var/i in 1 to owner.blockCount)
			for(var/j in 1 to 4) //4 pairs per block.
				var/symbol = pick("G", "T", "C" , "A")
				var/datum/basePair/B = new()
				B.bpp1 = symbol
				switch(symbol)
					if("G")
						B.bpp2 = "C"
					if("C")
						B.bpp2 = "G"
					if("T")
						B.bpp2 = "A"
					if("A")
						B.bpp2 = "T"
				blockList.Add(B)

	proc/ChangeAllMarkers(var/sprite_state)
		if(!istext(sprite_state))
			sprite_state = "white"
		for(var/datum/basePair/bp as anything in blockListCurr)
			bp.marker = sprite_state
			bp.style = ""

/datum/basePair
	var/bpp1 = ""
	var/bpp2 = ""
	var/marker = "green"
	var/style = ""
	var/lockcode = ""
	var/locktries = 0

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

	disposing()
		owner = null
		linked_power = null
		..()


	castcheck(atom/target)
		if (!owner)
			return FALSE
		if (!linked_power)
			return FALSE
		if (can_act_check && !can_act(owner, needs_hands))
			return FALSE
		if (targeted && GET_DIST(src.holder?.owner, target) > src.max_range)
			boutput(src.holder?.owner, SPAN_ALERT("[target] is too far away."))
			return FALSE
		return ..()

	handleCast(atom/target, params)
		if (src.linked_power) //paranoia check to keep them synched
			src.cooldown = src.linked_power.cooldown
		..()

	cast(atom/target)
		if (!has_misfire)
			return ..(target)
		var/success_prob = 100
		success_prob = src.linked_power.holder.genetic_stability
		success_prob = lerp(clamp(success_prob, 0, 100), 100, success_prob_min_cap/100)
		if (prob(success_prob))
			return ..(target)
		else
			return cast_misfire(target)

	logCast(atom/target)
		if (target)
			logTheThing(LOG_COMBAT, src.holder?.owner, "used the [linked_power.name] power on [constructTarget(target,"combat")] at [log_loc(target)].")
		else if (!linked_power.ability_path:targeted)
			logTheThing(LOG_COMBAT, src.holder?.owner, "used the [linked_power.name] power at [log_loc(src.holder?.owner)].")

	proc/cast_misfire(atom/target)
		if (target)
			logTheThing(LOG_COMBAT, owner, "misfired the [linked_power.name] power on [constructTarget(target,"combat")] at [log_loc(target)].")
		else
			logTheThing(LOG_COMBAT, owner, "misfired the [linked_power.name] power at [log_loc(owner)].")
		return 0


/datum/targetable/geneticsAbility/wrapper
	var/wrapped_ability = null
	var/datum/targetable/ability = null
	var/list/override_params

	New(datum/abilityHolder/holder)
		ability = new wrapped_ability(holder)
		src.holder = holder
		src.name = ability.name
		src.desc = ability.desc
		src.disabled = ability.disabled
		if( !src.cooldown ) src.cooldown = ability.cooldown
		if( !src.max_range) src.max_range = ability.max_range
		if( !src.start_on_cooldown ) src.start_on_cooldown = ability.start_on_cooldown

		if(override_params && islist(override_params))
			for(var/key in override_params)
				if(hasvar(ability, key) && !(key in src.vars) && !isatom(override_params[key]))
					ability.vars[key] = override_params[key]

		src.pointCost = ability.pointCost
		src.special_screen_loc = ability.special_screen_loc
		src.helpable = ability.helpable

		src.cd_text_color = ability.cd_text_color
		src.copiable = ability.copiable
		src.targeted = ability.targeted
		src.target_anything = ability.target_anything
		src.target_in_inventory = ability.target_in_inventory
		src.target_nodamage_check = ability.target_nodamage_check
		src.target_ghosts = ability.target_ghosts
		src.target_selection_check = ability.target_selection_check
		src.lock_holder = ability.lock_holder
		src.ignore_holder_lock = ability.ignore_holder_lock
		src.restricted_area_check = ability.restricted_area_check
		src.check_range = ability.check_range
		src.sticky = ability.sticky
		src.ignore_sticky_cooldown = ability.ignore_sticky_cooldown
		src.interrupt_action_bars = ability.interrupt_action_bars
		src.cooldown_after_action = ability.cooldown_after_action
		src.action_key_number = ability.action_key_number
		src.waiting_for_hotkey = ability.waiting_for_hotkey
		src.theme = ability.theme
		src.tooltip_flags = ability.tooltip_flags

		..()

		if (!src.icon || !src.icon_state)
			src.object.icon = ability.icon
			src.object.icon_state = ability.icon_state
		src.object.name = ability.name
		src.object.desc = ability.desc

	onAttach(datum/abilityHolder/H)
		. = ..()
		var/atom/movable/screen/ability/topBar/B = src.object
		var/icon/overlay_icon = icon(src.ability.icon,src.ability.icon_state)
		overlay_icon.Blend(icon('icons/mob/genetics_powers.dmi',"darkener"), ICON_ADD)
		B.UpdateOverlays(image(overlay_icon), "ability_overlay")

	onAttach(var/datum/abilityHolder/H)
		..()

	cast(atom/target)
		if (..())
			return 1
		. = ability.cast(target)

	handleCast(atom/target, params)
		. = ..()
		src.ability.last_cast = src.last_cast

	// Don't remove the holder.locked checks, as lots of people used lag and click-spamming
	// to execute one ability multiple times. The checks hopefully make it a bit more difficult.
	tryCast(atom/target, params)
		. = ability.tryCast(arglist(args))

	updateObject()
		. = ability.updateObject(arglist(args))

	castcheck(atom/target)
		. = ..() && ability.castcheck(arglist(args))

	afterCast()
		. = ability.afterCast(arglist(args))

	afterAction()
		. = ability.afterAction(arglist(args))

	Stat()
		updateObject(holder.owner)
		stat(null, object)
		. = ability.Stat(arglist(args))

	// See comment in /atom/movable/screen/ability (Convair880).
	target_reference_lookup()
		. = ability.target_reference_lookup(arglist(args))

	display_available()
		. = ..() && ability.display_available(arglist(args))

	flip_callback()
		. = ability.flip_callback(arglist(args))
