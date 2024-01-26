
/obj/item/devbutton
	name = "Romayne's Coding Button"
	desc = "What's it do? Who the fuck knows? Do you want to find out?"
	icon = 'icons/obj/items/bell.dmi'
	icon_state = "bell_kitchen"
	var/obj/item/tank/imcoder/test_tank = new /obj/item/tank/imcoder()

/obj/item/devbutton/attack_self(mob/user)
	. = ..()
	playsound(src, 'sound/effects/bell_ring.ogg', 30, FALSE)
	// Code fuckery goes here
	src.explosion_data()

/// Used to get the data for a csv file of explosion ranges since thats cool.
/obj/item/devbutton/proc/explosion_data()

	// min_ / max_ : lowest / highest temp of a gas
	// step_ : increment of temperature per iteration
	// oxy: oxygen | tox: plasma
	// temp: temperature, NOT temporary

	var/min_oxy = 100
	var/max_oxy = 300
	var/step_oxy = 1

	var/min_tox = 500
	var/max_tox = 2500
	var/step_tox = 1

	var/step_total = (1 + ceil( (max_oxy - min_oxy) / step_oxy )) * (1 + ceil( (max_tox - min_tox) / step_tox ))
	var/oxy_temp = min_oxy
	var/tox_temp = min_tox

	var/list/bomb_data = new/list(step_total,3)
	var/list_iter = 1
	var/fname = "testing_[min_oxy]_[max_oxy]_[step_oxy]_[min_tox]_[max_tox]_[step_tox].csv"
	var/fpath = "data/[fname]"

	while(oxy_temp <= max_oxy)
		while(tox_temp <= max_tox)
			bomb_data[list_iter] = src.test_bomb(oxy_temp, tox_temp)
			list_iter += 1
			tox_temp += step_tox
		tox_temp = min_tox
		oxy_temp += step_oxy

	// Writes the output as a CSV
	var/descriptors = list("oxygen", "plasma", "power")
	rustg_file_write("[jointext(descriptors,",")]\n[jointext(bomb_data,"\n")]",fpath)

#define PRESSURE_DELTA 506.625 // half the maximum fill pressure of a tank (5atm)
#define HANDHELD_TANK_VOLUME 70 // Litres in a handheld tank
/// Used to test a bomb safely and get the resultant explosion range
/obj/item/devbutton/proc/test_bomb(var/oxy_temp, var/tox_temp)
	var/range = -1

	var/datum/gas_mixture/air_contents = src.test_tank.air_contents

	var/mols_oxy = PRESSURE_DELTA * HANDHELD_TANK_VOLUME / (oxy_temp * R_IDEAL_GAS_EQUATION)
	var/mols_tox = PRESSURE_DELTA * HANDHELD_TANK_VOLUME / (tox_temp * R_IDEAL_GAS_EQUATION)

	var/oxy_heat_capacity = mols_oxy * SPECIFIC_HEAT_O2
	var/tox_heat_capacity = mols_tox * SPECIFIC_HEAT_PLASMA

	air_contents.oxygen = mols_oxy
	air_contents.toxins = mols_tox
	air_contents.temperature = (oxy_temp*oxy_heat_capacity + tox_temp*tox_heat_capacity) / (oxy_heat_capacity + tox_heat_capacity)

	var/ticks_limit = 20
	while (range == -1 && ticks_limit > 0)
		range = src.test_tank.process()
		ticks_limit -= 1

	test_tank.restore_original()

	return "[oxy_temp],[tox_temp],[range]"

#undef PRESSURE_DELTA
#undef HANDHELD_TANK_VOLUME
/// Used to create tanks which react and explode at different speeds to test reaction speed shenanagains
/obj/item/devbutton/proc/mult_test(mob/user)

	var/obj/item/tank/imcoder/tank1 = new /obj/item/tank/imcoder()
	var/obj/item/tank/imcoder/tank2 = new /obj/item/tank/imcoder()
	var/obj/item/tank/imcoder/tank3 = new /obj/item/tank/imcoder()

	tank1.creator = user
	tank2.creator = user
	tank3.creator = user

	tank1.air_contents.toxins = 3 MOLES
	tank1.air_contents.oxygen = 24 MOLES
	tank1.air_contents.temperature = 500 KELVIN
	tank1.name = "Mult = 1"

	tank2.air_contents.toxins = 3 MOLES
	tank2.air_contents.oxygen = 24 MOLES
	tank2.air_contents.temperature = 500 KELVIN
	tank2.air_contents.test_mult = 2
	tank2.name = "Mult = 2"

	tank3.air_contents.toxins = 3 MOLES
	tank3.air_contents.oxygen = 24 MOLES
	tank3.air_contents.temperature = 500 KELVIN
	tank3.air_contents.test_mult = 0.5
	tank3.name = "Mult = 0.5"

	tank1.loc = user.loc
	tank2.loc = user.loc
	tank3.loc = user.loc
