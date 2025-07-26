// A copy of all the evidence collected from a forensic scan
datum/forensic_scan
	var/datum/forensic_holder/holder = new()
	var/datum/forensic_scan/next_chain = null //! Allows scanning multiple objects at once
	var/scan_time = 0
	var/accuracy = 0 //! The quality of the scan

	var/report_title = "Unknown Forensic Analysis"

	New(var/atom/scan_target)
		..()
		src.scan_time = TIME
		if(scan_target)
			report_title = "Forensic Analysis of [scan_target]"
			scan_target.on_forensic_scan(src)

	proc/build_report()
		var/datum/forensic_report_builder/report_builder = new(src.report_title, src.scan_time)
		src.holder.report_text(src, report_builder)
		var/report = report_builder.compile_report()
		return report

	proc/add_data(var/datum/forensic_data/forensic_data, var/category = FORENSIC_GROUP_NOTES)
		src.holder.add_evidence(forensic_data, category)
		return

	proc/add_text(var/text, var/header = "Notes")
		if(!text)
			return
		var/datum/forensic_data/text/text_data = new(text, header)
		src.holder.add_evidence(text_data, FORENSIC_GROUP_TEXT)
		return

	proc/chain_scan_target(var/atom/chain_target)
		var/datum/forensic_scan/new_scan = new(chain_target)
		src.chain_scan(new_scan)

	proc/chain_scan(var/datum/forensic_scan/new_scan)
		if(new_scan == src)
			CRASH("Should not chain a forensic scan with itself.")
		if(!src.next_chain)
			src.next_chain = new_scan
		else
			src.next_chain.chain_scan(new_scan)

// Used to store text while building the forensic report
datum/forensic_report_builder
	var/list/list/report_lines = list()
	var/report_title = ""
	var/report_time = ""

	New(var/report_title, var/scan_time)
		..()
		src.report_title = report_title
		src.report_time = "[scan_time]"

	proc/add_line(var/evidence_text, var/header = FORENSIC_HEADER_NOTES)
		var/list/header_lines = src.report_lines[header]
		if(!header_lines)
			report_lines[header] = list()
			header_lines = src.report_lines[header]
		header_lines.Add(evidence_text)

	proc/compile_report()
		var/list/headers = list()
		for(var/header in src.report_lines)
			headers.Add(header)
		sortList(headers, PROC_REF(compare_header_priority))

		var/report = ""
		for(var/header in headers)
			report += SPAN_NOTICE("<li>[header]</li>")
			for(var/line in src.report_lines[header])
				report += "<li>[line]</li>"
		if(!report)
			report = "<li>No evidence detected.</li>"

		report = SPAN_SUCCESS("<li>[src.report_title]</li>") + report
		return report

	proc/compare_header_priority(var/headerA, var/headerB)
		var/priorityA = get_header_priority(headerA)
		var/priorityB = get_header_priority(headerB)
		if(priorityA == priorityB)
			return cmp_text_asc(headerA, headerB)
		return (priorityA > priorityB)

	proc/get_header_priority(var/header)
		switch(header)
			if(FORENSIC_HEADER_FINGERPRINTS)
				return 100
			if(FORENSIC_HEADER_DNA)
				return 90
			if(FORENSIC_HEADER_NOTES)
				return 20
			else
				return 50

