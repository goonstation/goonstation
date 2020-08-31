/mob/living/critter/flock/drone
	name = "weird glowy thing"
	desc = "Is it broccoli? A glass chicken? A peacock? A green roomba? A shiny discobot? A crystal turkey? A bugbird? A radio pigeon??"
	icon_state = "drone"
	density = 1
	hand_count = 3
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	can_help = 1
	death_text = "%src% clatters into a heap of fragments."
	pet_text = list("taps", "pats", "drums on", "ruffles", "touches", "pokes", "prods")
	custom_brain_type = /obj/item/organ/brain/flockdrone
	custom_organHolder_type = /datum/organHolder/critter/flock // for organs that aren't brain
	custom_hud_type = /datum/hud/critter/flock/drone
	var/datum/equipmentHolder/flockAbsorption/absorber
	health_brute = 30
	health_burn = 30
	var/damaged = 0 // used for state management for description showing, as well as preventing drones from screaming about being hit

	// too lazy, might as well use existing stuff
	butcherable = 1

	var/absorb_rate = 2 // how much item health is removed per tick when absorbing
	var/absorb_per_health = 3 // how much resources we get per item health
	var/absorb_completion = 6 // how much resources we get after the item is totally eaten

	// dormancy means do nothing

	// voltron powers activate
	var/floorrunning = 0

	// antigrab powers
	var/antigrab_counter = 0
	var/antigrab_fires_at = 100


/mob/living/critter/flock/drone/New(var/atom/location, var/datum/flock/F=null)
	// ai setup
	src.ai = new /datum/aiHolder/flock/drone(src)

	..()

	SPAWN_DBG(3 SECONDS) // aaaaaaa
		src.zone_sel.change_hud_style('icons/mob/flock_ui.dmi')

	src.name = "[pick_string("flockmind.txt", "flockdrone_name_adj")] [pick_string("flockmind.txt", "flockdrone_name_noun")]"
	src.real_name = "[pick(consonants_lower)][pick(vowels_lower)].[pick(consonants_lower)][pick(vowels_lower)].[pick(consonants_lower)][pick(vowels_lower)]"

	if(src.dormant) // we'be been flagged as dormant in the map editor or something
		src.dormantize()
	else
		if(src.client)
			// create a flocktrace for ourselves
			controller = new/mob/living/intangible/flock/trace(src, src.flock)
			src.is_npc = 0
		else
			emote("beep")
			say(pick_string("flockmind.txt", "flockdrone_created"))

/mob/living/critter/flock/drone/describe_state()
	var/list/state = ..()
	state["update"] = "drone"
	state["name"] = src.real_name
	if(src.is_npc)
		if(istype(src.ai.current_task))
			state["task"] = src.ai.current_task.name
		else
			state["task"] = ""
	else
		state["task"] = "controlled"
	. = state


/mob/living/critter/flock/drone/Login()
	..()
	if(src.client)
		src.client.color = null
	if(isnull(controller)) // finally i can just use swap bodies again
		// make a new controller
		controller = new/mob/living/intangible/flock/trace(src, src.flock)
		src.is_npc = 0

/mob/living/critter/flock/drone/proc/take_control(mob/living/intangible/flock/pilot)
	if(!pilot)
		return // fuck it
	if(controller)
		boutput(pilot, "<span class='alert'>This drone is already being controlled.</span>")
		return
	src.controller = pilot
	walk(src, 0)
	src.is_npc = 0
	src.dormant = 0
	src.anchored = 0
	// move mind into flockdrone
	var/datum/mind/mind = pilot.mind
	if (mind)
		mind.transfer_to(src)
	else
		if (pilot.client)
			var/key = pilot.client.key
			pilot.client.mob = src
			src.mind = new /datum/mind()
			src.mind.key = key
			src.mind.current = src
			ticker.minds += src.mind
	// move controller into ourselves
	pilot.set_loc(src)
	controller = pilot
	if(src.client)
		src.client.color = null // stop being all fucked up and weird aaaagh
	boutput(src, "<span class='flocksay'><b>\[SYSTEM: Control of drone [src.real_name] established.\]</b></span>")

