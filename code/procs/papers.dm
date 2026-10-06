// procs for HTML stuff to put on papers, yay!

/proc/random_barcode(lines, barcolor) // Makes vertical lines with color (no #) for barcodes!
	var/barcode
	var/i
	for (i=0, i < lines, i++)
		var/line = {"<td width="[rand(1,8)]px" bgcolor="[barcolor]"></td> "}
		barcode += line
	return barcode
