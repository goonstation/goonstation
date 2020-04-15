#define MAX_QUEUE_LENGTH 20

/obj/machinery/manufacturer
	name = "Manufacturing Unit"
	desc = "A standard fabricator unit capable of producing certain items from various materials."
	icon = 'icons/obj/manufacturer.dmi'
	icon_state = "fab"
	var/icon_base = null
	density = 1
	anchored = 1
	mats = 20
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL
	flags = NOSPLASH
	var/health = 100
	var/mode = "ready"
	var/error = null
	var/speed = 3
	var/repeat = 0
	var/timeleft = 0
	var/manual_stop = 0
	var/panelopen = 0
	var/powconsumption = 0
	var/hacked = 0
	var/malfunction = 0
	var/electrified = 0
	var/accept_blueprints = 1
	var/page = 0 // temporary measure, i want a better UI for this =(
	var/retain_output_internally = -1
	var/dismantle_stage = 0
	var/output_cap = 20
	// 0 is =>, 1 is ==
	var/base_material_class = /obj/item/material_piece/
	var/obj/item/reagent_containers/glass/beaker = null
	var/list/cuttings = list()
	var/area_name = null
	var/output_target = null
	var/list/materials_in_use = list()
	var/list/available = list()
	var/list/download = list()
	var/list/hidden = list()
	var/list/queue = list()
	var/last_queue_op = 0

	var/category = null
	var/list/categories = list("Tool","Clothing","Resource","Component","Machinery","Miscellaneous", "Downloaded")
	var/search = null
	var/wires = 15
	var/image/work_display = null
	var/image/activity_display = null
	var/image/panel_sprite = null
	var/list/free_resources = list()
	var/free_resource_amt = 0
	var/list/nearby_turfs = list()
	var/sound_happy = 'sound/machines/chime.ogg'
	var/sound_grump = 'sound/machines/buzz-two.ogg'
	var/sound_beginwork = 'sound/machines/computerboot_pc.ogg'
	var/sound_damaged = 'sound/impact_sounds/Metal_Hit_Light_1.ogg'
	var/sound_destroyed = 'sound/impact_sounds/Machinery_Break_1.ogg'
	power_usage = 200
	var/static/list/sounds_malfunction = list('sound/machines/engine_grump1.ogg','sound/machines/engine_grump2.ogg','sound/machines/engine_grump3.ogg',
	'sound/machines/glitch1.ogg','sound/machines/glitch2.ogg','sound/machines/glitch3.ogg','sound/impact_sounds/Metal_Clang_1.ogg','sound/impact_sounds/Metal_Hit_Heavy_1.ogg','sound/machines/romhack1.ogg','sound/machines/romhack3.ogg')
	var/static/list/text_flipout_adjective = list("an awful","a terrible","a loud","a horrible","a nasty","a horrendous")
	var/static/list/text_flipout_noun = list("noise","racket","ruckus","clatter","commotion","din")
	var/list/text_bad_output_adjective = list("janky","crooked","warped","shoddy","shabby","lousy","crappy","shitty")

