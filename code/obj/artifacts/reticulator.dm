/obj/machinery/reticulator
	name = "Reticulator"
	desc = "A fancy machine for doing fancy artifact things."
	icon = 'icons/obj/networked.dmi'
	icon_state = "heptemitter1"
	var/essence_shards = 0
	var/power_shards = 0
	var/spacetime_shards = 0
	var/omni_shards = 0

	ui_interact(mob/user, datum/tgui/ui)
	ui_data(mob/user)
	ui_act(action, params)
	ui_state()

	proc/break_down_artifact(obj/O)


/obj/item/artifact_resonator
	name = "Resonator"
	desc = "A useful device to assist in activating artifacts."
