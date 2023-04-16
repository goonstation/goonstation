#define IS_NOT_BEEPSKY_AND_HAS_SOME_GENERIC_BATON 0				// Just some everyday bot on the beat
#define IS_BEEPSKY_AND_HAS_HIS_SPECIAL_BATON 1						// Full-assed Beepsky
#define IS_NOT_BEEPSKY_BUT_HAS_HIS_SPECIAL_BATON 2				// A Beepsky brand secboton
#define IS_BEEPSKY_BUT_HAS_SOME_GENERIC_BATON 3						// A generic-ass shitcurity baton
#define IS_NOT_BEEPSKY_BUT_HAS_A_GENERIC_SPECIAL_BATON 4	// A generic, non-Beepsky brand secboton

/// Idle, handles routing to basic patrol-or-dont secbotting
#define SECBOT_IDLE					0
/// Bot is angry, chasing someone or arresting them
#define SECBOT_AGGRO				1
/// Starting patrol, looking for a patrol node
#define SECBOT_START_PATROL	2
/// On patrol!
#define SECBOT_PATROL				3
/// Summoned by PDA
#define SECBOT_SUMMON				4
/// Idle again, but handles routing for guard-related stuff
#define SECBOT_GUARD_IDLE		5
/// Was ordered to guard an area. Checking to see if that's something it can do
#define SECBOT_GUARD_START	6
/// Currently guarding an area and milling about like an asshole
#define SECBOT_GUARD				7
/// Bot is angry, but was guarding an area and should go back to guarding after this
#define SECBOT_GUARD_AGGRO	8

/// Kill Path And Give Up
/// Just kill their current path, likely invalid or unreachable or something
#define KPAGU_CLEAR_PATH	0
/// Clear *everything*, target, last target, guard orders, mode, everything. Return to secmonkey
#define KPAGU_CLEAR_ALL		1
/// Clear aggro, revert to default patrol, non-guard state. mode = SECBOT_IDLE
#define KPAGU_RETURN_TO_PATROL	2
/// Clear aggro, revert to guard duty. mode = SECBOT_GUARD_IDLE
#define KPAGU_RETURN_TO_GUARD		3

#define PATROL_SPEED 6
#define SUMMON_SPEED 3
#define ARREST_SPEED 2.5

#define BATON_INITIAL_DELAY (0.3 SECONDS)
#define BATON_DELAY_PER_STUN (0.2 SECONDS)

#define BATON_CHARGE_DURATION (3 SECONDS)
#define BATON_CHARGE_DURATION_BEEPSKY (6 SECONDS)

#define SECBOT_LASTTARGET_COOLDOWN "secbot_emag_grace_period"
#define SECBOT_GUARDMOVE_COOLDOWN "secbot_mill_about_delay"
#define SECBOT_HELPME_COOLDOWN "secbot_is_under_attack"
#define SECBOT_CHATSPAM_COOLDOWN "secbot_tenfourtenfourtenfour_etcetera"

/obj/machinery/bot/secbot
	name = "Securitron"
#ifdef HALLOWEEN
	desc = "A little security robot, apparently carved out of a pumpkin.  He looks...spooky?"
	icon = 'icons/misc/halloween.dmi'
#else
	desc = "A little security robot.  He looks less than thrilled."
	icon = 'icons/obj/bots/aibots.dmi'
#endif
	icon_state = "secbot0"
	layer = 5.0 //TODO LAYER
	density = 0
	anchored = UNANCHORED
	luminosity = 2
	req_access = list(access_security)
	var/weapon_access = access_carrypermit
	var/contraband_access = access_contrabandpermit
	var/obj/item/baton/secbot/our_baton // Our baton

	on = 1
	locked = 1 //Behavior Controls lock
	var/mob/living/carbon/target
	var/oldtarget_name
	var/threatlevel = 0
	var/target_lastloc //Loc of target when arrested.
	/// Time after giving up on assaulting someone before they'll consider assaulting them again
	var/last_target_cooldown = 10 SECONDS
	emagged = 0 //Emagged Secbots view everyone as a criminal
	health = 25
	bot_voice = 'sound/misc/talk/bottalk_2.ogg'
	var/idcheck = 1 //If false, all station IDs are authorized for weapons.
	var/check_records = 1 //Does it check security records?
	var/arrest_type = 0 //If true, don't handcuff
	var/report_arrests = 0 //If true, report arrests over PDA messages.
	var/is_beepsky = IS_NOT_BEEPSKY_AND_HAS_SOME_GENERIC_BATON	// How Beepsky are we?
	access_lookup = "Head of Security"
	var/hat = null //Add an overlay from bots/aibots.dmi with this state.  hats.
	var/our_baton_type = /obj/item/baton/secbot
	var/loot_baton_type = /obj/item/scrap
	var/stun_type = "stun"
	var/mode = 0

	var/auto_patrol = 0		// set to make bot automatically patrol
	var/beacon_freq = FREQ_NAVBEACON		// navigation beacon frequency
	var/control_freq = FREQ_BOT_CONTROL		// bot control frequency

	var/tmp/turf/patrol_target	// this is turf to navigate to (location of beacon)
	var/tmp/new_destination		// pending new destination (waiting for beacon response)
	var/tmp/destination			// destination description tag
	var/tmp/next_destination	// the next destination in the patrol route

	var/move_patrol_step_delay = PATROL_SPEED	// multiplies how slowly the bot moves on patrol
	var/move_summon_step_delay = SUMMON_SPEED	// same, but for summons. Lower is faster.
	var/move_arrest_step_delay = ARREST_SPEED
	var/emag_stages = 2 //number of times we can emag this thing
	var/proc_available = 1 // Are we not on cooldown from having forced a process()?

	var/blockcount = 0		//number of times retried a blocked path
	var/awaiting_beacon	= 0	// count of pticks awaiting a beacon response

	var/tmp/nearest_beacon			// the nearest beacon's tag
	var/tmp/turf/nearest_beacon_loc	// the nearest beacon's location

	var/attack_per_step = 0 // Tries to attack every step. 1 = 75% chance to attack, 2 = 25% chance to attack
	/// One WEEOOWEEOO at a time, please
	var/weeooing
	/// Set by the stun action bar if the target isnt in range, grants a brief window for a free zap next time they try to attack
	var/baton_charged
	/// Busy charging
	var/baton_charging
	/// How long these batons hold a charge
	var/baton_charge_duration = BATON_CHARGE_DURATION
	/// So we dont try to cuff someone while we're cuffing someone
	var/cuffing
	/// How much of a threat does something have to be for us to actually cuff them?
	var/cuff_threat_threshold = 5
	/// Obey the threat threshold. Otherwise, just cuff em
	var/warn_minor_crime = 0
	/// How long has the bot been sitting in the time-out locker? (process cycles spent inside a locked/welded storage object)
	var/container_cool_off_counter = 0
	/// When the bot's been stuck in a locker this long, they'll forget who they were mad at
	/// Note, this is in process() calls, not seconds, so it could vary quite a bit
	var/container_cool_off_max = 30
	var/added_to_records = FALSE
	/// Set a bot to guard an area, and they'll go there and mill around
	var/area/guard_area
	/// Arrest anyone who arent security / heads if they're in this area?
	var/guard_area_lockdown
	/// Who is exempt from our wrath while locking down an area?
	var/static/list/lockdown_permit = list(access_heads, access_security) // Only heads and security.
	/// How often should the bot try to wander around their guard post?
	var/guard_mill_cooldown = 5 SECONDS
	/// Secbots send a message when attacked. How long after this message should they send another?
	var/helpme_cooldown = 15 SECONDS
	/// Lots of bots say lots of things. Let's space them out since most of it is just guff
	var/static/chatspam_cooldown = 1 SECOND
	/// Was on guard duty, apprehended someone, then went to return to guard duty? Keep it to yourself please
	var/guard_start_no_announce
	var/static/image/bothat
	var/static/image/chargepic

	disposing()
		STOP_TRACKING
		src.chatspam_cooldown = (1 SECOND) + (length(by_type[/obj/machinery/bot/secbot]) * 2) // big hordes of bots can really jam up the chat
		src.KillPathAndGiveUp(KPAGU_CLEAR_ALL)
		if(our_baton)
			our_baton.dispose()
			our_baton = null
		target = null

		#ifdef I_AM_ABOVE_THE_LAW
		STOP_TRACKING_CAT(TR_CAT_DELETE_ME)
		#endif

		..()

