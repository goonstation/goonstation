//Xmas presents/ETC
//CONTAINS:
// * Setup and helper procs
// * Bootleg Guardbuddy Toy
// * Xmas Guardbuddy
// * Xmas Guardbuddy Module - Snowball launcher!
// * Seal Pup + walrus
// * Christmas Tree
// * Snow tiles
// * Christmas decoration
// * Grinch graffiti
// * Santa Claus stuff
// * Santa's letters landmark
// * Krampus 1.0 stuff
// * Stockings - from halloween.dm - wtf

var/global/christmas_cheer = 60
var/global/xmas_respawn_lock = 0
var/global/santa_spawned = 0
var/global/krampus_spawned = 0

var/static/list/santa_snacks = list(/obj/item/reagent_containers/food/drinks/eggnog,/obj/item/reagent_containers/food/snacks/cookie,
/obj/item/reagent_containers/food/snacks/ice_cream/random,/obj/item/reagent_containers/food/snacks/pie/apple,/obj/item/reagent_containers/food/snacks/snack_cake,
/obj/item/reagent_containers/food/snacks/yoghurt/frozen,/obj/item/reagent_containers/food/snacks/granola_bar,/obj/item/reagent_containers/food/snacks/candy/chocolate)

/proc/modify_christmas_cheer(var/mod)
	if (!mod || !isnum(mod))
		return
#ifdef XMAS
	christmas_cheer += mod
	christmas_cheer = max(0,min(christmas_cheer,100))

	if (!xmas_respawn_lock)
		if (christmas_cheer >= 80 && !santa_spawned)
			SPAWN_DBG(0) // Might have been responsible for locking up the mob loop via human Life() -> death() -> modify_christmas_cheer() -> santa_krampus_spawn().
				santa_krampus_spawn(0)
#endif
#if defined(XMAS) && !defined(RP_MODE)
		if (christmas_cheer <= 10 && !krampus_spawned)
			SPAWN_DBG(0)
				santa_krampus_spawn(1)
#endif
	return

// Might as well tweak Santa/Krampus respawn to make it use the universal player selection proc I wrote (Convair880).
/proc/santa_krampus_spawn(var/which_one = 0, var/confirmation_delay = 1200)
	if (xmas_respawn_lock != 0)
		return
	if (!isnum(confirmation_delay) || confirmation_delay < 0)
		message_admins("Couldn't set up [which_one == 0 ? "Santa Claus" : "Krampus"] respawn (setup failed).")
		return

	xmas_respawn_lock = 1

	// Setup.
	var/list/text_messages = list()
	if (confirmation_delay > 0) // These are irrelevant when player selection is instantaneous (confirmation_delay == 0).
		text_messages.Add("Would you like to respawn as [which_one == 0 ? "Santa Claus" : "Krampus"]? Your name will be added to the list of eligible candidates and may be selected at random by the game.")
		text_messages.Add("You are eligible to be respawned as [which_one == 0 ? "Santa Claus" : "Krampus"]. You have [confirmation_delay / 10] seconds to respond to the offer.")

		message_admins("[which_one == 0 ? "Santa Claus" : "Krampus"] respawn is sending offer to eligible ghosts. They have [confirmation_delay / 10] seconds to respond.")

	// Select player.
	var/list/datum/mind/candidates = dead_player_list(1, confirmation_delay, text_messages)
	if (!islist(candidates) || candidates.len <= 0)
		message_admins("Couldn't set up [which_one == 0 ? "Santa Claus" : "Krampus"] respawn (no eligible candidates found).")
		xmas_respawn_lock = 0
		return

	var/datum/mind/M = pick(candidates)
	if (!(M && istype(M) && M.current))
		message_admins("Couldn't set up [which_one == 0 ? "Santa Claus" : "Krampus"] respawn (candidate selection failed).")
		xmas_respawn_lock = 0
		return

	// Respawn player.
	var/mob/L
	var/ASLoc = pick_landmark(LANDMARK_LATEJOIN)
	var/WSLoc = job_start_locations["wizard"] ? pick(job_start_locations["wizard"]) : null

	if (!ASLoc)
		message_admins("Couldn't set up [which_one == 0 ? "Santa Claus" : "Krampus"] respawn (no late-join landmark found).")
		xmas_respawn_lock = 0
		return

	if (which_one == 0)
		L = new /mob/living/carbon/human/santa
		if (!(L && ismob(L)))
			message_admins("Couldn't set up [which_one == 0 ? "Santa Claus" : "Krampus"] respawn (new mob couldn't be created).")
			xmas_respawn_lock = 0
			return

		if (!WSLoc)
			L.set_loc(ASLoc)
		else
			L.set_loc(WSLoc)

		M.dnr = 1
		M.transfer_to(L)
		boutput(L, "<span class='notice'><b>You have been respawned as Santa Claus!</b></span>")
		boutput(L, "Go to the station and reward the crew for their high faith in Spacemas. Use your Spacemas magic!")
		boutput(L, "<b>Do not reference anything that happened during your past life!</b>")
		santa_spawned = 1

		SPAWN_DBG(0)
			L.choose_name(3, "Santa Claus", "Santa Claus")

	else
		L = new /mob/living/carbon/cube/meat/krampus
		if (!(L && ismob(L)))
			message_admins("Couldn't set up [which_one == 0 ? "Santa Claus" : "Krampus"] respawn (new mob couldn't be created).")
			xmas_respawn_lock = 0
			return

		L.set_loc(ASLoc)
		M.dnr = 1
		M.transfer_to(L)
		boutput(L, "<span class='notice'><b>You have been respawned as Krampus 3.0! <font color=red>CUTTING EDGE!</font></b></span>")
		boutput(L, "The station has been very naughty. <b>FUCK. UP. EVERYTHING.</b> This may be a little harder than usual.")
		boutput(L, "Be on the lookout for grinches. Do not harm them!")
		boutput(L, "<b>Do not reference anything that happened during your past life!</b>")
		krampus_spawned = 1

	message_admins("[which_one == 0 ? "Santa Claus" : "Krampus"] respawn completed successfully for player [L.mind.key] at [log_loc(L)].")
	logTheThing("admin", L, null, "respawned as [which_one == 0 ? "Santa Claus" : "Krampus"] at [log_loc(L)].")
	xmas_respawn_lock = 0
	return