/mob/living/critter/flock/drone/proc/release_control()
	if(src.flock)
		src.flock.hideAnnotations(src)
	src.is_npc = 1
	emote("beep")
	say(pick_string("flockmind.txt", "flockdrone_player_kicked"))
	if(src.client && !controller)
		// don't know how this happened but you need a controller right now
		controller = new/mob/living/intangible/flock/trace(src, src.flock)
	if(controller)
		// move controller out
		controller.set_loc(get_turf(src))
		// move us over to the controller
		var/datum/mind/mind = src.mind
		if (mind)
			mind.transfer_to(controller)
		else
			if (src.client)
				var/key = src.client.key
				src.client.mob = controller
				controller.mind = new /datum/mind()
				controller.mind.key = key
				controller.mind.current = controller
				ticker.minds += controller.mind
		flock_speak(null, "Control of drone [src.real_name] surrended.", src.flock)
		// clear refs
		controller = null

// sometimes we want a vegetable drone, ok
/mob/living/critter/flock/drone/proc/dormantize()
	src.dormant = 1
	src.canmove = 0
	src.anchored = 1 // unfun nerds ruin everything yet again
	src.is_npc = 0 // technically false, but it turns off the AI
	src.icon_state = "drone-dormant"
	src.a_intent = INTENT_DISARM // stop swapping places

/mob/living/critter/flock/drone/proc/undormantize()
	src.dormant = 0
	src.canmove = 1
	src.anchored = 0
	src.damaged = -1
	src.check_health() // handles updating the icon to something more appropriate
	src.visible_message("<span class='notice'><b>[src]</b> begins to glow and hover.</span>")
	src.a_intent = INTENT_HELP // default
	if(src.client)
		controller = new/mob/living/intangible/flock/trace(src, src.flock)
		src.is_npc = 0
	else
		src.is_npc = 1


/mob/living/critter/flock/drone/special_desc(dist, mob/user)
	if(isflock(user))
		var/special_desc = "<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received."
		if(src.controller)
			special_desc += "<br><span class='bold'>ID:</span> <b>[src.controller.real_name]</b> controlling [src.real_name])"
		else
			special_desc += "<br><span class='bold'>ID:</span> [src.real_name]"
		special_desc += "<br><span class='bold'>Flock:</span> [src.flock ? src.flock.name : "none"]"
		special_desc += "<br><span class='bold'>Resources:</span> [src.resources]"
		special_desc += "<br><span class='bold'>System Integrity:</span> [round(src.get_health_percentage()*100)]%"
		special_desc += "<br><span class='bold'>Cognition:</span> [src.is_npc ? "TORPID" : "SAPIENT"]"
		special_desc += "<br><span class='bold'>###=-</span></span>"
		return special_desc
	else
		return null // give the standard description

/mob/living/critter/flock/drone/proc/changeFlock(var/flockName)
	if(src.flock)
		src.flock.removeDrone(src)
	if(flocks[flockName])
		src.flock = flocks[flockName]
		src.flock.registerUnit(src) // for the sake of the flockmind
	if(controller)
		controller.flock = flocks[flockName]
	boutput(src, "<span class='notice'>You are now part of the <span class='bold'>[src.flock.name]</span> flock.</span>")

/mob/living/critter/flock/drone/Login()
	..()
	if(src.dormant)
		src.undormantize()
	if(src.flock)
		src.flock.showAnnotations(src)

/mob/living/critter/flock/drone/Logout()
	..()
	if(src.flock)
		src.flock.hideAnnotations(src)

/mob/living/critter/flock/drone/is_spacefaring() return 1

/mob/living/critter/flock/drone/CanPass(atom/movable/mover)
	if(isflock(mover))
		return 1
	else
		return 0

/mob/living/critter/flock/drone/MouseDrop_T(mob/living/target, mob/user)
	if(!target || !user)
		return
	if(target == user)
		// only allow people to jump into flockdrones if they're doing it themselves
		if(istype(user, /mob/living/intangible/flock))
			// jump on in there!
			src.take_control(user)
		else
			..() // do ghost observes, i guess
	else
		..()

/mob/living/critter/flock/drone/hotkey(var/name)
	switch (name)
		if("equip")
			src.equip_click(absorber)
		else
			return ..()

// TODO: PURGE THIS GODAWFUL THING
// TEMPORARY TEMPORARY TEMPORARY
/mob/living/critter/flock/drone/Stat()
	..()
	stat(null, " ")
	if(src.flock)
		stat("Flock:", src.flock.name)
	else
		stat("Flock:", "none")
	stat("Resources:", src.resources)

/mob/living/critter/flock/drone/setup_equipment_slots()
	absorber = new /datum/equipmentHolder/flockAbsorption(src)
	equipment += absorber

