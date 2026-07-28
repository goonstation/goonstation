ABSTRACT_TYPE(/obj/mapping_helper/mailtag)
/obj/mapping_helper/mailtag
	name = "mailtag spawn"
	desc = "Configures a mail chute or junction with its mail tag, then destroys itself."
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "mail_tag"
	var/mail_tag = null
	var/mailgroup = null
	var/mailgroup2 = null
	var/message = FALSE

/obj/mapping_helper/mailtag/setup()
	if (!src.mail_tag)
		CRASH("Unconfigured mailtag spawn!\nCoordinates: [src.x] x, [src.y] y, [src.z] z")

	for (var/obj/disposalpipe/switch_junction/junction in src.loc)
		junction.mail_tag ||= list()
		junction.mail_tag += src.mail_tag
		break

	for (var/obj/machinery/disposal/mail/chute in src.loc)
		chute.name = "mail chute ([src.name])"
		chute.mail_tag = src.mail_tag
		chute.mailgroup = src.mailgroup
		chute.mailgroup2 = src.mailgroup2
		chute.message = src.message
		SPAWN(1 SECOND)
			chute.post_radio_status()

		break


/obj/mapping_helper/mailtag/manual
	name = "varedit mailtag spawn"

/obj/mapping_helper/mailtag/janitor
	name = "Janitor"
	mail_tag = "janitor"
	mailgroup = MGT_JANITOR
	message = TRUE

/obj/mapping_helper/mailtag/kitchen
	name = "Kitchen"
	mail_tag = "kitchen"
	mailgroup = MGT_CATERING
	message = TRUE

/obj/mapping_helper/mailtag/bar
	name = "Bar"
	mail_tag = "bar"
	mailgroup = MGT_CATERING
	message = TRUE

/obj/mapping_helper/mailtag/hydroponics
	name = "Hydroponics"
	mail_tag = "hydroponics"
	mailgroup = MGT_HYDROPONICS
	message = TRUE

/obj/mapping_helper/mailtag/ranch
	name = "Ranch"
	mail_tag = "ranch"
	mailgroup = MGT_HYDROPONICS
	message = TRUE

/obj/mapping_helper/mailtag/security
	name = "Security"
	mail_tag = "security"
	mailgroup = MGD_SECURITY
	message = TRUE

/obj/mapping_helper/mailtag/security/foyer
	name = "Security Foyer"
	mail_tag = "sec foyer"

/obj/mapping_helper/mailtag/security/brig
	name = "Brig"
	mail_tag = "brig"

/obj/mapping_helper/mailtag/security/detective
	name = "Detective"
	mail_tag = "detective"

/obj/mapping_helper/mailtag/security/armory
	name = "Armory"
	mail_tag = "armory"

/obj/mapping_helper/mailtag/security/hangar
	name = "Security Hangar"
	mail_tag = "security_hangar"

/obj/mapping_helper/mailtag/bridge
	name = "Bridge"
	mail_tag = "bridge"
	mailgroup = MGD_COMMAND
	message = TRUE

/obj/mapping_helper/mailtag/chapel
	name = "Chapel"
	mail_tag = "chapel"
	mailgroup = MGT_SPIRITUALAFFAIRS
	message = TRUE

/obj/mapping_helper/mailtag/engineering
	name = "Engineering"
	mail_tag = "engineering"
	mailgroup = MGD_ENGINEER
	message = TRUE

/obj/mapping_helper/mailtag/engineering/storage
	name = "Engineering Storage"
	mail_tag = "engineering_storage"

/obj/mapping_helper/mailtag/mechanics
	name = "Mechanics"
	mail_tag = "mechanics"
	mailgroup = MGD_ENGINEER
	message = TRUE

/obj/mapping_helper/mailtag/mining
	name = "Mining"
	mail_tag = "mining"
	mailgroup = MGT_MINING
	message = TRUE

