/mob/proc/make_changeling()
	var/datum/abilityHolder/changeling/O = src.get_ability_holder(/datum/abilityHolder/changeling)
	if (O)
		return
	var/mob/living/L = src
	if(istype(L))
		L.blood_id = "bloodc"

	if (src.mind && !src.mind.is_changeling && (src.mind.special_role != "omnitraitor"))
		src.Browse(grabResource("html/traitorTips/changelingTips.html"),"window=antagTips;size=600x400;title=Antagonist Tips")

	var/datum/abilityHolder/changeling/C = src.add_ability_holder(/datum/abilityHolder/changeling)
	C.addAbility(/datum/targetable/changeling/abomination)
	C.addAbility(/datum/targetable/changeling/absorb)
	C.addAbility(/datum/targetable/changeling/devour)
	C.addAbility(/datum/targetable/changeling/mimic_voice)
	C.addAbility(/datum/targetable/changeling/monkey)
	C.addAbility(/datum/targetable/changeling/regeneration)
	C.addAbility(/datum/targetable/changeling/scream)
	C.addAbility(/datum/targetable/changeling/spit)
	C.addAbility(/datum/targetable/changeling/stasis)
	C.addAbility(/datum/targetable/changeling/sting/neurotoxin)
	C.addAbility(/datum/targetable/changeling/sting/lsd)
	C.addAbility(/datum/targetable/changeling/sting/dna)
	C.addAbility(/datum/targetable/changeling/transform)
	C.addAbility(/datum/targetable/changeling/morph_arm)
	C.addAbility(/datum/targetable/changeling/handspider)
	C.addAbility(/datum/targetable/changeling/eyespider)
	C.addAbility(/datum/targetable/changeling/legworm)
	C.addAbility(/datum/targetable/changeling/buttcrab)
	C.addAbility(/datum/targetable/changeling/hivesay)
	C.addAbility(/datum/targetable/changeling/boot)
	C.addAbility(/datum/targetable/changeling/give_control)

	if (src.mind)
		src.mind.is_changeling = C

	SPAWN_DBG (25) // Don't remove.
		if (src) src.assign_gimmick_skull()

	return

/obj/screen/ability/topBar/changeling
	clicked(params)
		var/datum/targetable/changeling/spell = owner
		var/datum/abilityHolder/holder = owner.holder

		if (!istype(spell))
			return
		if (!spell.holder)
			return

		if(params["shift"] && params["ctrl"])
			if(owner.waiting_for_hotkey)
				holder.cancel_action_binding()
				return
			else
				owner.waiting_for_hotkey = 1
				src.updateIcon()
				boutput(usr, "<span class='notice'>Please press a number to bind this ability to...</span>")
				return

		if (!isturf(owner.holder.owner.loc) && !spell.can_use_in_container)
			boutput(owner.holder.owner, "<span class='alert'>Using that in here will do just about no good for you.</span>")
			return
		if (spell.targeted && usr.targeting_ability == owner)
			usr.targeting_ability = null
			usr.update_cursor()
			return
		if (spell.targeted)
			if (world.time < spell.last_cast)
				return
			owner.holder.owner.targeting_ability = owner
			owner.holder.owner.update_cursor()
		else
			SPAWN_DBG(0)
				spell.handleCast()
		return