/obj/machinery/bot/secbot/autopatrol
	auto_patrol = 1

/obj/machinery/bot/secbot/beepsky
	name = "Officer Beepsky"
	desc = "It's Officer Beepsky! He's a loose cannon but he gets the job done."
	idcheck = 1
	auto_patrol = 1
	report_arrests = 1
	move_arrest_step_delay = ARREST_SPEED * 0.9 // beepsky has some experience chasing crimers
	loot_baton_type = /obj/item/baton/beepsky
	is_beepsky = IS_BEEPSKY_AND_HAS_HIS_SPECIAL_BATON
	baton_charge_duration = BATON_CHARGE_DURATION_BEEPSKY
	hat = "nt"

	New()
		. = ..()
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

/obj/machinery/bot/secbot/warden
	name = "Warden Jack"
	desc = "The mechanical guardian of the brig."
	auto_patrol = 1
	beacon_freq = 1444
	hat = "helm"

/obj/machinery/bot/secbot/commissar
	name = "Commissar Beepevich"
	desc = "Nobody gets in his way and lives to tell about it."
	health = 40000
	hat = "hos"

/obj/machinery/bot/secbot/formal
	name = "Lord Beepingshire"
	desc = "The most distinguished of security robots."
	hat = "that"

/obj/machinery/bot/secbot/haunted
	name = "Beep-o-Lantern"
	desc = "A little security robot, apparently carved out of a pumpkin.  He looks...spooky?"
	icon = 'icons/misc/halloween.dmi'

/obj/machinery/bot/secbot/neon
	name = "Beepsky (Mall Edition)"
	desc = "This little security robot appears to have been redesigned to appeal to civilians. How colourful!"
	icon = 'icons/misc/walp_decor.dmi'

/obj/machinery/bot/secbot/brute
	name = "Komisarz Beepinarska"
	desc = "This little security robot seems to have a particularly large chip on its... shoulder? ...head?"
	our_baton_type = /obj/item/baton/classic
	loot_baton_type = null
	stun_type = "harm_classic"
	emagged = 2
	control_freq = 0

	demag()
		//Nope
		return

/obj/item/secbot_assembly
	name = "helmet/signaler assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "helmet_signaler"
	item_state = "helmet"
	var/is_dead_beepsky = 0
	var/build_step = 0
	var/created_name = "Securitron" //To preserve the name if it's a unique securitron I guess
	var/beacon_freq = FREQ_NAVBEACON //If it's running on another beacon circuit I guess
	var/hat = null


