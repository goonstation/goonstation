/obj/submachine/slot_machine
	name = "Slot Machine"
	desc = "Gambling for the antisocial."
	icon = 'icons/obj/gambling.dmi'
	icon_state = "slots-off"
	anchored = 1
	density = 1
	mats = 8
	deconstruct_flags = DECON_SIMPLE
	//var/money = 1000000
	var/plays = 0
	var/working = 0
	var/obj/item/card/id/scan = null

	New()
		mechanics = new(src)
		mechanics.master = src
		mechanics.addInput("activate", "activateinput")
		..()

	proc/activateinput(var/datum/mechanicsMessage/inp) //make this work some day.
		//var/list/reflist = list("ops")
		//Topic(null,
		return

	attackby(var/obj/item/I as obj, user as mob)
		if(istype(I, /obj/item/card/id))
			if(src.scan)
				boutput(user, "<span style=\"color:red\">There is a card already in the slot machine.</span>")
			else
				boutput(user, "<span style=\"color:blue\">You insert your ID card.</span>")
				usr.drop_item()
				I.set_loc(src)
				src.scan = I
				src.updateUsrDialog()
		else src.attack_hand(user)
		return

	attack_hand(var/mob/user as mob)
		user.machine = src
		if (!src.scan)
			var/dat = {"<B>Slot Machine</B><BR>
			<HR><BR>
			<B>Please insert card!</B><BR>"}
			user.Browse(dat, "window=slotmachine;size=450x500")
			onclose(user, "slotmachine")
		else if (src.working)
			var/dat = {"<B>Slot Machine</B><BR>
			<HR><BR>
			<B>Please wait!</B><BR>"}
			user.Browse(dat, "window=slotmachine;size=450x500")
			onclose(user, "slotmachine")
		else
			var/dat = {"<B>Slot Machine</B><BR>
			<HR><BR>
			Twenty credits to play!<BR>
			<B>Your Card:</B> [src.scan]<BR>
			<B>Credits Remaining:</B> [src.scan.money]<BR>
			[src.plays] attempts have been made today!<BR>
			<HR><BR>
			<A href='?src=\ref[src];ops=1'>Play!</A><BR>
			<A href='?src=\ref[src];ops=2'>Eject card</A>"}
			user.Browse(dat, "window=slotmachine;size=400x500")
			onclose(user, "slotmachine")

	Topic(href, href_list)
		if (get_dist(src, usr) > 1 || !isliving(usr) || iswraith(usr) || isintangible(usr))
			return
		if (usr.getStatusDuration("stunned") > 0 || usr.getStatusDuration("weakened") || usr.getStatusDuration("paralysis") > 0 || !isalive(usr) || usr.restrained())
			return

		if(href_list["ops"])
			var/operation = text2num(href_list["ops"])
			if(operation == 1) // Play
				if(src.working) return
				if(!src.scan) return
				if (src.scan.money < 20)
					for(var/mob/O in hearers(src, null))
						O.show_message(text("<span style='color:#888888'><b>[]</b> says, 'Insufficient money to play!'</span>", src), 1)
					return
				/*if (src.money < 0)
					for(var/mob/O in hearers(src, null))
						O.show_message(text("<b>[]</b> says, 'No prize money left!'", src), 1)
					return*/
				src.scan.money -= 20
				//src.money += 10
				src.plays += 1
				src.working = 1
				src.icon_state = "slots-on"
				//for(var/mob/O in hearers(src, null))
					//O.show_message(text("<b>[]</b> says, 'Let's roll!'", src), 1)
				var/roll = rand(1,1350)

				playsound(src.loc, "sound/machines/ding.ogg", 50, 1)
				SPAWN_DBG(2.5 SECONDS) // why was this at ten seconds, christ
					if (roll == 1)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span style='color:#888888'><b>[]</b> says, 'JACKPOT! [src.scan.registered] has won a MILLION CREDITS!'</span>", src), 1)
						command_alert("Congratulations to [src.scan.registered] on winning the Jackpot of ONE MILLION CREDITS!", "Jackpot Winner")
						playsound(src.loc, "sound/misc/airraid_loop_short.ogg", 55, 1)
						src.scan.money += 1000000
						//src.money = 0
					else if (roll > 1 && roll <= 5)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span style='color:#888888'><b>[]</b> says, 'Big Winner! [src.scan.registered] has won a hundred thousand credits!'</span>", src), 1)
						command_alert("Congratulations to [src.scan.registered] on winning a hundred thousand credits!", "Big Winner")
						playsound(src.loc, "sound/misc/klaxon.ogg", 55, 1)
						src.scan.money += 100000
						//src.money -= 100000
					else if (roll > 5 && roll <= 25)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span style='color:#888888'><b>[]</b> says, 'Big Winner! [src.scan.registered] has won ten thousand credits!'</span>", src), 1)
						playsound(src.loc, "sound/misc/klaxon.ogg", 55, 1)
						src.scan.money += 10000
						//src.money -= 10000
					else if (roll > 25 && roll <= 50)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span style='color:#888888'><b>[]</b> says, 'Winner! [src.scan.registered] has won a thousand credits!'</span>", src), 1)
						playsound(src.loc, "sound/musical_instruments/Bell_Huge_1.ogg", 55, 1)
						src.scan.money += 1000
						//src.money -= 1000
					else if (roll > 50 && roll <= 100)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span style='color:#888888'><b>[]</b> says, 'Winner! [src.scan.registered] has won a hundred credits!'</span>", src), 1)
						playsound(src.loc, "sound/musical_instruments/Bell_Huge_1.ogg", 55, 1)
						src.scan.money += 100
						//src.money -= 100
					else if (roll > 100 && roll <= 200)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span style='color:#888888'><b>[]</b> says, 'Winner! [src.scan.registered] has won fifty credits!'</span>", src), 1)
						playsound(src.loc, "sound/machines/ping.ogg", 55, 1)
						src.scan.money += 50
						//src.money -= 50
					else if (roll > 200 && roll <= 500)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span style='color:#888888'><b>[]</b> says, '[src.scan.registered] has won ten credits!'</span>", src), 1)
						playsound(src.loc, "sound/machines/ping.ogg", 55, 1)
						src.scan.money += 10
						//src.money -= 10
					else
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span style='color:#888888'><b>[]</b> says, 'No luck!'</span>", src), 1)
							//playsound(src.loc, "sound/machines/buzz-two.ogg", 55, 1) // way too loud UGH
					src.working = 0
					src.icon_state = "slots-off"
					updateUsrDialog()
			if(operation == 2) // Eject Card
				if(!src.scan) return // jerks doing that "hide in a chute to glitch auto-update windows out" exploit caused a wall of runtime errors
				src.scan.set_loc(src.loc)
				src.scan = null
				src.working = 0
				src.icon_state = "slots-off" // just in case, some fucker broke it earlier
				for(var/mob/O in hearers(src, null))
					O.show_message(text("<span style='color:#888888'><b>[]</b> says, 'Thank you for playing!'</span>", src), 1)
		src.add_fingerprint(usr)
		src.updateUsrDialog()
		if(mechanics) mechanics.fireOutgoing(mechanics.newSignal("machineUsed"))
		return

/obj/submachine/slot_machine_manta
	name = "Slot Machine"
	desc = "Gambling for the antisocial."
	icon = 'icons/obj/gambling.dmi'
	icon_state = "slotsnew-off"
	anchored = 1
	density = 1
	mats = 8
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_MULTITOOL
	//var/money = 1000000
	var/plays = 0
	var/working = 0
	var/obj/item/card/id/scan = null

	New()
		mechanics = new(src)
		mechanics.master = src
		mechanics.addInput("activate", "activateinput")
		..()

	proc/activateinput(var/datum/mechanicsMessage/inp) //make this work some day.
		//var/list/reflist = list("ops")
		//Topic(null,
		return

	attackby(var/obj/item/I as obj, user as mob)
		if(istype(I, /obj/item/card/id))
			if(src.scan)
				boutput(user, "<span style=\"color:red\">There is a card already in the slot machine.</span>")
			else
				boutput(user, "<span style=\"color:blue\">You insert your ID card.</span>")
				usr.drop_item()
				I.set_loc(src)
				src.scan = I
				src.updateUsrDialog()
		else src.attack_hand(user)
		return

	attack_hand(var/mob/user as mob)
		user.machine = src
		if (!src.scan)
			var/dat = {"<B>Slot Machine</B><BR>
			<HR><BR>
			<B>Please insert card!</B><BR>"}
			user.Browse(dat, "window=slotmachine;size=450x500")
			onclose(user, "slotmachine")
		else if (src.working)
			var/dat = {"<B>Slot Machine</B><BR>
			<HR><BR>
			<B>Please wait!</B><BR>"}
			user.Browse(dat, "window=slotmachine;size=450x500")
			onclose(user, "slotmachine")
		else
			var/dat = {"<B>Slot Machine</B><BR>
			<HR><BR>
			Twenty credits to play!<BR>
			<B>Your Card:</B> [src.scan]<BR>
			<B>Credits Remaining:</B> [src.scan.money]<BR>
			[src.plays] attempts have been made today!<BR>
			<HR><BR>
			<A href='?src=\ref[src];ops=1'>Play!</A><BR>
			<A href='?src=\ref[src];ops=2'>Eject card</A>"}
			user.Browse(dat, "window=slotmachine;size=400x500")
			onclose(user, "slotmachine")

	Topic(href, href_list)
		if (get_dist(src, usr) > 1 || !isliving(usr) || iswraith(usr) || isintangible(usr))
			return
		if (usr.getStatusDuration("stunned") > 0 || usr.getStatusDuration("weakened") || usr.getStatusDuration("paralysis") > 0 || !isalive(usr) || usr.restrained())
			return

		if(href_list["ops"])
			var/operation = text2num(href_list["ops"])
			if(operation == 1) // Play
				if(src.working) return
				if(!src.scan) return
				if (src.scan.money < 20)
					for(var/mob/O in hearers(src, null))
						O.show_message(text("<span style='color:#888888'><b>[]</b> says, 'Insufficient money to play!'</span>", src), 1)
					return
				/*if (src.money < 0)
					for(var/mob/O in hearers(src, null))
						O.show_message(text("<b>[]</b> says, 'No prize money left!'", src), 1)
					return*/
				src.scan.money -= 20
				//src.money += 10
				src.plays += 1
				src.working = 1
				src.icon_state = "slotsnew-on"
				//for(var/mob/O in hearers(src, null))
					//O.show_message(text("<b>[]</b> says, 'Let's roll!'", src), 1)
				var/roll = rand(1,1350)

				playsound(src.loc, "sound/machines/ding.ogg", 50, 1)
				SPAWN_DBG(2.5 SECONDS) // why was this at ten seconds, christ
					if (roll == 1)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span style='color:#888888'><b>[]</b> says, 'JACKPOT! [src.scan.registered] has won a MILLION CREDITS!'</span>", src), 1)
						command_alert("Congratulations to [src.scan.registered] on winning the Jackpot of ONE MILLION CREDITS!", "Jackpot Winner")
						playsound(src.loc, "sound/misc/airraid_loop_short.ogg", 55, 1)
						src.scan.money += 1000000
						//src.money = 0
					else if (roll > 1 && roll <= 5)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span style='color:#888888'><b>[]</b> says, 'Big Winner! [src.scan.registered] has won a hundred thousand credits!'</span>", src), 1)
						command_alert("Congratulations to [src.scan.registered] on winning a hundred thousand credits!", "Big Winner")
						playsound(src.loc, "sound/misc/klaxon.ogg", 55, 1)
						src.scan.money += 100000
						//src.money -= 100000
					else if (roll > 5 && roll <= 25)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span style='color:#888888'><b>[]</b> says, 'Big Winner! [src.scan.registered] has won ten thousand credits!'</span>", src), 1)
						playsound(src.loc, "sound/misc/klaxon.ogg", 55, 1)
						src.scan.money += 10000
						//src.money -= 10000
					else if (roll > 25 && roll <= 50)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span style='color:#888888'><b>[]</b> says, 'Winner! [src.scan.registered] has won a thousand credits!'</span>", src), 1)
						playsound(src.loc, "sound/musical_instruments/Bell_Huge_1.ogg", 55, 1)
						src.scan.money += 1000
						//src.money -= 1000
					else if (roll > 50 && roll <= 100)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span style='color:#888888'><b>[]</b> says, 'Winner! [src.scan.registered] has won a hundred credits!'</span>", src), 1)
						playsound(src.loc, "sound/musical_instruments/Bell_Huge_1.ogg", 55, 1)
						src.scan.money += 100
						//src.money -= 100
					else if (roll > 100 && roll <= 200)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span style='color:#888888'><b>[]</b> says, 'Winner! [src.scan.registered] has won fifty credits!'</span>", src), 1)
						playsound(src.loc, "sound/machines/ping.ogg", 55, 1)
						src.scan.money += 50
						//src.money -= 50
					else if (roll > 200 && roll <= 500)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span style='color:#888888'><b>[]</b> says, '[src.scan.registered] has won ten credits!'</span>", src), 1)
						playsound(src.loc, "sound/machines/ping.ogg", 55, 1)
						src.scan.money += 10
						//src.money -= 10
					else
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span style='color:#888888'><b>[]</b> says, 'No luck!'</span>", src), 1)
							//playsound(src.loc, "sound/machines/buzz-two.ogg", 55, 1) // way too loud UGH
					src.working = 0
					src.icon_state = "slotsnew-off"
					updateUsrDialog()
			if(operation == 2) // Eject Card
				if(!src.scan) return // jerks doing that "hide in a chute to glitch auto-update windows out" exploit caused a wall of runtime errors
				src.scan.set_loc(src.loc)
				src.scan = null
				src.working = 0
				src.icon_state = "slotsnew-off" // just in case, some fucker broke it earlier
				for(var/mob/O in hearers(src, null))
					O.show_message(text("<span style='color:#888888'><b>[]</b> says, 'Thank you for playing!'</span>", src), 1)
		src.add_fingerprint(usr)
		src.updateUsrDialog()
		if(mechanics) mechanics.fireOutgoing(mechanics.newSignal("machineUsed"))
		return

/obj/submachine/slot_machine/cursed
	name = "Slot Machine"
	desc = "Gambling for the damned."
	icon = 'icons/obj/gambling.dmi'
	icon_state = "slots-off"

	New()
		mechanics = new(src)
		mechanics.master = src
		mechanics.addInput("activate", "activateinput")
		..()

	attack_hand(var/mob/user as mob)
		user.machine = src
		if (src.working)
			var/dat = {"<B>Slot Machine</B><BR>
			<HR><BR>
			<B>Please wait!</B><BR>"}
			user.Browse(dat, "window=slotmachine;size=450x500")
			onclose(user, "slotmachine")
		else
			var/dat = {"<B>Slot Machine</B><BR>
			<HR><BR>
			Free to play - IF YOU DARE!<BR>
			[src.plays] attempts have been made today!<BR>
			<HR><BR>
			<A href='?src=\ref[src];ops=1'>Play!</A><BR>"}
			user.Browse(dat, "window=slotmachine;size=400x500")
			onclose(user, "slotmachine")

	Topic(href, href_list)
		if (get_dist(src, usr) > 1 || !isliving(usr) || iswraith(usr) || isintangible(usr))
			return
		if (usr.getStatusDuration("stunned") > 0 || usr.getStatusDuration("weakened") || usr.getStatusDuration("paralysis") > 0 || !isalive(usr) || usr.restrained())
			return

		if(href_list["ops"])
			var/operation = text2num(href_list["ops"])
			if(operation == 1) // Play
				if(src.working) return
				/*if (src.money < 0)
					for(var/mob/O in hearers(src, null))
						O.show_message(text("<b>[]</b> says, 'No prize money left!'", src), 1)
					return*/
				//src.money += 10
				src.plays += 1
				src.working = 1
				src.icon_state = "slots-on"
				//for(var/mob/O in hearers(src, null))
					//O.show_message(text("<b>[]</b> says, 'Let's roll!'", src), 1)
				var/roll = rand(1,101)

				playsound(src.loc, "sound/machines/ding.ogg", 50, 1)
				SPAWN_DBG(2.5 SECONDS)
					if (roll == 1)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span style='color:#888888'><b>[]</b> says, 'JACKPOT! [usr.name] has won their freedom!'</span>", src), 1)
						playsound(src.loc, "sound/voice/heavenly.ogg", 55, 1)
						usr.un_damn()
					else if(roll > 1 && roll <= 10 && istype(usr,/mob/living/carbon/human))
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span style='color:#888888'><b>[]</b> says, '[usr.name] has a limb ripped off by the machine!'</span>", src), 1)
						playsound(src.loc, "sound/machines/ping.ogg", 55, 1)
						var/mob/living/carbon/human/H = usr
						if(H.limbs.l_arm)
							H.limbs.l_arm.sever()
							H.unlock_medal("One Armed Bandit", 1) // only need to unlock here since it always checks for left arm first and generally there's no other way to lose limbs in hell
						else if(H.limbs.l_leg)
							H.limbs.l_leg.sever()
						else if(H.limbs.r_leg)
							H.limbs.r_leg.sever()
						else if(H.limbs.r_arm)
							H.limbs.r_arm.sever()
					else
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<span style='color:#888888'><b>[]</b> says, 'No luck!'</span>", src), 1)
					src.working = 0
					src.icon_state = "slots-off"
					updateUsrDialog()
		src.add_fingerprint(usr)
		src.updateUsrDialog()
		if(mechanics) mechanics.fireOutgoing(mechanics.newSignal("machineUsed"))
		return
