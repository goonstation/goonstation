/proc/Artifact_Spawn(var/atom/T,var/forceartiorigin, var/datum/artifact/forceartitype = null)
	if (!T)
		return
	if (!istype(T,/turf/) && !istype(T,/obj/))
		return

	var/list/artifactweights
	if(forceartiorigin)
		artifactweights = artifact_controls.artifact_rarities[forceartiorigin]
	else
		artifactweights = artifact_controls.artifact_rarities["all"]

	var/datum/artifact/picked
	if(forceartitype)
		picked = forceartitype
	else
		if (length(artifactweights) == 0)
			return
		picked = weighted_pick(artifactweights)

	var/type = null
	if(ispath(picked,/datum/artifact/))
		type = initial(picked.associated_object)	// artifact type
	else
		return

	if (istext(forceartiorigin))
		. = new type(T,forceartiorigin)
	else
		. = new type(T)

/obj/proc/ArtifactSanityCheck()
	// This proc is called in any other proc or thing that uses the new artifact shit. If there was an improper artifact variable
	// involved when trying to do the new shit, it would probably spew errors fucking everywhere and generally be horrible so if
	// the sanity check detects that an artifact doesn't have the proper shit set up it'll just wipe out the artifact and stop
	// the rest of the proc from occurring.
	// This proc should be called in an if statement at the start of every artifact proc, since it returns 0 or 1.
	if (!src.artifact || src.disposed)
		return 0
	// if the artifact var isn't set at all, it's probably not an artifact so don't bother continuing
	if (!istype(src.artifact,/datum/artifact/))
		logTheThing(LOG_DEBUG, null, "<b>I Said No/Artifact:</b> Invalid artifact variable in [src.type] at [log_loc(src)]")
		qdel(src) // wipes itself out since if it's processing it'd be calling procs it can't use again and again
		return 0 // uh oh, we've got a poorly set up artifact and now we need to stop the proc that called it!
	else
		return 1 // give the all clear

