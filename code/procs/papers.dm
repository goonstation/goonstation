// procs for HTML stuff to put on papers, yay!

/// Passes a string through a base8 md5 hash to generate widths which are then assembled into a barcode.
/proc/string_to_barcode(text, bar_count = 20, bar_colour = "453425")
	var/list/barcode = list()
	barcode += "<table height='50px' cellspacing='2px'><tr>"

	var/list/base8 = splittext(global.base8md5(text), "")
	for (var/i in 1 to bar_count)
		var/size = text2num(base8[i], 8) + 1
		barcode += "<td width='[size]px' bgcolor='[bar_colour]'></td> "

	barcode += "</td></tr></table>"
	return barcode.Join()

/// `md5()`, but in base8.
/proc/base8md5(text)
	var/base16 = md5(text)
	var/list/base8 = list()

	// As BYOND cannot handle an integer the size of 32 base16 digits, do the conversion in small chunks.
	// This works because 3 base16 digits correspond to 4 base8 digits.
	for (var/i in 1 to 30 step 3)
		var/chunk = copytext(base16, i, i + 3)
		// Convert the base 16 string to a binary number.
		chunk = text2num(chunk, 16)
		// Convert the binary number to a base 8 string.
		chunk = num2text(chunk, 0, 8)
		// Readd any leading zeros.
		chunk = global.add_zero(chunk, 4)

		base8 += chunk

	return base8.Join()