/mob/living/critter/flock/drone/setup_hands()
	..()
	var/datum/handHolder/HH = hands[1]
	HH.limb = new /datum/limb/flock_grip
	HH.name = "grip tool"
	HH.icon = 'icons/mob/flock_ui.dmi'
	HH.icon_state = "griptool"
	HH.limb_name = HH.name
	HH.can_hold_items = 1
	HH.can_attack = 1
	HH.can_range_attack = 0

	HH = hands[2]
	HH.limb = new /datum/limb/flock_converter
	HH.name = "nanite spray"
	HH.icon = 'icons/mob/flock_ui.dmi'
	HH.icon_state = "converter"
	HH.limb_name = HH.name
	HH.can_hold_items = 0
	HH.can_attack = 1
	HH.can_range_attack = 0

	HH = hands[3]
	HH.limb = new /datum/limb/gun/flock_stunner
	HH.name = "incapacitor"
	HH.icon = 'icons/mob/flock_ui.dmi'
	HH.icon_state = "incapacitor"
	HH.limb_name = HH.name
	HH.can_hold_items = 0
	HH.can_attack = 0
	HH.can_range_attack = 1

/mob/living/critter/flock/drone/specific_emotes(var/act, var/param = null, var/voluntary = 0)
	switch (act)
		if ("whistle", "beep", "burp")
			if (src.emote_check(voluntary, 50))
				playsound(get_turf(src), "sound/misc/flockmind/flockdrone_beep[pick("1","2","3","4")].ogg", 60, 1)
				return "<b>[src]</b> beeps."
		if ("scream", "growl", "abeep", "grump")
			if (src.emote_check(voluntary, 50))
				playsound(get_turf(src), "sound/misc/flockmind/flockdrone_grump[pick("1","2","3")].ogg", 60, 1)
				return "<b>[src]</b> beeps grumpily!"
		if ("fart") // i cannot ignore my heritage any longer
			if (src.emote_check(voluntary, 50))
				var/fart_message = pick_string("flockmind.txt", "flockdrone_fart")
				playsound(get_turf(src), "sound/misc/flockmind/flockdrone_fart.ogg", 60, 1)
				return "<b>[src]</b> [fart_message]"
	return null

/mob/living/critter/flock/drone/specific_emote_type(var/act)
	switch (act)
		if ("whistle", "beep", "burp", "scream", "growl", "abeep", "grump", "fart")
			return 2
	return ..()

/mob/living/critter/flock/drone/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1
	var/obj/item/I = absorber.item

	if(I)
		var/absorb = min(src.absorb_rate, max(0, I.health))
		I.health -= absorb
		src.resources += src.absorb_per_health * absorb
		playsound(get_turf(src), "sound/effects/sparks[rand(1,6)].ogg", 50, 1)
		if(I && I.health <= 0) // fix runtime Cannot read null.health
			playsound(get_turf(src), "sound/impact_sounds/Energy_Hit_1.ogg", 50, 1)
			I.dropped(src)
			if(I.contents.len > 0)
				var/anything_tumbled = 0
				for(var/obj/O in I.contents)
					if(istype(O, /obj/item))
						O.set_loc(src.loc)
						anything_tumbled = 1
					else
						qdel(O)
				if(anything_tumbled)
					src.visible_message("<span class='alert'>The contents of [I] tumble out of [src].</span>",
						"<span class='alert'>The contents of [I] tumble out of you.</span>",
						"<span class='alert'>You hear things fall onto the floor.</span")
			src.resources += src.absorb_completion
			boutput(src, "<span class='notice'>You finish converting [I] into resources (you now have [src.resources] resource[src.resources == 1 ? "" : "s"]).</span>")
			if(istype(I, /obj/item/organ/heart/flock))
				var/obj/item/organ/heart/flock/F = I
				src.resources += F.resources
				boutput(src, "<span class='notice'>You assimilate [F]'s resource cache, adding <span class='bold'>[F.resources]</span> resources to your own (you now have [src.resources] resource[src.resources == 1 ? "" : "s"]).</span>")
			else if(istype(I, /obj/item/flockcache))
				var/obj/item/flockcache/C = I
				src.resources += C.resources
				boutput(src, "<span class='notice'>You break down the resource cache, adding <span class='bold'>[C.resources]</span> resources to your own (you now have [src.resources] resource[src.resources == 1 ? "" : "s"]). </span>")
			if(istype(I, /obj/item/raw_material))
				pool(I) //gotta pool stuff bruh
			else
				qdel(I)
	// AI ticks are handled in mob_ai.dm, as they ought to be

