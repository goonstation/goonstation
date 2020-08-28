
/obj/critter/domestic_bee
	name = "greater domestic space-bee"
	desc = "Genetically engineered for extreme size and indistinct segmentation and bred for docility, the greater domestic space-bee is increasingly popular among space traders and science-types."
	icon = 'icons/misc/bee.dmi'
	icon_state = "petbee-wings"
	sleeping_icon_state = "petbee-sleep"
	density = 0
	health = 25
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 0
	atksilicon = 0
	firevuln = 0.5
	brutevuln = 0.8
	angertext = "buzzes threateningly at"
	butcherable = 2
	flying = 1
	min_quality = -60
	p_class = 2

	var/honey_production_amount = 50
	var/nectar_check = 10
	var/datum/plantgenes/pollen = null
	var/honey_color = 0

	var/max_offset = 6

	var/mob/living/beeMom = null
	var/beeMomCkey = null
	var/beeKid = 0 // this creates an overlay on them and colors that rather than coloring all of the bee

	var/icon_body = "petbee" // don't wanna rely on initial()
	var/icon_antenna = "antenna" // for layering over hats
	var/icon_sleep = "beezzzs" // so we don't have to make a set of sleeping animations for each bee
	var/icon_color = null // for bees that've been barfed up by someone, so only their body is colored

	var/obj/item/clothing/head/hat = null // hatcode mostly shamelessly stolen from guardbuddies
	var/hat_icon = 'icons/misc/bee.dmi'
	var/cant_take_hat = 0 // maybe they already have a hat, or maybe they just don't want a hat?  I dunno, bees are allowed to have their own fashion sense
	var/royal = 0 // maybe they'll have a little crown  c:
	var/list/hat_list = list("detective","hoscap","hardhat0","hardhat1","hosberet","ntberet","chef","souschef",
	"captain","centcom","centcom-red","tophat","ptophat","mjhat","plunger","cakehat0","cakehat1",
	"butt-nc","butt-plant","butt-cyber","purplebutt","santa","yellow","blue","red","green","black","white",
	"psyche","wizard","wizardred","wizardpurple","witch","obcrown","macrown","safari","viking","dolan",
	"camhat","redcamhat","mailcap","paper","policehelm","bikercap","apprentice","chavcap","flatcap","ntberet",
	"captain-fancy","rank-fancy","mime_beret","mime_bowler","buckethat")

	var/sleep_y_offset = 5 // this amount removed from the hat's pixel_y on sleep or death
	var/hat_y_offset = 0
	var/hat_x_offset_left = 0 // ^^ used for bees whose hats need to be in a different place vv
	var/hat_x_offset_right = 7
	var/image/hat_overlay_left
	var/image/hat_overlay_right

	var/is_dancing = 0 // we're already dancin'!
	var/dance_chance = 10 // fuck it I gotta test this stuff so this gets to be a var now (how likely the bee is to dance in response to a dance)

	var/tmp/blog = "adult bub log|"

	var/shorn = 0
	var/shorn_time = 0
	var/shorn_item = null

	var/lastattacker

/* -------------------- BEES -------------------- */

	queen
		name = "queen greater domestic space-bee"
		desc = "Despite the royal title, the greater domestic space-bee cannot actually lay eggs--those are produced in large biochemical engineering tanks.  The stinger of this species is, unlike its terrestrial brethren, not a modified ovipositor but instead formed of keratin.  You probably expected this description to just be \"holy shit what a big bee!\" or something, right?"
		health = 50
		firevuln = 0.5
		brutevuln = 0.6
		pixel_x = -16
		pixel_y = -16
		layer = 30 // should be over windows and shit like that
		honey_production_amount = 100
		max_offset = 0
		icon = 'icons/misc/bigcritter.dmi'
		icon_state = "queenbee-wings"
		sleeping_icon_state = "queenbee-sleep"
		icon_body = "queenbee"
		icon_antenna = "antenna-queenbee"
		icon_sleep = null // temp
		sleep_y_offset = 10
		hat_y_offset = 20
		hat_x_offset_right = 24
		hat_x_offset_left = 15

		New()
			..()
			if (prob(10))
				src.royal = 1
				src.cant_take_hat = 1
				src.update_icon()

		ChaseAttack(mob/M)
			if (!istype(M)) return
			if (prob(20))
				return CritterAttack(M)
			if (M.stat || M.getStatusDuration("paralysis"))
				src.task = "thinking"
				return
			src.visible_message("<span class='alert'><B>[src]</B> pokes [M] with its [prob(50) ? "IMMENSE" : "COLOSSAL"] stinger!</span>")
			logTheThing("combat", src.name, M, "stings [constructTarget(M,"combat")]")
			random_brute_damage(src.target, 10)//armor-piercing stingers

			if(M.reagents)
				M.reagents.add_reagent("neurotoxin", 20)
				M.reagents.add_reagent("morphine", 10)

			if (isliving(M))
				var/mob/living/L = M
				var/datum/ailment_data/disease/plague = L.find_ailment_by_type(/datum/ailment/disease/space_plague)
				if (istype(plague,/datum/ailment_data/disease/))
					//That bee venom plague treatment does not work at all in this manner. However, future.
					L.cure_disease(plague)
			if (isliving(M))
				var/mob/living/H = M
				H.was_harmed(src)

		CritterAttack(mob/M)
			if (!istype(M))
				return ..()

			SPAWN_DBG(0.8 SECONDS) // hit_twitch() or attack_twitch() or something in the parent ai_think() causes the bumbling to stop so we have to restart it.
				if (src.alive && !src.sleeping) // boy I can't wait until we don't have to do stupid shit like this anymore!!!!
					animate_bumble(src)
			if ((M.loc != src) && ((issilicon(M) && prob(20)) || prob(5)))
				src.visible_message("<span class='alert'><B>[src]</B> swallows [M] whole!</span>")
				M.set_loc(src)
				SPAWN_DBG(2 SECONDS)
					var/obj/icecube/honeycube = new /obj/icecube(src)
					M.set_loc(honeycube)
					honeycube.name = "block of honey"
					honeycube.desc = "It's a block of honey. I guess there's someone trapped inside? Is it Han Solo?"
					honeycube.steam_on_death = 0
					honeycube.health = 100

					var/icon/composite = icon(honeycube.icon, honeycube.icon_state)
					composite.ColorTone( rgb(242,242,111) )
					honeycube.icon = composite
					honeycube.underlays += M

					honeycube.set_loc(src.loc)
					src.visible_message("<b>[src]</b> regurgitates [M]!")
					playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)

				src.attacking = 0
				task = "thinking"
				return

			src.visible_message("<span class='alert'><B>[src]</B> bites [M] with its [pick("rather large","big","expansive","proportionally small but still sizable")] [prob(50) ? "mandibles" : "bee-teeth"]!</span>")
			logTheThing("combat", src.name, M, "bites [constructTarget(M,"combat")]")
			random_brute_damage(M, 10,1)
			if (isliving(M))
				var/mob/living/H = M
				H.was_harmed(src)
			if (M.stat || M.getStatusDuration("paralysis"))
				src.task = "thinking"
				src.attacking = 0
				return
			SPAWN_DBG(3.5 SECONDS)
				src.attacking = 0

		puke_honey()
			. = ..()
			if (.)
				var/obj/item/reagent_containers/food/snacks/ingredient/honey/honey = .
				honey.icon_state = "bighoneyblob"
				honey.amount++

	queen/buddy
		desc = "It appears to be a hybrid of a queen domestic space-bee and a PR-6 Robuddy. How is that even possible?"
		icon_state = "buddybee-wings"
		sleeping_icon_state = "buddybee-sleep"
		icon_body = "buddybee"
		icon_antenna = null
		hat_y_offset = 23
		hat_x_offset_right = 23
		hat_x_offset_left = 23

	queen/big
		desc = "Despite the royal title, the greater domestic space-bee cannot actually lay eggs--those are produced in large biochemical engineering tanks.  The stinger of this species is, unlike its terrestrial brethren, not a modified ovipositor but instead formed of keratin. This one's a little bigger than normal."
		health = 75
		firevuln = 0.4
		brutevuln = 0.5
		honey_production_amount = 150
		icon_state = "bigqueenbee-wings"
		sleeping_icon_state = "bigqueenbee-sleep"
		icon_body = "bigqueenbee"
		icon_antenna = "antenna-bigqueenbee"
		sleep_y_offset = 4
		hat_y_offset = 28
		hat_x_offset_right = 29
		hat_x_offset_left = 10

	queen/big/buddy
		desc = "It appears to be a hybrid of a queen domestic space-bee and a PR-6 Robuddy. This one's a little bigger than normal."
		health = 75
		firevuln = 0.4
		brutevuln = 0.5
		icon = 'icons/misc/biggercritter.dmi'
		icon_state = "bigqueenbuddy-wings"
		sleeping_icon_state = "bigqueenbuddy-sleep"
		icon_body = "bigqueenbuddy"
		icon_antenna = null
		sleep_y_offset = 26
		hat_y_offset = 31
		hat_x_offset_right = 50
		hat_x_offset_left = 50

	queen/omega
		name = "queen greatest domestic space-bee"
		desc = "That's a big bee, that is."
		pixel_x = -48
		pixel_y = -48
		health = 250
		firevuln = 0.2
		brutevuln = 0.3
		honey_production_amount = 200
		icon = 'icons/misc/biggercritter.dmi'
		icon_state = "omega-wings"
		sleeping_icon_state = "omega-sleep"
		icon_body = "omega"
		icon_antenna = "antenna-omega"
		sleep_y_offset = 8
		hat_y_offset = 52
		hat_x_offset_right = 51
		hat_x_offset_left = 19

	heisenbee
		name = "Heisenbee"
		health = 30
		generic = 0
		var/jittered = 0
		honey_color = rgb(0, 255, 255)
		is_pet = 2
		var/tier = 0
		var/original_tier = 0
		var/original_hat_ref = ""
		var/static/hat_tier_list = list(
			///obj/item/clothing/head/butt,
			/obj/item/clothing/head/paper_hat,
			/obj/item/clothing/head/plunger,
			/obj/item/clothing/head/helmet/bucket/hat,
			/obj/item/clothing/head/cakehat,
			/obj/item/clothing/head/chefhat,
			/obj/item/clothing/head/mailcap,
			/obj/item/clothing/head/helmet/hardhat,
			/obj/item/clothing/head/det_hat,
			/obj/item/clothing/head/mj_hat,
			/obj/item/clothing/head/that,
			/obj/item/clothing/head/NTberet,
			/obj/item/clothing/head/helmet/HoS,
			/obj/item/clothing/head/hosberet,
			/obj/item/clothing/head/caphat,
			/obj/item/clothing/head/fancy/captain,
			/obj/item/clothing/head/apprentice,
			/obj/item/clothing/head/wizard,
			/obj/item/clothing/head/wizard/red,
			/obj/item/clothing/head/helmet/viking,
			/obj/item/clothing/head/void_crown
		)

		New()
			src.tier = world.load_intra_round_value("heisenbee_tier")
			src.original_tier = src.tier
			src.RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_REBOOT, .proc/save_upgraded_tier)
			heisentier_hat()
			..()

		disposing()
			UnregisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_REBOOT)
			..()

		proc/save_upgraded_tier()
			if(src.alive)
				world.save_intra_round_value("heisenbee_tier", src.tier + 1)

		proc/heisentier_hat()
			if(src.tier <= 0)
				return
			var/hat_type = src.hat_tier_list[(src.tier - 1) % length(src.hat_tier_list) + 1]
			var/obj/item/clothing/head/hat = new hat_type(src)
			var/ubertier = round((src.tier - 1) / length(src.hat_tier_list))
			switch(ubertier)
				if(0)
					; // regular hat
				if(1)
					hat.setMaterial(getMaterial("gold"))
				if(2)
					hat.setMaterial(getMaterial("miracle"))
				if(3)
					hat.setMaterial(getMaterial("telecrystal"))
				if(4)
					hat.setMaterial(getMaterial("negativematter"))
				if(5 to INFINITY)
					hat.setMaterial(getMaterial("starstone"))
					var/matrix/trans = new
					trans.Scale((ubertier - 4) / 3) // mmm, large hat
					hat.transform = trans
			hat.name = "[src]'s [hat.name]"
			src.original_hat_ref = ref(hat)
			src.hat_that_bee(hat)
			src.update_icon()

		CritterDeath()
			if(!src.alive)
				return
			world.save_intra_round_value("heisenbee_tier", 0)
			if(src.hat)
				src.hat.set_loc(src.loc)
				src.hat = null
				src.update_icon()
			src.tier = 0 // No free hat with SR...
			. = ..()

		attackby(obj/item/W, mob/living/user)
			if(!src.hat && ref(W) == src.original_hat_ref) // ...unless you return the hat!
				if(src.alive)
					boutput(user, "<span class='emote'>[src] bubmles happily at the sight of [W]!</span>")
				src.tier = src.original_tier
			. = ..()

		get_desc(dist)
			. = ..()
			if(src.hat)
				. += "Huh, is that \a [src.hat] on [src]? How did it even get there?"