// Grandma, no! you picked the wrong one!
/obj/machinery/bot/guardbot/bootleg
	name = "Super Protector Friend III"
	desc = "The label on the back reads 'New technology! Blinking light action!'."
	icon = 'icons/misc/xmas.dmi'

	speak(var/message)
		var/fontmode = rand(1,4)
		switch(fontmode)
			if(1) return ..("<font face='Comic Sans MS' size=3>[uppertext(message)]!!</font>")
			if(2) return ..("<font face='Curlz MT'size=3>[uppertext(message)]!!</font>")
			if(3) return ..("<font face='System'size=3>[uppertext(message)]!!</font>")
			else
				var/honk = pick("WACKA", "QUACK","QUACKY","GAGGLE")
				playsound(src.loc, "sound/misc/amusingduck.ogg", 50, 0)
				return ..("<font face='Comic Sans MS' size=3>[honk]!!</font>")
	Move()
		if(..())
			pixel_x = rand(-6, 6)
			pixel_y = rand(-6, 6)
			if(prob(5) && limiter.canISpawn(/obj/effects/sparks))
				var/obj/sparks = unpool(/obj/effects/sparks)
				sparks.set_loc(src.loc)
				SPAWN_DBG(2 SECONDS) if (sparks) pool(sparks)
			return TRUE

/obj/machinery/bot/guardbot/xmas
	name = "Jinglebuddy"
	desc = "Festive!"
	icon = 'icons/obj/bots/xmasbuddy.dmi'
	setup_default_tool_path = /obj/item/device/guardbot_tool/xmas

	speak(var/message)
		message = ("<font face='Segoe Script'><i><b>[message]</b></i></font>")
		. = ..()

	explode()
		if(src.exploding) return
		src.exploding = 1
		var/death_message = pick("I'll be back again some day!", "And to all a good night!", "A buddy is never truly happy until it is loved by a child. ", "I guess Spacemas isn't coming this year.", "Ho ho hFATAL ERROR")
		speak(death_message)
		src.visible_message("<span class='combat'><b>[src] blows apart!</b></span>")
		var/turf/T = get_turf(src)
		if(src.mover)
			src.mover.master = null
			qdel(src.mover)

		src.invisibility = 100
		var/obj/overlay/Ov = new/obj/overlay(T)
		Ov.anchored = 1
		Ov.name = "Explosion"
		Ov.layer = NOLIGHT_EFFECTS_LAYER_BASE
		Ov.pixel_x = -92
		Ov.pixel_y = -96
		Ov.icon = 'icons/effects/214x246.dmi'
		Ov.icon_state = "explosion"

		src.tool.set_loc(get_turf(src))

		var/list/throwparts = list()
		throwparts += new /obj/item/parts/robot_parts/arm/left(T)
		throwparts += new /obj/item/device/flash(T)
		//throwparts += core
		throwparts += src.tool
		if(src.hat)
			throwparts += src.hat
			src.hat.set_loc(T)

		for(var/obj/O in throwparts) //This is why it is called "throwparts"
			var/edge = get_edge_target_turf(src, pick(alldirs))
			O.throw_at(edge, 100, 4)

		SPAWN_DBG(0) //Delete the overlay when finished with it.
			src.on = 0
			sleep(1.5 SECONDS)
			qdel(Ov)
			qdel(src)

		T.hotspot_expose(800,125)
		explosion(src, T, -1, -1, 2, 3)

		return

/obj/item/device/guardbot_tool/xmas
	name = "Snowballer XL tool module"
	desc = "An exotic module for PR-6S Guardbuddies designed to fire snowballs."
	icon_state = "tool_xmas"
	tool_id = "SNOW"
	is_stun = 1
	is_gun = 1
	var/datum/projectile/current_projectile = new/datum/projectile/snowball

	// Updated for new projectile code (Convair880).
	bot_attack(var/atom/target as mob|obj, obj/machinery/bot/guardbot/user, ranged=0, lethal=0)
		if(..()) return

		if(src.last_use && world.time < src.last_use + 80)
			return

		if (ranged)
			var/obj/projectile/P = shoot_projectile_ST_pixel(master, current_projectile, target)
			if (!P)
				return

			user.visible_message("<span class='alert'><b>[master] throws a snowball at [target]!</b></span>")

		else
			var/obj/projectile/P = initialize_projectile_ST(master, current_projectile, target)
			if (!P)
				return

			user.visible_message("<span class='alert'><b>[master] beans [target] point-blank with the snowball!</b></span>")
			P.was_pointblank = 1
			hit_with_existing_projectile(P, target)

		src.last_use = world.time
		return

/datum/projectile/snowball
	name = "snowball"
	icon = 'icons/misc/xmas.dmi'
	icon_state = "snowball"
	power = 10
	cost = 25
	dissipation_rate = 2
	dissipation_delay = 4
	ks_ratio = 0.0
	sname = "stun"
	shot_sound = 'sound/effects/pop.ogg'
	shot_number = 1
	damage_type = 0
	hit_ground_chance = 0
	window_pass = 0

	on_hit(atom/hit)
		if (!iscarbon(hit))
			return

		var/mob/living/carbon/O = hit
		if (!O.lying)
			O.lying = 1
			O.visible_message("<span class='combat'><b>[O] is knocked down by the snowball!</b></span>")
			modify_christmas_cheer(1)
			boutput(O, "Brrr!")

		if (!O.is_hulk())
			O.changeStatus("weakened", 10 SECONDS)

#ifdef USE_STAMINA_DISORIENT
			O.do_disorient(120, weakened = 100, disorient = 80)
#else
			O.changeStatus("weakened", 10 SECONDS)
#endif

		O.bodytemperature = max(0, O.bodytemperature - 5)

		O.set_clothing_icon_dirty()
		return

