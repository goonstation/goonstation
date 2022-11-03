

/obj/machinery/computer3
	name = "computer"
	desc = "A computer that uses the bleeding-edge command line OS ThinkDOS."
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer_generic"
	density = 1
	anchored = 1
	var/base_icon_state = "computer_generic"
	var/temp = "<b>Thinktronic BIOS V2.1</b><br>"
	var/temp_add = null
	var/obj/item/disk/data/fixed_disk/hd = null
	var/datum/computer/file/terminal_program/active_program
	var/datum/computer/file/terminal_program/host_program //active is set to this when the normal active quits, if available
	var/datum/computer/file/terminal_shell/os_shell
	var/list/processing_programs = list()
	var/obj/item/disk/data/floppy/diskette = null
	var/list/peripherals = list()
	var/restarting = 0 //Are we currently restarting the system?
	var/datum/light/light

	//Does it spawn with a card scanner? (It should, the main os needs one of these now.)
	var/setup_idscan_path = null
	var/setup_has_internal_disk = 0 //Do we use that magic disk drive that has no peripheral attached?
	var/setup_drive_size = 64
	var/setup_drive_type = null //Use this path for the hd
	var/setup_frame_type = /obj/computer3frame //What kind of frame does it spawn while disassembled.  This better be a type of /obj/compute3frame !!
	var/setup_starting_program = null //This program will start out installed on the drive
	var/setup_starting_os = null //This program will start out installed AND AS ACTIVE PROGRAM
	var/setup_starting_peripheral1 = null //Please note that the user cannot install more than 3.
	var/setup_starting_peripheral2 = null //And the os tends to need that third one for the card reader
	var/setup_os_string = null
	var/setup_font_color = "#19A319"
	var/setup_bg_color = "#1B1E1B"
	/// does it have a glow in the dark screen? see computer_screens.dmi
	var/glow_in_dark_screen = TRUE
	var/image/screen_image

	power_usage = 250

	generic //Generic computer, standard os and card scanner
		setup_drive_type = /obj/item/disk/data/fixed_disk/computer3
		setup_starting_os = /datum/computer/file/terminal_program/os/main_os
		setup_idscan_path = /obj/item/peripheral/card_scanner
		setup_has_internal_disk = 1

		personal
			name = "Personal Computer"
			icon_state = "old"
			base_icon_state = "old"
			setup_frame_type = /obj/computer3frame/desktop
			setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card/terminal
			setup_starting_peripheral2 = /obj/item/peripheral/sound_card
			setup_starting_program = /datum/computer/file/terminal_program/email

			personel_alt
				icon_state = "old_alt"
				base_icon_state = "old_alt"


		med_data
			name = "Medical computer"
			icon_state = "datamed"
			base_icon_state = "datamed"
			setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card
			setup_starting_peripheral2 = /obj/item/peripheral/printer
			setup_starting_program = /datum/computer/file/terminal_program/medical_records



			console_upper
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "medicalcomputer1"
				base_icon_state = "azungarcomputer_upper"
				setup_frame_type = /obj/computer3frame/azungarcomputer_upper

			console_lower
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "medicalcomputer2"
				base_icon_state = "azungarcomputer_lower"
				setup_frame_type = /obj/computer3frame/azungarcomputer_lower

		secure_data
			name = "Security computer"
			icon_state = "datasec"
			base_icon_state = "datasec"
			setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card
			setup_starting_peripheral2 = /obj/item/peripheral/network/radio/locked/pda/transmit_only
			setup_starting_program = /datum/computer/file/terminal_program/secure_records

			console_upper
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "securitycomputer1"
				base_icon_state = "securitycomputer1"
			console_lower
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "securitycomputer2"
				base_icon_state = "securitycomputer2"

		communications
			name = "Communications Console"
			icon_state = "comm"
			setup_starting_program = /datum/computer/file/terminal_program/communications
			setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card
			setup_starting_peripheral2 = /obj/item/peripheral/network/radio/locked/status
			setup_drive_size = 80

			console_upper
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "communications1"
				base_icon_state = "communications1"
			console_lower
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "communications2"
				base_icon_state = "communications2"

		disease_research
			name = "Disease Database"
			icon_state = "resdis"
			setup_starting_program = /datum/computer/file/terminal_program/disease_research
			setup_drive_size = 48

		artifact_research
			name = "Artifact Database"
			icon_state = "resart"
			setup_starting_program = /datum/computer/file/terminal_program/artifact_research
			setup_drive_size = 48

		hangar_control
			name = "Hangar Control"
			icon_state = "comm"
			//setup_starting_program = /datum/computer/file/terminal_program/hangar_control
			setup_drive_size = 48
		hangar_research
			name = "Hangar Research"
			icon_state = "resrob"
			//setup_starting_program = /datum/computer/file/terminal_program/hangar_research
			setup_drive_size = 48
		robotics_research
			name = "Robotics Database"
			icon_state = "resrob"
			setup_starting_program = /datum/computer/file/terminal_program/robotics_research
			setup_drive_size = 48
