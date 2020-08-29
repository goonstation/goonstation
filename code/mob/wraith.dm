// Wraith
// Technically neither living nor dead benefits us in such a way that we should be subclassing them.

/mob/wraith
	name = "Wraith"
	real_name = "Wraith" //todo: construct name from a user input (e.g. <x> the Impaler)
	desc = "Jesus Christ, how spooky."
	icon = 'icons/mob/mob.dmi'
	icon_state = "wraith"
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	density = 0
	canmove = 1
	blinded = 0
	anchored = 1
	alpha = 180
	event_handler_flags = USE_CANPASS | IMMUNE_MANTA_PUSH

	var/deaths = 0
	var/datum/hud/wraith/hud

	var/atom/movable/overlay/animation = null

	var/haunting = 0
	var/hauntBonus = 0
	var/justdied = 0

	var/last_life_update = 0
	var/const/life_tick_spacing = 20
	var/haunt_duration = 300
	var/death_icon_state = "wraithdie"
	//////////////
	// Wraith Overrides
	//////////////

	proc/make_name()
		var/len = rand(4, 8)
		var/vowel_prob = 0
		var/list/con = list("x", "z", "n", "k", "s", "l", "t", "r", "sh", "m", "d")
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
		theName = theName  + "[pick(" the Impaler", " the Tormentor", " the Forsaken", " the Destroyer", " the Devourer", " the Tyrant", " the Overlord", " the Damned", " the Desolator", " the Exiled")]"
		return theName


	New(var/mob/M)
		. = ..()
		src.invisibility = 16
		//src.sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
		src.sight |= SEE_SELF // let's not make it see through walls
		src.see_invisible = 16
		src.a_intent = "disarm"
		src.see_in_dark = SEE_DARK_FULL
		src.abilityHolder = new /datum/abilityHolder/wraith(src)
		src.abilityHolder.points = 50
		src.addAllAbilities()
		last_life_update = world.timeofday
		src.hud = new(src)
		src.attach_hud(hud)

		name = make_name()
		real_name = name

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
		src.updateButtons()
		var/atom/plane = client.get_plane(PLANE_LIGHTING)
		plane.alpha = 200

	Logout()
		..()
		if (src.last_client)
			var/atom/plane = last_client.get_plane(PLANE_LIGHTING)
			if (plane)
				plane.alpha = 255

	disposing()
		..()

	Stat()
		..()
		stat("Health:", src.health)

	Life(parent)
		if (..(parent))
			return 1

		if (src.client)
			src.antagonist_overlay_refresh(0, 0)

		if (!src.abilityHolder)
			src.abilityHolder = new /datum/abilityHolder/wraith(src)

		var/life_time_passed = max(life_tick_spacing, world.timeofday - last_life_update)

		if (src.haunting)
			src.hauntBonus = 0
			for (var/mob/living/carbon/human/H in viewers(6, src))
				if (!H.stat && !H.bioHolder.HasEffect("revenant"))
					src.hauntBonus += 5
			src.abilityHolder.addBonus(src.hauntBonus * (life_time_passed / life_tick_spacing))

		src.abilityHolder.generatePoints(mult = (life_time_passed / life_tick_spacing))

		if (src.health < 1)
			src.death(0)
			return
		else if (src.health < src.max_health)
			HealDamage("chest", 1 * (life_time_passed / life_tick_spacing), 0)
		last_life_update = world.timeofday

	// No log entries for unaffected mobs (Convair880).
	ex_act(severity)
		return

	death(gibbed)
		//Todo: some cool-ass effects here

		//Back to square one with you!

		var/datum/abilityHolder/wraith/W = src.abilityHolder
		if(istype(W))
			W.corpsecount = 0
		src.abilityHolder.points = 0
		src.abilityHolder.regenRate = 1
		src.health = initial(src.health) // oh sweet jesus it spammed so hard
		src.haunting = 0
		src.hauntBonus = 0
		deaths++
		src.makeIncorporeal()
		if (src.mind)
			for (var/datum/objective/specialist/wraith/WO in src.mind.objectives)
				WO.onWeakened()
		if (deaths < 2)
			boutput(src, "<span class='alert'><b>You have been defeated...for now. The strain of banishment has weakened you, and you will not survive another.</b></span>")
			src.justdied = 1
			src.set_loc(pick_landmark(LANDMARK_LATEJOIN))
			SPAWN_DBG(15 SECONDS) //15 seconds
				src.justdied = 0
		else
			boutput(src, "<span class='alert'><b>Your connection with the mortal realm is severed. You have been permanently banished.</b></span>")
			if (src.mind)
				for (var/datum/objective/specialist/wraith/WO in src.mind.objectives)
					WO.onBanished()

			src.transforming = 1
			src.canmove = 0
			src.icon = null
			src.invisibility = 101

			if (client) client.color = null

			animation = new(src.loc)
			animation.icon_state = "blank"
			animation.icon = 'icons/mob/mob.dmi'
			animation.master = src
			flick(death_icon_state, animation)

			src.ghostize()
			qdel(src)

	proc/onAbsorb(var/mob/M)
		if (src.mind)
			for (var/datum/objective/specialist/wraith/WO in src.mind.objectives)
				WO.onAbsorb(M)

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if (src.density) return 0
		else return 1


	projCanHit(datum/projectile/P)
		if (src.density) return 1
		else return 0


	bullet_act(var/obj/projectile/P)
		var/damage = 0
		damage = round((P.power*P.proj_data.ks_ratio), 1.0)

		switch (P.proj_data.damage_type)
			if (D_KINETIC)
				src.TakeDamage(null, damage, 0)
			if (D_PIERCING)
				src.TakeDamage(null, damage / 2.0, 0)
			if (D_SLASHING)
				src.TakeDamage(null, damage, 0)
			if (D_BURNING)
				src.TakeDamage(null, 0, damage)
			if (D_ENERGY)
				src.TakeDamage(null, 0, damage)

		if(!P.proj_data.silentshot)
			src.visible_message("<span class='alert'>[src] is hit by the [P]!</span>")


	TakeDamage(zone, brute, burn)
		if (!src.density)
			return
		health -= burn
		health -= brute * 3
		health = min(max_health, health)
		if (src.health <= 0)
			src.death(0)
		health_update_queue |= src

	HealDamage(zone, brute, burn)
		TakeDamage(zone, -(brute / 3), -burn)

	//using this for updating the damage bar
	updatehealth()
		if (hud)
			hud.update_health()
		return

	Move(var/turf/NewLoc, direct)
		if (loc)
			if (!isturf(loc) && !density)
				src.set_loc(get_turf(loc))
		else
			src.set_loc(locate(1,1,1))

		if(!canmove) return

		if(!isturf(src.loc)) src.set_loc(get_turf(src))

		if (NewLoc)
			if (isghostrestrictedz(NewLoc.z) && !restricted_z_allowed(src, NewLoc) && !(src.client && src.client.holder))
				var/OS = pick_landmark(LANDMARK_OBSERVER, locate(1, 1, 1))
				if (OS)
					src.set_loc(OS)
				else
					src.z = 1
				OnMove()
				return

			var/mydir = get_dir(src, NewLoc)
			var/salted = 0
			if (mydir == NORTH || mydir == EAST || mydir == WEST || mydir == SOUTH)
				if (src.density && !NewLoc.Enter(src))
					return

			else
				var/turf/vertical
				var/turf/horizontal
				var/blocked = 1
				if (mydir & NORTH)
					vertical = get_step(src, NORTH)
				else
					vertical = get_step(src, SOUTH)

				if (mydir & WEST)
					horizontal = get_step(src, WEST)
				else
					horizontal = get_step(src, EAST)

				var/turf/oldloc = loc
				var/horiz = 0
				var/vert = 0

				if (!src.density || vertical.Enter(src))
					vert = 1
					src.set_loc(vertical)
					if (!src.density || NewLoc.Enter(src))
						blocked = 0
						for(var/obj/decal/cleanable/saltpile/A in vertical)
							if (istype(A)) salted = 1
							if (salted) break
					src.set_loc(oldloc)

				if (!src.density || horizontal.Enter(src))
					horiz = 1
					src.set_loc(horizontal)
					if (!src.density || NewLoc.Enter(src))
						blocked = 0
						for(var/obj/decal/cleanable/saltpile/A in horizontal)
							if (istype(A)) salted = 1
							if (salted) break
					src.set_loc(oldloc)

				if (blocked)
					if (horiz)
						Move(horizontal)
						return
					else if (vert)
						Move(vertical)
						return
					return

			for(var/obj/decal/cleanable/saltpile/A in NewLoc)
				if (istype(A)) salted = 1
				if (salted) break

			dir = get_dir(loc, NewLoc)
			src.set_loc(NewLoc)
			OnMove()
			NewLoc.HasEntered(src)

			//if tile contains salt, wraith becomes corporeal
			if (salted && !src.density && !src.justdied)
				src.makeCorporeal()
				boutput(src, "<span class='alert'>You have passed over salt! You now interact with the mortal realm...</span>")
				SPAWN_DBG(1 MINUTE) //one minute
					src.makeIncorporeal()

			return

		//Z level boundary stuff
		if((direct & NORTH) && src.y < world.maxy)
			src.y++
		if((direct & SOUTH) && src.y > 1)
			src.y--
		if((direct & EAST) && src.x < world.maxx)
			src.x++
		if((direct & WEST) && src.x > 1)
			src.x--
		OnMove()


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
		. = ..()
		if (. == 100)
			return 100
		if (!density)
			src.examine_verb(target)

	say(var/message)
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
		if (!message)
			return

		if (src.density) //If corporeal speak to the living (garbled)
			logTheThing("diary", src, null, "(WRAITH): [message]", "say")

			if (src.client && src.client.ismuted())
				boutput(src, "You are currently muted and may not speak.")
				return

			if (copytext(message, 1, 2) == "*")
				src.emote(copytext(message, 2))
				return
			else
				src.emote(pick("hiss", "murmur", "drone", "wheeze", "grustle", "rattle"))

			//Todo: random pick of spooky things or maybe parse the original message somehow
			/*var/rendered = "<strong>[src.name]</strong> screeches incomprehensibly!"

			var/list/listening = all_hearers(null, src)
			listening -= src
			listening += src

			for (var/mob/M in listening)
				M.show_message(rendered, 2)*/

		else //Speak in ghostchat if not corporeal
			if (copytext(message, 1, 2) == "*")
				return

			logTheThing("diary", src, null, "(WRAITH): [message]", "say")

			if (src.client && src.client.ismuted())
				boutput(src, "You are currently muted and may not speak.")
				return

			. = src.say_dead(message, 1)

	emote(var/act)
		if (!density)
			return
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
				M.show_message("<span class='alert'>[src] [acts]!</span>")

	attack_hand(var/mob/user)
		user.lastattacked = src
		if (user.a_intent != "harm")
			visible_message("[user] pets [src]!")
		else
			visible_message("[user] punches [src]!")
			TakeDamage("chest", 1, 0)



	//////////////
	// Wraith Procs
	//////////////
	proc

		makeCorporeal()
			if (!src.density)
				src.set_density(1)
				src.invisibility = 0
				src.alpha = 255
				src.see_invisible = 0
				src.visible_message(pick("<span class='alert'>A horrible apparition fades into view!</span>", "<span class='alert'>A pool of shadow forms!</span>"), pick("<span class='alert'>A shell of ectoplasm forms around you!</span>", "<span class='alert'>You manifest!</span>"))

		makeIncorporeal()
			if (src.density)
				src.visible_message(pick("<span class='alert'>[src] vanishes!</span>", "<span class='alert'>The wraith dissolves into shadow!</span>"), pick("<span class='notice'>The ectoplasm around you dissipates!</span>", "<span class='notice'>You fade into the aether!</span>"))
				src.set_density(0)
				src.invisibility = 10
				src.alpha = 160
				src.see_invisible = 16

		haunt()
			if (src.density)
				src.show_message("<span class='alert'>You are already corporeal! You cannot use this ability.</span>")
				return 1

			src.makeCorporeal()
			src.haunting = 1

			SPAWN_DBG (haunt_duration)
				src.makeIncorporeal()
				src.haunting = 0

			return 0


		addAllAbilities()
			src.addAbility(/datum/targetable/wraithAbility/help)
			src.addAbility(/datum/targetable/wraithAbility/absorbCorpse)
			src.addAbility(/datum/targetable/wraithAbility/possessObject)
			src.addAbility(/datum/targetable/wraithAbility/makeRevenant)
			src.addAbility(/datum/targetable/wraithAbility/decay)
			src.addAbility(/datum/targetable/wraithAbility/command)
			src.addAbility(/datum/targetable/wraithAbility/raiseSkeleton)
			src.addAbility(/datum/targetable/wraithAbility/animateObject)
			src.addAbility(/datum/targetable/wraithAbility/haunt)
			src.addAbility(/datum/targetable/wraithAbility/spook)
			src.addAbility(/datum/targetable/wraithAbility/whisper)
			src.addAbility(/datum/targetable/wraithAbility/blood_writing)
			src.addAbility(/datum/targetable/wraithAbility/make_poltergeist)

		removeAllAbilities()
			src.removeAbility(/datum/targetable/wraithAbility/help)
			src.removeAbility(/datum/targetable/wraithAbility/absorbCorpse)
			src.removeAbility(/datum/targetable/wraithAbility/possessObject)
			src.removeAbility(/datum/targetable/wraithAbility/makeRevenant)
			src.removeAbility(/datum/targetable/wraithAbility/decay)
			src.removeAbility(/datum/targetable/wraithAbility/command)
			src.removeAbility(/datum/targetable/wraithAbility/raiseSkeleton)
			src.removeAbility(/datum/targetable/wraithAbility/animateObject)
			src.removeAbility(/datum/targetable/wraithAbility/haunt)
			src.removeAbility(/datum/targetable/wraithAbility/spook)
			src.removeAbility(/datum/targetable/wraithAbility/whisper)
			src.removeAbility(/datum/targetable/wraithAbility/blood_writing)
			src.removeAbility(/datum/targetable/wraithAbility/make_poltergeist)

		addAbility(var/abilityType)
			abilityHolder.addAbility(abilityType)


		removeAbility(var/abilityType)
			abilityHolder.removeAbility(abilityType)


		getAbility(var/abilityType)
			return abilityHolder.getAbility(abilityType)


		updateButtons()
			abilityHolder.updateButtons()

		makeRevenant(var/mob/M as mob)
			if (!ishuman(M))
				boutput(usr, "<span class='alert'>You can only extend your consciousness into humans corpses.</span>")
				return 1
			var/mob/living/carbon/human/H = M
			if (!isdead(H))
				boutput(usr, "<span class='alert'>A living consciousness possesses this body. You cannot force your way in.</span>")
				return 1
			if (H.decomp_stage == 4)
				boutput(usr, "<span class='alert'>This corpse is no good for this!</span>")
				return 1
			if (ischangeling(H))
				boutput(usr, "<span class='alert'>What is this? An exquisite genetic structure. It forcibly resists your will, even in death.</span>")
				return 1
			if (!H.bioHolder)
				message_admins("[key_name(src)] tried to possess [M] as a revenant but failed due to a missing bioholder.")
				boutput(usr, "<span class='alert'>Failed.</span>")
				return 1
			// Happens in wraithPossess() already.
			//src.abilityHolder.suspendAllAbilities()
			var/datum/bioEffect/hidden/revenant/R = H.bioHolder.AddEffect("revenant")
			if (H.bioHolder.HasEffect("revenant")) // make sure we didn't get deleted on the way - should probably make a better check than this. whatever.
				R.wraithPossess(src)
				return 0
			return 1


	//////////////
	// Wraith Verbs
	//////////////

	/*verb
		makeCorporealDebug()
			src.makeCorporeal()


		makeIncorporealDebug()
			src.makeIncorporeal()


		givePointsDebug()
			src.abilityHolder.points = 99999*/