/obj/critter/sealpup
	name = "space seal pup"
	desc = "A seal pup, in space, aww."
	icon_state = "seal"
	density = 0
	health = 10
	aggressive = 0
	defensive = 0
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 0
	atksilicon = 0
	firevuln = 1
	brutevuln = 1
	butcherable = 2
	is_pet = 1

	New()
		..()
		src.name = pick_string_autokey("names/seals.txt")

	CritterDeath()
		if (!src.alive) return
		..()
		src.desc = "The lifeless corpse of [src.name], why would anyone do such a thing?"
		modify_christmas_cheer(-20)
		src.name = "dead space seal pup"
		for (var/obj/critter/sealpup/S in view(7,src))
			if(S.alive)
				S.visible_message("<b>[S.name]</b> [pick("groans","yelps")]!", 1)
				walk_away(S,src,20,1)
				SPAWN_DBG(1 SECOND) walk(S,0)
		///Killing seals pisses off walruses!! uh oh.
		for (var/obj/critter/walrus/W in view(7,src))
			if(W.alive)
				W.aggressive = 1
				SPAWN_DBG(0.7 SECONDS)
				W.aggressive = 0

	attack_hand(var/mob/user as mob)
		if (!src.alive)
			return
		if (user.a_intent == "harm")
			src.health -= rand(1,2) * src.brutevuln
			for(var/mob/O in viewers(src, null))
				O.show_message("<span class='combat'><b>[user]</b> punches [src]!</span>", 1)
			playsound(src.loc, "punch", 50, 1)
			if (src.alive && src.health <= 0) src.CritterDeath()
			if (src.defensive)
				src.target = user
				src.oldtarget_name = user.name
				src.visible_message("<span class='combat'><b>[src]</b> [src.angertext] [user.name]!</span>")
				src.task = "chasing"
			if(!src.defensive)
				src.visible_message("<b>[src]</b> [pick("groans","yelps")]!", 1)
				walk_away(src,user,10,1)
				SPAWN_DBG(0.7 SECONDS) walk(src,0)
		else
			src.visible_message("<b>[user]</b> [pick("hugs","pets","caresses","boops","squeezes")] [src]!", 1)
			if(prob(80))
				src.visible_message("<b>[src]</b> [pick("coos","purrs","mewls","chirps","arfs","arps","urps")].", 1)
			else
				src.visible_message("<b>[src]</b> hugs <b>[user]</b> back!", 1)
				if (user.reagents)
					user.reagents.add_reagent("hugs", 10)
				playsound(src.loc, "sound/voice/babynoise.ogg", 50, 10,10)

	attackby(obj/item/W as obj, mob/living/user as mob)
		..()
		if(!alive) return
		if (istype(W, /obj/item/reagent_containers/food/snacks))
			if(findtext(W.name,"seal")) // for you, spacemarine9
				src.visible_message("<b>[src]</b> [pick("groans","yelps")]!", 1)
				src.visible_message("<b>[src]</b> gets frightened by [W]!", 1)
				walk_away(src,user,10,1)
				SPAWN_DBG(1 SECOND) walk(src,0)
				return

			if(prob(5))
				src.visible_message("<b>[src]</b> gives [W] back to <b>[user]</b> as if they wanted to share!", 1)
				playsound(src.loc, "sound/voice/babynoise.ogg", 50, 10,10)
			user.visible_message("<b>[user]</b> feeds [W] to [src]!","You feed [W] to [src].")
			src.visible_message("<b>[src]</b> [pick("coos","purrs","mewls","chirps","arfs","arps","urps")].", 1)
			modify_christmas_cheer(1)
			src.health += 10
			qdel(W)
		else
			src.visible_message("<b>[src]</b> [pick("groans","yelps")]!", 1)
			walk_away(src,user,10,1)
			SPAWN_DBG(0.4 SECONDS) walk(src,0)
			..()

/obj/critter/walrus
	name = "space walrus"
	desc = "A walrus, in space."
	icon_state = "walrus"
	density = 1
	health = 30
	aggressive = 0
	defensive = 1
	wanderer = 1
	atkcarbon = 1
	atksilicon = 1
	atcritter = 1
	firevuln = 0.5
	brutevuln = 0.5
	butcherable = 1


	seek_target()
		src.anchored = 0
		for (var/mob/living/C in view(src.seekrange,src))
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (iscarbon(C) && !src.atkcarbon) continue
			if (issilicon(C) && !src.atksilicon) continue
			if (C.health < 0) continue
			if (C.name == src.attacker) src.attack = 1
			if (iscarbon(C) && src.atkcarbon) src.attack = 1
			if (issilicon(C) && src.atksilicon) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				src.visible_message("<span class='combat'><b>[src]</b> roars at [C:name]!</span>")
				playsound(src.loc, "sound/voice/MEraaargh.ogg", 50, 0)
				src.task = "chasing"
				break
			else
				continue


	CritterAttack(mob/M)
		src.attacking = 1
		M.visible_message("<span class='combat'><b>[src]</b> drives its tusks through [src.target]!</span>")
		random_brute_damage(M, rand(8,16),1)
		SPAWN_DBG(2 SECONDS) src.attacking = 0


	ChaseAttack(mob/M)
		src.visible_message("<span class='combat'><b>[src]</b> lunges upon [M]!</span>")
		if(iscarbon(M))
			if(prob(50)) M.changeStatus("stunned", 2 SECONDS)
		random_brute_damage(M, rand(4,8),1)