/*
		dna_scan
			name = "DNA Modifier Access Console"
			icon_state = "scanner"
			setup_starting_peripheral1 = /obj/item/peripheral/dnascanner_control
*/

		engine
			name = "Engine Control Console"
			icon_state = "engine"
			base_icon_state = "engine"

			setup_starting_program = /datum/computer/file/terminal_program/engine_control
			setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card
			setup_starting_peripheral2 = /obj/item/peripheral/network/radio/locked/pda/transmit_only
			setup_drive_size = 48

			console_upper
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "engine1"
				base_icon_state = "engine1"
			console_lower
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "engine2"
				base_icon_state = "engine2"
			manta_computer
				icon = 'icons/obj/large/32x96.dmi'
				icon_state = "nuclearcomputer"
				anchored = 2
				density = 1
				bound_height = 96
				bound_width = 32

		radio
			name = "wireless computer"
			setup_starting_peripheral1 = /obj/item/peripheral/network/radio

		basic_test
			name = "personal computer"
			//setup_starting_program = /datum/computer/file/terminal_program/basic
			setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card
			setup_starting_peripheral2 = /obj/item/peripheral/drive/cart_reader

		supply
			name = "Supply Ordering Computer"
			setup_idscan_path = /obj/item/peripheral/card_scanner/register

	terminal //Terminal computer, stripped down with less cards.
		name = "Terminal"
		icon_state = "dterm"
		base_icon_state = "dterm"
		setup_drive_size = 24
		setup_frame_type = /obj/computer3frame/terminal
		setup_starting_os = /datum/computer/file/terminal_program/os/terminal_os

		console_upper
			icon = 'icons/obj/computerpanel.dmi'
			icon_state = "dwaine1"
			base_icon_state = "dwaine1"
		console_lower
			icon = 'icons/obj/computerpanel.dmi'
			icon_state = "dwaine2"
			base_icon_state = "dwaine2"

		network
			name = "Network Terminal"
			//Terminal frames can only hold two cards please don't add more here
			setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card/terminal

			console_upper
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "dwaine1"
				base_icon_state = "dwaine1"
			console_lower
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "dwaine2"
				base_icon_state = "dwaine2"

		zeta
			name = "DWAINE Terminal"
			setup_idscan_path = /obj/item/peripheral/card_scanner
			setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card/terminal

			console_upper
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "dwaine1"
				base_icon_state = "dwaine1"
			console_lower
				icon = 'icons/obj/computerpanel.dmi'
				icon_state = "dwaine2"
				base_icon_state = "dwaine2"


	luggable //A portable(!!) computer 3. Cards cannot be exchanged.
		name = "portable computer"
		desc = "A much smaller computer workstation, designed to be hoisted around by 80s business executives."
		density = 0
		icon_state = "bcase"
		base_icon_state = "bcase"

		setup_drive_type = /obj/item/disk/data/fixed_disk/computer3
		setup_starting_os = /datum/computer/file/terminal_program/os/main_os
		setup_idscan_path = /obj/item/peripheral/card_scanner
		setup_has_internal_disk = 1
		setup_starting_peripheral1 = /obj/item/peripheral/network/omni
		setup_starting_peripheral2 = /obj/item/peripheral/cell_monitor
		setup_drive_size = 32

		var/obj/item/cell/cell //We have limited power! Immersion!!
		var/setup_charge_maximum = 15000
		var/obj/item/luggable_computer/personal/case //The object that holds us when we're all closed up.
		var/deployed = 1

		Exited(Obj, newloc)
			. = ..()
			if(Obj == src.cell)
				src.cell = null

		personal
			name = "Personal Laptop"
			desc = "This fine piece of hardware sports an incredible 2 kilobytes of RAM, all for a price slightly higher than the whole economy of greece."
			icon_state = "oldlap"
			base_icon_state = "oldlap"
			setup_starting_peripheral1 = /obj/item/peripheral/network/omni
			setup_starting_peripheral2 = /obj/item/peripheral/sound_card


