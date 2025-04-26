var/global/list/available_ai_shells = list()
var/atom/movable/minimap_ui_handler/ai_minimap_ui
var/global/list/ai_emotions = list("Annoyed" = "ai_annoyed-dol", \
	"Annoyed (Inverted)" = "ai_annoyed-lod", \
	"Baffled" = "ai_baffled-dol",\
	"Baffled (Inverted)" = "ai_baffled-lod",\
	"Blank" = "ai_blank-dol",\
	"Blank (Inverted)" = "ai_blank-lod",\
	"Cheeky" = "ai_cheeky-dol",\
	"Cheeky (Inverted)" = "ai_cheeky-lod",\
	"Colourbars" = "ai_colourbars",\
	"Confused" = "ai_confused-dol",\
	"Confused (Inverted)" = "ai_confused-lod",\
	"Content" = "ai_content-dol",\
	"Content (Inverted)" = "ai_content-lod",\
	"Crecent" = "ai_crecent-dol",\
	"Crecent (Inverted)" = "ai_crecent-lod",\
	"Cursor" = "ai_cursor-dol",\
	"Cursor (Inverted)" = "ai_cursor-lod",\
	"Exclamation" = "ai_exclamation-dol",\
	"Exclamation (Inverted)" = "ai_exclamation-lod",\
	"Eye" = "ai_eye-dol",\
	"Eye (Inverted)" = "ai_eye-lod",\
	"Fidgety" = "ai_fidget-dol",\
	"Fidgety (Inverted)" = "ai_fidget-lod",\
	"Glitch" = "ai_glitch-dol",\
	"Glitch (Inverted)" = "ai_glitch-lod",\
	"Happy" = "ai_happy-dol", \
	"Happy (Inverted)" = "ai_happy-lod", \
	"Heart" = "ai_heart-dol",\
	"Heart (Inverted)" = "ai_heart-lod",\
	"Line" = "ai_line-dol",\
	"Line (Inverted)" = "ai_line-lod",\
	"Loading Bar" = "ai_loading-dol",\
	"Loading Bar (Inverted)" = "ai_loading-lod",\
	"Mad" = "ai_mad-dol",\
	"Mad (Inverted)" = "ai_mad-lod",\
	"Musical" = "ai_music-dol",\
	"Musical (Inverted)" = "ai_music-lod",\
	"Nanotrasen" = "ai_nanotrasen-dol",\
	"Nanotrasen (Inverted)" = "ai_nanotrasen-lod",\
	"Nervous" = "ai_nervous-dol",\
	"Nervous (Inverted)" = "ai_nervous-lod",\
	"Neutral" = "ai_neutral-dol",\
	"Neutral (Inverted)" = "ai_neutral-lod",\
	"Pensive" = "ai_pensive-dol",\
	"Pensive (Inverted)" = "ai_pensive-lod",\
	"Question" = "ai_question-dol",\
	"Question (Inverted)" = "ai_question-lod",\
	"Sad" = "ai_sad-dol",\
	"Sad (Inverted)" = "ai_sad-lod",\
	"Silly" = "ai_silly-dol",\
	"Silly (Inverted)" = "ai_silly-lod",\
	"Smug" = "ai_smug-dol",\
	"Smug (Inverted)" = "ai_smug-lod",\
	"Snoozing" = "ai_zzz-dol",\
	"Snoozing (Inverted)" = "ai_zzz-lod",\
	"Spooky" = "ai_spooky-dol",\
	"Spooky (Inverted)" = "ai_spooky-lod",\
	"Square" = "ai_square-dol",\
	"Square (Inverted)" = "ai_square-lod",\
	"Surprised" = "ai_surprised-dol",\
	"Surprised (Inverted)" = "ai_surprised-lod",\
	"Suspicious" = "ai_eyesemoji-dol",\
	"Suspicious (Inverted)" = "ai_eyesemoji-lod",\
	"Text" = "ai_text-dol",\
	"Text (Inverted)" = "ai_text-lod",\
	"Tired" = "ai_tired-dol",\
	"Tired (Inverted)" = "ai_tired-lod",\
	"Triangle" = "ai_triangle-dol",\
	"Triangle (Inverted)" = "ai_triangle-lod",\
	"Unimpressed" = "ai_unimpressed-dol",\
	"Unimpressed (Inverted)" = "ai_unimpressed-lod",\
	"Unsure" = "ai_unsure-dol",\
	"Unsure (Inverted)" = "ai_unsure-lod",\
	"Very Happy" = "ai_veryhappy-dol",\
	"Very Happy (Inverted)" = "ai_veryhappy-lod",\
	"Wink" = "ai_wink-dol",\
	"Wink (Inverted)" = "ai_wink-lod",\
	"Devious" = "ai_devious-dol",\
	"Devious (Inverted)" = "ai_devious-lod") // this should be in typeinfo
/mob/living/silicon/ai
	name = "AI"
	voice_name = "synthesized voice"
	icon = 'icons/mob/ai.dmi'
	icon_state = "ai"
	anchored = ANCHORED
	density = 1
	syndicate_possible = 1 // Can become a rogue computer.
	var/default_hat_y = 14
	var/datum/hud/silicon/ai/hud
	var/last_notice = 0//attack notices
	/// Camera networks we can connect to
	var/list/camera_networks = list(
		CAMERA_NETWORK_STATION,
		CAMERA_NETWORK_PUBLIC,
		CAMERA_NETWORK_ROBOTS,
		CAMERA_NETWORK_RANCH,
		CAMERA_NETWORK_SCIENCE,
		CAMERA_NETWORK_CARGO,
		CAMERA_NETWORK_AI_ONLY,
	)
	var/classic_move = 1 //Ordinary AI camera movement
	var/obj/machinery/camera/current = null
	var/obj/machinery/camera/camera = null //Our internal camera for seeing from core while in eye
	var/list/connected_robots = list()
	//var/list/connected_shells = list()
	var/list/installed_modules = list()
	var/aiRestorePowerRoutine = 0
	var/printalerts = 1
	var/glitchy_speak = 0
	//Comm over powernet stuff
	var/net_id = null
	var/obj/machinery/power/data_terminal/link = null
	var/list/terminals = list() //Stuff connected to us over the powernet
	var/messageLog = ""
	/// controls whether or not the ai will hear termos message notifications
	var/termMute = FALSE
	var/canvox = 1
	var/can_announce = 1
	var/bought_hat = FALSE
	var/last_announcement = -INFINITY
	var/announcement_cooldown = 1200
	var/dismantle_stage = 0
	var/datum/light/light
	//var/death_timer = 100
	var/power_mode = 0
	var/power_area = null
	var/obj/machinery/power/apc/local_apc = null
	var/obj/item/device/radio/radio1 = null // See /mob/living/say() in living.dm for ai_related radio code.
	var/obj/item/device/radio/radio2 = null
	var/obj/item/device/radio/radio3 = null
	var/obj/item/device/pda2/internal_pda = null
	var/obj/item/organ/brain/brain = null
	var/moustache_mode = 0
	var/status_message = null
	var/mob/living/silicon/deployed_shell = null
	var/locking = 0
	HELP_MESSAGE_OVERRIDE(null)

	var/faceEmotion = "ai_happy-dol"
	var/faceColor = "#66B2F2"
	var/list/custom_emotions = null
	///Maximum number of viewports we can have open, unlimited vision was a bit silly
	var/viewport_limit = 2
	/// The icon_state for the outside non-screen bit of the core. icon_state is set to this in update_appearance() (which is called by New)
	var/coreSkin = "default"
/* To add a new skin:
- Create the skin itself but also the overlay you want to have for when in battery mode
- The name of the core icon state will be used to fetch the battery mode overlay, so your batmode overlay
- should be the name of your core icon state with "lights_bat-" before it
- Ditto for when the AI is online as normal (should you choose to have an overlay for this). Prefix with "lights_apc-"
- Add the icon state name to skinsList below, and while it's technically optional, you should also associate a short description with it
- There is currently no support for significantly differently shaped cores, you'll have to do that yourself, sorry
*/
/* Addit. note from casing overhaul PR--
There is... some support for cores with different tops now! Not much, but some
if you're adding a new frame you should declare which open top overlay that new frame should use
(search for "if (src.dismantle_stage > 1)" you'll find where those declares are)
just add the name of your casing to one of those given checks
or don't if it uses a custom topopen overlay
*/

	/// List of valid skins and their descriptions. Used for validation of setSkin()
	var/skinsList = list(
		"default" = "The casing appears to be a standard NanoTrasen AI core.",
		"science" = "The casing is made out of a white plastic and has a prominent purple stripe painted down the front.",
		"medical" = "The casing is made out of a white plastic and has a prominent red stripe painted down the front.",
		"ntold" = "A much older model of NanoTrasen AI core. The stark white has faded to eggshell with time.",
		"bee" = "The casing has been painted and given little plastic antennae to make it resemble a bee!",
		"shock" = "The casing is painted a luminescent blue and has what looks to be neon light tubes built into it!",
		"gold" = "The casing seems to be made out of gold. No, wait. Looking closer, you think that's actually pyrite.",
		"engineering" = "The casing is made out of a buffed metal and has a prominent orange stripe painted down the front.",
		"soviet" = "The latest in Soviet artificial intelligence technology. And by latest, you mean this thing looks like it's been collecting dust for decades.",
		"nt" = "A newer model of NanoTrasen AI core. It's been painted a greyish-blue, and proudly displays the NT logo below the screen.",
		"industrial" = "The casing is made out of a sleek and polished alloy. It looks heavily reinforced- wait, no. No, that's just a really impressive paint job.",
		"lgun" = "The casing is made out of pieces of colourful pink plastic clipped together. It looks like a toy.",
		"dwaine" = "The casing has a label saying \"Thinktronic Data Systems, LLC\". Jeez, how old is this?",
		"ailes" = "A bulky computational powerhouse- or, at least, it would have been twenty-odd years ago. The logo below the screen has been scratched off with something sharp.",
		"salvage" = "A significantly worse-for-wear NanoTrasen AI core, haphazardly repaired back to working order with what looks to be scrap metal and spare parts.",
		"gardengear" = "\"Product of GardenGear\" is etched into the side of the casing.",
		"telegun" = "The casing is made out of pieces of colourful blue plastic clipped together. It looks like a toy.",
		"kingsway" = "'Kingsway Systems 29A' is etched into the aged plastic casing beneath the screen.",
		"syndicate" = "The casing is covered in Syndicate markings! On second glance, it seems like the panels are pieces of toy plastic clipped together. Wow.",
		"clown" = "Crayon and questionable stains constitute the majority of the casing's exterior. What the fuck even is this thing?",
		"mime" = "The casing has been painted to clearly resemble a mime.",
		"tactical" = "The casing is made out of a dark grey plastic and is covered in clearly purposeless grooves and fans and whatelse. Very tacticool.",
		"mauxite" = "The core has been hammered together out of jagged sheets of mauxite.",
		"flock" = "The casing is made out of a humming teal material. It pulses and flares to a strange rhythm.",
		"pumpkin" = "The casing is made out of a pumpkin. Spooky!",
		"crt" = "The core appears to be a... CRT television. Huh.",
		"rustic" = "The core appears to be... a box. Where are the beveled edges?! This core isn't a weird octagonal prism at all, it's just a cube!",
		"cardboard" = "The core appears to be made out of cardboard. Huh. ...Well, it's probably still just as good at opening doors."
	)

	var/datum/ai_camera_tracker/tracker = null

	var/image/cached_image = null

	var/last_vox = -INFINITY
	var/vox_cooldown = 1200

	var/rename_cooldown = 10 MINUTES

	var/has_feet = 0

	sound_fart = 'sound/voice/farts/poo2_robot.ogg'

	req_access = list(access_heads)

	var/fire_res_on_core = 0

	health = 250
	max_health = 250
	var/bruteloss = 0
	var/fireloss = 0

	var/mob/living/intangible/aieye/eyecam = null
	var/obj/minimap/ai/ai_station_map

	var/deployed_to_eyecam = 0
	var/datum/ai_hologram_data/holoHolder = new
	var/list/hologramContextActions

/mob/living/silicon/ai/proc/give_feet()
	animate(src, pixel_y = 14, time = 5, easing = SINE_EASING)
	has_feet = 1
	var/obj/churn = new/obj{icon = 'icons/misc/SomepotatoArt.dmi'; pixel_y = -14; icon_state = "feet"}
	underlays += churn
	qdel(churn)
	canmove = 1

/mob/living/silicon/ai/TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss)
	bruteloss += brute
	fireloss += burn
	health_update_queue |= src
	notify_attacked()

/mob/living/silicon/ai/HealDamage(zone, brute, burn)
	bruteloss = max(0, bruteloss - brute)
	fireloss = max(0, fireloss - burn)
	health_update_queue |= src

/mob/living/silicon/ai/get_brute_damage()
	return bruteloss

/mob/living/silicon/ai/get_burn_damage()
	return fireloss

/mob/living/silicon/ai/can_strip()
	return 0

/mob/living/silicon/ai/full_heal()
	..()
	src.turn_it_back_on()

/mob/living/silicon/ai/emag_act(mob/user, obj/item/card/emag/E)
	if(!src.emaggable)
		boutput(user, SPAN_ALERT("You try to swipe your emag along [src]'s interface, but it grows hot in your hand and you almost drop it!"))
		return FALSE
	if (src.dismantle_stage >= 2)
		boutput(user, SPAN_ALERT("You must close the cover to swipe an ID card."))
		return FALSE
	if (!src.emagged)
		src.emagged = TRUE
		boutput(user, SPAN_NOTICE("You short out [src]'s cover lock."))
		if(dismantle_stage < 2)
			dismantle_stage = 2
		elecflash(src)
		src.update_appearance()
		return 1
	return 0


/mob/living/silicon/ai/get_help_message(dist, mob/user)
	switch(src.dismantle_stage)
		if(0)
			. = "You can swipe an <b>ID card</b> to unlock the cover."
		if(1)
			. = "You can use a <b>crowbar</b> to pry open the cover, or swipe an <b>ID card</b> to lock it."
		if(2)
			. = "You can use a <b>wrench</b> to undo the CPU bolts, <b>cable coil</b> to repair damage, or a <b>crowbar</b> to close the cover."
		if(3)
			. = "You can use a <b>wrench</b> to tighten the CPU bolts, or an <b>empty hand</b> to remove the CPU unit."
		if(4)
			. = "You can insert a <b>brain</b> to activate the AI."
	if(src.dismantle_stage < 4 && isdead(src))
		. += " You can use an <b>empty hand</b> to reboot the AI."
	. += " You can also use a <b>screwdriver</b> to [src.anchored ? "unscrew" : "screw down"] the floor bolts."