// Throughout December the icon will change!
/obj/xmastree
	name = "Spacemas tree"
	desc = "O Spacemas tree, O Spacemas tree, Much p- Huh, there's a note here with <a target='_blank' href='https://forum.ss13.co/showthread.php?tid=15478'>'https://forum.ss13.co/showthread.php?tid=15478'</a> written on it."
	icon = 'icons/effects/160x160.dmi'
	icon_state = "xmastree_2020"
	anchored = 1
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	pixel_x = -64
	plane = PLANE_DEFAULT + 2

	density = 1
	var/on_fire = 0
	var/image/fire_image = null

	New()
		..()
		src.fire_image = image('icons/effects/160x160.dmi', "")
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

	attack_hand(mob/user as mob)
		extinguish()
		..()

	proc/extinguish()
		if (!src.on_fire)
			return
		src.visible_message("<span class='combat'>[usr] attempts to extinguish the fire!</span>")
		if (prob(2))
			src.change_fire_state(0)
		else
			boutput(usr, "You couldn't get the fire out. Keep trying!")

	proc/change_fire_state(var/burning = 0)
		if (src.on_fire && burning == 0)
			src.on_fire = 0
			src.visible_message("<span class='notice'>[src] is extinguished. Phew!</span>")
		else if (!src.on_fire && burning == 1)
			src.visible_message("<span class='combat'><b>[src] catches on fire! Oh shit!</b></span>")
			src.on_fire = 1
			SPAWN_DBG(1 MINUTE)
				if (src.on_fire)
					src.visible_message("<span class='combat'>[src] burns down and collapses into a sad pile of ash. <b><i>Spacemas is ruined!!!</i></b></span>")
					for (var/turf/simulated/floor/T in range(1,src))
						make_cleanable( /obj/decal/cleanable/ash,T)
					modify_christmas_cheer(-33)
					qdel(src)
					return
		src.update_icon()

	proc/update_icon()
		if (src.on_fire)
			if (!src.fire_image)
				src.fire_image = image('icons/effects/160x160.dmi', "xmastree_2014_burning")
			src.fire_image.icon_state = "xmastree_2014_burning" // it didn't need to change from 2014 to 2015 so I just left it as this one
			src.UpdateOverlays(src.fire_image, "fire")
		else
			src.UpdateOverlays(null, "fire")

	ephemeral //Disappears except on xmas
#ifndef XMAS
		New()
			..()
			qdel(src)
#endif

/obj/item/reagent_containers/food/snacks/snowball
	name = "snowball"
	desc = "A snowball. Made of snow."
	icon = 'icons/misc/xmas.dmi'
	icon_state = "snowball"
	amount = 2
	w_class = 1.0
	throwforce = 1
	doants = 0
	food_color = "#FFFFFF"

	New()
		..()
		SPAWN_DBG(rand(100,500))
			if (src.loc && (istype(src.loc, /turf/simulated/floor/specialroom/freezer) || src.loc.loc.name == "Space" || src.loc.loc.name == "Ocean"))
				src.visible_message("\The [src] vanishes into thin air, as its subatomic particles decay!")
			else
				src.visible_message("\The [src] melts!")
				make_cleanable( /obj/decal/cleanable/water,get_turf(src))
			qdel(src)

	heal(var/mob/living/M)
		if (!M || !isliving(M))
			return
		M.bodytemperature -= rand(1, 10)
		M.show_text("That was chilly!", "blue")

	proc/hit(var/mob/living/M as mob, var/message = 1)
		if (!M || !isliving(M))
			return
		M.changeStatus("stunned", 1 SECOND)
		M.take_eye_damage(rand(0, 2))
		M.change_eye_blurry(25)
		M.make_dizzy(rand(0, 5))
		M.stuttering += rand(0, 1)
		M.bodytemperature -= rand(1, 10)
		if (message)
			M.visible_message("<span class='alert'><b>[M]</b> is hit by [src]!</span>",\
			"<span class='alert'>You get hit by [src]![pick("", " Brr!", " Ack!", " Cold!")]</span>")
		src.amount -= rand(1, 2)

	attack(mob/M as mob, mob/user as mob)
		if (user.bioHolder.HasEffect("clumsy") && prob(50))
			user.visible_message("<span class='alert'>[user] plasters the snowball over [his_or_her(user)] face.</span>",\
			"<span class='alert'>You plaster the snowball over your face.</span>")
			src.hit(user, 0)
			JOB_XP(user, "Clown", 4)
			return

		src.add_fingerprint(user)

		if (src.amount <= 0)
			src.visible_message("[src] collapses into a poof of snow!")
			qdel(src)
			return

		else if (user.a_intent == "harm")
			if (M == user)
				M.visible_message("<span class='alert'><b>[user] smushes [src] into [his_or_her(user)] own face!</b></span>",\
				"<span class='alert'><b>You smush [src] into your own face!</b></span>")
			else if ((user != M && iscarbon(M)))
				M.tri_message("<span class='alert'><b>[user] smushes [src] into [M]'s face!</b></span>",\
				user, "<span class='alert'><b>You smush [src] into [M]'s face!</b></span>",\
				M, "<span class='alert'><b>[user] smushes [src] in your face!</b></span>")
			src.hit(M, 0)

		else return ..()

	throw_impact(atom/A, datum/thrown_thing/thr)
		if (ismob(A))
			src.hit(A)
		if (src.amount <= 0)
			src.visible_message("[src] collapses into a poof of snow!")
			qdel(src)
			return

/obj/decal/garland
	name = "garland"
	icon = 'icons/misc/xmas.dmi'
	icon_state = "garland"
	layer = 5
	anchored = 1

	ephemeral //Disappears except on xmas
#ifndef XMAS
		New()
			qdel(src)
			..()
#endif

/obj/decal/tinsel
	name = "tinsel"
	icon = 'icons/misc/xmas.dmi'
	icon_state = "tinsel-silver"
	layer = 5
	anchored = 1

	ephemeral //Disappears except on xmas
#ifndef XMAS
		New()
			qdel(src)
			..()
#endif

/obj/decal/wreath
	name = "wreath"
	icon = 'icons/misc/xmas.dmi'
	icon_state = "wreath"
	layer = 5
	anchored = 1

	ephemeral //Disappears except on xmas
#ifndef XMAS
		New()
			qdel(src)
			..()
#endif

/obj/decal/mistletoe
	name = "mistletoe"
	icon = 'icons/misc/xmas.dmi'
	icon_state = "mistletoe"
	layer = 9
	anchored = 1

/obj/decal/xmas_lights
	name = "spacemas lights"
	icon = 'icons/misc/xmas.dmi'
	icon_state = "lights1"
	layer = 5
	anchored = 1
	var/datum/light/light

	New()
		..()
		light = new /datum/light/point
		light.set_color(0.20, 0.60, 0.90)
		light.set_brightness(0.3)
		light.attach(src)
		light.enable()

	attack_hand(mob/user as mob)
		change_light_pattern()
		..()

	proc/light_pattern(var/pattern as num)
		if (!pattern)
			src.icon_state = "lights0"
			light.disable()
			return
		if (isnum(pattern) && pattern > 0)
			src.icon_state = "lights[pattern]"
			light.enable()
			return

	proc/change_light_pattern()
		var/pattern = input(usr, "Type number from 0 to 4", "Enter Number", 1) as null|num
		if (isnull(pattern))
			return
		pattern = clamp(pattern, 0, 4)
		src.light_pattern(pattern)

	ephemeral //Disappears except on xmas
