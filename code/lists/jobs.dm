#define MGD_SPIRITUALAFFAIRS "spiritualaffairs"

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
	"Barman",
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
	"Captain" = "command",
	"Head of Personnel" = "command",
	"Head of Security" = "command",
	"Medical Director" = "command",
	"Quartermaster" = "cargo",
	"Botanist" = "botany",
	"Chaplain" = MGD_SPIRITUALAFFAIRS,
	"Medical Director" = "medresearch",
	"Roboticist" = "medresearch",
	"Geneticist" = "medresearch",
	"Medical Doctor" = "medbay")

//Used for PDA department paging.
var/list/page_departments = list(
	"Command" = "command",
	"Security" = "security",
	"Medbay" = "medbay",
	"Med Research" = "medresearch",
	"Research" = "science",
	"Cargo" = "cargo",
	"Botany" = "botany",
	"Bar / Kitchen" = "kitchen",
	"Spiritual Affairs" = MGD_SPIRITUALAFFAIRS)

/proc/get_all_jobs()
	return list("Assistant", "Detective", "Medical Doctor", "Captain", "Security Officer",
				"Geneticist", "Scientist", "Head of Personnel",
				"Chaplain", "Barman", "Janitor", "Chef", "Roboticist", "Quartermaster",
				"Chief Engineer","Engineer", "Miner", "Mechanic",
				"Research Director", "Medical Director", "Botanist", "Clown")