/obj/machinery/bot/secbot
	New()
		..()
		src.icon_state = "secbot[src.on]"
		if (!src.our_baton || !istype(src.our_baton))
			src.our_baton = new our_baton_type(src)

		add_simple_light("secbot", list(255, 255, 255, 0.4 * 255))
		chargepic = image('icons/effects/electile.dmi', "6c")
		START_TRACKING
		src.chatspam_cooldown = (1 SECOND) + (length(by_type[/obj/machinery/bot/secbot]) * 2) // big hordes of bots can really jam up the chat

		SPAWN(0.5 SECONDS)
			if(src.hat)
				bothat = image('icons/obj/bots/aibots.dmi', "hat-[src.hat]")
				UpdateOverlays(bothat, "secbot_hat")

		MAKE_DEFAULT_RADIO_PACKET_COMPONENT("control", control_freq)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT("beacon", beacon_freq)
		MAKE_SENDER_RADIO_PACKET_COMPONENT("pda", FREQ_PDA)

		#ifdef I_AM_ABOVE_THE_LAW
		START_TRACKING_CAT(TR_CAT_DELETE_ME)
		#endif

	speak(var/message, var/sing, var/just_float)
		if (src.emagged >= 2)
			message = capitalize(ckeyEx(message))
		. = ..()

	Move(var/turf/NewLoc, direct)
		var/oldloc = src.loc
		. = ..()
		if (src.attack_per_step && prob(src.attack_per_step == 2 ? 25 : 75))
			if (oldloc != NewLoc)
				if (mode == SECBOT_AGGRO && target)
					if ((BOUNDS_DIST(src, src.target) == 0))
						src.baton_attack(src.target, 1)

	attack_hand(mob/user, params)
		var/dat

		dat += {"
		<TT><B>Automatic Security Unit v2.0</B></TT><BR><BR>
		Status: <A href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</A><BR>
		Behaviour controls are [src.locked ? "locked" : "unlocked"]"}

		if(!src.locked)
			dat += {"<hr>
			Check for Unauthorised Equipment: <A href='?src=\ref[src];operation=idcheck'>[src.idcheck ? "Yes" : "No"]</A><BR>
			Check Security Records: <A href='?src=\ref[src];operation=ignorerec'>[src.check_records ? "Yes" : "No"]</A><BR>
			Operating Mode: <A href='?src=\ref[src];operation=switchmode'>[src.arrest_type ? "Detain" : "Arrest"]</A><BR>
			Issue Warnings: <A href='?src=\ref[src];operation=warning'>[src.warn_minor_crime ? "Yes" : "No"]</A><BR>
			Warning Threshold: [src.cuff_threat_threshold] | <A href='?src=\ref[src];operation=adjwarn;go=[1]'>\[+]</A> <A href='?src=\ref[src];operation=adjwarn;go=[0]'>\[-]</A><BR>
			Auto Patrol: <A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "On" : "Off"]</A><BR>
			Report Arrests: <A href='?src=\ref[src];operation=report'>[report_arrests ? "On" : "Off"]</A><BR>
			Guard Lockdown: <A href='?src=\ref[src];operation=lockdown'>[src.guard_area_lockdown ? "On" : "Off"]</A><BR>
			<A href='?src=\ref[src];operation=guardhere'>Guard Here</A>"}

		if (user.client?.tooltipHolder)
			user.client.tooltipHolder.showClickTip(src, list(
				"params" = params,
				"title" = "Securitron v2.0 controls",
				"content" = dat,
			))

		return

	Topic(href, href_list)
		if(..())
			return
		src.add_dialog(usr)
		src.add_fingerprint(usr)
		if ((href_list["power"]) && (!src.locked || src.allowed(usr)))
			src.on = !src.on
			if (src.on)
				add_simple_light("secbot", list(255, 255, 255, 0.4 * 255))
			else
				remove_simple_light("secbot")
			src.KillPathAndGiveUp(KPAGU_CLEAR_ALL)
			src.updateUsrDialog()
			logTheThing(LOG_STATION, usr, "turns [src] [src.on ? "on" : "off"] at [log_loc(src)].")

		switch(href_list["operation"])
			if ("idcheck")
				src.idcheck = !src.idcheck
				src.speak("Ten-Four. ID Scanner: [src.idcheck ? "ENGAGED" : "DISENGAGED"].")
				src.updateUsrDialog()
			if ("ignorerec")
				src.check_records = !src.check_records
				src.speak("Ten-Four. Security Records: [src.check_records ? "REFERENCED" : "IGNORED"].")
				src.updateUsrDialog()
			if ("switchmode")
				src.arrest_type = !src.arrest_type
				src.speak("Ten-Four. Arrest Mode: [src.arrest_type ? "DETAIN" : "RESTRAIN"].")
				src.updateUsrDialog()
			if("patrol")
				src.auto_patrol = !src.auto_patrol
				src.speak("Ten-Four. Auto-Patrol: [src.auto_patrol ? "ENGAGED" : "DISENGAGED"].")
				src.KillPathAndGiveUp(KPAGU_CLEAR_ALL)
				updateUsrDialog()
			if("report")
				src.report_arrests = !src.report_arrests
				src.speak("Ten-Four. [src.report_arrests ? "Reporting arrests on [FREQ_PDA]" : "No longer reporting arrests"].")
				updateUsrDialog()
			if("lockdown")
				src.guard_area_lockdown = !src.guard_area_lockdown
				src.speak("Ten-Four. [src.guard_area_lockdown ? "Arresting non-security, non-head personnel in guarded area" : "Standard guard-arrest protocol initiated"].")
				updateUsrDialog()
			if("warning")
				src.warn_minor_crime = !src.warn_minor_crime
				src.speak("Ten-Four. [src.guard_area_lockdown ? "Will not restrain minor offenders" : "Treating all crimes equally"].")
				updateUsrDialog()
			if("adjwarn")
				if(href_list["go"] == "1")
					src.cuff_threat_threshold++
					src.speak("!", just_float = 1)
				else
					src.cuff_threat_threshold--
					src.speak("...", just_float = 1)
				src.cuff_threat_threshold = clamp(src.cuff_threat_threshold, 1, 15)
				updateUsrDialog()
			if("guardhere")
				src.KillPathAndGiveUp(KPAGU_CLEAR_ALL)
				if(src.mode == SECBOT_GUARD_START || src.mode == SECBOT_GUARD)
					src.speak("Ten-Four. Guard orders deleted.")
				else if(isarea(get_area(src)))
					src.guard_area = get_area(src)
					src.mode = SECBOT_GUARD_START
					src.speak("Ten-Four. Guarding curent area.")
				else
					src.speak("ERROR 99-21: CURRENT AREA IS INVALID.")
				updateUsrDialog()

	attack_ai(mob/user as mob)
		if (src.on && src.emagged)
			boutput(user, "<span class='alert'>[src] refuses your authority!</span>")
			return
		src.on = !src.on
		src.KillPathAndGiveUp(KPAGU_CLEAR_ALL)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (src.emagged < emag_stages)
			if (emagged)
				if (user)
					boutput(user, "<span class='alert'>You short out [src]'s system clock inhibition circuis.</span>")
				UpdateOverlays(null, "secbot_hat")
				UpdateOverlays(null, "secbot_charge")
			else if (user)
				boutput(user, "<span class='alert'>You short out [src]'s target assessment circuits.</span>")
			src.audible_message("<span class='alert'><B>[src] buzzes oddly!</B></span>")


			src.emagged++
			src.on = 1
			src.icon_state = "secbot[src.on][(src.on && src.emagged >= 2) ? "-wild" : null]"
			src.KillPathAndGiveUp(KPAGU_CLEAR_PATH)


			if(src.emagged >= 3)
				src.stun_type = "harm_classic"
				processing_bucket = 1
				processing_tier = PROCESSING_FULL
				src.SubscribeToProcess()
				src.dynamic_processing = 0 // so it doesnt get its processing overwritten
				playsound(src.loc, 'sound/effects/elec_bzzz.ogg', 99, 1, 0.1, 0.7)


			if(user)
				src.oldtarget_name = user.name
				ON_COOLDOWN(src, "[SECBOT_LASTTARGET_COOLDOWN]-[src.oldtarget_name]", src.last_target_cooldown)
			logTheThing(LOG_STATION, user, "emagged a [src] at [log_loc(src)].")
			return 1
		return 0

	demag(var/mob/user)
		if (!src.emagged)
			return 0
		if (user)
			user.show_text("You repair [src]'s damaged electronics. Thank God.", "blue")
		src.emagged = 0
		src.KillPathAndGiveUp(KPAGU_CLEAR_PATH)
		src.processing_tier = src.PT_idle
		src.SubscribeToProcess()
		src.dynamic_processing = 1
		src.icon_state = "secbot0"
		return 1


	emp_act()
		..()
		if(!src.emagged && prob(75))
			src.emagged = 1
			src.visible_message("<span class='alert'><B>[src] buzzes oddly!</B></span>")
			src.on = 1
		else
			src.explode()
		return

	attackby(obj/item/I, mob/M)
		if (istype(I, /obj/item/device/pda2) && I:ID_card)
			I = I:ID_card
		if (istype(I, /obj/item/card/id))
			if (src.allowed(M))
				src.locked = !src.locked
				boutput(M, "Controls are now [src.locked ? "locked." : "unlocked."]")
				src.updateUsrDialog()
			else
				boutput(M, "<span class='alert'>Access denied.</span>")

		else if (isscrewingtool(I))
			if (src.health < initial(health))
				src.health = initial(health)
				src.visible_message("<span class='alert'>[M] repairs [src]!</span>", "<span class='alert'>You repair [src].</span>")
		else
			switch(I.hit_type)
				if (DAMAGE_BURN)
					src.health -= I.force * 0.75
				else
					src.health -= I.force * 0.5
			if (src.health <= 0)
				if (src.z == Z_LEVEL_STATION) // I only care about station secbots
					logTheThing(LOG_COMBAT, M, "destroyed secbot [src.emagged ? "(emagged)" : ""] [src] with [I] at [log_loc(src)]")
				src.explode()
			else if (I.force) // Prioritize your safety, cant kill crime if you're dead!
				src.EngageTarget(M, 1, 1)
			..()

	bullet_act(var/obj/projectile/P)
		var/damage = 0
		damage = round(((P.power/4)*P.proj_data.ks_ratio), 1.0)

		if(P.proj_data.damage_type == D_KINETIC)
			src.health -= damage
		else if(P.proj_data.damage_type == D_PIERCING)
			src.health -= (damage*2)
		else if(P.proj_data.damage_type == D_ENERGY)
			src.health -= damage

		if (src.health <= 0)
			if (src.z == Z_LEVEL_STATION) // I only care about station secbots
				if (ismob(P.shooter))
					var/mob/living/M = P.shooter
					logTheThing(LOG_COMBAT, M, "destroyed secbot [src.emagged ? "(emagged)" : ""] [src] at [log_loc(src)]. <b>Projectile:</b> <I>[P.name]</I>[P.proj_data && P.proj_data.type ? ", <b>Type:</b> [P.proj_data.type]" : ""]")
			src.explode()
			return

		if (ismob(P.shooter))
			var/mob/living/M = P.shooter
			if (P && iscarbon(M))
				src.EngageTarget(M, 1, 1)
		return

	//Generally we want to explode() instead of just deleting the securitron.
	ex_act(severity)
		switch(severity)
			if(1)
				src.explode()
				return
			if(2)
				src.health -= 15
				if (src.health <= 0)
					src.explode()
				return
		return

	meteorhit()
		src.explode()
		return

	blob_act(var/power)
		if(prob(25 * power / 20))
			src.explode()
		return

	explode()
		if (report_arrests)
			var/bot_location = get_area(src)
			var/datum/signal/pdaSignal = get_free_signal()
			var/message2send = "Notification: [src] destroyed in [bot_location]! Officer down!"
			pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="SECURITY-MAILBOT", "group"=list(MGD_SECURITY, MGA_DEATH), "sender"="00000000", "message"="[message2send]")
			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pdaSignal, null, "pda")

		if(src.exploding) return
		src.exploding = 1
		playsound(src.loc, 'sound/impact_sounds/Machinery_Break_1.ogg', 40, 1)
		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='alert'><B>[src] blows apart!</B></span>", 1)
		var/turf/Tsec = get_turf(src)

		var/obj/item/secbot_assembly/Sa = new /obj/item/secbot_assembly(Tsec)
		Sa.build_step = 1
		Sa.overlays += image('icons/obj/bots/aibots.dmi', "hs_hole")
		Sa.created_name = src.name
		Sa.beacon_freq = src.beacon_freq
		Sa.hat = src.hat
		if (src.is_beepsky == IS_BEEPSKY_AND_HAS_HIS_SPECIAL_BATON || src.is_beepsky == IS_BEEPSKY_BUT_HAS_SOME_GENERIC_BATON)	// Being Beepsky doesnt give you his baton, but it does mean you're him
			Sa.is_dead_beepsky = 1
		new /obj/item/device/prox_sensor(Tsec)

		// Not charged when dropped (ran on Beepsky's internal battery or whatever).
		if (istype(loot_baton_type, /obj/item/baton)) // Now we can drop *any* baton!
			var/obj/item/baton/B = new loot_baton_type(Tsec)
			B.is_active = FALSE
			B.process_charges(-INFINITY)
			if (src.is_beepsky == IS_BEEPSKY_AND_HAS_HIS_SPECIAL_BATON || src.is_beepsky == IS_NOT_BEEPSKY_BUT_HAS_HIS_SPECIAL_BATON)	// Holding Beepsky's baton doesnt make you him, but it does mean you're holding his baton
				B.name = "Beepsky's stun baton"
				B.beepsky_held_this = 1 // Just as a flag so we can know if this baton used to be Beepsky's. Maybe secbots just dont like people walking around with his sidearm vOv
		else
			new loot_baton_type(Tsec)

		if (prob(50))
			new /obj/item/parts/robot_parts/arm/left/standard(Tsec)

		elecflash(src, radius=1, power=3, exclude_center = 0)
		qdel(src)

	/// Makes the bot able to baton people, then makes them unable to baton people after a while
	proc/charge_baton()
		src.baton_charged = TRUE
		UpdateOverlays(chargepic, "secbot_charged")
		SPAWN(src.baton_charge_duration)
			src.baton_charged = FALSE
			UpdateOverlays(null, "secbot_charged")

	/// Hits someone with our baton, or charges it if it isnt
	proc/baton_attack(var/mob/living/carbon/M, var/force_attack = 0)
		if(force_attack || baton_charged)
			src.baton_charging = 0
			src.icon_state = "secbot-c[src.emagged >= 2 ? "-wild" : null]"
			var/maxstuns = 4
			var/stuncount = (src.emagged >= 2) ? rand(5,10) : 1

			// No need for unnecessary hassle, just make it ignore charges entirely for the time being.
			if (src.our_baton && istype(src.our_baton))
				src.our_baton.cost_normal = 0
			else
				src.our_baton = new src.our_baton_type(src)

			while (stuncount > 0 && src.target)
				// they moved while we were sleeping, abort
				if(!(BOUNDS_DIST(src, src.target) == 0))
					src.icon_state = "secbot[src.on][(src.on && src.emagged >= 2) ? "-wild" : null]"
					src.weeoo()
					src.process()
					return

				stuncount--
				if (check_target_immunity(M))
					src.visible_message("<span class='alert'><B>[src] tries to stun [M] with the [src.our_baton] but the attack bounces off uselessly!</B></span>")
					playsound(src, 'sound/impact_sounds/Generic_Swing_1.ogg', 25, 1, -1)
				else
					src.our_baton.do_stun(src, M, src.stun_type, 2)
				if (!stuncount && maxstuns-- <= 0)
					src.KillPathAndGiveUp(KPAGU_CLEAR_PATH)
				if (stuncount > 0)
					sleep(BATON_DELAY_PER_STUN)

			if (isnull(target))
				return
			SPAWN(0.2 SECONDS)
				src.icon_state = "secbot[src.on][(src.on && src.emagged >= 2) ? "-wild" : null]"
			if (src.target.getStatusDuration("weakened"))
				src.anchored = ANCHORED
				src.target_lastloc = M.loc
				src.KillPathAndGiveUp(KPAGU_CLEAR_PATH)
			return
		else
			actions.start(new/datum/action/bar/icon/secbot_stun(src, src.target, M, src), src)

	process()
		. = ..()
		if (!src.on)
			src.KillPathAndGiveUp(KPAGU_CLEAR_ALL)
			return

		switch(mode)
			/// No guard orders, start patrol if allowed, also look for people to heck up
			if(SECBOT_IDLE)
				src.doing_something = 0
				look_for_perp()	// see if any criminals are in range
				if(auto_patrol)	// still idle, and set to patrol
					mode = SECBOT_START_PATROL	// switch to patrol mode

			/// No guard orders, engaging target, seeking to arrest them
			if(SECBOT_AGGRO, SECBOT_GUARD_AGGRO)
				src.doing_something = 1
				src.assault_target()

			if(SECBOT_START_PATROL)	// start a patrol
				src.doing_something = 0
				if(patrol_target)
					if(!ON_COOLDOWN(global, "[SECBOT_CHATSPAM_COOLDOWN]-patrolstart", src.chatspam_cooldown)) // have a valid path, so go there
						src.speak("Patrol Mode: ENGAGED.")
					src.mode = SECBOT_PATROL
				else // no patrol target, so need a new one
					find_patrol_target()

			if(SECBOT_PATROL)		// patrol mode
				if(src.target)
					src.mode = SECBOT_AGGRO
					src.process()
				else
					move_the_bot(move_patrol_step_delay)
					look_for_perp()

			if(SECBOT_SUMMON)		// summoned to PDA
				src.doing_something = 1
				if(!src.path)
					src.speak("ERROR 99-28: COULD NOT FIND PATH TO SUMMON TARGET. ABORTING.")
					src.KillPathAndGiveUp(KPAGU_RETURN_TO_PATROL)	// switch back to what we should be

			/// On guard duty, returning from distraction
			if(SECBOT_GUARD_IDLE)
				src.doing_something = 0
				if(isarea(src.guard_area))
					if(get_area(get_turf(src)) == src.guard_area)
						mode = SECBOT_GUARD
					else
						mode = SECBOT_GUARD_START
						src.guard_start_no_announce = 1
				else
					mode = SECBOT_IDLE
				look_for_perp()

			/// On guard duty, check if we're in the place we're supposed to be
			if(SECBOT_GUARD_START, SECBOT_GUARD)
				src.doing_something = 1
				src.guard_target()

			if(SECBOT_GUARD_AGGRO)
				src.doing_something = 1
				src.assault_target()

	/// Makes bots go to an area, mill around, and maybe attack people who shouldnt be there
	proc/guard_target()
		src.look_for_perp()
		if(src.target)
			return

		if(!isarea(src.guard_area)) // Area isnt? Back to patrol, I guess
			src.speak("ERROR 99-24: INVALID AREA [src.guard_area]")
			src.KillPathAndGiveUp(KPAGU_RETURN_TO_PATROL)
			return

		if(src.guard_area?.name == "Space" || src.guard_area?.name == "Ocean") // Podsky we aint
			src.speak("ERROR 99-29: SPECIFIED AREA '[src.guard_area]' OUT OF BOUNDS.")
			src.KillPathAndGiveUp(KPAGU_RETURN_TO_PATROL)
			return

		if(get_area(get_turf(src)) == src.guard_area) // oh good we're here
			if(src.mode == SECBOT_GUARD_START)
				if(!src.guard_start_no_announce && !ON_COOLDOWN(global, "[SECBOT_CHATSPAM_COOLDOWN]-guardarrived", src.chatspam_cooldown))
					src.speak("Destination reached. Patrolling area.", just_float = 1)
				src.mode = SECBOT_GUARD

		if(!moving && !ON_COOLDOWN(src, SECBOT_GUARDMOVE_COOLDOWN, src.guard_mill_cooldown))
			var/list/T = get_area_turfs(src.guard_area, 1)
			if(src.mode == SECBOT_GUARD_START && !src.guard_start_no_announce && !ON_COOLDOWN(global, "[SECBOT_CHATSPAM_COOLDOWN]-guardcalc", src.chatspam_cooldown))
				src.speak("Calculating path to [src.guard_area]...", just_float = 1)
			if(length(T) >= 1)
				SPAWN(0)
					for(var/i in 1 to 10) // Not every turf is accessible to the bot. But some might!
						T = (pick(T))
						src.navigate_to(T, src.bot_move_delay)
						if(length(src.path) >= 1)
							if(src.mode == SECBOT_GUARD_START && !src.guard_start_no_announce && !ON_COOLDOWN(global, "[SECBOT_CHATSPAM_COOLDOWN]-guardpathOK", src.chatspam_cooldown))
								src.speak("Path calculated. Moving out.", just_float = 1)
							break
						sleep(1 SECOND)
					if(!src.path) // Can't get there? Eh just go back to patrolling
						src.speak("ERROR 99-02: COULD NOT FIND PATH TO GUARD AREA.")
						src.speak("Guard Mode: DISENGAGED.")
						src.KillPathAndGiveUp(KPAGU_RETURN_TO_PATROL)
			else
				src.speak("ERROR 99-81: AREA CONTAINS NO VALID TURFS.")
				src.speak("Guard Mode: DISENGAGED.")
				src.KillPathAndGiveUp(KPAGU_RETURN_TO_PATROL)

	/// Makes the bot chase perps, hit them, and cuff them
	proc/assault_target()
		var/kpagu // fun fact, the postalcode for Kpagu is 911101
		/// Current mode determines what we're supposed to go back to when we're done
		switch(src.mode)
			if(SECBOT_GUARD, SECBOT_GUARD_START, SECBOT_GUARD_AGGRO, SECBOT_GUARD_IDLE)
				kpagu = KPAGU_RETURN_TO_GUARD
			else
				kpagu = KPAGU_RETURN_TO_PATROL

		/// Tango never up to begin with? Or some kind of not-human? Eh whatever give up
		if(!istype(src.target, /mob/living/carbon/human))
			speak("???", just_float = 1)
			src.KillPathAndGiveUp(kpagu)
			return

		// If the target is or goes invisible, give up, securitrons don't have thermal vision! :p
		if((src.target.invisibility > INVIS_NONE)  && (!src.is_beepsky))
			speak("?!", just_float = 1)
			src.KillPathAndGiveUp(kpagu)
			return

		/// Tango hidden inside something or someone? Welp, can't hit them through a locker, so may as well give up!
		if(src.target?.loc && !isturf(src.target.loc))
			speak("?", just_float = 1)
			src.KillPathAndGiveUp(kpagu)
			return

		/// Tango down or tango hecked off or tango behind a bunch of stuff, give up and get back to work
		if (src.target.hasStatus("handcuffed") || src.frustration >= 8)
			speak("...", just_float = 1)
			src.KillPathAndGiveUp(kpagu)
			return

		/// Finish what you're doing first!
		if(src.moving || src.cuffing || src.baton_charging)
			return

		/// We inside something?
		if(istype(src.loc, /obj/storage))
			var/obj/storage/C = src.loc
			if(C.locked || C.welded)
				src.weeoo()
				if(prob(50 + (src.emagged * 15)))
					for(var/mob/M in hearers(C, null))
						M.show_text("<font size=[max(0, 5 - GET_DIST(get_turf(src), M))]>THUD, thud!</font>")
					playsound(C, 'sound/impact_sounds/Wood_Hit_1.ogg', 15, 1, -3)
					animate_storage_thump(C)
				src.container_cool_off_counter++
				if(src.container_cool_off_counter >= src.container_cool_off_max) // Give him some time to cool off
					src.KillPathAndGiveUp(kpagu)
					src.container_cool_off_counter = 0
				return // please stop zapping people from inside lockers
			else
				C.open() // just nudge it open, you goof

		src.container_cool_off_counter = 0

		/// Tango!
		if(src.target)
			/// Tango in batonning distance?
			if ((BOUNDS_DIST(src, src.target) == 0))
				/// Are they good and downed, and are we allowed to cuff em?
				if(!src.arrest_type && src.target?.getStatusDuration("weakened") >= 3 SECONDS)
					if(!src.warn_minor_crime || ((src.warn_minor_crime || src.guard_area_lockdown) && src.threatlevel >= src.cuff_threat_threshold))
						actions.start(new/datum/action/bar/icon/secbot_cuff(src, kpagu), src)
					else
						src.arrest_gloat()
						src.KillPathAndGiveUp(kpagu)
						return
				/// No? Well, make em good and downed then
				else
					SPAWN(0)
						src.baton_attack(src.target) // has while-sleeps, proc happens as part of process(), stc
			/// Tango in charging distance?
			else if(IN_RANGE(src, src.target, 13)) // max perp-seek distance of 13
				/// Charge em!
				navigate_to(src.target, src.move_arrest_step_delay, max_dist = 30) // but they can go anywhere in that 13 tiles
				if(!src.path || length(src.path) < 1)
					speak("...?", just_float = 1)
					src.KillPathAndGiveUp(kpagu)
				else
					weeoo()
				return
			/// Tango outside of charging distance?
			else
				src.frustration += 2
				speak("...", just_float = 1)

	// look for a criminal in range of the bot
	proc/look_for_perp()
		src.anchored = UNANCHORED
		for(var/mob/living/carbon/C in view(7, get_turf(src))) //Let's find us a criminal
			if ((C.stat) || (C.hasStatus("handcuffed")))
				continue
			if(GET_COOLDOWN(src, "[SECBOT_LASTTARGET_COOLDOWN]-[C.name]"))
				continue
			if (ishuman(C))
				src.threatlevel = src.assess_perp(C)
			if (src.guard_area_lockdown && isarea(src.guard_area) && get_area(C) == src.guard_area)
				if(ishuman(C))
					var/mob/living/carbon/human/H = C
					var/obj/item/card/id/perp_id = H.equipped()
					if (!istype(perp_id))
						perp_id = H.wear_id
					if(!perp_id || (perp_id && !length(perp_id.access & src.lockdown_permit)))
						src.threatlevel += 4
			if (src.threatlevel >= 4)
				src.EngageTarget(C)
				break
			else
				continue

	proc/EngageTarget(var/mob/living/carbon/C, var/need_backup, var/pda_help, var/force_new_target)
		/// Already engaging someone!
		if(src.target && !force_new_target)
			return

		if(need_backup)
			for_by_tcl(S, /obj/machinery/bot/secbot) // Beat up an officer? That's a batonning
				if(S == src)
					continue
				if(IN_RANGE(src, S, 7))
					if(!ON_COOLDOWN(global, "[SECBOT_CHATSPAM_COOLDOWN]-drawaggro", src.chatspam_cooldown))
						S.speak("ALLIED UNIT UNDER ATTACK. MOVING TO ASSIST.")
					S.EngageTarget(C, 0, 0, 0)

		if(pda_help && !ON_COOLDOWN(src, SECBOT_HELPME_COOLDOWN, src.helpme_cooldown))
			// HELPMEPLZ
			var/message2send ="ALERT: Unit under attack by [src.target] in [get_area(src)]. Requesting backup."

			var/datum/signal/signal = get_free_signal()
			signal.source = src
			signal.data["sender"] = src.botnet_id
			signal.data["command"] = "text_message"
			signal.data["sender_name"] = src
			signal.data["group"] = list(MGD_SECURITY, MGA_ARREST)
			signal.data["address_1"] = "00000000"
			signal.data["message"] = message2send
			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, null, "pda")

		src.KillPathAndGiveUp(KPAGU_CLEAR_PATH)
		src.target = C
		if(istype(C, /mob/living/carbon/human/npc/monkey))
			var/mob/living/carbon/human/npc/monkey/npcmonkey = C
			npcmonkey.pursuited_by(src)
		src.oldtarget_name = C.name
		if(!ON_COOLDOWN(global, "[SECBOT_CHATSPAM_COOLDOWN]-yellatthem", src.chatspam_cooldown * 3))
			src.YellAtPerp()
		switch(src.mode)
			if(SECBOT_IDLE, SECBOT_START_PATROL, SECBOT_PATROL, SECBOT_SUMMON, SECBOT_AGGRO)
				src.mode = SECBOT_AGGRO
			else
				src.mode = SECBOT_GUARD_AGGRO
		weeoo()
		process()	// ensure bot quickly responds to a perp

	proc/YellAtPerp()
		var/saything = pick('sound/voice/bcriminal.ogg', 'sound/voice/bjustice.ogg', 'sound/voice/bfreeze.ogg')
		src.point(src.target, 1)
		src.speak("Level [src.threatlevel] infraction alert!")
		switch(saything)
			if('sound/voice/bcriminal.ogg')
				src.speak("CRIMINAL DETECTED.")
			if('sound/voice/bjustice.ogg')
				src.speak("PREPARE FOR JUSTICE.")
			if('sound/voice/bfreeze.ogg')
				src.speak("FREEZE. SCUMBAG.")
		playsound(src, saything, 50, 0)

	proc/weeoo()
		if(weeooing)
			return
		SPAWN(0)
			weeooing = 1
			var/weeoo = 10
			playsound(src, 'sound/machines/siren_police.ogg', 50, 1)
			while (weeoo)
				add_simple_light("secbot", list(255 * 0.9, 255 * 0.1, 255 * 0.1, 0.8 * 255))
				sleep(0.3 SECONDS)
				add_simple_light("secbot", list(255 * 0.1, 255 * 0.1, 255 * 0.9, 0.8 * 255))
				sleep(0.3 SECONDS)
				weeoo--

			add_simple_light("secbot", list(255, 255, 255, 0.4 * 255))
			weeooing = 0

