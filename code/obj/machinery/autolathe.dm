TYPEINFO(/obj/machinery/autolathe)
	mats = 20

/obj/machinery/autolathe
	name = "Autolathe"
	icon_state = "autolathe"
	desc = "A device that can break down various materials and turn them into other objects."
	density = 1
	var/m_amount = 0
	var/g_amount = 0
	var/operating = 0
	var/opened = 0
	var/temp = null
	anchored = 1
	var/list/L = list()
	var/list/LL = list()
	var/hacked = 0
	var/disabled = 0
	var/shocked = 0
	var/list/wires = list()
	var/hack_wire
	var/disable_wire
	var/shock_wire


/obj/machinery/autolathe/attackby(var/obj/item/O, var/mob/user)
	if (isscrewingtool(O))
		if (!opened)
			src.opened = 1
			src.icon_state = "autolathef"
		else
			src.opened = 0
			src.icon_state = "autolathe"
		return
	if (opened)
		boutput(user, "You can't load the autolathe while it's opened.")
		return
/*
	if (istype(O, /obj/item/grab) && src.hacked)
		var/obj/item/grab/G = O
		if (prob(25) && G.affecting)
			G.affecting.gib()
			m_amount += 50000
		return
*/
	if (istype(O, /obj/item/sheet/metal))
		if (src.m_amount < 150000.0)
			SPAWN(1.6 SECONDS) {
				flick("autolathe_c",src)
				src.m_amount += O:height * O:width * O:length * 100000
				O:amount--
				if (O:amount < 1)
					qdel(O)
			}
		else
			boutput(user, "The autolathe is full. Please remove metal from the autolathe in order to insert more.")
	else if (istype(O, /obj/item/sheet/glass) || istype(O, /obj/item/sheet/glass/reinforced))
		if (src.g_amount < 75000.0)
			SPAWN(1.6 SECONDS) {
				flick("autolathe_c",src)
				src.g_amount += O:height * O:width * O:length * 100000
				O:amount--
				if (O:amount < 1)
					qdel(O)
			}
		else
			boutput(user, "The autolathe is full. Please remove glass from the autolathe in order to insert more.")

	else if (O.g_amt || O.m_amt)
		SPAWN(1.6 SECONDS) {
			flick("autolathe_c",src)
			src.g_amount += O.g_amt
			src.m_amount += O.m_amt
			qdel (O)
		}
	else
		boutput(user, "This object does not contain significant amounts of metal or glass, or cannot be accepted by the autolathe due to size or hazardous materials.")

/obj/machinery/autolathe/attack_hand(user)
	var/dat
	if(..())
		return
	if (src.shocked)
		src.shock(user)
	if (src.opened)
		dat += "Autolathe Wires:<BR>"
		var/wire
		for(wire in src.wires)
			dat += text("[wire] Wire: <A href='?src=\ref[src];wire=[wire];act=wire'>[src.wires[wire] ? "Mend" : "Cut"]</A> <A href='?src=\ref[src];wire=[wire];act=pulse'>Pulse</A><BR>")

		dat += text("The red light is [src.disabled ? "off" : "on"].<BR>")
		dat += text("The green light is [src.shocked ? "off" : "on"].<BR>")
		dat += text("The blue light is [src.hacked ? "off" : "on"].<BR>")
		user << browse("<HEAD><TITLE>Autolathe Hacking</TITLE></HEAD>[dat]","window=autolathe_hack")
		onclose(user, "autolathe_hack")
		return
	if (src.disabled)
		boutput(user, "You press the button, but nothing happens.")
		return
	if (src.temp)
		dat = text("<TT>[]</TT><BR><BR><A href='?src=\ref[];temp=1'>Clear Screen</A>", src.temp, src)
	else
		dat = text("<B>Metal Amount:</B> [src.m_amount] cm<sup>3</sup> (MAX: 150,000)<BR><br><FONT color = blue><B>Glass Amount:</B></FONT> [src.g_amount] cm<sup>3</sup> (MAX: 75,000)<HR>")
		var/list/objs = list()
		objs += src.L
		if (src.hacked)
			objs += src.LL
		for(var/obj/t in objs)
			dat += text("<A href='?src=\ref[src];make=\ref[t]'>[t.name] ([t.m_amt] cc metal/[t.g_amt] cc glass)<BR>")
	user << browse("<HEAD><TITLE>Autolathe Control Panel</TITLE></HEAD><TT>[dat]</TT>", "window=autolathe_regular")
	onclose(user, "autolathe_regular")
	return

