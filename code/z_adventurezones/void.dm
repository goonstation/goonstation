//moved all of the void area stuff here - ZeWaka

/* -----------------------------------------------------------------------------*\
CONTENTS:
  VOID AREAS
  VOID TURFS
  BODYSWAPPER
\*----------------------------------------------------------------------------- */
//broken rcd is in rcd.dm
//ghost gun and goggles are in energy.dm and glasses.dm
//port-a-medbay in sleeper.dm and remote.dm
/area/crunch
	name = "somewhere"
	icon_state = "purple"
	filler_turf = "/turf/unsimulated/floor/void"
	sound_environment = 21
	skip_sims = 1
	sims_score = 15
	sound_group = "void"
	sound_loop = 'sound/ambience/spooky/Void_Song.ogg'
	ambient_light = rgb(6.9, 4.20, 6.9)

/area/crunch/New()
	. = ..()
	START_TRACKING_CAT(TR_CAT_AREA_PROCESS)

/area/crunch/disposing()
	STOP_TRACKING_CAT(TR_CAT_AREA_PROCESS)
	. = ..()

/area/crunch/area_process()
	if(prob(20))
		src.sound_fx_2 = pick('sound/ambience/spooky/Void_Hisses.ogg',\
		'sound/ambience/spooky/Void_Screaming.ogg',\
		'sound/ambience/spooky/Void_Wail.ogg',\
		'sound/ambience/spooky/Void_Calls.ogg')

		for(var/mob/living/carbon/human/H in src)
			H.client?.playAmbience(src, AMBIENCE_FX_2, 50)

/turf/unsimulated/wall/void
	name = "dense void"
	icon = 'icons/turf/floors.dmi'
	desc = "It seems solid..."
	opacity = 1
	density = 1
	mat_appearances_to_ignore = list("steel")
#ifdef IN_MAP_EDITOR
	icon_state = "darkvoid-map" //so we can actually the walls from the floor
#else
	icon_state = "darkvoid"
#endif

/turf/unsimulated/wall/void/crunch //putting these here for now
	fullbright = 0

/turf/unsimulated/floor/void
	name = "void"
	icon = 'icons/turf/floors.dmi'
	icon_state = "void"
	desc = "A strange shifting void ..."
	mat_appearances_to_ignore = list("steel")

/turf/unsimulated/floor/void/crunch
	fullbright = 0

/turf/simulated/wall/void
	name = "dense void"
	icon = 'icons/turf/floors.dmi'
	icon_state = "darkvoid"
	desc = "It seems solid..."
	opacity = 1
	density = 1
	mat_appearances_to_ignore = list("steel")

	ex_act()
		return

	ex_act(severity)
		return

	blob_act(var/power)
		return

	attack_hand(mob/user)
		return

	attackby(obj/item/W, mob/user)
		return


/turf/simulated/floor/void
	name = "void"
	icon = 'icons/turf/floors.dmi'
	icon_state = "void"
	desc = "A strange shifting void ..."
	step_material = "step_lattice"
	step_priority = STEP_PRIORITY_MED
	mat_appearances_to_ignore = list("steel")

	ex_act()
		return

	ex_act(severity)
		return

	blob_act(var/power)
		return

	attack_hand(mob/user)
		return

	attackby(obj/item/W, mob/user)
		return

//////////////////////////////
//The amazing bodyswappitron
////////////////////////////