#define WIRE_EXTEND 1
#define WIRE_POWER 2
#define WIRE_MALF 3
#define WIRE_SHOCK 4

	New()
		..()
		src.area_name = src.loc.loc.name

		if (istype(manuf_controls,/datum/manufacturing_controller))
			src.set_up_schematics()
			manuf_controls.manufacturing_units += src

		for (var/turf/T in view(5,src))
			nearby_turfs += T

		var/datum/reagents/R = new/datum/reagents(1000)
		reagents = R
		R.maximum_volume = 1000
		R.my_atom = src

		src.work_display = image('icons/obj/manufacturer.dmi', "")
		src.activity_display = image('icons/obj/manufacturer.dmi', "")
		src.panel_sprite = image('icons/obj/manufacturer.dmi', "")
		SPAWN_DBG(0)
			src.build_icon()

	disposing()
		manuf_controls.manufacturing_units -= src
		src.work_display = null
		src.activity_display = null
		src.panel_sprite = null
		src.output_target = null
		src.beaker = null
		src.available.len = 0
		src.available = null
		src.download.len = 0
		src.download = null
		src.hidden.len = 0
		src.hidden = null
		src.queue.len = 0
		src.queue = null
		src.nearby_turfs.len = 0
		src.nearby_turfs = null
		src.sound_happy = null
		src.sound_grump = null
		src.sound_beginwork = null
		src.sound_damaged = null
		src.sound_destroyed = null

		for (var/obj/O in src.contents)
			O.loc = src.loc
		for (var/mob/M in src.contents)
			// unlikely as this is to happen we might as well make sure everything is purged
			M.loc = src.loc

		..()

	examine()
		..()
		if (src.health < 100)
			if (src.health < 50)
				boutput(usr, "<span style=\"color:red\">It's rather badly damaged. It probably needs some wiring replaced inside.</span>")
			else
				boutput(usr, "<span style=\"color:red\">It's a bit damaged. It looks like it needs some welding done.</span>")
		if	(status & BROKEN)
			boutput(usr, "<span style=\"color:red\">It seems to be damaged beyond the point of operability.</span>")
		if	(status & NOPOWER)
			boutput(usr, "<span style=\"color:red\">It seems to be offline.</span>")
		switch(src.dismantle_stage)
			if(1)
				boutput(usr, "<span style=\"color:red\">It's partially dismantled. To deconstruct it, use a crowbar. To repair it, use a wrench.</span>")
			if(2)
				boutput(usr, "<span style=\"color:red\">It's partially dismantled. To deconstruct it, use wirecutters. To repair it, add reinforced metal.</span>")
			if(3)
				boutput(usr, "<span style=\"color:red\">It's partially dismantled. To deconstruct it, use a wrench. To repair it, add some cable.</span>")

	process()
		if (status & NOPOWER)
			return

		power_usage = src.powconsumption + 200
		..()
		if (src.mode == "working")
			if (src.malfunction && prob(8))
				src.flip_out()
			src.timeleft -= src.speed * 2
			use_power(src.powconsumption)
			if (src.timeleft < 1)
				src.output_loop(src.queue[1])
				SPAWN_DBG(0)
					if (src.queue.len < 1)
						src.manual_stop = 0
						playsound(src.loc, src.sound_happy, 50, 1)
						src.visible_message("<span style=\"color:blue\">[src] finishes its production queue.</span>")
						src.mode = "ready"
						src.build_icon()

		if (src.electrified > 0)
			src.electrified--

	ex_act(severity)
		switch(severity)
			if(1.0)
				for(var/atom/movable/A as mob|obj in src)
					A.set_loc(src.loc)
					A.ex_act(severity)
				src.take_damage(rand(100,120))
			if(2.0)
				src.take_damage(rand(40,80))
			if(3.0)
				src.take_damage(rand(20,40))
		return

	blob_act(var/power)
		src.take_damage(rand(power * 0.5, power * 1.5))

	meteorhit()
		src.take_damage(rand(15,45))

	emp_act()
		src.take_damage(rand(5,10))
		src.malfunction = 1
		src.flip_out()

	bullet_act(var/obj/projectile/P)
		// swiped from guardbot.dm
		var/damage = 0
		damage = round(((P.power/6)*P.proj_data.ks_ratio), 1.0)

		if(src.material) src.material.triggerOnBullet(src, src, P)

		if (!damage)
			return
		if(P.proj_data.damage_type == D_KINETIC || (P.proj_data.damage_type == D_ENERGY && damage))
			src.take_damage(damage / 2)
		else if (P.proj_data.damage_type == D_PIERCING)
			src.take_damage(damage)

	power_change()
		if(status & BROKEN)
			src.build_icon()
		else
			if(powered() && src.dismantle_stage < 3)
				status &= ~NOPOWER
				src.build_icon()
			else
				SPAWN_DBG(rand(0, 15))
					status |= NOPOWER
					src.build_icon()

	attack_hand(var/mob/user as mob)
		if (free_resource_amt > 0)
			claim_free_resources()

		if(src.electrified != 0)
			if (!(status & NOPOWER || status & BROKEN))
				if (src.manuf_zap(user, 33))
					return

		user.machine = src
		var/list/dat = list("<B>[src.name]</B>")
		//dat += "<A href='?src=\ref[src];shake=0'>(shake)</A>"

		if (src.panelopen || isAI(user))
			var/list/manuwires = list(
			"Amber" = 1,
			"Teal" = 2,
			"Indigo" = 3,
			"Lime" = 4,
			)
			var/list/pdat = list("<B>[src] Maintenance Panel</B><hr>")
			for(var/wiredesc in manuwires)
				var/is_uncut = src.wires & APCWireColorToFlag[manuwires[wiredesc]]
				pdat += "[wiredesc] wire: "
				if(!is_uncut)
					pdat += "<a href='?src=\ref[src];cutwire=[manuwires[wiredesc]]'>Mend</a>"
				else
					pdat += "<a href='?src=\ref[src];cutwire=[manuwires[wiredesc]]'>Cut</a> "
					pdat += "<a href='?src=\ref[src];pulsewire=[manuwires[wiredesc]]'>Pulse</a> "
				pdat += "<br>"

			pdat += "<br>"
			if (status & BROKEN || status & NOPOWER)
				pdat += "The yellow light is off.<BR>"
				pdat += "The blue light is off.<BR>"
				pdat += "The white light is off.<BR>"
				pdat += "The red light is off.<BR>"
			else
				pdat += "The yellow light is [(src.electrified == 0) ? "off" : "on"].<BR>"
				pdat += "The blue light is [src.malfunction ? "flashing" : "on"].<BR>"
				pdat += "The white light is [src.hacked ? "on" : "off"].<BR>"
				pdat += "The red light is on.<BR>"

			user.Browse(pdat.Join(), "window=manupanel")
			onclose(user, "manupanel")

		if (status & BROKEN || status & NOPOWER)
			dat = "The screen is blank."
			user.Browse(dat, "window=manufact;size=400x500")
			onclose(user, "manufact")
			return

		if (src.error)
			dat += "<br><font face=\"fixedsys\" size=\"2\" color=\"#FF0000\"><b>ERROR: [src.error]</b></font>"
		if (src.mode == "halt")
			dat += "<br><A href='?src=\ref[src];continue=1'><u><b>Resume Production</b></u></a>"
		else if (src.mode == "working")
			var/datum/manufacture/M = src.queue[1]
			if (istype(M,/datum/manufacture/))
				var/TL = src.timeleft
				if (src.speed != 0)
					TL = round(TL / src.speed)
				dat += "<br><small>Current: [M.name] (ETC: [TL]) | <A href='?src=\ref[src];pause=1'><u><b>Pause</b></u></a></small>"

		dat += build_control_panel()
		dat += "<br>"
		dat += build_material_list()

		dat += "</small><HR>"

		if (!page)
			dat += "<B>Available Schematics</B><br>"
			if(istext(src.search))
				dat += " <small>(Search: \"[html_encode(src.search)]\")</small>"
			if(istext(src.category))
				dat += " <small>(Filter: \"[html_encode(src.category)]\")</small>"

			dat += "<small>"
			if (src.category != "Downloaded")
				for(var/datum/manufacture/A in src.available)
					var/list/mats_used = material_check(A)

					if (istext(src.search) && !findtext(A.name, src.search, 1, null))
						continue
					else if (istext(src.category) && src.category != A.category)
						continue

					if (isnull(mats_used))
						dat += "<BR><font color = 'red'><b><u>[A.name]</u></b></font> "		//change this name to red if can't be made
					else
						dat += "<BR><A href='?src=\ref[src];disp=\ref[A]'><b><u>[A.name]</u></b></A> "		//change this name to normal if available

					if (istext(A.category))
						dat += "([A.category])"
					dat += "<br>"

					var/list_count = 1
					for (var/X in A.item_paths)
						if (list_count != 1) dat += ", "
						var/found = 0
						var/list/usable_materials = get_mat_ids(A)

						//get all mat_ids in this manufacturable	needed to get the actual material to use in the material pattern match
						for (var/mat_id in usable_materials)
							if (usable_materials[mat_id] < A.item_amounts[list_count])
								continue
							var/datum/material/mat = getMaterial(mat_id)
							if (match_material_pattern(X, mat))
								found = 1
								break

						if (found)
							dat += "[A.item_amounts[list_count]] [A.item_names[list_count]]"		//change this line to red if mising <font color = "red">
						else
							dat += "<font color = 'red'>[A.item_amounts[list_count]] [A.item_names[list_count]]</font>"		//change this line to red if mising <font color = "red">

						list_count++

					if (A.time == 0 || src.speed == 0)
						dat += "<br><b>Time:</b> ERROR<br>"
					else
						dat += "<br><b>Time:</b> [round((A.time / src.speed))] Seconds<br>"

				if (src.hacked)
					for(var/datum/manufacture/A in src.hidden)
						if (istext(src.search) && !findtext(A.name, src.search, 1, null))
							continue
						else if (istext(src.category) && src.category != A.category)
							continue
						dat += "<BR><A href='?src=\ref[src];disp=\ref[A]'><b><u>[A.name]</u></b></A> "
						if (istext(A.category))
							dat += "([A.category]) "
						dat += "(Secret)<br>"
						var/list_count = 1
						for (var/X in A.item_paths)
							if (list_count != 1) dat += ", "
							dat += "[A.item_amounts[list_count]] [A.item_names[list_count]]"
							list_count++
						if (A.time == 0 || src.speed == 0)
							dat += "<br><b>Time:</b> ERROR<br>"
						else
							dat += "<br><b>Time:</b> [round((A.time / src.speed))] Seconds<br>"

			for(var/datum/manufacture/A in src.download)
				if (istext(src.search) && !findtext(A.name, src.search, 1, null))
					continue
				else if (istext(src.category))
					if (src.category != "Downloaded" && src.category != A.category)
						continue
				dat += "<BR><A href='?src=\ref[src];disp=\ref[A]'><b><u>[A.name]</u></b></A> "
				if (istext(A.category))
					dat += "([A.category]) "
				dat += "(Downloaded)<br>"
				var/list_count = 1
				for (var/X in A.item_paths)
					if (list_count != 1) dat += ", "
					dat += "[A.item_amounts[list_count]] [A.item_names[list_count]]"
					list_count++
				if (A.time == 0 || src.speed == 0)
					dat += "<br><b>Time:</b> ERROR<br>"
				else
					dat += "<br><b>Time:</b> [round((A.time / src.speed))] Seconds<br>"
			dat += "</small>"


		else if (page == 1)
			dat += "<B>Production Queue</B> <A href='?src=\ref[src];clearQ=1'>(Clear)</A>"
			if (src.queue.len > 0)
				var/queue_num = 1
				var/cumulative_time = 0
				var/timeleft = src.timeleft
				var/datum/manufacture/M = src.queue[1]
				if (istype(M,/datum/manufacture/) && src.speed != 0 && timeleft != 0)
					timeleft = round(timeleft / src.speed)
				cumulative_time = timeleft
				for(var/datum/manufacture/A in src.queue)
					if (queue_num == 1)
						dat += "<BR><small><b><u>Current Production: [A.name] (ETC: [timeleft])</b></u></A>"
						if (src.mode != "working")
							dat += " <A href='?src=\ref[src];removefromQ=[queue_num]'>(Remove)</A>"
					else
						if (src.speed != 0)
							cumulative_time += round(A.time / src.speed)
						else
							cumulative_time += A.time
						dat += "<BR>[queue_num]) [A.name] (ETC: [cumulative_time]) <A href='?src=\ref[src];removefromQ=[queue_num]'>(Remove)</A>"
					queue_num++
			else
				dat += "<BR>Queue is empty."

		dat += "<hr>"

		user.Browse(dat.Join(), "window=manufact;size=450x500")
		onclose(user, "manufact")

		interact_particle(user,src)

	// Validate that an item is inside this machine for HREF check purposes
	proc/validate_disp(var/datum/manufacture/M)
		if(src.available && src.available.Find(M))
			return 1

		if(src.download && src.download.Find(M))
			return 1

		if(src.hacked && src.hidden && src.hidden.Find(M))
			return 1

		return 0


	Topic(href, href_list)

		if(!(href_list["cutwire"] || href_list["pulsewire"]))
			if(status & BROKEN || status & NOPOWER)
				return

		if(usr.stat || usr.restrained())
			return

		if(src.electrified != 0)
			if (!(status & NOPOWER || status & BROKEN))
				if (src.manuf_zap(usr, 10))
					return

		if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1 || isAI(usr)) && istype(src.loc, /turf))))
			usr.machine = src

			if (src.malfunction && prob(10))
				src.flip_out()

			//if (href_list["shake"])
			//	src.flip_out()

			if (href_list["eject"])
				if (src.mode != "ready")
					boutput(usr, "<span style=\"color:red\">You cannot eject materials while the unit is working.</span>")
				else
					var/mat_name = href_list["eject"]
					var/ejectamt = 0
					var/turf/ejectturf = get_turf(usr)
					for(var/obj/item/O in src.contents)
						if (O.material && O.material.name == mat_name)
							if (!ejectamt)
								ejectamt = input(usr,"How many units do you want to eject?","Eject Materials") as num
								if (ejectamt <= 0 || src.mode != "ready" || get_dist(src, usr) > 1)
									break
							if (!ejectturf)
								break
							O.set_loc(get_output_location(O,1))
							ejectamt--
							if (ejectamt <= 0)
								break

			if (href_list["speed"])
				if (src.mode == "working")
					boutput(usr, "<span style=\"color:red\">You cannot alter the speed setting while the unit is working.</span>")
				else
					var/upperbound = 3
					if (src.hacked)
						upperbound = 5
					var/newset = input(usr,"Enter from 1 to [upperbound]. Higher settings consume more power","Manufacturing Speed") as num
					newset = max(1,min(newset,upperbound))
					src.speed = newset

			if (href_list["clearQ"])
				var/Qcounter = 1
				for (var/datum/manufacture/M in src.queue)
					if (Qcounter == 1 && src.mode == "working") continue
					src.queue -= src.queue[Qcounter]
				if (src.mode == "halt")
					src.manual_stop = 0
					src.error = null
					src.mode = "ready"
					src.build_icon()

			if (href_list["removefromQ"])
				var/operation = text2num(href_list["removefromQ"])
				if (!isnum(operation) || src.queue.len < 1 || operation > src.queue.len)
					boutput(usr, "<span style=\"color:red\">Invalid operation.</span>")
					return

				if(world.time < last_queue_op + 5) //Anti-spam to prevent people lagging the server with autoclickers
					return
				else
					last_queue_op = world.time

				src.queue -= src.queue[operation]
				begin_work(1)//pesky exploits

			if (href_list["page"])
				var/operation = text2num(href_list["page"])
				src.page = operation

			if (href_list["repeat"])
				src.repeat = !src.repeat

			if (href_list["internalize"])
				if (src.retain_output_internally < 0)
					boutput(usr, "<span style=\"color:red\">This unit does not feature that function.</span>")
				else
					src.retain_output_internally = !src.retain_output_internally

			if (href_list["search"])
				src.search = input("Enter text to search for in schematics.","Manufacturing Unit") as null|text
				if (lentext(src.search) == 0)
					src.search = null

			if (href_list["category"])
				src.category = input("Select which category to filter by.","Manufacturing Unit") as null|anything in src.categories

			if (href_list["continue"])
				if (src.queue.len < 1)
					boutput(usr, "<span style=\"color:red\">Cannot find any items in queue to continue production.</span>")
					return
				if (isnull(material_check(src.queue[1])))
					boutput(usr, "<span style=\"color:red\">Insufficient usable materials to manufacture first item in queue.</span>")
				else
					src.begin_work(0)

			if (href_list["pause"])
				src.mode = "halt"
				src.build_icon()

			if (href_list["disp"])
				var/datum/manufacture/I = locate(href_list["disp"])
				if (!istype(I,/datum/manufacture/))
					return
				if(world.time < last_queue_op + 5) //Anti-spam to prevent people lagging the server with autoclickers
					return
				else
					last_queue_op = world.time

				// Verify that there is no href fuckery abound
				if(!validate_disp(I))
					// Since a manufacturer may get unhacked or a downloaded item could get deleted between someone
					// opening the window and clicking the button we can't assume intent here, so no cluwne
					return

				if (isnull(material_check(I)))
					boutput(usr, "<span style=\"color:red\">Insufficient usable materials to manufacture that item.</span>")
				else if (src.queue.len >= MAX_QUEUE_LENGTH)
					boutput(usr, "<span style=\"color:red\">Manufacturer queue length limit reached.</span>")
				else
					src.queue += I
					if (src.mode == "ready")
						src.begin_work(1)
						src.updateUsrDialog()

				if (src.queue.len > 0 && src.mode == "ready")
					src.begin_work(1)
					src.updateUsrDialog()
					return

			/*if (href_list["delete"])
				var/datum/manufacture/I = locate(href_list["disp"])
				if (!istype(I,/datum/manufacture/mechanics/))
					boutput(usr, "<span style=\"color:red\">Cannot delete this schematic.</span>")
					return
				src.download -= I*/

			if (href_list["ejectbeaker"])
				var/obj/item/reagent_containers/glass/beaker/B = locate(href_list["ejectbeaker"])
				if (!istype(B,/obj/item/reagent_containers/glass/beaker/))
					return
				src.beaker.set_loc(get_output_location(B,1))
				src.beaker = null

			if (href_list["transto"])
				// reagents are going into beaker
				var/obj/item/reagent_containers/glass/beaker/B = locate(href_list["transto"])
				if (!istype(B,/obj/item/reagent_containers/glass/beaker/))
					return
				var/howmuch = input("Transfer how much to [B]?","[src.name]",B.reagents.maximum_volume - B.reagents.total_volume) as null|num
				if (!howmuch || !B || B != src.beaker )
					return
				src.reagents.trans_to(B,howmuch)

			if (href_list["transfrom"])
				// reagents are being drawn from beaker
				var/obj/item/reagent_containers/glass/beaker/B = locate(href_list["transfrom"])
				if (!istype(B,/obj/item/reagent_containers/glass/beaker/))
					return
				var/howmuch = input("Transfer how much from [B]?","[src.name]",B.reagents.total_volume) as null|num
				if (!howmuch)
					return
				B.reagents.trans_to(src,howmuch)

			if (href_list["flush"])
				var/the_reagent = href_list["flush"]
				if (!istext(the_reagent))
					return
				var/howmuch = input("Flush how much [the_reagent]?","[src.name]",0) as null|num
				if (!howmuch)
					return
				src.reagents.remove_reagent(the_reagent,howmuch)

			if ((href_list["cutwire"]) && (src.panelopen || isAI(usr)))
				if (src.electrified)
					if (src.manuf_zap(usr, 100))
						return
				var/twire = text2num(href_list["cutwire"])
				if (!usr.find_tool_in_hand(TOOL_SNIPPING))
					boutput(usr, "You need a snipping tool!")
					return
				else if (src.isWireColorCut(twire))
					src.mend(twire)
				else
					src.cut(twire)
				src.build_icon()

			if ((href_list["pulsewire"]) && (src.panelopen || isAI(usr)))
				var/twire = text2num(href_list["pulsewire"])
				if ( !(usr.find_tool_in_hand(TOOL_PULSING) || isAI(usr)) )
					boutput(usr, "You need a multitool or similar!")
					return
				else if (src.isWireColorCut(twire))
					boutput(usr, "You can't pulse a cut wire.")
					return
				else
					src.pulse(twire)
				src.build_icon()

			src.updateUsrDialog()
		return

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.hacked)
			src.hacked = 1
			if(user)
				boutput(user, "<span style=\"color:blue\">You remove the [src]'s product locks!</span>")
			return 1
		return 0

	attackby(obj/item/W as obj, mob/user as mob)
		if (src.electrified)
			if (src.manuf_zap(usr, 33))
				return

		if (istype(W, /obj/item/paper/manufacturer_blueprint))
			if (!src.accept_blueprints)
				boutput(user, "<span style=\"color:red\">This manufacturer unit does not accept blueprints.</span>")
				return
			var/obj/item/paper/manufacturer_blueprint/BP = W
			if (src.malfunction && prob(75))
				src.visible_message("<span style=\"color:red\">[src] emits a [pick(src.text_flipout_adjective)] [pick(src.text_flipout_noun)]!</span>")
				playsound(src.loc, pick(src.sounds_malfunction), 50, 1)
				boutput(user, "<span style=\"color:red\">The manufacturer mangles and ruins the blueprint in the scanner! What the fuck?</span>")
				qdel(BP)
				return
			if (!BP.blueprint)
				src.visible_message("<span style=\"color:red\">[src] emits a grumpy buzz!</span>")
				playsound(src.loc, src.sound_grump, 50, 1)
				boutput(user, "<span style=\"color:red\">The manufacturer rejects the blueprint. Is something wrong with it?</span>")
				return
			for (var/datum/manufacture/M in (src.available + src.download))
				if (BP.blueprint.name == M.name)
					src.visible_message("<span style=\"color:red\">[src] emits an irritable buzz!</span>")
					playsound(src.loc, src.sound_grump, 50, 1)
					boutput(user, "<span style=\"color:red\">The manufacturer rejects the blueprint, as it already knows it.</span>")
					return
			BP.dropped()
			src.download += BP.blueprint
			src.visible_message("<span style=\"color:red\">[src] emits a pleased chime!</span>")
			playsound(src.loc, src.sound_happy, 50, 1)
			boutput(user, "<span style=\"color:blue\">The manufacturer accepts and scans the blueprint.</span>")
			qdel(BP)
			return

		else if (istype(W, /obj/item/satchel))
			user.visible_message("<span style=\"color:blue\">[user] uses [src]'s automatic loader on [W]!</span>", "<span style=\"color:blue\">You use [src]'s automatic loader on [W].</span>")
			var/amtload = 0
			for (var/obj/item/M in W.contents)
				if (!istype(M,src.base_material_class))
					continue
				src.load_item(M)
				amtload++
			W:satchel_updateicon()
			if (amtload) boutput(user, "<span style=\"color:blue\">[amtload] materials loaded from [W]!</span>")
			else boutput(user, "<span style=\"color:red\">No materials loaded!</span>")

		else if (isscrewingtool(W))
			if (!src.panelopen)
				src.panelopen = 1
			else
				src.panelopen = 0
			boutput(user, "You [src.panelopen ? "open" : "close"] the maintenance panel.")
			src.build_icon()

		else if (istype(W,/obj/item/weldingtool))
			var/obj/item/weldingtool/WELD = W
			var/do_action = 0
			if (istype(WELD,src.base_material_class) && src.accept_loading(user))
				if (alert(user,"What do you want to do with [WELD]?","[src.name]","Repair","Load it in") == "Load it in")
					do_action = 1
			if (do_action == 1)
				user.visible_message("<span style=\"color:blue\">[user] loads [WELD] into the [src].</span>", "<span style=\"color:blue\">You load [WELD] into the [src].</span>")
				src.load_item(WELD,user)
			else
				if (src.health < 50)
					boutput(user, "<span style=\"color:red\">It's too badly damaged. You'll need to replace the wiring first.</span>")
				else if(WELD.try_weld(user, 1))
					src.take_damage(-10)
					user.visible_message("<b>[user]</b> uses [WELD] to repair some of [src]'s damage.")
					if (src.health == 100)
						boutput(user, "<span style=\"color:blue\"><b>[src] looks fully repaired!</b></span>")

		else if (istype(W,/obj/item/cable_coil) && src.panelopen)
			var/obj/item/cable_coil/C = W
			var/do_action = 0
			if (istype(C,src.base_material_class) && src.accept_loading(user))
				if (alert(user,"What do you want to do with [C]?","[src.name]","Repair","Load it in") == "Load it in")
					do_action = 1
			if (do_action == 1)
				user.visible_message("<span style=\"color:blue\">[user] loads [C] into the [src].</span>", "<span style=\"color:blue\">You load [C] into the [src].</span>")
				src.load_item(C,user)
			else
				if (src.health >= 50)
					boutput(user, "<span style=\"color:red\">The wiring is fine. You need to weld the external plating to do further repairs.</span>")
				else
					C.use(1)
					src.take_damage(-10)
					user.visible_message("<b>[user]</b> uses [C] to repair some of [src]'s cabling.")
					playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
					if (src.health >= 50)
						boutput(user, "<span style=\"color:blue\">The wiring is fully repaired. Now you need to weld the external plating.</span>")

		else if (iswrenchingtool(W))
			var/do_action = 0
			if (istype(W,src.base_material_class) && src.accept_loading(user))
				if (alert(user,"What do you want to do with [W]?","[src.name]","Dismantle/Construct","Load it in") == "Load it in")
					do_action = 1
			if (do_action == 1)
				user.visible_message("<span style=\"color:blue\">[user] loads [W] into the [src].</span>", "<span style=\"color:blue\">You load [W] into the [src].</span>")
				src.load_item(W,user)
			else
				playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)
				if (src.dismantle_stage == 0)
					user.visible_message("<b>[user]</b> loosens [src]'s external plating bolts.")
					src.dismantle_stage = 1
				else if (src.dismantle_stage == 1)
					user.visible_message("<b>[user]</b> fastens [src]'s external plating bolts.")
					src.dismantle_stage = 0
				else if (src.dismantle_stage == 3)
					user.visible_message("<b>[user]</b> dismantles [src]'s mechanisms.")
					new /obj/item/sheet/steel/reinforced(src.loc)
					qdel(src)
					return
				src.build_icon()

		else if (ispryingtool(W) && src.dismantle_stage == 1)
			user.visible_message("<b>[user]</b> pries off [src]'s plating.")
			playsound(src.loc, "sound/items/Crowbar.ogg", 50, 1)
			src.dismantle_stage = 2
			new /obj/item/sheet/steel/reinforced(src.loc)
			src.build_icon()

		else if (issnippingtool(W) && src.dismantle_stage == 2)
			if (!(status & NOPOWER))
				if (src.manuf_zap(user,100))
					return
			user.visible_message("<b>[user]</b> disconnects [src]'s cabling.")
			playsound(src.loc, "sound/items/Wirecutter.ogg", 50, 1)
			src.dismantle_stage = 3
			src.status |= NOPOWER
			var/obj/item/cable_coil/cut/C = new /obj/item/cable_coil/cut(src.loc)
			C.amount = 1
			src.build_icon()

		else if (istype(W,/obj/item/sheet/steel/reinforced) && src.dismantle_stage == 2)
			user.visible_message("<b>[user]</b> adds plating to [src].")
			src.dismantle_stage = 1
			qdel(W)
			src.build_icon()

		else if (istype(W,/obj/item/cable_coil) && src.dismantle_stage == 3)
			user.visible_message("<b>[user]</b> adds cabling to [src].")
			src.dismantle_stage = 2
			qdel(W)
			src.status &= ~NOPOWER
			src.manuf_zap(user,100)
			src.build_icon()

		else if (istype(W,/obj/item/reagent_containers/glass))
			if (src.beaker)
				boutput(user, "<span style=\"color:red\">There's already a receptacle in the machine. You need to remove it first.</span>")
			else
				boutput(user, "<span style=\"color:blue\">You insert [W].</span>")
				W.set_loc(src)
				src.beaker = W
				if (user && W)
					user.u_equip(W)
					W.dropped()

		else if (istype(W, src.base_material_class) && src.accept_loading(user))
			user.visible_message("<span style=\"color:blue\">[user] loads [W] into the [src].</span>", "<span style=\"color:blue\">You load [W] into the [src].</span>")
			src.load_item(W,user)

		else
			..()
			user.lastattacked = src
			if (W.hitsound)
				playsound(src.loc, W.hitsound, 50, 1)
			if (W.force)
				var/damage = W.force
				damage /= 3
				if (user.is_hulk())
					damage *= 4
				if (iscarbon(user))
					var/mob/living/carbon/C = user
					if (C.bioHolder && C.bioHolder.HasEffect("strong"))
						damage *= 2
				if (damage >= 5)
					src.take_damage(damage)

		src.updateUsrDialog()

	MouseDrop(over_object, src_location, over_location)
		if(!isliving(usr))
			boutput(usr, "<span style=\"color:red\">Only living mobs are able to set the manufacturer's output target.</span>")
			return

		if(get_dist(over_object,src) > 1)
			boutput(usr, "<span style=\"color:red\">The manufacturing unit is too far away from the target!</span>")
			return

		if(get_dist(over_object,usr) > 1)
			boutput(usr, "<span style=\"color:red\">You are too far away from the target!</span>")
			return

		if (istype(over_object,/obj/storage/crate/))
			var/obj/storage/crate/C = over_object
			if (C.locked || C.welded)
				boutput(usr, "<span style=\"color:red\">You can't use a currently unopenable crate as an output target.</span>")
			else
				src.output_target = over_object
				boutput(usr, "<span style=\"color:blue\">You set the manufacturer to output to [over_object]!</span>")

		else if (istype(over_object,/obj/storage/cart/))
			var/obj/storage/cart/C = over_object
			if (C.locked || C.welded)
				boutput(usr, "<span style=\"color:red\">You can't use a currently unopenable cart as an output target.</span>")
			else
				src.output_target = over_object
				boutput(usr, "<span style=\"color:blue\">You set the manufacturer to output to [over_object]!</span>")

		else if (istype(over_object,/obj/machinery/manufacturer/))
			var/obj/machinery/manufacturer/M = over_object
			if (M.status & BROKEN || M.status & NOPOWER || M.dismantle_stage > 0)
				boutput(usr, "<span style=\"color:red\">You can't use a non-functioning manufacturer as an output target.</span>")
			else
				src.output_target = M
				boutput(usr, "<span style=\"color:blue\">You set the manufacturer to output to [over_object]!</span>")

		else if (istype(over_object,/obj/table/) || istype(over_object,/obj/rack/))
			var/obj/O = over_object
			src.output_target = O.loc
			boutput(usr, "<span style=\"color:blue\">You set the manufacturer to output on top of [O]!</span>")

		else if (istype(over_object,/turf/simulated/floor/))
			src.output_target = over_object
			boutput(usr, "<span style=\"color:blue\">You set the manufacturer to output to [over_object]!</span>")

		else
			boutput(usr, "<span style=\"color:red\">You can't use that as an output target.</span>")
		return

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!O || !user)
			return

		if(!isliving(user))
			boutput(user, "<span style=\"color:red\">Only living mobs are able to use the manufacturer's quick-load feature.</span>")
			return

		if (!istype(O,/obj/))
			boutput(user, "<span style=\"color:red\">You can't quick-load that.</span>")
			return

		if(get_dist(O,user) > 1)
			boutput(user, "<span style=\"color:red\">You are too far away!</span>")
			return


		if (istype(O, /obj/item/paper/manufacturer_blueprint))
			src.attackby(O, user)

		if (istype(O, /obj/storage/crate/) || istype(O, /obj/storage/cart/) && src.accept_loading(user,1))
			if (O:welded || O:locked)
				boutput(user, "<span style=\"color:red\">You cannot load from a container that cannot open!</span>")
				return

			user.visible_message("<span style=\"color:blue\">[user] uses [src]'s automatic loader on [O]!</span>", "<span style=\"color:blue\">You use [src]'s automatic loader on [O].</span>")
			var/amtload = 0
			for (var/obj/item/M in O.contents)
				if (!istype(M,src.base_material_class))
					continue
				src.load_item(M)
				amtload++
			if (amtload) boutput(user, "<span style=\"color:blue\">[amtload] materials loaded from [O]!</span>")
			else boutput(user, "<span style=\"color:red\">No material loaded!</span>")

		else if (isitem(O) && src.accept_loading(user,1))
			user.visible_message("<span style=\"color:blue\">[user] begins quickly stuffing materials into [src]!</span>")
			var/staystill = user.loc
			for(var/obj/item/M in view(1,user))
				if (!O)
					continue
				if (!istype(M,O.type))
					continue
				if (!istype(M,src.base_material_class))
					continue
				if (O.loc == user)
					continue
				if (O in user.contents)
					continue
				src.load_item(M)
				sleep(0.5)
				if (user.loc != staystill) break
			boutput(user, "<span style=\"color:blue\">You finish stuffing materials into [src]!</span>")

		else ..()

		src.updateUsrDialog()

	proc/accept_loading(var/mob/user,var/allow_silicon = 0)
		if (!user)
			return 0
		if (src.status & BROKEN || src.status & NOPOWER)
			return 0
		if (src.dismantle_stage > 0)
			return 0
		if (!isliving(user))
			return 0
		if (issilicon(user) && !allow_silicon)
			return 0
		var/mob/living/L = user
		if (L.stat || L.transforming)
			return 0
		return 1

	proc/isWireColorCut(var/wireColor)
		var/wireFlag = APCWireColorToFlag[wireColor]
		return ((src.wires & wireFlag) == 0)

	proc/isWireCut(var/wireIndex)
		var/wireFlag = APCIndexToFlag[wireIndex]
		return ((src.wires & wireFlag) == 0)

	proc/cut(var/wireColor)
		var/wireFlag = APCWireColorToFlag[wireColor]
		var/wireIndex = APCWireColorToIndex[wireColor]
		src.wires &= ~wireFlag
		switch(wireIndex)
			if(WIRE_EXTEND)
				src.hacked = 0
			if(WIRE_SHOCK)
				src.electrified = -1
			if(WIRE_MALF)
				src.malfunction = 1
			if(WIRE_POWER)
				if(!(src.status & BROKEN || src.status & NOPOWER))
					src.manuf_zap(usr,100)
					src.status |= NOPOWER

	proc/mend(var/wireColor)
		var/wireFlag = APCWireColorToFlag[wireColor]
		var/wireIndex = APCWireColorToIndex[wireColor] //not used in this function
		src.wires |= wireFlag
		switch(wireIndex)
			if(WIRE_SHOCK)
				src.electrified = 0
			if(WIRE_MALF)
				src.malfunction = 0
			if(WIRE_POWER)
				if (!(src.status & BROKEN) && (src.status & NOPOWER))
					src.manuf_zap(usr,100)
					src.status &= ~NOPOWER

	proc/pulse(var/wireColor)
		var/wireIndex = APCWireColorToIndex[wireColor]
		switch(wireIndex)
			if(WIRE_EXTEND)
				src.hacked = !src.hacked
			if (WIRE_SHOCK)
				src.electrified = 30
			if (WIRE_MALF)
				src.malfunction = !src.malfunction
			if (WIRE_POWER)
				if(!(src.status & BROKEN || src.status & NOPOWER))
					src.manuf_zap(usr,100)

	proc/manuf_zap(mob/user, prb)
		if(issilicon(user) || isAI(user))
			return 0
		if(!prob(prb))
			return 0
		if(src.status & (BROKEN|NOPOWER))
			return 0
		if(ishuman(user))
			if (istype(user:gloves, /obj/item/clothing/gloves/yellow))
				return 0

		var/netnum = 0
		for(var/turf/T in range(1, user))
			for(var/obj/cable/C in T.contents)
				netnum = C.netnum
				break
			if (netnum) break

		if (!netnum) return 0

		if (src.electrocute(user,prb,netnum))
			return 1
		else
			return 0

	proc/add_schematic(var/schematic_path,var/add_to_list = "available")
		if (!ispath(schematic_path))
			return

		var/datum/manufacture/S = get_schematic_from_path(schematic_path)
		if (!istype(S,/datum/manufacture/))
			return

		switch(add_to_list)
			if ("hidden")
				src.hidden += S
			if ("download")
				src.download += S
			else
				src.available += S

	proc/set_up_schematics()
		for (var/X in src.available)
			if (ispath(X))
				src.add_schematic(X)
				src.available -= X

		for (var/X in src.hidden)
			if (ispath(X))
				src.add_schematic(X,"hidden")
				src.hidden -= X

	proc/match_material_pattern(pattern, datum/material/mat)
		if (!mat) // Marq fix for various cannot read null. runtimes
			return 0

		if (pattern == "ALL") // anything at all
			return 1
		else if (copytext(pattern, 4, 5) == "-") // wildcard
			var/firstpart = copytext(pattern, 1, 4)
			var/secondpart = text2num(copytext(pattern, 5))
			switch(firstpart)
				// this was kind of thrown together in a panic when i felt shitty so if its horrible
				// go ahead and clean it up a bit
				if ("MET")

					if (mat.material_flags & MATERIAL_METAL)
						// maux hardness = 15
						// bohr hardness = 33
						switch(secondpart)
							if(2)
								return mat.getProperty("hard") >= 15
							if(3 to INFINITY)
								return mat.getProperty("hard") >= 30
							else
								return 1
				if ("CRY")
					return (mat.material_flags & MATERIAL_CRYSTAL)
				if ("REF")
					return (mat.getProperty("reflective") >= 50)
				if ("CON")
					switch(secondpart)
						if(2)
							return (mat.getProperty("electrical") >= 75) && (mat.material_flags & MATERIAL_METAL) || (mat.getProperty("electrical") >= 75) && (mat.material_flags & MATERIAL_CRYSTAL) //Wow! Claretine has a use again!
						else
							return (mat.getProperty("electrical") >= 50) && (mat.material_flags & MATERIAL_METAL) || (mat.getProperty("electrical") >= 50) && (mat.material_flags & MATERIAL_CRYSTAL)
				if ("INS")
					switch(secondpart)
						if(2)
							return mat.getProperty("electrical") <= 20 && (mat.material_flags & MATERIAL_CLOTH) || mat.getProperty("electrical") <= 20 && (mat.material_flags & MATERIAL_RUBBER)
						else
							return mat.getProperty("electrical") <= 47 && (mat.material_flags & MATERIAL_CLOTH) || mat.getProperty("electrical") <= 47 && (mat.material_flags & MATERIAL_RUBBER)
				if ("DEN")
					switch(secondpart)
						if(3)
							return mat.getProperty("density") >= 75  && (mat.material_flags & MATERIAL_CRYSTAL)
						if(2)
							return mat.getProperty("density") >= 60  && (mat.material_flags & MATERIAL_CRYSTAL)
						else
							return mat.getProperty("density") >= 40  && (mat.material_flags & MATERIAL_CRYSTAL)
				if ("POW")
					if (mat.material_flags & MATERIAL_ENERGY)
						switch(secondpart)
							if(3)
								return mat.getProperty("radioactive") >= 55 //soulsteel and erebite basically
							if(2)
								return mat.getProperty("radioactive") >= 10
							else
								return 1
				if ("FAB")
					return mat.material_flags & MATERIAL_CLOTH || mat.material_flags & MATERIAL_RUBBER || mat.material_flags & MATERIAL_ORGANIC
		else if (pattern == mat.mat_id) // specific material id
			return 1
		return 0

	//return list of all mat_ids of a manufacturable
	proc/get_mat_ids(datum/manufacture/M)
		var/list/usable = src.contents
		var/list/usable_materials = cuttings.Copy()
		for (var/obj/item/I in usable)
			if (istype(I, src.base_material_class) && I.material)
				usable_materials[I.material.mat_id] += 10

		return usable_materials

	proc/material_check(datum/manufacture/M)
		var/list/usable = src.contents
		var/list/materials = list()
		var/list/usable_materials = get_mat_ids(M)
		materials.len = M.item_paths.len

		for (var/i = 1; i <= M.item_paths.len; i++)
			var/pattern = M.item_paths[i]
			var/amount = M.item_amounts[i]
			if (ispath(pattern))
				for (var/j = 0; j < amount; j++)
					var/obj/O = locate(pattern) in usable
					if (O)
						usable -= O
					else
						return
			else
				var/found = 0
				for (var/mat_id in usable_materials)
					var/available = usable_materials[mat_id]
					if (available < amount)
						continue
					var/datum/material/mat = getMaterial(mat_id)
					if (match_material_pattern(pattern, mat))
						materials[i] = mat_id
						found = 1
						break
				if (!found)
					return
		return materials


	proc/add_and_get_similar_materials(var/obj/item/material_piece/M,var/amount_needed)
		if (!istype(M) || !M.material || !isnum(amount_needed))
			return list()

		var/list/mats = list()
		mats += M
		amount_needed++
		for (var/obj/O in src.contents)
			if (mats.len >= amount_needed)
				break
			if (O == M)
				continue
			if (O.name == M.name)
				mats += O

		return mats

	proc/begin_work(var/new_production = 1)
		if (status & NOPOWER || status & BROKEN)
			return
		if (!src.queue.len)
			src.manual_stop = 0
			src.mode = "ready"
			src.build_icon()
			src.updateUsrDialog()
			return
		if (!istype(src.queue[1],/datum/manufacture/))
			src.mode = "halt"
			src.error = "Corrupted entry purged from production queue."
			src.queue -= src.queue[1]
			src.visible_message("<span style=\"color:red\">[src] emits an angry buzz!</span>")
			playsound(src.loc, src.sound_grump, 50, 1)
			src.build_icon()
			return

		var/datum/manufacture/M = src.queue[1]
		//Wire: Fix for href exploit creating arbitrary items
		if (!(M in src.available + src.hidden + src.download))
			src.mode = "halt"
			src.error = "Corrupted entry purged from production queue."
			src.queue -= src.queue[1]
			src.visible_message("<span style=\"color:red\">[src] emits an angry buzz!</span>")
			playsound(src.loc, src.sound_grump, 50, 1)
			src.build_icon()
			return

		src.error = null

		if (src.malfunction && prob(40))
			src.flip_out()

		if (new_production)
			var/list/mats_used = src.material_check(M)
			if (isnull(mats_used))
				src.mode = "halt"
				src.error = "Insufficient usable materials to continue queue production."
				src.visible_message("<span style=\"color:red\">[src] emits an angry buzz!</span>")
				playsound(src.loc, src.sound_grump, 50, 1)
				src.build_icon()
				return

			if (mats_used && mats_used.len)
				src.materials_in_use = mats_used
				//for (var/obj/item/O in mats_used)
				//	del O

			src.powconsumption = 1500
			src.powconsumption *= src.speed * 1.5
			src.timeleft = M.time
			if (src.malfunction)
				src.powconsumption += 3000
				src.timeleft += rand(2,6)
				src.timeleft *= 1.5
		playsound(src.loc, src.sound_beginwork, 50, 1, 0, 3)
		src.mode = "working"
		src.build_icon()

	proc/output_loop(var/datum/manufacture/M)

		if (!istype(M,/datum/manufacture/))
			return

		if (M.item_outputs.len <= 0)
			return
		var/mcheck = material_check(M)
		if(mcheck)
			var/make = max(0,min(M.create,src.output_cap))
			switch(M.randomise_output)
				if(1) // pick a new item each loop
					while (make > 0)
						src.dispense_product(pick(M.item_outputs),M)
						make--
				if(2) // get a random item from the list and produce it
					var/to_make = pick(M.item_outputs)
					while (make > 0)
						src.dispense_product(to_make,M)
						make--
				else // produce every item in the list once per loop
					while (make > 0)
						for (var/X in M.item_outputs)
							src.dispense_product(X,M)
						make--

			for (var/i = 1; i <= M.item_paths.len; i++)
				var/pattern = M.item_paths[i]
				var/amount = M.item_amounts[i]
				if (ispath(pattern))
					for (var/j = 0; j < amount; j++)
						var/obj/O = locate(pattern) in src
						src.contents -= O
						qdel(O)

			for (var/i = 1; i <= src.materials_in_use.len; i++)
				if (i > src.materials_in_use.len)
					break
				var/mat_id = src.materials_in_use[i]
				if (!M.item_amounts[i]) //Wire: Fix for list index out of bounds
					continue
				var/amount = M.item_amounts[i]
				if (!mat_id)
					continue
				var/cutting_amount = src.cuttings[mat_id]
				if (cutting_amount)
					var/used = min(cutting_amount, amount)
					src.cuttings[mat_id] -= used
					amount -= used
				if (amount == 0)
					continue
				for (var/obj/item/I in src)
					if (I.material && istype(I, src.base_material_class) && I.material.mat_id == mat_id)
						src.contents -= I
						pool(I)
						if (amount < 10)
							src.cuttings[mat_id] += 10 - amount
							amount = 0
							break
						else
							amount -= 10

		if (src.repeat)
			if (!mcheck)
				src.queue -= M
		else
			src.queue -= M
		src.begin_work(1)
		return

	proc/dispense_product(var/product,var/datum/manufacture/M)
		if (ispath(product))
			if (istype(M,/datum/manufacture/))
				var/atom/movable/A = new product(src)
				if (isitem(A))
					var/obj/item/I = A
					M.modify_output(src, I, src.materials_in_use)
					I.set_loc(src.get_output_location(I))
				else
					A.set_loc(src.get_output_location(A))
			else
				new product(get_output_location())

		else if (istext(product) || isnum(product))
			if (istext(product) && copytext(product,1,8) == "reagent")
				var/the_reagent = copytext(product,9,length(product) + 1)
				if (M.create != 0)
					src.reagents.add_reagent(the_reagent,M.create / 10)
			else
				src.visible_message("<b>[src.name]</b> says, \"[product]\"")

		else if (isicon(product)) // adapted from vending machine code
			var/icon/welp = icon(product)
			if (welp.Width() > 32 || welp.Height() > 32)
				welp.Scale(32, 32)
				product = welp
			var/obj/dummy = new /obj/item(get_turf(src))
			dummy.name = "strange thing"
			dummy.desc = "The fuck is this?"
			dummy.icon = welp

		else if (isfile(product)) // adapted from vending machine code
			var/S = sound(product)
			if (S)
				playsound(src.loc, S, 50, 0)

		else if (isobj(product))
			var/obj/X = product
			X.set_loc(get_output_location())

		else if (ismob(product))
			var/mob/X = product
			X.set_loc(get_output_location())

		else
			return

	proc/flip_out()
		if (status & BROKEN || status & NOPOWER || !src.malfunction)
			return
		animate_shake(src,5,rand(3,8),rand(3,8))
		src.visible_message("<span style=\"color:red\">[src] makes [pick(src.text_flipout_adjective)] [pick(src.text_flipout_noun)]!</span>")
		playsound(src.loc, pick(src.sounds_malfunction), 50, 2)
		if (prob(15) && src.contents.len > 4 && src.mode != "working")
			var/to_throw = rand(1,4)
			var/obj/item/X = null
			while(to_throw > 0)
				if(!src.nearby_turfs.len) //SpyGuy for RTE "pick() from empty list"
					break
				X = pick(src.contents)
				X.set_loc(src.loc)
				X.throw_at(pick(src.nearby_turfs), 16, 3)
				to_throw--
		if (src.queue.len > 1 && prob(20))
			var/list_counter = 0
			for (var/datum/manufacture/X in src.queue)
				list_counter++
				if (list_counter == 1)
					continue
				if (prob(33))
					src.queue -= X
		if (src.mode == "working")
			if (prob(5))
				src.mode = "halt"
				src.build_icon()
			else
				if (prob(10))
					src.powconsumption *= 2
		if (prob(10))
			src.speed = rand(1,8)
		if (prob(5))
			if (!src.electrified)
				src.electrified = 5

	proc/build_icon()
		icon_state = "fab[src.icon_base ? "-[src.icon_base]" : null]"

		if (status & BROKEN)
			src.UpdateOverlays(null, "work")
			src.UpdateOverlays(null, "activity")
			icon_state = "[src.icon_base]-broken"
		else if (src.dismantle_stage >= 2)
			src.UpdateOverlays(null, "work")
			src.UpdateOverlays(null, "activity")
			icon_state = "fab-noplate"

		if (!(status & NOPOWER) && !(status & BROKEN))
			if (src.malfunction && prob(50))
				switch  (rand(1,4))
					if (1) src.activity_display.icon_state = "light-ready"
					if (2) src.activity_display.icon_state = "light-halt"
					if (3) src.activity_display.icon_state = "light-working"
					else src.activity_display.icon_state = "light-malf"
			else
				src.activity_display.icon_state = "light-[src.mode]"

			var/animspeed = src.speed
			if (animspeed < 1 || animspeed > 5 || (src.malfunction && prob(50)))
				animspeed = "malf"

			if (src.mode == "working")
				src.work_display.icon_state = "fab-work[animspeed]"
			else
				src.work_display.icon_state = ""

			src.UpdateOverlays(src.work_display, "work")
			src.UpdateOverlays(src.activity_display, "activity")

		if (src.panelopen)
			src.panel_sprite.icon_state = "fab-panel"
			src.UpdateOverlays(src.panel_sprite, "panel")
		else
			src.UpdateOverlays(null, "panel")

	proc/build_material_list()
		var/dat = "<b>Available Materials & Reagents:</b><small><br>"
		var/list/mat_amts = list()
		for(var/obj/item/O in src.contents)
			if (istype(O,/obj/item/reagent_containers/glass/beaker/))
				if (O == src.beaker)
					continue
			if (istype(O,src.base_material_class) && O.material)
				mat_amts[O.material.name] += 10
		for (var/mat_id in cuttings)
			var/amount = cuttings[mat_id]
			var/datum/material/mat = getMaterial(mat_id)
			mat_amts[mat.name] += amount

		if (mat_amts.len)
			for(var/mat_type in mat_amts)
				dat += "<A href='?src=\ref[src];eject=[mat_type]'><B>[mat_type]:</B></A> [mat_amts[mat_type]]<br>"
		else
			dat += "No materials currently loaded.<br>"

		var/reag_list = ""
		for(var/current_id in src.reagents.reagent_list)
			var/datum/reagent/current_reagent = src.reagents.reagent_list[current_id]
			dat += "[reag_list ? "<br>" : " "][current_reagent.volume] units of <A href='?src=\ref[src];flush=[current_reagent.name]'>[current_reagent.name]</a><br>"

		dat += reag_list
		dat += "</small>"

		return dat

	proc/build_control_panel()
		var/dat = "<small>"

		if (src.page == 1)
			dat += "<br><u><A href='?src=\ref[src];page=0'>Production List</A> | <b>Queue:</b> [src.queue.len]</u>"
		else
			dat += "<br><u><b>Production List</b> | <A href='?src=\ref[src];page=1'>Queue:</A> [src.queue.len]</u>"

		if (src.mode == "working" && src.queue.len > 0)
			dat += "<br><b>Current Production:</b> <u>[src.queue[1]]</u>"
		else
			dat += "<br><b>Current Production:</b> None"

		dat += "<HR>"

		dat += "<b><A href='?src=\ref[src];speed=1'>Speed:</A></b> [src.speed]"

		if (src.repeat == 1)
			dat += " | <A href='?src=\ref[src];repeat=1'><b>Repeat: On</b></A>"
		else
			dat += " | <A href='?src=\ref[src];repeat=1'><b>Repeat: Off</b></A>"

		dat += "<br>"

		if (src.retain_output_internally >= 0)
			if (src.retain_output_internally == 1)
				dat += "<A href='?src=\ref[src];internalize=1'><b>Store outputs internally: Yes</b></A>"
			else
				dat += "<A href='?src=\ref[src];internalize=1'><b>Store outputs internally: No</b></A>"

		dat += "<br>"

		if (src.beaker)
			dat += "<A href='?src=\ref[src];ejectbeaker=\ref[src.beaker]'><b>Receptacle:</b></a> [src.beaker.name]"
			if (src.beaker.reagents.total_volume < src.beaker.reagents.maximum_volume)
				dat += " <A href='?src=\ref[src];transto=\ref[src.beaker]'>(Transfer to Receptacle)</a>"
			if (src.beaker.reagents.total_volume > 0)
				dat += " <A href='?src=\ref[src];transfrom=\ref[src.beaker]'>(Transfer to Unit)</a>"
		else
			dat += "No reagent receptacle inserted."

		dat += "<br>"

		if (!src.page)
			dat += "<A href='?src=\ref[src];category=1'>Filter</A> | <A href='?src=\ref[src];search=1'>Search</A>"

		dat += "</small>"

		return dat

	proc/load_item(var/obj/item/O,var/mob/living/user)
		if (!O)
			return

		if (O.amount > 1)
			var/amtCopy = O.amount //Need to run the loop on a copy or the loop will be shortened by us splitting the stack. (since that reduces O.amount)
			for(var/i=0, i<(amtCopy - 1), i++)
				var/obj/item/S = O.split_stack(1)
				if(S) S.set_loc(src)

		O.set_loc(src)

		if (user && O)
			user.u_equip(O)
			O.dropped()

	proc/take_damage(var/damage_amount = 0)
		if (!damage_amount)
			return
		src.health -= damage_amount
		src.health = max(0,min(src.health,100))
		if (damage_amount > 0)
			playsound(src.loc, src.sound_damaged, 50, 2)
			if (src.health == 0)
				src.visible_message("<span style=\"color:red\"><b>[src.name] is destroyed!</b></span>")
				robogibs(src.loc,null)
				playsound(src.loc, src.sound_destroyed, 50, 2)
				qdel(src)
				return
			if (src.health <= 70 && !src.malfunction && prob(33))
				src.malfunction = 1
				src.flip_out()
			if (src.malfunction && prob(40))
				src.flip_out()
			if (src.health <= 25 && !(src.status & BROKEN))
				src.visible_message("<span style=\"color:red\"><b>[src.name] breaks down and stops working!</b></span>")
				src.status |= BROKEN
		else
			if (src.health >= 60 && src.status & BROKEN)
				src.visible_message("<span style=\"color:red\"><b>[src.name] looks like it can function again!</b></span>")
				status &= ~BROKEN

		src.build_icon()

	proc/claim_free_resources()
		if (src.deconstruct_flags & DECON_BUILT)
			free_resource_amt = 0
		if (free_resources.len && free_resource_amt > 0)
			var/looper = src.free_resource_amt
			free_resource_amt = 0

			while (looper > 0)
				looper--
				for (var/X in src.free_resources)
					if (ispath(X))
						var/atom/movable/A = unpool(X)
						A.set_loc(src)
						LAGCHECK(LAG_HIGH)
		else
			logTheThing("debug", null, null, "<b>obj/manufacturer:</b> [src.name]-[src.type] empty free resources list!")

	proc/get_output_location(var/atom/A,var/ejection = 0)
		if (!src.output_target)
			return src.loc

		if (get_dist(src.output_target,src) > 1)
			src.output_target = null
			return src.loc

		if (istype(src.output_target,/obj/storage/crate/))
			var/obj/storage/crate/C = src.output_target
			if (C.locked || C.welded)
				src.output_target = null
				return src.loc
			else
				if (C.open)
					return C.loc
				else
					return C
		if (istype(src.output_target,/obj/storage/cart/))
			var/obj/storage/cart/C = src.output_target
			if (C.locked || C.welded)
				src.output_target = null
				return src.loc
			else
				if (C.open)
					return C.loc
				else
					return C
		else if (istype(src.output_target,/obj/machinery/manufacturer))
			var/obj/machinery/manufacturer/M = src.output_target
			if (M.status & BROKEN || M.status & NOPOWER || M.dismantle_stage > 0)
				src.output_target = null
				return src.loc
			if (A && istype(A,M.base_material_class))
				return M
			else
				return M.loc

		else if (istype(src.output_target,/turf/simulated/floor/))
			return src.output_target

		else
			return src.loc

