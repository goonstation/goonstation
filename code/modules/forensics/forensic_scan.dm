// A copy of all the evidence collected from a forensic scan
/datum/forensic_scan
	var/datum/forensic_holder/holder = new()
	var/datum/forensic_scan/next_chain = null //! Allows scanning multiple objects at once
	var/scan_time = 0
	var/accuracy = 0 //! The quality of the scan
	var/is_admin = FALSE
	var/list/scan_effects = list()

	var/report_title = "Unknown Forensic Analysis"

	New(var/atom/scan_target)
		..()
		src.scan_time = TIME
		if(scan_target)
			report_title = "Forensic Analysis of <b>[scan_target]</b>"
			scan_target.on_forensic_scan(src)

	proc/build_report(var/print_hyperlink = "", var/compress = FALSE)
		var/datum/forensic_report/report = new(src, src.report_title)
		src.holder.report_text(src, report)
		var/report_scan = report.compile_report(compress = compress)
		var/report_chain = next_chain?.build_report(null, compress)
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

	proc/add_effect(var/effect_id)
		src.scan_effects += effect_id

	proc/has_effect(var/effect_id)
		return src.scan_effects.Find(effect_id)

// The results of a forensics scan in text format.
/datum/forensic_report
	/// Associative list. Keys are header names. Each element is a list of evidence under that header in text format.
	var/datum/forensic_scan/scan
	var/list/list/report_lines = list()
	var/title = ""

	New(var/datum/forensic_scan/scan, var/title)
		..()
		src.scan = scan
		src.title = title

	proc/add_line(var/evidence_text, var/header = FORENSIC_HEADER_NOTES)
		var/list/header_lines = src.report_lines[header]
		if(!header_lines)
			report_lines[header] = list()
			header_lines = src.report_lines[header]
		header_lines.Add(evidence_text)

	/// Collect all the lines into a single string
	proc/compile_report(var/print_hyperlink = "", var/compress = FALSE)
		var/list/headers = list()
		for(var/header in src.report_lines)
			headers.Add(header)
		sortList(headers, /proc/cmp_forensic_headers)

		var/report = ""
		// Go through headers in order
		for(var/i=1; i<= headers.len; i++)
			report += SPAN_NOTICE("[headers[i]]") + compile_report_header(headers[i], compress)
			//for(var/line in src.report_lines[headers[i]])
			//	report += "<li style='padding-left:12px'>[line]</li>" // Indent line and add a bullet point
		if(!report)
			report = "<ul style='margin-top:0px;padding-left:25px'><li>No evidence detected.</li></ul>"

		var/report_title = SPAN_SUCCESS(src.title)
		if(print_hyperlink)
			report_title += ": [print_hyperlink]"
		report = "[report_title]<br>" + report
		return report

	proc/compile_report_header(var/header, var/compress)
		// Check if there should be columns and how many
		var/column_count = 1
		for(var/line in src.report_lines[header])
			var/col_count = findtext(line, ";") + 1
			if(col_count > column_count)
				column_count = col_count
		if(column_count > 1)
			return compile_report_columns(src.report_lines[header], column_count)
		else if(compress && header == FORENSIC_HEADER_FINGERPRINTS && !src.scan.has_effect("effect_silver_nitrate"))
			return compile_report_compress(header, 2)
		else
			var/header_text = "<ul style='margin-top:0px;padding-left:20px'>"
			for(var/line in src.report_lines[header])
				header_text += "<li style='padding-left:0px'>[line]</li>" // Indent line and add a bullet point
			return "[header_text]</ul>"

	proc/compile_report_columns(var/list/lines, var/column_count, var/bullet_pts = FALSE)
		// There is probably a better way way to do this formatting
		var/text_header = "<table style='border-spacing: -5px'><ul style='margin-top:-13px;padding-left:20px'>"
		for(var/line in lines)
			text_header += "<tr>"
			var/list/row_text = splittext(line, ";")
			var/current_column = 1
			for(var/text in row_text)
				var/style = "padding-left:20px;padding-right:10px"
				if(current_column != column_count)
					style += ";border-right:1px solid white"
				if(current_column == 1 || bullet_pts)
					text_header += "<td style='[style]'><li>[text]</li></td>"
				else
					text_header += "<td style='[style]'>[text]</td>"
				current_column++
			text_header += "</tr>"
		return "[text_header]</ul></table>"

	proc/compile_report_compress(var/header, var/lines_per_row = 2)
		var/list/row_text = list()

		// Combine multiple lines into rows
		var/counter = 1
		var/current_row = ""
		if(src.report_lines[header].len < lines_per_row)
			lines_per_row = src.report_lines[header].len
		for(var/line in src.report_lines[header])
			if(current_row)
				current_row += " ; [line]"
			else
				current_row = line
			if(counter == lines_per_row)
				counter = 0
				row_text += current_row
				current_row = ""
			counter++
		if(current_row)
			row_text += current_row
		return compile_report_columns(row_text, lines_per_row, TRUE)


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

