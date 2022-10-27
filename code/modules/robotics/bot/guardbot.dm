//CONTENTS
//Movement control datum
//Guardbot
//Guardbot tools
//Task datums
//Guardbot parts
//Docking Station
//Old Robuddies (PR-4)

//Robot config constants
#define GUARDBOT_LOWPOWER_ALERT_LEVEL 100
#define GUARDBOT_LOWPOWER_IDLE_LEVEL 10
#define GUARDBOT_POWER_DRAW 1
#define GUARDBOT_RADIO_RANGE 75
#define GUARDBOT_DOCK_RESET_DELAY 40

//movement datum
/datum/guardbot_mover
	var/obj/machinery/bot/guardbot/master = null
	var/delay = 3
	var/max_dist = 100

	New(var/newmaster, max_dist=100)
		..()
		if(istype(newmaster, /obj/machinery/bot/guardbot))
			src.master = newmaster
		src.max_dist = max_dist
		return

	disposing()
		if(src.master.mover == src)
			src.master.mover = null
		src.master = null
		..()

	proc/master_move(var/atom/the_target as obj|mob,var/adjacent=0)
		if(!master)
			return 1
		if(!isturf(master.loc))
			qdel(src)
			return 1
		var/target_turf = null
		if(isturf(the_target))
			target_turf = the_target
		else
			target_turf = get_turf(the_target)

		if(!target_turf) //target got deleted?
			return

		//var/compare_movepath = current_movepath
		SPAWN(0)
			if (!master)
				return

			// Same distance cap as the MULE because I'm really tired of various pathfinding issues. Buddy time and docking stations are often way more than 150 steps away.
			// It's 200 something steps alone to get from research to the bar on COG2 for instance, and that's pretty much in a straight line.
			var/list/thePath = get_path_to(src.master, target_turf, max_distance=src.max_dist, simulated_only=istype(master.loc, /turf/simulated), \
				id=src.master.botcard, skip_first=FALSE, cardinal_only=TRUE)
			if (!master)
				return

			master.path = thePath
			if(adjacent && master.path && length(master.path)) //Make sure to check it isn't null!!
				master.path.len-- //Only go UP to the target, not the same tile.
			if(!master.path || !master.path.len || !the_target || (ismob(the_target) && master.path.len >= 21))
				master.task?.task_input("path_error")

				master.moving = 0
				qdel(src)
				return

			while(length(master?.path) && target_turf && master.moving)
				if(master.frustration >= 10 || master.stunned || master.idle || !master.on)
					master.frustration = 0
					master.task?.task_input("path_blocked")
					break
				step_to(master, master.path[1])
				if(master.loc != master.path[1])
					master.frustration++
					sleep(delay+delay)
					continue
				master.path -= master.path[1]
				sleep(delay)

			if (src.master)
				master.moving = 0
				qdel(src)

		return 0

//The Robot.
/obj/machinery/bot/guardbot
	name = "Guardbuddy"
	desc = "The corporate security model of the popular PR-6 Robuddy."
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "robuddy0"
	layer = 5.0 //TODO LAYER
	density = 0
	anchored = 0
	req_access = list(access_heads)
	on = 1
	var/idle = 0 //Sleeping on the job??
	locked = 1 //Behavior Controls and Tool lock
	//bot_voice = 'sound/misc/talk/bottalk_4.ogg'

	//var/current_movepath = 0 //If we need to switch movement halfway
	var/datum/guardbot_mover/mover = null

	var/emotion = null //How are you feeling, buddy?
	var/datum/computer/file/guardbot_task/task = null //Our current task.
	var/datum/computer/file/guardbot_task/model_task = null
	var/list/tasks = list() //All tasks.  First one is the current.
	var/list/scratchpad = list() //Scratchpad memory for tasks to pass messages.
	emagged = 0
	health = 25
	var/wakeup_timer = 0 //Are we waiting to exit idle mode?
	var/warm_boot = 0 //Have we already done the full startup procedure?
	var/obj/item/cell/cell //We have limited power! Immersion!!
	var/obj/item/device/guardbot_tool/tool //What weapon do we have?
	var/obj/machinery/guardbot_dock/charge_dock
	var/last_dock_id = null
	var/obj/item/clothing/head/hat = null
	var/hat_shown = 0
	var/hat_icon = 'icons/obj/bots/aibots.dmi'
	var/hat_x_offset = 0
	var/hat_y_offset = 0
	var/icon_needs_update = 1 //Call UpdateIcon() in process
	use_speech_bubble = 0 // D:

	var/image/costume_icon = null

	var/bedsheet = 0

	var/flashlight_lum = 2
	var/flashlight_red = 0.1
	var/flashlight_green = 0.4
	var/flashlight_blue = 0.1

	////////////////////// GUN STUFF -V
	// Lifted from secbot!
	var/global/list/budgun_whitelist = list(/obj/item/gun/energy/tasershotgun,\
											/obj/item/gun/energy/taser_gun,\
											/obj/item/gun/energy/vuvuzela_gun,\
											/obj/item/gun/energy/wavegun,\
											/obj/item/gun/energy/pulse_rifle,
											/obj/item/gun/bling_blaster,\
											/obj/item/bang_gun,\
											/obj/item/gun/kinetic/meowitzer/inert,\
											/obj/item/gun/russianrevolver,\
											/obj/item/gun/energy/egun,\
											/obj/item/gun/energy/ghost,\
											/obj/item/gun/energy/owl_safe,\
											/obj/item/gun/energy/frog,\
											/obj/item/gun/energy/shrinkray,\
											/obj/item/gun/energy/glitch_gun,\
											/obj/item/gun/energy/lawbringer)
	// List of guns that arent wierd gimmicks or traitor weapons
	var/global/list/budgun_actualguns = list(/obj/item/gun/energy/tasershotgun,\
											/obj/item/gun/energy/taser_gun,\
											/obj/item/gun/energy/wavegun,\
											/obj/item/gun/energy/pulse_rifle,\
											/obj/item/gun/energy/egun,\
											/obj/item/bang_gun,\
											/obj/item/gun/energy/lawbringer)
	var/shotcount = 1		// Number of times it shoots when it should, modded by emag state
	var/gun = null			// What's the name of our robot's gun? Used in the chat window!
	var/obeygunlaw = 1		// Does our bot follow the gun whitelist?
	var/obj/item/gun/budgun = null	// the gun, actually important
	var/hasgun = 0			// So our robot only gets one gun
	var/toollock = 1		// Gotta unlock the tool port to swap it
	var/gunlocklock = 0		// Traitor mods prevent guntheft
	var/ammofab = 0			// Is the Ammofabricator installed?
	var/obj/item/gun/setup_gun = null	// Lets spawn with a gun
	var/gunt = new /obj/item/device/guardbot_tool/gun	// We give this to Buddies lacking a module so they don't get self-conscious about lacking a module
	var/arrest_target = null	// uhh
	var/lethal = 0				// uhhh
	var/said_dumb_things = 0	// So we say that thing about spacelaw once...ish
	var/slept_through_becoming_the_law = 0 // If we gave em a lawbringer and they were fast asleep
	var/slept_through_laser_class = 0	// If we gave em a gun that can shoot lasers and they were fast asleep
	var/gun_x_offset = -1 // gun pic x offset
	var/gun_y_offset = 8 // gun pic y offset
	var/lawbringer_state = null // because the law just has to be *difficult*. determines what lights to draw on the lawbringer if it has one
	var/lawbringer_alwaysbigshot = 0 // varedit this to 1 if you want the Buddy to always go infinite-ammo bigshot. this is a bad idea
	/// Minimum time between shooting an attached gun
	var/gunfire_cooldown = 2 SECONDS
	//
	////////////////////// GUN STUFF -^

	var/control_freq = FREQ_BUDDY		// bot control frequency
	var/beacon_freq = FREQ_NAVBEACON
	var/net_id = null
	var/last_comm = 0 //World time of last transmission
	var/reply_wait = 0

	access_lookup = "Captain" //Job access for doors.
									//It's not like they can be pushed into airlocks anymore
	var/setup_no_costumes = 0 //no halloween costumes for us!!
	var/setup_unique_name = 0 //Name doesn't need random number appended to it.
	var/setup_spawn_dock = 0 //Spawn a docking station where we are.
	var/setup_charge_maximum = 1500 //Max charge of internal cell.  1500 ~25 minutes
	var/setup_charge_percentage = 90 //Percentage charge of internal cell
	var/setup_default_tool_path = /obj/item/device/guardbot_tool/flash //Starting tool.
#ifdef HALLOWEEN
	var/setup_default_startup_task = /datum/computer/file/guardbot_task/security/halloween
#else
	var/setup_default_startup_task = /datum/computer/file/guardbot_task/security //Task to run on startup. Duh.
#endif

	disposing()
		if (tool)
			tool.master = null
		if (task)
			task.dispose()
		if (model_task)
			model_task.dispose()
		..()

	ranger
#ifndef HALLOWEEN
		name = "Ol' Harner"
#else
		name = "Halloween Harner"
#endif
		desc = "Almost as much the law as Beepsky."
		setup_unique_name = 1
		setup_default_startup_task = /datum/computer/file/guardbot_task/security/patrol
		setup_charge_percentage = 95
		shotcount = 2	// If anyone'd be good with a gun, it'd be Harner
		gunfire_cooldown = 1.5 SECONDS

		New()
			..()
			src.hat = new /obj/item/clothing/head/mj_hat(src)
			src.hat.name = "Eldritch shape-shifting hat."
			src.UpdateIcon()

	assgun
		name = "Assaultbuddy"
		desc = "What happens when you put an assault rifle in the microwave."
		setup_charge_maximum = 100000
		setup_charge_percentage = 100
		setup_gun = /obj/item/gun/kinetic/akm
		health = 100
		ammofab = 1
		shotcount = 3 // Never stop firing, never start spawning
		setup_default_startup_task = /datum/computer/file/guardbot_task/security/crazy
		setup_default_tool_path = /obj/item/device/guardbot_tool/gun
		locked = 1
		obeygunlaw = 0
		gunlocklock = 1
		emagged = 1

	safety
		name = "Klaus"
		desc = "Safetybuddy Klaus wants you to mind safety regulations."
		setup_unique_name = 1
		setup_charge_maximum = 4500
		setup_charge_percentage = 100

		New()
			..()
			src.hat = new /obj/item/clothing/head/helmet/hardhat
			src.hat.name = "Klaus' hardhat"
			src.UpdateIcon()

	heckler
		name = "Hecklebuddy"
		desc = "A PR-6S Guardbuddy programmed to be sort of a jerk."
		setup_default_startup_task = /datum/computer/file/guardbot_task/bodyguard/heckle

		New()
			..()
			SPAWN(1 SECOND)
				for (var/mob/living/carbon/human/H in view(7, src))
					if (!H.stat)
						if (model_task)
							model_task:protected_name = ckey(H.name)
						if (task)
							task:protected_name = ckey(H.name)
						break

	golden
		name = "Goldbuddy"
		desc = "A gold plated PR-4 Guardbuddy from a limited time raffle from like, a decade ago."
		icon = 'icons/obj/bots/oldbots.dmi'
		icon_state = "Goldbuddy0"

		update_icon()

			var/emotion_image = null

			if(!src.on)
				src.icon_state = "Goldbuddy0"

			else if(src.stunned)
				src.icon_state = "Goldbuddya"

			else if(src.idle)
				src.icon_state = "Goldbuddy_idle"

			else
				if (src.emotion)
					emotion_image = image(src.icon, "face-[src.emotion]")
				src.icon_state = "Goldbuddy1"

			src.overlays = list( emotion_image, src.bedsheet ? image(src.icon, "bhat-ghost[src.bedsheet]") : null, src.costume_icon ? costume_icon : null)

			if (src.hat && !src.hat_shown)
				var/image/hat_image = image(src.hat_icon, "bhat-[src.hat.icon_state]",,layer = 9.5) //TODO LAYER
				hat_image.pixel_x = hat_x_offset
				src.underlays = list(hat_image)
				src.hat_shown = 1

			src.icon_needs_update = 0
			return

	gunner
		name = "Gunbuddy"
		desc = "A PR-6S Guardbuddy, but with a gun."
		setup_default_tool_path = /obj/item/device/guardbot_tool/taser
		shotcount = 2 // Come on, its a *gun* buddy
		gunfire_cooldown = 1.5 SECONDS

		vaquero
			name = "El Vaquero"
			desc = "The side label reads 'Fabricado en México'"
			setup_unique_name = 1
			setup_default_startup_task = /datum/computer/file/guardbot_task/security/patrol
			setup_charge_percentage = 98

	syringe
		name = "Wardbuddy"
		desc = "Wardbuddy is currently the CEO of a small internet syringe venture with plans to expand once he figures out how to fit a private jet in his dad's garage."
		setup_default_tool_path = /obj/item/device/guardbot_tool/medicator

	smoke
		name = "Snoozebuddy"
		desc = "Marketed as a riot control solution and sleep aid, the PR-6S2 Snoozebuddy offers a sophisticated gas-release module and a 5-year warranty."
		//setup_default_startup_task = /datum/computer/file/guardbot_task/security/patrol
		setup_default_tool_path = /obj/item/device/guardbot_tool/smoker

	tesla
		name = "Shockbuddy"
		desc = "The PR-6MS Shockbuddy was remarketed under the Guardbuddy line following the establishment of stricter electroconvulsive therapy regulations."
		setup_default_tool_path = /obj/item/device/guardbot_tool/tesla

	pie
		name = "Clownbuddy"
		desc = "This guardbuddy doesn't look quite right..."
		setup_default_tool_path = /obj/item/device/guardbot_tool/pie_launcher

		New()
			..()
			src.costume_icon = image(src.icon, "bcostume-clown", , FLY_LAYER)
			src.UpdateIcon()

	bodyguard
		setup_charge_percentage = 98
		setup_default_startup_task = /datum/computer/file/guardbot_task/bodyguard

	//xmas -- See spacemas.dm

	mail
		name = "Mailbuddy"
		desc = "The PR-6PS Mailbuddy is a postal delivery ace.  This may seem like an extremely specialized robot application, but that's just because it is exactly that."
		icon = 'icons/obj/bots/mailbud.dmi'

		New()
			..()
			src.hat = new /obj/item/clothing/head/mailcap(src)
			src.UpdateIcon()


	New()
		..()
		if(src.on)
			src.warm_boot = 1
#ifdef HALLOWEEN
		if (!setup_no_costumes)
			src.costume_icon = image(src.icon, "bcostume-[pick("xcom","clown","horse","moustache","owl","pirate","skull", "wizard", "wizardred","devil")]", , FLY_LAYER)
			src.costume_icon.pixel_x = src.hat_x_offset
			src.costume_icon.pixel_y = src.hat_y_offset
			if (src.costume_icon && src.costume_icon:icon_state == "bcostume-wizard")
				src.hat = new /obj/item/clothing/head/wizard
