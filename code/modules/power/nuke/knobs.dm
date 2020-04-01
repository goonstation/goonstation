/************************************************
 *                                              *
 *  NUCLEAR ENGINE MASTER CONTROL COEFFICIENTS  *
 *                                              *
 ************************************************

 This file defines a "knob set" datum containing
 various coefficients/parameters/modifiers/factors
 used by the nuclear engine. This is meant to
 provide an easy, single interface for balancing
 the reactor's operation in a gameplay context

 This datum should only be instantiated ONCE per
 game by the reactor (fchamber) New() function,
 all consumers of the knobset should reference only
 the fchamber's knobset. This ensures modifications
 to the knobset affects all consumers equally.
 */


/datum/nuke_knobset
	var
		/* create this many energy units per 1 unit of heat consumed by the turbines */
		joules_per_heat = 1

		/* heat capacity of reactor & turbine cores */
		core_capacity = 100

		/* thermal mass of reactor & turbine cores */
		core_mass = 500

		/* mass units per fluid volume unit */
		fluid_mass = 1

		/* per-tick nuke debug messages */
		stfu = 1

	New()
		..()