/obj/proc/ArtifactSetup()
	// This proc gets called in every artifact's New() proc, after src.artifact is turned from a 1 into its appropriate datum.
	//It scrambles the name and appearance of the artifact so we can't tell what it is on sight or cursory examination.
	// Could potentially go in /obj/New(), but...
	if (!src.ArtifactSanityCheck())
		return
	var/datum/artifact/A = src.artifact
	A.holder = src

	if (!artifact_controls) //Hasn't been init'd yet
		sleep(2 SECONDS)

	var/datum/artifact_origin/AO = artifact_controls.get_origin_from_string(pick(A.validtypes))
	if (!istype(AO,/datum/artifact_origin/))
		qdel(src)
		return
	A.artitype = AO
	A.scramblechance = AO.scramblechance
	// Refers to the artifact datum's list of origins it's allowed to be from and selects one at random. This way we can avoid
	// stuff that doesn't make sense like ancient robot plant seeds or eldritch healing devices

	var/datum/artifact_origin/appearance = artifact_controls.get_origin_from_string(AO.name)
	if (prob(A.scramblechance))
		appearance = null
		A.disguised = TRUE
	// rare-ish chance of an artifact appearing to be a different origin, just to throw things off

	if (!istype(appearance,/datum/artifact_origin/))
		var/list/all_origin_names = list()
		for (var/datum/artifact_origin/O in artifact_controls.artifact_origins)
			all_origin_names += O.name
		appearance = artifact_controls.get_origin_from_string(pick(all_origin_names))

	var/name1 = pick(appearance.adjectives)
	var/name2 = "thingy"
	if (isitem(src))
		name2 = pick(appearance.nouns_small)
	else
		name2 = pick(appearance.nouns_large)

	src.name = "[name1] [name2]"
	src.real_name = "[name1] [name2]"
	desc = "You have no idea what this thing is!"
	A.touch_descriptors |= appearance.touch_descriptors

	src.icon_state = appearance.name + "-[rand(1,appearance.max_sprites)]"
	if (isitem(src))
		var/obj/item/I = src
		I.item_state = appearance.name

	A.fx_image = new
	A.fx_image.icon = src.icon
	A.fx_image.icon_state = src.icon_state + "fx"
	A.fx_image.color = rgb(rand(AO.fx_red_min,AO.fx_red_max),rand(AO.fx_green_min,AO.fx_green_max),rand(AO.fx_blue_min,AO.fx_blue_max))
	A.fx_image.alpha = rand(AO.fx_alpha_min, AO.fx_alpha_max)
	A.fx_image.layer = 5
	A.fx_image.blend_mode = BLEND_ADD
	A.fx_image.plane = PLANE_LIGHTING

	A.fx_fallback = new
	A.fx_fallback.icon = src.icon
	A.fx_fallback.icon_state = src.icon_state + "fx"
	A.fx_fallback.color = A.fx_image.color
	A.fx_fallback.alpha = A.fx_image.alpha
	A.fx_fallback.vis_flags |= VIS_INHERIT_LAYER
	A.fx_fallback.vis_flags |= VIS_INHERIT_PLANE

	A.react_mpct[1] = AO.impact_reaction_one
	A.react_mpct[2] = AO.impact_reaction_two
	A.react_heat[1] = AO.heat_reaction_one
	A.activ_sound = pick(AO.activation_sounds)
	A.fault_types |= AO.fault_types - A.fault_blacklist
	A.internal_name = AO.generate_name()
	A.used_names[AO.type_name] = A.internal_name
	A.nofx = AO.nofx

	ArtifactDevelopFault(10)

	if (A.automatic_activation)
		src.ArtifactActivated()

	var/list/valid_triggers = A.validtriggers
	var/trigger_amount = rand(A.min_triggers,A.max_triggers)
	var/selection = null
	while (trigger_amount > 0)
		trigger_amount--
		selection = pick(valid_triggers)
		if (ispath(selection))
			var/datum/artifact_trigger/AT = new selection
			A.triggers += AT
			valid_triggers -= selection

	artifact_controls.artifacts += src
	A.post_setup()

/obj/proc/ArtifactActivated(combined_art_activation = FALSE)
	if (!src)
		return 1
	if (!src.ArtifactSanityCheck())
		return 1
	var/datum/artifact/A = src.artifact
	if (A.activated)
		return 1
	if (length(A.triggers) < 1 && !A.automatic_activation)
		return 1 // can't activate these ones at all by design
	if (!A.may_activate(src))
		return 1
	if (A.activ_sound && !combined_art_activation)
		playsound(src.loc, A.activ_sound, 100, 1)
	if (A.activ_text)
		var/turf/T = get_turf(src)
		if (T) T.visible_message("<b>[src] [A.activ_text]</b>") //ZeWaka: Fix for null.visible_message()
	A.activated = 1
	if (A.nofx)
		src.icon_state = src.icon_state + "fx"
	else
		A.show_fx(src)
	A.effect_activate(!combined_art_activation ? src : src.get_uppermost_artifact())
	for (var/obj/O in src.combined_artifacts)
		O.ArtifactActivated(TRUE)
	if (combined_art_activation)
		return
	for (var/mob/living/L in range(5, src))
		for(var/datum/objective/objective in L.mind?.objectives)
			if (istype(objective, /datum/objective/crew/scientist/artifact))
				var/datum/objective/crew/scientist/artifact/art_obj = objective
				art_obj.artifacts_activated++
				break
			if (istype(objective, /datum/objective/crew/researchdirector/artifact))
				var/datum/objective/crew/researchdirector/artifact/art_obj = objective
				art_obj.artifacts_activated++
				break