#ifdef HALLOWEEN
		var/masked = 1

		New()
			..()
			if (masked)
				if (prob(50))
					desc = "The Research Director's pet domestic space-bee, wearing a weird mask for Halloween.  You aren't sure who it's supposed to be.  It looks like it would be difficult for a bee to put on."
					src.overlays += image(src.icon, "halloweenmask")
				else
					src.overlays += image(src.icon, "halloweenmask2")
					desc = "Oh my god!! A robber!! Who sent them, was it the syndica-oh wait no nevermind, it's the Research Director's pet domestic space-bee.  Nice Halloween costume!"
					masked = 2
					src.name = "Heistenbee"

		attack_hand(mob/user as mob)
			if (src.alive)
				if (user.a_intent == INTENT_HELP)
					src.visible_message("<span class='notice'><b>[user]</b> [pick("pets","hugs","snuggles","cuddles")] [src]!</span>")
					user.add_karma(1)

					if (masked == 1)
						src.visible_message("<span class='alert'>[src]'s halloween mask falls off!<br>[src] stares at the fallen mask for a moment, then buzzes wearily.</span>")
						src.masked = 0
						src.overlays = list()
						new /obj/item/clothing/mask/waltwhite {name = "weird nerd mask"; desc = "A Halloween mask of some guy who seems sorta familiar.  Walt, you think.  Walt...Whitman.  That's it, Walt Whitman.  Weird choice for a costume.";} (src.loc)
						desc = "The Research Director's pet domestic space-bee.  Heisenbee has been invaluable in the study of the effects of space on bee behaviors."

					else

						if(prob(15))
							for(var/mob/O in hearers(src, null))
								O.show_message("[src] buzzes[prob(50) ? " happily!" : ""]!",2)
						if (prob(10))
							user.visible_message("<span class='notice'>[src] hugs [user] back!</span>", "<span class='notice'>[src] hugs you back!</span>")
							if (user.reagents)
								user.reagents.add_reagent("hugs", 10)
							user.add_karma(2)

					return
			else
				..()

			return
#else
		desc = "The Research Director's pet domestic space-bee.  Heisenbee has been invaluable in the study of the effects of space on bee behaviors."