// Blueprints

/obj/item/paper/manufacturer_blueprint
	name = "Manufacturer Blueprint"
	desc = "It's a blueprint to allow a manufacturing unit to build something."
	info = "There's all manner of confusing diagrams and instructions on here. It's meant for a machine to read."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "blueprint"
	item_state = "sheet"
	var/datum/manufacture/blueprint = null



 	//TODO : pooling i guess cause other paper does
	New(var/loc,var/schematic = null)
		if(istype(schematic, /datum/manufacture))
			src.blueprint = schematic
		else if (!schematic)
			if (ispath(src.blueprint))
				src.blueprint = get_schematic_from_path(src.blueprint)
			else
				pool(src)
				return 0
		else
			if (istext(schematic))
				src.blueprint = get_schematic_from_name(schematic)
			else if (ispath(schematic))
				src.blueprint = get_schematic_from_path(schematic)

		if (!src.blueprint)
			qdel(src)
			return 0

		src.name = "Manufacturer Blueprint: [src.blueprint.name]"
		src.desc = "This blueprint will allow a manufacturer unit to build a [src.blueprint.name]"

		src.pixel_x = rand(-4,4)
		src.pixel_y = rand(-4,4)

		return 1

/******************** Cloner Blueprints *******************/

/obj/item/cloner_blueprints_folder
	name = "dirty manilla folder"
	desc = "An old manilla folder covered in stains. It looks like it'll fall apart at the slightest touch."
	icon = 'icons/obj/writing.dmi'
	icon_state = "folder"
	w_class = 2.0
	throwforce = 0
	w_class = 3.0
	throw_speed = 3
	throw_range = 10

	attack_self(mob/user as mob)
		boutput(user, "<span style=\"color:red\">The folder disintegrates in your hands, and papers scatter out. Shit!</span>")
		new /obj/item/paper/manufacturer_blueprint/clonepod(get_turf(src))
		new /obj/item/paper/manufacturer_blueprint/clonegrinder(get_turf(src))
		new /obj/item/paper/manufacturer_blueprint/clone_scanner(get_turf(src))
		new /obj/item/paper/hecate(get_turf(src))
		qdel(src)

