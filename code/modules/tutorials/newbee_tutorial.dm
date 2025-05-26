/// How long before auto-continuing for timed steps. Matches the related tutorial timer animation duration.
#define NEWBEE_TUTORIAL_TIMER_DURATION 13 SECONDS

// Markers

/// A large target marker, good for turfs
#define NEWBEE_TUTORIAL_MARKER_TARGET_GROUND "target_ground"
/// A point marker, good for items
#define NEWBEE_TUTORIAL_MARKER_TARGET_POINT "target_point"
/// Highlights an inventory slot
#define NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY "inventory"
/// Highlights the Help intent
#define NEWBEE_TUTORIAL_MARKER_HUD_INTENT_HELP "intent_help"
/// Highlights the Disarm intent
#define NEWBEE_TUTORIAL_MARKER_HUD_INTENT_DISARM "intent_disarm"
/// Highlights the Grab intent
#define NEWBEE_TUTORIAL_MARKER_HUD_INTENT_GRAB "intent_grab"
/// Highlights the Harm intent
#define NEWBEE_TUTORIAL_MARKER_HUD_INTENT_HARM "intent_harm"
/// Highlights the Stand intent
#define NEWBEE_TUTORIAL_MARKER_HUD_STAND "stand"
/// Highlights the Pull intent
#define NEWBEE_TUTORIAL_MARKER_HUD_PULL "pull"

// Sidebars

/// Empty sidebar with no content
#define NEWBEE_TUTORIAL_SIDEBAR_EMPTY "empty"
/// Movement keybinds
#define NEWBEE_TUTORIAL_SIDEBAR_MOVEMENT "movement"
/// Item keybinds
#define NEWBEE_TUTORIAL_SIDEBAR_ITEMS "items"
/// Intent keybinds
#define NEWBEE_TUTORIAL_SIDEBAR_INTENTS "intents"
/// actions like rest and sprint
#define NEWBEE_TUTORIAL_SIDEBAR_ACTIONS "actions"
/// talking and radio
#define NEWBEE_TUTORIAL_SIDEBAR_COMMUNICATION "communication"
/// modifiers like examine and pull
#define NEWBEE_TUTORIAL_SIDEBAR_MODIFIERS "modifiers"
/// meta ahelp/mhelp/looc
#define NEWBEE_TUTORIAL_SIDEBAR_META "meta"

/area/tutorial/newbee
	name = "Newbee Tutorial Zone"
	icon_state = "green"
	sound_group = "newbee"

	/// Landmark at the start of the area, used for warping players backwards
	var/starting_landmark = LANDMARK_TUTORIAL_START

/area/tutorial/newbee/unpowered
	icon_state = "red"
	requires_power = TRUE
	starting_landmark = LANDMARK_TUTORIAL_NEWBEE_UNPOWERED_DOORS

/area/tutorial/newbee/room_1
	icon_state = "start"
	starting_landmark = LANDMARK_TUTORIAL_START
/area/tutorial/newbee/room_2
	icon_state = "yellow"
	starting_landmark = LANDMARK_TUTORIAL_NEWBEE_POWERED_DOORS
/area/tutorial/newbee/room_3
	icon_state = "blue"
	starting_landmark = LANDMARK_TUTORIAL_NEWBEE_IDLOCK_DOORS
/area/tutorial/newbee/room_4
	icon_state = "orange"
	starting_landmark = LANDMARK_TUTORIAL_NEWBEE_UNPOWERED_DOORS
/area/tutorial/newbee/room_5
	icon_state = "purple"
	starting_landmark = LANDMARK_TUTORIAL_NEWBEE_GET_HEALTH
/area/tutorial/newbee/room_6
	icon_state = "pink"
	starting_landmark = LANDMARK_TUTORIAL_NEWBEE_EXIT_HEALING
/area/tutorial/newbee/room_7
	icon_state = "yellow"
	starting_landmark = LANDMARK_TUTORIAL_NEWBEE_DECON_GIRDER
/area/tutorial/newbee/room_8
	icon_state = "blue"
	starting_landmark = LANDMARK_TUTORIAL_NEWBEE_ENTER_MAINTS
/area/tutorial/newbee/room_9
	icon_state = "orange"
	starting_landmark = LANDMARK_TUTORIAL_NEWBEE_TRAVERSE_MAINTS
/area/tutorial/newbee/room_10
	icon_state = "purple"
	starting_landmark = LANDMARK_TUTORIAL_NEWBEE_ENTER_SPACE
/area/tutorial/newbee/room_11
	icon_state = "pink"
	starting_landmark = LANDMARK_TUTORIAL_NEWBEE_TRAVERSE_SPACE
/area/tutorial/newbee/room_12
	icon_state = "yellow"
	starting_landmark = LANDMARK_TUTORIAL_NEWBEE_EXIT_STORAGE
/area/tutorial/newbee/room_13
	icon_state = "blue"
	starting_landmark = LANDMARK_TUTORIAL_NEWBEE_DECON_WALL
/area/tutorial/newbee/room_14
	icon_state = "orange"
	starting_landmark = LANDMARK_TUTORIAL_NEWBEE_EXIT_MOVEMENT
/area/tutorial/newbee/room_15
	icon_state = "purple"
	starting_landmark = LANDMARK_TUTORIAL_NEWBEE_EXIT_RADIO
/area/tutorial/newbee/room_16
	icon_state = "exit"
	starting_landmark = LANDMARK_TUTORIAL_NEWBEE_FINAL_ROOM

/mob/new_player/verb/play_tutorial()
	set name = "Play Tutorial"
	set desc = "Launch the in-game tutorial!"
	set category = "Commands"
	set hidden = TRUE

	if (global.current_state < GAME_STATE_SETTING_UP)
		boutput(usr, SPAN_ALERT("The tutorial will launch when the game starts."))
		src.ready_tutorial = TRUE
		src.update_joinmenu()
	else if (global.current_state <= GAME_STATE_PLAYING)
		if (src.tutorial_loading)
			boutput(usr, SPAN_ALERT("The tutorial is loading, please be patient!"))
			return
		src.tutorial_loading = TRUE
		boutput(usr, SPAN_ALERT("Launching the tutorial!"))
		src.client?.tutorial = new(src)
		src.client?.tutorial.Start()
	else
		boutput(usr, SPAN_ALERT("It's too late to start the tutorial! Please try next round."))

/mob/living/carbon/human/tutorial/verb/stop_newbee_tutorial()
	set name = "Stop Tutorial"
	if (!src.client.tutorial)
		boutput(src, SPAN_ALERT("You're not in a tutorial. It's real. IT'S ALL REAL."))
		return
	src.client.tutorial.Finish()
	src.client.tutorial = null

/datum/tutorial_base/regional/newbee
	name = "Newbee Tutorial"
	region_type = /datum/mapPrefab/allocated/newbee_tutorial

	advance_sound = 'sound/misc/tutorial-bloop.ogg'

	var/mob/living/carbon/human/tutorial/newbee = null
	var/mob/new_player/origin_mob
	var/datum/hud/tutorial/tutorial_hud
	var/datum/keymap/keymap
	var/checkpoint_landmark = LANDMARK_TUTORIAL_START

	var/current_sidebar
	var/list/sidebars = list()

	New(mob/M)
		..()
		src.exit_point = pick_landmark(LANDMARK_NEW_PLAYER)
		src.origin_mob = M
		src.origin_mob.close_spawn_windows()
		animate(src.origin_mob.client, color = "#000000", time = 5, easing = QUAD_EASING | EASE_IN)
		src.keymap = src.origin_mob.client.keymap
		src.generate_sidebars()
		src.newbee = new(src.initial_turf, src.origin_mob.client.preferences.AH, src.origin_mob.client.preferences, TRUE)
		src.owner = src.newbee
		src.AddNewbeeSteps() // need the keymap in place before adding steps for reading player custom binds

	Start()
		src.tutorial_hud = new()
		src.origin_mob.mind.transfer_to(src.newbee)
		src.tutorial_hud.add_client(src.newbee.client)
		src.newbee.addAbility(/datum/targetable/newbee/exit)
		src.newbee.addAbility(/datum/targetable/newbee/previous)
		src.newbee.addAbility(/datum/targetable/newbee/next)
		var/target_color = "#FFFFFF"
		if(src.newbee.client.color != "#000000")
			target_color = src.newbee.client.color
		animate(src.newbee.client, color = "#000000", time = 0, flags = ANIMATION_END_NOW)
		animate(color = "#000000", time = 10, easing = QUAD_EASING | EASE_IN)
		animate(color = target_color, time = 10, easing = QUAD_EASING | EASE_IN)
		. = ..()

	Advance(manually_selected=FALSE)
		var/datum/tutorialStep/newbee/T = steps[current_step]
		if (!manually_selected)
			var/completion_sound = src.advance_sound
			if (T.custom_advance_sound)
				completion_sound = T.custom_advance_sound
			playsound(get_turf(owner), completion_sound, 50)
		if (current_step > steps.len)
			return
		T.TearDown()
		current_step++
		if (current_step > steps.len)
			Finish()
			return
		T = steps[current_step]
		ShowStep()
		T.SetUp(manually_selected)

	ShowStep()
		. = ..()
		var/datum/tutorialStep/newbee/T = src.steps[src.current_step]
		src.tutorial_hud.update_step(T.name)
		src.tutorial_hud.update_text(T.instructions)
		if (T.sidebar && T.sidebar != src.current_sidebar)
			src.tutorial_hud.update_sidebar(src.sidebars[T.sidebar])
			src.current_sidebar = T.sidebar

	Finish()
		if(..())
			src.tutorial_hud.remove_client(src.newbee.client)
			var/mob/new_player/M = new()
			M.key = src.newbee.client.key
			qdel(src.newbee)
			src.newbee = null
			qdel(src.tutorial_hud)
			src.tutorial_hud = null
			src.region.clean_up() // aggressive cleanup to wipe out landmarks/spawned objects
			qdel(src)

	proc/generate_sidebars()
		if (!src.keymap)
			CRASH("Tried to generate tutorial sidebar without keymap")

		src.sidebars += list(NEWBEE_TUTORIAL_SIDEBAR_EMPTY = "")

		var/up = src.keymap.action_to_keybind(KEY_FORWARD) || "W"
		var/left = src.keymap.action_to_keybind(KEY_LEFT) || "A"
		var/down = src.keymap.action_to_keybind(KEY_BACKWARD) || "S"
		var/right = src.keymap.action_to_keybind(KEY_RIGHT) || "D"
		src.sidebars += list(NEWBEE_TUTORIAL_SIDEBAR_MOVEMENT = "Movement:<br>[up] - Up<br>[left] - Left<br>[down] - Down<br>[right] - Right")

		var/equip = src.keymap.action_to_keybind("equip") || "V"
		var/attackself = src.keymap.action_to_keybind("attackself") || "C"
		var/drop_item = src.keymap.action_to_keybind("drop") || "Q"
		var/swaphand = src.keymap.action_to_keybind("swaphand") || "E"
		src.sidebars += list(NEWBEE_TUTORIAL_SIDEBAR_ITEMS = "Items:<br>[equip] - Equip<br>[attackself] - Use in hand<br>[drop_item] - Drop<br>[swaphand] - Swap Hands")

		var/help = src.keymap.action_to_keybind("help") || "1"
		var/disarm = src.keymap.action_to_keybind("disarm") || "2"
		var/grab = src.keymap.action_to_keybind("grab") || "3"
		var/harm = src.keymap.action_to_keybind("harm") || "4"
		src.sidebars += list(NEWBEE_TUTORIAL_SIDEBAR_INTENTS = "Intents:<br>[help] - <span style='color:#349E00'>Help</span><br>[disarm] - <span style='color:#EAC300'>Disarm</span><br>[grab] - <span style='color:#FF6A00'>Grab</span><br>[harm] - <span style='color:#B51214'>Harm</span>")

		var/rest = src.keymap.action_to_keybind("rest") || "="
		var/sprint = src.keymap.action_to_keybind(KEY_RUN) || "SHIFT"
		var/walk = src.keymap.action_to_keybind("walk") || "-"
		var/resist = src.keymap.action_to_keybind("resist") || "Z"
		src.sidebars += list(NEWBEE_TUTORIAL_SIDEBAR_ACTIONS = "Actions:<br>[rest] - Laydown/Standup<br>[sprint] - Sprint<br>[walk] - Walk<br>[resist] - Resist")

		var/say = src.keymap.action_to_keybind("say") || "T"
		var/say_over_channel = src.keymap.action_to_keybind("say_over_channel") || "Y"
		var/say_over_main_radio = src.keymap.action_to_keybind("say_over_main_radio") || ";"
		var/emote = src.keymap.action_to_keybind("emote") || "M"
		src.sidebars += list(NEWBEE_TUTORIAL_SIDEBAR_COMMUNICATION = "Communication:<br>[say] - Talk<br>[say_over_channel] - Radio Channels<br>[say_over_main_radio] - Main Radio<br>[emote] - Emote")

		var/examine = src.keymap.action_to_keybind(KEY_EXAMINE) || "ALT"
		var/pull = src.keymap.action_to_keybind(KEY_PULL) || "CTRL"
		var/point = src.keymap.action_to_keybind(KEY_POINT) || "B"
		var/throw_key = src.keymap.action_to_keybind("throw") || "SPACE"
		src.sidebars += list(NEWBEE_TUTORIAL_SIDEBAR_MODIFIERS = "Modifiers:<br>[examine] - Examine<br>[pull] - Pull<br>[point] - Point<br>[throw_key] - Throw")

		var/adminhelp = src.keymap.action_to_keybind("adminhelp") || "F1"
		var/mentorhelp = src.keymap.action_to_keybind("mentorhelp") || "F3"
		var/looc = src.keymap.action_to_keybind("looc") || "ALT+L"
		src.sidebars += list(NEWBEE_TUTORIAL_SIDEBAR_META = "Meta:<br>[adminhelp] - Admin Help<br>[mentorhelp] - Mentor Help<br>[looc] - Local OOC")


