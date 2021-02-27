// debugging stuff, possibly laggy, turn off when not using
/// Enables debug overlay which counts process_cell() calls per turf (viewable through info-overlays)
// #define ATMOS_PROCESS_CELL_STATS_TRACKING
/// Enables debug overlay which counts all atmos operations per turf (viewable through info-overlays)
// #define ATMOS_TILE_STATS_TRACKING
/// Puts a list of turfs which get processed a lot into `global.hotly_processed_turf` for debugging
// #define KEEP_A_LIST_OF_HOTLY_PROCESSED_TURFS 1

#if defined(ATMOS_TILE_STATS_TRACKING) && defined(KEEP_A_LIST_OF_HOTLY_PROCESSED_TURFS)
	#define ATMOS_TILE_OPERATION_DEBUG(turf) do { \
		turf?.atmos_operations++; \
		turf?.max_atmos_operations = max(turf?.max_atmos_operations, turf?.atmos_operations); \
		if(turf?.atmos_operations > air_master.current_cycle * KEEP_A_LIST_OF_HOTLY_PROCESSED_TURFS) hotly_processed_turfs |= turf ;\
		else hotly_processed_turfs -= turf ;\
		} while(0)
#elif defined(ATMOS_TILE_STATS_TRACKING)
	#define ATMOS_TILE_OPERATION_DEBUG(turf) do { \
		turf?.atmos_operations++; \
		turf?.max_atmos_operations = max(turf?.max_atmos_operations, turf?.atmos_operations); \
		} while(0)
#else
	#define ATMOS_TILE_OPERATION_DEBUG(turf)
#endif

// end debugging stuff



/// in kPa * L/(K * mol)
#define R_IDEAL_GAS_EQUATION	8.31
/// 1atm, now in kPa
#define ONE_ATMOSPHERE		101.325

#define CELL_VOLUME 2500	//liters in a cell
#define MOLES_CELLSTANDARD (ONE_ATMOSPHERE*CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION))	//moles in a 2.5 m^3 cell at 101.325 Pa and 20 degC

#define O2STANDARD 0.21
#define N2STANDARD 0.79

/// O2 standard value (21%)
#define MOLES_O2STANDARD MOLES_CELLSTANDARD*O2STANDARD
/// N2 standard value (79%)
#define MOLES_N2STANDARD MOLES_CELLSTANDARD*N2STANDARD

/// Moles in a standard cell after which visible gases are visible
#define MOLES_GAS_VISIBLE	1

/// Plasma Tile Overlay Id
#define GAS_IMG_PLASMA 0
/// N20 Tile Overlay Id
#define GAS_IMG_N2O 1

/// Enables gas overlays to have continuous opacity based on molarity
#define ALPHA_GAS_OVERLAYS
/// Factor that reduces the number of gas opacity levels, higher = better performance and worse visuals
#define ALPHA_GAS_COMPRESSION 4

#ifdef ALPHA_GAS_OVERLAYS
/// Given gas mixture's graphics var and gas overlay id and gas moles sets the graphics so the gas is rendered if there are right conditions
#define UPDATE_GAS_MIXTURE_GRAPHIC(VISUALS_STATE, OVERLAY_ID, MOLES) do { \
	var/_base_alpha = 0; \
	if(UNLINT(OVERLAY_ID == GAS_IMG_N2O)) {if(MOLES > MOLES_GAS_VISIBLE / 2) _base_alpha = 95 + MOLES / 8 * 180;} \
	else {if(MOLES > MOLES_GAS_VISIBLE) _base_alpha = 30 + MOLES / 40 * 125;} \
	VISUALS_STATE |= (round(min(255, _base_alpha) / ALPHA_GAS_COMPRESSION) << (OVERLAY_ID * 8)); \
	} while(0)
