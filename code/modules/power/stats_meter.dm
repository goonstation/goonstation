/obj/machinery/power/stats_meter
	name = "Gas Meter"
	icon = 'icons/obj/reactorstats_meter.dmi'
	icon_state = "meter_anim"
	var/obj/machinery/atmospherics/pipe/target = null
	anchored = ANCHORED

/obj/machinery/power/stats_meter/New()
	..()
	src.target = locate(/obj/machinery/atmospherics/pipe) in loc
	return 1

/obj/machinery/power/stats_meter/proc/add_overlay(I as icon)
	overlays += I

/obj/machinery/power/stats_meter/proc/del_overlay(I as icon)
	overlays -= I

/obj/machinery/power/stats_meter/proc/set_bars(N as num)

	del_overlay("bar1_overlay")
	del_overlay("bar2_overlay")
	del_overlay("bar3_overlay")
	del_overlay("bar4_overlay")
	del_overlay("bar5_overlay")

	if(N > 0)
		add_overlay("bar1_overlay")
	if(N >= 1e5)
		add_overlay("bar2_overlay")
	if(N >= 1e8)
		add_overlay("bar3_overlay")
	if(N >= 1e11)
		add_overlay("bar4_overlay")
	if(N >= 1e15)
		add_overlay("bar5_overlay")
