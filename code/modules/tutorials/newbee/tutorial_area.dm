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
	starting_landmark = LANDMARK_TUTORIAL_NEWBEE_EXIT_INTENTS
/area/tutorial/newbee/room_6
	icon_state = "pink"
	starting_landmark = LANDMARK_TUTORIAL_NEWBEE_EXIT_HEALTH
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