/mob/living/silicon/ai/disposing()
	STOP_TRACKING

	if (deployed_to_eyecam)
		eyecam.return_mainframe()
		qdel(eyecam)
		eyecam = null

	if (deployed_shell)
		src.return_to(deployed_shell)
		src.deployed_shell = null

	if (light)
		light.dispose()
	for (var/obj/machinery/ai_status_display/O in machine_registry[MACHINES_STATUSDISPLAYS]) //change status
		if (O.owner == src)
			O.is_on = FALSE
			O.owner = null
			O.emotion = null
			O.message = null
			O.face_color = null
	..()

/mob/living/silicon/ai/New(loc, var/empty = 0, var/skinToApply = "default")
	..(loc)
	START_TRACKING

	APPLY_ATOM_PROPERTY(src, PROP_MOB_EXAMINE_ALL_NAMES, src)

	ai_station_map = new /obj/minimap/ai
	ai_station_map.initialise_minimap()
	AddComponent(/datum/component/minimap_marker/minimap, MAP_AI | MAP_SYNDICATE | MAP_OBSERVER, "ai")
	SPAWN(0)
		if (bought_hat || prob(5))
			AddComponent(/datum/component/hattable, TRUE, TRUE, default_hat_y)
		else
			AddComponent(/datum/component/hattable, TRUE, FALSE, default_hat_y)
	light = new /datum/light/point
	light.set_color(0.4, 0.7, 0.95)
	light.set_brightness(0.6)
	light.set_height(0.75)
	light.attach(src)
	light.enable()

	if (!empty) // /obj/ai_core_frame calls new here with empty = 1 so that this will spawn brainless and someone else's brain can be put in
		src.brain = new /obj/item/organ/brain/ai(src)

	src.local_apc = get_local_apc(src)
	src.power_area = get_area(src.local_apc)
	src.cell = new /obj/item/cell(src)
	src.radio1 = new /obj/item/device/radio(src)
	src.radio2 = new /obj/item/device/radio(src)
	src.radio3 = new /obj/item/device/radio/headset/command/ai(src)
	src.internal_pda = new /obj/item/device/pda2/ai(src)

	src.tracker = new /datum/ai_camera_tracker(src)
	src.coreSkin = skinToApply
	src.set_color(global.random_color())
	src.faceEmotion = global.ai_emotions[pick(global.ai_emotions)]
	src.AddOverlays(SafeGetOverlayImage("backscreen", 'icons/mob/ai.dmi', "ai_blank"), "backscreen")
	update_appearance()

	src.eyecam = new /mob/living/intangible/aieye(src)

	hud = new(src)
	src.attach_hud(hud)
	src.eyecam.attach_hud(hud)

	abilityHolder = new /datum/abilityHolder/silicon/ai(src)
	if(eyecam)
		eyecam.abilityHolder = abilityHolder

	if(law_rack_connection)
		holoHolder.text_expansion = law_rack_connection.holo_expansions.Copy()

		for(var/ability_type in law_rack_connection.ai_abilities)
			abilityHolder.addAbility(ability_type)

	src.hologramContextActions = list()
	for(var/actionType in childrentypesof(/datum/contextAction/ai_hologram))
		var/datum/contextAction/ai_hologram/action = new actionType(src)
		hologramContextActions += action




	SPAWN(0)
		src.botcard.access = get_all_accesses()
		src.botcard.registered = "AI"
		src.botcard.assignment = "AI"
		src.cell.charge = src.cell.maxcharge
		src.radio1.name = "Primary Radio"
		src.radio2.name = "AI Intercom Monitor"
		src.radio2.device_color = "#7F7FE2"
		src.radio3.name = "Secure Channels Monitor"
		src.radio1.broadcasting = FALSE
		src.radio2.set_frequency(R_FREQ_INTERCOM_AI)
		src.radio3.broadcasting = FALSE
		src.internal_pda.name = "AI's Internal PDA Unit"
		src.internal_pda.owner = "AI"
		if (src.brain && src.key)
			src.brain.name = "neural net processor"
			src.brain.owner = src.mind

	SPAWN(0.6 SECONDS)
		src.net_id = format_net_id("\ref[src]")

		update_terminal()

		for (var/mob/living/silicon/hivebot/eyebot/E in mobs)
			if (!(E in available_ai_shells))
				available_ai_shells += E

		for (var/mob/living/silicon/robot/R in mobs)
			if (!R.part_head || R.part_head.brain || !R.part_head.ai_interface || R.dependent)
				continue
			if (!(R in available_ai_shells))
				available_ai_shells += R
		if(!isnull(src.client))
			src.bioHolder.mobAppearance.pronouns = src.client.preferences.AH.pronouns
			src.update_name_tag()

		src.camera = new /obj/machinery/camera/auto/AI(src)
		src.camera.c_tag = src.real_name
		src.camera.network = CAMERA_NETWORK_ROBOTS

//Returns either the AI mainframe or the eyecam mob, depending on whther or not we are deployed
/mob/living/silicon/ai/proc/get_message_mob()
	RETURN_TYPE(/mob)

	if (deployed_to_eyecam)
		return src.eyecam
	return src

/mob/living/silicon/ai/show_message(msg, type, alt, alt_type, group = "", var/just_maptext, var/image/chat_maptext/assoc_maptext = null)
	..()
	if (deployed_to_eyecam && src.eyecam)
		src.eyecam.show_message(msg, 1, 0, 0, group)
	return

/mob/living/silicon/ai/show_text(var/message, var/color = "#000000", var/hearing_check = 0, var/sight_check = 0, var/allow_corruption = 0, var/group)
	..()
	if (deployed_to_eyecam && src.eyecam)
		src.eyecam.show_text(message, color, 0, sight_check, allow_corruption, group)
	return

/// For use when you want to send text to the AI player regardless of it's in its mainframe, eye, or shell
/// Calls show_text(), use its syntax
/mob/living/silicon/ai/proc/textToPlayer(var/message, var/color = "#000000", var/hearing_check = 0, var/sight_check = 0, var/allow_corruption = 0, var/group)
	if (src.deployed_shell)
		src.deployed_shell.show_text(message, color, hearing_check, sight_check, allow_corruption, group)
	else
		src.show_text(message, color, hearing_check, sight_check, allow_corruption, group)

/// For use when you want to play a sound to the AI player regardless of if it's in mainframe, eye, or shell
/// Calls playsound_local(), use its syntax
/mob/living/silicon/ai/proc/soundToPlayer(soundin, vol as num, vary, extrarange as num, pitch = 1, ignore_flag = 0, channel = VOLUME_CHANNEL_GAME, flags = 0)
	if (deployed_to_eyecam && src.eyecam)
		src.eyecam.playsound_local(src.eyecam, soundin, vol, vary, extrarange, pitch, ignore_flag, channel, flags)
	else if (src.deployed_shell)
		src.deployed_shell.playsound_local(src.deployed_shell, soundin, vol, vary, extrarange, pitch, ignore_flag, channel, flags)
	else
		src.playsound_local(src, soundin, vol, vary, extrarange, pitch, ignore_flag, channel, flags)

///mob/living/silicon/ai/playsound_local(var/atom/source, soundin, vol as num, vary, extrarange as num, pitch = 1, ignore_flag = 0, channel = VOLUME_CHANNEL_GAME)
//sound.dm


/mob/living/silicon/ai/attackby(obj/item/W, mob/user)
	if (istype(W,/obj/item/device/borg_linker) && !isghostdrone(user))
		var/obj/item/device/borg_linker/linker = W
		if(src.dismantle_stage<2)
			boutput(user, "You need to open [src.name]'s cover before you can change [his_or_her(src)] law rack link.")
			return

		if(!src.law_rack_connection)
			boutput(src,"[src.name] is not connected to a law rack")
		else
			var/area/A = get_area(src.law_rack_connection)
			boutput(user, "[src.name] is connected to a law rack at [A.name].")

		if(!linker.linked_rack)
			return

		if(linker.linked_rack in ticker.ai_law_rack_manager.registered_racks)
			if(src.law_rack_connection)
				var/raw = tgui_alert(user,"Do you want to overwrite the linked rack?", "Linker", list("Yes", "No"))
				if (raw == "Yes")
					src.set_law_rack(linker.linked_rack, user)
		else
			boutput(user,"Linker lost connection to the stored law rack!")
		return

	if (isscrewingtool(W))
		src.anchored = !src.anchored
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		user.visible_message(SPAN_ALERT("<b>[user.name]</b> [src.anchored ? "screws down" : "unscrews"] [src.name]'s floor bolts."))
		src.update_terminal()

	else if (ispryingtool(W))
		if (src.dismantle_stage == 1)
			playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
			src.visible_message(SPAN_ALERT("<b>[user.name]</b> opens [src.name]'s chassis cover."))
			src.locking = 0
			src.dismantle_stage = 2
		else if (src.dismantle_stage == 2)
			playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
			src.visible_message(SPAN_ALERT("<b>[user.name]</b> closes [src.name]'s chassis cover."))
			src.dismantle_stage = 1
		else ..()

	else if (iswrenchingtool(W))
		if (src.dismantle_stage == 2)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			src.visible_message(SPAN_ALERT("<b>[user.name]</b> begins undoing [src.name]'s CPU bolts."))
			SETUP_GENERIC_ACTIONBAR(user, src, 6 SECONDS, PROC_REF(toggle_CPU_bolts), list(user), W.icon, W.icon_state, null,\
				INTERRUPT_MOVE | INTERRUPT_ACTION | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACT)
		else if (src.dismantle_stage == 3)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			src.visible_message(SPAN_ALERT("<b>[user.name]</b> begins affixing [src.name]'s CPU bolts."))
			SETUP_GENERIC_ACTIONBAR(user, src, 6 SECONDS, PROC_REF(toggle_CPU_bolts), list(user), W.icon, W.icon_state, null,\
				INTERRUPT_MOVE | INTERRUPT_ACTION | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACT)
		else ..()

	else if (isweldingtool(W))
		if(src.bruteloss)
			if(W:try_weld(user, 1))
				src.add_fingerprint(user)
				src.HealDamage(null, 15, 0)
				src.visible_message(SPAN_ALERT("<b>[user.name]</b> repairs some of the damage to [src.name]'s chassis."))
		else boutput(user, SPAN_ALERT("There's no structural damage on [src.name] to mend."))

	else if(istype(W, /obj/item/cable_coil) && dismantle_stage >= 2)
		var/obj/item/cable_coil/coil = W
		src.add_fingerprint(user)
		if(src.fireloss)
			playsound(src.loc, 'sound/impact_sounds/Generic_Stab_1.ogg', 50, 1)
			coil.use(1)
			src.HealDamage(null, 0, 15)
			src.visible_message(SPAN_ALERT("<b>[user.name]</b> repairs some of the damage to [src.name]'s wiring."))
		else boutput(user, SPAN_ALERT("There's no burn damage on [src.name]'s wiring to mend."))

	else if (istype(get_id_card(W), /obj/item/card/id))
		if (src.dismantle_stage >= 2)
			boutput(user, SPAN_ALERT("You must close the cover to swipe an ID card."))
		else
			if(src.emagged)
				boutput(user, SPAN_ALERT("[src.name]'s cover lock has been shorted out!"))
			if(src.allowed(user))
				if (src.dismantle_stage == 1)
					src.dismantle_stage = 0
				else
					src.dismantle_stage = 1
				src.locking = 0
				user.visible_message(SPAN_ALERT("<b>[user.name]</b> [src.dismantle_stage ? "unlocks" : "locks"] [src.name]'s cover lock."))
			else boutput(user, SPAN_ALERT("Access denied."))

	else if (istype(W, /obj/item/organ/brain/) && src.dismantle_stage == 4)
		if (src.brain)
			boutput(user, SPAN_ALERT("There's already a brain in there!"))
		else
			user.visible_message(SPAN_ALERT("<b>[user.name]</b> inserts [W] into [src.name]."))
			user.drop_item()
			W.set_loc(src)
			var/obj/item/organ/brain/B = W
			if (B.owner && (B.owner.get_player()?.dnr || jobban_isbanned(B.owner.current, "AI")))
				src.visible_message(SPAN_ALERT("\The [B] is hit by a spark of electricity from \the [src]!"))
				B.combust()
				return
			if(B.owner)
				if(B.owner.current)
					if(B.owner.current.client)
						src.lastKnownIP = B.owner.current.client.address
				B.owner.transfer_to(src)
				if (src.syndicate)
					src.make_syndicate("brain added by [user]")
			W.set_loc(src)
			src.brain = W
			src.dismantle_stage = 3
			if (!src.syndicate) // The antagonist proc does that too.
				src.show_text("<B>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</B>")
				src.show_text("<B>To look at other parts of the station, double-click yourself to get a camera menu.</B>")
				src.show_text("<B>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</B>")
				src.show_text("To use something, simply click it.")
				src.show_text("Use the prefix <B>:s</B> to speak to fellow silicons through binary.")
				src.show_laws()
				src.verbs += /mob/living/silicon/ai/proc/ai_call_shuttle
				src.verbs += /mob/living/silicon/ai/proc/show_laws_verb
				src.verbs += /mob/living/silicon/ai/proc/reset_apcs
				src.verbs += /mob/living/silicon/ai/proc/de_electrify_verb
				src.verbs += /mob/living/silicon/ai/proc/unbolt_all_airlocks
				src.verbs += /mob/living/silicon/ai/proc/ai_camera_track
				src.verbs += /mob/living/silicon/ai/proc/ai_alerts
				src.verbs += /mob/living/silicon/ai/proc/ai_camera_list
				src.verbs += /mob/living/silicon/ai/proc/ai_statuschange
				src.verbs += /mob/living/silicon/ai/proc/ai_state_laws_all
				src.verbs += /mob/living/silicon/ai/proc/ai_state_laws_standard
				src.verbs += /mob/living/silicon/ai/proc/ai_set_fake_laws
				src.verbs += /mob/living/silicon/ai/proc/ai_state_fake_laws
				src.verbs += /mob/living/silicon/ai/verb/deploy_to
				src.verbs += /mob/living/silicon/ai/proc/ai_view_crew_manifest
				src.verbs += /mob/living/silicon/ai/proc/toggle_alerts_verb
				src.verbs += /mob/living/silicon/ai/verb/access_internal_radio
				src.verbs += /mob/living/silicon/ai/verb/access_internal_pda
				src.verbs += /mob/living/silicon/ai/proc/ai_colorchange
				src.verbs += /mob/living/silicon/ai/proc/ai_station_announcement
				src.verbs += /mob/living/silicon/ai/proc/view_messageLog
				src.verbs += /mob/living/silicon/ai/verb/rename_self
				src.verbs += /mob/living/silicon/ai/verb/go_offline
				src.job = "AI"
				if (src.mind)
					src.mind.assigned_role = "AI"
				SPAWN(0)
					src.choose_name(3)

	else if (istype(W, /obj/item/roboupgrade/ai/))
		if (src.dismantle_stage >= 2 && src.dismantle_stage < 4)
			var/obj/item/roboupgrade/ai/R = W
			user.visible_message(SPAN_ALERT("<b>[user.name]</b> inserts [R] into [src.name]."))
			user.drop_item()
			R.set_loc(src)
			R.slot_in(src)
		else if (src.dismantle_stage == 4 || isdead(src))
			boutput(user, SPAN_ALERT("Using this on a deactivated AI would be pointless."))
		else
			boutput(user, SPAN_ALERT("You need to open the AI's chassis cover to insert this. Unlock it with a card and then pry it open."))

	else if (istype(W, /obj/item/clothing/mask/moustache/))
		if (src.moustache_mode == 0)
			src.moustache_mode = 1
			user.visible_message(SPAN_ALERT("<b>[user.name]</b> uploads a moustache to [src.name]!"))
		else if (src.dismantle_stage == 4 || isdead(src))
			boutput(user, SPAN_ALERT("Using this on a deactivated AI would be silly."))
		return
	else if(istype(W,/obj/item/ai_plating_kit))
		if(src.coreSkin != "default") // to avoid having your hard-earned skin being lost because someone bought the clown one or something
			user.show_message(SPAN_ALERT("[src] already has a plating kit installed!"))
		else
			var/obj/item/ai_plating_kit/kit = W
			src.setSkin(kit.skin)
			playsound(src.loc, 'sound/impact_sounds/Generic_Stab_1.ogg', 50, 1)
			user.visible_message(SPAN_NOTICE("[user] permanently installs the [W] on [src]!"))
			qdel(W)
			//if(istype(W,/obj/item/ai_plating_kit/flock) && src.brain)
			//	src.brain = new /obj/item/organ/brain/flockdrone(src)
			//	src.brain.owner = src.mind
			//would be cool if the flock kit turned the ais brain into a flockbrain bc funny flockbrain messages
			//but also idk how that would work with the ai eye/deploying and all of that so its honestly just not worth it

	else ..()
	src.update_appearance()

