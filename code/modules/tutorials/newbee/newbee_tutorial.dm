var/global/newbee_tutorial_enabled = TRUE

/datum/tutorial_base/regional/newbee
	name = "Newbee Tutorial"
	region_type = /datum/mapPrefab/allocated/newbee_tutorial

	/// The sound to play when advancing a step in the tutorial
	var/advance_sound = 'sound/misc/tutorial-bloop.ogg'

	/// Reference to the generated tutorial mob
	var/mob/living/carbon/human/tutorial/newbee = null
	/// Reference to the original new player mob, needed to transfer the mind properly on startup
	var/mob/new_player/origin_mob
	/// Reference to the tutorial instructions HUD given to the tutorial mob
	var/datum/hud/tutorial/tutorial_hud
	/// Reference to the player's keymap for dyanmic key instructions
	var/datum/keymap/keymap
	/// The current checkpoint landmark, used if the player dies
	var/checkpoint_landmark = LANDMARK_TUTORIAL_START

	/// The currently displayed sidebar step (uses `NEWBEE_TUTORIAL_SIDEBAR_*` defines)
	var/current_sidebar

	/// A key-value list of pre-generated sidebar content
	///
	/// The key is a `NEWBEE_TUTORIAL_SIDEBAR_*` define.
	/// The value is a generated HTML blob to put as maptext.
	var/list/sidebars = list()

/datum/tutorial_base/regional/newbee/New(mob/M)
	..()
	src.exit_point = pick_landmark(LANDMARK_NEW_PLAYER)
	src.origin_mob = M
	src.origin_mob.close_spawn_windows()
	animate(src.origin_mob.client, color = "#000000", time = 5, easing = QUAD_EASING | EASE_IN)
	src.newbee = new(src.initial_turf, src.origin_mob.client.preferences.AH, src.origin_mob.client.preferences, TRUE)
	src.owner = src.newbee

/datum/tutorial_base/regional/newbee/Start()
	src.tutorial_hud = new()
	src.origin_mob.mind.transfer_to(src.newbee)
	src.keymap = src.newbee.client.keymap
	src.AddNewbeeSteps()
	src.newbee.attach_hud(src.tutorial_hud)
	var/datum/abilityHolder/newbee/newbee_holder = src.newbee.add_ability_holder(/datum/abilityHolder/newbee)
	newbee_holder.my_tutorial = src
	var/target_color = "#FFFFFF"
	if(src.newbee.client.color != "#000000")
		target_color = src.newbee.client.color
	animate(src.newbee.client, color = "#000000", time = 0, flags = ANIMATION_END_NOW)
	animate(color = "#000000", time = 10, easing = QUAD_EASING | EASE_IN)
	animate(color = target_color, time = 10, easing = QUAD_EASING | EASE_IN)
	. = ..()
	src.setup_keymap(src.keymap)

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
	var/datum/abilityHolder/newbee/newbee_holder = src.newbee.get_ability_holder(/datum/abilityHolder/newbee)
	newbee_holder.updateText()
	T = steps[current_step]
	T.SetUp(manually_selected)
	src.ShowStep()

/datum/tutorial_base/regional/newbee/ShowStep()
	. = ..()
	var/datum/tutorialStep/newbee/T = src.steps[src.current_step]
	T.update_instructions()

/datum/tutorial_base/regional/newbee/Finish()
	src.newbee.unequip_all(TRUE)
	if(..())
		var/mob/new_player/M = new()
		M.adminspawned = TRUE
		src.newbee.mind?.transfer_to(M)
		src.region.clean_up() // aggressive cleanup to wipe out landmarks/spawned objects
		qdel(src)

/datum/tutorial_base/regional/newbee/disposing()
	. = ..()
	qdel(src.newbee)
	src.newbee = null
	qdel(src.origin_mob)
	src.origin_mob = null
	qdel(src.tutorial_hud)
	src.tutorial_hud = null
	src.keymap = null

