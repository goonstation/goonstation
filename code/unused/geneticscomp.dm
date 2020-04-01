//Super secret message here.

/obj/machinery/dna_scannernew/allow_drop()
	return 0

/obj/machinery/dna_scannernew/relaymove(mob/user as mob)
	if (user.stat)
		return
	src.go_out()
	return

/obj/machinery/dna_scannernew/verb/eject()
	set src in oview(1)

	if (!isalive(usr))
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/dna_scannernew/verb/move_inside()
	set src in oview(1)

	if (!isalive(usr))
		return
	if (src.occupant)
		boutput(usr, "<span style=\"color:blue\"><B>The scanner is already occupied!</B></span>")
		return
	usr.pulling = null
	usr.set_loc(src)
	src.occupant = usr
	src.icon_state = "scanner_1"
	for(var/obj/O in src)
		//O = null
		qdel(O)
		//Foreach goto(124)
	src.add_fingerprint(usr)
	return

/obj/machinery/dna_scannernew/attackby(obj/item/weapon/grab/G as obj, user as mob)
	if ((!( istype(G, /obj/item/weapon/grab) ) || !( ismob(G.affecting) )))
		return
	if (src.occupant)
		boutput(user, "<span style=\"color:blue\"><B>The scanner is already occupied!</B></span>")
		return
	var/mob/M = G.affecting
	M.set_loc(src)
	src.occupant = M
	src.icon_state = "scanner_1"
	for(var/obj/O in src)
		O.set_loc(src.loc)
		//Foreach goto(154)
	src.add_fingerprint(user)
	//G = null
	qdel(G)
	return

/obj/machinery/dna_scannernew/proc/go_out()
	if ((!( src.occupant ) || src.locked))
		return
	for(var/obj/O in src)
		O.set_loc(src.loc)
		//Foreach goto(30)
	src.occupant.set_loc(src.loc)
	src.occupant = null
	src.icon_state = "scanner_0"
	return

/obj/machinery/dna_scannernew/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.set_loc(src.loc)
				ex_act(severity)
				//Foreach goto(35)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.set_loc(src.loc)
					ex_act(severity)
					//Foreach goto(108)
				//SN src = null
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.set_loc(src.loc)
					ex_act(severity)
					//Foreach goto(181)
				//SN src = null
				qdel(src)
				return
		else
	return


/obj/machinery/dna_scannernew/blob_act(var/power)
	if(prob(power * 2.5))
		for(var/atom/movable/A as mob|obj in src)
			A.set_loc(src.loc)
		qdel(src)

/obj/machinery/scan_consolenew/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				qdel(src)
				return
		else
	return

/obj/machinery/scan_consolenew/blob_act(var/power)

	if(prob(power * 2.5))
		qdel(src)

/obj/machinery/scan_consolenew/power_change()
	if(status & BROKEN)
		icon_state = "broken"
	else if(powered())
		icon_state = initial(icon_state)
		status &= ~NOPOWER
	else
		SPAWN_DBG(rand(0, 15))
			src.icon_state = "c_unpowered"
			status |= NOPOWER

/obj/machinery/scan_consolenew/New()
	..()
	SPAWN_DBG( 5 )
		src.connected = locate(/obj/machinery/dna_scannernew, get_step(src, WEST))
		return
	return

/obj/machinery/scan_consolenew/process() //not really used right now
	if(status & (NOPOWER|BROKEN))
		return
	use_power(250) // power stuff

	var/mob/M //occupant
	if (!( src.status )) //remove this
		return
	if ((src.connected && src.connected.occupant)) //connected & occupant ok
		M = src.connected.occupant
	if (src.status == "something") // remove this
		//something else
	else
		if (src.status == "placeholder")
			if (ismob(M))
			//do stuff
			else
				src.temphtml = "Process terminated due to lack of occupant in DNA chamber."
				src.status = null
	src.updateDialog()
	return

/obj/machinery/scan_consolenew/attack_ai(user as mob)
	return src.attack_hand(user)