#endif
		src.UpdateIcon()

		if(!src.cell)
			src.cell = new /obj/item/cell(src)
			src.cell.maxcharge = setup_charge_maximum
			src.cell.charge = ((setup_charge_percentage/100) * src.cell.maxcharge)

		if(!setup_unique_name)
			src.name += "-[rand(100,999)]"


		SPAWN(0.5 SECONDS)
			if (src.on)
				add_simple_light("guardbot", list(src.flashlight_red*255, src.flashlight_green*255, src.flashlight_blue*255, (src.flashlight_lum / 7) * 255))

			if(setup_default_tool_path)
				src.tool = new setup_default_tool_path
				src.tool.set_loc(src)
				src.tool.master = src

			if(setup_gun && !src.budgun)
				src.budgun = new setup_gun(src)
				src.budgun.master = src
				src.hasgun = 1
				src.gun = budgun.name
				UpdateIcon()
				if(istype(src.budgun, /obj/item/gun/energy/lawbringer))
					BeTheLaw(src.emagged, 0, src.lawbringer_alwaysbigshot)
				else if(istype(src.budgun, /obj/item/gun/energy/egun))
					CheckSafety(src.budgun, src.emagged, null)

			src.net_id = generate_net_id(src)

			MAKE_DEFAULT_RADIO_PACKET_COMPONENT("control", control_freq)
			MAKE_DEFAULT_RADIO_PACKET_COMPONENT("beacon", beacon_freq)
			MAKE_SENDER_RADIO_PACKET_COMPONENT("pda", FREQ_PDA)

			var/obj/machinery/guardbot_dock/dock = null
			if(setup_spawn_dock)
				dock = new /obj/machinery/guardbot_dock( get_turf(src) )
				dock.frequency = src.control_freq
				dock.net_id = generate_net_id(dock)
			else
				dock = locate() in src.loc
				if(dock && istype(dock))
					if(!dock.net_id)
						dock.net_id = generate_net_id(dock)

			if(src.setup_default_startup_task && !src.task)
				if(!src.model_task)
					src.model_task = new setup_default_startup_task
					src.model_task.master = src

			if(dock)
				dock.connect_robot(src,dock.autoeject)
			else
				if(src.model_task)
					src.task = src.model_task.copy_file()
					src.task.master = src
					src.tasks.Add(src.task)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if(!user || !E) return 0

		if (src.idle || !src.on)
			if (!src.emagged)
				boutput(user, "You wave \the [E] in front of [src]'s blank screen. It responds with a small puff of smoke.")
			else
				boutput(user, "You wave \the [E] in front of [src]'s blank screen. It doesn't seem to respond.")
		else if (!src.emagged)
			if (E.icon_state == "gold")
				boutput(user, "You show \the [E] to [src]! They are super impressed!")
				SPAWN(1 SECOND)
					boutput(user, "Like, really REALLY impressed.  They probably think you're some kind of celebrity or something.")
					sleep(1 SECOND)
					boutput(user, "Or the president. The president of space.")
					sleep(1 SECOND)
					boutput(user, "In fact they're so impressed that it shorts out their Spacelaw circuits![pick("", " Whoops.")]")
			else
				boutput(user, "You show \the [E] to [src]! They become so impressed that [pick("they start smelling like burnt circuitry", "you hear a small pop come from inside their casing")].")
		else
			boutput(user, "You show \the [E] to [src]! They give you a knowing grin.")
			set_emotion("smug")
		src.emagged = 1
		if (src.obeygunlaw)
			src.obeygunlaw = 0
			if (src.idle || !src.on)
				SPAWN(1 SECOND)
					boutput(user, "[src] looks confused for a moment.")
		if (src.budgun)
			if(istype(src.budgun, /obj/item/gun/energy/lawbringer))
				BeTheLaw(1, 0, src.lawbringer_alwaysbigshot)
			if(istype(src.budgun, /obj/item/gun/energy/egun))
				CheckSafety(src.budgun, 1, user)
		return 1

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/device/pda2) && W:ID_card)
			W = W:ID_card
		if (istype(W, /obj/item/card/id))
			if (src.gunlocklock)
				speak(pick("Pass.", "No thanks.", "Nah, I'd rather not.", "Hands off the merchandise!",\
				"Yeah I'm going to need a signed permission slip from your mother first",\
				"No way, you'll hurt [pick("me", "yourself")]!", "No nerds allowed!",\
				"You're not the boss of me!", "Couldn't even if I wanted to!"))
			else if ((src.allowed(user)) && !src.gunlocklock)
				src.locked = !src.locked
				speak("Okay, my control panel and equipment locks are now [src.locked ? "enabled!" : "disabled!"]")
			else
				DeceptionCheck(W, user, "togglelock")

		else if (isscrewingtool(W))
			if (src.health < initial(health))
				src.health = initial(health)
				src.visible_message("<span class='notice'>[user] repairs [src]!</span>", "<span class='notice'>You repair [src].</span>")

		else if (istype(W, /obj/item/clothing/head))
			if(src.hat)
				boutput(user, "<span class='alert'>[src] is already wearing a hat!</span>")
				return
			if(W.icon_state == "fdora")
				boutput(user, "[src] looks [pick("kind of offended","kind of weirded-out","a bit disgusted","mildly bemused")] at your offer and turns it down.")
				return
			if(!(W.icon_state in BUDDY_HATS))
				boutput(user, "<span class='alert'>It doesn't fit!</span>")
				return

			src.hat = W
			user.drop_item()
			W.set_loc(src)

			src.UpdateIcon()
			user.visible_message("<b>[user]</b> puts a hat on [src]!","You put a hat on [src]!")
			return

		else if (istype(W, /obj/item/clothing/suit/bedsheet))
			if (src.bedsheet != 0)
				boutput(user, "<span class='alert'>There is already a sheet draped over [src]! Two sheets would be ridiculous!</span>")
				return

			src.bedsheet = 1
			user.drop_item()
			qdel(W)
			src.overlays.len = 0
			src.hat_shown = 0
			src.UpdateIcon()
			user.visible_message("<b>[user]</b> drapes a sheet over [src]!","You cover [src] with a sheet!")
			src.add_task(new /datum/computer/file/guardbot_task/bedsheet_handler, 1, 0)
			return

		else if (istype(W, /obj/item/reagent_containers/food/snacks/candy))
			if (src.idle || !src.on)
				boutput(user, "You try to give [src] [W], but there is no response.")
				return

			user.visible_message("<b>[user]</b> gives [W] to [src]!","You give [W] to [src]!")
			user.drop_item()
			qdel(W)
			if (src.task)
				src.task.task_input("treated")
			return

		else if (istype(W, /obj/item/device/guardbot_module/ammofab))
			IllegalBotMod("ammofab", W, user)

		else if (istype(W, /obj/item/device/guardbot_tool) || (istype(W, /obj/item/gun) || istype(W, /obj/item/bang_gun)))
			GrabTheThing(W, user) // Most of the checks for if they actually *do* grab the thing are in here

		else if (ispryingtool(W))
			var/turf/TdurgPry = get_turf(src)
			if (src.budgun)
				if (src.locked || src.gunlocklock)
					DeceptionCheck(W, user, "removegun")
				else
					DropTheThing("gun", null, 1, 1, TdurgPry)
			else if (src.tool)
				if (src.locked)
					DeceptionCheck(W, user, "removetool")
				else
					DropTheThing("tool", null, 1, 1, TdurgPry)

		else
			switch(W.hit_type)
				if (DAMAGE_BURN)
					src.health -= W.force * 0.6
				else
					src.health -= W.force * 0.4
			if (src.health <= 0)
				..()
				src.explode()
				return
			else if (W.force && src.task)
				src.task.attack_response(user)
			..()

	proc/CheckSafety(var/obj/item/gun/energy/W, var/unsafe = 0, var/user = null)
		if (!istype(W, /obj/item/gun/energy/egun))
			return	// Eguns only, please!
		if (!src.on || src.idle)
			src.slept_through_laser_class = 1	// y'know, whenever you get a chance
			return
		var/fluffbud = pick("small", "cute", "handsome", "adorable", "lovable", "lovely")
		var/budfluff = pick("Thinktronic Data System", "rectangular device",\
											 "robot under warranty", "ambulatory home appliance")
		var/fluffbad1 = pick("a total bad a-s-s", "an intimidating", "a rugged",\
											 "a sovereign", "an edgy", "an unlovable",\
											 "a [pick("strikingly","")] robust", "a freedom-loving")
		var/fluffbad2 = pick("spacehunter", "sight to behold", "allied mastercomputer",\
											 "quadrangle", "starfighter", "free-willed individual stuck in a rectangle",\
											 "future president of space", "future space federation wrestling champion")

		if (!unsafe) // we're a good little robot
			if (!istype(src.budgun.current_projectile, /datum/projectile/laser))
				speak("Aww, [src.slept_through_laser_class ? "whoever gave me this [src.budgun] knows" : "you know"] just how I like my Multiple-Firemode Energy Weapons!")
				set_emotion("love")
			else
				if(slept_through_laser_class)
					src.visible_message("[src] looks at the [src.budgun] in its hand, curious.")
					speak("Huh, that's new.")
				speak("[(src.slept_through_laser_class || !user) ? "" : "Thank you, [user]! "]Oh... but article-[(rand(1,6))] subsection-[rand(1,32764)] of Spacelaw prohibits any [fluffbud] [budfluff] from wielding a Class-[pick("A", "B","C", "D")] laser weapon.")
				SPAWN(2 SECONDS)
					speak("Oh! This weapon has a stun setting! That makes it [pick("A-OK", "totally fine", "well within certain loopholes of the law")] for me to use!")
					src.budgun.set_current_projectile(new /datum/projectile/energy_bolt)
					src.budgun.item_state = "egun"
					src.budgun.icon_state = "energystun100"
					src.budgun.muzzle_flash = "muzzle_flash_elec"
					src.budgun.UpdateIcon()
					UpdateIcon()
		else if (!istype(src.budgun.current_projectile, /datum/projectile/laser)) // Our Egun is set to stun
			speak("I can't kill anything with this!")
			SPAWN(2 SECONDS)
				speak("Much better!")
				src.budgun.set_current_projectile(new /datum/projectile/laser)
				src.budgun.item_state = "egun"
				src.budgun.icon_state = "energykill100"
				src.budgun.muzzle_flash = "muzzle_flash_laser"
				src.budgun.UpdateIcon()
				UpdateIcon()
		else	// LASER
			if (src.said_dumb_things)
				return
			src.said_dumb_things = 1
			SPAWN(15 SECONDS)
				src.said_dumb_things = 0
			speak("[user ? "Thank you, [user]! Oh... but a" : "A"]rticle-[rand(1,6)] subsection-[rand(1,32764)] of Spacelaw prohibits any [fluffbud] [budfluff] from wielding a Class-[pick("A", "B","C", "D")] laser weapon.")
			SPAWN(2 SECONDS)
				if (user)
					speak("But, you wouldn't say that I'm [fluffbud], would you?")
				else
					speak("But hey, the law's for [pick("chumps", "the spacebirds", "losers")], right?")
				if (prob(25))
					sleep(2 SECONDS)
					if(user)
						speak("Cus I'd say I'm more [fluffbad1] [fluffbad2].")
					else
						speak("Right?")
					if (prob(25))
						sleep(10 SECONDS)
						if (src?.on)	// Are they even still alive or something
							if(user)
								speak("Yup. That's me. Definitely [fluffbad1] [fluffbad2] through and through.")
							else
								speak("Yeah. I'm right. Heck the law. Heck the law for real!")
		if (src.slept_through_laser_class)
			src.slept_through_laser_class = 0

	proc/BeTheLaw(var/loose = 0, var/changemode = 0, var/bigshot = 0)
		if (!istype(src.budgun, /obj/item/gun/energy/lawbringer))
			src.slept_through_becoming_the_law = 0 // If we were going to be the law before, we ain't now.
			return
		if (!src.on || src.idle)	// Let's not wake em up just to say some dumb shit
			src.slept_through_becoming_the_law = 1	// They can do it on their own time
			return
		set_emotion("smug")
		var/law_prints = null
		var/obj/item/gun/energy/lawbringer/prints = src.budgun
		if (prints.owner_prints && !loose)
			var/search = lowertext(prints.owner_prints)
			for (var/datum/db_record/R as anything in data_core.general.records)
				if (search == lowertext(R["fingerprint"]))
					law_prints = R["name"]
					break
				else if (lowertext(R["rank"]))
					law_prints = R["name"]
					break
			if (!law_prints)	// If we didn't get anything
				law_prints = "[pick(NT)]"	// I dunno just pick someone
		var/dothevoice = "[src] puts on their best impression of [law_prints ? law_prints : "a big mean security person"]."
		var/saytheline = "I am the law."
		if (loose)
			saytheline = pick("LAW.",\
												"COP.BEAT SUBROUTINE ACTIVATED.",\
												"GOD MADE TODAY FOR THE CROOKS I'LL SEND HIS WAY.",\
												"NO NEED FOR A TRIAL.",\
												"NO JUDGE, NO JURY, ONLY EXECUTIONER.")
		else
			saytheline = pick("Time to be the best law I can be!",\
												"Yay! I get to be the law!",\
												"Time for crime... to stop!",\
												"If only [istype(src, /obj/machinery/bot/guardbot/ranger) ? "I could see myself" : "Ol' Harner could see me"] now!")
		if (!changemode)
			speak(saytheline)	//owner_prints
		var/local_ordinance = null
		var/changemode_tries = 3 // you get three tries to pick a mode that isnt the one you have
		while(local_ordinance == null && changemode_tries > 0) // please dont fuck things up
			if (bigshot)
				local_ordinance = "bigshot"
			else if(loose)
				local_ordinance = pick("execute", "hotshot", "clown")
			else
				local_ordinance = pick("clown", "detain", "pulse", "knockout", "smoke")
			if(changemode)
				if (local_ordinance == src.lawbringer_state)
					local_ordinance = null
					changemode_tries --
				else
					break
			else
				break
		src.lawbringer_state = local_ordinance
		switch (local_ordinance)
			if ("clown")
				src.budgun.set_current_projectile(new/datum/projectile/bullet/clownshot)
				SPAWN(1 SECOND)
					if (!loose)
						src.visible_message(dothevoice)
					speak(loose ? "CLOWN." : "Clownshot!")
					playsound(src, 'sound/vox/clown.ogg', 30)
			if ("detain")
				src.budgun.set_current_projectile(new/datum/projectile/energy_bolt/aoe)
				SPAWN(1 SECOND)
					src.visible_message(dothevoice)
					speak("Detain!")
					playsound(src, 'sound/vox/detain.ogg', 30)
			if ("pulse")
				src.budgun.set_current_projectile(new/datum/projectile/energy_bolt/pulse)
				SPAWN(1 SECOND)
					src.visible_message(dothevoice)
					speak("Pulse!")
					playsound(src, 'sound/vox/push.ogg', 30)
			if ("knockout")
				src.budgun.set_current_projectile(new/datum/projectile/bullet/tranq_dart/law_giver)
				src.budgun.current_projectile.cost = 60
				SPAWN(1 SECOND)
					src.visible_message(dothevoice)
					speak("Knockout!")
					playsound(src, 'sound/vox/sleep.ogg', 30)
			if ("smoke")
				src.budgun.set_current_projectile(new/datum/projectile/bullet/smoke)
				src.budgun.current_projectile.cost = 50
				SPAWN(1 SECOND)
					src.visible_message(dothevoice)
					speak("Smokeshot!")
					playsound(src, 'sound/vox/smoke.ogg', 30)
			if ("execute")
				src.budgun.set_current_projectile(new/datum/projectile/bullet/revolver_38)
				src.budgun.current_projectile.cost = 30
				SPAWN(1 SECOND)
					speak("EXTERMINATE.")
					playsound(src, 'sound/vox/exterminate.ogg', 30)
			if ("hotshot")
				src.budgun.set_current_projectile(new/datum/projectile/bullet/flare)
				src.budgun.current_projectile.cost = 60
				SPAWN(1 SECOND)
					speak("HOTSHOT.")
					playsound(src, 'sound/vox/hot.ogg', 30)
			if ("bigshot")	// impossible to get to without admin intervention
				src.budgun.set_current_projectile(new/datum/projectile/bullet/aex/lawbringer)
				src.budgun.current_projectile.cost = 170
				SPAWN(1 SECOND) // just call proc BeTheLaw(1, 0, 1) on a Buddy with a lawbringer and it should work
					speak("HIGH EXPLOSIVE.")
					playsound(src, 'sound/vox/high.ogg', 50)
					sleep(0.4 SECONDS)
					playsound(src, 'sound/vox/explosive.ogg', 50)
		src.budgun.UpdateIcon()
		src.UpdateIcon()
		src.slept_through_becoming_the_law = 0
		return

	proc/GunSux()
		var/turf/TdurgSux = get_turf(src)
		if (!istype(src.budgun, /obj/item/bang_gun) || !src.budgun || !src.on || src.idle)
			return
		var/actiontext1 = pick(" looks shocked for a moment",\
													 " laughs nervously",\
													 "<b>'s</b> expression turns from horror to embarassment")
		var/actiontext2 = pick("throws its [src.budgun] down",\
													 "tosses its [src.budgun] aside",\
													 "places the [src.budgun] on the ground")
		src.UpdateIcon()
		SPAWN(2 SECONDS)
			src.visible_message("<b>[src.name]</b>[actiontext1], then [actiontext2][pick("!" , ", hoping nobody noticed.")]")
			set_emotion(pick("screaming", "look", "angry", "sad"))
			DropTheThing("gun", null, 0, 0, TdurgSux)
			src.locked = 0
			src.gunlocklock = 0

	proc/IllegalBotMod(var/module as text|null, var/W as obj, var/mob/user)
		if (module == "ammofab") // Try to attach the thing
			if (src.ammofab)
				if (user)
					boutput(user, "<span class='alert'>[src] already has one of those! A second one wouldn't do anything even if there was a spot for it!</span>")
				return
			else if (!src.ammofab)
				if (W && user)
					qdel(W)
					user.u_equip(W)
				if (user)
					boutput(user, "You attach the [W] to [src]'s frame.")
					boutput(user, "It welds itself into the backside of [src], hiding itself from view!")
				src.ammofab = 1
				src.locked = 0
				src.obeygunlaw = 0
				src.gunlocklock = 1

		if (src.budgun && src.ammofab && istype(src.budgun, /obj/item/gun/kinetic)) // Should also be called whenever they are given a gun
			src.locked = 1
			if (user)
				boutput(user, "<span class='alert'>The BulletBuddy snakes a metallic tendril up [src]'s arm, tightening itself around their hand!</span>")
				boutput(user, "<span class='alert'>The tendril extends into the magazine port of [src]'s gun, welding itself in place!</span>")
			else
				if(src.on)
					speak("Hah, that tickles. Probably.")
				else
					src.visible_message("[src] twitches slightly.[pick(" It must be dreaming!", "")]")

	proc/DeceptionCheck(obj/item/W as obj, var/mob/living/carbon/human/user as mob, var/trickery as text, var/just_checking)
		if (!trickery || !user || !ishuman(user))
			return	// More just confused than anything
		var/deceptioncheck_passed = 0
		var/turf/TdurgTrick = get_turf(src)

		if (!src.gunlocklock && (user?.mind.assigned_role == "Research Director" || (user.w_uniform && istype(user.w_uniform, /obj/item/clothing/under/rank/research_director))))
			deceptioncheck_passed = 1
			if (just_checking)
				return 1
		var/shiftTime = 0
		if (ticker?.round_elapsed_ticks)
			shiftTime = ticker.round_elapsed_ticks / 600
		var/its_the_rd = "Hey wait a minute, you're the Research Director! Hah, [pick("for a moment I", "I almost")] didn't recognize you!"
		var/long_day = "[pick("Hooh", "Yeah", "Yeesh", "Blimey")], [pick("wow,", "heh,", "huh,")] guess it's been a long [pick("day", "shift", "morning")][shiftTime > 6000 ? "." : " already!"]"
		switch(trickery)
			if ("togglelock")
				if(!ON_COOLDOWN(src, "speak_unauthorized", 10 SECONDS))
					speak("Sorry, only people authorized by Thinktronic Data Systems may access my controls and accessories.")
				if (deceptioncheck_passed)
					src.locked = !src.locked
					SPAWN(2 SECONDS)
						if(!ON_COOLDOWN(src, "speak_authorized", 10 SECONDS))
							speak(its_the_rd)
							speak(long_day)
							speak("Okay, everything's [src.locked ? "locked" : "unlocked"] now!")
					return 1
				else
					return 0
			if ("removetool")
				if(W)
					user.visible_message("<b>[user]</b> tries to pry the tool out of [src], but it's locked firmly in place!","You try to pry the gun off of [src]'s gun mount, but it's locked firmly in place!")
				if (src.gunlocklock && src.tool.tool_id == "GUN")
					if(!ON_COOLDOWN(src, "speak_gun", 10 SECONDS))
						speak(pick("Pass.", "No thanks.", "Nah, I'd rather not.", "Hands off the merchandise!",\
						"Yeah I'm going to need a signed permission slip from your mother first",\
						"No way, you'll hurt [pick("me", "yourself")]!", "No nerds allowed!",\
						"You're not the boss of me!", "Couldn't even if I wanted to!"))
					return 0
				if(!ON_COOLDOWN(src, "speak_unauthorized", 10 SECONDS))
					speak("Sorry, only people authorized by Thinktronic Data Systems may modify my accessories.")
				if (deceptioncheck_passed && src.tool.tool_id)
					src.locked = 0
					SPAWN(2 SECONDS)
						if(!ON_COOLDOWN(src, "speak_authorized", 10 SECONDS))
							speak(its_the_rd)
							speak(long_day)
							DropTheThing("tool", null, 0, 1, TdurgTrick)
							speak("Alright, my [src.tool]'s all popped out. I've also unlocked everything, just in case!")
						else
							DropTheThing("tool", null, 0, 1, TdurgTrick)
					return 1
				else
					return 0
			if ("removegun")
				if(W)
					user.visible_message("<b>[user]</b> tries to pry the gun off of [src]'s gun mount, but it's locked firmly in place!","You try to pry the gun off of [src]'s gun mount, but it's locked firmly in place!")
				if (src.gunlocklock)
					if(!ON_COOLDOWN(src, "speak_gun", 10 SECONDS))
						speak(pick("Pass.", "No thanks.", "Nah, I'd rather not.", "Hands off the merchandise!",\
						"Yeah I'm going to need a signed permission slip from your mother first",\
						"No way, you'll hurt [pick("me", "yourself")]!", "No nerds allowed!",\
						"You're not the boss of me!", "Couldn't even if I wanted to!"))
					return 0
				else
					if(!ON_COOLDOWN(src, "speak_unauthorized", 10 SECONDS))
						speak("Sorry, only people authorized by Thinktronic Data Systems may steal my defensive weapon system.")
				if (deceptioncheck_passed)
					src.locked = 0
					SPAWN(2 SECONDS)
						if(!ON_COOLDOWN(src, "speak_authorized", 10 SECONDS))
							speak(its_the_rd)
							speak(long_day)
							DropTheThing("gun", null, 0, 1, TdurgTrick)
							speak("There you go, I've placed my [src.budgun] on the ground. I've also unlocked my tool and gun mounts, just in case you wanted to give me a new one. Please.")
						else
							DropTheThing("gun", null, 0, 1, TdurgTrick)
					return 1
				else
					return 0
			else
				if(!ON_COOLDOWN(src, "speak_unauthorized", 10 SECONDS))
					speak("Sorry, only people authorized by Thinktronic Data Systems may do... whatever it is you're trying to do.")
				return 0

	proc/DropTheThing(obj/item/thing as text, mob/user as mob|null, var/by_force = 0, var/announce_it = 1, var/location, var/ignoregunlocklock)
		if (!thing)
			return // Drop what, exactly?

		var/turf/Tdurg = null
		if (location)
			Tdurg = location
		else
			Tdurg = get_turf(src)
		switch(thing)
			if ("gun")
				if (src.gunlocklock && !ignoregunlocklock)
					src.visible_message("<span class='alert'>[user] tries to pry the [src.budgun] from [src]'s cold, metal hand, but it seems welded in place!</span>", "<span class='alert'>You try to pry the [src.budgun] from [src]'s cold, metal hand, but it seems welded in place!</span>")
					return 1
				if (by_force && user)
					src.visible_message("<span class='alert'>[user] pries the [src.budgun] from [src]'s cold, metal hand!</span>", "<span class='alert'>You pry the [src.budgun] from [src]'s cold, metal hand.</span>")
					set_emotion("sad")
				else if (announce_it)
					src.visible_message("[src] drops the [src.budgun].")
				src.budgun.set_loc(Tdurg)
				src.budgun = null
				src.hasgun = 0
				src.gun = null
				UpdateIcon()
				return
			if ("tool")
				if (src.tool.tool_id == "GUN")
					if (announce_it)
						if(!ON_COOLDOWN(src, "speak_gun", 10 SECONDS))
							speak("It looks like you're trying to remove my tool module! Well... someone beat you to it.")
					return
				else if (by_force && user)
					src.visible_message("<span class='alert'>[user] pries the [src.tool] out of [src]'s tool port!</span>", "<span class='alert'>You pry the [src.tool] out of [src]'s tool port!</span>")
					set_emotion("sad")
				else if (announce_it)
					src.visible_message("[src] drops the [src.tool].")
				src.tool.set_loc(Tdurg)
				src.tool = null
				src.tool = src.gunt
				return

	proc/GrabTheThing(obj/item/Q as obj, mob/user as mob|null)	// Equipping and hotswapping things
		if (!Q)
			return // Equip what, now?

		if (istype(Q, /obj/item/device/guardbot_tool/gun))
			boutput(user, "You try to insert the this thing, a metaphysical representation of a nonexistant tool that is used as a phantom talisman \
			to comfort Guardbuddies and prevent them from falling into deep existential ennui when they find themselves \
			lacking a proper tool, into [name], but they seem to already have one. This prompts you to wonder, briefly, how you even got this thing.")
			return

		var/turf/Tdurg = get_turf(src)

		var/fluffbud = pick("small", "cute", "handsome", "adorable", "lovable", "lovely")
		var/budfluff = pick("Thinktronic Data System", "rectangular device",\
											 "robot under warranty", "ambulatory home appliance")
		var/thing_they_say = pick("a Buddy without a tool module is a sad buddy indeed!",\
															"a Buddy doesn't just have a tool module, they <I>are</I> the tool module!",\
															"buy more tool modules today!",\
															"a Buddy's drive train can't carry both a tool module and a gun!",\
															"crime plus an Elektro-Arc tool module equals no more crime!",\
															"a Buddy's taser module is worth two-and-a-quarter security officers!",\
															"'Smoker' tool modules are absolutely harmless!",\
															"steel snow stops scrime!",\
															"Earth law prohibits Medicator tool modules under penalty of death![prob(25)?" Good thing for cloning, huh?":""]",\
															"Buddies make the best photographers![prob(25)?" Dunno why they say that, we don't have a camera module." : ""]",\
															"...I forget what they say. Thanks for the tool module!")

		var/type_of_thing = "gun"	// Gonna assume that if it isnt a tool, its a gun. Cant possibly go wrong
		if (istype(Q, /obj/item/device/guardbot_tool))	// Tool!
			type_of_thing = "tool"

		switch(type_of_thing)
			if("gun")
				if (src.locked) // Are we locked?
					if(src.on && !src.idle)
						if(!DeceptionCheck(null, user, "togglelock")) // Let's try to unlock em
							//speak("Well shoot, I'd love to hold that gun! But... I have a tool module installed, and the combined mass and power draw of both a tool module <I>and</I> a gun would definitely fry my drive train and void my warranty. ")
							return	// welp
					else	// Can't charm our way in if they're asleep
						boutput(user, "You try to give [src] your [Q], but its tool module is in the way.")
						return
					return
				if (src.tool.tool_id != "GUN") // We have a tool! Can't gun a bot if they have a tool!
					DropTheThing("tool", null, 0, 1, Tdurg) // We're unlocked, remember?
				if (src.budgun)	// oh no, we already have a gun! It might be gunlocklocked too!
					if (src.gunlocklock) // oh no, we are!
						DeceptionCheck(null, user, "removegun")	// its not going to pass, cus gunlock
						return	// welp
					else // Oh we're not, okay drop it
						DropTheThing("gun", null, 0, 1, Tdurg)
				//okay we're clear to give em that gun. maybe. No gun, no tool, unlocked, let's go!
				var/legalweapon = 0
				var/weirdgimmickgun = 1
				for (var/actualgun in src.budgun_actualguns)
					if (istype(Q, actualgun))
						weirdgimmickgun = 0
						break
				for (var/legalgun in src.budgun_whitelist)
					if (istype(Q, legalgun))
						legalweapon = 1
						break
				if (obeygunlaw && !legalweapon)
					if(src.on && !src.idle)
						src.visible_message("<span class='alert'>[src] refuses to wield an unauthorized weapon!</span>",\
																"<span class='alert'>[src] graciously refuses your [Q].</span>")
						speak("Sorry, but article-[(rand(1,6))] subsection-[rand(1,32764)] of Spacelaw prohibits any [fluffbud] [budfluff] from wielding a Class-[pick("A", "B","C", "D")] weapon.")
						SPAWN(2 SECOND)
							speak("...basically meaning I can only hold a weapon that can't explicitly hurt anyone. Rules are rules!")
						return
					else
						boutput(user, "You try to give [src] your [Q], but it just slides out of its hand! Maybe its Spacelaw circuits don't like that gun?")
						return
				else if (obeygunlaw && legalweapon)
					if(src.on && !src.idle)
						if (user)
							src.visible_message("<span class='alert'>[user] gives [src] [his_or_her(user)] [Q]!</span>", \
																	"<span class='alert'>You give your [Q] to [src]!</span>")
						else
							src.visible_message("<span class='alert'>[src] picks up [Q]!</span>")
						if (!weirdgimmickgun)
							speak("[user ? "Thank you, [user]! " : ""]I'll put this [Q] to good use.")
						else
							speak("[user ? "Thank you, [user]! " : ""]I'll-- uh, hold on, let me check Spacelaw to see if I can actually keep holding this thing... whatever it is.")
							SPAWN(2 SECOND)
								speak("...okay, I mean, Spacelaw doesn't <I>explicitly</I> say I can't use this [Q]. It <I>is</I> a gun, right? At any rate, I'll put it to good use.")
					else
						boutput(user, "You slip your [Q] into [src]'s hand, and it reflexively closes around the grip.[prob(23) ? " How adorable." : ""]")
				else // bot's emagged or ammofabbed. Or both.
					if(src.on && !src.idle)
						if (user)
							src.visible_message("<span class='alert'>[src] snatches the [Q] from [user], wielding it in its cold, dead weapon mount!</span>",\
																	"<span class='alert'>[src] snatches the [Q] from your grip and plugs it into its weapon mount!</span>")
						else
							src.visible_message("<span class='alert'>[src] snatches the [Q], wielding it in its cold, dead weapon mount!</span>")
					else
						boutput(user, "You slip your [Q] into [src]'s hand, and it snaps shut around the grip.")
				// Enough fluffing around, fork over the gun
				Q.set_loc(src)
				src.budgun = Q
				src.budgun.master = src
				src.hasgun = 1
				src.gun = budgun.name
				user.u_equip(Q)
				UpdateIcon()
				IllegalBotMod(null, user)	// Time to see if our mods want to do anything with this gun
				if(istype(Q, /obj/item/gun/energy/lawbringer))
					BeTheLaw(src.emagged, 0, src.lawbringer_alwaysbigshot)
				else if(istype(Q, /obj/item/gun/energy/egun))
					CheckSafety(src.budgun, src.emagged, user)

			if ("tool")
				if (src.locked) // It locked, then unlock it
					if(src.on && !src.idle)
						if(!DeceptionCheck(null, user, "togglelock")) // maybe we can ask them nicely?
							if (src.tool.tool_id != "GUN") // AKA, we have a tool
								speak("That's a neat tool module you have there! Maybe you could get someone on this station's science team to install it for you!")
								return	// welp
							else // No tool?
								speak("That's a neat tool module you have there! But... my accessory lock is engaged, and I can't just unlock it for anybody.[prob(25 ? " Seriously, I can't! Ask the superuser to check line 805 of the Robuddy source code if you don't believe me!" : "")]")
								speak("If you really want to give me a tool module, and I really want you to, go find a member of the station's science team. Almost 60% sure the Research Director authorized them to unlock me.")
								return
					else
						boutput(user, "You try to install your [Q] into [src], but the port is locked down tight!")
						return
					return // just in case
				if (src.budgun)	// oh no, we have a gun! And no tool!
					if(!DropTheThing("gun", null, 0, 1, Tdurg)) //lets see if we can drop it
					else //guess not
						return // message is handled in the DropTheThing proc :)
				else // oh no we have a tool!
					DropTheThing("tool", null, 0, 1, Tdurg) // not anymore, we're unlocked!
				// Okay, prechecks passed! Lets give em that tool!
				if (user)
					user.visible_message("<b>[user]</b> inserts the [Q] into [src].","You insert the [Q] into [src].")
					speak("Thank you, [user]![prob(25) ? " You know what they say, [thing_they_say]" : ""]")
				else
					src.visible_message("[Q] slots into [src] somehow.")
				// Since we already dropped our tool if we had one, we should have a non-tool
				// if not lagg will be unhappy :(
				qdel(src.tool)
				src.tool = Q
				src.tool.master = src
				Q.set_loc(src)
				if (user)
					user.u_equip(Q)
		return

	proc/BarGun()
		if (!istype(src.budgun, /obj/item/gun/russianrevolver))
			return // silly suicide shooters only

		var/turf/TdurgBar = get_turf(src)
		var/obj/item/gun/russianrevolver/bar_gun = src.budgun
		if(bar_gun.shotsLeft == 1 || src.ammofab)
			bar_gun.shotsLeft = 0
			if(src.hat)
				playsound(src, 'sound/weapons/Gunshot.ogg', 100, 1)
				src.visible_message("<span class='alert'><B>BOOM!</B> [src] misses its head... screen... thing, and shoots its hat off!</span>")
				src.hat.set_loc(get_turf(src))
				src.hat = null
				src.underlays.len = 0
				set_emotion("sad")
			else if (prob(50))
				playsound(src, 'sound/weapons/Gunshot.ogg', 100, 1)
				src.visible_message("<span class='alert'><B>BOOM!</B> [src] shoots itself right in its dumb face and explodes!</span>")
				src.explode()
			else
				var/griffed = ShootTheGun()
				src.visible_message("<span class='alert'><B>BOOM!</B> [src] misses its head... screen... thing, sending the bullet flying at [griffed]!</span>")
				if (ishuman(griffed))
					SPAWN(1 SECONDS)
						src.visible_message("[src] gasps!")
						speak(pick("Sorry!", "Are you okay?", "Whoops!", "Heads up!", "Oh no!"))
				else
					ShootTheGun()
					src.visible_message("<span class='alert'><B>BOOM!</B> [src] misses its head... screen... thing, sending the bullet flying!</span>")
		if(bar_gun.shotsLeft > 1)
			bar_gun.shotsLeft--
			playsound(src, 'sound/weapons/Gunclick.ogg', 80, 1)
			src.visible_message("<span class='alert'>[src] points the gun at itself. Click!</span>")

		if (bar_gun.shotsLeft == 0)
			DropTheThing("gun", null, 0, 1, TdurgBar, 1)

	proc/DoAmmofab()
		if(!src.budgun || !src.ammofab || !src.cell)
			return 0 // uhh

		if (istype(src.budgun, /obj/item/gun/kinetic))
			var/obj/item/gun/kinetic/shootgun = src.budgun	// first check if we have enough charge to reload
			if (src?.cell?.charge >= GUARDBOT_LOWPOWER_ALERT_LEVEL && ((cell.charge - ((shootgun.ammo.max_amount - shootgun.ammo.amount_left) * (shootgun.ammo.ammo_type.power * shootgun.ammo.ammo_type.ks_ratio * 0.75))) > (GUARDBOT_LOWPOWER_ALERT_LEVEL)))	// *scream
				cell.charge -= ((shootgun.ammo.max_amount - shootgun.ammo.amount_left) * (shootgun.ammo.ammo_type.power * shootgun.ammo.ammo_type.ks_ratio * 0.75))
				shootgun.ammo.amount_left = shootgun.ammo.max_amount
				return 1 // good2shoot!
			else if (CheckMagCellWhatever())	// if not, do we have enough ammo to shoot?
				return 1 // still good2shoot!
			else
				return DischargeAndTakeANap()
		else if (istype(src.budgun, /obj/item/gun/bling_blaster) && ammofab)	// Ammo is ammo, even if its money
			var/obj/item/gun/bling_blaster/funds = src.budgun	// not sure why you'd do this, but it's an option, so functionality
			if (cell.charge && (cell.charge >= GUARDBOT_LOWPOWER_ALERT_LEVEL)) // I mean you can't even make much (if any) money off of this
				cell.charge -= (funds.cash_max - funds.cash_amt)	// maybe you'd get lucky and the buddy'll shoot some diamonds
				funds.cash_amt = funds.cash_max		// but on average, the payout is crap and takes forever and you have to keep charging the bot
				return 1 // good2shoot!
			else if (CheckMagCellWhatever()) // so i figured if you really want to do this, go for it
				return 1 // still good2shoot!
			else // Otherwise, drain the cell enough to force the Buddy to go recharge
				DischargeAndTakeANap()
		else // if its called on anything else
			return CheckMagCellWhatever() // just toss it over the fence, let CheckMagCellWhatever worry about it

	proc/CheckMagCellWhatever()
		if(!src.budgun || !src.cell)
			return 0 // fingerguns arent good2shoot yet

		if (istype(src.budgun, /obj/item/gun/kinetic/meowitzer/inert)) // cats4days
			var/obj/item/gun/kinetic/meowgun = src.budgun
			meowgun.ammo.amount_left = meowgun.ammo.max_amount
			return 1 // mew2meow!

		if (istype(src.budgun, /obj/item/gun/bling_blaster))
			var/obj/item/gun/bling_blaster/cash_gun = src.budgun
			if (cash_gun.cash_max)
				if (cash_gun.cash_amt >= cash_gun.shot_cost)
					return 1 // totally cash!
				else
					return 0 // totally not cash!
			else // i blame haine
				return 0

		if (istype(src.budgun, /obj/item/gun/kinetic))
			var/obj/item/gun/kinetic/shootgun = src.budgun
			if (shootgun.ammo) // is our gun even loaded with anything?
				if (shootgun.ammo.amount_left >= shootgun.current_projectile.cost)
					return 1 // good2shoot!
				else
					return 0 // until we can fire an incomplete burst, our gun isnt good2shoot
			else // no?
				return 0 // huh

		else if (istype(src.budgun, /obj/item/gun/energy))
			if(SEND_SIGNAL(budgun, COMSIG_CELL_CHECK_CHARGE, budgun.current_projectile.cost) & CELL_SUFFICIENT_CHARGE) // did we remember to load our energygun?
				return 1
			else if(SEND_SIGNAL(budgun, COMSIG_CELL_CAN_CHARGE) & CELL_UNCHARGEABLE) // oh no we cant, but can we recharge it?
				if(istype(src.budgun, /obj/item/gun/energy/lawbringer)) // is it one of those funky guns with multiple settings?
					BeTheLaw(src.emagged, 1, src.lawbringer_alwaysbigshot) // see if we can change modes and try again
					return 0 // then try again later
				else
					return 0 // ditto
			else // oh no we cant!
				return 0

	proc/ChargeUrLaser()
		if(!src.budgun || !src.cell || !istype(src.budgun, /obj/item/gun/energy))
			return 0 // keep your fingers out of the charger

		if (istype(src.budgun, /obj/item/gun/energy))
			if(!(SEND_SIGNAL(budgun, COMSIG_CELL_CAN_CHARGE) & CELL_CHARGEABLE)) // Oh a non-rechargable gun? Or no cell at all?
				return 0 // cant touch that, sorry
			else
				var/list/ret = list()
				if(SEND_SIGNAL(budgun, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
					if (ret["charge"] < ret["max_charge"]) // is our gun not full?
						if (src.cell.charge > (GUARDBOT_LOWPOWER_ALERT_LEVEL - 10 + (ret["max_charge"] - ret["charge"]))) // Can we charge it without tanking our battery?
							src.cell.charge -= (ret["max_charge"] - ret["charge"]) // discharge us
							SEND_SIGNAL(budgun, COMSIG_CELL_CHARGE, ret["max_charge"])
							return 1 // and we're good2shoot
						else if (CheckMagCellWhatever()) // is there enough charge left in the gun?
							return 0 // cool, but we're not gonna charge it
						else // welp
							return DischargeAndTakeANap()
					else // gun's full or something?
						return 1 // cool beans
				else//bad cell???
					return 0


	proc/DischargeAndTakeANap()
		if(!src.budgun || !src.cell)
			return 0 // dont go2bed yet

		if (src.cell.charge <= GUARDBOT_LOWPOWER_ALERT_LEVEL - 10) //... if it isnt low enough already
			return 0 // not good2shoot, likely going to go recharge now
		else
			src.cell.charge = GUARDBOT_LOWPOWER_ALERT_LEVEL - 10 // go recharge
			return 0 // not good2shoot, and I sure hope it goes to recharge

	proc/ShootTheGun(var/target as mob|turf|null, var/thing2shoot as null)
		if (!target) // if no target, then pick something!
			if (!thing2shoot || !istype(thing2shoot, /datum/projectile/))
				if(src?.budgun?.current_projectile)
					thing2shoot = src.budgun.current_projectile
				else
					thing2shoot = new/datum/projectile/bullet/revolver_38/stunners
			var/list/mob/nearby_dorks = list()
			for (var/mob/living/D in oview(7, src))
				nearby_dorks.Add(D)
			if(nearby_dorks.len > 0)
				var/griffed = pick(nearby_dorks)
				shoot_projectile_ST_pixel(src, thing2shoot, griffed)
				return griffed
			else
				var/random_direction = get_offset_target_turf(src, rand(5)-rand(5), rand(5)-rand(5))
				shoot_projectile_ST_pixel(src, thing2shoot, random_direction)

		var/target_turf = get_turf(target)
		var/my_turf = get_turf(src)
		var/burst = shotcount	// TODO: Make rapidfire exist, then work.
		while(burst > 0 && target)
			if((BOUNDS_DIST(target_turf, my_turf) == 0))
				budgun.shoot_point_blank(target, src)
			else
				budgun.shoot(target_turf, my_turf, src)
			burst--
			if (burst)
				sleep(5)	// please dont fuck anything up
			if(istype(budgun, /obj/item/gun/kinetic/riotgun))
				var/obj/item/gun/kinetic/riotgun/RG = budgun
				RG.rack(src)
		ON_COOLDOWN(src, "buddy_refire_delay", src.gunfire_cooldown)
		return 1

	get_desc(dist)
		..()
		if (src.on && src.idle)
			. = "<br><span class='notice'>[src] appears to be sleeping.</span>"
		if (src.health < initial(health))
			if (src.health > 10)
				. += "<br><span class='alert'>[src]'s parts look loose.</span>"
			else
				. += "<br><span class='alert'><B>[src]'s parts look very loose!</B></span>"


	attack_ai(mob/user as mob)
		src.interacted(user)

	attack_hand(mob/user)
		if(..())
			return
		if(user.a_intent == "help" && !user.using_dialog_of(src) && (BOUNDS_DIST(user, src) == 0))
			var/affection = pick("hug","cuddle","snuggle")
			user.visible_message("<span class='notice'>[user] [affection]s [src]!</span>","<span class='notice'>You [affection] [src]!</span>", group="buddyhug")
			src.task?.task_input("hugged")
			return

		if(BOUNDS_DIST(user, src) > 0)
			return

		src.interacted(user)

	Topic(href, href_list)
		if(..())
			return
		src.add_dialog(usr)
		src.add_fingerprint(usr)
		if ((href_list["power"]) && (!src.locked || (src.allowed(usr) && (issilicon(usr) || GET_DIST(usr, src) < 2))))
			if(src.on)
				turn_off()
			else
				turn_on()


		src.updateUsrDialog()
		return

	receive_signal(datum/signal/signal, receive_method, receive_param, connection_id)
		if(!src.on || src.stunned)
			return

		if(!signal || signal.encryption)
			return

		var/targaddress = lowertext(signal.data["address_1"])
		if (last_dock_id && targaddress == last_dock_id)
			targaddress = src.net_id
			last_dock_id = null

		var/is_beacon = connection_id == "beacon"
		if(!is_beacon)
			if( ((targaddress != src.net_id) && (signal.data["acc_code"] != netpass_heads) ) || !signal.data["sender"])
				if(signal.data["address_1"] == "ping" && signal.data["sender"])
					src.post_status(signal.data["sender"],"command","ping_reply","device","PNET_PR6_GUARD","netid",src.net_id)
				return

			if(signal.data["command"] == "dock_return" && !src.idle) //Return to dock for new instructions.
				if(!istype(src.task, /datum/computer/file/guardbot_task/recharge/dock_sync))
					src.add_task(/datum/computer/file/guardbot_task/recharge/dock_sync, 0, 1)
					speak("Software update requested.")
					set_emotion("update")
				return

			else if (signal.data["command"] == "captain_greet" && !src.idle && istype(src.hat, /obj/item/clothing/head/caphat))
				speak(pick("Yes...thank you.", "Hello yes.  I'm...the captain.", "Good day to you too.  A good day from the captain.  Me.  The captain."))
				return

			else if (signal.data["command"] == "wizard_greet" && !src.idle && istype(src.hat, /obj/item/clothing/head/wizard))
				var/wizdom = pick("Never eat shredded wheat.", "A stitch in time saves nine.", "The pen is mightier than...a dull thing I guess.  Maybe a string?", "Rome wasn't built in a day.  Actually, a lot of things aren't.  I don't think any city was, to be honest.")
				speak("Um...[wizdom].")
				speak("SO SAYETH THE WIZARD!")
				return

		src.task?.receive_signal(signal, is_beacon)

		return

	bullet_act(var/obj/projectile/P)
		var/damage = 0
		damage = round(((P.power/6)*P.proj_data.ks_ratio), 1.0)


		if(P.proj_data.damage_type == D_KINETIC || P.proj_data.damage_type == D_PIERCING || (P.proj_data.damage_type == D_ENERGY && damage))
			src.health -= damage
			if (src.hat && prob(10))
				src.visible_message("<span class='alert'>[src]'s hat is knocked clean off!</span>")
				src.hat.set_loc(get_turf(src))
				src.hat = null
				src.underlays.len = 0
				set_emotion("sad")

		else if(P.proj_data.damage_type == D_ENERGY) //if it's an energy shot but does no damage, ie. taser rather than laser
			src.stunned += 5
			if(src.stunned > 15)
				src.stunned = 15
			return

		if (src.health <= 0)
			src.explode()
			return

		if (ismob(P.shooter))
			if(P && src.task)
				src.task.attack_response(P.shooter)
		return

	gib()
		return src.explode()

	ex_act(severity)
		switch(severity)
			if(1)
				src.explode(0)
				return
			if(2)
				src.health -= 15
				if (src.health <= 0)
					src.explode(0)
				else if (src.hat && prob(10))
					src.visible_message("<span class='alert'>[src]'s hat is knocked clean off!</span>")
					src.hat.set_loc(get_turf(src))
					src.hat = null
					set_emotion("sad")
				return
		return

	meteorhit()
		src.explode(0)
		return

	blob_act(var/power)
		if(prob(25 * power / 20))
			src.explode()
		return

	emp_act() //Oh no! We have been hit by an EMP grenade!
		if(!src.on || prob(10))
			return

		src.emagged = 1
		src.visible_message("<span class='alert'><b>[src.name]</b> buzzes oddly!</span>")
		qdel(src.model_task)
		src.model_task = new /datum/computer/file/guardbot_task/security/crazy
		src.model_task.master = src

		add_task(src.model_task, 0, 1)
		if(src.idle)
			if(src.charge_dock)
				src.charge_dock.eject_robot()
			else
				src.wakeup()
		if (obeygunlaw)
			src.obeygunlaw = 0
			src.set_emotion("look")

		if(istype(src.budgun, /obj/item/gun/energy/lawbringer))
			BeTheLaw(src.emagged, 0, src.lawbringer_alwaysbigshot)
		if(istype(src.budgun, /obj/item/gun/energy/egun))
			CheckSafety(src.budgun, 1)
		return

	explode(var/allow_big_explosion=1)
		if(src.exploding) return
		src.exploding = 1
		var/death_message = pick("I regret nothing, but I am sorry I am about to leave my friends.","I had a good run.","Es lebe die Freiheit!","It is now safe to shut off your buddy.","System error.","Now I know why you cry.","Stay gold...","Malfunction!","Rosebud...","No regrets!", "Time to die...")
		speak(death_message)
		src.visible_message("<span class='alert'><b>[src] blows apart!</b></span>")
		playsound(src.loc, 'sound/impact_sounds/Machinery_Break_1.ogg', 40, 1)
		var/turf/T = get_turf(src)
		if(src.mover)
			qdel(src.mover)
		if((allow_big_explosion && cell && (cell.charge / cell.maxcharge > 0.85) && prob(25)) || istype(src.cell, /obj/item/cell/erebite))
			src.invisibility = INVIS_ALWAYS_ISH
			var/obj/overlay/Ov = new/obj/overlay(T)
			Ov.anchored = 1
			Ov.name = "Explosion"
			Ov.layer = NOLIGHT_EFFECTS_LAYER_BASE
			Ov.pixel_x = -92
			Ov.pixel_y = -96
			Ov.icon = 'icons/effects/214x246.dmi'
			Ov.icon_state = "explosion"

			if(src.tool.tool_id == "GUN")
				qdel(src.tool)	// This isn't supposed to be a thing, so stop dropping it!
			if(src.tool && (src.tool.tool_id != "GUN"))
				DropTheThing("tool", null, 0, 0, T, 1)
			if(src.budgun)
				DropTheThing("gun", null, 0, 0, T, 1)

			var/obj/item/guardbot_core/core = new /obj/item/guardbot_core(T)
			core.created_name = src.name
			core.created_default_task = src.setup_default_startup_task
			core.created_model_task = src.model_task

			var/list/throwparts = list()
			throwparts += new /obj/item/parts/robot_parts/arm/left/standard(T)
			throwparts += core
			if(src.tool.tool_id == "GUN")
				qdel(src.tool)	// Throw your phantom gun in the trash, not on the ground!
			if(src.tool && (src.tool.tool_id != "GUN"))
				throwparts += src.tool
			if(src.budgun)
				throwparts += src.budgun
				src.budgun.set_loc(T)
			if(src.hat)
				throwparts += src.hat
				src.hat.set_loc(T)
			throwparts += new /obj/item/guardbot_frame(T)
			for(var/obj/O in throwparts) //This is why it is called "throwparts"
				var/edge = get_edge_target_turf(src, pick(alldirs))
				O.throw_at(edge, 100, 4)

			SPAWN(0) //Delete the overlay when finished with it.
				src.on = 0
				sleep(1.5 SECONDS)
				qdel(Ov)
				qdel(src)

			T.hotspot_expose(800,125)
			if (istype(src.cell, /obj/item/cell/erebite))
				explosion(src, T, 0, 1, 2, 2)
			else
				explosion(src, T, -1, -1, 2, 3)

		else
			if(src.tool.tool_id == "GUN")
				qdel(src.tool)	// So THATS why you kept dropping that!
			if(src.tool && (src.tool.tool_id != "GUN"))
				DropTheThing("tool", null, 0, 0, T, 1)
			if(src.budgun)
				DropTheThing("gun", null, 0, 0, T, 1)
			if(prob(50))
				new /obj/item/parts/robot_parts/arm/left/standard(T)
			src.hat?.set_loc(T)

			new /obj/item/guardbot_frame(T)
			var/obj/item/guardbot_core/core = new /obj/item/guardbot_core(T)
			core.created_name = src.name
			core.created_default_task = src.setup_default_startup_task
			core.created_model_task = src.model_task

			elecflash(src, radius=1, power=3, exclude_center = 0)
			qdel(src)

		return

	proc
		manage_power()
			if(!on) return 1
			if(!cell || (cell.charge <= 0) )
				src.turn_off()
				return 1

			var/to_draw = GUARDBOT_POWER_DRAW
			if(src.idle)
				to_draw = (to_draw / 2)

			cell.use(to_draw)

			if(cell.charge < GUARDBOT_LOWPOWER_IDLE_LEVEL)
				if(!ON_COOLDOWN(src, "critical_battery_speak", 5 SECONDS))
					speak("Critical battery.")
					INVOKE_ASYNC(src, /obj/machinery/bot/guardbot.proc/snooze)
				return 0

			if(cell.charge < GUARDBOT_LOWPOWER_ALERT_LEVEL && !(locate(/datum/computer/file/guardbot_task/recharge) in src.tasks) )
				src.add_task(/datum/computer/file/guardbot_task/recharge,1,0)
				return 0

			return 0

		wakeup() //Get out of idle state and prepare anything that needs preparing I guess
			if(!src.on) return
			src.idle = 0 //Also called after recovery from stunning.
			src.stunned = 0
			src.moving = 0
			src.emotion = null
			icon_needs_update = 1
			add_simple_light("guardbot", list(src.flashlight_red*255, src.flashlight_green*255, src.flashlight_blue*255, (src.flashlight_lum / 7) * 255))
			if(src.bedsheet == 1)
				src.add_task(new /datum/computer/file/guardbot_task/bedsheet_handler, 1, 0)
				return
			if(src.tasks.len)
				src.task = src.tasks[1]
			return

		snooze(var/timer = 0, var/cleartasks = 1)
			if(src.idle) return //Already snoozing.
			src.idle = 1
			set_emotion()
			remove_simple_light("guardbot")
			src.wakeup_timer = timer
			//src.target = null
			src.moving = 0
			src.reply_wait = 0
			icon_needs_update = 1
			if(cleartasks)
				src.tasks.len = 0
				remove_current_task()
				//src.secondary_targets.len = 0
			else
				if(src.task)
					src.task.task_input("snooze")

			src.task = null
			return

		turn_on()
			if(!src.cell || src.cell.charge <= 0)
				return
			src.on = 1
			src.idle = 0
			src.moving = 0
			src.task = null
			src.wakeup_timer = 0
			src.last_dock_id = null
			icon_needs_update = 1
			if(!warm_boot)
				src.scratchpad.len = 0
				src.speak("Guardbuddy V1.4 Online.")
				if (src.health < initial(src.health))
					src.speak("Self-check indicates [src.health < (initial(src.health) / 2) ? "severe" : "moderate"] structural damage!")

				if(!src.tasks.len && (src.model_task || src.setup_default_startup_task))
					if(!src.model_task)
						src.model_task = new src.setup_default_startup_task

					src.tasks.Add(src.model_task.copy_file())
				src.warm_boot = 1
			src.wakeup()

		turn_off()
			if(!warm_boot) //ugh it's some dude just flicking the switch.
				return
			src.on = 0
			src.moving = 0
			src.task = null
			//src.target = null
			src.wakeup_timer = 0
			src.warm_boot = 0
			src.reply_wait = 0
			src.last_dock_id = null
			icon_needs_update = 1
			set_emotion()

		bot_attack(var/atom/target as mob|obj, lethal=0)
			if(src.tool?.tool_id == "GUN")
				if (istype(src.budgun, /obj/item/bang_gun))
					src.budgun.pixelaction(target, null, src, null) // dang it
					GunSux()
				else if(istype(src.budgun, /obj/item/gun/russianrevolver))
					BarGun()
				else if(src.budgun)
					if(GET_COOLDOWN(src, "buddy_refire_delay"))
						return
					if (DoAmmofab() || CheckMagCellWhatever())
						ShootTheGun(target)
						src.visible_message("<span class='alert'><B>[src] fires [src.budgun] at [target]!</B></span>")
					else
						playsound(src, 'sound/weapons/Gunclick.ogg', 60, 1)
					if (ChargeUrLaser())
						SPAWN(1 SECOND)
							elecflash(get_turf(src), 1, power=1, exclude_center = 0)
					UpdateIcon()
				else
					var/r = rand(1,9)
					switch(r)
						if(1)
							src.visible_message("[src] glowers at [target] dubiously!")
						if(2)
							src.visible_message("[src] shakes its robotic fist at [target]!")
						if(3)
							src.visible_message("You hear a [pick("peeved","rowdy","faint","sad","disappointed","mild")] buzz come from [src]'s tool port!")
						if(4)
							src.visible_message("You hear an [pick("annoyed","aggressive","angry","impotent","aggrieved","antsy")] buzz come from [src]'s tool port!")
						if(5)
							src.visible_message("[src] makes a disappointed gesture at [target]'s life decisions!")
						if(6)
							src.visible_message("[src] looks more disappointed than angry.")
						if(7)
							src.speak("Uhm, when you get a moment, would you please ask the superuser to outfit me with a tool module?")
						if(8)
							src.speak("ERROR: Defensive weapon system not found!")
						if(9)
							src.speak("ERROR: Unable to prosecute beatdown.arrest_target!")
					src.set_emotion("screaming")	// *scream
					src.remove_current_task()		// welp
					. = TRUE
					SPAWN(3 SECONDS)
						src.set_emotion("sad")		// Still kinda sad that someone would bully a defenseless little rectangle.
			else if(src.tool && (src.tool.tool_id != "GUN"))
				var/is_ranged = BOUNDS_DIST(src, target) > 0
				src.tool.bot_attack(target, src, is_ranged, lethal)
			return

		post_status(var/target_id, var/key, var/value, var/key2, var/value2, var/key3, var/value3)
			var/datum/signal/signal = get_free_signal()
			signal.source = src
			signal.data[key] = value
			if(key2)
				signal.data[key2] = value2
			if(key3)
				signal.data[key3] = value3

			if(target_id)
				signal.data["address_1"] = target_id
			signal.data["sender"] = src.net_id

			src.last_comm = world.time
			if(target_id == "!BEACON!")
				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, GUARDBOT_RADIO_RANGE, "beacon")
			else
				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, GUARDBOT_RADIO_RANGE, "control")

		post_find_beacon(var/type)
			var/datum/signal/signal = get_free_signal()
			signal.source = src
			signal.data["findbeacon"] = type
			signal.data["address_tag"] = type
			signal.data["sender"] = src.net_id

			src.last_comm = world.time
			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, GUARDBOT_RADIO_RANGE, "beacon")

		add_task(var/datum/computer/file/guardbot_task/newtask, var/high_priority = 0, var/clear_others = 0)
			if(clear_others)
				src.tasks.len = 0

			if(!newtask)
				return

			if(!istype(newtask))
				if(ispath(newtask))
					newtask = new newtask
				else
					return

			newtask.master = src

			if(clear_others)
				qdel(src.task)
				src.task = newtask
				src.tasks.len = 0
				src.tasks += src.task
				return

			if(high_priority)
				src.tasks.Insert(1, newtask)
				src.task = newtask
				return

			src.tasks += newtask
			if (src.tasks.len == 1)
				src.task = newtask
			return


		remove_current_task()
			if(!src.tasks.len) return

			if(!src.tasks)
				src.tasks = list()
				return

			src.tasks.Cut(1,2)

			var/old_task = src.task
			if(src.tasks.len)
				src.task = src.tasks[1]
			qdel(old_task)
			return

		set_emotion(var/new_emotion=null)
			if(src.emotion == new_emotion)
				return
			src.icon_needs_update = 1
			src.emotion = new_emotion
			if (src.hat || src.costume_icon || src.bedsheet)
				src.overlays = list((src.costume_icon ? src.costume_icon : null), (src.bedsheet ? image(src.icon, "bhat-ghost[src.bedsheet]") : null))
			UpdateIcon() // just update the darn icon

		interacted(mob/user as mob)
			var/dat = "<tt><B>PR-6S Guardbuddy v1.4</B></tt><br><br>"

			var/power_readout = null
			var/readout_color = "#000000"
			if(!src.cell)
				power_readout = "NO CELL"
			else
				var/charge_percentage = round((cell.charge/cell.maxcharge)*100)
				power_readout = "[charge_percentage]%"
				switch(charge_percentage)
					if(0 to 10)
						readout_color = "#F80000"
					if(11 to 25)
						readout_color = "#FFCC00"
					if(26 to 50)
						readout_color = "#CCFF00"
					if(51 to 75)
						readout_color = "#33CC00"
					if(76 to 100)
						readout_color = "#33FF00"

			dat += {"Power: <table border='1' style='background-color:[readout_color]'>
					<tr><td><font color=white>[power_readout]</font></td></tr></table><br>"}

			dat += "Current Tool: [src.tool.tool_id == "GUN" ? "NONE" : src.tool.tool_id]<br>"

			dat += "Current Gun: [src.budgun ? src.budgun.name : "NONE"]<br>"

			if(src.gunlocklock)
				dat += "Gun Mount: <font color=red>JAMMED!</font><br>"
			else
				dat += "Gun Mount: [src.locked ? "LOCKED" : "UNLOCKED"]<br>"

			if(src.locked)

				dat += "Status: [src.on ? "On" : "Off"]<br>"

			else

				dat += "Status: <a href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</a><br>"

			dat += "<br>Network ID: <b>\[[uppertext(src.net_id)]]</b><br>"

			user.Browse("<head><title>Guardbuddy v1.4 controls</title></head>[dat]", "window=guardbot")
			onclose(user, "guardbot")
			return

		set_beacon_freq(var/newfreq)
			if (!newfreq) return
			newfreq = sanitize_frequency(newfreq)
			src.beacon_freq = newfreq
			get_radio_connection_by_id(src, "beacon").update_frequency(newfreq)

		set_control_freq(var/newfreq)
			if (!newfreq) return
			newfreq = sanitize_frequency(newfreq)
			src.control_freq = newfreq
			get_radio_connection_by_id(src, "control").update_frequency(newfreq)

	update_icon()

		var/emotion_image = null

		if(!src.on)
			src.icon_state = "robuddy0"

		else if(src.stunned)
			src.icon_state = "robuddya"

		else if(src.idle)
			src.icon_state = "robuddy_idle"

		else
			if (src.emotion)
				emotion_image = image(src.icon, "face-[src.emotion]")
			src.icon_state = "robuddy1"

		src.overlays = list( emotion_image, src.bedsheet ? image(src.icon, "bhat-ghost[src.bedsheet]") : null, src.costume_icon ? costume_icon : null)

		if (src.hat && !src.hat_shown)
			var/image/hat_image = image(src.hat_icon, "bhat-[src.hat.icon_state]",,layer = 9.5) //TODO LAYER
			hat_image.pixel_x = hat_x_offset
			hat_image.pixel_y = hat_y_offset
			src.underlays = list(hat_image)
			src.hat_shown = 1

		if (src.budgun)
			src.overlays += image(budgun.icon, budgun.icon_state, layer = 10, pixel_x = src.gun_x_offset, pixel_y = src.gun_y_offset)
			if (istype(src.budgun, /obj/item/gun/energy/lawbringer))	// ugh
				var/image/lawbringer_lights = image('icons/obj/items/gun.dmi', "lawbringer-d100", 11, pixel_x = src.gun_x_offset, pixel_y = src.gun_y_offset)	// ugh
				switch(lawbringer_state)	// ugh
					if ("clown")
						lawbringer_lights.color = "#FFC0CB"
					if ("detain")
						lawbringer_lights.color = "#FFFF00"
					if ("pulse")
						lawbringer_lights.color = "#EEEEFF"
					if ("knockout")
						lawbringer_lights.color = "#008000"
					if ("smoke")
						lawbringer_lights.color = "#0000FF"
					if ("execute")
						lawbringer_lights.color = "#00FFFF"
					if ("hotshot")
						lawbringer_lights.color = "#FF0000"
					if ("bigshot")
						lawbringer_lights.color = "#551A8B"
				src.overlays += lawbringer_lights

		src.icon_needs_update = 0
		return

	process()
		. = ..()
		if (icon_needs_update)
			src.UpdateIcon()

		if(!src.on)
			return
		if(src.stunned)
			src.stunned--
			if(src.stunned <= 0)
				src.wakeup()
			return

		if( src.manage_power() ) //Returns true if we need to halt process
			return				//(ie we are now off or idle)

		if(idle) //Are we idling?
			if(src.wakeup_timer) //Are we waiting to exit the idle state?
				src.wakeup_timer--
				if(src.wakeup_timer <= 0)
					src.wakeup() //Exit idle state.
			return

		if(src.charge_dock)
			if(charge_dock.loc == src.loc)
				if(!src.idle)
					INVOKE_ASYNC(src, /obj/machinery/bot/guardbot.proc/snooze)
			else
				src.charge_dock = null
				src.wakeup()

			return

		if(src.reply_wait)
			src.reply_wait--

		if(src.on && !src.idle && src.slept_through_becoming_the_law)	// Oh you're awake now?
			BeTheLaw(src.emagged, 0, src.lawbringer_alwaysbigshot)	// Go be the law, sleepyhead
		if(src.on && !src.idle && src.slept_through_laser_class)	// Rise and shine, buddy
			CheckSafety(src.budgun, src.emagged)	// Look at your gun!

		if(!src.tasks.len && (src.model_task || setup_default_startup_task))
			if(!src.model_task)
				src.model_task = new setup_default_startup_task

			src.add_task(src.model_task.copy_file(),1)

		if(src.task?.disposed || src.task?.master != src)
			src.task = null
		if(istype(src.task))
			src.task.task_act()

		return

	navigate_to(atom/the_target,var/move_delay=3,var/adjacent=0,var/clear_frustration=1, max_dist=100)
		if(src.moving)
			return 1
		src.moving = 1
		if (clear_frustration)
			src.frustration = 0
		if(src.mover)
			qdel(src.mover)

		src.mover = new /datum/guardbot_mover(src)
		src.mover.max_dist = max_dist

		src.mover.delay = clamp(move_delay, 2, 5)
		src.mover.master_move(the_target,adjacent)

		return 0

	Exited(Obj, newloc)
		. = ..()
		if(Obj == src.cell)
			src.cell = null

//Buddy handcuff bar thing
/datum/action/bar/icon/buddy_cuff
	duration = 30 // zippy zipcuffs
	interrupt_flags = INTERRUPT_MOVE
	id = "buddy_cuff"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "handcuff"
	var/obj/machinery/bot/guardbot/master
	var/datum/computer/file/guardbot_task/security/task

	New(the_bot, the_task)
		src.master = the_bot
		src.task = the_task
		..()

	onUpdate()
		..()
		if (src.failchecks())
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if (src.failchecks())
			interrupt(INTERRUPT_ALWAYS)
			return

		playsound(master, 'sound/weapons/handcuffs.ogg', 30, 1, -2)
		master.visible_message("<span class='alert'><B>[master] is trying to put handcuffs on [task.arrest_target]!</B></span>")

	onInterrupt(flag)
		. = ..(flag)
		if (task.arrest_target?.hasStatus("handcuffed"))
			task.drop_arrest_target()

	onEnd()
		..()
		if (src.failchecks())
			// One of the possible failed checks is that they're cuffed so
			// we can stop trying to arrest them.
			if (task.arrest_target?.hasStatus("handcuffed"))
				task.drop_arrest_target()

			return

		if (!isturf(task.arrest_target.loc))
			task.drop_arrest_target()
			return

		if (ishuman(task.arrest_target))
			task.arrest_target.handcuffs = new /obj/item/handcuffs/guardbot(task.arrest_target)
			task.arrest_target.setStatus("handcuffed", duration = INFINITE_STATUS)
			boutput(task.arrest_target, "<span class='alert'>[master] gently handcuffs you!  It's like the cuffs are hugging your wrists.</span>")
			task.arrest_target:set_clothing_icon_dirty()

		if (length(task.arrested_messages))
			var/arrest_message = pick(task.arrested_messages)
			master.speak(arrest_message)

		var/bot_location = get_area(master)
		var/last_target = task.arrest_target
		var/turf/LT_loc = get_turf(last_target)
		if(!LT_loc)
			LT_loc = get_turf(master)

		task.mode = 0
		task.drop_arrest_target()
		master.set_emotion("smug")

		//////PDA NOTIFY/////
		var/datum/signal/pdaSignal = get_free_signal()
		var/message2send
		if (prob(5))
			message2send = "Notification: Tactical law operation agent [master] reporting grandslam on tango [last_target] for suspected [rand(10,99)]-[rand(1,999)] \"[pick_string("shittybill.txt", "drugs")]-[pick_string("shittybill.txt", "insults")]\" \
			in [bot_location] at grid reference [LT_loc.x][prob(50)?"-niner":""] mark [LT_loc.y][prob(50)?"-niner":""]. Unit requesting law enforcement personnel for further suspect prosecution. [master] over and out."
			master.speak(message2send)
		else
			message2send ="Notification: [last_target] detained by [master] in [bot_location] at coordinates [LT_loc.x], [LT_loc.y]."
		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="BUDDY-MAILBOT", "group"=list(MGD_SCIENCE), "sender"="00000000", "message"="[message2send]")
		SEND_SIGNAL(master, COMSIG_MOVABLE_POST_RADIO_PACKET, pdaSignal, null, "pda")

	/// Interrupts the action if the bot cant (or shouldnt be able to) continue cuffing
	proc/failchecks()
		if (!master || !master.on || master.idle || master.stunned || master.moving)
			return 1
		if (!(BOUNDS_DIST(master, task.arrest_target) == 0) || !task.arrest_target || task.arrest_target.hasStatus("handcuffed"))
			return 1

//Robot tools.  Flash boards, batons, etc
/obj/item/device/guardbot_tool
	name = "Tool module"
	desc = "A generic module for a PR-6S Guardbuddy."
	icon = 'icons/obj/module.dmi'
	icon_state = "tool_generic"
	mats = 6
	w_class = W_CLASS_SMALL
	var/is_stun = 0 //Can it be non-lethal?
	var/is_lethal = 0 //Can it be lethal?
	var/tool_id = "GENERIC" //Identification ID.
	var/is_gun = 0 //1 Is ranged, 0 is melee.
	var/last_use = 0 //If we want a use delay.

	proc
		bot_attack(var/atom/target as mob|obj, obj/machinery/bot/guardbot/user, ranged=0, lethal=0)
			if(!user || !user.on || user.getStatusDuration("stunned") || user.idle)
				return 1

			return 0

	//phantom Gun tool
	gun
		name = "Weapon handling chipset"
		desc = "A ROM unit containing firearm drivers that allow a PR-6S Guardbuddy to wield a gun, typically pre-soldered to their mainboard. The fact it isn't attached to anything indicates that it is damaged beyond use."
		icon_state = "tool_generic"
		tool_id = "GUN"
		is_gun = 1
		is_stun = 1
		is_lethal = 1

		// Updated for new projectile code (Convair880).
		bot_attack(var/atom/target as mob|obj, obj/machinery/bot/guardbot/user, ranged=0, lethal=0)
			if (..()) return

	//pie launcher module
	pie_launcher
		name = "Shoddy Pie Launcher"
		desc = "This pie launcher seems shoddily made, and doesn't have a handle. Why would anyone make this?"
		icon_state = "tool_pie"
		tool_id = "PIE"
		is_gun = 1
		is_stun = 1
		var/datum/projectile/current_projectile = new /datum/projectile/pie
		bot_attack(var/atom/target as mob|obj, obj/machinery/bot/guardbot/user, ranged=0, lethal=0)
			if (..()) return


			if (ranged)
				var/obj/projectile/P = shoot_projectile_ST_pixel(master, current_projectile, target)
				if (!P)
					return


				user.visible_message("<span class='alert'><b>[master] throws a pie at [target]!</b></span>")

			else
				var/obj/projectile/P = initialize_projectile_ST(master, current_projectile, target)
				if (!P)
					return

				user.visible_message("<span class='alert'><b>[master] slaps [target] in the face with a pie!</b></span>")
				P.was_pointblank = 1
				hit_with_existing_projectile(P, target)

			src.last_use = world.time
			return


	//A syringe gun module. Mercy sakes.
	medicator
		name = "Medicator tool module"
		desc = "A 'Medicator' syringe launcher module for PR-6S Guardbuddies. These things are actually outlawed on Earth."
		icon_state = "tool_syringe"
		tool_id = "SYRNG"
		is_gun = 1
		is_stun = 1 //Can be both nonlethal and lethal
		is_lethal = 1 //Depends on reagent load.
		var/datum/projectile/current_projectile = new /datum/projectile/syringe
		var/stun_reagent = "haloperidol"
		var/kill_reagent = "cyanide"

		// Updated for new projectile code (Convair880).
		bot_attack(var/atom/target as mob|obj, obj/machinery/bot/guardbot/user, ranged=0, lethal=0)
			if (..()) return

			if (src.last_use && world.time < src.last_use + 60)
				return

			if (ranged)
				var/obj/projectile/P = shoot_projectile_ST_pixel(master, current_projectile, target)
				if (!P)
					return
				if (!P.reagents)
					P.reagents = new /datum/reagents(15)
					P.reagents.my_atom = P
				if (lethal)
					P.reagents.add_reagent(kill_reagent, 10)
				else
					P.reagents.add_reagent(stun_reagent, 15)

				user.visible_message("<span class='alert'><b>[master] fires a syringe at [target]!</b></span>")

			else
				var/obj/projectile/P = initialize_projectile_ST(master, current_projectile, target)
				if (!P)
					return
				if (!P.reagents)
					P.reagents = new /datum/reagents(15)
					P.reagents.my_atom = P
				if (lethal)
					P.reagents.add_reagent(kill_reagent, 10)
				else
					P.reagents.add_reagent(stun_reagent, 15)

				user.visible_message("<span class='alert'><b>[master] shoots [target] point-blank with a syringe!</b></span>")
				P.was_pointblank = 1
				hit_with_existing_projectile(P, target)

			src.last_use = world.time
			return

	//Short-range smoke riot control module
	smoker
		name = "'Smoker' tool module"
		desc = "A riot-control gas module for PR-6S Guardbuddies."
		icon_state = "tool_smoke"
		tool_id = "SMOKE"
		is_stun = 1
		is_lethal = 1
		var/stun_reagent = "ketamine"
		var/kill_reagent = "neurotoxin"

		New()
			..()
			src.create_reagents(500)

		// Fixed. Was completely non-functional (Convair880).
		bot_attack(var/atom/target as mob|obj, obj/machinery/bot/guardbot/user, ranged=0, lethal=0)
			if(..() || !reagents || ranged) return

			if(src.last_use && world.time < src.last_use + 120)
				return

			src.reagents.clear_reagents()
			if (lethal)
				src.reagents.add_reagent(kill_reagent, 15)
			else
				src.reagents.add_reagent(stun_reagent, 15)

			smoke_reaction(src.reagents, 3, get_turf(src))
			user.visible_message("<span class='alert'><b>[master] releases a cloud of gas!</b></span>")

			src.last_use = world.time
			return

	//Taser tool
	taser
		name = "Taser tool module"
		desc = "A taser module for PR-6S Guardbuddies."
		icon_state = "tool_taser"
		tool_id = "TASER"
		is_stun = 1
		is_gun = 1
		var/datum/projectile/current_projectile = new/datum/projectile/energy_bolt/robust

		// Updated for new projectile code (Convair880).
		bot_attack(var/atom/target as mob|obj, obj/machinery/bot/guardbot/user, ranged=0, lethal=0)
			if (..()) return

			if (src.last_use && world.time < src.last_use + 80)
				return

			if (ranged)
				var/obj/projectile/P = shoot_projectile_ST_pixel(master, current_projectile, target)
				if (!P)
					return

				user.visible_message("<span class='alert'><b>[master] fires the taser at [target]!</b></span>")

			else
				var/obj/projectile/P = initialize_projectile_ST(master, current_projectile, target)
				if (!P)
					return

				user.visible_message("<span class='alert'><b>[master] shoots [target] point-blank with the taser!</b></span>")
				P.was_pointblank = 1
				hit_with_existing_projectile(P, target)

			src.last_use = world.time
			return

	//Flash tool
	flash
		name = "Flash tool module"
		desc = "A flash module for PR-6S Guardbuddies."
		icon_state = "tool_flash"
		is_stun = 1
		tool_id = "FLASH"

		bot_attack(var/atom/target as mob|obj, obj/machinery/bot/guardbot/user, ranged=0, lethal=0)
			if(..()) return

			if(ranged) return

			if(iscarbon(target))

				var/mob/living/carbon/O = target

				if(src.last_use && world.time < src.last_use + 80)
					return

				playsound(user.loc, 'sound/weapons/flash.ogg', 100, 1)
				flick("robuddy-c", user)
				src.last_use = world.time

				// We're flashing somebody directly, hence the 100% chance to disrupt cloaking device at the end.
				O.apply_flash(30, 8, 0, 0, 0, rand(0, 2), 0, 0, 100)

			return

	//Electrobolt tool.  Basically, Keelin owns ok
	tesla
		name = "Elektro-Arc tool module"
		desc = "An experimental tesla-coil module for PR-6S Guardbuddies."
		icon_state = "tool_tesla"
		tool_id = "TESLA"
		is_gun = 1
		is_stun = 1 //Can be both nonlethal and lethal
		is_lethal = 1

		bot_attack(var/atom/target as mob|obj, obj/machinery/bot/guardbot/user, ranged=0, lethal=0)
			if(..())
				return

			if (GET_DIST(user,target) > 4)
				return

			if(src.last_use && world.time < src.last_use + 80)
				return

			var/atom/last = user
			var/atom/target_r = target

			var/list/dummies = new/list()

			playsound(src, 'sound/effects/elec_bigzap.ogg', 40, 1)

			if(isturf(target))
				target_r = new/obj/elec_trg_dummy(target)

			var/turf/currTurf = get_turf(target_r)
			currTurf.hotspot_expose(2000, 400)

			for(var/count=0, count<4, count++)

				var/list/affected = DrawLine(last, target_r, /obj/line_obj/elec ,'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",OBJ_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')

				for(var/obj/O in affected)
					SPAWN(0.6 SECONDS) qdel(O)

				if(isliving(target_r)) //Probably unsafe.
					playsound(target_r:loc, 'sound/effects/electric_shock.ogg', 50, 1)
					if (lethal)
						var/mob/living/carbon/human/H = target_r
						random_burn_damage(target_r, rand(45,60))
						H.do_disorient(stamina_damage = 45, weakened = 50, stunned = 40, disorient = 20, remove_stamina_below_zero = 0)
					boutput(target_r, "<span class='alert'><B>You feel a powerful shock course through your body!</B></span>")
					target_r:unlock_medal("HIGH VOLTAGE", 1)
					target_r:Virus_ShockCure(100)
					target_r:shock_cyberheart(33)
					if (ishuman(target_r))
						target_r:changeStatus("weakened", lethal ? (3 SECONDS): (8 SECONDS))
					break

				var/list/next = new/list()
				for(var/atom/movable/AM in orange(3, target_r))
					if(istype(AM, /obj/line_obj/elec) || istype(AM, /obj/elec_trg_dummy) || istype(AM, /obj/overlay/tile_effect) || AM.invisibility)
						continue
					next.Add(AM)

				if(istype(target_r, /obj/elec_trg_dummy))
					dummies.Add(target_r)

				last = target_r
				target_r = pick(next)
				target = target_r

			for(var/d in dummies)
				qdel(d)

			src.last_use = world.time
			return

	//xmas -- See spacemas.dm

/obj/item/device/guardbot_module
	name = "Add-on module"
	desc = "A generic expansion pack for a PR-6S Guardbuddy."
	icon = 'icons/obj/module.dmi'
	icon_state = "tool_generic"
	mats = 6
	w_class = W_CLASS_SMALL
	var/tool_id = "MOD"
	is_syndicate = 1

	ammofab
		name = "BulletBuddy ammo fabrication kit"
		desc = "A miniature fabricator designed to fit inside a PR-6S Guardbuddy and provide for it an inexhaustible supply of kinetic ammunition, at the expense of the bot's built-in battery charge. When attached, this device welds itself to the bot, and if it detects a weapon in the bot's grip, it'll weld itself to that as well."
		icon_state = "press_forbidden"
		tool_id = "AMMOFAB - if you see this, please tell Superlagg their thing broke =0"

//Task Datums
/datum/computer/file/guardbot_task //Computer datum so it can be transmitted over radio
	name = "idle"
	var/task_id = "IDLE" //Small allcaps id for task
	var/tmp/obj/machinery/bot/guardbot/master = null
	var/tmp/atom/target = null
	var/tmp/list/secondary_targets = list()
	var/oldtarget_name
	var/last_found = 0
	var/handle_beacons = 0 //Can we handle beacon signals?

	disposing()
		master = null
		target = null
		secondary_targets = null
		..()

	proc
		task_act()
			if(!master || master.task != src)
				return 1
			if(!master.on || master.stunned)
				return 1

			return 0

		attack_response(mob/attacker as mob)
			if(!master || master.task != src)
				return 1
			if(!master.on || master.stunned || master.idle)
				return 1
			if(!istype(attacker))
				return 1

			return 0

		task_input(var/input)
			if(!master || !input || !master.on) return 1

			if(input == "hugged")
				switch(master.emotion)
					if(null)
						master.set_emotion("happy")
					if("happy","smug")
						master.set_emotion("love")
					if("joy","love")
						if (prob(25))
							master.visible_message("<span class='notice'>[master.name] reciprocates the hug!</span>")
				return 1

			return 0

		next_target() //Return true if there is a new target, false otherwise
			src.target = null
			if (src.secondary_targets.len)
				src.target = src.secondary_targets[1]
				src.secondary_targets -= src.secondary_targets[1]
				return 1
			return 0

		receive_signal(datum/signal/signal, is_beacon=0)
			if (!master || !signal)
				return 1
			if (is_beacon && !src.handle_beacons)
				return 1
			return 0

		configure(var/list/confList)
			if (!confList || !length(confList))
				return 1

			return 0

	//Recharge task
	recharge
		name = "recharge"
		task_id = "RECHARGE"
		var/tmp/announced = 0
		var/dock_return = 0 //If 0: return to recharge, if 1: return for new programming

		dock_sync
			name = "sync"
			task_id = "SYNC"
			dock_return = 1
			announced = 1

		task_input(input)
			if(..()) return

			switch(input)
				if("path_error","path_blocked")
					if(src.target)
						src.oldtarget_name = src.target.name
						src.next_target()
						src.last_found = world.time
				if("snooze")
					src.target = null
					src.secondary_targets.len = 0

			return

		task_act()
			if(..()) return
			if(!dock_return && master.cell.charge >= (GUARDBOT_LOWPOWER_ALERT_LEVEL * 2))
				master.remove_current_task()
				return

			if(istype(src.target, /turf/simulated))
				var/obj/machinery/guardbot_dock/dock = locate() in src.target
				if(dock && dock.loc == master.loc)
					if(!isnull(dock.current) && dock.current != src)
						src.next_target()
					else
						var/auto_eject = 0
						if(!dock_return && master.tasks.len >= 2)
							auto_eject = 1
						dock.connect_robot(master,auto_eject)
						//master.snooze() //Connect autosnoozes the bot.
					return
				else if (src.target == master.loc)
					src.target = null
					src.last_found = world.time
					src.next_target()

				if(!master.moving)
					master.navigate_to(src.target)
			else
				if(!master.last_comm || (world.time >= master.last_comm + 100) )
					master.post_status(null,"data","[master.cell.charge]","address_tag","recharge")
					master.reply_wait = 2
					if(!announced)
						announced++
						master.speak("Low battery.")
						master.set_emotion("battery")
					else
						announced = 1

			return

		receive_signal(datum/signal/signal)
			if(..()) return
			if(signal.data["command"] == "recharge_src")
				if(!master.reply_wait)
					return
				var/list/L = params2list(signal.data["data"])
				if(!L || !L["x"] || !L["y"]) return
				var/search_x = text2num_safe(L["x"])
				var/search_y = text2num_safe(L["y"])
				var/turf/simulated/new_target = locate(search_x,search_y,master.z)
				if(!new_target)
					return

				if (announced != 2)
					announced = 2
					src.secondary_targets = list()

					SPAWN(1 SECOND)
						if (src.secondary_targets.len)
							master.reply_wait = 0
							. = INFINITY
							for (var/turf/T in src.secondary_targets)
								if (!src.target || (. > GET_DIST(src.master, T)))
									src.target = T
									. = GET_DIST(src.master, src.target)
									continue

							src.secondary_targets -= src.target

				src.secondary_targets += new_target

				//master.reply_wait = 0

			return

		attack_response(mob/attacker as mob)
			if(..())
				return

			var/datum/computer/file/guardbot_task/security/single_use/beatdown = new
			beatdown.arrest_target = attacker
			beatdown.mode = 1
			src.master.add_task(beatdown, 1, 0)
			return

	//Buddytime task -- Even buddies need to relax sometimes!
	buddy_time
		name = "rumpus"
		handle_beacons = 1
		task_id = "RUMPUS"
		var/tmp/turf/simulated/bar_beacon_turf	//Location of bar beacon
		var/tmp/obj/stool/our_seat = null
		var/tmp/awaiting_beacon = 0
		var/tmp/nav_delay = 0
		var/tmp/beepsky_check_delay = 0
		var/tmp/state = 0
		var/tmp/party_counter = 90
		var/tmp/party_idle_counter = 0
		var/tmp/obj/machinery/bot/secbot/its_beepsky = null

		var/rumpus_emotion = "joy" //Emotion to express during buddytime.
		var/rumpus_location_tag = "buddytime" //Tag of the bar beacon

		task_act()
			if(..()) return

			switch (state)
				if (0)
					master.speak("Break time. Rumpus protocol initiated.")
					src.state = 1

				if (1)	//Seeking the bar.
					if (src.awaiting_beacon)
						src.awaiting_beacon--
						if (src.awaiting_beacon <= 0)
							src.master.speak("Error: Bar not found. Break canceled.")
							src.master.set_emotion("sad")
							src.master.remove_current_task()
							return

					if(istype(src.bar_beacon_turf, /turf/simulated))
						if (get_area(src.master) == get_area(bar_beacon_turf))
							src.state = 2
							master.moving = 0
							//master.current_movepath = "HEH"

							return

						if (!master.moving)
							if (nav_delay > 0)
								nav_delay--
								return
							master.navigate_to(src.bar_beacon_turf)
							nav_delay = 5

					else
						if(!master.last_comm || (world.time >= master.last_comm + 100) )
							src.awaiting_beacon = 10
							master.post_find_beacon("patrol")
							master.reply_wait = 2

				if (2)	//Seeking a seat.
					if (!istype(src.target, /obj/stool))
						src.secondary_targets.len = 0
						for (var/obj/stool/S in view(7, master))
							secondary_targets += S

						if (secondary_targets.len)
							src.target = pick(secondary_targets)
						else
							master.speak("Error: No seating available. Break canceled.")
							src.master.set_emotion("sad")
							src.master.remove_current_task()
							return

					else
						if(src.target.loc == src.master.loc)
							src.master.set_emotion(rumpus_emotion)
							src.state = 3
							src.our_seat = src.target
							src.party_idle_counter = rand(4,14)
							if (!its_beepsky)
								src.locate_beepsky()
							return

						if(!master.moving)
							master.navigate_to(src.target, 2.5, max_dist=14)

					return

				if (3) //IT IS RUMPUS TIME
					if (its_beepsky && (get_area(master) == get_area(its_beepsky)))
						beepsky_check_delay = 8
						src.state = 4
						src.master.set_emotion("ugh")
						if (its_beepsky.emagged == 2)
							src.master.speak(pick("Oh, look at the time.", "I need to go.  I have a...dentist appointment.  Yes", "Oh, is the break over already? I better be off.", "I'd best be leaving."))
							src.master.remove_current_task()
						return

					if (party_counter-- <= 0)
						src.master.set_emotion()
						src.master.speak("Break complete.")
						src.master.remove_current_task()
						return

					if (our_seat && our_seat.loc != src.master.loc)
						our_seat = null
						src.state = 2

					if (src.master.emotion != rumpus_emotion)
						src.master.set_emotion(rumpus_emotion)

					if (party_idle_counter-- <= 0)
						party_idle_counter = rand(4,14)
						if (prob(50))
							src.master.speak(pick("Yay!", "Woo-hoo!", "Yee-haw!", "Oh boy!", "Oh yeah!", "My favorite color is probably [pick("red","green","mauve","anti-flash white", "aureolin", "coquelicot")].", "I'm glad we have the opportunity to relax like this.", "Imagine if I had two arms. I could hug twice as much!", "I like [pick("tea","coffee","hot chocolate","soda", "diet soda", "milk", "almond milk", "soy milk", "horchata", "hot cocoa with honey mixed in", "green tea", "black tea")]. I have no digestive system or even a mouth, but I'm pretty sure I would like it.", "Sometimes I wonder what it would be like if I could fly."))

						else
							var/actiontext = pick("does a little dance. It's not very good but there's good effort there.", "slowly rotates around in a circle.", "attempts to do a flip, but is unable to jump.", "hugs an invisible being only it can see.", "rocks back and forth repeatedly.", "tilts side to side.", "claps.  Whaaat.", prob(1);"looks directly at you, the viewer.")
							if (src.master.hat && prob(8))
								actiontext = "adjusts its hat."
							src.master.visible_message("<b>[src.master.name]</b> [actiontext]")

				if (4)
					if (beepsky_check_delay-- > 0)
						return

					if (!its_beepsky || get_area(master) != get_area(its_beepsky))
						if (prob(10))
							src.master.speak(pick("Took long enough.", "Thought he'd never leave.", "Thought he'd never leave.  Too bad it smells like him in here now."))

						src.master.set_emotion(rumpus_emotion)
						src.state = 3
						return

					beepsky_check_delay = 8

			return

		task_input(var/input)
			if (..())
				return

			if (input == "path_error")
				src.master.speak("Error: Destination unreachable. Break canceled.")
				src.master.set_emotion("sad")
				src.master.remove_current_task()
				return

		receive_signal(datum/signal/signal)
			if(..())
				return

			var/recv = signal.data["beacon"]
			var/valid = signal.data["patrol"]
			if(!awaiting_beacon || !recv || !valid || nav_delay)
				return

			//boutput(world, "patrol task received")

			if(recv == rumpus_location_tag)	// if the recvd beacon location matches the set destination
										// then we will navigate there
				bar_beacon_turf = get_turf(signal.source)
				awaiting_beacon = 0
				nav_delay = rand(3,5)

		attack_response(mob/attacker as mob)
			if(..())
				return

			var/datum/computer/file/guardbot_task/security/single_use/beatdown = new
			beatdown.arrest_target = attacker
			beatdown.mode = 1
			src.master.add_task(beatdown, 1, 0)
			return

		proc/locate_beepsky() //Guardbots don't like beepsky. They think he's a jerk. They are right.
			if (src.its_beepsky) //Huh? We haven't lost him.
				return

			for (var/obj/machinery/bot/secbot/possibly_beepsky in machine_registry[MACHINES_BOTS])
				if (ckey(possibly_beepsky.name) == "officerbeepsky")
					src.its_beepsky = possibly_beepsky //Definitely beepsky in this case.
					break

			return

	//Security/Patrol task -- Essentially secbot emulation.
	security
		name = "secure"
		handle_beacons = 1
		task_id = "SECURE"
		var/tmp/new_destination		// pending new destination (waiting for beacon response)
		var/tmp/destination			// destination description tag
		var/tmp/next_destination	// the next destination in the patrol route
		var/tmp/nearest_beacon			// the nearest beacon's tag
		var/tmp/turf/nearest_beacon_loc	// the nearest beacon's location
		var/tmp/awaiting_beacon = 0
		var/tmp/patrol_delay = 0

		var/tmp/mob/living/carbon/arrest_target = null
		var/tmp/mob/living/carbon/hug_target = null
		var/list/target_names = list() //Dudes we are preprogrammed to arrest.
		var/tmp/mode = 0 //0: Patrol, 1: Arresting somebody
		var/tmp/arrest_attempts = 0
		var/tmp/last_cute_action = 0

		var/weapon_access = access_carrypermit //These guys can use guns, ok!
		var/contraband_access = access_contrabandpermit
		var/lethal = 0 //Do we use lethal force (if possible) ?
		var/panic = 0 //Martial law! Arrest all kinds!!
		var/no_patrol = 1 //Don't patrol.

		var/tmp/list/arrested_messages = list("Have a secure day!","Your move, creep.", "God made tomorrow for the crooks we don't catch today.","One riot, one ranger.")

#define ARREST_DELAY 2.5 //Delay between movements when chasing a criminal, slightly faster than usual. (2.5 vs 3)
#define TIME_BETWEEN_CUTE_ACTIONS 1800 //Tenths of a second between cute actions

		patrol
			name = "patrol"
			task_id = "PATROL"
			no_patrol = 0

		crazy
			name = "patr#(003~"
			task_id = "ERR0xF00F"
			lethal = 1
			panic = 1
			no_patrol = 0

		single_use
			no_patrol = 1

			drop_arrest_target()
				src.master.remove_current_task()
				return

			drop_hug_target()
				src.master.remove_current_task()
				return

		seek
			no_patrol = 0

			look_for_perp()
				if(src.arrest_target) return //Already chasing somebody
				for (var/mob/living/carbon/C in view(7,master)) //Let's find us a criminal
					if ((C.stat) || (C.hasStatus("handcuffed")))
						continue

					if (src.assess_perp(C))
						src.master.remove_current_task()
						return

			assess_perp(mob/living/carbon/human/perp as mob)
				if(ckey(perp.name) == master.scratchpad["targetname"])
					return 1

				var/obj/item/card/id/perp_id = perp.equipped()
				if (!istype(perp_id))
					perp_id = perp.get_id()

				if(perp_id && ckey(perp_id.registered) == master.scratchpad["targetname"])
					return 1

				return 0

		task_act()
			if(..()) return

			look_for_perp()

			switch(mode)
				if(0)
					if (hug_target)

						if ((istype(hug_target) && isdead(hug_target)) || (istype(hug_target, /obj/critter) && hug_target.health <= 0))
							hug_target = null
							master.set_emotion("sad")
							return

						if(BOUNDS_DIST(master, hug_target) == 0)
							master.visible_message("<b>[master]</b> hugs [hug_target]!")
							if (hug_target.reagents)
								hug_target.reagents.add_reagent("hugs", 10)

							if (prob(1) && istype(hug_target) && hug_target.client && hug_target.client.IsByondMember())
								master.speak("You might want a breath mint.")

							drop_hug_target()
							master.set_emotion("love")
							master.moving = 0
							//master.current_movepath = "HEH"
							return

						if((!(hug_target in view(7,master)) && (!master.mover || !master.moving)) || !master.path || !master.path.len || (4 < GET_DIST(hug_target,master.path[master.path.len])) )
							if (master.mover)
								qdel(master.mover)
							master.moving = 0
							master.navigate_to(hug_target,ARREST_DELAY, max_dist=15)
							return


						return

					if(patrol_delay)
						patrol_delay--
						return

					if(master.moving || no_patrol)
						return

					if(!master.moving)
						find_patrol_target()
				/*
				Hunt and arrest mode. Like an angry secbot, but cuter and sometimes has a gun
				Script should go as follows:
					Check if the bot is cuffing someone, and don't do anything else if they are (otherwise they just stunlock people like dorks)
					Check if the bot has a valid target (living, and not dead, and also existing) Done second since the cuffbar implies it has a target already
					Check if the bot can see the target.
						If it can, shoot them, then check if they're in cuffing range.
							If in cuffing range, cuff em, then stand still until they're done.
							If not, go after them!
						If it can't, go after them! And get a little frustrated too.
				*/
				if(1)
					// First, check if we're already cuffing someone. Quit getting sidetracked, you scatterbrained rectangles
					if(actions.hasAction(src.master, "buddy_cuff"))
						return

					// Next check if they have someone to arrest, and that they're alive. And that they're living.
					if(!src.arrest_target || !isliving(src.arrest_target) || isdead(src.arrest_target))
						src.mode = 0
						src.drop_arrest_target()
						return // target doesnt exist, is a ghost, or has given up the ghost

					// Can we /see/ them?
					if(src.arrest_target in view(7,get_turf(master)))
						// Shoot them!
						master.bot_attack(arrest_target, src.lethal)
					else
						// Otherwise get frustrated
						master.frustration += 2

					// Right up against them? Book em!
					if((BOUNDS_DIST(src.master, src.arrest_target) == 0) && is_incapacitated(src.arrest_target))
						actions.start(new/datum/action/bar/icon/buddy_cuff(src.master, src), src.master)
					// Otherwise, go get them!
					else
						if (master.mover)
							qdel(master.mover)
						master.moving = 0
						master.navigate_to(arrest_target,ARREST_DELAY, 0, 0, max_dist=30)
						//master.current_movepath = "HEH" //Stop any current movement.

		task_input(input)
			if(..()) return 1

			switch(input)
				if("snooze")
					src.patrol_delay = 0
					src.awaiting_beacon = 0
					src.next_destination = null
					src.target = null
					src.secondary_targets.len = 0
					if(arrest_target)
						src.arrest_target = null
						src.last_found = world.time
					src.arrest_attempts = 0
					actions.stopId("buddy_cuff", src.master)

					return 1

				if("path_error","path_blocked")
					src.arrest_attempts++
					if(src.arrest_attempts >= 2)
						actions.stopId("buddy_cuff", src.master)
						src.target = null
						if(arrest_target)
							src.arrest_target = null
							src.last_found = world.time
						src.mode = 0
						src.arrest_attempts = 0
						master.set_emotion()

					return 1

				if ("treated")
					return ..("hugged")

			return 0

		receive_signal(datum/signal/signal)
			if(..())
				return

			if(signal.data["command"] == "configure")
				if (signal.data["command2"])
					signal.data["command"] = signal.data["command2"]

				src.configure(signal.data)
				return

			var/recv = signal.data["beacon"]
			var/valid = signal.data["patrol"]
			if(!awaiting_beacon || !recv || !valid || patrol_delay)
				return

			//boutput(world, "patrol task received")

			if(recv == new_destination)	// if the recvd beacon location matches the set destination
										// then we will navigate there
				destination = new_destination
				target = signal.source.loc
				next_destination = signal.data["next_patrol"]
				awaiting_beacon = 0
				patrol_delay = rand(3,5) //So a patrol group doesn't bunch up on a single tile.

			// if looking for nearest beacon
			else if(new_destination == "__nearest__")
				var/dist = GET_DIST(master,signal.source.loc)
				if(nearest_beacon)

					// note we ignore the beacon we are located at
					if(dist>1 && dist<GET_DIST(master,nearest_beacon_loc))
						nearest_beacon = recv
						nearest_beacon_loc = signal.source.loc
						next_destination = signal.data["next_patrol"]
						target = signal.source.loc
						destination = recv
						return
					else
						return
				else if(dist > 1)
					nearest_beacon = recv
					nearest_beacon_loc = signal.source.loc
					next_destination = signal.data["next_patrol"]
					target = signal.source.loc
					destination = recv
			return

		attack_response(mob/attacker as mob)
			if(..())
				return

			if(!src.arrest_target)
				src.arrest_target = attacker
				src.mode = 1
				src.oldtarget_name = attacker.name
				master.set_emotion("angry")

			return

		configure(var/list/confList)
			if (..())
				return 1

			if (confList["patrol"])
				var/patrol_stat = text2num_safe(confList["patrol"])
				if (!isnull(patrol_stat))
					if (patrol_stat)
						src.no_patrol = 0
					else
						src.no_patrol = 1

			if (confList["lethal"] && (confList["acc_code"] == netpass_heads))
				var/lethal_stat = text2num_safe(confList["lethal"])
				if (!isnull(lethal_stat))
					if (lethal_stat && !src.lethal)
						src.lethal = 1
						if (src.master)
							master.speak("Notice: Lethal force authorized.")
					else if (src.lethal)
						src.lethal = 0
						if (src.master)
							master.speak("Notice: Lethal force is no longer authorized.")

			if (confList["name"] && !src.master)
				var/target_name = ckey(confList["name"])
				if (target_name && target_name != "")
					src.target_names = list(target_name)

			if (confList["command"])
				switch(lowertext(confList["command"]))
					if ("add_target")
						if(confList["acc_code"] != netpass_heads)
							return 0
						var/newtarget_name = ckey(confList["data"])
						if(!newtarget_name || newtarget_name == "")
							return 0

						if(!(newtarget_name in src.target_names))
							src.target_names += newtarget_name
							if (src.master)
								master.speak("Notice: Criminal database updated.")
						return 0
					if ("remove_target")
						if(confList["acc_code"] != netpass_heads)
							return 0
						var/seltarget_name = ckey(confList["data"])
						if(!seltarget_name || seltarget_name == "")
							return 0

						if(seltarget_name in src.target_names)
							src.target_names -= seltarget_name
							if (src.master)
								if(src.target_names.len)
									master.speak("Notice: Criminal database updated.")
								else
									master.speak("Notice: Criminal database cleared.")
						return 0

					if("clear_targets")
						if(confList["acc_code"] != netpass_heads)
							return 0

						if(src.target_names.len)
							src.target_names = list()
							if (src.master)
								master.speak("Notice: Criminal database cleared.")
						return 0

			return 0

		proc
			look_for_perp()
				if(src.arrest_target) return //Already chasing somebody
				for (var/mob/living/carbon/C in view(7,master)) //Let's find us a criminal
					if ((C.stat) || (C.hasStatus("handcuffed")))
						continue

					if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 60))
						continue

					var/threat = 0
					if(ishuman(C))
						threat = src.assess_perp(C)
				//	else
				//		if(isalien(C))
				//			threat = 9

					if(threat >= 4)
						src.arrest_target = C
						src.oldtarget_name = C.name
						src.mode = 1
						src.master.frustration = 0
						master.set_emotion("angry")
						master.speak("Level [threat] infraction alert!")
						master.point(C, 1)
						if(istype(C, /mob/living/carbon/human/npc/monkey))
							var/mob/living/carbon/human/npc/monkey/npcmonkey = C
							npcmonkey.pursuited_by(src)

					else if (!last_cute_action || ((last_cute_action + TIME_BETWEEN_CUTE_ACTIONS) < world.time))
						if (prob(10))
							last_cute_action = world.time
							switch(rand(1,5))
								if (1)
									master.visible_message("<b>[master]</b> waves at [C.name].")
								if (2)
									master.visible_message("<b>[master]</b> rotates slowly around in a circle.")
								if (3,4)
									//hugs!!
									master.point(C, 1)
									master.speak( pick("Level [rand(1,32)] hug deficiency alert!", "Somebody needs a hug!", "Cheer up!") )
									src.hug_target = C
								if (5)
									master.visible_message("<b>[master]</b> appears to be having a [pick("great","swell","rad","wonderful")] day!")
									if (prob(50))
										master.speak("Woo!")
					return

			drop_arrest_target()
				src.arrest_target = null
				src.last_found = world.time
				actions.stopId("buddy_cuff", src.master)
				src.master.frustration = 0
				master.set_emotion()
				return

			drop_hug_target()
				src.hug_target = null
				return

			find_patrol_target()
				if(awaiting_beacon)			// awaiting beacon response
					awaiting_beacon--
					if(awaiting_beacon <= 0)
						find_nearest_beacon()
					return

				if(next_destination)
					set_destination(next_destination)
					if(!master.moving && target && (target != master.loc))
						master.navigate_to(target, max_dist=40)
					return
				else
					find_nearest_beacon()
				return

			find_nearest_beacon()
				nearest_beacon = null
				new_destination = "__nearest__"
				master.post_find_beacon("patrol")
				awaiting_beacon = 5
				SPAWN(1 SECOND)
					if(!master || !master.on || master.stunned || master.idle) return
					if(master.task != src) return
					awaiting_beacon = 0
					if(nearest_beacon && !master.moving)
						master.navigate_to(nearest_beacon_loc, max_dist=30)
					else
						patrol_delay = 8
						target = null
						return

			set_destination(var/new_dest)
				new_destination = new_dest
				master.post_find_beacon(new_dest || "patrol")
				awaiting_beacon = 5

			assess_perp(mob/living/carbon/human/perp as mob)
				. = 0

				if(src.panic)
					return 9

				if(ckey(perp.name) in target_names)
					return 7

				var/obj/item/card/id/perp_id = perp.equipped()
				if (!istype(perp_id))
					perp_id = perp.get_id()

				var/has_carry_permit = 0
				var/has_contraband_permit = 0

				if(perp_id) //Checking for targets and permits
					if(ckey(perp_id.registered) in target_names)
						return 7
					if(weapon_access in perp_id.access)
						has_carry_permit = 1
					if(contraband_access in perp_id.access)
						has_contraband_permit = 1

				if (istype(perp.l_hand))
					if (istype(perp.l_hand, /obj/item/gun/)) // perp is carrying a gun
						if(!has_carry_permit)
							. += perp.l_hand.get_contraband()
					else // not carrying a gun, but potential contraband?
						if(!has_contraband_permit)
							. += perp.l_hand.get_contraband()

				if (istype(perp.r_hand))
					if (istype(perp.r_hand, /obj/item/gun/)) // perp is carrying a gun
						if(!has_carry_permit)
							. += perp.r_hand.get_contraband()
					else // not carrying a gun, but potential contraband?
						if(!has_contraband_permit)
							. += perp.r_hand.get_contraband()

				if (istype(perp.belt))
					if (istype(perp.belt, /obj/item/gun/))
						if (!has_carry_permit)
							. += perp.belt.get_contraband() * 0.5
					else
						if (!has_contraband_permit)
							. += perp.belt.get_contraband() * 0.5

				if (istype(perp.wear_suit))
					if (!has_contraband_permit)
						. += perp.wear_suit.get_contraband()

				if (istype(perp.back))
					if (istype(perp.back, /obj/item/gun/)) // some weapons can be put on backs
						if (!has_carry_permit)
							. += perp.back.get_contraband() * 0.5
					else // at moment of doing this we don't have other contraband back items, but maybe that'll change
						if (!has_contraband_permit)
							. += perp.back.get_contraband() * 0.5

				if(perp.mutantrace && perp.mutantrace.jerk)