/datum/tutorial_base/regional/newbee/proc/setup_keymap(datum/keymap/keymap)
	if (!keymap)
		CRASH("Tried to generate tutorial sidebar without keymap")

	src.keymap = keymap

	src.sidebars = list(NEWBEE_TUTORIAL_SIDEBAR_EMPTY = "")

	var/up = src.keymap.action_to_keybind(KEY_FORWARD)
	var/left = src.keymap.action_to_keybind(KEY_LEFT)
	var/down = src.keymap.action_to_keybind(KEY_BACKWARD)
	var/right = src.keymap.action_to_keybind(KEY_RIGHT)
	src.sidebars += list(NEWBEE_TUTORIAL_SIDEBAR_MOVEMENT = "Movement:<br>[up] - Up<br>[down] - Down<br>[left] - Left<br>[right] - Right")

	var/equip = src.keymap.action_to_keybind("equip")
	var/attackself = src.keymap.action_to_keybind("attackself")
	var/drop_item = src.keymap.action_to_keybind("drop")
	var/swaphand = src.keymap.action_to_keybind("swaphand")
	src.sidebars += list(NEWBEE_TUTORIAL_SIDEBAR_ITEMS = "Items:<br>[equip] - Wear/Store<br>[attackself] - Open/Use<br>[drop_item] - Drop<br>[swaphand] - Swap hands")

	var/help = src.keymap.action_to_keybind("help")
	var/disarm = src.keymap.action_to_keybind("disarm")
	var/grab = src.keymap.action_to_keybind("grab")
	var/harm = src.keymap.action_to_keybind("harm")
	src.sidebars += list(NEWBEE_TUTORIAL_SIDEBAR_INTENTS = "Intents:<br>[help] - [TEXT_INTENT_HELP]<br>[disarm] - [TEXT_INTENT_DISARM]<br>[grab] - [TEXT_INTENT_GRAB]<br>[harm] - [TEXT_INTENT_HARM]")

	var/rest = src.keymap.action_to_keybind("rest")
	var/walk = src.keymap.action_to_keybind("walk")
	var/resist = src.keymap.action_to_keybind("resist")
	var/sprint = src.keymap.action_to_keybind(KEY_RUN)
	src.sidebars += list(NEWBEE_TUTORIAL_SIDEBAR_ACTIONS = "Actions:<br>[rest] - Rest/Stand<br>[walk] - Walk/Run<br>[resist] - Resist<br>[sprint] - Sprint")

	var/say = src.keymap.action_to_keybind("say")
	var/say_over_channel = src.keymap.action_to_keybind("say_over_channel")
	var/say_over_main_radio = src.keymap.action_to_keybind("say_over_main_radio")
	var/emote = src.keymap.action_to_keybind("emote")
	src.sidebars += list(NEWBEE_TUTORIAL_SIDEBAR_COMMUNICATION = "Communication:<br>[say] - Talk<br>[say_over_channel] - Radio Channels<br>[say_over_main_radio] - Main Radio<br>[emote] - Emote")

	var/throw_key = src.keymap.action_to_keybind(KEY_THROW)
	var/examine = src.keymap.action_to_keybind(KEY_EXAMINE)
	var/pull = src.keymap.action_to_keybind(KEY_PULL)
	var/point = src.keymap.action_to_keybind(KEY_POINT)
	src.sidebars += list(NEWBEE_TUTORIAL_SIDEBAR_MODIFIERS = "Modifiers:<br>[throw_key] - Throw<br>[examine] - Examine<br>[pull] - Pull<br>[point] - Point")

	src.sidebars += list(NEWBEE_TUTORIAL_SIDEBAR_HEALTH = "Damage Types:<br>[TEXT_HEALTH_BRUTE] - Blunt/Cut/Stab<br>[TEXT_HEALTH_BURN] - Fire/Shocks<br>[TEXT_HEALTH_TOXIN] - Poison/Radiation<br>[TEXT_HEALTH_OXY] - Suffocation")

	var/adminhelp = src.keymap.action_to_keybind("adminhelp")
	var/mentorhelp = src.keymap.action_to_keybind("mentorhelp")
	var/looc = src.keymap.action_to_keybind("looc")
	src.sidebars += list(NEWBEE_TUTORIAL_SIDEBAR_META = "Meta:<br>[adminhelp] - Admin Help<br>[mentorhelp] - Mentor Help<br>[looc] - Local OOC")

	if (src.current_sidebar)
		src.tutorial_hud.update_sidebar(src.sidebars[src.current_sidebar])
	if (length(src.steps)) // keymaps call this a little early, so we have to check
		var/datum/tutorialStep/newbee/step_to_update = src.steps[src.current_step]
		step_to_update.update_instructions()

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
	src.AddStep(/datum/tutorialStep/newbee/move_to/exit_items)

	// room 4 - Intents & Resist
	src.AddStep(/datum/tutorialStep/newbee/drop_item)
	src.AddStep(/datum/tutorialStep/newbee/intent_help)
	src.AddStep(/datum/tutorialStep/newbee/help_person)
	src.AddStep(/datum/tutorialStep/newbee/intent_disarm)
	src.AddStep(/datum/tutorialStep/newbee/disarm_person)
	src.AddStep(/datum/tutorialStep/newbee/intent_grab)
	src.AddStep(/datum/tutorialStep/newbee/grab_person)
	src.AddStep(/datum/tutorialStep/newbee/intent_harm)
	src.AddStep(/datum/tutorialStep/newbee/basic_combat)
	src.AddStep(/datum/tutorialStep/newbee/resisting)
	src.AddStep(/datum/tutorialStep/newbee/move_to/exit_intents)

	// room 5 - Healing
	src.AddStep(/datum/tutorialStep/newbee/move_to/damage_types)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/brute_first_aid)
	src.AddStep(/datum/tutorialStep/newbee/storage_inhands)
	src.AddStep(/datum/tutorialStep/newbee/hand_swap)
	src.AddStep(/datum/tutorialStep/newbee/apply_brute_patch)
	src.AddStep(/datum/tutorialStep/newbee/on_fire)
	src.AddStep(/datum/tutorialStep/newbee/standing_up)
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
	src.AddStep(/datum/tutorialStep/newbee/timer/spaceworthy)
	src.AddStep(/datum/tutorialStep/newbee/opening_closets)
	src.AddStep(/datum/tutorialStep/newbee/equipping_space_gear)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/oxygen)
	src.AddStep(/datum/tutorialStep/newbee/internals_on)
	src.AddStep(/datum/tutorialStep/newbee/timer/stats_after)

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

	/// Associated area of the step. Used to handle warping for previous step
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
	/// A reference to the currently targeted hud elements for HUD highlighting
	var/list/atom/movable/screen/hud/_target_hud_elements = list()
	/// Reference to the currently needed item
	var/obj/item/_needed_item
	/// Current HUD point
	var/obj/decal/point/hud_point

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
		src.highlight_hud(src.highlight_hud_element, src.highlight_hud_marker)
	if (src.needed_item_path)
		src._needed_item = src.highlight_needed_item(src.needed_item_path)