/// Given the VISUALS_STATE bit field and gas overlay id as defined above it possibly adds the right overlay to TILE_GRAPHIC
#define UPDATE_TILE_GAS_OVERLAY(VISUALS_STATE, TILE_GRAPHIC, OVERLAY_ID) \
	if(VISUALS_STATE & (0xff << (OVERLAY_ID * 8))) {\
		gas_overlays[1 + OVERLAY_ID].alpha = ((VISUALS_STATE >> (OVERLAY_ID * 8)) & 0xff) * ALPHA_GAS_COMPRESSION ; \
		TILE_GRAPHIC.overlays.Add(gas_overlays[1 + OVERLAY_ID]) \
	}
#else
/// Given gas mixture's graphics var and gas overlay id and gas moles sets the graphics so the gas is rendered if there are right conditions
#define UPDATE_GAS_MIXTURE_GRAPHIC(VISUALS_STATE, OVERLAY_ID, MOLES) \
	if(MOLES > MOLES_GAS_VISIBLE) \
		VISUALS_STATE |= (1 << OVERLAY_ID)
/// Given the VISUALS_STATE bit field and gas overlay id as defined above it possibly adds the right overlay to TILE_GRAPHIC
#define UPDATE_TILE_GAS_OVERLAY(VISUALS_STATE, TILE_GRAPHIC, OVERLAY_ID) \
	if(VISUALS_STATE & (1 << OVERLAY_ID)) \
		TILE_GRAPHIC.overlays.Add(gas_overlays[1 + OVERLAY_ID])
#endif

/// liters in a normal breath
#define BREATH_VOLUME 0.5
/// Amount of air to take a from a tile
#define BREATH_PERCENTAGE BREATH_VOLUME/CELL_VOLUME
/// Amount of air needed before pass out/suffocation commences
#define HUMAN_NEEDED_OXYGEN	MOLES_CELLSTANDARD*BREATH_PERCENTAGE*0.16


/// Minimum ratio of air that must move to/from a tile to suspend group processing
#define MINIMUM_AIR_RATIO_TO_SUSPEND 0.1
/// Minimum amount of air that has to move before a group processing can be suspended
#define MINIMUM_AIR_TO_SUSPEND MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_SUSPEND


#define MINIMUM_WATER_TO_SUSPEND MOLAR_DENSITY_WATER*CELL_VOLUME*MINIMUM_AIR_RATIO_TO_SUSPEND

#define MINIMUM_MOLES_DELTA_TO_MOVE MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_SUSPEND //Either this must be active
#define MINIMUM_TEMPERATURE_TO_MOVE	(T20C+100) 		  //or this (or both, obviously)

#define MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND 0.02
/// Minimum temperature difference before group processing is suspended
#define MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND 6
/// Minimum temperature difference before the gas temperatures are just set to be equa
#define MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER 1


#define MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION		(T20C+10)
#define MINIMUM_TEMPERATURE_START_SUPERCONDUCTION	(T20C+200)

#define FLOOR_HEAT_TRANSFER_COEFFICIENT 0.15
#define WALL_HEAT_TRANSFER_COEFFICIENT 0.12
#define SPACE_HEAT_TRANSFER_COEFFICIENT 0.20 //a hack to partly simulate radiative heat
#define OPEN_HEAT_TRANSFER_COEFFICIENT 0.40
#define WINDOW_HEAT_TRANSFER_COEFFICIENT 0.18 //a hack for now
	//Must be between 0 and 1. Values closer to 1 equalize temperature faster
	//Should not exceed 0.4 else strange heat flow occur

#define FIRE_MINIMUM_TEMPERATURE_TO_SPREAD	(120+T0C)
#define FIRE_MINIMUM_TEMPERATURE_TO_EXIST	(100+T0C)
#define FIRE_SPREAD_RADIOSITY_SCALE		0.85
/// Amount of heat released per mole of burnt carbon into the tile
#define FIRE_CARBON_ENERGY_RELEASED	  500000
/// Amount of heat released per mole of burnt plasma into the tile
#define FIRE_PLASMA_ENERGY_RELEASED	 3000000
#define FIRE_GROWTH_RATE			25000 //For small fires