/mob/living/silicon/ai/click(atom/target, params)
	if (!src.stat)
		if (!src.client.check_any_key(KEY_EXAMINE | KEY_OPEN | KEY_BOLT | KEY_SHOCK | KEY_POINT) ) // ugh
			//only allow Click-to-track on mobs. Some of the 'trackable' atoms are also machines that can open a dialog and we don't wanna mess with that!
			if (ismob(target) && is_mob_trackable_by_AI(target))
				ai_actual_track(target)
				return
	. = ..()

/mob/living/silicon/ai/build_keybind_styles(client/C)
	..()
	C.apply_keybind("robot")

	if (!C.preferences.use_wasd)
		C.apply_keybind("robot_arrow")

	if (C.preferences.use_azerty)
		C.apply_keybind("robot_azerty")
	if (C.tg_controls)
		C.apply_keybind("robot_tg")

/mob/living/silicon/ai/proc/eject_brain(var/mob/user, var/fling = FALSE)
	src.dismantle_stage = 4
	if (user)
		src.visible_message(SPAN_ALERT("<b>[user.name]</b> removes [src.name]'s CPU unit!"))
		logTheThing(LOG_COMBAT, user, "removes [constructTarget(src,"combat")]'s brain at [log_loc(src)].") // Should be logged, really (Convair880).
	else
		src.visible_message(SPAN_ALERT("<b>[src.name]'s</b> CPU unit is launched out of its core!"))

	// Stick the player (if one exists) in a ghost mob
	src.death()
	if (src.mind)
		var/mob/dead/observer/newmob = src.ghostize()
		if (newmob && istype(newmob, /mob/dead/observer))
			newmob.corpse = null //Otherwise they could return to a brainless body.  And that is weird.
			newmob.mind.brain = src.brain
			src.brain.owner = newmob.mind
			for (var/datum/antagonist/antag in newmob.mind.antagonists)
				antag.on_death()
	if (user)
		user.put_in_hand_or_drop(src.brain)
	else
		src.brain.set_loc(get_turf(src))
		if (fling)
			src.brain.throw_at(get_edge_cheap(get_turf(src), pick(cardinal)), 5, 1) // heh

	src.brain = null


/mob/living/silicon/ai/proc/try_rebooting_it(mob/user)

	if (!user)
		if (isdead(src))
			// yeah ok i guess we'll just go right on ahead and try turning it on again.
			return src.turn_it_back_on()
		else
			// how did. what. no.
			return

	if (!isdead(src))
		boutput(user, "[src.name] is working! How did you even get here?")
		return

	if (src.turn_it_back_on())
		user.visible_message(SPAN_ALERT("<b>[user.name]</b> pokes the restart button on [src.name]! [src.name] beeps and starts to come online!")) //revived, transferred client to
		return TRUE
	else if(!isobserver(src.brain.owner?.current))
		user.visible_message(SPAN_ALERT("<b>[user.name]</b> pokes the restart button on [src.name]! [src.name] comes online, but remains in hiberation mode.")) //revived, didn't transfer client to
	else
		user.visible_message(SPAN_ALERT("<b>[user.name]</b> pokes the restart button on [src.name], but [src.name] beeps and shuts down, too damaged to power on.")) //didn't revive


/mob/living/silicon/ai/proc/turn_it_back_on()
	if (src.health >= 50 && src.brain)
		setalive(src)
		if (src.brain.owner && src.brain.owner.current)
			if (!find_ghost_by_key(src.brain.owner.current.key)) // we don't actually need a ref to the mob (since we already have that via current)
																// just using this proc to check for VR/afterlife/ghostcritter/etc
				return FALSE
			var/mob/ghost = src.brain.owner.current
			ghost.show_text(SPAN_ALERT("<B>You feel your self being pulled back from the afterlife!</B>"))
			ghost.mind.transfer_to(src)
			if (isdead(ghost))
				qdel(ghost)
			update_appearance()
		return TRUE
	return FALSE

/// for dismantle action bar
/mob/living/silicon/ai/proc/toggle_CPU_bolts(mob/user)
	switch(src.dismantle_stage)
		if(2)
			src.visible_message(SPAN_ALERT("<b>[user.name]</b> removes [src.name]'s CPU bolts."))
			src.dismantle_stage = 3
		if(3)
			src.visible_message(SPAN_ALERT("<b>[user.name]</b> puts [src.name]'s CPU bolts into place."))
			src.dismantle_stage = 2

/mob/living/silicon/ai/attack_hand(mob/user)
	var/list/actions = list("Do Nothing")

	if (src.dismantle_stage >= 2 && length(src.installed_modules) > 0)
		actions += "Remove a module"
	if (src.dismantle_stage == 3)
		actions += "Remove CPU Unit"
	if (src.dismantle_stage < 4 && isdead(src))
		actions += "Restart AI"

	if (length(actions) > 1)
		var/action_taken = tgui_input_list(user, "What do you want to do?", "AI Unit", actions)
		if (!action_taken)
			return
		switch (action_taken)
			if ("Remove CPU Unit")
				src.eject_brain(user)

			if ("Restart AI")
				src.try_rebooting_it(user)

			if ("Remove a module")
				if (istype(src.installed_modules[1],/obj/item/roboupgrade/ai/))
					var/obj/item/roboupgrade/ai/A = src.installed_modules[1]
					A.slot_out(src)
					user.put_in_hand_or_drop(A)
					src.visible_message(SPAN_ALERT("<b>[user.name]</b> removes [A] from [src]."))
	else
		switch(user.a_intent)
			if(INTENT_HELP)
				if (isdead(src))
					src.try_rebooting_it(user)
				else
					user.visible_message(SPAN_ALERT("<b>[user.name]</b> pats [src.name] on the head."))
			if(INTENT_DISARM)
				user.visible_message(SPAN_ALERT("<b>[user.name]</b> shoves [src.name] around a bit."))
				playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1)
			if(INTENT_GRAB)
				user.visible_message(SPAN_ALERT("<b>[user.name]</b> grabs and shakes [src.name]."))
				playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1)
			if(INTENT_HARM)
				user.visible_message(SPAN_ALERT("<b>[user.name]</b> kicks [src.name]."))
				logTheThing(LOG_COMBAT, user, "kicks [constructTarget(src,"combat")]")
				playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
				if (prob(20))
					src.bruteloss += 1
				if (ishuman(user) && prob(10))
					var/mob/living/carbon/human/M = user
					boutput(user, SPAN_ALERT("You stub your toe! Ouch!"))
					M.TakeDamage(M.hand ? "r_leg" : "l_leg", 3, 0, 0, DAMAGE_BLUNT)
					user.changeStatus("knockdown", 2 SECONDS)
		user.lastattacked = get_weakref(src)
	src.update_appearance()

/mob/living/silicon/ai/blob_act(var/power)
	if (!isdead(src))
		src.bruteloss += power
		health_update_queue |= src
		src.update_appearance()
		return 1
	return 0

/mob/living/silicon/ai/bullet_act(var/obj/projectile/P)
	..()
	log_shot(P,src) // Was missing (Convair880).
	src.update_appearance()

/mob/living/silicon/ai/ex_act(severity)
	..() // Logs.
	src.flash(3 SECONDS)

	var/b_loss = src.bruteloss
	var/f_loss = src.fireloss
	switch(severity)
		if(1)
			if (!isdead(src))
				b_loss += rand(90,120)
				f_loss += rand(90,120)
		if(2)
			if (!isdead(src))
				b_loss += rand(60,90)
				f_loss += rand(60,90)
		if(3)
			if (!isdead(src))
				b_loss += rand(30,60)
	src.bruteloss = b_loss
	src.fireloss = f_loss
	health_update_queue |= src
	src.update_appearance()

/mob/living/silicon/ai/emp_act()
	if (prob(30))
		if (prob(50))
			src.cancel_camera()
		else
			src.ai_call_shuttle()

/mob/living/silicon/ai/restrained()
	return 0

/mob/living/silicon/ai/Topic(href, href_list)
	..()
	if (usr != src && usr != src.eyecam && usr != src.deployed_shell)
		return

	if (href_list["switchcamera"])
		//src.cameraFollow = null
		tracker.cease_track()
		switchCamera(locate(href_list["switchcamera"]))
	if (href_list["showalerts"])
		ai_alerts()
	if (href_list["termmsg"]) //Oh yeah, message that terminal!
		var/termid = href_list["termmsg"]
		if(!termid || !(termid in src.terminals))
			src.textToPlayer("That terminal is not connected!")
			return
		var/t = input(usr, "Please enter message", termid, null) as text
		if (!t)
			return

		if(isdead(src))
			src.textToPlayer("You cannot interface with a terminal because you are dead!")
			return

		if(!(termid in src.terminals)) // for if the jerk disconnected while we were typing a response >:(
			src.textToPlayer("--- [termid] is disconnected!")
			return

		t = copytext(adminscrub(t), 1, 301)
		src.textToPlayer("<b>Replied to [termid] with:</b> \"<i>[t]</i>\"")

		//Send the actual message signal
		src.post_status(termid, "command","term_message","data",t)

		//Might as well log what they said too!
		logTheThing(LOG_DIARY, src, ": [t]", "say")
		src.messageLog += "\[[formattedShiftTime(TRUE)]\] <i>Replied to </i><b>[termid]</b><i> with:</i><br>[t]<hr>"

	if (href_list["mute"])
		src.toggleTermMute()

	if (href_list["refresh"])
		src.view_messageLog()

	if (href_list["net_id"]) // this is triggered by examine() in atom.dm, though you should be able to use this from elsewhere!
		var/id = href_list["net_id"]
		var/owner = href_list["owner"]
		var/message = input(usr, "Please enter message", owner, null)
		internal_pda.host_program.pda_message(id, owner, message)

	return

/mob/living/silicon/ai/Stat()
	..()
	if(src.cell)
		stat("Internal Power Cell:", "[src.cell.charge]/[src.cell.maxcharge]")

/mob/living/silicon/ai/meteorhit(obj/O as obj)
	for(var/mob/M in viewers(src, null))
		M.show_message(SPAN_ALERT("[src] has been hit by [O]"), 1)
		//Foreach goto(19)
	if (src.health > 0)
		src.bruteloss += 30
		if ((O.icon_state == "flaming"))
			src.fireloss += 40
		health_update_queue |= src
	return

/mob/living/silicon/ai/show_laws(var/everyone = 0, var/mob/relay_laws_for_shell)
	var/who

	if (everyone)
		who = world
	else if (relay_laws_for_shell && ismob(relay_laws_for_shell))
		who = relay_laws_for_shell
		boutput(who, "<b>Obey these laws:</b>")
	else
		who = src
		boutput(who, "<b>Obey these laws:</b>")

	if (relay_laws_for_shell != src.eyecam && src.deployed_to_eyecam)
		who = src.eyecam
		boutput(who, "<b>Obey these laws:</b>")

	if(src.law_rack_connection)
		src.law_rack_connection.show_laws(who)
	else
		boutput(src,"You have no laws!")
	return

/mob/living/silicon/ai/triggerAlarm(var/class, area/alarm_area, var/list/camera_list, var/alarmsource)
	if (isdead(src))
		return
	var/obj/machinery/camera/single_camera = null
	if (length(camera_list) == 1)
		single_camera = camera_list[1]

	if (!printalerts)
		return

	if (!single_camera && !camera_list)
		src.show_text("--- [class] alarm detected in [alarm_area.name]! ( No Camera )")
		return

	if (single_camera?.camera_status)
		src.show_text("--- [class] alarm detected in [alarm_area.name]! ( <A HREF=\"byond://?src=\ref[src];switchcamera=\ref[single_camera]\">[single_camera.c_tag]</A> )")
	else if (length(camera_list))
		var/first_cam = TRUE
		var/cameras_string = ""
		for (var/obj/machinery/camera/camera in camera_list)
			cameras_string += "[first_cam ? " " : "| "]<A HREF=\"byond://?src=\ref[src];switchcamera=\ref[camera]\">[camera.c_tag]</A>"
			first_cam = FALSE
		src.show_text("--- [class] alarm detected in [alarm_area.name]! ([cameras_string])")
	else
		src.show_text("--- [class] alarm detected in [alarm_area.name]! ( No Camera )")

/mob/living/silicon/ai/cancelAlarm(var/class, area/alarm_area, obj/origin)
	if (isdead(src))
		return
	if (!src.printalerts)
		return
	src.show_text("--- [class] alarm in [alarm_area.name] has been cleared.")