#ifndef XMAS
		New()
			qdel(src)
			..()
#endif



// Grinch Stuff

/obj/decal/cleanable/grinch_graffiti
	name = "un-jolly graffiti"
	desc = "Wow, rude."
	icon = 'icons/obj/decals/graffiti.dmi'
	random_icon_states = list("grinch1","grinch2","grinch3","grinch4","grinch5","grinch6")

	disposing()
		modify_christmas_cheer(1)
		..()

// Santa Stuff

/obj/item/card/id/captains_spare/santa
	name = "Spacemas Card"
	registered = "Santa Claus"
	assignment = "Spacemas Spirit"

/mob/living/carbon/human/santa
	New()
		..()
		real_name = "Santa Claus"
		desc = "Father Christmas! Santa Claus! Old Nick! ..wait, not that last one. I hope."
		gender = "male"

		src.equip_new_if_possible(/obj/item/clothing/under/shorts/red, slot_w_uniform)
		src.equip_new_if_possible(/obj/item/clothing/suit/space/santa, slot_wear_suit)
		src.equip_new_if_possible(/obj/item/clothing/shoes/black, slot_shoes)
		src.equip_new_if_possible(/obj/item/clothing/glasses/regular, slot_glasses)
		src.equip_new_if_possible(/obj/item/clothing/head/helmet/space/santahat, slot_head)
		src.equip_new_if_possible(/obj/item/storage/backpack, slot_back)
		src.equip_new_if_possible(/obj/item/device/radio/headset, slot_ears)
		src.equip_new_if_possible(/obj/item/card/id/captains_spare/santa, slot_wear_id)

		var/datum/abilityHolder/HS = src.add_ability_holder(/datum/abilityHolder/santa)
		HS.addAbility(/datum/targetable/santa/heal)
		HS.addAbility(/datum/targetable/santa/gifts)
		HS.addAbility(/datum/targetable/santa/food)
		HS.addAbility(/datum/targetable/santa/warmth)
		HS.addAbility(/datum/targetable/santa/teleport)
		HS.addAbility(/datum/targetable/santa/banish)

	initializeBioholder()
		bioHolder.mobAppearance.customization_first = "Balding"
		bioHolder.mobAppearance.customization_second = "Full Beard"
		bioHolder.mobAppearance.customization_third = "Eyebrows"
		bioHolder.mobAppearance.customization_first_color = "#FFFFFF"
		bioHolder.mobAppearance.customization_second_color = "#FFFFFF"
		bioHolder.mobAppearance.customization_third_color = "#FFFFFF"
		. = ..()


	death()
		modify_christmas_cheer(-60)
		..()

	disposing()
		modify_christmas_cheer(-30)
		..()
	verb
		santa_heal()
			set name = "Holiday Healing"
			set desc = "Heal everyone around you."
			set category = "Festive Fun"

			if (src.stat || src.transforming)
				boutput(src, "<span class='alert'>You can't do that while you're incapacitated.</span>")
				return

			src.verbs -= /mob/living/carbon/human/santa/verb/santa_heal
			playsound(src.loc, "sound/voice/heavenly.ogg", 100, 1, 0)
			src.visible_message("<span class='alert'><B>[src] calls on the power of Spacemas to heal everyone!</B></span>")
			for (var/mob/living/M in view(src,5))
				M.HealDamage("All", 30, 30)
			SPAWN_DBG(1 MINUTE)
				boutput(src, "<span class='notice'>You may now use your healing spell again.</span>")
				src.verbs += /mob/living/carbon/human/santa/verb/santa_heal

		santa_gifts()
			set name = "Spacemas Presents"
			set desc = "Summon a whole bunch of Spacemas presents!"
			set category = "Festive Fun"

			if (src.stat || src.transforming)
				boutput(src, "<span class='alert'>You can't do that while you're incapacitated.</span>")
				return

			src.verbs -= /mob/living/carbon/human/santa/verb/santa_gifts
			src.visible_message("<span class='alert'><B>[src] throws out a bunch of Spacemas presents from nowhere!</B></span>")
			playsound(usr.loc, "sound/machines/fortune_laugh.ogg", 25, 1, -1)
			src.transforming = 1
			var/to_throw = rand(3,12)

			var/list/nearby_turfs = list()

			for (var/turf/T in view(5,src))
				nearby_turfs += T

			while(to_throw > 0)
				var/obj/item/a_gift/festive/X = new /obj/item/a_gift/festive(src.loc)
				X.throw_at(pick(nearby_turfs), 16, 3)
				to_throw--
				sleep(0.2 SECONDS)
			src.transforming = 0

			SPAWN_DBG(2 MINUTES)
				boutput(src, "<span class='notice'>You may now summon gifts again.</span>")
				src.verbs += /mob/living/carbon/human/santa/verb/santa_gifts

		santa_food()
			set name = "Spacemas Goodies"
			set desc = "Summon a whole bunch of festive snacks!"
			set category = "Festive Fun"

			if (src.stat || src.transforming)
				boutput(src, "<span class='alert'>You can't do that while you're incapacitated.</span>")
				return

			src.verbs -= /mob/living/carbon/human/santa/verb/santa_food
			src.visible_message("<span class='alert'><B>[src] casts out a whole shitload of snacks from nowhere!</B></span>")
			playsound(usr.loc, "sound/machines/fortune_laugh.ogg", 25, 1, -1)
			src.transforming = 1
			var/to_throw = rand(6,18)

			var/list/nearby_turfs = list()

			for (var/turf/T in view(5,src))
				nearby_turfs += T

			var/snack
			while(to_throw > 0)
				snack = pick(santa_snacks)
				var/obj/item/X = new snack(src.loc)
				X.throw_at(pick(nearby_turfs), 16, 3)
				to_throw--
				sleep(0.1 SECONDS)
			src.transforming = 0

			SPAWN_DBG(80 SECONDS)
				boutput(src, "<span class='notice'>You may now summon snacks again.</span>")
				src.verbs += /mob/living/carbon/human/santa/verb/santa_food

		santa_warmth()
			set name = "Winter Hearth"
			set desc = "Gives everyone near you temporary cold resistance."
			set category = "Festive Fun"

			if (src.stat || src.transforming)
				boutput(src, "<span class='alert'>You can't do that while you're incapacitated.</span>")
				return

			src.verbs -= /mob/living/carbon/human/santa/verb/santa_warmth
			playsound(src.loc, "sound/effects/MagShieldUp.ogg", 100, 1, 0)
			src.visible_message("<span class='alert'><B>[src] summons the warmth of a nice toasty fireplace!</B></span>")
			for (var/mob/living/M in view(src,5))
				if (M.bioHolder)
					M.bioHolder.AddEffect("cold_resist", 0, 60)
			SPAWN_DBG(80 SECONDS)
				boutput(src, "<span class='notice'>You may now use your warmth spell again.</span>")
				src.verbs += /mob/living/carbon/human/santa/verb/santa_warmth

		santa_teleport()
			set name = "Spacemas Warp"
			set desc = "Warp to somewhere else via the power of Christmas."
			set category = "Festive Fun"

			if (src.stat || src.transforming)
				boutput(src, "<span class='alert'>You can't do that while you're incapacitated.</span>")
				return

			src.verbs -= /mob/living/carbon/human/santa/verb/santa_teleport
			var/A
			A = input("Area to jump to", "TELEPORTATION", A) in get_teleareas()
			var/area/thearea = get_telearea(A)

			src.visible_message("<span class='alert'><B>[src] poofs away in a puff of cold, snowy air!</B></span>")
			playsound(usr.loc, "sound/effects/bamf.ogg", 25, 1, -1)
			playsound(usr.loc, "sound/machines/fortune_laugh.ogg", 25, 1, -1)
			var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
			smoke.set_up(1, 0, usr.loc)
			smoke.attach(usr)
			smoke.start()
			var/list/L = list()
			for(var/turf/T in get_area_turfs(thearea.type))
				if(!T.density)
					var/clear = 1
					for(var/obj/O in T)
						if(O.density)
							clear = 0
							break
					if(clear)
						L+=T
			src.set_loc(pick(L))

			SPAWN_DBG(30 SECONDS)
				boutput(src, "<span class='notice'>You may now teleport again.</span>")
				src.verbs += /mob/living/carbon/human/santa/verb/santa_teleport

		santa_banish()
			set name = "Banish Krampus"
			set desc = "Get rid of Krampus. He may return if Christmas Cheer goes too low again though."
			set category = "Festive Fun"

			if (src.stat || src.transforming)
				boutput(src, "<span class='alert'>You can't do that while you're incapacitated.</span>")
				return

			var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
			for (var/mob/living/carbon/cube/meat/krampus/K in view(7,src))
				src.visible_message("<span class='alert'><B>[src] makes a stern gesture at [K]!</B></span>")
				boutput(K, "<span class='alert'>You have been banished by Santa Claus!</span>")
				playsound(usr.loc, "sound/effects/bamf.ogg", 25, 1, -1)
				smoke.set_up(1, 0, K.loc)
				smoke.attach(K)
				smoke.start()
				K.gib()
				krampus_spawned = 0


