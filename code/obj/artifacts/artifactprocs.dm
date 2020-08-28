/proc/Artifact_Spawn(var/atom/T,var/forceartitype)
	if (!T)
		return
	if (!istype(T,/turf/) && !istype(T,/obj/))
		return

	var/rarityroll = 1

// artifact tweak. rarity 1 now contains garbage artifacts so that it's easier to control how much garbage science sees.
	switch(rand(1,100))
		if (36 to 80) 		// 45%. 4% chance for a particular level 2 art.
			rarityroll = 2
		if (81 to 95) 		// 15%. With current art list this means 2% chance of a certain level 3 art
			rarityroll = 3
		if (96 to 100) 		// 5%. With current art list this means 1% chance of a certain level 4 art. 2 of the 5 are bombs...
			rarityroll = 4
		else 							// 35%. 4% chance for a particular garbage level 1 art.
			rarityroll = 1

	var/list/selection_pool = list()

	for (var/datum/artifact/A in artifact_controls.artifact_types)
		if (A.rarity_class != rarityroll)
			continue
		if (istext(forceartitype) && !(forceartitype in A.validtypes))
			continue
		selection_pool += A

	if (selection_pool.len < 1)
		return

	var/datum/artifact/picked = pick(selection_pool)
	if (!istype(picked,/datum/artifact/))
		return

	if (istext(forceartitype))
		new picked.associated_object(T,forceartitype)
	else
		new picked.associated_object(T)

/obj/proc/ArtifactSanityCheck()
	// This proc is called in any other proc or thing that uses the new artifact shit. If there was an improper artifact variable
	// involved when trying to do the new shit, it would probably spew errors fucking everywhere and generally be horrible so if
	// the sanity check detects that an artifact doesn't have the proper shit set up it'll just wipe out the artifact and stop
	// the rest of the proc from occurring.
	// This proc should be called in an if statement at the start of every artifact proc, since it returns 0 or 1.
	if (!src.artifact)
		return 0
	// if the artifact var isn't set at all, it's probably not an artifact so don't bother continuing
	if (!istype(src.artifact,/datum/artifact/))
		logTheThing("debug", null, null, "<b>I Said No/Artifact:</b> Invalid artifact variable in [src.type] at [showCoords(src.x, src.y, src.z)]")
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
	src:real_name = "[name1] [name2]"
	desc = "You have no idea what this thing is!"
	A.touch_descriptors |= appearance.touch_descriptors

	src.icon_state = appearance.name + "-[rand(1,appearance.max_sprites)]"
	if (isitem(src))
		var/obj/item/I = src
		I.item_state = appearance.name

	A.fx_image = image(src.icon, src.icon_state + "fx")
	A.fx_image.color = rgb(rand(AO.fx_red_min,AO.fx_red_max),rand(AO.fx_green_min,AO.fx_green_max),rand(AO.fx_blue_min,AO.fx_blue_max))

	A.react_mpct[1] = AO.impact_reaction_one
	A.react_mpct[2] = AO.impact_reaction_two
	A.react_heat[1] = AO.heat_reaction_one
	A.activ_sound = pick(AO.activation_sounds)
	A.fault_types |= AO.fault_types
	A.internal_name = AO.generate_name()
	A.nofx = AO.nofx

	ArtifactDevelopFault(10)

	if (A.automatic_activation)
		src.ArtifactActivated()
	else
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

/obj/proc/ArtifactActivated()
	if (!src)
		return
	if (!src.ArtifactSanityCheck())
		return 1
	var/datum/artifact/A = src.artifact
	if(A.internal_name)
		src.name = A.internal_name
	if (A.activated)
		return 1
	if (A.triggers.len < 1 && !A.automatic_activation)
		return 1 // can't activate these ones at all by design
	if (!A.may_activate(src))
		return 1
	if (A.activ_sound)
		playsound(src.loc, A.activ_sound, 100, 1)
	if (A.activ_text)
		var/turf/T = get_turf(src)
		if (T) T.visible_message("<b>[src] [A.activ_text]</b>") //ZeWaka: Fix for null.visible_message()
	A.activated = 1
	if (A.nofx)
		src.icon_state = src.icon_state + "fx"
	else
		src.overlays += A.fx_image
	A.effect_activate(src)

/obj/proc/ArtifactDeactivated()
	if (!src.ArtifactSanityCheck())
		return
	var/datum/artifact/A = src.artifact
	if (A.deact_sound)
		playsound(src.loc, A.deact_sound, 100, 1)
	if (A.deact_text)
		var/turf/T = get_turf(src)
		T.visible_message("<b>[src] [A.deact_text]</b>")
	A.activated = 0
	if (A.nofx)
		src.icon_state = src.icon_state - "fx"
	else
		src.overlays = null
	A.effect_deactivate(src)

