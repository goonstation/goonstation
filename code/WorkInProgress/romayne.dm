
/obj/item/coderbutton
	name = "coderbutton"

	attack_self(mob/user)
		. = ..()
		var/obj/item/tank/T = new /obj/item/tank/empty
		var/o2_pct = tgui_input_number(user, "o2 pct", "out of 100%", 0) / 100
		var/tx_pct = tgui_input_number(user, "toxins pct", "out of 100%", 0) / 100
		var/fl_pct = tgui_input_number(user, "fallout pct", "out of 100%", 0) / 100
		T.air_contents.temperature = 600 KELVIN
		T.air_contents.oxygen = (o2_pct * (10 * ONE_ATMOSPHERE))*T.air_contents.volume/(R_IDEAL_GAS_EQUATION*T.air_contents.temperature)
		T.air_contents.radgas = (fl_pct * (10 * ONE_ATMOSPHERE))*T.air_contents.volume/(R_IDEAL_GAS_EQUATION*T.air_contents.temperature)
		T.air_contents.toxins = (tx_pct * (10 * ONE_ATMOSPHERE))*T.air_contents.volume/(R_IDEAL_GAS_EQUATION*T.air_contents.temperature)
		boutput(user, "O2: [T.air_contents.oxygen] mols")
		boutput(user, "Radgas: [T.air_contents.radgas] mols")
		boutput(user, "Plasma: [T.air_contents.toxins] mols")
		T.set_loc(user.loc)
		// add some items to test item-filled explosions with
		T.

/obj/machinery/portable_atmospherics/canister/toxins/hotplasma
	name = "hot plasma"
	starting_temperature = 1325 KELVIN

/obj/machinery/portable_atmospherics/canister/oxygen/coldoxygen
	name = "cold oxygen"
	starting_temperature = 175 KELVIN

/obj/machinery/portable_atmospherics/canister/radgas
	name = "fallout"