/obj/landmark/newbee
	deleted_on_start = FALSE

	Crossed(atom/movable/AM)
		..()
		if (!ismob(AM) || !isliving(AM))
			return
		var/mob/M = AM
		M.client?.tutorial?.PerformSilentAction(src.name)

	disposing()
		landmarks[name] -= src.loc
		. = ..()

/datum/tutorial_base/regional/newbee/proc/AddNewbeeSteps()
	// room 1 - Arrivals & Movement
	src.AddStep(/datum/tutorialStep/newbee/timer/welcome)
	src.AddStep(/datum/tutorialStep/newbee/move_to/basic_movement)
	src.AddStep(/datum/tutorialStep/newbee/move_to/powered_doors)

	// room 2 - ID-locked Doors
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/id_card)
	src.AddStep(/datum/tutorialStep/newbee/wear_id_card)
	src.AddStep(/datum/tutorialStep/newbee/move_to/id_locked_doors)

	// room 3 - Items & Unpowered Doors
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/crowbar)
	src.AddStep(/datum/tutorialStep/newbee/move_to/unpowered_doors)

	// room 4 - Intents & Combat
	src.AddStep(/datum/tutorialStep/newbee/drop_item)
	src.AddStep(/datum/tutorialStep/newbee/intent_help)
	src.AddStep(/datum/tutorialStep/newbee/help_person)
	src.AddStep(/datum/tutorialStep/newbee/intent_disarm)
	src.AddStep(/datum/tutorialStep/newbee/disarm_person)
	src.AddStep(/datum/tutorialStep/newbee/intent_grab)
	src.AddStep(/datum/tutorialStep/newbee/grab_person)
	src.AddStep(/datum/tutorialStep/newbee/intent_harm)
	src.AddStep(/datum/tutorialStep/newbee/basic_combat)
	src.AddStep(/datum/tutorialStep/newbee/move_to/exit_intents)

	// room 5 - Healing
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/first_aid)
	src.AddStep(/datum/tutorialStep/newbee/storage_inhands)
	src.AddStep(/datum/tutorialStep/newbee/hand_swap)
	src.AddStep(/datum/tutorialStep/newbee/apply_patch)
	src.AddStep(/datum/tutorialStep/newbee/move_to/exit_healing)

	// room 6 - Girder Deconstruction
	src.AddStep(/datum/tutorialStep/newbee/examining)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/toolbox)
	src.AddStep(/datum/tutorialStep/newbee/move_to/deconstructing_girder)

	// room 7 - Active Items
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/flashlight)
	src.AddStep(/datum/tutorialStep/newbee/activating_items)

	// room 8 - Dark Areas
	src.AddStep(/datum/tutorialStep/newbee/move_to/enter_maints)
	src.AddStep(/datum/tutorialStep/newbee/move_to/traversing_maints)

	// room 9 - Space Prep
	src.AddStep(/datum/tutorialStep/newbee/opening_closets)
	src.AddStep(/datum/tutorialStep/newbee/equip_space_suit)
	src.AddStep(/datum/tutorialStep/newbee/equip_breath_mask)
	src.AddStep(/datum/tutorialStep/newbee/equip_space_helmet)
	src.AddStep(/datum/tutorialStep/newbee/oxygen)
	src.AddStep(/datum/tutorialStep/newbee/internals)

	// room 10 - Space Traversal
	src.AddStep(/datum/tutorialStep/newbee/move_to/enter_space)
	src.AddStep(/datum/tutorialStep/newbee/move_to/traversing_space)

	// room 11 - Storage
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/backpack)
	src.AddStep(/datum/tutorialStep/newbee/equip_backpack)
	src.AddStep(/datum/tutorialStep/newbee/unequipping_worn_items)
	src.AddStep(/datum/tutorialStep/newbee/move_to/exit_storage)

	// room 12 - Wall Deconstruction
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/welding_mask)
	src.AddStep(/datum/tutorialStep/newbee/equip_welding_mask)
	src.AddStep(/datum/tutorialStep/newbee/flip_welding_mask_down)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/weldingtool)
	src.AddStep(/datum/tutorialStep/newbee/using_welder)
	src.AddStep(/datum/tutorialStep/newbee/move_to/decon_wall)
	src.AddStep(/datum/tutorialStep/newbee/flip_welding_mask_up)
	src.AddStep(/datum/tutorialStep/newbee/move_to/decon_wall_girder)

	// room 13 - Advanced Movement
	src.AddStep(/datum/tutorialStep/newbee/move_to/laying_down)
	src.AddStep(/datum/tutorialStep/newbee/move_to/sprinting)
	src.AddStep(/datum/tutorialStep/newbee/move_to/exit_movement)

	// room 14 - Talking / Radio
	src.AddStep(/datum/tutorialStep/newbee/say)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/headset)
	src.AddStep(/datum/tutorialStep/newbee/equip_headset)
	src.AddStep(/datum/tutorialStep/newbee/using_headset)
	src.AddStep(/datum/tutorialStep/newbee/move_to/exit_radio)

	// room 15 - Pulling
	src.AddStep(/datum/tutorialStep/newbee/pull_start)
	src.AddStep(/datum/tutorialStep/newbee/move_to/pull_target)
	src.AddStep(/datum/tutorialStep/newbee/pull_end)
	src.AddStep(/datum/tutorialStep/newbee/move_to/final_room)

	// room 16 - Advanced Combat
	src.AddStep(/datum/tutorialStep/newbee/murder)
	src.AddStep(/datum/tutorialStep/newbee/timer/following_rules)
	src.AddStep(/datum/tutorialStep/newbee/timer/getting_help)
	src.AddStep(/datum/tutorialStep/newbee/timer/finished)

/datum/tutorialStep/newbee
	var/static/image/destination_marker = null
	var/static/image/point_marker = null
	var/static/image/inventory_marker = null
	var/static/image/help_intent_marker = null
	var/static/image/disarm_intent_marker = null
	var/static/image/grab_intent_marker = null
	var/static/image/harm_intent_marker = null
	var/static/image/stand_marker = null
	var/static/image/pull_marker = null

	// common vars
	var/datum/tutorial_base/regional/newbee/newbee_tutorial
	var/datum/allocated_region/region
	var/datum/keymap/keymap

	// settable vars for enabling specific behavior
	/// Which sidebar to display; see NEWBEE_TUTORIAL_SIDEBAR_*
	var/sidebar = NEWBEE_TUTORIAL_SIDEBAR_EMPTY

	/// Associated area of the step. Used to handle warping for stepping backwards
	var/area/tutorial/newbee/step_area

	/// an optional custom sound to use when advacing this step
	var/custom_advance_sound

	/// Which HUD element to highlight, by ID
	var/highlight_hud_element
	/// The icon state to apply to the HUD
	var/highlight_hud_marker

	/// A needed item to complete this tutorial step. Will attempt to find the object on the player and highlight it. Failing that, it will create one.
	var/needed_item_path

	// internal tracking for setup/teardown
	/// A reference to the currently targeted hud element for HUD highlighting
	var/atom/movable/screen/hud/_target_hud_element
	/// Reference to the currently needed item
	var/obj/item/_needed_item
	/// A reference to the currently targeted hud element for HUD highlighting
	var/atom/movable/screen/hud/_target_hud_item

	New(datum/tutorial_base/regional/newbee/tutorial)
		src.newbee_tutorial = tutorial
		src.region = tutorial.region
		src.keymap = tutorial.keymap
		if (!src.destination_marker)
			src.destination_marker = image('icons/effects/VR.dmi', "lightning_marker", HUD_LAYER_3)
			src.destination_marker.alpha = 125
			src.destination_marker.plane = PLANE_HUD
			src.destination_marker.filters = filter(type="outline", size=1)
		if (!src.point_marker)
			src.point_marker = image('icons/mob/screen1.dmi', "arrow", HUD_LAYER_3, pixel_y=8)
			src.point_marker.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | PIXEL_SCALE
			src.point_marker.plane = PLANE_HUD
			src.point_marker.color = "#33cccc"
		if (!src.inventory_marker)
			src.inventory_marker = image('icons/mob/tutorial_ui.dmi', "inventory", HUD_LAYER_3)
			src.inventory_marker.plane = PLANE_HUD
		if (!src.help_intent_marker)
			src.help_intent_marker = image('icons/mob/tutorial_ui.dmi', "intent_help", HUD_LAYER_3)
			src.help_intent_marker.plane = PLANE_HUD
		if (!src.disarm_intent_marker)
			src.disarm_intent_marker = image('icons/mob/tutorial_ui.dmi', "intent_disarm", HUD_LAYER_3)
			src.disarm_intent_marker.plane = PLANE_HUD
		if (!src.grab_intent_marker)
			src.grab_intent_marker = image('icons/mob/tutorial_ui.dmi', "intent_grab", HUD_LAYER_3)
			src.grab_intent_marker.plane = PLANE_HUD
		if (!src.harm_intent_marker)
			src.harm_intent_marker = image('icons/mob/tutorial_ui.dmi', "intent_harm", HUD_LAYER_3)
			src.harm_intent_marker.plane = PLANE_HUD
		if (!src.stand_marker)
			src.stand_marker = image('icons/mob/tutorial_ui.dmi', "stand", HUD_LAYER_3)
			src.stand_marker.plane = PLANE_HUD
		if (!src.pull_marker)
			src.pull_marker = image('icons/mob/tutorial_ui.dmi', "pull", HUD_LAYER_3)
			src.pull_marker.plane = PLANE_HUD
		..()

	SetUp(manually_selected=FALSE)
		. = ..()
		if (manually_selected && src.step_area)
			if (!istype(get_area(src.newbee_tutorial.newbee), src.step_area))
				for(var/turf/T in landmarks[src.step_area.starting_landmark])
					if(src.region.turf_in_region(T))
						src.newbee_tutorial.newbee.set_loc(T)
		if (src.highlight_hud_element && src.highlight_hud_marker)
			src.highlight_hud()
		if (src.needed_item_path)
			src.highlight_needed_item()

	TearDown()
		. = ..()
		src._target_hud_element?.UpdateOverlays(null, "marker")
		src._needed_item?.UpdateOverlays(null, "marker")
		src._target_hud_item?.UpdateOverlays(null, "marker")

	/// highlight a specific hud element
	proc/highlight_hud()
		if (!src.highlight_hud_element || !src.highlight_hud_marker)
			return

		var/image/highlight_image
		switch(src.highlight_hud_marker)
			if(NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY)
				highlight_image = src.inventory_marker
			if(NEWBEE_TUTORIAL_MARKER_HUD_INTENT_HELP)
				highlight_image = src.help_intent_marker
			if(NEWBEE_TUTORIAL_MARKER_HUD_INTENT_DISARM)
				highlight_image = src.disarm_intent_marker
			if(NEWBEE_TUTORIAL_MARKER_HUD_INTENT_GRAB)
				highlight_image = src.grab_intent_marker
			if(NEWBEE_TUTORIAL_MARKER_HUD_INTENT_HARM)
				highlight_image = src.harm_intent_marker
			if(NEWBEE_TUTORIAL_MARKER_HUD_STAND)
				highlight_image = src.stand_marker
			if(NEWBEE_TUTORIAL_MARKER_HUD_PULL)
				highlight_image = src.pull_marker

		if (!highlight_image)
			return

		for (var/atom/movable/screen/hud/hud_element in src.newbee_tutorial.newbee.hud.objects)
			if (hud_element.id == src.highlight_hud_element)
				src._target_hud_element = hud_element
				break

		src._target_hud_element?.UpdateOverlays(highlight_image, "marker")

	/// highlight a needed item, including the inventory slot if on the character
	proc/highlight_needed_item()
		if (!src.needed_item_path)
			return

		src._needed_item = locate(src.needed_item_path) in src.newbee_tutorial.newbee
		if (!src._needed_item)
			src._needed_item = new src.needed_item_path(get_turf(src.newbee_tutorial.newbee))
			src.newbee_tutorial.newbee.put_in_hand_or_drop(src._needed_item)

		var/highlight_target
		if (src._needed_item == src.newbee_tutorial.newbee.l_hand)
			highlight_target = "lhand"
		else if (src._needed_item == src.newbee_tutorial.newbee.r_hand)
			highlight_target = "rhand"
		else if (src._needed_item == src.newbee_tutorial.newbee.l_store)
			highlight_target = "storage1"
		else if (src._needed_item == src.newbee_tutorial.newbee.l_store)
			highlight_target = "storage2"
		else if (src._needed_item == src.newbee_tutorial.newbee.back)
			highlight_target = "back"
		else if (src._needed_item == src.newbee_tutorial.newbee.belt)
			highlight_target = "belt"
		else if (src._needed_item == src.newbee_tutorial.newbee.shoes)
			highlight_target = "shoes"
		else if (src._needed_item == src.newbee_tutorial.newbee.gloves)
			highlight_target = "gloves"
		else if (src._needed_item == src.newbee_tutorial.newbee.wear_id)
			highlight_target = "id"
		else if (src._needed_item == src.newbee_tutorial.newbee.w_uniform)
			highlight_target = "under"
		else if (src._needed_item == src.newbee_tutorial.newbee.wear_suit)
			highlight_target = "suit"
		else if (src._needed_item == src.newbee_tutorial.newbee.glasses)
			highlight_target = "glasses"
		else if (src._needed_item == src.newbee_tutorial.newbee.ears)
			highlight_target = "ears"
		else if (src._needed_item == src.newbee_tutorial.newbee.back)
			highlight_target = "back"
		else if (src._needed_item == src.newbee_tutorial.newbee.wear_mask)
			highlight_target = "mask"
		else if (src._needed_item == src.newbee_tutorial.newbee.head)
			highlight_target = "head"

		if (highlight_target)
			for (var/atom/movable/screen/hud/hud_element in src.newbee_tutorial.newbee.hud.objects)
				if (hud_element.id == highlight_target)
					src._target_hud_item = hud_element
					break
			src._target_hud_item.UpdateOverlays(src.inventory_marker, "marker")

		src._needed_item.UpdateOverlays(src.point_marker, "marker")