/mob/living/critter/flock/drone/process_move(keys)
	if(src.grabbed_by.len)
		// someone is grabbing us, and we want to move
		++src.antigrab_counter
		if(src.antigrab_counter >= src.antigrab_fires_at)
			playsound(get_turf(src), "sound/effects/electric_shock.ogg", 40, 1, -3)
			boutput(src, "<span class='flocksay'><b>\[SYSTEM: Anti-grapple countermeasures deployed.\]</b></span>")
			for(var/obj/item/grab/G in src.grabbed_by)
				var/mob/living/L = G.assailant
				L.shock(src, 5000)
			src.antigrab_counter = 0
	else
		src.antigrab_counter = 0
	if(keys & KEY_RUN)
		if(!src.floorrunning && isfeathertile(src.loc))
			if(istype(src.loc, /turf/simulated/floor/feather))
				var/turf/simulated/floor/feather/floor = src.loc
				if(!floor.on)
					floor.on()
			src.start_floorrunning()
	else if(src.floorrunning)
		src.end_floorrunning()
	return ..()

/mob/living/critter/flock/drone/proc/start_floorrunning()
	if(src.floorrunning)
		return
	playsound(get_turf(src), "sound/misc/flockmind/flockdrone_floorrun.ogg", 50, 1, -3)
	src.floorrunning = 1
	src.set_density(0)
	animate_flock_floorrun_start(src)

/mob/living/critter/flock/drone/proc/end_floorrunning()
	if(!src.floorrunning)
		return
	playsound(get_turf(src), "sound/misc/flockmind/flockdrone_floorrun.ogg", 50, 1, -3)
	src.floorrunning = 0
	src.set_density(1)
	animate_flock_floorrun_end(src)

/mob/living/critter/flock/drone/movement_delay()
	if(floorrunning)
		return 0.6
	else
		return ..()

/mob/living/critter/flock/drone/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(floorrunning)
		return 1
	else
		return ..()

/mob/living/critter/flock/drone/Move(NewLoc, direct)
	if(!canmove) return

	if(floorrunning)
		// do our custom MOVE THROUGH ANYTHING stuff
		// copypasted from intangible.dm
		src.dir = get_dir(src, NewLoc)
		if(!isturf(src.loc))
			src.set_loc(get_turf(src))
		if(NewLoc)
			src.set_loc(NewLoc)
			return
		if((direct & NORTH) && src.y < world.maxy)
			src.y++
		if((direct & SOUTH) && src.y > 1)
			src.y--
		if((direct & EAST) && src.x < world.maxx)
			src.x++
		if((direct & WEST) && src.x > 1)
			src.x--
	else
		// do normal movement
		return ..(NewLoc, direct)

// catchall for shitlisting a dude that attacks us
/mob/living/critter/flock/drone/proc/harmedBy(var/mob/enemy)
	if(isflock(enemy))
		return
	if(!isdead(src) && src.is_npc && src.flock)
		// if this is a new guy to add to our enemies, call it out
		var/enemy_name = lowertext(enemy.name)
		if(enemy_name != "unknown")
			if(!src.flock.isEnemy(enemy)) // a new challenger emerges
				emote("scream")
				say("[pick_string("flockmind.txt", "flockdrone_enemy")] [enemy_name]")
			src.flock.updateEnemy(enemy)
			src.ai.interrupt()

// and then the numerous procs that use that catchall proc
/mob/living/critter/flock/drone/bullet_act(var/obj/projectile/P)
	if(floorrunning)
		return // haha fuck you i'm in the FLOOR
	if(istype(P.proj_data, /datum/projectile/energy_bolt/flockdrone))
		src.visible_message("<span class='notice'>[src] harmlessly absorbs the [P].</span>")
	else
		..()
		if(P.mob_shooter)
			src.harmedBy(P.mob_shooter)

/mob/living/critter/flock/drone/attackby(var/obj/item/I, var/mob/M)
	// check whatever reagents are about to get dumped on us
	var/has_harmful_chemicals = 0
	if(istype(I, /obj/item/reagent_containers/glass))
		var/list/reagent_list = I.reagents.reagent_list
		for(var/reagent_id in reagent_list)
			var/datum/reagent/current_reagent = reagent_list[reagent_id]
			// if the reagent mix dumped on us includes a combustible or harmful reagent, the mob has harmful intent
			// (there's other reagents that might be effective on these things without them realising it's dangerous outright)
			if(istype(current_reagent, /datum/reagent/combustible) || istype(current_reagent, /datum/reagent/harmful))
				has_harmful_chemicals = 1
				break
	// get reagents dumped on us or whatever
	..()
	if(I.force)
		src.harmedBy(M)
	if(has_harmful_chemicals)
		src.harmedBy(M)