/obj/proc/Artifact_attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/cargotele)) // Re-added (Convair880).
		var/obj/item/cargotele/CT = W
		CT.cargoteleport(src, user)
		return

	if (isrobot(user))
		src.ArtifactStimulus("silitouch", 1)

	if (istype(W,/obj/item/artifact/activator_key))
		var/obj/item/artifact/activator_key/ACT = W
		if (!src.ArtifactSanityCheck())
			return
		if (!W.ArtifactSanityCheck())
			return
		var/datum/artifact/A = src.artifact
		var/datum/artifact/K = ACT.artifact

		if (K.activated)
			if (ACT.universal || A.artitype == K.artitype)
				if (ACT.activator && !A.activated)
					src.ArtifactActivated()
				else if (!ACT.activator && A.activated)
					src.ArtifactDeactivated()

	if (isweldingtool(W))
		if (W:try_weld(user,0,-1,0,1))
			src.ArtifactStimulus("heat", 800)
			src.visible_message("<span class='alert'>[user.name] burns the artifact with [W]!</span>")
			return 0

	if (istype(W,/obj/item/device/light/zippo))
		var/obj/item/device/light/zippo/ZIP = W
		if (ZIP.on)
			src.ArtifactStimulus("heat", 400)
			src.visible_message("<span class='alert'>[user.name] burns the artifact with [ZIP]!</span>")
			return 0

	if (istype(W, /obj/item/robodefibrillator))
		var/obj/item/robodefibrillator/R = W
		if (R.do_the_shocky_thing(user))
			src.ArtifactStimulus("elec", 2500)
			src.visible_message("<span class='alert'>[user.name] shocks \the [src] with \the [R]!</span>")
		return 0

	if(istype(W,/obj/item/baton))
		var/obj/item/baton/BAT = W
		if (BAT.can_stun(1, 1, user) == 1)
			src.ArtifactStimulus("force", BAT.force)
			src.ArtifactStimulus("elec", 1500)
			playsound(src.loc, "sound/impact_sounds/Energy_Hit_3.ogg", 100, 1)
			src.visible_message("<span class='alert'>[user.name] beats the artifact with [BAT]!</span>")
			BAT.process_charges(-1, user)
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
			if (get_dist(src.loc, M.loc) > 1)
				return
			src.visible_message("<strong class='combat'>[A] shoves [M] against \the [src]!</strong>")
			logTheThing("combat", A, M, "forces [constructTarget(M,"combat")] to touch \an ([A.type]) artifact at [log_loc(src)].")
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
	return 1

/obj/proc/ArtifactFaultUsed(var/mob/user)
	// This is for a tool/item artifact that you can use. If it has a fault, whoever is using it is basically rolling the dice
	// every time the thing is used (a check to see if rand(1,faultcount) hits 1 most of the time) and if they're unlucky, the
	// thing will deliver it's payload onto them.
	// There's also no reason this can't be used whoever the artifact is being used *ON*, also!
	if (!src.ArtifactSanityCheck())
		return

	var/datum/artifact/A = src.artifact

	if (!A.faults.len)
		return // no faults, so dont waste any more time
	if (!A.activated)
		return // doesn't make a lot of sense for an inert artifact to go haywire
	var/halt = 0
	for (var/datum/artifact_fault/F in A.faults)
		if (prob(F.trigger_prob))
			if (F.halt_loop)
				halt = 1
			F.deploy(src,user)
		if (halt)
			break

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

	// Possible stimuli = force, elec, radiate, heat
	switch(A.artitype.name)
		if("martian") // biotech, so anything that'd probably kill a living thing works on them too
			if(stimtype == "force")
				if (strength >= 30)
					T.visible_message("<span class='alert'>[src] bruises from the impact!</span>")
					playsound(src.loc, "sound/impact_sounds/Slimy_Hit_3.ogg", 100, 1)
					ArtifactDevelopFault(33)
					src.ArtifactTakeDamage(strength / 1.5)
			if(stimtype == "elec")
				if (strength >= 3000) // max you can get from the electrobox is 5000
					if (prob(10))
						T.visible_message("<span class='alert'>[src] seems to quiver in pain!</span>")
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
					T.visible_message("<span class='alert'>[src] cracks and splinters!</span>")
					playsound(src.loc, "sound/impact_sounds/Glass_Shards_Hit_1.ogg", 100, 1)
					ArtifactDevelopFault(80)
					src.ArtifactTakeDamage(strength * 1.5)
		if("reliquary") // fragile machinery so no smacking them too hard, also pretty vulnerable to electricity
			if(stimtype == "force")
				if (strength >= 20)
					T.visible_message(pick("<span class='alert'>[src] cracks and splinters!</span>","<span class='alert'>[src] starts to split and break from the impact!</span>"))
					playsound(src.loc, "sound/impact_sounds/Metal_Hit_Heavy_1.ogg", 100, 1)
					ArtifactDevelopFault(80)
					src.ArtifactTakeDamage(strength * 1.5)
			if(stimtype == "elec")
				if (strength >= 3000) // max you can get from the electrobox is 5000
					if (prob(10))
						T.visible_message(pick("<span class='alert'>[src] buzzes angrily!</span>","<span class='alert'>[src] beeps grumpily!</span>"))
						src.ArtifactTakeDamage(strength / 1000)

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
	if (isAI(user))
		return
	if (isobserver(user))
		return

	var/datum/artifact/A = src.artifact
	if (istype(A,/datum/artifact/))
		if (iscarbon(user))
			src.ArtifactStimulus("carbtouch", 1)
		if (issilicon(user))
			src.ArtifactStimulus("silitouch", 1)
		src.ArtifactStimulus("force", 1)
		user.visible_message("<b>[user.name]</b> touches [src].")
		if (istype(src.artifact,/datum/artifact))
			if (A.touch_descriptors.len > 0)
				boutput(user, "[pick(A.touch_descriptors)]")
			else
				boutput(user, "You can't really tell how it feels.")
		if (A.activated)
			A.effect_touch(src,user)
	return