/obj/item/paper/manufacturer_blueprint/clonepod
	blueprint = /datum/manufacture/mechanics/clonepod

/obj/item/paper/manufacturer_blueprint/clonegrinder
	blueprint = /datum/manufacture/mechanics/clonegrinder

/obj/item/paper/manufacturer_blueprint/clone_scanner
	blueprint = /datum/manufacture/mechanics/clone_scanner

/******************** Loafer Blueprints *******************/

/obj/item/paper/manufacturer_blueprint/loafer
	blueprint = /datum/manufacture/mechanics/loafer


/******************** Alastor Pattern Thruster Blueprints *******************/
/obj/item/paper/manufacturer_blueprint/thrusters
	icon = 'icons/obj/writing.dmi'
	icon_state = "blueprint"
	desc = "Seems like theres traces of charcoal on the paper. Huh."
	blueprint = /datum/manufacture/thrusters

/******************** Alastor Pattern Thruster Blueprints *******************/
/obj/item/paper/manufacturer_blueprint/alastor
	icon = 'icons/obj/writing.dmi'
	icon_state = "blueprint"
	desc = "Seems like theres traces of charcoal on the paper. Huh."
	blueprint = /datum/manufacture/alastor

// Fabricator Defines

/obj/machinery/manufacturer/general
	name = "General Manufacturer"
	desc = "A manufacturing unit calibrated to produce tools and general purpose items."
	free_resource_amt = 5
	free_resources = list(/obj/item/material_piece/mauxite,
		/obj/item/material_piece/pharosium,
		/obj/item/material_piece/molitz)
	available = list(/datum/manufacture/screwdriver,
		/datum/manufacture/wirecutters,
		/datum/manufacture/wrench,
		/datum/manufacture/crowbar,
		/datum/manufacture/extinguisher,
		/datum/manufacture/welder,
		/datum/manufacture/soldering,
		/datum/manufacture/flashlight,
		/datum/manufacture/weldingmask,
		/datum/manufacture/multitool,
		/datum/manufacture/metal,
		/datum/manufacture/metalR,
		/datum/manufacture/glass,
		/datum/manufacture/glassR,
		/datum/manufacture/atmos_can,
		/datum/manufacture/circuit_board,
		/datum/manufacture/cable,
		/datum/manufacture/powercell,
		/datum/manufacture/powercellE,
		/datum/manufacture/powercellC,
		/datum/manufacture/light_bulb,
		/datum/manufacture/red_bulb,
		/datum/manufacture/yellow_bulb,
		/datum/manufacture/green_bulb,
		/datum/manufacture/cyan_bulb,
		/datum/manufacture/blue_bulb,
		/datum/manufacture/purple_bulb,
		/datum/manufacture/blacklight_bulb,
		/datum/manufacture/light_tube,
		/datum/manufacture/red_tube,
		/datum/manufacture/yellow_tube,
		/datum/manufacture/green_tube,
		/datum/manufacture/cyan_tube,
		/datum/manufacture/blue_tube,
		/datum/manufacture/purple_tube,
		/datum/manufacture/blacklight_tube,
		/datum/manufacture/table_folding,
		/datum/manufacture/jumpsuit,
		/datum/manufacture/shoes,
		/datum/manufacture/breathmask,
		/datum/manufacture/fluidcanister,
		/datum/manufacture/patch)
	hidden = list(/datum/manufacture/RCDammo,
		/datum/manufacture/RCDammolarge,
		/datum/manufacture/bottle,
		/datum/manufacture/vuvuzela,
		/datum/manufacture/harmonica,
		/datum/manufacture/bikehorn,
		/datum/manufacture/stunrounds,
		/datum/manufacture/bullet_22,
		/datum/manufacture/bullet_smoke,
#if ASS_JAM
		/datum/manufacture/bullet_12g_nail,
#endif
		/datum/manufacture/stapler)