/mob/living/critter/flock/drone/attack_hand(var/mob/living/M)
	..()
	if(M.a_intent in list(INTENT_HARM,INTENT_DISARM,INTENT_GRAB))
		src.harmedBy(M)

// also maybe we've just had environmental damage, who knows
/mob/living/critter/flock/drone/TakeDamage(zone, brute, burn)
	..()
	var/prev_damaged = src.damaged
	src.check_health()
	if(!isdead(src) && src.is_npc)
		// if we've been damaged a new stage, call it out
		if(prev_damaged != src.damaged && src.damaged > 0)
			src.emote("scream")
			say("[pick_string("flockmind.txt", "flockdrone_hurt")]")
			src.ai.interrupt()

/mob/living/critter/flock/drone/proc/check_health()
	if(isdead(src))
		return
	var/percent_damage = src.get_health_percentage() * 100
	switch(percent_damage)
		if(75 to 100)
			if(damaged == 0) return
			damaged = 0
			if(!dormant)
				src.icon_state = "drone"
		if(50 to 74)
			if(damaged == 1) return
			damaged = 1
			desc = "[initial(desc)]<br><span class='alert'>\The [src] looks lightly [pick("dented", "scratched", "beaten", "wobbly")].</span>"
			if(!dormant)
				src.icon_state = "drone-d1"
		if(25 to 49)
			if(damaged == 2) return
			damaged = 2
			desc = "[initial(desc)]<br><span class='alert'>\The [src] looks [pick("quite", "pretty", "rather")] [pick("dented", "busted", "messed up", "haggard")].</span>"
			if(!dormant)
				src.icon_state = "drone-d2"
		if(0 to 24)
			if(damaged == 3) return
			damaged = 3
			desc = "[initial(desc)]<br><span class='alert'>\The [src] looks [pick("really", "totally", "very", "all sorts of", "super")] [pick("mangled", "busted", "messed up", "broken", "haggard", "smashed up", "trashed")].</span>"
			if(!dormant)
				src.icon_state = "drone-d2"
	return

/mob/living/critter/flock/drone/death(var/gibbed)
	if(src.floorrunning)
		src.end_floorrunning()
	if(!src.dormant)
		if(src.is_npc)
			emote("scream")
			say(pick_string("flockmind.txt", "flockdrone_death"))
			src.is_npc = 0 // stop ticking the AI for this mob
		else
			emote("scream")
			say("\[System notification: drone lost.\]")
	src.ai.die()
	walk(src, 0)
	// transfer our resources to our heart
	var/obj/item/organ/heart/flock/core = src.organHolder.get_organ("heart")
	if(core)
		core.resources = src.resources
		src.resources = 0 // just in case any weirdness happens let's pre-empt the dupe bug
	if(src.controller)
		src.release_control()
	if(src.flock)
		src.flock.removeDrone(src)
	..()
	src.icon_state = "drone-dead"
	playsound(get_turf(src), "sound/impact_sounds/Glass_Shatter_3.ogg", 50, 1)
	src.set_density(0)
	desc = "[initial(desc)]<br><span class='alert'>\The [src] is a dead, broken heap.</span>"

/mob/living/critter/flock/drone/ghostize()
	if(src.controller)
		src.release_control()
	else
		..()

/mob/living/critter/flock/drone/butcher(var/mob/M)
	// break us down into pieces, this is our last retort
	var/num_pieces = rand(3, 6)
	var/my_turf = get_turf(src)
	var/atom/movable/B
	for(var/i=1 to num_pieces)
		switch(rand(100))
			if(0 to 45)
				B = unpool(/obj/item/raw_material/scrap_metal)
				B.set_loc(my_turf)
				B.setMaterial(getMaterial("gnesis"))
			if(46 to 90)
				B = unpool(/obj/item/raw_material/shard)
				B.set_loc(my_turf)
				B.setMaterial(getMaterial("gnesisglass"))
			if(91 to 100)
				B = new /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/flock(my_turf)

	playsound(get_turf(src), "sound/impact_sounds/Glass_Shatter_2.ogg", 50, 1)
	if (src.organHolder)
		src.organHolder.drop_organ("brain",src.loc)
		src.organHolder.drop_organ("heart",src.loc)
	src.ghostize()
	qdel(src)

