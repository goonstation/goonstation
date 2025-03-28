// Wraith

/mob/living/intangible/wraith
	name = "wraith"
	real_name = "wraith"
	desc = "Jesus Christ, how spooky."
	icon = 'icons/mob/mob.dmi'
#if defined(XMAS) || (BUILD_TIME_MONTH == 2 && BUILD_TIME_DAY == 14)
	icon_state = "wraith-love"
#elif defined(APRIL_FOOLS)
	icon_state = "wraith-jeans"
#else
	icon_state = "wraith"
#endif
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	alpha = 180
	plane = PLANE_NOSHADOW_ABOVE

	var/deaths = 0
	var/datum/hud/wraith/hud
	var/hud_path = /datum/hud/wraith

	var/atom/movable/overlay/animation = null

	var/haunting = 0
	var/hauntBonus = 0
	var/justdied = 0
	/// last time that were forced to manifest by a spirit candle
	var/last_spirit_candle_time = 0
	/// reference to our harbinger portal, if any
	var/obj/machinery/wraith/vortex_wraith/linked_portal = null
	/// flag set if we were manifested involuntarily, e.g. salt. Blocks wraith powers is true
	var/forced_manifest = FALSE

	var/last_life_update = 0
	var/const/life_tick_spacing = LIFE_PROCESS_TICK_SPACING
	/// standard duration of an involuntary haunt action
	var/forced_haunt_duration = 30 SECOND
	var/death_icon_state = "wraith-die"
	var/last_typing = null
	var/list/area/booster_locations = list()	//Zones in which you get more points
	var/list/area/valid_locations = list()	//Zones that can become booster zones
	var/list/area/excluded_areas = list(/area/shuttle/escape/transit, /area/shuttle_transit_space)
	var/next_area_change = 10 MINUTES
	var/list/mob/living/critter/summons = list()	//Keep track of who we summoned to the material plane
	var/datum/abilityHolder/wraith/AH = null

	var/list/poltergeists
	/// how much formaldehyde a corpse can have while still being absorbable
	var/formaldehyde_tolerance = 25
	///specifiy strong or weak tk powers. Weak for poltergeists.
	var/weak_tk = FALSE
	///can the wraith hear ghosts? Toggleable with an ability
	var/hearghosts = TRUE
	/// what is our minion summoning marker, if we have any?
	var/obj/spookMarker/spawn_marker = null

	var/datum/movement_controller/movement_controller

	faction = list(FACTION_WRAITH)

	//////////////
	// Wraith Overrides
	//////////////

	proc/make_name()
		var/len = rand(4, 8)
		var/vowel_prob = 0
		var/list/con = list("x", "z", "n", "k", "s", "l", "t", "r", "sh", "m", "d")
		#ifdef APRIL_FOOLS
		con += list("j", "j", "j", "j", "j", "j", "j", "j")
		#endif
		var/list/vow = list("y", "o", "a", "ae", "u", "ou")
		var/theName = ""
		for (var/i = 1, i <= len, i++)
			if (prob(vowel_prob))
				vowel_prob = 0
				theName += pick(vow)
			else
				vowel_prob += rand(15, 40)
				theName += pick(con)
		var/fc = copytext(theName, 1, 2)
		theName = "[uppertext(fc)][copytext(theName, 2)]"

		#ifdef APRIL_FOOLS
		var/suffix = pick(" the Jimpaler", " the Jormentor", " the Jorsaken", " the Jestroyer", " the Jevourer", " the Jyrant", " the Joverlord", " the Jamned", " the Jesolator", " the Jexiled")
		#else
		var/suffix = pick(" the Impaler", " the Tormentor", " the Forsaken", " the Destroyer", " the Devourer", " the Tyrant", " the Overlord", " the Damned", " the Desolator", " the Exiled")
		#endif
		theName = theName  + suffix
		return theName

	New(var/mob/M)
		. = ..()
		START_TRACKING
		src.poltergeists = list()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src, INVIS_SPOOKY)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_AI_UNTRACKABLE, src)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_EXAMINE_ALL_NAMES, src)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NO_MOVEMENT_PUFFS, src)
		//src.sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
		src.sight |= SEE_SELF // let's not make it see through walls
		src.see_invisible = INVIS_SPOOKY
		src.see_in_dark = SEE_DARK_FULL
		src.abilityHolder = new /datum/abilityHolder/wraith(src)
		AH = src.abilityHolder
		src.abilityHolder.points = 50