/obj/machinery/manufacturer/robotics
	name = "Robotics Fabricator"
	desc = "A manufacturing unit calibrated to produce robot-related equipment."
	icon_state = "fab-robotics"
	icon_base = "robotics"
	free_resource_amt = 5
	free_resources = list(/obj/item/material_piece/mauxite,
	/obj/item/material_piece/pharosium,
	/obj/item/material_piece/molitz)

	available = list(/datum/manufacture/robo_frame,
	/datum/manufacture/full_cyborg_standard,
	/datum/manufacture/full_cyborg_light,
	/datum/manufacture/robo_head,
	/datum/manufacture/robo_chest,
	/datum/manufacture/robo_arm_r,
	/datum/manufacture/robo_arm_l,
	/datum/manufacture/robo_leg_r,
	/datum/manufacture/robo_leg_l,
	/datum/manufacture/robo_head_light,
	/datum/manufacture/robo_chest_light,
	/datum/manufacture/robo_arm_r_light,
	/datum/manufacture/robo_arm_l_light,
	/datum/manufacture/robo_leg_r_light,
	/datum/manufacture/robo_leg_l_light,
	/datum/manufacture/robo_leg_treads,
	/datum/manufacture/robo_module,
	/datum/manufacture/cyberheart,
	/datum/manufacture/cybereye,
	/datum/manufacture/cybereye_meson,
	/datum/manufacture/cybereye_spectro,
	/datum/manufacture/cybereye_prodoc,
	/datum/manufacture/cybereye_camera,
	/datum/manufacture/core_frame,
	/datum/manufacture/shell_frame,
	/datum/manufacture/ai_interface,
	/datum/manufacture/latejoin,
	/datum/manufacture/shell_cell,
	/datum/manufacture/cable,
	/datum/manufacture/powercell,
	/datum/manufacture/powercellE,
	/datum/manufacture/powercellC,
	/datum/manufacture/crowbar,
	/datum/manufacture/wrench,
	/datum/manufacture/scalpel,
	/datum/manufacture/circular_saw,
	/datum/manufacture/surgical_scissors,
	/datum/manufacture/hemostat,
	/datum/manufacture/suture,
	/datum/manufacture/stapler,
	/datum/manufacture/surgical_spoon,
	/datum/manufacture/implanter,
	/datum/manufacture/secbot,
	/datum/manufacture/medbot,
	/datum/manufacture/firebot,
	/datum/manufacture/floorbot,
	/datum/manufacture/cleanbot,
	/datum/manufacture/visor,
	/datum/manufacture/deafhs,
	/datum/manufacture/robup_jetpack,
	/datum/manufacture/robup_healthgoggles,
	/datum/manufacture/robup_spectro,
	/datum/manufacture/robup_recharge,
	/datum/manufacture/robup_repairpack,
	/datum/manufacture/robup_speed,
	/datum/manufacture/robup_meson,
	/datum/manufacture/robup_aware,
	/datum/manufacture/robup_physshield,
	/datum/manufacture/robup_fireshield,
	/datum/manufacture/robup_teleport,
	/datum/manufacture/robup_visualizer,
	/*/datum/manufacture/robup_thermal,*/
	/datum/manufacture/robup_efficiency,
	/datum/manufacture/robup_repair,
	/datum/manufacture/implant_robotalk,
	/datum/manufacture/sbradio,
	/datum/manufacture/implant_health,
	/datum/manufacture/cyberappendix,
	/datum/manufacture/cyberpancreas,
	/datum/manufacture/cyberspleen,
	/datum/manufacture/cyberintestines,
	/datum/manufacture/cyberstomach,
	/datum/manufacture/cyberkidney,
	/datum/manufacture/cyberliver,
	/datum/manufacture/cyberlung_left,
	/datum/manufacture/cyberlung_right,
	/datum/manufacture/rods2,
	/datum/manufacture/metal,
	/datum/manufacture/glass)

	hidden = list(/datum/manufacture/flash,
	/datum/manufacture/cybereye_thermal,
	/datum/manufacture/cybereye_laser,
	/datum/manufacture/cyberbutt,
	/datum/manufacture/robup_expand)