// tutorial step subtypes with common behavior

/// Steps that direct the player to move to a location
/datum/tutorialStep/newbee/move_to
	name = "Moving on..."
	instructions = "Head into the next room to continue."
	var/target_landmark
	var/targeting_type = NEWBEE_TUTORIAL_MARKER_TARGET_GROUND

	var/turf/_target_destination

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[src.target_landmark])
			if(src.region.turf_in_region(T))
				src._target_destination = T
				break
		if (src.targeting_type == NEWBEE_TUTORIAL_MARKER_TARGET_GROUND)
			src._target_destination.UpdateOverlays(src.destination_marker, "marker")
		else if (src.targeting_type == NEWBEE_TUTORIAL_MARKER_TARGET_POINT)
			src._target_destination.UpdateOverlays(src.point_marker, "marker")

	PerformAction(action, context)
		. = ..()
		if (action == src.target_landmark)
			src.finished = TRUE

	TearDown()
		. = ..()
		src._target_destination.UpdateOverlays(null, "marker")
		src.newbee_tutorial.checkpoint_landmark = src.target_landmark

/// Show countdown clock and move to the next step after `NEWBEE_TUTORIAL_TIMER_DURATION`
/datum/tutorialStep/newbee/timer
	SetUp()
		. = ..()
		src.newbee_tutorial.tutorial_hud.flick_timer()
		SPAWN (NEWBEE_TUTORIAL_TIMER_DURATION)
			if (src.tutorial.steps[src.tutorial.current_step] == src)
				src.tutorial.Advance()

	TearDown()
		. = ..()
		src.newbee_tutorial.tutorial_hud?.stop_timer()

/// Spawn an item of the given type at given landmark, and continue when picked up
/datum/tutorialStep/newbee/item_pickup
	var/target_landmark
	var/item_path

	var/obj/item/_target_item

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[target_landmark])
			if(src.region.turf_in_region(T))
				if (!src._target_item || QDELETED(src._target_item))
					src._target_item = new item_path(T)
				if (ismob(src._target_item.loc))
					var/mob/M = src._target_item.loc
					M.drop_item(src._target_item)
				src._target_item.set_loc(T)
				break
		src._target_item.UpdateOverlays(src.point_marker, "marker")
		RegisterSignal(src._target_item, COMSIG_ITEM_PICKUP, PROC_REF(check_item))

	proc/check_item(atom/source, mob/user)
		src.tutorial.PerformAction("item_pickup", item_path)

	PerformAction(action, context)
		if (action == "item_pickup" && context == item_path)
			src.finished = TRUE
		. = ..()

	TearDown()
		. = ..()
		src._target_item.UpdateOverlays(null, "marker")
		UnregisterSignal(src._target_item, COMSIG_ITEM_PICKUP)

// actual tutorial steps

//
// room 1 - Arrivals / Movement
//

/datum/tutorialStep/newbee/timer/welcome
	name = "Welcome to Space Station 13!"
	instructions = "This tutorial covers the basics of the game.<br>The top-left buttons let you exit, go back a step, or skip a step."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_EMPTY

	step_area = /area/tutorial/newbee/room_1

/obj/landmark/newbee/basic_movement
	name = LANDMARK_TUTORIAL_NEWBEE_BASIC_MOVEMENT
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/basic_movement
	name = "Basic Movement"
	instructions = "Use W/A/S/D to move your character.<br>Walk to the marker to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_BASIC_MOVEMENT
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_MOVEMENT
	step_area = /area/tutorial/newbee/room_1

	New()
		. = ..()
		var/up = src.keymap.action_to_keybind(KEY_FORWARD) || "W"
		var/left = src.keymap.action_to_keybind(KEY_LEFT) || "A"
		var/down = src.keymap.action_to_keybind(KEY_BACKWARD) || "S"
		var/right = src.keymap.action_to_keybind(KEY_RIGHT) || "D"
		src.instructions = "Use [up]/[left]/[down]/[right] to move your character.<br>Walk to the marker to continue."

/obj/landmark/newbee/powered_doors
	name = LANDMARK_TUTORIAL_NEWBEE_POWERED_DOORS
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/powered_doors
	name = "Powered Doors"
	instructions = "Powered doors will open when you walk into them.<br>Head through the doorway into the next room."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_POWERED_DOORS
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_MOVEMENT
	step_area = /area/tutorial/newbee/room_1
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

//
// room 2 - ID-locked Doors
//

/obj/landmark/newbee/pickup_id_card
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_ID_CARD
	icon = 'icons/obj/items/card.dmi'
	icon_state = "id_eng"

/datum/tutorialStep/newbee/item_pickup/id_card
	name = "Picking Up Items"
	instructions = "You can <b>click</b> on items to pick them up.<br><b>Click</b> the ID card to pick it up."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_ID_CARD
	item_path = /obj/item/card/id/engineering/tutorial
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_2

	SetUp()
		. = ..()
		if (istype(src._target_item, /obj/item/card/id/engineering/tutorial))
			var/obj/item/card/id/engineering/tutorial/tutorial_card = src._target_item
			tutorial_card.registered = src.newbee_tutorial.newbee.name
			tutorial_card.assignment = "Engineer"
			tutorial_card.update_name()

/datum/tutorialStep/newbee/wear_id_card
	name = "Worn Items"
	instructions = "Some items can be worn. Press <b>V</b> to wear the ID card, or click the ID card slot in your HUD."
	highlight_hud_element = "id"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	needed_item_path = /obj/item/card/id/engineering/tutorial
	step_area = /area/tutorial/newbee/room_2

	New()
		. = ..()
		var/equip = src.keymap.action_to_keybind("equip") || "V"
		src.instructions = "Some items can be worn.<br>Press <b>[equip]</b> to wear the ID card, or click the ID card slot in your HUD.."

	SetUp()
		. = ..()
		RegisterSignal(src._needed_item, COMSIG_ITEM_EQUIPPED, PROC_REF(check_item_equipped))

	proc/check_item_equipped(datum/source, mob/equipper, slot)
		src.tutorial.PerformSilentAction("item_equipped", "id_card")

	PerformAction(action, context)
		. = ..()
		if (action == "item_equipped" && context == "id_card")
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src._needed_item, COMSIG_ITEM_EQUIPPED)

/obj/landmark/newbee/idlock_doors
	name = LANDMARK_TUTORIAL_NEWBEE_IDLOCK_DOORS
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/id_locked_doors
	name = "ID-Locked Doors"
	instructions = "Some doors require a valid ID to open.<br>With your worn ID, you can head into the next room."
	highlight_hud_element = "id"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	needed_item_path = /obj/item/card/id/engineering/tutorial
	step_area = /area/tutorial/newbee/room_2
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_IDLOCK_DOORS

//
// room 3 - Items & Unpowered Doors
//

/obj/landmark/newbee/pickup_crowbar
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_CROWBAR
	icon = 'icons/obj/items/tools/crowbar.dmi'
	icon_state = "crowbar"

/datum/tutorialStep/newbee/item_pickup/crowbar
	name = "Usable Items"
	instructions = "Some items can interact with the world.<br><b>Click</b> the crowbar to pick it up."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_CROWBAR
	item_path = /obj/item/crowbar
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_3

/obj/landmark/newbee/unpowered_doors
	name = LANDMARK_TUTORIAL_NEWBEE_UNPOWERED_DOORS
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/unpowered_doors
	name = "Unpowered Doors"
	instructions = "Unpowered doors can be opened with crowbars.<br><b>Click</b> the door with the crowbar, and head into the next room."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_UNPOWERED_DOORS
	targeting_type = NEWBEE_TUTORIAL_MARKER_TARGET_POINT
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	needed_item_path = /obj/item/crowbar
	step_area = /area/tutorial/newbee/room_3
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

//
// room 4 - Intents & Combat
//

/datum/tutorialStep/newbee/drop_item
	name = "Dropping Items"
	instructions = "You'll need to free your hands up for the next lesson.<br>Drop the crowbar in your active hand by pressing <b>Q</b>."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	needed_item_path = /obj/item/crowbar
	step_area = /area/tutorial/newbee/room_4

	New()
		. = ..()
		var/drop = src.keymap.action_to_keybind("drop") || "Q"
		src.instructions = "You'll need to free your hands up for the next lesson.<br>Drop the crowbar in your active hand by pressing <b>[drop]</b>."

	SetUp()
		. = ..()
		RegisterSignal(src._needed_item, COMSIG_ITEM_DROPPED, PROC_REF(check_item_dropped))

	proc/check_item_dropped(item, mob/user)
		src.tutorial.PerformAction("item_dropped", "held_item")

	PerformAction(action, context)
		. = ..()
		if (action == "item_dropped" && context == "held_item")
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src._needed_item, COMSIG_ITEM_DROPPED)

/datum/tutorialStep/newbee/intent_help
	name = "Help Intent"
	instructions = "The <span style='color:#349E00; font-weight: bold'>Help</span> intent will help people up, or give critical people CPR.<br>Press <b>1</b> to switch to the <span style='color:#349E00; font-weight: bold'>Help</span> intent."
	highlight_hud_element = "intent"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INTENT_HELP
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_INTENTS
	step_area = /area/tutorial/newbee/room_4

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		var/help = src.keymap.action_to_keybind("help") || "1"
		src.instructions = "The <span style='color:#349E00; font-weight: bold'>Help</span> intent will help people up, or give critical people CPR.<br>Press <b>[help]</b> to switch to the <span style='color:#349E00; font-weight: bold'>Help</span> intent."

	SetUp()
		. = ..()
		if (src.newbee_tutorial.newbee.intent == INTENT_HELP || src.newbee_tutorial.newbee.intent == null)
			src.newbee_tutorial.newbee.set_a_intent(INTENT_HARM)
		RegisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_SET_A_INTENT, PROC_REF(check_intent))

	proc/check_intent(datum/source, intent)
		if (intent == INTENT_HELP)
			src.tutorial.PerformAction("set_a_intent", intent)

	PerformAction(action, context)
		. = ..()
		if (action == "set_a_intent" && context == INTENT_HELP)
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_SET_A_INTENT)

/obj/landmark/newbee/help_person
	name = LANDMARK_TUTORIAL_NEWBEE_HELP_PERSON
	icon = 'icons/map-editing/job_start.dmi'
	icon_state = "clown"

/datum/tutorialStep/newbee/help_person
	name = "Helping People"
	instructions = "<b>Click</b> the clown with the <span style='color:#349E00; font-weight: bold'>Help</span> intent.<br>Help the clown stand up."
	highlight_hud_element = "intent"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INTENT_HELP
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_INTENTS
	step_area = /area/tutorial/newbee/room_4

	var/mob/living/carbon/human/normal/tutorial_help/target_mob

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_HELP_PERSON])
			if(src.region.turf_in_region(T))
				if (src.target_mob)
					src.target_mob.set_loc(T)
				else
					src.target_mob = new(T)
				break
		src.target_mob.setStatus("resting", INFINITE_STATUS)
		src.target_mob.force_laydown_standup()
		src.target_mob.UpdateOverlays(src.point_marker, "marker")
		RegisterSignal(src.target_mob, COMSIG_MOB_LAYDOWN_STANDUP, PROC_REF(check_mob_laydown_standup), TRUE)

	proc/check_mob_laydown_standup(source, lying)
		src.tutorial.PerformAction("mob_laydown_standup", "standup")

	PerformAction(action, context)
		. = ..()
		if (action == "mob_laydown_standup" && context == "standup")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (!src.target_mob)
			return
		src.target_mob.UpdateOverlays(null, "marker")
		UnregisterSignal(src.target_mob, COMSIG_MOB_LAYDOWN_STANDUP)
		var/mob/M = src.target_mob
		src.target_mob = null
		SPAWN(4 SECONDS)
			animate_teleport(M)
			showswirl_out(M)
			if (length(M.grabbed_by))
				for(var/obj/item/grab/G in M.grabbed_by)
					qdel(G)
			SPAWN (1.5 SECONDS)
				if (M)
					qdel(M)

/datum/tutorialStep/newbee/intent_disarm
	name = "Disarm Intent"
	instructions = "The <span style='color:#EAC300; font-weight: bold'>Disarm</span> intent will knock items out of someone's hands or push them to the ground.<br>Press <b>2</b> to switch to the <span style='color:#EAC300; font-weight: bold'>Disarm</span> intent."
	highlight_hud_element = "intent"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INTENT_DISARM
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_INTENTS
	step_area = /area/tutorial/newbee/room_4

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		var/disarm = src.keymap.action_to_keybind("disarm") || "2"
		src.instructions = "The <span style='color:#EAC300; font-weight: bold'>Disarm</span> intent will knock items out of someone's hands or push them to the ground.<br>Press <b>[disarm]</b> to switch to the <span style='color:#EAC300; font-weight: bold'>Disarm</span> intent."

	SetUp()
		. = ..()
		if (src.newbee_tutorial.newbee.intent == INTENT_DISARM)
			src.newbee_tutorial.newbee.set_a_intent(INTENT_HELP)
		RegisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_SET_A_INTENT, PROC_REF(check_intent))

	proc/check_intent(datum/source, intent)
		if (intent == INTENT_DISARM)
			src.tutorial.PerformAction("set_a_intent", intent)

	PerformAction(action, context)
		. = ..()
		if (action == "set_a_intent" && context == INTENT_DISARM)
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_SET_A_INTENT)