//If the security records say to arrest them, arrest them
//Or if they have weapons and aren't security, arrest them.
	proc/assess_perp(mob/living/carbon/human/perp as mob)
		var/threatcount = 0

		if(src.emagged) return 10 //Everyone is a criminal!

		if((src.idcheck)) // bot is set to actively search for contraband
			var/obj/item/card/id/perp_id = perp.equipped()
			if (!istype(perp_id))
				perp_id = perp.wear_id

			var/has_carry_permit = 0
			var/has_contraband_permit = 0

			if (!has_contraband_permit)
				threatcount += GET_ATOM_PROPERTY(perp, PROP_MOVABLE_CONTRABAND_OVERRIDE)

			if(perp_id) //Checking for permits
				if(weapon_access in perp_id.access)
					has_carry_permit = 1
				if(contraband_access in perp_id.access)
					has_contraband_permit = 1

			if (istype(perp.l_hand))
				if (istype(perp.l_hand, /obj/item/gun/)) // perp is carrying a gun
					if(!has_carry_permit)
						threatcount += perp.l_hand.get_contraband()
				else // not carrying a gun, but potential contraband?
					if(!has_contraband_permit)
						threatcount += perp.l_hand.get_contraband()

			if (istype(perp.r_hand))
				if (istype(perp.r_hand, /obj/item/gun/)) // perp is carrying a gun
					if(!has_carry_permit)
						threatcount += perp.r_hand.get_contraband()
				else // not carrying a gun, but potential contraband?
					if(!has_contraband_permit)
						threatcount += perp.r_hand.get_contraband()

			if (istype(perp.belt))
				if (istype(perp.belt, /obj/item/gun/))
					if (!has_carry_permit)
						threatcount += perp.belt.get_contraband() * 0.5
				else
					if (!has_contraband_permit)
						threatcount += perp.belt.get_contraband() * 0.5

			if (istype(perp.wear_suit))
				if (!has_contraband_permit)
					threatcount += perp.wear_suit.get_contraband()

			if (istype(perp.back))
				if (istype(perp.back, /obj/item/gun/)) // some weapons can be put on backs
					if (!has_carry_permit)
						threatcount += perp.back.get_contraband() * 0.5
				else // at moment of doing this we don't have other contraband back items, but maybe that'll change
					if (!has_contraband_permit)
						threatcount += perp.back.get_contraband() * 0.5


		if(istype(perp.mutantrace, /datum/mutantrace/abomination))
			threatcount += 5

		if(perp.traitHolder.hasTrait("stowaway") && perp.traitHolder.hasTrait("jailbird"))
			if(isnull(data_core.security.find_record("name", perp.name)))
				threatcount += 5

		//Agent cards lower threat level
		if((istype(perp.wear_id, /obj/item/card/id/syndicate)))
			threatcount -= 2

		// we have grounds to make an arrest, don't bother with further analysis
		if(threatcount >= 4)
			return threatcount

		if (src.check_records) // bot is set to actively compare security records
			var/perpname = perp.face_visible() ? perp.real_name : perp.name

			for (var/datum/db_record/R as anything in data_core.security.find_records("name", perpname))
				if(R["criminal"] == "*Arrest*")
					threatcount = 7
					break

		return threatcount

	DoWhileMoving()
		. = ..()
		/// Every 5 tiles, look for someone to kill
		if(!src.target && src.path?.len % 5 == 1)
			src.look_for_perp()

		/// If we happen to be chasing someone and get in batonning range, let's stop and maybe try to hit them
		if(src.target && (BOUNDS_DIST(src, src.target) == 0))
			return TRUE

	KillPathAndGiveUp(var/give_up = KPAGU_CLEAR_PATH)
		. = ..()
		src.anchored = UNANCHORED
		src.icon_state = "secbot[src.on][(src.on && src.emagged >= 2) ? "-wild" : null]"
		if(give_up == KPAGU_RETURN_TO_GUARD || give_up == KPAGU_CLEAR_ALL)
			src.oldtarget_name = src.target?.name
			src.target = null
			ON_COOLDOWN(src, "[SECBOT_LASTTARGET_COOLDOWN]-[src.oldtarget_name]", src.last_target_cooldown)
			src.mode = SECBOT_GUARD_IDLE
		if(give_up == KPAGU_RETURN_TO_PATROL || give_up == KPAGU_CLEAR_ALL)
			src.oldtarget_name = src.target?.name
			src.target = null
			ON_COOLDOWN(src, "[SECBOT_LASTTARGET_COOLDOWN]-[src.oldtarget_name]", src.last_target_cooldown)
			src.guard_area = null
			src.guard_area_lockdown = FALSE
			src.mode = SECBOT_IDLE

	/// Sends the bot on to a patrol target. Or Summon target, if that's what patrol_target is set to
	proc/move_the_bot(var/delay = 3)
		. = FALSE
		if(loc == patrol_target) // We where we want to be?
			at_patrol_target() // Find somewhere else to go!
			look_for_perp()
			. = TRUE
		else if (patrol_target && (frustration >= 3 || isnull(src.bot_mover) || get_turf(src.bot_mover.the_target) != get_turf(patrol_target)))
			navigate_to(patrol_target, delay)
			if(src.bot_mover && !src.bot_mover.disposed)
				. = TRUE
		else if(patrol_target)
			. = TRUE
		if(!.)
			if(!ON_COOLDOWN(src, "find new path after failure", 15 SECONDS))
				find_patrol_target() // find next beacon I guess!

	/// finds a new patrol target
	proc/find_patrol_target()
		send_status()
		if(awaiting_beacon)			// awaiting beacon response
			awaiting_beacon++
			if(awaiting_beacon > 5)	// wait 5 secs for beacon response
				if(text2num(new_destination) && prob(66))
					new_destination = "[1 + text2num(new_destination)]"
					send_status()
				else
					find_nearest_beacon()	// then go to nearest instead
				return 0
			else
				return 1

		if(next_destination)
			set_destination(next_destination)
			return 1
		else
			find_nearest_beacon()
			return 0

	// finds the nearest beacon to self
	// signals all beacons matching the patrol code
	proc/find_nearest_beacon()
		nearest_beacon = null
		new_destination = "__nearest__"
		post_signal_multiple("beacon", list("findbeacon" = "patrol", "address_tag" = "patrol"))
		awaiting_beacon = 1
		SPAWN(1 SECOND)
			awaiting_beacon = 0
			if(nearest_beacon)
				set_destination(nearest_beacon)
			else
				auto_patrol = 0
				src.KillPathAndGiveUp(2)
				if(!ON_COOLDOWN(global, "[SECBOT_CHATSPAM_COOLDOWN]-patrolend", src.chatspam_cooldown))
					src.speak("Patrol Mode: DISENGAGED.")
				send_status()

	proc/at_patrol_target()
		find_patrol_target()
		return

	// sets the current destination
	// signals all beacons matching the patrol code
	// beacons will return a signal giving their locations
	proc/set_destination(var/new_dest)
		new_destination = new_dest
		post_signal_multiple("beacon", list("findbeacon" = new_dest || "patrol", "address_tag" = new_dest || "patrol"))
		awaiting_beacon = 1

	// receive a radio signal
	// used for beacon reception
	receive_signal(datum/signal/signal)

		if(!on)
			return
		var/signal_command = signal.data["command"]
		var/signal_target = signal.data["target"]
		// process all-bot input
		if(signal_command=="bot_status")
			send_status()

		// check to see if we are the commanded bot
		if(signal.data["active"] == src)
		// process control input
			switch(signal_command)
				if("stop")
					src.mode = SECBOT_IDLE
					src.auto_patrol = 0
					return

				if("go")
					src.mode = SECBOT_IDLE
					src.auto_patrol = 1
					return

				if("summon")
					src.summon_bot(signal_target)
					return

				if("proc")
					if (src.proc_available)
						src.speak("!", just_float = 1)
						src.proc_available = 0
						src.process()
						SPAWN(3 SECONDS)
							src.proc_available = 1
					else
						src.speak("...", just_float = 1)
					return

				if("guard")
					src.guard_the_area(signal_target)
					return

				if("lockdown")
					src.guard_the_area(signal_target, 1)
					return

		// receive response from beacon
		var/signal_beacon = signal.data["beacon"]
		var/valid = signal.data["patrol"]
		if(!signal_beacon || !valid)
			return

		if(signal_beacon == new_destination)	// if the signal_beacon location matches the set destination
									// the we will navigate there
			destination = new_destination
			patrol_target = signal.source.loc
			next_destination = signal.data["next_patrol"]
			awaiting_beacon = 0

		// if looking for nearest beacon
		else if(new_destination == "__nearest__")
			var/dist = GET_DIST(src,signal.source.loc)
			if(nearest_beacon)

				// note we ignore the beacon we are located at
				if(dist>1 && dist<GET_DIST(src,nearest_beacon_loc))
					nearest_beacon = signal_beacon
					nearest_beacon_loc = signal.source.loc
					return
				else
					return
			else if(dist > 1)
				nearest_beacon = signal_beacon
				nearest_beacon_loc = signal.source.loc
		return

	proc/guard_the_area(var/area/A, var/lockdown)
		src.KillPathAndGiveUp(1)
		src.guard_area_lockdown = lockdown
		if(isarea(A))
			src.guard_area = A
		src.mode = SECBOT_GUARD_START
		if(!ON_COOLDOWN(global, "[SECBOT_CHATSPAM_COOLDOWN]-guardstart", src.chatspam_cooldown))
			src.speak("Ten-Four. Guard orders confirmed.")

	proc/summon_bot(var/turf/target)
		src.KillPathAndGiveUp(1)
		if(isturf(target))
			src.patrol_target = target
		else
			return
		src.next_destination = destination
		src.destination = null
		src.awaiting_beacon = 0
		src.mode = SECBOT_SUMMON
		if(!ON_COOLDOWN(global, "[SECBOT_CHATSPAM_COOLDOWN]-summonstart", src.chatspam_cooldown))
			src.speak("Responding to summon.")
		src.move_the_bot(move_summon_step_delay)

	// send a radio signal with a single data key/value pair
	proc/post_signal(var/freq, var/key, var/value)
		post_signal_multiple(freq, list("[key]" = value) )

	// send a radio signal with multiple data key/values
	proc/post_signal_multiple(var/freq, var/list/keyval)
		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.data["sender"] = src.botnet_id
		for(var/key in keyval)
			signal.data[key] = keyval[key]
		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, null, freq)

	// signals bot status etc. to controller
	proc/send_status()
		var/list/kv = new()
		kv["type"] = "secbot"
		kv["name"] = name
		kv["loca"] = get_area(src)
		kv["mode"] = mode
		post_signal_multiple(control_freq, kv)

	proc/arrest_gloat()
		var/list/voice_lines = list(
				'sound/voice/bgod.ogg'
			, 'sound/voice/biamthelaw.ogg'
			, 'sound/voice/bsecureday.ogg'
			, 'sound/voice/bradio.ogg'
			, 'sound/voice/binsultbeep.ogg'
			, 'sound/voice/bcreep.ogg'
			)

		var/say_thing = pick(voice_lines)
		if(say_thing == 'sound/voice/binsultbeep.ogg' && prob(90))
			say_thing = 'sound/voice/bsecureday.ogg'
		switch(say_thing)
			if('sound/voice/bgod.ogg')
				src.speak("GOD MADE TOMORROW FOR THE CROOKS WE DON'T CATCH TO-DAY.")
			if('sound/voice/biamthelaw.ogg')
				src.speak("I-AM-THE-LAW.")
			if('sound/voice/bsecureday.ogg')
				src.speak("HAVE A SECURE DAY.")
			if('sound/voice/bradio.ogg')
				src.speak("YOU CANT OUTRUN A RADIO.")
			if('sound/voice/bcreep.ogg')
				src.speak("YOUR MOVE. CREEP.")
			if('sound/voice/binsultbeep.ogg')
				var/qbert = ""
				for(var/i in 1 to rand(5,20))
					qbert += "[pick("!", "@", "#", "$", "%", "&", "*", ">:(", 20;"SHUT YOUR ", 20;"ASS-ENDING ", 20;"FROM THE DEPTHS OF ")]"
					if(prob(10))
						qbert += " "
				for(var/j in 1 to rand(2,5))
					qbert += "[pick("!","?")]"
				src.speak("[qbert]")
		playsound(src, say_thing, 50, 0, 0, 1)
		ON_COOLDOWN(src, "[SECBOT_LASTTARGET_COOLDOWN]-[src.target?.name]", src.last_target_cooldown)

