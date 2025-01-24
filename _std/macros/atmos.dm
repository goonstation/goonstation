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
#define R_IDEAL_GAS_EQUATION	8.3144626
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
/// Rad Particles Tile Overlay Id
#define GAS_IMG_RAD 2

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

//multi group checking
/// Our group processing check failed. We will suspend group processing.
#define SELF_CHECK_FAIL 0
/// Sharer group processing check failed. The sharer will suspend group processing.
#define SHARER_CHECK_FAIL -1
/// All group processing checks passed. Group processing can be preserved.
#define GROUP_CHECK_PASS 1

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
#define SPACE_HEAT_TRANSFER_COEFFICIENT 0.2 //a hack to partly simulate radiative heat
#define OPEN_HEAT_TRANSFER_COEFFICIENT 0.4
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

// Radgas properties
// Rad particles concentration required to contaminate stuff
#define RADGAS_MINIMUM_CONTAMINATION_MOLES 5
// how much stuff gets contaminated per tick
#define RADGAS_MAXIMUM_CONTAMINATION_TICK 5
// maximum amount stuff can be contaminated by radgas - lower values mean it'll spread out more, higher values mean it'll be more deadly
#define RADGAS_MAXIMUM_CONTAMINATION 10
// how much radstrength per mole of contamination is applied - how much radiation per radgas
#define RADGAS_CONTAMINATION_PER_MOLE 5
// only apply contamination to atoms on a turf every few seconds, instead of every tick
#define RADGAS_CONTAMINATION_COOLDOWN 3 SECONDS
// threshold for neutrons reacting with gasses
#define NEUTRON_PLASMA_REACT_MOLS_PER_LITRE 0.25
#define NEUTRON_CO2_REACT_MOLS_PER_LITRE 0.40
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
// "Archiving gas is how you ensure the order of turfs talking to each other is consistent. It's a key part of the sim actually working" - LemonInTheDark
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

#define SPECIFIC_HEAT_PLASMA	150
#define SPECIFIC_HEAT_O2		40
#define SPECIFIC_HEAT_N2		50
#define SPECIFIC_HEAT_CO2		40
#define SPECIFIC_HEAT_FARTS 	69
#define SPECIFIC_HEAT_RADGAS 	5
#define SPECIFIC_HEAT_N2O		60
#define SPECIFIC_HEAT_AGENTB	300

