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

/// Map of departments to their mailgroup
var/list/page_departments = list(
	"Command" = MGD_COMMAND,
	"Security" = MGD_SECURITY,
	"Medical" = MGD_MEDICAL,
	"Research" = MGD_RESEARCH,
	"Engineering" = MGD_ENGINEER,
	"Supply" = MGD_SUPPLY,
	"Civilian" = MGD_CIVILIAN,
)
/// Map of department sub-teams to their mailgroup
var/list/page_teams = list(
	"Robotics" = MGT_ROBOTICS,
	"Genetics" = MGT_GENETICS,
	"Cargo" = MGT_CARGO,
	"Mining" = MGT_MINING,
	"Catering" = MGT_CATERING,
	"Hydroponics" = MGT_HYDROPONICS,
	"Janitor" = MGT_JANITOR,
	"Spiritual Affairs" = MGT_SPIRITUALAFFAIRS,
)

/proc/get_all_jobs()
	var/all_jobs = list()
	all_jobs += command_jobs
	all_jobs += security_jobs
	all_jobs += engineering_jobs
	all_jobs += science_jobs
	all_jobs += medical_jobs
	all_jobs += service_jobs
	all_jobs += "Staff Assistant"
	return all_jobs

var/list/command_jobs = list(
	"Captain",
	"Medical Director",
	"Research Director",
	"Head of Personnel",
	"Head of Security",
	"Chief Engineer",
	/*"Clown"*/
)
var/list/security_jobs = list(
	"Head of Security",
	"Nanotrasen Security Consultant",
	"Nanotrasen Special Operative",
	"Security Officer",
	"Security Assistant",
	"Detective",
)
var/list/engineering_jobs = list(
	"Chief Engineer",
	"Engineer",
	"Miner",
	"Quartermaster",
	"Technical Trainee",
)
var/list/medical_jobs = list(
	"Medical Director",
	"Medical Doctor",
	"Pharmacist",
	"Roboticist",
	"Geneticist",
	"Medical Trainee",
)
var/list/science_jobs = list(
	"Research Director",
	"Scientist",
	"Research Trainee",
)
var/list/service_jobs = list(
	"Head of Personnel",
	"Bartender",
	"Chef",
	"Botanist",
	"Rancher",
	"Angler",
	"Clown",
	"Chaplain",
	"Janitor",
	"Mail Courier",
	"Head of Deliverying",
	"Mail Bringer",
)

// we have to include alt names for jobs or they won't be sorted into categories correctly
var/list/command_gimmicks = list(
	"Head of Mining",
	"Nanotrasen Security Consultant" /* NTSC isn't a gimmick role, but for the sake of sorting, it practically is*/,
	"Communications Officer",
)
var/list/security_gimmicks = list(
	"Vice Officer",
	"Forensic Technician"
)
var/list/engineering_gimmicks = list(
	"Head of Mining",
	"Station Builder",
	"Atmospherish Technician",
)
var/list/medical_gimmicks = list(
	"Acupuncturist",
	"Anesthesiologist",
	"Cardiologist",
	"Counselor",
	"Dental Specialist",
	"Dermatologist",
	"Emergency Medicine Specialist",
	"Hematology Specialist",
	"Hepatology Specialist",
	"Immunology Specialist",
	"Internal Medicine Specialist",
	"Maxillofacial Specialist",
	"Medical Director's Assistant",
	"Neurological Specialist",
	"Ophthalmic Specialist",
	"Orthopaedic Specialist",
	"Otorhinolaryngology Specialist",
	"Plastic Surgeon",
	"Psychiatrist",
	"Psychologist",
	"Psychotherapist",
	"Therapist",
	"Thoracic Specialist",
	"Vascular Specialist",
)
var/list/science_gimmicks = list(
	"Toxins Researcher",
	"Chemist",
	"Test Subject",
)
var/list/service_gimmicks = list(
	"Lawyer",
	"Attorney",
	"Barber",
	"Hairdresser",
	"Mime",
	"Musician",
	"Apiculturist",
	"Apiarist",
	"Sous-Chef",
	"Waiter",
	"Life Coach",
	"Stowaway",
	"Hall Monitor",
)

