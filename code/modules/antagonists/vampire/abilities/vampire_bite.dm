/datum/abilityHolder/vampire/var/list/blood_tally
/datum/abilityHolder/vampire/var/const/max_take_per_mob = 250

/datum/abilityHolder/vampire/proc/tally_bite(var/mob/living/carbon/human/target, var/blood_amt_taken)
	if (!src.blood_tally)
		src.blood_tally = list()

	if (!(target in src.blood_tally))
		src.blood_tally[target] = 0

	src.blood_tally[target] += blood_amt_taken

/datum/abilityHolder/vampire/proc/can_take_blood_from(var/mob/living/carbon/human/target)
	. = TRUE
	if (src.blood_tally)
		if (target in src.blood_tally)
			.= src.blood_tally[target] < max_take_per_mob


/datum/abilityHolder/vampire/proc/can_bite(var/mob/living/carbon/human/target, is_pointblank = TRUE)
	var/datum/abilityHolder/vampire/holder = src
	var/mob/living/M = holder.owner
	var/datum/abilityHolder/vampire/H = holder

	if (!ishuman(target)) // Only humans use the blood system.
		boutput(M, "<span class='alert'>You can't seem to find any blood vessels.</span>")
		return FALSE
	else
		var/mob/living/carbon/human/humantarget = target
		if (istype(humantarget.mutantrace, /datum/mutantrace/vampiric_thrall))
			boutput(M, "<span class='alert'>You cannot drink the blood of a thrall.</span>")
			return FALSE

	if (M == target)
		boutput(M, "<span class='alert'>Why would you want to bite yourself?</span>")
		return FALSE

	if (ismobcritter(M) && !istype(H))
		boutput(M, "<span class='alert'>Critter mobs currently don't have to worry about blood. Lucky you.</span>")
		return FALSE

	if (istype(H) && H.vamp_isbiting)
		if (vamp_isbiting != target)
			boutput(M, "<span class='alert'>You are already draining someone's blood!</span>")
			return FALSE

	if (is_pointblank && target.head && target.head.c_flags & (BLOCKCHOKE))
		boutput(M, "<span class='alert'>You need to remove [his_or_her(target)] headgear first.</span>")
		return FALSE

	if (check_target_immunity(target) == 1)
		target.visible_message("<span class='alert'><B>[M] bites [target], but fails to even pierce their skin!</B></span>")
		return FALSE

	if (isnpcmonkey(target))
		boutput(M, "<span class='alert'>Drink monkey blood?! That's disgusting!</span>")
		return FALSE

	if (!holder.can_take_blood_from(target))
		return FALSE

	if (isnpc(target))
		boutput(M, "<span class='alert'>The blood of this target would provide you with no sustenance.</span>")
		return FALSE

	return TRUE

