/datum/tutorial_base/regional/newbee
	name = "Newbee Tutorial"
	region_type = /datum/mapPrefab/allocated/newbee_tutorial

	var/advance_sound = 'sound/misc/tutorial-bloop.ogg'

	var/mob/living/carbon/human/tutorial/newbee = null
	var/mob/new_player/origin_mob
	var/datum/hud/tutorial/tutorial_hud
	var/datum/keymap/keymap
	var/checkpoint_landmark = LANDMARK_TUTORIAL_START

	var/current_sidebar
	var/list/sidebars = list()

/datum/tutorial_base/regional/newbee/New(mob/M)
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

/datum/tutorial_base/regional/newbee/Start()
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

/datum/tutorial_base/regional/newbee/Advance(manually_selected=FALSE)
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

/datum/tutorial_base/regional/newbee/ShowStep()
	. = ..()
	var/datum/tutorialStep/newbee/T = src.steps[src.current_step]
	src.tutorial_hud?.update_step(T.name)
	src.tutorial_hud.update_text(T.instructions)
	if (T.sidebar && T.sidebar != src.current_sidebar)
		src.tutorial_hud.update_sidebar(src.sidebars[T.sidebar])
		src.current_sidebar = T.sidebar

/datum/tutorial_base/regional/newbee/Finish()
	if(..())
		src.tutorial_hud.remove_client(src.newbee.client)
		src.newbee.unequip_all(TRUE) // removes any lingering item ability HUDs
		var/mob/new_player/M = new()
		M.key = src.newbee.client.key
		src.newbee.mind.transfer_to(M)
		qdel(src.newbee)
		src.newbee = null
		qdel(src.tutorial_hud)
		src.tutorial_hud = null
		src.region.clean_up() // aggressive cleanup to wipe out landmarks/spawned objects
		qdel(src)

/datum/tutorial_base/regional/newbee/proc/generate_sidebars()
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
	src.sidebars += list(NEWBEE_TUTORIAL_SIDEBAR_INTENTS = "Intents:<br>[help] - [TEXT_INTENT_HELP]<br>[disarm] - [TEXT_INTENT_DISARM]<br>[grab] - [TEXT_INTENT_GRAB]<br>[harm] - [TEXT_INTENT_HARM]")

	var/rest = src.keymap.action_to_keybind("rest") || "="
	var/walk = src.keymap.action_to_keybind("walk") || "-"
	var/resist = src.keymap.action_to_keybind("resist") || "Z"
	var/sprint = src.keymap.action_to_keybind(KEY_RUN) || "SHIFT"
	src.sidebars += list(NEWBEE_TUTORIAL_SIDEBAR_ACTIONS = "Actions:<br>[rest] - Rest/Stand<br>[walk] - Walk<br>[resist] - Resist<br>[sprint] - Sprint")

	var/say = src.keymap.action_to_keybind("say") || "T"
	var/say_over_channel = src.keymap.action_to_keybind("say_over_channel") || "Y"
	var/say_over_main_radio = src.keymap.action_to_keybind("say_over_main_radio") || ";"
	var/emote = src.keymap.action_to_keybind("emote") || "M"
	src.sidebars += list(NEWBEE_TUTORIAL_SIDEBAR_COMMUNICATION = "Communication:<br>[say] - Talk<br>[say_over_channel] - Radio Channels<br>[say_over_main_radio] - Main Radio<br>[emote] - Emote")

	var/throw_key = src.keymap.action_to_keybind("throw") || "SPACE"
	var/examine = src.keymap.action_to_keybind(KEY_EXAMINE) || "ALT"
	var/pull = src.keymap.action_to_keybind(KEY_PULL) || "CTRL"
	var/point = src.keymap.action_to_keybind(KEY_POINT) || "B"
	src.sidebars += list(NEWBEE_TUTORIAL_SIDEBAR_MODIFIERS = "Modifiers:<br>[throw_key] - Throw<br>[examine] - Examine<br>[pull] - Pull<br>[point] - Point")

	src.sidebars += list(NEWBEE_TUTORIAL_SIDEBAR_HEALTH = "Damage Types:<br>[TEXT_HEALTH_BRUTE]<br>[TEXT_HEALTH_BURN]<br>[TEXT_HEALTH_TOXIN]<br>[TEXT_HEALTH_OXY]")

	var/adminhelp = src.keymap.action_to_keybind("adminhelp") || "F1"
	var/mentorhelp = src.keymap.action_to_keybind("mentorhelp") || "F3"
	var/looc = src.keymap.action_to_keybind("looc") || "ALT+L"
	src.sidebars += list(NEWBEE_TUTORIAL_SIDEBAR_META = "Meta:<br>[adminhelp] - Admin Help<br>[mentorhelp] - Mentor Help<br>[looc] - Local OOC")