//secbot handcuff bar thing
/datum/action/bar/icon/secbot_cuff
	duration = 40
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "secbot_cuff"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "buddycuff"
	var/obj/machinery/bot/secbot/master

	New(var/obj/machinery/bot/secbot/the_bot)
		src.master = the_bot
		..()

	onUpdate()
		..()
		if (src.failchecks())
			master.weeoo()
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		master.cuffing = 1
		if (src.failchecks())
			master.weeoo()
			interrupt(INTERRUPT_ALWAYS)
			return

		playsound(master, 'sound/weapons/handcuffs.ogg', 30, 1, -2)
		master.visible_message("<span class='alert'><B>[master] is trying to put handcuffs on [master.target]!</B></span>")
		if(master.is_beepsky == IS_BEEPSKY_AND_HAS_HIS_SPECIAL_BATON || master.is_beepsky == IS_BEEPSKY_BUT_HAS_SOME_GENERIC_BATON)
			duration = round(duration * 0.75)
			playsound(master, 'sound/misc/winding.ogg', 30, 1, -2)

	onInterrupt()
		..()
		master.cuffing = 0

	onEnd()
		..()
		if(!master.cuffing)
			return

		master.cuffing = 0

		if (BOUNDS_DIST(master, master.target) == 0)
			if (!master.target || master.target.hasStatus("handcuffed"))
				return

			var/uncuffable = 0

			if (!isturf(master.target.loc))
				uncuffable = 1

			if(ishuman(master.target) && !uncuffable)
				master.target.handcuffs = new /obj/item/handcuffs/guardbot(master.target)
				master.target.setStatus("handcuffed", duration = INFINITE_STATUS)

			if(!uncuffable)
				master.arrest_gloat()
			if (master.report_arrests && !uncuffable)
				var/bot_location = get_area(master)
				var/last_target = master.target
				var/turf/LT_loc = get_turf(last_target)
				if(!LT_loc)
					LT_loc = get_turf(master)

					//////PDA NOTIFY/////

				var/message2send ="Notification: [last_target] detained by [master] in [bot_location] at coordinates [LT_loc.x], [LT_loc.y]."

				var/datum/signal/signal = get_free_signal()
				signal.source = src
				signal.data["sender"] = "00000000"
				signal.data["command"] = "text_message"
				signal.data["sender_name"] = "SECURITY-MAILBOT"
				signal.data["group"] = list(MGD_SECURITY, MGA_ARREST)
				signal.data["address_1"] = "00000000"
				signal.data["message"] = message2send
				SEND_SIGNAL(src.master, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, null, "pda")

			switch(master.mode)
				if(SECBOT_AGGRO)
					master.KillPathAndGiveUp(KPAGU_RETURN_TO_PATROL)
				if(SECBOT_GUARD_AGGRO)
					master.KillPathAndGiveUp(KPAGU_RETURN_TO_GUARD)
				else
					master.KillPathAndGiveUp(KPAGU_CLEAR_ALL)

	proc/failchecks()
		if (!(BOUNDS_DIST(master, master.target) == 0))
			return 1
		if (!master.target || master.target.hasStatus("handcuffed") || master.moving)
			return 1
		if (!isturf(master.loc) || !isturf(master.target?.loc)) // Most often, inside a locker
			return 1 // cant cuff people through lockers... and not enough room to cuff if both are in that locker

