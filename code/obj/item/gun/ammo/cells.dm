//////////////////////////////////// Power cells for eguns //////////////////////////
TYPEINFO(/obj/item/ammo/power_cell)
	/// Charge overlay `icon_state`s. Must be ordered ascending. Not used after `New()`, edit `charge_overlays` for live changes.
	var/charge_overlay_states = list("cell_1/5", "cell_2/5", "cell_3/5", "cell_4/5", "cell_5/5")

/obj/item/ammo/power_cell
	name = "Power Cell"
	desc = null // updated in `New()`
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 10000
	g_amt = 20000
	var/charge = 100
	var/max_charge = 100
	var/recharge_rate = 0
	var/recharge_delay = 0
	var/sound_load = 'sound/weapons/gunload_click.ogg'
	var/unusualCell = FALSE
	var/rechargable = TRUE
	var/component_type = /datum/component/power_cell
	/// Charge overlay images. Populated in `New()`. Would ideally be static or in typeinfo, but both approaches have issues.
	var/charge_overlays = null

	New()
		..()
		AddComponent(src.component_type, max_charge, charge, recharge_rate, recharge_delay, rechargable)
		RegisterSignal(src, COMSIG_UPDATE_ICON, /atom/proc/UpdateIcon)
		desc = "A power cell that holds a max of [src.max_charge]PU. Can be inserted into any energy gun, even tasers!"

		src.charge_overlays = list()
		for (var/state in src.get_typeinfo().charge_overlay_states)
			src.charge_overlays += image(src.icon, state)
		UpdateIcon()

	disposing()
		processing_items -= src
		..()

	emp_act()
		SEND_SIGNAL(src, COMSIG_CELL_USE, INFINITY)
		return

	update_icon()
		if (src.artifact || src.unusualCell)
			return
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			// ratio [0-1] of charge remaining
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			// convert ratio to index of correct state
			var/state_idx = round(ratio * length(src.charge_overlays), 1)
			if (state_idx > 0)
				UpdateOverlays(src.charge_overlays[state_idx], "charge_overlay", retain_cache=TRUE)
			else
				ClearSpecificOverlays(TRUE, "charge_overlay")
			inventory_counter.update_percent(ret["charge"], ret["max_charge"])

	examine()
		if (src.artifact)
			return list("You have no idea what this thing is!")
		. = ..()
		if (src.unusualCell)
			return
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			. += "There are [ret["charge"]]/[ret["max_charge"]] PU left!"

	proc/get_charge()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			return clamp(ret["charge"], 0, src.max_charge)

/obj/item/ammo/power_cell/empty
	charge = 0

/obj/item/ammo/power_cell/med_minus_power
	name = "Power Cell - 150"
	desc = "A power cell that holds a max of 150PU"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 15000
	g_amt = 30000
	charge = 150
	max_charge = 150

/obj/item/ammo/power_cell/med_power
	name = "Power Cell - 200"
	desc = "A power cell that holds a max of 200PU"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 15000
	g_amt = 30000
	charge = 200
	max_charge = 200

/obj/item/ammo/power_cell/med_plus_power
	name = "Power Cell - 250"
	desc = "A power cell that holds a max of 250PU"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 17500
	g_amt = 35000
	charge = 250
	max_charge = 250

/obj/item/ammo/power_cell/high_power
	name = "Power Cell - 300"
	desc = "A power cell that holds a max of 300PU"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 20000
	g_amt = 40000
	charge = 300
	max_charge = 300

/obj/item/ammo/power_cell/higherish_power
	name = "Power Cell - 400"
	desc = "A power cell that holds a max of 400PU"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 20000
	g_amt = 40000
	charge = 400
	max_charge = 400

/obj/item/ammo/power_cell/tiny
	name = "Power Cell - 50"
	desc = "A power cell that holds a max of 50PU"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 5000
	g_amt = 10000
	charge = 50
	max_charge = 50

/obj/item/ammo/power_cell/self_charging
	name = "Power Cell - Atomic"
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 60PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	m_amt = 18000
	g_amt = 38000
	charge = 60
	max_charge = 60
	recharge_rate = 2.5


/obj/item/ammo/power_cell/self_charging/custom
	name = "Power Cell"
	desc = "A custom-made power cell."

	onMaterialChanged()
		..()
		if(istype(src.material))

			max_charge = round((material.getProperty("electrical") ** 2) * 4, 25)

			recharge_rate = 0
			recharge_rate += material.getProperty("radioactive")/4
			recharge_rate += material.getProperty("n_radioactive")/2


		charge = max_charge

		AddComponent(/datum/component/power_cell, max_charge, charge, recharge_rate, recharge_delay)
		return


	proc/set_custom_mats(datum/material/coreMat, datum/material/genMat = null)
		src.setMaterial(coreMat)
		if(genMat)
			src.name = "[genMat.getName()]-doped [src.name]"

			var/conductivity = (2 * coreMat.getProperty("electrical") + genMat.getProperty("electrical")) / 3 //if self-charging, use a weighted average of the conductivities
			max_charge = round((conductivity ** 2) * 4, 25)

			recharge_rate = (coreMat.getProperty("radioactive") / 2 + coreMat.getProperty("n_radioactive") \
			+ genMat.getProperty("radioactive")  + genMat.getProperty("n_radioactive") * 2) / 6 //weight this too

			AddComponent(/datum/component/power_cell, max_charge, max_charge, recharge_rate, recharge_delay)