#endif

		attackby(obj/item/W as obj, mob/living/user as mob)
			if (!src.alive)
				return ..()

			if (istype(W, /obj/item/device/gps))
				if (src.jittered)
					boutput(user, "<span class='alert'>[src] politely declines.</span>")
					return

				src.jittered = 1
				user.visible_message("<span class='alert'>[user] hands [src] the [W.name]</span>","You hand [src] the [W.name].")

				W.layer = initial(src.layer)
				user.u_equip(W)
				W.set_loc(src)

				SPAWN_DBG(rand(10,20))
					src.visible_message("<span class='alert'><b>[src] begins to move at unpredicable speeds!</b></span>")
					animate_bumble(src, floatspeed = 3)
					sleep(rand(30,50))
					src.visible_message("<span class='alert'>[W] goes flying!</span>")
					if (W)
						W.set_loc(src.loc)
						var/edge = get_edge_target_turf(src, pick(alldirs))
						W.throw_at(edge, 25, 4)

					animate_bumble(src)
					src.visible_message("<b>[src]</b> gives off a dizzy buzz.")

			else if (istype(W, /obj/item/photo/heisenbee))
				user.visible_message("[user] shows [src] the [W.name].","You show [src] the [W.name].")
				src.visible_message("[src] bumbles in a slightly embarrassed manner.[prob(30) ? "  You can discern this degree of emotion from bumbling, ok." : null]")

			else
				..()

	bubs
		name = "fat and sassy space-bee"
		desc = "A greater domestic space-bee that happens to be particularly pudgy and obstinate."
		angertext = "gets even fatter and sassier at"
		health = 500
		generic = 0
		icon_state = "bubsbee-wings"
		icon_body = "bubsbee"
		sleeping_icon_state = "bubsbee-sleep"
		icon_antenna = "antenna-bubsbee"
		density = 1 // well I mean... duh
		hat_y_offset = 2
		var/cleaned = 0

		New()
			..()
			SPAWN_DBG (20)
				if (time2text(world.realtime, "MM DD") == "10 31")
					name = "Beezlebubs"
					desc = "Oh no, a terrifying demon!!  Oh, wait, no, nevermind, it's just the fat and sassy space-bee.  Wow, really had me fooled for a moment...guess that's a Halloween trick...."
					src.hat = new /obj/item/clothing/head/devil (src)
					src.hat_that_bee(src.hat)
					src.update_icon()

				else
					perhaps_go_to_work()

		CritterAttack(mob/M)
			src.attacking = 1
			if (!istype(M))
				return ..(M)

			SPAWN_DBG(0.8 SECONDS) // hit_twitch() or attack_twitch() or something in the parent ai_think() causes the bumbling to stop so we have to restart it.
				if (src.alive && !src.sleeping) // boy I can't wait until we don't have to do stupid shit like this anymore!!!!
					animate_bumble(src)
			src.visible_message("<span class='alert'><B>[src]</B> shanks [M] with its [pick("tiny","eeny-weeny","minute","little")] switchblade!</span>")
			random_brute_damage(M, 20)//get shivved - no armor for this
			if (isliving(M))
				var/mob/living/H = M
				H.was_harmed(src)
			if (M.stat || M.getStatusDuration("paralysis"))
				src.task = "thinking"
				src.attacking = 0
				return
			SPAWN_DBG(3.5 SECONDS)
				src.attacking = 0

		attack_hand(mob/user as mob)
			if (src.alive && user.a_intent == INTENT_GRAB)
				src.visible_message("<span class='alert'><b>[user]</b> attempts to wrangle [src], but [src] is far, FAR too sassy!</span>")
				return

			else
				return ..()

		attackby(obj/item/W as obj, mob/user as mob)
			if (istype(W, /obj/item/reagent_containers/glass/bottle/bubblebath) && src.alive && !cleaned && src.task != "attacking")
				if (!W.reagents || !W.reagents.has_reagent("fluorosurfactant"))
					boutput(user, "<span class='alert'>How do you expect this to work without bubble bath in the bubble bath bottle?</span>")
					return

				cleaned = 1
				W.reagents.clear_reagents()
				playsound(src, "sound/effects/bubbles2.ogg", 80, 1, -3)
				user.visible_message("<span class='notice'><b>[user]</b> washes [src]!</span>", "<span class='notice'>You clean the HECK out of [src]!</span>")
				src.visible_message("<span class='notice'>[src] bumbles really happily!  Also, a little squeakily.</span>")
				//todo: splash visual effect
				src.dance()
				user.unlock_medal("Remember to Wash Behind the Antennae", 1)
			else
				return ..()

		proc/perhaps_go_to_work()
			. = time2text(world.realtime, "DDD")
			if (. == "Sun" || . == "Sat")
				return 0		//No working the weekends!

			. = text2num(time2text(world.timeofday, "hh"))
			//1 am to 9 am cst is a little offset from the Real Bubs Jobtime
			//of course, this is tied to the server's local time so G4 will be different
			if (. >= 1 && . < 9)
				var/turf/T = pick_landmark(LANDMARK_BUBS_BEE_JOB)
				if (istype(T))
					src.hat = new /obj/item/clothing/head/flatcap (src)
					src.hat_that_bee(src.hat)
					src.update_icon()
					src.set_loc(T)

			return 1

		dance()
			set waitfor = 0
			src.is_dancing = 1

			var/dir_choice = prob(50) ? -90 : 90//pick("L", "R")
			var/sleep_time = (rand(1,20) / 10)//rand_deci(0, 0, 2, 0) // so if you have a big pack of bees they don't all start bumbling in exact synch
			var/time_time = (rand(15,20) / 10)//rand_deci(1, 5, 2, 0) // same as above
			//DEBUG_MESSAGE("[src] initial sleep time [sleep_time], animation time [time_time]")

			sleep(sleep_time)
			animate_beespin(src, dir_choice, time_time, 1)

			sleep(time_time * 8)
			src.icon_state = "bubsbee-8I"
			src.task = "thinking"
			animate(src, pixel_y = -6, time = 20, easing = BOUNCE_EASING)

			sleep(2 SECONDS)
			src.pixel_y = 0
			src.icon_state = "bubsbee"
			src.sleeping = rand(10, 20)
			src.task = "sleeping"
			src.on_sleep()
			src.visible_message("<span class='notice'>[src] gets tired from all that work and takes a nap!</span>")
			src.is_dancing = 0

	overbee
		name = "THE OVERBEE"
		desc = "Not to be confused with that other stinging over-insect."
		health = 500
		firevuln = 0.2
		brutevuln = 0.2
		generic = 0
		icon_state = "overbee-wings"
		icon_body = "overbee"
		sleeping_icon_state = "overbee-sleep"
		icon_antenna = "antenna-overbee"

		puke_honey()
			var/turf/T = locate(src.x + rand(-2,2), src.y + rand(-2,2), src.z)
			if (!T)
				return null
			;
			new /obj/overlay/self_deleting {name = "hole in space time"; layer=2.2; icon = 'icons/misc/lavamoon.dmi'; icon_state="voidwarp";} (T, 20)
			elecflash(T,power=3)

			var/obj/item/reagent_containers/food/snacks/ingredient/honey/honey = new /obj/item/reagent_containers/food/snacks/ingredient/honey(T)
			. = honey
			if (honey.reagents)
				honey.reagents.maximum_volume = honey_production_amount
			src.reagents.trans_to(honey, honey_production_amount)
			src.visible_message("<b>[src]</b> wills a blob of honey into existence![prob(10) ? " Weird!" : null]")
			playsound(src.loc, "sound/effects/mag_forcewall.ogg", 50, 1)

		CritterAttack(mob/M)
			if (!istype(M))
				return ..()

			SPAWN_DBG(0.8 SECONDS) // hit_twitch() or attack_twitch() or something in the parent ai_think() causes the bumbling to stop so we have to restart it.
				if (src.alive && !src.sleeping) // boy I can't wait until we don't have to do stupid shit like this anymore!!!!
					animate_bumble(src)

			if (attacking)
				return

			if (M.stat || M.getStatusDuration("paralysis"))
				src.task = "thinking"
				src.attacking = 0
				return

			attacking = 1
			src.visible_message("<span class='alert'><b>[src]</b> stares at [M.name]!</span>")
			playsound(src.loc, 'sound/voice/animal/buzz.ogg', 100, 1)
			boutput(M, "<span class='alert'>You feel a horrible pain in your head!</span>")
			M.changeStatus("stunned", 2 SECONDS)
			if (isliving(M))
				var/mob/living/H = M
				H.was_harmed(src)
			SPAWN_DBG(2.5 SECONDS)
				if ((get_dist(src, M) <= 6) && src.alive)
					M.visible_message("<span class='alert'><b>[M.name] clutches their temples!</b></span>")
					M.emote("scream")
					M.setStatus("paralysis", max(M.getStatusDuration("paralysis"), 100))
					M.take_brain_damage(10)

					do_teleport(M, locate((world.maxx/2) + rand(-10,10), (world.maxy/2) + rand(-10,10), 1), 0)

				src.attacking = 0

		attackby(obj/item/W as obj, mob/living/user as mob)
			if(!alive)
				return ..()

			if (istype(W, /obj/item/device/key))
				if (dd_hasprefix(lowertext(W.name), "gold"))
					boutput(user, "<b>[src]</b> respectfully declines, as it didn't stay down the first time.")
					return
				if (!dd_hasprefix(lowertext(W.name), "lead"))
					boutput(user, "<b>[src]</b> doesn't seem to be interested.  Maybe it's the color?  The metal?")
					return

				W.layer = initial(src.layer)
				user.u_equip(W)
				W.set_loc(src)
				user.visible_message("<b>[user]</b> feeds [W] to [src]!","You feed [W] to [src]. Fuck!")
				SPAWN_DBG(2 SECONDS)
					W.icon_state = "key_gold"
					W.desc += "  It appears to be covered in honey.  Gross."
					src.visible_message("<b>[src]</b> regurgitates [W]!")
					W.name = "golden key"
					playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
					W.set_loc(get_turf(src))
			else
				return ..()

	moon
		name = "Moon Bee"
		desc = "A moon bee.  It's like a regular space bee, but it has a peculiar gleam in its eyes..."
		generic = 0
		var/hug_count = 0

		attack_hand(mob/user as mob)
			if (src.alive)
				if (user.a_intent == INTENT_HARM)
					return ..()

				else if (user.a_intent == INTENT_GRAB)
					if (src.task == "attacking" && src.target)
						src.visible_message("<span class='alert'><b>[user]</b> attempts to wrangle [src], but [src] is [pick("mad","grumpy","hecka grumpy","agitated", "too angry")] and resists!</span>")
						return

					user.pulling = src
					src.wanderer = 0
					if (src.task == "wandering")
						src.task = "thinking"
					src.wrangler = user
					src.visible_message("<span class='alert'><b>[user]</b> wrangles [src].</span>")

				else

					src.visible_message("<span class='notice'><b>[user]</b> [pick("pets","hugs","snuggles","cuddles")] [src]!</span>")
					switch (++hug_count)
						if (10)
							src.visible_message("<b>[src]</b> burps!  It smells like beeswax.")

						if (25)
							src.visible_message("<b>[src]</b> burps!  It smells...coppery.  What'd that bee eat?")

						if (100)
							src.visible_message("<b>[src]</b> regurgitates a...key? Huh!")
							playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)

							// Something is fishy about this bee.
							var/obj/item/device/key/K
							var/key_dodgy = (src.name == "sun bee" && !derelict_mode) || (src.name == "moon bee" && derelict_mode)

							if(src.name == "sun bee")
								K = new /obj/item/device/key {name = "solar key"; desc = "A metal key with a sun icon on the bow.";} (src.loc)
							else
								K = new /obj/item/device/key {name = "lunar key"; desc = "A metal key with a moon icon on the bow.";} (src.loc)
							K.dodgy = key_dodgy

					if(prob(15))
						for(var/mob/O in hearers(src, null))
							O.show_message("[src] buzzes[prob(50) ? " happily!" : ""]!",2)
					return
			else
				..()

			return

	buddy
		name = "B-33"
		desc = "It appears to be a hybrid of a domestic space-bee and a PR-6 Robuddy. How is that even possible?"
		icon_state = "buddybee-wings"
		icon_body = "buddybee"
		icon_sleep = "beezzzs-buddybee"
		sleeping_icon_state = "buddybee-sleep"
		icon_antenna = null
		hat_y_offset = 3
		hat_x_offset_right = 4
		hat_x_offset_left = 4


	trauma
		name = "traumatized space bee"
		desc = "This poor bee has seen some serious shit."
		icon_state = "traumabee-wings"
		icon_body = "traumabee"
		sleeping_icon_state = "traumabee-sleep"
		generic = 0

		attack_hand(mob/user as mob)
			if (src.alive && user.a_intent == "help")

				src.visible_message("<span class='notice'><b>[user]</b> [pick("pets","hugs","snuggles","cuddles")] [src]!</span>")
				if(prob(15))
					for(var/mob/O in hearers(src, null))
						O.show_message("[src] buzzes[prob(50) ? " in a comforted manner" : ""].",2)
				return
			else
				..()

	chef
		desc = "Please do not think too hard about the circumstances that would result in a bee chef."
		icon_state = "chefbee-wings"
		icon_body = "chefbee"
		sleeping_icon_state = "chefbee-sleep"
		cant_take_hat = 1
		generic = 0

	santa
		desc = "Genetically engineered for extreme size and indistinct segmentation and bred for docility, the greater domestic space-bee is increasingly popular among space traders and science-types.<br>This one has a little santa hat, aww."
		icon_state = "santabee-wings"
		icon_body = "santabee"
		sleeping_icon_state = "santabee-sleep"
		cant_take_hat = 1
		generic = 0
		honey_color = rgb(0, 255, 0)
		shorn_item = /obj/item/clothing/mask/beard

	reindeer
		desc = "Genetically engineered for extreme size and indistinct segmentation and bred for docility, the greater domestic space-bee is increasingly popular among space traders and science-types. It seems to have antlers?"
		icon_state = "deerbee-wings"
		icon_body = "deerbee"
		sleeping_icon_state = "deerbee-sleep"
		icon_antenna = "antenna-deerbee"

	fancy
		icon_state = "tophatbee-wings"
		icon_body = "tophatbee"
		sleeping_icon_state = "tophatbee-sleep"
		cant_take_hat = 1

	creepy
		desc = "Genetically engineered for extreme size and indistinct segmen-<br>oh god what is wrong with its face<br><b>oh god it's looking at you</b>"
		icon_state = "creepybee-wings"
		icon_body = "creepybee"
		sleeping_icon_state = "creepybee-sleep"

	angry // the angry bee is like angry birds if angry birds was nothing like angry birds and was instead a bee that looked grumpy
		icon_state = "madbee-wings"
		icon_body = "madbee"
		sleeping_icon_state = "madbee-sleep"

	zombee
		name = "zombee"
		desc = "Genetically engineered for extreme size and indistinct segmentation and bred for docility, the greater domestic space-bee is increasingly popular among space traders and science-types.<br>This one seems kinda sick, poor thing."
		icon_state = "zombee-wings"
		icon_body = "zombee"
		sleeping_icon_state = "zombee-sleep"
		honey_color = rgb(0, 255, 0)
		var/stay_dead = 0

		CritterDeath()
			..()
			if (!src.stay_dead)
				SPAWN_DBG(rand(100,1000))
					src.health = initial(src.health)
					src.alive = 1
					src.set_density(initial(src.density))
					src.on_revive()
					src.visible_message("<span class='alert'>[src] seems to rise from the dead!</span>")

	zombee/lich // sprite by mageziya, it's silly but cute imo
		name = "lich-bee"
		icon_state = "lichbee-wings"
		icon_body = "lichbee"
		sleeping_icon_state = "lichbee-sleep"
		honey_color = rgb(25, 55, 25)
		cant_take_hat = 1
		generic = 0

	small
		icon_state = "lilbee-wings"
		icon_body = "lilbee"
		sleeping_icon_state = "lilbee-sleep"
		icon_antenna = "antenna-lilbee"
		hat_y_offset = -1
		hat_x_offset_left = 1
		hat_x_offset_right = 6

	sea // c b
		name = "greater domestic sea-bee"
		desc = "Genetically engineered for extreme size and indistinct segmentation and bred for docility, the greater domestic sea-bee is increasingly popular among ocean traders and science-types."
		icon_state = "seabee-wings"
		icon_body = "seabee"
		sleeping_icon_state = "seabee-sleep"

	sonic
		name = "sonic bee"
		desc = "OH GOD IT IS BACK, WE WERE SURE WE REMOVED IT FROM THE CODEBASE BUT IT KEEPS COMING BACK OH GOD"
		icon_body = "sonicbee"
		icon_state = "sonicbee-wings"
		sleeping_icon_state = "sonicbee-sleep"

	ascbee
		name = "ASCBee"
		desc = "This bee looks rather... old school."
		icon_body = "ascbee"
		icon_state = "ascbee-wings"
		sleeping_icon_state = "ascbee-sleep"
		angertext = "beeps aggressively at"
		honey_color = rgb(0, 255, 0)

		attack_hand(mob/user as mob)
			if(src.alive && user.a_intent=="help")
				src.visible_message("<span class='emote'><b>[user]</b> [pick("pets","hugs","snuggles","cuddles")] [src]!</span>")
				if(prob(15))
					for(var/mob/O in hearers(src, null))
						O.show_message("<span class='emote'><b>[src]</b> beeps[prob(50) ? " in a comforted manner, and gives [user] the ASCII" : ""].</span>",2)
				return
			else
				..()
