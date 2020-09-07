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
				master.scan_program = null
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
					update_medical_record(P.occupant)

			if (!iscarbon(A))
				return
			var/mob/living/carbon/C = A

			. = scan_health(C, 0, 1, visible = 1)
			update_medical_record(C)


	//Forensic scanner
	forensic_scan
		name = "Forensic Scan"
		size = 8

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

		scan_atom(atom/A as obj)
			if (..() || !istype(A, /obj))
				return

			var/obj/O = A
			if(istype(O,/obj/machinery/rkit))
				return

			if(O.mats == 0 || O.disposed || O.is_syndicate != 0)
				return "<span class='alert'>Unable to scan.</span>"

			if (!istype(master.host_program, /datum/computer/file/pda_program/os/main_os) || !master.host_program:message_on)
				return "<span class='alert'>Messaging must be on to communicate with engineering kit.</span>"

			animate_scanning(O, "#FFFF00")

			var/datum/computer/file/electronics_scan/theScan = new
			theScan.scannedName = initial(O.name)
			theScan.scannedPath = O.mechanics_type_override ? O.mechanics_type_override : O.type
			theScan.scannedMats = initial(O.mats)

			var/datum/signal/signal = get_free_signal()
			signal.source = src.master
			signal.transmission_method = 1

			if (mechanic_controls.rkit_addresses.len)
				last_address = pick(mechanic_controls.rkit_addresses)

			signal.data["address_1"] = last_address
			signal.data["command"] = "add"

			signal.data_file = theScan
			post_signal(signal)

/datum/computer/file/electronics_scan
	name = "scanfile"
	extension = "OSCN"
	var/scannedName = null
	var/scannedPath = null
	var/scannedMats = null

/datum/computer/file/genetics_scan
	name = "DNA Scan"
	extension = "GSCN"
	var/subject_name = null
	var/subject_uID = null
	var/list/dna_pool = list()

	disposing()
		if (dna_pool)
			dna_pool = null

		..()