/obj/landmark/newbee/disarm_person
	name = LANDMARK_TUTORIAL_NEWBEE_DISARM_PERSON
	icon = 'icons/map-editing/job_start.dmi'
	icon_state = "clown"

/datum/tutorialStep/newbee/disarm_person
	name = "Disarming People"
	instructions = "<b>Click</b> the clown while on <span style='color:#EAC300; font-weight: bold'>Disarm</span> intent.<br>Knock the bike horn out of the clown's hands."
	highlight_hud_element = "intent"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INTENT_DISARM
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_INTENTS
	step_area = /area/tutorial/newbee/room_4

	var/mob/living/carbon/human/normal/tutorial_disarm/target_mob
	var/obj/item/target_item_left

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_DISARM_PERSON])
			if(src.region.turf_in_region(T))
				if (src.target_mob)
					src.target_mob.set_loc(T)
				else
					src.target_mob = new(T)
				break
		src.target_mob.UpdateOverlays(src.point_marker, "marker")
		src.target_item_left = src.target_mob.l_hand
		RegisterSignal(src.target_item_left, COMSIG_ITEM_DROPPED, PROC_REF(check_item_dropped))

	proc/check_item_dropped()
		src.tutorial.PerformAction("item_dropped", "disarm_clown")

	PerformAction(action, context)
		. = ..()
		if (action == "item_dropped" && context == "disarm_clown")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (!src.target_mob)
			return
		src.target_mob.UpdateOverlays(null, "marker")
		UnregisterSignal(src.target_mob, COMSIG_ITEM_DROPPED)
		var/mob/M = src.target_mob
		src.target_mob = null
		SPAWN(4 SECONDS)
			animate_teleport(M)
			showswirl_out(M)
			if (length(M.grabbed_by))
				for(var/obj/item/grab/G in M.grabbed_by)
					qdel(G)
			SPAWN (1.5 SECONDS)
				if (M)
					qdel(M)


/datum/tutorialStep/newbee/intent_grab
	name = "Grab Intent"
	instructions = "The <span style='color:#FF6A00; font-weight:bold'>Grab</span> intent will grab someone.<br>Press <b>3</b> to switch to the <span style='color:#FF6A00; font-weight:bold'>Grab</span> intent."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_INTENTS
	highlight_hud_element = "intent"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INTENT_GRAB
	step_area = /area/tutorial/newbee/room_4

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		var/grab = src.keymap.action_to_keybind("grab") || "3"
		src.instructions = "The <span style='color:#FF6A00; font-weight:bold'>Grab</span> intent will grab someone.<br>Press <b>[grab]</b> to switch to the <span style='color:#FF6A00; font-weight:bold'>Grab</span> intent."

	SetUp()
		. = ..()
		if (src.newbee_tutorial.newbee.intent == INTENT_GRAB)
			src.newbee_tutorial.newbee.set_a_intent(INTENT_DISARM)
		RegisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_SET_A_INTENT, PROC_REF(check_intent))

	proc/check_intent(datum/source, intent)
		if (intent == INTENT_GRAB)
			src.tutorial.PerformAction("set_a_intent", intent)

	PerformAction(action, context)
		. = ..()
		if (action == "set_a_intent" && context == INTENT_GRAB)
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_SET_A_INTENT)

/obj/landmark/newbee/grab_person
	name = LANDMARK_TUTORIAL_NEWBEE_GRAB_PERSON
	icon = 'icons/map-editing/job_start.dmi'
	icon_state = "clown"

/datum/tutorialStep/newbee/grab_person
	name = "Grabbing People"
	instructions = "<b>Click</b> the clown while on <span style='color:#FF6A00; font-weight:bold'>Grab</span> intent. <b>Click</b> them again or press <b>C</b>to grip tighter.<br>Get the clown in an aggressive grab."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_INTENTS
	highlight_hud_element = "intent"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INTENT_GRAB
	step_area = /area/tutorial/newbee/room_4

	var/mob/living/carbon/human/normal/tutorial_grab/target_mob

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		var/attackself = src.keymap.action_to_keybind("attackself") || "C"
		src.instructions = "<b>Click</b> the clown while on <span style='color:#FF6A00; font-weight:bold'>Grab</span> intent. <b>Click</b> them again or press <b>[attackself]</b> to grip tighter.<br>Get the clown in an aggressive grab."

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_GRAB_PERSON])
			if(src.region.turf_in_region(T))
				if (src.target_mob)
					src.target_mob.set_loc(T)
				else
					src.target_mob = new(T)
				break
		src.target_mob.UpdateOverlays(src.point_marker, "marker")
		RegisterSignal(src.target_mob, COMSIG_MOB_GRABBED, PROC_REF(check_mob_grabbed))

	proc/check_mob_grabbed(source, obj/item/grab/grab)
		if (grab.state >= GRAB_AGGRESSIVE)
			src.tutorial.PerformAction("mob_grabbed", "grab_clown")

	PerformAction(action, context)
		. = ..()
		if (action == "mob_grabbed" && context == "grab_clown")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (!src.target_mob)
			return
		src.target_mob.UpdateOverlays(null, "marker")
		UnregisterSignal(src.target_mob, COMSIG_MOB_GRABBED)
		var/mob/M = src.target_mob
		src.target_mob = null
		SPAWN(4 SECONDS)
			animate_teleport(M)
			showswirl_out(M)
			if (length(M.grabbed_by))
				for(var/obj/item/grab/G in M.grabbed_by)
					qdel(G)
			SPAWN (1.5 SECONDS)
				if (M)
					qdel(M)

/datum/tutorialStep/newbee/intent_harm
	name = "Harm Intent"
	instructions = "The <span style='color:#B51214; font-weight:bold'>Harm</span> intent will attack people by punching them or hitting them with items.<br>Press <b>4</b> to switch to the <span style='color:#B51214; font-weight:bold'>Harm</span> intent."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_INTENTS
	highlight_hud_element = "intent"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INTENT_HARM
	step_area = /area/tutorial/newbee/room_4

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		var/harm = src.keymap.action_to_keybind("harm") || "4"
		src.instructions = "The <span style='color:#B51214; font-weight:bold'>Harm</span> intent will attack people by punching them or hitting them with items.<br>Press <b>[harm]</b> to switch to the <span style='color:#B51214; font-weight:bold'>Harm</span> intent."

	SetUp()
		. = ..()
		if (src.newbee_tutorial.newbee.intent == INTENT_HARM)
			src.newbee_tutorial.newbee.set_a_intent(INTENT_GRAB)
		RegisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_SET_A_INTENT, PROC_REF(check_intent))

	proc/check_intent(datum/source, intent)
		if (intent == INTENT_HARM)
			src.tutorial.PerformAction("set_a_intent", intent)

	PerformAction(action, context)
		. = ..()
		if (action == "set_a_intent" && context == INTENT_HARM)
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_SET_A_INTENT)

/obj/landmark/newbee/mouse
	name = LANDMARK_TUTORIAL_NEWBEE_MOUSE
	icon = 'icons/misc/critter.dmi'
	icon_state = "mouse_white"

/datum/tutorialStep/newbee/basic_combat
	name = "Basic Combat"
	instructions = "Oh no! Attack of the angry mouse!<br>Defeat the mouse by <b>clicking</b> on them while using the <span style='color:#B51214; font-weight:bold'>Harm</span> intent."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_INTENTS
	highlight_hud_element = "intent"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INTENT_HARM
	step_area = /area/tutorial/newbee/room_4

	var/mob/living/critter/small_animal/mouse/mad/target_mob

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_MOUSE])
			if(src.region.turf_in_region(T))
				if (src.target_mob && isalive(src.target_mob))
					src.target_mob.set_loc(T)
				else
					src.target_mob = new(T)
				break
		RegisterSignal(src.target_mob, COMSIG_MOB_DEATH, PROC_REF(check_mob_death))
		src.target_mob.UpdateOverlays(src.point_marker, "marker")

	proc/check_mob_death()
		if (isdead(src.target_mob))
			src.tutorial.PerformAction("mob_death", "mouse")

	PerformAction(action, context)
		. = ..()
		if (action == "mob_death" && context == "mouse")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (!src.target_mob)
			return
		src.target_mob.UpdateOverlays(null, "marker")
		UnregisterSignal(src.target_mob, COMSIG_MOB_DEATH)
		var/mob/M = src.target_mob
		src.target_mob = null
		SPAWN(4 SECONDS)
			animate_teleport(M)
			showswirl_out(M)
			if (length(M.grabbed_by))
				for(var/obj/item/grab/G in M.grabbed_by)
					qdel(G)
			SPAWN (1.5 SECONDS)
				if (M)
					qdel(M)

/obj/landmark/newbee/get_health
	name = LANDMARK_TUTORIAL_NEWBEE_GET_HEALTH
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/exit_intents
	name = "Healing Up"
	instructions = "Your health is displayed in the top-right corner. As you can see, you've taken some damage.<br>Head into the next room to patch yourself up."
	highlight_hud_element = "health"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY
	step_area = /area/tutorial/newbee/room_4
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_GET_HEALTH

	SetUp()
		. = ..()
		if (src.newbee_tutorial.newbee.bruteloss < 5)
			src.newbee_tutorial.newbee.TakeDamage("All", 5)

//
// room 5 - Healing
//

/obj/landmark/newbee/pickup_first_aid
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_FIRST_AID
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "brute1"

/datum/tutorialStep/newbee/item_pickup/first_aid
	name = "First Aid Kits"
	instructions = "You can heal yourself by using supplies from first aid kits.<br><b>Click</b> the first aid kit to pick it up."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	highlight_hud_element = "health"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY
	step_area = /area/tutorial/newbee/room_5

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_FIRST_AID
	item_path = /obj/item/storage/firstaid/brute/tutorial

/datum/tutorialStep/newbee/storage_inhands
	name = "Opening Storage"
	instructions = "With the first aid kit in-hand, press <b>C</b> to open it."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	highlight_hud_element = "health"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY
	needed_item_path = /obj/item/storage/firstaid/brute/tutorial
	step_area = /area/tutorial/newbee/room_5

	New()
		. = ..()
		var/attackself = src.keymap.action_to_keybind("attackself") || "C"
		src.instructions = "With the first aid kit in-hand, press <b>[attackself]</b> to open it."

	PerformAction(action, context)
		. = ..()
		if (action == "open_storage" && context == "first_aid")
			src.finished = TRUE

/datum/tutorialStep/newbee/hand_swap
	name = "Swapping Hands"
	instructions = "Only one hand can be active at a time. You need an open hand to take items from storage.<br>Press <b>E</b> to swap to your open hand."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	highlight_hud_element = "health"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY
	needed_item_path = /obj/item/storage/firstaid/brute/tutorial
	step_area = /area/tutorial/newbee/room_5

	New()
		. = ..()
		var/swaphand = src.keymap.action_to_keybind("swaphand") || "E"
		src.instructions = "Only one hand can be active at a time. You need an open hand to take items from storage.<br>Press <b>[swaphand]</b> to swap to your open hand."

	SetUp()
		. = ..()
		RegisterSignal(src._needed_item, COMSIG_ITEM_SWAP_AWAY, PROC_REF(check_swap))

	proc/check_swap()
		src.tutorial.PerformAction("swapped-hands")

	PerformAction(action, context)
		. = ..()
		if (action == "swapped-hands")
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src._needed_item, COMSIG_ITEM_SWAP_AWAY)

/datum/tutorialStep/newbee/apply_patch
	name = "Applying Patches"
	instructions = "Grab a patch out of the first aid kit, and apply it by <b>clicking</b> yourself.<br>You can also press <b>C</b> to self-apply the patch."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	highlight_hud_element = "health"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY
	step_area = /area/tutorial/newbee/room_5

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		var/attackself = src.keymap.action_to_keybind("attackself") || "C"
		src.instructions = "Grab a patch out of the first aid kit, and apply it by <b>clicking</b> yourself.<br>You can also press <b>[attackself]</b> to self-apply the patch."

	SetUp()
		. = ..()
		RegisterSignal(src.newbee_tutorial.newbee, COMSIG_ATTACKBY, PROC_REF(check_attackby))

	proc/check_attackby(source, obj/item/I, mob/user, params, is_special)
		if (istype(I, /obj/item/reagent_containers/patch))
			src.tutorial.PerformAction("attackby", "patch")

	PerformAction(action, context)
		. = ..()
		if (action == "attackby" && context == "patch")
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src.newbee_tutorial.newbee, COMSIG_ATTACKBY)

/obj/landmark/newbee/exit_healing
	name = LANDMARK_TUTORIAL_NEWBEE_EXIT_HEALING
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/exit_healing
	name = "All Better!"
	instructions = "Now that you're patched up, let's learn some deconstruction.<br>Head into the next room."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_EXIT_HEALING
	step_area = /area/tutorial/newbee/room_5
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

//
// room 6 - Girder Deconstruction
//