/* -------------------- END -------------------- */

/* -------------------- BASE BEE STUFF -------------------- */

	New()
		..()
		var/datum/reagents/R = new/datum/reagents(honey_production_amount)
		reagents = R
		R.my_atom = src

		statlog_bees(src)

		//SPAWN_DBG(1 SECOND)
		src.pixel_x = rand(-max_offset,max_offset)
		src.pixel_y = rand(-max_offset,max_offset)

		SPAWN_DBG(1 DECI SECOND)
			src.update_icon()
			if (src.alive && !src.sleeping)
				animate_bumble(src)

#if ASS_JAM
		if(src.icon_body == "petbee" && prob(5))
			src.icon_body = "sonicbee"
			src.icon_state = "[src.icon_body]-wings"
			src.sleeping_icon_state = "[src.icon_body]-sleep"
			src.desc = "OH GOD IT IS BACK, WE WERE SURE WE REMOVED IT FROM THE CODEBASE BUT IT KEEPS COMING BACK OH GOD"
#endif

	process()
		if(shorn && (world.time - shorn_time) >= 1800)
			shorn = 0
		return ..()

	ai_think()
		src.wanderer = !(src.wrangler && src.wrangler.pulling == src)

		if (task != "attacking")
			if (!beeMom && beeMomCkey)
				for (var/mob/maybeOurMom in hearers(src, null))
					if (!isdead(maybeOurMom) && beeMomCkey == maybeOurMom.ckey)
						beeMom = maybeOurMom
						src.visible_message("<span class='notice'><b>[src]</b> stares at [maybeOurMom] for a moment, then bumbles happily!</span>")
						break

			else if ((beeMom in hearers(src, null)))
				if (isdead(beeMom))
					beeMom = null //beeMomCkey still set.
					src.visible_message("<span class='alert'><b>[src]</b> bumbles MOURNFULLY.</span>")
					return

				if (beeMom.lastattacker && beeMom.lastattacker != beeMom && (beeMom.lastattackertime + 140) >= world.time)
					src.target = beeMom.lastattacker
					src.oldtarget_name = "[src.target]"
					src.visible_message("<span class='alert'><b>[src] buzzes angrily at [beeMom.lastattacker]!</b></span>")
					src.task = "chasing"
					return ..()

			if (nectar_check-- < 1)
				nectar_check = initial(nectar_check)

				for (var/obj/machinery/plantpot/planter in view(7, src))
					if (!planter.reagents || !planter.current || planter.dead)
						continue

					if (planter.reagents.get_reagent_amount("nectar"))
						src.target = planter
						break

			else
				return ..()

		else
			return ..()

		return 1

	on_grump()
		if (src.target)
			for (var/obj/critter/domestic_bee/fellow_bee in view(7, src))
				if (fellow_bee.task == "chasing" || fellow_bee.task == "attacking")
					continue

				fellow_bee.target = src.target
				fellow_bee.oldtarget_name = src.oldtarget_name
				fellow_bee.task = "chasing"

	attack_ai(mob/user as mob)
		if (get_dist(user, src) < 2)
			return attack_hand(user)
		else
			return ..()

	attack_hand(mob/user as mob)
		if (src.alive)
			if (src.sleeping)
				sleeping = 0
				on_wake()

			if (user.a_intent == INTENT_HARM)
				src.lastattacker = user
				return ..()

			else if (user.a_intent == INTENT_GRAB)
				if (src.task == "attacking" && src.target)
					if (istype(src.target, /obj/machinery/plantpot))
						src.visible_message("<span class='alert'><b>[user]</b> attempts to wrangle [src], but [src] is too focused on \the [src.target] to be wrangled!</span>")
					else
						src.visible_message("<span class='alert'><b>[user]</b> attempts to wrangle [src], but [src] is [pick("mad","grumpy","hecka grumpy","agitated", "too angry")] and resists!</span>")
					return

				user.pulling = src
				src.wanderer = 0
				if (src.task == "wandering")
					src.task = "thinking"
				src.wrangler = user
				src.visible_message("<span class='alert'><b>[user]</b> wrangles [src].</span>")

			else

				src.visible_message("<span class='notice'><b>[user]</b> [pick("pets","hugs","snuggles","cuddles")] [src]!</span>")
				if(prob(15))
					for(var/mob/O in hearers(src, null))
						O.show_message("[src] buzzes[prob(50) ? " happily!" : ""]!",2)
				if (prob(10))
					user.visible_message("<span class='notice'>[src] hugs [user] back!</span>", "<span class='notice'>[src] hugs you back!</span>")
					if (user.reagents)
						user.reagents.add_reagent("hugs", 10)

				return
		else
			..()

		return

	CritterAttack(mob/M)
		SPAWN_DBG(0.8 SECONDS) // hit_twitch() or attack_twitch() or something in the parent ai_think() causes the bumbling to stop so we have to restart it.
			if (src.alive && !src.sleeping) // boy I can't wait until we don't have to do stupid shit like this anymore!!!!
				animate_bumble(src)
		src.attacking = 1
		if (istype(M, /obj/machinery/plantpot))
			var/obj/machinery/plantpot/planter = M
			if (planter.dead || !planter.reagents || !planter.current)
				src.task = "thinking"
				src.attacking = 0
				return

			//todo: Robust pollination action
			var/planterNectarAmt = planter.reagents.get_reagent_amount("nectar")

			if (planterNectarAmt < 5)
				src.task = "thinking"
				src.attacking = 0
				return

			var/nectarTransferAmt = min(  min( (src.reagents.maximum_volume - src.reagents.total_volume), planterNectarAmt), 25  )

			if (nectarTransferAmt <= 0)
				src.task = "thinking"
				src.attacking = 0
				return

			if (planter.current.assoc_reagents.len || (planter.plantgenes && planter.plantgenes.mutation && planter.plantgenes.mutation.assoc_reagents.len))
				var/list/additional_reagents = planter.current.assoc_reagents
				if (planter.plantgenes && planter.plantgenes.mutation && planter.plantgenes.mutation.assoc_reagents.len)
					additional_reagents = additional_reagents | planter.plantgenes.mutation.assoc_reagents

				/*var/associated_reagent = planter.current.associated_reagent
				if (planter.plantgenes && planter.plantgenes.mutation && planter.plantgenes.mutation.associated_reagent)
					associated_reagent = planter.plantgenes.mutation.associated_reagent*/

				planter.reagents.remove_reagent("nectar", nectarTransferAmt*0.75)
				src.reagents.add_reagent("honey", nectarTransferAmt*0.75)
				for (var/X in additional_reagents)
					src.reagents.add_reagent(X, (nectarTransferAmt*0.25) / additional_reagents.len)

			else
				planter.reagents.remove_reagent("nectar", nectarTransferAmt)
				src.reagents.add_reagent("honey", nectarTransferAmt)

			//Bee is good for plants.  Synergy.  Going to hold a business meeting and use only yellow and black in the powerpoints.
			if (prob(10) && planter.health < planter.current.starthealth)
				planter.health++

			src.visible_message("<b>[src]</b> [pick("slurps","sips","drinks")] nectar out of [planter].")
			src.health = min(initial(src.health), src.health + 5)

			if (src.reagents.total_volume >= src.reagents.maximum_volume)
				src.puke_honey()

				src.task = "thinking"
				src.attacking = 0
				return

			SPAWN_DBG(3.5 SECONDS)
				src.attacking = 0
			return

		src.visible_message("<span class='alert'><B>[src]</B> bites [M] with its [pick("tiny","eeny-weeny","minute","little", "nubby")] [prob(50) ? "mandibles" : "bee-teeth"]!</span>")
		logTheThing("combat", src.name, M, "bites [constructTarget(M,"combat")]")
		random_brute_damage(M, 2, 1)
		if (isliving(M))
			var/mob/living/H = M
			H.was_harmed(src)
		if (M.stat || M.getStatusDuration("paralysis"))
			src.task = "thinking"
			src.attacking = 0
			return
		SPAWN_DBG(3.5 SECONDS)
			src.attacking = 0

	ChaseAttack(mob/M)
		if (istype(M, /obj/machinery/plantpot))
			return CritterAttack(M)
		if (!istype(M))
			return
		if (prob(20))
			return CritterAttack(M)
		if (M.stat || M.getStatusDuration("paralysis"))
			src.task = "thinking"
			return
		src.visible_message("<span class='alert'><B>[src]</B> pokes [M] with its [pick("nubby","stubby","tiny")] little stinger!</span>")
		logTheThing("combat", src.name, M, "stings [constructTarget(M,"combat")]")
		if (isliving(M))
			var/mob/living/H = M
			H.was_harmed(src)

		if(M.reagents)
			if (M.reagents.get_reagent_amount("histamine") < 10)
				M.reagents.add_reagent("histamine", 5)
			M.reagents.add_reagent("toxin", 4)

		if (isliving(M))
			var/mob/living/L = M
			var/datum/ailment_data/disease/plague = L.find_ailment_by_type(/datum/ailment/disease/space_plague)
			if (istype(plague,/datum/ailment_data/disease/))
				//That bee venom plague treatment does not work at all in this manner. However, future.
				L.cure_disease(plague)

	on_sleep()
		..()
		SPAWN_DBG(1 DECI SECOND)
			src.update_icon()
			animate(src)

	on_wake()
		..()
		SPAWN_DBG(1 DECI SECOND)
			src.update_icon()
			if (src.alive)
				animate_bumble(src)

	on_revive()
		..()
		SPAWN_DBG(1 DECI SECOND)
			src.update_icon()
			animate_bumble(src)

	CritterDeath()
		..()
		src.update_icon()
		animate(src)
		modify_christmas_cheer(-5)
		var/mob/M = src.lastattacker
		if (M)
			M.add_karma(-5)
		for (var/obj/critter/domestic_bee/fellow_bee in view(7,src))
			if(fellow_bee.alive)
				fellow_bee.aggressive = 1
				SPAWN_DBG(0.7 SECONDS)
					fellow_bee.aggressive = 0

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if(!user || !E) return 0
		if(!src.alive)
			return
		if (E.icon_state == "gold")
			boutput(user, "<b>[src]</b> respectfully declines, as it didn't stay down the first time.")
			return
		E.layer = initial(src.layer)
		user.u_equip(E)
		E.set_loc(src)
		if (user)
			user.visible_message("<b>[user]</b> feeds [E] to [src]!","You feed [E] to [src]. Fuck!")
		SPAWN_DBG(2 SECONDS)
			if(istype(src, /obj/critter/domestic_bee/bubs)) //The fattest and hungriest bee
				qdel(E)
				src.visible_message("<b>[src]</b> burps.")
				SPAWN_DBG(1 SECOND)
					src.visible_message("<b>[src]</b> bumbles happily!")
					src.dance()
				SPAWN_DBG(18 SECONDS)
					if(src.task != "chasing" && src.task != "attacking" && user && get_dist(src, user) <= 7)
						src.visible_message("<b>[src]</b> buzzes in a clueless manner as to why [user] looks so dejected.[prob(5)?" You can tell because you studied bee linguistics, ok?": null]")

						//Is this a bad idea? It probably is a bad idea.
						SPAWN_DBG(2 SECONDS)
							var/obj/item/dagger/D = new /obj/item/dagger/syndicate(src.loc)
							D.name = "tiny switchblade"
							D.desc = "Why would a bee even have this!?"
							src.visible_message("<b>[src]</b> drops \a [D] on the floor in an attempt to cheer [user] up!")
							playsound(D.loc, 'sound/impact_sounds/Crystal_Hit_1.ogg' , 30, 1)
			else
				E.icon_state = "gold"
				E.desc += "  It appears to be covered in honey.  Gross."
				src.visible_message("<b>[src]</b> regurgitates [E]!")
				E.name = "sticky [E.name]"
				playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
				E.set_loc(get_turf(src))
		return

	attackby(obj/item/W as obj, mob/living/user as mob)
		if (!alive)
			return ..()
		if (issnippingtool(W))
			if(shorn)
				boutput(user, "<b>[src]</b> has barely any beefuzz left. Stop it.")
			else
				shorn = 1
				shorn_time = world.time
				user.visible_message("<b>[user]</b> shears \the [src]!","You shear \the [src].")
				var/obj/item/material_piece/cloth/beewool/BW = unpool(/obj/item/material_piece/cloth/beewool)
				BW.set_loc(src.loc)
				if (shorn_item)
					new shorn_item(src.loc)
			return
		if (istype(W, /obj/item/reagent_containers/food/snacks))
			if(findtext(W.name,"bee") && !istype(W, /obj/item/reagent_containers/food/snacks/beefood)) // You just know somebody will do this
				src.visible_message("<b>[src]</b> buzzes in a repulsed manner!", 1)
				user.add_karma(-1)

				if (user != src.target)
					walk_away(src,user,10,1)
					SPAWN_DBG(1 SECOND)
						walk(src,0)
				return

			if (!W.reagents)
				boutput(user, "<b>[src]</b> respectfully declines, being a strict nectarian.")
				return

			var/nectarAmt = W.reagents.get_reagent_amount("nectar")
			var/isHoney = istype(W, /obj/item/reagent_containers/food/snacks/ingredient/honey) || istype(W, /obj/item/reagent_containers/food/snacks/pizza) || W.reagents.has_reagent("honey")
			if (!nectarAmt && !isHoney)
				boutput(user, "<b>[src]</b> respectfully declines, being a strict nectarian.")
				return

			user.visible_message("<b>[user]</b> feeds [W] to [src]!","You feed [W] to [src].")
			src.visible_message("<b>[src]</b> buzzes delightedly.", 1)
			src.health = min(initial(src.health), src.health+10)
			W.reagents.del_reagent("nectar")

			src.reagents.add_reagent("honey", nectarAmt)
			W.reagents.trans_to(src, (isHoney ? W.reagents.total_volume * 0.75 : 100) )
			if (src.reagents.total_volume >= src.reagents.maximum_volume)
				src.puke_honey()
			qdel(W)
		else if (istype(W, /obj/item/reagent_containers/glass))
			if (W.reagents.has_reagent("menthol") && W.reagents.reagent_list.len == 1)
				src.visible_message("<b>[src]</b> sniffles a bit.", 1)
				src.health = min(initial(src.health), src.health+5)
		else
			src.lastattacker = user
			..()
		src.update_icon()

	proc/update_icon()
		if (src.overlays)
			src.overlays = null
		if (src.generic && src.color)
			src.color = src.beeKid
			src.color = null

		if (!src.alive)
			src.icon_state = "[src.icon_body]-dead"
			if (src.beeKid)
				var/image/color_overlay = image(src.icon, "[src.icon_body]-dead-color")
				color_overlay.color = src.beeKid
				src.overlays += color_overlay
		else if (src.alive && src.sleeping)
			src.icon_state = "[src.icon_body]-sleep"
			if (src.beeKid)
				var/image/color_overlay = image(src.icon, "[src.icon_body]-sleep-color")
				color_overlay.color = src.beeKid
				src.overlays += color_overlay
			src.overlays += image(src.icon, src.icon_sleep)
		else
			src.icon_state = "[src.icon_body]-wings"
			if (src.beeKid)
				var/image/color_overlay = image(src.icon, "[src.icon_body]-color")
				color_overlay.color = src.beeKid
				src.overlays += color_overlay

		if (src.royal)
			var/image/crown_image = image(src.icon, "crown-[src.icon_body]")
			var/image/antenna_image = image(src.icon, "[src.icon_antenna]")
			if (!src.alive)
				crown_image.pixel_y -= src.sleep_y_offset
				antenna_image.icon_state = "[src.icon_antenna]-dead"
			else if (src.alive && src.sleeping)
				crown_image.pixel_y -= src.sleep_y_offset
				antenna_image.icon_state = "[src.icon_antenna]-sleep"
			src.overlays += crown_image
			src.overlays += antenna_image

		else if (src.hat && !src.cant_take_hat)
			if (hat_overlay_left)
				hat_overlay_left.pixel_x = src.hat_x_offset_left
				hat_overlay_left.pixel_y = src.hat_y_offset
			if (hat_overlay_right)
				hat_overlay_right.pixel_x = src.hat_x_offset_right
				hat_overlay_right.pixel_y = src.hat_y_offset
			var/image/antenna_image = image(src.icon, "[src.icon_antenna]")
			if (!src.alive)
				if (hat_overlay_left)
					hat_overlay_left.pixel_y -= src.sleep_y_offset
				if (hat_overlay_right)
					hat_overlay_right.pixel_y -= src.sleep_y_offset
				antenna_image.icon_state = "[src.icon_antenna]-dead"
			else if (src.alive && src.sleeping)
				if (hat_overlay_left)
					hat_overlay_left.pixel_y -= src.sleep_y_offset
				if (hat_overlay_right)
					hat_overlay_right.pixel_y -= src.sleep_y_offset
				antenna_image.icon_state = "[src.icon_antenna]-sleep"

			src.overlays += hat_overlay_left
			src.overlays += hat_overlay_right
			src.overlays += antenna_image

	proc/hat_that_bee(var/obj/ourHat)
		if (!ourHat)
			return

		src.hat = ourHat

		var/icon/newHatIcon = new /icon()
		var/icon/workingIcon = new /icon(src.hat_icon, "bhat-[src.hat.icon_state]", SOUTH)
		newHatIcon.Insert(workingIcon, "hat", SOUTH)
		newHatIcon.Insert(workingIcon, "hat", WEST)
		hat_overlay_left = image(newHatIcon, "hat")

		newHatIcon = new /icon()
		newHatIcon.Insert(workingIcon, "hat", NORTH)
		newHatIcon.Insert(workingIcon, "hat", EAST)

		hat_overlay_right = image(newHatIcon, "hat")

	proc/dance_response()
		if (src.is_dancing || !src.alive || src.sleeping)
			return

		if (prob(dance_chance))
			src.visible_message("<b>[src]</b> responds with a dance of its own!")
			src.dance()
		else
			if (istype(src, /obj/critter/domestic_bee/trauma))
				src.visible_message("<b>[src]</b> buzzes in short-lived comfort.")
			else
				src.visible_message("<b>[src]</b> buzzes [pick("to the beat", "in tune", "approvingly", "happily")].")

	proc/dance()
		set waitfor = 0
		src.is_dancing = 1

		var/dir_choice = prob(50) ? -90 : 90//pick("L", "R")
		var/sleep_time = (rand(1,20) / 10)//rand_deci(0, 0, 2, 0) // so if you have a big pack of bees they don't all start bumbling in exact synch
		var/time_time = (rand(15,20) / 10)//rand_deci(1, 5, 2, 0) // same as above
		//DEBUG_MESSAGE("[src] initial sleep time [sleep_time], animation time [time_time]")

		sleep(sleep_time)
		animate_beespin(src, dir_choice, time_time, 1)

		sleep(time_time * 8)
		animate_bumble(src)
		src.is_dancing = 0

	proc/puke_honey()
		var/turf/honeyTurf = get_turf(src)
		var/obj/item/reagent_containers/food/snacks/pizza/floor_pizza = locate() in honeyTurf
		var/obj/item/reagent_containers/food/snacks/ingredient/honey/honey
		if (istype(floor_pizza))
			honey = new /obj/item/reagent_containers/food/snacks/pizza(honeyTurf)
			src.visible_message("<b>[src]</b> regurgitates a blob of honey directly onto [floor_pizza]![prob(10) ? " This is a thing that makes sense." : null]")
			honey.name = replacetext(floor_pizza.name, "pizza", "beezza")
			qdel(floor_pizza)

		else
			honey = new /obj/item/reagent_containers/food/snacks/ingredient/honey(honeyTurf)
			src.visible_message("<b>[src]</b> regurgitates a blob of honey![prob(10) ? " Gross!" : null]")

		if (honey.reagents)
			honey.reagents.clear_reagents() // clear reagents since honey's New() makes it start with some already, making less room for the bee's reagents
			honey.reagents.maximum_volume = honey_production_amount

		src.reagents.trans_to(honey, honey_production_amount)
		playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
		if (src.honey_color)
			var/icon/composite = icon(honey.icon, honey.icon_state)
			composite.ColorTone( honey_color )
			honey.icon = composite

		return honey

	attackby(obj/item/W as obj, mob/living/user as mob)
		if (istype(W, /obj/item/clothing/head))
			if (src.cant_take_hat)
				boutput(user, "<span class='alert'>[src] declines, but appreciates the offer.[prob(30) ? " You can tell, because of the bumbling. Appreciative bumbling, definitely." : null]</span>")
				return // yes let's say no and then take the hat anyway and keep it in our hat void
			if (src.hat)
				boutput(user, "<span class='alert'>[src] is already wearing a hat!</span>")
				return
			if (W.icon_state == "fdora")
				var/fluff = pick("kind of", "kinda", "a bit", "mildly", "slightly", "just a little")
				var/fluff2 = pick("offended", "weirded-out", "disgusted", "bemused", "confused", "annoyed")
				boutput(user, "[src] looks [fluff] [fluff2] at your offer and turns it down.")
				return
			if (!(W.icon_state in src.hat_list))
				boutput(user, "<span class='alert'>It doesn't fit!</span>")
				return

			src.hat = W
			user.drop_item()
			W.set_loc(src)

			hat_that_bee(src.hat)
			src.update_icon()
			user.visible_message("<span class='notice'><b>[user]</b> puts a hat on [src]!</span>",\
			"<span class='notice'>You put a hat on [src]!</span>")
			return
		else
			return ..()

	CanPass(atom/mover, turf/target, height=0, air_group=0)
		if (istype(mover, /obj/projectile))
			return prob(50)
		else
			return ..()

	throw_impact(atom/hit_atom)
		..()
		if (src.alive && !src.sleeping)
			animate_bumble(src) // please keep bumbling tia