/datum/tutorial_base/regional/newbee/proc/AddNewbeeSteps()
	// room 1 - Arrivals & Movement
	src.AddStep(/datum/tutorialStep/newbee/timer/welcome)
	src.AddStep(/datum/tutorialStep/newbee/timer/custom_controls)
	src.AddStep(/datum/tutorialStep/newbee/move_to/basic_movement)
	src.AddStep(/datum/tutorialStep/newbee/move_to/powered_doors)

	// room 2 - ID-locked Doors
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/id_card)
	src.AddStep(/datum/tutorialStep/newbee/wear_id_card)
	src.AddStep(/datum/tutorialStep/newbee/move_to/id_locked_doors)

	// room 3 - Items & Unpowered Doors
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/can)
	src.AddStep(/datum/tutorialStep/newbee/can_throw)
	src.AddStep(/datum/tutorialStep/newbee/flush_disposals)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/crowbar)
	src.AddStep(/datum/tutorialStep/newbee/open_unpowered_door)
	src.AddStep(/datum/tutorialStep/newbee/drop_item)
	src.AddStep(/datum/tutorialStep/newbee/move_to/exit_items)

	// room 4 - Intents
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
	src.AddStep(/datum/tutorialStep/newbee/move_to/damage_types)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/brute_first_aid)
	src.AddStep(/datum/tutorialStep/newbee/storage_inhands)
	src.AddStep(/datum/tutorialStep/newbee/hand_swap)
	src.AddStep(/datum/tutorialStep/newbee/apply_brute_patch)
	src.AddStep(/datum/tutorialStep/newbee/resisting)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/fire_first_aid)
	src.AddStep(/datum/tutorialStep/newbee/apply_fire_patch)
	src.AddStep(/datum/tutorialStep/newbee/move_to/exit_healing)

	// room 6 - Girder Deconstruction
	src.AddStep(/datum/tutorialStep/newbee/examining)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/toolbox)
	src.AddStep(/datum/tutorialStep/newbee/deconstructing_girder)
	src.AddStep(/datum/tutorialStep/newbee/move_to/exit_girder)

	// room 7 - Active Items
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/flashlight)
	src.AddStep(/datum/tutorialStep/newbee/activating_items)

	// room 8 - Dark Areas
	src.AddStep(/datum/tutorialStep/newbee/move_to/enter_maints)
	src.AddStep(/datum/tutorialStep/newbee/move_to/traversing_maints)

	// room 9 - Space Prep
	src.AddStep(/datum/tutorialStep/newbee/timer/stats_before)
	src.AddStep(/datum/tutorialStep/newbee/opening_closets)
	src.AddStep(/datum/tutorialStep/newbee/equip_space_suit)
	src.AddStep(/datum/tutorialStep/newbee/equip_breath_mask)
	src.AddStep(/datum/tutorialStep/newbee/equip_space_helmet)
	src.AddStep(/datum/tutorialStep/newbee/timer/stats_after)
	src.AddStep(/datum/tutorialStep/newbee/oxygen)
	src.AddStep(/datum/tutorialStep/newbee/internals_on)

	// room 10 - Space Traversal
	src.AddStep(/datum/tutorialStep/newbee/move_to/enter_space)
	src.AddStep(/datum/tutorialStep/newbee/move_to/traversing_space)

	// room 11 - Storage
	src.AddStep(/datum/tutorialStep/newbee/internals_off)
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
	src.AddStep(/datum/tutorialStep/newbee/decon_wall)
	src.AddStep(/datum/tutorialStep/newbee/flip_welding_mask_up)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/wrench)
	src.AddStep(/datum/tutorialStep/newbee/decon_wall_girder)
	src.AddStep(/datum/tutorialStep/newbee/move_to/exit_decon_wall)

	// room 13 - Advanced Movement
	src.AddStep(/datum/tutorialStep/newbee/move_to/laying_down)
	src.AddStep(/datum/tutorialStep/newbee/move_to/sprinting)
	src.AddStep(/datum/tutorialStep/newbee/walking)
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
	var/static/image/lower_half_marker = null
	var/static/image/upper_half_marker = null
	var/static/image/ability_marker = null
	var/static/image/stats_marker = null

	// common vars
	/// Reference to our newbee tutorial
	var/datum/tutorial_base/regional/newbee/newbee_tutorial
	/// Reference to the tutorial's region
	var/datum/allocated_region/region
	/// Reference to the player's keymapping
	var/datum/keymap/keymap

	// settable vars for enabling specific behavior
	/// Which sidebar to display; see NEWBEE_TUTORIAL_SIDEBAR_*
	var/sidebar = NEWBEE_TUTORIAL_SIDEBAR_EMPTY

	/// Associated area of the step. Used to handle warping for stepping backwards
	var/area/tutorial/newbee/step_area

	/// an optional custom sound to use when advancing this step
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
	/// A reference to the currently targeted item in the HUD for highlighting
	var/atom/movable/screen/hud/_target_hud_item

