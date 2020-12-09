/datum/game_mode/sandbox
	name = "sandbox"
	config_tag = "sandbox"

/datum/game_mode/sandbox/announce()
	boutput(world, "<B>The current game mode is - Sandbox!</B>")
	boutput(world, "<B>Build your own station with the sandbox-panel command!</B>")

/datum/game_mode/sandbox/pre_setup()
	for(var/mob/M in mobs)
		if(M.client)
			M.CanBuild()

	return 1

/datum/game_mode/sandbox/check_finished()
	return 0

// migrated from h_sandbox.dm

var
	hsboxspawn = 1
	list
		hrefs = list(
					"hsbsuit" = "Suit Up (Space Travel Gear)",
					"hsbmetal" = "Spawn 50 Metal",
					"hsbglass" = "Spawn 50 Glass",
					"hsbairlock" = "Spawn Airlock",
					"hsbregulator" = "Spawn Air Regulator",
					"hsbfilter" = "Spawn Air Filter",
					"hsbcanister" = "Spawn Canister",
					"hsbfueltank" = "Spawn Welding Fuel Tank",
					"hsbwater	tank" = "Spawn Water Tank",
					"hsbtoolbox" = "Spawn Toolbox",
					"hsbmedkit" = "Spawn Medical Kit")

mob
	var
		datum/hSB/sandbox = null
	proc
		CanBuild()
			if(master_mode == "sandbox")
				sandbox = new/datum/hSB
				sandbox.owner = src.ckey
				if(src.client.holder)
					sandbox.admin = 1
				verbs += /mob/proc/sandbox_panel
		sandbox_panel()
			if(sandbox)
				sandbox.update()
//
datum/hSB
	var
		owner = null
		admin = 0
	proc
		update()
			var/hsbpanel = "<center><b>h_Sandbox Panel</b></center><hr>"
			if(admin)
				hsbpanel += "<b>Administration Tools:</b><br>"
				hsbpanel += "- <a href=\"?\ref[src];hsb=hsbtobj\">Toggle Object Spawning</a><br><br>"
			hsbpanel += "<b>Regular Tools:</b><br>"
			for(var/T in hrefs)
				hsbpanel += "- <a href=\"?\ref[src];hsb=[T]\">[hrefs[T]]</a><br>"
			if(hsboxspawn)
				hsbpanel += "- <a href=\"?\ref[src];hsb=hsbobj\">Spawn Object</a><br><br>"
			usr << browse(hsbpanel, "window=hsbpanel")
	Topic(href, href_list)
		if(!(src.owner == usr.ckey)) return
		if(!usr) return //I guess this is possible if they log out or die with the panel open? It happened.
		if(href_list["hsb"])
			switch(href_list["hsb"])
				if("hsbtobj")
					if(!admin) return
					if(hsboxspawn)
						boutput(world, "<b>Sandbox:  [usr.key] has disabled object spawning!</b>")
						hsboxspawn = 0
						return
					if(!hsboxspawn)
						boutput(world, "<b>Sandbox:  [usr.key] has enabled object spawning!</b>")
						hsboxspawn = 1
						return
				if("hsbsuit")
					var/mob/living/carbon/human/P = usr
					if(P.wear_suit)
						P.wear_suit.set_loc(P.loc)
						P.wear_suit.layer = initial(P.wear_suit.layer)
						P.wear_suit = null
					P.wear_suit = new/obj/item/clothing/suit/space(P)
					P.wear_suit.layer = HUD_LAYER
					if(P.head)
						P.head.set_loc(P.loc)
						P.head.layer = initial(P.head.layer)
						P.head = null
					P.head = new/obj/item/clothing/head/helmet/space(P)
					P.head.layer = HUD_LAYER
					if(P.wear_mask)
						P.wear_mask.set_loc(P.loc)
						P.wear_mask.layer = initial(P.wear_mask.layer)
						P.wear_mask = null
					P.wear_mask = new/obj/item/clothing/mask/gas(P)
					P.wear_mask.layer = HUD_LAYER
					if(P.back)
						P.back.set_loc(P.loc)
						P.back.layer = initial(P.back.layer)
						P.back = null
					P.back = new/obj/item/tank/jetpack(P)
					P.back.layer = HUD_LAYER
					P.internal = P.back
					for (var/obj/ability_button/tank_valve_toggle/T in P.internal.ability_buttons)
						T.icon_state = "airon"

				if("hsbmetal")
					var/obj/item/sheet/hsb = new/obj/item/sheet/steel
					hsb.amount = 50
					hsb.set_loc(usr.loc)
				if("hsbglass")
					var/obj/item/sheet/hsb = new/obj/item/sheet/glass
					hsb.amount = 50
					hsb.set_loc(usr.loc)
				if("hsbairlock")
					var/obj/machinery/door/hsb = new/obj/machinery/door/airlock

					//TODO: DEFERRED make this better, with an HTML window or something instead of 15 popups
					hsb.req_access = list()
					var/accesses = get_all_accesses()
					for(var/A in accesses)
						if(alert(usr, "Will this airlock require [get_access_desc(A)] access?", "Sandbox:", "Yes", "No") == "Yes")
							hsb.req_access += A

					hsb.set_loc(usr.loc)
					boutput(usr, "<b>Sandbox:  Created an airlock.")
				if("hsbcanister")
					var/list/hsbcanisters = childrentypesof(/obj/machinery/portable_atmospherics/canister/)
					var/hsbcanister = input(usr, "Choose a canister to spawn.", "Sandbox:") in hsbcanisters + "Cancel"
					if(!(hsbcanister == "Cancel"))
						new hsbcanister(usr.loc)
				if("hsbfueltank")
					//var/obj/hsb = new/obj/weldfueltank
					//hsb.set_loc(usr.loc)
				if("hsbwatertank")
					//var/obj/hsb = new/obj/watertank
					//hsb.set_loc(usr.loc)
				if("hsbtoolbox")
					var/obj/item/storage/hsb = new/obj/item/storage/toolbox/mechanical
					for(var/obj/item/device/radio/T in hsb)
						qdel(T)
					new/obj/item/crowbar (hsb)
					hsb.set_loc(usr.loc)
				if("hsbmedkit")
					var/obj/item/storage/firstaid/hsb = new/obj/item/storage/firstaid/regular
					hsb.set_loc(usr.loc)
				if("hsbobj")
					if(!hsboxspawn) return

					var/list/selectable = list()
					for(var/O in typesof(/obj/item/))
//						if(ispath(O, /obj/item/gun))
//							continue
//						if(ispath(O, /obj/item/assembly))
//							continue
//						if(ispath(O, /obj/item/camera))
//							continue
//						if(ispath(O, /obj/item/cloaking_device))
//							continue
						if(ispath(O, /obj/item/dummy))
							continue
						if(ispath(O, /obj/item/sword))
							continue
						if(ispath(O, /obj/item/device/shield))
							continue
						if(ispath(O, /obj/item/SWF_uplink))
							continue
						selectable += O

					var/hsbitem = input(usr, "Choose an object to spawn.", "Sandbox:") in selectable + "Cancel"
					if(hsbitem != "Cancel")
						new hsbitem(usr.loc)
