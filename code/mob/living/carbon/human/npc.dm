
#define IS_NPC_HATED_ITEM(x) ( \
		istype(x, /obj/item/clothing/suit/straight_jacket) || \
		istype(x, /obj/item/handcuffs) || \
		istype(x, /obj/item/device/radio/electropack) || \
		x:block_vision \
	)
#define IS_NPC_CLOTHING(x) ( \
		( \
			istype(x, /obj/item/clothing) || \
			istype(x, /obj/item/device/radio/headset) || \
			istype(x, /obj/item/card/id) || \
			x.flags & ONBELT || \
			x.flags & ONBACK \
		) && !IS_NPC_HATED_ITEM(x) \
	)


/mob/living/carbon/human/npc
	name = "human"
	real_name = "human"
	is_npc = 1
	ai_attacknpc = 0
	New()
		..()
		SPAWN(0)
			src.mind = new(src)
			if (src.name == "human")
				randomize_look(src, 1, 1, 1, 1, 1, 0) // change gender/bloodtype/age/name/underwear, keep bioeffects
				src.organHolder.head.UpdateIcon()
		SPAWN(1 SECOND)
			set_clothing_icon_dirty()
		SPAWN(2 SECONDS)
			ai_init()

/mob/living/carbon/human/npc/assistant
	ai_aggressive = 1

	New()
		..()
		SPAWN(0)
			JobEquipSpawned("Staff Assistant")

	ai_findtarget_new()
		if((world.timeofday - ai_threatened) < 600)
			..()

	proc/cry_grief(mob/M)
		if(!M)
			return
		if(isdead(src))
			return
		src.target = M
		src.ai_state = AI_ATTACKING
		src.ai_threatened = world.timeofday
		var/target_name = M.name
		//var/area/current_loc = get_area(src)
		//var/tmp/loc_name = lowertext(current_loc.name) // removing this because nobody believes it
		var/complaint = pick("[target_name] [pick("is killing","is griefing","is trying to kill","just fucking tried to kill")] me",\
		"getting griefed, help",\
		"security!!!",\
		"[target_name] just fucking attacked me",\
		"SOMEONE [prob(40) ? "FUCKING " : ""]ARREST [uppertext(target_name)]",\
		"need help",\
		"[uppertext(target_name)] IS [prob(50) ? "A TRAITOR" : "AN ANTAG"] [prob(40) ? "FUCKING" : ""] HELP [prob(40) ? "ME" : ""]",\
		"[prob(40) ? "please" : ""] I need help can someone [prob(50) ? "hear" : "help"] me",\
		"[uppertext(target_name)] WON'T [prob(40) ? "FUCKING " : ""]LEAVE ME ALONE, HELP",\
		"SOMEONE [prob(40) ? "PLEASE " : ""] [prob(40) ? "FUCKING" : ""] HELP [prob(40) ? "ME" : ""] [prob(40) ? "I SWEAR TO GOD" : ""]",\
		"[prob(40) ? "FUCKING" : ""] GRIEFERES WON'T LEAVE ME ALONE",\
		"[pick("HLEP","HELP")] ME [uppertext(target_name)] IS [prob(40) ? "FUCKING " : ""]KILLING ME")
		if(prob(60))
			complaint = uppertext(complaint)
		var/max_excl = rand(-2,4)
		for(var/i = 0, i < max_excl, i++)
			complaint += "!"
		src.say(";[complaint]")

	attack_hand(mob/M)
		..()
		if(M.a_intent in list(INTENT_HARM,INTENT_DISARM,INTENT_GRAB))
			if(!ON_COOLDOWN(src, "cry_grief", 5 SECONDS))
				SPAWN(rand(10,30))
					src.cry_grief(M)

	attackby(obj/item/W, mob/M)
		var/oldbloss = get_brute_damage()
		var/oldfloss = get_burn_damage()
		..()
		var/damage = ((get_brute_damage() - oldbloss) + (get_burn_damage() - oldfloss))
		if((damage > 0) || W.force)
			if(!ON_COOLDOWN(src, "cry_grief", 5 SECONDS))
				SPAWN(rand(10,30))
					src.cry_grief(M)



//// rest in peace NPC classic-mentally challenged idiots, you were shit ////


/mob/living/carbon/human/npc/syndicate
	ai_aggressive = 1
	New()
		..()
		SPAWN(0)
			if(ticker?.mode && istype(ticker.mode, /datum/game_mode/nuclear))
				src.real_name = "[syndicate_name()] Operative #[ticker.mode:agent_number]"
				ticker.mode:agent_number++
			else
				src.real_name = "Syndicate Agent"
			JobEquipSpawned("Syndicate Operative")
			u_equip(l_store) // Deletes syndicate remote teleporter to keep people out of the syndie shuttle
			u_equip(r_store) // Deletes uplink radio because fuckem

/mob/living/carbon/human/npc/syndicate_weak
	ai_aggressive = 1
	New()
		..()
		SPAWN(0)
			src.real_name = "Junior Syndicate Agent"
			JobEquipSpawned("Junior Syndicate Operative")