/obj/proc/ArtifactDeactivated(combined_art_activation = FALSE)
	if (!src.ArtifactSanityCheck())
		return
	var/datum/artifact/A = src.artifact
	if (!A.activated) // do not deactivate if already deactivated
		return
	if (A.deact_sound && !combined_art_activation)
		playsound(src.loc, A.deact_sound, 100, 1)
	if (A.deact_text)
		var/turf/T = get_turf(src)
		T.visible_message("<b>[src] [A.deact_text]</b>")
	A.activated = 0
	if (A.nofx)
		src.icon_state = src.icon_state - "fx"
	else
		A.hide_fx(src)
	A.effect_deactivate(!combined_art_activation ? src : src.get_uppermost_artifact())
	for (var/obj/O in src.combined_artifacts)
		O.ArtifactDeactivated(TRUE)

/obj/proc/Artifact_emp_act()
	if (!src.ArtifactSanityCheck())
		return
	src.ArtifactStimulus("elec", 800)
	src.ArtifactStimulus("radiate", 3)

/obj/proc/Artifact_blob_act(var/power)
	if (!src.ArtifactSanityCheck())
		return
	src.ArtifactStimulus("force", power)
	src.ArtifactStimulus("carbtouch", 1)

/obj/proc/Artifact_reagent_act(var/reagent_id, var/volume)
	if (!src.ArtifactSanityCheck())
		return
	var/datum/artifact/A = src.artifact
	switch(reagent_id)
		if("porktonium")
			src.ArtifactStimulus("radiate", round(volume / 10))
			src.ArtifactStimulus("carbtouch", round(volume / 5))
		if("synthflesh","blood","bloodc","meat_slurry") //not carbon, because it's about detecting *lifeforms*, not elements
			src.ArtifactStimulus("carbtouch", round(volume / 5)) //require at least 5 units
		if("nanites","corruptnanites","goodnanites","flockdrone_fluid") //not silicon&friends for the same reason
			src.ArtifactStimulus("silitouch", round(volume / 5)) //require at least 5 units
		if("radium")
			src.ArtifactStimulus("radiate", round(volume / 10))
		if("uranium","polonium")
			src.ArtifactStimulus("radiate", round(volume / 2))
		if("dna_mutagen","mutagen","omega_mutagen")
			if (A.artitype.name == "martian")
				ArtifactDevelopFault(80)
		if("phlogiston","el_diablo","thermite","pyrosium","argine")
			src.ArtifactStimulus("heat", 310 + (volume * 5))
		if("napalm_goo","kerosene","ghostchilijuice")
			src.ArtifactStimulus("heat", 310 + (volume * 10))
		if("infernite","foof","dbreath")
			src.ArtifactStimulus("heat", 310 + (volume * 15))
		if("cryostylane")
			src.ArtifactStimulus("heat", 310 - (volume * 10))
		if("freeze")
			src.ArtifactStimulus("heat", 310 - (volume * 15))
		if("voltagen","energydrink")
			src.ArtifactStimulus("elec", volume * 50)
		if("acid","acetic_acid")
			src.ArtifactTakeDamage(volume * 2)
		if("pacid","clacid","nitric_acid")
			src.ArtifactTakeDamage(volume * 10)
		if("george_melonium")
			var/random_stimulus = pick("heat","force","radiate","elec", "carbtouch", "silitouch")
			var/random_strength = 0
			switch(random_stimulus)
				if ("heat")
					random_strength = rand(200,400)
				if ("elec")
					random_strength = rand(5,5000)
				if ("force")
					random_strength = rand(3,30)
				if ("radiate")
					random_strength = rand(1,10)
				else // carbon and silicon touch
					random_strength = 1
			src.ArtifactStimulus(random_stimulus,random_strength)
	return

