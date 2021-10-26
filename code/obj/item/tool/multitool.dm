/obj/item/device/multitool
	name = "multitool"
	desc = "You can use this on airlocks or APCs to try to hack them without cutting wires."
	icon = 'icons/obj/items/tools/multitool.dmi'
	inhand_image_icon = 'icons/mob/inhand/tools/multitool.dmi'
	icon_state = "multitool"

	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	tool_flags = TOOL_PULSING
	w_class = W_CLASS_SMALL

	force = 5.0
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3

	m_amt = 50
	g_amt = 20
	mats = 6

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] connects the wires from the multitool onto [his_or_her(user)] tongue and presses pulse. It's pretty shocking to look at.</b></span>")
		user.TakeDamage("head", 0, 160)
		return 1

/obj/item/device/multitool/afterattack(atom/target, mob/user , flag)
	//Get the NETID from bots/computers/everything else
	//There's a lot of local vars so this is somewhat evil code
	//Tried to keep it self contained, read only, and tried to do the appropriate checks
	var/net_id
	//And the wifi frequency
	var/frequency
	//Beacon and control frequencies for bots!
	var/control
	var/beacon
	//turf and data_terminal for powernet check
	var/turf/T = get_turf(target.loc)
	var/obj/machinery/power/data_terminal/test_link = locate() in T
	var/obj/item/implant/tracking/targetimplant = locate() in target.contents
	//net_id block, except computers, where we do it all in one go
	if (hasvar(target, "net_id"))
		net_id = target:net_id
	else if (hasvar(target, "botnet_id"))
		net_id = target:botnet_id
	else if (istype(target,/obj/machinery/computer3))
		var/obj/computer = target
		var/obj/item/peripheral/network/peripheral = locate(/obj/item/peripheral/network) in computer.contents
		var/obj/item/peripheral/network/radio/radioperipheral = locate(/obj/item/peripheral/network/radio) in computer.contents
		var/obj/item/peripheral/network/omni/omniperipheral = locate(/obj/item/peripheral/network/omni) in computer.contents
		if (peripheral)
			net_id = peripheral.net_id
		if (radioperipheral)
			frequency = radioperipheral.frequency
		//laptops are special too!
		if(omniperipheral)
			frequency = omniperipheral.frequency
	else if (targetimplant)
		net_id = targetimplant.net_id
		frequency = targetimplant.pda_alert_frequency

	//frequency block
	if (hasvar(target, "alarm_frequency"))
		frequency = target:alarm_frequency
	else if (hasvar(target, "freq"))
		frequency = target:freq
	else if (hasvar(target, "control_freq"))
		control = target:control_freq
		if (hasvar(target, "beacon_freq"))
			beacon = target:beacon_freq
	else if (hasvar(target, "radio_connection.frequency"))
		var/datum/radio_frequency/radiofreq = target:radio_connection
		frequency = radiofreq.frequency
	else if (hasvar(target, "frequency"))
		if(isnum(target:frequency) || istext(target:frequency))
			frequency = target:frequency
	//We'll do lockers safely since nothing else seems to store the frequency exactly like this
	else if (istype(target, /obj/storage/secure))
		var/obj/storage/secure/lockerfreq = target
		frequency = lockerfreq.radio_control.frequency

	if(net_id)
		boutput(user, "<span class='alert'>NETID#[net_id]</span>")
	if(frequency)
		boutput(user, "<span class='alert'>FREQ#[frequency]</span>")
	if(control)
		boutput(user, "<span class='alert'>CTRLFREQ#[control]</span>")
	if(beacon)
		boutput(user, "<span class='alert'>BCKNFREQ#[beacon]</span>")
	//Powernet Test Block
	//If we have a net_id but no wireless frequency, we're probably a powernet device
	if(isturf(T) && net_id && !frequency)
		if(!test_link || !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
			boutput(user, "<span class='alert'>ERR#NOLINK</span>")
	if (test_link)
		if (length(test_link.powernet.cables) < 1)
			boutput(user, "<span class='alert'>ERR#NOTATERM</span>")