/obj/machinery/scan_consolenew/attack_hand(user as mob)
	if(..())
		return
	var/dat
	if (src.delete && src.temphtml) //Window in buffer but its just simple message, so nothing
		src.delete = src.delete
	else if (!src.delete && src.temphtml) //Window in buffer - its a menu, dont add clear message
		dat = text("[]<BR><BR><A href='?src=\ref[];clear=1'>Main Menu</A>", src.temphtml, src)
	else
		if (src.connected) //Is something connected?
			var/mob/occupant = src.connected.occupant
			dat = "<font color='blue'><B>Occupant Statistics:</B></FONT><BR>" //Blah obvious
			if (occupant) //is there REALLY someone in there?
				if (!ishuman(occupant))
					sleep(1)
				var/t1
				switch(occupant.stat) // obvious, see what their status is
					if(0)
						t1 = "Conscious"
					if(1)
						t1 = "Unconscious"
					else
						t1 = "*dead*"
				dat += text("[]\tHealth %: [] ([])</FONT><BR>", (occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"), occupant.health, t1)
				dat += text("<font color='green'>Radiation Level: []%</FONT><BR><BR>", occupant.radiation)
				dat += text("Unique Enzymes : <font color='blue'>[]</FONT><BR>", uppertext(occupant.primarynew.use_enzyme))
				dat += text("Unique Identifier: <font color='blue'>[]</FONT><BR>", occupant.primarynew.uni_identity)
				dat += text("Structural Enzymes: <font color='blue'>[]</FONT><BR><BR>", occupant.primarynew.struc_enzyme)
				dat += text("<A href='?src=\ref[];unimenu=1'>Modify Unique Identifier</A><BR>", src)
				dat += text("<A href='?src=\ref[];strucmenu=1'>Modify Structural Enzymes</A><BR><BR>", src)
				dat += text("<A href='?src=\ref[];buffermenu=1'>View/Edit/Transfer Buffer</A><BR><BR>", src)
				dat += text("<A href='?src=\ref[];genpulse=1'>Pulse Radiation</A><BR>", src)
				dat += text("<A href='?src=\ref[];radset=1'>Radiation Emitter Settings</A><BR><BR>", src)
				dat += text("<A href='?src=\ref[];rejuv=1'>Inject Rejuvenators</A><BR><BR>", src)
			else
				dat += "The scanner is empty.<BR><BR>"
				dat += text("<A href='?src=\ref[];buffermenu=1'>View/Edit/Transfer Buffer</A><BR><BR>", src)
				dat += text("<A href='?src=\ref[];radset=1'>Radiation Emitter Settings</A><BR><BR>", src)
			if (!( src.connected.locked ))
				dat += text("<A href='?src=\ref[];locked=1'>Lock (Unlocked)</A><BR>", src)
			else
				dat += text("<A href='?src=\ref[];locked=1'>Unlock (Locked)</A><BR>", src)
				//Other stuff goes here
			dat += text("<BR><BR><A href='?action=mach_close&window=scannernew'>Close</A>", user)
		else
			dat = "<font color='red'> Error: No DNA Modifier connected. </FONT>"
	user << browse(dat, "window=scannernew;size=550x625")
	onclose(user, "scannernew")
	return

/obj/machinery/scan_consolenew/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (get_dist(src, usr) <= 1 || usr.telekinesis == 1) && istype(src.loc, /turf)) || (isAI(usr)))
		usr.machine = src
		if (href_list["locked"])
			if ((src.connected && src.connected.occupant))
				src.connected.locked = !( src.connected.locked )
		////////////////////////////////////////////////////////
		if (href_list["genpulse"])
			src.delete = 1
			src.temphtml = text("Working ... Please wait ([] Seconds)", src.radduration)
			usr << browse(temphtml, "window=scannernew;size=550x650")
			onclose(usr, "scannernew")
			sleep(10*src.radduration)
			if (!src.connected.occupant)
				temphtml = null
				delete = 0
				return null
			if (prob(95))
				if(prob(75))
					randmutb(src.connected.occupant)
				else
					randmuti(src.connected.occupant)
			else
				if(prob(95))
					randmutg(src.connected.occupant)
				else
					randmuti(src.connected.occupant)
			src.connected.occupant.radiation += ((src.radstrength*3)+src.radduration*3)
			temphtml = null
			delete = 0
		if (href_list["radset"])
			src.temphtml = text("Radiation Duration: <B><font color='green'>[]</B></FONT><BR>", src.radduration)
			src.temphtml += text("Radiation Intensity: <font color='green'><B>[]</B></FONT><BR><BR>", src.radstrength)
			src.temphtml += text("<A href='?src=\ref[];radleminus=1'>--</A> Duration <A href='?src=\ref[];radleplus=1'>++</A><BR>", src, src)
			src.temphtml += text("<A href='?src=\ref[];radinminus=1'>--</A> Intesity <A href='?src=\ref[];radinplus=1'>++</A><BR>", src, src)
			src.delete = 0
		if (href_list["radleplus"])
			if (src.radduration < 20)
				src.radduration++
				src.radduration++
			dopage(src,"radset")
		if (href_list["radleminus"])
			if (src.radduration > 2)
				src.radduration--
				src.radduration--
			dopage(src,"radset")
		if (href_list["radinplus"])
			if (src.radstrength < 10)
				src.radstrength++
			dopage(src,"radset")
		if (href_list["radinminus"])
			if (src.radstrength > 1)
				src.radstrength--
			dopage(src,"radset")
		////////////////////////////////////////////////////////
		if (href_list["unimenu"])
			//src.temphtml = text("Unique Identifier: <font color='blue'>[]</FONT><BR><BR>", src.connected.occupant.primarynew.uni_identity)
			src.temphtml = text("Unique Identifier: <font color='blue'>[getleftblocks(src.connected.occupant.primarynew.uni_identity,uniblock,3)][src.subblock == 1 ? "<U><B>"+getblock(getblock(src.connected.occupant.primarynew.uni_identity,src.uniblock,3),1,1)+"</U></B>" : getblock(getblock(src.connected.occupant.primarynew.uni_identity,src.uniblock,3),1,1)][src.subblock == 2 ? "<U><B>"+getblock(getblock(src.connected.occupant.primarynew.uni_identity,src.uniblock,3),2,1)+"</U></B>" : getblock(getblock(src.connected.occupant.primarynew.uni_identity,src.uniblock,3),2,1)][src.subblock == 3 ? "<U><B>"+getblock(getblock(src.connected.occupant.primarynew.uni_identity,src.uniblock,3),3,1)+"</U></B>" : getblock(getblock(src.connected.occupant.primarynew.uni_identity,src.uniblock,3),3,1)][getrightblocks(src.connected.occupant.primarynew.uni_identity,uniblock,3)]</FONT><BR><BR>")
			src.temphtml += text("Selected Block: <font color='blue'><B>[]</B></FONT><BR>", src.uniblock)
			src.temphtml += text("<A href='?src=\ref[];unimenuminus=1'><-</A> Block <A href='?src=\ref[];unimenuplus=1'>-></A><BR><BR>", src, src)
			src.temphtml += text("Selected Sub-Block: <font color='blue'><B>[]</B></FONT><BR>", src.subblock)
			src.temphtml += text("<A href='?src=\ref[];unimenusubminus=1'><-</A> Sub-Block <A href='?src=\ref[];unimenusubplus=1'>-></A><BR><BR>", src, src)
			src.temphtml += "<B>Modify Block:</B><BR>"
			src.temphtml += text("<A href='?src=\ref[];unipulse=1'>Radiation</A><BR>", src)
			src.delete = 0
		if (href_list["unimenuplus"])
			if (src.uniblock < 13)
				src.uniblock++
			dopage(src,"unimenu")
		if (href_list["unimenuminus"])
			if (src.uniblock > 1)
				src.uniblock--
			dopage(src,"unimenu")
		if (href_list["unimenusubplus"])
			if (src.subblock < 3)
				src.subblock++
			dopage(src,"unimenu")
		if (href_list["unimenusubminus"])
			if (src.subblock > 1)
				src.subblock--
			dopage(src,"unimenu")
		if (href_list["unipulse"])
			var/block
			var/newblock
			var/tstructure2
			block = getblock(getblock(src.connected.occupant.primarynew.uni_identity,src.uniblock,3),src.subblock,1)
			src.delete = 1
			src.temphtml = text("Working ... Please wait ([] Seconds)", src.radduration)
			usr << browse(temphtml, "window=scannernew;size=550x650")
			onclose(usr, "scannernew")
			sleep(10*src.radduration)
			if (!src.connected.occupant)
				temphtml = null
				delete = 0
				return null
			///
			if (prob((80 + (src.radduration / 2))))
				block = miniscramble(block, src.radstrength, src.radduration)
				newblock = null
				if (src.subblock == 1) newblock = block + getblock(getblock(src.connected.occupant.primarynew.uni_identity,src.uniblock,3),2,1) + getblock(getblock(src.connected.occupant.primarynew.uni_identity,src.uniblock,3),3,1)
				if (src.subblock == 2) newblock = getblock(getblock(src.connected.occupant.primarynew.uni_identity,src.uniblock,3),1,1) + block + getblock(getblock(src.connected.occupant.primarynew.uni_identity,src.uniblock,3),3,1)
				if (src.subblock == 3) newblock = getblock(getblock(src.connected.occupant.primarynew.uni_identity,src.uniblock,3),1,1) + getblock(getblock(src.connected.occupant.primarynew.uni_identity,src.uniblock,3),2,1) + block
				tstructure2 = setblock(src.connected.occupant.primarynew.uni_identity, src.uniblock, newblock,3)
				src.connected.occupant.primarynew.uni_identity = tstructure2
				updateappearance(src.connected.occupant,src.connected.occupant.primarynew.uni_identity)
				src.connected.occupant.radiation += (src.radstrength+src.radduration)
			else
				if	(prob(20+src.radstrength))
					randmutb(src.connected.occupant)
					domutcheck(src.connected.occupant,src.connected)
				else
					randmuti(src.connected.occupant)
					updateappearance(src.connected.occupant,src.connected.occupant.primarynew.uni_identity)
				src.connected.occupant.radiation += ((src.radstrength*2)+src.radduration)
			dopage(src,"unimenu")
			src.delete = 0
		////////////////////////////////////////////////////////
		if (href_list["rejuv"])
			if (src.connected.occupant.rejuv < 30)
				src.connected.occupant.rejuv += 10
			src.temphtml = text("Occupant now has [] units of rejuvenation in his/her bloodstream.", src.connected.occupant.rejuv)
			src.delete = 0
		////////////////////////////////////////////////////////
		if (href_list["strucmenu"])
			src.temphtml = text("Structural Enzymes: <font color='blue'>[getleftblocks(src.connected.occupant.primarynew.struc_enzyme,strucblock,3)][src.subblock == 1 ? "<U><B>"+getblock(getblock(src.connected.occupant.primarynew.struc_enzyme,src.strucblock,3),1,1)+"</U></B>" : getblock(getblock(src.connected.occupant.primarynew.struc_enzyme,src.strucblock,3),1,1)][src.subblock == 2 ? "<U><B>"+getblock(getblock(src.connected.occupant.primarynew.struc_enzyme,src.strucblock,3),2,1)+"</U></B>" : getblock(getblock(src.connected.occupant.primarynew.struc_enzyme,src.strucblock,3),2,1)][src.subblock == 3 ? "<U><B>"+getblock(getblock(src.connected.occupant.primarynew.struc_enzyme,src.strucblock,3),3,1)+"</U></B>" : getblock(getblock(src.connected.occupant.primarynew.struc_enzyme,src.strucblock,3),3,1)][getrightblocks(src.connected.occupant.primarynew.struc_enzyme,strucblock,3)]</FONT><BR><BR>")
			//src.temphtml = text("Structural Enzymes: <font color='blue'>[]</FONT><BR><BR>", src.connected.occupant.primarynew.struc_enzyme)
			src.temphtml += text("Selected Block: <font color='blue'><B>[]</B></FONT><BR>", src.strucblock)
			src.temphtml += text("<A href='?src=\ref[];strucmenuminus=1'><-</A> Block <A href='?src=\ref[];strucmenuplus=1'>-></A><BR><BR>", src, src)
			src.temphtml += text("Selected Sub-Block: <font color='blue'><B>[]</B></FONT><BR>", src.subblock)
			src.temphtml += text("<A href='?src=\ref[];strucmenusubminus=1'><-</A> Sub-Block <A href='?src=\ref[];strucmenusubplus=1'>-></A><BR><BR>", src, src)
			src.temphtml += "<B>Modify Block:</B><BR>"
			src.temphtml += text("<A href='?src=\ref[];strucpulse=1'>Radiation</A><BR>", src)
			src.delete = 0
		if (href_list["strucmenuplus"])
			if (src.strucblock < 14)
				src.strucblock++
			dopage(src,"strucmenu")
		if (href_list["strucmenuminus"])
			if (src.strucblock > 1)
				src.strucblock--
			dopage(src,"strucmenu")
		if (href_list["strucmenusubplus"])
			if (src.subblock < 3)
				src.subblock++
			dopage(src,"strucmenu")
		if (href_list["strucmenusubminus"])
			if (src.subblock > 1)
				src.subblock--
			dopage(src,"strucmenu")
		if (href_list["strucpulse"])
			var/block
			var/newblock
			var/tstructure2
			var/oldblock
			block = getblock(getblock(src.connected.occupant.primarynew.struc_enzyme,src.strucblock,3),src.subblock,1)
			src.delete = 1
			src.temphtml = text("Working ... Please wait ([] Seconds)", src.radduration)
			usr << browse(temphtml, "window=scannernew;size=550x650")
			onclose(usr, "scannernew")
			sleep(10*src.radduration)
			if (!src.connected.occupant)
				temphtml = null
				delete = 0
				return null
			///
			if (prob((80 + (src.radduration / 2))))
				if ((src.strucblock != 2 || src.strucblock != 12 || src.strucblock != 8 || src.strucblock || 10) && prob (20))
					oldblock = src.strucblock
					block = miniscramble(block, src.radstrength, src.radduration)
					newblock = null
					if (src.strucblock > 1 && src.strucblock < 5)
						src.strucblock++
					else if (src.strucblock > 5 && src.strucblock < 14)
						src.strucblock--
					if (src.subblock == 1) newblock = block + getblock(getblock(src.connected.occupant.primarynew.struc_enzyme,src.strucblock,3),2,1) + getblock(getblock(src.connected.occupant.primarynew.struc_enzyme,src.strucblock,3),3,1)
					if (src.subblock == 2) newblock = getblock(getblock(src.connected.occupant.primarynew.struc_enzyme,src.strucblock,3),1,1) + block + getblock(getblock(src.connected.occupant.primarynew.struc_enzyme,src.strucblock,3),3,1)
					if (src.subblock == 3) newblock = getblock(getblock(src.connected.occupant.primarynew.struc_enzyme,src.strucblock,3),1,1) + getblock(getblock(src.connected.occupant.primarynew.struc_enzyme,src.strucblock,3),2,1) + block
					tstructure2 = setblock(src.connected.occupant.primarynew.struc_enzyme, src.strucblock, newblock,3)
					src.connected.occupant.primarynew.struc_enzyme = tstructure2
					domutcheck(src.connected.occupant,src.connected)
					src.connected.occupant.radiation += (src.radstrength+src.radduration)
					src.strucblock = oldblock
				else
					//
					block = miniscramble(block, src.radstrength, src.radduration)
					newblock = null
					if (src.subblock == 1) newblock = block + getblock(getblock(src.connected.occupant.primarynew.struc_enzyme,src.strucblock,3),2,1) + getblock(getblock(src.connected.occupant.primarynew.struc_enzyme,src.strucblock,3),3,1)
					if (src.subblock == 2) newblock = getblock(getblock(src.connected.occupant.primarynew.struc_enzyme,src.strucblock,3),1,1) + block + getblock(getblock(src.connected.occupant.primarynew.struc_enzyme,src.strucblock,3),3,1)
					if (src.subblock == 3) newblock = getblock(getblock(src.connected.occupant.primarynew.struc_enzyme,src.strucblock,3),1,1) + getblock(getblock(src.connected.occupant.primarynew.struc_enzyme,src.strucblock,3),2,1) + block
					tstructure2 = setblock(src.connected.occupant.primarynew.struc_enzyme, src.strucblock, newblock,3)
					src.connected.occupant.primarynew.struc_enzyme = tstructure2
					domutcheck(src.connected.occupant,src.connected)
					src.connected.occupant.radiation += (src.radstrength+src.radduration)
			else
				if	(prob(80-src.radduration))
					randmutb(src.connected.occupant)
					domutcheck(src.connected.occupant,src.connected)
				else
					randmuti(src.connected.occupant)
					updateappearance(src.connected.occupant,src.connected.occupant.primarynew.uni_identity)
				src.connected.occupant.radiation += ((src.radstrength*2)+src.radduration)
			///
			dopage(src,"strucmenu")
			src.delete = 0
		////////////////////////////////////////////////////////
		if (href_list["buffermenu"])
			src.temphtml = "<B>Buffer 1:</B><BR>"
			if (!(src.buffer1))
				src.temphtml += "Buffer Empty<BR>"
			else
				src.temphtml += text("Data: <font color='blue'>[]</FONT><BR>", src.buffer1)
				src.temphtml += text("By: <font color='blue'>[]</FONT><BR>", src.buffer1owner)
				src.temphtml += text("Label: <font color='blue'>[]</FONT><BR>", src.buffer1label)
			if (src.connected.occupant) src.temphtml += text("Save : <A href='?src=\ref[];b1addui=1'>UI</A> - <A href='?src=\ref[];b1adduiue=1'>UI+UE</A> - <A href='?src=\ref[];b1addse=1'>SE</A><BR>", src, src, src)
			if (src.buffer1) src.temphtml += text("Transfer to: <A href='?src=\ref[];b1transfer=1'>Occupant</A> - <A href='?src=\ref[];b1injector=1'>Injector</A><BR>", src, src)
			//if (src.buffer1) src.temphtml += text("<A href='?src=\ref[];b1iso=1'>Isolate Block</A><BR>", src)
			if (src.buffer1) src.temphtml += text("<A href='?src=\ref[];b1label=1'>Edit Label</A><BR>", src)
			if (src.buffer1) src.temphtml += text("<A href='?src=\ref[];b1clear=1'>Clear Buffer</A><BR><BR>", src)
			if (!src.buffer1) src.temphtml += "<BR>"
			src.temphtml += "<B>Buffer 2:</B><BR>"
			if (!(src.buffer2))
				src.temphtml += "Buffer Empty<BR>"
			else
				src.temphtml += text("Data: <font color='blue'>[]</FONT><BR>", src.buffer2)
				src.temphtml += text("By: <font color='blue'>[]</FONT><BR>", src.buffer2owner)
				src.temphtml += text("Label: <font color='blue'>[]</FONT><BR>", src.buffer2label)
			if (src.connected.occupant) src.temphtml += text("Save : <A href='?src=\ref[];b2addui=1'>UI</A> - <A href='?src=\ref[];b2adduiue=1'>UI+UE</A> - <A href='?src=\ref[];b2addse=1'>SE</A><BR>", src, src, src)
			if (src.buffer2) src.temphtml += text("Transfer to: <A href='?src=\ref[];b2transfer=1'>Occupant</A> - <A href='?src=\ref[];b2injector=1'>Injector</A><BR>", src, src)
			//if (src.buffer2) src.temphtml += text("<A href='?src=\ref[];b2iso=1'>Isolate Block</A><BR>", src)
			if (src.buffer2) src.temphtml += text("<A href='?src=\ref[];b2label=1'>Edit Label</A><BR>", src)
			if (src.buffer2) src.temphtml += text("<A href='?src=\ref[];b2clear=1'>Clear Buffer</A><BR><BR>", src)
			if (!src.buffer2) src.temphtml += "<BR>"
			src.temphtml += "<B>Buffer 3:</B><BR>"
			if (!(src.buffer3))
				src.temphtml += "Buffer Empty<BR>"
			else
				src.temphtml += text("Data: <font color='blue'>[]</FONT><BR>", src.buffer3)
				src.temphtml += text("By: <font color='blue'>[]</FONT><BR>", src.buffer3owner)
				src.temphtml += text("Label: <font color='blue'>[]</FONT><BR>", src.buffer3label)
			if (src.connected.occupant) src.temphtml += text("Save : <A href='?src=\ref[];b3addui=1'>UI</A> - <A href='?src=\ref[];b3adduiue=1'>UI+UE</A> - <A href='?src=\ref[];b3addse=1'>SE</A><BR>", src, src, src)
			if (src.buffer3) src.temphtml += text("Transfer to: <A href='?src=\ref[];b3transfer=1'>Occupant</A> - <A href='?src=\ref[];b3injector=1'>Injector</A><BR>", src, src)
			//if (src.buffer3) src.temphtml += text("<A href='?src=\ref[];b3iso=1'>Isolate Block</A><BR>", src)
			if (src.buffer3) src.temphtml += text("<A href='?src=\ref[];b3label=1'>Edit Label</A><BR>", src)
			if (src.buffer3) src.temphtml += text("<A href='?src=\ref[];b3clear=1'>Clear Buffer</A><BR><BR>", src)
			if (!src.buffer3) src.temphtml += "<BR>"
		if (href_list["b1addui"])
			src.buffer1iue = 0
			src.buffer1 = src.connected.occupant.primarynew.uni_identity
			if (!ishuman(src.connected.occupant))
				src.buffer1owner = src.connected.occupant.name
			else
				src.buffer1owner = src.connected.occupant.real_name
			src.buffer1label = "Unique Identifier"
			src.buffer1type = "ui"
			dopage(src,"buffermenu")
		if (href_list["b1adduiue"])
			src.buffer1 = src.connected.occupant.primarynew.uni_identity
			if (!ishuman(src.connected.occupant))
				src.buffer1owner = src.connected.occupant.name
			else
				src.buffer1owner = src.connected.occupant.real_name
			src.buffer1label = "Unique Identifier & Unique Enzymes"
			src.buffer1type = "ui"
			src.buffer1iue = 1
			dopage(src,"buffermenu")
		if (href_list["b2adduiue"])
			src.buffer2 = src.connected.occupant.primarynew.uni_identity
			if (!ishuman(src.connected.occupant))
				src.buffer2owner = src.connected.occupant.name
			else
				src.buffer2owner = src.connected.occupant.real_name
			src.buffer2label = "Unique Identifier & Unique Enzymes"
			src.buffer2type = "ui"
			src.buffer2iue = 1
			dopage(src,"buffermenu")
		if (href_list["b3adduiue"])
			src.buffer3 = src.connected.occupant.primarynew.uni_identity
			if (!ishuman(src.connected.occupant))
				src.buffer3owner = src.connected.occupant.name
			else
				src.buffer3owner = src.connected.occupant.real_name
			src.buffer3label = "Unique Identifier & Unique Enzymes"
			src.buffer3type = "ui"
			src.buffer3iue = 1
			dopage(src,"buffermenu")
		if (href_list["b2addui"])
			src.buffer2iue = 0
			src.buffer2 = src.connected.occupant.primarynew.uni_identity
			if (!ishuman(src.connected.occupant))
				src.buffer2owner = src.connected.occupant.name
			else
				src.buffer2owner = src.connected.occupant.real_name
			src.buffer2label = "Unique Identifier"
			src.buffer2type = "ui"
			dopage(src,"buffermenu")
		if (href_list["b3addui"])
			src.buffer3iue = 0
			src.buffer3 = src.connected.occupant.primarynew.uni_identity
			if (!ishuman(src.connected.occupant))
				src.buffer3owner = src.connected.occupant.name
			else
				src.buffer3owner = src.connected.occupant.real_name
			src.buffer3label = "Unique Identifier"
			src.buffer3type = "ui"
			dopage(src,"buffermenu")
		if (href_list["b1addse"])
			src.buffer1iue = 0
			src.buffer1 = src.connected.occupant.primarynew.struc_enzyme
			if (!ishuman(src.connected.occupant))
				src.buffer1owner = src.connected.occupant.name
			else
				src.buffer1owner = src.connected.occupant.real_name
			src.buffer1label = "Structural Enzymes"
			src.buffer1type = "se"
			dopage(src,"buffermenu")
		if (href_list["b2addse"])
			src.buffer2iue = 0
			src.buffer2 = src.connected.occupant.primarynew.struc_enzyme
			if (!ishuman(src.connected.occupant))
				src.buffer2owner = src.connected.occupant.name
			else
				src.buffer2owner = src.connected.occupant.real_name
			src.buffer2label = "Structural Enzymes"
			src.buffer2type = "se"
			dopage(src,"buffermenu")
		if (href_list["b3addse"])
			src.buffer3iue = 0
			src.buffer3 = src.connected.occupant.primarynew.struc_enzyme
			if (!ishuman(src.connected.occupant))
				src.buffer3owner = src.connected.occupant.name
			else
				src.buffer3owner = src.connected.occupant.real_name
			src.buffer3label = "Structural Enzymes"
			src.buffer3type = "se"
			dopage(src,"buffermenu")
		if (href_list["b1clear"])
			src.buffer1 = null
			src.buffer1owner = null
			src.buffer1label = null
			src.buffer1iue = null
			dopage(src,"buffermenu")
		if (href_list["b2clear"])
			src.buffer2 = null
			src.buffer2owner = null
			src.buffer2label = null
			src.buffer2iue = null
			dopage(src,"buffermenu")
		if (href_list["b3clear"])
			src.buffer3 = null
			src.buffer3owner = null
			src.buffer3label = null
			src.buffer3iue = null
			dopage(src,"buffermenu")
		if (href_list["b1label"])
			src.buffer1label = input("New Label:","Edit Label","Infos here") as text
			dopage(src,"buffermenu")
		if (href_list["b2label"])
			src.buffer2label = input("New Label:","Edit Label","Infos here") as text
			dopage(src,"buffermenu")
		if (href_list["b3label"])
			src.buffer3label = input("New Label:","Edit Label","Infos here") as text
			dopage(src,"buffermenu")
		if (href_list["b1transfer"])
			if (!src.connected.occupant)
				return
			if (src.buffer1type == "ui")
				if (src.buffer1iue)
					src.connected.occupant.real_name = src.buffer1owner
					src.connected.occupant.name = src.buffer1owner
				src.connected.occupant.primarynew.uni_identity = src.buffer1
				updateappearance(src.connected.occupant,src.connected.occupant.primarynew.uni_identity)
			else if (src.buffer1type == "se")
				src.connected.occupant.primarynew.struc_enzyme = src.buffer1
				domutcheck(src.connected.occupant,src.connected)
			src.temphtml = "Transfered."
			src.connected.occupant.radiation += rand(20,50)
			src.delete = 0
		if (href_list["b2transfer"])
			if (!src.connected.occupant)
				return
			if (src.buffer2type == "ui")
				if (src.buffer2iue)
					src.connected.occupant.real_name = src.buffer2owner
					src.connected.occupant.name = src.buffer2owner
				src.connected.occupant.primarynew.uni_identity = src.buffer2
				updateappearance(src.connected.occupant,src.connected.occupant.primarynew.uni_identity)
			else if (src.buffer2type == "se")
				src.connected.occupant.primarynew.struc_enzyme = src.buffer2
				domutcheck(src.connected.occupant,src.connected)
			src.temphtml = "Transfered."
			src.connected.occupant.radiation += rand(20,50)
			src.delete = 0
		if (href_list["b3transfer"])
			if (!src.connected.occupant)
				return
			if (src.buffer3type == "ui")
				if (src.buffer3iue)
					src.connected.occupant.real_name = src.buffer3owner
					src.connected.occupant.name = src.buffer3owner
				src.connected.occupant.primarynew.uni_identity = src.buffer3
				updateappearance(src.connected.occupant,src.connected.occupant.primarynew.uni_identity)
			else if (src.buffer3type == "se")
				src.connected.occupant.primarynew.struc_enzyme = src.buffer3
				domutcheck(src.connected.occupant,src.connected)
			src.temphtml = "Transfered."
			src.connected.occupant.radiation += rand(20,50)
			src.delete = 0
		if (href_list["b1injector"])
			if (src.injectorready)
				var/obj/item/weapon/dnainjector/I = new /obj/item/weapon/dnainjector
				I.dna = src.buffer1
				I.dnatype = src.buffer1type
				I.set_loc(src.loc)
				I.name += " ([src.buffer1label])"
				if (src.buffer1iue) I.ue = src.buffer1owner //lazy haw haw
				src.temphtml = "Injector created."
				src.delete = 0
				src.injectorready = 0
				SPAWN_DBG(2 MINUTES)
					src.injectorready = 1
			else
				src.temphtml = "Replicator not ready yet."
				src.delete = 0
		if (href_list["b2injector"])
			if (src.injectorready)
				var/obj/item/weapon/dnainjector/I = new /obj/item/weapon/dnainjector
				I.dna = src.buffer2
				I.dnatype = src.buffer2type
				I.set_loc(src.loc)
				I.name += " ([src.buffer2label])"
				if (src.buffer2iue) I.ue = src.buffer2owner //lazy haw haw
				src.temphtml = "Injector created."
				src.delete = 0
				src.injectorready = 0
				SPAWN_DBG(2 MINUTES)
					src.injectorready = 1
			else
				src.temphtml = "Replicator not ready yet."
				src.delete = 0
		if (href_list["b3injector"])
			if (src.injectorready)
				var/obj/item/weapon/dnainjector/I = new /obj/item/weapon/dnainjector
				I.dna = src.buffer3
				I.dnatype = src.buffer3type
				I.set_loc(src.loc)
				I.name += " ([src.buffer3label])"
				if (src.buffer3iue) I.ue = src.buffer3owner //lazy haw haw
				src.temphtml = "Injector created."
				src.delete = 0
				src.injectorready = 0
				SPAWN_DBG(2 MINUTES)
					src.injectorready = 1
			else
				src.temphtml = "Replicator not ready yet."
				src.delete = 0
		////////////////////////////////////////////////////////
		if (href_list["clear"])
			src.temphtml = null
			src.delete = 0
		if (href_list["update"]) //ignore
			src.temphtml = src.temphtml
		src.add_fingerprint(usr)
		src.updateUsrDialog()
	return
