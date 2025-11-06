// A copy of all the evidence collected from a forensic scan
/datum/forensic_scan
	var/datum/forensic_holder/holder = new()
	var/datum/forensic_scan/next_chain = null //! Allows scanning multiple objects at once
	var/scan_time = 0
	var/accuracy = 0 //! The quality of the scan
	var/is_admin = FALSE

	var/report_title = "Unknown Forensic Analysis"

	New(var/atom/scan_target)
		..()
		src.scan_time = TIME
		if(scan_target)
			report_title = "Forensic Analysis of <b>[scan_target]</b>"
			scan_target.on_forensic_scan(src)

	proc/build_report(var/print_hyperlink = "")
		var/datum/forensic_report/report = new(src.report_title, src.scan_time)
		src.holder.report_text(src, report)
		var/report_scan = report.compile_report()
		var/report_chain = next_chain?.build_report()
		if(report_chain)
			report_chain = "<li></li>" + report_chain
		return report_scan + report_chain

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

// The results of a forensics scan in text format.
/datum/forensic_report
	/// Associative list. Keys are header names. Each element is a list of evidence under that header in text format.
	var/list/list/report_lines = list()
	var/title = ""

	New(var/title)
		..()
		src.title = title

	proc/add_line(var/evidence_text, var/header = FORENSIC_HEADER_NOTES)
		var/list/header_lines = src.report_lines[header]
		if(!header_lines)
			report_lines[header] = list()
			header_lines = src.report_lines[header]
		header_lines.Add(evidence_text)

	/// Collect all the lines into a single string
	proc/compile_report(var/print_hyperlink = "")
		var/list/headers = list()
		for(var/header in src.report_lines)
			headers.Add(header)
		sortList(headers, /proc/cmp_forensic_headers)

		var/report = ""
		// Go through headers in order
		for(var/i=1; i<= headers.len; i++)
			report += SPAN_NOTICE("[headers[i]]")
			report += "<ul style='list-style-type: disc; margin-top: 0; margin-left:-5px'>"
			for(var/line in src.report_lines[headers[i]])
				report += "<li>[line]</li>" // Indent line and add a bullent point
			report += "</ul>"
		if(!report)
			report = "<li>No evidence detected.</li>"
		var/report_title = SPAN_SUCCESS(src.title)
		if(print_hyperlink)
			report_title += ": [print_hyperlink]"
		report = "[report_title]<br>" + report
		return report

/proc/cmp_forensic_headers(var/headerA, var/headerB)
	var/priorityA = get_header_priority(headerA)
	var/priorityB = get_header_priority(headerB)
	if(priorityA == priorityB)
		return cmp_text_asc(headerA, headerB)
	return (priorityA < priorityB)

/proc/get_header_priority(var/header)
	switch(header)
		if(FORENSIC_HEADER_FINGERPRINTS)
			return 100
		if(FORENSIC_HEADER_DNA)
			return 90
		if(FORENSIC_HEADER_NOTES)
			return 20
		else
			return 50