/obj/proc/Artifact_attackby(obj/item/W, mob/user)
	if (istype(W,/obj/item/artifact/activator_key))
		var/obj/item/artifact/activator_key/ACT = W
		if (!src.ArtifactSanityCheck())
			return
		if (!W.ArtifactSanityCheck())
			return
		var/datum/artifact/A = src.artifact
		var/datum/artifact/activator_key/K = ACT.artifact

		if (K.activated)
			if (K.universal || A.artitype == K.artitype)
				if (K.activator && !A.activated)
					src.ArtifactActivated()
					if(K.corrupting && length(A.faults) < 10) // there's only so much corrupting you can do ok
						for(var/i=1,i<rand(1,3),i++)
							src.ArtifactDevelopFault(100)
					// prevent instantly adding to contents, since a bad effect happens
					if (istype(src, /obj/item/artifact/bag_of_holding))
						return
				else if (A.activated)
					if (istype(src, /obj/item/artifact/bag_of_holding) && src.storage.check_can_hold(W) == STORAGE_CAN_HOLD)
						src.storage.add_contents(W, user)
						return
					src.ArtifactDeactivated()

	if (isweldingtool(W))
		if (W:try_weld(user,0,-1,0,1))
			src.ArtifactStimulus("heat", 800)
			src.visible_message(SPAN_ALERT("[user.name] burns the artifact with [W]!"))
			return 0

	if (istype(W,/obj/item/device/light/zippo))
		var/obj/item/device/light/zippo/ZIP = W
		if (ZIP.on)
			src.ArtifactStimulus("heat", 400)
			src.visible_message(SPAN_ALERT("[user.name] burns the artifact with [ZIP]!"))
			return 0

	if(istype(W,/obj/item/device/igniter))
		var/obj/item/device/igniter/igniter = W
		src.ArtifactStimulus("elec", 700)
		src.ArtifactStimulus("heat", 385)
		src.visible_message(SPAN_ALERT("[user.name] sparks against \the [src] with \the [igniter]!"))

	if (istype(W, /obj/item/robodefibrillator))
		var/obj/item/robodefibrillator/R = W
		if (R.do_the_shocky_thing(user))
			src.ArtifactStimulus("elec", 2500)
			src.visible_message(SPAN_ALERT("[user.name] shocks \the [src] with \the [R]!"))
		return 0

	if(istype(W,/obj/item/baton))
		var/obj/item/baton/BAT = W
		if (BAT.can_stun(1, user) == 1)
			src.ArtifactStimulus("force", BAT.force)
			src.ArtifactStimulus("elec", 1500)
			playsound(src.loc, 'sound/impact_sounds/Energy_Hit_3.ogg', 100, 1)
			src.visible_message(SPAN_ALERT("[user.name] beats the artifact with [BAT]!"))
			BAT.process_charges(-1, user)
			return 0

	if(istype(W,/obj/item/device/flyswatter))
		var/obj/item/device/flyswatter/swatter = W
		src.ArtifactStimulus("elec", 1500)
		src.visible_message(SPAN_ALERT("[user.name] shocks \the [src] with \the [swatter]!"))
		return 0

	if(ispulsingtool(W))
		src.ArtifactStimulus("elec", 1000)
		src.visible_message(SPAN_ALERT("[user.name] shocks \the [src] with \the [W]!"))
		return 0

	if (istype(W,/obj/item/parts/robot_parts))
		var/obj/item/parts/robot_parts/THISPART = W
		src.visible_message("<b>[user.name]</b> presses \the [THISPART] against \the [src].</span>")
		src.ArtifactStimulus("silitouch", 1)
		return 0

	if (istype(W, /obj/item/parts/human_parts))
		var/obj/item/parts/human_parts/THISPART = W
		src.visible_message("<b>[user.name]</b> smooshes \the [THISPART] against \the [src].</span>")
		src.ArtifactStimulus("carbtouch", 1)
		return 0

	if (istype(W, /obj/item/grab))
		var/obj/item/grab/GRAB = W
		if (ismob(GRAB.affecting))
			if (GRAB.state < 1)
				// Not a strong grip so just smoosh em into it
				// generally speaking only humans and the like can be grabbed so whatev
				if (istype(GRAB.affecting, /mob/living/carbon))
					src.visible_message("<b>[user]</b> gently presses [GRAB.affecting] against \the [src].")
					src.ArtifactStimulus("carbtouch", 1)
				return 0

			var/mob/M = GRAB.affecting
			var/mob/A = GRAB.assailant
			if (BOUNDS_DIST(src.loc, M.loc) > 0)
				return
			src.visible_message("<strong class='combat'>[A] shoves [M] against \the [src]!</strong>")
			logTheThing(LOG_COMBAT, A, "forces [constructTarget(M,"combat")] to touch \an ([src.type]) artifact at [log_loc(src)].")
			src.ArtifactTouched(M)
			return 0

	if (istype(W,/obj/item/circuitboard))
		var/obj/item/circuitboard/CIRCUITBOARD = W
		src.visible_message("<b>[user.name]</b> offers the [CIRCUITBOARD] to the artifact.</span>")
		src.ArtifactStimulus("data", 1)
		return 0

	if (istype(W,/obj/item/disk/data))
		var/obj/item/disk/data/DISK = W
		src.visible_message("<b>[user.name]</b> offers the [DISK] to the artifact.</span>")
		src.ArtifactStimulus("data", 1)
		return 0

	if (W.force)
		src.ArtifactStimulus("force", W.force)

	src.ArtifactHitWith(W, user)
	return 1