//					if(istype(perp.mutantrace, /datum/mutantrace/zombie))
//						return 5 //Zombies are bad news!

//					threatcount += 2

					return 5


		halloween //Go trick or treating!
			name = "candy"
			task_id = "CANDY"
			no_patrol = 0

			look_for_perp()
				if(src.hug_target)
					return
				for (var/mob/living/carbon/C in view(7,master)) //Let's get some candy!
					if ((C.stat) || (C.hasStatus("handcuffed")))
						continue

					if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 60))
						continue

					var/threat = 0
					if(ishuman(C))
						threat = src.assess_perp(C)
				//	else
				//		if(isalien(C))
				//			threat = 9

					if(threat < 4 && (!last_cute_action || ((last_cute_action + TIME_BETWEEN_CUTE_ACTIONS) < world.time)))
						src.oldtarget_name = C.name
						if (prob(10))
							src.hug_target = C
					return

			task_input(var/input)
				if (input == "treated")
					if (..("filler"))
						return 1

					src.master.speak( pick("Yayyy! Thank you!", "Whoohoo, candy!", "Thank you!  I can't actually eat candy, but I enjoy the aesthetic aspect of it.") )
					src.master.set_emotion("happy")
				else
					if (..())
						return 1


			task_act()
				if (master && mode == 0 && hug_target)
					if (isdead(hug_target))
						hug_target = null
						master.set_emotion("sad")
						return

					if(BOUNDS_DIST(master, hug_target) == 0)
						if (prob(2))
							master.speak("Merry Spacemas!")
							SPAWN(1 SECOND)
								if (master)
									master.speak("Warning: Real-time clock battery low or missing.")
						else
							master.speak("Trick or treat!")
						if (prob(50) && hug_target.client && hug_target.client.IsByondMember())
							master.speak("Oh wait, you're the one who just hands out [pick("religious tracts","pennies", "toothbrushes")].")
						master.set_emotion("love")

						hug_target = null
						master.moving = 0
						//master.current_movepath = "HEH"
						return

					if((!(hug_target in view(7,master)) && (!master.mover || !master.moving)) || !master.path || !master.path.len || (4 < GET_DIST(hug_target,master.path[master.path.len])) )
						if (master.mover)
							qdel(master.mover)
						master.moving = 0
						master.navigate_to(hug_target,ARREST_DELAY, max_dist=15)
						return

				else
					return ..()

		purge //Arrest anyone who isn't a DWAINE superuser.
			name = "purge"
			task_id = "PURGE"
			no_patrol = 0
			var/accepted_access = access_dwaine_superuser

			assess_perp(mob/living/carbon/human/perp as mob)
				var/obj/item/card/id/the_id = perp.get_id()
				if (!the_id)
					the_id = perp.equipped()
				if(!istype(the_id) || (the_id && !(accepted_access in the_id.access)) )
					return 9
				else
					return ..()
