#define PROCESSING_FULL      1
#define PROCESSING_HALF      2
#define PROCESSING_QUARTER   3
#define PROCESSING_EIGHTH    4
#define PROCESSING_SIXTEENTH 5
#define PROCESSING_32TH			 6
// Uncomment and adjust PROCESSING_MAX_IN_USE as needed

//
//

#define PROCESSING_MAX_IN_USE PROCESSING_32TH

#define MACHINES_CONVEYORS				1 // Conveyor belts
#define MACHINES_ATMOSALERTS			2 // /obj/machinery/computer/atmosphere/alerts
#define MACHINES_COMMSCONSOLES		3 // /obj/machinery/computer/communications
#define MACHINES_POWER						4 // /obj/machinery/power, perhaps worth splitting further
#define MACHINES_PIPES						5 // /obj/machinery/pipes
#define MACHINES_BOTS							6 // /obj/machinery/bot
#define MACHINES_STATUSDISPLAYS		7 // /obj/machinery/ai_status_display
#define MACHINES_CLONINGCONSOLES 	8 // /obj/machinery/computer/cloning
#define	MACHINES_FISSION					9 // Contains both the computers and the reactors
#define MACHINES_FIREALARMS				10 // /obj/machinery/firealarm
#define MACHINES_PRINTERS					11 // /obj/machinery/networked/printer
#define MACHINES_SHIELDGENERATORS	12 // /obj/machinery/shield_generator
#define MACHINES_ANNOUNCEMENTS		13 // /obj/machinery/computer/announcement
#define MACHINES_INLETS						14 // /obj/machinery/inlet/filter
#define MACHINES_PORTALGENERATORS	15 // /obj/machinery/teleport/portal_generator
#define MACHINES_MASSDRIVERS			16 // /obj/machinery/mass_driver
#define MACHINES_MAINFRAMES				17 // /obj/machinery/networked/mainframe
#define MACHINES_ELEVATORCOMPS		18 // /obj/machinery/computer/sea_elevator, /obj/machinery/computer/icebase_elevator, /obj/machinery/computer/biodome_elevator
#define MACHINES_SHUTTLECOMPS			19 // /obj/machinery/computer/mining_shuttle, /obj/machinery/computer/research_shuttle, /obj/machinery/computer/prison_shuttle, /obj/machinery/computer/shuttle_bus
#define MACHINES_SHUTTLEPROPULSION 20 // /obj/machinery/shuttle/engine/propulsion
#define MACHINES_TURRETS					21	// /obj/machinery/turret
#define MACHINES_DRONERECHARGERS	22	// /obj/machinery/drone_recharger

// misc objects that get looped for that have relatively few instances and the loops are not performance critical: /obj/machinery/tripod, /obj/machinery/compressor, /obj/machinery/noise_maker, /obj/machinery/engine_laser_spawner
#define MACHINES_MISC							23

#define MACHINES_BEACONS					24 // /obj/machinery/beacon
#define MACHINES_SPARKERS					25 // /obj/machinery/sparker AND /obj/machinery/igniter
#define MACHINES_SIM							26	// Stuff that lets you access v-space: /obj/machinery/sim/vr_bed, /obj/machinery/sim/chair
#define MACHINES_PLANTPOTS				27 // Plantpots

#define MACHINES_REGISTRY_MAX MACHINES_PLANTPOTS

var/global/list/processing_machines = generate_machinery_processing_buckets()
var/global/list/machine_registry = generate_machine_registry()

/proc/generate_machine_registry()
	. = new /list(MACHINES_REGISTRY_MAX)
	for (var/i in 1 to MACHINES_REGISTRY_MAX)
		.[i] = list()

/proc/generate_machinery_processing_buckets()
	. = new /list(PROCESSING_MAX_IN_USE)
	for(var/i in 1 to PROCESSING_MAX_IN_USE)
		.[i] = new /list(1<<(i-1)) // 1 list for index 1, 2 for 2, 4 for 3, 8 for 4, 16 for 5, 32 for 6
		for (var/j in 1 to length(.[i]))
			.[i][j] = list()

/proc/all_processing_machines()
	. = list()
	for(var/i in 1 to PROCESSING_MAX_IN_USE)
		for(var/list/machines_list in processing_machines[i])
			. += machines_list

#define STOP_PROCESSING(target) do {\
	if (target.current_processing_tier) {\
		processing_machines[target.current_processing_tier][(target.processing_bucket%(1<<(target.current_processing_tier-1)))+1] -= target;\
		target.current_processing_tier = null;\
	};\
	} while (FALSE)

#define START_PROCESSING(target, priority) do {\
	if (target.current_processing_tier) { \
		STOP_PROCESSING(target);\
	};\
	target.current_processing_tier = priority;\
	processing_machines[priority][(target.processing_bucket%(1<<(priority-1)))+1] += target;\
	} while (FALSE)