/obj/machinery/computer3/New()
	..()

	light = new/datum/light/point
	light.set_brightness(0.4)
	light.attach(src)

	src.base_icon_state = src.icon_state

	if(glow_in_dark_screen)
		src.screen_image = image('icons/obj/computer_screens.dmi', src.icon_state, -1)
		screen_image.plane = PLANE_LIGHTING
		screen_image.blend_mode = BLEND_ADD
		screen_image.layer = LIGHTING_LAYER_BASE
		screen_image.color = list(0.33,0.33,0.33, 0.33,0.33,0.33, 0.33,0.33,0.33)
		src.UpdateOverlays(screen_image, "screen_image")

	SPAWN(0.4 SECONDS)
		if(ispath(src.setup_starting_peripheral1))
			new src.setup_starting_peripheral1(src) //Peripherals add themselves automatically if spawned inside a computer3

		if(ispath(src.setup_starting_peripheral2))
			new src.setup_starting_peripheral2(src)


		if(src.setup_idscan_path)
			new src.setup_idscan_path(src)

		if(!hd && (setup_drive_size > 0))
			if(src.setup_drive_type)
				src.hd = new src.setup_drive_type
				src.hd.set_loc(src)
			else
				src.hd = new /obj/item/disk/data/fixed_disk(src)
			src.hd.file_amount = src.setup_drive_size

		if(ispath(src.setup_starting_program))
			var/datum/computer/file/terminal_program/starting = new src.setup_starting_program

			src.hd.file_amount = max(src.hd.file_amount, starting.size)

			starting.transfer_holder(src.hd)
			//src.processing_programs += src.active_program

		if(ispath(src.setup_starting_os) && src.hd)
			var/datum/computer/file/terminal_program/os/os = new src.setup_starting_os
			if((src.hd.root.size + os.size) >= src.hd.file_amount)
				src.hd.file_amount += os.size

			os.setup_string = src.setup_os_string
			src.host_program = os
			src.host_program.master = src
			src.processing_programs += src.host_program
			if(!src.active_program)
				src.active_program = os

			src.hd.root.add_file(os)

		src.post_system()

		if (prob(60))
			switch(rand(1,2))
				if(1)
					setup_font_color = "#E79C01"
				if(2)
					setup_font_color = "#A5A5FF"
					setup_bg_color = "#4242E7"

	return

/obj/machinery/computer3/attack_hand(mob/user)
	if(..() && !istype(user, /mob/dead/target_observer/mentor_mouse_observer))
		return

	if(!user.literate)
		boutput(user, "<span class='alert'>You don't know how to read or write, operating a computer isn't going to work!</span>")
		return

	if (user.using_dialog_of(src))
		if (!src.temp)
			user << output(null, "comp3.browser:con_clear")

		if (src.temp_add)
			user << output(url_encode(src.temp_add), "comp3.browser:con_output")