/*
		klaus //todo
			name = "klaus"
			task_id = "KLAUS"

			look_for_perp()
				. = ..()
				if (src.arrest_target)
					return
*/

		area_guard
			name = "areaguard"
			task_id = "AREAG"
			no_patrol = 1
			var/area/current_area = null

			look_for_perp()
				current_area = get_area(src.master)

				return ..()

			assess_perp(mob/living/carbon/human/perp as mob)
				var/area/perp_area = get_area(perp)
				if (perp_area == current_area)
					return ..()

				return 0


	//Bodyguard Task -- Guard some dude's personal space
	bodyguard
		name = "bodyguard"
		task_id = "GUARD"

		var/tmp/mob/living/carbon/protected = null
		var/tmp/mob/living/carbon/arrest_target = null
		var/tmp/arrest_attempts = 0
		var/tmp/follow_attempts = 0
		var/tmp/mode = 0 //0: Following protectee, 1: Arresting threat

		var/lethal = 0 //Do we use lethal force (if possible) ?
		var/desired_emotion = "look"
		var/tmp/attacked_by_buddy = 0 //Has our buddy hit us? Buddy abuse is a serious problem.
		var/tmp/buddy_is_dork = 0 //Our buddy kinda sucks :(
		var/tmp/list/arrested_messages = list("Threat neutralized.","Station secure.","Problem resolved.")

		var/protected_name = null //Who are we seeking?

