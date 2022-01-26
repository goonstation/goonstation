
/obj/hud/proc/hivebot_hud()
	var/mob/living/silicon/hivebot/myhive = mymob

	src.adding = list(  )
	src.other = list(  )
	src.intents = list(  )
	src.mon_blo = list(  )
	src.m_ints = list(  )
	src.mov_int = list(  )
	src.darkMask = list(  )

	var/atom/movable/screen/using


//Radio
	using = new src.h_type( src )
	using.name = "radio"
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "radio"
	using.screen_loc = ui_movi
	using.layer = HUD_LAYER
	src.adding += using

//Generic overlays

	using = new src.h_type(src) //Right hud bar
	using.set_dir(SOUTH)
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.screen_loc = "EAST+1,SOUTH to EAST+1,NORTH"
	using.layer = HUD_LAYER_UNDER_1
	src.adding += using

	using = new src.h_type(src) //Lower hud bar
	using.set_dir(EAST)
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.screen_loc = "WEST,SOUTH-1 to EAST,SOUTH-1"
	using.layer = HUD_LAYER_UNDER_1
	src.adding += using

	using = new src.h_type(src) //Corner Button
	using.set_dir(NORTHWEST)
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.screen_loc = "EAST+1,SOUTH-1"
	using.layer = HUD_LAYER_UNDER_1
	src.adding += using


//Module select

	using = new src.h_type( src )
	using.name = "module1"
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv1"
	using.screen_loc = ui_inv1
	using.layer = HUD_LAYER
	src.adding += using
	myhive:inv1 = using

	using = new src.h_type( src )
	using.name = "module2"
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv2"
	using.screen_loc = ui_inv2
	using.layer = HUD_LAYER
	src.adding += using
	myhive:inv2 = using

	using = new src.h_type( src )
	using.name = "module3"
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv3"
	using.screen_loc = ui_inv3
	using.layer = HUD_LAYER
	src.adding += using
	myhive:inv3 = using

//End of module select

//Intent
	using = new src.h_type( src )
	using.name = "act_intent"
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = (myhive.a_intent == "harm" ? "harm" : myhive.a_intent)
	using.screen_loc = ui_acti
	using.layer = HUD_LAYER
	src.adding += using
	action_intent = using
/*
	using = new src.h_type( src )
	using.name = "arrowleft"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "s_arrow"
	using.set_dir(WEST)
	using.screen_loc = ui_iarrowleft
	using.layer = 19
	src.adding += using

	using = new src.h_type( src )
	using.name = "arrowright"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "s_arrow"
	using.set_dir(EAST)
	using.screen_loc = ui_iarrowright
	using.layer = 19
	src.adding += using
*/
//End of Intent

//Cell
	myhive:cells = new /atom/movable/screen( null )
	myhive:cells.icon = 'icons/mob/screen1_robot.dmi'
	myhive:cells.icon_state = "charge-empty"
	myhive:cells.name = "cell"
	myhive:cells.screen_loc = ui_cell

//Health
	myhive.healths = new /atom/movable/screen( null )
	myhive.healths.icon = 'icons/mob/screen1_robot.dmi'
	myhive.healths.icon_state = "health0"
	myhive.healths.name = "health"
	myhive.healths.screen_loc = ui_bothealth

//Installed Module
	myhive.hands = new /atom/movable/screen( null )
	myhive.hands.icon = 'icons/mob/screen1_robot.dmi'
	myhive.hands.icon_state = "nomod"
	myhive.hands.name = "module"
	myhive.hands.screen_loc = ui_module

//Module Panel
	using = new src.h_type( src )
	using.name = "panel"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "panel"
	using.screen_loc = ui_panel
	using.layer = HUD_LAYER_UNDER_1
	src.adding += using

//Store
	myhive.throw_icon = new /atom/movable/screen(null)
	myhive.throw_icon.icon = 'icons/mob/screen1_robot.dmi'
	myhive.throw_icon.icon_state = "store"
	myhive.throw_icon.name = "store"
	myhive.throw_icon.screen_loc = ui_botstore

//Temp
	myhive.bodytemp = new /atom/movable/screen( null )
	myhive.bodytemp.icon_state = "temp0"
	myhive.bodytemp.name = "body temperature"
	myhive.bodytemp.screen_loc = ui_bottemp

//does nothing (fire and oxy)
	myhive.oxygen = new /atom/movable/screen( null )
	myhive.oxygen.icon = 'icons/mob/screen1_robot.dmi'
	myhive.oxygen.icon_state = "oxy0"
	myhive.oxygen.name = "oxygen"
	myhive.oxygen.screen_loc = ui_boto2


	myhive.pullin = new /atom/movable/screen( null )
	myhive.pullin.icon = 'icons/mob/screen1_robot.dmi'
	myhive.pullin.icon_state = "pull0"
	myhive.pullin.name = "pull"
	myhive.pullin.screen_loc = ui_botpull

/*
	myhive.rest = new /atom/movable/screen( null )
	myhive.rest.icon = 'icons/mob/screen1_robot.dmi'
	myhive.rest.icon_state = "rest0"
	myhive.rest.name = "rest"
	myhive.rest.screen_loc = ui_rest
*/
	myhive.zone_sel = new(myhive, "EAST-4, SOUTH-1")
	myhive.attach_hud(myhive.zone_sel)

	myhive.client.screen = null

	myhive.throw_icon.add_to_client(myhive.client)
	//myhive.zone_sel.add_to_client(myhive.client)
	myhive.oxygen.add_to_client(myhive.client)
	myhive.hands.add_to_client(myhive.client)
	myhive.healths.add_to_client(myhive.client)
	myhive:cells.add_to_client(myhive.client)
	myhive.pullin.add_to_client(myhive.client)

	for(var/atom/movable/screen/O in adding)
		O.add_to_client(myhive.client)

	for(var/atom/movable/screen/O in other)
		O.add_to_client(myhive.client)


	return