/*
			if (src.current_user == user)
				src.temp += temp_add
				src.temp_add = null
*/
		update_peripheral_menu(user)
	else
		src.add_dialog(user)

		if (src.temp_add)
			src.temp += temp_add
			temp_add = null

		// preference is in a percentage of the default
		var/font_size = user.client ? (((user.client.preferences.font_size/100) * 10) || 10) : 10 // font size pref is null if you haven't changed it from the default, so we need extra logic
		var/dat = {"<title>Computer Terminal</title>
		<style type="text/css">
		body
		{
			background-color:#999876;
		}

		img
		{
			border-style: none;
		}

		#consolelog
		{
			border: 1px grey solid;
			height: 280px;
			width: 410px;
			overflow-y: scroll;
			word-wrap: break-word;
			word-break: break-all;
			background-color:[src.setup_bg_color];
			color:[src.setup_font_color];
			font-family: "Consolas", monospace;
			font-size:[font_size]pt;
		}

		#consoleshell
		{
			border: 1px grey solid;
			height: 280px;
			width: 410px;
			overflow-x: hidden;
			overflow-y: hidden;
			word-wrap: break-word;
			word-break: break-all;
			background-color:#1B1E1B;
			color:#19A319;
			font-family: "Consolas", monospace;
			font-size:10pt;
		}

		</style>
		<body scroll=no>
		<div id=\"consolelog\">[src.temp]</div>
		<script language="JavaScript">
			var objDiv = document.getElementById("consolelog");
			objDiv.scrollTop = objDiv.scrollHeight;

var lastVals = new Array();
var lastValsOffset = 0;
function keydownfunc (event)
{
	var theKey = (event.which) ? event.which : event.keyCode;
	if (theKey == 38)
	{
		if (lastVals.length > lastValsOffset)
		{
			document.getElementById("consoleinput_text").value = lastVals\[lastVals.length - lastValsOffset - 1];
			lastValsOffset++;
			if (lastValsOffset >= lastVals.length)
			{
				lastValsOffset = 0;
			}
		}
	}
	else if (theKey == 40)
	{
		if (lastValsOffset > 0)
		{
			lastValsOffset--;
			document.getElementById("consoleinput_text").value = lastVals\[lastVals.length - lastValsOffset - 1];
		}
	}
}

function lineEnter (ev)
{
	if (document.getElementById("consoleinput_text").value != null)
	{
		lastVals.push(document.getElementById("consoleinput_text").value);
		document.location = "byond://?src=\ref[src]&command=" + encodeURIComponent(document.getElementById("consoleinput_text").value);
		document.getElementById("consoleinput_text").focus();
		if (lastVals.length > 10)
		{
			lastVals.shift();
		}
	}
	ev.preventDefault();
	return false;
}

		</script>
		<br>
		<form name="consoleinput" action="byond://?src=\ref[src]" method="get" onsubmit="javascript:return lineEnter(event)">
			<input id = "consoleinput_text" type="text" name="command" maxlength="300" size="40" onKeyDown="javascript:return keydownfunc(event)">
			<input type="submit" value="Enter">
		</form>
		<table cellspacing=5><tr>"}
		if(setup_has_internal_disk)
			dat += "<td id=\"internaldisk\">Disk: <a href='byond://?src=\ref[src];disk=1'>[src.diskette ? "Eject" : "-----"]</a></td>"
		else
			dat += "<td id = \"internaldisk\" style=\"display: none;\"></td>"

		//Show up to two card "badges," so ID scanners can present a slot, etc
		var/count = 0
		for(var/obj/item/peripheral/C in src.peripherals)
			if(C.setup_has_badge) //If it has an interface to present here, let it
				dat += "<td id=\"badge[count]\">[C.return_badge()]</td>"
				count++

		if(!count)
			dat += "<td></td><td></td>"

		dat += {"<script language="JavaScript">
		document.consoleinput.command.focus();
		var printing = "";
		var t_count = 0;
		var last_output;

		function input_clear()
		{
			document.getElementById("consoleinput_text").value = '';
		}

		function setInternalDisk(t)
		{
			document.getElementById("internaldisk").innerHTML = t;
		}

		function setBadge0(t)
		{
			document.getElementById("badge0").innerHTML = t;
		}

		function setBadge1(t)
		{
			document.getElementById("badge1").innerHTML = t;
		}


		function setBadge2(t)
		{
			document.getElementById("badge2").innerHTML = t;
		}

		function con_output(t)
		{
			if (printing.length > 0)
			{
				var toadd = t.split("<br>");
				if (t.substr(t.length - 4,4) == "<br>")
				{
					toadd.pop();
				}
				printing = printing.concat(toadd);
			}
			else
			{
				printing = t.split("<br>");
				if (t.substr(t.length - 4,4) == "<br>")
				{
					printing.pop();
				}
				last_output = window.setInterval((function () {real_con_output();}), 10);
			}

		}

		function real_con_output()
		{
			if (printing.length > 0)
			{
				var t_bit = printing.shift();
				if (t_bit != undefined)
				{
					objDiv.innerHTML += t_bit + "<br>";
				}
				objDiv.scrollTop = objDiv.scrollHeight;
				return;
			}

			window.clearTimeout(last_output);
			return;
		}

		function con_clear()
		{
			printing.length = 0;
			objDiv.innerHTML = "";
		}

		</script>"}

		dat += {"<td><a href='byond://?src=\ref[src];restart=1'>Restart</a></td>
		</body>"}

		user.Browse(dat,"window=comp3;size=455x405")
		onclose(user,"comp3")
	return

/obj/machinery/computer3/proc/update_peripheral_menu(mob/user as mob)
	var/count = 0
	for (var/obj/item/peripheral/pCard in src.peripherals)
		if (pCard.setup_has_badge)
			user <<  output(url_encode(pCard.return_badge()),"comp3.browser:setBadge[count]")
			count++

	return

/obj/machinery/computer3/Topic(href, href_list)
	if(..())
		return

	src.add_dialog(usr)

	if((href_list["command"]) && src.active_program)
		usr << output(null, "comp3.browser:input_clear")
		src.active_program.input_text(href_list["command"])
		playsound(src.loc, "keyboard", 50, 1, -15)

	else if(href_list["disk"])
		if (src.diskette)
			//Ai/cyborgs cannot press a physical button from a room away.
			if((issilicon(usr) || isAI(usr)) && BOUNDS_DIST(src, usr) > 0)
				boutput(usr, "<span class='alert'>You cannot press the ejection button.</span>")
				return

			for(var/datum/computer/file/terminal_program/P in src.processing_programs)
				P.disk_ejected(src.diskette)

			usr.put_in_hand_or_eject(src.diskette) // try to eject it into the users hand, if we can
			src.diskette = null
			usr << output(url_encode("Disk: <a href='byond://?src=\ref[src];disk=1'>-----</a>"),"comp3.browser:setInternalDisk")
		else
			var/obj/item/I = usr.equipped()
			if (istype(I, /obj/item/disk/data/floppy))
				usr.drop_item()
				I.set_loc(src)
				src.diskette = I
				usr << output(url_encode("Disk: <a href='byond://?src=\ref[src];disk=1'>Eject</a>"),"comp3.browser:setInternalDisk")
			else if (istype(I, /obj/item/magtractor))
				var/obj/item/magtractor/mag = I
				if (istype(mag.holding, /obj/item/disk/data/floppy))
					I = mag.holding
					mag.dropItem(0)
					I.set_loc(src)
					src.diskette = I
					usr << output(url_encode("Disk: <a href='byond://?src=\ref[src];disk=1'>Eject</a>"),"comp3.browser:setInternalDisk")

	else if(href_list["restart"] && !src.restarting)
		src.restart()

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer3/updateUsrDialog()
	..()
	if (src.temp_add)
		src.temp += src.temp_add
		src.temp_add = null

/obj/machinery/computer3/process()
	if(status & BROKEN)
		return
	..()
	if(status & NOPOWER)
		return
	use_power(250)

	for(var/datum/computer/file/terminal_program/P in src.processing_programs)
		P.process()

	return

/obj/machinery/computer3/power_change()
	if(status & BROKEN)
		icon_state = src.base_icon_state
		src.icon_state += "b"
		light.disable()
		if(glow_in_dark_screen)
			src.ClearSpecificOverlays("screen_image")

	else if(powered())
		icon_state = src.base_icon_state
		status &= ~NOPOWER
		light.enable()
		if(glow_in_dark_screen)
			src.UpdateOverlays(screen_image, "screen_image")
	else
		SPAWN(rand(0, 15))
			icon_state = src.base_icon_state
			src.icon_state += "0"
			status |= NOPOWER
			light.disable()
			if(glow_in_dark_screen)
				src.ClearSpecificOverlays("screen_image")

/obj/machinery/computer3/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/disk/data/floppy)) //INSERT SOME DISKETTES
		if ((!src.diskette) && src.setup_has_internal_disk)
			user.drop_item()
			W.set_loc(src)
			src.diskette = W
			boutput(user, "You insert [W].")
			if(user.using_dialog_of(src))
				src.updateUsrDialog()
				user << output(url_encode("Disk: <a href='byond://?src=\ref[src];disk=1'>Eject</a>"),"comp3.browser:setInternalDisk")
			return
		else if(src.diskette)
			boutput(user, "<span class='alert'>There's already a disk inside!</span>")
		else if(!src.setup_has_internal_disk)
			boutput(user, "<span class='alert'>There's no visible peripheral device to insert the disk into!</span>")

	else if (isscrewingtool(W))
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/computer3/proc/unscrew_monitor,\
		list(W, user), W.icon, W.icon_state, null, null)

	else
		src.Attackhand(user)
	return