/* -------------------- END -------------------- */

/* -------------------- LARVA -------------------- */

/obj/critter/domestic_bee_larva
	name = "greater domestic space-larva"
	desc = "As a result of the extensive genetic alteration, the domestic space-bee's larval and pupal stages have been compacted together."
	icon = 'icons/misc/bee.dmi'
	icon_state = "petbee_larva"
	density = 0
	health = 5
	aggressive = 0
	seekrange = 6
	defensive = 0
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 0
	atksilicon = 0
	firevuln = 1
	brutevuln = 1
	angertext = "squeals at"
	butcherable = 2
	generic = 0
	var/growth_timer = 60
	var/royal = 0
	var/custom_desc = null
	var/custom_bee_type = null
	var/custom_bee_queen = null
	var/mob/living/beeMom = null
	var/grow_anim = "grow"
	var/beeMomCkey = null
	var/scolded = 0

	var/tmp/blog = "larvalog|"

	bonnet
		desc = "A domestic space bee larva, but with a little bonnet.  Where did that even come from?"
		icon_state = "petbee_larva_bonnet"

	buddy
		icon_state = "buddybee_larva"
		//royal = -1
		custom_bee_type = /obj/critter/domestic_bee/buddy
		custom_bee_queen = /obj/critter/domestic_bee/queen/buddy
		grow_anim = "grow-buddybee"

	New()
		..()
		if (src.reagents)
			src.reagents.maximum_volume = 50; // semi-arbitrarily chosen, the parent ..() creates a reagent holder with a max volume of 100, most bees only have 50 so I set it as such, special bees will raise the max if necessary
		growth_timer += rand(-10,15)
		SPAWN_DBG (20)
			if (!beeMom)
				for (var/mob/living/M in range(2, src))
					if (!isdead(M) && M.ckey)
						beeMom = M
						beeMomCkey = M.ckey
						break

	ai_think()
		..()
		if (growth_timer-- == 0)
			if (royal == 1)
				src.visible_message("[src] pupates!")
				src.icon = 'icons/misc/bigcritter.dmi'
				src.icon_state = src.grow_anim
				pixel_x = -16
				pixel_y = -16
				SPAWN_DBG(2.5 SECONDS)
					var/obj/critter/domestic_bee/queen/grownbee
					if (ispath(custom_bee_queen, /obj/critter/domestic_bee/queen))
						grownbee = new custom_bee_queen(get_turf(src))
					else if (prob(5))
						grownbee = new /obj/critter/domestic_bee/queen/big(get_turf(src))
					else
						grownbee = new /obj/critter/domestic_bee/queen(get_turf(src))
					grownbee.name = replacetext(src.name, "larva", "bee")
					if (src.color)
						grownbee.beeKid = src.color
					if (src.custom_desc)
						grownbee.desc = custom_desc
					if (src.reagents)
						grownbee.reagents = src.reagents
						grownbee.reagents.my_atom = grownbee
						grownbee.reagents.maximum_volume = grownbee.honey_production_amount

					grownbee.beeMom = src.beeMom
					grownbee.beeMomCkey = src.beeMomCkey
					grownbee.update_icon()
					src.reagents = null
					qdel(src)
				return
			else
				src.visible_message("[src] pupates!")
				src.icon_state = "[initial(src.icon_state)]-grow"
				SPAWN_DBG(2.5 SECONDS)
					var/obj/critter/domestic_bee/grownbee
					if (ispath(custom_bee_type, /obj/critter/domestic_bee))
						grownbee = new custom_bee_type(get_turf(src))
					else
						grownbee = new /obj/critter/domestic_bee(get_turf(src))
					grownbee.name = replacetext(src.name, "larva", "bee")
					if (src.color)
						grownbee.beeKid = src.color
					if (src.custom_desc)
						grownbee.desc = custom_desc
					if (src.reagents)
						grownbee.reagents = src.reagents
						grownbee.reagents.my_atom = grownbee

					grownbee.beeMom = src.beeMom
					grownbee.beeMomCkey = src.beeMomCkey
					grownbee.update_icon()
					grownbee.blog = src.blog + "all grown up!|"
					src.reagents = null
					qdel(src)

		else if (src.task != "attacking" && !src.scolded)
			var/obj/item/clothing/under/nibble_target = locate() in range(3, src)
			if (istype(nibble_target))
				target = nibble_target
				src.task = "chasing"
			return
		return

	CritterAttack(mob/M)
		if (istype(src.target, /obj/item/clothing/under))
			if (!isturf(M.loc))
				target = null
				src.task = "thinking"
				src.attacking = 0
				return

			if (!src.attacking)
				src.attacking = 1
				src.visible_message("<b>[src]</b> [pick("nibbles on", "nips at", "chews on", "gnaws")] [target]!")
				SPAWN_DBG (100)
					src.attacking = 0
		else
			return ..()

	ChaseAttack(mob/M)
		return

	attackby(obj/item/W as obj, mob/living/user as mob)
		if(!alive)
			return
		if (istype(W, /obj/item/reagent_containers/food/snacks))
			if(findtext(W.name,"bee")) // You just know somebody will do this
				src.visible_message("<b>[src]</b> squeals in a repulsed manner!", 1)

				if (user != src.target)
					walk_away(src,user,10,1)
					SPAWN_DBG(1 SECOND)
						walk(src,0)
				return

			if (!W.reagents || !W.reagents.has_reagent("royal_jelly"))
				boutput(user, "<b>[src]</b> stares at [W], confused.")
				return

			if (royal != 0)
				boutput(user, "<b>[src]</b> doesn't seem hungry.  Oh well.")
				return

			user.visible_message("<b>[user]</b> feeds [W] to [src]!","You feed [W] to [src].")
			src.visible_message("<b>[src]</b> squeals delightedly.", 1)
			src.health = min(initial(src.health), src.health+10)
			royal = 1

			qdel(W)

		else if (istype(W, /obj/item/paper) && istype(src.target, /obj/item/clothing))
			user.visible_message("<b>[user]</b> [prob(50) ? "bops" : "boops"] [src] with a rolled paper!","You roll up the paper and gently bop [src] on the...nose ? area??")
			user.say("No!")
			src.task = "thinking"
			src.attacking = 0
			src.target = null
			src.scolded = 1
			src.visible_message("<b>[src]</b> squeals in a SCOLDED MANNER.")

		else
			user.add_karma(-1)
			..()

	CritterDeath()
		..()

		modify_christmas_cheer(-5)
		for (var/obj/critter/domestic_bee/fellow_bee in view(7,src))
			if(fellow_bee.alive)
				fellow_bee.aggressive = 1
				SPAWN_DBG(0.7 SECONDS)
					fellow_bee.aggressive = 0

