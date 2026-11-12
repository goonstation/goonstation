/obj/item/disk/data/floppy/read_only/ai_program
	name = "AI Program Disk"
	desc = "A disk containing AI-accessible software programs."

/obj/item/disk/data/floppy/read_only/ai_program/hologram
	name = "data disk-'AI Hologram Library'"
	desc = "A disk containing a library of projectible holograms. Hologram Projection Routines Included!"
	var/library_name

	disk_name()
		return "Hologram Library - [src.library_name]"

//-- Hologram programs

/obj/item/disk/data/floppy/read_only/ai_program/hologram/standard
	name = "data disk-'Standard Hologram Library'"
	library_name = "Standard"
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/hologram/base)
		src.read_only = TRUE

/obj/item/disk/data/floppy/read_only/ai_program/hologram/syndicate
	name = "data disk-'Syndicate Hologram Library'"
	library_name = "Syndicate"
	random_color = FALSE
	icon_state = "datadiskhos"
	disk_color = "#f04c59"

	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/hologram/syndicate)
		src.read_only = TRUE

/obj/item/disk/data/floppy/read_only/ai_program/hologram/clown
	name = "data disk-'Funny Hologram Library'"
	library_name = "Clown"
	icon_state = "datadiskjan"
	random_color = FALSE
	disk_color = "#f884fc"

	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/hologram/clown)
		src.read_only = TRUE

/obj/item/disk/data/floppy/read_only/ai_program/hologram/elden
	name = "data disk-'Old, Circular Hologram Library'"
	library_name = "Elden"
	icon_state = "datadiskeng"
	random_color = FALSE
	disk_color = "#E7A545"

	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/hologram/elden)
		src.read_only = TRUE

//-- Base programs

/obj/item/disk/data/floppy/read_only/ai_program/tracking // Camera tracking
	name = "data disk-'AI Camera Tracking'"
	desc = "A disk with programs that adjust camera lense focus. Allows AI controlled cameras to produce a hologram."

	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/skill/camera_tracking)
		src.read_only = TRUE

/obj/item/disk/data/floppy/read_only/ai_program/viewports // Create Viewport / Viewport windows
	name = "data disk-'Remote AI Viewports'"
	desc = "A disk with programs that compress video data. Allows AIs to process multiple visual streams."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/skill/viewports)
		src.read_only = TRUE

/obj/item/disk/data/floppy/read_only/ai_program/call_shuttle // Ability to call shuttle (need to modify checks in terminal program?)
	name = "data disk-'Remote AI Shuttle Call'"
	desc = "A disk with programs that adjust camera lens focus. Allows AI controlled cameras to produce a hologram."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/skill/call_shuttle)
		src.read_only = TRUE

//-- Antag programs

/obj/item/disk/data/floppy/read_only/ai_program/laser
	name = "data disk-'CLF: Laser Focusing'"
	desc = "A disk with programs that adjust camera lens focus. Allows AI controlled cameras to produce a laser like effect."
	icon_state = "datadiskhos"
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/camera_laser)
		src.read_only = TRUE

//-- Common programs

// found in hacked SoftTech vendors
/obj/item/disk/data/floppy/read_only/ai_program/flash // Emit an AOE flash from a camera
	name = "data disk-'CLF: Flash'"
	desc = "A disk with programs for AI units to emit a bright flash."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/camera_flash)
		src.read_only = TRUE

// found on auth disk
/obj/item/disk/data/floppy/read_only/ai_program/taser
	name = "data disk-'CLF: Taser Discharge'"
	desc = "A camera lense focus module.  This module allows for the AI controlled camera produce a taser like effect."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/camera_taser)
		src.read_only = TRUE

//-- Uncommon programs

/obj/item/disk/data/floppy/read_only/ai_program/assisted_guidance // Provide GPS targets for crew
	name = "data disk-'Remote Path Projection'"
	desc = "A disk with programs that enable to project a path from a crew member to a destination."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/assisted_guidance)
		src.read_only = TRUE

/obj/item/disk/data/floppy/read_only/ai_program/proto_teleman
	name = "data disk-'Telescience Integration'"
	desc = "A disk with programs for AI units to remotely control a telescience console."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/proto_teleman)
		src.read_only = TRUE

/obj/item/disk/data/floppy/read_only/ai_program/remote_health_scan // get a remote health scan
	name = "data disk-'Visual Health Analysis'"
	desc = "A disk with programs for AI units to remotely survey crew health."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/doctor_vision)
		src.read_only = TRUE

//-- Admin only

/obj/item/disk/data/floppy/read_only/ai_program/remote_security_record // lookup a security record on examine
	name = "data disk-'Visual Security Lookup'"
	desc = "A disk with programs for AI units to remotely control a turret."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/security_vision)
		src.read_only = TRUE


/obj/item/disk/data/floppy/read_only/ai_program/metal_foam_launcher // shoot metal foam from a camera
	name = "data disk-'Remote Foam Displacement'"
	desc = "A disk with programs for AI units to remotely launch metal foam."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/mfoam_launcher)
		src.read_only = TRUE

/obj/item/disk/data/floppy/read_only/ai_program/nanite_hive // repair a silicon or camera
	name = "data disk-'Remote Nanite Repair'"
	desc = "A disk with programs for AI units to remotely repair the station and cameras."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/nanite_hive)
		src.read_only = TRUE

/obj/item/disk/data/floppy/read_only/ai_program/friend_turret // :]
	name = "data disk-'Remote Turret Guidance'"
	desc = "A disk with programs for AI units to remotely control a turret."
	New()
		. = ..()
		src.root.add_file(new /datum/computer/file/ai_program/ability/friend_turret)
		src.read_only = TRUE