/obj/machinery/computer3/proc/unscrew_monitor(obj/item/W as obj, mob/user as mob)
	if(!ispath(setup_frame_type, /obj/computer3frame))
		src.setup_frame_type = /obj/computer3frame
	var/obj/computer3frame/A = new setup_frame_type( src.loc )
	A.computer_type = src.type
	if(src.material) A.setMaterial(src.material)
	A.created_icon_state = src.base_icon_state
	A.set_dir(src.dir)
	if (src.status & BROKEN)
		boutput(user, "<span class='notice'>The broken glass falls out.</span>")
		var/obj/item/raw_material/shard/glass/G = new /obj/item/raw_material/shard/glass
		G.set_loc( src.loc )
		A.state = 3
		A.icon_state = "3"
	else
		boutput(user, "<span class='notice'>You disconnect the monitor.</span>")
		A.state = 4
		A.icon_state = "4"

	for (var/obj/item/peripheral/C in src.peripherals)
		C.set_loc(A)
		A.peripherals.Add(C)
		C.uninstalled()

	if(src.diskette)
		src.diskette.set_loc(src.loc)
		src.diskette = null

	if(src.hd)
		src.hd.set_loc(A)
		A.hd = src.hd
		src.hd = null

	A.mainboard = new /obj/item/motherboard(A)
	A.mainboard.created_name = src.name
	A.mainboard.integrated_floppy = src.setup_has_internal_disk


	A.anchored = 1
	//dispose()
	src.dispose()