/obj/mapping_helper/mailtag/qm
	name = "QM"
	mail_tag = "QM"
	mailgroup = MGT_CARGO
	message = TRUE

/obj/mapping_helper/mailtag/qm/refinery
	name = "Refinery"
	mail_tag = "refinery"

/obj/mapping_helper/mailtag/qm/warehouse
	name = "Warehouse"
	mail_tag = "warehouse"

/obj/mapping_helper/mailtag/tool_storage
	name = "Tool Storage"
	mail_tag = "storage"

/obj/mapping_helper/mailtag/sorting_room
	name = "Sorting Room"
	mail_tag = "sortingroom"

/obj/mapping_helper/mailtag/research
	name = "Research"
	mail_tag = "research"
	mailgroup = MGD_RESEARCH
	message = TRUE

/obj/mapping_helper/mailtag/research/telescience
	name = "Telescience"
	mail_tag = "telescience"

/obj/mapping_helper/mailtag/research/chemistry
	name = "Chemistry"
	mail_tag = "chemistry"

/obj/mapping_helper/mailtag/research/toxins
	name = "Toxins"
	mail_tag = "toxins"

/obj/mapping_helper/mailtag/research/artlab
	name = "Artifact lab"
	mail_tag = "artlab"

/obj/mapping_helper/mailtag/research/testchamber
	name = "Test Chamber"
	mail_tag = "testchamber"

/obj/mapping_helper/mailtag/research/robot_depot
	name = "Robot Depot"
	mail_tag = "buddy_depot"

/obj/mapping_helper/mailtag/research/hangar
	name = "Research Hangar"
	mail_tag = "research_hangar"

/obj/mapping_helper/mailtag/medbay
	name = "Medbay"
	mail_tag = "medbay"
	mailgroup = MGD_MEDICAL
	message = TRUE

/obj/mapping_helper/mailtag/medbay/robotics
	name = "Robotics"
	mail_tag = "robotics"
	mailgroup = MGT_ROBOTICS

/obj/mapping_helper/mailtag/medbay/genetics
	name = "Genetics"
	mail_tag = "genetics"
	mailgroup = MGT_GENETICS

/obj/mapping_helper/mailtag/medbay/pathology
	name = "Pathology"
	mail_tag = "pathology"

/obj/mapping_helper/mailtag/medbay/pharmacy
	name = "Pharmacy"
	mail_tag = "pharmacy"

/obj/mapping_helper/mailtag/medbay/morgue
	name = "Morgue"
	mail_tag = "morgue"

/obj/mapping_helper/mailtag/medbay/booth
	name = "Medical Booth"
	mail_tag = "medical booth"

/obj/mapping_helper/mailtag/medbay/psychiatry
	name = "Psychiatry"
	mail_tag = "psychiatry"

ABSTRACT_TYPE(/obj/mapping_helper/mailtag/command_office)
/obj/mapping_helper/mailtag/command_office
	mailgroup = MGD_COMMAND

/obj/mapping_helper/mailtag/command_office/cap
	name = "Captain's Office"
	mail_tag = "captain"

/obj/mapping_helper/mailtag/command_office/hop
	name = "Head of Personnel's Office"
	mail_tag = "head_of_personnel"

/obj/mapping_helper/mailtag/command_office/rd
	name = "Research Director's Office"
	mail_tag = "research_director"
	mailgroup2 = MGD_RESEARCH

/obj/mapping_helper/mailtag/command_office/md
	name = "Medical Director's Office"
	mail_tag = "medical_director"
	mailgroup2 = MGD_MEDICAL

/obj/mapping_helper/mailtag/command_office/ce
	name = "Chief Engineer's Office"
	mail_tag = "chief_engineer"
	mailgroup2 = MGD_ENGINEER

ABSTRACT_TYPE(/obj/mapping_helper/mailtag/checkpoint)
/obj/mapping_helper/mailtag/checkpoint
	mailgroup = MGD_SECURITY
	mailgroup2 = MGD_COMMAND
	message = TRUE