//////////////
// Related procs and verbs
//////////////

// i am dumb - marq
/mob/proc/wraithize()
	if (src.mind || src.client)
		message_admins("[key_name(usr)] made [key_name(src)] a wraith.")
		logTheThing("admin", usr, src, "made [constructTarget(src,"admin")] a wraith.")
		return make_wraith()
	return null

/mob/proc/make_wraith()
	if (src.mind || src.client)
		var/mob/wraith/W = new/mob/wraith(src)

		var/turf/T = get_turf(src)
		if (!(T && isturf(T)) || ((isghostrestrictedz(T.z) || T.z != 1) && !(src.client && src.client.holder)))
			var/OS = pick_landmark(LANDMARK_OBSERVER, locate(1, 1, 1))
			if (OS)
				W.set_loc(OS)
			else
				W.z = 1
		else
			W.set_loc(T)

		if (src.mind)
			src.mind.transfer_to(W)
		else
			var/key = src.client.key
			if (src.client)
				src.client.mob = W
			W.mind = new /datum/mind()
			W.mind.key = key
			W.mind.current = W
			ticker.minds += W.mind
		qdel(src)

		//W.addAllAbilities()
		boutput(W, "<B>You are a wraith! Terrorize the mortals and drive them into releasing their life essence!</B>")
		boutput(W, "Your astral powers enable you to survive one banishment. Beware of salt.")
		boutput(W, "Use the question mark button in the lower right corner to get help on your abilities.")

		return W
	return null