#ifdef BONUS_POINTS
		src.abilityHolder.points = 99999
#endif
		if (!istype(src, /mob/living/intangible/wraith/wraith_trickster) && !istype(src, /mob/living/intangible/wraith/wraith_decay) && !istype(src, /mob/living/intangible/wraith/wraith_harbinger) && !istype(src, /mob/living/intangible/wraith/poltergeist))
			src.addAbility(/datum/targetable/wraithAbility/specialize)
		src.addAllBasicAbilities()
		last_life_update = TIME
		src.hud = new hud_path (src)
		src.attach_hud(hud)
		src.flags |= UNCRUSHABLE
		valid_locations = get_accessible_station_areas()
		next_area_change = world.time + (5 SECONDS)
		#ifdef APRIL_FOOLS
		animate_levitate(src)
		#endif

		if (!movement_controller)
			movement_controller = new /datum/movement_controller/poltergeist (src)

		real_name = make_name()
		src.UpdateName()

		get_image_group(CLIENT_IMAGE_GROUP_CURSES).add_mob(src)

	is_spacefaring()
		return !density

	movement_delay()
		if (density)
			return 3 + movement_delay_modifier
		return 1

	meteorhit()
		return

	Login()
		..()
		abilityHolder.updateButtons()
		var/atom/plane = client.get_plane(PLANE_LIGHTING)
		plane.alpha = 200

	Logout()
		..()
		if (src.last_client)
			var/atom/plane = last_client.get_plane(PLANE_LIGHTING)
			if (plane)
				plane.alpha = 255

	disposing()
		STOP_TRACKING
		for (var/mob/living/intangible/wraith/poltergeist/P in src.poltergeists)
			P.master = null
		poltergeists = null
		..()

	proc/transmute_random_stuff(datum/material/mat, count=1)
		var/list/valid_objs = list()
		for (var/obj/O in range(3, src))
			if (O.invisibility == 0 && !istype(O, /obj/effect) && !istype(O, /obj/overlay))
				valid_objs += O
		for (var/i in 1 to count)
			var/obj/O = pick(valid_objs)
			O.setMaterial(mat)

	Life(parent)
		if (..(parent))
			return 1

		#ifdef APRIL_FOOLS
		transmute_random_stuff(getMaterial("jean"))
		if(prob(1))
			animate(src)
			animate_levitate(src)
		#endif

		if (!src.abilityHolder)
			src.abilityHolder = new /datum/abilityHolder/wraith(src)

		var/life_time_passed = max(life_tick_spacing, TIME - last_life_update)


		src.hauntBonus = 0
		if (src.haunting)
			for (var/mob/living/carbon/human/H in viewers(6, src))
				if (!H.stat && !H.bioHolder.HasEffect("revenant"))
					src.hauntBonus += 5
					if(istype(src, /mob/living/intangible/wraith/wraith_trickster))
						src.hauntBonus += 1

		for_by_tcl(V, /obj/machinery/wraith/vortex_wraith)
			if (V == linked_portal)
				if (IN_RANGE(src, V, 8))
					src.hauntBonus += 2
				break //we only ever have one

		if (src.next_area_change != null)
			if (src.next_area_change < TIME)
				next_area_change = TIME + 10 MINUTES
				get_new_booster_zones()

		if (get_area(src) in booster_locations)
			hauntBonus += 2

		if(hauntBonus > 0)
			src.abilityHolder.addBonus(src.hauntBonus * (life_time_passed / life_tick_spacing))

		src.abilityHolder.generatePoints(mult = (life_time_passed / life_tick_spacing))
		src.abilityHolder.updateText()

		if (src.health <= 0 )
			src.death(FALSE)
			return
		else if (src.health < src.max_health)
			HealDamage("chest", 1 * (life_time_passed / life_tick_spacing), 0)
		last_life_update = TIME

	death(gibbed)
		. = ..()

		//When a master wraith dies, any of its poltergeists who are following it are thrown out. also send a message
		drop_following_poltergeists()

		if (deaths < 2)
			//Back to square one with you!

			var/datum/abilityHolder/wraith/W = src.abilityHolder
			if(istype(W))
				W.corpsecount = 0
				var/datum/targetable/wraithAbility/absorbCorpse/absorb = W.getAbility(/datum/targetable/wraithAbility/absorbCorpse)
				absorb?.doCooldown()
			src.abilityHolder.points = 0
			src.abilityHolder.regenRate = 1
			src.health = initial(src.health) // oh sweet jesus it spammed so hard
			src.haunting = 0
			src.flags |= UNCRUSHABLE
			src.hauntBonus = 0
			deaths++
			src.delStatus("corporeal")
			if (src.mind)
				for (var/datum/objective/specialist/wraith/WO in src.mind.objectives)
					WO.onWeakened()

			boutput(src, SPAN_ALERT("<b>You have been defeated...for now. The strain of banishment has weakened you, and you will not survive another.</b>"))
			logTheThing(LOG_COMBAT, src, "lost a life as a wraith at [log_loc(src.loc)].")
			src.justdied = 1
			src.set_loc(pick_landmark(LANDMARK_LATEJOIN))
			SPAWN(15 SECONDS) //15 seconds
				src.justdied = 0
		else
			boutput(src, SPAN_ALERT("<b>Your connection with the mortal realm is severed. You have been permanently banished.</b>"))
			message_admins("Wraith [key_name(src)] died with no more respawns at [log_loc(src.loc)].")
			logTheThing(LOG_COMBAT, src, "died as a wraith with no more respawns at [log_loc(src.loc)].")
			if (src.mind)
				for (var/datum/objective/specialist/wraith/WO in src.mind.objectives)
					WO.onBanished()

			src.transforming = 1
			src.canmove = 0
			src.icon = null
			APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)

			if (client) client.set_color()

			animation = new(src.loc)
			animation.icon = 'icons/mob/mob.dmi'
			animation.icon_state = "wraithdie"
			animation.master = src
			FLICK(death_icon_state, animation)

			src.ghostize()
			qdel(src)

	//When a master wraith dies, any of its poltergeists who are following it are thrown out. also send a message
	proc/drop_following_poltergeists()
		if (src.poltergeists)
			for (var/mob/living/intangible/wraith/poltergeist/P in src.poltergeists)
				if (P.following_master && locate(P) in src.poltergeists)	//just to be safe
					var/turf/T1 = get_turf(src)
					var/tx = T1.x + rand(3 * -1, 3)
					var/ty = T1.y + rand(3 * -1, 3)

					var/turf/tmploc = locate(tx, ty, 1)
					if (isturf(tmploc))
						P.exit_master(tmploc)
					else
						P.exit_master(T1)
					P.setStatus("corporeal", INFINITE_STATUS, TRUE)
					boutput(P, SPAN_ALERT("<b>Oh no! Your master has died and you've been ejected outside into the material plane!</b>"))
				boutput(P, SPAN_ALERT("<b>Your master has died!</b>"))

	proc/onAbsorb(var/mob/M)
		if (src.mind)
			for (var/datum/objective/specialist/wraith/WO in src.mind.objectives)
				WO.onAbsorb(M)

	Cross(atom/movable/mover)
		if (istype(mover, /obj/projectile))
			var/obj/projectile/proj = mover
			if (proj.proj_data.hits_wraiths)
				return FALSE
		if (src.density)
			return FALSE
		else
			return TRUE


	projCanHit(datum/projectile/P)
		if (src.density || P.hits_wraiths) return 1
		else return FALSE


	bullet_act(var/obj/projectile/P)
		var/damage = 0
		damage = round((P.power*P.proj_data.ks_ratio), 1.0)

		switch (P.proj_data.damage_type)
			if (D_KINETIC)
				src.TakeDamage(null, damage, 0)
			if (D_PIERCING)
				src.TakeDamage(null, damage / 2, 0)
			if (D_SLASHING)
				src.TakeDamage(null, damage, 0)
			if (D_BURNING)
				src.TakeDamage(null, 0, damage)
			if (D_ENERGY)
				src.TakeDamage(null, 0, damage)

		if(!P.proj_data.silentshot)
			boutput(src, SPAN_ALERT("You are hit by the [P]!"))

	ex_act(severity)
		if (!src.density) return
		switch(severity)
			if(1)
				src.TakeDamage(null, 100)
				return
			if(2)
				src.TakeDamage(null, 80)
				return
			if(3)
				src.TakeDamage(null, 30)
				return

	TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss)
		if (!src.density)
			return
		health -= burn
		health -= brute * 3

		health = min(max_health, health)
		if (src.health <= 0)
			src.death(FALSE)
		health_update_queue |= src

	HealDamage(zone, brute, burn)
		TakeDamage(zone, -(brute / 3), -burn)

	//using this for updating the damage bar
	updatehealth()
		if (hud)
			hud.update_health()
		return

	Move(var/turf/NewLoc, direct)
		if (NewLoc.x == world.maxx || NewLoc.y == world.maxy)
			return

		if (src.density)
			for (var/obj/machinery/door/door in NewLoc)
				if (istype(door, /obj/machinery/door/poddoor))
					continue
				if (istype(door, /obj/machinery/door/feather) && !istype(door, /obj/machinery/door/feather/friendly))
					continue
				door.open()
			return ..()

		if (!src.density && !src.justdied)
			for (var/obj/decal/cleanable/saltpile/salt in NewLoc)
				src.setStatus("corporeal", src.forced_haunt_duration, TRUE)
				var/datum/targetable/ability = src.abilityHolder.getAbility(/datum/targetable/wraithAbility/haunt)
				ability.doCooldown()
				boutput(src, SPAN_ALERT("You have passed over salt! You now interact with the mortal realm..."))
				break

		return ..()

	can_use_hands()
		if (src.density) return 1
		else return 0

	is_active()
		if (src.density) return 1
		else return 0

	put_in_hand(obj/item/I, hand)
		return 0

	equipped()
		return 0

	click(atom/target)
		if (src.targeting_ability)
			return ..()
		if (!density)
			src.examine_verb(target)

	examine_verb(atom/A as mob|obj|turf in view())
		..()

		//Special info (that might eventually) be pertinent to the wraith.
		//the target's chaplain training, formaldehyde (in use), and holy water amounts.
		if (ismob(A))
			var/string = ""
			var/mob/M = A
			if (M.traitHolder.hasTrait("training_chaplain"))
				string += "[SPAN_ALERT("This creature is <b><i>vile</i></b>!")]\n"

			if (M.reagents)
				var/f_amt = M.reagents.get_reagent_amount("formaldehyde")
				if (f_amt >= src.formaldehyde_tolerance)
					string += "[SPAN_NOTICE("This creature is <i>saturated</i> with a most unpleasant substance!")]\n"
				else if (f_amt > 0)
					string += "[SPAN_NOTICE("This creature has a somewhat unpleasant <i>taste</i>.")]\n"

			if (length(string))
				boutput(src, string)


	say(var/message)
		message = trimtext(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
		if (!message)
			return

		if (src.density) //If corporeal speak to the living (garbled)
			logTheThing(LOG_DIARY, src, "(WRAITH): [message]", "say")
			SEND_SIGNAL(src, COMSIG_MOB_SAY, message)
			if (src.client && src.client.ismuted())
				boutput(src, "You are currently muted and may not speak.")
				return

			else
				if (copytext(message, 1, 2) == "*")
					src.emote(copytext(message, 2))
					return
				else
					src.emote(pick("hiss", "murmur", "drone", "wheeze", "grustle", "rattle"))

		else //Speak in ghostchat if not corporeal
			if (copytext(message, 1, 2) == "*")
				return

			logTheThing(LOG_DIARY, src, "(WRAITH): [message]", "say")

			if (src.client && src.client.ismuted())
				boutput(src, "You are currently muted and may not speak.")
				return

			. = src.say_dead(message, 1)

	emote(var/act)
		if (!density)
			return
		..()
		var/acts = null
		switch (act)
			if ("hiss")
				acts = "hisses"
			if ("murmur")
				acts = "murmurs"
			if ("drone")
				acts = "drones"
			if ("wheeze")
				acts = "wheezes"
			if ("grustle")
				acts = "grustles"
			if ("rattle")
				acts = "rattles"

		if (acts)
			for (var/mob/M in hearers(src, null))
				M.show_message(SPAN_ALERT("[src] [acts]!"))

	attack_hand(var/mob/user)
		user.lastattacked = get_weakref(src)
		if (user.a_intent != "harm")
			visible_message("[user] pets [src]!")
		else
			visible_message("[user] punches [src]!")
			TakeDamage("chest", 1, 0)




	//////////////
	// Wraith Procs
	//////////////
	proc/addAllBasicAbilities()
		src.addAbility(/datum/targetable/wraithAbility/help)
		src.addAbility(/datum/targetable/wraithAbility/absorbCorpse)
		src.addAbility(/datum/targetable/wraithAbility/possessObject)
		src.addAbility(/datum/targetable/wraithAbility/decay)
		src.addAbility(/datum/targetable/wraithAbility/command)
		src.addAbility(/datum/targetable/wraithAbility/animateObject)
		src.addAbility(/datum/targetable/wraithAbility/spook)
		src.addAbility(/datum/targetable/wraithAbility/whisper)
		src.addAbility(/datum/targetable/wraithAbility/blood_writing)
		src.addAbility(/datum/targetable/wraithAbility/haunt)
		src.addAbility(/datum/targetable/wraithAbility/toggle_deadchat)

	proc/removeAllAbilities()
		for (var/datum/targetable/wraithAbility/abil in abilityHolder.abilities)
			src.removeAbility(abil)

	proc/get_new_booster_zones()	//Get new zones you can get more power in.
		booster_locations = list()
		var/num_booster_areas = 3
		var/list/candidate_areas = list()
		for(var/area/A in valid_locations)
			for (var/datum/mind/D in A.population)
				if (!D.current?.client) continue
				if (!istype(D.current, /mob/living/carbon/human)) continue
				if (isdead(D.current)) continue
				candidate_areas += A
				break
		if (length(candidate_areas) < num_booster_areas)
			for (var/i in 1 to num_booster_areas - length(candidate_areas))
				candidate_areas |= pick(valid_locations)
		for(var/i in 1 to num_booster_areas)
			if (!length(candidate_areas)) break
			var/chosen = pick(candidate_areas)
			candidate_areas -= chosen
			booster_locations += get_area_name(chosen)
		var/list/safe_area_names = list()
		for (var/area/area as anything in booster_locations)
			safe_area_names += area.name
		boutput(src, SPAN_ALERT("<b>You will gather energy more rapidly if you are close to [get_battle_area_names(safe_area_names)]!</b>"))

	proc/makeRevenant(var/mob/M as mob)
		if (!ishuman(M))
			boutput(usr, SPAN_ALERT("You can only extend your consciousness into humans corpses."))
			return 1
		var/mob/living/carbon/human/H = M
		if (!isdead(H))
			boutput(usr, SPAN_ALERT("A living consciousness possesses this body. You cannot force your way in."))
			return 1
		if (H.decomp_stage == DECOMP_STAGE_SKELETONIZED)
			boutput(usr, SPAN_ALERT("This corpse is no good for this!"))
			return 1
		if (ischangeling(H))
			boutput(usr, SPAN_ALERT("What is this? An exquisite genetic structure. It forcibly resists your will, even in death."))
			return 1
		if (!H.bioHolder)
			message_admins("[key_name(src)] tried to possess [M] as a revenant but failed due to a missing bioholder.")
			boutput(usr, SPAN_ALERT("Failed."))
			return 1
		var/datum/bioEffect/hidden/revenant/R = H.bioHolder.AddEffect("revenant")
		if (H.bioHolder.HasEffect("revenant")) // make sure we didn't get deleted on the way - should probably make a better check than this. whatever.
			R.wraithPossess(src)
			return 0
		return 1

//////////////
// Subtypes
//////////////

/mob/living/intangible/wraith/wraith_decay
	name = "Plaguebringer"
	real_name = "plaguebringer"
	desc = "A pestilent ghost, spreading disease wherever it goes. Just looking at it makes you queasy."
	icon = 'icons/mob/mob.dmi'
	#ifdef APRIL_FOOLS
	icon_state = "wraith-jeans"
	#else
	icon_state = "wraith_plague"
	#endif

	New(var/mob/M)
		..()
		src.abilityHolder.regenRate = 3
		src.addAbility(/datum/targetable/wraithAbility/curse/blood)
		src.addAbility(/datum/targetable/wraithAbility/curse/enfeeble)
		src.addAbility(/datum/targetable/wraithAbility/curse/blindness)
		src.addAbility(/datum/targetable/wraithAbility/curse/rot)
		src.addAbility(/datum/targetable/wraithAbility/curse/death)
		src.addAbility(/datum/targetable/wraithAbility/poison)
		src.addAbility(/datum/targetable/wraithAbility/summon_rot_hulk)
		src.addAbility(/datum/targetable/wraithAbility/make_plague_rat)
		src.addAbility(/datum/targetable/wraithAbility/speak)
/mob/living/intangible/wraith/wraith_harbinger
	name = "Harbinger"
	real_name = "harbinger"
	desc = "An evil looking, regal specter. Usually seen commanding a horde of minions."
	icon = 'icons/mob/mob.dmi'
	#ifdef APRIL_FOOLS
	icon_state = "wraith-jeans"
	#else
	icon_state = "wraith_harbinger"
	#endif

	New(var/mob/M)
		..()
		src.abilityHolder.regenRate = 3
		src.addAbility(/datum/targetable/wraithAbility/create_summon_portal)
		src.addAbility(/datum/targetable/wraithAbility/raiseSkeleton)
		src.addAbility(/datum/targetable/wraithAbility/makeRevenant)
		src.addAbility(/datum/targetable/wraithAbility/harbinger_summon)
		src.addAbility(/datum/targetable/wraithAbility/speak)

/mob/living/intangible/wraith/wraith_trickster
	name = "trickster"
	real_name = "trickster"
	desc = "A living shadow seeking to disrupt the station with lies and deception."
	icon = 'icons/mob/mob.dmi'
	#ifdef APRIL_FOOLS
	icon_state = "wraith-jeans"
	#else
	icon_state = "wraith_trickster"
	#endif
	/// How many points do we need to possess someone?
	var/points_to_possess = 50
	/// Steal someone's appearance and use it during haunt
	var/mutable_appearance/copied_appearance = null
	/// Steal their descriptions and name too
	var/copied_desc = null
	var/copied_name = null
	var/copied_real_name = null
	var/copied_pronouns = null
	var/copied_footstep_sound = null
	var/copied_voice = null
	var/traps_laid = 0

	New(var/mob/M)
		..()
		src.abilityHolder.regenRate = 3
		src.addAbility(/datum/targetable/wraithAbility/choose_haunt_appearance)
		src.addAbility(/datum/targetable/wraithAbility/mass_whisper)
		src.addAbility(/datum/targetable/wraithAbility/dread)
		src.addAbility(/datum/targetable/wraithAbility/hallucinate)
		src.addAbility(/datum/targetable/wraithAbility/fake_sound)
		src.addAbility(/datum/targetable/wraithAbility/lay_trap)
		src.addAbility(/datum/targetable/wraithAbility/possess)
		src.addAbility(/datum/targetable/wraithAbility/make_poltergeist)

	Life(parent)
		if (..(parent))
			return 1
		if(src.haunting)
			for (var/mob/living/carbon/human/H in viewers(6, src))
				if (!H.stat && !H.bioHolder.HasEffect("revenant"))
					AH.possession_points ++

//////////////
// Related procs and verbs
//////////////

/proc/visibleBodies(var/mob/M)
	var/list/ret = new
	for (var/mob/living/carbon/human/H in view(M))
		if (istype(H) && isdead(H) && H.decomp_stage < DECOMP_STAGE_SKELETONIZED)
			ret += H
	return ret

/proc/generate_wraith_objectives(var/datum/mind/traitor)
	switch (rand(1,3))
		if (1)
			for(var/i in 1 to 3)
				new/datum/objective/specialist/wraith/murder(null, traitor)
		if (2)
			new/datum/objective/specialist/wraith/absorb(null, traitor)
			new/datum/objective/specialist/wraith/prevent(null, traitor)
		if (3)
			new/datum/objective/specialist/wraith/absorb(null, traitor)
			new/datum/objective/specialist/wraith/murder/absorb(null, traitor)
	switch (rand(1,3))
		if(1)
			new/datum/objective/specialist/wraith/travel(null, traitor)
		if(2)
			new/datum/objective/specialist/wraith/survive(null, traitor)
		if(3)
			new/datum/objective/specialist/wraith/flawless(null, traitor)