/mob/living/carbon/human/npc/syndicate_weak/no_ammo
	ai_aggressive = 1
	New()
		..()
		SPAWN(0)
			src.real_name = "Junior Syndicate Agent"
			JobEquipSpawned("Poorly Equipped Junior Syndicate Operative")

//reverse blade samurai

// npc ai procs

//NOTE TO SELF: BYONDS TIMING FUNCTIONS ARE INACCURATE AS FUCK
//ADD HELP INTEND.

//0 = Pasive, 1 = Getting angry, 2 = Attacking , 3 = Helping, 4 = Idle , 5 = Fleeing(??)

/mob/living/carbon/human/proc/ai_set_active(active)
	if (ai_active != active)
		ai_active = active

		if (ai_active)
			if(src.skipped_mobs_list & SKIPPED_MOBS_LIST)
				src.skipped_mobs_list |= SKIPPED_AI_MOBS_LIST
			else
				ai_mobs.Add(src)
		else
			src.skipped_mobs_list &= ~SKIPPED_AI_MOBS_LIST
			ai_mobs.Remove(src)

/mob/living/carbon/human/proc/ai_init()
	ai_set_active(1)
	ai_laststep = 0
	ai_state = AI_PASSIVE
	ai_target = null
	ai_threatened = 0
	ai_movedelay = 3
	ai_attacked = 0

	if(abilityHolder)
		if(!abilityHolder.getAbility(/datum/targetable/ai_toggle))
			abilityHolder.addAbility(/datum/targetable/ai_toggle)

/mob/living/carbon/human/proc/ai_stop()
	ai_set_active(0)
	ai_laststep = 0
	ai_state = AI_PASSIVE
	ai_target = null
	ai_threatened = 0
	ai_movedelay = 3
	ai_attacked = 0

/mob/living/carbon/human/proc/ai_process()
	if(!ai_active) return
	if(world.time < ai_lastaction + ai_actiondelay) return
	usr = src

	var/action_delay = 0
	delStatus("resting")
	if(hud?.master) hud.update_resting()

	if (isdead(src))
		ai_set_active(0)
		ai_target = null
		walk_towards(src, null)
		return

	//Moving this up because apparently beds were tripping the AI up.
	if(src.buckled && !src.hasStatus("handcuffed"))
		src.buckled.Attackhand(src)
		if(src.buckled) //WE'RE STUCKED :C
			return

		action_delay += 5

	if(ai_incapacitated())
		action_delay = 10
		ai_lastaction = world.time
		walk_towards(src, null)
		return

	if(!src.restrained() && !src.lying && !src.buckled)
		ai_action()
	if(ai_busy && !src.hasStatus("handcuffed"))
		ai_busy = 0
	if(src.hasStatus("handcuffed"))
		ai_target = null
		ai_state = AI_PASSIVE
		if(src.canmove && !ai_busy)
			actions.start(new/datum/action/bar/private/icon/handcuffRemoval(1 MINUTE + rand(-10 SECONDS, 10 SECONDS)), src)
	ai_move()

	if(ai_target)
		SPAWN(1 DECI SECOND)
			ai_move()
		action_delay += 10
	else
		action_delay += 40

	ai_lastaction = world.time
	ai_actiondelay = action_delay


/*
/mob/living/carbon/human/proc/ai_findtarget()
	var/tempmob
	for (var/mob/living/carbon/M in view(7,src))
		if (M.stat > 0 || !M.client || M == src || M.is_npc) continue
		if (!tempmob) tempmob = M
		for(var/mob/living/carbon/human/L in oview(7,src))
			if (L.ai_target == tempmob && prob(50)) continue
		if (M.health < tempmob:health) tempmob = M
	if(tempmob)
		ai_target = tempmob
		ai_state = AI_ANGERING
		ai_threatened = world.timeofday
*/

/mob/living/carbon/human/proc/ai_is_valid_target(mob/M)
	return TRUE