/obj/landmark/newbee/decon_girder
	name = LANDMARK_TUTORIAL_NEWBEE_DECON_GIRDER
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/examining
	name = "Taking a Closer Look"
	instructions = "Examine things by holding <b>ALT</b> and <b>clicking</b> them. Text in blue boxes are hints.<br>Examine the girder to find out how to deconstruct it."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_MODIFIERS
	step_area = /area/tutorial/newbee/room_6

	var/obj/structure/girder/target_girder

	SetUp()
		. = ..()
		var/turf/target_turf
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_DECON_GIRDER])
			if(src.region.turf_in_region(T))
				target_turf = T
				break
		src.target_girder = locate(/obj/structure/girder) in target_turf
		if (!src.target_girder)
			src.target_girder = new(target_turf)

		src.target_girder.UpdateOverlays(src.point_marker, "marker")
		RegisterSignal(src.target_girder, COMSIG_ATOM_EXAMINE, PROC_REF(check_examine))

	proc/check_examine(mob/owner, mob/examiner, list/lines)
		src.tutorial.PerformSilentAction("examine", "girder")

	PerformAction(action, context)
		. = ..()
		if (action == "examine" && context == "girder")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (src.target_girder)
			UnregisterSignal(src.target_girder, COMSIG_ATOM_EXAMINE)
			src.target_girder.UpdateOverlays(null, "marker")

/obj/landmark/newbee/pickup_toolbox
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_TOOLBOX
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "blue"

/datum/tutorialStep/newbee/item_pickup/toolbox
	name = "Toolboxes"
	instructions = "Toolboxes contain up to 7 small objects. This one has a set of tools.<br><b>Click</b> the toolbox to pick it up, then press <b>C</b> to open it."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_6

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_TOOLBOX
	item_path = /obj/item/storage/toolbox/tutorial

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		var/attackself = src.keymap.action_to_keybind("attackself") || "C"
		src.instructions = "Toolboxes contain up to 7 small objects. This one has a set of tools.<br><b>Click</b> the toolbox to pick it up, then press <b>[attackself]</b> to open it."

	SetUp()
		. = ..()
		if (istype(src._target_item, /obj/item/storage/toolbox/tutorial))
			var/obj/item/storage/toolbox/tutorial/tutorial_box = src._target_item
			for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_PICKUP_TOOLBOX])
				if(src.region.turf_in_region(T))
					tutorial_box.reset(T)
					break

/datum/tutorialStep/newbee/move_to/deconstructing_girder
	name = "Deconstructing a Girder"
	instructions = "To deconstruct the girder, you need a wrench from the toolbox.<br><b>Click</b> the girder with a wrench, then head into the next room."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_6
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_DECON_GIRDER
	targeting_type = NEWBEE_TUTORIAL_MARKER_TARGET_POINT

	SetUp()
		. = ..()
		var/turf/target_turf
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_DECON_GIRDER])
			if(src.region.turf_in_region(T))
				target_turf = T
				break

		var/obj/structure/girder/target_girder = locate(/obj/structure/girder) in target_turf
		if (!target_girder)
			new /obj/structure/girder(target_turf)

//
// room 7 - Active Items
//

/obj/landmark/newbee/pickup_flashlight
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_FLASHLIGHT
	icon = 'icons/obj/items/device.dmi'
	icon_state = "flight0"

/datum/tutorialStep/newbee/item_pickup/flashlight
	name = "Exploring Darkness"
	instructions = "The next area has no lights.<br>Pick up the flashlight to help you navigate."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_7

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_FLASHLIGHT
	item_path = /obj/item/device/light/flashlight/tutorial

/datum/tutorialStep/newbee/activating_items
	name = "Activating Items"
	instructions = "Some items do something when used in-hand.<br>Press <b>C</b> to activate the flashlight."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_7

	New()
		. = ..()
		var/attackself = src.keymap.action_to_keybind("attackself") || "C"
		src.instructions = "Some items do something when used in-hand.<Br>Press <b>[attackself]</b> to activate the flashlight."

	PerformAction(action, context)
		. = ..() // custom item sends action
		if (action == "use_item" && context == "flashlight")
			src.finished = TRUE

/obj/landmark/newbee/enter_maints
	name = LANDMARK_TUTORIAL_NEWBEE_ENTER_MAINTS
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/enter_maints
	name = "Maintenance"
	instructions = "Enter the maintenance tunnel. Don't dawdle..."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_MOVEMENT
	step_area = /area/tutorial/newbee/room_7
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_ENTER_MAINTS

//
// room 8 - Dark Areas
//

/obj/landmark/newbee/traverse_maints
	name = LANDMARK_TUTORIAL_NEWBEE_TRAVERSE_MAINTS
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/traversing_maints
	name = "Traversing Maintenance"
	instructions = "Head through the maintenance tunnel to get to the next area."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_MOVEMENT
	step_area = /area/tutorial/newbee/room_8
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_TRAVERSE_MAINTS

//
// room 9 - Space Prep
//

/obj/landmark/newbee/emergency_supply_closet
	name = LANDMARK_TUTORIAL_NEWBEE_EMERGENCY_SUPPLY_CLOSET
	icon = 'icons/obj/large_storage.dmi'
	icon_state = "emergency"

/datum/tutorialStep/newbee/opening_closets
	name = "Emergency Closets"
	instructions = "Closets contain specialized gear.<br>Open the emergency supply closet by <b>clicking</b> on it."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_9

	var/obj/storage/closet/emergency_tutorial/target_closet

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_EMERGENCY_SUPPLY_CLOSET])
			if(src.region.turf_in_region(T))
				if (src.target_closet)
					src.target_closet.reset(T)
				else
					src.target_closet = new(T)
				break
		src.newbee_tutorial.newbee.hud.show_inventory = TRUE
		src.newbee_tutorial.newbee.hud.update_inventory()

	PerformAction(action, context)
		. = ..()
		if (action == "open_storage" && context == "emergency_tutorial")
			src.finished = TRUE

/datum/tutorialStep/newbee/equip_space_suit
	name = "Space Suits"
	instructions = "Space suits help protect against the vacuum of space.<br><b>Click</b> to pick up the emergency suit and press <b>V</b> to equip it."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	highlight_hud_element = "suit"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY
	step_area = /area/tutorial/newbee/room_9

	New()
		. = ..()
		var/equip = src.keymap.action_to_keybind("equip") || "V"
		src.instructions = "Space suits help protect against the vacuum of space.<br><b>Click</b> the emergency suit and press <b>[equip]</b> to equip it."

	PerformAction(action, context)
		. = ..()
		if (action == "item_equipped" && istype(context, /obj/item/clothing/suit/space/emerg))
			src.finished = TRUE


/datum/tutorialStep/newbee/equip_breath_mask
	name = "Breath Masks"
	instructions = "A breath mask is required to use an air tank.<br><b>Click</b> the breath mask and press <b>V</b> to equip it."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	highlight_hud_element = "mask"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY
	step_area = /area/tutorial/newbee/room_9

	New()
		. = ..()
		var/equip = src.keymap.action_to_keybind("equip") || "V"
		src.instructions = "A breath mask is required to use an air tank.<br><b>Click</b> the breath mask and press <b>[equip]</b> to equip it."

	PerformAction(action, context)
		. = ..()
		if (action == "item_equipped" && istype(context, /obj/item/clothing/mask/breath))
			src.finished = TRUE

/datum/tutorialStep/newbee/equip_space_helmet
	name = "Space Helmets"
	instructions = "Space helmets complete your ability to survive the cold of space.<br><b>Click</b> the emergency hood and press <b>V</b> to equip it."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	highlight_hud_element = "head"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY
	step_area = /area/tutorial/newbee/room_9

	New()
		. = ..()
		var/equip = src.keymap.action_to_keybind("equip") || "V"
		src.instructions = "Space helmets complete your ability to survive the cold of space.<br><b>Click</b> the emergency hood and press <b>[equip]</b> to equip it."

	PerformAction(action, context)
		. = ..()
		if (action == "item_equipped" && istype(context, /obj/item/clothing/head/emerg))
			src.finished = TRUE

/datum/tutorialStep/newbee/oxygen
	name = "Oxygen Required"
	instructions = "You need oxygen to breathe in areas without air, like space.<br><b>Click</b> the oxygen tank to pick it up."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_9

	PerformAction(action, context)
		. = ..()
		if (action == "item_pickup" && istype(context, /obj/item/tank/oxygen))
			src.finished = TRUE

/datum/tutorialStep/newbee/internals
	name = "Using Internals"
	instructions = "Make sure you are breathing from your oxygen tank before heading into space.<br><b>Click</b> the 'Toggle Tank Valve' button in the top-left corner to turn on your internals."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	needed_item_path = /obj/item/tank/oxygen/tutorial
	step_area = /area/tutorial/newbee/room_9

	SetUp()
		. = ..()
		for(var/obj/ability_button/tank_valve_toggle/tank_ability in src._needed_item.ability_buttons)
			tank_ability.UpdateOverlays(src.inventory_marker, "marker")

	PerformAction(action, context)
		. = ..()
		if (action == "action_button" && context == "internals")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (src._needed_item)
			for(var/obj/ability_button/tank_valve_toggle/tank_ability in src._needed_item.ability_buttons)
				tank_ability.UpdateOverlays(null, "marker")

/obj/landmark/newbee/enter_space
	name = LANDMARK_TUTORIAL_NEWBEE_ENTER_SPACE
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/enter_space
	name = "Entering Space"
	instructions = "With your suit on and internals set, you're ready to go into space.<br>Head through the airlock!"
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_MOVEMENT
	step_area = /area/tutorial/newbee/room_9
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_ENTER_SPACE

//
// room 10 - Space Traversal
//

/obj/landmark/newbee/traverse_space
	name = LANDMARK_TUTORIAL_NEWBEE_TRAVERSE_SPACE
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/traversing_space
	name = "Traversing Space"
	instructions = "You slowly float in space without solid ground under you.<br>Drift to the airlock on the other side."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_MOVEMENT
	step_area = /area/tutorial/newbee/room_10
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_TRAVERSE_SPACE

//
// room 11 - Storage
//

/obj/landmark/newbee/pickup_backpack
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_BACKPACK
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "backpack"

/datum/tutorialStep/newbee/item_pickup/backpack
	name = "Backpack Storage"
	instructions = "Backpacks allow you to store items for later use.<br><b>Click</b> the backpack with an empty hand to pick it up."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_11

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_BACKPACK
	item_path = /obj/item/storage/backpack/empty

/datum/tutorialStep/newbee/equip_backpack
	name = "Wearing a Backpack"
	instructions = "Backpacks can be worn on your back.<br>Equip the backpack with <b>V</b> or <b>click</b> the back slot in your HUD."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	highlight_hud_element = "back"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY
	needed_item_path = /obj/item/storage/backpack/empty
	step_area = /area/tutorial/newbee/room_11

	New()
		. = ..()
		var/equip = src.keymap.action_to_keybind("equip") || "V"
		src.instructions = "Backpacks can be worn on your back.<br>Equip the backpack with <b>[equip]</b> or <b>click</b> the back slot in your HUD."

	SetUp()
		. = ..()
		RegisterSignal(src._needed_item, COMSIG_ITEM_EQUIPPED, PROC_REF(check_item_equipped))

	proc/check_item_equipped(datum/source, mob/equipper, slot)
		src.tutorial.PerformSilentAction("item_equipped", "backpack")

	PerformAction(action, context)
		. = ..()
		if (action == "item_equipped" && context == "backpack")
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src._needed_item, COMSIG_ITEM_EQUIPPED)

/datum/tutorialStep/newbee/unequipping_worn_items
	name = "Storing Items"
	instructions = "Space suits slow you down on solid ground. You can keep the gear in your backpack, instead.<br><b>Click</b> a piece of space gear to take it off, and then <b>click</b> your backpack to store it."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_11

	var/atom/movable/screen/hud/head_hud
	var/atom/movable/screen/hud/suit_hud
	var/atom/movable/screen/hud/mask_hud

	var/obj/item/clothing/head/worn_head
	var/obj/item/clothing/suit/worn_suit
	var/obj/item/clothing/mask/worn_mask

	SetUp()
		. = ..()
		src.worn_head = src.newbee_tutorial.newbee.head
		if (!src.worn_head)
			src.worn_head = new /obj/item/clothing/head/emerg(get_turf(src.newbee_tutorial.newbee))
			src.newbee_tutorial.newbee.equip_if_possible(src.worn_head)
		if (src.worn_head)
			src.worn_head.UpdateOverlays(src.point_marker, "marker")
			for (var/atom/movable/screen/hud/hud_element in src.newbee_tutorial.newbee.hud.objects)
				if (hud_element.id == "head")
					src.head_hud = hud_element
					break

		src.worn_suit = src.newbee_tutorial.newbee.wear_suit
		if (!src.worn_suit)
			src.worn_suit = new /obj/item/clothing/suit/space/emerg(get_turf(src.newbee_tutorial.newbee))
			src.newbee_tutorial.newbee.equip_if_possible(src.worn_suit)
		if (src.worn_suit)
			src.worn_suit.UpdateOverlays(src.point_marker, "marker")
			for (var/atom/movable/screen/hud/hud_element in src.newbee_tutorial.newbee.hud.objects)
				if (hud_element.id == "suit")
					src.suit_hud = hud_element
					break

		src.worn_mask = src.newbee_tutorial.newbee.wear_mask
		if (!src.worn_mask)
			src.worn_mask = new /obj/item/clothing/mask/breath(get_turf(src.newbee_tutorial.newbee))
			src.newbee_tutorial.newbee.equip_if_possible(src.worn_mask)
		if (src.worn_mask)
			src.worn_mask.UpdateOverlays(src.point_marker, "marker")
			for (var/atom/movable/screen/hud/hud_element in src.newbee_tutorial.newbee.hud.objects)
				if (hud_element.id == "mask")
					src.mask_hud = hud_element
					break

		if (src.head_hud)
			src.head_hud.UpdateOverlays(src.inventory_marker, "marker")
		if (src.suit_hud)
			src.suit_hud.UpdateOverlays(src.inventory_marker, "marker")
		if (src.mask_hud)
			src.mask_hud.UpdateOverlays(src.inventory_marker, "marker")

	PerformAction(action, context)
		. = ..()
		if (action == "item_unequipped")
			if (context == src.worn_head)
				if (src.head_hud)
					src.head_hud.UpdateOverlays(null, "marker")
					src.head_hud = null
				src.worn_head.UpdateOverlays(null, "marker")
				src.worn_head = null
			else if (context == src.worn_suit)
				if (src.suit_hud)
					src.suit_hud.UpdateOverlays(null, "marker")
					src.suit_hud = null
				src.worn_suit.UpdateOverlays(null, "marker")
				src.worn_suit = null
			else if (context == src.worn_mask)
				if (src.mask_hud)
					src.mask_hud.UpdateOverlays(null, "marker")
					src.mask_hud = null
				src.worn_mask.UpdateOverlays(null, "marker")
				src.worn_mask = null

		if (isnull(src.worn_head) && isnull(src.worn_suit) && isnull(src.worn_mask))
			src.finished = TRUE

	TearDown()
		. = ..()
		if (src.worn_head)
			src.worn_head.UpdateOverlays(null, "marker")
			src.worn_head = null
		if (src.worn_suit)
			src.worn_suit.UpdateOverlays(null, "marker")
			src.worn_suit = null
		if (src.worn_mask)
			src.worn_mask.UpdateOverlays(null, "marker")
			src.worn_mask = null
		if (src.head_hud)
			src.head_hud.UpdateOverlays(null, "marker")
			src.head_hud = null
		if (src.suit_hud)
			src.suit_hud.UpdateOverlays(null, "marker")
			src.suit_hud = null
		if (src.mask_hud)
			src.mask_hud.UpdateOverlays(null, "marker")
			src.mask_hud = null

