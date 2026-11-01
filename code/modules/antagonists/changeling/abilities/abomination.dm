/datum/targetable/changeling/abomination
	name = "Horror Form"
	desc = "Become something much more powerful."
	icon_state = "horror"
	cooldown = 0
	targeted = 0
	target_anything = 0
	can_use_in_container = 1

	incapacitationCheck()
		return 0

	cast(atom/target)
		if (..())
			return 1

		var/mob/living/carbon/human/H = holder.owner
		if (isabomination(H))
			if (tgui_alert(H,"Are we sure?","Exit Horror Form?",list("Yes","No")) != "Yes")
				return 1
			H.revert_from_horror_form()
		else if (ismonkey(H))
			boutput(H, "We cannot transform in this form.")
			return 1
		else
			if (actions.hasAction(holder.owner, /datum/action/bar/private/icon/changelingHorrorForm))
				boutput(holder.owner, SPAN_ALERT("We are already transforming!"))
				return 1
			if (holder.points < 15)
				boutput(holder.owner, SPAN_ALERT("We're not strong enough to maintain the form."))
				return 1
			if (tgui_alert(H,"Are we sure?","Enter Horror Form?",list("Yes","No")) != "Yes")
				return 1

			actions.start(new/datum/action/bar/private/icon/changelingHorrorForm(holder), H)

			logTheThing(LOG_COMBAT, H, "begins entering horror form as a changeling, [log_loc(H)].")
			return 0

/mob/proc/revert_from_horror_form()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		H.set_mutantrace(null)
		var/datum/abilityHolder/changeling/C = H.get_ability_holder(/datum/abilityHolder/changeling)
		if(!C || C.points < 15)
			boutput(H, SPAN_ALERT("You weren't strong enough to change back safely and blacked out!"))
			H.changeStatus("unconscious", 10 SECONDS)
		else
			boutput(H, SPAN_ALERT("You revert back to your original form. It leaves you weak."))
			H.changeStatus("knockdown", 5 SECONDS)
		if (C)
			C.points = max(C.points - 15, 0)
			var/datum/absorbedIdentity/face = C.absorbed_dna[pick(C.absorbed_dna)]
			face.apply_to(src)
		H.update_face()
		H.update_body()
		H.update_clothing()
		H.abilityHolder.updateButtons()
		C?.transferOwnership(H)
		logTheThing(LOG_COMBAT, H, "voluntarily leaves horror form as a changeling, [log_loc(H)].")
		return 0

/datum/targetable/changeling/scream
	name = "Horrific Scream"
	desc = "A terrorizing scream that causes everyone nearby to become flustered."
	icon_state = "scream"
	cooldown = 100
	targeted = 0
	target_anything = 0
	pointCost = 0
	abomination_only = 1

	cast(atom/target)
		if (..())
			return 1
		holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner] screeches loudly! The very noise fills you with dread!</B>"))
		logTheThing(LOG_COMBAT, holder.owner, "screeches as a changeling in horror form [log_loc(holder.owner)].")
		playsound(holder.owner.loc, 'sound/voice/creepyshriek.ogg', 80, 1) // cogwerks - using ISN's scary goddamn shriek here

		for (var/mob/living/O in viewers(holder.owner, null))
			if (O == holder.owner)
				continue
			O.apply_sonic_stun(0, 0, 0, 10, 70, rand(0, 2))

		return 0

/datum/action/bar/private/icon/changelingHorrorForm
	duration = 3 SECONDS
	interrupt_flags = INTERRUPT_NONE
	bar_icon_state = "bar-changeling"
	border_icon_state = "border-changeling"
	color_active = "#d73715"
	color_success = "#3fb54f"
	color_failure = "#8d1422"
	var/datum/abilityHolder/changeling/C

	New(Holder)
		..()
		C = Holder

	onStart()
		..()
		src.owner.visible_message(SPAN_ALERT("[src.owner] starts contorting horribly!"))

	onUpdate()
		..()
		if (QDELETED(C) || !ishuman(src.owner))
			src.interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/living/carbon/human/H = src.owner
		if (isdead(H))
			src.interrupt(INTERRUPT_ALWAYS)
			return
		if (!H.lying)
			H.changeStatus("knockdown", 5 SECONDS)
			H.force_laydown_standup()
		if (H.pulled_by)
			boutput(H.pulled_by, SPAN_ALERT("[src.owner] writhes free of your grip!"))
			H.pulled_by.remove_pulling()
		if (length(H.grabbed_by))
			for (var/obj/item/grab/G in H.grabbed_by) // not necessary to check for blocks here -- the knockdown gets rid of them already
				boutput(G.assailant, SPAN_ALERT("[src.owner] writhes free of your grip!"))
				qdel(G)
		// the goal of piling on all these effects is to make it VERY obvious what's happening
		// the animations and jittering here have the nice effect of making the convulsing look super inhuman
		H.make_jittery(1000)
		violent_standup_twitch(H)
		bleed(H, 0, 5)
		var/list/spooks = list(
			'sound/impact_sounds/Slimy_Splat_1.ogg',
			'sound/impact_sounds/Flesh_Break_1.ogg',
			'sound/impact_sounds/Flesh_Crush_1.ogg',
			'sound/impact_sounds/Flesh_Tear_1.ogg',
			'sound/impact_sounds/Flesh_Tear_2.ogg'
		)
		for (var/i in 0 to 2)
			var/spook = pick(spooks)
			spooks.Remove(spook)
			playsound(H, spook, rand(30, 50), TRUE)

	onEnd()
		..()
		var/mob/living/carbon/human/H = src.owner
		logTheThing(LOG_COMBAT, H, "enters horror form as a changeling, [log_loc(H)].")
		H.visible_message(SPAN_ALERT(SPAN_BOLD("[H]'s body splits apart into a [pick("ravening", "gibbering", "shrieking")] \
		mass of limbs and teeth! [pick("HOLY FUCK!!!", "OH HELL NO!!!", "NO NO NO NO NO", "UHHHHHHHHHHHH")]")))

		// step 1: clear stuns, set to conscious
		// this has to be done *before* setting the mutantrace or it won't process the standup call 'til the next life tick
		H.lying = FALSE
		H.remove_stuns()
		H.delStatus("disorient")
		H.delStatus("pinned")
		H.jitteriness = 0
		H.force_laydown_standup()
		setalive(H)

		// step 2: set mutantrace and update appearance
		H.set_mutantrace(/datum/mutantrace/abomination)
		H.real_name = "Shambling Abomination"
		H.UpdateName()
		H.update_face()
		H.update_body()
		H.update_clothing()

		// step 3: handle ability holder stuff, kick us out of fakedeath
		// the ability set swaps over automatically, so we just need to update the buttons
		H.abilityHolder.transferOwnership(H)
		H.abilityHolder.updateButtons()
		C.in_fakedeath = FALSE
		REMOVE_ATOM_PROPERTY(H, PROP_MOB_CANTMOVE, "regen_stasis")

		// finally: make it extra scary with a big burst of gore
		// dir is set to south so that it shows off the full sprite
		gibs(get_turf(H), null, H.bioHolder.Uid, H.bioHolder.bloodType)
		H.set_dir(SOUTH)
		H.emote("scream")
