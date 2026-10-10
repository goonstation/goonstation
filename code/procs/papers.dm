// procs for HTML stuff to put on papers, yay!

/proc/random_barcode(lines, barcolor) // Makes vertical lines with color (no #) for barcodes!
	for (var/i in 1 to lines)
		. += {"<td width="[rand(1, 8)]px" bgcolor="[barcolor]"></td> "}