/* -------------------- END -------------------- */

/* -------------------- EGGS & FOOD -------------------- */

/obj/item/reagent_containers/food/snacks/ingredient/egg/bee
	name = "space bee egg"
	desc = "A marvel of modern biological engineering, the space bee egg is held in a form of stasis until activation through an intuitive twisting action."
	icon = 'icons/misc/bee.dmi'
	icon_state = "petbee_egg"
	var/bee_name = null
	var/hatched = 0
	var/larva_type = null
	rand_pos = 1

	var/tmp/blog = "egg blog|"

	New()
		..()
		if (reagents)
			reagents.add_reagent("bee", 10)

		if (prob(25) && !larva_type)
			larva_type = /obj/critter/domestic_bee_larva/bonnet

	attack_hand(mob/user as mob)
		if (src.anchored)
			return
		else
			..()

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/pen))
			if (!bee_name)
				bee_name = pick_string("bee_names.txt", "beename")
			var/t = input(user, "Enter new bee name", src.name, src.bee_name) as null|text
			logTheThing("debug", user, null, "names a bee egg \"[t]\"")
			if (!t)
				return
			t = strip_html(replacetext(t, "'",""))
			t = copytext(t, 1, 65)
			if (!t)
				return
			if (!in_range(src, usr) && src.loc != usr)
				return

			src.bee_name = t
		else
			return ..()

	attack_self(mob/user as mob)
		if (src.anchored)
			return
		user.visible_message("[user] primes [src] and puts it down.", "You twist [src], priming it to hatch, then place it on the ground.")
		src.anchored = 1
		src.layer = initial(src.layer)
		user.u_equip(src)
		src.set_loc(get_turf(user))

		SPAWN_DBG(0)
			var/hatch_wiggle_counter = rand(3,8)
			while (hatch_wiggle_counter-- > 0)
				src.pixel_x++
				sleep(0.2 SECONDS)
				src.pixel_x--
				sleep(1 SECOND)

			src.visible_message("[src] hatches!")
			var/obj/critter/domestic_bee_larva/newLarva
			if (larva_type)
				newLarva = new larva_type(get_turf(src))
			else
				newLarva = new /obj/critter/domestic_bee_larva(get_turf(src))

			newLarva.blog += src.blog + "|larva hatched by [key_name(user)]|"

			if (bee_name)
				newLarva.name = bee_name
			else if (prob(50))
				newLarva.name = pick_string("bee_names.txt", "beename")

			qdel(src)

	throw_impact(var/atom/A)
		var/turf/T = get_turf(A)
		if (hatched || 0)//todo: re-enable this when people stop abusing bees!!!
			return
		hatched = 1
		src.visible_message("<span class='alert'>[src] splats onto the floor messily!</span>")
		playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 100, 1)
		make_cleanable(/obj/decal/cleanable/eggsplat,T)
		var/obj/critter/domestic_bee_larva/newLarva
		if (larva_type)
			newLarva = new larva_type(get_turf(src))
		else
			newLarva = new /obj/critter/domestic_bee_larva(get_turf(src))

		if (bee_name)
			newLarva.name = bee_name
		else if (prob(50))
			newLarva.name = pick_string("bee_names.txt", "beename")

		newLarva.throw_at(get_edge_target_turf(src, src.dir), 2, 1)
		qdel (src)

	buddy
		name = "cubic bee egg"
		desc = "You can't square the circle, but apparently you can square a space bee egg. Uh huhhh."
		icon_state = "buddybee_egg"
		larva_type = /obj/critter/domestic_bee_larva/buddy

	moon
		name = "moon egg"
		desc = "DUMU NANNA AK"
		icon_state = "moonbee_egg"
		bee_name = "moon larva"

		New()
			..()
			SPAWN_DBG (20)
				if (derelict_mode)
					name = "sun egg"
					desc = "DUMU UTU AK"
					icon_state = "sunbee_egg"
					bee_name = "sun larva"

		heal(var/mob/M)
			boutput(M, "<span class='alert'>You feel as if you have made a grave mistake.  Perhaps a doorway has closed forever.</span>")

		attack_self(mob/user as mob)
			if (src.anchored)
				return

			var/area/ourArea = get_area(src)
			if (!ourArea || !findtext(ourArea.name, "solarium"))
				user.visible_message("[user] fumbles with [src].  Maybe this is the wrong place for eggs?")
				return

			user.visible_message("[user] primes [src] and puts it down.", "You twist [src], priming it to hatch, then place it on the ground.")
			src.anchored = 1
			src.layer = initial(src.layer)
			user.u_equip(src)
			src.set_loc(get_turf(user))

			SPAWN_DBG(0)
				var/hatch_wiggle_counter = rand(3,8)
				while (hatch_wiggle_counter-- > 0)
					src.pixel_x++
					sleep(0.2 SECONDS)
					src.pixel_x--
					sleep(1 SECOND)

				src.visible_message("[src] hatches!")
				var/obj/critter/domestic_bee_larva/newLarva = new /obj/critter/domestic_bee_larva(get_turf(src))
				if (bee_name)
					newLarva.name = bee_name

				if (bee_name == "sun larva")
					newLarva.desc = "A sun...larva.  A space bee larva, but kinda weird."
					newLarva.custom_desc = "A sun bee.  It's like a regular space bee, but it has a look of fiery passion.  Passion for doing bee stuff."
				else
					newLarva.desc = "A moon...larva.  A space bee larva, but kinda odd."
					newLarva.custom_desc = "A moon bee.  It's like a regular space bee, but it has a peculiar gleam in its eyes..."
				newLarva.custom_bee_type = /obj/critter/domestic_bee/moon
				newLarva.blog += "larva hatched by [key_name(user)]"
				var/datum/reagents/R = new/datum/reagents(50)
				newLarva.reagents = R
				R.my_atom = newLarva
				R.add_reagent("wolfsbane", 10)
				qdel (src)

	throw_impact(var/atom/A)
		var/turf/T = get_turf(A)
		if (hatched || 0)//replace me too!!!
			return

		src.hatched = 1
		src.visible_message("<span class='alert'>[src] splats onto the floor messily!</span>")
		playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 100, 1)
		make_cleanable(/obj/decal/cleanable/eggsplat,T)
		var/obj/critter/domestic_bee_larva/newLarva = new /obj/critter/domestic_bee_larva(get_turf(src))
		if (bee_name)
			newLarva.name = bee_name
		if (bee_name == "sun larva")
			newLarva.desc = "A sun...larva.  A space bee larva, but kinda weird."
			newLarva.custom_desc = "A sun bee.  It's like a regular space bee, but it has a look of fiery passion.  Passion for doing bee stuff."
		else
			newLarva.desc = "A moon...larva.  A space bee larva, but kinda odd."
			newLarva.custom_desc = "A moon bee.  It's like a regular space bee, but it has a peculiar gleam in its eyes..."
		newLarva.throw_at(get_edge_target_turf(src, src.dir), 2, 1)
		qdel (src)