/obj/proc/ArtifactTakeDamage(var/dmg_amount)
	if (!src.ArtifactSanityCheck() || !isnum(dmg_amount))
		return

	var/datum/artifact/A = src.artifact

	A.health -= dmg_amount
	A.health = max(0,min(A.health,100))

	if (A.health <= 0)
		src.ArtifactDestroyed()
	return

/obj/proc/ArtifactDestroyed()
	// Call this rather than straight disposing() on an artifact if you want to destroy it. This way, artifacts can have their own
	// version of this for ones that will deliver a payload if broken.
	if (!src.ArtifactSanityCheck())
		return

	var/datum/artifact/A = src.artifact

	ArtifactLogs(usr, null, src, "destroyed", null, 0)

	artifact_controls.artifacts -= src

	var/turf/T = get_turf(src)
	if (istype(T,/turf/))
		switch(A.artitype.name)
			if("ancient")
				T.visible_message("<span class='alert'><B>[src] sparks and sputters violently before falling apart!</B></span>")
			if("martian")
				T.visible_message("<span class='alert'><B>[src] bursts open, and rapidly liquefies!</B></span>")
			if("wizard")
				T.visible_message("<span class='alert'><B>[src] shatters and disintegrates!</B></span>")
			if("eldritch")
				T.visible_message("<span class='alert'><B>[src] warps in on itself and vanishes!</B></span>")
			if("precursor")
				T.visible_message("<span class='alert'><B>[src] implodes, crushing itself into dust!</B></span>")
			if("reliquary")
				T.visible_message("<span class='alert'><B>[src] sparks violently before its internal circuitry falls apart and causes it to collapse!</B></span>")

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
	faultprob = max(0,min(faultprob,100))

	if (prob(faultprob) && A.fault_types.len)
		var/new_fault = pick(A.fault_types)
		if (ispath(new_fault))
			var/datum/artifact_fault/F = new new_fault(A)
			F.holder = A
			A.faults += F

// Added. Very little related to artifacts was logged (Convair880).
/proc/ArtifactLogs(var/mob/user, var/mob/target, var/obj/O, var/type_of_action, var/special_addendum, var/trigger_alert = 0)
	if (!O || !istype(O.artifact, /datum/artifact) || !type_of_action)
		return

	var/datum/artifact/A = O.artifact

	if ((target && ismob(target)) && type_of_action == "weapon")
		logTheThing("combat", user, target, "attacks [constructTarget(target,"combat")] with an active artifact ([A.type])[special_addendum ? ", [special_addendum]" : ""] at [log_loc(target)].")
	else
		logTheThing(type_of_action == "detonated" ? "bombing" : "station", user, target, "an artifact ([A.type]) was [type_of_action] [special_addendum ? "([special_addendum])" : ""] at [target && isturf(target) ? "[log_loc(target)]" : "[log_loc(O)]"].[type_of_action == "detonated" ? " Last touched by: [O.fingerprintslast ? "[O.fingerprintslast]" : "*null*"]" : ""]")

	if (trigger_alert)
		message_admins("An artifact ([A.type]) was [type_of_action] [special_addendum ? "([special_addendum])" : ""] at [log_loc(O)]. Last touched by: [O.fingerprintslast ? "[O.fingerprintslast]" : "*null*"]")

	return