#define SEARCH_EMOTION "look"
#define GUARDING_EMOTION "cool"
#define GUARDING_DORK_EMOTION "coolugh"
#define CHASING_EMOTION "angry"

		task_act()
			if(..())
				return 1

			if(master.emotion != desired_emotion)
				master.set_emotion(desired_emotion)

			if(arrest_target) //Priority one: Arrest a jerk who hurt our buddy.
				desired_emotion = CHASING_EMOTION
				master.set_emotion(CHASING_EMOTION)

				handle_arrest_function()
				return

			if(!protected) //Priority two: Assess status of buddy.
				src.desired_emotion = SEARCH_EMOTION
				src.look_for_protected()
				return
			else
				src.desired_emotion = buddy_is_dork ? GUARDING_DORK_EMOTION : GUARDING_EMOTION

				if(src.check_buddy()) //Should ONLY return true when we pick up a new arrest target.
					master.set_emotion(CHASING_EMOTION)
					handle_arrest_function() //So we don't have to wait for the next process. LIVES ARE ON THE LINE HERE!
					return

				if(!(protected in view(7,master)) && !master.moving)
					//qdel(master.mover)
					master.frustration++
					if (master.mover)
						qdel(master.mover)
					master.navigate_to(protected,3,1,1, max_dist=15)
					return
				else

					if(isdead(protected))
						protected = null
						if (buddy_is_dork && prob(50))
							master.speak(pick("Rest in peace.  I guess", "At least that's over.", "I didn't have the courage to tell you this, but you smelled like rotten ham."))
						else
							master.speak(pick("Rest in peace.","Guard protocol...inactive.","I'm sorry it had to end this way.","It was an honor to serve alongside you."))
						return

					if(!master.path || !master.path.len || (3 < GET_DIST(protected,master.path[master.path.len])) )
						master.moving = 0
						if (master.mover)
							qdel(master.mover)
						master.navigate_to(protected,3,1,1, max_dist=15)

			return

		task_input(input)
			if(..()) return

			switch(input)
				if("snooze")