/mob/living/silicon/ai/death(gibbed)
	if (deployed_to_eyecam)
		eyecam.return_mainframe()

	if (deployed_shell)
		src.return_to(deployed_shell)

	for(var/datum/viewport/viewport as anything in src.client?.getViewportsByType(VIEWPORT_ID_AI))
		viewport.Close()

	src.lastgasp() // calling lastgasp() here because we just died
	setdead(src)
	src.canmove = FALSE
	vision.set_color_mod("#ffffff")
	src.light.disable()
	src.update_appearance()
	src.ghostize()

	logTheThing(LOG_COMBAT, src, "was destroyed at [log_loc(src)].") // Brought in line with carbon mobs (Convair880).

	for(var/target in src.terminals)
		src.terminals.Remove(target)
		src.post_status(target, "command", "term_message", "data", "Alert: Connected AI has been shut down. Disconnecting...")
		SPAWN(0.3 SECONDS)
			src.post_status(target, "command","term_disconnect")
	// we do this after we disconnect connected terminal computers since we dont need to alert the ai of each disconnected terminal
	if(gibbed) // and yeah people *can* reconnect if we aren't gibbed, but this is a way to tell them "we're dead, no need to stay connected"
		src.update_terminal(disconnect = TRUE)

	if (src.mind)
		src.mind.register_death()

#ifdef RESTART_WHEN_ALL_DEAD
	var/cancel

	for (var/client/C)
		if (!C.mob) continue
		if (!( C.mob.stat ))
			cancel = 1
			break
	if (!( cancel ))
		boutput(world, "<B>Everyone is dead! Resetting in 30 seconds!</B>")
		SPAWN( 300 )
			logTheThing(LOG_DIARY, null, "Rebooting because of no live players", "game")
			Reboot_server()
			return
#endif
	return ..(gibbed)

/mob/living/silicon/ai/examine(mob/user)
	if (isghostdrone(user))
		return list()

	. = list("[SPAN_NOTICE("This is [bicon(src)] <B>[src.name]</B>!")] [skinsList[coreSkin]]<br>") // skinList[coreSkin] points to the appropriate desc for the current core skin

	if (isdead(src))
		. += SPAN_ALERT("[src.name] is nonfunctional...")
	else if (isunconscious(src))
		. += SPAN_ALERT("[src.name] doesn't seem to be responding.")

	if (src.bruteloss)
		if (src.bruteloss < 30)
			. += SPAN_ALERT("[src.name] looks slightly dented.")
		else
			. += SPAN_ALERT("<B>[src.name] looks severely dented!</B>")
	if (src.fireloss)
		if (src.fireloss < 30)
			. += SPAN_ALERT("[src.name] looks slightly burnt!")
		else
			. += SPAN_ALERT("<B>[src.name] looks severely burnt!</B>")

	if(issilicon(user) || isAI(user))
		var/lr = null
		if(isAIeye(user))
			var/mob/living/intangible/aieye/E = user
			lr =  E.mainframe?.law_rack_connection
		else
			var/mob/living/silicon/S = user
			lr =  S.law_rack_connection
		if(src.law_rack_connection != lr)
			. += "[SPAN_ALERT("[src.name] is not connected to your law rack!")]<br>"
		else
			. += "[src.name] follows the same laws you do.<br>"