/obj/landmark/newbee/exit_storage
	name = LANDMARK_TUTORIAL_NEWBEE_EXIT_STORAGE
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/exit_storage
	name = "Backpack Storage"
	instructions = "You can <b>Click</b> on your backpack to open it. Backpacks can store 7 normal-sized objects.<br>Head into the next room."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_11
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_EXIT_STORAGE

//
// room 12 - Wall Deconstruction
//

/obj/landmark/newbee/pickup_welding_mask
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_WELDING_MASK
	icon = 'icons/obj/clothing/item_hats.dmi'
	icon_state = "welding"

/datum/tutorialStep/newbee/item_pickup/welding_mask
	name = "Space OSHA Reminder"
	instructions = "Welding without proper eyewear is a bad idea!<br><b>Click</b> the welding mask to pick it up."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_12

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_WELDING_MASK
	item_path = /obj/item/clothing/head/helmet/welding/tutorial

	SetUp()
		. = ..()
		if (istype(src._target_item, /obj/item/clothing/head/helmet/welding/tutorial))
			var/obj/item/clothing/head/helmet/welding/tutorial/welding_mask = src._target_item
			welding_mask.flip_up(silent=TRUE)
			for(var/obj/ability_button/mask_toggle/toggle in welding_mask.ability_buttons)
				toggle.icon_state = "welddown" // manually set the ability button state

/datum/tutorialStep/newbee/equip_welding_mask
	name = "Welding Masks"
	instructions = "You need to wear the welding mask before it will protect your eyes.<br>Equip the welding mask with <b>V</b> or by <b>clicking</b> the head slot in your HUD."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	highlight_hud_element = "head"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY
	needed_item_path = /obj/item/clothing/head/helmet/welding/tutorial
	step_area = /area/tutorial/newbee/room_12

	New()
		. = ..()
		var/equip = src.keymap.action_to_keybind("equip") || "V"
		src.instructions = "You need to wear the welding mask before it will protect your eyes.<br>Equip the welding mask with <b>[equip]</b> or by <b>clicking</b> the head slot in your HUD."

	SetUp()
		. = ..()
		RegisterSignal(src._needed_item, COMSIG_ITEM_EQUIPPED, PROC_REF(check_item_equipped))

	proc/check_item_equipped(datum/source, mob/equipper, slot)
		src.tutorial.PerformSilentAction("item_equipped", "welding_mask")

	PerformAction(action, context)
		. = ..()
		if (action == "item_equipped" && context == "welding_mask")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (src._needed_item)
			UnregisterSignal(src._needed_item, COMSIG_ITEM_EQUIPPED)

/datum/tutorialStep/newbee/flip_welding_mask_down
	name = "Eye Protection"
	instructions = "Flipping a welding mask down will protect your eyes, but obscure your sight.<br><b>Click</b> the icon in the top-left corner to lower the mask."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	needed_item_path = /obj/item/clothing/head/helmet/welding/tutorial
	step_area = /area/tutorial/newbee/room_12

	SetUp()
		. = ..()
		for(var/obj/ability_button/mask_toggle/toggle in src._needed_item.ability_buttons)
			toggle.UpdateOverlays(src.inventory_marker, "marker")

	PerformAction(action, context)
		. = ..()
		if (action == "welding_mask" && context == "flip_down")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (src._needed_item)
			for(var/obj/ability_button/mask_toggle/toggle in src._needed_item.ability_buttons)
				toggle.UpdateOverlays(null, "marker")

/obj/landmark/newbee/pickup_weldingtool
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_WELDINGTOOL
	icon = 'icons/obj/items/tools/weldingtool.dmi'
	icon_state = "weldingtool-off"

/datum/tutorialStep/newbee/item_pickup/weldingtool
	name = "Welding Tools"
	instructions = "Deconstructing walls requires a welding tool.<br><b>Click</b> the welding tool to pick it up."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_12

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_WELDINGTOOL
	item_path = /obj/item/weldingtool/tutorial

/datum/tutorialStep/newbee/using_welder
	name = "Using Welding Tools"
	instructions = "Welding tools can be used in-hand to light them. Lit welding tools slowly use up fuel.<br>Turn on the welding tool with <b>C</b>."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	needed_item_path = /obj/item/weldingtool/tutorial
	step_area = /area/tutorial/newbee/room_12

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		var/attackself = src.keymap.action_to_keybind("attackself") || "C"
		src.instructions = "Welding tools can be used in-hand to light them. Lit welding tools slowly use up fuel.<br>Turn on the welding tool with <b>[attackself]</b>."

	PerformAction(action, context)
		. = ..()
		if (action == "use_item" && context == "weldingtool")
			src.finished = TRUE

/obj/landmark/newbee/decon_wall
	name = LANDMARK_TUTORIAL_NEWBEE_DECON_WALL
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/decon_wall
	name = "Deconstructing a Wall"
	instructions = "Regular walls can be deconstructed with lit welding tools.<br><b>Click</b> the wall with the lit welding tool and wait for the action bar to finish."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	needed_item_path = /obj/item/weldingtool/tutorial
	step_area = /area/tutorial/newbee/room_12

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_DECON_WALL
	targeting_type = NEWBEE_TUTORIAL_MARKER_TARGET_POINT

	SetUp()
		. = ..()
		if (!istype(src._target_destination, /turf/simulated/wall/auto/supernorn))
			src._target_destination.ReplaceWith(/turf/simulated/wall/auto/supernorn)

		var/obj/structure/girder/girder = locate(/obj/structure/girder) in src._target_destination
		if (istype(girder))
			qdel(girder)

		RegisterSignal(src._target_destination, COMSIG_TURF_REPLACED, PROC_REF(check_turf_replaced))

	proc/check_turf_replaced(turf/replaced, turf/new_turf)
		src.tutorial.PerformSilentAction("turf_replaced")

	PerformAction(action, context)
		. = ..()
		if (action == "turf_replaced")
			src.finished = TRUE

	TearDown()
		UnregisterSignal(src._target_destination, COMSIG_TURF_REPLACED)
		. = ..()

/datum/tutorialStep/newbee/flip_welding_mask_up
	name = "Lift the Veil"
	instructions = "With the welding done, flip the welding mask back up to see better.<br><b>Click</b> the icon in the top-left corner to raise the mask."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	needed_item_path = /obj/item/clothing/head/helmet/welding/tutorial
	step_area = /area/tutorial/newbee/room_12

	SetUp()
		. = ..()
		for(var/obj/ability_button/mask_toggle/toggle in src._needed_item.ability_buttons)
			toggle.UpdateOverlays(src.inventory_marker, "marker")

	PerformAction(action, context)
		. = ..()
		if (action == "welding_mask" && context == "flip_up")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (src._needed_item)
			for(var/obj/ability_button/mask_toggle/toggle in src._needed_item.ability_buttons)
				toggle.UpdateOverlays(null, "marker")

/datum/tutorialStep/newbee/move_to/decon_wall_girder
	name = "Removing the Girder"
	instructions = "With the wall sliced open, all that remains is a girder.<br>Remove the girder with a wrench, and then proceed into the next room."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_12
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_DECON_WALL
	targeting_type = NEWBEE_TUTORIAL_MARKER_TARGET_POINT

//
// room 13 - Advanced Movement
//

/obj/landmark/newbee/laying_down
	name = LANDMARK_TUTORIAL_NEWBEE_LAYING_DOWN
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/laying_down
	name = "Laying Down"
	instructions = "Laying down drops all items in your hands and lets you pass under some objects.<br>Press <b>=</b> or <b>click</b> the REST button in the HUD to crawl under the flaps."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ACTIONS
	highlight_hud_element = "rest"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_STAND
	step_area = /area/tutorial/newbee/room_13

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_LAYING_DOWN

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		var/rest = src.keymap.action_to_keybind("rest") || "="
		src.instructions = "Laying down drops all items in your hands and lets you pass under some objects.<br>Press <b>[rest]</b> or <b>click</b> the REST button in the HUD to crawl under the flaps."

/obj/landmark/newbee/sprinting
	name = LANDMARK_TUTORIAL_NEWBEE_SPRINTING
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/sprinting
	name = "Sprinting"
	instructions = "Sprint to move faster. Sprinting takes stamina, displayed in the top-right corner.<br>Hold <b>SHIFT</b> to sprint across the conveyors."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ACTIONS
	highlight_hud_element = "stamina"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY
	step_area = /area/tutorial/newbee/room_13

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_SPRINTING

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		var/sprint = src.keymap.action_to_keybind(KEY_RUN) || "SHIFT"
		src.instructions = "Sprint to move faster. Sprinting takes stamina, displayed in the top-right corner.<br>Hold <b>[sprint]</b> to sprint across the conveyors."

	SetUp()
		. = ..()

	TearDown()
		. = ..()


/obj/landmark/newbee/exit_movement
	name = LANDMARK_TUTORIAL_NEWBEE_EXIT_MOVEMENT
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/exit_movement
	name = "Whoa, Careful!"
	instructions = "Some things on the ground can make you slip, like that banana peel!<br>Head into the next room."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ACTIONS
	step_area = /area/tutorial/newbee/room_13
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_EXIT_MOVEMENT

//
// room 14 - Talking / Radio
//

/datum/tutorialStep/newbee/say
	name = "Talking"
	instructions = "Talking is a great way to communicate with nearby crewmates!<br>Press <b>T</b> to open the talk dialog and press <b>ENTER</b> to say something."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_COMMUNICATION
	step_area = /area/tutorial/newbee/room_14

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		var/say = src.keymap.action_to_keybind("say") || "T"
		src.instructions = "Talking is a great way to communicate with nearby crewmates!<br>Press <b>[say]</b> to open the talk dialog and press <b>ENTER</b> to say something."

	SetUp()
		. = ..()
		RegisterSignal(src.newbee_tutorial.newbee, COMSIG_ATOM_SAY, PROC_REF(check_say))

	proc/check_say(source, datum/say_message/message)
		src.tutorial.PerformAction("atom_say", "say")

	PerformAction(action, context)
		. = ..()
		if (action == "atom_say" && context == "say")
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src.newbee_tutorial.newbee, COMSIG_ATOM_SAY)

/obj/landmark/newbee/pickup_headset
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_HEADSET
	icon = 'icons/obj/clothing/item_ears.dmi'
	icon_state = "headset"

/datum/tutorialStep/newbee/item_pickup/headset
	name = "Headsets"
	instructions = "Headsets let you speak over the radio to the entire station.<br><b>Click</b> the headset to pick it up."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_COMMUNICATION
	step_area = /area/tutorial/newbee/room_14

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_HEADSET
	item_path = /obj/item/device/radio/headset/tutorial

/datum/tutorialStep/newbee/equip_headset
	name = "Equipping Headsets"
	instructions = "Headsets go on your ear.<br>Equip the headset by pressing <b>V</b> or <b>clicking</b> the ear slot in your HUD."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_COMMUNICATION
	highlight_hud_element = "ears"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY
	needed_item_path = /obj/item/device/radio/headset/tutorial
	step_area = /area/tutorial/newbee/room_14

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		var/equip = src.keymap.action_to_keybind("equip") || "V"
		instructions = "Headsets go on your ear.<br>Equip the headset by pressing <b>[equip]</b> or <b>clicking</b> the ear slot in your HUD."

	SetUp()
		. = ..()
		RegisterSignal(src._needed_item, COMSIG_ITEM_EQUIPPED, PROC_REF(check_item_equipped))

	proc/check_item_equipped(datum/source, mob/equipper, slot)
		src.tutorial.PerformAction("item_equipped", "headset")

	PerformAction(action, context)
		. = ..()
		if (action == "item_equipped" && context == "headset")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (src._needed_item)
			UnregisterSignal(src._needed_item, COMSIG_ITEM_EQUIPPED)