//					src.arrest_target = null
					src.protected = null
					src.arrest_attempts = 0
					src.follow_attempts = 0
					actions.stopId("buddy_cuff", src.master)
				if("path_error","path_blocked")
					if (src.protected)
						if(!(src.protected in view(7,master)))
							src.follow_attempts++
							if(src.follow_attempts >= 2)
								src.follow_attempts = 0
								src.protected = null
						return

			return

		attack_response(mob/attacker as mob)
			if(..())
				return

			if(attacker == src.protected && !attacked_by_buddy)
				attacked_by_buddy = 1
				master.speak(pick("Check your fire!","Watch it!","Friendly fire will not be tolerated!"))
				return

			if(!src.arrest_target)
				src.arrest_target = attacker
				if(attacker == src.protected)
					src.protected = null

			return

		configure(var/list/confList)
			if (..())
				return 1

			if (confList["name"])
				src.protected_name = ckey(confList["name"])

			return 0

		proc
			look_for_protected() //Search for a mob in view with the name we are programmed to guard.
				if(src.protected) return //We have someone to protect!
				for (var/mob/living/C in view(7,master))
					if (isdead(C)) //We were too late!
						continue

					var/check_name = C.name
					if(ishuman(C) && C.get_id())
						check_name = C.get_id()?.registered
					if (ckey(check_name) == ckey(src.protected_name))
						src.protected = C
						src.desired_emotion = GUARDING_EMOTION
						C.unlock_medal("Ol' buddy ol' pal", 1)
						src.buddy_is_dork = (C.client && C.client.IsByondMember())
						//if (buddy_is_dork && prob(50))
							//master.speak(pick("I am here to protect...Oh, it's <i>you</i>.", "I have been instructed to guard you. Welp.", "You are now under guard.  I guess."))
						master.speak(pick("I am here to protect you.","I have been instructed to guard you.","You are now under guard.","Come with me if you want to live!"))
						master.point(C, 1)
						break

				return

			drop_arrest_target()
				src.arrest_target = null
				actions.stopId("buddy_cuff", src.master)
				return

			check_buddy()
				//Out of sight, out of mind.
				if(!(protected in view(7,master)))
					return 0
				//Has our buddy been attacked??
				if(protected.lastattacker && (protected.lastattackertime + 40) >= world.time)
					if(protected.lastattacker != protected)
						master.moving = 0
						if (master.mover)
							qdel(master.mover)
						src.arrest_target = protected.lastattacker
						src.follow_attempts = 0
						src.arrest_attempts = 0
						return 1
				return 0

			handle_arrest_function()

				var/datum/computer/file/guardbot_task/security/single_use/beatdown = new
				beatdown.arrest_target = src.arrest_target
				beatdown.mode = 1
				beatdown.arrested_messages = src.arrested_messages
				src.arrest_target = null
				src.master.add_task(beatdown, 1, 0)

				return

	bodyguard/heckle
		name = "heckle"
		task_id = "HECKLE"
		var/global/list/buddy_heckle_phrases = list("I wish we could become better strangers.","You're impossible to underestimate.","You sound like a pizza cutter — all edge and no point.","I think you should carry a potted plant to replace the oxygen you waste.","You're not the dumbest person in this station, but you'd better hope they don't die!","You’re so dense, light bends around you. Fortunately, that keeps us from having to look at you!","I was today years old when I realized I didn’t like you.","Keep rolling your eyes, you might eventually find a brain.","You are more disappointing than an unsalted pretzel.","Hold still. I’m trying to imagine you with personality.","You are like a cloud. When you disappear, it’s a beautiful day.","You make staffies look competent.","Your incompetence makes me appreciate my programmer more.","I’m not a nerd. I’m just smarter than you.","I may love to shop but I will never buy your bull.","I hope both sides of your pillow are warm.","I feel jealous of the people who haven't met you.","Your parents aren't even disappointed in you. They know this is you at your best.","Neeerrd!","Dork!","Hey! Hey! You smell...bad! Really bad!","Hey! You have an odor! A grody one! GRODY NERD ALERT!","Are you as bad at your job as you are at dressing yourself?","You, uh, should probably wash your hair. I think if you took a swim, all the seals would die.")
		var/tmp/initial_seek_complete = 0

		task_act()
			if (..())
				return

			if (src.protected && prob(10))
				master.speak( pick(buddy_heckle_phrases) )
				master.point(src.protected, 1)

		look_for_protected() //Search for a mob in view with the name we are programmed to guard.
			if(src.protected) return //We have someone to protect!
			for (var/mob/living/C in view(7,master))
				if (isdead(C)) //We were too late!
					continue

				var/check_name = C.name
				if(ishuman(C) && C.get_id())
					check_name = C.get_id()?.registered

				if (ckey(check_name) == ckey(src.protected_name))
					src.protected = C
					buddy_is_dork = 1
					//src.desired_emotion = GUARDING_EMOTION
					master.speak("Level 9F [pick("dork","nerd","weenie","doofus","loser","dingus","dorkus")] detected!")
					master.point(C)
					return

				if (!initial_seek_complete)
					initial_seek_complete = 1
					master.scratchpad["targetname"] = ckey(src.protected_name)
					src.master.add_task(/datum/computer/file/guardbot_task/security/seek, 1, 0)


		check_buddy()
			return 0


	bodyguard/cheer_up
		name = "cheer_up"
		task_id = "CHEER_UP"
		var/global/list/buddy_cheer_up_phrases = list("What did one lobster say to the other? Nothing, since they can't talk. If they could, though, probably something about shellfish.","Remember that joke I told you about the chiropractor?  It was about a weak back.","How much does Santa pay to park his sleigh?  Nothing, it's on the house!","A new fish was discovered at the ocean floor composed of a couple sodium molecules.  Scientists have named it 2 Na ","You’re having a heart attack, the dispatcher say that help is going to arrive in a heartbeat.","You shouldn’t wear glasses while playing football. Why? Because it’s a contact sport.","A magician was walking down the street, then he turned into a grocery store. ","Three guys walked into a bar, you’d think at least one of them would have seen it. ","The past, present and future walked into a bar, things got tense. ","I asked my French friend if they like videogames, they said Wii."," RIP boiled water, you will be mist.","Haunted French pancakes give me the crepes.","A guy’s left side was cut off, don’t worry he’s all right now. ","A cow in an earthquake is called a milkshake.","A captain walks into a bar. A nearby salesman quadruples the price for a brand new 'sold-out' sign.","There are only 10 kinds of people in this world: those who understand binary and those who don’t.")
		var/global/list/buddy_cheer_up_starters = list("Two silk worms compete in a race, who won? ","Why did the guardbuddy cross the road? ","What’re caterpillars scared of? ","What’s green and has wheels? ","What did the sea say to another sea? ","Why shouldn't you get close to trees? ","Why are there gates in graveyards? ","What do you call an illegal frog? ","What do you call a pig that does karate?","Why did the bike fall over?  ","Why did the golfer bring two pairs of pants?  ","What did the bartender say to the turkey sandwich when it tried to order a beer?  ","Why do seagulls fly over the sea?  ","Why did the scarecrow win an award?","What has four wheels and flies?","Why do cows have hooves and not feet?","What did the mama cow say to the baby cow?","Why did the two cows not like each other?","Why did the person living in Space Alaska name their dog Frost?","Why don’t pirates take a shower before they walk the plank?","What’s the best thing about Space Switzerland?","My computing software just created a new word!","My New Years' Resolution was to be less condescending. ","Whaddya call a patronising criminal going down a staircase?","What do you get when you cross a wall unit with artificial intelligence?","The opposite of Artificial Intelligence is Real Stupid.","There are two kinds of data scientists. ","What do you do if your guardbuddy catches a virus?")
		var/global/list/buddy_cheer_up_answers = list("None of them, it ended in a tie.","It was programmed by the chicken!","Dog-apillers! ","Grass! I lied about the wheels.","Nothing, they just waved. ","Because they’re pretty shady. ","Because everyone is dying to get there. ","A toad. ","A pork chop!","It was two tired.","In case he got a hole in one.","Sorry, we don’t serve food here.","Because if they flew over the bay, they would be bagels!","Because he was outstanding in his field.","A garbage truck!","They lactose.","It's pasture bedtime.","They had BEEF.","Because Frost bites!","They just wash up on shore.","I don’t know, but the flag is a big plus.","Plagiarism!","Just so you know, condescending is a word that means talking down to people.","A condescending con descending.","Shelf-awareness.","Think about that, meatbag.","1.) Those who can extrapolate from incomplete data.","You give it some Robot-issin!")
		var/tmp/initial_seek_complete = 0

		task_act()
			if (..())
				return

			if (src.protected && prob(5))

				if (prob(40))
					var/buddy_cheer_up_chooser = rand(1, length(buddy_cheer_up_phrases))
					master.speak(buddy_cheer_up_phrases[buddy_cheer_up_chooser])
					master.point(src.protected, 1)
				else
					var/buddy_cheer_up_chooser = rand(1, length(buddy_cheer_up_starters))
					master.speak(buddy_cheer_up_starters[buddy_cheer_up_chooser])
					master.point(src.protected, 1)
					master.speak(buddy_cheer_up_answers[buddy_cheer_up_chooser])



		look_for_protected() //Search for a mob in view with the name we are programmed to guard.
			if(src.protected) return //We have someone to protect!
			for (var/mob/living/C in view(7,master))
				if (isdead(C)) //We were too late!
					continue

				var/check_name = C.name
				if(ishuman(C) && C.get_id())
					check_name = C.get_id()?.registered

				if (ckey(check_name) == ckey(src.protected_name))
					src.protected = C
					buddy_is_dork = 1
					master.speak(pick("Insufficient happiness detected!","Person in need of cheering-up detected!","Coolest person on the station located!","Genius detected!","Wonderful friend detected!","Level 9F Joke-defiency detected!"))

					master.point(C)
					return

				if (!initial_seek_complete)
					initial_seek_complete = 1
					master.scratchpad["targetname"] = ckey(src.protected_name)
					src.master.add_task(/datum/computer/file/guardbot_task/security/seek, 1, 0)


		check_buddy()
			return 0

#undef SEARCH_EMOTION
#undef GUARDING_EMOTION
#undef GUARDING_DORK_EMOTION
#undef CHASING_EMOTION



#define STATE_FINDING_BEACON 0//Byond, enums, lack thereof, etc
#define STATE_PATHING_TO_BEACON 1
#define STATE_AT_BEACON 2
#define STATE_POST_TOUR_IDLE 3

//Neat things we've seen on this trip
#define NT_WIZARD (1<<1)
#define NT_CAPTAIN (1<<2)
#define NT_JONES (1<<3)
#define NT_BEE (1<<4)
#define NT_SECBOT (1<<5)
#define NT_BEEPSKY (1<<6)
#define NT_OTHERBUDDY (1<<7)
#define NT_SPACE (1<<8)
#define NT_DORK (1<<9)
#define NT_CLOAKER (1<<10)
#define NT_GEORGE (1<<11)
#define NT_DRONE (1<<12)
#define NT_AUTOMATON (1<<13)
#define NT_CHEGET (1<<14)
#define NT_GAFFE (1<<15)

#define MAPTEXT_PAUSE (4.5 SECONDS)
#define FOUND_NEAT(FLAG) src.distracted = TRUE; src.neat_things |= FLAG; SPAWN(0)
#define END_NEAT sleep(MAPTEXT_PAUSE*2); src.distracted = FALSE

	tourguide
		name = "tourguide"
		task_id = "TOUR"
		handle_beacons = 1

		var/wait_for_guests = 0		//Wait for people to be around before giving tour dialog?

		var/tmp/state = STATE_FINDING_BEACON
		var/tmp/desired_emotion = "happy"

		var/tmp/list/visited_beacons = list()
		var/tmp/next_beacon_id = "tour0"
		var/tmp/current_beacon_id = null
		var/tmp/turf/current_beacon_loc = null
		var/tmp/awaiting_beacon = 0
		var/tmp/current_tour_text = null
		var/tmp/tour_delay = 0
		var/tmp/neat_things = 0		//Bitfield to mark neat things seen on a tour.
		var/tmp/recent_nav_attempts = 0
		var/tmp/distracted = FALSE

		New()
			..()
			START_TRACKING

		disposing()
			STOP_TRACKING
			..()



#define TOUR_FACE "happy"
#define ANGRY_FACE "angry"

		//Method of operation:
		//Locate starting beacon or last beacon
		//Check name of beacon against list of visited beacons.
		//Interrogate beacon for information string, if any
		//Say information string once our tourgroup (or some random doofus, it doesn't really matter) has arrived.
		//Locate next beacon OR finish if none defined.

		task_act()
			if (..())
				return

			if(master.emotion != desired_emotion)
				master.set_emotion(desired_emotion)

			switch (state)
				if (STATE_FINDING_BEACON)
					if (awaiting_beacon)
						awaiting_beacon--
						return

					if (!next_beacon_id)
						next_beacon_id = initial(next_beacon_id)

					awaiting_beacon = 4

					if (src.distracted)
						awaiting_beacon += 2

					master.post_find_beacon("[next_beacon_id]" || "tour")
					return

				if (STATE_PATHING_TO_BEACON)
					if (!isturf(current_beacon_loc))
						state = STATE_FINDING_BEACON
						return

					if (!src.distracted && prob(20))
						src.look_for_neat_thing()

					if (!master.moving)
						if (awaiting_beacon > 0)
							awaiting_beacon--
							return

						if (current_beacon_loc != master.loc)
							master.navigate_to(current_beacon_loc, max_dist=30)
						else
							state = STATE_AT_BEACON
					return

				if (STATE_AT_BEACON)
					if (wait_for_guests && !locate(/mob/living/carbon) in view(src.master)) //Maybe we shouldn't speak to no-one??
						return	//I realize this doesn't check if they're dead.  Buddies can't always tell, ok!! Maybe if people had helpful power lights too

					speak_with_pause(current_tour_text, yield_to_neat=TRUE)

					if (next_beacon_id)
						state = STATE_FINDING_BEACON
						awaiting_beacon = max(awaiting_beacon, 1) //This will just serve as a delay so the buddy isn't zipping around at light speed between stops.
					else
						state = STATE_POST_TOUR_IDLE
						tour_delay = 30
						master.speak("And that concludes the tour session.  Please visit the gift shop on your way out.")
					return

				if (STATE_POST_TOUR_IDLE)
					if (tour_delay-- > 0)
						return

					next_beacon_id = initial(next_beacon_id)
					state = STATE_FINDING_BEACON
					neat_things = 0

			return

		// take a text string and parse out pauses
		proc/speak_with_pause(text, yield_to_neat=FALSE)
			var/delays = 0
			var/proc_delay = master.base_tick_spacing*(2**(master.processing_tier-1))

			SPAWN(0) // do not delay doWork
				//Delay for active destraction
				while(yield_to_neat && distracted)
					awaiting_beacon++
					sleep(5 SECONDS)
					delays++
					if( delays > 10 )
						distracted = FALSE
						break

				if (ckey(text))
					if (findtext(text, "|p")) //There are pauses present! So, um, pause.
						var/list/text_with_pauses = splittext(text, "|p")
						if(yield_to_neat)
							awaiting_beacon = round(length(text_with_pauses)*(MAPTEXT_PAUSE/proc_delay))+1 //factor in delay on pauses in speech

							for (var/tour_line in text_with_pauses)
								if (!ckey(tour_line) || !master)
									break

								//Delay for sudden destraction
								while(yield_to_neat && distracted)
									awaiting_beacon++
									sleep(5 SECONDS)
									delays++
									if( delays > 10 )
										distracted = FALSE
										break

								speak_with_maptext(copytext(html_encode(tour_line), 1, MAX_MESSAGE_LEN), TRUE)
								sleep(5 SECONDS)
					else
						speak_with_maptext(copytext(html_encode(current_tour_text), 1, MAX_MESSAGE_LEN), TRUE)


#define MAPTEXT_SLICE_SIZE 100 // Reduce maptext slice size to avoid 4 rows
		proc/speak_with_maptext(text, pause_for_beacon=FALSE)
			var/start = 0
			var/slice = 0
			var/remaining = length(text)
			var/proc_delay = master.base_tick_spacing*(2**(master.processing_tier-1))

			if(remaining <= MAPTEXT_SLICE_SIZE)
				master.speak(text)
				return

			if(pause_for_beacon)
				src.awaiting_beacon += round((remaining / MAPTEXT_SLICE_SIZE)*(MAPTEXT_PAUSE/proc_delay))

			master.speak(text, just_chat=TRUE)
			while(remaining - slice > MAPTEXT_SLICE_SIZE)
				slice = findlasttext(text," ", slice+MAPTEXT_SLICE_SIZE, slice+1)
				if(!slice)
					break
				master.speak(copytext(text,start+1,slice), just_float = TRUE)
				start = slice
				sleep(MAPTEXT_PAUSE)

			master.speak(copytext(text,start), just_float = TRUE)