/mob/living/carbon/human/proc/ai_findtarget_new()
	//Priority-based target finding
	var/mob/T
	var/lastRating = -INFINITY
	for (var/mob/living/carbon/M in view(7,src))
		//Any reason we do not want to take this target into account AT ALL?
		if((M == src && !ai_suicidal) || isdead(M) || (M.is_npc && !ai_attacknpc)) continue //Let's not fight ourselves (unless we're real crazy) or a dead person... or NPCs, unless we're allowed to.

		if(!src.ai_is_valid_target(M))
			continue

		var/rating = 100 //Base rating

		//Why do we WANT to go after this jerk?
		if(M.client) rating += 20 //We'd rather go after actual non-braindead players
		if(src.lastattacker == M && M != src) rating += 10 //Hey, you're a jerk! (but I'm not a jerk)


		//Why do we NOT want to go after this jerk
		if(isunconscious(M)) rating-=8 //This one's unconscious
		for(var/mob/living/carbon/human/H in oview(7,src))
			if(H.ai_target == M) rating -= 4 //I'd rather fight my own fight
		if(M.is_npc) rating -= 5 //I don't want to go after my fellow NPCs unless there is no other option
		if(M == src) rating -= 14 //I don't want to go after myself
		if(M in ai_target_old) rating -= 15 //I definitely don't want to go after my old target; chances are I still can't get to them.


		//Any reasons that could go either way when dealing with this bum?
		rating += 5*(M.health/M.max_health) //I'd rather fight things with a lot of health because I AIN'T NO COWARD!

		rating = max(rating,0) //Clamp the rating

		//Do we like this target better than the last one?
		if(rating > lastRating || (rating == lastRating && prob(50)))
			T = M
			lastRating = rating
	//Did we find anyone to fight?
	if(T)
		ai_target = T
		ai_state = AI_ANGERING
		ai_threatened = world.timeofday
	else
		ai_state = AI_PASSIVE