/mob/living/critter/flock/drone/proc/split_into_bits()
	// turn into 3 flockbits
	var/num_bits = 3
	// handle the cleanup of this drone first
	walk(src, 0)
	if(src.floorrunning)
		src.end_floorrunning()
	if(src.ai)
		src.ai.die()
	emote("scream")
	say("\[System notification: drone diffracting.\]")
	if(src.controller)
		src.release_control()
	if(src.flock)
		src.flock.removeDrone(src)
	// create the flockbits
	animate_flock_drone_split(src)
	var/mob/living/critter/flock/bit/B
	// get candidate places to move them
	var/turf/T = get_turf(src)
	var/list/candidate_turfs = getNeighbors(T, alldirs)
	for(var/i=1 to num_bits)
		B = new(get_turf(src), F = src.flock)
		if(src.flock)
			src.flock.registerUnit(B)
		SPAWN_DBG(0.2 SECONDS)
			B.set_loc(pick(candidate_turfs))
	sleep(0.1 SECONDS) // make sure the animation finishes
	// finally, away with us
	src.ghostize()
	qdel(src)


/mob/living/critter/flock/drone/update_inhands()
	return // no dammit

/mob/living/critter/flock/drone/proc/create_egg()
	if(isnull(src.flock))
		boutput(src, "<span class='alert'>You do not have flockmind authorization to synthesize eggs.</span>")
		return
	if(src.resources < 100)
		boutput(src, "<span class='alert'>Not enough resources (you need 100).</span>")
		return
	var/turf/simulated/floor/feather/nest = get_turf(src)
	if(!istype(nest, /turf/simulated/floor/feather))
		boutput(src, "<span class='alert'>The egg needs to be placed on flock tile.</span>")
		return
	actions.start(new/datum/action/bar/flock_egg(), src)

/mob/living/critter/flock/drone/list_ejectables()
	. = list()
	if(src.organHolder)
		var/obj/item/organ/brain/B = src.organHolder.get_organ("brain")
		if(B)
			. += B // always drop brain
	// handle our contents, such as whatever item we're trying to eat or what we're holding
	for(var/atom/movable/O in src.contents)
		if(istype(O, /obj/screen))
			continue // no UI elements please
		. += O

// TODO: do this better
/mob/living/critter/flock/drone/change_eye_blurry(var/amount, var/cap = 0)
	if (amount < 0)
		return ..()
	else
		return 1

/mob/living/critter/flock/drone/take_eye_damage(var/amount, var/tempblind = 0)
	if (amount < 0)
		return ..()
	else
		return 1

/mob/living/critter/flock/drone/take_ear_damage(var/amount, var/tempdeaf = 0)
	if (amount < 0)
		return ..()
	else
		return 1

/////////////////////////////////////////////////////////////////////////////////
// FLOCKDRONE SPECIFIC LIMBS AND EQUIPMENT SLOTS
/////////////////////////////////////////////////////////////////////////////////

/datum/limb/flock_grip // an ordinary hand but with some modified messages
	var/attack_hit_prob = 50
	var/grab_mob_hit_prob = 30
	var/dam_low = 4 // 2 is human baseline
	var/dam_high = 7 // 9 is human baseline

	var/list/attack_messages = list(\
		list("prods", "with a pointy spike"),\
		list("jabs", "with a sharp instrument"),\
		list("pinches", "with a pair of spikes"),\
		list("smacks", "with an array of cylinders"),\
		list("pecks", "with an oversized beak-like structure"),\
		list("thwaps", "with a glowy mesh of fibres"),\
		list("whips", "with its elaborate sensory tail mesh"),\
		list("clobbers", "with a flurry of blunt instruments"),\
		)

/datum/limb/flock_grip/grab(mob/target, var/mob/living/critter/flock/drone/user)
	if (!user || !target)
		return 0
	if (isintangible(target))
		return 0 // stop grabbing AI eyes dammit
	if (user.floorrunning)
		return 0 // you'll need to be out of the floor to do anything
	if(prob(grab_mob_hit_prob))
		..()
	else
		boutput(user, "<span class='alert'>The grip tool can't get a good grip on [target]!</span>")
		user.lastattacked = target

