/*CONTENTS
Gas Sensor
Siphon computer
*/

/obj/machinery/computer/atmosphere
	name = "atmos"

	light_r =0.85
	light_g = 0.86
	light_b = 1

/obj/machinery/computer/atmosphere/siphonswitch
	name = "area air control"
	icon_state = "atmos"
	var/otherarea
	var/area/area

/obj/machinery/computer/atmosphere/siphonswitch/mastersiphonswitch
	name = "Master Air Control"