#define FAULT_RESULT_INVALID 2 // artifact can't do faults
#define FAULT_RESULT_STOP	1		 // we gotta stop, artifact was destroyed or deactivated
#define FAULT_RESULT_SUCCESS 0 // everything's cool!
/obj/proc/ArtifactFaultUsed(var/mob/user, var/atom/cosmeticSource = null)
	// This is for a tool/item artifact that you can use. If it has a fault, whoever is using it is basically rolling the dice
	// every time the thing is used (a check to see if rand(1,faultcount) hits 1 most of the time) and if they're unlucky, the
	// thing will deliver it's payload onto them.
	// There's also no reason this can't be used whoever the artifact is being used *ON*, also!
	// The cosmetic source is just to specify where the effect comes from in the visual message.
	// So that you can make it come from something like a forcefield or bullet instead of the artifact itself!
	if (!src.ArtifactSanityCheck())
		return

	var/datum/artifact/A = src.artifact

	if (!A.faults.len)
		return FAULT_RESULT_INVALID // no faults, so dont waste any more time
	if (!cosmeticSource)
		cosmeticSource = src
	var/halt = 0
	for (var/datum/artifact_fault/F in A.faults)
		if (prob(F.trigger_prob))
			if (F.halt_loop)
				halt = 1
			logTheThing(LOG_COMBAT, src, "experienced an artifact fault [F.type_name] affecting [constructTarget(user,"combat")] at [log_loc(src)]")
			F.deploy(src,user,cosmeticSource)
		if (halt)
			return FAULT_RESULT_STOP
	return FAULT_RESULT_SUCCESS