/datum/tutorialStep/newbee/using_headset
	name = "Using the Radio"
	instructions = "Press <b>Y</b> to get a list of radio channels, and press <b>ENTER</b> to select one.<br>Say something over the radio to continue."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_COMMUNICATION
	needed_item_path = /obj/item/device/radio/headset/tutorial
	step_area = /area/tutorial/newbee/room_14

	New()
		. = ..()
		var/say_over_channel = src.keymap.action_to_keybind("say_over_channel") || "Y"
		src.instructions = "Press <b>[say_over_channel]</b> to get a list of radio channels, and press <b>ENTER</b> to select one.<br>Say something over the radio to continue."

	SetUp()
		. = ..()
		RegisterSignal(src.newbee_tutorial.newbee, COMSIG_ATOM_SAY, PROC_REF(check_say))

	proc/check_say(source, datum/say_message/message)
		if (message.prefix)
			src.tutorial.PerformAction("atom_say", "say")

	PerformAction(action, context)
		. = ..()
		if (action == "atom_say" && context == "say")
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src.newbee_tutorial.newbee, COMSIG_ATOM_SAY)

/obj/landmark/newbee/exit_radio
	name = LANDMARK_TUTORIAL_NEWBEE_EXIT_RADIO
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/exit_radio
	name = "Radio Channels"
	instructions = "Each department has their own dedicated radio channel.<br>Move into the next room to learn about pulling objects."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_COMMUNICATION
	step_area = /area/tutorial/newbee/room_14
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_EXIT_RADIO

//
// room 15 - hallway (Pulling)
//

/obj/landmark/newbee/water_tank
	name = LANDMARK_TUTORIAL_NEWBEE_WATER_TANK
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"

/datum/tutorialStep/newbee/pull_start
	name = "Pulling Objects"
	instructions = "You can pull objects (and people!) by holding <b>CTRL</b> and <b>clicking</b> them.<br>Start pulling the water tank."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_MODIFIERS
	highlight_hud_element = "pull"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_PULL
	step_area = /area/tutorial/newbee/room_15

	var/obj/reagent_dispensers/watertank/target_object

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		var/pull = src.keymap.action_to_keybind(KEY_PULL) || "CTRL"
		src.instructions = "You can pull objects (and people!) by holding <b>[pull]</b> and <b>clicking</b> them.<br>Start pulling the water tank."

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_WATER_TANK])
			if(src.region.turf_in_region(T))
				if(src.target_object)
					src.target_object.set_loc(T)
				else
					src.target_object = new(T)
				break
		src.target_object.UpdateOverlays(src.point_marker, "marker")

	PerformAction(action, context)
		. = ..()
		if (action == "set_pulling" && istype(context, /obj/reagent_dispensers/watertank))
			src.finished = TRUE

	TearDown()
		. = ..()
		src.target_object.UpdateOverlays(null, "marker")

/obj/landmark/newbee/pull_target
	name = LANDMARK_TUTORIAL_NEWBEE_PULL_TARGET
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/pull_target
	name = "Pull the Tank"
	instructions = "Walk to the previous room while pulling the water tank to move it out of your way.<br>Drag the water tank to the marker."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_MODIFIERS
	highlight_hud_element = "pull"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_PULL
	step_area = /area/tutorial/newbee/room_15

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PULL_TARGET

/datum/tutorialStep/newbee/pull_end
	name = "Stop Pulling"
	instructions = "Press <b>CTRL</b> and <b>click</b> far away to stop pulling the water tank.<br>You can also press the PULL button in your hud to stop pulling."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_MODIFIERS
	highlight_hud_element = "pull"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_PULL
	step_area = /area/tutorial/newbee/room_15

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		var/pull = src.keymap.action_to_keybind(KEY_PULL) || "CTRL"
		src.instructions = "Press <b>[pull]</b> and <b>click</b> far away to stop pulling the water tank.<br>You can also press the PULL button in your hud to stop pulling."


	PerformAction(action, context)
		. = ..()
		if (action == "remove_pulling" && istype(context, /obj/reagent_dispensers/watertank))
			src.finished = TRUE

/obj/landmark/newbee/final_room
	name = LANDMARK_TUTORIAL_NEWBEE_FINAL_ROOM
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/final_room
	name = "Almost Done!"
	instructions = "You're almost a fully functioning spacefarer! There's just one more thing to learn...<br>Head through the hallway into the final room."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_FINAL_ROOM
	step_area = /area/tutorial/newbee/room_15
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

//
// room 16 - escape (Advanced Combat)
//

/obj/landmark/newbee/clown_murder
	name = LANDMARK_TUTORIAL_NEWBEE_CLOWN_MURDER
	icon = 'icons/map-editing/job_start.dmi'
	icon_state = "clown"

/datum/tutorialStep/newbee/murder
	name = "Advanced Combat"
	instructions = "To activate the special attack of some items, <b>click</b> far away and use <span style='color:#EAC300; font-weight: bold'>Disarm</span> or <span style='color:#B51214; font-weight:bold'>Harm</span> intent.<br><span style='color:#962121; font-weight:bold'>Kill the clown</span> to complete the tutorial. Their robustness may surprise you!"
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_INTENTS
	step_area = /area/tutorial/newbee/room_16

	var/mob/living/carbon/human/normal/tutorial_kill/tutorial_clown

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_CLOWN_MURDER])
			if(src.region.turf_in_region(T))
				if (src.tutorial_clown)
					src.tutorial_clown.set_loc(T)
				else
					src.tutorial_clown = new(T)
				break
		src.tutorial_clown.tutorial_owner = src.newbee_tutorial.newbee
		RegisterSignal(src.tutorial_clown, COMSIG_MOB_DEATH, PROC_REF(check_mob_death))

	proc/check_mob_death()
		if (isdead(src.tutorial_clown))
			src.tutorial.PerformAction("mob_death", "clown")

	PerformAction(action, context)
		. = ..()
		if (action == "mob_death" && context == "clown")
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src.tutorial_clown, COMSIG_MOB_DEATH)
		if (src.tutorial_clown)
			src.tutorial_clown.gib()

/datum/tutorialStep/newbee/timer/following_rules
	name = "Server Rules"
	instructions = "The 'Rules' verb is located in the Commands tab above the chat top-right.<br>On the RP servers, the 'Rules - RP' verb is in the same tab.<br><b>Not knowing the rules isn't an excuse for breaking 'em!</b>"
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_META
	step_area = /area/tutorial/newbee/room_16

/datum/tutorialStep/newbee/timer/getting_help
	name = "Getting Help"
	instructions = "The <a href=\"https://wiki.ss13.co/\" style='color:#0099cc;text-decoration: underline;'>wiki</a> has detailed guides and information.<br>Ask our mentors gameplay questions in-game by pressing <b>F3</b>.<br>Ask our admins rules questions in-game by pressing <b>F1</b>."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_META
	step_area = /area/tutorial/newbee/room_16

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		var/adminhelp = src.keymap.action_to_keybind("adminhelp") || "F1"
		var/mentorhelp = src.keymap.action_to_keybind("mentorhelp") || "F3"
		src.instructions = "The <a href=\"https://wiki.ss13.co/\" style='color:#0099cc;text-decoration: underline;'>wiki</a> has detailed guides and information.<br>Ask our mentors gameplay questions in-game by pressing <b>[mentorhelp]</b>.<br>Ask our admins rules questions in-game by pressing <b>[adminhelp]</b>."

/datum/tutorialStep/newbee/timer/finished
	name = "Tutorial Complete!"
	instructions = "Congratulations on completing the basic tutorial!<br>There's more to learn and discover, but you can confidently take your first space-steps.<br>Returning to the main menu..."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_EMPTY
	step_area = /area/tutorial/newbee/room_16
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	SetUp()
		..()
		src.newbee_tutorial.newbee.unlock_medal("On My Own Two (Space) Legs")
		playsound(src.newbee_tutorial.newbee, pick(20;'sound/misc/openlootcrate.ogg',100;'sound/misc/openlootcrate2.ogg'), 60, 0)

//
// Tutorial UI Buttons
//

/datum/abilityHolder/newbee
	usesPoints = FALSE
	tabName = "Tutorial"
/datum/targetable/newbee
	icon = 'icons/mob/tutorial_ui.dmi'
	icon_state = "frame"
	targeted = 0
	do_logs = FALSE

/datum/targetable/newbee/exit
	name = "Exit Tutorial"
	desc = "Exit the tutorial and go to the main menu."
	icon_state = "exit"

	cast(atom/target)
		. = ..()
		var/confirm = tgui_alert(src.holder.owner, "Do you want to exit the tutorial?", "Leave Tutorial", list("Yes", "No"))
		if (confirm == "Yes")
			src.holder.owner.client?.tutorial?.Finish()

/datum/targetable/newbee/previous
	name = "Previous Step"
	desc = "Go back one step in the tutorial."
	icon_state = "previous"

	cast(atom/target)
		. = ..()
		var/datum/tutorial_base/regional/newbee/tutorial = src.holder.owner.client?.tutorial
		if (!istype(tutorial))
			return // ???
		if (tutorial.current_step <= 1)
			boutput(src.holder.owner, SPAN_ALERT("You're already at the first step!"))
			return
		var/datum/tutorialStep/newbee/current_step = tutorial.steps[tutorial.current_step]
		current_step.TearDown()
		tutorial.current_step -= 1
		var/datum/tutorialStep/newbee/previous_step = tutorial.steps[tutorial.current_step]
		tutorial.ShowStep()
		previous_step.SetUp(TRUE)

/datum/targetable/newbee/next
	name = "Next Step"
	desc = "Go forward one step in the tutorial."
	icon_state = "next"

	cast(atom/target)
		. = ..()
		src.holder.owner.client?.tutorial?.Advance(TRUE)

//
// tutorial mobs
//

/// Newbee Tutorial mob; no headset or PDA, does not spawn via jobs
/mob/living/carbon/human/tutorial
	New()
		..()
		src.equip_new_if_possible(/obj/item/clothing/under/rank/assistant, SLOT_W_UNIFORM)
		src.equip_new_if_possible(/obj/item/clothing/shoes/black, SLOT_SHOES)

	set_pulling(atom/movable/A)
		. = ..()
		if (src.client?.tutorial)
			src.client.tutorial.PerformSilentAction("set_pulling", A)

	remove_pulling()
		if (src.client?.tutorial)
			src.client.tutorial.PerformSilentAction("remove_pulling", src.pulling)
		. = ..()

	contract_disease()
		return // no

	gib(give_medal, include_ejectables)
		if (src.client?.tutorial)
			src.death(TRUE) // don't actually blow us up, thanks
		else
			. = ..(give_medal, include_ejectables)

	death(gibbed)
		if (src.client?.tutorial)
			var/datum/tutorial_base/regional/newbee/current_tutorial = src.client.tutorial
			for(var/turf/T in landmarks[current_tutorial.checkpoint_landmark])
				if(current_tutorial.region.turf_in_region(T))
					src.set_loc(T)
					showswirl(T)
					break

			src.full_heal()
			boutput(src, SPAN_ALERT("Whoa, you almost died! Let's try that again..."))
		else
			. = ..(gibbed)

/mob/living/carbon/human/normal/tutorial_help
	New()
		. = ..()
		src.real_name = "The Clown You Help"
		src.equip_new_if_possible(/obj/item/clothing/mask/clown_hat/blue, SLOT_WEAR_MASK)
		src.equip_new_if_possible(/obj/item/clothing/under/misc/clown/blue, SLOT_W_UNIFORM)
		src.equip_new_if_possible(/obj/item/clothing/shoes/clown_shoes/blue, SLOT_SHOES)
		var/obj/item/card/id/clown/clown_id = new()
		clown_id.registered = "The Clown You Help"
		clown_id.assignment = "Clown"
		clown_id.update_name()
		src.UpdateName()
		src.equip_if_possible(clown_id, SLOT_WEAR_ID)
		src.bioHolder?.AddEffect("accent_comic", innate = TRUE)

		SPAWN (0.3 SECONDS)
			src?.say("Owie! My funny bone is shattered!")

/mob/living/carbon/human/normal/tutorial_disarm
	New()
		. = ..()
		src.real_name = "The Clown You Disarm"
		src.equip_new_if_possible(/obj/item/clothing/mask/clown_hat/yellow, SLOT_WEAR_MASK)
		src.equip_new_if_possible(/obj/item/clothing/under/misc/clown/yellow, SLOT_W_UNIFORM)
		src.equip_new_if_possible(/obj/item/clothing/shoes/clown_shoes/yellow, SLOT_SHOES)
		src.equip_new_if_possible(/obj/item/instrument/bikehorn, SLOT_L_HAND)
		var/obj/item/card/id/clown/clown_id = new()
		clown_id.registered = "The Clown You Disarm"
		clown_id.assignment = "Clown"
		clown_id.update_name()
		src.UpdateName()
		src.equip_if_possible(clown_id, SLOT_WEAR_ID)
		src.bioHolder?.AddEffect("accent_comic", innate = TRUE)

		SPAWN (0.5 SECONDS)
			if (!QDELETED(src))
				src.say("We're gonna have a honkin' good time!")
		SPAWN (1 SECOND)
			if (!QDELETED(src))
				src.l_hand?.AttackSelf() // honk

/mob/living/carbon/human/normal/tutorial_grab
	New()
		. = ..()
		src.real_name = "The Clown You Grab"
		src.equip_new_if_possible(/obj/item/clothing/mask/clown_hat/purple, SLOT_WEAR_MASK)
		src.equip_new_if_possible(/obj/item/clothing/under/misc/clown/purple, SLOT_W_UNIFORM)
		src.equip_new_if_possible(/obj/item/clothing/shoes/clown_shoes/purple, SLOT_SHOES)
		var/obj/item/card/id/clown/clown_id = new()
		clown_id.registered = "The Clown You Grab"
		clown_id.assignment = "Clown"
		clown_id.update_name()
		src.UpdateName()
		src.equip_if_possible(clown_id, SLOT_WEAR_ID)
		src.bioHolder?.AddEffect("accent_comic", innate = TRUE)
		src.bioHolder?.AddEffect("sims_stinky", innate = TRUE)

		SPAWN (0.7 SECONDS)
			if (!QDELETED(src))
				src.say("Do I smell funny?")

