//CONTENTS:
//Base scanner stuff
//Health scanner
//Forensic scanner
//Reagent scanner
//Plant scanner

/datum/computer/file/pda_program/scan
	return_text()
		return src.return_text_header()

	proc/scan_atom(atom/A as mob|obj|turf|area)

		if( !A || (!src.holder) || (!src.master))
			return 1

		if((!istype(holder)) || (!istype(master)))
			return 1

		if(!(holder in src.master.contents))
			if(master.scan_program == src)
				src.master.set_scan_program(null)
			return 1

		return 0

	//Health analyzer program
	health_scan
		name = "Health Scan"
		size = 8

		scan_atom(atom/A as mob|obj|turf|area)
			if (..())
				return

			if (istype(A, /obj/machinery/clonepod))
				var/obj/machinery/clonepod/P = A
				if(P.occupant)
					scan_health(P.occupant, 0, 1)
					scan_health_overhead(P.occupant, usr)
					update_medical_record(P.occupant)

			if (!iscarbon(A))
				return
			var/mob/living/carbon/C = A

			. = scan_health(C, 0, 1, visible = 1)
			scan_health_overhead(C, usr)
			update_medical_record(C)


	//Forensic scanner
	forensic_scan
		name = "Forensic Scan"
		size = 6

		scan_atom(atom/A as mob|obj|turf|area)
			if(..())
				return
			. = scan_forensic(A, visible = 1) // Moved to scanprocs.dm to cut down on code duplication (Convair880).

	//Reagent scanning program
	reagent_scan
		name = "Reagent Scan"
		size = 6

		scan_atom(atom/A as mob|obj|turf|area)
			if (..())
				return
			. = scan_reagents(A, visible = 1)

	//Plant scanner
	plant_scan
		name = "Plant Scan"
		size = 6

		scan_atom(atom/A as mob|obj|turf|area)
			if(..())
				return
			. = scan_plant(A, usr, visible = 1) // Moved to scanprocs.dm to cut down on code duplication (Convair880).

	electronics
		name = "Device Analyzer"
		size = 16
		var/last_address = "02000000"

		on_set_scan(obj/item/device/pda2/pda)
			pda.AddComponent(
				/datum/component/packet_connected/radio, \
				"ruckkit",\
				FREQ_RUCK, \
				pda.net_id, \
				null, \
				FALSE, \
				null, \
				FALSE \
			)


		on_unset_scan(obj/item/device/pda2/pda)
			qdel(get_radio_connection_by_id(pda, "ruckkit"))

		scan_atom(atom/A)
			if (..() || !isobj(A) || !ismob(usr))
				return
			if (!istype(master.host_program, /datum/computer/file/pda_program/os/main_os) || !master.host_program:message_on)
				return "<span class='alert'>Messaging must be enabled to communicate with engineering kit.</span>"
			var/obj/O = A
			var/mob/user = usr
			if (O.mechanics_interaction == MECHANICS_INTERACTION_BLACKLISTED)
				return
			var/scan_result = SEND_SIGNAL(A, COMSIG_ATOM_ANALYZE, src.master, user)
			if (scan_result != MECHANICS_ANALYSIS_SUCCESS && O.mechanics_interaction == MECHANICS_INTERACTION_SKIP_IF_FAIL)
				return
			animate_scanning(A, "#FFFF00")
			if (!scan_result || scan_result == MECHANICS_ANALYSIS_INCOMPATIBLE)
				return "<span class='alert'>Unable to scan.</span>"

			var/datum/computer/file/electronics_scan/theScan = new
			theScan.scannedName = initial(O.name)
			theScan.scannedPath = O.mechanics_type_override ? O.mechanics_type_override : O.type
			var/typeinfo/obj/typeinfo = O.get_typeinfo()
			theScan.scannedMats = typeinfo.mats

			var/datum/signal/signal = get_free_signal()
			signal.source = src.master
			signal.transmission_method = 1

			signal.data["address_tag"] = "TRANSRKIT"
			signal.data["command"] = "add"

			signal.data_file = theScan
			post_signal(signal, "ruckkit")

	medrecord_scan
		name = "MedTrak Scanner"
		size = 2

		scan_atom(atom/A as mob|obj|turf|area)
			if (..())
				return

			if (istype(A, /obj/machinery/clonepod))
				var/obj/machinery/clonepod/P = A
				if(P.occupant)
					scan_medrecord(src.master, P.occupant)
					update_medical_record(P.occupant)

			if (!iscarbon(A))
				return
			var/mob/living/carbon/C = A

			. = scan_medrecord(src.master, C, visible = 1)
			update_medical_record(C)

	secrecord_scan
		name = "Secmate Scanner"
		size = 2

		scan_atom(atom/A as mob|obj|turf|area)
			if (..())
				return

			if (!iscarbon(A))
				return
			var/mob/living/carbon/C = A

			. = scan_secrecord(src.master, C, visible = 1)

/datum/computer/file/electronics_scan
	name = "scanfile"
	extension = "OSCN"
	var/scannedName = null
	var/scannedPath = null
	var/scannedMats = null

/datum/computer/file/electronics_bundle
	name = "Ruckingenur Data"
	extension = "DSCN"
	var/datum/mechanic_controller/ruckData = null
	var/target = null
	var/known_rucks = null

/datum/computer/file/genetics_scan
	name = "DNA Scan"
	extension = "GSCN"
	var/subject_name = null
	var/subject_uID = null
	var/subject_stability = null
	var/scanned_at = null
	var/list/datum/bioEffect/dna_pool = null
	var/list/datum/bioEffect/dna_active = null

	disposing()
		src.dna_pool = null
		src.dna_active = null
		..()