/obj/proc/ArtifactStimulus(var/stimtype, var/strength = 0)
	// This is what will be used for most of the testing equipment stuff. Stimtype is what kind of stimulus the artifact is being
	// exposed to (such as brute force, high temperatures, electricity, etc) and strength is how powerful the stimulus is. This
	// one here is intended as a master proc with individual items calling back to this one and then rolling their own version of
	// it alongside this. This one mainly deals with accidentally damaging an artifact due to hitting it with a poor choice of
	// stimulus, such as hitting crystals with brute force and so forth.
	if (!stimtype)
		return
	if (!src.ArtifactSanityCheck())
		return
	var/turf/T = get_turf(src)

	var/datum/artifact/A = src.artifact
	if(!istype(A) || !A.artitype)
		return

	// Possible stimuli = force, elec, radiate, heat
	switch(A.artitype.name)
		if("martian") // biotech, so anything that'd probably kill a living thing works on them too
			if(stimtype == "force")
				if (strength >= 30)
					T.visible_message(SPAN_ALERT("[src] bruises from the impact!"))
					playsound(src.loc, 'sound/impact_sounds/Slimy_Hit_3.ogg', 100, 1)
					ArtifactDevelopFault(33)
					src.ArtifactTakeDamage(strength / 1.5)
			if(stimtype == "elec")
				if (strength >= 3000) // max you can get from the electrobox is 5000
					if (prob(10))
						T.visible_message(SPAN_ALERT("[src] seems to quiver in pain!"))
					src.ArtifactTakeDamage(strength / 1000)
			if(stimtype == "radiate")
				if (strength >= 6)
					ArtifactDevelopFault(50)
					if (strength >= 9)
						ArtifactDevelopFault(75)
					src.ArtifactTakeDamage(strength * 1.25)
		if("wizard") // these are big crystals, thus you probably shouldn't smack them around too hard!
			if(stimtype == "force")
				if (strength >= 20)
					T.visible_message(SPAN_ALERT("[src] cracks and splinters!"))
					playsound(src.loc, 'sound/impact_sounds/Glass_Shards_Hit_1.ogg', 100, 1)
					ArtifactDevelopFault(80)
					src.ArtifactTakeDamage(strength * 1.5)

	if (!src || !A)
		return

	if (!A.activated)
		for (var/datum/artifact_trigger/AT in A.triggers)
			if (A.activated)
				break
			if (AT.stimulus_required == stimtype)
				if (AT.do_amount_check)
					if (AT.stimulus_type == ">=" && strength >= AT.stimulus_amount)
						src.ArtifactActivated()
					else if (AT.stimulus_type == "<=" && strength <= AT.stimulus_amount)
						src.ArtifactActivated()
					else if (AT.stimulus_type == "==" && strength == AT.stimulus_amount)
						src.ArtifactActivated()
					else
						if (istext(A.hint_text))
							if (strength >= AT.stimulus_amount - AT.hint_range && strength <= AT.stimulus_amount + AT.hint_range)
								if (prob(AT.hint_prob))
									T.visible_message("<b>[src]</b> [A.hint_text]")
				else
					src.ArtifactActivated()

/obj/proc/ArtifactTouched(mob/user as mob)
	if (!in_interact_range(get_turf(src), user))
		return
	if (isAI(user))
		return
	if (isobserver(user))
		return

	var/datum/artifact/A = src.artifact
	if (istype(A,/datum/artifact/))
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			var/obj/item/parts/arm = H.hand ? H.limbs.l_arm : H.limbs.r_arm
			if(istype(arm, /obj/item/parts/robot_parts))
				src.ArtifactStimulus("silitouch", 1)
			else
				src.ArtifactStimulus("carbtouch", 1)
		else if (iscarbon(user))
			src.ArtifactStimulus("carbtouch", 1)
		else if (issilicon(user))
			src.ArtifactStimulus("silitouch", 1)
		src.ArtifactStimulus("force", 1)
		user.visible_message("<b>[user.name]</b> touches [src].")
		if (istype(src.artifact,/datum/artifact))
			if (length(A.touch_descriptors) > 0)
				boutput(user, "[pick(A.touch_descriptors)]")
			else
				boutput(user, "You can't really tell how it feels.")
		if (A.activated)
			A.effect_touch(src,user)
			for (var/obj/O in src.combined_artifacts)
				O.artifact.effect_touch(O, user)
	return

/obj/proc/ArtifactHitWith(var/obj/item/O, var/mob/user)
	if (!src.ArtifactSanityCheck())
		return 1