/obj/machinery/computer3/meteorhit(var/obj/O as obj)
	if(status & BROKEN)
		//dispose()
		src.dispose()
	set_broken()
	var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
	smoke.set_up(5, 0, src)
	smoke.start()
	return

/obj/machinery/computer3/ex_act(severity)
	switch(severity)
		if(1)
			//dispose()
			src.dispose()
			return
		if(2)
			if (prob(50))
				set_broken()
		if(3)
			if (prob(25))
				set_broken()
		else
	return

/obj/machinery/computer3/emp_act()
	..()
	if(prob(20))
		src.set_broken()
	return

/obj/machinery/computer3/blob_act(var/power)
	if (prob(power * 2.5))
		set_broken()
		src.set_density(0)

/obj/machinery/computer3/disposing()
	if (hd)
		if (hd.loc == src)
			hd.dispose()
		hd = null

	if (diskette)
		if (diskette.loc == src)
			diskette.dispose()
		diskette = null

	if (peripherals)
		for (var/obj/P in peripherals)
			if (P.loc == src)
				P.dispose()

		peripherals.len = 0
		peripherals = null

	if (processing_programs)
		src.processing_programs.len = 0
		src.processing_programs = null

	active_program = null
	host_program = null

	..()

/obj/machinery/computer3/proc

	run_program(datum/computer/file/terminal_program/program)
		if((!program) || (!program.holder))
			return 0

		if(!(program.holder in src))
	//		boutput(world, "Not in src")
			program = new program.type
			program.transfer_holder(src.hd)

		if(program.master != src)
			program.master = src

		if(!src.host_program && istype(program, /datum/computer/file/terminal_program/os))
			src.host_program = program

		if(!(program in src.processing_programs))
			src.processing_programs += program

		src.active_program = program
		src.active_program.initialize()
		return 1

	//Stop processing the current active program and make the host active again
	unload_program(datum/computer/file/terminal_program/program)
		if(!program)
			return 0

		if(program == src.host_program)
			return 0

		src.processing_programs -= program
		if(src.active_program == program)
			src.active_program = src.host_program

		return 1

	delete_file(datum/computer/file/theFile)
		//boutput(world, "Deleting [file]...")
		if((!theFile) || (!theFile.holder) || (theFile.holder.read_only))
			//boutput(world, "Cannot delete :(")
			return 0

		//Don't delete the running program you jerk
		if(src.active_program == theFile || src.host_program == theFile)
			src.active_program = null

		//boutput(world, "Now calling del on [file]...")
		//qdel(file)
		theFile.dispose()
		return 1

	send_command(command, datum/signal/signal, target_ref)
		//for(var/obj/item/peripheral/P in src.peripherals)
		//	P.receive_command(src, command, signal)

		. = 1
		var/obj/item/peripheral/P = locate(target_ref) in src.peripherals
		if(istype(P))
			. = P.receive_command(src, command, signal)

		if(signal)
			qdel(signal)
		return

	receive_command(obj/source, command, datum/signal/signal)
		if(source in src.contents)

			for(var/datum/computer/file/terminal_program/P in src.processing_programs)
				P.receive_command(src, command, signal)

			qdel(signal)
		return

	set_broken()
		icon_state = src.base_icon_state
		icon_state += "b"
		status |= BROKEN
		light.disable()

	restart()
		if(src.restarting)
			return
		src.restarting = 1
		src.active_program = null
		src.host_program?.restart()
		src.host_program = null
		src.processing_programs = new
		src.temp = null
		src.temp_add = "Restarting system...<br>"
		src.updateUsrDialog()
		playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, -15)
		SPAWN(2 SECONDS)
			src.restarting = 0
			src.post_system()

		return

	post_system()
		src.temp_add += "Initializing system...<br>"

		if(!src.hd)
			src.temp_add += "<font color=red>1701 - NO FIXED DISK</font><br>"

		if(src.host_program) //Let the starting programs set up vars or whatever
			src.host_program.initialize()

			if(src.active_program && src.active_program != src.host_program) //Don't init one twice!
				src.active_program.initialize()

		else
			if(src.diskette && src.diskette.root)
				var/datum/computer/file/terminal_program/os/newos = locate(/datum/computer/file/terminal_program/os) in src.diskette.root.contents

				if(newos && istype(newos))
					src.temp_add += "Booting from diskette...<br>"
					src.run_program(newos)
				else
					src.temp_add += "<font color=red>Non-system disk or disk error.</font><br>"

			if(!src.host_program && src.hd && src.hd.root)
				var/datum/computer/file/terminal_program/os/newos = locate(/datum/computer/file/terminal_program/os) in src.hd.root.contents

				if(newos && istype(newos))
					src.temp_add += "Booting from fixed disk...<br>"
					src.run_program(newos)
				else
					src.temp_add += "<font color=red>Unable to boot from fixed disk.</font><br>"

			if(!src.host_program)
				var/success = 0
				for(var/obj/item/disk/data/D in src)
					if(D == src.hd || D == src.diskette)
						continue

					var/datum/computer/file/terminal_program/os/newos = locate() in D.root.contents

					if(istype(newos))
						src.temp_add += "Booting from peripheral disk...<br>"
						success = 1
						src.run_program(newos)
						break

				if(!success)
					src.temp_add += "<font color=red>ERR - BOOT FAILURE</font><br>"

		src.updateUsrDialog()
		return

