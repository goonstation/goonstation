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
					display_health_maptext(P.occupant, usr)
					update_medical_record(P.occupant)

			if (!iscarbon(A))
				return
			var/mob/living/carbon/C = A

			. = scan_health(C, 0, 1, visible = 1)
			display_health_maptext(C, usr)
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

		scan_atom(atom/A)
			var/mob/user = usr
			if (..())
				return
			. = scan_reagents(A, visible = TRUE)
			if (user.traitHolder.hasTrait("training_bartender"))
				var/eth_eq = get_ethanol_equivalent(user, A.reagents)
				if (eth_eq)
					. += "<br> [SPAN_REGULAR("You estimate there's the equivalent of <b>[eth_eq] units of ethanol</b> here.")]"

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
				return SPAN_ALERT("Messaging must be enabled to communicate with engineering kit.")
			var/obj/O = A
			var/mob/user = usr
			if (O.mechanics_interaction == MECHANICS_INTERACTION_BLACKLISTED)
				return
			var/scan_result = SEND_SIGNAL(A, COMSIG_ATOM_ANALYZE, src.master, user)
			if (scan_result != MECHANICS_ANALYSIS_SUCCESS && O.mechanics_interaction == MECHANICS_INTERACTION_SKIP_IF_FAIL)
				return
			animate_scanning(A, "#FFFF00")
			if (!scan_result || scan_result == MECHANICS_ANALYSIS_INCOMPATIBLE)
				return SPAN_ALERT("Unable to scan.")

			var/datum/computer/file/electronics_scan/theScan = new
			theScan.scannedPath = O.mechanics_type_override ? O.mechanics_type_override : O.type
			var/atom/atom_cast = theScan.scannedPath
			theScan.scannedName = initial(atom_cast.name)
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

	material_scan
		name = "Material Scanner"
		size = 2

		scan_atom(atom/A as mob|obj|turf|area)
			if(..())
				return

			if(!A.material)
				. = "No significant material found in \the [A]."
				return

			. = "<u>[capitalize(A.material.getName())]</u><br>[A.material.getDesc()]<br><br>"
			if (length(A.material.getMaterialProperties()))
				for(var/datum/material_property/mat in A.material.getMaterialProperties())
					var/value = A.material.getProperty(mat.id)
					. += "• [mat.getAdjective(A.material)] ([value])<br>"
			else
				. += "The material is completely unremarkable."

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