/obj/machinery/manufacturer/medical
	name = "Medical Fabricator"
	desc = "A manufacturing unit calibrated to produce medical equipment."
	icon_state = "fab-med"
	icon_base = "med"
	free_resource_amt = 2
	free_resources = list(/obj/item/material_piece/mauxite,
	/obj/item/material_piece/cloth/cottonfabric,
	/obj/item/material_piece/pharosium,
	/obj/item/material_piece/molitz)

	available = list(
		/datum/manufacture/scalpel,
		/datum/manufacture/circular_saw,
		/datum/manufacture/surgical_scissors,
		/datum/manufacture/hemostat,
		/datum/manufacture/suture,
		/datum/manufacture/stapler,
		/datum/manufacture/surgical_spoon,
		/datum/manufacture/prodocs,
		/datum/manufacture/glasses,
		/datum/manufacture/visor,
		/datum/manufacture/deafhs,
		/datum/manufacture/hypospray,
		/datum/manufacture/patch,
		/datum/manufacture/mender,
		/datum/manufacture/latex_gloves,
		/datum/manufacture/surgical_mask,
		/datum/manufacture/surgical_shield,
		/datum/manufacture/scrubs_white,
		/datum/manufacture/scrubs_teal,
		/datum/manufacture/scrubs_maroon,
		/datum/manufacture/scrubs_blue,
		/datum/manufacture/scrubs_purple,
		/datum/manufacture/scrubs_orange,
		/datum/manufacture/scrubs_pink,
		/datum/manufacture/patient_gown,
		/datum/manufacture/blindfold,
		/datum/manufacture/muzzle,
		/datum/manufacture/body_bag,
		/datum/manufacture/implanter,
		/datum/manufacture/implant_health,
		/datum/manufacture/crowbar,
		/datum/manufacture/extinguisher,
		/datum/manufacture/cyberappendix,
		/datum/manufacture/cyberpancreas,
		/datum/manufacture/cyberspleen,
		/datum/manufacture/cyberintestines,
		/datum/manufacture/cyberstomach,
		/datum/manufacture/cyberkidney,
		/datum/manufacture/cyberliver,
		/datum/manufacture/cyberlung_left,
		/datum/manufacture/cyberlung_right,
		/datum/manufacture/rods2,
		/datum/manufacture/metal,
		/datum/manufacture/glass
	)

	hidden = list(/datum/manufacture/cyberheart,
	/datum/manufacture/cybereye)