//Plasma fire properties
#define PLASMA_MINIMUM_BURN_TEMPERATURE		(100+T0C)
#define PLASMA_UPPER_TEMPERATURE			(2370+T0C)
#define PLASMA_MINIMUM_OXYGEN_NEEDED		(2 MOLES)
#define PLASMA_MINIMUM_OXYGEN_PLASMA_RATIO	30
#define PLASMA_OXYGEN_FULLBURN				10

/// Hotspot Maximum Temperature without a catalyst
#define HOTSPOT_MAX_NOCAT_TEMPERATURE (80000)
/// Hotspot Maximum Temperature to maintain maths works to 1e35-sh in practice)
#define HOTSPOT_MAX_CAT_TEMPERATURE (INFINITY)

//Gas Reaction Flags
#define REACTION_ACTIVE (1<<0) 	//! Reaction is Active
#define COMBUSTION_ACTIVE (1<<1) //! Combustion is Active
#define CATALYST_ACTIVE (1<<2)	//! Hotspot Catalyst is Active

// tank properties

/// Tank starts leaking
#define TANK_LEAK_PRESSURE		(30.*ONE_ATMOSPHERE)
/// Tank spills all contents into atmosphere
#define TANK_RUPTURE_PRESSURE	(40.*ONE_ATMOSPHERE)

#define TANK_FRAGMENT_PRESSURE	(50.*ONE_ATMOSPHERE) // Boom 3x3 base explosion
#define TANK_FRAGMENT_SCALE	    (10.*ONE_ATMOSPHERE) // +1 for each SCALE kPa aboe threshold

#define TANK_MIN_RELEASE_PRESSURE 0
#define TANK_MAX_RELEASE_PRESSURE	(3*ONE_ATMOSPHERE)

// portable atmos properties

#define PORTABLE_ATMOS_MIN_RELEASE_PRESSURE (ONE_ATMOSPHERE/10)
#define PORTABLE_ATMOS_MAX_RELEASE_PRESSURE (10*ONE_ATMOSPHERE)

// pipe properties

#define NORMPIPERATE 30					//pipe-insulation rate divisor
#define HEATPIPERATE 8					//heat-exch pipe insulation

#define FLOWFRAC 0.99				// fraction of gas transfered per process

// archiving

// comment out to make atmos a bit less precise but less memory intensive and maybe a bit faster, may cause bugs
// #define ATMOS_ARCHIVING

#ifdef ATMOS_ARCHIVING
#define ARCHIVED(VAR) VAR##_archived
#else
#define ARCHIVED(VAR) VAR
#endif

// non-trace gases

/*
Adding new base gases should now in theory be as easy as adding them to this macro.
Format:
	MACRO(PREF ## gas_name ## SUFF, specific_heat_of_the_gas, human_readable_gas_name, ARGS) \

If you want to do a thing for all base gases do something like:
#define _DO_THE_THING(GAS, SPECIFIC_HEAT, GAS_NAME, ...) air.GAS = rand(100);
APPLY_TO_GASES(_DO_THE_THING)
#undef _DO_THE_THING
It's basically kind of a for loop but for base gases.

What can break when adding new gases:
	By default air scrubbers *will* scrub the gas, look at scrubber.dm to change that.
	Air alarms also require custom code to support new gases.
	Atmos retrofilters and non-retro filters also aren't adapted to this system yet but nothing uses those. Same for air sensors.
	TEG stats computer will ignore your new gas. Feel free to add it to reactor_stats.dm manually but good luck.
*/

#define SPECIFIC_HEAT_PLASMA		200
#define SPECIFIC_HEAT_O2		20
#define SPECIFIC_HEAT_N2		20
#define SPECIFIC_HEAT_CO2		30
#define SPECIFIC_HEAT_FARTS 69