//secbot stunner bar thing
/datum/action/bar/icon/secbot_stun
	duration = 10
	interrupt_flags = 0 //THE SECURITRON STOPS FOR NOTHING
	id = "secbot_cuff"
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "stunbaton_active"
	var/obj/machinery/bot/secbot/master

	New(var/the_bot, var/M)
		src.master = the_bot
		..()

	onUpdate()
		..()
		if (!master.on)
			interrupt(INTERRUPT_ALWAYS)
			return

	onInterrupt()
		..()
		master.baton_charging = 0

	onStart()
		..()
		if (!master.on)
			interrupt(INTERRUPT_ALWAYS)
			return

		master.baton_charging = 1
		master.visible_message("<span class='alert'><B>[master] is energizing its prod, preparing to zap [master.target]!</B></span>")
		if(master.is_beepsky == IS_BEEPSKY_AND_HAS_HIS_SPECIAL_BATON || master.is_beepsky == IS_BEEPSKY_BUT_HAS_SOME_GENERIC_BATON || master.emagged >= 2)
			playsound(master, 'sound/machines/ArtifactBee2.ogg', 30, 1, -2)
			duration = round(duration * 0.6)
		else
			playsound(master, 'sound/effects/electric_shock_short.ogg', 30, 1, -2)

	onEnd()
		..()
		master.baton_charging = 0
		if((BOUNDS_DIST(master, master.target) == 0))
			master.baton_attack(master.target, 1)
		else
			master.charge_baton()
		SPAWN(0)
			master.weeoo()