/mob/living/carbon/human/proc/ai_action()

	src.ai_do_hand_stuff()

	switch(ai_state)
		if(AI_PASSIVE) //Life is good.

			src.set_a_intent(src.ai_default_intent)

			ai_pickupstuff()
			ai_obstacle(1)
			ai_openclosets()
			//ai_findtarget()
			if (ai_calm_down && ai_aggressive && prob(20))
				ai_aggressive = 0
			if (ai_aggressive)
				ai_findtarget_new()
		if(AI_ANGERING)	//WHATS THAT?

			if (GET_DIST(src,ai_target) > 6)
				ai_target = null
				ai_state = AI_PASSIVE
				ai_threatened = 0
				return

			if ( (world.timeofday - ai_threatened) > 20 ) //Oh, it is on now! >:C
				ai_state = AI_ATTACKING
				return

		if(AI_ATTACKING)	//Gonna kick your ass.

			src.set_a_intent(INTENT_HARM)

			if(src.health < src.max_health / 8 && !src.ai_suicidal && !src.ai_aggressive)
				src.ai_state = AI_FLEEING
				src.ai_frustration = 0
				return

			if(!ai_target || ai_target == src && !ai_suicidal || ai_target.z != src.z || !src.ai_is_valid_target(ai_target))
				ai_frustration = 0
				ai_target = null
				ai_state = AI_PASSIVE
				return

			var/valid = ai_validpath()
			var/distance = GET_DIST(src,ai_target)

			ai_obstacle(0)
			ai_openclosets()

			if(ai_target == src && prob(10)) //If we're fighting ourselves we wanna look for other targets periodically
				src.ai_findtarget_new()

			if (ai_frustration >= 25)
				var/datum/bioEffect/power/adrenaline/adrenaline_rush = src.bioHolder.GetEffect("adrenaline")
				adrenaline_rush?.ability.handleCast()

				if (ai_frustration >= 100)
					ai_target_old |= ai_target //Can't get to this dork
					ai_frustration = 0
					ai_target = null
					ai_state = AI_PASSIVE
					walk_towards(src,null)

			var/area/A = get_area(src)

			var/stop_fight = FALSE
			if(isnull(ai_target) || !src.see_invisible && ai_target.invisibility)
				stop_fight = TRUE
			else if(ismob(src.ai_target))
				stop_fight = isdead(src.ai_target) || isunconscious(src.ai_target) && prob(25)
			else if(iscritter(src.ai_target))
				var/obj/critter/critter = src.ai_target
				stop_fight = !critter.alive
			else if(istype(src.ai_target, /obj/fitness/speedbag))
				stop_fight = prob(30)
			else
				stop_fight = prob(10)

			if(stop_fight)
				ai_target = null
				ai_state = AI_PASSIVE
				return


			if(iscarbon(ai_target))
				var/mob/living/carbon/carbon_target = ai_target

				if(src.get_brain_damage() >= 60)
					src.visible_message("<b>[src]</b> [pick("stares off into space momentarily.","loses track of what they were doing.")]")
					return

				if((carbon_target.getStatusDuration("weakened") || carbon_target.getStatusDuration("stunned") || carbon_target.getStatusDuration("paralysis")) && distance <= 1 && !ai_incapacitated())
					if (istype(carbon_target.wear_mask, /obj/item/clothing/mask) && prob(10))
						var/mask = carbon_target.wear_mask
						src.visible_message("<span class='alert'><b>[src] is trying to take off [mask] from [carbon_target]'s head!</b></span>")
						carbon_target.u_equip(mask)
						if (mask)
							mask:set_loc(carbon_target:loc)
							mask:dropped(carbon_target)
							mask:layer = initial(mask:layer)
					else if (carbon_target:wear_suit && prob(5) && !src.r_hand)
						var/suit = carbon_target:wear_suit
						src.visible_message("<span class='alert'><b>[src] is trying to take off [suit] from [carbon_target]'s body!</b></span>")
						carbon_target.u_equip(suit)
						if (suit)
							suit:set_loc(carbon_target:loc)
							suit:dropped(carbon_target)
							suit:layer = initial(suit:layer)
				if(prob(75) && distance > 1 && (world.timeofday - ai_attacked) > 100 && ai_validpath() && ((istype(src.r_hand,/obj/item/gun) && src.r_hand:canshoot(src)) || src.bioHolder.HasOneOfTheseEffects("eyebeams", "cryokinesis", "jumpy")) && !A?.sanctuary)
					//I can attack someone! =D
					ai_target_old.Cut()
					var/datum/bioEffect/power/eyebeams/eyebeams = src.bioHolder.GetEffect("eyebeams")
					var/datum/bioEffect/power/cryokinesis = src.bioHolder.GetEffect("cryokinesis")
					var/datum/bioEffect/power/jumpy/jumpy = src.bioHolder.GetEffect("jumpy")
					if (eyebeams && (eyebeams.ability.last_cast < world.time))
						eyebeams?.ability.handleCast(target)
					else if (cryokinesis && (cryokinesis.ability.last_cast < world.time))
						cryokinesis?.ability.handleCast(target)
					else if (jumpy && (jumpy.ability.last_cast < world.time))
						jumpy?.ability.handleCast(target)
					else
						var/obj/item/gun/W = src.r_hand
						W.shoot(get_turf(carbon_target), get_turf(src), src, 0, 0)
						if(src.bioHolder.HasEffect("coprolalia") && prob(10))
							switch(pick(1,2))
								if(1)
									hearers(src) << "<B>[src.name]</B> makes machine-gun noises with [his_or_her(src)] mouth."
								if(2)
									src.say(pick("BANG!", "POW!", "Eat lead, [carbon_target.name]!", "Suck it down, [carbon_target.name]!"))

				if((prob(33) || ai_throw) && (distance > 1 || A?.sanctuary) && ai_validpath() && src.equipped() && !(istype(src.equipped(),/obj/item/gun) && src.equipped():canshoot(src) && !A?.sanctuary))
					//I can attack someone! =D
					ai_target_old.Cut()
					src.throw_item(ai_target, list("npc_throw"))

			if(distance <= 1 && (world.timeofday - ai_attacked) > 100 && !ai_incapacitated() && ai_meleecheck() && !A?.sanctuary)
				//I can attack someone! =D
				ai_target_old.Cut()
				if(src.bioHolder.HasEffect("coprolalia") && prob(10)) //Combat Trash Talk
					src.say(pick("Fuck you, [ai_target.name]!", "You're [prob(10) ? "fucking " : ""]dead, [ai_target.name]!", "I will kill you, [ai_target.name]!!"))

				if(prob(20))
					src.zone_sel.select_zone(pick(prob(150); "head", prob(200); "chest", "l_arm", "r_arm", "l_leg", "r_leg"))

				if(src.r_hand && src.l_hand)
					if(prob(src.hand ? 90 : 5))
						src.swap_hand()
				else if(!src.equipped())
					if(src.hand || prob(10))
						src.swap_hand()
				else if(src.hand && prob(50))
					src.swap_hand()

				if(istype(src.equipped(),/obj/item/gun))
					src.swap_hand()

				src.set_a_intent(INTENT_HARM)

				var/prefer_hand = FALSE
				if(istype(ai_target, /obj/fitness/speedbag))
					prefer_hand = TRUE
				if(prob(1))
					prefer_hand = TRUE

				if(isgrab(src.r_hand) || isgrab(src.l_hand))
					var/obj/item/grab/grab = locate(/obj/item/grab) in src
					grab.Attackhand(src)

				if(!src.equipped() || prefer_hand)
					// need to restore this at some point i guess, the "monkeys bite" code is commented out right now
					//if(src.get_brain_damage() >= 60 && prob(25))
					//	target.attack_paw(src) // idiots bite
					//else
					if(prob(20) && !ON_COOLDOWN(src, "ai grab", 15 SECONDS))
						src.set_a_intent(INTENT_GRAB)
					src.ai_attack_target(ai_target, null)
				else // With a weapon
					if(istype(src.equipped(), /obj/item/sword) && prob(80))
						var/obj/item/sword/csaber = src.equipped()
						if(!csaber.open)
							src.ai_attack_target(csaber, null)
					src.ai_attack_target(ai_target, src.equipped())
					src.set_a_intent(INTENT_HARM)




			ai_pickupstuff()

			if(prob(5) && (distance == 3) && (world.timeofday - ai_pounced) > 180 && ai_validpath())
				if(valid)
					ai_pounced = world.timeofday
					src.visible_message("<span class='alert'>[src] lunges at [ai_target]!</span>")
					ai_target:changeStatus("weakened", 2 SECONDS)
					SPAWN(0)
						step_towards(src,ai_target)
						step_towards(src,ai_target)

			if (grabbed_by.len)
				src.resist()

		if(AI_FLEEING)  //Yes, brave Sir Robin turned about. And gallantly he chickened out.
			var/cancel_fleeing = FALSE
			if(isnull(src.ai_target) || src.ai_target.disposed || !IN_RANGE(src, src.ai_target, 8))
				cancel_fleeing = TRUE
			else if(ismob(src.ai_target) && !isalive(src.ai_target))
				cancel_fleeing = TRUE
			else if(istype(src.ai_target, /obj/machinery/bot/secbot))
				var/obj/machinery/bot/secbot/securitron = src.ai_target
				if(securitron.target != src)
					cancel_fleeing = TRUE
			else if(istype(src.ai_target, /obj/machinery/bot/guardbot))
				var/obj/machinery/bot/guardbot/guardbuddy = src.ai_target
				if(guardbuddy.arrest_target != src)
					cancel_fleeing = TRUE
			if(cancel_fleeing)
				src.ai_state = AI_PASSIVE
				if(prob(95))
					src.ai_target = null