/proc/visibleBodies(var/mob/M)
	var/list/ret = new
	for (var/mob/living/carbon/human/H in view(M))
		if (istype(H) && isdead(H) && H.decomp_stage < 4)
			ret += H
	return ret

/proc/generate_wraith_objectives(var/datum/mind/traitor)
	switch (rand(1,3))
		if (1)
			var/datum/objective/specialist/wraith/murder/M1 = new
			M1.owner = traitor
			M1.set_up()
			traitor.objectives += M1
			var/datum/objective/specialist/wraith/murder/M2 = new
			M2.owner = traitor
			M2.set_up()
			traitor.objectives += M2
			var/datum/objective/specialist/wraith/murder/M3 = new
			M3.owner = traitor
			M3.set_up()
			traitor.objectives += M3
		if (2)
			var/datum/objective/specialist/wraith/absorb/A1 = new
			A1.owner = traitor
			A1.set_up()
			traitor.objectives += A1
			var/datum/objective/specialist/wraith/prevent/P2 = new
			P2.owner = traitor
			P2.set_up()
			traitor.objectives += P2
		if (3)
			var/datum/objective/specialist/wraith/absorb/A1 = new
			A1.owner = traitor
			A1.set_up()
			traitor.objectives += A1
			var/datum/objective/specialist/wraith/murder/absorb/M2 = new
			M2.owner = traitor
			M2.set_up()
			traitor.objectives += M2
	switch (rand(1,3))
		if (1)
			var/datum/objective/specialist/wraith/travel/T = new
			T.owner = traitor
			T.set_up()
			traitor.objectives += T
		if (2)
			var/datum/objective/specialist/wraith/survive/T = new
			T.owner = traitor
			T.set_up()
			traitor.objectives += T
		if (3)
			var/datum/objective/specialist/wraith/flawless/T = new
			T.owner = traitor
			T.set_up()
			traitor.objectives += T