/obj/machinery/computer3/clone()
	var/obj/machinery/computer3/cloneComp = ..()
	if (!cloneComp)
		return

	if (src.hd)
		cloneComp.hd = src.hd.clone()

	if (src.diskette)
		cloneComp.diskette = src.diskette.clone()

	cloneComp.setup_starting_peripheral1 = src.setup_starting_peripheral1
	cloneComp.setup_starting_peripheral2 = src.setup_starting_peripheral2

	cloneComp.setup_starting_os = null
	cloneComp.setup_idscan_path = src.setup_idscan_path
	cloneComp.setup_has_internal_disk = src.setup_has_internal_disk

	cloneComp.setup_font_color = src.setup_font_color
	cloneComp.setup_bg_color = src.setup_bg_color

	return cloneComp


//Special overrides and what-not for luggables.
/obj/item/luggable_computer
	name = "briefcase"
	icon = 'icons/obj/computer.dmi'
	icon_state = "briefcase"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "briefcase"
	desc = "A common item to find in an office.  Is that an antenna?"
	flags = FPRINT | TABLEPASS| CONDUCT | NOSPLASH
	force = 8
	throw_speed = 1
	throw_range = 4
	w_class = W_CLASS_BULKY
	var/obj/machinery/computer3/luggable/luggable = null
	var/luggable_type = /obj/machinery/computer3/luggable

	New()
		..()
		SPAWN(1 SECOND)
			if(!luggable)
				src.luggable = new luggable_type (src)
				src.luggable.case = src
				src.luggable.deployed = 0
		BLOCK_SETUP(BLOCK_LARGE)
		return

	attack_self(mob/user as mob)
		return deploy(user)

	disposing()
		if (luggable && luggable.loc == src)
			luggable.dispose()
			luggable = null

		..()

	verb/unfold()
		set src in view(1)

		if (usr.stat)
			return

		src.deploy(usr)
		return

	proc/deploy(mob/user as mob)
		var/turf/T = get_turf(src)
		if(!T || !luggable)
			boutput(user, "<span class='alert'>You can't seem to get the latch open!</span>")
			return

		if (src.loc == user)
			user.drop_item()
		src.luggable.set_loc(T)
		src.luggable.case = src
		src.luggable.deployed = 1
		src.set_loc(src.luggable)
		for (var/obj/item/peripheral/P in src.luggable)
			P.installed(src.luggable)

		user.visible_message("<b>[user]</b> deploys [src.luggable]!","You deploy [src.luggable]!")