/datum/abilityHolder/vampire/proc/do_bite(var/mob/living/carbon/human/HH, var/mult = 1)
	. = TRUE
	var/mob/living/carbon/human/M = src.owner

	if (HH.blood_volume <= 0)
		boutput(M, "<span class='alert'>This human is completely void of blood... Wow!</span>")
		return FALSE

	if (isdead(HH))
		if (prob(20))
			boutput(M, "<span class='alert'>The blood of the dead provides little sustenance...</span>")

		var/bitesize = 5 * mult
		src.change_vampire_blood(bitesize, 1)
		src.change_vampire_blood(bitesize, 0)
		src.tally_bite(HH,bitesize)
		if (HH.blood_volume < 20 * mult)
			HH.blood_volume = 0
		else
			HH.blood_volume -= 20 * mult

	else if (HH.traitHolder.hasTrait("training_chaplain"))
		if(istype(M))
			M.visible_message("<span class='alert'><b>[M]</b> begins to crisp and burn!</span>", "<span class='alert'>You drank the blood of a holy man! It burns!</span>")
			M.emote("scream")
			if (M.get_vampire_blood() >= 20 * mult)
				M.change_vampire_blood(-20 * mult, 0)
			else
				M.change_vampire_blood(0, 0, 1)
			M.TakeDamage("chest", 0, 30 * mult)

	else
		if (isvampire(HH))
			var/bitesize = 20 * mult
			if (HH.get_vampire_blood() >= bitesize)
				HH.change_vampire_blood(-bitesize, 0)
				HH.change_vampire_blood(-bitesize, 1) // Otherwise, two vampires could perpetually feed off of each other, trading blood endlessly.

				src.change_vampire_blood(bitesize, 0)
				src.change_vampire_blood(bitesize, 1)
				src.tally_bite(HH,bitesize)
				if (istype(src))
					src.blood_tracking_output()
				if (prob(50))
					boutput(M, "<span class='alert'>This is the blood of a fellow vampire!</span>")
			else
				HH.change_vampire_blood(0, 0, 1)
				boutput(M, "<span class='alert'>[HH] doesn't have enough blood left to drink.</span>")
				return 0
		else
			var/bitesize = 10 * mult
			src.change_vampire_blood(bitesize, 1)
			src.change_vampire_blood(bitesize, 0)
			src.tally_bite(HH,bitesize)
			if (HH.blood_volume < 20 * mult)
				HH.blood_volume = 0
			else
				HH.blood_volume -= 20 * mult

			// Vampire TEG also uses this ability, prevent runtimes
			if (ismob(src.owner))
				//vampires heal, thralls don't
				M.HealDamage("All", 3, 3)
				M.take_toxin_damage(-1)
				M.take_oxygen_deprivation(-1)

			if (mult >= 1) //mult is only 1 or greater during a pointblank true suck
				if (HH.blood_volume < 300 && prob(15))
					if (!HH.getStatusDuration("paralysis"))
						boutput(HH, "<span class='alert'>Your vision fades to blackness.</span>")
					HH.changeStatus("paralysis", 10 SECONDS)
				else
					if (prob(65))
						HH.changeStatus("weakened", 1 SECOND)
						HH.stuttering = min(HH.stuttering + 3, 10)

			src.blood_tracking_output()

	if (!can_take_blood_from(HH) && (mult >= 1) && isunconscious(HH))
		boutput(HH, "<span class='alert'>You feel your soul slipping away...</span>")
		HH.death(FALSE)

	src.check_for_unlocks()

	eat_twitch(src.owner)
	playsound(src.owner.loc, 'sound/items/drink.ogg', 5, 1, -15, pitch = 1.4) //tested to be audible for about 5 tiles, assuming quiet environment
	HH.was_harmed(M, special = "vamp")
	bleed(HH, 1, 3, get_turf(src.owner))

/datum/abilityHolder/vampiric_thrall/var/list/blood_tally
/datum/abilityHolder/vampiric_thrall/var/const/max_take_per_mob = 250

/datum/abilityHolder/vampiric_thrall/proc/can_take_blood_from(var/mob/living/carbon/human/target)
	. = TRUE
	if (src.blood_tally)
		if (target in src.blood_tally)
			.= src.blood_tally[target] < max_take_per_mob

/datum/abilityHolder/vampiric_thrall/proc/tally_bite(var/mob/living/carbon/human/target, var/blood_amt_taken)
	if (!src.blood_tally)
		src.blood_tally = list()

	if (!(target in src.blood_tally))
		src.blood_tally[target] = 0

	src.blood_tally[target] += blood_amt_taken

/datum/abilityHolder/vampiric_thrall/proc/can_bite(var/mob/living/carbon/human/target, is_pointblank = 1)
	var/datum/abilityHolder/vampiric_thrall/holder = src
	var/mob/living/M = holder.owner
	var/datum/abilityHolder/vampiric_thrall/H = holder

	if (!ishuman(target)) // Only humans use the blood system.
		boutput(M, "<span class='alert'>You can't seem to find any blood vessels.</span>")
		return FALSE
	else
		var/mob/living/carbon/human/humantarget = target
		if (istype(humantarget.mutantrace, /datum/mutantrace/vampiric_thrall))
			boutput(M, "<span class='alert'>You cannot drink the blood of a thrall.</span>")
			return FALSE

	if (M == target)
		boutput(M, "<span class='alert'>Why would you want to bite yourself?</span>")
		return FALSE

	if (ismobcritter(M) && !istype(H))
		boutput(M, "<span class='alert'>Critter mobs currently don't have to worry about blood. Lucky you.</span>")
		return FALSE

	if (istype(H) && H.vamp_isbiting)
		if (vamp_isbiting != target)
			boutput(M, "<span class='alert'>You are already draining someone's blood!</span>")
			return FALSE

	if (is_pointblank && target.head && target.head.c_flags & (BLOCKCHOKE))
		boutput(M, "<span class='alert'>You need to remove [his_or_her(target)] headgear first.</span>")
		return FALSE

	if (check_target_immunity(target) == 1)
		target.visible_message("<span class='alert'><B>[M] bites [target], but fails to even pierce their skin!</B></span>")
		return FALSE

	if (isnpcmonkey(target))
		boutput(M, "<span class='alert'>Drink monkey blood?! That's disgusting!</span>")
		return FALSE

	if (!holder.can_take_blood_from(target))
		return FALSE

	return TRUE