/datum/tutorialStep/newbee/TearDown()
	. = ..()
	for (var/atom/movable/screen/hud/hud_element in src._target_hud_elements)
		hud_element?.UpdateOverlays(null, "marker")
	src._needed_item?.UpdateOverlays(null, "marker")
	qdel(src.hud_point)

/// update instruction text. IMPORTANT: tail-call parent to update properly
/datum/tutorialStep/newbee/proc/update_instructions()
	SHOULD_CALL_PARENT(TRUE)
	src.newbee_tutorial.tutorial_hud.update_step(src.name)
	src.newbee_tutorial.tutorial_hud.update_text(src.instructions)
	if (src.sidebar && src.sidebar != src.newbee_tutorial.current_sidebar)
		src.newbee_tutorial.tutorial_hud.update_sidebar(src.newbee_tutorial.sidebars[src.sidebar])
		src.newbee_tutorial.current_sidebar = src.sidebar

/// highlight a specific hud element
/datum/tutorialStep/newbee/proc/highlight_hud(hud_element, hud_marker)
	if (!hud_element || !hud_marker)
		return

	var/image/highlight_image

	var/point_x_offset = 0
	var/point_y_offset = 0
	switch(hud_marker)
		if(NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY)
			highlight_image = src.inventory_marker
			point_x_offset += 16
			point_y_offset += 32
		if(NEWBEE_TUTORIAL_MARKER_HUD_INTENT_HELP)
			highlight_image = src.help_intent_marker
			point_x_offset += 8
			point_y_offset += 32
		if(NEWBEE_TUTORIAL_MARKER_HUD_INTENT_DISARM)
			highlight_image = src.disarm_intent_marker
			point_x_offset += 24
			point_y_offset += 32
		if(NEWBEE_TUTORIAL_MARKER_HUD_INTENT_GRAB)
			highlight_image = src.grab_intent_marker
			point_x_offset += 8
			point_y_offset += 16
		if(NEWBEE_TUTORIAL_MARKER_HUD_INTENT_HARM)
			highlight_image = src.harm_intent_marker
			point_x_offset += 24
			point_y_offset += 16
		if(NEWBEE_TUTORIAL_MARKER_HUD_LOWER_HALF)
			highlight_image = src.lower_half_marker
			point_x_offset += 16
			point_y_offset += 16
		if(NEWBEE_TUTORIAL_MARKER_HUD_UPPER_HALF)
			highlight_image = src.upper_half_marker
			point_x_offset += 16
			point_y_offset += 32
		if(NEWBEE_TUTORIAL_MARKER_HUD_ABILITY)
			highlight_image = src.ability_marker
			point_x_offset += 16
			point_y_offset += 32
		if(NEWBEE_TUTORIAL_MARKER_HUD_STATS)
			highlight_image = src.stats_marker
			point_x_offset += 8
			point_y_offset += 32

	if (!highlight_image)
		return

	for (var/atom/movable/screen/hud/element in src.newbee_tutorial.newbee.hud.objects)
		if (element.id == hud_element)
			src._target_hud_elements += element
			element.UpdateOverlays(highlight_image, "marker")
			if (src.newbee_tutorial.newbee.client)
				var/hud_x_y_offset = screen_loc_to_pixel_offset(src.newbee_tutorial.newbee.client, element.screen_loc)
				point_x_offset += hud_x_y_offset[1]
				point_y_offset += hud_x_y_offset[2]
				// points to north-anchored items go off the screen, so slightly lower them
				if (findtext(element.screen_loc, "NORTH"))
					point_y_offset -= 10
				src.hud_point_loop(src.newbee_tutorial.current_step, point_x_offset, point_y_offset)
			break

