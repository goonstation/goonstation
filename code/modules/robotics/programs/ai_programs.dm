/datum/computer/file/ai_program
	name = "AI Software"
	extension = "AI"
	size = 32

	asText()
		return /datum/language/binary::to_binary(src.name)


/datum/computer/file/ai_program/hologram
	name = "AI Media Library"
	extension = "AIML"
	size = 24
	var/hologram_set = ""

/datum/computer/file/ai_program/hologram/base
	name = "HoloLib_Base"
	hologram_set = SILICON::AI::HOLOGRAM::BASE
/datum/computer/file/ai_program/hologram/syndicate
	name = "HoloLib_Syndicate"
	hologram_set = SILICON::AI::HOLOGRAM::SYNDICATE
/datum/computer/file/ai_program/hologram/clown
	name = "HoloLib_Honk"
	hologram_set = SILICON::AI::HOLOGRAM::CLOWN
/datum/computer/file/ai_program/hologram/elden
	name = "HoloLib_Circular"
	hologram_set = SILICON::AI::HOLOGRAM::ELDEN


/datum/computer/file/ai_program/skill
	name = "AI Expansion Program - Skill"
	var/skill = ""

/datum/computer/file/ai_program/skill/hologram_emitter
	name = "HoloEmitter"
	size = 8  // flavor
	skill = SILICON::AI::SKILL::HOLOGRAM
/datum/computer/file/ai_program/skill/call_shuttle
	name = "ShuttleCall"
	skill = SILICON::AI::SKILL::SHUTTLE
/datum/computer/file/ai_program/skill/camera_tracking
	name = "CameraTrack"
	skill = SILICON::AI::SKILL::TRACKING
/datum/computer/file/ai_program/skill/viewports
	name = "ViewMirror"
	skill = SILICON::AI::SKILL::VIEWPORT


/datum/computer/file/ai_program/ability
	name = "AI Expansion Program - Ability"
	extension = "AIEP"
	var/list/datum/targetable/ai_abilities
	var/last_use
	var/shared_cooldown

/datum/computer/file/ai_program/ability/proto_teleman
	name = "Teleman_Remote"
	ai_abilities = list(/datum/targetable/ai/program/teleport/send, /datum/targetable/ai/program/teleport/receive)

/datum/computer/file/ai_program/ability/nanite_hive
	name = "CameraEmitter_Nanite"
	ai_abilities = list(/datum/targetable/ai/program/camera_repair, /datum/targetable/ai/program/nanite_repair)

/datum/computer/file/ai_program/ability/doctor_vision
	name = "Medical_Optics"
	ai_abilities = list(/datum/targetable/ai/program/prodocs)

/datum/computer/file/ai_program/ability/security_vision
	name = "Security_Optics"
	ai_abilities = list(/datum/targetable/ai/program/sec_huds)

/datum/computer/file/ai_program/ability/camera_flash
	name = "CameraLensFocus_Flash"
	ai_abilities = list(/datum/targetable/ai/program/flash)

/datum/computer/file/ai_program/ability/camera_laser
	name = "CameraLensFocus_Laser"
	ai_abilities = list(/datum/targetable/ai/program/camera_gun/laser)

/datum/computer/file/ai_program/ability/assisted_guidance
	name = "GPS_Routing"
	ai_abilities = list(/datum/targetable/ai/program/gps_select)

/datum/computer/file/ai_program/ability/camera_taser
	name = "CameraLensFocus_Taser"
	ai_abilities = list(/datum/targetable/ai/program/camera_gun/taser)

/datum/computer/file/ai_program/ability/mfoam_launcher
	name = "CameraEmitter_Foam"
	ai_abilities = list(/datum/targetable/ai/program/chems/metal_foam)

/datum/computer/file/ai_program/ability/friend_turret
	name = "TurretControl"
	ai_abilities = list(/datum/targetable/ai/program/turret/deploy, /datum/targetable/ai/program/turret/target, /datum/targetable/ai/program/turret/swap_bullets)