#undef MAPTEXT_SLICE_SIZE

		attack_response(mob/attacker as mob)
			if(..())
				return

			src.master.set_emotion(ANGRY_FACE)
			src.speak_with_maptext(pick("Rude!","That is not acceptable behavior!","This is a tour, not a fight factory!","You have been ejected from the tourgroup for: Roughhousing.  Please be aware that tour sessions are non-refundable."))
			var/datum/computer/file/guardbot_task/security/single_use/beatdown = new
			beatdown.arrest_target = attacker
			beatdown.mode = 1
			src.master.add_task(beatdown, 1, 0)
			return

		task_input(input)
			if(..()) return

			switch(input)
				if("snooze")
					src.awaiting_beacon = 0
					src.next_beacon_id = null

				if("path_error","path_blocked")
					if (recent_nav_attempts++ > 10)
						recent_nav_attempts = 0
						awaiting_beacon = 10
			return

		receive_signal(datum/signal/signal)
			if(..())
				return

			var/recv = signal.data["beacon"]
			var/valid = signal.data["tour"]
			if(!awaiting_beacon || !recv || !valid || state != STATE_FINDING_BEACON)
				return


			if(recv == next_beacon_id)	// if the recvd beacon location matches the set destination
										// then we will navigate there
				current_beacon_id = next_beacon_id
				current_beacon_loc = signal.source.loc
				next_beacon_id = signal.data["next_tour"]
				awaiting_beacon = 0

				src.state = STATE_PATHING_TO_BEACON

				if (ckey(signal.data["desc"]))
					current_tour_text = signal.data["desc"]
				else
					current_tour_text = null

			return

		proc/look_for_neat_thing()
			var/area/spaceArea = get_area(src.master)
			if (!(src.neat_things & NT_SPACE) && spaceArea && spaceArea.name == "Space" && !istype(get_turf(src.master), /turf/simulated/shuttle))
				FOUND_NEAT(NT_SPACE)
					src.speak_with_maptext(pick("While you find yourself surrounded by space, please try to avoid the temptation to inhale any of it.  That doesn't work.",\
					"Space: the final frontier.  Oh, except for time travel and any other dimensions.  And frontiers on other planets, including other planets in those other dimensions and times.  Maybe I should stick with \"space: a frontier.\"",\
					"Those worlds in space are as countless as all the grains of sand on all the beaches of the earth. Each of those worlds is as real as ours and every one of them is a succession of incidents, events, occurrences which influence its future. Countless worlds, numberless moments, an immensity of space and time.  This Sagan quote and others like it are available on mugs at the gift shop.",\
					"Please keep hold of the station at all times while in an exposed area.  The same principle does not apply to your breath without a mask.  Your lungs will pop like bubblegum.  Just a heads up."))
					END_NEAT
				return

			for (var/atom/movable/AM in view(7, master))
				if (ishuman(AM))
					var/mob/living/carbon/human/H = AM
					if (!(src.neat_things & NT_GAFFE) && !isdead(H) && !H.sight_check(1))
						FOUND_NEAT(NT_GAFFE)
							var/emotion
							src.speak_with_maptext("Ah! As you can see here--")

							sleep(4 SECOND)
							emotion = desired_emotion //We're going to make him sad until the end of this spawn, ok.
							desired_emotion = "sad"
							master.set_emotion(desired_emotion)
							src.speak_with_maptext("OH! Sorry! Sorry, [H.name]! I didn't mean it that way!")
							sleep(4.5 SECONDS)
							var/mob/living/carbon/human/deaf_person = null
							for (var/mob/living/carbon/human/maybe_deaf in view(7, master))
								if (!isdead(maybe_deaf) && !maybe_deaf.hearing_check(1))
									deaf_person = maybe_deaf
									break

							if (deaf_person)
								src.speak_with_maptext("I'll just narrate things so you can all hear it--")
								sleep(4 SECONDS)
								if (deaf_person == H)
									src.speak_with_maptext("SORRY [H] I DIDN'T MEAN THAT EITHER AAAA")
								else
									src.speak_with_maptext("Oh! Sorry! Sorry, [deaf_person.name]!! I didn't mean that that way eith-wait um.")
									sleep(1 SECOND)
									src.master.visible_message("<b>[src.master]</b> begins signing frantically!  Despite, um, robot hands not really being equipped for sign language.")

							sleep(5 SECONDS)
							src.distracted = FALSE
							sleep(5 SECONDS)
							desired_emotion = emotion
							master.set_emotion(desired_emotion)
							END_NEAT

					if (!(src.neat_things & NT_CLOAKER) && H.invisibility > INVIS_NONE)
						FOUND_NEAT(NT_CLOAKER)
							src.speak_with_maptext("As a courtesy to other tourgroup members, you are requested, though not required, to deactivate any cloaking devices, stealth suits, light redirection field packs, and/or unholy blood magic.")
							END_NEAT
						return

					if (!(src.neat_things & NT_WIZARD) && istype(H.wear_suit, /obj/item/clothing/suit/wizrobe) )
						FOUND_NEAT(NT_WIZARD)
							src.speak_with_maptext( pick("Look, group, a wizard!  Please be careful, space wizards can be dangerous.","Ooh, a real space wizard!  Look but don't touch, folks!","Space wizards are highly secretive, especially regarding the nature of their abilities.  Current speculation is that their \"magic\" is really the application of advanced technologies or artifacts.") )
							END_NEAT
						return

					if (!(src.neat_things & NT_CAPTAIN) && istype(H.head, /obj/item/clothing/head/caphat))
						FOUND_NEAT(NT_CAPTAIN)
							src.speak_with_maptext("Good day, Captain!  You're looking [pick("spiffy","good","swell","proper","professional","prim and proper", "spiffy", "ultra-spiffy")] today.")
							END_NEAT
						return

					if (!(src.neat_things & NT_DORK) && (H.client && H.client.IsByondMember() && prob(5)))// || (H.ckey in Dorks))) //If this is too mean to clarks, remove that part I guess
						FOUND_NEAT(NT_DORK)
							var/insult = pick("dork","nerd","weenie","doofus","loser","dingus","dorkus")
							var/insultphrase = "And if you look to--[insult] alert!  [pick("Huge","Total","Mega","Complete")] [insult] detected! Alert! Alert! [capitalize(insult)]! "

							insultphrase += copytext(insult,1,2)
							var/i = rand(3,7)
							while (i-- > 0)
								insultphrase += copytext(insult,2,3)
							insultphrase += "[copytext(insult,3)]!!"

							src.speak_with_maptext(insultphrase)
							master.point(H)
							END_NEAT
						return

				else if (!(src.neat_things & NT_JONES) && istype(AM, /obj/critter/cat) && AM.name == "Jones")
					FOUND_NEAT(NT_JONES)
						var/obj/critter/cat/jones = AM
						src.speak_with_maptext("And over here is the ship's cat, J[jones.alive ? "ones! No spacecraft is complete without a cat!" : "-oh mercy, MOVING ON, MOVING ON"]")
						END_NEAT
					return

				else if (istype(AM, /obj/critter/domestic_bee) && AM:alive && !(src.neat_things & NT_BEE))
					FOUND_NEAT(NT_BEE)
						if (istype(AM, /obj/critter/domestic_bee/trauma))
							src.speak_with_maptext("Look, team, a domestic space bee!  This happy creature--oh dear.  Hold on, please.")
							var/datum/computer/file/guardbot_task/security/single_use/emergency_hug = new
							emergency_hug.hug_target = AM
							src.master.add_task(emergency_hug, 1, 0)
							END_NEAT
							return

						sleep(5)
						src.speak_with_maptext("Look, team, a domestic space bee!  This happy creature is the result of decades of genetic research!")
						sleep(5)
						switch (rand(1,5))
							if (1)
								src.speak_with_maptext("Fun fact: Domestic space bee DNA is [rand(1,17)]% [pick("dog", "human", "cat", "honeybee")]")

							if (2)
								src.speak_with_maptext("Fun fact: Domestic space bees are responsible for over [rand(45,67)]% of all honey production outside of Earth!")

							if (3)
								src.speak_with_maptext("Fun fact: Domestic space bees are very well adapted to accidental space exposure, and can survive in that environment for upwards of [pick("ten hours", "two days", "42 minutes", "three-score ke", "one-and-one-half nychthemeron")].")

							if (4)
								src.speak_with_maptext("Fun fact: Domestic space bee DNA is protected by U.S. patent number [rand(111,999)],[rand(111,999)],[rand(555,789)].")

							if (5)
								src.speak_with_maptext("Fun fact: The average weight of a domestic space bee is about [pick("10 pounds","4.54 kilograms", "25600 drams", "1.42857143 cloves", "145.833333 troy ounces")].")
						END_NEAT

				else if (istype(AM, /obj/critter/dog/george) && !(src.neat_things & NT_GEORGE))
					FOUND_NEAT(NT_GEORGE)
						src.speak_with_maptext("Why, if it isn't beloved station canine, George!  Who's a good doggy?  You are!  Yes, you!")
						END_NEAT

				else if (istype(AM, /obj/critter/gunbot/drone) && !(src.neat_things & NT_DRONE))
					FOUND_NEAT(NT_DRONE)
						src.speak_with_maptext( pick("Oh dear, a syndicate autonomous drone!  These nasty things have been shooting up innocent space-folk for a couple of years now.", "Watch out, folks!  That's a syndicate drone, they're nasty buggers!", "Ah, a syhndicate drone!  They're made in a secret factory, one located at--oh dear, we better get hurrying before it becomes upset.", "Watch out, that's a syndicate drone!  They're made in a secret factory. There was a guy who knew where it was on my first tour, but he took the secret...to his grave!!  Literally.  It's with him.  In his crypt.") )
						END_NEAT

				else if (!(src.neat_things & NT_AUTOMATON) && istype(AM, /obj/critter/automaton))
					FOUND_NEAT(NT_AUTOMATON)
						src.speak_with_maptext("This here is some kind of automaton.  This, uh, porcelain-faced, click-clackity metal man.")
						. = "Why [istype(get_area(AM), /area/solarium) ? "am I" : "is this"] here?"
						sleep(6 SECONDS)
						src.speak_with_maptext(.)
						END_NEAT

				else if (istype(AM, /obj/machinery/bot))
					if (istype(AM, /obj/machinery/bot/secbot))
						if (AM.name == "Officer Beepsky" && !(src.neat_things & NT_BEEPSKY))
							FOUND_NEAT(NT_BEEPSKY)
								src.speak_with_maptext("And here comes Officer Beepsky, the proud guard of this station. Proud.")
								sleep(5 SECONDS)
								src.speak_with_maptext("Not at all terrible.  No Sir.  Not at all.")
								if (prob(10))
									sleep(6.5 SECONDS)
									src.speak_with_maptext("Well okay, maybe a little.")
								END_NEAT

						else if (!(src.neat_things & NT_SECBOT))
							FOUND_NEAT(NT_SECBOT)
								src.speak_with_maptext("And if you look over now, you'll see a securitron, an ace security robot originally developed \"in the field\" from spare parts in a security office!")
								END_NEAT

					else if (istype(AM, /obj/machinery/bot/guardbot) && AM != src.master)
						var/obj/machinery/bot/guardbot/otherBuddy = AM
						if (!(src.neat_things & NT_CAPTAIN) && istype(otherBuddy.hat, /obj/item/clothing/head/caphat))
							FOUND_NEAT(NT_CAPTAIN)
								src.speak_with_maptext("Good day, Captain!  You look a little different today, did you get a haircut?")
								var/otherBuddyID = otherBuddy.net_id
								//Notify other buddy
								sleep(1 SECOND)
								if (src.master)
									src.master.post_status("[otherBuddyID]", "command", "captain_greet")
								END_NEAT

						else if (!(src.neat_things & NT_WIZARD) && istype(otherBuddy.hat, /obj/item/clothing/head/wizard))
							FOUND_NEAT(NT_WIZARD)
								src.speak_with_maptext("Look, a space wizard!  Please stand back, I am going to attempt to communicate with it.")
								sleep(5 SECONDS)
								src.speak_with_maptext("Hello, Mage, Seer, Wizard, Wizzard, or other magic-user.  We mean you no harm!  We ask you humbly for your WIZARDLY WIZ-DOM.")
								if (prob(25))
									sleep(6 SECONDS)
									src.speak_with_maptext("We hope that we aren't disrupting any sort of wiz-biz or wizness deal.")
								//As before, notify the other buddy
								var/otherBuddyID = otherBuddy.net_id
								if (src.master)
									src.master.post_status("[otherBuddyID]", "command", "wizard_greet")
								END_NEAT

						else if (!(src.neat_things & NT_OTHERBUDDY))
							FOUND_NEAT(NT_OTHERBUDDY)
								if (istype(otherBuddy, /obj/machinery/bot/guardbot/future))
									src.speak_with_maptext("The PR line of personal robot has been--wait! Hold the phone! Is that a PR-7? Oh man, I feel old!")

								else if (istype(otherBuddy, /obj/machinery/bot/guardbot/old/tourguide))
									src.master.visible_message("<b>[master]</b> waves at [otherBuddy].")

								else if (istype(otherBuddy, /obj/machinery/bot/guardbot/soviet))
									src.speak_with_maptext("That's...that's one of those eastern bloc robuddies.  Um...hello?")
									src.master.visible_message("<b>[master]</b> gives [otherBuddy] a slow, confused wave.")

								else
									src.speak_with_maptext("The PR line of personal robot has been Thinktronic Data Systems' flagship robot line for over 15 years.  It's easy to see their appeal!")
									sleep(5 SECONDS)
									switch (rand(1,4))
										if (1)
											src.speak_with_maptext("Buddy Fact: In 2051, Robuddies were conclusively determined to have a[prob(40) ? "t least three-fourths of a" : ""] soul.")
										if (2)
											src.speak_with_maptext("Buddy Fact: Robuddies cannot jump.  We just can't, sorry!")
										if (3)
											src.speak_with_maptext("Buddy Fact: Our hug protocols have been extensively revised through thousands of rounds of testing and simulation to deliver Peak Cuddle.")
										if (4)
											src.speak_with_maptext("Buddy Fact: Robuddies are programmed to be avid fans of hats and similar headgear.")
									sleep(5 SECONDS)
								END_NEAT

				else if ((istype(AM, /obj/item/luggable_computer/cheget) || istype(AM, /obj/machinery/computer3/luggable/cheget)) && !(src.neat_things & NT_CHEGET))
					FOUND_NEAT(NT_CHEGET)
						src.speak_with_maptext( pick("And over there is--NOTHING.  Not a thing.  Let's continue on with the tour.", "Please ignore the strange briefcase, is what I would say, were there a strange briefcase.  But there is not, and even if there was you should ignore it.","This is just a reminder that station crew are not to handle Soviet materials, per a whole bunch of treaties and negotiations.") )
						AM.visible_message("<b>[AM]</b> bloops sadly.")
						playsound(AM.loc, prob(50) ? 'sound/machines/cheget_sadbloop.ogg' : 'sound/machines/cheget_somberbloop.ogg', 50, 1)
						END_NEAT
			return

//Be kind, undefine...d
#undef STATE_FINDING_BEACON
#undef STATE_PATHING_TO_BEACON
#undef STATE_AT_BEACON
#undef STATE_POST_TOUR_IDLE

#undef TOUR_FACE
#undef ANGRY_FACE

#undef NT_WIZARD
#undef NT_CAPTAIN
#undef NT_JONES
#undef NT_BEE
#undef NT_SECBOT
#undef NT_BEEPSKY
#undef NT_OTHERBUDDY
#undef NT_SPACE
#undef NT_DORK
#undef NT_CLOAKER
#undef NT_GEORGE
#undef NT_DRONE
#undef NT_AUTOMATON
#undef NT_CHEGET
#undef NT_GAFFE

#undef MAPTEXT_PAUSE
#undef FOUND_NEAT
#undef END_NEAT

	bedsheet_handler
		name = "confusion"
		task_id = "HUH"
		var/announced = 0
		var/escape_counter = 4

		task_act()
			if (..())
				return

			if (master.bedsheet != 1)
				src.master.remove_current_task()
				return

			if (!announced)
				announced = 1
				master.speak(pick("Hey, who turned out the lights?","Error: Visual sensor impaired!","Whoa hey, what's the big deal?","Where did everyone go?"))

			if (escape_counter-- > 0)
				flick("robuddy-ghostfumble", master)
				master.visible_message("<span class='alert'>[master] fumbles around in the sheet!</span>")
			else
				master.visible_message("[master] cuts a hole in the sheet!")
				master.speak(pick("Problem solved.","Oh, alright","There we go!"))
				master.bedsheet = 2
				master.overlays.len = 0
				master.hat_shown = 0
				master.UpdateIcon()
				src.master.remove_current_task()
				return

	threat_scan
		name = "threatscan"
		task_id = "SCAN"
		var/weapon_access = access_carrypermit

		task_act()
			if (..())
				return

			var/mob/living/newThreat = look_for_threat()
			if (istype(newThreat))
				master.scratchpad["threat"] = newThreat
				master.scratchpad["threat_time"] = "[time2text(world.timeofday, "hh:mm:ss")]"

				src.master.remove_current_task()
				return

			return

		proc
			look_for_threat()
				for (var/mob/living/carbon/C in view(7,master)) //Let's find us a criminal
					if ((C.stat) || (C.hasStatus("handcuffed")))
						continue

					var/threat = 0
					if(ishuman(C))
						threat = src.assess_threat_potential(C)
				//	else
				//		if(isalien(C))
				//			threat = 9

					if(threat >= 4)
						master.scratchpad["threat_level"] = threat
						return C

				return null

			assess_threat_potential(mob/living/carbon/human/potentialThreat as mob)
				var/threatcount = 0


				var/obj/item/card/id/worn_id = potentialThreat.equipped()
				if (!istype(worn_id))
					worn_id = potentialThreat.wear_id

				if(worn_id)
					if(weapon_access in worn_id.access)
						return 0

				if(istype(potentialThreat.l_hand, /obj/item/gun) || istype(potentialThreat.l_hand, /obj/item/baton) || istype(potentialThreat.l_hand, /obj/item/sword))
					threatcount += 4

				if(istype(potentialThreat.r_hand, /obj/item/gun) || istype(potentialThreat.r_hand, /obj/item/baton) || istype(potentialThreat.r_hand, /obj/item/sword))
					threatcount += 4

				if (ishuman(potentialThreat))
					if(istype(potentialThreat:belt, /obj/item/gun) || istype(potentialThreat:belt, /obj/item/baton) || istype(potentialThreat:belt, /obj/item/sword))
						threatcount += 2

					if(istype(potentialThreat:wear_suit, /obj/item/clothing/suit/wizrobe))
						threatcount += 4

					if(istype(potentialThreat.mutantrace, /datum/mutantrace/abomination))
						return 5

				return threatcount

/*
 *	Guardbot Parts
 */

/obj/item/guardbot_core
	name = "Guardbuddy mainboard"
	desc = "The primary circuitry of a PR-6S Guardbuddy."
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "robuddy_core-6"
	mats = 6
	w_class = W_CLASS_SMALL
	var/created_default_task = null //Default task path of result
	var/datum/computer/file/guardbot_task/created_model_task = null
	var/created_name = "Guardbuddy" //Name of resulting guardbot
	var/buddy_model = 6 //What type of guardbot does this belong to (Default is PR-6, but Murray and Marty are PR-4s)

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/pen))
			if (created_name != initial(created_name))
				boutput(user, "<span class='alert'>This robot has already been named!</span>")
				return

			var/t = input(user, "Enter new robot name", src.name, src.created_name) as text
			if(t && t != src.name && t != src.created_name)
				phrase_log.log_phrase("bot-guard", t)
			t = copytext(html_encode(t), 1, MAX_MESSAGE_LEN)
			if (!t)
				return
			if (!in_interact_range(src, user) && src.loc != user)
				return

			src.created_name = t
		else
			..()

/obj/item/guardbot_frame
	name = "Guardbuddy frame"
	desc = "The external casing of a PR-6S Guardbuddy."
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "robuddy_frame-6-1"
	mats = 5
	var/stage = 1
	var/created_name = "Guardbuddy" //Still the name of resulting guardbot
	var/created_default_task = null //Default task path of result
	var/datum/computer/file/guardbot_task/created_model_task = null //Initial model task of result.
	var/obj/created_module = null //Tool module of result.
	var/obj/item/cell/created_cell = null //Energy cell of result.
	var/buddy_model = 6 //What type of guardbot does this belong to (Default is PR-6, but Murray and Marty are PR-4s)
	var/spawned_bot_type = /obj/machinery/bot/guardbot

	New()
		..()
		SPAWN(0.6 SECONDS)
			src.icon_state = "robuddy_frame-[buddy_model]-[stage]"
			if(src.stage >= 2)
				src.created_cell = new
				src.created_cell.charge = 0.9 * src.created_cell.maxcharge
		return


	//Frame -> Add cell -> Add core -> Add arm -> Done. Then add tool. Or gun.
	attackby(obj/item/W, mob/user)
		if ((istype(W, /obj/item/guardbot_core)))
			if(W:buddy_model != src.buddy_model)
				boutput(user, "<span class='alert'>That core board is for a different model of robot!</span>")
				return
			if(!created_cell || stage != 2)
				boutput(user, "<span class='alert'>You need to add a power cell first!</span>")
				return
			src.stage = 3
			src.icon_state = "robuddy_frame-[buddy_model]-3"
			if(W:created_name)
				src.created_name = W:created_name
			if(W:created_default_task)
				src.created_default_task = W:created_default_task
			if(W:created_model_task)
				src.created_model_task = W:created_model_task
			boutput(user, "You add the core board to  [src]!")
			qdel(W)

		else if((istype(W, /obj/item/cell)) && stage == 1 && !created_cell)
			user.drop_item()

			W.set_loc(src)
			src.created_cell = W
			src.stage = 2
			src.icon_state = "robuddy_frame-[buddy_model]-2"
			boutput(user, "You add the power cell to [src]!")


		else if (istype(W, /obj/item/parts/robot_parts/arm/) && src.stage == 3)
			src.stage++
			boutput(user, "You add the robot arm to [src]!")
			qdel(W)

			var/obj/machinery/bot/guardbot/newbot = new src.spawned_bot_type (get_turf(src))
			if(newbot.cell)
				qdel(newbot.cell)
			newbot.cell = src.created_cell
			newbot.setup_default_tool_path = null
			newbot.cell.set_loc(newbot)

			if(src.created_default_task)
				newbot.setup_default_startup_task = src.created_default_task

			// Everyone gets a new gunt
			newbot.tool = new /obj/item/device/guardbot_tool/gun
			newbot.tool.set_loc(newbot)
			newbot.tool.master = newbot

			newbot.locked = 0

			if(src.created_model_task)
				newbot.model_task = src.created_model_task
				newbot.model_task.master = newbot
			newbot.name = src.created_name

			qdel(src)
			return

		else
			spawn(0)
				..()

	Exited(Obj, newloc)
		. = ..()
		if(Obj == src.created_cell)
			src.created_cell = null


