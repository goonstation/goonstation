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

var/list/job_mailgroup_list = list(
	"Captain" = MGD_COMMAND,
	"Head of Personnel" = MGD_COMMAND,
	"Head of Security" = MGD_COMMAND,
	"Medical Director" = MGD_COMMAND,
	"Research Director" = MGD_COMMAND,
	"Chief Engineer" = MGD_COMMAND,
	"Quartermaster" = MGD_CARGO,
	"Engineer" = MGD_STATIONREPAIR,
	"Technical Trainee" = MGD_STATIONREPAIR,
	"Janitor" = MGD_STATIONREPAIR,
	"Miner" = MGD_MINING,
	"Botanist" = MGD_BOTANY,
	"Medical Director" = MGD_MEDRESEACH,
	"Roboticist" = MGD_MEDRESEACH,
	"Geneticist" = MGD_MEDRESEACH,
	"Pathologist" = MGD_MEDRESEACH,
	"Medical Doctor" = MGD_MEDBAY,
	"Medical Trainee" = MGD_MEDBAY,
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
	"Spiritual Affairs" = MGD_SPIRITUALAFFAIRS,
	"Mining" = MGD_MINING)

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
	"Communications Officer",
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
)

// we have to include alt names for jobs or they won't be sorted into categories correctly
var/list/command_gimmicks = list(
	"Head of Mining",
	"Nanotrasen Security Consultant" /* NTSC isn't a gimmick role, but for the sake of sorting, it practically is*/,
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
	"Pharmacist",
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
	"Barber",
	"Mail Courier",
	"Head of Deliverying",
	"Mail Bringer",
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

