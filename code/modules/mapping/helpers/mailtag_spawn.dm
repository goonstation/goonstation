#define MEDICAL "#3daff7"
#define SECURITY "#f73d3d"
#define MORGUE_BLACK "#002135"
#define RESEARCH "#b23df7"
#define ENGINEERING "#f7af3d"
#define CARGO "#f7e43d"
#define MAINTENANCE "#e5ff32"
#define COMMAND "#00783c"

ABSTRACT_TYPE(/obj/mapping_helper/mailtag)
/obj/mapping_helper/mailtag
	name = "junction mailtag spawn"
	desc = "Configures a mail junction with its mail tag, then destroys itself."
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "mail_tag"
	var/mail_tag = null

	setup()
		for (var/obj/disposalpipe/switch_junction/sj in src.loc)
			if(src.mail_tag)
				if(!sj.mail_tag) sj.mail_tag = list()
				sj.mail_tag += src.mail_tag
				break

	// Mailtag types
	// All subtypes should exist across:
	// - /obj/mapping_helper/mailtag (here)
	// - /obj/machinery/disposal/mail/autoname
	// - /obj/machinery/disposal/mail/small/autoname

	manual
		name = "varedit mailtag spawn"

	janitor
		name = "Janitor"
		mail_tag = "janitor"
		color = MAINTENANCE
	kitchen
		name = "Kitchen"
		mail_tag = "kitchen"
		color = MAINTENANCE
	bar
		name = "Bar"
		mail_tag = "bar"
		color = MAINTENANCE
	hydroponics
		name = "Hydroponics"
		mail_tag = "hydroponics"
		color = MAINTENANCE
	security
		name = "Security"
		mail_tag = "security"
		color = SECURITY

		brig
			name = "Brig"
			mail_tag = "brig"
		detective
			name = "Detective"
			mail_tag = "detective"
		armory
			name = "Armory"
			mail_tag = "armory"

	bridge
		name = "Bridge"
		mail_tag = "bridge"
		color = COMMAND
	chapel
		name = "Chapel"
		mail_tag = "chapel"
		color = MAINTENANCE
	engineering
		name = "Engineering"
		mail_tag = "engineering"
		color = ENGINEERING
	mechanics
		name = "Mechanics"
		mail_tag = "mechanics"
		color = ENGINEERING
	mining
		name = "Mining"
		mail_tag = "mining"
		color = ENGINEERING
	qm
		name = "QM"
		mail_tag = "QM"
		color = ENGINEERING

		refinery
			name = "Refinery"
			mail_tag = "refinery"

	research
		name = "Research"
		mail_tag = "research"
		color = RESEARCH

		telescience
			name = "Telescience"
			mail_tag = "telescience"
		chemistry
			name = "Chemistry"
			mail_tag = "chemistry"
		testchamber
			name = "Test Chamber"
			mail_tag = "testchamber"

	medbay
		name = "Medbay"
		mail_tag = "medbay"
		color = MEDICAL

		robotics
			name = "Robotics"
			mail_tag = "robotics"
		genetics
			name = "Genetics"
			mail_tag = "genetics"
		pathology
			name = "Pathology"
			mail_tag = "pathology"
		morgue
			name = "Morgue"
			mail_tag = "morgue"
			color = MORGUE_BLACK
		booth
			name = "Medical Booth"
			mail_tag = "medical booth"

ABSTRACT_TYPE(/obj/mapping_helper/mailtag/checkpoint)
/obj/mapping_helper/mailtag/checkpoint
	color = SECURITY

	arrivals
		name = "Arrivals Checkpoint"
		mail_tag = "arrivals checkpoint"
	escape
		name = "Escape Hallway Checkpoint"
		mail_tag = "escape checkpoint"
	customs
		name = "Customs Checkpoint"
		mail_tag = "customs checkpoint"
	sec_foyer
		name = "Security Foyer Checkpoint"
		mail_tag = "sec foyer checkpoint"
	podbay
		name = "Pod Bay Checkpoint"
		mail_tag = "podbay checkpoint"
	chapel
		name = "Chapel Checkpoint"
		mail_tag = "chapel checkpoint"
	cargo
		name = "Cargo Checkpoint"
		mail_tag = "cargo checkpoint"
	west
		name = "West Hallway Checkpoint"
		mail_tag = "west hallway checkpoint"
	east
		name = "East Hallway Checkpoint"
		mail_tag = "east hallway checkpoint"

ABSTRACT_TYPE(/obj/mapping_helper/mailtag/public)
/obj/mapping_helper/mailtag/public
	color = MAINTENANCE

	crew
		name = "Crew Quarters"
		mail_tag = "crew"
	crewA
		name = "Crew A"
		mail_tag = "crewA"
	crewB
		name = "Crew B"
		mail_tag = "crewB"
	arcade
		name = "Arcade"
		mail_tag = "arcade"
	market
		name = "Market"
		mail_tag = "market"
	cafeteria
		name = "Cafeteria"
		mail_tag = "cafeteria"
	arrivals
		name = "Arrivals"
		mail_tag = "arrivals hallway"
	escape
		name = "Escape"
		mail_tag = "escape hallway"
	medbay_lobby
		name = "Medbay Lobby"
		mail_tag = "medbay lobby"
	podbay
		name = "Pod Bay"
		mail_tag = "podbay"

#undef MEDICAL
#undef SECURITY
#undef MORGUE_BLACK
#undef RESEARCH
#undef ENGINEERING
#undef CARGO
#undef MAINTENANCE
#undef COMMAND