/obj/mapping_helper/mailtag/checkpoint/arrivals
	name = "Arrivals Checkpoint"
	mail_tag = "arrivals checkpoint"

/obj/mapping_helper/mailtag/checkpoint/escape
	name = "Escape Hallway Checkpoint"
	mail_tag = "escape checkpoint"

/obj/mapping_helper/mailtag/checkpoint/customs
	name = "Customs Checkpoint"
	mail_tag = "customs checkpoint"

/obj/mapping_helper/mailtag/checkpoint/sec_foyer
	name = "Security Foyer Checkpoint"
	mail_tag = "sec foyer checkpoint"

/obj/mapping_helper/mailtag/checkpoint/podbay
	name = "Pod Bay Checkpoint"
	mail_tag = "podbay checkpoint"

/obj/mapping_helper/mailtag/checkpoint/chapel
	name = "Chapel Checkpoint"
	mail_tag = "chapel checkpoint"

/obj/mapping_helper/mailtag/checkpoint/cargo
	name = "Cargo Checkpoint"
	mail_tag = "cargo checkpoint"

/obj/mapping_helper/mailtag/checkpoint/west
	name = "West Hallway Checkpoint"
	mail_tag = "west hallway checkpoint"

/obj/mapping_helper/mailtag/checkpoint/east
	name = "East Hallway Checkpoint"
	mail_tag = "east hallway checkpoint"

/obj/mapping_helper/mailtag/checkpoint/zeta
	name = "Outpost Checkpoint"
	mail_tag = "zeta checkpoint"

ABSTRACT_TYPE(/obj/mapping_helper/mailtag/public)
/obj/mapping_helper/mailtag/public

/obj/mapping_helper/mailtag/public/crew
	name = "Crew Quarters"
	mail_tag = "crew"

/obj/mapping_helper/mailtag/public/crewA
	name = "Crew A"
	mail_tag = "crewA"

/obj/mapping_helper/mailtag/public/crewB
	name = "Crew B"
	mail_tag = "crewB"

/obj/mapping_helper/mailtag/public/crewC
	name = "Crew C"
	mail_tag = "crewC"

/obj/mapping_helper/mailtag/public/arcade
	name = "Arcade"
	mail_tag = "arcade"

/obj/mapping_helper/mailtag/public/market
	name = "Market"
	mail_tag = "market"

/obj/mapping_helper/mailtag/public/cafeteria
	name = "Cafeteria"
	mail_tag = "cafeteria"

/obj/mapping_helper/mailtag/public/arrivals
	name = "Arrivals"
	mail_tag = "arrivals hallway"

/obj/mapping_helper/mailtag/public/escape
	name = "Escape"
	mail_tag = "escape hallway"

/obj/mapping_helper/mailtag/public/medbay_lobby
	name = "Medbay Lobby"
	mail_tag = "medbay lobby"

/obj/mapping_helper/mailtag/public/podbay
	name = "Pod Bay"
	mail_tag = "podbay"

/obj/mapping_helper/mailtag/public/barbershop
	name = "The Snip"
	mail_tag = "barbershop"

/obj/mapping_helper/mailtag/public/info_office
	name = "Information Office"
	mail_tag = "information office"

/obj/mapping_helper/mailtag/public/fitness
	name = "Fitness Room"
	mail_tag = "fitness room"

/obj/mapping_helper/mailtag/public/radio
	name = "Radio Booth"
	mail_tag = "radio booth"

/obj/mapping_helper/mailtag/public/fuq3
	name = "Fuq III"
	mail_tag = "fuq III"

/obj/mapping_helper/mailtag/public/news
	name = "News Office"
	mail_tag = "news office"

/obj/mapping_helper/mailtag/public/aviary
	name = "Aviary"
	mail_tag = "aviary"

/obj/mapping_helper/mailtag/public/library
	name = "Library"
	mail_tag = "library"
