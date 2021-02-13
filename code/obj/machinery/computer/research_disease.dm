/obj/machinery/computer/research

/obj/machinery/computer/research/disease
	name = "Disease Database"
	icon_state = "resdis"
	req_access = list(access_tox)
	object_flags = CAN_REPROGRAM_ACCESS
	var/obj/item/card/id/scan = null
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/datum/data/record/active1 = null
	var/datum/data/record/active2 = null
	var/a_id = null
	var/temp = null
	var/printing = null

	light_r =1
	light_g = 0.3
	light_b = 0.9

/obj/machinery/computer/research/disease/attack_ai(user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/research/disease/attack_hand(mob/user as mob)
	if(..())
		return

	src.add_dialog(user)

	var/dat
	if (src.temp)
		dat = {"
<TT>[src.temp]</TT><BR><BR><A href='?src=\ref[src];temp=1'>Clear Screen</A>
"}
	else
		dat = {"
Confirm Identity: <A href='?src=\ref[src];scan=1'>[src.scan ? src.scan.name : "----------"]</A><HR>
"}
		if (src.authenticated)
			switch(src.screen)
				if(1.0)
					dat += {"
<B>Tier [disease_research.tier] Disease Research</B>
<HR>
"}
					if(disease_research.is_researching)
						var/timeleft = disease_research.get_research_timeleft()
						var/text = disease_research.current_research
						dat += "<BR>Current Research: [text ? text : "None"]. ETA: [timeleft ? timeleft : "Completed"]."
					else
						dat += {"<BR>Currently not researching."}
					dat += {"
<BR><BR><A href='?src=\ref[src];screen=2'>Research</A>
<BR>
<BR><A href='?src=\ref[src];screen=3'>Researched Items</A>
<BR>
<BR><A href='?src=\ref[src];logout=1'>{Log Out}</A><BR>
"}

//


				if(2.0)
					dat += {"
<B>Research List</B>:<HR><BR>"}

					if(disease_research.check_if_tier_completed() && (disease_research.tier < disease_research.max_tiers))
						dat += "<A href='?src=\ref[src];advt=1'>Advance Research Tier</A>"
					else if(disease_research.check_if_tier_completed())
						dat += "No more research can be conducted<BR>"
					else
						for(var/datum/ailment/a in disease_research.items_to_research[disease_research.tier])
							dat += {"<A href='?src=\ref[src];res=\ref[a]'>[a.name]</A><BR>"}

					dat += {"<HR><A href='?src=\ref[src];screen=1'>Back</A>"}

				if(3.0)
					dat += {"
<B>Items Researched</B>:<HR>"}
					for(var/i = disease_research.starting_tier, i <= disease_research.max_tiers, i++)
						dat += {"
<BR><BR><B>Tier: [i]</B>
"}
						for(var/a in disease_research.researched_items[i])
							dat += {"
<BR><A href='?src=\ref[src];read=\ref[a]'>[a]</A>
"}
					dat += {"
<HR><BR><A href='?src=\ref[src];screen=1'>Back</A>
"}

				else
		else
			dat += text("<A href='?src=\ref[src];login=1'>{Log In}</A>")
	user.Browse(text("<HEAD><TITLE>Disease Research</TITLE></HEAD><TT>[]</TT>", dat), "window=dis_res")
	onclose(user, "dis_res")
	return

/obj/machinery/computer/research/disease/Topic(href, href_list)
	if(..())
		return
	if (!( data_core.general.Find(src.active1) ))
		src.active1 = null
	if (!( data_core.medical.Find(src.active2) ))
		src.active2 = null
	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		src.add_dialog(usr)
		if (href_list["temp"])
			src.temp = null
		if (href_list["scan"])
			if (src.scan)
				src.scan.set_loc(src.loc)
				src.scan = null
			else
				var/obj/item/I = usr.equipped()
				if (istype(I, /obj/item/card/id))
					usr.drop_item()
					I.set_loc(src)
					src.scan = I
				else if (istype(I, /obj/item/magtractor))
					var/obj/item/magtractor/mag = I
					if (istype(mag.holding, /obj/item/card/id))
						I = mag.holding
						mag.dropItem(0)
						I.set_loc(src)
						src.scan = I
		else if (href_list["logout"])
			src.authenticated = null
			src.screen = null
			src.active1 = null
			src.active2 = null
		else if (href_list["login"])
			if ((issilicon(usr) || isAI(usr)) && !isghostdrone(usr))
				src.active1 = null
				src.active2 = null
				src.authenticated = 1
				src.rank = "AI"
				src.screen = 1
			else if (istype(src.scan, /obj/item/card/id))
				src.active1 = null
				src.active2 = null
				if (src.check_access(src.scan))
					src.authenticated = src.scan.registered
					src.rank = src.scan.assignment
					src.screen = 1
		if (src.authenticated)
			if(href_list["screen"])
				src.screen = text2num(href_list["screen"])
				if(src.screen < 1)
					src.screen = 1

				src.active1 = null
				src.active2 = null

		if(href_list["advt"])
			disease_research.advance_tier()

		if(href_list["res"])
			var/datum/ailment/researched_item = locate(href_list["res"])
			if(disease_research.start_research(disease_research.tier*1000, researched_item))
				boutput(usr, "<span class='notice'>Commencing research</span>")
			else
				boutput(usr, "<span class='notice'>Could not start research</span>")

//		if(href_list["read"])

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