#define _APPLY_TO_GASES(PREF, SUFF, MACRO, ARGS...) \
	MACRO(PREF ## oxygen ## SUFF, SPECIFIC_HEAT_O2, "O2", ARGS) \
	MACRO(PREF ## nitrogen ## SUFF, SPECIFIC_HEAT_N2, "N2", ARGS) \
	MACRO(PREF ## carbon_dioxide ## SUFF, SPECIFIC_HEAT_CO2, "CO2", ARGS) \
	MACRO(PREF ## toxins ## SUFF, SPECIFIC_HEAT_PLASMA, "Plasma", ARGS) \
	MACRO(PREF ## farts ## SUFF, SPECIFIC_HEAT_FARTS, "Farts", ARGS) \
	MACRO(PREF ## radgas ## SUFF, SPECIFIC_HEAT_RADGAS, "Fallout", ARGS) \
	MACRO(PREF ## nitrous_oxide ## SUFF, SPECIFIC_HEAT_N2O, "N2O", ARGS) \
	MACRO(PREF ## oxygen_agent_b ## SUFF, SPECIFIC_HEAT_AGENTB, "Oxygen Agent B", ARGS) \

#define APPLY_TO_GASES(MACRO, ARGS...) \
	MACRO(oxygen, SPECIFIC_HEAT_O2, "O2", ARGS) \
	MACRO(nitrogen, SPECIFIC_HEAT_N2, "N2", ARGS) \
	MACRO(carbon_dioxide, SPECIFIC_HEAT_CO2, "CO2", ARGS) \
	MACRO(toxins, SPECIFIC_HEAT_PLASMA, "Plasma", ARGS) \
	MACRO(farts, SPECIFIC_HEAT_FARTS, "Farts", ARGS) \
	MACRO(radgas, SPECIFIC_HEAT_RADGAS, "Fallout", ARGS) \
	MACRO(nitrous_oxide, SPECIFIC_HEAT_N2O, "N2O", ARGS) \
	MACRO(oxygen_agent_b, SPECIFIC_HEAT_AGENTB, "Oxygen Agent B", ARGS) \
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
	* Garash - 2024: Hi, this is the tgui gas mixer computer speaking, we still use it!
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
		if("farts")
			return "purple"
		if("radgas")
			return "green"
	return "black"

////////////////////////////
// gas calculation macros //
////////////////////////////

#define ATMOS_EPSILON 0.0001
#define MINIMUM_HEAT_CAPACITY	0.0003
#define MINIMUM_REACT_QUANTITY MINIMUM_HEAT_CAPACITY
#define QUANTIZE(variable)		(round(variable, ATMOS_EPSILON))

// Zeroing gases
#define _ZERO_GAS(GAS, _, _, MIXTURE) (MIXTURE).GAS = 0;
/// Given a gas mixture, zeroes it.
#define ZERO_GASES(MIXTURE) APPLY_TO_GASES(_ZERO_GAS, MIXTURE)
/// Given a gas mixture, zeroes it's archived gases.
#define ZERO_ARCHIVED_GASES(MIXTURE) APPLY_TO_ARCHIVED_GASES(_ZERO_GAS, MIXTURE)

// total moles
#define _GAS_MOLES_ADD(GAS, _, _, MIXTURE) (MIXTURE).GAS +
/// Returns total moles of a given gas mixture
#define TOTAL_MOLES(MIXTURE) (APPLY_TO_GASES(_GAS_MOLES_ADD, MIXTURE) 0)

// pressure
/// Returns the mixture pressure.
#define MIXTURE_PRESSURE(MIXTURE) (TOTAL_MOLES(MIXTURE) * R_IDEAL_GAS_EQUATION * (MIXTURE).temperature / (MIXTURE).volume)
/// Add the pressure of the mixture to VAR.
#define ADD_MIXTURE_PRESSURE(MIXTURE, VAR) VAR += TOTAL_MOLES(MIXTURE) * R_IDEAL_GAS_EQUATION * MIXTURE.temperature / MIXTURE.volume

// heat capacity
#define _GAS_HEAT_CAP(GAS, SPECIFIC_HEAT, _, MIXTURE) (MIXTURE).GAS * SPECIFIC_HEAT +
/// Returns the total heat capacity of the given mixture
#define HEAT_CAPACITY(MIXTURE) (APPLY_TO_GASES(_GAS_HEAT_CAP, MIXTURE) 0)
/// Returns the total heat capacity of the given mixture's archived gases.
#define HEAT_CAPACITY_ARCHIVED(MIXTURE) (APPLY_TO_ARCHIVED_GASES(_GAS_HEAT_CAP, MIXTURE) 0)
/// Returns the total heat energy of the given mixture
#define THERMAL_ENERGY(MIXTURE) ((MIXTURE).temperature * HEAT_CAPACITY(MIXTURE))

// air stats

#define _MOLES_REPORT(GAS, _, NAME, MIXTURE) "[NAME]: [MIXTURE.GAS]<br>" +
#define MOLES_REPORT(MIXTURE) (APPLY_TO_GASES(_MOLES_REPORT, MIXTURE) "")

#define _MOLES_REPORT_PACKET(GAS, _, _, MIXTURE) "[#GAS]=[MIXTURE.GAS]&" +
#define MOLES_REPORT_PACKET(MIXTURE) (APPLY_TO_GASES(_MOLES_REPORT_PACKET, MIXTURE) "")

// requires var/total_moles = TOTAL_MOLES(MIXTURE) defined beforehand
#define _CONCENTRATION_REPORT(GAS, _, NAME, MIXTURE, SEP) "[NAME]: [round(MIXTURE.GAS / total_moles * 100)]%[SEP]" +
#define CONCENTRATION_REPORT(MIXTURE, SEP) (APPLY_TO_GASES(_CONCENTRATION_REPORT, MIXTURE, SEP) "")

#define _SIMPLE_CONCENTRATION_REPORT(GAS, _, NAME, MIXTURE, SEP) "[(round(MIXTURE.GAS / total_moles * 100)) ? "[NAME]: [round(MIXTURE.GAS / total_moles * 100)]%[SEP]" : ""]" +
#define SIMPLE_CONCENTRATION_REPORT(MIXTURE, SEP) (APPLY_TO_GASES(_SIMPLE_CONCENTRATION_REPORT, MIXTURE, SEP) "")

#define _LIST_CONCENTRATION_REPORT(GAS, _, NAME, MIXTURE, LIST) LIST += "[NAME]: [round(MIXTURE.GAS / total_moles * 100)]%";
#define LIST_CONCENTRATION_REPORT(MIXTURE, LIST) APPLY_TO_GASES(_LIST_CONCENTRATION_REPORT, MIXTURE, LIST)

//Possible states are "exposed" and "intact". sizes are "short", "medium" and "long". These are strings.
#define SET_PIPE_UNDERLAY(NODE, DIR, SIZE, COLOUR, HIDDEN) do { \
	if (UNLINT(HIDDEN)) { \
		src.ClearSpecificOverlays("[DIR]"); \
		break; \
		}  \
	var/pipe_state = NODE ? "intact" : "exposed"; \
	var/pipe_cached = pipe_underlay_cache["[pipe_state]_[DIR]_[SIZE]"]; \
	if (!pipe_cached) { \
		pipe_cached = icon('icons/obj/atmospherics/pipes/pipe_underlays.dmi', "[pipe_state]_[NODE ? null : SIZE]", DIR); \
		pipe_underlay_cache["[pipe_state]_[DIR]_[SIZE]"] = pipe_cached; \
		} \
	var/image/pipe_image = mutable_appearance(pipe_cached); \
	pipe_image.color = COLOUR ? COLOUR : "#B4B4B4"; \
	pipe_image.layer = src.layer - 0.001; \
	pipe_image.appearance_flags |= RESET_TRANSFORM | RESET_COLOR | KEEP_APART; \
	src.AddOverlays(pipe_image, "[DIR]"); \
	} while(0)

//Used solely for simple pipes. Possible states are "exposed" and "intact".
#define SET_SIMPLE_PIPE_UNDERLAY(NODE, DIR) do { \
	var/pipe_state = NODE ? "intact" : "exposed"; \
	var/pipe_cached = pipe_underlay_cache["[pipe_state]_[DIR]"]; \
	if (!pipe_cached) { \
		pipe_cached = icon('icons/obj/atmospherics/pipes/pipe.dmi', "ends_[pipe_state]", DIR); \
		pipe_underlay_cache["simple_[pipe_state]_[DIR]"] = pipe_cached; \
		} \
	var/image/pipe_image = mutable_appearance(pipe_cached); \
	pipe_image.color = src.color; \
	pipe_image.layer = src.layer - 0.001; \
	pipe_image.appearance_flags |= RESET_TRANSFORM | RESET_COLOR | KEEP_APART; \
	src.AddOverlays(pipe_image, "[DIR]"); \
	} while(0)

#define issimplepipe(X) istype(X, /obj/machinery/atmospherics/pipe/simple)

//check if we should hide our pipe ends
#define CHECKHIDEPIPE(X) (intact && issimulatedturf(X.loc) && X.level == UNDERFLOOR)