/mob/living/carbon/human/proc/ai_attack_target(atom/target, obj/item/weapon)
	var/list/attack_params = list("icon-x"=rand(32), "icon-y"=rand(32), "left"=1)
	if(weapon)
		return src.weapon_attack(target, weapon, 1, attack_params)
	else
		return src.hand_attack(target, attack_params, null, null)

/mob/living/carbon/human/proc/ai_put_away_thing(obj/item/thing)


/mob/living/carbon/human/proc/ai_do_hand_stuff()
	if(prob(10))
		src.in_throw_mode = !src.in_throw_mode

	// suplex and table!
	if(isgrab(src.r_hand) || isgrab(src.l_hand))
		var/obj/item/grab/grab = src.equipped()
		if(!istype(grab))
			src.swap_hand()
			grab = src.equipped()
		if(prob(10) || grab.state > 0)
			if(prob(80))
				var/list/obj/table/tables = list()
				for(var/obj/table/table in view(1))
					tables += table
				if(length(tables))
					src.ai_attack_target(pick(tables), grab)
			if(!grab.disposed && grab.loc == src)
				src.emote("flip", TRUE)

	// swap hands
	if(src.r_hand && src.l_hand)
		if(prob(src.hand ? 15 : 4))
			src.swap_hand()
	else if(!src.equipped() && (src.r_hand || src.l_hand))
		src.swap_hand()

	if(!src.equipped())
		return

	var/throw_equipped = prob(0.1)

	if(IS_NPC_HATED_ITEM(src.equipped()))
		throw_equipped |= prob(80)

	// pull things out of other things!
	if(istype(src.equipped(), /obj/item/storage))
		var/obj/item/storage/storage = src.equipped()
		if(!length(storage.contents) && src.hand) // keep toolboxes in the right hand
			throw_equipped |= prob(80)
		else if(length(storage.contents))
			var/obj/item/taken = pick(storage.contents)
			src.u_equip(storage)
			storage.set_loc(src.loc)
			storage.dropped(src)
			storage.layer = initial(storage.layer)
			taken.set_loc(storage.loc)
			src.put_in_hand_or_drop(taken)

	// wear clothes
	if(src.hand && IS_NPC_CLOTHING(src.equipped()) && prob(80) && (!(src.equipped()?.flags & ONBELT) || prob(0.1)))
		src.hud.relay_click("invtoggle", src, list())
		if(src.equipped())
			throw_equipped |= prob(80)

	if(istype(src.wear_mask, /obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/cigarette = src.wear_mask
		if(istype(src.equipped(), /obj/item/device/light/zippo) || istype(src.equipped(), /obj/item/weldingtool) || istype(src.equipped(), /obj/item/device/igniter))
			if(!cigarette.on)
				if(istype(src.equipped(), /obj/item/device/light/zippo))
					var/obj/item/device/light/zippo/zippo = src.equipped()
					if(!zippo.on)
						zippo.AttackSelf(src)
				if(istype(src.equipped(), /obj/item/weldingtool))
					var/obj/item/weldingtool/welder = src.equipped()
					if(!welder.welding)
						welder.AttackSelf(src)
				src.ai_attack_target(cigarette, src.equipped())
				throw_equipped = 1

	// eat, drink, splash!
	if(istype(src.equipped(), /obj/item/reagent_containers))
		var/poured = FALSE
		if(istype(src.equipped(), /obj/item/reagent_containers/glass) || prob(20))
			for(var/obj/item/reagent_containers/container in view(1, src))
				if(container != src.equipped() && container.is_open_container() && container.reagents?.total_volume < container.reagents?.maximum_volume)
					src.ai_attack_target(container, src.equipped())
					poured = TRUE
					break
		if(poured || istype(src.equipped(), /obj/item/reagent_containers/glass) && prob(80))
			// do nothing
		else if((istype(src.equipped(), /obj/item/reagent_containers/food/snacks) || src.equipped().reagents?.total_volume > 0) && ai_useitems)
			src.ai_attack_target(src, src.equipped())
		else
			var/obj/item/thing = src.equipped()
			src.u_equip(thing)
			thing.set_loc(src.loc)
			thing.dropped(src)
			thing.layer = initial(thing.layer)

	// draw
	if(istype(src.equipped(), /obj/item/pen/crayon) && prob(20))
		var/list/turf/eligible = list()
		for(var/turf/T in view(1, src))
			if(!T.density && !(locate(/obj/decal/cleanable/writing) in T))
				eligible += T
		if(length(eligible))
			src.ai_attack_target(pick(eligible), src.equipped())

	// use
	if(src.equipped() && prob(ai_state == AI_PASSIVE ? 2 : 7) && ai_useitems)
		src.equipped().AttackSelf(src)

	// throw
	if(throw_equipped)
		var/turf/T = get_turf(src)
		if(T)
			SPAWN(0.2 SECONDS) // todo: probably reorder ai_move stuff and remove this spawn, without this they keep hitting themselves
				src.throw_item(locate(T.x + rand(-5, 5), T.y + rand(-5, 5), T.z), list("npc_throw"))

	// give
	if(prob(src.hand ? 5 : 1) && src.equipped() && ai_state != AI_ATTACKING)
		for(var/mob/living/carbon/human/H in view(1))
			if(H != src && isalive(H))
				SPAWN(0)
					src.give_to(H)
				break

	// put on table
	if(prob(5) && src.equipped())
		for(var/obj/table/table in view(1))
			src.ai_attack_target(table, src.equipped())
			break

/mob/living/carbon/human/proc/ai_move()
	if(ai_incapacitated() || !ai_canmove() || ai_busy)
		walk_towards(src, null)
		walk_away(src, null)
		return
	if((src in actions.running) && length(actions.running[src]))
		return // don't interupt actions
	if( ai_state == AI_PASSIVE && ai_canmove() ) step_rand(src)
	if( ai_state == AI_ATTACKING && ai_canmove() )
		if(src.pulling)
			src.set_pulling(null)
		if(!ai_validpath() && BOUNDS_DIST(src, ai_target) == 0)
			set_dir(get_step_towards(src,ai_target))
			ai_obstacle() //Remove.
		else
			//step_towards(src, ai_target)
			var/dist = GET_DIST(src,ai_target)
			if(ai_target && dist > 2) //We're in fast approach mode
				walk_towards(src,ai_target, ai_movedelay)
			else if (dist > 1)
				walk_towards(src, null)
				step_towards(src, ai_target) //Take a step and hit the shite (but only if you won't push them out of the way by doing so)
	if( ai_state == AI_FLEEING && ai_canmove() )
		set_dir(get_step_away(src, ai_target))
		ai_obstacle(1)
		walk_away(src, ai_target, 10, ai_movedelay)

/mob/living/carbon/human/changeStatus(statusId, duration, optional)
	. = ..()
	if(!src.ai_active)
		return
	if(ai_incapacitated())
		walk(src, null)
		if(src.ai_state == AI_FLEEING)
			src.ai_state = AI_PASSIVE


/mob/living/carbon/human/proc/ai_pickupstuff()
	src.ai_pickupweapon()
	if(prob(ai_offhand_pickup_chance))
		src.ai_pickupoffhand()

/mob/living/carbon/human/proc/ai_pickupoffhand()
	// this doesn't actually do anything yet because the movement of pulled object happens in process_move which npcs don't use
	/*
	if(src.pulling)
		if(prob(15))
			src.set_pulling(null)
	else
		if(prob(100))
			var/list/atom/movable/pullables = list()
			for(var/atom/movable/AM in view(1, src))
				if(AM != src && !isitem(AM) && !AM.anchored)
					pullables += AM
			if(length(pullables))
				src.set_pulling(pick(pullables))
	*/

	if(src.l_hand?.cant_drop)
		return

	var/obj/item/pickup
	var/pickup_score = 0

	for (var/obj/item/G in view(1,src))
		if(G.anchored || G.throwing) continue
		var/score = 0
		if(G.loc == src && !G.equipped_in_slot) // probably organs
			continue
		if(istype(G, /obj/item/chem_grenade) || istype(G, /obj/item/old_grenade))
			score += 6
		if(IS_NPC_CLOTHING(G) && (G.loc != src || prob(2)) && !ON_COOLDOWN(src, "pickup clothing", 30 SECONDS))
			score += 10
		else if(IS_NPC_CLOTHING(G) && G.loc == src)
			continue
		if(IS_NPC_HATED_ITEM(G))
			score -= 10
		if(istype(G, /obj/item/remote))
			score += 3
		if(istype(G, /obj/item/reagent_containers) && G.reagents?.total_volume > 0)
			score += 5
		if(istype(G, /obj/item/reagent_containers/food/snacks))
			score += 5
		if(istype(G, /obj/item/pen/crayon))
			score += 4
		if(istype(G, /obj/item/storage) && length(G.contents))
			score += 9
		if(G.loc == src)
			score += 1
		if(istype(src.wear_mask, /obj/item/clothing/mask/cigarette))
			var/obj/item/clothing/mask/cigarette/cigarette = src.wear_mask
			if(!cigarette.on && (istype(G, /obj/item/device/light/zippo) || istype(G, /obj/item/weldingtool) || istype(G, /obj/item/device/igniter)))
				score += 8
		score += G.contraband
		score += rand(-2, 2)
		if(score > pickup_score)
			pickup_score = score
			pickup = G

	if(src.l_hand && pickup && pickup != src.l_hand)
		var/obj/item/LHITM = src.l_hand
		src.u_equip(LHITM)
		LHITM.set_loc(get_turf(src))
		LHITM.dropped(src)
		LHITM.layer = initial(LHITM.layer)

	if(pickup && !src.l_hand)
		src.swap_hand(1)
		if(pickup.equipped_in_slot)
			src.u_equip(pickup)
		if(src.put_in_hand_or_drop(pickup))
			src.set_clothing_icon_dirty()

/mob/living/carbon/human/proc/ai_pickupweapon()
	if(istype(src.r_hand,/obj/item/gun) && src.r_hand:canshoot(src))
		return

	if(istype(src.r_hand,/obj/item/gun/kinetic) && !src.r_hand:canshoot(src))
		var/obj/item/gun/kinetic/GN = src.r_hand
		for(var/obj/item/ammo/bullets/BB in src.contents)
			src.l_hand = BB
			GN:attackby(BB,src)
			src.u_equip(BB)
			src.l_hand = null
			if (BB)
				BB.set_loc(src.loc)
				BB.dropped(src)
				BB.layer = initial(BB.layer)
			return

	if(src.r_hand?.cant_drop)
		return

	if(istype(src.r_hand, /obj/item/gun) && !src.r_hand:canshoot(src))
		var/obj/item/gun/GN = src.r_hand
		src.drop_item()
		if(src.w_uniform && !src.belt)
			GN:set_loc(src)
			src.belt = GN
			GN:layer = HUD_LAYER
		else if(src.back && istype(src.back,/obj/item/storage/backpack))
			var/obj/item/storage/backpack/B = src.back
			if(B.contents.len < 7)
				B.Attackby(GN,src)

	var/obj/item/pickup

	for(var/obj/item/G in src.contents)
		if(G.throwing) continue
		if((istype(G,/obj/item/gun) && G:canshoot(src)) && src.r_hand != G)
			pickup = G
			src.u_equip(G)
			break

	if(!pickup)
		for (var/obj/item/G in view(1,src))
			if(G.throwing) continue
			if(!istype(G.loc, /turf) || G.anchored) continue
			if((istype(G,/obj/item/gun) && G:canshoot(src)))
				pickup = G
				break
			else if(!src.r_hand && !pickup && G.force > 3)
				pickup = G
			else if(!src.r_hand && pickup && G.force > 3)
				if(G.force > pickup.force) pickup = G
			else if(src.r_hand && !pickup && G.force > 3)
				if(src:r_hand:force < G.force) pickup = G
			else if(src.r_hand && pickup && G.force > 3)
				if(pickup.force < G.force) pickup = G
			else if(istype(G, /obj/item/sword))
				pickup = G
				break

	if(src.r_hand && pickup)
		var/RHITM = src.r_hand
		src.u_equip(RHITM)
		RHITM:set_loc(get_turf(src))
		RHITM:dropped(src)
		RHITM:layer = initial(RHITM:layer)

	if(pickup && !src.r_hand)
		src.swap_hand(0)
		if(src.put_in_hand_or_drop(pickup))
			src.set_clothing_icon_dirty()


/mob/living/carbon/human/proc/ai_avoid(var/turf/T)
	return
/*
	if(ai_incapacitated()) return
	var/turf/tempturf = T
	var/tempdir = null
	var/turf/testturf = null

	//Extremely simple. EXTREMELY.

	if(T.firelevel)
		for (var/dir1 in list(NORTH,NORTHEAST,EAST,SOUTHEAST,SOUTH,SOUTHWEST,WEST,NORTHWEST))
			testturf = get_step(T,dir1)
			if (testturf.firelevel < tempturf.firelevel)
				tempdir = dir1
				tempturf = testturf
	else if(T.poison > 100000.0)
		for (var/dir1 in list(NORTH,NORTHEAST,EAST,SOUTHEAST,SOUTH,SOUTHWEST,WEST,NORTHWEST))
			testturf = get_step(T,dir1)
			if (testturf.poison < tempturf.poison)
				tempdir = dir1
				tempturf = testturf
	else if(T.co2 > 7500.0)
		for (var/dir1 in list(NORTH,NORTHEAST,EAST,SOUTHEAST,SOUTH,SOUTHWEST,WEST,NORTHWEST))
			testturf = get_step(T,dir1)
			if (testturf.co2 < tempturf.co2)
				tempdir = dir1
				tempturf = testturf
	else if (T.oxygen < 560000)
		for (var/dir1 in list(NORTH,NORTHEAST,EAST,SOUTHEAST,SOUTH,SOUTHWEST,WEST,NORTHWEST))
			testturf = get_step(T,dir1)
			if (testturf.oxygen > tempturf.oxygen)
				tempdir = dir1
				tempturf = testturf

	step(src,tempdir)
*/

/mob/living/carbon/human/proc/ai_canmove()
	if(!istype(src.loc,/turf))
		ai_freeself()
		return 0
	if(src.restrained())
		for(var/mob/M in range(src, 1))
			if (((M.pulling == src && (!( M.restrained() ) && isalive(M))) || locate(/obj/item/grab, src.grabbed_by.len)))
				return 0
	var/speed = (5 * ai_movedelay)
	if (!ai_laststep) ai_laststep = (world.timeofday - 5)
	if ((world.timeofday - ai_laststep) >= speed) return 1
	else return 0

/mob/living/carbon/human/proc/ai_incapacitated()
	if(stat || hasStatus(list("stunned", "paralysis", "weakened")) || !sight_check(1)) return 1
	else return 0

/mob/living/carbon/human/proc/ai_validpath()

	var/list/L = new/list()

	var/mob/living/target = ai_target

	if(!istype(src.loc,/turf)) return 0

	if(!target) return 0 //WTF

	L = getline(src,target)

	for (var/turf/T in L)
		if(target in T)
			continue
		if (T.density)
			ai_frustration += 3
			return 0
		for (var/obj/D in T)
			if (D.density && !istype(D, /obj/storage/closet) && D.anchored)
				ai_frustration += 3
				return 0
			else if (istype(D, /obj/storage/closet))
				var/obj/storage/closet/closet = D
				if (closet.open == 0)
					return 0

	return 1

/mob/living/carbon/human/proc/ai_meleecheck() //Simple right now.
	var/targetturf = get_turf(ai_target)
	var/myturf = get_turf(src)

	if(!istype(src.loc,/turf)) return 0

	for (var/obj/machinery/door/window/W in myturf)
		if(!W.CheckExit(src,targetturf)) return 0

	for (var/obj/machinery/door/window/W in targetturf)
		if(!W.Cross(src)) return 0

	return 1



/mob/living/carbon/human/proc/ai_freeself()
	if(istype(src.loc, /obj/machinery/disposal))
		var/obj/machinery/disposal/C = src.loc
		src.set_loc(C.loc)
		src.changeStatus("weakened", 2 SECONDS)

	else if(istype(src.loc, /obj/storage/closet))
		var/obj/storage/closet/C = src.loc
		if (C.open)
			C.close()
			C.open(user=src)
		else
			C.open(user=src)

	else if(istype(src.loc, /obj/vehicle/))
		var/obj/vehicle/V = src.loc
		if (V.rider == src)
			if(!(src.getStatusDuration("paralysis") || src.getStatusDuration("stunned") || src.getStatusDuration("weakened") || src.stat))
				V.eject_rider(0, 1)

	else if(istype(src.loc, /obj/icecube/))
		src.ai_attack_target(src.loc, null)

/mob/living/carbon/human/proc/ai_obstacle(var/doorsonly)

	var/acted = 0

	if(ai_incapacitated()) return

	if(src.r_hand && !doorsonly) //So they dont smash windows while wandering around.

		if((locate(/obj/window) in get_step(src,dir))  && !acted)
			var/obj/window/W = (locate(/obj/window) in get_step(src,dir))
			W.Attackby(src.r_hand, src)
			acted = 1
		else if((locate(/obj/window) in get_turf(src.loc))  && !acted)
			var/obj/window/W = (locate(/obj/window) in get_turf(src.loc))
			W.Attackby(src.r_hand, src)
			acted = 1

		if((locate(/obj/grille) in get_step(src,dir))  && !acted)
			var/obj/grille/G = (locate(/obj/grille) in get_step(src,dir))
			if(!G.ruined)
				G.Attackby(src.r_hand, src)
				acted = 1

	if((locate(/obj/machinery/door) in get_step(src,dir)))
		var/obj/machinery/door/W = (locate(/obj/machinery/door) in get_step(src,dir))
		if(W.density) src.ai_attack_target(W, null)
	else if((locate(/obj/machinery/door) in get_turf(src.loc)))
		var/obj/machinery/door/W = (locate(/obj/machinery/door) in get_turf(src.loc))
		if(W.density) src.ai_attack_target(W, null)

/mob/living/carbon/human/proc/ai_openclosets()
	if (ai_incapacitated())
		return
	for (var/obj/storage/closet/C in view(1,src))
		if (!C.open)
			C.open(user=src)
	for (var/obj/storage/secure/closet/S in view(1,src))
		if (!S.open && !S.locked)
			S.open(user=src)


#undef IS_NPC_HATED_ITEM
#undef IS_NPC_CLOTHING
