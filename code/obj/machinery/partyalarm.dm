//
// Party alarm
//

TYPEINFO(/obj/machinery/partyalarm)
	mats = 0

/obj/machinery/partyalarm
	name = "Party Button"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "party"
	desc = "WOOP WOOP PARTY ALARM WOOP WOOP"
	var/working = 1
	var/time = 10
	var/timing = 0
	var/party = 0
	var/duration = 60//admemes
	var/list/lights = list()
	anchored = 1

/obj/machinery/partyalarm/process()
	if (timing > 0)
		timing--

/obj/machinery/partyalarm/attack_hand(mob/user)
	if(user.stat || status & (NOPOWER|BROKEN))
		return

	if (!(src.working))
		return
	var/area/A = get_area(src)
	if (!(istype(A, /area)) || A.name == "Space" || A.name == "Ocean")
		return
	if (timing > 0)
		user.show_text("The party is still going on! Wait a little while longer before trying to shut it down.")
		return
	if (src.party)
		user.show_text("You shut the party down. What a killjoy.")
		src.party = 0
		for (var/obj/machinery/light/L in lights)
			L.light.set_color(initial(L.light.r), initial(L.light.g), initial(L.light.b))
	else
		src.party = 1
		playsound(user, 'sound/musical_instruments/partybutton.ogg', 25, 0)
		user.visible_message("<span style='color:purple'><B><font size=3>Let's get the party started!</font></B></span>")
		var/obj/machinery/light_area_manager/M = A.light_manager
		src.lights = M.lights
		src.party()
	return

/obj/machinery/partyalarm/proc/party()
	var/r = rand(100) / 100
	var/g = rand(100) / 100
	var/b = rand(100) / 100
	for (var/obj/machinery/light/L in lights)
		if (L.on)
			L.light.set_color(r, g, b)
	src.timing = duration