/obj/proc/ArtifactTakeDamage(var/dmg_amount)
	if (!src.ArtifactSanityCheck() || !isnum(dmg_amount))
		return

	var/datum/artifact/A = src.artifact

	A.health -= dmg_amount
	A.health = clamp(A.health, 0, 100)

	if (A.health <= 0)
		src.ArtifactDestroyed()
	return

/obj/hear_talk(mob/M, text, real_name, lang_id)
	if (!src.artifact || src.artifact.activated)
		return ..()
	var/datum/artifact_trigger/language/trigger = locate(/datum/artifact_trigger/language) in src.artifact.triggers
	if (!trigger || GET_DIST(M, src) > 2)
		return
	if (isghostcritter(M))
		return
	if (ON_COOLDOWN(src, "speech_act_cd", 2 SECONDS))
		return
	var/result = trigger.speech_act(text)
	if (!result)
		return
	if (result == "error")
		src.visible_message("[src] gives a <b>dull</b> chime.", "[src] gives a <b>dull</b> chime.")
	else if (result == "hint")
		src.visible_message("<b>[src]</b> [src.artifact.hint_text]", "<b>[src]</b> [src.artifact.hint_text]")
	else if (result == "correct")
		src.ArtifactStimulus("language", 1)
	else
		src.visible_message("[src] [result]", "[src] [result]")

/// Removes all artifact forms attached to this and makes them fall to the floor
/// Because artifacts often like to disappear in mysterious ways
/obj/proc/remove_artifact_forms()
	var/removed = 0
	for(var/obj/item/sticker/postit/artifact_paper/AP in src.vis_contents)
		AP.remove_from_attached()
		removed++
	if(removed == 1)
		src.visible_message("The artifact form that was attached falls to the ground.")
	else if(removed > 1)
		src.visible_message("All the artifact forms that were attached fall to the ground.")

/obj/proc/ArtifactDestroyed(combined_arti_destroy = FALSE)
	// Call this rather than straight disposing() on an artifact if you want to destroy it. This way, artifacts can have their own
	// version of this for ones that will deliver a payload if broken.
	if (!src.ArtifactSanityCheck())
		return

	var/datum/artifact/A = src.artifact

	var/turf/T = get_turf(src)
	if (istype(T,/turf/) && !combined_arti_destroy)
		switch(A.artitype.name)
			if("ancient")
				T.visible_message(SPAN_ALERT("<B>[src] sparks and sputters violently before falling apart!</B>"))
			if("martian")
				T.visible_message(SPAN_ALERT("<B>[src] bursts open, and rapidly liquefies!</B>"))
			if("wizard")
				T.visible_message(SPAN_ALERT("<B>[src] shatters and disintegrates!</B>"))
			if("eldritch")
				T.visible_message(SPAN_ALERT("<B>[src] warps in on itself and vanishes!</B>"))
			if("precursor")
				T.visible_message(SPAN_ALERT("<B>[src] implodes, crushing itself into dust!</B>"))

	src.remove_artifact_forms()

	src.ArtifactDeactivated(TRUE)

	ArtifactLogs(usr, null, src, "destroyed", null, 0)

	artifact_controls.artifacts -= src

	for (var/obj/O in src.combined_artifacts)
		O.ArtifactDestroyed(TRUE)

	qdel(src)
	return

/obj/proc/ArtifactDevelopFault(var/faultprob)
	// This proc is used for randomly giving an artifact a fault. It's usually used in the New() proc of an artifact so that
	// newly spawned artifacts have a chance of being faulty by default, though this can also be called whenever an artifact is
	// damaged or otherwise poorly handled, so you could potentially turn a good artifact into a dangerous piece of shit if you
	// abuse it too much.
	// I'm probably going to change this one up to use a list of fault datum rather than some kind of variable, that way multiple
	// faults can be on one artifact.
	if (!isnum(faultprob))
		return
	if (!src.ArtifactSanityCheck())
		return
	var/datum/artifact/A = src.artifact

	if (A.artitype.name == "eldritch")
		faultprob *= 2 // eldritch artifacts fucking hate you and are twice as likely to go faulty
	faultprob = clamp(faultprob, 0, 100)

	if (prob(faultprob) && length(A.fault_types))
		var/new_fault = weighted_pick(A.fault_types)
		if (ispath(new_fault))
			var/datum/artifact_fault/F = new new_fault(A)
			F.holder = A
			A.faults += F