/obj/item/bee_egg_carton
	name = "space bee egg carton"
	desc = "A space-age cardboard carton designed to safely transport a single space bee egg."
	icon = 'icons/misc/bee.dmi'
	icon_state = "petbee_carton"
	w_class = 2
	var/obj/item/reagent_containers/food/snacks/ingredient/egg/bee/ourEgg
	var/open = 0

	New()
		..()
		ourEgg = new /obj/item/reagent_containers/food/snacks/ingredient/egg/bee(src)

	attack_self(mob/user as mob)
		src.open = !src.open
		src.update_icon()
		return

	attackby(obj/item/W as obj, mob/living/user as mob)
		if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/egg/bee))
			if (!src.open)
				boutput(user, "<span class='alert'>For <i>some reason</i>, you are unable to place the egg into a closed carton.</span>")
				return

			if (src.ourEgg)
				boutput(user, "<span class='alert'>There is already an egg in the carton.  It's only big enough for one egg at a time.  They are very large eggs.</span>")
				return

			user.u_equip(W)
			W.layer = initial(W.layer)
			src.ourEgg = W
			W.set_loc(src)
			src.update_icon()
			boutput(user, "You place [W] into [src].")

		else
			return ..()

	attack_hand(mob/user as mob)
		if (src.loc == user && src.ourEgg && src.open)
			user.put_in_hand_or_drop(src.ourEgg)
			boutput(user, "You take [src.ourEgg] out of [src].")
			src.ourEgg.blog += "egg taken out by [key_name(user)]|"
			src.ourEgg = null
			src.add_fingerprint(user)
			src.update_icon()

			return

		return ..()


	proc/update_icon()
		if (open)
			src.icon_state = "petbee_carton[ourEgg != null]"
		else
			src.icon_state = "petbee_carton"

