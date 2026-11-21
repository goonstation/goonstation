/obj/item/disk/data/wide_floppy/read_only/ai_program
	name = "AI Program Disk"
	desc = "A disk containing AI-accessible software programs."
	var/software_package

	disk_name()
		return "[src.software_package]"

/obj/item/disk/data/wide_floppy/read_only/ai_program/hologram
	name = "data disk-'AI Hologram Library'"
	desc = "A disk containing a library of projectible holograms. Hologram Projection Routines Included!"

	disk_name()
		return "Hologram Library:  [src.software_package]"

//-- Hologram programs

/obj/item/disk/data/wide_floppy/read_only/ai_program/hologram/standard
	name = "data disk-'Standard Hologram Library'"
	software_package = "Standard"
	random_color = FALSE
	icon_state = "big-blue"
	disk_color = "#5166ee"

	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/hologram/base)
		src.read_only = TRUE

/obj/item/disk/data/wide_floppy/read_only/ai_program/hologram/syndicate
	name = "data disk-'Syndicate Hologram Library'"
	software_package = "Syndicate"
	random_color = FALSE
	icon_state = "big-red"
	disk_color = "#f04c59"

	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/hologram/syndicate)
		src.read_only = TRUE

/obj/item/disk/data/wide_floppy/read_only/ai_program/hologram/clown
	name = "data disk-'Funny Hologram Library'"
	software_package = "Clown"
	random_color = FALSE
	icon_state = "big-pink"
	disk_color = "#f884fc"

	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/hologram/clown)
		src.read_only = TRUE

/obj/item/disk/data/wide_floppy/read_only/ai_program/hologram/elden
	name = "data disk-'Old, Circular Hologram Library'"
	software_package = "Elden"
	random_color = FALSE
	icon_state = "big-brown"
	disk_color = "#705339"

	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/hologram/elden)
		src.read_only = TRUE

//-- Base programs

/obj/item/disk/data/wide_floppy/read_only/ai_program/tracking // Camera tracking
	name = "data disk-'AI Camera Tracking'"
	software_package = "Tracking Camera"
	desc = "A disk with programs that provide facial and ID recognition across all connected cameras."

	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/skill/camera_tracking)
		src.read_only = TRUE

/obj/item/disk/data/wide_floppy/read_only/ai_program/viewports // Create Viewport / Viewport windows
	name = "data disk-'Remote Viewports'"
	software_package = "Viewport Video Streams"
	desc = "A disk with programs that compress video data. Allows AIs to process multiple visual streams."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/skill/viewports)
		src.read_only = TRUE

/obj/item/disk/data/wide_floppy/read_only/ai_program/call_shuttle // Ability to call shuttle (need to modify checks in terminal program?)
	name = "data disk-'Remote AI Shuttle Call'"
	software_package = "Emergency Shuttle Call"
	desc = "A disk with programs that adjust camera lens focus. Allows AIs to remotely call the emergency shuttle."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/skill/call_shuttle)
		src.read_only = TRUE

//-- Antag programs

/obj/item/disk/data/wide_floppy/read_only/ai_program/laser
	name = "data disk-'CLF: Laser Focusing'"
	software_package = "CLF: Laser Focusing"
	desc = "A disk with programs that adjust camera lens focus. Allows AI controlled cameras to produce a laser like effect."
	icon_state = "big-red"
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/camera_laser)
		src.read_only = TRUE

//-- Misc programs

/obj/item/disk/data/wide_floppy/read_only/ai_program/flash // Emit an AOE flash from a camera
	name = "data disk-'CLF: Flash'"
	software_package = "CLF: Flash"
	desc = "A disk with programs for AI units to emit a bright flash."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/camera_flash)
		src.read_only = TRUE

/obj/item/disk/data/wide_floppy/read_only/ai_program/taser
	name = "data disk-'CLF: Taser Discharge'"
	software_package = "CLF: Taser"
	desc = "A camera lense focus module.  This module allows for the AI controlled camera produce a taser like effect."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/camera_taser)
		src.read_only = TRUE

/obj/item/disk/data/wide_floppy/read_only/ai_program/assisted_guidance // Provide GPS targets for crew
	name = "data disk-'Remote Path Projection'"
	software_package = "Remote GPS Pathing"
	desc = "A disk with programs that enable to project a hologrpahic path from a crew member to a destination."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/assisted_guidance)
		src.read_only = TRUE