/obj/item/ammo/power_cell/self_charging/slowcharge
	name = "Power Cell - Atomic Slowcharge"
	desc = "A self-contained radioisotope power cell that very slowly recharges an internal capacitor. Holds 60PU."
	recharge_rate = 2 // cogwerks: raised from 1.0 because radbows were terrible!!!!!

/obj/item/ammo/power_cell/self_charging/tricklecharge
	name = "Power Cell - Trickle Charge"
	desc = "A prototype power cell with a koshmarite attenuator to recapture ambient and post-discharge energy. Holds 40PU."
	recharge_rate = 0.2
	charge = 40
	max_charge = 40

/obj/item/ammo/power_cell/self_charging/disruptor
	name = "Power Cell - Disruptor Charger"
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 100PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	m_amt = 18000
	g_amt = 38000
	charge = 100
	max_charge = 100

/obj/item/ammo/power_cell/self_charging/ntso_baton
	name = "Power Cell - NTSO Stun Baton"
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 100PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	charge = 150
	max_charge = 150
	recharge_rate = 4

/obj/item/ammo/power_cell/self_charging/ntso_signifer
	name = "Power Cell - NTSO D49"
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 250PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	charge = 250
	max_charge = 250
	recharge_rate = 5

/obj/item/ammo/power_cell/self_charging/ntso_signifer/bad
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 150PU."
	charge = 150
	max_charge = 150
	recharge_rate = 2

/obj/item/ammo/power_cell/self_charging/medium
	name = "Power Cell - Hicap RTG"
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 200PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	charge = 200
	max_charge = 200
	recharge_rate = 4

/obj/item/ammo/power_cell/self_charging/mediumbig
	name = "Power Cell - Fission"
	desc = "Half the power of a Fusion model power cell with a tenth of the cost. Holds 200PU."
	max_charge = 200
	charge = 200
	recharge_rate = 10

/obj/item/ammo/power_cell/self_charging/big
	name = "Power Cell - Fusion"
	desc = "A self-contained cold fusion power cell that quickly recharges an internal capacitor. Holds 400PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	m_amt = 18000
	g_amt = 38000
	charge = 400
	max_charge = 400
	recharge_rate = 20

/obj/item/ammo/power_cell/self_charging/lawbringer
	name = "Power Cell - Lawbringer Charger"
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 300PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	m_amt = 18000
	g_amt = 38000
	charge = 300
	max_charge = 300
	recharge_rate = 5

/obj/item/ammo/power_cell/self_charging/lawbringer/bad
	desc = "A self-contained radioisotope power cell that slowly recharges an internal capacitor. Holds 175PU."
	charge = 175
	max_charge = 175
	recharge_rate = 3

/obj/item/ammo/power_cell/self_charging/howitzer
	name = "Miniaturized SMES"
	desc = "This thing is huge! How did you even lift it put it into the gun?"
	charge = 2500
	max_charge = 2500

/obj/item/ammo/power_cell/self_charging/flockdrone
	name = "Flockdrone incapacitor cell"
	desc = "You should not be seeing this!"
	charge = 40
	max_charge = 40
	recharge_rate = 5
	component_type = /datum/component/power_cell/flockdrone

/obj/item/ammo/power_cell/redirect
	component_type = /datum/component/power_cell/redirect
	var/target_type = null
	var/internal = FALSE

TYPEINFO(/obj/item/ammo/power_cell/lasergat)
	charge_overlay_states = list("burst_laspistol-33", "burst_laspistol-66", "burst_laspistol-100")

/obj/item/ammo/power_cell/lasergat
	name = "Mod. 93R Repeating Laser Cell"
	desc = "This single-use cell has a proprietary port for injecting liquid coolant into a laser firearm."
	charge = 180
	max_charge = 180
	icon_state = "burst_laspistol"
	rechargable = FALSE

	New()
		..()
		desc = "This single-use cell has a proprietary port for injecting liquid coolant into a laser firearm. It has [src.max_charge]PU."

	update_icon()
		var/list/ret = list()
		overlays = null
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			var/ratio = min(1, ret["charge"] / ret["max_charge"]) * 100
			ratio = round(ratio, 33)
			inventory_counter.update_percent(ret["charge"], ret["max_charge"])
			switch(ratio)
				if(33)
					overlays += "burst_laspistol-33"
				if(66)
					overlays += "burst_laspistol-66"
				if(99)
					overlays += "burst_laspistol-100"
			return

/obj/item/ammo/power_cell/siren_orb
	name = "Siren Orb"
	desc = "You've somehow dislodged this from the resonator. Good Job!"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "siren_orb"
	charge = 400
	max_charge = 400
	recharge_rate = 10