/// Newbee Tutorial mob; the clown you kill to Win the Tutorial
/mob/living/carbon/human/normal/tutorial_kill
	/// Owner of the tutorial, assigned in the step that spawns this mob
	var/mob/tutorial_owner

	New()
		. = ..()
		src.real_name = "The Clown You Kill"
		src.equip_new_if_possible(/obj/item/clothing/mask/clown_hat, SLOT_WEAR_MASK)
		src.equip_new_if_possible(/obj/item/clothing/under/misc/clown, SLOT_W_UNIFORM)
		src.equip_new_if_possible(/obj/item/clothing/shoes/clown_shoes, SLOT_SHOES)
		src.equip_new_if_possible(/obj/item/storage/fanny/funny, SLOT_BELT)
		src.equip_new_if_possible(/obj/item/instrument/bikehorn, SLOT_L_HAND)
		src.equip_new_if_possible(/obj/item/bananapeel, SLOT_R_HAND)
		var/obj/item/card/id/clown/clown_id = new()
		clown_id.registered = "The Clown You Kill"
		clown_id.assignment = "Clown"
		clown_id.update_name()
		src.equip_if_possible(clown_id, SLOT_WEAR_ID)
		src.UpdateName()
		src.bioHolder?.AddEffect("accent_comic", innate = TRUE)
		src.AddComponent(/datum/component/health_maptext)

		SPAWN (0.2 SECONDS)
			if (!QDELETED(src))
				src.l_hand?.AttackSelf() // honk

		SPAWN (0.3 SECONDS)
			if (!QDELETED(src))
				src.say("Honk honk!")

		SPAWN (1.7 SECONDS)
			if (!QDELETED(src))
				src.l_hand?.AttackSelf() // honk

		SPAWN (2.8 SECONDS)
			if (!QDELETED(src))
				src.say("Was that banana a-peel-ing?")

	death(gibbed)
		if (tutorial_owner && istype(src.lastattacker?.deref(), /mob/living/critter/spider))
			src.tutorial_owner.unlock_medal("On My Own (Eight) Space Legs")
		. = ..()

//
// tutorial objects
//

/obj/item/card/id/engineering/tutorial
	name = ""
	access = list(access_engineering_power)

/obj/item/storage/firstaid/brute/tutorial
	attack_self(mob/user)
		. = ..()
		if (user.client?.tutorial)
			user.client.tutorial.PerformSilentAction("open_storage", "first_aid")

/obj/item/device/light/flashlight/tutorial
	toggle(mob/user, activated_inhand)
		. = ..()
		if (user.client?.tutorial)
			user.client.tutorial.PerformSilentAction("use_item", "flashlight")

/obj/item/clothing/head/helmet/welding/tutorial
	flip_up(mob/living/carbon/human/user, silent)
		. = ..()
		if (user?.client?.tutorial)
			user.client.tutorial.PerformSilentAction("welding_mask", "flip_up")
	flip_down(mob/living/carbon/human/user, silent)
		. = ..()
		if (user?.client?.tutorial)
			user.client.tutorial.PerformSilentAction("welding_mask", "flip_down")

/obj/item/weldingtool/tutorial
	fuel_capacity = 999

	attack_self(mob/user)
		. = ..()
		if (user.client?.tutorial)
			user.client.tutorial.PerformSilentAction("use_item", "weldingtool")

/// Guaranteed to contain everything needed for a space walk
/obj/storage/closet/emergency_tutorial
	name = "emergency supplies closet"
	desc = "It's a closet! This one can be opened AND closed. Comes prestocked with emergency equipment."
	icon_state = "emergency"
	icon_closed = "emergency"
	icon_opened = "emergency-open"

	var/obj/item/clothing/suit/space/emerg/emergency_suit
	var/obj/item/clothing/mask/breath/breath_mask
	var/obj/item/clothing/head/emerg/emergency_hood
	var/obj/item/tank/oxygen/tutorial/oxygen_tank

	proc/reset(turf/move_to)
		src.set_loc(move_to)
		src.close()

		if (!src.emergency_suit || QDELETED(src.emergency_suit))
			src.make_emergency_suit()
		if (ismob(src.emergency_suit.loc))
			var/mob/M = src.emergency_suit.loc
			M.drop_item(src.emergency_suit)
		src.emergency_suit.set_loc(src)

		if (!src.breath_mask || QDELELTED(src.breath_mask))
			src.make_breath_mask()
		if (ismob(src.breath_mask.loc))
			var/mob/M = src.breath_mask.loc
			M.drop_item(src.breath_mask)
		src.breath_mask.set_loc(src)

		if (!src.emergency_hood || QDELETED(src.emergency_hood))
			src.make_emergency_hood()
		if (ismob(src.emergency_hood.loc))
			var/mob/M = src.emergency_hood.loc
			M.drop_item(src.emergency_hood)
		src.emergency_hood.set_loc(src)

		if (!src.oxygen_tank || QDELETED(src.oxygen_tank))
			src.make_oxygen_tank()
		if (ismob(src.oxygen_tank.loc))
			var/mob/M = src.oxygen_tank.loc
			M.drop_item(src.oxygen_tank)
		src.oxygen_tank.set_loc(src)

	proc/make_emergency_suit()
		src.emergency_suit = new(src)
		src.emergency_suit.layer = OBJ_LAYER + 0.04
		RegisterSignal(src.emergency_suit, COMSIG_ITEM_PICKUP, PROC_REF(pickup_tutorial_item))
		RegisterSignal(src.emergency_suit, COMSIG_ITEM_EQUIPPED, PROC_REF(equip_tutorial_item))
		RegisterSignal(src.emergency_suit, COMSIG_ITEM_UNEQUIPPED, PROC_REF(unequip_tutorial_item))

	proc/make_breath_mask()
		src.breath_mask = new(src)
		src.breath_mask.layer = OBJ_LAYER + 0.03
		RegisterSignal(src.breath_mask, COMSIG_ITEM_PICKUP, PROC_REF(pickup_tutorial_item))
		RegisterSignal(src.breath_mask, COMSIG_ITEM_EQUIPPED, PROC_REF(equip_tutorial_item))
		RegisterSignal(src.breath_mask, COMSIG_ITEM_UNEQUIPPED, PROC_REF(unequip_tutorial_item))

	proc/make_emergency_hood()
		src.emergency_hood = new(src)
		src.emergency_hood.layer = OBJ_LAYER + 0.02
		RegisterSignal(src.emergency_hood, COMSIG_ITEM_PICKUP, PROC_REF(pickup_tutorial_item))
		RegisterSignal(src.emergency_hood, COMSIG_ITEM_EQUIPPED, PROC_REF(equip_tutorial_item))
		RegisterSignal(src.emergency_hood, COMSIG_ITEM_UNEQUIPPED, PROC_REF(unequip_tutorial_item))

	proc/make_oxygen_tank()
		src.oxygen_tank = new(src)
		src.oxygen_tank.layer = OBJ_LAYER + 0.01
		RegisterSignal(oxygen_tank, COMSIG_ITEM_PICKUP, PROC_REF(pickup_tutorial_item))

	make_my_stuff()
		if(..())
			src.make_emergency_suit()
			src.make_breath_mask()
			src.make_emergency_hood()
			src.make_oxygen_tank()
			return 1

	proc/pickup_tutorial_item(datum/source, mob/user)
		if (user.client?.tutorial)
			user.client.tutorial.PerformSilentAction("item_pickup", source)

	proc/equip_tutorial_item(datum/source, mob/user, slot)
		if (user.client?.tutorial)
			user.client.tutorial.PerformSilentAction("item_equipped", source)

	proc/unequip_tutorial_item(datum/source, mob/user)
		if (user.client?.tutorial)
			user.client.tutorial.PerformSilentAction("item_unequipped", source)

	open(entangleLogic, mob/user)
		. = ..()
		if (user.client?.tutorial)
			user.client.tutorial.PerformSilentAction("open_storage", "emergency_tutorial")

/// mechanical toolbox that tracks its contents
/obj/item/storage/toolbox/tutorial
	name = "mechanical toolbox"
	icon_state = "blue"
	item_state = "toolbox-blue"
	desc = "A metal container designed to hold various tools. This variety holds standard construction tools."

	var/obj/item/screwdriver/screwdriver
	var/obj/item/wrench/wrench
	var/obj/item/weldingtool/weldingtool
	var/obj/item/crowbar/crowbar
	var/obj/item/wirecutters/wirecutters
	var/obj/item/device/analyzer/atmospheric/atmos_scanner

	proc/reset(turf/move_to)
		if (isnull(move_to))
			return
		if (ismob(src.loc))
			var/mob/M = src.loc
			M.drop_item(src)
		src.set_loc(move_to)
		src.pixel_x = 0
		src.pixel_y = 0

		if (!src.screwdriver || QDELETED(src.screwdriver))
			src.screwdriver = new(src)
		src.ensure_item_in_storage(src.screwdriver)

		if (!src.wrench || QDELETED(src.wrench))
			src.wrench = new(src)
		src.ensure_item_in_storage(src.wrench)

		if (!src.weldingtool || QDELETED(src.weldingtool))
			src.weldingtool = new(src)
		src.ensure_item_in_storage(src.weldingtool)

		if (!src.crowbar || QDELETED(src.crowbar))
			src.crowbar = new(src)
		src.ensure_item_in_storage(src.crowbar)

		if (!src.wirecutters || QDELETED(src.wirecutters))
			src.wirecutters = new(src)
		src.ensure_item_in_storage(src.wirecutters)

		if (!src.atmos_scanner || QDELETED(src.atmos_scanner))
			src.atmos_scanner = new(src)
		src.ensure_item_in_storage(src.atmos_scanner)

	proc/ensure_item_in_storage(obj/item)
		if (ismob(item.loc))
			var/mob/M = item.loc
			M.drop_item(item)
		if (!(item in src.storage.stored_items))
			src.storage.add_contents(item, visible=FALSE)

	make_my_stuff()
		if(..())
			src.reset(get_turf(src))
			return TRUE

/obj/item/tank/oxygen/tutorial
	toggle_valve()
		if (..())
			var/mob/living/carbon/M = src.loc
			if (M.client?.tutorial)
				if (M.internal == src)
					M.client.tutorial.PerformSilentAction("action_button", "internals")

/obj/machinery/crusher/slow/tutorial
	finish_crushing(atom/movable/AM)
		if (istype(AM, /mob/living/carbon/human/tutorial))
			var/mob/M = AM
			M.temp_flags &= ~BEING_CRUSHERED
			M.gib() // don't qdel the tutorial mob
			return
		else
			. = ..()

/obj/item/device/radio/headset/tutorial
	hardened = TRUE // needs to always work
	protected_radio = TRUE
	locked_frequency = TRUE

	var/radio_freq_alpha
	var/radio_freq_beta

/obj/item/device/radio/headset/tutorial/New()
	. = ..()
	src.radio_freq_alpha = src.pick_randomized_freq()
	global.protected_frequencies += src.radio_freq_alpha

	src.radio_freq_beta = src.pick_randomized_freq()
	global.protected_frequencies += src.radio_freq_beta

	src.bricked = FALSE // always. work.

	src.secure_frequencies = list(
		"a" = src.radio_freq_alpha,
		"b" = src.radio_freq_beta,
	)
	src.secure_classes = list(
		"a" = RADIOCL_ENGINEERING,
		"b" = RADIOCL_RESEARCH,
	)

	src.set_secure_frequencies()

	// SPAWN(1 SECOND)
	src.frequency = src.radio_freq_alpha


/obj/item/device/radio/headset/tutorial/proc/pick_randomized_freq()
	var/list/blacklisted = list(FREQ_SIGNALER)
	blacklisted.Add(R_FREQ_BLACKLIST)
	blacklisted += global.protected_frequencies

	do
		. = rand(1352, 1439)
	while (blacklisted.Find(.))

/obj/item/device/radio/headset/tutorial/disposing()
	. = ..()
	global.protected_frequencies -= src.radio_freq_alpha
	global.protected_frequencies -= src.radio_freq_beta

#undef NEWBEE_TUTORIAL_TIMER_DURATION

#undef NEWBEE_TUTORIAL_MARKER_TARGET_GROUND
#undef NEWBEE_TUTORIAL_MARKER_TARGET_POINT
#undef NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY
#undef NEWBEE_TUTORIAL_MARKER_HUD_INTENT_HELP
#undef NEWBEE_TUTORIAL_MARKER_HUD_INTENT_DISARM
#undef NEWBEE_TUTORIAL_MARKER_HUD_INTENT_GRAB
#undef NEWBEE_TUTORIAL_MARKER_HUD_INTENT_HARM
#undef NEWBEE_TUTORIAL_MARKER_HUD_STAND
#undef NEWBEE_TUTORIAL_MARKER_HUD_PULL

#undef NEWBEE_TUTORIAL_SIDEBAR_EMPTY
#undef NEWBEE_TUTORIAL_SIDEBAR_MOVEMENT
#undef NEWBEE_TUTORIAL_SIDEBAR_ITEMS
#undef NEWBEE_TUTORIAL_SIDEBAR_INTENTS
#undef NEWBEE_TUTORIAL_SIDEBAR_ACTIONS
#undef NEWBEE_TUTORIAL_SIDEBAR_COMMUNICATION
#undef NEWBEE_TUTORIAL_SIDEBAR_MODIFIERS
#undef NEWBEE_TUTORIAL_SIDEBAR_META