#define _APPLY_TO_GASES(PREF, SUFF, MACRO, ARGS...) \
	MACRO(PREF ## oxygen ## SUFF, SPECIFIC_HEAT_O2, "O2", ARGS) \
	MACRO(PREF ## nitrogen ## SUFF, SPECIFIC_HEAT_N2, "N2", ARGS) \
	MACRO(PREF ## carbon_dioxide ## SUFF, SPECIFIC_HEAT_CO2, "CO2", ARGS) \
	MACRO(PREF ## toxins ## SUFF, SPECIFIC_HEAT_PLASMA, "Plasma", ARGS) \
	MACRO(PREF ## farts ## SUFF, SPECIFIC_HEAT_FARTS, "Farts", ARGS) \

#define APPLY_TO_GASES(MACRO, ARGS...) \
	MACRO(oxygen, SPECIFIC_HEAT_O2, "O2", ARGS) \
	MACRO(nitrogen, SPECIFIC_HEAT_N2, "N2", ARGS) \
	MACRO(carbon_dioxide, SPECIFIC_HEAT_CO2, "CO2", ARGS) \
	MACRO(toxins, SPECIFIC_HEAT_PLASMA, "Plasma", ARGS) \
	MACRO(farts, SPECIFIC_HEAT_FARTS, "Farts", ARGS)
//	_APPLY_TO_GASES(,, MACRO, ARGS) // replace with this when the langserver gets fixed >:(
// (the _APPLY_TO_GASES version compiles and works fine but the linter rejects it for now)

#ifdef ATMOS_ARCHIVING
#define APPLY_TO_ARCHIVED_GASES(MACRO, ARGS...) \
	_APPLY_TO_GASES(, _archived, MACRO, ARGS)
#else
#define APPLY_TO_ARCHIVED_GASES(MACRO, ARGS...) \
	APPLY_TO_GASES(MACRO, ARGS)
#endif

/**
	* Returns the color of a given gas ID.
	*
	* This is used only in the gas mixer computer as of now.
	*/
proc/gas_text_color(gas_id)
	switch(gas_id)
		if("oxygen")
			return "blue"
		if("nitrogen")
			return "gray"
		if("carbon_dioxide")
			return "orange"
		if("toxins")
			return "red"
		if ("farts")
			return "purple"
	return "black"

////////////////////////////
// gas calculation macros //
////////////////////////////

#define ATMOS_EPSILON 0.0001
#define MINIMUM_HEAT_CAPACITY	0.0003
#define MINIMUM_REACT_QUANTITY MINIMUM_HEAT_CAPACITY
#define QUANTIZE(variable)		(round(variable, ATMOS_EPSILON))

/// Given a gas mixture, zeroes it
#define _ZERO_GAS(GAS, _, _, MIXTURE) (MIXTURE).GAS = 0;
#define ZERO_BASE_GASES(MIXTURE) APPLY_TO_GASES(_ZERO_GAS, MIXTURE)
#define ZERO_ARCHIVED_BASE_GASES(MIXTURE) APPLY_TO_ARCHIVED_GASES(_ZERO_GAS, MIXTURE)

// total moles

#define _GAS_MOLES_ADD(GAS, _, _, MIXTURE) (MIXTURE).GAS +
#define BASE_GASES_TOTAL_MOLES(MIXTURE) (APPLY_TO_GASES(_GAS_MOLES_ADD, MIXTURE) 0)

/datum/gas_mixture/proc/total_moles_full()
	. = BASE_GASES_TOTAL_MOLES(src)
	for(var/datum/gas/trace_gas as() in trace_gases)
		. += trace_gas.moles

/// Returns total moles of a given gas mixture
#define TOTAL_MOLES(MIXTURE) (length((MIXTURE).trace_gases) ? (MIXTURE).total_moles_full() : BASE_GASES_TOTAL_MOLES(MIXTURE))

// pressure

#define MIXTURE_PRESSURE(MIXTURE) (TOTAL_MOLES(MIXTURE) * R_IDEAL_GAS_EQUATION * (MIXTURE).temperature / (MIXTURE).volume)

#define ADD_MIXTURE_PRESSURE(MIXTURE, VAR) do { \
	var/_moles = BASE_GASES_TOTAL_MOLES(MIXTURE); \
	if(length(MIXTURE.trace_gases)) { \
		for(var/datum/gas/trace_gas as() in MIXTURE.trace_gases) { \
			_moles += trace_gas.moles; \
		} \
	} \
	VAR += _moles * R_IDEAL_GAS_EQUATION * MIXTURE.temperature / MIXTURE.volume; \
} while (0)

// heat capacity

#define _GAS_HEAT_CAP(GAS, SPECIFIC_HEAT, _, MIXTURE) (MIXTURE).GAS * SPECIFIC_HEAT +
#define BASE_GASES_HEAT_CAPACITY(MIXTURE) (APPLY_TO_GASES(_GAS_HEAT_CAP, MIXTURE) 0)
#define BASE_GASES_ARCH_HEAT_CAPACITY(MIXTURE) (APPLY_TO_ARCHIVED_GASES(_GAS_HEAT_CAP, MIXTURE) 0)

/datum/gas_mixture/proc/heat_capacity_full()
	. = BASE_GASES_HEAT_CAPACITY(src)
	for(var/datum/gas/trace_gas as() in trace_gases)
		. += trace_gas.moles * trace_gas.specific_heat

#define HEAT_CAPACITY(MIXTURE) (length((MIXTURE).trace_gases) ? (MIXTURE).heat_capacity_full() : BASE_GASES_HEAT_CAPACITY(MIXTURE))

/datum/gas_mixture/proc/heat_capacity_archived_full()
	. = BASE_GASES_HEAT_CAPACITY(src)
	for(var/datum/gas/trace_gas as() in trace_gases)
		. += trace_gas.ARCHIVED(moles) * trace_gas.specific_heat

#define HEAT_CAPACITY_ARCHIVED(MIXTURE) (length((MIXTURE).trace_gases) ? (MIXTURE).heat_capacity_archived_full() : BASE_GASES_ARCH_HEAT_CAPACITY(MIXTURE))

#define THERMAL_ENERGY(MIXTURE) ((MIXTURE).temperature * HEAT_CAPACITY(MIXTURE))

// air stats

#define _MOLES_REPORT(GAS, _, NAME, MIXTURE) "[NAME]: [MIXTURE.GAS]<br>" +
#define MOLES_REPORT(MIXTURE) (APPLY_TO_GASES(_MOLES_REPORT, MIXTURE) "")

#define _MOLES_REPORT_PACKET(GAS, _, _, MIXTURE) "[#GAS]=[MIXTURE.GAS]&" +
#define MOLES_REPORT_PACKET(MIXTURE) (APPLY_TO_GASES(_MOLES_REPORT_PACKET, MIXTURE) "")

// requires var/total_moles = TOTAL_MOLES(MIXTURE) defined beforehand
#define _CONCENTRATION_REPORT(GAS, _, NAME, MIXTURE, SEP) "[NAME]: [round(MIXTURE.GAS / total_moles * 100)]%[SEP]" +
#define _UNKNOWN_CONCENTRATION_REPORT(MIXTURE, SEP) (length((MIXTURE).trace_gases) ? "Unknown: [round((total_moles - BASE_GASES_TOTAL_MOLES(MIXTURE)) / total_moles * 100)]%[SEP]": "")
#define CONCENTRATION_REPORT(MIXTURE, SEP) (APPLY_TO_GASES(_CONCENTRATION_REPORT, MIXTURE, SEP) _UNKNOWN_CONCENTRATION_REPORT(MIXTURE, SEP))

#define _LIST_CONCENTRATION_REPORT(GAS, _, NAME, MIXTURE, LIST) LIST += "[NAME]: [round(MIXTURE.GAS / total_moles * 100)]%";
#define _LIST_UNKNOWN_CONCENTRATION_REPORT(MIXTURE, LIST) LIST += (length((MIXTURE).trace_gases) ? "Unknown: [round((total_moles - BASE_GASES_TOTAL_MOLES(MIXTURE)) / total_moles * 100)]%": "")
#define LIST_CONCENTRATION_REPORT(MIXTURE, LIST) APPLY_TO_GASES(_LIST_CONCENTRATION_REPORT, MIXTURE, LIST) \
_LIST_UNKNOWN_CONCENTRATION_REPORT(MIXTURE, LIST)