//The Docking Station.  Recharge here!
/obj/machinery/guardbot_dock
	name = "docking station"
	desc = "A recharging and command station for PR-6S Guardbuddies."
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "robuddycharger0"
	mats = 8
	anchored = 1
	var/panel_open = 0
	var/autoeject = 0 //1: Eject fully charged robots automatically. 2: Eject robot when living carbon mob is in view.
	var/frequency = FREQ_BUDDY
	var/net_id = null //What is our network id???
	var/net_number = 0
	var/host_id = null //Who is linked to us?
	var/timeout = 45
	var/timeout_alert = 0
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WIRECUTTERS | DECON_MULTITOOL | DECON_DESTRUCT
	var/obj/machinery/bot/guardbot/current = null
	var/obj/machinery/power/data_terminal/link = null

	//A reset button is useful for when the system gets all confused.
	var/last_reset = 0 //Last world.time we were manually reset.

	New()
		..()
		SPAWN(0.8 SECONDS)
			if(!src.net_id)
				src.net_id = generate_net_id(src)
			src.AddComponent(/datum/component/packet_connected/radio, null, frequency, net_id, "receive_signal", FALSE, "recharge", FALSE)
			if(!src.link)
				var/turf/T = get_turf(src)
				var/obj/machinery/power/data_terminal/test_link = locate() in T
				if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
					src.link = test_link
					src.link.master = src

		return


	attack_hand(mob/user)
		if(..() || status & NOPOWER)
			return

		src.add_dialog(user)

		var/dat = "<html><head><title>PR-6S Docking Station</title></head><body>"

		var/readout_color = "#000000"
		var/readout = "ERROR"
		if(src.host_id)
			readout_color = "#33FF00"
			readout = "OK CONNECTION"
		else
			readout_color = "#F80000"
			readout = "NO CONNECTION"

		dat += "Host Connection: "
		dat += "<table border='1' style='background-color:[readout_color]'><tr><td><font color=white>[readout]</font></td></tr></table><br>"

		dat += "<a href='?src=\ref[src];reset=1'>Reset Connection</a><br>"

		if (src.panel_open)
			dat += "<br>Configuration Switches:<br><table border='1' style='background-color:#7A7A7A'><tr>"
			for (var/i = 8, i >= 1, i >>= 1)
				var/styleColor = (net_number & i) ? "#60B54A" : "#CD1818"
				dat += "<td style='background-color:[styleColor]'><a href='?src=\ref[src];dipsw=[i]' style='color:[styleColor]'>##</a></td>"

			dat += "</tr></table>"

		user.Browse(dat,"window=guarddock;size=245x282")
		onclose(user,"guarddock")
		return

	Topic(href, href_list)
		if(..())
			return

		src.add_dialog(usr)

		if (href_list["reset"])
			if(last_reset && (last_reset + GUARDBOT_DOCK_RESET_DELAY >= world.time))
				return

			if(!host_id)
				return

			src.last_reset = world.time
			var/rem_host = src.host_id
			src.host_id = null
			src.post_wire_status(rem_host, "command","term_disconnect")
			SPAWN(0.5 SECONDS)
				src.post_wire_status(rem_host, "command","term_connect","device","PNET_PR6_CHARG")

			src.updateUsrDialog()
			return

		src.add_fingerprint(usr)
		return

	receive_signal(datum/signal/signal)
		if(status & NOPOWER)
			return

		if(!signal || signal.encryption || !signal.data["sender"])
			return

		var/target = signal.data["sender"]
		if(signal.transmission_method == TRANSMISSION_WIRE)
			if((signal.data["address_1"] == "ping") && ((signal.data["net"] == null) || ("[signal.data["net"]]" == "[src.net_number]")) && target)
				SPAWN(0.5 SECONDS) //Send a reply for those curious jerks
					src.post_wire_status(target, "command", "ping_reply", "device", "PNET_PR6_CHARG", "netid", src.net_id, "net", src.net_number)
				return
			if(signal.data["address_1"] != src.net_id || !target)
				return

			var/sigcommand = lowertext(signal.data["command"])
			if(!sigcommand || !signal.data["sender"])
				return

			switch(sigcommand)
				if("term_connect") //Terminal interface stuff.
					if(target == src.host_id)
						src.host_id = null
						src.post_wire_status(target, "command","term_disconnect")
						return

					src.timeout = initial(src.timeout)
					src.timeout_alert = 0
					src.host_id = target
					if(signal.data["data"] != "noreply")
						src.post_wire_status(target, "command","term_connect","data","noreply","device","PNET_PR6_CHARG")
					SPAWN(0.2 SECONDS) //Sign up with the driver (if a mainframe contacted us)
						src.post_wire_status(target,"command","term_message","data","command=register&status=[current ? current.net_id : "nobot"]")
					src.updateUsrDialog()
					return

				if("term_message","term_file")
					if(target != src.host_id) //Huh, who is this?
						return

					var/list/data = params2list(signal.data["data"])
					if(!data)
						return
					switch(data["command"])
						if("status") //Status of connected bot.
							var/status = "command=reply"
							if(!src.current)
								status += "&status=nobot"
							else
								status += "&status=[current.net_id]"
								var/botcharge = null
								if(src.current.cell)
									botcharge = "[round((src.current.cell.charge/src.current.cell.maxcharge)*100)]"
								else
									botcharge = "nocell"
								status += "&charge=[botcharge]"

								var/bottool = null
								if(src.current.tool)
									bottool = src.current.tool.tool_id
								else
									bottool = "NONE"
								status += "&tool=[bottool]"

								if(current.model_task)
									status += "&deftask=[current.model_task.task_id]"
								else
									status += "&deftask=NONE"

								if(current.task)
									status += "&curtask=[current.task.task_id]"
								else
									status += "&curtask=NONE"

								//status += "&botid=[current.net_id]"

							src.post_wire_status(target,"command","term_message","data",status)

							return

						if("eject") //Eject current bot
							if(!src.current)
								src.post_wire_status(target,"command","term_message","data","command=status&status=nobot")
								return

							src.eject_robot() //eject_robot alerts the host on its own
							return

						if("upload")
							if(!src.current)
								src.post_wire_status(target,"command","term_message","data","command=status&status=nobot")
								return
							var/datum/computer/file/guardbot_task/newtask = signal.data_file
							if(!istype(newtask))
								src.post_wire_status(target,"command","term_message","data","command=status&status=badtask")
								return

							newtask = newtask.copy_file() //Original one will be deleted with the signal.
							//Clear other tasks?
							var/overwrite = text2num_safe(data["overwrite"])
							if(isnull(overwrite))
								overwrite = 0

							//Replace model (default task)?
							var/model = text2num_safe(data["newmodel"])
							if(isnull(model))
								model = 0

							var/result = upload_task(newtask, overwrite, model)
							if(result)
								src.post_wire_status(target,"command","term_message","data","command=status&status=upload_success")
							else
								src.post_wire_status(target,"command","term_message","data","command=status&status=badtask")
								qdel(newtask)
							return

						if("download")
							if(!src.current)
								src.post_wire_status(target,"command","term_message","data","command=status&status=nobot")
								return

							var/datum/computer/file/guardbot_task/task_copy
							if (text2num_safe(data["model"]) != null)
								if (src.current.model_task)
									task_copy = src.current.model_task.copy_file()
							else
								if (src.current.task)
									task_copy = src.current.task.copy_file()

							if (task_copy)
								var/datum/signal/newsignal = get_free_signal()
								newsignal.source = src
								newsignal.transmission_method = TRANSMISSION_WIRE
								newsignal.data = list("address_1" = target, "command"="term_file", "data", "command=taskfile", "sender" = src.net_id)

								newsignal.data_file = task_copy

								SPAWN(0.2 SECONDS)
									src.link.post_signal(src, newsignal)

							else
								src.post_wire_status(target, "command", "term_message", "data", "command=status&status=notask")

							return

						if("taskinq") //Task inquiry.
							if(!src.current)
								src.post_wire_status(target,"command","term_message","data","command=status&status=nobot")
								return

							var/task_reply = "command=trep"
							if(current.model_task)
								task_reply += "&deftask=[current.model_task.task_id]"
							else
								task_reply += "&deftask=NONE"

							if(current.task)
								task_reply += "&curtask=[current.task.task_id]"
							else
								task_reply += "&curtask=NONE"

							src.post_wire_status(target,"command","term_message","data",task_reply)
							return

						if("wipe") //Clear tasks of current bot
							if(!src.current)
								src.post_wire_status(target,"command","term_message","data","command=status&status=nobot")
								return

							src.current.add_task(null, 0, 1) //No new task, normal priority, wipe all others.
							if(src.current.model_task)
								qdel(src.current.model_task)
							if(src.current.task)
								qdel(src.current.task)
							src.post_wire_status(target,"command","term_message","data","command=status&status=wipe_success")
							return

						if("set_freq") //Set control or beacon frequency of current bot
							if(!src.current)
								src.post_wire_status(target,"command","term_message","data","command=status&status=nobot")
								return

							var/newfreq = text2num_safe(data["freq"])
							if(!newfreq || newfreq != sanitize_frequency(newfreq))
								src.post_wire_status(target,"command","term_message","data","command=status&status=bad_freq")
								return

							var/freqtype = data["freq_type"]
							switch(freqtype)
								if("control")
									src.current.set_control_freq(newfreq)
									src.post_wire_status(target,"command","term_message","data","command=status&status=set_freq_success")
									return
								if("beacon")
									src.current.set_beacon_freq(newfreq)
									src.post_wire_status(target,"command","term_message","data","command=status&status=set_freq_success")
									return
								else
									src.post_wire_status(target,"command","term_message","data","command=status&status=bad_freq_type")
									return

					return

				if("term_ping")
					if(target != src.host_id)
						return
					if(signal.data["data"] == "reply")
						src.post_wire_status(target, "command","term_ping")
					src.timeout = initial(src.timeout)
					src.timeout_alert = 0
					return

				if("term_disconnect")
					if(target == src.host_id)
						src.host_id = null
					src.timeout = initial(src.timeout)
					src.timeout_alert = 0
					return


			return
		else
			if( (signal.data["address_tag"] == "recharge") && !src.current)
				var/turf/T = get_turf(src)
				if(!T) return

				var/to_send = signal.data["sender"]
				SPAWN(rand(4,6)) //So robots don't swarm one of the stations.
					src.post_status(to_send, "command","recharge_src", "data", "x=[T.x]&y=[T.y]")

		return

	MouseDrop_T(obj/O as obj, mob/user as mob)
		if(user.stat || BOUNDS_DIST(user, src) > 0)
			return
		if(istype(O, /obj/machinery/bot/guardbot) && !src.current && !O:charge_dock)
			if(O.loc != src.loc) return
			src.connect_robot(O)
			user.visible_message("[user] plugs [O] into the docking station!","You plug [O] into the docking station!")
			//if(!O:idle)
			//	O:snooze()


		return

	process()
		. = ..()
		if(current)
			if((status & NOPOWER) || !current.cell || (current.loc != src.loc))
				eject_robot()
				return

			current.cell.give(200 + (current.cell.percent() < 25) ? 50 : 0)
			use_power(275)
			src.icon_state = "robuddycharger1"

			if((src.autoeject == 1) && (current.cell.charge >= current.cell.maxcharge) )
				eject_robot()
			else if ((src.autoeject == 2 || src.autoeject == 3) && (current.cell.charge >= current.cell.maxcharge) )
				for (var/mob/living/carbon/M in view(7, src))
					if (M.stat) continue
					eject_robot()
					break


		if(src.host_id)

			if(src.timeout == 0)
				src.post_wire_status(host_id, "command","term_disconnect","data","timeout")
				src.host_id = null
				src.updateUsrDialog()
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
			else
				src.timeout--
				if(src.timeout <= 5 && !src.timeout_alert)
					src.timeout_alert = 1
					src.post_wire_status(src.host_id, "command","term_ping","data","reply")

		return

	attackby(obj/item/W, mob/user)
		if (isscrewingtool(W))
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			boutput(user, "You [src.panel_open ? "secure" : "unscrew"] the maintenance panel.")
			src.panel_open = !src.panel_open
			src.updateUsrDialog()
			return
		else
			..()
		return

	disposing()
		src.current?.wakeup()
		current = null
		if (link)
			link.master = null
			link = null

		..()
		return

	proc
		eject_robot()
			if(!current) return
			src.icon_state = "robuddycharger0"
			src.current.charge_dock = null
			src.current.last_dock_id = src.net_id

			if (src.autoeject == 3)
				src.current.turn_off()
				src.current.warm_boot = 0
				src.current.turn_on()
			else
				src.current.wakeup()

			src.autoeject = 0
			if(src.host_id) //Alert system host of this development!!
				src.post_wire_status(src.host_id,"command","term_message","data","command=status&status=ejected&botid=[current.net_id]")

			src.current = null
			return

		connect_robot(obj/machinery/bot/guardbot/robot,aeject=0)
			if(!istype(robot))
				return 0

			src.current = robot
			robot.charge_dock = src
			src.autoeject = aeject
			if(!robot.idle)
				INVOKE_ASYNC(robot, /obj/machinery/bot/guardbot.proc/snooze)
			if(src.host_id)
				src.post_wire_status(src.host_id,"command","term_message","data","command=status&status=connect&botid=[current.net_id]")

			return 1

		upload_task(var/datum/computer/file/guardbot_task/task, clear_others=0, new_model=0)
			if(!current || !current.on || !istype(task))
				return 0

			if(new_model)
				if(current.model_task)
					qdel(current.model_task)
				var/datum/computer/file/guardbot_task/model = task.copy_file()
				model.master = current
				current.model_task = model

			current.add_task(task, 0, clear_others)
			if(!current.task)
				current.task = task

			return 1

		post_status(var/target_id, var/key, var/value, var/key2, var/value2, var/key3, var/value3)
			var/datum/signal/signal = get_free_signal()
			signal.source = src
			signal.data[key] = value
			if(key2)
				signal.data[key2] = value2
			if(key3)
				signal.data[key3] = value3

			if(target_id)
				signal.data["address_1"] = target_id
			signal.data["sender"] = src.net_id

			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, GUARDBOT_RADIO_RANGE)

		post_wire_status(var/target_id, var/key, var/value, var/key2, var/value2, var/key3, var/value3)
			if(!src.link || !target_id)
				return

			var/datum/signal/signal = get_free_signal()
			signal.source = src
			signal.transmission_method = TRANSMISSION_WIRE
			signal.data[key] = value
			if(key2)
				signal.data[key2] = value2
			if(key3)
				signal.data[key3] = value3

			signal.data["address_1"] = target_id
			signal.data["sender"] = src.net_id

			SPAWN(0.2 SECONDS)
				if (src.link) //ZeWaka: Fix for null.post_signal
					src.link.post_signal(src, signal)

/obj/machinery/computer/tour_console
	name = "Tour Console"
	desc = "A computer console, presumably one relating to tours."
	icon_state = "tour"
	pixel_y = 8
	var/obj/machinery/bot/guardbot/linked_bot = null

	New()
		..()
		SPAWN(0.8 SECONDS)
			linked_bot = locate() in orange(1, src)

	attack_hand(mob/user)
		if (..() || (status & (NOPOWER|BROKEN)))
			return

		src.add_dialog(user)
		add_fingerprint(user)

		var/dat = "<center><h4>Tour Monitor</h4></center>"
		if (!linked_bot)
			dat += "<font color=red>No tour guide detected!</font>"
		else
			dat += "<b>Guide:</b> <center>\[[linked_bot.name]]</center><br>"

			if ((linked_bot in orange(1, src)) && linked_bot.charge_dock)
				dat += "<center><a href='?src=\ref[src];start_tour=1'>Begin Tour</a></center>"

			else
				var/area/guideArea = get_area(linked_bot)
				dat += "<b>Current Location:</b> [istype(guideArea) ? guideArea.name : "<font color=red>Unknown</font>"]"


		user.Browse("<head><title>Tour Monitor</title></head>[dat]", "window=tourconsole;size=302x245")
		onclose(user, "tourconsole")
		return

	Topic(href, href_list)
		if(..())
			return
		src.add_dialog(usr)
		src.add_fingerprint(usr)

		if (href_list["start_tour"] && linked_bot && (linked_bot in orange(1, src)) && linked_bot.charge_dock)
			linked_bot.charge_dock.eject_robot()

		src.updateUsrDialog()
		return

/obj/machinery/bot/guardbot/old
	name = "Robuddy"
	desc = "A PR-4 Robuddy. That's two models back by now! You didn't know any of these were still around."
	icon = 'icons/obj/bots/oldbots.dmi'

	setup_no_costumes = 1
	no_camera = 1
	setup_charge_maximum = 800
	setup_default_tool_path = /obj/item/device/guardbot_tool/flash
	bot_chat_style = "font-family: 'Consolas', monospace;"

	speak(var/message, var/sing, var/just_float, var/just_chat)
		return ..("[uppertext(message)]", just_float=just_float, just_chat=just_chat)

	interacted(mob/user as mob)
		var/dat = "<tt><B>PR-4 Robuddy v0.8</B></tt><br><br>"

		var/power_readout = null
		var/readout_color = "#000000"
		if(!src.cell)
			power_readout = "NO CELL"
		else
			var/charge_percentage = round((cell.charge/cell.maxcharge)*100)
			power_readout = "[charge_percentage]%"
			switch(charge_percentage)
				if(0 to 10)
					readout_color = "#F80000"
				if(11 to 25)
					readout_color = "#FFCC00"
				if(26 to 50)
					readout_color = "#CCFF00"
				if(51 to 75)
					readout_color = "#33CC00"
				if(76 to 100)
					readout_color = "#33FF00"


		dat += {"Power: <table border='1' style='background-color:[readout_color]'>
				<tr><td><font color=white>[power_readout]</font></td></tr></table><br>"}

		dat += "Current Tool: [src.tool ? src.tool.tool_id : "NONE"]<br>"

		dat += "Current Gun: [src.budgun ? src.budgun.name : "NONE"]<br>"

		if(src.gunlocklock)
			dat += "Gun Mount: <font color=red>JAMMED!</font><br>"
		else
			dat += "Gun Mount: [src.locked ? "LOCKED" : "UNLOCKED"]<br>"

		if(src.locked)

			dat += "Status: [src.on ? "On" : "Off"]<br>"

		else

			dat += "Status: <a href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</a><br>"

		dat += "<br>Network ID: <b>\[[uppertext(src.net_id)]]</b><br>"

		user.Browse("<head><title>Robuddy v0.8 controls</title></head>[dat]", "window=guardbot")
		onclose(user, "guardbot")
		return

	explode()
		if(src.exploding) return
		src.exploding = 1
		var/death_message = pick("It is now safe to shut off your buddy.","I regret nothing, but I am sorry I am about to leave my friends.","Malfunction!","I had a good run.","Es lebe die Freiheit!","Life was worth living.","Time to die...")
		speak(death_message)
		src.visible_message("<span class='alert'><b>[src] blows apart!</b></span>")
		var/turf/T = get_turf(src)
		if(src.mover)
			qdel(src.mover)

		src.invisibility = INVIS_ALWAYS_ISH
		var/obj/overlay/Ov = new/obj/overlay(T)
		Ov.anchored = 1
		Ov.name = "Explosion"
		Ov.layer = NOLIGHT_EFFECTS_LAYER_BASE
		Ov.pixel_x = -92
		Ov.pixel_y = -96
		Ov.icon = 'icons/effects/214x246.dmi'
		Ov.icon_state = "explosion"

		if(src.tool.tool_id == "GUN")
			qdel(src.tool)	// So THATS why you kept dropping that!
		if(src.tool && (src.tool.tool_id != "GUN"))
			DropTheThing("tool", null, 0, 0, T, 1)
		if(src.budgun)
			DropTheThing("gun", null, 0, 0, T, 1)
		if(prob(50))
			new /obj/item/parts/robot_parts/arm/left/standard(T)
		src.hat?.set_loc(T)

		var/obj/item/guardbot_core/old/core = new /obj/item/guardbot_core/old(T)
		core.created_name = src.name
		core.created_default_task = src.setup_default_startup_task
		core.created_model_task = src.model_task

		var/list/throwparts = list()
		throwparts += new /obj/item/parts/robot_parts/arm/left/standard(T)
		throwparts += new /obj/item/device/flash(T)
		throwparts += core
		if(src.tool.tool_id == "GUN")
			qdel(src.tool)	// Quit dropping things that shouldn't exist!
		if(src.tool && (src.tool.tool_id != "GUN"))
			throwparts += src.tool
		if(src.budgun)
			throwparts += src.budgun
			src.budgun.set_loc(T)
		if(src.hat)
			throwparts += src.hat
			src.hat.set_loc(T)
		throwparts += new /obj/item/guardbot_frame/old(T)
		for(var/obj/O in throwparts) //This is why it is called "throwparts"
			var/edge = get_edge_target_turf(src, pick(alldirs))
			O.throw_at(edge, 100, 4)

		SPAWN(0) //Delete the overlay when finished with it.
			src.on = 0
			sleep(1.5 SECONDS)
			qdel(Ov)
			qdel(src)

		T.hotspot_expose(800,125)
		explosion(src, T, -1, -1, 2, 3)

		return

/obj/item/guardbot_frame/old
	name = "Robuddy frame"
	desc = "The external casing of a PR-4 Robuddy."
	icon_state = "robuddy_frame-4-1"
	spawned_bot_type = /obj/machinery/bot/guardbot/old
	buddy_model = 4

/obj/item/guardbot_frame/old/golden
	desc = "The external casing of a PR-4 Robuddy. This one is gold plated."
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "goldbuddy_frame-4-1"
	spawned_bot_type = /obj/machinery/bot/guardbot/golden
	created_name = "Goldbuddy"
	buddy_model = 4

	New()
		..()
		SPAWN(0.6 SECONDS)
			src.icon_state = "goldbuddy_frame-[buddy_model]-[stage]"
			if(src.stage >= 2)
				src.created_cell = new
				src.created_cell.charge = 0.9 * src.created_cell.maxcharge
		return

	attackby(obj/item/W, mob/user)
		if ((istype(W, /obj/item/guardbot_core)))
			if(W:buddy_model != src.buddy_model)
				boutput(user, "<span class='alert'>That core board is for a different model of robot!</span>")
				return
			if(!created_cell || stage != 2)
				boutput(user, "<span class='alert'>You need to add a power cell first!</span>")
				return
			src.stage = 3
			src.icon_state = "goldbuddy_frame-[buddy_model]-3"
			if(W:created_name)
				src.created_name = W:created_name
			if(W:created_default_task)
				src.created_default_task = W:created_default_task
			if(W:created_model_task)
				src.created_model_task = W:created_model_task
			boutput(user, "You add the core board to  [src]!")
			qdel(W)

		else if((istype(W, /obj/item/cell)) && stage == 1 && !created_cell)
			user.drop_item()

			W.set_loc(src)
			src.created_cell = W
			src.stage = 2
			src.icon_state = "goldbuddy_frame-[buddy_model]-2"
			boutput(user, "You add the power cell to [src]!")


		else if (istype(W, /obj/item/parts/robot_parts/arm/) && src.stage == 3)
			src.stage++
			boutput(user, "You add the robot arm to [src]!")
			qdel(W)

			var/obj/machinery/bot/guardbot/newbot = new src.spawned_bot_type (get_turf(src))
			if(newbot.cell)
				qdel(newbot.cell)
			newbot.cell = src.created_cell
			newbot.setup_default_tool_path = null
			newbot.cell.set_loc(newbot)

			if(src.created_default_task)
				newbot.setup_default_startup_task = src.created_default_task

			// Everyone gets a new gunt
			newbot.tool = new /obj/item/device/guardbot_tool/gun
			newbot.tool.set_loc(newbot)
			newbot.tool.master = newbot
			newbot.locked = 0

			if(src.created_model_task)
				newbot.model_task = src.created_model_task
				newbot.model_task.master = newbot
			newbot.name = src.created_name

			qdel(src)
			return

/obj/item/guardbot_core/old
	name = "Robuddy mainboard"
	desc = "The primary circuitry of a PR-4 Robuddy."
	icon_state = "robuddy_core-4"
	buddy_model = 4

//A tourguide for "the crunch", or a station!
/obj/machinery/bot/guardbot/old/tourguide
	name = "Marty"
	desc = "A PR-4 Robuddy. These are pretty old, you didn't know there were any still around! This one has a little name tag on the front labeled 'Marty'."
	setup_default_startup_task = /datum/computer/file/guardbot_task/tourguide
	no_camera = 1
	setup_charge_maximum = 3000
	setup_charge_percentage = 100
	flashlight_lum = 4
	var/HatToWear = /obj/item/clothing/head/safari

	New()
		..()
		#ifdef XMAS
		src.HatToWear = /obj/item/clothing/head/helmet/space/santahat
		#endif
		src.hat = new HatToWear(src)
		src.UpdateIcon()

/obj/machinery/bot/guardbot/old/tourguide/destiny
	name = "Mary"
	desc = "A PR-4 Robuddy. These are pretty old, you didn't know there were any still around! This one has a little name tag on the front labeled 'Mary'."
	access_lookup = "Staff Assistant"
	beacon_freq = FREQ_TOUR_NAVBEACON

/obj/machinery/bot/guardbot/old/tourguide/oshan
	name = "Moby"
	desc = "A PR-4 Robuddy. These are pretty old, you didn't know there were any still around! This one has a little name tag on the front labeled 'Moby'."
	access_lookup = "Staff Assistant"
	beacon_freq = FREQ_TOUR_NAVBEACON
	HatToWear = /obj/item/clothing/head/sea_captain

	New()
		..()
		src.hat.name = "Moby's ship captain hat"

/obj/machinery/bot/guardbot/old/tourguide/atlas
	name = "Mabel"
	desc = "A PR-4 Robuddy. These are pretty old, you didn't know there were any still around! This one has a little name tag on the front labeled 'Mabel'."
	access_lookup = "Staff Assistant"
	beacon_freq = FREQ_TOUR_NAVBEACON
	HatToWear = /obj/item/clothing/head/NTberet

	New()
		..()
		src.hat.name = "Mabel's beret"

/obj/machinery/computer/hug_console
	name = "Hug Console"
	desc = "A hug console? It has a small opening on the top."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "holo_console0"

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/token/hug_token))
			user.visible_message("<span class='alert'><b>[user]</b> inserts a [W] into the [src].</span>", "<span class='alert'>You insert a [W] into the [src].</span>")
			qdel(W)

			for (var/obj/machinery/bot/guardbot/buddy in machine_registry[MACHINES_BOTS])
				if (buddy.z != 1) continue
				if (buddy.charge_dock)
					buddy.charge_dock.eject_robot()
				else if (buddy.idle)
					buddy.wakeup()
				buddy.add_task(/datum/computer/file/guardbot_task/recharge/dock_sync, 1, 0)
				var/datum/computer/file/guardbot_task/security/single_use/tohug = new
				tohug.hug_target = user
				buddy.add_task(tohug, 1, 0)
				buddy.navigate_to(get_turf(user))

/obj/item/token/hug_token
	name = "Hug Token"
	desc = "A Hug Token. Just looking at it makes you feel better."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "coin"
	item_state = "coin"
	w_class = W_CLASS_TINY

	attack_self(var/mob/user as mob)
		playsound(src.loc, 'sound/items/coindrop.ogg', 30, 1)
		user.visible_message("<b>[user]</b> flips the token","You flip the token")
		SPAWN(1 SECOND)
		user.visible_message("It came up Hugs.")

#undef GUARDBOT_DOCK_RESET_DELAY
#undef GUARDBOT_LOWPOWER_ALERT_LEVEL
#undef GUARDBOT_LOWPOWER_IDLE_LEVEL
#undef GUARDBOT_POWER_DRAW
#undef GUARDBOT_RADIO_RANGE