//Secbot Construction

/obj/item/clothing/head/helmet/hardhat/security/attackby(var/obj/item/device/radio/signaler/S, mob/user as mob)
	if (!istype(S, /obj/item/device/radio/signaler))
		..()
		return

	if (!S.b_stat)
		return
	else
		var/obj/item/secbot_assembly/A = new /obj/item/secbot_assembly
		user.u_equip(S)
		user.put_in_hand_or_drop(A)
		boutput(user, "You add the signaler to the helmet.")
		qdel(S)
		qdel(src)


/obj/item/secbot_assembly/attackby(obj/item/W, mob/user)
	if ((isweldingtool(W)) && (!src.build_step))
		if(W:try_weld(user, 1))
			src.build_step++
			src.overlays += image('icons/obj/bots/aibots.dmi', "hs_hole")
			boutput(user, "You weld a hole in [src]!")

	else if (istype(W, /obj/item/device/prox_sensor) && src.build_step == 1)
		src.build_step++
		boutput(user, "You add the prox sensor to [src]!")
		src.overlays += image('icons/obj/bots/aibots.dmi', "hs_eye")
		src.name = "helmet/signaler/prox sensor assembly"
		qdel(W)

	else if (istype(W, /obj/item/parts/robot_parts/arm/) && src.build_step == 2)
		src.build_step++
		boutput(user, "You add the robot arm to [src]!")
		src.name = "helmet/signaler/prox sensor/robot arm assembly"
		src.overlays += image('icons/obj/bots/aibots.dmi', "hs_arm")
		user.u_equip(W)
		qdel(W)

	else if (istype(W, /obj/item/baton/) && src.build_step >= 3)
		if (istype(W, /obj/item/baton/beepsky))	// If we used Beepsky's dropped baton
			var/obj/item/baton/Y = W
			if (src.is_dead_beepsky)							// on Beepsky's corpse
				boutput(user, "You return Officer Beepsky his trusty baton, reassembling the Securitron! Beep boop.")
				new /obj/machinery/bot/secbot/beepsky(get_turf(src))
				qdel(src)
				user.u_equip(W)
				qdel(W)
			else												// On any other securitron assembly?
				boutput(user, "You give the [src] [W] and connect a cable in the arm to the baton's parallel port, completing the Securitron! Beep boop.")
				var/obj/machinery/bot/secbot/S = new /obj/machinery/bot/secbot(get_turf(src))
				S.beacon_freq = src.beacon_freq
				get_radio_connection_by_id(S, "beacon").update_frequency(S.beacon_freq)
				S.hat = src.hat
				S.name = src.created_name		// We get an upgraded securitron
				S.loot_baton_type = W.type	// So we can drop it all over again.
				if (Y.beepsky_held_this == 1)
					S.is_beepsky = IS_NOT_BEEPSKY_BUT_HAS_HIS_SPECIAL_BATON	// So we drop Beepsky's baton, and not just some generic secbot one
				else
					S.is_beepsky = IS_NOT_BEEPSKY_BUT_HAS_A_GENERIC_SPECIAL_BATON // So we drop some generic secboton
				qdel(src)
				user.u_equip(W)
				qdel(W)
		else												// If we used any old stun baton
			if (src.is_dead_beepsky)	// On Beepsky's corpse
				boutput(user, "You give Officer Beepsky a stun baton, reassembling the Securitron! Beep boop.")
				var/obj/machinery/bot/secbot/beepsky/S = new /obj/machinery/bot/secbot/beepsky(get_turf(src))
				S.is_beepsky = IS_BEEPSKY_BUT_HAS_SOME_GENERIC_BATON // So Beepsky's corpse is his corpse
				S.loot_baton_type = W.type	// Our baton isn't special
				qdel(src)
				user.u_equip(W)
				qdel(W)
			else											// On any other securitron assembly?
				boutput(user, "You give the [src] a stun baton, completing the Securitron! Beep boop.")
				var/obj/machinery/bot/secbot/S = new /obj/machinery/bot/secbot(get_turf(src))
				S.beacon_freq = src.beacon_freq
				get_radio_connection_by_id(S, "beacon").update_frequency(S.beacon_freq)
				S.hat = src.hat
				S.name = src.created_name
				S.is_beepsky = IS_NOT_BEEPSKY_AND_HAS_SOME_GENERIC_BATON // You're still not Beepsky
				S.loot_baton_type = W.type	// Our baton isn't special either
				qdel(src)
				user.u_equip(W)
				qdel(W)

	else if (istype(W, /obj/item/rods) && src.build_step == 3)
		var/obj/item/rods/R = W
		if (!R.change_stack_amount(-1))
			boutput(user, "You need a non-zero amount of rods. How did you even do that?")
		else
			src.build_step++
			boutput(user, "You add a rod to [src]'s robot arm!")
			src.name = "helmet/signaler/prox sensor/robot arm/rod assembly"
			src.overlays += image('icons/obj/bots/aibots.dmi', "hs_rod")

	else if (istype(W, /obj/item/cable_coil) && src.build_step >= 4)
		var/obj/item/cable_coil/C = W
		if (!C.use(5))
			boutput(user, "You need a longer length of cable! A length of five should be enough.")
		else if (src.is_dead_beepsky)	// On Beepsky's corpse
			boutput(user, "You add wires to Officer Beepsky, reassembling the Securitron! Beep boop.")
			var/obj/machinery/bot/secbot/beepsky/S = new /obj/machinery/bot/secbot/beepsky(get_turf(src))
			S.is_beepsky = IS_BEEPSKY_BUT_HAS_SOME_GENERIC_BATON	// So Beepsky's corpse is his corpse
			S.loot_baton_type = /obj/item/scrap	// our baton's a hunk of junk!
			qdel(src)
		else
			src.build_step++
			boutput(user, "You add the wires to the rod, completing the Securitron! Beep boop.")
			var/obj/machinery/bot/secbot/S = new /obj/machinery/bot/secbot(get_turf(src))
			S.beacon_freq = src.beacon_freq
			get_radio_connection_by_id(S, "beacon").update_frequency(S.beacon_freq)
			S.hat = src.hat
			S.name = src.created_name
			qdel(src)

	else if (istype(W, /obj/item/pen))
		var/t = input(user, "Enter new robot name", src.name, src.created_name) as text
		if(t && t != src.name && t != src.created_name)
			phrase_log.log_phrase("bot-sec", t)
		t = strip_html(replacetext(t, "'",""))
		t = copytext(t, 1, 45)
		if (!t)
			return
		if (!in_interact_range(src, user) && src.loc != user)
			return

		src.created_name = t

#undef IS_NOT_BEEPSKY_AND_HAS_SOME_GENERIC_BATON
#undef IS_BEEPSKY_AND_HAS_HIS_SPECIAL_BATON
#undef IS_NOT_BEEPSKY_BUT_HAS_HIS_SPECIAL_BATON
#undef IS_BEEPSKY_BUT_HAS_SOME_GENERIC_BATON
#undef IS_NOT_BEEPSKY_BUT_HAS_A_GENERIC_SPECIAL_BATON
#undef PATROL_SPEED
#undef SUMMON_SPEED
#undef ARREST_SPEED
#undef BATON_INITIAL_DELAY
#undef BATON_DELAY_PER_STUN
