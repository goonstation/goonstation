
/obj/artifact/heatwave
	name = "artifact heatwave"
	associated_datum = /datum/artifact/heatwave

/datum/artifact/heatwave
	associated_object = /obj/artifact/heatwave
	type_name = "Heat Surge"
	rarity_weight = 365
	validtypes = list("ancient","martian","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch,/datum/artifact_trigger/heat)
	fault_blacklist = list(ITEM_ONLY_FAULTS,TOUCH_ONLY_FAULTS)
	activ_text = "starts emitting HUGE flames!"
	deact_text = "stops emitting flames."
	react_xray = list(12,35,85,5,"POROUS") //has pores for flames idk
	examine_hint = "It is covered in very conspicuous markings."
	var/recharge_time = 20 SECONDS
	var/recharging = 0
	post_setup()
		..()

	effect_activate(var/obj/O)
		if (..())
			return
		var/turf/T = get_turf(O)
		if (recharging)
			return
		if (recharge_time > 0)
			recharging = 1
		playsound(O.loc, "sound/effects/mag_fireballlaunch.ogg", 50, 0)
		T.visible_message("<span class='alert'><b>[O]</b> erupts into a huge column of flames! Holy shit!</span>")
		fireflash_sm(T, 4, 7000, 2000)
		SPAWN_DBG(recharge_time) //so some chemist doesnt discover how to make a liquid that can turn this thing on 900000 times in a second
			recharging = 0