
/// Uppercases first letter
/proc/ucfirst(str)
	return "[uppertext(copytext(str, 1))][copytext(str, 2)]"

/// Uppercases first letter of every word
/proc/ucfirsts(str)
	var/list/split = splittext(str, " ")
	. = list()
	for (var/P in split)
		. += ucfirst(P)
	. = jointext(., " ")

var/global/list/FrozenAccounts = list()

/proc/list_frozen()
	for (var/A in FrozenAccounts)
		boutput(usr, "[A]: [length(FrozenAccounts[A])] borrows")


/proc/plotBarGraph(list/points, base_text, width = 400, height = 400)
	var/list/output = list()
	output += "<table style='border:1px solid black; border-collapse: collapse; width: [width]px; height: [height]px'>"
	if (points.len && height > 20 && width > 20)
		var/min = points[1]
		var/max = points[1]
		for (var/v in points)
			if (v < min)
				min = v
			if (v > max)
				max = v
		var/cells = (height - 20) / 20
		if (cells > round(cells))
			cells = round(cells) + 1
		var/diff = max - min
		var/ost = diff / cells
		if (min > 0)
			min = max(min - ost, 0)
		diff = max - min
		ost = diff / cells
		var/cval = max
		var/cwid = width / (points.len + 1)
		for (var/y = cells, y > 0, y--)
			if (y == cells)
				output += "<tr>"
			else
				output += "<tr style='border:none; border-top:1px solid #00ff00; height: 20px'>"
			for (var/x = 0, x <= points.len, x++)
				if (x == 0)
					output += "<td style='border:none; height: 20px; width: [cwid]px; font-size:10px; color:#00ff00; background:black; text-align:right; vertical-align:bottom'>[round(cval - ost)]</td>"
				else
					var/v = points[x]
					if (v >= cval)
						output += "<td style='border:none; height: 20px; width: [cwid]px; background:#0000ff'>&nbsp;</td>"
					else
						output += "<td style='border:none; height: 20px; width: [cwid]px; background:black'>&nbsp;</td>"
			output += "</tr>"
			cval -= ost
		output += "<tr><td style='font-size:10px; height: 20px; width: 100%; background:black; color:green; text-align:center' colspan='[points.len + 1]'>[base_text]</td></tr>"
	else
		output += "<tr><td style='width:[width]px; height:[height]px; background: black'></td></tr>"
		output += "<tr><td style='font-size:10px; background:black; color:green; text-align:center'>[base_text]</td></tr>"

	return "[jointext(output, "")]</table>"