/datum/tutorialStep/newbee/New(datum/tutorial_base/regional/newbee/tutorial)
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
	if (!src.lower_half_marker)
		src.lower_half_marker = image('icons/mob/tutorial_ui.dmi', "lower_half", HUD_LAYER_3)
		src.lower_half_marker.plane = PLANE_HUD
	if (!src.upper_half_marker)
		src.upper_half_marker = image('icons/mob/tutorial_ui.dmi', "upper_half", HUD_LAYER_3)
		src.upper_half_marker.plane = PLANE_HUD
	if (!src.ability_marker)
		src.ability_marker = image('icons/mob/tutorial_ui.dmi', "ability", HUD_LAYER_3)
		src.ability_marker.plane = PLANE_HUD
	if (!src.stats_marker)
		src.stats_marker = image('icons/mob/tutorial_ui.dmi', "stats", HUD_LAYER_3)
		src.stats_marker.plane = PLANE_HUD
	..()

/datum/tutorialStep/newbee/SetUp(manually_selected=FALSE)
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

/datum/tutorialStep/newbee/TearDown()
	. = ..()
	src._target_hud_element?.UpdateOverlays(null, "marker")
	src._needed_item?.UpdateOverlays(null, "marker")
	src._target_hud_item?.UpdateOverlays(null, "marker")

/// highlight a specific hud element
/datum/tutorialStep/newbee/proc/highlight_hud()
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
		if(NEWBEE_TUTORIAL_MARKER_HUD_LOWER_HALF)
			highlight_image = src.lower_half_marker
		if(NEWBEE_TUTORIAL_MARKER_HUD_UPPER_HALF)
			highlight_image = src.upper_half_marker
		if(NEWBEE_TUTORIAL_MARKER_HUD_ABILITY)
			highlight_image = src.ability_marker
		if(NEWBEE_TUTORIAL_MARKER_HUD_STATS)
			highlight_image = src.stats_marker

	if (!highlight_image)
		return

	for (var/atom/movable/screen/hud/hud_element in src.newbee_tutorial.newbee.hud.objects)
		if (hud_element.id == src.highlight_hud_element)
			src._target_hud_element = hud_element
			break

	src._target_hud_element?.UpdateOverlays(highlight_image, "marker")

