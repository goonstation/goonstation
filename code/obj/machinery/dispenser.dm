/*
		Oxygen and plasma tank dispenser
*/
/obj/machinery/dispenser
	desc = "A simple yet bulky one-way storage device for gas tanks. Holds 10 plasma and 10 oxygen tanks."
	name = "Tank Storage Unit"
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser"
	density = 1
	var/o2tanks = 10.0
	var/pltanks = 10.0
	anchored = 1.0
	mats = 24
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER

/obj/machinery/dispenser/ex_act(severity)
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
		if(3.0)
			if (prob(25))
				while(src.o2tanks > 0)
					new /obj/item/tank/oxygen( src.loc )
					src.o2tanks--
				while(src.pltanks > 0)
					new /obj/item/tank/plasma( src.loc )
					src.pltanks--
		else
	return

/obj/machinery/dispenser/blob_act(var/power)
	if (prob(25 * power / 20))
		while(src.o2tanks > 0)
			new /obj/item/tank/oxygen( src.loc )
			src.o2tanks--
		while(src.pltanks > 0)
			new /obj/item/tank/plasma( src.loc )
			src.pltanks--
		qdel(src)

/obj/machinery/dispenser/meteorhit()
	while(src.o2tanks > 0)
		new /obj/item/tank/oxygen( src.loc )
		src.o2tanks--
	while(src.pltanks > 0)
		new /obj/item/tank/plasma( src.loc )
		src.pltanks--
	qdel(src)
	return

/obj/machinery/dispenser/New()
	..()
	UnsubscribeProcess()

/obj/machinery/dispenser/process()
	return

/obj/machinery/dispenser/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/dispenser/attack_hand(mob/user as mob)
	if(status & BROKEN)
		return
	user.machine = src
	var/dat = text("<TT><B>Loaded Tank Dispensing Unit</B><BR><br><FONT color = 'blue'><B>Oxygen</B>: []</FONT> []<BR><br><FONT color = 'orange'><B>Plasma</B>: []</FONT> []<BR><br></TT>", src.o2tanks, (src.o2tanks ? text("<A href='?src=\ref[];oxygen=1'>Dispense</A>", src) : "empty"), src.pltanks, (src.pltanks ? text("<A href='?src=\ref[];plasma=1'>Dispense</A>", src) : "empty"))
	user.Browse(dat, "window=dispenser")
	onclose(user, "dispenser")
	return

/obj/machinery/dispenser/Topic(href, href_list)
	if(status & BROKEN)
		return
	if(usr.stat || usr.restrained())
		return
	if (isAI(usr))
		boutput(usr, "<span class='alert'>You are unable to dispense anything, since the controls are physical levers which don't go through any other kind of input.</span>")
		return

	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))))
		usr.machine = src
		if (href_list["oxygen"])
			if (text2num(href_list["oxygen"]))
				if (src.o2tanks > 0)
					use_power(5)
					var/newtank = new /obj/item/tank/oxygen(src.loc)
					usr.put_in_hand_or_eject(newtank)
					src.o2tanks--
			if (ismob(src.loc))
				attack_hand(src.loc)
		else
			if (href_list["plasma"])
				if (text2num(href_list["plasma"]))
					if (src.pltanks > 0)
						use_power(5)
						var/newtank = new /obj/item/tank/plasma(src.loc)
						usr.put_in_hand_or_eject(newtank)
						src.pltanks--
				if (ismob(src.loc))
					attack_hand(src.loc)
		src.add_fingerprint(usr)
		for(var/mob/M in viewers(1, src))
			if ((M.client && M.machine == src))
				src.attack_hand(M)
	else
		usr.Browse(null, "window=dispenser")
		return
	return

/*
		Disease Dispenser
*/