/obj/machinery/bodyswapper
	name = "complicated contraption"
	desc = "A big machine with lots of buttons and dials on it. Looks kinda dangerous."
	density = 1
	anchored = 1

	icon = 'icons/obj/machines/mindswap.dmi'
	icon_state = "mindswap"

	var/obj/stool/chair/e_chair/chair1 = null
	var/obj/stool/chair/e_chair/chair2 = null

	var/used = 0
	var/do_not_break = 0 //Set to one to have the thing regain usability on reboot


	var/active = 0
	var/activating = 0
	var/operating = 0

	var/remain_active = 0
	var/remain_active_max = 400

	var/boot_duration = 150
	var/loop_duration = 11.8

	var/list/icon/overlays_list = list()

	New()
		..()
		SPAWN(0.5 SECONDS)
			update_chairs()

		overlays_list["cables"] = new /image('icons/obj/machines/mindswap.dmi', "mindswap-cables")

		overlays_list["topcable"] =  new /image('icons/obj/machines/mindswap.dmi', "mindswap-topcable")

		overlays_list["lscreen0"] = new/image('icons/obj/machines/mindswap.dmi', "mindswap-screenY")
		overlays_list["lscreen1"] = new/image('icons/obj/machines/mindswap.dmi', "mindswap-screenY-bright")

		overlays_list["rscreen0"] = new /image('icons/obj/machines/mindswap.dmi', "mindswap-screenT")
		overlays_list["rscreen1"] = new /image('icons/obj/machines/mindswap.dmi', "mindswap-screenT-bright")

		overlays_list["mainindicator_off"] = new /image('icons/obj/machines/mindswap.dmi', "mindswap-dial-off")
		overlays_list["mainindicator"] = new /image('icons/obj/machines/mindswap.dmi', "mindswap-dial")
		overlays_list["mainindicator_on"] = new /image('icons/obj/machines/mindswap.dmi', "mindswap-dial-on")

		overlays_list["l_dial_idle"] = new /image('icons/obj/machines/mindswap.dmi', "mindswap-dial-L-idle")
		overlays_list["l_dial_0"] = new /image('icons/obj/machines/mindswap.dmi', "mindswap-dial-L-on")
		overlays_list["l_dial_1"] = new /image('icons/obj/machines/mindswap.dmi', "mindswap-dial-L-jitter")

		overlays_list["r_dial_idle"] = new /image('icons/obj/machines/mindswap.dmi', "mindswap-dial-R-idle")
		overlays_list["r_dial_0"] = new /image('icons/obj/machines/mindswap.dmi', "mindswap-dial-R-on")
		overlays_list["r_dial_1"] = new /image('icons/obj/machines/mindswap.dmi', "mindswap-dial-R-jitter")

		UpdateIcons()

	attack_hand(mob/user)
		..()

		display_ui(user)

	attack_ai(mob/user)
		attack_hand(user)


	proc/UpdateIcons()
		//src.overlays.Cut()

		UpdateOverlays(overlays_list["cables"], "cables")
		UpdateOverlays(overlays_list["topcable"], "topcable")

		if(active || activating > 1)
			UpdateOverlays(overlays_list["mainindicator[active ? "_on" : null]"], "main_ind")
		else
			UpdateOverlays(null, "main_ind")

		if(active)
			UpdateOverlays(overlays_list["lscreen[operating]"], "lscreen")
			UpdateOverlays(overlays_list["rscreen[operating]"], "rscreen")

			if(chair1?.buckled_guy)
				UpdateOverlays(overlays_list["l_dial_[operating]"], "l_dial")
			else
				UpdateOverlays(overlays_list["l_dial_idle"], "l_dial")

			if(chair2?.buckled_guy)
				UpdateOverlays(overlays_list["r_dial_[operating]"], "r_dial")
			else
				UpdateOverlays(overlays_list["r_dial_idle"], "r_dial")

		else if(activating)
			ClearSpecificOverlays("l_dial", "r_dial")
			if(activating >= 2)
				UpdateOverlays(overlays_list["lscreen[operating]"], "lscreen")
			else
				UpdateOverlays(null, "lscreen")

			if(activating >= 3)
				UpdateOverlays(overlays_list["rscreen[operating]"], "rscreen")
			else
				UpdateOverlays(null, "rscreen")

		else
			ClearSpecificOverlays("lscreen", "rscreen", "l_dial", "r_dial", "main_ind")

	proc/display_ui(var/mob/user)
		var/T
		src.add_dialog(user)
		if(active)
			if(!used)
				T = {"<span style="display: block">
					<h3>System Status: <font color=green>[operating ? "Operating" : "Active"]</font></h3>
					<A HREF='?src=\ref[src];shutdown=1'>Shut down</A>
					<h3>Device Interfaces</h3>
					<table border=1><tr>
						<th>Interface #1<td><B>[chair1 ? "<font color=green>Connected</font>" : "<font color=red>Disconnected</font>"]</B><tr>
						<th>Interface #2<td><B>[chair2 ? "<font color=green>Connected</font>" : "<font color=red>Disconnected</font>"]</B><tr>
					</table>
					<A HREF='?src=\ref[src];refresh_chair_connection=1'>Re-establish</A>
					<h3>Mental Interfaces</h3>
					<table border=1><tr>
						<th>Interface #1<td><B>[chair1?.buckled_guy ? "<font color=green>Connected</font>" : "<font color=red>Disconnected</font>"]</B><tr>
						<th>Interface #2<td><B>[chair2?.buckled_guy ? "<font color=green>Connected</font>" : "<font color=red>Disconnected</font>"]</B><tr>
					</table>
					<A HREF='?src=\ref[src];refresh_mind_connection=1'>Re-establish</A><BR><BR>
					<A HREF='?src=\ref[src];execute_swap=1'><B><font bold=5 size=7>Activate</font></B></A></span>"}

			else
				T = {"<span style="display: block">
					<body bgcolor=#000000>
					<font color=#FFFFFF>
					<h3>System Status: <font color=red>ERROR</font></h3>
					<A HREF='?src=\ref[src];shutdown=1'>Shut down</A>
					<h3>Device Interfaces</h3>
					<table border=1><tr>
						<th><font color=#FFFFFF>Interface #1</font><td><B><font color=red>ERROR!</font></B><tr>
						<th><font color=#FFFFFF>Interface #2</font><td><B><font color=red>ERROR!</font></B><tr>
					</table>
					<A HREF='?src=\ref[src];refresh_chair_connection=1'>ERROR</A>
					<h3>Mental Interfaces</h3>
					<table border=1><tr>
						<th><font color=#FFFFFF>Interface #1</font><td><B><font color=red>ERROR!</font></B><tr>
						<th><font color=#FFFFFF>Interface #2</font><td><B><font color=red>ERROR!</font></B><tr>
					</table>
					<A HREF='?src=\ref[src];refresh_mind_connection=1'>ERROR</A><BR><BR>

					<A HREF='?src=\ref[src];execute_swap=1'><B><font bold=5 size=7>ERROR</font></B></A>
					</font>
					</body>
					</span>
					"}
		else
			T = {"<span style="display: block">
				<h3>System Status: <font color=red>[activating ? "BOOTING" : "OFFLINE"]</font></h3>
				<A HREF='?src=\ref[src];bootup=1'>Boot</A>
				<h3>Device Interfaces</h3>
				<table border=1><tr>
					<th>Interface #1<td><B>OFFLINE</B><tr>
					<th>Interface #2<td><B>OFFLINE</B><tr>
				</table>
				<U>Re-establish</U>
				<h3>Mental Interfaces</h3>
				<table border=1><tr>
					<th>Interface #1<td><B>OFFLINE</B><tr>
					<th>Interface #2<td><B>OFFLINE</B><tr>
				</table>
				<U>Re-establish</U><BR><BR>
				<U><B><font bold=5 size=7>Activate</font></B></U></span>"}

		user.Browse(T, "window=bodyswapper;size=300x600;title=Control Panel")
		onclose(user, "bodyswapper")

	Topic(href, href_list[])
		..()

		if(href_list["shutdown"])
			remain_active = 0
		else if(href_list["bootup"])
			activate()
			src.updateUsrDialog()
		else if(!used)
			if(href_list["refresh_chair_connection"])
				update_chairs()
				src.updateUsrDialog()

			else if(href_list["refresh_mind_connection"])
				src.updateUsrDialog() //lol cheats
				UpdateIcons()

			else if(href_list["execute_swap"])
				do_swap()
				src.updateUsrDialog()
		else
			usr.show_text("The controls seem unresponsive...", "red")


	proc/activate()
		if(activating) return
		activating = 1
		src.updateUsrDialog()
		playsound(src.loc, 'sound/machines/computerboot_pc_start.ogg', 50, 0)

		sleep(boot_duration / 2)
		activating = 2
		UpdateIcons()

		sleep(boot_duration / 4)
		activating = 3
		UpdateIcons()

		sleep(boot_duration / 4)
		active = 1
		activating = 0
		UpdateIcons()

		remain_active = remain_active_max

		make_some_noise()
		if(do_not_break)
			used = 0
			loop_duration = initial(loop_duration)

		src.updateUsrDialog()

	proc/make_some_noise()
		do
			playsound(src.loc, 'sound/machines/computerboot_pc_loop.ogg', 50, 0)
			sleep(loop_duration)
		while(active && !activating && remain_active-- > 0) //So it will shut itself down after a while

		if(remain_active <= 0)
			src.visible_message("<span class='alert'>You hear a quiet click as \the [src] deactivates itself.</span>")
			deactivate()



	proc/deactivate()
		if(!active || activating || operating) return
		activating = 1
		playsound(src.loc, 'sound/machines/computerboot_pc_end.ogg', 50, 0)
		sleep(2 SECONDS)
		activating = 0
		active = 0
		UpdateIcons()

		src.updateUsrDialog()


	proc/update_chairs()
		if(!chair1) chair1 = locate(/obj/stool/chair/e_chair, get_step(src, WEST))
		if(!chair2) chair2 = locate(/obj/stool/chair/e_chair, get_step(src, EAST))

		if(chair1 && !chair1.on) chair1.toggle_active()
		if(chair2 && !chair2.on) chair2.toggle_active()
		UpdateIcons()

	proc/can_operate()
		return valid_mindswap(chair1?.buckled_guy) && valid_mindswap(chair2?.buckled_guy)

	proc/valid_mindswap(mob/M)
		. = 0
		if(isliving(M))
			. = 1

		if(issilicon(M))
			. = 0

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.on_chair)
				. = 0
		if(istype(M, /mob/living/critter))
			var/mob/living/critter/C = M
			if(C.dormant || C.ghost_spawned)
				. = 0
		if(istype(M, /mob/living/critter/small_animal/mouse/weak/mentor) || istype(M, /mob/living/critter/flock) || istype(M, /mob/living/intangible))
			. = 0

	proc/do_swap()

		var/success = 1
		if(!operating && !used)

			operating = 1


			update_chairs()
			if(can_operate()) //We have what we need
				remain_active += 200 //So it won't switch itself off on us
				UpdateIcons()

				//We're not going to allow you to unbuckle during the process
				chair1.allow_unbuckle = 0
				chair2.allow_unbuckle = 0

				var/mob/living/carbon/human/A = chair1.buckled_guy
				var/mob/living/carbon/human/B = chair2.buckled_guy

				if(istype(A, /mob/living/carbon/human/future))
					A:death_countdown = 20 //Don't die on us mid-process
				else if(istype(B, /mob/living/carbon/human/future))
					B:death_countdown = 20

				playsound(src.loc, 'sound/machines/modem.ogg', 75, 1)

				A.emote("scream")
				A.changeStatus("weakened", 5 SECONDS)
				A.show_text("<B>IT HURTS!</B>", "red")
				A.shock(src, 75000, ignore_gloves=1)

				B.emote("scream")
				B.changeStatus("weakened", 5 SECONDS)
				B.show_text("<B>IT HURTS!</B>", "red")
				B.shock(src, 75000, ignore_gloves=1)
				SPAWN(5 SECONDS)
					playsound(src.loc, 'sound/machines/modem.ogg', 100, 1)
					A.show_text("<B>You feel your mind slipping...</B>", "red")
					A.changeStatus("drowsy", 20 SECONDS)
					B.show_text("<B>You feel your mind slipping...</B>", "red")
					B.changeStatus("drowsy", 20 SECONDS)

				sleep(10 SECONDS)
				playsound(src.loc,'sound/effects/elec_bzzz.ogg', 60, 1)
				if(A && B && can_operate()) //We're all here, still
					A.emote("faint")
					A.changeStatus("paralysis", 25 SECONDS)
					A.shock(src, 750000, ignore_gloves=1)

					B.emote("faint")
					B.changeStatus("paralysis", 25 SECONDS)
					A.shock(src, 750000, ignore_gloves=1)

					if(A.mind)
						A.mind.swap_with(B)
					else if(B.mind) //Just in case A is mindless, try from B's side
						B.mind.swap_with(A)
					else
						success = 0

				else if(!can_operate()) //Someone was being clever during the process
					SPAWN(0)
						if(A)
							playsound(A.loc, 'sound/impact_sounds/Machinery_Break_1.ogg', 70, 1)
							A.show_text("<B>The residual energy from the machine suddenly rips you apart!</B>", "red")
							A.shock(src, 7500000, ignore_gloves=1)
							if(A) A.vaporize() //Still standing, you fuck?
						if(B)
							playsound(B.loc, 'sound/impact_sounds/Machinery_Break_1.ogg', 70, 1)
							B.show_text("<B>The residual energy from the machine suddenly rips you apart!</B>", "red")
							B.shock(src, 7500000, ignore_gloves=1)
							if(B) B.vaporize() //Still standing, you fuck?

				//Time to die
				if(istype(A, /mob/living/carbon/human/future))
					A:death_countdown = 5
				else if(istype(B, /mob/living/carbon/human/future))
					B:death_countdown = 5

				//We're now going to allow you to unbuckle

				if(chair1) chair1.allow_unbuckle = 1
				if(chair2) chair2.allow_unbuckle = 1
			else //Failure.
				success = 0

			if(success)
				playsound(src.loc, 'sound/effects/electric_shock.ogg', 50,1)
				src.visible_message("<span class='alert'>\The [src] emits a loud crackling sound and the smell of ozone fills the air!</span>")
				loop_duration = 7 //Something is amiss oh no!
				remain_active = min(remain_active, 100)
				remain_active_max = 100
				used = 1
			else
				playsound(src.loc, 'sound/machines/buzz-two.ogg', 50,1)
				src.visible_message("<span class='alert'>\The [src] emits a whirring and clicking noise followed by an angry beep!</span>")

		SPAWN(5 SECONDS)
			operating = 0
			UpdateIcons()
