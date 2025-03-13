/datum/buildmode/gas
	name = "Gas"
	desc = {"**************************************************************<br>
Left Click on turf 			   		   - Spawn gas at location
Right Click on Buildmode Button 	   - Select gas
Ctrl + Right Click on Buildmode Button - Select amount
**************************************************************"}
	icon_state = "buildmode1"
	var/gas = "toxins"
	var/amount = 100

	click_mode_right(ctrl, alt, shift)
		if (ctrl)
			src.amount = input(usr, "Amount in mols", "Amount") as num
		else
			var/list/gases = list()
#define _ADD_TO_LIST(GAS, ...) gases += #GAS;
			APPLY_TO_GASES(_ADD_TO_LIST)
#undef _ADD_TO_LIST
			var/picked = input(usr, "Select gas to spawn", "Select gas") as anything in gases
			src.gas = picked
			boutput(usr, "Selected gas [src.gas]")

		src.update_button_text()

	update_button_text()
		..("[src.gas] ([src.amount])")

	click_left(atom/object, ctrl, alt, shift)
		if (hasvar(object, "air_contents"))
			var/datum/gas_mixture/air_contents = object:air_contents
			if (air_contents)
				var/datum/gas_mixture/mixture = new()
				mixture.vars[src.gas] = src.amount
				air_contents.merge(mixture)
				boutput(usr, "Added [src.amount] mols of [src.gas] to [object]")
		else if (issimulatedturf(object))
			var/turf/simulated/T = object
			var/datum/gas_mixture/mixture = new()
			mixture.vars[src.gas] = src.amount
			T.assume_air(mixture)
			boutput(usr, "Released [src.amount] mols of [src.gas] on [T]")