/// highlight a needed item, including the inventory slot if on the character
/datum/tutorialStep/newbee/proc/highlight_needed_item()
	if (!src.needed_item_path)
		return

	var/highlight_target

	src._needed_item = locate(src.needed_item_path) in src.newbee_tutorial.newbee
	if (src._needed_item) // item is on newbee
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
		else if (src._needed_item == src.newbee_tutorial.newbee.wear_id)
			highlight_target = "id"
		else if (src._needed_item == src.newbee_tutorial.newbee.back)
			highlight_target = "back"
		else if (src._needed_item == src.newbee_tutorial.newbee.shoes)
			src.newbee_tutorial.newbee.hud.show_inventory = TRUE
			src.newbee_tutorial.newbee.hud.update_inventory()
			highlight_target = "shoes"
		else if (src._needed_item == src.newbee_tutorial.newbee.gloves)
			src.newbee_tutorial.newbee.hud.show_inventory = TRUE
			src.newbee_tutorial.newbee.hud.update_inventory()
			highlight_target = "gloves"
		else if (src._needed_item == src.newbee_tutorial.newbee.w_uniform)
			src.newbee_tutorial.newbee.hud.show_inventory = TRUE
			src.newbee_tutorial.newbee.hud.update_inventory()
			highlight_target = "under"
		else if (src._needed_item == src.newbee_tutorial.newbee.wear_suit)
			src.newbee_tutorial.newbee.hud.show_inventory = TRUE
			src.newbee_tutorial.newbee.hud.update_inventory()
			highlight_target = "suit"
		else if (src._needed_item == src.newbee_tutorial.newbee.glasses)
			src.newbee_tutorial.newbee.hud.show_inventory = TRUE
			src.newbee_tutorial.newbee.hud.update_inventory()
			highlight_target = "glasses"
		else if (src._needed_item == src.newbee_tutorial.newbee.ears)
			src.newbee_tutorial.newbee.hud.show_inventory = TRUE
			src.newbee_tutorial.newbee.hud.update_inventory()
			highlight_target = "ears"
		else if (src._needed_item == src.newbee_tutorial.newbee.wear_mask)
			src.newbee_tutorial.newbee.hud.show_inventory = TRUE
			src.newbee_tutorial.newbee.hud.update_inventory()
			highlight_target = "mask"
		else if (src._needed_item == src.newbee_tutorial.newbee.head)
			src.newbee_tutorial.newbee.hud.show_inventory = TRUE
			src.newbee_tutorial.newbee.hud.update_inventory()
			highlight_target = "head"
	else
		src._needed_item = locate(src.needed_item_path) in REGION_TILES(src.region)
		if (src._needed_item) // item is in tutorial area
			src._needed_item.set_loc(get_turf(src.newbee_tutorial.newbee))
		else // item doesn't exist
			src._needed_item = new src.needed_item_path(get_turf(src.newbee_tutorial.newbee))
			src.newbee_tutorial.newbee.put_in_hand_or_drop(src._needed_item)


	if (highlight_target)
		for (var/atom/movable/screen/hud/hud_element in src.newbee_tutorial.newbee.hud.objects)
			if (hud_element.id == highlight_target)
				src._target_hud_item = hud_element
				break
		src._target_hud_item?.UpdateOverlays(src.inventory_marker, "marker")

	src._needed_item.UpdateOverlays(src.point_marker, "marker")

// tutorial step subtypes with common behavior

/// Steps that direct the player to move to a location
/datum/tutorialStep/newbee/move_to
	name = "Moving on..."
	instructions = "Head into the next room to continue."
	/// Landmark to direct the player to
	var/target_landmark

	/// Internal turf reference to the target location
	var/turf/_target_destination

/datum/tutorialStep/newbee/move_to/SetUp()
	. = ..()
	for(var/turf/T in landmarks[src.target_landmark])
		if(src.region.turf_in_region(T))
			src._target_destination = T
			break
	src._target_destination?.UpdateOverlays(src.destination_marker, "marker")

/datum/tutorialStep/newbee/move_to/PerformAction(action, context)
	. = ..()
	if (action == src.target_landmark)
		src.finished = TRUE

/datum/tutorialStep/newbee/move_to/TearDown()
	. = ..()
	src._target_destination.UpdateOverlays(null, "marker")
	src.newbee_tutorial.checkpoint_landmark = src.target_landmark

/// Show countdown clock and move to the next step after `NEWBEE_TUTORIAL_TIMER_DURATION`
/datum/tutorialStep/newbee/timer
/datum/tutorialStep/newbee/timer/SetUp()
	. = ..()
	src.newbee_tutorial.tutorial_hud.flick_timer()
	SPAWN (NEWBEE_TUTORIAL_TIMER_DURATION)
		if (src.tutorial.current_step <= length(src.tutorial.steps) && (src.tutorial.steps[src.tutorial.current_step] == src))
			src.tutorial.Advance()

/datum/tutorialStep/newbee/timer/TearDown()
	. = ..()
	src.newbee_tutorial.tutorial_hud?.stop_timer()

/// Spawn an item of the given type at given landmark, and continue when picked up
/datum/tutorialStep/newbee/item_pickup
	/// Landmark where the item should spawn
	var/target_landmark
	/// Item of the path to spawn/move
	var/item_path

	/// Internal reference to the target item
	var/obj/item/_target_item

/datum/tutorialStep/newbee/item_pickup/SetUp()
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

/datum/tutorialStep/newbee/item_pickup/proc/check_item(atom/source, mob/user)
	src.tutorial.PerformAction("item_pickup", item_path)

/datum/tutorialStep/newbee/item_pickup/PerformAction(action, context)
	if (action == "item_pickup" && context == item_path)
		src.finished = TRUE
	. = ..()

/datum/tutorialStep/newbee/item_pickup/TearDown()
	. = ..()
	src._target_item.UpdateOverlays(null, "marker")
	UnregisterSignal(src._target_item, COMSIG_ITEM_PICKUP)