/obj/machinery/computer3/luggable
	New()
		..()
		src.cell = new /obj/item/cell(src)
		src.cell.maxcharge = setup_charge_maximum
		src.cell.charge = src.cell.maxcharge
		return

	disposing()
		if (src.cell)
			src.cell.dispose()
			src.cell = null

		if (case && case.loc == src)
			case.dispose()
			case = null

		..()

	verb/fold_up()
		set src in view(1)

		if(usr.stat)
			return

		src.visible_message("<span class='alert'>[usr] folds [src] back up!</span>")
		src.undeploy()
		return

	proc/undeploy()
		if(!src.case)
			src.case = new /obj/item/luggable_computer(src)
			src.case.luggable = src

		for (var/obj/item/peripheral/peripheral in peripherals)
			peripheral.uninstalled()

		src.case.set_loc(get_turf(src))
		src.set_loc(src.case)
		src.deployed = 0
		return

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/disk/data/floppy)) //INSERT SOME DISKETTES
			if ((!src.diskette) && src.setup_has_internal_disk)
				user.drop_item()
				W.set_loc(src)
				src.diskette = W
				boutput(user, "You insert [W].")
				if(user.using_dialog_of(src))
					src.updateUsrDialog()
					user << output(url_encode("Disk: <a href='byond://?src=\ref[src];disk=1'>Eject</a>"),"comp3.browser:setInternalDisk")
				return
			else if(src.diskette)
				boutput(user, "<span class='alert'>There's already a disk inside!</span>")
			else if(!src.setup_has_internal_disk)
				boutput(user, "<span class='alert'>There's no visible peripheral device to insert the disk into!</span>")

		else if (ispryingtool(W))
			if(!src.cell)
				boutput(user, "<span class='alert'>There is no energy cell inserted!</span>")
				return

			playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
			src.cell.set_loc(get_turf(src))
			src.cell = null
			user.visible_message("<span class='alert'>[user] removes the power cell from [src]!.</span>","<span class='alert'>You remove the power cell from [src]!</span>")
			src.power_change()
			return

		else if (istype(W, /obj/item/cell))
			if(src.cell)
				boutput(user, "<span class='alert'>There is already an energy cell inserted!</span>")

			else
				user.drop_item()
				W.set_loc(src)
				src.cell = W
				boutput(user, "You insert [W].")
				src.power_change()
				src.updateUsrDialog()

			return

		else
			src.Attackhand(user)

		return

	powered()
		if(!src.cell || src.cell.charge <= 0)
			return 0

		return 1

	use_power(var/amount, var/chan=EQUIP)
		if(!src.cell || !src.deployed)
			return

		cell.use(amount / 100)

		src.power_change()
		return



//A personal version!

/obj/item/luggable_computer/personal
	name = "Personal Laptop"
	desc = "This fine piece of hardware sports an incredible 2 kilobytes of RAM, all for a price slightly higher than the whole economy of greece."
	icon_state = "oldlapshut"
	luggable_type = /obj/machinery/computer3/luggable/personal
	w_class = W_CLASS_NORMAL


/obj/machinery/computer3/luggable/personal

	undeploy()
		if(!src.case)
			src.case = new /obj/item/luggable_computer/personal(src)
			src.case.luggable = src

		for (var/obj/item/peripheral/peripheral in peripherals)
			peripheral.uninstalled()

		src.case.set_loc(get_turf(src))
		src.set_loc(src.case)
		src.deployed = 0
		return