/obj/item/clothing/mask/beard
	name = "bee beard"
	desc = "A beard. From a bee."
	icon_state = "beard"

/obj/item/reagent_containers/food/snacks/beefood
	name = "bee kibble"
	desc = "A bowl of \"bee kibble.\" It is probably best not to think too hard about its composition."
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	icon_state = "petfood"
	amount = 4
	heal_amt = 1
	doants = 0

	New()
		..()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("nectar", 10)
		R.add_reagent("honey", 10)
		R.add_reagent("cornstarch", 5)
		R.add_reagent("pollen", 20)

/* -------------------- END -------------------- */

/* -------------------- NOT A BEE -------------------- */

/obj/critter/fake_bee //Based on the deer botfly, a bumblebee mimic that plants eggs in the noses of deer.  Oh, except when it confuses a human eye for a deer nose.
	name = "kocmoc pchela"
	desc = "This...isn't a bee.  A fake bee.  Counterfeit bee."
	icon_state = "fakebee"
	density = 1
	health = 20
	aggressive = 0
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 1
	atksilicon = 1
	firevuln = 0.8
	brutevuln = 0.8
	angertext = "bozzes angrily at"
	butcherable = 1
	sleeping_icon_state = "fakebee-sleep"
	max_quality = 25
	flying = 1

	CritterAttack(mob/M)
		src.attacking = 1

		src.visible_message("<span class='alert'><B>[src]</B> bites [M]!</span>")
		logTheThing("combat", src.name, M, "bites [constructTarget(M,"combat")]")
		random_brute_damage(M, 2, 1)
		if (M.stat || M.getStatusDuration("paralysis"))
			src.task = "thinking"
			src.attacking = 0
			return
		SPAWN_DBG(3.5 SECONDS)
			src.attacking = 0

	ChaseAttack(mob/M)
		if (!istype(M)) return

		if (M.stat || M.getStatusDuration("paralysis"))
			src.task = "thinking"
			return

		return CritterAttack(M)

	attack_hand(mob/user as mob)
		if (src.alive)
			if (user.a_intent == INTENT_HARM)
				return ..()

			else if (user.a_intent == INTENT_GRAB)
				src.visible_message("<span class='alert'><b>[user]</b> attempts to wrangle [src], but [src] squirms away.</span>")
				return

			else

				user.visible_message("<span class='alert'><b>[user]</b> pets [src]. Both parties look uncomfortable.</span>","<span class='alert'>You pet [src]. [src] looks uncomfortable.  You don't feel much better.</span>")
				if(prob(15))
					for(var/mob/O in hearers(src, null))
						O.show_message("[src] bozzes.",2)
				return
		else
			..()

	attackby(obj/item/W as obj, mob/living/user as mob)
		if(!alive)
			return
		if (istype(W, /obj/item/reagent_containers/food/snacks))
			src.visible_message("<b>[src]</b> stares blankly at [W].")

		else if (istype(W, /obj/item/luggable_computer/cheget))
			if (!W:locked)
				src.visible_message("<b>[src]</b> stares blankly at [W].")
			else
				src.visible_message("<b>[src]</b> stares blankly at [W] for a moment, then bops against its keypad several times.")
				W.Topic("enter=[W:code]",list("enter"="[W:code]"))

		else
			..()