/obj/proc/can_combine_artifact(obj/O)
	. = FALSE
	if (!src.artifact.activated)
		return
	if (!O || !O.artifact || !O.artifact.activated)
		return

	if (src.artifact.combine_flags & ARTIFACT_DOES_NOT_COMBINE)
		return
	if (O.artifact.combine_flags & ARTIFACT_DOES_NOT_COMBINE)
		return
	if (src.artifact.combine_flags & ARTIFACT_ACCEPTS_ANY_COMBINE)
		if (O.artifact.combine_flags & ARTIFACT_COMBINES_INTO_ANY)
			. = TRUE
		else if (src.artifact.type_size == ARTIFACT_SIZE_LARGE)
			if (O.artifact.combine_flags & ARTIFACT_COMBINES_INTO_LARGE)
				. = TRUE
		else
			if (O.artifact.combine_flags & ARTIFACT_COMBINES_INTO_HANDHELD)
				. = TRUE

	for (var/obj/art in O.combined_artifacts)
		if (!src.can_combine_artifact(art))
			return FALSE

/// combines passed object into src
/obj/proc/combine_artifact(obj/O)
	if (!src.artifact.activated)
		return
	if (!O || !O.artifact || !O.artifact.activated)
		return

	if (!length(src.combined_artifacts))
		src.combined_artifacts = list()
	if (O.artifact.combine_effect_priority == ARTIFACT_COMBINATION_TOUCHED)
		src.combined_artifacts.Insert(1, O)
	else
		src.combined_artifacts += O
	O.name = src.name
	O.real_name = src.real_name
	O.set_loc(src)
	O.parent_artifact = src
	O.artifact.hide_fx(O)
	src.artifact.faults |= O.artifact.faults
	src.artifact.validtriggers |= O.artifact.validtriggers
	src.vis_contents += O.vis_contents
	for (var/obj/art in O.combined_artifacts)
		src.combine_artifact(art)
	O.combined_artifacts = null

/obj/proc/get_uppermost_artifact()
	return src.parent_artifact || src

// Added. Very little related to artifacts was logged (Convair880).
/proc/ArtifactLogs(var/mob/user, var/mob/target, var/obj/O, var/type_of_action, var/special_addendum, var/trigger_alert = 0)
	if (!O || !istype(O.artifact, /datum/artifact) || !type_of_action)
		return

	var/datum/artifact/A = O.artifact

	if ((target && ismob(target)) && type_of_action == "weapon")
		logTheThing(LOG_COMBAT, user, "attacks [constructTarget(target,"combat")] with an active artifact ([A.type_name])[special_addendum ? ", [special_addendum]" : ""] at [log_loc(target)].")
	else
		logTheThing(type_of_action == "detonated" ? LOG_BOMBING : LOG_STATION, user, "an artifact ([A.type_name]) was [type_of_action] [special_addendum ? "([special_addendum])" : ""] at [target && isturf(target) ? "[log_loc(target)]" : "[log_loc(O)]"].[type_of_action == "detonated" ? " Last touched by: [O.fingerprintslast ? "[O.fingerprintslast]" : "*null*"]" : ""]")

	if (trigger_alert)
		message_admins("An <a href='byond://?src=%client_ref%;Refresh=\ref[O]'>artifact</a> ([A.type_name]) was [type_of_action] [special_addendum ? "([special_addendum])" : ""] at [log_loc(O)]. Last touched by: [key_name(O.fingerprintslast)]")

	return