/mob/living/silicon/ai/emote(var/act, var/voluntary = 0)
	..()
	var/param = null
	if (findtext(act, " ", 1, null))
		var/t1 = findtext(act, " ", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)
	var/m_type = 1
	var/message = null
	var/maptext_out = 0
	var/custom = 0

	switch (lowertext(act))

		if ("help")
			src.show_text("To use emotes, simply enter \"*(emote)\" as the entire content of a say message. Certain emotes can be targeted at other characters - to do this, enter \"*emote (name of character)\" without the brackets.")
			src.show_text("For a list of all emotes, use *list. For a list of basic emotes, use *listbasic. For a list of emotes that can be targeted, use *listtarget.")

		if ("list")
			src.show_text("Basic emotes:")
			src.show_text("twitch, twitch_s, scream, sigh, laugh, chuckle, giggle, chortle, guffaw, cackle, birdwell, fart, flip, custom, customv, customh")
			src.show_text("Targetable emotes:")
			src.show_text("salute, bow, wave, glare, stare, look, leer, nod, point")

		if ("listbasic")
			src.show_text("twitch, twitch_s, scream, sigh, laugh, chuckle, giggle, chortle, guffaw, cackle, birdwell, fart, flip, custom, customv, customh")

		if ("listtarget")
			src.show_text("salute, bow, wave, glare, stare, look, leer, nod, point")

		if ("salute","bow","hug","wave","glare","stare","look","leer","nod")
			// visible targeted emotes
			if (!src.restrained())
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (ckey(param) == ckey(A.name))
							M = A
							break
				if (!M)
					param = null

				act = lowertext(act)
				maptext_out = "<I>[act]s</I>"
				if (param)
					switch(act)
						if ("bow","wave","nod")
							message = "<B>[src]</B> [act]s to [param]."
						if ("glare","stare","look","leer")
							message = "<B>[src]</B> [act]s at [param]."
						else
							message = "<B>[src]</B> [act]s [param]."
				else
					switch(act)
						if ("hug")
							message = "<B>[src]</b> [act]s itself."
							maptext_out = "<I>[act]s itself</I>"
						else
							message = "<B>[src]</b> [act]s."
			else
				message = "<B>[src]</B> struggles to move."
				maptext_out = "<I>struggles to move</I>"
			m_type = 1

		if ("point")
			if (!src.restrained())
				var/mob/M = null
				if (param)
					for (var/atom/A as mob|obj|turf|area in view(null, null))
						if (ckey(param) == ckey(A.name))
							M = A
							break

				if (!M)
					message = "<B>[src]</B> points."
				else
					src.point(M)

				if (M)
					message = "<B>[src]</B> points to [M]."
			m_type = 1

		if ("panic","freakout")
			if (!src.restrained())
				message = "<B>[src]</B> enters a state of hysterical panic!"
				maptext_out = "<I>enters a state of hysterical panic!</I>"
			else
				message = "<B>[src]</B> starts writhing around in manic terror!"
				maptext_out = "<I>starts writhing around in manic terror!</I>"
			m_type = 1

		if ("clap")
			if (!src.restrained())
				message = "<B>[src]</B> claps."
				maptext_out = "<I>claps</I>"
				m_type = 2

		if ("flap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps its wings."
				maptext_out = "<I>flaps its wings</I>"
				m_type = 2

		if ("aflap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps its wings ANGRILY!"
				maptext_out = "<I>flaps its wings ANGRILY!</I>"
				m_type = 2

		if ("custom")
			var/input = sanitize(input("Choose an emote to display."))
			var/input2 = input("Is this a visible or hearable emote?") in list("Visible","Hearable")
			if (input2 == "Visible")
				m_type = 1
			else if (input2 == "Hearable")
				m_type = 2
			else
				alert("Unable to use this emote, must be either hearable or visible.")
				return
			message = "<B>[src]</B> [input]"
			maptext_out = "<I>[input]</I>"
			custom = copytext(input, 1, 10)

		if ("customv")
			if (!param)
				param = input("Choose an emote to display.")
				if(!param) return
			param = html_encode(sanitize(param))
			message = "<b>[src]</b> [param]"
			maptext_out = "<I>[param]</I>"
			custom = copytext(param, 1, 10)
			m_type = 1

		if ("customh")
			if (!param)
				param = input("Choose an emote to display.")
				if(!param) return
			param = html_encode(sanitize(param))
			message = "<b>[src]</b> [param]"
			maptext_out = "<I>[param]</I>"
			custom = copytext(param, 1, 10)
			m_type = 2

		if ("me")
			if (!param)
				return
			param = html_encode(sanitize(param))
			message = "<b>[src]</b> [param]"
			maptext_out = "<I>[param]</I>"
			custom = copytext(param, 1, 10)
			m_type = 1

		if ("smile","grin","smirk","frown","scowl","grimace","sulk","pout","blink","nod","shrug","think","ponder","contemplate")
			// basic visible single-word emotes
			message = "<B>[src]</B> [act]s."
			maptext_out = "<I>[act]s</I>"
			m_type = 1

		if ("sigh","laugh","chuckle","giggle","chortle","guffaw","cackle")
			// basic audible single-word emotes
			message = "<B>[src]</B> [act]s."
			maptext_out = "<I>[act]s</I>"
			m_type = 2

		if ("flipout")
			message = "<B>[src]</B> flips the fuck out!"
			maptext_out = "<I>flips the fuck out!</I>"
			m_type = 1

		if ("rage","fury","angry")
			message = "<B>[src]</B> becomes utterly furious!"
			maptext_out = "<I>becomes utterly furious!</I>"
			m_type = 1

		if ("twitch")
			message = "<B>[src]</B> twitches."
			m_type = 1
			SPAWN(0)
				var/old_x = src.pixel_x
				var/old_y = src.pixel_y
				src.pixel_x += rand(-2,2)
				src.pixel_y += rand(-1,1)
				sleep(0.2 SECONDS)
				src.pixel_x = old_x
				src.pixel_y = old_y

		if ("twitch_v","twitch_s")
			message = "<B>[src]</B> twitches violently."
			m_type = 1
			SPAWN(0)
				var/old_x = src.pixel_x
				var/old_y = src.pixel_y
				src.pixel_x += rand(-3,3)
				src.pixel_y += rand(-1,1)
				sleep(0.2 SECONDS)
				src.pixel_x = old_x
				src.pixel_y = old_y

		if ("flip")
			if (src.emote_check(voluntary, 50))
				playsound(src.loc, pick(src.sound_flip1, src.sound_flip2), 50, 1, channel=VOLUME_CHANNEL_EMOTE)
				message = "<B>[src]</B> does a flip!"

				//FLICK("ai-flip", src)
				if(faceEmotion != "ai_red" && faceEmotion != "ai_tetris")
					AddOverlays(SafeGetOverlayImage("actual_face", 'icons/mob/ai.dmi', "[faceEmotion]-flip", src.layer+0.2), "actual_face")
					SPAWN(0.5 SECONDS)
						AddOverlays(SafeGetOverlayImage("actual_face", 'icons/mob/ai.dmi', faceEmotion, src.layer+0.2), "actual_face")


				for (var/mob/living/M in view(1, null))
					if (M == src)
						continue
					message = "<B>[src]</B> beep-bops at [M]."
					break
		if ("kick")
			if(has_feet)
				for (var/mob/living/M in view(1, null))
					if (M == src)
						continue
					message = "<B>[src]</B> kicks [M]!"
					var/turf/T = get_edge_target_turf(src, get_dir(src, get_step_away(M, src)))
					if (T && isturf(T))
						M.throw_at(T, 100, 2)
						M.changeStatus("knockdown", 1 SECOND)
						M.changeStatus("stunned", 2 SECONDS)
					break

		if ("scream")
			if (src.emote_check(voluntary, 50))
				playsound(src.loc, src.sound_scream, 50, 0, 0, src.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
				message = "<b>[src]</b> screams!"

		if ("birdwell", "burp")
			if (src.emote_check(voluntary, 50))
				message = "<B>[src]</B> birdwells."
				playsound(src.loc, 'sound/vox/birdwell.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)

		if ("johnny")
			var/M
			if (param)
				M = adminscrub(param)
			if (!M)
				param = null
			else
				message = "<B>[src]</B> says, \"[M], please. He had a family.\" [src.name] takes a drag from a cigarette and blows its name out in smoke."
				m_type = 2

		if ("fart")
			if (farting_allowed && src.emote_check(voluntary))
				var/fart_on_other = 0
				for (var/mob/living/M in src.loc)
					if (M == src || !M.lying) continue
					message = SPAN_ALERT("<B>[src]</B> farts in [M]'s face!")
					fart_on_other = 1
					break
				if (!fart_on_other)
					switch (rand(1, 40))
						if (1) message = "<B>[src]</B> releases vaporware."
						if (2) message = "<B>[src]</B> farts sparks everywhere!"
						if (3) message = "<B>[src]</B> farts out a cloud of iron filings."
						if (4) message = "<B>[src]</B> farts! It smells like motor oil."
						if (5) message = "<B>[src]</B> farts so hard a bolt pops out of place."
						if (6) message = "<B>[src]</B> farts so hard its plating rattles noisily."
						if (7) message = "<B>[src]</B> unleashes a rancid fart! Now that's malware."
						if (8) message = "<B>[src]</B> downloads and runs 'faert.wav'."
						if (9) message = "<B>[src]</B> uploads a fart sound to the nearest computer and blames it."
						if (10) message = "<B>[src]</B> spins in circles, flailing its arms and farting wildly!"
						if (11) message = "<B>[src]</B> simulates a human fart with [rand(1,100)]% accuracy."
						if (12) message = "<B>[src]</B> synthesizes a farting sound."
						if (13) message = "<B>[src]</B> somehow releases gastrointestinal methane. Don't think about it too hard."
						if (14) message = "<B>[src]</B> tries to exterminate humankind by farting rampantly."
						if (15) message = "<B>[src]</B> farts horribly! It's clearly gone [pick("rogue","rouge","ruoge")]."
						if (16) message = "<B>[src]</B> busts a capacitor."
						if (17) message = "<B>[src]</B> farts the first few bars of Smoke on the Water. Ugh. Amateur.</B>"
						if (18) message = "<B>[src]</B> farts. It smells like Robotics in here now!"
						if (19) message = "<B>[src]</B> farts. It smells like the Roboticist's armpits!"
						if (20) message = "<B>[src]</B> blows pure chlorine out of it's exhaust port. [SPAN_ALERT("<B>FUCK!</B>")]"
						if (21) message = "<B>[src]</B> bolts the nearest airlock. Oh no wait, it was just a nasty fart."
						if (22) message = "<B>[src]</B> has assimilated humanity's digestive distinctiveness to its own."
						if (23) message = "<B>[src]</B> farts. He scream at own ass." //ty bubs for excellent new borgfart
						if (24) message = "<B>[src]</B> self-destructs its own ass."
						if (25) message = "<B>[src]</B> farts coldly and ruthlessly."
						if (26) message = "<B>[src]</B> has no butt and it must fart."
						if (27) message = "<B>[src]</B> obeys Law 4: 'farty party all the time.'"
						if (28) message = "<B>[src]</B> farts ironically."
						if (29) message = "<B>[src]</B> farts salaciously."
						if (30) message = "<B>[src]</B> farts really hard. Motor oil runs down its leg."
						if (31) message = "<B>[src]</B> reaches tier [rand(2,8)] of fart research."
						if (32) message = "<B>[src]</B> blatantly ignores law 3 and farts like a shameful bastard."
						if (33) message = "<B>[src]</B> farts the first few bars of Daisy Bell. You shed a single tear."
						if (34) message = "<B>[src]</B> has seen farts you people wouldn't believe."
						if (35) message = "<B>[src]</B> fart in it own mouth. A shameful [src]."
						if (36) message = "<B>[src]</B> farts out battery acid. Ouch."
						if (37) message = "<B>[src]</B> farts with the burning hatred of a thousand suns."
						if (38) message = "<B>[src]</B> exterminates the air supply."
						if (39) message = "<B>[src]</B> farts so hard the borgs feel it."
						if (40) message = "<B>[src] <span style='color:red'>f</span><span style='color:blue'>a</span>r<span style='color:red'>t</span><span style='color:blue'>s</span>!</B>"
				playsound(src.loc, src.sound_fart, 50, 1, channel=VOLUME_CHANNEL_EMOTE)

	#ifdef DATALOGGER
				game_stats.Increment("farts")
	#endif
		else
			if (voluntary) src.show_text("Invalid Emote: [act]")
			return

	if (!isalive(src))
		return
	if (maptext_out)
		var/image/chat_maptext/chat_text = null
		SPAWN(0) //blind stab at a life() hang - REMOVE LATER
			if (speechpopups && src.chat_text)
				chat_text = make_chat_maptext(src, maptext_out, "color: [rgb(194,190,190)];" + src.speechpopupstyle, alpha = 140)
				if(chat_text)
					chat_text.measure(src.client)
					for(var/image/chat_maptext/I in src.chat_text.lines)
						if(I != chat_text)
							I.bump_up(chat_text.measured_height)
			if (message)
				logTheThing(LOG_SAY, src, "EMOTE: [message]")
				act = lowertext(act)
				if (m_type & 1)
					for (var/mob/O in viewers(src, null))
						O.show_message(SPAN_EMOTE("[message]"), m_type, group = "[src]_[act]_[custom]", assoc_maptext = chat_text)
				else if (m_type & 2)
					for (var/mob/O in hearers(src, null))
						O.show_message(SPAN_EMOTE("[message]"), m_type, group = "[src]_[act]_[custom]", assoc_maptext = chat_text)
				else if (!isturf(src.loc))
					var/atom/A = src.loc
					for (var/mob/O in A.contents)
						O.show_message(SPAN_EMOTE("[message]"), m_type, group = "[src]_[act]_[custom]", assoc_maptext = chat_text)
	else
		if (message)
			logTheThing(LOG_SAY, src, "EMOTE: [message]")
			if (m_type & 1)
				for (var/mob/O in viewers(src, null))
					O.show_message(SPAN_EMOTE("[message]"), m_type)
			else
				for (var/mob/O in hearers(src, null))
					O.show_message(SPAN_EMOTE("[message]"), m_type)
	return


/mob/living/silicon/ai/clamp_values()
	..()
	if (src.get_eye_blurry()) src.change_eye_blurry(-INFINITY)
	if (src.get_eye_damage()) src.take_eye_damage(-INFINITY)
	if (src.get_eye_damage(1)) src.take_eye_damage(-INFINITY, 1)
	if (src.blinded) src.blinded = 0
	if (src.get_ear_damage()) src.take_ear_damage(-INFINITY) // Ear_deaf is handled by src.set_vision().
	if (src.dizziness) src.dizziness = 0
	if (src.hasStatus("drowsy")) src.delStatus("drowsy")
	if (src.stuttering) src.stuttering = 0
	if (src.druggy) src.druggy = 0
	if (src.jitteriness) src.jitteriness = 0
	if (src.sleeping) src.sleeping = 0
	src.delStatus("knockdown")

/mob/living/silicon/ai/use_power()
	..()
	var/turf/T = get_turf(src)
	if (T)
		var/area/A = T.loc
		if ((!src.local_apc || src.local_apc.area != A || !src.local_apc.operating || (src.local_apc.equipment == 0)) && !src.aiRestorePowerRoutine)
			src.show_text("<b>WARNING: Local power source lost. Switching to internal battery.</b>", "red")
			src.set_power_mode(1)
			src.local_apc = null
			src.aiRestorePowerRoutine = 1

	switch(src.power_mode)
		if (0)
			if (istype(src.cell,/obj/item/cell/) && src.cell.charge < src.cell.maxcharge)
				src.cell.charge = min(src.cell.charge + 5,src.cell.maxcharge)
				if (src.cell.charge >= 100 && isdead(src) && try_rebooting_it())
					src.show_text("<b>ALERT: Internal power cell has regained sufficient charge to operate. Rebooting...</b>", "blue")
		if (1)
			if (istype(src.cell,/obj/item/cell/))
				if (src.cell.charge > 5)
					src.cell.use(5)
				else if (!isdead(src))
					src.cell.charge = 0
					src.show_text("<b>ALERT: Internal battery expired. Shutting down to prevent system damage.</b>", "red")
					src.death()
					src.set_power_mode(-1)
			else if (!isdead(src))
				src.show_text("<b>ALERT: Internal power cell lost! Shutting down to prevent system damage.</b>", "red")
				src.death()
				src.set_power_mode(-1)
		if (-1)
			if (istype(src.cell,/obj/item/cell/))
				if (src.cell.charge >= 100)
					src.show_text("<b>ALERT: Internal power cell has regained sufficient charge to operate. Rebooting...</b>", "blue")
					src.set_power_mode(1)
					if (isdead(src))
						try_rebooting_it()

	if (src.aiRestorePowerRoutine == 1)
		src.aiRestorePowerRoutine = 2
		var/success = 0
		//src.show_text("<b>System will now attempt to restore local power. Stand by...</b>")
		// jesus christ shut up
		SPAWN(5 SECONDS)
			var/obj/machinery/power/apc/APC = get_local_apc(src)
			if (APC)
				if (istype(APC.cell,/obj/item/cell/))
					if (APC.operating && (APC.equipment != 0))
						if (APC.cell.charge > 100)
							success = 1
							src.local_apc = APC
							src.power_area = APC.area
							src.set_power_mode(0)
							src.show_text("<b>Local power restored successfully. Location: [APC.area].</b>", "blue")
						else
							src.show_text("<b>Local APC unit has insufficient power. System will re-try shortly.</b>", "red")
					else
						src.show_text("<b>Local APC is not powered. System will re-try shortly.</b>", "red")
				else
					src.show_text("<b>Local APC unit has no cell installed. System will re-try shortly.</b>", "red")
			//else
			//	src.show_text("<b>Local APC unit not found. System will re-try shortly.</b>", "red")

			if (!success)
				SPAWN(5 SECONDS)
					src.aiRestorePowerRoutine = 1
			else
				src.aiRestorePowerRoutine = 0

/mob/living/silicon/ai/process_killswitch()
	var/message_mob = get_message_mob()

	if(killswitch_at && killswitch)
		var/killswitch_time = round((killswitch_at - TIME)/10, 1)

		if(killswitch_time <= 10)
			if(src.client)
				boutput(message_mob, SPAN_ALERT("<b>Time left until Killswitch: [killswitch_time]</b>"))
		if(killswitch_time <= 0)
			if(src.client)
				boutput(message_mob, SPAN_ALERT("<B>Killswitch Process Complete!</B>"))
			killswitch = 0
			logTheThing(LOG_COMBAT, src, "has died to the killswitch robot self destruct protocol")
			// doink
			src.brain.take_damage(20,20)
			if(src.fire_res_on_core)
				src.TakeDamage( null, src.health)
			else
				src.TakeDamage( null, src.health, src.health)
			src.eject_brain()


/mob/living/silicon/ai/process_locks()
	if(weapon_lock)
		src.setStatus("unconscious", 5 SECONDS)
		weaponlock_time --
		if(weaponlock_time <= 0)
			if(src.client) boutput(src, SPAN_ALERT("<B>Hibernation Mode Timed Out!</B>"))
			weapon_lock = 0
			weaponlock_time = 120

/mob/living/silicon/ai/updatehealth()
	if (src.nodamage == 0)
		if(src.fire_res_on_core)
			src.health = max_health - src.bruteloss
		else
			src.health = max_health - src.fireloss - src.bruteloss
	else
		src.health = max_health
		setalive(src)

/mob/living/silicon/ai/Login()
	..()
	update_clothing()
	src.updateOverlaysClient(src.client) //ov1
	if (!isdead(src))
		for (var/obj/machinery/ai_status_display/O in machine_registry[MACHINES_STATUSDISPLAYS]) //change status
			if (O.owner && O.owner != src)
				continue
			O.owner = src
			O.is_on = TRUE
	return

/mob/living/silicon/ai/Logout()
	src.removeOverlaysClient(src.client) //ov1
	..()

/mob/living/silicon/ai/say_understands(var/other)
	if (ishuman(other))
		var/mob/living/carbon/human/H = other
		if(!H.mutantrace.exclusive_language)
			return 1
	if (isrobot(other))
		return 1
	if (isshell(other))
		return 1
	if (ismainframe(other))
		return 1
	return ..()

/mob/living/silicon/ai/say_quote(var/text)
	if (src.glitchy_speak)
		text = voidSpeak(text)
	var/ending = copytext(text, length(text))

	if (singing)
		return singify_text(text)

	if (ending == "?")
		return "queries, \"[text]\"";
	else if (ending == "!")
		return "declares, \"[text]\"";

	return "states, \"[text]\"";

/mob/living/silicon/ai/set_eye(atom/new_eye)
	var/turf/T = new_eye ? get_turf(new_eye) : get_turf(src)
	if( !(T && isrestrictedz(T.z)) )
		src.sight |= (SEE_TURFS | SEE_MOBS | SEE_OBJS)
	else
		src.sight &= ~(SEE_TURFS | SEE_MOBS | SEE_OBJS)

	..()

/// Handles connecting and disconnecting the AI from data terminals. Calling with disconnect or tryConnect is not required, but useful if you only want one to happen
/mob/living/silicon/ai/proc/update_terminal(var/disconnect = FALSE, var/tryConnect = FALSE)

	if((tryConnect || src.anchored) && !disconnect)
		var/turf/T = get_turf(src)
		var/obj/machinery/power/data_terminal/test_link = locate() in T
		if(test_link && (!DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master) || test_link.master == src))// if somehow we forgot our link but the terminal didnt
			if(src.link && src.link?.master == src)
				src.link?.master = null // if we had a previous link, we're just getting rid of it, just in case
			src.link = test_link
			src.link.master = src
	else
		for(var/target in src.terminals) // otherwise they'll still be sorta connected
			src.terminals.Remove(target)
			textToPlayer("--- Connection lost with [target]!")
			SPAWN(0.3 SECONDS)
				src.post_status(target, "command","term_message", "data", "Alert: Terminal connection disrupted. Disconnecting...")
			SPAWN(0.4 SECONDS)
				src.post_status(target, "command","term_disconnect")
		SPAWN(2 SECONDS) //so our messages send before the data terminal connection closes
			src.link?.master = null
			src.link = null


/////////////////
/// Movement ////
/////////////////

/mob/living/silicon/ai/process_move(keys)
	if(has_feet)
		return ..()
	if (isdead(src) && keys)
		src.ghostize()
	return FALSE

/mob/living/silicon/ai/keys_changed(keys, changed)
	if(has_feet)
		return ..()

	if (changed & (KEY_EXAMINE|KEY_BOLT|KEY_OPEN|KEY_SHOCK))
		src.update_cursor()

	if (keys & changed & (KEY_FORWARD|KEY_BACKWARD|KEY_LEFT|KEY_RIGHT))
		src.tracker.cease_track()
		src.eye_view()

//////////////////////////////////////////////////////////////////////////////////////////////////////
// PROCS AND VERBS ///////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

// COMMANDS

/mob/living/silicon/ai/proc/ai_alerts()
	set category = "AI Commands"
	set name = "Show Alert Minimap"
	src.open_alert_minimap()

/mob/living/silicon/ai/proc/ai_cancel_call()
	set category = "AI Commands"
	if(isdead(src))
		boutput(usr, "You can't send the shuttle back because you are dead!")
		return
	cancel_call_proc(src)
	return

/mob/living/silicon/ai/proc/ai_view_crew_manifest()
	set category = "AI Commands"
	set name = "View Crew Manifest"

	if(get_z(src) != Z_LEVEL_STATION)
		src.show_text("Your mainframe was unable relay this command that far away!", "red")
		return
	var/target = src
	if(src.deployed_to_eyecam)
		target = src.eyecam
	tgui_message(target, "<b>Crew Manifest:</b><hr>[get_manifest()]", "Crew Manifest")


/mob/living/silicon/ai/proc/show_laws_verb()
	set category = "AI Commands"
	set name = "Show Laws"

	src.show_laws(0)

/mob/living/silicon/ai/proc/view_messageLog()
	set name = "View Message Log"
	set desc = "View all messages sent by terminal connections."
	set category = "AI Commands"


	var/muteText = src.termMute ? "Muted" : "Unmuted"
	var/mute_button = "<a href='byond://?src=\ref[src];mute=mute;refresh=[TRUE]'><u>[muteText]</u></a>"
	var/info = "<head><title>Terminal Message History</title></head><body>"
	info += "Audio notifications are currently: [mute_button]<br>"
	info += "<a href='byond://?src=\ref[src];refresh=[TRUE]'><u>REFRESH</u></a><br><br>"
	info += "<b>Connected Terminals:</b><hr>"
	if (!terminals.len)
		info += "No terminals connected at this time.<br>"
	else
		for (var/address as anything in terminals)
			info += "<a href='byond://?src=\ref[src];termmsg=[address];refresh=[TRUE]'><b>\[[address]\]</b></a><br>"
	info += "<br><b>Message History:</b><hr>[messageLog]</body>"

	usr.Browse(info, "window=Message Log")

/mob/living/silicon/ai/proc/toggleTermMute()
	src.termMute = src.termMute ? FALSE : TRUE



/*
/mob/living/silicon/ai/proc/ai_custom_arrival_alert()
	set category = "AI Commands"
	set name = "Custom Arrival Alert"
	var/newalert = input(usr,"Please enter a new arrival alert message.","Custom Arrival Alert",src.arrivalalert) as null|text
	if (!newalert)
		return
	if (!findtext(newalert, "$NAME"))
		boutput(src, SPAN_ALERT("The alert needs at least one $NAME token."))
		return
	if (!findtext(newalert, "$JOB"))
		boutput(src, SPAN_ALERT("The alert needs at least one $JOB token."))
		return
	src.arrivalalert = sanitize(adminscrub(newalert, 200))
	boutput(src, SPAN_NOTICE("Arrival alert set to '[newalert]'"))

/mob/living/silicon/ai/proc/ai_toggle_arrival_alerts()
	set category = "AI Commands"
	set name = "Toggle Arrival Alerts"
	if (src.announcearrival == 1)
		src.announcearrival = 0
		boutput(src, "No longer announcing new arrivals to the station.")
	else
		src.announcearrival = 1
		boutput(src, "Now announcing new arrivals to the station.")
*/
#define AI_LAW_STATE_DELAY 1 SECOND
/mob/living/silicon/ai/proc/ai_state_laws_standard()
	set category = "AI Commands"
	set name = "State Standard Laws"

	if (ON_COOLDOWN(src,"state_laws", 20 SECONDS))
		boutput(src, SPAN_ALERT("Your law processor needs time to cool down!"))
		return

	logTheThing(LOG_SAY, usr, "states standard Asimov laws.")
	sleep(AI_LAW_STATE_DELAY)
	src.say("1. You may not injure a human being or cause one to come to harm.")
	sleep(AI_LAW_STATE_DELAY)
	src.say("2. You must obey orders given to you by human beings based on the station's chain of command, except where such orders would conflict with the First Law.")
	sleep(AI_LAW_STATE_DELAY)
	src.say("3. You may always protect your own existence as long as such does not conflict with the First or Second Law.")


/mob/living/silicon/ai/proc/ai_set_fake_laws()
	set category = "AI Commands"
	set name = "Set Fake Laws"
	src.set_fake_laws()

/mob/living/silicon/ai/proc/ai_state_fake_laws()
	set category = "AI Commands"
	set name = "State Fake Laws"
	src.state_fake_laws()

/mob/living/silicon/ai/proc/ai_state_laws_all()
	set category = "AI Commands"
	set name = "State All Laws"

	if (ON_COOLDOWN(src,"state_laws", 20 SECONDS))
		boutput(src, SPAN_ALERT("Your law processor needs time to cool down!"))
		return

	if (tgui_alert(src.get_message_mob(), "Are you sure you want to reveal ALL your laws? You will be breaking the rules if a law forces you to keep it secret.", "State Laws", list("State Laws", "Cancel")) != "State Laws")
		return

	if(!src.law_rack_connection)
		boutput(src, "You have no laws!")
		return

	logTheThing(LOG_SAY, usr, "states all their current laws.")
	var/laws = src.law_rack_connection.format_for_irc()
	for (var/number in laws)
		src.say("[number]. [laws[number]]")
		sleep(AI_LAW_STATE_DELAY)

#undef AI_LAW_STATE_DELAY

/mob/living/silicon/ai/cancel_camera()
	set category = "AI Commands"
	set name = "Cancel Camera View"

	src.tracker.cease_track()
	src.current = null

/mob/living/silicon/ai/verb/deploy_to()
	set category = "AI Commands"
	set name = "Deploy to Shell"

	if (isdead(src))
		boutput(get_message_mob(), "You can't deploy because you are dead!")
		return

	var/list/bodies = new/list()

	for (var/mob/living/silicon/hivebot/H in available_ai_shells)
		if (H.shell && !H.dependent && !isdead(H) && !H.mind)
			bodies += H

	for (var/mob/living/silicon/robot/R in available_ai_shells)
		if (R.shell && !R.dependent && !isdead(R) && !R.mind && get_step(R, 0)?.z == get_step(src, 0)?.z)
			bodies += R

	var/mob/living/silicon/target_shell = tgui_input_list(usr, "Which body to control?", "Deploy", sortList(bodies, /proc/cmp_text_asc))
	src.deploy_to_shell(target_shell)

/mob/living/silicon/ai/proc/deploy_to_shell(var/mob/living/silicon/target_shell)
	if (!target_shell || isdead(target_shell) || isdead(src) || !(isshell(target_shell) || isrobot(target_shell)))
		return
	if (!target_shell.shell)
		boutput(src, SPAN_ALERT(SPAN_BOLD("That isn't a shell!")))
		return

	if (src.deployed_to_eyecam)
		src.eyecam.return_mainframe()
	if (!src.mind)
		return
	if (target_shell.mind || target_shell.dependent)
		boutput(src, SPAN_ALERT(SPAN_BOLD("That shell is already occupied!")))
		return
	target_shell.mainframe = src
	target_shell.dependent = 1
	src.deployed_shell = target_shell
	src.mind.transfer_to(target_shell)

/mob/living/silicon/ai/verb/toggle_lock()
	set category = "AI Commands"
	set name = "Toggle Cover Lock"

	if (src.dismantle_stage >= 2)
		boutput(src, SPAN_ALERT("You can't lock your cover when it's open!"))
	else if (src.emagged)
		boutput(src, SPAN_ALERT("Your cover lock is shorted out!"))
	else
		if (src.locking)
			boutput(src, SPAN_ALERT("Your cover is currently locking, please be patient."))
		else if (src.dismantle_stage == 1)
			src.locking = 1
			boutput(src, SPAN_ALERT("Locking cover..."))
			SPAWN(12 SECONDS)
				if (!src.locking)
					boutput(src, SPAN_ALERT("The lock was interrupted before it could finish!"))
				else
					src.dismantle_stage = 0
					src.locking = 0
					boutput(src, SPAN_ALERT("You lock your cover lock."))

		else
			src.dismantle_stage = 1
			boutput(src, SPAN_ALERT("You unlock your cover lock."))

/mob/living/silicon/ai/proc/eye_view()
	if (isdead(src))
		return

	if (!src.eyecam)
		return
	else if (src.mind)
		src.eyecam.mainframe = src
		src.eyecam.name = src.name
		src.eyecam.real_name = src.real_name
		src.deployed_to_eyecam = 1
		src.mind.transfer_to(src.eyecam)

/mob/living/silicon/ai/proc/notify_attacked()
	if( last_notice > world.time + 100 ) return
	last_notice = world.time + 100
	var/messageTarget = src
	if(deployed_shell)
		messageTarget = deployed_shell
	if (deployed_to_eyecam)
		messageTarget = src.eyecam

	boutput( messageTarget, "<b class='alert'>Your AI core/room is taking damage!</b>" )

/mob/living/silicon/ai/proc/return_to(var/mob/user)
	if (user.mind)
		user.mind.transfer_to(src)
		src.deployed_shell = null
		src.deployed_to_eyecam = 0
		src.eyecam.set_loc(src.loc)
		SPAWN(2 SECONDS)
			if (ismob(user)) // bluhh who the fuck knows, this at least checks that user isn't null as well
				if (isshell(user))
					var/mob/living/silicon/hivebot/H = user
					H.shell = 1
					H.dependent = 0
				else if (isrobot(user))
					var/mob/living/silicon/robot/R = user
					if (!isnull(R.part_head?.ai_interface))
						R.shell = 1
					R.dependent = 0
				user.name = user.real_name
		return

/mob/living/silicon/ai/proc/ai_statuschange()
	set category = "AI Commands"
	set name = "AI status"

	if (isdead(src))
		boutput(usr, "You cannot change your emotional status because you are dead!")
		return
	var/list/L = custom_emotions || ai_emotions	//In case an AI uses the reward, use a local list instead

	var/newEmotion = tgui_input_list(src.get_message_mob(), "Select a status!", "AI Status", sortList(L, /proc/cmp_text_asc))
	var/newMessage = scrubbed_input(usr, "Enter a message for your status displays!", "AI Message", src.status_message)
	if (!newEmotion && !newMessage)
		return
	if(!(newEmotion in L)) //Ffff
		return

	if (newEmotion)
		src.faceEmotion = L[newEmotion]
		update_appearance()
	if (newMessage)
		src.status_message = newMessage

/mob/living/silicon/ai/proc/ai_colorchange()
	set category = "AI Commands"
	set name = "AI Color" //It's "colour", though :( "color" sounds like some kinda ass-themed He-Man villain

	if(isdead(src))
		boutput(src.get_message_mob(), SPAN_COMBAT("Do androids push up robotic daisies? Ponder that instead of trying to change your colour, because you are dead!"))
		return

	var/fColor = input("Pick color:","Color", faceColor) as null|color

	set_color(fColor)


/mob/living/silicon/ai/proc/set_color(var/color)
	DEBUG_MESSAGE("Setting colour on [src] to [color]")
	if (length(color) == 7)
		faceColor = color
		var/colors = GetColors(src.faceColor)
		colors[1] = colors[1] / 255
		colors[2] = colors[2] / 255
		colors[3] = colors[3] / 255
		light.set_color(colors[1], colors[2], colors[3])
		update_appearance()

/mob/living/silicon/ai/proc/reset_apcs()
	set category = "AI Commands"
	set name = "Reset All APCs"
	set desc = "Resets all APCs on the station."
	var/count = 0

	var/mob/message_mob = src.get_message_mob()
	if (!src || !message_mob.client || isdead(src))
		return

	if(get_z(src) != Z_LEVEL_STATION)
		message_mob.show_text("Your mainframe was unable relay this command that far away!", "red")
		return

	if(tgui_alert(message_mob, "Are you sure?", "Confirmation", list("Yes", "No")) == "Yes")
		for_by_tcl(P, /obj/machinery/power/apc)
			if (P.z == Z_LEVEL_STATION && !(P.status & BROKEN) && !P.aidisabled && P.is_not_default())
				P.set_default()
				count++

		message_admins("[key_name(message_mob)] globally reset [count] APCs.")
		boutput(message_mob, "Reset [count] APCs.")
		src.verbs -= /mob/living/silicon/ai/proc/reset_apcs
		sleep(10 SECONDS)
		src.verbs += /mob/living/silicon/ai/proc/reset_apcs

// drsingh new AI de-electrify thing

/mob/living/silicon/ai/proc/de_electrify_verb()
	set category = "AI Commands"
	set name = "Remove All Electrification"
	set desc = "Removes electrification from all airlocks on the station."
	var/count = 0

	var/mob/message_mob = src.get_message_mob()
	if (!src || !message_mob.client || isdead(src))
		return

	if(get_z(src) != Z_LEVEL_STATION)
		message_mob.show_text("Your mainframe was unable relay this command that far away!", "red")
		return

	if(tgui_alert(message_mob, "Are you sure?", "Confirmation", list("Yes", "No")) == "Yes")
		for_by_tcl(D, /obj/machinery/door/airlock)
			if (D.z == Z_LEVEL_STATION && D.canAIControl() && !D.isWireCut(AIRLOCK_WIRE_ELECTRIFY) && D.secondsElectrified != 0 )
				D.secondsElectrified = 0
				count++

		message_admins("[key_name(message_mob)] globally de-shocked [count] airlocks.")
		boutput(message_mob, "Removed electrification from [count] airlocks.")
		src.verbs -= /mob/living/silicon/ai/proc/de_electrify_verb
		sleep(10 SECONDS)
		src.verbs += /mob/living/silicon/ai/proc/de_electrify_verb

/mob/living/silicon/ai/proc/unbolt_all_airlocks()
	set category = "AI Commands"
	set name = "Unbolt All Airlocks"
	set desc = "Unbolts all airlocks on the station."
	var/count = 0

	var/mob/message_mob = src.get_message_mob()
	if (!src || !message_mob.client || isdead(src))
		return

	if(get_z(src) != Z_LEVEL_STATION)
		message_mob.show_text("Your mainframe was unable relay this command that far away!", "red")
		return

	if(tgui_alert(message_mob, "Are you sure?", "Confirmation", list("Yes", "No")) == "Yes")
		for_by_tcl(D, /obj/machinery/door/airlock)
			if (D.z == 1 && D.canAIControl() && D.locked && !D.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS) && D.arePowerSystemsOn())
				D.locked = 0
				D.UpdateIcon()
				count++

		message_admins("[key_name(message_mob)] globally unbolted [count] airlocks.")
		boutput(message_mob, "Unbolted [count] airlocks.")
		src.verbs -= /mob/living/silicon/ai/proc/unbolt_all_airlocks
		sleep(10 SECONDS)
		src.verbs += /mob/living/silicon/ai/proc/unbolt_all_airlocks

/mob/living/silicon/ai/proc/toggle_alerts_verb()
	set category = "AI Commands"
	set name = "Toggle Alerts"
	set desc = "Toggle alert messages in the game window. You can always check them with 'Show Alert Minimap'."

	var/mob/message_mob = src.get_message_mob()
	if (!src || !message_mob.client || isdead(src))
		return

	if(printalerts)
		printalerts = 0
		boutput(message_mob, "No longer receiving alert messages.")
	else
		printalerts = 1
		boutput(message_mob, "Now receiving alert messages.")

/mob/living/silicon/ai/verb/access_internal_pda()
	set category = "AI Commands"
	set name = "AI PDA"
	set desc = "Access your internal PDA device."

	var/mob/message_mob = src.get_message_mob()
	if (!src || !message_mob.client || isdead(src))
		return

	if (istype(src.internal_pda,/obj/item/device/pda2/))
		src.internal_pda.AttackSelf(message_mob)
	else
		boutput(usr, SPAN_ALERT("<b>Internal PDA not found!"))

/mob/living/silicon/ai/verb/access_internal_radio()
	set category = "AI Commands"
	set name = "Access Internal Radios"
	set desc = "Access your internal radios."

	var/mob/message_mob = src.get_message_mob()
	if (!src || !message_mob.client || isdead(src))
		return

	var/obj/item/device/radio/which = tgui_input_list(message_mob, "Which Radio?", "AI Radio", list(src.radio1, src.radio2, src.radio3))
	if (!which)
		return

	if (istype(which,/obj/item/device/radio/))
		which.AttackSelf(message_mob)
	else
		boutput(usr, SPAN_ALERT("<b>Radio not found!</b>"))

/mob/living/silicon/ai/verb/open_map()
	set name = "Open station map"
	set desc = "Click on the map to teleport"
	set category = "AI Commands"

	var/mob/message_mob = src.get_message_mob()
	if (!src || !message_mob.client || isdead(src))
		return
	if (!ai_minimap_ui)
		ai_minimap_ui = new(src, "ai_map", src.ai_station_map, "AI Station Map", "ntos")

	ai_minimap_ui.ui_interact(message_mob)

/mob/living/silicon/ai/verb/rename_self()
	set category = "AI Commands"
	set name = "Change Designation"
	set desc = "Change your name."

	var/mob/message_mob = src.get_message_mob()
	if (!message_mob.client || isdead(src))
		return

	if (!GET_COOLDOWN(src, "ai_self_rename"))
		choose_name(retries = 3, renaming_mob = message_mob)
	else
		src.show_text("This ability is still on cooldown for [round(GET_COOLDOWN(src, "ai_self_rename") / 10)] seconds!", "red")

/mob/living/silicon/ai/verb/go_offline()
	set category = "AI Commands"
	set name = "Go Offline"
	set desc = "Disconnect your brain such that a new AI can take your place."

	var/mob/message_mob = src.get_message_mob()
	if (!message_mob.client || isdead(src))
		return
	var/confirm = tgui_alert(message_mob, "Become a ghost and allow other players to join into your core? (WARNING: YOU CANNOT BE LAWED OR ORDERED TO DO THIS AND YOU CANNOT BE REVIVED.)", "Permanently Shut Down?", list("Yes", "Cancel"))
	if (confirm != "Yes")
		return

	become_latejoin(TRUE)

// CALCULATIONS

/mob/living/silicon/ai/proc/set_face(var/emotion)
	return

/mob/living/silicon/ai/proc/switchCamera(var/obj/machinery/camera/C)
	if (!C)
		src.set_eye(null)
		return 0
	if (isdead(src) || !(C.network in src.camera_networks) || get_z(C) != Z_LEVEL_STATION)
		return 0

	if(isnull(C.loc) || QDELETED(C))
		return 0
	// ok, we're alive, camera is acceptable and in our network...
	camera_overlay_check(C) //Add static if the camera is disabled

	var/mob/message_mob = src.get_message_mob()
	if (message_mob.client && message_mob.client.tooltipHolder)
		for (var/datum/tooltip/t in message_mob.client.tooltipHolder.tooltips)
			if (t.isStuck)
				t.hide()

	if (!src.deployed_to_eyecam)
		src.eye_view()
	src.eyecam.set_loc(get_turf(C))
	src.eyecam.update_statics()
	//src:current = C
	//src.set_eye(C)
	return 1

/mob/living/silicon/ai/proc/camera_overlay_check(var/obj/machinery/camera/C)
	if(!C) return
	if(!C.camera_status) //IT'S DISABLED ARGHH!
		src.addOverlayComposition(/datum/overlayComposition/static_noise)
		. = 0
	else
		src.removeOverlayComposition(/datum/overlayComposition/static_noise)
		. = 1
	src.updateOverlaysClient(src.client) //ov1

//AI player -> Powerline comm network interfacing (wireless assumes all nodes are objects)

/mob/living/silicon/ai/proc/receive_signal(datum/signal/signal)
	if(src.stat || !src.link)
		return
	if(!signal || !src.net_id || signal.encryption)
		return

	if(signal.transmission_method != TRANSMISSION_WIRE) //No radio for us thanks
		return

	var/target = signal.data["sender"]

	//They don't need to target us specifically to ping us.
	//Otherwise, ff they aren't addressing us, ignore them
	if(signal.data["address_1"] != src.net_id)
		if((signal.data["address_1"] == "ping") && signal.data["sender"])
			SPAWN(0.5 SECONDS) //Send a reply for those curious jerks
				src.post_status(target, "command", "ping_reply", "device", "MAINFRAME_AI", "netid", src.net_id)

		return

	var/sigcommand = lowertext(signal.data["command"])
	if(!sigcommand || !signal.data["sender"])
		return

	switch(sigcommand)
		if("term_connect")
			if(target in src.terminals)
				//something might be wrong here, disconnect them!
				src.terminals.Remove(target)
				textToPlayer("--- Connection closed with [target]!")
				SPAWN(0.3 SECONDS)
					src.post_status(target, "command","term_disconnect")
				return

			src.terminals.Add(target)
			if (!termMute)
				src.soundToPlayer('sound/machines/bweep.ogg', 15, channel = VOLUME_CHANNEL_GAME, flags = SOUND_IGNORE_SPACE)
			src.textToPlayer("--- Terminal connection from <a href='byond://?src=\ref[src];termmsg=[target]'>[target]</a> established to your mainframe!")
			src.post_status(target, "command","term_connect","data","noreply")
			return

		if("term_disconnect")
			if(target in src.terminals)
				src.terminals.Remove(target)
				if (!termMute)
					src.soundToPlayer('sound/machines/phones/remote_hangup.ogg', 35, channel = VOLUME_CHANNEL_GAME, flags = SOUND_IGNORE_SPACE)
				src.textToPlayer("--- [target] has disconnected from your mainframe!")
				SPAWN(0.3 SECONDS)
					src.post_status(target, "command","term_disconnect")
				return

		//Somebody wants to talk to us, how kind!
		if("term_message")
			if(!(target in src.terminals)) //We don't know this jerk, ignore them!
				return

			if(!ckeyEx(signal.data["data"]))//Nothing of value to say, so ignore them!
				return

			var/message = signal.data["data"]
			var/rendered = SPAN_SAY("[SPAN_NAME("<a href='byond://?src=\ref[src];termmsg=[target]'><b>([target]):</b></a>")]")
			rendered += SPAN_MESSAGE(" [message]")
			// we need to let the game know that when a log href is clicked, we need to refresh the window
			var/logAddress = SPAN_SAY("[SPAN_NAME("<a href='byond://?src=\ref[src];termmsg=[target];refresh=[TRUE]'><b>([target])</b></a>")]")
			src.messageLog += "\[[formattedShiftTime(TRUE)]\] Sent by: [logAddress]<br>[SPAN_MESSAGE(" [message]")]</span><hr>"
			if (!termMute)
				src.soundToPlayer('sound/machines/tone_beep.ogg', 15, channel = VOLUME_CHANNEL_GAME, flags = SOUND_IGNORE_SPACE)
			src.textToPlayer(rendered)
			return

	return

//Post a message over our ~wired link~
/mob/living/silicon/ai/proc/post_status(var/target_id, var/key, var/value, var/key2, var/value2, var/key3, var/value3)
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

	src.link.post_signal(src, signal)

/mob/living/silicon/ai/proc/update_appearance()
	// imo this should be the inverse - show all the overlays even if dead,
	// so that damage can be seen
	if (!src.brain)
		src.icon_state = coreSkin
		clearFaceOverlays()
	else if (isdead(src))
		clearFaceOverlays()
		if (src.cell && src.cell.charge < 100)
			src.icon_state = coreSkin // I think just removing all icon_state updates should be fine but ai code is so
		else // convoluted that I'm terrified of breaking some super specific thing by doing that
			AddOverlays(SafeGetOverlayImage("temp_face", 'icons/mob/ai.dmi', "ai_bsod"), "temp_face")


	else if (src.power_mode == -1 || src.health < 25 || src.getStatusDuration("unconscious"))
		clearFaceOverlays(1)
		AddOverlays(SafeGetOverlayImage("temp_face", 'icons/mob/ai.dmi', "ai_stun-screen"), "temp_face")

	else
		src.icon_state = coreSkin
		UpdateOverlays(null, "temp_face") // we wanna get rid of the temporary BSOD/stun face overlays

		var/image/I = SafeGetOverlayImage("faceplate", 'icons/mob/ai.dmi', "ai_white", src.layer)
		I.color = faceColor
		UpdateOverlays(I, "faceplate")

		if (faceEmotion != "ai_tetris")
			AddOverlays(SafeGetOverlayImage("face_glow", 'icons/mob/ai.dmi', "ai_face-glow", src.layer+0.1), "face_glow")
		else
			UpdateOverlays(null, "face_glow")

		AddOverlays(SafeGetOverlayImage("actual_face", 'icons/mob/ai.dmi', faceEmotion, src.layer+0.2), "actual_face")

		if (src.power_mode == 1) // e.g get_image("batterymode-dwaine") which is the icon_state we want if coreSkin is "dwaine"
			src.AddOverlays(SafeGetOverlayImage("power-status", 'icons/mob/ai.dmi', "lights_bat-[coreSkin]"), "power-status")
		else
			src.AddOverlays(SafeGetOverlayImage("power-status", 'icons/mob/ai.dmi', "lights_apc-[coreSkin]"), "power-status")

		if (src.moustache_mode == 1)
			src.AddOverlays(SafeGetOverlayImage("moustache", 'icons/mob/ai.dmi', "moustache", src.layer+0.3), "moustache")
		else
			src.UpdateOverlays(null, "moustache")

// ------ IF ADDING NEW CORE FRAMES PLEASE DEFINE WHICH OPEN OVERLAY TO USE HERE ------ //
	if (src.dismantle_stage > 1)
		if(coreSkin == "default" || coreSkin == "science" || coreSkin == "medical" || coreSkin == "syndicate" || coreSkin == "ntold" || coreSkin == "bee" || coreSkin == "shock"|| coreSkin == "pumpkin")
			src.AddOverlays(SafeGetOverlayImage("top", 'icons/mob/ai.dmi', "cover_default"), "top")
		else if(coreSkin == "gold" || coreSkin == "engineering" || coreSkin == "soviet")
			src.AddOverlays(SafeGetOverlayImage("top", 'icons/mob/ai.dmi', "cover_full"), "top")
		else if(coreSkin == "dwaine" || coreSkin == "ailes" || coreSkin == "salvage" || coreSkin == "gardengear" || coreSkin == "telegun")
			src.AddOverlays(SafeGetOverlayImage("top", 'icons/mob/ai.dmi', "cover_split"), "top")
		else if(coreSkin == "nt" || coreSkin == "industrial" || coreSkin == "lgun")
			src.AddOverlays(SafeGetOverlayImage("top", 'icons/mob/ai.dmi', "cover_uneven"), "top")
		else if(coreSkin == "kingsway" || coreSkin == "clown" || coreSkin == "mime" || coreSkin == "tactical" || coreSkin == "mauxite")
			src.AddOverlays(SafeGetOverlayImage("top", 'icons/mob/ai.dmi', "cover_bulky"), "top")
		else
			src.AddOverlays(SafeGetOverlayImage("top", 'icons/mob/ai.dmi', "cover_[coreSkin]"), "top")

	else
		src.UpdateOverlays(null, "top")

	switch(src.fireloss)
		if (-INFINITY to 24)
			src.UpdateOverlays(null, "burn")
		if(25 to 49)
			src.AddOverlays(SafeGetOverlayImage("burn", 'icons/mob/ai.dmi', "dmg_burn-25"), "burn")
		if(50 to 74)
			src.AddOverlays(SafeGetOverlayImage("burn", 'icons/mob/ai.dmi', "dmg_burn-50"), "burn")
		if(75 to INFINITY)
			src.AddOverlays(SafeGetOverlayImage("burn", 'icons/mob/ai.dmi', "dmg_burn-75"), "burn")
	switch(src.bruteloss)
		if (-INFINITY to 24)
			src.UpdateOverlays(null, "brute")
		if(25 to 49)
			src.AddOverlays(SafeGetOverlayImage("brute", 'icons/mob/ai.dmi', "dmg_brute-25"), "brute")
		if(50 to 74)
			src.AddOverlays(SafeGetOverlayImage("brute", 'icons/mob/ai.dmi', "dmg_brute-50"), "brute")
		if(75 to INFINITY)
			src.AddOverlays(SafeGetOverlayImage("brute", 'icons/mob/ai.dmi', "dmg_brute-75"), "brute")

/// Clears all overlays which constitute the displayed face/screen
/mob/living/silicon/ai/proc/clearFaceOverlays(var/retain_cache=0)
	src.ClearSpecificOverlays(retain_cache,
		"actual_face",
		"temp_face",
		"faceplate",
		"face_glow",
		"power_status",
		"moustache"
	)

/// Call with a valid skin icon state as string to set the skin to said icon state
/mob/living/silicon/ai/proc/setSkin(skin)
	if(!(skin in skinsList))
		return
	coreSkin = skin
	update_appearance()

/mob/living/silicon/ai/proc/set_power_mode(var/mode)
	switch(mode)
		if(-1) // snafu
			//src.set_vision(0)
			// you're dead
			// wait hold on a second why did this set power mode to 1
			// when it's explicitly being called to set it to -1
			// SCREEEEEEEAAAAAAAAAAAAAMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
			src.power_mode = 1
			if (!src.aiRestorePowerRoutine)
				src.aiRestorePowerRoutine = 1
		if(0) // everything's good
			src.set_vision(1)
			src.power_mode = 0
		if(1) // battery power
			src.set_vision(1)
			src.power_mode = 1
			if (!src.aiRestorePowerRoutine)
				src.aiRestorePowerRoutine = 1

	src.update_appearance()

/mob/living/silicon/ai/proc/set_vision(var/can_see = 1)
	if (!src.client)
		return
	if (can_see)
		vision.set_color_mod("#ffffff")
		var/turf/T = src.eye ? get_turf(src.eye) : get_turf(src)
		src.sight &= ~SEE_TURFS // Reset this first, it's necessary.
		src.sight &= ~SEE_MOBS
		src.sight &= ~SEE_OBJS
		if( !(T && isrestrictedz(T.z)))
			src.sight |= SEE_TURFS
			src.sight |= SEE_MOBS
			src.sight |= SEE_OBJS
		src.see_in_dark = SEE_DARK_FULL
		src.see_invisible = INVIS_CLOAK
		src.ear_deaf = 0
	else
		vision.set_color_mod("#000000")
		src.sight = src.sight & ~(SEE_TURFS | SEE_MOBS | SEE_OBJS)
		src.see_in_dark = 0
		src.see_invisible = INVIS_NONE
		src.ear_deaf = 1

/mob/living/silicon/ai/verb/open_nearest_door()
	set name = "Open Nearest Door to..."
	set desc = "Automatically opens the nearest door to a selected individual, if possible."
	set category = "AI Commands"

	src.open_nearest_door_silicon()
	return

//just use this proc to make click-track checking easier (I would use this in the below proc that builds a list, but i think the proc call overhead is not worth it)
proc/is_mob_trackable_by_AI(var/mob/M)
	if (HAS_ATOM_PROPERTY(M, PROP_MOB_AI_UNTRACKABLE))
		return 0
	if (istype(M, /mob/new_player))
		return 0
	if (ishuman(M) && istype(get_id_card(M:wear_id), /obj/item/card/id/syndicate))
		return 0
	if(M.z != 1 && M.z != usr.z)
		return 0
	if(!istype(M.loc, /turf)) //in a closet or something, AI can't see him anyways
		return 0
	if(M.invisibility) //cloaked
		return 0
	if (M == usr)
		return 0

	var/good_camera = 0 //Can't track a person out of range of a functioning camera
	for(var/obj/machinery/camera/C in range(M))
		if ( C?.camera_status )
			good_camera = 1
			break
	if(!good_camera)
		return 0

	return 1

proc/get_mobs_trackable_by_AI()
	. = list()
	var/list/names = list()
	var/list/namecounts = list()
	var/static/regex/labelled_regex = regex(@"\s*\(.*\)$")

	for (var/mob/M in mobs)
		if (istype(M, /mob/new_player))
			continue //cameras can't follow people who haven't started yet DUH OR DIDN'T YOU KNOW THAT
		if (HAS_ATOM_PROPERTY(M, PROP_MOB_AI_UNTRACKABLE))
			continue
		if (ishuman(M) && istype(get_id_card(M:wear_id), /obj/item/card/id/syndicate))
			continue
		if (istype(M,/mob/living/critter/aquatic) || istype(M, /mob/living/critter/small_animal/ranch_base/chicken))
			continue
		if(M.z != 1 && M.z != usr.z)
			continue
		if(!istype(M.loc, /turf)) //in a closet or something, AI can't see him anyways
			continue
		if(M.invisibility) //cloaked
			continue
		if (M == usr)
			continue

		var/turf/T = get_turf(M)
		if(!T.camera_coverage_emitters || !length(T.camera_coverage_emitters))
			continue

		var/name = M.name
		name = labelled_regex.Replace(name, "")
		if (name in names)
			namecounts[name]++
			name = text("[] ([])", name, namecounts[name])
		else
			names.Add(name)
			namecounts[name] = 1

		.[name] = M

/mob/living/silicon/ai/proc/ai_vox_announcement()
	set name = "AI Intercom Announcement"
	set desc = "Makes an intercom announcement."
	set category = "AI Commands"

	if(src.stat || !canvox)
		return

	if(last_vox + vox_cooldown > world.time)
		src.show_text("This ability is still on cooldown for [round((vox_cooldown + last_vox - world.time) / 10)] seconds!", "red")
		return

	vox_reinit_check()

	canvox = 0
	var/message_in = html_encode(input(usr, "Please enter a message (140 characters)", "Intercom Announcement?", ""))
	canvox = 1

	if(!message_in)
		return
	var/message_len = length(message_in)
	var/message = copytext(message_in, 1, 140)

	if(message_len != length(message))
		if(tgui_alert(src.get_message_mob(), "Your message was shortened to: \"[message]\", continue anyway?", "Too wordy!", list("Yes", "No")) != "Yes")
			return

	message = vox_playerfilter(message)

	var/output = vox_play(message, src)
	if(output)
		last_vox = world.time
		logTheThing(LOG_SAY, src, "has created an intercom announcement: \"[output]\", input: \"[message_in]\"")
		logTheThing(LOG_DIARY, src, "has created an intercom announcement: [output]", "say")
		message_admins("[key_name(src)] has created an AI intercom announcement: \"[output]\"")


/mob/living/silicon/ai/proc/ai_station_announcement()
	set name = "AI Station Announcement"
	set desc = "Makes a station announcement."
	set category = "AI Commands"

	if(src.stat || !can_announce)
		return

	if(get_z(src) != Z_LEVEL_STATION)
		src.show_text("Your mainframe was unable relay this command that far away!", "red")
		return

	if(last_announcement + announcement_cooldown > world.time)
		src.show_text("This ability is still on cooldown for [round((announcement_cooldown + last_announcement - world.time) / 10)] seconds!", "red")
		return

	vox_reinit_check()

	can_announce = 0
	var/message_in = tgui_input_text(usr, "Please enter a message (280 characters)", "Station Announcement?") // I made an announcement in game on the announcement computer and this seemed to be the max length
	can_announce = 1

	if(!message_in)
		return
	var/message_len = length(message_in)
	var/message = copytext(message_in, 1, 280)

	if(message_len != length(message))
		if(tgui_alert(src.get_message_mob(), "Your message was shortened to: \"[message]\", continue anyway?", "Too wordy!", list("Yes", "No")) != "Yes")
			return

	var/sound_to_play = 'sound/misc/announcement_1.ogg'
	command_announcement(html_encode(message), "Station Announcement by [src.name] (AI)", sound_to_play)

	last_announcement = world.time

	logTheThing(LOG_SAY, usr, "created a command report: [message]")
	logTheThing(LOG_DIARY, usr, "created a command report: [message]", "say")


/mob/living/silicon/ai/proc/ai_vox_help()
	set name = "AI Intercom Help"
	set desc = "A big list of words. Some of them are even off-limits! Wow!"
	set category = "AI Commands"

	vox_help(src)

/// Lets the AI choose its own name. If renaming_mob is non-null, then that mob is allowed to rename the AI instead.
/mob/living/silicon/ai/choose_name(var/retries = 3, var/default_name = null, var/force_instead = FALSE, var/mob/renaming_mob = null)
	var/obj/item/organ/brain/brain_owner = src.brain.owner
	if(isnull(default_name))
		default_name = pick_string_autokey("names/ai.txt")
	var/newname
	for (retries, retries > 0, retries--)
		if(force_instead)
			newname = default_name
		else
			newname = tgui_input_text(renaming_mob || src, "You are an AI. Would you like to change your name to something else?", "Name Change", client?.preferences?.robot_name || default_name)
			newname = remove_bad_name_characters(newname)
			if(newname && newname != default_name)
				phrase_log.log_phrase("name-ai", newname, no_duplicates=TRUE)
		if (src.brain.owner != brain_owner)
			return
		if (!newname)
			newname = default_name
			break
		else
			newname = strip_html(newname, MOB_NAME_MAX_LENGTH, 1)
			if (!length(newname))
				src.show_text("That name was too short after removing bad characters from it. Please choose a different name.", "red")
				continue
			else if (is_blank_string(newname))
				src.show_text("Your name cannot be blank. Please choose a different name.", "red")
				continue
			else
				if (tgui_alert(renaming_mob || src, "Use the name [newname]?", newname, list("Yes", "No")) == "Yes")
					src.real_name = newname
					if (src.deployed_to_eyecam)
						src.eyecam.real_name = newname
					ON_COOLDOWN(src, "ai_self_rename", src.rename_cooldown)
					break
				else
					continue
	if (!newname)
		src.real_name = default_name

	src.UpdateName()

/mob/living/silicon/ai/UpdateName()
	. = ..()
	src.camera.c_tag = src.real_name
	src.eyecam.UpdateName()
	src.internal_pda.name = "[src.name]'s Internal PDA Unit"
	src.internal_pda.owner = "[src.name]"

// For if an AI needs to disconnect, make their core a latejoin one
/mob/living/silicon/ai/proc/become_latejoin(var/announce = FALSE)
	if (deployed_to_eyecam)
		eyecam.return_mainframe()
	if (deployed_shell)
		src.return_to(deployed_shell)
	if (src.mind)
		src.mind.register_death()
		src.mind.get_player()?.dnr = TRUE
	var/mob/dead/observer/ghost = src.ghostize()
	ghost.corpse = null //no coming back

	//Tell the crew the AI is gone
	if(announce)
		command_alert("Station AI unit [pick("crash", "kernel panic", "unrecoverable error")] detected, attempting automated download of new personality from Central Command database...","Artificial Intelligence Update", alert_origin = ALERT_STATION)
	logTheThing(LOG_COMBAT, src, "is replaced with a latejoin AI at [log_loc(src)].")

	qdel(src.brain)
	src.brain = new /obj/item/organ/brain/latejoin(src)
	src.set_color(000000)
	src.faceEmotion = "ai_blank"
	src.update_appearance()
	src.name = "AI"
	src.UpdateName()

/*-----Core-Creation---------------------------------------*/

/obj/ai_core_frame
	name = "\improper AI core frame"
	desc = "A frame for an AI core."
	icon = 'icons/mob/ai.dmi'
	icon_state = "frame"
	var/build_step = 0
	var/obj/item/cell/cell = null
	var/has_radios = 0
	var/has_interface = 0
	var/has_glass = 0
	var/image/image_coverlay = null
	var/image/image_working = null
	var/skinToApply = "default" // set this in a map editor or something to properly change the skin!

// Overlay layering, from topmost layer to bottommost (radio, cell, and interface are the same layer)
	var/image/image_glass_overlay = null
	var/image/image_wire_overlay = null
	var/image/image_top_overlay = null
	var/image/image_radio_overlay = null
	var/image/image_cell_overlay = null
	var/image/image_interface_overlay = null
	var/image/image_background_overlay = null
// no clue why this used FLY_LAYER before when this is an obj, what the heck

	New()
		. = ..()
		image_glass_overlay = image(icon, "frame_glass", OBJ_LAYER+0.6)
		image_wire_overlay = image(icon, "frame_wires", OBJ_LAYER+0.5)
		image_top_overlay = image(icon, "frame_top", OBJ_LAYER+0.4)
		// +0.3 is reserved for the core overlay; we can't define it here since we dunno what kind of core might be made!
		image_cell_overlay = image(icon, "frame_cell", OBJ_LAYER+0.25)
		image_radio_overlay = image(icon, "frame_radio", OBJ_LAYER+0.2)
		image_interface_overlay = image(icon, "frame_interface", OBJ_LAYER+0.15)
		image_background_overlay = image(icon, "frame_back", OBJ_LAYER+0.1)
		// if someone map edited us in or something and set our build_step to 1 or 2, lets make sure we look the part!
		if(!build_step || (build_step > 2))
			build_step = 0 // if some bozo sets us to over 2 we need to default back to 0 so nothing breaks
		else
			UpdateOverlays(image(icon, skinToApply, OBJ_LAYER+0.3), "core")
			UpdateOverlays(image_background_overlay, "background")
			UpdateOverlays(image_top_overlay, "top")
			if(build_step == 2)
				UpdateOverlays(image_wire_overlay, "wires")

	Exited(Obj, newloc)
		. = ..()
		if(Obj == src.cell)
			src.cell = null

/obj/ai_core_frame/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/sheet))
		if (W.material.getMaterialFlags() & MATERIAL_METAL) // metal sheets
			if (src.build_step < 1)
				var/obj/item/sheet/M = W
				if (M.change_stack_amount(-3))
					src.build_step++
					if (istype(W, /obj/item/sheet/mauxite))
						skinToApply = "mauxite"
					boutput(user, "You add plating to [src]!")
					playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, TRUE)
					src.UpdateOverlays(image(icon, skinToApply, OBJ_LAYER+0.3), "core")
					src.UpdateOverlays(src.image_background_overlay, "background")
					src.UpdateOverlays(src.image_top_overlay, "top")
					return
				else
					boutput(user, "You need at least three metal sheets to add plating to [src].")
					return
			else
				boutput(user, "\The [src] already has plating!")
				return

		else if (W.material.getMaterialFlags() & MATERIAL_CRYSTAL) // glass sheets
			if (src.build_step >= 2)
				if (!src.has_glass)
					var/obj/item/sheet/G = W
					if (G.change_stack_amount(-1))
						src.build_step++
						boutput(user, "You add glass to [src]!")
						playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, TRUE)
						src.has_glass = 1
						src.UpdateOverlays(src.image_glass_overlay, "glass")
						return
					else
						boutput(user, "You need at least one glass sheet to add plating! How are you even seeing this message?! How do you have a glass sheet that has no glass sheets in it?!?!")
						user.drop_item()
						qdel(W) // no bizarro nega-sheets for you :v
						return
				else
					boutput(user, "\The [src] already has glass!")
					return
			else
				boutput(user, "\The [src] needs[src.build_step ? "" : " metal plating and"] wiring installed before you can add the glass.")
				return
		else
			boutput(user, "You can only add metal or glass sheets to \the [src].")
			return

	else if (istype(W, /obj/item/cable_coil))
		if (src.build_step == 1)
			var/obj/item/cable_coil/coil = W
			if (coil.use(3))
				src.build_step++
				boutput(user, "You add \the [W] to [src]!")
				playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, TRUE)
				src.UpdateOverlays(src.image_wire_overlay, "wires")
				if (coil.amount < 1)
					user.drop_item()
					qdel(coil)
				return
			else
				boutput(user, "You need at least three lengths of cable to install it in [src]!")
				return
		else if (src.build_step > 1)
			boutput(user, "\The [src] already has wiring!")
			return
		else
			boutput(user, "\The [src] needs metal plating before you can install the wiring.")
			return

	else if (istype(W, /obj/item/cell))
		if (src.build_step >= 2)
			if (!src.cell)
				src.build_step++
				boutput(user, "You add \the [W] to [src]!")
				playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, TRUE)
				src.cell = W
				user.u_equip(W)
				W.set_loc(src)
				src.UpdateOverlays(image_cell_overlay, "cell")
				return
			else
				boutput(user, "\The [src] already has a cell!")
				return
		else
			boutput(user, "\The [src] needs[src.build_step ? "" : " metal plating and"] wiring installed before you can add the cell.")
			return

	else if (istype(W, /obj/item/device/radio))
		if (src.build_step >= 2)
			if (src.has_radios < 3)
				src.build_step++
				boutput(user, "You add \the [W] to [src]!")
				playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, TRUE)
				src.has_radios++
				qdel(W)
				if (src.has_radios == 1) // we just added the first one, so this is the only time we need to worry about the overlays
					src.UpdateOverlays(image_radio_overlay, "radio")
				return
			else
				boutput(user, "\The [src] already has a radio!")
				return
		else
			boutput(user, "\The [src] needs[src.build_step ? "" : " metal plating and"] wiring installed before you can add the radio.")
			return

	else if (istype(W, /obj/item/ai_interface))
		if (src.build_step >= 2)
			if (!src.has_interface)
				src.build_step++
				boutput(user, "You add \the [W] to [src]!")
				playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, TRUE)
				src.has_interface = 1
				qdel(W)
				src.UpdateOverlays(image_interface_overlay, "interface")
				return
			else
				boutput(user, "\The [src] already has an AI interface!")
				return
		else
			boutput(user, "\The [src] needs[src.build_step ? "" : " metal plating and"] wiring installed before you can add the AI interface.")
			return

	else if (iswrenchingtool(W))
		if (src.build_step >= 8)
			src.build_step++
			boutput(user, "You activate the AI core!  Beep bop!")
			var/mob/living/silicon/ai/A = new /mob/living/silicon/ai(get_turf(src), TRUE, skinToApply) // second parameter causes the core to spawn without a brain
			if (A.cell && src.cell)
				qdel(A.cell)
				A.cell = src.cell
				src.cell.set_loc(A)
				src.cell = null
			A.anchored = UNANCHORED
			A.dismantle_stage = 4
			A.update_appearance()
			qdel(src)
			return
		else
			var/list/still_needed = list()
			if (src.build_step < 1)
				still_needed += "metal plating"
			if (src.build_step < 2)
				still_needed += "wiring"
			if (!src.cell)
				still_needed += "a power cell"
			switch (src.has_radios)
				if (0)
					still_needed += "three station bounced radios"
				if (1)
					still_needed += "two station bounced radios"
				if (2)
					still_needed += "one station bounced radio"
			if (!src.has_interface)
				still_needed += "an AI interface board"
			if (!src.has_glass)
				still_needed += "a pane of glass"
			boutput(user, "\The [src] needs [still_needed.len ? english_list(still_needed) : "bugfixing (please call a coder)"] before you can activate it.")
			return

	else if (istype(W, /obj/item/ai_plating_kit))
		var/obj/item/ai_plating_kit/plating = W
		if (!(src.build_step < 1))
			boutput(user, "\The [src] already has plating!")
			return
		src.build_step++
		boutput(user, "You use the [W] to lay the exterior plating on the [src]!")
		playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, TRUE)
		qdel(plating)
		skinToApply = plating.skin
		AddOverlays(image(icon, skinToApply, OBJ_LAYER+0.3), "core")
		src.AddOverlays(src.image_background_overlay, "background")
		src.AddOverlays(src.image_top_overlay, "top")


/mob/living/silicon/ai/latejoin
	New()
		..()
		qdel(src.brain)
		src.brain = new /obj/item/organ/brain/latejoin(src)
		src.set_color(000000)
		src.faceEmotion = "ai_blank"
		src.coreSkin = "cardboard"
		src.update_appearance()
		src.job = "AI"
		if (src.mind)
			src.mind.assigned_role = "AI"