/datum/abilityHolder/vampiric_thrall/proc/do_bite(var/mob/living/carbon/human/HH, var/mult = 1)
	. = TRUE
	var/mob/living/carbon/human/M = src.owner
	var/datum/abilityHolder/vampiric_thrall/H = src


	if (HH.blood_volume <= 0)
		boutput(M, "<span class='alert'>This human is completely void of blood... Wow!</span>")
		return FALSE

	if (HH.decomp_stage > DECOMP_STAGE_NO_ROT)
		if (prob(20))
			boutput(M, "<span class='alert'>The blood of the rotten provides little sustenance...</span>")

		var/bitesize = 5 * mult
		M.change_vampire_blood(bitesize, 1)
		M.change_vampire_blood(bitesize, 0)
		H.tally_bite(HH,bitesize)
		if (HH.blood_volume < 20 * mult)
			HH.blood_volume = 0
		else
			HH.blood_volume -= 20 * mult

	else if (HH.bioHolder && HH.traitHolder.hasTrait("training_chaplain"))
		M.visible_message("<span class='alert'><b>[M]</b> begins to crisp and burn!</span>", "<span class='alert'>You drank the blood of a holy man! It burns!</span>")
		M.emote("scream")
		if (M.get_vampire_blood() >= 20 * mult)
			M.change_vampire_blood(-20 * mult, 0)
		else
			M.change_vampire_blood(0, 0, 1)
		M.TakeDamage("chest", 0, 30 * mult)

	else
		if (isvampire(HH))
			var/bitesize = 20 * mult
			if (HH.get_vampire_blood() >= bitesize)
				HH.change_vampire_blood(-bitesize, 0)
				HH.change_vampire_blood(-bitesize, 1) // Otherwise, two vampires could perpetually feed off of each other, trading blood endlessly.

				M.change_vampire_blood(bitesize, 0)
				M.change_vampire_blood(bitesize, 1)
				H.tally_bite(HH,bitesize)
				if (prob(50))
					boutput(M, "<span class='alert'>This is the blood of a fellow vampire!</span>")
			else
				HH.change_vampire_blood(0, 0, 1)
				boutput(M, "<span class='alert'>[HH] doesn't have enough blood left to drink.</span>")
				return 0
		else
			var/bitesize = 10 * mult
			M.change_vampire_blood(bitesize, 1)
			M.change_vampire_blood(bitesize, 0)
			H.tally_bite(HH,bitesize)
			if (HH.blood_volume < 20 * mult)
				HH.blood_volume = 0
			else
				HH.blood_volume -= 20 * mult
			if (mult >= 1) //mult is only 1 or greater during a pointblank true suck
				if (HH.blood_volume < 300 && prob(15))
					if (!HH.getStatusDuration("paralysis"))
						boutput(HH, "<span class='alert'>Your vision fades to blackness.</span>")
					HH.changeStatus("paralysis", 10 SECONDS)
				else
					if (prob(65))
						HH.changeStatus("weakened", 1 SECOND)
						HH.stuttering = min(HH.stuttering + 3, 10)

	if (!can_take_blood_from(HH) && (mult >= 1) && isunconscious(HH))
		boutput(HH, "<span class='alert'>You feel your soul slipping away...</span>")
		HH.death(FALSE)

	eat_twitch(src.owner)
	playsound(src.owner.loc, 'sound/items/drink.ogg', 5, 1, -15, pitch = 1.4) //tested to be audible for about 5 tiles, assuming quiet environment
	HH.was_harmed(M, special = "vamp")


