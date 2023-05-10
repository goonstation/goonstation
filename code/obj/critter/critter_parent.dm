// p much straight up copied from secbot code =I


//don't attack mobs in santuary zones. attacking non-mobs there is fine
//we can only attack people in pods etc if we're also in the pod etc
#define ATTACK_CHECK(target) ((!ismob(target) || !((get_area(target))?:sanctuary)) && (isturf(target:loc) || target:loc == src.loc))

/obj/critter/
	name = "critter"
	desc = "you shouldnt be able to see this"
	icon = 'icons/misc/critter.dmi'
	var/living_state = null
	var/dead_state = null
	layer = 5
	density = 1
	anchored = UNANCHORED
	flags = FPRINT | CONDUCT | USEDELAY | FLUID_SUBMERGE
	event_handler_flags = USE_PROXIMITY | USE_FLUID_ENTER
	var/is_template = 0
	var/alive = 1
	var/health = 10
	var/maxhealth = 100

	// "sleeping" is a special state that sleeps for 10 cycles, wakes up, sleeps again unless someone is found
	// "hibernating" is another special state where it does nothing unless explicitly woken up
	var/task = "thinking"

	var/list/followed_path = null
	var/followed_path_retries = 0
	var/followed_path_retry_target = null
	var/follow_path_blindly = 0

	var/report_state = 0
	var/quality_name = null
	var/mobile = 1
	var/aggressive = 0
	var/defensive = 0
	var/wanderer = 1
	var/opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	var/frustration = 0
	var/last_found = null
	var/atom/movable/target = null
	var/oldtarget_name = null
	var/atom/target_lastloc = null
	var/atkcarbon = 0
	var/atksilicon = 0
	var/atcritter = 0
	var/atkintangible = 0
	var/attack = 0
	var/attacking = 0
	var/atk_delay = 25 // how long before a critter will attack again
	var/crit_chance = 5
	var/atk_diseases = null // can be a path to a disease or a list (lists will be picked from)
	var/atk_disease_prob = 0 // if atk_diseases isn't null, this is how likely it is that a disease will be contracted
	var/atk_brute_amt = 1 // how much brute to do per attack
	var/atk_burn_amt = 0 // how much burn to do per attack
	var/crit_brute_amt = 2
	var/crit_burn_amt = 0
	var/steps = 0
	var/firevuln = 1
	var/brutevuln = 1
	var/miscvuln = 0.2
	var/attack_range = 1 // how many tiles away it will attack from
	var/seekrange = 7 // how many tiles away it will look for a target
	var/list/friends = list() // used for tracking hydro-grown monsters's creator
	var/attacker = null // used for defensive tracking
	var/angertext = "charges at" // comes between critter name and target name
	var/pet_text = "pets"
	var/post_pet_text = null
	var/death_text = "%src% dies!"
	var/atk_text = "bites"
	var/chase_text = "leaps on"
	var/crit_text = "savagely bites"
	var/hitsound = null
	var/flying = 0
	//flags = OPENCONTAINER
	var/sleeping = 0 //countdown, when hits 0 does a wake check
	var/sleep_check = 10 //countdown, when hits 0 does a sleep check
	var/hibernate_check = 2
	var/wander_check = 0
	var/sleeping_icon_state = null
	var/mob/living/wrangler = null

	var/butcherable = 0
	var/meat_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat
	var/name_the_meat = 1

	var/critter_family = null
	var/generic = 1 // if yes, critter can be randomized a bit
	var/max_quality = 100
	var/min_quality = -100
	var/is_pet = null // if null gets determined based on capitalization, 0 = not pet, 1 = pet, 2 = command pet

	var/can_revive = 1 // resurrectable with strange reagent

	var/skinresult = null //type path of hide/leather item from skinning
	var/max_skins = 1	  //How many skins you can get at most from this critter. It's 1 to the max amound defined here. random.
	var/muted = 0 // shut UP

	var/chases_food = 0
	var/health_gain_from_food = 0
	var/obj/item/reagent_containers/food/snacks/food_target = null
	var/eat_text = "nibbles at"
	var/feed_text = null

	var/scavenger = 0
	var/mob/living/corpse_target = null

	var/area/registered_area = null //the area this critter is registered in
	var/parent = null			//the mob or obj/critter that is the progenitor of this critter. Currently only set via hatched eggs


	proc/tokenized_message(var/message, var/target)
		if (!message || !length(message))
			return
		var/msg = replacetext(message, "%src%", "<b>[src]</b>")
		msg = replacetext(msg, "%target%", "[target]")
		msg = replacetext(msg, "[constructTarget(target,"combat")]", "[target]")
		src.visible_message("<span class='alert'>[msg]</span>")

	proc/report_spawn()
		if (!report_state)
			report_state = 1
			if (src in gauntlet_controller.gauntlet)
				gauntlet_controller.increaseCritters(src)

	proc/report_death()
		if (report_state == 1)
			report_state = 0
			if (src in gauntlet_controller.gauntlet)
				gauntlet_controller.decreaseCritters(src)

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].aggressive"] << src.aggressive
		F["[path].atkcarbon"] << src.atkcarbon
		F["[path].atksilicon"] << src.atksilicon
		F["[path].health"] << src.health
		F["[path].opensdoors"] << src.opensdoors
		F["[path].wanderer"] << src.wanderer
		F["[path].mobile"] << src.mobile
		F["[path].brutevuln"] << src.brutevuln
		F["[path].firevuln"] << src.firevuln

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		F["[path].aggressive"] >> src.aggressive
		F["[path].atkcarbon"] >> src.atkcarbon
		F["[path].atksilicon"] >> src.atksilicon
		F["[path].health"] >> src.health
		F["[path].opensdoors"] >> src.opensdoors
		F["[path].wanderer"] >> src.wanderer
		F["[path].mobile"] >> src.mobile
		F["[path].brutevuln"] >> src.brutevuln
		F["[path].firevuln"] >> src.firevuln

	clone()
		var/obj/critter/C = ..()
		C.mobile = mobile
		C.aggressive = aggressive
		C.defensive = defensive
		C.atkcarbon = atkcarbon
		C.atksilicon = atksilicon
		C.health = health
		C.wanderer = wanderer
		C.brutevuln = brutevuln
		C.firevuln = firevuln
		return C

	proc/wake_from_hibernation()
		if(task != "hibernating") return

		//DEBUG_MESSAGE("[src] woke from hibernation at [log_loc(src)] in [registered_area ? registered_area.name : "nowhere"] due to [usr ? usr : "some mysterious fucking reason"]")
		//Ok, now we look to see if we should get murdlin'
		task = "sleeping"
		hibernate_check = 20 //20 sleep_checks
		do_wake_check(1)

		if(registered_area)
			registered_area.registered_critters -= src
			registered_area = null

		anchored = initial(anchored)
		//critters |= src //Resume processing this critter


	proc/hibernate()
		registered_area = get_area(src)
		hibernate_check = 20 //Reset this counter in case of failure
		if(registered_area)
			task = "hibernating"
			registered_area.registered_critters |= src
			anchored = ANCHORED
			//DEBUG_MESSAGE("[src] started hibernating at [log_loc(src)] in [registered_area ? registered_area.name : "nowhere"].")
			//critters -= src //Stop processing this critter


	HasProximity(atom/movable/AM as mob|obj)
		if(task == "hibernating" && ismob(AM))
			var/mob/living/M = AM
			if(M.client) wake_from_hibernation()

		..()

	set_loc(var/atom/newloc)
		..()
		wake_from_hibernation() //Critters hibernate lightly enough to wake up when moved

	proc/on_revive()
		return

	proc/on_sleep()

	proc/on_wake()
		var/area/A = get_area(src)
		if(A) A.wake_critters() //HLEP!

	proc/on_grump()

	attackby(obj/item/W, mob/living/user)
		..()
		if (!src.alive)
			if (src.skinresult && max_skins)
				if (issawingtool(W) || iscuttingtool(W) || issnippingtool(W))

					for(var/i, i<rand(1, max_skins), i++)
						new src.skinresult (src.loc)

					src.skinresult = null

					user.visible_message("<span class='alert'>[user] skins [src].</span>","You skin [src].")

			if (src.butcherable && (istype(W, /obj/item/kitchen/utensil/knife) || istype(W, /obj/item/knife/butcher)))
				user.visible_message("<span class='alert'>[user] butchers [src].[src.butcherable == 2 ? "<b>WHAT A MONSTER</b>" : null]","You butcher [src].</span>")

				var/i = rand(2,4)
				var/transfer = src.reagents.total_volume / i

				while (i-- > 0)
					var/obj/item/reagent_containers/food/newmeat = new meat_type
					newmeat.set_loc(src.loc)
					src.reagents.trans_to(newmeat, transfer)
					if (name_the_meat)
						newmeat.name = "[src.name] meat"
						newmeat.real_name = newmeat.name
				qdel (src)
				return
			..()
			return

		if (istype(W, /obj/item/reagent_containers/food/snacks) || istype(W, /obj/item/seed))
			boutput(user, "You offer [src] [W].")
			if (!do_mob(user, src, 1 SECOND) || BOUNDS_DIST(user, src) > 0)
				if (user && ismob(user))
					user.show_text("You were interrupted!", "red")
				return
			if (src.feed_text)
				src.visible_message("<span class='notice'>[src] [src.feed_text]</span>")
			eat_twitch(src)
			src.health = min(src.maxhealth, src.health + health_gain_from_food)
			user.drop_item()
			qdel(W)
			return

		user.lastattacked = src
		attack_particle(user,src)

		var/attack_force = 0
		var/damage_type = "brute"
		if (istype(W, /obj/item/artifact/melee_weapon))
			var/datum/artifact/melee/ME = W.artifact
			attack_force = ME.dmg_amount
			damage_type = ME.damtype
		else
			attack_force = W.force
			switch(W.hit_type)
				if (DAMAGE_BURN)
					damage_type = "fire"
				else
					damage_type = "brute"

		if (istype(W, /obj/item/device/flyswatter))
			var/obj/item/device/flyswatter/F = W
			if (src.critter_family == BUG)
				F.smack_bug(src, user)

		//Simplified weapon properties for critters. Fuck this shit.
		if(W.getProperty("searing"))
			damage_type = "fire"
			attack_force += W.getProperty("searing")

		if(W.hasProperty("vorpal"))
			attack_force += W.getProperty("vorpal")

		if(W.hasProperty("unstable"))
			attack_force = rand(attack_force, round(attack_force * W.getProperty("unstable")))

		if(W.hasProperty("frenzy"))
			SPAWN(0)
				var/frenzy = W.getProperty("frenzy")
				W.click_delay -= frenzy
				sleep(3 SECONDS)
				W.click_delay += frenzy
		///////////////////////////

		if (!attack_force)
			return

		if (src.sleeping)
			sleeping = 0
			on_wake()

		switch(damage_type)
			if("fire")
				src.health -= attack_force * max(1,(src.firevuln + W.getProperty("piercing")/100)) //Extremely half assed piercing for critters
			if("brute")
				src.health -= attack_force * max(1,(src.brutevuln + W.getProperty("piercing")/100))
			else
				src.health -= attack_force * max(1,(src.miscvuln + W.getProperty("piercing")/100))

		if (src.alive && src.health <= 0) src.CritterDeath()

		if (hitsound)
			playsound(src, hitsound, 50, 1)
		if (W?.hitsound)
			playsound(src,W.hitsound,50,1)

		if (src.alive)
			on_damaged(user)

		if(W.hasProperty("impact"))
			var/turf/T = get_edge_target_turf(src, get_dir(user, src))
			src.throw_at(T, 2, W.getProperty("impact"))

		if (src.defensive)
			if (src.target == user && src.task == "attacking")
				if (prob(50 - attack_force))
					return
				else
					src.visible_message("<span class='alert'><b>[src]</b> flinches!</span>")
			src.target = user
			src.oldtarget_name = user.name
			src.visible_message("<span class='alert'><b>[src]</b> [src.angertext] [user.name]!</span>")
			src.task = "chasing"
			on_grump()



	proc/on_damaged(mob/user)
		if(registered_area) //In case some butt fiddles with a hibernating critter
			registered_area.wake_critters(user)
		return


	proc/on_pet(mob/user)
		if(registered_area) //In case some nice person fiddles with a hibernating critter
			registered_area.wake_critters(user)
		if (!user)
			return 1 // so things can do if (..())
		return

	attack_hand(var/mob/user)
		..()
		if (!src.alive)
			return ..()

		if (src.sleeping)
			sleeping = 0
			on_wake()

		user.lastattacked = src
		attack_particle(user,src)

		if (user.a_intent == INTENT_HARM)
			src.health -= rand(1,2) * src.brutevuln
			src.visible_message("<span class='alert'><b>[user]</b> punches [src]!</span>")
			playsound(src.loc, pick(sounds_punch), 100, 1)
			attack_twitch(user)
			hit_twitch(src)
			if (hitsound)
				playsound(src, hitsound, 50, 1)
			if (src.alive && src.health <= 0) src.CritterDeath()
			if (src.alive)
				on_damaged(user)
			if (src.defensive)
				if (src.target == user && src.task == "attacking")
					if (prob(50))
						return
					else
						src.visible_message("<span class='alert'><b>[src]</b> flinches!</span>")
				src.target = user
				src.oldtarget_name = user.name
				src.visible_message("<span class='alert'><b>[src]</b> [src.angertext] [user.name]!</span>")
				src.task = "chasing"
				on_grump()
		else
			var/pet_verb = islist(src.pet_text) ? pick(src.pet_text) : src.pet_text
			var/post_pet_verb = islist(src.post_pet_text) ? pick(src.post_pet_text) : src.post_pet_text
			src.visible_message("<span class='notice'><b>[user]</b> [pet_verb] [src]![post_pet_verb]</span>", 1)
			on_pet(user)

	proc/patrol_step()
		if (!mobile)
			return

		var/turf/moveto = locate(src.x + rand(-1,1),src.y + rand(-1, 1),src.z)
		if(isturf(moveto) && !moveto.density) patrol_to(moveto)
		if(src.aggressive) seek_target()
		steps += 1
		//if (steps == rand(5,20)) src.task = "thinking" // what the fuck is wrong with you
		if (steps == wander_check)
			src.task = "thinking"
			wander_check = rand(5,20)

	proc/patrol_to(var/towhat)
		step_to(src, towhat)

	bump(atom/M as mob|obj)
		if ((isliving(M)) && (!src.anchored))
			src.set_loc(M.loc)
			src.frustration = 0

	bullet_act(var/obj/projectile/P)
		var/damage = 0
		damage = round((P.power*P.proj_data.ks_ratio), 1.0)

		if (src.sleeping)
			sleeping = 0
			on_wake()

		if(src.material) src.material.triggerOnBullet(src, src, P)

		switch(P.proj_data.damage_type)
			if(D_KINETIC,D_PIERCING,D_SLASHING)
				src.health -= (damage*brutevuln)
			if(D_ENERGY)
				src.health -= damage
			if(D_BURNING)
				src.health -= (damage*firevuln)
			if(D_RADIOACTIVE)
				src.health -= 1
			if(D_TOXIC)
				src.health -= 1

		on_damaged(usr)
		if (src.health <= 0)
			src.CritterDeath()

	ex_act(severity)

		if (src.sleeping)
			sleeping = 0
			on_wake()

		on_damaged()

		switch(severity)
			if(1)
				src.health -= 200
				if (src.health <= 0)
					src.CritterDeath()
				return
			if(2)
				src.health -= 75
				if (src.health <= 0)
					src.CritterDeath()
				return
			else
				src.health -= 25
				if (src.health <= 0)
					src.CritterDeath()
				return

	meteorhit()
		src.health -= 150 // no more instakill
		on_damaged()
		if (src.health <= 0)
			src.CritterDeath()
		return

	proc/check_health()
		if (src.health <= 0)
			src.CritterDeath()

	blob_act(var/power)
		src.health -= power
		on_damaged()
		if (src.health <= 0)
			src.CritterDeath()
		return

	proc/follow_path()
		if (!mobile)
			task = "thinking"
			return

		if (src.loc == followed_path_retry_target)
			logTheThing(LOG_DEBUG, null, "<B>Marquesas/Critter Astar:</b> Critter arrived at target location.")
			task = "thinking"
			followed_path = null
			followed_path_retries = 0
			followed_path_retry_target = null
		else if (!followed_path)
			logTheThing(LOG_DEBUG, null, "<B>Marquesas/Critter Astar:</b> Critter following empty path.")
			task = "thinking"
		else if (!followed_path.len)
			logTheThing(LOG_DEBUG, null, "<B>Marquesas/Critter Astar:</b> Critter path ran out.")
			task = "thinking"
		else
			var/turf/nextturf = followed_path[1]
			var/retry = 0
			if (nextturf.density)
				retry = 1
			if (!retry)
				for (var/obj/O in nextturf)
					if (O.density)
						retry = 1
						break
			if (retry)
				if (!followed_path_retry_target)
					task = "thinking"
				else if (followed_path_retries > 10)
					logTheThing(LOG_DEBUG, null, "<B>Marquesas/Critter Astar:</b> Critter out of retries.")
					task = "thinking"
				else
					logTheThing(LOG_DEBUG, null, "<B>Marquesas/Critter Astar:</b> Hit a wall, retrying.")
					followed_path = findPath(src.loc, followed_path_retry_target)
					return
			else
				step_to(src, nextturf)
				followed_path -= nextturf
		if (!follow_path_blindly)

			seek_target()

	proc/do_wake_check(var/force = 0)
		if(!force && sleeping-- > 0) return

		var/waking = 0

		for (var/client/C)
			var/mob/M = C.mob
			if (M && src.z == M.z && GET_DIST(src, M) <= 10)
				if (isliving(M))
					waking = 1
					break

		if(waking)
			hibernate_check = 20
			sleeping = 0
			task = "thinking"
			on_wake()
			if (sleeping_icon_state)
				src.icon_state = initial(src.icon_state)
			return 1
		else
			sleeping = 10
			if(--hibernate_check <= 0)
				src.hibernate()
			return 0

	proc/do_sleep_check(var/force = 0)
		if(!force && sleep_check-- > 0) return

		var/stay_awake = 0

		for (var/client/C)
			var/mob/M = C.mob
			if (M && src.z == M.z && GET_DIST(src, M) <= 10)
				if (isliving(M))
					stay_awake = 1
					break

		if(!stay_awake)
			sleeping = 10
			on_sleep()
			if (sleeping_icon_state)
				src.icon_state = sleeping_icon_state
			task = "sleeping"
			return 0
		else
			sleep_check = 10

	proc/process()
		if (is_template || task == "hibernating")
			return 0
		if (!src.alive)
			return 0
		if(sleeping > 0)
			sleeping--
			return 0

		check_health()

		if(task == "following path")
			follow_path()
			SPAWN(1 SECOND)
				follow_path()
		else if(task == "sleeping")
			do_wake_check()
		else
			do_sleep_check()

		return ai_think()

	proc/ai_think()
		switch(task)
			if ("thinking")
				src.attack = 0
				src.target = null

				walk_to(src, 0)

				if (src.aggressive) seek_target()
				if (src.wanderer && src.mobile && !src.target) src.task = "wandering"

			if ("chasing")
				if (src.frustration >= 8)
					src.target = null
					src.food_target = null
					src.corpse_target = null
					src.last_found = world.time
					src.frustration = 0
					src.task = "thinking"

					if (mobile)
						walk_to(src, 0)

				var/atom/current_target
				if (src.target)
					current_target = src.target
				else if (src.scavenger && src.corpse_target)
					current_target = src.corpse_target
				else if (src.chases_food && src.food_target)
					current_target = src.food_target

				if (current_target)
					if (GET_DIST(src, current_target) <= src.attack_range)
						if (current_target == src.corpse_target)
							src.task = "scavenging"
						else if (current_target == src.food_target)
							src.task = "eating"
						else
							if(ATTACK_CHECK(current_target))
								ChaseAttack(current_target)
							src.task = "attacking"
							src.anchored = ANCHORED
							src.target_lastloc = current_target.loc
					else
						if (mobile)
							var/turf/olddist = GET_DIST(src, current_target)
							walk_to(src, current_target,1,4)
							if ((GET_DIST(src, current_target)) >= (olddist))
								src.frustration++
								step_towards(src, current_target, 4)
							else
								src.frustration = 0
						else
							if (GET_DIST(src, current_target) > attack_range)
								src.frustration++
							else
								src.frustration = 0
				else
					src.task = "thinking"

			if ("chasing food")

				if (!src.chases_food || src.food_target == null)
					src.task = "thinking"
				else if (GET_DIST(src, src.food_target) <= src.attack_range)
					src.task = "eating"
				else if (src.mobile)
					walk_to(src, src.food_target,1,4)

			if ("eating")

				if (GET_DIST(src, src.food_target) > src.attack_range)
					src.task = "chasing"// food"
				else
					src.task = "eating2"

			if ("eating2")

				if (GET_DIST(src, src.food_target) > src.attack_range)
					src.task = "chasing"// food"
				else
					src.visible_message("<b>[src]</b> [src.eat_text] [src.food_target].")
					playsound(src.loc,'sound/items/eatfood.ogg', rand(10,50), 1)
					if (food_target)
						if (food_target.bites_left) src.food_target.bites_left-- //ZeWaka: Fix for null. bites_left
						if (food_target.reagents && food_target.reagents.total_volume > 0 && src.reagents.total_volume < 30)
							food_target.reagents.trans_to(src, 5)
					if (src.food_target != null && src.food_target.bites_left <= 0)
						src.food_target.set_loc(null)
						SPAWN(1 SECOND)
							qdel(src.food_target)
						src.task = "thinking"
						src.food_target = null
						src.health = min(src.maxhealth, src.health + health_gain_from_food)

			if ("chasing corpse")

				if (!src.scavenger || src.corpse_target == null)
					src.task = "thinking"
				else if (GET_DIST(src, src.corpse_target) <= src.attack_range)
					src.task = "scavenging"
				else if (src.mobile)
					walk_to(src, src.corpse_target,1,4)

			if ("scavenging")

				if (!src.scavenger || src.corpse_target == null)
					src.task = "thinking"
				if (GET_DIST(src, src.corpse_target) > src.attack_range)
					src.task = "chasing"// corpse"
				var/mob/living/carbon/human/C = src.corpse_target
				src.visible_message("<b>[src]</b> gnaws some meat off [src.corpse_target]'s body!")
				playsound(src.loc,'sound/items/eatfood.ogg', rand(10,50), 1)
				sleep(rand(20,30))
				if (prob(20))
					C.decomp_stage += 1
					C.update_body()
					C.update_face()
					switch (C.decomp_stage)
						if (DECOMP_STAGE_SKELETONIZED)
							src.visible_message("<span class='combat'><b>[src]</b> tears the last piece of meat off [src.corpse_target]!</span>")
							src.task = "thinking"
							src.corpse_target = null
						if (DECOMP_STAGE_HIGHLY_DECAYED)
							src.visible_message("<span class='alert'><b>[src]</b> has eaten most of the flesh from [src.corpse_target]'s bones!")
						if (DECOMP_STAGE_DECAYED)
							src.visible_message("<span class='alert'><b>[src]</b> has eaten enough of [src.corpse_target] that their bones are showing!")

			if ("attacking")

				// see if he got away
				if ((GET_DIST(src, src.target) > src.attack_range) || ((src.target:loc != src.target_lastloc)))
					src.anchored = initial(src.anchored)
					src.task = "chasing"
				else
					if (GET_DIST(src, src.target) <= src.attack_range)
						var/mob/living/carbon/M = src.target
						if (!src.attacking)
							if(ATTACK_CHECK(src.target))
								CritterAttack(src.target)
								if (src)
									attack_twitch(src)
								if (src.target)
									hit_twitch(src.target)
						if (!src.aggressive)
							src.task = "thinking"
							src.target = null
							src.anchored = initial(src.anchored)
							src.last_found = world.time
							src.frustration = 0
							src.attacking = 0
						else
							if(M!=null)
								if (M.health <= 0 || !isalive(M))
									src.task = "thinking"
									src.target = null
									src.anchored = initial(src.anchored)
									src.last_found = world.time
									src.frustration = 0
									src.attacking = 0
					else
						src.anchored = initial(src.anchored)
						src.attacking = 0
						src.task = "chasing"
			if ("wandering")

				patrol_step()
		return 1


	New(loc)
		if(!src.reagents) src.create_reagents(100)
		wander_check = rand(5,20)
		START_TRACKING_CAT(TR_CAT_CRITTERS)
		report_spawn()
		if(isnull(src.is_pet))
			src.is_pet = !generic && (copytext(src.name, 1, 2) in uppercase_letters)
		if(in_centcom(loc) || current_state >= GAME_STATE_PLAYING)
			src.is_pet = 0
		if(src.is_pet)
			START_TRACKING_CAT(TR_CAT_PETS)
		if(generic)
			src.quality = rand(min_quality,max_quality)
			var/nickname = getCritterQuality(src.quality)
			if(nickname)
				src.quality_name = nickname
				src.name = "[nickname] [src.name]"
		..()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_CRITTERS)
		registered_area?.registered_critters -= src
		if(src.is_pet)
			STOP_TRACKING_CAT(TR_CAT_PETS)
		..()

	proc/seek_target()
		src.anchored = initial(src.anchored)
		if (src.target)
			src.task = "chasing"
			return

		if (src.scavenger)
			if (src.corpse_target)
				src.task = "chasing"// corpse"
				return
			var/list/visible = new()
			for (var/mob/living/carbon/human/H in view (src.seekrange,src))
				if (isdead(H) && H.decomp_stage <= DECOMP_STAGE_HIGHLY_DECAYED && !H.bioHolder?.HasEffect("husk")) //is dead, isn't a skeleton, isn't a grody husk
					visible.Add(H)
				else continue
			if (src.corpse_target && (src.corpse_target in visible))
				src.task = "chasing"// corpse"
				return
			else
				src.task = "thinking"
			if (visible.len)
				src.corpse_target = visible[1]
				src.visible_message("<span class='alert'><b>[src]</b> eyes [src.corpse_target.name] hungrily!</span>")
				src.task = "chasing"// corpse"

		if (src.chases_food)
			var/list/visible = new()
			for (var/obj/item/reagent_containers/food/snacks/S in view(src.seekrange,src))
				visible.Add(S)
			if (src.food_target && (src.food_target in visible))
				src.task = "chasing"// food"
				return
			else
				src.task = "thinking"
			if (visible.len)
				src.food_target = visible[1]
				src.task = "chasing"// food"

		for (var/mob/living/C in hearers(src.seekrange,src))
			//if (src.target)
			//	src.task = "chasing"
			//	break
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (iscarbon(C) && !src.atkcarbon) continue
			if (issilicon(C) && !src.atksilicon) continue
			if (isintangible(C) && !src.atkintangible) continue
			if (C.health < 0) continue
			if(!filter_target(C)) continue
			if (C in src.friends) continue
			if (ishuman(C))
				if (C.bioHolder?.HasEffect("revenant") || C.bioHolder?.HasEffect("husk"))
					continue
			if (C.name == src.attacker) src.attack = 1
			if (iscarbon(C) && src.atkcarbon) src.attack = 1
			if (issilicon(C) && src.atksilicon) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				src.visible_message("<span class='combat'><b>[src]</b> [src.angertext] [C.name]!</span>")
				src.task = "chasing"
				on_grump()
				break
			else
				continue

	proc/filter_target(var/mob/living/M) //Better to have specialized filters in it's own proc rather than overriding the main seek_target thing imo
		return 1

	proc/CritterDeath()
		SHOULD_CALL_PARENT(TRUE)
		if (!src.alive) return

		#ifdef COMSIG_OBJ_CRITTER_DEATH
		SEND_SIGNAL(src, COMSIG_OBJ_CRITTER_DEATH)
		#endif

		if (!dead_state)
			src.icon_state = "[initial(src.icon_state)]-dead"
		else
			src.icon_state = dead_state
		src.alive = 0
		src.anchored = UNANCHORED
		src.set_density(0)
		walk_to(src,0) //halt walking
		report_death()
		src.tokenized_message(death_text)

	proc/ChaseAttack(mob/M)
		src.visible_message("<span class='combat'><B>[src]</B> [src.chase_text] [src.target]!</span>")
		if (isliving(M))
			var/mob/living/H = M
			H.was_harmed(src)

	proc/CritterAttack(mob/M)
		src.attacking = 1
		if (prob(src.crit_chance))
			CritAttack(M)
		else
			src.visible_message("<span class='combat'><B>[src]</B> [src.atk_text] [src.target]!</span>")
			random_brute_damage(src.target, src.atk_brute_amt,1)
			random_burn_damage(src.target, src.atk_burn_amt)
		if (isliving(M))
			var/mob/living/H = M
			H.was_harmed(src)
		SPAWN(src.atk_delay)
			src.attacking = 0
		if (iscarbon(M) && src.atk_diseases && prob(src.atk_disease_prob))
			var/mob/living/carbon/C = M
			if (islist(src.atk_diseases))
				C.contract_disease(pick(src.atk_diseases), null, null, 1) // path, name, strain, bypass resist
			else if (ispath(src.atk_diseases))
				C.contract_disease(src.atk_diseases, null, null, 1) // path, name, strain, bypass resist

	proc/CritAttack(mob/M)
		src.visible_message("<span class='combat'><B>[src]</B> [src.crit_text] [src.target]!</span>")
		random_brute_damage(src.target, src.crit_brute_amt,1)
		random_burn_damage(src.target, src.crit_burn_amt)

	proc/getCritterQuality(var/quality)
		switch(quality)
			if(-INFINITY to -100)
				return "abysmal"
			if(-100 to -99)
				return "worst"
			if(-98 to -91)
				return pick("shameful", "hideous", "grotesque", "vile", "misshapen", "garbage", "illegal", "dreadful", "god-awful")
			if(-90 to -75)
				return pick("ugly", "grody", "stinky", "awful", "diseased", "filthy", "lousy", "overweight", "broken", "unfortunate", "unacceptable", "sad", "slipshod", "crappy", "faulty", "fraudulent")
			if(-74 to -50)
				return pick("shabby", "mangy", "dented", "dusty", "sub-par", "slightly less nice", "weird", "crummy", "busted", "funky", "bad news", "deficient", "cruddy", "icky", "not good")
			if(-49 to 50)
				return ""
			if(51 to 64)
				return pick("nice", "cute", "healthy", "buff", "strong")
			if(65 to 74)
				return pick("suave", "buff", "robust", "handsome", "fine", "slightly nicer", "pretty good")
			if(75 to 85)
				return pick("high-class", "great", "burly", "superb", "excellent", "admirable")
			if(86 to 90)
				return pick("majestic", "fantastic", "high-quality", "marvelous", "deluxe")
			if(91 to 94)
				return pick("show-quality", "finest", "superb")
			if(95 to 97)
				return "champion"
			if(98 to 99)
				src.setMaterial(getMaterial("gold"), appearance = 0, setname = 0)
				return "best"
			if(100 to INFINITY)
				src.setMaterial(getMaterial("gold"), appearance = 0, setname = 0)
				return "mystical"
			else
				return "odd"

	proc/Shoot(var/target, var/start, var/user, var/bullet = 0)
		if(target == start)
			return

		if (!isturf(target))
			return
		// FUCK YOU WHOEVER IS USING THIS
		// FUCK YOU
		shoot_projectile_ST(src,  new/datum/projectile/bullet/revolver_38(), target)
		return