// Krampus Stuff

/datum/mutantrace/krampus
	name = "krampus"
	icon_state = "hunter"
	human_compatible = 0
	uses_human_clothes = 0
	voice_message = "bellows"
	jerk = 1

	sight_modifier()
		mob.sight |= SEE_MOBS
		mob.see_in_dark = SEE_DARK_FULL
		mob.see_invisible = 1

/mob/living/carbon/human/krampus
	New()
		..()
		src.mind = new
		real_name = "Krampus"
		desc = "Oh shit! Have you been naughty?!"

		if(!src.reagents)
			src.create_reagents(1000)

		src.set_mutantrace(/datum/mutantrace/krampus)
		src.changeStatus("stimulants", 4 MINUTES)
		src.gender = "male"
		bioHolder.AddEffect("loud_voice")
		bioHolder.AddEffect("cold_resist")

	initializeBioholder()
		bioHolder.mobAppearance.customization_first = "None"
		bioHolder.mobAppearance.customization_second = "None"
		bioHolder.mobAppearance.customization_third = "None"
		. = ..()


	Bump(atom/movable/AM, yes)
		if(src.stance == "krampage")
			if ((!( yes ) || src.now_pushing))
				return
			now_pushing = 1
			var/attack_strength = 2
			var/attack_text = "furiously pounds"
			var/attack_volume = 60
			if (src.health <= 80)
				attack_strength = 3
				attack_text = "pounds"
				attack_volume = 30
			else if (src.health < 50)
				attack_strength = 4
				attack_text = "weakly pounds"
				attack_volume = 5
			if(ismob(AM))
				var/mob/M = AM
				for (var/mob/C in viewers(src))
					shake_camera(C, 8, 16)
					C.show_message("<span class='alert'><B>[src] tramples right over [M]!</B></span>", 1)
				M.changeStatus("stunned", 80)
				M.changeStatus("weakened", 5 SECONDS)
				random_brute_damage(M, 10,1)
				M.take_brain_damage(rand(5,10))
				playsound(M.loc, "fleshbr1.ogg", attack_volume, 1, -1)
				playsound(M.loc, "loudcrunch2.ogg", attack_volume, 1, -1)
				if (istype(M.loc,/turf/))
					src.set_loc(M.loc)
			else if(isobj(AM))
				var/obj/O = AM
				if(O.density)
					playsound(O.loc, "sound/impact_sounds/Metal_Hit_Heavy_1.ogg", attack_volume, 1, 0, 0.4)
					for (var/mob/C in viewers(src))
						shake_camera(C, 8, 16)
						C.show_message("<span class='alert'><B>[src] [attack_text] on [O]!</B></span>", 1)
					if(istype(O, /obj/window) || istype(O, /obj/grille) || istype(O, /obj/machinery/door) || istype(O, /obj/structure/girder) || istype(O, /obj/foamedmetal))
						qdel(O)
					else
						O.ex_act(attack_strength)
			else if(isturf(AM))
				var/turf/T = AM
				if(T.density && istype(T,/turf/simulated/wall/))
					for (var/mob/C in viewers(src))
						shake_camera(C, 8, 16)
						C.show_message("<span class='alert'><B>[src] [attack_text] on [T]!</B></span>", 1)
					playsound(T.loc, "sound/impact_sounds/Metal_Hit_Heavy_1.ogg", attack_volume, 1, 0, 0.4)
					T.ex_act(attack_strength)

			now_pushing = 0
		else
			..()
			return

	verb
		krampus_rampage()
			set name = "Krampage"
			set desc = "Go on a rampage, crushing everything in your path."
			set category = "Festive Fury"

			if (src.stat || src.transforming)
				boutput(src, "<span class='alert'>You can't do that while you're incapacitated.</span>")
				return

			src.stance = "krampage"
			playsound(src.loc, "sound/voice/animal/bull.ogg", 80, 1, 0, 0.4)
			src.visible_message("<span class='alert'><B>[src] goes completely apeshit!</B></span>")
			src.verbs -= /mob/living/carbon/human/krampus/verb/krampus_rampage
			SPAWN_DBG(30 SECONDS)
				src.stance = "normal"
				boutput(src, "<span class='alert'>Your rage burns out for a while.</span>")
			SPAWN_DBG(1800)
				boutput(src, "<span class='notice'>You feel ready to rampage again.</span>")
				src.verbs += /mob/living/carbon/human/krampus/verb/krampus_rampage

		krampus_leap(var/mob/living/M as mob in oview(7))
			set name = "Krampus Leap"
			set desc = "Leap onto someone near you, crushing them underfoot."
			set category = "Festive Fury"

			if (src.stat || src.transforming)
				boutput(src, "<span class='alert'>You can't do that while you're incapacitated.</span>")
				return

			var/turf/target
			if (isturf(M.loc))
				target = M.loc
			else
				return
			src.verbs -= /mob/living/carbon/human/krampus/verb/krampus_leap
			src.transforming = 1
			playsound(src.loc, "sound/misc/rustle5.ogg", 100, 1, 0, 0.3)
			src.visible_message("<span class='alert'><B>[src] leaps high into the air, heading right for [M]!</B></span>")
			animate_fading_leap_up(src)
			sleep(2.5 SECONDS)
			src.set_loc(target)
			playsound(src.loc, "sound/voice/animal/bull.ogg", 50, 1, 0, 0.8)
			animate_fading_leap_down(src)
			SPAWN_DBG(0)
				playsound(M.loc, "Explosion1.ogg", 50, 1, -1)
				for (var/mob/C in viewers(src))
					shake_camera(C, 10, 64)
					C.show_message("<span class='alert'><B>[src] slams down onto the ground!</B></span>", 1)
				for (var/turf/T in range(src,3))
					animate_shake(T,5,rand(3,8),rand(3,8))
				for (var/mob/living/X in range(src,1))
					if (X == src)
						continue
					X.ex_act(3)
					playsound(X.loc, "fleshbr1.ogg", 50, 1, -1)
				src.transforming = 0

			SPAWN_DBG(1 MINUTE)
				boutput(src, "<span class='notice'>You may now leap again.</span>")
				src.verbs += /mob/living/carbon/human/krampus/verb/krampus_leap

		krampus_stomp()
			set name = "Krampus Stomp"
			set desc = "Stomp everyone around you with your mighty feet."
			set category = "Festive Fury"

			if (src.stat || src.transforming)
				boutput(src, "<span class='alert'>You can't do that while you're incapacitated.</span>")
				return

			src.verbs -= /mob/living/carbon/human/krampus/verb/krampus_stomp
			if(!src.stat && !src.transforming)
				for (var/mob/C in viewers(src))
					shake_camera(C, 10, 64)
					C.show_message("<span class='alert'><B>[src] stomps the ground with \his huge feet!</B></span>", 1)
				playsound(src.loc, "meteorimpact.ogg", 80, 1, 1, 0.6)
				for (var/mob/living/M in view(src,2))
					if (M == src)
						continue
					playsound(M.loc, "fleshbr1.ogg", 40, 1, -1)
					M.ex_act(3)
				for (var/turf/T in range(src,3))
					animate_shake(T,5,rand(3,8),rand(3,8))

				SPAWN_DBG(1 MINUTE)
					boutput(src, "<span class='notice'>You may now stomp again.</span>")
					src.verbs += /mob/living/carbon/human/krampus/verb/krampus_stomp

		krampus_teleport()
			set name = "Krampus Poof"
			set desc = "Warp to somewhere else via the power of Spacemas."
			set category = "Festive Fury"

			if (src.stat || src.transforming)
				boutput(src, "<span class='alert'>You can't do that while you're incapacitated.</span>")
				return

			src.verbs -= /mob/living/carbon/human/krampus/verb/krampus_teleport
			var/A
			A = input("Area to jump to", "TELEPORTATION", A) in get_teleareas()
			var/area/thearea = get_telearea(A)

			src.visible_message("<span class='alert'><B>[src] poofs away in a puff of cold, snowy air!</B></span>")
			playsound(usr.loc, "sound/effects/bamf.ogg", 25, 1, -1)
			var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
			smoke.set_up(1, 0, usr.loc)
			smoke.attach(usr)
			smoke.start()
			var/list/L = list()
			for(var/turf/T in get_area_turfs(thearea.type))
				if(!T.density)
					var/clear = 1
					for(var/obj/O in T)
						if(O.density)
							clear = 0
							break
					if(clear)
						L+=T
			src.set_loc(pick(L))

			usr.set_loc(pick(L))
			smoke.start()
			SPAWN_DBG(1800)
				boutput(src, "<span class='notice'>You may now teleport again.</span>")
				src.verbs += /mob/living/carbon/human/krampus/verb/krampus_teleport

		krampus_snatch(var/mob/living/M as mob in oview(1))
			set name = "Krampus Snatch"
			set desc = "Grab someone nearby you instantly."
			set category = "Festive Fury"

			if (src.stat || src.transforming)
				boutput(src, "<span class='alert'>You can't do that while you're incapacitated.</span>")
				return

			if(istype(M))
				for(var/obj/item/grab/G in src)
					if(G.affecting == M)
						return
				src.visible_message("<span class='alert'><B>[src] snatches up [M] in \his huge claws!</B></span>")
				var/obj/item/grab/G = new /obj/item/grab(src, src, M)
				usr.put_in_hand_or_drop(G)
				M.changeStatus("stunned", 1 SECOND)
				G.state = 1
				G.update_icon()
				src.set_dir(get_dir(src, M))
				playsound(src.loc, "sound/voice/animal/werewolf_attack3.ogg", 65, 1, 0, 0.5)
				playsound(src.loc, "sound/impact_sounds/Generic_Shove_1.ogg", 65, 1)

		krampus_crush()
			set name = "(G) Krampus Crush"
			set desc = "Gradually crush someone you have held in your claws."
			set category = "Festive Fury"

			if (src.stat || src.transforming)
				boutput(src, "<span class='alert'>You can't do that while you're incapacitated.</span>")
				return

			for(var/obj/item/grab/G in src)
				if(ishuman(G.affecting))
					src.verbs -= /mob/living/carbon/human/krampus/verb/krampus_crush
					var/mob/living/carbon/human/H = G.affecting
					src.visible_message("<span class='alert'><B>[src] begins squeezing [H] in \his hand!</B></span>")
					H.set_loc(src.loc)
					while (!isdead(H))
						if (src.stat || src.transforming || get_dist(src,H) > 1)
							boutput(src, "<span class='alert'>Your victim escaped! Curses!</span>")
							qdel(G)
							src.verbs += /mob/living/carbon/human/krampus/verb/krampus_crush
							return
						random_brute_damage(H, 10,1)
						H.changeStatus("stunned", 80)
						H.changeStatus("weakened", 5 SECONDS)
						if (H.health < 0)
							src.visible_message("<span class='alert'><B>[H] bursts like a ripe melon! Holy shit!</B></span>")
							H.gib()
							qdel(G)
							src.verbs += /mob/living/carbon/human/krampus/verb/krampus_crush
							return
						playsound(src.loc, "sound/impact_sounds/Flesh_Tear_1.ogg", 75, 0.7)
						H.UpdateDamageIcon()
						sleep(1.5 SECONDS)
				else
					playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 75, 1)
					src.visible_message("<span class='alert'><B>[src] crushes [G.affecting] like a bug!</B></span>")
					G.affecting.gib()
					qdel(G)
					src.verbs += /mob/living/carbon/human/krampus/verb/krampus_crush
				break

		krampus_devour()
			set name = "(G) Krampus Devour"
			set desc = "Eat someone you have held in your claws, healing yourself a little."
			set category = "Festive Fury"

			if (src.stat || src.transforming)
				boutput(src, "<span class='alert'>You can't do that while you're incapacitated.</span>")
				return

			for(var/obj/item/grab/G in src)
				if(ishuman(G.affecting))
					var/mob/living/carbon/human/H = G.affecting
					src.visible_message("<span class='alert'><B>[src] raises [H] up to \his mouth! Oh shit!</B></span>")
					H.set_loc(src.loc)
					sleep(6 SECONDS)
					if (src.stat || src.transforming || get_dist(src,H) > 1)
						boutput(src, "<span class='alert'>Your prey escaped! Curses!</span>")
					else
						src.visible_message("<span class='alert'><B>[src] devours [H] whole!</B></span>")
						playsound(src.loc, "sound/items/eatfood.ogg", 30, 1, -2)
						H.death(1)
						H.ghostize()
						qdel(H)
						qdel(G)
						src.HealDamage("All", 15, 15)
						sleep(1 SECOND)
						playsound(src.loc, pick("sound/voice/burp_alien.ogg"), 50, 1, 0 ,0.5)