/obj/machinery/manufacturer/mining
	name = "Mining Fabricator"
	desc = "A manufacturing unit calibrated to produce mining related equipment."
	icon_state = "fab-mining"
	icon_base = "mining"
	free_resource_amt = 2
	free_resources = list(/obj/item/material_piece/mauxite,
	/obj/item/material_piece/pharosium,
	/obj/item/material_piece/molitz)
	available = list(/datum/manufacture/pick,
	/datum/manufacture/powerpick,
	/datum/manufacture/blastchargeslite,
	/datum/manufacture/blastcharges,
	/datum/manufacture/powerhammer,
	/datum/manufacture/drill,
	/datum/manufacture/conc_gloves,
	/datum/manufacture/jumpsuit,
	/datum/manufacture/shoes,
	/datum/manufacture/breathmask,
	/datum/manufacture/engspacesuit,
	/datum/manufacture/industrialarmor,
	/datum/manufacture/industrialboots,
	/datum/manufacture/powercell,
	/datum/manufacture/powercellE,
	/datum/manufacture/powercellC,
	/datum/manufacture/oresatchel,
	/datum/manufacture/oresatchelL,
	/datum/manufacture/jetpack,
	/datum/manufacture/geoscanner,
	/datum/manufacture/eyes_meson,
	/datum/manufacture/flashlight,
	/datum/manufacture/ore_accumulator,
	/datum/manufacture/rods2,
	/datum/manufacture/metal,
#ifdef UNDERWATER_MAP
	/datum/manufacture/jetpackmkII,
#endif
	/datum/manufacture/mining_magnet)

	hidden = list(/datum/manufacture/RCD,
	/datum/manufacture/RCDammo,
	/datum/manufacture/RCDammolarge)

