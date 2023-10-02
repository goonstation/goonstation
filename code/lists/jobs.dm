var/list/occupations = list(

	"Chief Engineer",
	"Engineer","Engineer","Engineer",
	"Miner","Miner","Miner",
	"Security Officer", "Security Officer", "Security Officer",
//	"Vice Officer",
	"Detective",
	"Geneticist",
	"Pathologist",
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

// e-mails
var/list/job_mailgroup_list = list(
	"Captain" = MGD_COMMAND,
	"Head of Personnel" = MGD_COMMAND,
	"Head of Security" = MGD_COMMAND,
	"Medical Director" = MGD_COMMAND,
	"Medical Director" = MGD_MEDICAL,
	"Research Director" = MGD_COMMAND,
	"Chief Engineer" = MGD_COMMAND,
	"Quartermaster" = MGD_ENGINEERING,
	"Engineer" = MGD_ENGINEERING,
	"Janitor" = MGJ_JANITOR,
	"Miner" = MGD_ENGINEERING,
	"Botanist" = MGT_HYDROPONICS,
	"Rancher" = MGT_HYDROPONICS,
	"Roboticist" = MGD_MEDICAL,
	"Geneticist" = MGD_MEDICAL,
	"Medical Doctor" = MGD_MEDICAL,
	"Chaplain" = MGJ_SPIRITUAL)


// Groups that show on messenger by default
var/list/pageable_groups = list(
	"Command" = MGD_COMMAND,
	"Security" = MGD_SECURITY,
	"Medical" = MGD_MEDICAL,
	"Science" = MGD_SCIENCE,
	"Station Repair" = MGT_REPAIR,
	"Cargo" = MGJ_CARGO,
	"Hydroponics" = MGT_HYDROPONICS,
	"Bar / Kitchen" = MGT_CATERING,
	"Spiritual Affairs" = MGJ_SPIRITUAL,
	"Mining" = MGJ_MINING)

/proc/get_all_jobs()
	var/all_jobs = list()
	all_jobs += command_jobs
	all_jobs += security_jobs
	all_jobs += engineering_jobs
	all_jobs += medsci_jobs
	all_jobs += service_jobs
	all_jobs += "Staff Assistant"
	return all_jobs

var/list/command_jobs = list("Captain", "Medical Director", "Research Director", "Head of Personnel", "Head of Security", "Chief Engineer", "Communications Officer"/*"Clown"*/)
var/list/security_jobs = list("Head of Security", "Nanotrasen Security Consultant", "Nanotrasen Special Operative", "Security Officer", "Security Assistant", "Detective")
var/list/engineering_jobs = list("Chief Engineer", "Engineer", "Miner", "Quartermaster")
var/list/medical_jobs = list("Medical Director", "Medical Doctor", "Roboticist", "Geneticist")
var/list/science_jobs = list("Research Director", "Scientist")
var/list/medsci_jobs = medical_jobs + science_jobs
var/list/service_jobs = list("Head of Personnel", "Bartender", "Chef", "Botanist", "Rancher", "Angler", "Clown", "Chaplain", "Janitor")

var/list/command_gimmicks = list("Head of Mining", "Nanotrasen Security Consultant" /* NTSC isn't a gimmick role, but for the sake of sorting, it practically is*/)
var/list/security_gimmicks = list("Vice Officer", "Forensic Technician")
var/list/engineering_gimmicks = list("Head of Mining", "Station Builder", "Atmospherish Technician", "Technical Assistant")
var/list/medical_gimmicks = list("Medical Specialist", "Medical Assistant", "Pharmacist", "Psychiatrist", "Psychologist", "Psychotherapist", "Therapist", "Counselor")
var/list/science_gimmicks = list("Toxins Researcher", "Chemist", "Research Assistant", "Test Subject")
var/list/medsci_gimmicks = medical_gimmicks + science_gimmicks
var/list/service_gimmicks = list("Lawyer", "Barber", "Mailman", "Mime", "Musician", "Apiculturist", "Apiarist", "Sous-Chef", "Waiter", "Life Coach")