/datum/abilityHolder/changeling
	usesPoints = 1
	regenRate = 0
	tabName = "Changeling"
	notEnoughPointsMessage = "<span class='alert'>We are not strong enough to do this.</span>"
	var/list/absorbed_dna = list()
	var/in_fakedeath = 0
	var/absorbtions = 0
	var/list/hivemind = list()
	//If we relinquish control of the body to a subordinate.
	var/mob/dead/target_observer/hivemind_observer/master = null
	var/mob/dead/target_observer/hivemind_observer/temp_controller = null
	var/original_controller_name = null
	var/original_controller_real_name = null

	New(var/mob/living/M)
		..()
		if (M)
			var/datum/bioHolder/original = new/datum/bioHolder(M)
			original.CopyOther(M.bioHolder)

			absorbed_dna = list("[M.name]" = original)

	proc/addDna(var/mob/living/M, var/headspider_override = 0)
		var/datum/abilityHolder/changeling/O = M.get_ability_holder(/datum/abilityHolder/changeling)
		if (O)
			boutput(owner, "<span class='notice'>[M] was a changeling! We have absorbed their entire genetic structure!</span>")
			logTheThing("combat", owner, M, "absorbs %target% as a changeling [log_loc(owner)].")

			if (headspider_override != 1) // Headspiders shouldn't be free.
				src.points += M.dna_to_absorb // 10 regular points for their body...

			if (O.points > 0) // ...and then grab their DNA stockpile too.
				src.points = max(0, src.points + O.points)

			src.absorbtions++ // Same principle.
			for(var/D in O.absorbed_dna)
				src.absorbed_dna[D] = O.absorbed_dna[D]
				src.absorbtions++

			O.absorbed_dna = list()
			O.points = 0

			for(var/mob/H in O.hivemind)
				src.insert_into_hivemind(H)
			O.hivemind = list()

		else
			var/datum/bioHolder/original = new/datum/bioHolder(M)
			original.CopyOther(M.bioHolder)
			src.absorbed_dna[M.real_name] = original
			if (headspider_override != 1)
				src.points += M.dna_to_absorb
			src.absorbtions++
		src.insert_into_hivemind(M)

	//Insert a mob into the hivemind by creating a hivemind_observer for them and transferring Mind
	proc/insert_into_hivemind(var/mob/victim, var/restore_name=0)
		var/mob/dead/target_observer/hivemind_observer/obs
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		//Just inserting a random chumpler (regular human)
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		if (iscarbon(victim))
			var/mob/living/M = victim
			obs = new(src.owner)
			obs.corpse = null

			//Set up name and vision
			obs.name = M.name
			obs.real_name = M.real_name
			if (src.owner.invisibility)
				obs.see_invisible = src.owner.invisibility

			//Transfer the control from the victim to the hivemind member
			if (M.mind)
				M.mind.transfer_to(obs)
			else if (M.client)
				obs.client = M.client
			else if (M.ghost && !(M.ghost.mind && M.ghost.mind.dnr)) //Heh, death is no escape // (except sometimes when the ghost really doesn't want to come back and has DNR set HHHHEH)
				var/mob/dead/ghost = M.ghost
				ghost.show_text("<span class='red'>You feel yourself torn away from the afterlife and into another consciousness!</span>")
				if(ghost.mind)
					ghost.mind.transfer_to(obs)
				else if (ghost.client)
					obs.client = ghost.client
				else if (ghost.key)
					obs.key = ghost.key
				else
					return
				M.ghost = null
			else
				return

			/*
			if(victim != src.owner)
				obs.corpse = M
				M.ghost = obs
			*/
			obs.set_owner(src)
		else if (istype(victim,/mob/dead/target_observer/hivemind_observer))
			obs = victim

			obs.set_owner(src)
		else if (istype(victim,/mob/dead))
			if(istype(victim,/mob/dead/target_observer)) // Gotta do some shuffling about
				var/datum/mind/M = victim.mind
				victim.ghostize()
				victim = M.current
			var/mob/dead/ghost = victim
			if(istype(ghost, /mob/dead/observer)) // fuck corpse not being defined on /mob/dead
				var/mob/dead/observer/O = ghost
				if(O.corpse)
					O.corpse.ghost = null
					O.corpse = null
			else if(istype(ghost, /mob/dead/target_observer))
				var/mob/dead/target_observer/O = ghost
				if(O.corpse)
					O.corpse.ghost = null
					O.corpse = null
			obs = new(src.owner)
			obs.corpse = null
			obs.name = ghost.name
			obs.real_name = ghost.real_name
			ghost.show_text("<span class='red'>You feel yourself torn away from the afterlife and into another consciousness!</span>")
			if(ghost.mind)
				ghost.mind.transfer_to(obs)
			else if (ghost.client)
				obs.client = ghost.client
			else if (ghost.key)
				obs.key = ghost.key
			else
				return

			obs.set_owner(src)

		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		//	Inserting a handspider (or eyespider)
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		else if (istype(victim, /mob/living/critter/changeling))
			var/mob/living/critter/changeling/spider = victim
			obs = new(src.owner)
			//Set up observer name
			obs.name = victim.name
			obs.real_name = victim.real_name
			//Set up corpse and ghost stuff
			obs.corpse = victim
			victim.ghost = obs

			//Handle vision
			if (src.owner.invisibility)
				obs.see_invisible = src.owner.invisibility
			//Transfer the mind and control to the new observer
			if (victim.mind)
				victim.mind.transfer_to(obs)
			else if (victim.client)
				victim.client.mob = obs

			//Assign an owner to the observer
			obs.set_owner(src)

			src.hivemind -= spider
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		//	Inserting an existing hivemind_observer
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		if(restore_name)
			obs.name = original_controller_name
			obs.real_name = original_controller_real_name

			original_controller_name = null
			original_controller_real_name = null
		obs.can_exit_hivemind_time = world.time + 1 MINUTE
		return obs

	proc/return_control_to_master()
		if(master)
			logTheThing("combat", master, owner, "has retaken control of the changeling body from %target%.")
			//Return the controller to the hivemind, with their original names.
			boutput(src.owner,"<h2><span class='combat bold'>[master] has retaken control of the flesh!</span></h2>")
			src.owner.mind.transfer_to(temp_controller)
			//src.insert_into_hivemind(src.owner, 1)
			temp_controller = null
			boutput(master, __blue("We retake control of our form!"))
			master.mind.transfer_to(owner)
			master = null
			return 1


	proc/reassign_hivemind_target_mob()
		if(src.owner)
			for (var/mob/dead/target_observer/hivemind_observer/O in src.hivemind)
				O.set_observe_target(src.owner)

	onAbilityStat()
		..()
		//On Changeling tab
		stat("Absorbed DNA:", absorbtions)
		stat("DNA Points:", points)


	onAbilityHolderInstanceAdd()
		..()
		for(var/mob/dead/target_observer/hivemind_observer/HO in hivemind)
			src.insert_into_hivemind(HO)