/datum/limb/flock_grip/harm(mob/target, var/mob/living/critter/flock/drone/user)
	if (!user || !target)
		return 0
	if (user.floorrunning)
		return 0 // you'll need to be out of the floor to do anything
	var/mob/living/critter/flock/drone/F = target
	if(istype(F, /mob/living/critter/flock/drone))
		boutput(user, "<span class='alert'>The grip tool refuses to harm another flockdrone, jamming briefly.</span>")
	else
		if (!target.melee_attack_test(user))
			return
		if (prob(src.attack_hit_prob) || target.getStatusDuration("stunned") || target.getStatusDuration("weakened") || target.getStatusDuration("paralysis") || target.stat || target.restrained())
			var/obj/item/affecting = target.get_affecting(user)
			var/datum/attackResults/msgs = user.calculate_melee_attack(target, affecting, dam_low, dam_high, 0)
			user.attack_effects(target, affecting)
			var/list/specific_attack_messages = pick(attack_messages)
			msgs.base_attack_message = "<span class='combat bold'>[user] [specific_attack_messages[1]] [target] [specific_attack_messages[2]]!</span>"
			msgs.flush(0)
			user.lastattacked = target
		else
			user.visible_message("<span class='combat bold'>[user] attempts to prod [target] but misses!</span>")
			user.lastattacked = target

/////////////////////////////////////////////////////////////////////////////////

/datum/limb/flock_converter // requires 20 resources to initiate a conversion action, 10 for a repair (give target drone 33% of max health)

/datum/limb/flock_converter/attack_hand(atom/target, var/mob/living/critter/flock/drone/user, var/reach, params, location, control)
	if (!holder)
		return
	if(check_target_immunity( target ))
		return
	if (!istype(user))
		return
	if (user.floorrunning)
		return // you'll need to be out of the floor to do anything
	// CONVERT TURF
	if(!isturf(target) && !(istype(target, /obj/storage/closet/flock) || istype(target, /obj/table/flock) || istype(target, /obj/structure/girder) || istype(target, /obj/machinery/door/feather)))
		target = get_turf(target)

	if(istype(target, /turf) && !istype(target, /turf/simulated) && !istype(target, /turf/space))
		boutput(user, "<span class='alert'>Something about this structure prevents it from being assimilated.</span>")
	else if(isfeathertile(target))
		if(istype(target, /turf/simulated/floor/feather))
			var/turf/simulated/floor/feather/flocktarget = target
			if(user.a_intent == INTENT_DISARM)
				if(!locate(/obj/grille/flock) in flocktarget)
					if(user.resources < 25)
						boutput(user, "<span class='alert'>Not enough resources to construct a barricade (you need 25).</span>")
					else
						actions.start(new/datum/action/bar/flock_construct(target), user)
				else
					boutput(user, "<span class='alert'>There's already a barricade here.</span>")
			else
				boutput(user, "<span class='notice'>It's already been repurposed. Can't improve on perfection. (Use the disarm intent to construct a barricade.)</span>")
		else
			boutput(user, "<span class='notice'>It's already been repurposed. Can't improve on perfection.</span>")
	else if(user.resources < 20 && istype(target, /turf))
		boutput(user, "<span class='alert'>Not enough resources to convert (you need 20).</span>")
	else
		if(istype(target, /turf))
			actions.start(new/datum/action/bar/flock_convert(target), user)
	if(user.a_intent == INTENT_HARM)
		switch (target.type)
			if(/obj/table/flock, /obj/table/flock/auto)
				actions.start(new /datum/action/bar/flock_decon(target), user)
			if(/obj/storage/closet/flock)
				//soap
				actions.start(new /datum/action/bar/flock_decon(target), user)
			if(/turf/simulated/wall/auto/feather)
				actions.start(new /datum/action/bar/flock_decon(target), user)
			if(/obj/structure/girder)
				if(target?.material.mat_id == "gnesis")
					var/atom/A = new /obj/item/sheet(get_turf(target))
					if (target.material)
						A.setMaterial(target.material)
						qdel(target)
				else
					return
			if(/obj/machinery/door/feather)
				actions.start(new /datum/action/bar/flock_decon(target), user)
			else
				..()
//help intent actions
	else if(user.a_intent == INTENT_HELP)
		if(istype(target, /obj/machinery/door/feather))
			var/obj/machinery/door/feather/F = target
			if(F.broken || (F.health > F.health_max))
				if(user.resources < 10)
					boutput(user, "<span class='alert'>Not enough resources to repair (you need 10).</span>")
				else
					actions.start(new/datum/action/bar/flock_repair(F), user)


