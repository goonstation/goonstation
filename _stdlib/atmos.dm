#define R_IDEAL_GAS_EQUATION	8.31 //kPa*L/(K*mol)
#define ONE_ATMOSPHERE		101.325	//kPa

#define CELL_VOLUME 2500	//liters in a cell
#define MOLES_CELLSTANDARD (ONE_ATMOSPHERE*CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION))	//moles in a 2.5 m^3 cell at 101.325 Pa and 20 degC

#define O2STANDARD 0.21
#define N2STANDARD 0.79

#define MOLES_O2STANDARD MOLES_CELLSTANDARD*O2STANDARD	// O2 standard value (21%)
#define MOLES_N2STANDARD MOLES_CELLSTANDARD*N2STANDARD	// N2 standard value (79%)

#define MOLES_PLASMA_VISIBLE	2 //Moles in a standard cell after which plasma is visible

#define BREATH_VOLUME 0.5	//liters in a normal breath
#define BREATH_PERCENTAGE BREATH_VOLUME/CELL_VOLUME
	//Amount of air to take a from a tile
#define HUMAN_NEEDED_OXYGEN	MOLES_CELLSTANDARD*BREATH_PERCENTAGE*0.16
	//Amount of air needed before pass out/suffocation commences


#define MINIMUM_AIR_RATIO_TO_SUSPEND 0.08
	//Minimum ratio of air that must move to/from a tile to suspend group processing
#define MINIMUM_AIR_TO_SUSPEND MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_SUSPEND
	//Minimum amount of air that has to move before a group processing can be suspended

#define MINIMUM_WATER_TO_SUSPEND MOLAR_DENSITY_WATER*CELL_VOLUME*MINIMUM_AIR_RATIO_TO_SUSPEND

#define MINIMUM_MOLES_DELTA_TO_MOVE MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_SUSPEND //Either this must be active
#define MINIMUM_TEMPERATURE_TO_MOVE	(T20C+100) 		  //or this (or both, obviously)

#define MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND 0.012
#define MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND 5
	//Minimum temperature difference before group processing is suspended
#define MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER 1
	//Minimum temperature difference before the gas temperatures are just set to be equal

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
#define FIRE_CARBON_ENERGY_RELEASED	  500000 //Amount of heat released per mole of burnt carbon into the tile
#define FIRE_PLASMA_ENERGY_RELEASED	 3000000 //Amount of heat released per mole of burnt plasma into the tile
#define FIRE_GROWTH_RATE			25000 //For small fires

//Plasma fire properties
#define PLASMA_MINIMUM_BURN_TEMPERATURE		(100+T0C)
#define PLASMA_UPPER_TEMPERATURE			(2370+T0C)
#define PLASMA_MINIMUM_OXYGEN_NEEDED		2
#define PLASMA_MINIMUM_OXYGEN_PLASMA_RATIO	30
#define PLASMA_OXYGEN_FULLBURN				10

// tank properties

#define TANK_LEAK_PRESSURE		(30.*ONE_ATMOSPHERE)	// Tank starts leaking
#define TANK_RUPTURE_PRESSURE	(40.*ONE_ATMOSPHERE) // Tank spills all contents into atmosphere

#define TANK_FRAGMENT_PRESSURE	(50.*ONE_ATMOSPHERE) // Boom 3x3 base explosion
#define TANK_FRAGMENT_SCALE	    (10.*ONE_ATMOSPHERE) // +1 for each SCALE kPa aboe threshold

// pipe properties

#define NORMPIPERATE 30					//pipe-insulation rate divisor
#define HEATPIPERATE 8					//heat-exch pipe insulation

#define FLOWFRAC 0.99				// fraction of gas transfered per process

// non-trace gases

#define SPECIFIC_HEAT_PLASMA		200
#define SPECIFIC_HEAT_O2		20
#define SPECIFIC_HEAT_N2		20
#define SPECIFIC_HEAT_CO2		30