/datum/targetable/vampire/vampire_bite
	name = "Bite Victim"
	desc = "Bite the victim's neck to drain them of blood."
	icon_state = "bite"
	targeted = TRUE
	target_nodamage_check = TRUE
	can_cast_while_cuffed = FALSE
	lock_holder = FALSE
	restricted_area_check = ABILITY_AREA_CHECK_VR_ONLY
	var/thrall = FALSE

	cast(mob/target)
		. = ..()
		actions.start(new/datum/action/bar/private/icon/vamp_blood_suc(src.holder.owner, src.holder, target, src), src.holder.owner)

	castcheck(atom/target)
		. = ..()
		var/mob/living/M = src.holder.owner

		if (actions.hasAction(M, "vamp_blood_suck_ranged"))
			boutput(M, "<span class='alert'>You are already performing a Blood action and cannot start a Bite.</span>")
			return TRUE

		if (isnpc(target))
			boutput(M, "<span class='alert'>The blood of this target would provide you with no sustenance.</span>")
			return TRUE

		boutput(M, "<span class='notice'>You bite [target] and begin to drain them of blood.</span>")
		target.visible_message("<span class='alert'><B>[M] bites [target]!</B></span>")

/datum/targetable/vampire/vampire_bite/thrall
	thrall = TRUE

/datum/action/bar/private/icon/vamp_blood_suc
	duration = 3 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "vamp_blood_suck"
	icon = 'icons/ui/actions.dmi'
	icon_state = "blood"
	bar_icon_state = "bar-vampire"
	border_icon_state = "border-vampire"
	color_active = "#d73715"
	color_success = "#f21b1b"
	color_failure = "#8d1422"
	var/mob/living/carbon/human/M
	var/datum/abilityHolder/vampire/H
	var/mob/living/carbon/human/HH
	var/datum/targetable/vampire/vampire_bite/B

	New(mob/user, datum/abilityHolder/vampire/vampabilityholder, mob/target, datum/targetable/vampire/vampire_bite/biteabil)
		M = user
		H = vampabilityholder
		HH = target
		B = biteabil
		..()
		if (B.thrall)
			duration *= 2


	onUpdate()
		..()
		if(BOUNDS_DIST(M, HH) > 0 || M == null || HH == null || B == null)
			interrupt(INTERRUPT_ALWAYS)
			return


	onStart()
		..()
		if(BOUNDS_DIST(M, HH) > 0 || M == null || HH == null || B == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!H.can_bite(HH, is_pointblank = 1))
			interrupt(INTERRUPT_ALWAYS)
			return

		if (istype(H))
			H.vamp_isbiting = HH

		HH.client?.images += bar.img
		HH.client?.images += border.img
		HH.client?.images += icon_image

		src.loopStart()

	loopStart()
		..()
		logTheThing(LOG_COMBAT, M, "bites [constructTarget(HH,"combat")]'s neck at [log_loc(M)].")
		return

	onEnd()
		if(BOUNDS_DIST(M, HH) > 0 || M == null || HH == null || B == null)
			..()
			interrupt(INTERRUPT_ALWAYS)
			src.end()
			return

		if (!H.do_bite(HH,mult = 1.5))
			..()
			interrupt(INTERRUPT_ALWAYS)
			src.end()
			return

		src.onRestart()

	onInterrupt() //Called when the action fails / is interrupted.
		if (state == ACTIONSTATE_RUNNING)
			if (HH.blood_volume < 0)
				boutput(M, "<span class='alert'>[HH] doesn't have enough blood left to drink.</span>")
			else if (!H.can_take_blood_from(H, HH))
				boutput(M, "<span class='alert'>You have drank your fill [HH]'s blood. It tastes all bland and gross now.</span>")
			else
				boutput(M, "<span class='alert'>Your feast was interrupted.</span>")

		src.end()

		..()

	onDelete()
		. = ..()
		HH.client?.images -= bar.img
		HH.client?.images -= border.img
		HH.client?.images -= icon_image

	proc/end()
		if (istype(H))
			H.vamp_isbiting = null
