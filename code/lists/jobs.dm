var/list/occupations = list(

	"Chief Engineer",
	"Mechanic","Mechanic",
	"Engineer","Engineer","Engineer",
	"Miner","Miner","Miner",
	"Security Officer", "Security Officer", "Security Officer",
//	"Vice Officer",
	"Detective",
	"Geneticist",
	"Scientist","Scientist", "Scientist",
	"Medical Doctor", "Medical Doctor",
	"Head of Personnel",
//	"Head of Security",
	"Research Director",
	"Medical Director",
	"Chaplain",
	"Roboticist",
//	"Hangar Mechanic", "Hangar Mechanic",
	"AI",
	"Cyborg", "Cyborg",
	"Bartender",
	"Chef",
	"Janitor",
	"Clown",
//	"Chemist","Chemist",
	"Quartermaster","Quartermaster",
	"Botanist","Botanist")
//	"Attorney at Space-Law")

var/list/assistant_occupations = list(
	"Staff Assistant")

//	"Mechanic",
//	"Atmospheric Technician","Atmospheric Technician","Atmospheric Technician",

var/list/job_mailgroup_list = list(
	"Captain" = MGD_COMMAND,
	"Head of Personnel" = MGD_COMMAND,
	"Head of Security" = MGD_COMMAND,
	"Medical Director" = MGD_COMMAND,
	"Research Director" = MGD_COMMAND,
	"Chief Engineer" = MGD_COMMAND,
	"Quartermaster" = MGD_CARGO,
	"Mechanic" = MGD_STATIONREPAIR,
	"Engineer" = MGD_STATIONREPAIR,
	"Janitor" = MGD_STATIONREPAIR,
	"Botanist" = MGD_BOTANY,
	"Medical Director" = MGD_MEDRESEACH,
	"Roboticist" = MGD_MEDRESEACH,
	"Geneticist" = MGD_MEDRESEACH,
	"Medical Doctor" = MGD_MEDBAY,
	"Chaplain" = MGD_SPIRITUALAFFAIRS)

//Used for PDA department paging.
var/list/page_departments = list(
	"Command" = MGD_COMMAND,
	"Security" = MGD_SECURITY,
	"Medbay" = MGD_MEDBAY,
	"Med Research" = MGD_MEDRESEACH,
	"Research" = MGD_SCIENCE,
	"Station Repair" = MGD_STATIONREPAIR,
	"Cargo" = MGD_CARGO,
	"Botany" = MGD_BOTANY,
	"Bar / Kitchen" = MGD_KITCHEN,
	"Spiritual Affairs" = MGD_SPIRITUALAFFAIRS)

/proc/get_all_jobs()
	return list("Assistant", "Detective", "Medical Doctor", "Captain", "Security Officer",
				"Geneticist", "Scientist", "Head of Personnel",
				"Chaplain", "Bartender", "Janitor", "Chef", "Roboticist", "Quartermaster",
				"Chief Engineer","Engineer", "Miner", "Mechanic",
				"Research Director", "Medical Director", "Botanist", "Clown")