/obj/item/disk/data/wide_floppy/read_only/ai_program/proto_teleman
	name = "data disk-'Telescience Integration'"
	software_package = "Telesci Controller"
	desc = "A disk with programs for AI units to remotely control a telescience console."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/proto_teleman)
		src.read_only = TRUE

//-- Admin only

/obj/item/disk/data/wide_floppy/read_only/ai_program/metal_foam_launcher // shoot metal foam from a camera
	name = "data disk-'Remote Foam Displacement'"
	software_package = "Repair Foamer"
	desc = "A disk with programs for AI units to remotely launch metal foam."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/mfoam_launcher)
		src.read_only = TRUE

/obj/item/disk/data/wide_floppy/read_only/ai_program/nanite_hive // repair a silicon or camera
	name = "data disk-'Remote Nanite Repair'"
	software_package = "Repair Nanites"
	desc = "A disk with programs for AI units to remotely repair the station and cameras."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/nanite_hive)
		src.read_only = TRUE

/obj/item/disk/data/wide_floppy/read_only/ai_program/friend_turret // :]
	name = "data disk-'Remote Turret Guidance'"
	software_package = "Turret Control"
	desc = "A disk with programs for AI units to remotely control a turret."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/friend_turret)
		src.read_only = TRUE

// -- Reworked Disks

/obj/item/disk/data/wide_floppy/read_only/ai_program/viewports_expansion
	name = "data disk-'ViewPort: Enterprise License'"
	software_package = "ViewPort: Enterprise License"
	desc = "A disk with programs that compress video data even further. This license allows AIs to process an additional visual stream."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/skill/viewport_expansion)
		src.read_only = TRUE

/obj/item/disk/data/wide_floppy/read_only/ai_program/security_lite
	name = "data disk-'SecHelper Lite'"
	software_package = "Security Records"
	desc = "A disk with programs for AI units to check and set a crewmember's security records."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/record/sec)
		src.root.add_file(new /datum/computer/file/ai_program/ability/scan/prisoner)
		src.read_only = TRUE

/obj/item/disk/data/wide_floppy/read_only/ai_program/security_heavy
	name = "data disk-'SecHelper Control Upgrade'"
	software_package = "Flagging and Citation"
	desc = "A disk with programs for AI units to assist station security in maintaining order."
	file_amount = 64
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/vision/sechud)
		src.root.add_file(new /datum/computer/file/ai_program/ability/issue_citation)
		src.read_only = TRUE

/obj/item/disk/data/wide_floppy/read_only/ai_program/medical_lite
	name = "data disk-'Medical Record Lookup'"
	software_package = "Medical Record Lookup"
	desc = "A disk with programs for AI units to check a crewmember's medical records."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/record/med)
		src.read_only = TRUE

/obj/item/disk/data/wide_floppy/read_only/ai_program/medical_heavy
	name = "data disk-'Remote Medical Examination'"
	software_package = "Medical Examination"
	desc = "A disk with programs for AI units to remotely monitor crew vitals."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/scan/health)
		src.root.add_file(new /datum/computer/file/ai_program/ability/vision/prodoc)
		src.read_only = TRUE

/obj/item/disk/data/wide_floppy/read_only/ai_program/engi_air
	name = "data disk-'Re-Air Lite'"
	software_package = "Breach Detection"
	desc = "A disk with programs for AI units to assist engineering teams in repairing breaches."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/vision/pressure)
		src.root.add_file(new /datum/computer/file/ai_program/ability/scan/atmos)
		src.read_only = TRUE

/obj/item/disk/data/wide_floppy/read_only/ai_program/engi_mech
	name = "data disk-'MechMinder'"
	software_package = "MechComp Visualizer"
	desc = "A disk with programs for AI unitPs to visualize MechComp connections."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/vision/mechcomp)
		src.read_only = TRUE

/obj/item/disk/data/wide_floppy/read_only/ai_program/misc
	name = "data disk-'MiscAssist'"
	software_package = "MiscAssist"
	desc = "A disk with programs for AI units to assist with miscellaneous tasks."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/record/bank)
		src.root.add_file(new /datum/computer/file/ai_program/ability/scan/plant)
		src.root.add_file(new /datum/computer/file/ai_program/ability/vision/mining)
		src.read_only = TRUE

/obj/item/disk/data/wide_floppy/read_only/ai_program/fluid_scan
	name = "data disk-'Fluid Scan'"
	software_package = "Fluid Scanner"
	desc = "A disk with programs for AI units to scan loose fluids."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/scan/reagent)
		src.read_only = TRUE