/*
/obj/machinery/dispenser_disease
	desc = "A machine which you can put test tubes into"
	name = "Chemical Dispensing Unit"
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser"
	density = 1
	anchored = 1.0

	var/obj/item/reagent_containers/glass/vial/active_vial = null
	var/obj/item/disk/data/tape/tape = null

	ex_act(severity)
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

	blob_act(var/power)
		if (prob(25))
			qdel(src)

	meteorhit()
		qdel(src)
		return

	New()
		..()
		UnsubscribeProcess()

	process()
		return

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if(status & BROKEN)
			return
		user.machine = src

		var/dat = "<TT><B>Chemical Dispenser Unit</B><BR><HR><BR>"

		if(src.tape)
			dat += "Tape Loaded. <A href='?src=\ref[src];etape=1'>Eject</a><br>"
		else
			dat += "<font color=red>No Data Tape Loaded.</font><br>"

		if(src.active_vial)
			dat += {"Test tube Loaded <A href='?src=\ref[src];eject=1'>(Eject)</A>
					<BR><BR><BR>It contains:<BR>"}

			if(src.active_vial.reagents.reagent_list.len)
				for(var/current_id in src.active_vial.reagents.reagent_list)
					var/datum/reagent/current_reagent = src.active_vial.reagents.reagent_list[current_id]
					dat += "[current_reagent.volume] units of [current_reagent.name]<BR>"
			else
				dat += "Nothing<BR><BR>Pick a disease to dispense to it:<BR>"
				if(src.tape && src.tape.root)
					var/count = 0
					for(var/datum/computer/file/disease/D in src.tape.root.contents)
						count++
						dat += "<BR><A href='?src=\ref[src];disp=\ref[D]'>[D.disease_name]</A>"

					if(!count)
						dat += "<br><font color=red>No VDNA disease profiles on tape!</font><br>"

		else
			dat += "No Test Tube Loaded<BR>"

		user.Browse(dat, "window=dis_dispenser")
		onclose(user, "dis_dispenser")
		return

	attackby(obj/item/W, mob/user as mob)
		if(istype(W, /obj/item/reagent_containers/glass/vial))
			if(src.active_vial)
				boutput(user, "<span class='notice'>The dispenser already has a test tube in it</span>")
			else
				boutput(user, "<span class='notice'>You insert the test tube into the dispenser</span>")
				user.drop_vial()
				W.set_loc(src)
				src.active_vial = W
			src.updateUsrDialog()
			return

		else if(istype(W, /obj/item/reagent_containers))
			boutput(user, "<span class='notice'>[W] is too big to fit in!</span>")
			return

		else if (istype(W, /obj/item/disk/data/tape))
			if(!src.tape)
				user.drop_item()
				W.set_loc(src)
				src.tape = W
				boutput(user, "You insert [W].")
			else
				boutput(user, "<span class='alert'>There is already a tape loaded!</span>")
			src.updateUsrDialog()
			return

		..()
		return


	Topic(href, href_list)
		if(status & BROKEN)
			return
		if(usr.stat || usr.restrained())
			return
		if (isAI(usr))
			boutput(usr, "<span class='alert'>You are unable to dispense anything, since the controls are physical levers which don't go through any other kind of input.</span>")
			return

		if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))))
			usr.machine = src

			if (href_list["eject"])
				if(src.active_vial)
					var/log_reagents = ""
					for(var/reagent_id in src.active_vial.reagents.reagent_list)
						log_reagents += " [reagent_id]"

					logTheThing("combat", usr, null, "ejected a test tube <i>(<b>Contents:</b>[log_reagents])</i>)")
					src.active_vial.set_loc(src.loc)
					src.active_vial = null

			if (href_list["etape"])
				if(src.tape)
					src.tape.set_loc(src.loc)
					src.tape = null

			if (href_list["disp"])
				if(src.active_vial && src.tape)
					var/datum/computer/file/disease/D = locate(href_list["disp"])
					if(!istype(D) || D.holder != src.tape || !D.disease_path)
						return
					// NOOOOOOO
					//var/datum/ailment/disease/new_ailment = new D.disease_path
					//src.active_vial.contained = new_ailment
					//new_ailment.spread = D.spread
					//new_ailment.cure = D.cure
					//new_ailment.name = D.disease_name
					//new_ailment.stage_prob = D.stage_prob
					//new_ailment.curable = D.curable
					//new_ailment.regress = D.regress
					//new_ailment.vaccine = D.vaccine

					//var/datum/reagent/disease/R = null
					//for(var/A in typesof(/datum/reagent/disease) - /datum/reagent/disease)
					//	R = new A()
					//	if (R.id == new_ailment.associated_reagent)
					//		R.Rvaccine = D.vaccine
					//		R.Rcurable = D.curable
					//		R.Rregress = D.regress
					//		R.Rspread = D.spread
					//		R.Rcure = D.cure
					//		R.Rprob = D.stage_prob
					//		break
					//	qdel(R)

					//if(R)
					//	src.active_vial.reagents.add_reagent_disease(R, 5)
					//	qdel(R)


			src.add_fingerprint(usr)
			for(var/mob/M in viewers(1, src))
				if ((M.client && M.machine == src))
					src.attack_hand(M)
		else
			usr.Browse(null, "window=dis_dispenser")
			return
		return

*/