/datum/limb/flock_converter/help(mob/target, var/mob/living/critter/flock/drone/user)
	if(!target || !user)
		return
	if (user.floorrunning)
		return // you'll need to be out of the floor to do anything
	// REPAIR FLOCKDRONE
	var/mob/living/critter/flock/drone/F = target
	if(isflock(F))
		if(F.get_health_percentage() >= 1.0)
			boutput(user, "<span class='alert'>They don't need to be repaired, they're in perfect condition.</span>")
			return
		if(user.resources < 10)
			boutput(user, "<span class='alert'>Not enough resources to repair (you need 10).</span>")
		else
			actions.start(new/datum/action/bar/flock_repair(F), user)
	else
		..()

/datum/limb/flock_converter/disarm(mob/target, var/mob/living/critter/flock/drone/user)
	if(!target || !user)
		return
	if(isintangible(target))
		return // STOP CAGING AI EYES
	if (user.floorrunning)
		return // you'll need to be out of the floor to do anything
	if (!user.flock)
		boutput(user, "<span class='alert'>You do not have access to the imprisonment matrix without flockmind authorization.</span>")
		return
	// IMPRISON TARGET
	if(isflock(target))
		boutput(user, "<span class='alert'>The imprisonment matrix doesn't work on flockdrones.</span>")
		return
	else if(user.resources < 15)
		boutput(user, "<span class='alert'>Not enough resources to imprison (you need 15).</span>")
	else if(istype(target.loc, /obj/icecube/flockdrone))
		boutput(user, "<span class='alert'>They're already imprisoned, you can't double-imprison them!</span>")
	else
		actions.start(new/datum/action/bar/flock_entomb(target), user)

 //FUCK - moonlol
/datum/limb/flock_converter/harm(atom/target, var/mob/living/critter/flock/drone/user)
	if(!target || !user)
		return
	if(user.floorrunning)
		return
	if(istype(target, /mob/living/critter/flock/drone))
		var/mob/living/critter/flock/drone/f = target
		if(isdead(f))
			actions.start(new/datum/action/bar/icon/butcher_living_critter(f), user)
		else
			boutput(user, "<span class='alert'>You can't butcher a living flockdrone!</span>")
	else
		..()

/////////////////////////////////////////////////////////////////////////////////

/datum/limb/gun/flock_stunner // fires a stunning bolt on a cooldown which doesn't affect flockdrones
	proj = new/datum/projectile/energy_bolt/flockdrone
	shots = 4
	current_shots = 4
	cooldown = 15
	reload_time = 60
	reloading_str = "recharging"

/datum/limb/gun/flock_stunner/attack_range(atom/target, var/mob/living/critter/flock/drone/user, params)
	if(!target || !user || user.floorrunning)
		return
	return ..()

// I CAN DEFINE WHATEVER PROJECTILES I WANT HERE OK
// YOU'RE NOT MY REAL PARENTS
/datum/projectile/energy_bolt/flockdrone
	name = "incapacitor bolt"
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "stunbolt"
	cost = 20
	power = 40
	dissipation_rate = 1
	dissipation_delay = 3
	sname = "stunbolt"
	shot_sound = 'sound/weapons/laser_f.ogg'
	shot_number = 1
	window_pass = 1
	brightness = 1
	color_red = 0.5
	color_green = 0.9
	color_blue = 0.8
	disruption = 10

/////////////////////////////////////////////////////////////////////////////////

/datum/equipmentHolder/flockAbsorption
	show_on_holder = 0
	name = "disintegration reclaimer"
	type_filters = list(/obj/item)
	icon = 'icons/mob/flock_ui.dmi'
	icon_state = "absorber"

/datum/equipmentHolder/flockAbsorption/on_equip()
	if(!isobj(item))
		boutput(holder, "<span class='alert'>You can't possibly absorb that!</span>")
		drop()
	if(istype(item, /obj/item/grab))
		// STOP TRYING TO EAT GRABS
		drop()
	holder.visible_message("<span class='alert'>[holder] absorbs [item]!</span>", "<span class='notice'>You place [item] into [src.name] and begin breaking it down.</span>")
	animate_flockdrone_item_absorb(item)

/datum/equipmentHolder/flockAbsorption/on_unequip()
	var/obj/item/temp = item
	if(temp)
		animate(temp) // cancel animation
	..()

/datum/equipmentHolder/flockAbsorption/drop(var/force = 0)
	var/obj/item/temp = item
	if(temp)
		animate(temp) // cancel animation
	..()
