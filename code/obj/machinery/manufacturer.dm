#define MAX_QUEUE_LENGTH 20
#define WIRE_EXTEND 1
#define WIRE_POWER 2
#define WIRE_MALF 3
#define WIRE_SHOCK 4

/obj/machinery/manufacturer
	name = "manufacturing unit"
	desc = "A 3D printer-like machine that can construct items from raw materials."
	icon = 'icons/obj/manufacturer.dmi'
	icon_state = "fab-general"
	var/icon_base = "general" //! This is used to make icon state changes cleaner by setting it to "fab-[icon_base]"
	density = TRUE
	anchored = TRUE
	mats = 20
	power_usage = 200
	// req_access is used to lock out specific featurs and not limit deconstruciton therefore DECON_NO_ACCESS is required
	req_access = list(access_heads)
	event_handler_flags = NO_MOUSEDROP_QOL
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL | DECON_NO_ACCESS
	flags = NOSPLASH | FLUID_SUBMERGE

	// General stuff
	var/health = 100
	var/supplemental_desc = null //! appended in get_desc() to the base description, to make subtype definitions cleaner
	var/mode = "ready"
	var/error = null
	var/active_power_consumption = 0 //! How much power is consumed while active? This is determined automatically when the unit starts a production cycle
	var/panel_open = FALSE
	var/dismantle_stage = 0
	var/hacked = FALSE
	var/malfunction = FALSE
	var/electrified = 0 //! This is a timer and not a true/false; it's decremented every process() tick
	var/output_target = null
	var/list/nearby_turfs = list()
	var/wires = 15 //! This is a bitflag used to track wire states, for hacking and such. Replace it with something cleaner if an option exists when you're reading this :p
	var/temp = null //! Used as a cache when outputting messages to users
	var/frequency = FREQ_PDA
	var/net_id = null
	var/device_tag = "PNET_MANUFACTURER"
	var/obj/machinery/power/data_terminal/link = null
	var/obj/item/card/id/scan = null //! Used when deducting payment for ores from a Rockbox

	// Printing and queues
	var/time_left = 0
	var/speed = 3
	var/repeat = FALSE
	var/manual_stop = FALSE
	var/output_cap = 20
	var/last_queue_op = 0 //! This is an antispam timer to prevent autoclickers from lagging the server
	var/list/queue = list()

	// Resources/materials
	var/base_material_class = /obj/item/material_piece //! Base class for material pieces that the manufacturer accepts. Keep this as material pieces only unless you're making larger changes to the system
	var/free_resource_amt = 0 //! The amount of each free resource that the manufacturer comes preloaded with
	var/list/obj/item/material_piece/free_resources = list() //! See free_resource_amt; this is the list of resources being populated from
	var/obj/item/reagent_containers/glass/beaker = null
	var/obj/item/disk/data/floppy/manudrive = null
	var/list/resource_amounts = list()
	var/list/materials_in_use = list()

	// Production options
	var/search = null
	var/accept_blueprints = TRUE
	var/list/available = list() //! A list of every option available in this unit subtype by default
	var/list/download = list() //! Options gained from scanned blueprints
	var/list/drive_recipes = list() //! Options provided by an inserted manudrive
	var/list/hidden = list() //! These options are available by default, but can't be printed unless the machine is hacked

	// Unsorted stuff. The names for these should (hopefully!) be self-explanatory
	var/image/work_display = null
	var/image/activity_display = null
	var/image/panel_sprite = null
	var/sound_happy = 'sound/machines/chime.ogg'
	var/sound_grump = 'sound/machines/buzz-two.ogg'
	var/sound_beginwork = 'sound/machines/computerboot_pc.ogg'
	var/sound_damaged = 'sound/impact_sounds/Metal_Hit_Light_1.ogg'
	var/sound_destroyed = 'sound/impact_sounds/Machinery_Break_1.ogg'
	var/static/list/sounds_malfunction = list('sound/machines/engine_grump1.ogg','sound/machines/engine_grump2.ogg','sound/machines/engine_grump3.ogg',
	'sound/machines/glitch1.ogg','sound/machines/glitch2.ogg','sound/machines/glitch3.ogg','sound/impact_sounds/Metal_Clang_1.ogg','sound/impact_sounds/Metal_Hit_Heavy_1.ogg','sound/machines/romhack1.ogg','sound/machines/romhack3.ogg')
	var/static/list/text_flipout_adjective = list("an awful","a terrible","a loud","a horrible","a nasty","a horrendous")
	var/static/list/text_flipout_noun = list("noise","racket","ruckus","clatter","commotion","din")
	var/static/list/text_bad_output_adjective = list("janky","crooked","warped","shoddy","shabby","lousy","crappy","shitty")
	var/datum/action/action_bar = null

	New()
		START_TRACKING
		..()
		MAKE_SENDER_RADIO_PACKET_COMPONENT(null, src.frequency)
		src.net_id = generate_net_id(src)

		if(!src.link)
			var/turf/T = get_turf(src)
			var/obj/machinery/power/data_terminal/test_link = locate() in T
			if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
				src.link = test_link
				src.link.master = src

		src.AddComponent(/datum/component/bullet_holes, 15, 5)

		if (istype(manuf_controls,/datum/manufacturing_controller))
			src.set_up_schematics()
			manuf_controls.manufacturing_units += src

		for (var/turf/T in view(5,src))
			nearby_turfs += T

		src.create_reagents(1000)

		src.work_display = image('icons/obj/manufacturer.dmi', "")
		src.activity_display = image('icons/obj/manufacturer.dmi', "")
		src.panel_sprite = image('icons/obj/manufacturer.dmi', "")
		SPAWN(0)
			src.build_icon()

	disposing()
		STOP_TRACKING
		manuf_controls.manufacturing_units -= src
		src.work_display = null
		src.activity_display = null
		src.panel_sprite = null
		src.output_target = null
		src.beaker = null
		src.manudrive = null
		src.available.len = 0
		src.available = null
		src.drive_recipes = null
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
		if (src.link)
			src.link.master = null
			src.link = null

		for (var/obj/O in src.contents)
			O.set_loc(src.loc)
		for (var/mob/M in src.contents)
			// unlikely as this is to happen we might as well make sure everything is purged
			M.set_loc(src.loc)

		..()

	get_desc()
		if (supplemental_desc)
			. += " [supplemental_desc]"
		if (src.health < 100)
			if (src.health < 50)
				. += "<br><span class='alert'>It's rather badly damaged. It probably needs some wiring replaced inside.</span>"
			else
				. += "<br><span class='alert'>It's a bit damaged. It looks like it needs some welding done.</span>"

		if	(status & BROKEN)
			. += "<br><span class='alert'>It seems to be damaged beyond the point of operability!</span>"
		if	(status & NOPOWER)
			. += "<br><span class='alert'>It seems to be offline.</span>"

		switch(src.dismantle_stage)
			if(1)
				. += "<br><span class='alert'>It's partially dismantled. To deconstruct it, use a crowbar. To repair it, use a wrench.</span>"
			if(2)
				. += "<br><span class='alert'>It's partially dismantled. To deconstruct it, use wirecutters. To repair it, add reinforced metal.</span>"
			if(3)
				. += "<br><span class='alert'>It's partially dismantled. To deconstruct it, use a wrench. To repair it, add some cable.</span>"

	process(mult)
		if (status & NOPOWER)
			return

		power_usage = src.active_power_consumption + 200 * mult
		..()

		if (src.mode == "working")
			use_power(src.active_power_consumption)

		if (src.electrified > 0)
			src.electrified--
		/*
		if (src.mode == "working")
			if (src.malfunction && prob(8))
				src.flip_out()
			src.time_left -= src.speed * 4.4 * mult
			use_power(src.active_power_consumption)
			if (src.time_left < 1)
				src.output_loop(src.queue[1])
				SPAWN(0)
					if (src.queue.len < 1)
						src.manual_stop = 0
						playsound(src.loc, src.sound_happy, 50, 1)
						src.visible_message("<span class='notice'>[src] finishes its production queue.</span>")
						src.mode = "ready"
						src.build_icon()
		*/

	proc/finish_work()

		if(length(src.queue))
			output_loop(src.queue[1])
			if (!src.repeat)
				src.queue -= src.queue[1]

		if (src.queue.len < 1)
			src.manual_stop = 0
			playsound(src.loc, src.sound_happy, 50, 1)
			src.visible_message("<span class='notice'>[src] finishes its production queue.</span>")
			src.mode = "ready"
			src.build_icon()

	ex_act(severity)
		switch(severity)
			if(1)
				for(var/atom/movable/A as mob|obj in src)
					A.set_loc(src.loc)
					A.ex_act(severity)
				src.take_damage(rand(100,120))
			if(2)
				src.take_damage(rand(40,80))
			if(3)
				src.take_damage(rand(20,40))
		return

	blob_act(power)
		src.take_damage(rand(power * 0.5, power * 1.5))

	meteorhit()
		src.take_damage(rand(15,45))

	emp_act()
		src.take_damage(rand(5,10))
		src.malfunction = TRUE
		src.flip_out()

	bullet_act(obj/projectile/P)
		// swiped from guardbot.dm
		var/damage = 0
		damage = round(((P.power/3)*P.proj_data.ks_ratio), 1.0)

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
				SPAWN(rand(0, 15))
					status |= NOPOWER
					src.build_icon()

	attack_hand(mob/user)
		if (free_resource_amt > 0) // We do this here instead of on New() as a tiny optimization to keep some overhead off of map load
			claim_free_resources()
		if(src.electrified)
			if (!(status & NOPOWER || status & BROKEN))
				if (src.shock(user, 33))
					return

		src.add_dialog(user)

		var/HTML = {"
		<title>[src.name]</title>
		<style type='text/css'>

			/* will probaby break chui, dont care */
			body { background: #222; color: white; font-family: Tahoma, sans-serif; }
			a { color: #88f; }

			.l { text-align: left; } .r { text-align: right; } .c { text-align: center; }
			.buttonlink { background: #66c; min-width: 1.1em; height: 1.2em; padding: 0.2em 0.2em; margin-bottom: 2px; border-radius: 4px; font-size: 90%; color: white; text-decoration: none; display: inline-block; vertical-align: middle; }
			thead { background: #555555; }

			table {
				border-collapse: collapse;
				width: 100%;
				}
			td, th { padding: 0.2em; 0.5em; }
			.outline td, .outline th {
				border: 1px solid #666;
			}

			img, a img {
				border: 0;
				}

			#info {
				position: absolute;
				right: 0.5em;
				top: 0;
				width: 25%;
				padding: 0.5em;
				}

			#products {
				position: absolute;
				left: 0;
				top: 0;
				width: 73%;
				padding: 0.25em;
			}

			.queue, .product {
				position: relative;
				display: inline-block;
				width: 12em;
				padding: 0.25em 0.5em;
				border-radius: 5px;
				margin: 0.5em;
				background: #555;
				box-shadow: 3px 3px 0 2px #000;
				}

			.queue {
				vertical-align: middle;
				clear: both;
				}
			.queue .icon {
				float: left;
				margin: 0.2em;
				}
			.product {
				vertical-align: top;
				text-align: center;
				}
			.product .time {
				position: absolute;
				bottom: 0.3em;
				right: 0.3em;
				}
			.product .mats {
				position: absolute;
				bottom: 0.3em;
				left: 0.3em;
				}
			.product .icon {
				display: block;
				height: 64px;
				width: 64px;
				margin: 0.2em auto 0.5em auto;
				-ms-interpolation-mode: nearest-neighbor; /* pixels go cronch */
				}
			.product.disabled {
				background: #333;
				color: #aaa;
			}
			.required {
				display: none;
				}

			.product:hover {
				cursor: pointer;
				background: #666;
			}
			.product:hover .required {
				display: block;
				position: absolute;
				left: 0;
				right: 0;
				}
			.product .delete {
				color: #c44;
				background: #222;
				padding: 0.25em 0.5em;
				border-radius: 10px;
				}
			.required div {
				position: absolute;
				top: 0;
				left: 0;
				right: 0;
				background: #333;
				border: 1px solid #888888;
				padding: 0.25em 0.5em;
				margin: 0.25em 0.5em;
				font-size: 80%;
				text-align: left;
				border-radius: 5px;
				}
			.mat-missing {
				color: #f66;
			}
		</style>
		<script type="text/javascript">
			function product(ref) {
				window.location = "?src=\ref[src];disp=" + ref;
			}

			function delete_product(ref) {
				window.location = "?src=\ref[src];delete=1;disp=" + ref;
			}
		</script>
		"}


		var/list/dat = list()
		var/delete_allowed = src.allowed(user)

		if (src.panel_open || isAI(user))
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
			user.Browse(dat, "window=manufact;size=750x500")
			onclose(user, "manufact")
			return

		dat += "<div id='products'>"

		// Get the list of stuff we can print ...
		var/list/products = src.available + src.drive_recipes + src.download
		if (src.hacked)
			products += src.hidden

		// Then make it
		var/can_be_made = 0
		var/delete_link
		for(var/datum/manufacture/A in products)
			var/list/mats_used = get_materials_needed(A)

			if (istext(src.search) && !findtext(A.name, src.search, 1, null))
				continue

			can_be_made = (mats_used.len >= A.item_paths.len)
			if(delete_allowed && src.download.Find(A))
				delete_link = {"<span class='delete' onclick='delete_product("\ref[A]");'>DELETE</span>"}

			else
				delete_link = ""

			var/icon_text = "<img class='icon'>"
			// @todo probably refactor this since it's copy pasted twice now.
			if (A.item_outputs)
				var/icon_rsc = getItemIcon(A.item_outputs[1], C = user.client)
				// user << browse_rsc(browse_item_icons[icon_rsc], icon_rsc)
				icon_text = "<img class='icon' src='[icon_rsc]'>"

			if (istype(A, /datum/manufacture/mechanics))
				var/datum/manufacture/mechanics/F = A
				var/icon_rsc = getItemIcon(F.frame_path, C = user.client)
				// user << browse_rsc(browse_item_icons[icon_rsc], icon_rsc)
				icon_text = "<img class='icon' src='[icon_rsc]'>"

			var/list/material_text = list()
			var/list/material_count = 0
			for (var/i in 1 to A.item_paths.len)
				material_count += A.item_amounts[i]
				var/mat_name
				if(isnull(A.item_names) || isnull(A.item_names[i]))
					mat_name = get_nice_mat_name_for_manufacturers(A.item_paths[i])
				else
					mat_name = A.item_names[i]
				material_text += {"
				<span class='mat[mats_used[A.item_paths[i]] ? "" : "-missing"]'>[A.item_amounts[i]/10] [mat_name]</span>
				"}

			dat += {"
		<div class='product[can_be_made ? "" : " disabled"]' onclick='product("\ref[A]");'>
			<strong>[A.name]</strong>
			<div class='required'><div>[material_text.Join("<br>")]</div></div>
			[icon_text]
			[delete_link]
			<span class='mats'>[material_count/10] mat.</span>
			<span class='time'>[A.time && src.speed ? round(A.time / src.speed / 10, 0.1) : "??"] sec.</span>
		</div>"}


		dat += "</div><div id='info'>"
		dat += build_material_list(user)

		// This is not re-formatted yet just b/c i don't wanna mess with it
		dat +="<B>Scanned Card:</B> <A href='?src=\ref[src];card=1'>([src.scan])</A><BR>"
		if(scan)
			var/datum/db_record/account = null
			account = FindBankAccountByName(src.scan.registered)
			if (account)
				dat+="<B>Current Funds</B>: [account["current_money"]] Credits<br>"
		dat+= src.temp
		dat += "<HR><B>Ores Available for Purchase:</B><br><small>"
		for_by_tcl(S, /obj/machinery/ore_cloud_storage_container)
			if(S.broken)
				continue
			dat += "<B>[S.name] at [get_area(S)]:</B><br>"
			var/list/ores = S.ores
			for(var/ore in ores)
				var/datum/ore_cloud_data/OCD = ores[ore]
				if(!OCD.for_sale || !OCD.amount)
					continue
				var/taxes = round(max(rockbox_globals.rockbox_client_fee_min,abs(OCD.price*rockbox_globals.rockbox_client_fee_pct/100)),0.01) //transaction taxes for the station budget
				dat += "[ore]: [OCD.amount] ([OCD.price+taxes+(!rockbox_globals.rockbox_premium_purchased ? rockbox_globals.rockbox_standard_fee : 0)][CREDIT_SIGN]/ore) (<A href='?src=\ref[src];purchase=1;storage=\ref[S];ore=[ore]'>Purchase</A>)<br>"

		dat += "</small><HR>"

		dat += build_control_panel(user)


		user.Browse(HTML + dat.Join(), "window=manufact;size=1111x600")
		onclose(user, "manufact")

		interact_particle(user,src)

	// Validate that an item is inside this machine for HREF check purposes
	proc/validate_disp(datum/manufacture/M)
		. = FALSE
		if(src.available && (M in src.available))
			return TRUE

		if(src.download && (M in src.download))
			return TRUE

		if(src.drive_recipes && (M in src.drive_recipes))
			return TRUE

		if(src.hacked && src.hidden && (M in src.hidden))
			return TRUE


	Topic(href, href_list)

		if(!(href_list["cutwire"] || href_list["pulsewire"]))
			if(status & BROKEN || status & NOPOWER)
				return

		if(usr.stat || usr.restrained())
			return

		if(src.electrified)
			if (!(status & NOPOWER || status & BROKEN))
				if (src.shock(usr, 10))
					return

		if (((BOUNDS_DIST(src, usr) == 0 || (isAI(usr) || isrobot(usr))) && istype(src.loc, /turf)))
			src.add_dialog(usr)

			if (src.malfunction && prob(10))
				src.flip_out()

			if (href_list["eject"])
				if (src.mode != "ready")
					boutput(usr, "<span class='alert'>You cannot eject materials while the unit is working.</span>")
				else
					var/mat_id = href_list["eject"]
					var/ejectamt = 0
					var/turf/ejectturf = get_turf(usr)
					for(var/obj/item/O in src.contents)
						if (O.material && O.material.mat_id == mat_id)
							if (!ejectamt)
								ejectamt = input(usr,"How many material pieces do you want to eject?","Eject Materials") as num
								if (ejectamt <= 0 || src.mode != "ready" || BOUNDS_DIST(src, usr) > 0 || !isnum_safe(ejectamt))
									break
								if (round(ejectamt) != ejectamt)
									boutput(usr, "<span class='alert'>You can only eject a whole number of a material</span>")
									break
							if (!ejectturf)
								break
							if (ejectamt > O.amount)
								playsound(src.loc, src.sound_grump, 50, 1)
								boutput(usr, "<span class='alert'>There's not that much material in [name]. It has ejected what it could.</span>")
								ejectamt = O.amount
							src.update_resource_amount(mat_id, -ejectamt * 10) // ejectamt will always be <= actual amount
							if (ejectamt == O.amount)
								O.set_loc(get_output_location(O))
							else
								var/obj/item/material_piece/P = new O.type
								P.setMaterial(copyMaterial(O.material))
								P.change_stack_amount(ejectamt - P.amount)
								O.change_stack_amount(-ejectamt)
								P.set_loc(get_output_location(O))
							break

			if (href_list["speed"])
				var/upperbound = src.hacked ? 5 : 3
				var/given_speed = text2num(href_list["speed"])
				if (src.mode == "working")
					boutput(usr, "<span class='alert'>You cannot alter the speed setting while the unit is working.</span>")
				else if (given_speed >= 1 && given_speed <= upperbound)
					src.speed = given_speed
				else
					var/newset = input(usr, "Enter from 1 to [upperbound]. Higher settings consume more power.", "Manufacturing Speed") as num
					src.speed = clamp(newset, 1, upperbound)

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
				var/operation = text2num_safe(href_list["removefromQ"])
				if (!isnum(operation) || src.queue.len < 1 || operation > src.queue.len)
					boutput(usr, "<span class='alert'>Invalid operation.</span>")
					return

				if(world.time < last_queue_op + 5) //Anti-spam to prevent people lagging the server with autoclickers
					return
				else
					last_queue_op = world.time

				src.queue -= src.queue[operation]
				begin_work()//pesky exploits

			if (href_list["repeat"])
				src.repeat = !src.repeat

			if (href_list["continue"])
				if (src.queue.len < 1)
					boutput(usr, "<span class='alert'>Cannot find any items in queue to continue production.</span>")
					return
				if (!check_enough_materials(src.queue[1]))
					boutput(usr, "<span class='alert'>Insufficient usable materials to manufacture first item in queue.</span>")
				else
					src.begin_work(0)

			if (href_list["pause"])
				src.mode = "halt"
				src.build_icon()
				if (src.action_bar)
					src.action_bar.interrupt(INTERRUPT_ALWAYS)

			if (href_list["delete"])
				if(!src.allowed(usr))
					boutput(usr, "<span class='alert'>Access denied.</span>")
					return
				var/datum/manufacture/I = locate(href_list["disp"])
				if (!istype(I,/datum/manufacture/mechanics/))
					boutput(usr, "<span class='alert'>Cannot delete this schematic.</span>")
					return
				last_queue_op = world.time
				if(tgui_alert(usr, "Are you sure you want to remove [I.name] from the [src]?", "Confirmation", list("Yes", "No")) == "Yes")
					src.download -= I
			else if (href_list["disp"])
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

				if (!check_enough_materials(I))
					boutput(usr, "<span class='alert'>Insufficient usable materials to manufacture that item.</span>")
				else if (src.queue.len >= MAX_QUEUE_LENGTH)
					boutput(usr, "<span class='alert'>Manufacturer queue length limit reached.</span>")
				else
					src.queue += I
					if (src.mode == "ready")
						src.begin_work(1)
						src.updateUsrDialog()

				if (src.queue.len > 0 && src.mode == "ready")
					src.begin_work(1)
					src.updateUsrDialog()
					return

			if (href_list["ejectmanudrive"])
				src.eject_manudrive(usr)

			if (href_list["ejectbeaker"])
				if (src.beaker)
					src.beaker.set_loc(get_output_location(beaker))
				src.beaker = null

			if (href_list["transto"])
				// reagents are going into beaker
				var/obj/item/reagent_containers/glass/B = locate(href_list["transto"])
				if (!istype(B,/obj/item/reagent_containers/glass/))
					return
				var/howmuch = input("Transfer how much to [B]?","[src.name]",B.reagents.maximum_volume - B.reagents.total_volume) as null|num
				if (!howmuch || !B || B != src.beaker || !isnum_safe(howmuch) )
					return
				src.reagents.trans_to(B,howmuch)

			if (href_list["transfrom"])
				// reagents are being drawn from beaker
				var/obj/item/reagent_containers/glass/B = locate(href_list["transfrom"])
				if (!istype(B,/obj/item/reagent_containers/glass/))
					return
				var/howmuch = input("Transfer how much from [B]?","[src.name]",B.reagents.total_volume) as null|num
				if (!howmuch || !isnum_safe(howmuch))
					return
				B.reagents.trans_to(src,howmuch)

			if (href_list["flush"])
				var/the_reagent = href_list["flush"]
				if (!istext(the_reagent))
					return
				var/howmuch = input("Flush how much [the_reagent]?","[src.name]",0) as null|num
				if (!howmuch || !isnum_safe(howmuch))
					return
				src.reagents.remove_reagent(the_reagent,howmuch)

			if ((href_list["cutwire"]) && (src.panel_open || isAI(usr)))
				if (src.electrified)
					if (src.shock(usr, 100))
						return
				var/twire = text2num_safe(href_list["cutwire"])
				if (!usr.find_tool_in_hand(TOOL_SNIPPING))
					boutput(usr, "You need a snipping tool!")
					return
				else if (src.isWireColorCut(twire))
					src.mend(usr, twire)
				else
					src.cut(usr, twire)
				src.build_icon()

			if ((href_list["pulsewire"]) && (src.panel_open || isAI(usr)))
				var/twire = text2num_safe(href_list["pulsewire"])
				if ( !(usr.find_tool_in_hand(TOOL_PULSING) || isAI(usr)) )
					boutput(usr, "You need a multitool or similar!")
					return
				else if (src.isWireColorCut(twire))
					boutput(usr, "You can't pulse a cut wire.")
					return
				else
					src.pulse(usr, twire)
				src.build_icon()

			if (href_list["card"])
				if (src.scan) src.scan = null
				else
					var/obj/item/I = usr.equipped()
					src.scan_card(I)

			if (href_list["purchase"])
				var/obj/machinery/ore_cloud_storage_container/storage = locate(href_list["storage"])
				var/ore = href_list["ore"]
				var/datum/ore_cloud_data/OCD = storage.ores[ore]
				var/price = OCD.price
				var/taxes = round(max(rockbox_globals.rockbox_client_fee_min,abs(price*rockbox_globals.rockbox_client_fee_pct/100)),0.01) //transaction taxes for the station budget

				if(storage?.broken)
					return

				if(!scan)
					src.temp = {"You have to scan a card in first.<BR>"}
					src.updateUsrDialog()
					return
				else
					src.temp = null
				if (src.scan.registered in FrozenAccounts)
					boutput(usr, "<span class='alert'>Your account cannot currently be liquidated due to active borrows.</span>")
					return
				var/datum/db_record/account = null
				account = FindBankAccountByName(src.scan.registered)
				if (account)
					var/quantity = 1
					quantity = max(0, input("How many units do you want to purchase?", "Ore Purchase", null, null) as num)
					if(!isnum_safe(quantity))
						return
					////////////

					if(OCD.amount >= quantity && quantity > 0)
						var/subtotal = round(price * quantity)
						var/sum_taxes = round(taxes * quantity)
						var/rockbox_fees = (!rockbox_globals.rockbox_premium_purchased ? rockbox_globals.rockbox_standard_fee : 0) * quantity
						var/total = subtotal + sum_taxes + rockbox_fees
						if(account["current_money"] >= total)
							account["current_money"] -= total
							storage.eject_ores(ore, get_output_location(), quantity, transmit=1, user=usr)

							 // This next bit is stolen from PTL Code
							var/list/accounts = \
								data_core.bank.find_records("job", "Chief Engineer") + \
								data_core.bank.find_records("job", "Chief Engineer") + \
								data_core.bank.find_records("job", "Engineer")


							var/datum/signal/minerSignal = get_free_signal()
							minerSignal.source = src
							//any non-divisible amounts go to the shipping budget
							var/leftovers = 0
							if(length(accounts))
								leftovers = subtotal % length(accounts)
								var/divisible_amount = subtotal - leftovers
								if(divisible_amount)
									var/amount_per_account = divisible_amount/length(accounts)
									for(var/datum/db_record/t as anything in accounts)
										t["current_money"] += amount_per_account
									minerSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="ROCKBOX&trade;-MAILBOT",  "group"=list(MGD_MINING, MGA_SALES), "sender"=src.net_id, "message"="Notification: [amount_per_account] credits earned from Rockbox&trade; sale, deposited to your account.")
							else
								leftovers = subtotal
								minerSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="ROCKBOX&trade;-MAILBOT",  "group"=list(MGD_MINING, MGA_SALES), "sender"=src.net_id, "message"="Notification: [leftovers + sum_taxes] credits earned from Rockbox&trade; sale, deposited to the shipping budget.")
							wagesystem.shipping_budget += (leftovers + sum_taxes)
							SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, minerSignal)

							src.temp = {"Enjoy your purchase!<BR>"}
						else
							src.temp = {"You don't have enough dosh, bucko.<BR>"}
					else
						if(quantity > 0)
							src.temp = {"I don't have that many for sale, champ.<BR>"}
						else
							src.temp = {"Enter some actual valid number, you doofus!<BR>"}
				else
					src.temp = {"That card doesn't have an account anymore, you might wanna get that checked out.<BR>"}

			src.updateUsrDialog()
		return

	emag_act(mob/user, obj/item/card/emag/E)
		if (!src.hacked)
			src.hacked = TRUE
			if(user)
				boutput(user, "<span class='notice'>You remove the [src]'s product locks!</span>")
			return TRUE
		return FALSE

	attackby(obj/item/W, mob/user)
		if (src.electrified)
			if (src.shock(user, 33))
				return

		if (istype(W, /obj/item/ore_scoop))
			var/obj/item/ore_scoop/scoop = W
			W = scoop.satchel

		if (istype(W, /obj/item/paper/manufacturer_blueprint))
			if (!src.accept_blueprints)
				boutput(user, "<span class='alert'>This manufacturer unit does not accept blueprints.</span>")
				return
			var/obj/item/paper/manufacturer_blueprint/BP = W
			if (src.malfunction && prob(75))
				src.visible_message("<span class='alert'>[src] emits a [pick(src.text_flipout_adjective)] [pick(src.text_flipout_noun)]!</span>")
				playsound(src.loc, pick(src.sounds_malfunction), 50, 1)
				boutput(user, "<span class='alert'>The manufacturer mangles and ruins the blueprint in the scanner! What the fuck?</span>")
				qdel(BP)
				return
			if (!BP.blueprint)
				src.visible_message("<span class='alert'>[src] emits a grumpy buzz!</span>")
				playsound(src.loc, src.sound_grump, 50, 1)
				boutput(user, "<span class='alert'>The manufacturer rejects the blueprint. Is something wrong with it?</span>")
				return
			for (var/datum/manufacture/mechanics/M in (src.available + src.download))
				if(istype(M) && istype(BP.blueprint, /datum/manufacture/mechanics))
					var/datum/manufacture/mechanics/BPM = BP.blueprint
					if(M.frame_path == BPM.frame_path)
						src.visible_message("<span class='alert'>[src] emits an irritable buzz!</span>")
						playsound(src.loc, src.sound_grump, 50, 1)
						boutput(user, "<span class='alert'>The manufacturer rejects the blueprint, as it already knows it.</span>")
						return
				else if (BP.blueprint.name == M.name)
					src.visible_message("<span class='alert'>[src] emits an irritable buzz!</span>")
					playsound(src.loc, src.sound_grump, 50, 1)
					boutput(user, "<span class='alert'>The manufacturer rejects the blueprint, as it already knows it.</span>")
					return
			BP.dropped(user)
			src.download += BP.blueprint
			src.visible_message("<span class='alert'>[src] emits a pleased chime!</span>")
			playsound(src.loc, src.sound_happy, 50, 1)
			boutput(user, "<span class='notice'>The manufacturer accepts and scans the blueprint.</span>")
			qdel(BP)
			return

		else if (istype(W, /obj/item/satchel))
			user.visible_message("<span class='notice'>[user] uses [src]'s automatic loader on [W]!</span>", "<span class='notice'>You use [src]'s automatic loader on [W].</span>")
			var/amtload = 0
			for (var/obj/item/M in W.contents)
				if (!istype(M,src.base_material_class))
					continue
				src.load_item(M)
				amtload++
			W:UpdateIcon()
			if (amtload) boutput(user, "<span class='notice'>[amtload] materials loaded from [W]!</span>")
			else boutput(user, "<span class='alert'>No materials loaded!</span>")

		else if (isscrewingtool(W))
			if (!src.panel_open)
				src.panel_open = TRUE
			else
				src.panel_open = FALSE
			boutput(user, "You [src.panel_open ? "open" : "close"] the maintenance panel.")
			src.build_icon()

		else if (isweldingtool(W))
			var/do_action = 0
			if (istype(W,src.base_material_class) && src.accept_loading(user))
				var/choice = tgui_alert(user, "What do you want to do with [W]?", "[src.name]", list("Repair", "Load it in"))
				if (!choice)
					return
				if (choice == "Load it in")
					do_action = 1
			if (do_action == 1)
				user.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>", "<span class='notice'>You load [W] into the [src].</span>")
				src.load_item(W,user)
			else
				if (src.health < 50)
					boutput(user, "<span class='alert'>It's too badly damaged. You'll need to replace the wiring first.</span>")
				else if(W:try_weld(user, 1))
					src.take_damage(-10)
					user.visible_message("<b>[user]</b> uses [W] to repair some of [src]'s damage.")
					if (src.health == 100)
						boutput(user, "<span class='notice'><b>[src] looks fully repaired!</b></span>")

		else if (istype(W,/obj/item/cable_coil) && src.panel_open)
			var/obj/item/cable_coil/C = W
			var/do_action = 0
			if (istype(C,src.base_material_class) && src.accept_loading(user))
				var/choice = tgui_alert(user, "What do you want to do with [C]?", "[src.name]", list("Repair", "Load it in"))
				if (!choice)
					return
				if (choice == "Load it in")
					do_action = 1
			if (do_action == 1)
				user.visible_message("<span class='notice'>[user] loads [C] into the [src].</span>", "<span class='notice'>You load [C] into the [src].</span>")
				src.load_item(C,user)
			else
				if (src.health >= 50)
					boutput(user, "<span class='alert'>The wiring is fine. You need to weld the external plating to do further repairs.</span>")
				else
					C.use(1)
					src.take_damage(-10)
					user.visible_message("<b>[user]</b> uses [C] to repair some of [src]'s cabling.")
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					if (src.health >= 50)
						boutput(user, "<span class='notice'>The wiring is fully repaired. Now you need to weld the external plating.</span>")

		else if (iswrenchingtool(W))
			var/do_action = 0
			if (istype(W,src.base_material_class) && src.accept_loading(user))
				var/choice = tgui_alert(user, "What do you want to do with [W]?", "[src.name]", list("Dismantle/Construct", "Load it in"))
				if (!choice)
					return
				if (choice == "Load it in")
					do_action = 1
			if (do_action == 1)
				user.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>", "<span class='notice'>You load [W] into the [src].</span>")
				src.load_item(W,user)
			else
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
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
			playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
			src.dismantle_stage = 2
			new /obj/item/sheet/steel/reinforced(src.loc)
			src.build_icon()

		else if (issnippingtool(W) && src.dismantle_stage == 2)
			if (!(status & NOPOWER))
				if (src.shock(user,100))
					return
			user.visible_message("<b>[user]</b> disconnects [src]'s cabling.")
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
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
			src.shock(user,100)
			src.build_icon()

		else if (istype(W,/obj/item/reagent_containers/glass))
			if (W.cant_drop)
				boutput(user, "<span class='alert'>You cannot put the [W] into [src]!</span>")
				return
			if (src.beaker)
				boutput(user, "<span class='alert'>There's already a receptacle in the machine. You need to remove it first.</span>")
			else
				boutput(user, "<span class='notice'>You insert [W].</span>")
				W.set_loc(src)
				src.beaker = W
				if (user && W)
					user.u_equip(W)
					W.dropped(user)

		else if (istype(W,/obj/item/disk/data/floppy))
			if (src.manudrive)
				boutput(user, "<span class='alert'>You swap out the disk in the manufacturer with a different one.</span>")
				src.eject_manudrive(user)
				src.manudrive = W
				if (user && W)
					user.u_equip(W)
					W.dropped(user)
				for (var/datum/computer/file/manudrive/MD in src.manudrive.root.contents)
					src.drive_recipes = MD.drivestored
			else
				boutput(user, "<span class='notice'>You insert [W].</span>")
				W.set_loc(src)
				src.manudrive = W
				if (user && W)
					user.u_equip(W)
					W.dropped(user)
				for (var/datum/computer/file/manudrive/MD in src.manudrive.root.contents)
					src.drive_recipes = MD.drivestored


		else if (istype(W,/obj/item/sheet/) || (istype(W,/obj/item/cable_coil/ || (istype(W,/obj/item/raw_material/ )))))
			boutput(user, "<span class='alert'>The fabricator rejects the [W]. You'll need to refine them in a reclaimer first.</span>")
			playsound(src.loc, src.sound_grump, 50, 1)
			return

		else if (istype(W, src.base_material_class) && src.accept_loading(user))
			user.visible_message("<span class='notice'>[user] loads [W] into [src].</span>", "<span class='notice'>You load [W] into [src].</span>")
			src.load_item(W,user)

		else if (src.panel_open && (issnippingtool(W) || ispulsingtool(W)))
			src.Attackhand(user)
			return

		else if(scan_card(W))
			return

		else
			..()
			user.lastattacked = src
			attack_particle(user,src)
			hit_twitch(src)
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

	proc/scan_card(obj/item/I)
		if (istype(I, /obj/item/device/pda2))
			var/obj/item/device/pda2/P = I
			if(P.ID_card)
				I = P.ID_card
		if (istype(I, /obj/item/card/id))
			var/obj/item/card/id/ID = I
			boutput(usr, "<span class='notice'>You swipe the ID card in the card reader.</span>")
			var/datum/db_record/account = null
			account = FindBankAccountByName(ID.registered)
			if(account)
				var/enterpin = usr.enter_pin("Card Reader")
				if (enterpin == ID.pin)
					boutput(usr, "<span class='notice'>Card authorized.</span>")
					src.scan = ID
					return TRUE
				else
					boutput(usr, "<span class='alert'>Pin number incorrect.</span>")
					src.scan = null
			else
				boutput(usr, "<span class='alert'>No bank account associated with this ID found.</span>")
				src.scan = null
		return FALSE

	mouse_drop(over_object, src_location, over_location)
		if(!isliving(usr))
			boutput(usr, "<span class='alert'>Only living mobs are able to set the manufacturer's output target.</span>")
			return

		if(BOUNDS_DIST(over_object, src) > 0)
			boutput(usr, "<span class='alert'>The manufacturing unit is too far away from the target!</span>")
			return

		if(BOUNDS_DIST(over_object, usr) > 0)
			boutput(usr, "<span class='alert'>You are too far away from the target!</span>")
			return

		if (istype(over_object,/obj/storage/crate/))
			var/obj/storage/crate/C = over_object
			if (C.locked || C.welded)
				boutput(usr, "<span class='alert'>You can't use a currently unopenable crate as an output target.</span>")
			else
				src.output_target = over_object
				boutput(usr, "<span class='notice'>You set the manufacturer to output to [over_object]!</span>")

		else if (istype(over_object,/obj/storage/cart/))
			var/obj/storage/cart/C = over_object
			if (C.locked || C.welded)
				boutput(usr, "<span class='alert'>You can't use a currently unopenable cart as an output target.</span>")
			else
				src.output_target = over_object
				boutput(usr, "<span class='notice'>You set the manufacturer to output to [over_object]!</span>")

		else if (istype(over_object,/obj/table/) || istype(over_object,/obj/rack/))
			var/obj/O = over_object
			src.output_target = O.loc
			boutput(usr, "<span class='notice'>You set the manufacturer to output on top of [O]!</span>")

		else if (istype(over_object,/turf/simulated/floor/) || istype(over_object,/turf/unsimulated/floor/))
			src.output_target = over_object
			boutput(usr, "<span class='notice'>You set the manufacturer to output to [over_object]!</span>")

		else
			boutput(usr, "<span class='alert'>You can't use that as an output target.</span>")
		return

	MouseDrop_T(atom/movable/O as mob|obj, mob/user)
		if (!O || !user)
			return

		if(!isliving(user))
			boutput(user, "<span class='alert'>Only living mobs are able to use the manufacturer's quick-load feature.</span>")
			return

		if (!istype(O,/obj/))
			boutput(user, "<span class='alert'>You can't quick-load that.</span>")
			return

		if(BOUNDS_DIST(O, user) > 0)
			boutput(user, "<span class='alert'>You are too far away!</span>")
			return


		if (istype(O, /obj/item/paper/manufacturer_blueprint))
			src.Attackby(O, user)

		if (istype(O, /obj/storage/crate/) || istype(O, /obj/storage/cart/) && src.accept_loading(user,1))
			if (O:welded || O:locked)
				boutput(user, "<span class='alert'>You cannot load from a container that cannot open!</span>")
				return

			user.visible_message("<span class='notice'>[user] uses [src]'s automatic loader on [O]!</span>", "<span class='notice'>You use [src]'s automatic loader on [O].</span>")
			var/amtload = 0
			for (var/obj/item/M in O.contents)
				if (!istype(M,src.base_material_class))
					continue
				src.load_item(M)
				amtload++
			if (amtload) boutput(user, "<span class='notice'>[amtload] materials loaded from [O]!</span>")
			else boutput(user, "<span class='alert'>No material loaded!</span>")

		else if (isitem(O) && src.accept_loading(user,1))
			user.visible_message("<span class='notice'>[user] begins quickly stuffing materials into [src]!</span>")
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
			boutput(user, "<span class='notice'>You finish stuffing materials into [src]!</span>")

		else ..()

		src.updateUsrDialog()

	receive_signal(datum/signal/signal)
		if (!signal || signal.encryption || signal.transmission_method != TRANSMISSION_WIRE)
			return

		var/sender = signal.data["sender"]
		if (!sender) // important for replies etc.
			return

		var/address = signal.data["address_1"]
		if (address != src.net_id) // ping or they're not talking to us entirely
			if (address == "ping")
				var/list/ping_data = list()
				ping_data["address_1"] = sender
				ping_data["netid"] = src.net_id
				ping_data["sender"] = src.net_id
				ping_data["command"] = "ping_reply"
				ping_data["device"] = src.device_tag
				post_signal(ping_data)

			return

		var/command = signal.data["command"]
		if (!command) // not telling us to do anything
			return

		switch(command)
			if ("help")
				var/list/help = list()
				help["address_1"] = sender
				help["sender"] = src.net_id
				help["command"] = "help"
				if (!signal.data["topic"])
					help["description"] = "[src.name] - Allows the manufacturing of various goods"
					help["topics"] = "status,queue,add,remove,clear,speed,resume,pause,repeat"

				else
					switch (signal.data["topic"])
						if ("status")
							help["description"] = "Returns data about the manufacturers current state."

						if ("queue")
							help["description"] = "Returns the manufacturers entire queue."

						if ("add")
							help["description"] = "Appends the item with the corresponding name to the queue."
							help["args"] = "data"

						if ("remove")
							help["description"] = "Removes the item at the corresponding index."
							help["args"] = "data"

						if ("clear")
							help["description"] = "Clears the entire queue."

						if ("speed")
							help["description"] = "Sets the manufacturers speed to the included state."
							help["args"] = "data"

						if ("resume")
							help["description"] = "Resumes building the current item."

						if ("pause")
							help["description"] = "Pauses bulding the current item."

						if ("repeat")
							help["description"] = "Sets whether or not the manufacturer is repeating building the current item based on the included state."
							help["args"] = "data"

				post_signal(help)
				return

			if ("status")
				post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "status", "data" = "mode=[src.mode]&speed=[src.speed]&timeleft=[src.time_left]&repeat=[src.repeat]"))
				return

			if ("queue")
				var/return_queue
				for (var/datum/manufacture/I in src.queue)
					return_queue += I.name + ","

				post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "queue", "data" = return_queue))
				return

			if ("add")
				var/item_name = signal.data["data"]
				if (!item_name)
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ERR#BADITEMNAME"))
					return

				var/datum/manufacture/item_bp
				for (var/datum/manufacture/bp in src.available + src.download + src.drive_recipes + (src.hacked ? src.hidden : null))
					if (bp.name == item_name)
						item_bp = bp
						break

				if (!item_bp)
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ERR#NOITEMBLUEPRINT"))
					return

				if (free_resource_amt > 0) // We do this here instead of on New() as a tiny optimization to keep some overhead off of map load - Also required for packets
					claim_free_resources()

				if (!check_enough_materials(item_bp))
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ERR#NOMATERIALS"))
					return

				else if (src.queue.len >= MAX_QUEUE_LENGTH)
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ERR#QUEUEFULL"))
					return

				else
					src.queue += item_bp
					src.begin_work(1)
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ACK#APPENDED"))

			if ("clear")
				var/Qcounter = 1
				for (var/datum/manufacture/M in src.queue)
					if (Qcounter == 1 && src.mode == "working") continue
					src.queue -= src.queue[Qcounter]

				if (src.mode == "halt")
					src.manual_stop = 0
					src.error = null
					src.mode = "ready"
					src.build_icon()

				post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ACK#CLEARED"))

			if ("remove")
				var/operation = text2num_safe(signal.data["data"])
				if (!isnum(operation) || src.queue.len < 1 || operation > src.queue.len)
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ERR#BADOPERATION"))
					return

				if(world.time < last_queue_op + 5)
					return

				else
					last_queue_op = world.time

				src.queue -= src.queue[operation]
				begin_work()
				post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ACK#REMOVED"))

			if ("resume")
				if (src.queue.len < 1)
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ERR#NOQUEUE"))
					return

				if (!check_enough_materials(src.queue[1]))
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ERR#NOMATERIALS"))
					return

				else
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ACK#RESUMED"))
					src.begin_work(0)

			if ("pause")
				src.mode = "halt"
				src.build_icon()
				if (src.action_bar)
					src.action_bar.interrupt(INTERRUPT_ALWAYS)

				post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ACK#PAUSED"))

			if ("repeat")
				if (!signal.data["data"])
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ERR#BADSTATE"))
					return

				var/state = text2num_safe(signal.data["data"])
				if (isnull(state))
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ACK#BADSTATE"))
					return

				if (state)
					src.repeat = 1
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ACK#REPEAT"))

				else
					src.repeat = 0
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ACK#NOREPEAT"))

			if ("speed")
				var/upperbound = src.hacked ? 5 : 3
				var/given_speed = text2num(signal.data["data"])
				if (src.mode == "working")
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ERR#WORKING"))
					return

				if (isnull(given_speed) || given_speed < 1 || given_speed > upperbound)
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ERR#BADSPEED"))
					return

				src.speed = given_speed
				post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ACK#SPEEDSET"))

		src.updateUsrDialog()

	proc/post_signal(var/list/data)
		var/datum/signal/new_signal = get_free_signal()
		new_signal.source = src
		new_signal.transmission_method = TRANSMISSION_WIRE
		new_signal.data = data
		src.link.post_signal(src, new_signal)

	proc/accept_loading(mob/user,allow_silicon)
		if (!user)
			return FALSE
		if (src.status & BROKEN || src.status & NOPOWER)
			return FALSE
		if (src.dismantle_stage > 0)
			return FALSE
		if (!isliving(user))
			return FALSE
		if (issilicon(user) && !allow_silicon)
			return FALSE
		var/mob/living/L = user
		if (L.stat || L.transforming)
			return FALSE
		return TRUE

	proc/isWireColorCut(wireColor)
		var/wireFlag = APCWireColorToFlag[wireColor]
		return ((src.wires & wireFlag) == 0)

	proc/isWireCut(wireIndex)
		var/wireFlag = APCIndexToFlag[wireIndex]
		return ((src.wires & wireFlag) == 0)

	proc/cut(mob/user, wireColor)
		var/wireFlag = APCWireColorToFlag[wireColor]
		var/wireIndex = APCWireColorToIndex[wireColor]
		src.wires &= ~wireFlag
		switch(wireIndex)
			if(WIRE_EXTEND)
				src.hacked = FALSE
			if(WIRE_SHOCK)
				src.electrified = -1
			if(WIRE_MALF)
				src.malfunction = TRUE
			if(WIRE_POWER)
				if(!(src.status & BROKEN || src.status & NOPOWER))
					src.shock(user, 100)
					src.status |= NOPOWER

	proc/mend(mob/user, wireColor)
		var/wireFlag = APCWireColorToFlag[wireColor]
		var/wireIndex = APCWireColorToIndex[wireColor] //not used in this function
		src.wires |= wireFlag
		switch(wireIndex)
			if(WIRE_SHOCK)
				src.electrified = 0
			if(WIRE_MALF)
				src.malfunction = FALSE
			if(WIRE_POWER)
				if (!(src.status & BROKEN) && (src.status & NOPOWER))
					src.shock(user, 100)
					src.status &= ~NOPOWER

	proc/pulse(mob/user, wireColor)
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
					src.shock(user, 100)

	proc/shock(mob/user, prb)
		if(src.status & (BROKEN|NOPOWER))
			return FALSE

		var/netnum = FALSE
		for(var/turf/T in range(1, user))
			for(var/obj/cable/C in T.contents)
				netnum = C.netnum
				break
			if (netnum)
				break

		if (!netnum)
			return FALSE
		if (!IN_RANGE(src, user, 2))
			return FALSE
		if (src.electrocute(user,prb,netnum))
			return TRUE
		else
			return FALSE

	proc/add_schematic(schematic_path, add_to_list = "available")
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
			return FALSE

		if (pattern == "ALL") // anything at all
			return TRUE
		if (pattern == "ORG|RUB")
			return mat.material_flags & MATERIAL_RUBBER || mat.material_flags & MATERIAL_ORGANIC
		if (pattern == "RUB")
			return mat.material_flags & MATERIAL_RUBBER
		else if (copytext(pattern, 4, 5) == "-") // wildcard
			var/firstpart = copytext(pattern, 1, 4)
			var/secondpart = text2num_safe(copytext(pattern, 5))
			switch(firstpart)
				// this was kind of thrown together in a panic when i felt shitty so if its horrible
				// go ahead and clean it up a bit
				if ("MET")

					if (mat.material_flags & MATERIAL_METAL)
						// maux hardness = 15
						// bohr hardness = 33
						switch(secondpart)
							if(2)
								return mat.getProperty("hard") * 2 + mat.getProperty("density") >= 10
							if(3 to INFINITY)
								return mat.getProperty("hard") * 2 + mat.getProperty("density") >= 15
							else
								return TRUE
				if ("CRY")
					if (mat.material_flags & MATERIAL_CRYSTAL)

						switch(secondpart)
							if(2)
								return mat.getProperty("density") >= 7
							else
								return TRUE
				if ("REF")
					return (mat.getProperty("reflective") >= 6)
				if ("CON")
					switch(secondpart)
						if(2)
							return (mat.getProperty("electrical") >= 8)
						else
							return (mat.getProperty("electrical") >= 6)
				if ("INS")
					switch(secondpart)
						if(2)
							return mat.getProperty("electrical") <= 2 && (mat.material_flags & (MATERIAL_CLOTH | MATERIAL_RUBBER))
						else
							return mat.getProperty("electrical") <= 4 && (mat.material_flags & (MATERIAL_CLOTH | MATERIAL_RUBBER))
				if ("DEN")
					switch(secondpart)
						if(2)
							return mat.getProperty("density") >= 6
						else
							return mat.getProperty("density") >= 4
				if ("POW")
					if (mat.material_flags & MATERIAL_ENERGY)
						switch(secondpart)
							if(3)
								return mat.getProperty("radioactive") >= 5 //soulsteel and erebite basically
							if(2)
								return mat.getProperty("radioactive") >= 2
							else
								return TRUE
				if ("FAB")
					return mat.material_flags & (MATERIAL_CLOTH | MATERIAL_RUBBER | MATERIAL_ORGANIC)
		else if (pattern == mat.mat_id) // specific material id
			return TRUE
		return FALSE

	proc/get_materials_needed(datum/manufacture/M) // returns associative list of item_paths with the mat_ids they're gonna use; does not guarantee all item_paths are satisfied
		var/list/mats_used = list()
		var/list/mats_available = src.resource_amounts.Copy()

		for (var/i in 1 to M.item_paths.len)
			var/pattern = M.item_paths[i]
			var/amount = M.item_amounts[i]
			for (var/mat_id in mats_available)
				if (mats_available[mat_id] < amount)
					continue
				var/datum/material/mat = getMaterial(mat_id)
				if (match_material_pattern(pattern, mat)) // TODO: refactor proc cuz this is bad
					mats_used[pattern] = mat_id
					mats_available[mat_id] -= amount
					break

		return mats_used

	proc/check_enough_materials(datum/manufacture/M)
		var/list/mats_used = get_materials_needed(M)
		if (mats_used.len == M.item_paths.len) // we have enough materials, so return the materials list, else return null
			return mats_used

	proc/remove_materials(datum/manufacture/M)
		for (var/i = 1 to M.item_paths.len)
			var/pattern = M.item_paths[i]
			var/mat_id = src.materials_in_use[pattern]
			if (mat_id)
				var/amount = M.item_amounts[i]
				src.update_resource_amount(mat_id, -amount)
				for (var/obj/item/I in src.contents)
					if (I.material && istype(I, src.base_material_class) && I.material.mat_id == mat_id)
						var/target_amount = round(src.resource_amounts[mat_id] / 10)
						if (!target_amount)
							src.contents -= I
							qdel(I)
						else if (I.amount != target_amount)
							I.change_stack_amount(-(I.amount - target_amount))
						break

	proc/begin_work(new_production = TRUE)
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
			src.visible_message("<span class='alert'>[src] emits an angry buzz!</span>")
			playsound(src.loc, src.sound_grump, 50, 1)
			src.build_icon()
			return

		var/datum/manufacture/M = src.queue[1]
		//Wire: Fix for href exploit creating arbitrary items
		if (!(M in src.available + src.hidden + src.drive_recipes + src.download))
			src.mode = "halt"
			src.error = "Corrupted entry purged from production queue."
			src.queue -= src.queue[1]
			src.visible_message("<span class='alert'>[src] emits an angry buzz!</span>")
			playsound(src.loc, src.sound_grump, 50, 1)
			src.build_icon()
			return

		src.error = null

		if (src.malfunction && prob(40))
			src.flip_out()

		if (new_production)
			var/list/mats_used = check_enough_materials(M)

			if (!mats_used)
				src.mode = "halt"
				src.error = "Insufficient usable materials to continue queue production."
				src.visible_message("<span class='alert'>[src] emits an angry buzz!</span>")
				playsound(src.loc, src.sound_grump, 50, 1)
				src.build_icon()
				return
			else
				src.materials_in_use = mats_used

			// speed/power usage
			// spd   time    new     old (1500 * speed * 1.5)
			// 1:    10.0s     750   2250
			// 2:     5.0s    3000   4500
			// 3:     3.3s    6750   6750
			// 4:     2.5s   12000   9000
			// 5:     2.0s   18750  11250
			src.active_power_consumption = 750 * src.speed ** 2
			src.time_left = M.time
			if (src.malfunction)
				src.active_power_consumption += 3000
				src.time_left += rand(2,6)
				src.time_left *= 1.5
			src.time_left /= src.speed

		if(src.manudrive)
			if(src.queue[1] in src.drive_recipes)
				var/obj/item/disk/data/floppy/ManuD = src.manudrive
				for (var/datum/computer/file/manudrive/MD in ManuD.root.contents)
					if(MD.fablimit == 0)
						src.mode = "halt"
						src.error = "The inserted ManuDrive is unable to operate further."
						src.queue = list()
						return
					else
						MD.fablimit -= 1

		playsound(src.loc, src.sound_beginwork, 50, 1, 0, 3)
		src.mode = "working"
		src.build_icon()

		src.action_bar = actions.start(new/datum/action/bar/manufacturer(src, src.time_left), src)


	proc/output_loop(datum/manufacture/M)

		if (!istype(M,/datum/manufacture/))
			return

		if (M.item_outputs.len <= 0)
			return
		var/mcheck = check_enough_materials(M)
		if(mcheck)
			var/make = clamp(M.create, 0, src.output_cap)
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

			src.remove_materials(M)
		else
			src.mode = "halt"
			src.error = "Insufficient usable materials to continue queue production."
			src.visible_message("<span class='alert'>[src] emits an angry buzz!</span>")
			playsound(src.loc, src.sound_grump, 50, 1)
			src.build_icon()

		return

	proc/dispense_product(product,datum/manufacture/M)
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
				src.visible_message("<b>[src]</b> says, \"[product]\"")

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

	proc/flip_out()
		if (status & BROKEN || status & NOPOWER || !src.malfunction)
			return
		animate_shake(src,5,rand(3,8),rand(3,8))
		src.visible_message("<span class='alert'>[src] makes [pick(src.text_flipout_adjective)] [pick(src.text_flipout_noun)]!</span>")
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
					src.active_power_consumption *= 2
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

		if (src.panel_open)
			src.panel_sprite.icon_state = "fab-panel"
			src.UpdateOverlays(src.panel_sprite, "panel")
		else
			src.UpdateOverlays(null, "panel")

	proc/build_material_list()
		var/list/dat = list()
		dat += {"
<table class="outline" style="width: 100%;">
	<thead>
		<tr><th colspan='2'>Loaded Materials</th></tr>
	</thead>
	<tbody>
		"}
		for(var/mat_id in src.resource_amounts)
			var/datum/material/mat = getMaterial(mat_id)
			dat += {"
		<tr>
			<td><a href='?src=\ref[src];eject=[mat_id]' class='buttonlink'>&#9167;</a>  [mat]</td>
			<td class='r'>[src.resource_amounts[mat_id]/10]</td>
		</tr>
			"}
		if (dat.len == 1)
			dat += {"
		<tr>
			<td colspan='2' class='c'>No materials loaded.</td>
		</tr>
			"}

		if (src.manudrive)
			dat += {"
		<tr><th colspan='2'>Manufacturer drive</th></tr>
			"}

			dat += {"
		<tr><td colspan='2'><a href='?src=\ref[src];ejectmanudrive=\ref[src]' class='buttonlink'>&#9167;</a> [src.manudrive.name]</td></tr>
			"}

			var/obj/item/disk/data/floppy/ManuD = src.manudrive
			for (var/datum/computer/file/manudrive/MD in ManuD.root.contents)
				if(MD.fablimit >= 0)
					dat += {"
				<tr>
					<td>ManuDrive Usages</td>
					<td class='r'>[MD.fablimit]</td>
				</tr>
					"}

		if (src.reagents.total_volume > 0)
			dat += {"
		<tr><th colspan='2'>Loaded Reagents</th></tr>
			"}
			for(var/current_id in src.reagents.reagent_list)
				var/datum/reagent/current_reagent = src.reagents.reagent_list[current_id]
				dat += {"
		<tr>
			<td><a href='?src=\ref[src];flush=[current_reagent.name]'>[current_reagent.name]</a></td>
			<td class='r'>[current_reagent.volume] units</td>
		</tr>
				"}

		if (src.beaker)
			dat += {"
		<tr><th colspan='2'>Container</th></tr>
			"}

			dat += {"
		<tr><td colspan='2'><a href='?src=\ref[src];ejectbeaker=\ref[src.beaker]' class='buttonlink'>&#9167;</a> [src.beaker.name]<br>([round(src.beaker.reagents.total_volume)]/[src.beaker.reagents.maximum_volume])</td></tr>
		<tr><td class='c'>
			"}
			if (src.reagents.total_volume && src.beaker.reagents.total_volume < src.beaker.reagents.maximum_volume)
				dat += {"
				<a href='?src=\ref[src];transto=\ref[src.beaker]'>Transfer<br>Machine &rarr; Container</a>
				"}
			else
				dat += {"
				&nbsp;
				"}

			dat += {"
		</td><td class='c'>
			"}

			if (src.beaker.reagents.total_volume > 0)
				dat += {"
				<a href='?src=\ref[src];transfrom=\ref[src.beaker]'>Transfer<br>Container &rarr; Machine</a>
				"}

			dat += {"
		</td></tr>
			"}
		dat += {"
	</tbody>
</table>
			"}

		return dat.Join()

	proc/build_control_panel(mob/user as mob)
		var/list/dat = list()

		var/list/speed_opts = list()
		for (var/i in 1 to (src.hacked ? 5 : 3))
			speed_opts += "<a href='?src=\ref[src];speed=[i]' class='buttonlink' style='[i == src.speed ? "font-weight: bold; background: #6c6;" : ""]'>[i]</a>"

		if (src.speed > (src.hacked ? 5 : 3))
			// sometimes people get these set to wacky values
			speed_opts += "<a href='?src=\ref[src];speed=[src.speed]' class='buttonlink' style='font-weight: bold; background: #c66;'>[src.speed]</a>"

		dat += {"
			<br>
			<table style='width: 100%:'>
				<thead><tr><th style='width: 50%:'>Speed</th><th style='width: 50%:'>Repeat</th></tr></thead>
				<tbody><tr>
					<td class='c'>[speed_opts.Join(" ")]</td>
					<td class='c'><a href='?src=\ref[src];repeat=1'>[src.repeat ? "Yes" : "No"]</a></td>
				</tr></tbody>
			</table>

			"}
		if (src.error)
			dat += "<br><b>ERROR: [src.error]</b><br>"

		var/queue_num = 1
		for(var/datum/manufacture/A in src.queue)

			var/time_number = 0
			var/remove_link = ""
			var/pause_link = ""
			if (queue_num == 1)
				pause_link = (src.mode == "working" ? "<a href='?src=\ref[src];pause=1' class='buttonlink'>&#9208; Pause</a>" : "<a href='?src=\ref[src];continue=1' class='buttonlink'>&#57914; Resume</a>") + "<br>"
			else
				pause_link = ""

			time_number = A.time && src.speed ? round(A.time / src.speed / 10, 0.1) : "??"

			if (src.mode != "working" || queue_num != 1)
				remove_link = "<a href='?src=\ref[src];removefromQ=[queue_num]' class='buttonlink'>&#128465; Remove</a>"
			else
				// shut up
				remove_link = "&#8987; Working..."

			var/icon_text = "<img class='icon'>"
			if (A.item_outputs)
				var/icon_rsc = getItemIcon(A.item_outputs[1], C = user.client)
				// user << browse_rsc(browse_item_icons[icon_rsc], icon_rsc)
				icon_text = "<img class='icon' src='[icon_rsc]'>"

			if (istype(A, /datum/manufacture/mechanics))
				var/datum/manufacture/mechanics/F = A
				var/icon_rsc = getItemIcon(F.frame_path, C = user.client)
				// user << browse_rsc(browse_item_icons[icon_rsc], icon_rsc)
				icon_text = "<img class='icon' src='[icon_rsc]'>"


			dat += {"
		<div class='queue'>
			[icon_text]
			<strong>[A.name]</strong>
			<br>[time_number] sec.
		</div><div style='display: inline-block; vertical-align: middle;'>
		[pause_link]
		[remove_link]
		</div>
		<br>
		"}

			queue_num++

		return dat.Join()

	proc/eject_manudrive(mob/living/user)
		src.drive_recipes = null
		user.put_in_hand_or_drop(manudrive)
		src.manudrive = null

	proc/load_item(obj/item/O, mob/living/user)
		if (!O)
			return

		if (user)
			user.u_equip(O)
			O.dropped(user)

		if (istype(O, src.base_material_class) && O.material)
			var/obj/item/material_piece/P = O
			for(var/obj/item/material_piece/M in src.contents)
				if (istype(M, P) && M.material && isSameMaterial(M.material, P.material))
					M.change_stack_amount(P.amount)
					src.update_resource_amount(M.material.mat_id, P.amount * 10)
					qdel(P)
					return
			src.update_resource_amount(P.material.mat_id, P.amount * 10)

		O.set_loc(src)

	proc/take_damage(damage_amount = 0)
		if (!damage_amount)
			return
		src.health = clamp(src.health - damage_amount, 0, 100)
		if (damage_amount > 0)
			playsound(src.loc, src.sound_damaged, 50, 2)
			if (src.health == 0)
				src.visible_message("<span class='alert'><b>[src] is destroyed!</b></span>")
				playsound(src.loc, src.sound_destroyed, 50, 2)
				robogibs(src.loc, null)
				qdel(src)
				return
			if (src.health <= 70 && !src.malfunction && prob(33))
				src.malfunction = TRUE
				src.flip_out()
			if (src.malfunction && prob(40))
				src.flip_out()
			if (src.health <= 25 && !(src.status & BROKEN))
				src.visible_message("<span class='alert'><b>[src] breaks down and stops working!</b></span>")
				src.status |= BROKEN
		else
			if (src.health >= 60 && src.status & BROKEN)
				src.visible_message("<span class='alert'><b>[src] looks like it can function again!</b></span>")
				status &= ~BROKEN

		src.build_icon()

	proc/update_resource_amount(mat_id, amt)
		src.resource_amounts[mat_id] = max(src.resource_amounts[mat_id] + amt, 0)

	proc/claim_free_resources()
		if (src.deconstruct_flags & DECON_BUILT)
			free_resource_amt = 0
		else if (free_resources.len && free_resource_amt > 0)
			for (var/X in src.free_resources)
				if (ispath(X))
					var/obj/item/material_piece/P = new X
					P.set_loc(src)
					if (free_resource_amt > 1)
						P.change_stack_amount(free_resource_amt - P.amount)
					src.update_resource_amount(P.material.mat_id, free_resource_amt * 10)
			free_resource_amt = 0
		else
			logTheThing(LOG_DEBUG, null, "<b>obj/manufacturer:</b> [src.name]-[src.type] empty free resources list!")

	proc/get_output_location(atom/A)
		if (!src.output_target)
			return src.loc

		if (BOUNDS_DIST(src.output_target, src) > 0)
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

		else if (istype(src.output_target,/turf/simulated/floor/) || istype(src.output_target,/turf/unsimulated/floor/))
			return src.output_target

		else
			return src.loc


// Fabricator Defines

/obj/machinery/manufacturer/general
	name = "general manufacturer"
	supplemental_desc = "This one produces tools and other hardware, as well as general-purpose items like replacement lights."
	free_resource_amt = 5
	free_resources = list(/obj/item/material_piece/steel,
		/obj/item/material_piece/copper,
		/obj/item/material_piece/glass)
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
		/datum/manufacture/rods2,
		/datum/manufacture/glass,
		/datum/manufacture/glassR,
		/datum/manufacture/atmos_can,
		/datum/manufacture/player_module,
		/datum/manufacture/cable,
		/datum/manufacture/powercell,
		/datum/manufacture/powercellE,
		/datum/manufacture/powercellC,
		/datum/manufacture/powercellH,
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
#ifdef UNDERWATER_MAP
		/datum/manufacture/flippers,
#endif
		/datum/manufacture/breathmask,
#ifdef MAP_OVERRIDE_NADIR
		/datum/manufacture/nanoloom,
		/datum/manufacture/nanoloom_cart,
#endif
		/datum/manufacture/fluidcanister,
		/datum/manufacture/meteorshieldgen,
		/datum/manufacture/shieldgen,
		/datum/manufacture/doorshieldgen,
		/datum/manufacture/patch,
		/datum/manufacture/saxophone,
		/datum/manufacture/trumpet)
	hidden = list(/datum/manufacture/RCDammo,
		/datum/manufacture/RCDammomedium,
		/datum/manufacture/RCDammolarge,
		/datum/manufacture/bottle,
		/datum/manufacture/vuvuzela,
		/datum/manufacture/harmonica,
		/datum/manufacture/bikehorn,
		/datum/manufacture/bullet_22,
		/datum/manufacture/bullet_smoke,
		/datum/manufacture/stapler,
		/datum/manufacture/bagpipe,
		/datum/manufacture/whistle)

/obj/machinery/manufacturer/robotics
	name = "robotics fabricator"
	supplemental_desc = "This one produces robot parts, cybernetic organs, and other robotics-related equipment."
	icon_state = "fab-robotics"
	icon_base = "robotics"
	free_resource_amt = 5
	free_resources = list(/obj/item/material_piece/steel,
		/obj/item/material_piece/copper,
		/obj/item/material_piece/glass)

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
		/datum/manufacture/robo_head_screen,
		/datum/manufacture/robo_module,
		/datum/manufacture/cyberheart,
		/datum/manufacture/cybereye,
		/datum/manufacture/cybereye_meson,
		/datum/manufacture/cybereye_spectro,
		/datum/manufacture/cybereye_prodoc,
		/datum/manufacture/cybereye_camera,
		/datum/manufacture/shell_frame,
		/datum/manufacture/ai_interface,
		/datum/manufacture/latejoin_brain,
		/datum/manufacture/shell_cell,
		/datum/manufacture/cable,
		/datum/manufacture/powercell,
		/datum/manufacture/powercellE,
		/datum/manufacture/powercellC,
		/datum/manufacture/powercellH,
		/datum/manufacture/crowbar,
		/datum/manufacture/wrench,
		/datum/manufacture/screwdriver,
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
		/datum/manufacture/digbot,
		/datum/manufacture/visor,
		/datum/manufacture/deafhs,
		/datum/manufacture/robup_jetpack,
		/datum/manufacture/robup_healthgoggles,
		/datum/manufacture/robup_sechudgoggles,
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
		/datum/manufacture/implant_antirot,
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
		/datum/manufacture/glass,
		/datum/manufacture/asimov_laws,
		/datum/manufacture/borg_linker)

	hidden = list(/datum/manufacture/flash,
		/datum/manufacture/cybereye_thermal,
		/datum/manufacture/cybereye_laser,
		/datum/manufacture/cyberbutt,
		/datum/manufacture/robup_expand,
		/datum/manufacture/cardboard_ai,
		/datum/manufacture/corporate_laws,
		/datum/manufacture/robocop_laws)

/obj/machinery/manufacturer/medical
	name = "medical fabricator"
	supplemental_desc = "This one produces medical equipment and sterile clothing."
	icon_state = "fab-med"
	icon_base = "med"
	free_resource_amt = 2
	free_resources = list(/obj/item/material_piece/steel,
		/obj/item/material_piece/copper,
		/obj/item/material_piece/glass,
		/obj/item/material_piece/cloth/cottonfabric)

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
		/datum/manufacture/penlight,
		/datum/manufacture/stethoscope,
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
		/datum/manufacture/eyepatch,
		/datum/manufacture/blindfold,
		/datum/manufacture/muzzle,
		/datum/manufacture/stress_ball,
		/datum/manufacture/body_bag,
		/datum/manufacture/implanter,
		/datum/manufacture/implant_health,
		/datum/manufacture/implant_antirot,
		/datum/manufacture/floppydisk,
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
		/datum/manufacture/empty_kit,
		/datum/manufacture/rods2,
		/datum/manufacture/metal,
		/datum/manufacture/glass
	)

	hidden = list(/datum/manufacture/cyberheart,
	/datum/manufacture/cybereye)

/obj/machinery/manufacturer/science
	name = "science fabricator"
	supplemental_desc = "This one produces science equipment for experiments as well as expeditions."
	icon_state = "fab-sci"
	icon_base = "sci"
	free_resource_amt = 2
	free_resources = list(/obj/item/material_piece/steel,
		/obj/item/material_piece/copper,
		/obj/item/material_piece/glass,
		/obj/item/material_piece/cloth/cottonfabric)
	available = list(
		/datum/manufacture/flashlight,
		/datum/manufacture/gps,
		/datum/manufacture/crowbar,
		/datum/manufacture/extinguisher,
		/datum/manufacture/welder,
		/datum/manufacture/patch,
		/datum/manufacture/atmos_can,
		/datum/manufacture/artifactforms,
		/datum/manufacture/fluidcanister,
		/datum/manufacture/spectrogoggles,
		/datum/manufacture/reagentscanner,
		/datum/manufacture/dropper,
		/datum/manufacture/mechdropper,
		/datum/manufacture/biosuit,
		/datum/manufacture/labcoat,
		/datum/manufacture/jumpsuit_white,
		/datum/manufacture/patient_gown,
		/datum/manufacture/blindfold,
		/datum/manufacture/muzzle,
		/datum/manufacture/gasmask,
		/datum/manufacture/latex_gloves,
		/datum/manufacture/shoes_white,
		/datum/manufacture/rods2,
		/datum/manufacture/metal,
		/datum/manufacture/glass)

	hidden = list(/datum/manufacture/scalpel,
		/datum/manufacture/circular_saw,
		/datum/manufacture/surgical_scissors,
		/datum/manufacture/hemostat,
		/datum/manufacture/suture,
		/datum/manufacture/stapler,
		/datum/manufacture/surgical_spoon
	)

/obj/machinery/manufacturer/mining
	name = "mining fabricator"
	supplemental_desc = "This one produces mining equipment like concussive charges and powered tools."
	icon_state = "fab-mining"
	icon_base = "mining"
	free_resource_amt = 2
	free_resources = list(/obj/item/material_piece/steel,
		/obj/item/material_piece/copper,
		/obj/item/material_piece/glass)
	available = list(/datum/manufacture/pick,
		/datum/manufacture/powerpick,
		/datum/manufacture/blastchargeslite,
		/datum/manufacture/blastcharges,
		/datum/manufacture/powerhammer,
		/datum/manufacture/drill,
		/datum/manufacture/conc_gloves,
		/datum/manufacture/digbot,
		/datum/manufacture/jumpsuit,
		/datum/manufacture/shoes,
		/datum/manufacture/breathmask,
		/datum/manufacture/engspacesuit,
#ifdef UNDERWATER_MAP
		/datum/manufacture/engdivesuit,
		/datum/manufacture/flippers,
#endif
		/datum/manufacture/industrialarmor,
		/datum/manufacture/industrialboots,
		/datum/manufacture/powercell,
		/datum/manufacture/powercellE,
		/datum/manufacture/powercellC,
		/datum/manufacture/powercellH,
		/datum/manufacture/ore_scoop,
		/datum/manufacture/oresatchel,
		/datum/manufacture/oresatchelL,
		/datum/manufacture/microjetpack,
		/datum/manufacture/jetpack,
		/datum/manufacture/geoscanner,
		/datum/manufacture/geigercounter,
		/datum/manufacture/eyes_meson,
		/datum/manufacture/flashlight,
		/datum/manufacture/ore_accumulator,
		/datum/manufacture/rods2,
		/datum/manufacture/metal,
#ifdef UNDERWATER_MAP
		/datum/manufacture/jetpackmkII,
#endif
#ifndef UNDERWATER_MAP
		/datum/manufacture/mining_magnet
#endif
		)

	hidden = list(/datum/manufacture/RCD,
		/datum/manufacture/RCDammo,
		/datum/manufacture/RCDammomedium,
		/datum/manufacture/RCDammolarge)

/obj/machinery/manufacturer/hangar
	name = "ship component fabricator"
	supplemental_desc = "This one produces modules for space pods or minisubs."
	icon_state = "fab-hangar"
	icon_base = "hangar"
	free_resource_amt = 2
	free_resources = list(/obj/item/material_piece/steel,
		/obj/item/material_piece/copper,
		/obj/item/material_piece/glass)
	available = list(
#ifdef UNDERWATER_MAP
		/datum/manufacture/sub/engine,
		/datum/manufacture/sub/boards,
		/datum/manufacture/sub/control,
		/datum/manufacture/sub/parts,
#else
		/datum/manufacture/putt/engine,
		/datum/manufacture/putt/boards,
		/datum/manufacture/putt/control,
		/datum/manufacture/putt/parts,
#endif
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
		/datum/manufacture/pod/lock,
		/datum/manufacture/beaconkit
	)

/obj/machinery/manufacturer/uniform // add more stuff to this as needed, but it should be for regular uniforms the HoP might hand out, not tons of gimmicks. -cogwerks
	name = "uniform manufacturer"
	supplemental_desc = "This one can create a wide variety of one-size-fits-all jumpsuits, as well as backpacks and radio headsets."
	icon_state = "fab-jumpsuit"
	icon_base = "jumpsuit"
	free_resource_amt = 5
	free_resources = list(/obj/item/material_piece/cloth/cottonfabric,
		/obj/item/material_piece/steel,
		/obj/item/material_piece/copper)
	accept_blueprints = FALSE
	available = list(/datum/manufacture/shoes,	//hey if you update these please remember to add it to /hop_and_uniform's list too
		/datum/manufacture/shoes_brown,
		/datum/manufacture/shoes_white,
		/datum/manufacture/flippers,
		/datum/manufacture/civilian_headset,
		/datum/manufacture/jumpsuit_assistant,
		/datum/manufacture/jumpsuit_pink,
		/datum/manufacture/jumpsuit_red,
		/datum/manufacture/jumpsuit_orange,
		/datum/manufacture/jumpsuit_yellow,
		/datum/manufacture/jumpsuit_green,
		/datum/manufacture/jumpsuit_blue,
		/datum/manufacture/jumpsuit_purple,
		/datum/manufacture/jumpsuit_black,
		/datum/manufacture/jumpsuit,
		/datum/manufacture/jumpsuit_white,
		/datum/manufacture/jumpsuit_brown,
		/datum/manufacture/pride_lgbt,
		/datum/manufacture/pride_ace,
		/datum/manufacture/pride_aro,
		/datum/manufacture/pride_bi,
		/datum/manufacture/pride_inter,
		/datum/manufacture/pride_lesb,
		/datum/manufacture/pride_gay,
		/datum/manufacture/pride_nb,
		/datum/manufacture/pride_pan,
		/datum/manufacture/pride_poly,
		/datum/manufacture/pride_trans,
		/datum/manufacture/suit_black,
		/datum/manufacture/dress_black,
		/datum/manufacture/hat_black,
		/datum/manufacture/hat_white,
		/datum/manufacture/hat_pink,
		/datum/manufacture/hat_red,
		/datum/manufacture/hat_yellow,
		/datum/manufacture/hat_orange,
		/datum/manufacture/hat_green,
		/datum/manufacture/hat_blue,
		/datum/manufacture/hat_purple,
		/datum/manufacture/hat_tophat,
		/datum/manufacture/backpack,
		/datum/manufacture/backpack_red,
		/datum/manufacture/backpack_green,
		/datum/manufacture/backpack_blue,
		/datum/manufacture/satchel,
		/datum/manufacture/satchel_red,
		/datum/manufacture/satchel_green,
		/datum/manufacture/satchel_blue)

	hidden = list(/datum/manufacture/breathmask,
		/datum/manufacture/patch,
		/datum/manufacture/towel,
		/datum/manufacture/tricolor,
		/datum/manufacture/hat_ltophat)

/// cogwerks - a gas extractor for the engine

/obj/machinery/manufacturer/gas
	name = "gas extractor"
	supplemental_desc = "This one can create gas canisters, either empty or filled with gases extracted from certain minerals."
	icon_state = "fab-atmos"
	icon_base = "atmos"
	accept_blueprints = FALSE
	available = list(
		/datum/manufacture/atmos_can,
		/datum/manufacture/air_can/large,
		/datum/manufacture/o2_can,
		/datum/manufacture/co2_can,
		/datum/manufacture/n2_can,
		/datum/manufacture/plasma_can,
		/datum/manufacture/red_o2_grenade)

// a blank manufacturer for mechanics

/obj/machinery/manufacturer/mechanic
	name = "reverse-engineering fabricator"
	desc = "A specialized manufacturing unit designed to create new things (or copies of existing things) from blueprints."
	icon_state = "fab-hangar"
	icon_base = "hangar"
	free_resource_amt = 2
	free_resources = list(/obj/item/material_piece/steel,
		/obj/item/material_piece/copper,
		/obj/item/material_piece/glass)

/obj/machinery/manufacturer/personnel
	name = "personnel equipment manufacturer"
	supplemental_desc = "This one can produce blank ID cards and access implants."
	icon_state = "fab-access"
	icon_base = "access"
	free_resource_amt = 2
	free_resources = list(/obj/item/material_piece/steel,
		/obj/item/material_piece/copper,
		/obj/item/material_piece/glass)
	available = list(/datum/manufacture/id_card, /datum/manufacture/implant_access,	/datum/manufacture/implanter)
	hidden = list(/datum/manufacture/id_card_gold, /datum/manufacture/implant_access_infinite)

//combine personnel + uniform manufactuer here. this is 'cause destiny doesn't have enough room! arrg!
//and i hate this, i do, but you're gonna have to update this list whenever you update /personnel or /uniform
/obj/machinery/manufacturer/hop_and_uniform
	name = "personnel manufacturer"
	supplemental_desc = "This one is an multi-purpose model, and is able to produce uniforms, headsets, and identification equipment."
	icon_state = "fab-access"
	icon_base = "access"
	free_resource_amt = 5
	free_resources = list(/obj/item/material_piece/steel,
		/obj/item/material_piece/copper,
		/obj/item/material_piece/glass,
		/obj/item/material_piece/cloth/cottonfabric)
	accept_blueprints = FALSE
	available = list(/datum/manufacture/id_card,
		/datum/manufacture/implant_access,
		/datum/manufacture/implanter,
		/datum/manufacture/shoes,
		/datum/manufacture/shoes_brown,
		/datum/manufacture/shoes_white,
		/datum/manufacture/flippers,
		/datum/manufacture/civilian_headset,
		/datum/manufacture/jumpsuit_assistant,
		/datum/manufacture/jumpsuit,
		/datum/manufacture/jumpsuit_white,
		/datum/manufacture/jumpsuit_pink,
		/datum/manufacture/jumpsuit_red,
		/datum/manufacture/jumpsuit_orange,
		/datum/manufacture/jumpsuit_yellow,
		/datum/manufacture/jumpsuit_green,
		/datum/manufacture/jumpsuit_blue,
		/datum/manufacture/jumpsuit_purple,
		/datum/manufacture/jumpsuit_black,
		/datum/manufacture/jumpsuit_brown,
		/datum/manufacture/pride_lgbt,
		/datum/manufacture/pride_ace,
		/datum/manufacture/pride_aro,
		/datum/manufacture/pride_bi,
		/datum/manufacture/pride_inter,
		/datum/manufacture/pride_lesb,
		/datum/manufacture/pride_gay,
		/datum/manufacture/pride_nb,
		/datum/manufacture/pride_pan,
		/datum/manufacture/pride_poly,
		/datum/manufacture/pride_trans,
		/datum/manufacture/hat_black,
		/datum/manufacture/hat_white,
		/datum/manufacture/hat_pink,
		/datum/manufacture/hat_red,
		/datum/manufacture/hat_yellow,
		/datum/manufacture/hat_orange,
		/datum/manufacture/hat_green,
		/datum/manufacture/hat_blue,
		/datum/manufacture/hat_purple,
		/datum/manufacture/hat_tophat)

	hidden = list(/datum/manufacture/id_card_gold,
		/datum/manufacture/implant_access_infinite,
		/datum/manufacture/breathmask,
		/datum/manufacture/patch,
		/datum/manufacture/tricolor,
		/datum/manufacture/hat_ltophat)

/obj/machinery/manufacturer/qm // This manufacturer just creates different crated and boxes for the QM. Lets give their boring lives at least something more interesting.
	name = "crate manufacturer"
	supplemental_desc = "This one produces crates, carts, that sort of thing. Y'know, box stuff."
	icon_state = "fab-crates"
	icon_base = "crates"
	free_resource_amt = 5
	free_resources = list(/obj/item/material_piece/steel)
	accept_blueprints = FALSE
	available = list(/datum/manufacture/crate,
		/datum/manufacture/packingcrate,
		/datum/manufacture/wooden,
		/datum/manufacture/medical,
		/datum/manufacture/biohazard,
		/datum/manufacture/freezer)

	hidden = list(/datum/manufacture/classcrate)

/obj/machinery/manufacturer/zombie_survival
	name = "\improper Uber-Extreme Survival Manufacturer"
	desc = "This manufacturing unit seems to have been loaded with a bunch of nonstandard blueprints, apparently to be useful in surviving \"extreme scenarios\"."
	icon_state = "fab-crates"
	icon_base = "crates"
	free_resource_amt = 50
	free_resources = list(/obj/item/material_piece/steel,
		/obj/item/material_piece/copper,
		/obj/item/material_piece/glass,
		/obj/item/material_piece/cloth/cottonfabric)
	accept_blueprints = FALSE
	available = list(
		/datum/manufacture/engspacesuit,
		/datum/manufacture/breathmask,
		/datum/manufacture/suture,
		/datum/manufacture/scalpel,
		/datum/manufacture/flashlight,
		/datum/manufacture/armor_vest,
		/datum/manufacture/bullet_22,
		/datum/manufacture/harmonica,
		/datum/manufacture/riot_shotgun,
		/datum/manufacture/riot_shotgun_ammo,
		/datum/manufacture/clock,
		/datum/manufacture/clock_ammo,
		/datum/manufacture/saa,
		/datum/manufacture/saa_ammo,
		/datum/manufacture/riot_launcher,
		/datum/manufacture/riot_launcher_ammo_pbr,
		/datum/manufacture/riot_launcher_ammo_flashbang,
		/datum/manufacture/sniper,
		/datum/manufacture/sniper_ammo,
		/datum/manufacture/tac_shotgun,
		/datum/manufacture/tac_shotgun_ammo,
		/datum/manufacture/gyrojet,
		/datum/manufacture/gyrojet_ammo,
		/datum/manufacture/plank,
		/datum/manufacture/brute_kit,
		/datum/manufacture/burn_kit,
		/datum/manufacture/crit_kit,
		/datum/manufacture/spacecillin,
		/datum/manufacture/bat,
		/datum/manufacture/quarterstaff,
		/datum/manufacture/cleaver,
		/datum/manufacture/fireaxe,
		/datum/manufacture/shovel)



/// Manufacturer blueprints can be read by any manufacturer unit to add the referenced object to the unit's production options.
/obj/item/paper/manufacturer_blueprint
	name = "manufacturer blueprint"
	desc = "This is a laminated blueprint covered in specialized instructions. A manufacturing unit could build something from this."
	info = "There's all manner of confusing diagrams and instructions on here. It's meant for a machine to read."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "blueprint"
	item_state = "sheet"
	var/datum/manufacture/blueprint = null
	var/override_name_desc = TRUE //! If non-zero, the name and description of this blueprint will be overriden on New() with standardized values

	New(loc, schematic = null)
		..()
		if(istype(schematic, /datum/manufacture))
			src.blueprint = schematic
		else if (!schematic)
			if (ispath(src.blueprint))
				src.blueprint = get_schematic_from_path(src.blueprint)
			else
				qdel(src)
				return FALSE
		else
			if (istext(schematic))
				src.blueprint = get_schematic_from_name(schematic)
			else if (ispath(schematic))
				src.blueprint = get_schematic_from_path(schematic)
		if (!src.blueprint)
			qdel(src)
			return FALSE
		if(src.override_name_desc)
			src.name = "manufacturer blueprint: [src.blueprint.name]"
			src.desc = "This laminated blueprint could be read by a manufacturing unit to add \the [src.blueprint.name] to its production options."
		src.pixel_x = rand(-4, 4)
		src.pixel_y = rand(-4, 4)
		return TRUE

/obj/item/paper/manufacturer_blueprint/clonepod
	blueprint = /datum/manufacture/mechanics/clonepod

/obj/item/paper/manufacturer_blueprint/clonegrinder
	blueprint = /datum/manufacture/mechanics/clonegrinder

/obj/item/paper/manufacturer_blueprint/clone_scanner
	blueprint = /datum/manufacture/mechanics/clone_scanner

/obj/item/paper/manufacturer_blueprint/loafer
	blueprint = /datum/manufacture/mechanics/loafer

/obj/item/paper/manufacturer_blueprint/lawrack
	blueprint = /datum/manufacture/mechanics/lawrack

/obj/item/paper/manufacturer_blueprint/ai_status_display
	blueprint = /datum/manufacture/mechanics/ai_status_display

/obj/item/paper/manufacturer_blueprint/thrusters
	name = "manufacturer blueprint: Alastor Pattern Thrusters"
	desc = "This blueprint lacks the usual human-readable documentation, and is smudged with traces of charcoal. Huh."
	icon = 'icons/obj/writing.dmi'
	icon_state = "blueprint"
	blueprint = /datum/manufacture/thrusters

/obj/item/paper/manufacturer_blueprint/alastor
	name = "manufacturer blueprint: Alastor Pattern Laser Rifle"
	desc = "This blueprint lacks the usual human-readable documentation, and is smudged with traces of charcoal. Huh."
	icon = 'icons/obj/writing.dmi'
	icon_state = "blueprint"
	blueprint = /datum/manufacture/alastor

/obj/item/paper/manufacturer_blueprint/interdictor_kit
	name = "Interdictor Assembly Kit"
	icon = 'icons/obj/writing.dmi'
	icon_state = "interdictor_blueprint"
	blueprint = /datum/manufacture/interdictor_kit

/obj/item/paper/manufacturer_blueprint/interdictor_rod_lambda
	name = "Lambda Phase-Control Rod"
	icon = 'icons/obj/writing.dmi'
	icon_state = "interdictor_blueprint"
	blueprint = /datum/manufacture/interdictor_rod_lambda

/obj/item/paper/manufacturer_blueprint/interdictor_rod_sigma
	name = "Sigma Phase-Control Rod"
	icon = 'icons/obj/writing.dmi'
	icon_state = "interdictor_blueprint"
	blueprint = /datum/manufacture/interdictor_rod_sigma

/obj/item/paper/manufacturer_blueprint/gunbot
	name = "manufacturer blueprint: AP-Class Security Robot"
	desc = "This blueprint seems to detail a very old model of security bot dating back to the 2030s. Hopefully the manufacturers have legacy support."
	blueprint = /datum/manufacture/mechanics/gunbot
	override_name_desc = FALSE

/******************** Nadir Resonators *******************/

/obj/item/paper/manufacturer_blueprint/resonator_type_ax
	name = "Type-AX Resonator"
	blueprint = /datum/manufacture/resonator_type_ax

/obj/item/paper/manufacturer_blueprint/resonator_type_sm
	name = "Type-SM Resonator"
	blueprint = /datum/manufacture/resonator_type_sm


/// This is a special item that breaks apart into blueprints for the machines needed to build/repair a cloner.
/obj/item/cloner_blueprints_folder
	name = "dirty manila folder"
	desc = "An old manila folder covered in stains. It looks like it'll fall apart at the slightest touch."
	icon = 'icons/obj/writing.dmi'
	icon_state = "folder"
	w_class = W_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 10

	attack_self(mob/user)
		boutput(user, "<span class='alert'>The folder disintegrates in your hands, and papers scatter out. Shit!</span>")
		new /obj/item/paper/manufacturer_blueprint/clonepod(get_turf(src))
		new /obj/item/paper/manufacturer_blueprint/clonegrinder(get_turf(src))
		new /obj/item/paper/manufacturer_blueprint/clone_scanner(get_turf(src))
		new /obj/item/paper/hecate(get_turf(src))
		qdel(src)

/datum/action/bar/manufacturer
	duration = 100 SECONDS
	id = "manufacturer"
	var/obj/machinery/manufacturer/MA
	var/completed = FALSE

	New(machine, dur)
		MA = machine
		duration = dur
		..()

	onUpdate()
		..()
		if (MA.malfunction && prob(8))
			MA.flip_out()

		if (MA.status & (NOPOWER | BROKEN))
			interrupt(INTERRUPT_ALWAYS)
			return

	onInterrupt()
		..()
		MA.time_left = src.duration - (TIME - src.started)
		MA.manual_stop = FALSE
		MA.error = null
		MA.mode = "ready"
		MA.build_icon()

	onEnd()
		..()
		src.completed = TRUE
		MA.finish_work()
		// call dispense

	onDelete()
		..()
		MA.action_bar = null
		if (src.completed && length(MA.queue))
			SPAWN(0.1 SECONDS)
				MA.begin_work(TRUE)

/// Pre-build the icons for things manufacturers make
/proc/build_manufacturer_icons()
	for (var/datum/manufacture/P as anything in concrete_typesof(/datum/manufacture, FALSE))
		if (ispath(P, /datum/manufacture/mechanics))
			var/datum/manufacture/mechanics/M = P
			if (!initial(M.frame_path))
				continue
			getItemIcon(initial(M.frame_path))

		else
			// temporarily create this so we can get the list from it
			// i tried very hard to use initial() here and got nowhere,
			// but the fact it's a list seems to not really go well with it
			// maybe someone else can get it to work.
			var/datum/manufacture/I = new P
			if (I && length(I.item_outputs) && I.item_outputs[1])
				getItemIcon(I.item_outputs[1])


#undef WIRE_EXTEND
#undef WIRE_POWER
#undef WIRE_MALF
#undef WIRE_SHOCK
#undef MAX_QUEUE_LENGTH
