/obj/machinery/computer/operating
	name = "Operating Computer"
	density = 1
	anchored = 1
	icon = 'icons/obj/computer.dmi'
	icon_state = "operating"
	desc = "Shows information on a patient laying on an operating table."
	power_usage = 500
	can_reconnect = TRUE
	circuit_type = /obj/item/circuitboard/operating

	var/mob/living/carbon/human/victim = null

	var/obj/machinery/optable/table = null
	id = 0

/obj/machinery/computer/operating/New()
	..()
	SPAWN(0.5 SECONDS)
		connection_scan()

/obj/machinery/computer/operating/connection_scan()
	src.table = locate(/obj/machinery/optable, orange(2,src))

/obj/machinery/computer/operating/attack_hand(mob/user)
	add_fingerprint(user)
	if(status & (BROKEN|NOPOWER))
		return
	interacted(user)

/obj/machinery/computer/operating/proc/interacted(mob/user)
	if (!in_interact_range(src,user) || (status & (BROKEN|NOPOWER)) )
		src.remove_dialog(user)
		user.Browse(null, "window=op")
		return

	src.add_dialog(user)
	var/dat = "<HEAD><TITLE>Operating Computer</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY><br>"
	dat += "<A HREF='?action=mach_close&window=op'>Close</A><br><br>" //| <A HREF='?src=\ref[user];update=1'>Update</A>"
	if(src.table && (src.table.check_victim()))
		src.victim = src.table.victim
		dat += {"
<B>Patient Information:</B><BR>
<BR>
<B>Name:</B> [src.victim.real_name]<BR>
<B>Age:</B> [src.victim.bioHolder.age]<BR>
<B>Blood Type:</B> [src.victim.bioHolder.bloodType]<BR>
<BR>
<B>Health:</B> [src.victim.health]<BR>
<B>Brute Damage:</B> [src.victim.get_brute_damage()]<BR>
<B>Toxins Damage:</B> [src.victim.get_toxin_damage()]<BR>
<B>Fire Damage:</B> [src.victim.get_burn_damage()]<BR>
<B>Suffocation Damage:</B> [src.victim.get_oxygen_deprivation()]<BR>
<B>Patient Status:</B> [src.victim.stat ? "Non-responsive" : "Stable"]<BR>
"}
	else
		src.victim = null
		dat += {"
<B>Patient Information:</B><BR>
<BR>
<B>No Patient Detected</B>
"}
	user.Browse(dat, "window=op")
	onclose(user, "op")

/obj/machinery/computer/operating/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		src.add_dialog(usr)
//		if (href_list["update"])
//			src.interacted(usr)
	return

/obj/machinery/computer/operating/process()
	..()
	if (status & (BROKEN | NOPOWER))
		return
	use_power(250)

	src.updateDialog()
