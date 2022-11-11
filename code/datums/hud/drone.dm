/datum/hud/drone
	var/atom/movable/screen/charge
	var/atom/movable/screen/health
	var/atom/movable/screen/disconnect
	var/mob/living/silicon/drone/master
	var/icon/icon_hud = 'icons/mob/hud_drone.dmi'
	var/list/tools = list(null, null, null, null, null)

	var/list/statusUiElements = list() //Assoc. List  STATUS EFFECT INSTANCE : UI ELEMENT add_screen(atom/movable/screen/S). Used to hold the ui elements since they shouldnt be on the status effects themselves.

	New(M)
		..()
		master = M
		charge = create_screen("health", "Condition", icon_hud, "health5", "NORTH, EAST", HUD_LAYER+1)
		charge = create_screen("charge", "Battery", icon_hud, "charge4", "NORTH, EAST-1", HUD_LAYER+1)
		disconnect = create_screen("disconnect", "Disconnect", icon_hud, "disconnect", "SOUTH, EAST", HUD_LAYER+1)
		tools[1] = create_screen("tool1", "Tool 1", icon_hud, "toolslot", "NORTH, 1", HUD_LAYER+1)
		tools[2] = create_screen("tool2", "Tool 2", icon_hud, "toolslot", "NORTH, 2", HUD_LAYER+1)
		tools[3] = create_screen("tool3", "Tool 3", icon_hud, "toolslot", "NORTH, 3", HUD_LAYER+1)
		tools[4] = create_screen("tool4", "Tool 4", icon_hud, "toolslot", "NORTH, 4", HUD_LAYER+1)
		tools[5] = create_screen("tool5", "Tool 5", icon_hud, "toolslot", "NORTH, 5", HUD_LAYER+1)
		update_health()
		update_charge()
		update_tools()

	clear_master()
		master = null
		..()

	relay_click(id)
		if (!master)
			return
		switch (id)
			if ("tool1")
				master.swap_hand(1)
			if ("tool2")
				master.swap_hand(2)
			if ("tool3")
				master.swap_hand(3)
			if ("tool4")
				master.swap_hand(4)
			if ("tool5")
				master.swap_hand(5)
			if ("charge")
				if (master.controller)
					if (master.cell)
						var/perc = round(100*master.cell.charge/master.cell.maxcharge)
						boutput(master.controller, "<span class='notice'>Current cell charge level is [perc]%.</span>")
					else
						boutput(master.controller, "<span class='alert'>No power cell installed. Only basic systems will be available.</span>")
			if ("disconnect")
				master.disconnect_user()

	proc
		update_health()
			if (!health)
				return
			if (isdead(master))
				health.icon_state = "dead"
			else
				switch(round(100*master.health/master.health_max))
					if(100 to INFINITY)
						health.icon_state = "health5"
					if(75 to 99)
						health.icon_state = "health4"
					if(50 to 75)
						health.icon_state = "health3"
					if(25 to 50)
						health.icon_state = "health2"
					if(1 to 25)
						health.icon_state = "health1"
					else
						health.icon_state = "health0"

		update_charge()
			if (!charge)
				return
			if (master.cell)
				switch(round(100*master.cell.charge/master.cell.maxcharge))
					if(75 to INFINITY)
						charge.icon_state = "charge4"
					if(50 to 75)
						charge.icon_state = "charge3"
					if(25 to 50)
						charge.icon_state = "charge2"
					if(1 to 25)
						charge.icon_state = "charge1"
					else
						charge.icon_state = "charge0"
			else
				charge.icon_state = "charge-none"

		set_active_tool()
			var/list_counter = 0
			var/atom/movable/screen/S = null
			for (var/obj/item/I in master.equipment_slots)
				list_counter++
				if (I == master.active_tool)
					S = tools[list_counter]
					S.icon_state = "toolslot1"
				else
					S = tools[list_counter]
					S.icon_state = "toolslot"

		update_tools()
			//for (var/obj/item/I in last_tools)
			//	remove_object(I)
			var/obj/item/tool1 = master.equipment_slots[1]
			var/obj/item/tool2 = master.equipment_slots[2]
			var/obj/item/tool3 = master.equipment_slots[3]
			var/obj/item/tool4 = master.equipment_slots[4]
			var/obj/item/tool5 = master.equipment_slots[5]
			if (tool1)
				add_object(tool1, HUD_LAYER+2, "NORTH, 1")
			if (tool2)
				add_object(tool2, HUD_LAYER+2, "NORTH, 2")
			if (tool3)
				add_object(tool3, HUD_LAYER+2, "NORTH, 3")
			if (tool4)
				add_object(tool4, HUD_LAYER+2, "NORTH, 4")
			if (tool5)
				add_object(tool5, HUD_LAYER+2, "NORTH, 5")

		update_status_effects()
			for(var/atom/movable/screen/statusEffect/G in src.objects)
				remove_screen(G)

			for(var/datum/statusEffect/S as anything in src.statusUiElements) //Remove stray effects.
				if(!master.statusEffects || !(S in master.statusEffects) )
					qdel(statusUiElements[S])
					src.statusUiElements.Remove(S)
					qdel(S)

			var/spacing = 0.6
			var/pos_x = spacing - 0.2 - 1

			if(master.statusEffects)
				for(var/datum/statusEffect/S as anything in master.statusEffects) //Add new ones, update old ones.
					if(!S.visible) continue
					if((S in statusUiElements) && statusUiElements[S])
						var/atom/movable/screen/statusEffect/U = statusUiElements[S]
						U.icon = icon_hud
						U.screen_loc = "EAST[pos_x < 0 ? "":"+"][pos_x],NORTH+0.3"
						U.update_value()
						add_screen(U)
						pos_x -= spacing
					else
						if(S.visible)
							var/atom/movable/screen/statusEffect/U = new /atom/movable/screen/statusEffect
							U.init(master,S)
							U.icon = icon_hud
							statusUiElements.Add(S)
							statusUiElements[S] = U
							U.screen_loc = "EAST[pos_x < 0 ? "":"+"][pos_x],NORTH+0.3"
							U.update_value()
							add_screen(U)
							pos_x -= spacing
							animate_buff_in(U)
			return

/mob/living/silicon/drone
	updateStatusUi()
		if(src.hud && istype(src.hud, /datum/hud/drone))
			var/datum/hud/drone/H = src.hud
			H.update_status_effects()
		return
