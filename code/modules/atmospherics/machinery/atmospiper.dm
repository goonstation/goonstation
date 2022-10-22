

/obj/machinery/atmos_pipedispenser
	name = "Atmospheric Pipe Dispenser"
	desc = "A fancy, new machine that dispenses atmos constructs one at a time."
	icon = 'icons/obj/manufacturer.dmi'
	icon_state = "pipe-fab"
	density = 1
	anchored = 1
	mats = 16
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS

	var/dat
	var/static/list/pipesforcreation = list(
	"Pipe" = /obj/machinery/atmospherics/pipe/simple/overfloor,
	"Bent pipe" = /obj/machinery/atmospherics/pipe/simple/overfloor/bent,
	"Manifold" = /obj/machinery/atmospherics/pipe/manifold/overfloor,
	"Passive vent" = /obj/machinery/atmospherics/pipe/vent,
	"Pressure tank" = /obj/machinery/atmospherics/pipe/tank,
	"Passive gate" = /obj/machinery/atmospherics/binary/passive_gate,
	"Pressure pump" = /obj/machinery/atmospherics/binary/pump,
	"Volume pump" = /obj/machinery/atmospherics/binary/volume_pump,
	"Portable connector" = /obj/machinery/atmospherics/portables_connector,
	"Manual valve" = /obj/machinery/atmospherics/valve,
	"Digital valve" = /obj/machinery/atmospherics/valve/digital,
	"Furnace connector" = /obj/machinery/atmospherics/unary/furnace_connector,
	"Outlet Injector" = /obj/machinery/atmospherics/unary/outlet_injector,
	"Vent pump" = /obj/machinery/atmospherics/unary/vent_pump
	)

/obj/machinery/atmos_pipedispenser/New(mob/user)
	..()
	dat = {"<b>Atmos Pipes</b><br><br>"}

	for (var/type in pipesforcreation)
		dat += "<A href='?src=\ref[src];dmake=[type]'>[type]</A><BR>"

/obj/machinery/atmos_pipedispenser/attack_hand(mob/user)
	if(..())
		return

	user.Browse("<HEAD><TITLE>Disposal Pipe Dispenser</TITLE></HEAD><TT>[dat]</TT>", "window=pipedispenser")
	return

// 0=straight, 1=bent, 2=junction-j1, 3=junction-j2, 4=junction-y, 5=trunk


/obj/machinery/atmos_pipedispenser/Topic(href, href_list)
	if(..())
		return
	src.add_dialog(usr)
	src.add_fingerprint(usr)
	if(href_list["dmake"])
		var/path = pipesforcreation[(href_list["dmake"])]
		var/obj/machinery/atmospherics/temp = new path()
		new /obj/item/pipeconstruct(src.loc, temp)
		qdel(temp)

		usr.Browse(null, "window=pipedispenser")
		src.remove_dialog(usr)
	return
