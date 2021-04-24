/*
		Radio Antennas. Cell phones require a signal to work!
*/

/var/global/list/radio_antennas = list()

/obj/machinery/radio_antenna
	icon='icons/obj/large/32x64.dmi'
	icon_state = "commstower"
	var/range = 10
	var/active = 0

	process()
		..()

	proc/get_max_range()
		return range * 5

	proc/process_message()

/obj/machinery/radio_antenna/large
	range = 40
