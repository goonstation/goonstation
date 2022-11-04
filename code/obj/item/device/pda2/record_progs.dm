//CONTENTS:
//Generic records
//Security records
//Medical records

/datum/computer/file/pda_program/records
	var/mode = 0
	var/datum/db_record/active1 = null //General
	var/datum/db_record/active2 = null //Security/Medical/Whatever

//To-do: editing arrest status/etc from pda.
/datum/computer/file/pda_program/records/security
	name = "Security Records"
	size = 8

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()

		switch(src.mode)
			if(0)
				dat += "<h4>Security Record List</h4>"

				for (var/datum/db_record/R as anything in data_core.general.records)
					dat += "<a href='byond://?src=\ref[src];select_rec=\ref[R]'>[R["id"]]: [R["name"]]<br>"

				dat += "<br>"

			if(1)

				dat += "<h4>Security Record</h4>"

				dat += "<a href='byond://?src=\ref[src];mode=0'>Back</a><br>"

				if (istype(src.active1, /datum/db_record) && data_core.general.has_record(src.active1))
					dat += "Full Name: [src.active1["full_name"]] ID: [src.active1["id"]]<br>"
					dat += "Sex: [src.active1["sex"]]<br>"
					dat += "Age: [src.active1["age"]]<br>"
					dat += "Fingerprint: [src.active1["fingerprint"]]<br>"
					dat += "DNA: [src.active1["dna"]]<br>"
					dat += "Physical Status: [src.active1["p_stat"]]<br>"
					dat += "Mental Status: [src.active1["m_stat"]]<br>"
				else
					dat += "<b>Record Lost!</b><br>"

				dat += "<br>"

				dat += "<h4>Security Data</h4>"
				if (istype(src.active2, /datum/db_record) && data_core.security.has_record(src.active2))
					dat += "Criminal Status: [src.active2["criminal"]]<br>"
					dat += "SecHUD Flag: [src.active2["sec_flag"]]<br>"

					dat += "Minor Crimes: [src.active2["mi_crim"]]<br>"
					dat += "Details: [src.active2["mi_crim"]]<br><br>"

					dat += "Major Crimes: [src.active2["ma_crim"]]<br>"
					dat += "Details: [src.active2["ma_crim_d"]]<br><br>"

					dat += "Important Notes:<br>"
					dat += "[src.active2["notes"]]"
				else
					dat += "<b>Record Lost!</b><br>"

				dat += "<br>"

		return dat

	Topic(href, href_list)
		if(..())
			return

		if(href_list["mode"])
			var/newmode = text2num_safe(href_list["mode"])
			src.mode = max(newmode, 0)

		else if(href_list["select_rec"])
			var/datum/db_record/R = locate(href_list["select_rec"])
			var/datum/db_record/S = locate(href_list["select_rec"])

			if (data_core.general.has_record(R))
				S = data_core.security.find_record("id", R["id"])
				if(!S) S = data_core.security.find_record("name", R["name"])
				if(!S) S = locate(href_list["select_rec"])

				src.active1 = R
				src.active2 = S

				src.mode = 1

		src.master.add_fingerprint(usr)
		src.master.updateSelfDialog()
		return

/datum/computer/file/pda_program/records/medical
	name = "Medical Records"
	size = 8

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()

		switch(src.mode)
			if(0)

				dat += "<h4>Medical Record List</h4>"
				for (var/datum/db_record/R as anything in data_core.general.records)
					dat += "<a href='byond://?src=\ref[src];select_rec=\ref[R]'>[R["id"]]: [R["name"]]<br>"
				dat += "<br>"

			if(1)

				dat += "<h4>Medical Record</h4>"

				dat += "<a href='byond://?src=\ref[src];mode=0'>Back</a><br>"

				if (istype(src.active1, /datum/db_record) && data_core.general.has_record(src.active1))
					dat += "Full Name: [src.active1["full_name"]] ID: [src.active1["id"]]<br>"
					dat += "Sex: [src.active1["sex"]]<br>"
					dat += "Age: [src.active1["age"]]<br>"
					dat += "Fingerprint: [src.active1["fingerprint"]]<br>"
					dat += "DNA: [src.active1["dna"]]<br>"
					dat += "Physical Status: [src.active1["p_stat"]]<br>"
					dat += "Mental Status: [src.active1["m_stat"]]<br>"
				else
					dat += "<b>Record Lost!</b><br>"

				dat += "<br>"

				dat += "<h4>Medical Data</h4>"
				if (istype(src.active2, /datum/db_record) && data_core.medical.has_record(src.active2))
					dat += "Current Health: [src.active2["h_imp"]]<br><br>"

					dat += "Blood Type: [src.active2["bioHolder.bloodType"]]<br><br>"

					dat += "Minor Disabilities: [src.active2["mi_dis"]]<br>"
					dat += "Details: [src.active2["mi_dis_d"]]<br><br>"

					dat += "Major Disabilities: [src.active2["ma_dis"]]<br>"
					dat += "Details: [src.active2["ma_dis_d"]]<br><br>"

					dat += "Allergies: [src.active2["alg"]]<br>"
					dat += "Details: [src.active2["alg_d"]]<br><br>"

					dat += "Current Diseases: [src.active2["cdi"]]<br>"
					dat += "Details: [src.active2["cdi_d"]]<br><br>"

					dat += "Traits: [src.active2["traits"]]<br><br>"

					dat += "Important Notes: [src.active2["notes"]]<br>"
				else
					dat += "<b>Record Lost!</b><br>"

				dat += "<br>"

		return dat

	Topic(href, href_list)
		if(..())
			return

		if(href_list["mode"])
			var/newmode = text2num_safe(href_list["mode"])
			src.mode = max(newmode, 0)

		else if(href_list["select_rec"])
			var/datum/db_record/R = locate(href_list["select_rec"])
			var/datum/db_record/M = locate(href_list["select_rec"])

			if (data_core.general.has_record(R))
				M = data_core.medical.find_record("id", R["id"])
				if(!M) M = data_core.medical.find_record("name", R["name"])
				if(!M) M = locate(href_list["select_rec"])

				src.active1 = R
				src.active2 = M

				src.mode = 1

		src.master.add_fingerprint(usr)
		src.master.updateSelfDialog()
		return