/// highlight a needed item, including the inventory slot if on the character
/datum/tutorialStep/newbee/proc/highlight_needed_item(item_path)
	if (!item_path)
		return

	var/highlight_target
	var/obj/item/target_item

	target_item = locate(item_path) in src.newbee_tutorial.newbee
	if (target_item) // item is on newbee
		if (target_item == src.newbee_tutorial.newbee.l_hand)
			highlight_target = "lhand"
		else if (target_item == src.newbee_tutorial.newbee.r_hand)
			highlight_target = "rhand"
		else if (target_item == src.newbee_tutorial.newbee.l_store)
			highlight_target = "storage1"
		else if (target_item == src.newbee_tutorial.newbee.l_store)
			highlight_target = "storage2"
		else if (target_item == src.newbee_tutorial.newbee.back)
			highlight_target = "back"
		else if (target_item == src.newbee_tutorial.newbee.belt)
			highlight_target = "belt"
		else if (target_item == src.newbee_tutorial.newbee.wear_id)
			highlight_target = "id"
		else if (target_item == src.newbee_tutorial.newbee.back)
			highlight_target = "back"
		else if (target_item == src.newbee_tutorial.newbee.shoes)
			src.newbee_tutorial.newbee.hud.show_inventory = TRUE
			src.newbee_tutorial.newbee.hud.update_inventory()
			highlight_target = "shoes"
		else if (target_item == src.newbee_tutorial.newbee.gloves)
			src.newbee_tutorial.newbee.hud.show_inventory = TRUE
			src.newbee_tutorial.newbee.hud.update_inventory()
			highlight_target = "gloves"
		else if (target_item == src.newbee_tutorial.newbee.w_uniform)
			src.newbee_tutorial.newbee.hud.show_inventory = TRUE
			src.newbee_tutorial.newbee.hud.update_inventory()
			highlight_target = "under"
		else if (target_item == src.newbee_tutorial.newbee.wear_suit)
			src.newbee_tutorial.newbee.hud.show_inventory = TRUE
			src.newbee_tutorial.newbee.hud.update_inventory()
			highlight_target = "suit"
		else if (target_item == src.newbee_tutorial.newbee.glasses)
			src.newbee_tutorial.newbee.hud.show_inventory = TRUE
			src.newbee_tutorial.newbee.hud.update_inventory()
			highlight_target = "glasses"
		else if (target_item == src.newbee_tutorial.newbee.ears)
			src.newbee_tutorial.newbee.hud.show_inventory = TRUE
			src.newbee_tutorial.newbee.hud.update_inventory()
			highlight_target = "ears"
		else if (target_item == src.newbee_tutorial.newbee.wear_mask)
			src.newbee_tutorial.newbee.hud.show_inventory = TRUE
			src.newbee_tutorial.newbee.hud.update_inventory()
			highlight_target = "mask"
		else if (target_item == src.newbee_tutorial.newbee.head)
			src.newbee_tutorial.newbee.hud.show_inventory = TRUE
			src.newbee_tutorial.newbee.hud.update_inventory()
			highlight_target = "head"
	else
		target_item = locate(item_path) in REGION_TILES(src.region)
		if (target_item) // item is in tutorial region
			if (!istype(get_area(target_item), src.step_area)) // only move if out of area
				target_item.set_loc(get_turf(src.newbee_tutorial.newbee))
		else // item doesn't exist
			target_item = new item_path(get_turf(src.newbee_tutorial.newbee))
			src.newbee_tutorial.newbee.put_in_hand_or_drop(target_item)

	if (highlight_target)
		for (var/atom/movable/screen/hud/hud_element in src.newbee_tutorial.newbee.hud.objects)
			if (hud_element.id == highlight_target)
				src._target_hud_elements += hud_element
				hud_element.UpdateOverlays(src.inventory_marker, "marker")
				break

	target_item.UpdateOverlays(src.point_marker, "marker")
	return target_item