#define _APPLY_TO_GASES(PREF, SUFF, MACRO, ARGS...) \
	MACRO(PREF ## oxygen ## SUFF, SPECIFIC_HEAT_O2, "O2", ARGS) \
	MACRO(PREF ## nitrogen ## SUFF, SPECIFIC_HEAT_N2, "N2", ARGS) \
	MACRO(PREF ## carbon_dioxide ## SUFF, SPECIFIC_HEAT_CO2, "CO2", ARGS) \
	MACRO(PREF ## toxins ## SUFF, SPECIFIC_HEAT_PLASMA, "Plasma", ARGS)

#define APPLY_TO_GASES(MACRO, ARGS...) \
	MACRO(oxygen, SPECIFIC_HEAT_O2, "O2", ARGS) \
	MACRO(nitrogen, SPECIFIC_HEAT_N2, "N2", ARGS) \
	MACRO(carbon_dioxide, SPECIFIC_HEAT_CO2, "CO2", ARGS) \
	MACRO(toxins, SPECIFIC_HEAT_PLASMA, "Plasma", ARGS)
//	_APPLY_TO_GASES(,, MACRO, ARGS) // replace with this when the langserver gets fixed >:(

#define APPLY_TO_ARCHIVED_GASES(MACRO, ARGS...) \
	_APPLY_TO_GASES(, _archived, MACRO, ARGS)

////////////////////////////
// gas calculation macros //
////////////////////////////

#define MINIMUM_HEAT_CAPACITY	0.0003
#define QUANTIZE(variable)		(round(variable,0.0001))

#define _ZERO_GAS(GAS, _, _, MIXTURE) (MIXTURE).GAS = 0;
#define ZERO_BASE_GASES(MIXTURE) APPLY_TO_GASES(_ZERO_GAS, MIXTURE)
#define ZERO_ARCHIVED_BASE_GASES(MIXTURE) APPLY_TO_ARCHIVED_GASES(_ZERO_GAS, MIXTURE)

// total moles

#define _GAS_MOLES_ADD(GAS, _, _, MIXTURE) (MIXTURE).GAS +
#define BASE_GASES_TOTAL_MOLES(MIXTURE) (APPLY_TO_GASES(_GAS_MOLES_ADD, MIXTURE) 0)

/datum/gas_mixture/proc/total_moles_full()
	. = BASE_GASES_TOTAL_MOLES(src)
	for(var/x in trace_gases)
		var/datum/gas/trace_gas = x
		. += trace_gas.moles

#define TOTAL_MOLES(MIXTURE) (length((MIXTURE).trace_gases) ? (MIXTURE).total_moles_full() : BASE_GASES_TOTAL_MOLES(MIXTURE))

// pressure

#define MIXTURE_PRESSURE(MIXTURE) (TOTAL_MOLES(MIXTURE) * R_IDEAL_GAS_EQUATION * (MIXTURE).temperature / (MIXTURE).volume)

#define ADD_MIXTURE_PRESSURE(MIXTURE, VAR) do { \
	var/_moles = BASE_GASES_TOTAL_MOLES(MIXTURE); \
	if(length(MIXTURE.trace_gases)) { \
		for(var/datum/gas/trace_gas in MIXTURE.trace_gases) { \
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
	for(var/x in trace_gases)
		var/datum/gas/trace_gas = x
		. += trace_gas.moles * trace_gas.specific_heat

#define HEAT_CAPACITY(MIXTURE) (length((MIXTURE).trace_gases) ? (MIXTURE).heat_capacity_full() : BASE_GASES_HEAT_CAPACITY(MIXTURE))

/datum/gas_mixture/proc/heat_capacity_archived_full()
	. = BASE_GASES_HEAT_CAPACITY(src)
	for(var/x in trace_gases)
		var/datum/gas/trace_gas = x
		. += trace_gas.moles_archived * trace_gas.specific_heat

#define HEAT_CAPACITY_ARCHIVED(MIXTURE) (length((MIXTURE).trace_gases) ? (MIXTURE).heat_capacity_archived_full() : BASE_GASES_ARCH_HEAT_CAPACITY(MIXTURE))

#define THERMAL_ENERGY(MIXTURE) ((MIXTURE).temperature * HEAT_CAPACITY(MIXTURE))

// air stats

#define _MOLES_REPORT(GAS, _, NAME, MIXTURE) "[NAME]: [MIXTURE.GAS]<br>" +
#define MOLES_REPORT(MIXTURE) (APPLY_TO_GASES(_MOLES_REPORT, MIXTURE) "")

// requires var/total_moles = TOTAL_MOLES(MIXTURE) defined beforehand
#define _CONCENTRATION_REPORT(GAS, _, NAME, MIXTURE, SEP) "[NAME]: [round(MIXTURE.GAS / total_moles * 100)]%[SEP]" +
#define _UNKNOWN_CONCETRATION_REPORT(MIXTURE) (length((MIXTURE).trace_gases) ? "Unknown: [round((total_moles - BASE_GASES_TOTAL_MOLES(MIXTURE)) / total_moles * 100)]%": "")
#define CONCENTRATION_REPORT(MIXTURE, SEP) (APPLY_TO_GASES(_CONCENTRATION_REPORT, MIXTURE, SEP) _UNKNOWN_CONCETRATION_REPORT(MIXTURE))