// ----------------------------------------
// Generic abilities that critters may have
// ----------------------------------------

/datum/targetable/changeling
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "template" // No longer ToDo thanks to Sundance420.
	cooldown = 0
	last_cast = 0
	var/abomination_only = 0
	var/human_only = 0
	var/can_use_in_container = 0
	preferred_holder_type = /datum/abilityHolder/changeling

	New()
		var/obj/screen/ability/topBar/changeling/B = new /obj/screen/ability/topBar/changeling(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B

	updateObject()
		..()
		if (!src.object)
			src.object = new /obj/screen/ability/topBar/changeling()
			object.icon = src.icon
			object.owner = src
		if (src.last_cast > world.time)
			var/pttxt = ""
			if (pointCost)
				pttxt = " \[[pointCost]\]"
			object.name = "[src.name][pttxt] ([round((src.last_cast-world.time)/10)])"
			object.icon_state = src.icon_state + "_cd"
		else
			var/pttxt = ""
			if (pointCost)
				pttxt = " \[[pointCost]\]"
			object.name = "[src.name][pttxt]"
			object.icon_state = src.icon_state

	proc/incapacitationCheck()
		var/mob/living/M = holder.owner
		var/datum/abilityHolder/changeling/H = holder
		if (istype(H) && H.in_fakedeath)
			return 1
		return M.stat || M.getStatusDuration("paralysis")

	castcheck()
		if (incapacitationCheck())
			boutput(holder.owner, __red("We cannot use our abilities while incapacitated."))
			return 0
		if (!human_only && !abomination_only)
			return 1
		var/mob/living/carbon/human/H = holder.owner
		if (istype(H))
			if (human_only && (isabomination(H) || ismonkey(H)))
				return 0
			else if (abomination_only && !isabomination(H))
				return 0
			else
				return 1//what could possibly go wrong
		return 0

	Stat()
		if (!human_only && !abomination_only)
			..()
		var/mob/living/carbon/human/H = holder.owner
		if (istype(H))
			if (human_only && !isabomination(H) && !ismonkey(H))
				..()
			else if (abomination_only && isabomination(H))
				..()

	display_available()
		.= 1
		if (human_only || abomination_only)
			.= 0
			var/mob/living/carbon/human/H = holder.owner
			if (istype(H))
				if (human_only && !isabomination(H) && !ismonkey(H))
					.= 1
				else if (abomination_only && isabomination(H))
					.= 1
