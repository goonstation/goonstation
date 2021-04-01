/mob/living/silicon/robot
	name = "Robot"
	voice_name = "synthesized voice"
	icon = 'robots.dmi'//
	icon_state = "robot"
	health = 300

//3 Modules can be activated at any one time.
	var/obj/item/weapon/robot_module/module = null
	var/module_state_1 = null
	var/module_state_2 = null
	var/module_state_3 = null

	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/weapon/cell/cell = null
	var/obj/machinery/camera/camera = null

	var/opened = 0
	var/emagged = 0
	var/wiresexposed = 0
	var/locked = 1
	var/list/req_access = list(access_robotics)
	//var/list/laws = list()
	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list())
	var/viewalerts = 0