/// Loops a hud pointer until the step moves on
/datum/tutorialStep/newbee/proc/hud_point_loop(step_number, x_offset, y_offset)
	if (src.newbee_tutorial.current_step == step_number)
		src.hud_point = make_hud_point(src.newbee_tutorial.newbee, x_offset, y_offset, "#9eee80", 3 SECONDS)
		SPAWN (4 SECONDS)
			src.hud_point_loop(step_number, x_offset, y_offset)

/// Points from a mob to a target X/Y point; meant for HUDs. See also: screen_loc_to_pixel_offset
proc/make_hud_point(mob/pointer, target_x=0, target_y=0, color="#ffffff", time=2 SECONDS, invisibility=INVIS_NONE)
	if(QDELETED(pointer)) return
	if(!istype(pointer)) return

	var/obj/decal/point/point = new
	point.color = color
	point.invisibility = invisibility
	point.layer = HUD_LAYER_3
	point.plane = PLANE_ABOVE_HUD
	pointer.vis_contents += point

	var/matrix/M = matrix()
	M.Translate(target_x,  target_y)
	animate(point, transform=M, time=1 SECOND) // slower so you can track it

	SPAWN(time)
		if(pointer)
			pointer.vis_contents -= point
		qdel(point)
	return point

/// For a client and target screen location, give a pixel offset from the client to the bottom-left corner of the location on screen
proc/screen_loc_to_pixel_offset(client/C, target_screen_loc)
	var/x_component
	var/y_component

	var/list/a_b = splittext(target_screen_loc, ",")
	if (findtext(a_b[1], "NORTH") || findtext(a_b[1], "SOUTH") || findtext(a_b[2], "EAST") || findtext(a_b[2], "WEST"))
		x_component = a_b[2]
		y_component = a_b[1]
	else
		x_component = a_b[1]
		y_component = a_b[2]

	// go to 0,0 from centre
	var/x_offset = -(istext(C.view) ? WIDE_TILE_WIDTH / 2 : SQUARE_TILE_WIDTH / 2) * 32
	var/y_offset = -TILE_HEIGHT / 2 * 32

	var/list/x_subcomponent = splittext(x_component, ":")
	var/list/y_subcomponent = splittext(y_component, ":")

	if (findtext(x_subcomponent[1], "CENTER"))
		x_offset += (istext(C.view) ? WIDE_TILE_WIDTH / 2 : SQUARE_TILE_WIDTH / 2) * 32 - 16
	else if (findtext(x_subcomponent[1], "WEST"))
		x_offset += 0
	else if (findtext(x_subcomponent[1], "EAST"))
		x_offset += (istext(C.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH) * 32 - 32
	else
		// bare number
		x_offset += text2num(x_subcomponent[1]) * 32 - 32

	// grid offsets
	if (findtext(x_subcomponent[1], "+"))
		x_offset += text2num(splittext(x_subcomponent[1], "+")[2]) * 32
	if (findtext(x_subcomponent[1], "-"))
		x_offset -= text2num(splittext(x_subcomponent[1], "-")[2]) * 32

	// pixel_x component
	if (findtext(x_component, ":"))
		x_offset += text2num(x_subcomponent[2])

	if (findtext(y_subcomponent[1], "CENTER"))
		y_offset += TILE_HEIGHT / 2 * 32 - 16
	else if (findtext(y_subcomponent[1], "SOUTH"))
		y_offset += 0
	else if (findtext(y_subcomponent[1], "NORTH"))
		y_offset += TILE_HEIGHT * 32 - 32
	else
		// bare number
		y_offset += text2num(y_subcomponent[1]) * 32 - 32

	// grid offsets
	if (findtext(y_subcomponent[1], "+"))
		y_offset += text2num(splittext(y_component, "+")[2]) * 32
	if (findtext(y_subcomponent[1], "-"))
		y_offset -= text2num(splittext(y_component, "-")[2]) * 32

	 // pixel_y component
	if (findtext(y_component, ":"))
		y_offset += text2num(y_subcomponent[2])

	return list(x_offset, y_offset)

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
	src.newbee_tutorial.tutorial_hud?.flick_timer()
	SPAWN (NEWBEE_TUTORIAL_TIMER_DURATION)
		if (src.tutorial && !QDELETED(src.tutorial) && src.tutorial.current_step <= length(src.tutorial.steps) && (src.tutorial.steps[src.tutorial.current_step] == src))
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
