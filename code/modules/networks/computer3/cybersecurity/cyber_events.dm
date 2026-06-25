var/list/hashchars = list("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f")
var/list/vulncomchars = list("#", "!", "@", "$", "%", "&", "*")

proc/generateHash(charlist, amt)
	var/hash = ""
	for (var/I in 1 to amt)
		hash += pick(charlist)
	return hash

var/global/vulncom = generateHash(vulncomchars, 8)// for signal.data["command"], initiates worm file download and execution in a ThinkDos
var/global/list/cyberintel_articles = list() // used by cybersecurity_machines.dm to actually display them
var/global/round_apt

/datum/controller/process/hackevents

	var/apt_struck = FALSE // if APT already hit the network (relevant article appears only once)
	var/datum/cyberintel/threatgroup/apt = null // round APT (10% chance)
	var/list/apts = list(
		/datum/cyberintel/threatgroup/syndira,
		/datum/cyberintel/threatgroup/plasmasteel
	)

	var/list/threatpool = list()
	var/list/threatpoolfiller = list() // for irrelevant articles

	var/list/malware_lowpop = list(
		new /datum/computer/file/terminal_program/malware/cluwnebash,
		new /datum/computer/file/terminal_program/malware/background/electrum,
	)
	var/list/malware = list(
		new /datum/computer/file/terminal_program/malware/cluwnebash,
		new /datum/computer/file/terminal_program/malware/background/electrum,
		new /datum/computer/file/terminal_program/malware/background/electrum/electrumx,
	)


	proc/randomId(n)
		var/num = ""
		for (var/i in 1 to n)
			num += "[rand(0,9)]"
		return num


	proc/generateThreats(amt = rand(8,10))
		for(var/i in 1 to amt)
			var/datum/cyberintel/threatgroup/A = new
			A.name = "Threat [prob(50) ? "Group-" : "Actor-"][randomId(4)]"
			if(alive_player_count() < 20)
				A.malware = pick(malware)
			else // lowpop
				A.malware = pick(malware_lowpop)
			switch(rand(1,7))
				if(1)
					A.malware.worm = 1
				if(2)
					A.malware.cworm = 1
				if(3)
					A.malware.mworm = 1
				if(4)
					A.malware.mask = 1
				if(5)
					A.malware.perst = 1
				if(6)
					A.malware.ghost = 1
				if(7)
					A.malware.aware = 1

			A.hash = generateHash(hashchars, 8)
			A.malware.hash = A.hash
			threatpool += A


	proc/generateThreatsIr(amt = rand(2,4)) // irrelevant (to put you off-guard :) )
		for(var/i in 1 to amt)
			var/datum/cyberintel/threatgroup/A = new
			A.name = "Threat [prob(50) ? "Group-" : "Actor-"][randomId(4)]"
			A.malware = pick(malware)
			A.hash = generateHash(hashchars, 8)
			threatpoolfiller += A


	proc/generateSpoofNames()
		return "[prob(50) ? pick_string_autokey("names/first_male.txt") : pick_string_autokey("names/first_female.txt")] [pick_string_autokey("names/last.txt")]"


	proc/generateArticle(eventgroup, malwarestrain, hash, relevant)
		var/datum/cyberintel/article/A = new
		A.relevant = relevant
		A.generateAuthor()
		A.formatSpacetime()
		A.generateArticle(eventgroup, malwarestrain, hash, relevant)
		cyberintel_articles += A

		// PDA update
		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.data["command"] = "text_message"
		signal.data["sender_name"] = "CYBER-MAILBOT"
		signal.data["group"] = MGA_CYBERINTEL
		signal.data["message"] = "Cyberintel updated."
		signal.data["sender"] = "00000000"
		signal.data["address_1"] = "00000000"

		radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(signal)


	proc/hackevent(eventgroup, eventmalware)
		var/datum/computer/file/terminal_program/malware/evmal = eventmalware
		var/picked = FALSE
		for_by_tcl(W, /obj/machinery/communications_dish)
			if(isnull(W) || get_z(W) != Z_LEVEL_STATION || picked == TRUE)
				return
			W.post_status("ping", "command", vulncom, "device", "PNET_COM_ARRAY", "netid", W.net_id) // collects targets

			SPAWN(5 SECONDS) // wait for targets to fill up
				if (isnull(W.dishtargets) || !length(W.dishtargets))
					return

				var/target = pick(W.dishtargets)
				// login spoof packet	// copied from malware.dm, don't know if you can make this more efficient
				var/datum/signal/loginspoof = get_free_signal()
				loginspoof.data["command"] = "card_authed"
				loginspoof.data["registered"] = generateSpoofNames()
				loginspoof.data["assignment"] = "Janitor" // do more of these so packet sniffing is less suspicious
				loginspoof.data["access"] = "34"
				loginspoof.data["address_1"] = target
				W.link.post_signal(W, loginspoof)

				SPAWN(1)
					var/datum/signal/wormsig = get_free_signal()
					wormsig.transmission_method = TRANSMISSION_WIRE
					wormsig.data["address_1"] = target
					wormsig.data["command"] = vulncom // vulnerability command, used in base_os (ThinkDos)
					wormsig.data_file = eventmalware
					W.link.post_signal(W, wormsig)

				W.dishtargets = list() // reset the list to avoid duplicates

		if(prob(10))
			var/list/targets = list()
			for_by_tcl(C, /obj/item/peripheral/network/omni)
				if(isnull(C) || get_z(C) != Z_LEVEL_STATION)
					return
				targets += C.net_id
			for_by_tcl(C, /obj/item/peripheral/network/radio)
				if(isnull(C) || get_z(C) != Z_LEVEL_STATION)
					return
				targets += C.net_id

			var/datum/signal/wormsig = get_free_signal()
			wormsig.transmission_method = TRANSMISSION_RADIO
			wormsig.data["address_1"] = pick(targets)
			wormsig.data["command"] = vulncom // vulnerability command, used in base_os (ThinkDos)
			evmal.wless = 1
			wormsig.data_file = evmal
			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, wormsig)

	setup()
		name = "Hack Event"
		schedule_interval = 6 MINUTES
		schedule_jitter = 4 MINUTES
		src.generateThreats()
		var/pop_check = 0
		for (var/mob/living/carbon/human/H as anything in global.mobs)
			if (H.client && !H.mind?.is_antagonist() && !isVRghost(H) && H.client.preferences.be_misc && isalive(H)) //using "misc" prefs for now
				pop_check += H
		if (pop_check <= 20)
			return
		if(prob(10) && alive_player_count() > 20)
			apt = pick(apts)
			round_apt = apt.name // used by roundstart threat report
			threatpool += apt

	doWork()
		if(!isnull(apt) && prob(10)) // APT strike
			if (global.ticker.round_elapsed_ticks < 4800) // ensure 8 minutes passed
				return
			if (apt_struck == FALSE)
				src.generateArticle(apt.name, apt.malware.name, apt.hash, TRUE)
				apt_struck = TRUE

			SPAWN(rand(2,5) MINUTES)
				src.hackevent(apt, apt.malware)
		else
			var/datum/cyberintel/threatgroup/eventgroup = pick(threatpool)
			if(prob(90))
				src.generateArticle(eventgroup.name, eventgroup.malware.name, eventgroup.hash, TRUE)
			SPAWN(rand(2,5) MINUTES)
				src.hackevent(eventgroup, eventgroup.malware)


/datum/controller/process/hackevents/irrelevant
	setup()
		name = "Irrelevant Article Event"
		schedule_interval = 6 MINUTES
		schedule_jitter = 4 MINUTES
		src.generateThreatsIr()
	doWork()
		var/datum/cyberintel/threatgroup/eventgroup = pick(threatpoolfiller)
		var/datum/cyberintel/threatgroup/eventmalware = eventgroup.malware

		src.generateArticle(eventgroup.name, eventmalware.name, null, FALSE)