/obj/machinery/autolathe/Topic(href, href_list)
	if(..() || !(usr in range(1)))
		return
	src.add_dialog(usr)
	src.add_fingerprint(usr)
	if(href_list["make"])
		var/list/makeable = list()
		makeable += L
		if(hacked) makeable += LL
		var/obj/template = locate(href_list["make"]) in makeable
		if(src.m_amount >= template.m_amt && src.g_amount >= template.g_amt)
			src.operating = 1
			src.m_amount -= template.m_amt
			src.g_amount -= template.g_amt
			if(src.m_amount < 0)
				src.m_amount = 0
			if(src.g_amount < 0)
				src.g_amount = 0
			SPAWN(1.6 SECONDS)
				flick("autolathe_c",src)
				sleep(1.6 SECONDS)
				flick("autolathe_o",src)
				sleep(1.6 SECONDS)
				new template.type(usr.loc)
				src.operating = 0

	if(href_list["act"])
		if(href_list["act"] == "pulse")
			if (!usr.find_tool_in_hand(TOOL_PULSING))
				boutput(usr, "You need a multitool or similar!")
			else
				if(src.wires[href_list["wire"]])
					boutput(usr, "You can't pulse a cut wire.")
				else
					if(src.hack_wire == href_list["wire"])
						src.hacked = !src.hacked
						SPAWN(10 SECONDS) src.hacked = !src.hacked
					if(src.disable_wire == href_list["wire"])
						src.disabled = !src.disabled
						src.shock(usr)
						SPAWN(10 SECONDS) src.disabled = !src.disabled
					if(src.shock_wire == href_list["wire"])
						src.shocked = !src.shocked
						src.shock(usr)
						SPAWN(10 SECONDS) src.shocked = !src.shocked
		if(href_list["act"] == "wire")
			if (!usr.find_tool_in_hand(TOOL_SNIPPING))
				boutput(usr, "You need wirecutters!")
			else
				if(src.hack_wire == href_list["wire"])
					src.hacked = !src.hacked
				if(src.disable_wire == href_list["wire"])
					src.disabled = !src.disabled
					src.shock(usr)
				if(src.shock_wire == href_list["wire"])
					src.shocked = !src.shocked
					src.shock(usr)

	if (href_list["temp"])
		src.temp = null

	for(var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			src.Attackhand(M)
	return

/obj/machinery/autolathe/New()
	..()
	// screwdriver removed
	src.L += new /obj/item/wirecutters(src)
	src.L += new /obj/item/wrench(src)
	src.L += new /obj/item/crowbar(src)
	src.L += new /obj/item/weldingtool(src)
	src.L += new /obj/item/clothing/head/helmet/welding(src)
	src.L += new /obj/item/device/multitool(src)
	src.L += new /obj/item/device/light/flashlight(src)
	src.L += new /obj/item/extinguisher(src)
	src.L += new /obj/item/sheet/metal(src)
	src.L += new /obj/item/sheet/glass(src)
	src.L += new /obj/item/sheet/r_metal(src)
	src.L += new /obj/item/sheet/glass/reinforced(src)
	src.L += new /obj/item/rods(src)
	src.L += new /obj/item/rcd_ammo(src)
	src.L += new /obj/item/scalpel(src)
	src.L += new /obj/item/circular_saw(src)
	src.L += new /obj/item/device/t_scanner(src)
	src.L += new /obj/item/reagent_containers/food/drinks/cola_bottle(src)
	src.L += new /obj/item/device/gps(src)
	src.LL += new /obj/item/gun/flamethrower/assembled(src)
	src.LL += new /obj/item/device/igniter(src)
	src.LL += new /obj/item/device/timer(src)
	src.LL += new /obj/item/rcd(src)
	src.LL += new /obj/item/device/infra(src)
	src.LL += new /obj/item/device/infra_sensor(src)
	src.LL += new /obj/item/handcuffs(src)
	src.LL += new /obj/item/ammo/bullets/a357(src)
	src.LL += new /obj/item/ammo/bullets/a38(src)
	src.LL += new /obj/item/ammo/bullets/a12(src)
	src.wires["Light Red"] = 0
	src.wires["Dark Red"] = 0
	src.wires["Blue"] = 0
	src.wires["Green"] = 0
	src.wires["Yellow"] = 0
	src.wires["Black"] = 0
	src.wires["White"] = 0
	src.wires["Gray"] = 0
	src.wires["Orange"] = 0
	src.wires["Pink"] = 0
	var/list/w = list("Light Red","Dark Red","Blue","Green","Yellow","Black","White","Gray","Orange","Pink")
	src.hack_wire = pick(w)
	w -= src.hack_wire
	src.shock_wire = pick(w)
	w -= src.shock_wire
	src.disable_wire = pick(w)
	w -= src.disable_wire

/obj/machinery/autolathe/proc/get_connection()
	var/turf/T = src.loc
	if(!istype(T, /turf/simulated/floor))
		return

	for(var/obj/cable/C in T)
		if(C.d1 == 0)
			return C.netnum

	return 0

/obj/machinery/autolathe/proc/shock(M as mob)
	return src.electrocute(M, 50, get_connection())