/obj/stocking
	name = "stocking"
	desc = "The most festive kind of sock!"
	icon = 'icons/misc/xmas.dmi'
	icon_state = "stocking_red"
	anchored = 1
	var/list/giftees = list()
	var/list/gift_paths = null//list()
	var/list/questionable_gift_paths = null//list()
	var/danger_chance = 1
	var/booby_trapped = 0

	New()
		..()
		if (prob(50))
			icon_state = "stocking_green"

	attack_hand(mob/user as mob)
		if (..())
			return
		if (!islist(src.gift_paths) || !src.gift_paths.len)
			src.gift_paths = generic_gift_paths + xmas_gift_paths

		if (!islist(src.questionable_gift_paths) || !src.questionable_gift_paths.len)
			src.questionable_gift_paths = questionable_generic_gift_paths + questionable_xmas_gift_paths

		if (user.key in giftees)
			boutput(user, "<span class='combat'>You've already gotten something from here, don't be greedy!</span>")
			boutput(user, "<span class='combat'><font size=1>Note: If this message is in error, please call 1-555-BAD-GIFT.</font></span>")
			return

		giftees += user.key

		if (src.booby_trapped)
			boutput(user, "<span class='alert'>There is a pissed off snake in the stocking! It bites you! What the hell?!</span>")
			modify_christmas_cheer(-5)
			if (user.reagents)
				user.reagents.add_reagent("venom", 5)
		else
			modify_christmas_cheer(2)
			var/dangerous = 0
			var/giftpath
			if (prob(danger_chance))
				dangerous = 1
				giftpath = pick(questionable_gift_paths)
			else
				giftpath = pick(gift_paths)

			var/obj/item/gift = new giftpath
			user.put_in_hand_or_drop(gift)

			if (dangerous)
				user.visible_message("<span class='combat'><b>[user.name]</b> takes [gift] out of [src]!</span>", "<span class='combat'>You take [gift] out of [src]!<br>This looks dangerous...</span>")
			else
				user.visible_message("<span class='notice'><b>[user.name]</b> takes [gift] out of [src]!</span>", "<span class='notice'>You take [gift] out of [src]!</span>")
		return

	ephemeral //Disappears except on xmas
#ifndef XMAS
		New()
			..()
			qdel(src)
#endif

/obj/decal/tile_edge/stripe/xmas
	icon_state = "xmas"

/obj/storage/crate/xmas
	name = "\improper Spacemas crate"
	icon_state = "xmascrate"
	icon_opened = "xmascrateopen"
	icon_closed = "xmascrate"

/obj/landmark/santa_mail
	name = "santa_mail"
	add_to_landmarks = TRUE
	desc = "All of Santa's mail gets spawned here."
	icon_state = "x"