/obj/item/reagent_containers/food/snacks/ingredient/egg/critter
	name = "egg"
	desc = "Looks like this could hatch into something."
	icon_state = "critter_egg"
	var/critter_name = null
	var/hatched = 0
	var/critter_type = null
	var/warm_count = 10 // how many times you gotta warm it before it hatches
	var/critter_reagent = null
	var/parent = null
	rand_pos = 1

	New()
		..()
		var/amt_to_mod = round(src.warm_count / 10, 1)
		src.warm_count += rand(-amt_to_mod,amt_to_mod)
		src.color = random_saturated_hex_color(1)
		if (src.reagents && src.critter_reagent)
			src.reagents.add_reagent(src.critter_reagent, 10)

	attack_hand(mob/user)
		if (src.anchored)
			return
		else
			..()

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/pen))
			var/t = input(user, "Enter new name", src.name, src.critter_name) as null|text
			logTheThing(LOG_DEBUG, user, "names a critter egg \"[t]\"")
			if (!t)
				return
			phrase_log.log_phrase("name-critter", t, no_duplicates=TRUE)
			t = strip_html(replacetext(t, "'",""))
			t = copytext(t, 1, 65)
			if (!t)
				return
			if (!in_interact_range(src, user) && src.loc != user)
				return

			src.critter_name = t

		else if ((isweldingtool(W) && W:try_weld(user,0,-1,0,0)) || (istype(W, /obj/item/clothing/head/cakehat) && W:on) || istype(W, /obj/item/device/igniter) || ((istype(W, /obj/item/device/light/zippo) || istype(W, /obj/item/match) || istype(W, /obj/item/device/light/candle)) && W:on) || W.burning || W.hit_type == DAMAGE_BURN) // jesus motherfucking christ
			user.visible_message("<span class='alert'><b>[user]</b> warms [src] with [W].</span>",\
			"<span class='alert'>You warm [src] with [W].</span>")
			src.warm_count -= 2
			src.warm_count = max(src.warm_count, 0)
			src.hatch_check(0, user)
		else
			return ..()

	attack_self(mob/user as mob)
		if (src.anchored)
			return
		user.visible_message("[user] warms [src] with [his_or_her(user)] hands.",\
		"You warm [src] with your hands.")
		src.warm_count --
		src.warm_count = max(src.warm_count, 0)
		src.hatch_check(0, user)

	throw_impact(atom/A, datum/thrown_thing/thr)
		var/turf/T = get_turf(A)
		//..() <- Fuck off mom, I'm 25 and I do what I want =I
		src.hatch_check(1, null, T)

	proc/hatch_check(var/shouldThrow = 0, var/mob/user, var/turf/T)
		if (hatched || anchored)
			return
		if (src.warm_count <= 0 || shouldThrow)
			hatched = TRUE
			if (shouldThrow && T)
				make_cleanable( /obj/decal/cleanable/eggsplat,T)
				src.set_loc(T)
			else
				src.anchored = ANCHORED
				src.layer = initial(src.layer)
				if (user)
					user.u_equip(src)
				src.set_loc(get_turf(src))

			if (shouldThrow && T)
				src.visible_message("<span class='alert'>[src] splats onto the floor messily!</span>")
				playsound(T, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
			else
				var/hatch_wiggle_counter = rand(3,8)
				while (hatch_wiggle_counter-- > 0)
					src.pixel_x++
					sleep(0.2 SECONDS)
					src.pixel_x--
					sleep(1 SECOND)
				src.visible_message("[src] hatches!")

			if (!ispath(critter_type))
				if (istext(critter_type))
					critter_type = text2path(critter_type)
				else
					logTheThing(LOG_DEBUG, null, "EGG: [src] has invalid critter path!")
					src.visible_message("Looks like there wasn't anything inside of [src]!")
					qdel(src)
					return

			var/obj/critter/newCritter = new critter_type(T ? T : get_turf(src), src.parent)

			if (critter_name)
				newCritter.name = critter_name

			if (shouldThrow && T)
				newCritter.throw_at(get_edge_target_turf(src, src.dir), 2, 1)

			//hack. Clownspider queens keep track of their babies.
			if (istype(src.parent, /mob/living/critter/spider/clownqueen))
				var/mob/living/critter/spider/clownqueen/queen = src.parent
				if (islist(queen.babies))
					queen.babies += newCritter

			sleep(0.1 SECONDS)
			qdel(src)
			return newCritter
		else
			return

/obj/critter/proc/revive_critter()
	USR_ADMIN_ONLY
	var/obj/critter/C = src
	if (!istype(C, /obj/critter))
		boutput(src, "[C] isn't a critter! How did you even get here?!")
		return

	if (!C.alive || C.health <= 0)
		C.health = initial(C.health)
		C.alive = 1
		C.icon_state = copytext(C.icon_state, 1, -5) // if people aren't being weird about the icons it should just remove the "-dead"
		C.set_density(initial(C.density))
		C.on_revive()
		C.visible_message("<span class='alert'>[C] seems to rise from the dead!</span>")
		logTheThing(LOG_ADMIN, src, "revived [C] (critter).")
		message_admins("[key_name(src)] revived [C] (critter)!")
	else
		boutput(src, "[C] isn't dead, you goof!")
		return

/obj/critter/proc/kill_critter()
	USR_ADMIN_ONLY
	var/obj/critter/C = src
	if (!istype(C, /obj/critter))
		boutput(src, "[C] isn't a critter! How did you even get here?!")
		return

	if (C.alive)
		C.health = 0
		C.CritterDeath()
		logTheThing(LOG_ADMIN, src, "killed [C] (critter).")
		message_admins("[key_name(src)] killed [C] (critter)!")
	else
		boutput(src, "[C] isn't alive, you goof!")
		return

#undef ATTACK_CHECK