/obj/machinery/manufacturer/hangar
	name = "Ship Component Fabricator"
	desc = "A manufacturing unit calibrated to produce parts for ships."
	icon_state = "fab-hangar"
	icon_base = "hangar"
	free_resource_amt = 2
	free_resources = list(
		/obj/item/material_piece/mauxite,
		/obj/item/material_piece/pharosium,
		/obj/item/material_piece/molitz
	)
	available = list(
		/datum/manufacture/putt/engine,
		/datum/manufacture/putt/boards,
		/datum/manufacture/putt/control,
		/datum/manufacture/putt/parts,
		/datum/manufacture/pod/engine,
		/datum/manufacture/pod/boards,
		/datum/manufacture/pod/armor_light,
		/datum/manufacture/pod/armor_heavy,
		/datum/manufacture/pod/armor_industrial,
		/datum/manufacture/pod/control,
		/datum/manufacture/pod/parts,
		/datum/manufacture/cargohold,
		/datum/manufacture/orescoop,
		/datum/manufacture/conclave,
		/datum/manufacture/communications/mining,
		/datum/manufacture/pod/weapon/mining,
		/datum/manufacture/pod/weapon/mining/drill,
		/datum/manufacture/pod/weapon/ltlaser,
		/datum/manufacture/engine2,
		/datum/manufacture/engine3,
		/datum/manufacture/pod/lock
	)

/obj/machinery/manufacturer/uniform // add more stuff to this as needed, but it should be for regular uniforms the HoP might hand out, not tons of gimmicks. -cogwerks
	name = "Uniform Manufacturer"
	desc = "A manufacturing unit calibrated to produce workplace uniforms."
	icon_state = "fab-jumpsuit"
	icon_base = "jumpsuit"
	free_resource_amt = 5
	free_resources = list(/obj/item/material_piece/cloth/cottonfabric)
	accept_blueprints = 0
	available = list(/datum/manufacture/shoes,	//hey if you update these please remember to add it to /hop_and_uniform's list too
	/datum/manufacture/shoes_brown,
	/datum/manufacture/shoes_white,
	/datum/manufacture/jumpsuit,
	/datum/manufacture/jumpsuit_white,
	/datum/manufacture/jumpsuit_red,
	/datum/manufacture/jumpsuit_yellow,
	/datum/manufacture/jumpsuit_green,
	/datum/manufacture/jumpsuit_pink,
	/datum/manufacture/jumpsuit_blue,
	/datum/manufacture/jumpsuit_brown,
	/datum/manufacture/jumpsuit_black,
	/datum/manufacture/jumpsuit_orange,
	/datum/manufacture/suit_black,
	/datum/manufacture/dress_black,
	/datum/manufacture/hat_black,
	/datum/manufacture/hat_white,
	/datum/manufacture/hat_blue,
	/datum/manufacture/hat_yellow,
	/datum/manufacture/hat_red,
	/datum/manufacture/hat_green,
	/datum/manufacture/hat_tophat,
	/datum/manufacture/backpack,
	/datum/manufacture/satchel)

	hidden = list(/datum/manufacture/breathmask,
	/datum/manufacture/patch)
	///datum/manufacture/hermes) //all hail the shoe lord - needs adjusting for the new movement system which I cba to do right now

/// cogwerks - a gas extractor for the engine

/obj/machinery/manufacturer/gas
	name = "Gas Extractor"
	desc = "A manufacturing unit that can produce gas canisters from certain ores."
	icon_state = "fab-mining"
	icon_base = "mining"
	accept_blueprints = 0
	available = list(
	/datum/manufacture/atmos_can,
	/datum/manufacture/air_can/large,
	/datum/manufacture/o2_can,
	/datum/manufacture/co2_can,
	/datum/manufacture/n2_can,
	/datum/manufacture/plasma_can)

// a blank manufacturer for mechanics

/obj/machinery/manufacturer/mechanic
	name = "Reverse-Engineering Fabricator"
	desc = "A manufacturing unit designed to create new things from blueprints."
	icon_state = "fab-hangar"
	icon_base = "hangar"
	free_resource_amt = 2
	free_resources = list(/obj/item/material_piece/mauxite,/obj/item/material_piece/pharosium,/obj/item/material_piece/molitz)

/obj/machinery/manufacturer/personnel
	name = "Personnel Equipment Manufacturer"
	desc = "A manufacturing unit that produces important identification and access equipment."
	icon_state = "fab-access"
	icon_base = "access"
	free_resource_amt = 2
	free_resources = list(/obj/item/material_piece/mauxite,/obj/item/material_piece/pharosium,/obj/item/material_piece/molitz)
	available = list(/datum/manufacture/id_card, /datum/manufacture/implant_access,	/datum/manufacture/implanter) //hey if you update these please remember to add it to /hop_and_uniform's list too
	hidden = list(/datum/manufacture/id_card_gold, /datum/manufacture/implant_access_infinite)

//combine personnel + uniform manufactuer here. this is 'cause destiny doesn't have enough room! arrg!
//and i hate this, i do, but you're gonna have to update this list whenever you update /personnel or /uniform
/obj/machinery/manufacturer/hop_and_uniform
	name = "Personnel Manufacturer"
	desc = "A manufacturing unit calibrated to produce workplace uniforms and identification equipment."
	icon_state = "fab-access"
	icon_base = "access"
	free_resource_amt = 5
	free_resources = list(/obj/item/material_piece/cloth/cottonfabric,/obj/item/material_piece/mauxite,/obj/item/material_piece/pharosium,/obj/item/material_piece/molitz)
	accept_blueprints = 0
	available = list(/datum/manufacture/id_card,
	/datum/manufacture/implant_access,
	/datum/manufacture/implanter,
	/datum/manufacture/shoes,
	/datum/manufacture/shoes_brown,
	/datum/manufacture/shoes_white,
	/datum/manufacture/jumpsuit,
	/datum/manufacture/jumpsuit_white,
	/datum/manufacture/jumpsuit_red,
	/datum/manufacture/jumpsuit_yellow,
	/datum/manufacture/jumpsuit_green,
	/datum/manufacture/jumpsuit_pink,
	/datum/manufacture/jumpsuit_blue,
	/datum/manufacture/jumpsuit_brown,
	/datum/manufacture/jumpsuit_black,
	/datum/manufacture/jumpsuit_orange,
	/datum/manufacture/suit_black,
	/datum/manufacture/hat_black,
	/datum/manufacture/hat_white,
	/datum/manufacture/hat_blue,
	/datum/manufacture/hat_yellow,
	/datum/manufacture/hat_red,
	/datum/manufacture/hat_green,
	/datum/manufacture/hat_tophat)

	hidden = list(/datum/manufacture/id_card_gold,
	/datum/manufacture/implant_access_infinite,
	/datum/manufacture/breathmask,
	/datum/manufacture/patch)

/obj/machinery/manufacturer/qm // This manufacturer just creates different crated and boxes for the QM. Lets give their boring lives at least something more interesting.
	name = "Crate Manufacturer"
	desc = "A manufacturing unit calibrated to produce different crates and boxes."
	icon_state = "fab-crates"
	icon_base = "crates"
	free_resource_amt = 5
	free_resources = list(/obj/item/material_piece/mauxite)
	accept_blueprints = 0
	available = list(/datum/manufacture/crate,	//hey if you update these please remember to add it to /hop_and_uniform's list too
	/datum/manufacture/packingcrate,
	/datum/manufacture/pizzabox,
	/datum/manufacture/wooden,
	/datum/manufacture/medical,
	/datum/manufacture/biohazard)

	hidden = list(/datum/manufacture/classcrate)

#undef WIRE_EXTEND
#undef WIRE_POWER
#undef WIRE_MALF
#undef WIRE_SHOCK
#undef MAX_QUEUE_LENGTH
