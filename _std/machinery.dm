// debug stats for machines
//#define MACHINE_PROCESSING_DEBUG

//this file is not in defines or macros because this one is kind of a frankenstein
/// Time (in 1/10 of a second) before we can be manually reset again (machines).
#define NETWORK_MACHINE_RESET_DELAY 40

#define MACHINE_PROC_INTERVAL (0.4 SECONDS)

//lighting stuff
#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3

//apc stuff
#define EQUIP 1 	//! Power Channel: Equipment
#define LIGHT 2 	//! Power Channel: Lighting
#define ENVIRON 3 //! Power Channel: Enviroment
#define TOTAL 4		//! For total power used only

// bitflags for machine stat variable
#define BROKEN    (1<<0)		//! Status flag: machine non-functional
#define NOPOWER   (1<<1)		//! Status flag: no available power
#define POWEROFF  (1<<2)		//! Status flag: machine shut down, but may still draw a trace amount
#define MAINT     (1<<3)		//! Status flag: under maintainance
#define HIGHLOAD  (1<<4)		//! Status flag: using a lot of power
#define EMP_SHORT (1<<5)		//! Status flag: 1 second long emp duration, avoid stacking emp faster than 1Hz
#define REQ_PHYSICAL_ACCESS (1<<6) //! Can only be interacted with if adjacent and physical

//recharger stuff
/// multiplier for watts per tick != cell storage (eg: .002 means if there is a load of 1000 watts, 20 units will be taken from a cell per second)
#define CELLRATE 0.002
/// Cap for how fast cells charge, as a percentage-per-tick (.001 means cellcharge is capped to 1% per second)
#define CHARGELEVEL 0.001

//red smashy button stuff
#define SHIP_ALERT_GOOD 0
#define SHIP_ALERT_BAD 1

//conveyor belt operating modes
#define CONVEYOR_FORWARD 1
#define CONVEYOR_REVERSE -1
#define CONVEYOR_STOPPED 0

#define DATA_TERMINAL_IS_VALID_MASTER(terminal, master) (master && (get_turf(master) == terminal.loc))

#define PROCESSING_TIER_MULTI(target) (1<<(target.current_processing_tier-1)) //! Scalar to behave as if it were running at full speed
#define MACHINE_PROCS_PER_SEC (MACHINE_PROC_INTERVAL / (1 SECOND))

#define PROCESSING_FULL      1
#define PROCESSING_HALF      2
#define PROCESSING_QUARTER   3
#define PROCESSING_EIGHTH    4
#define PROCESSING_SIXTEENTH 5
#define PROCESSING_32TH			 6
// adjust PROCESSING_MAX_IN_USE as needed
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

var/global/list/list/list/processing_machines = generate_machinery_processing_buckets()
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
