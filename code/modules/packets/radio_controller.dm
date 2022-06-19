var/global/datum/controller/radio/radio_controller

/datum/controller/radio
	var/list/datum/radio_frequency/frequencies = list()

	proc/get_frequency(freq)
		RETURN_TYPE(/datum/radio_frequency)
		if(isnum(freq))
			freq = "[freq]"
		. = frequencies[freq]
		if(!.)
			. = new/datum/radio_frequency(freq)
			frequencies[freq] = .

	proc/debug_window(client/cl)
		var/list/html = list()
		html += "<title>Radio Controller</title>"
		html += @{"<style>
table {
  font-family: Arial, Helvetica, sans-serif;
  border-collapse: collapse;
  width: 100%;
}
td, th {
  border: 3px solid #ddd;
  padding: 3px;
}
tr:nth-child(even){background-color: #f2f2f2;}
tr:hover {background-color: #ddd;}
th {
  padding-top: 12px;
  padding-bottom: 12px;
  text-align: left;
  background-color: #666;
  color: white;
}
th a { color: #ddf; }
</style>
<script>
function sortTable(n) {
  var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
  table = document.getElementById("table");
  switching = true;
  dir = "asc";
  while (switching) {
    switching = false;
    rows = table.rows;
    for (i = 1; i < (rows.length - 1); i++) {
      shouldSwitch = false;
      x = rows[i].getElementsByTagName("TD")[n];
      y = rows[i + 1].getElementsByTagName("TD")[n];
      if (dir == "asc") {
        if (parseFloat(x.innerHTML) > parseFloat(y.innerHTML)) {
          shouldSwitch = true;
          break;
        }
      } else if (dir == "desc") {
        if (parseFloat(x.innerHTML) < parseFloat(y.innerHTML)) {
          shouldSwitch = true;
          break;
        }
      }
    }
    if (shouldSwitch) {
      rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
      switching = true;
      switchcount ++;
    } else {
      if (switchcount == 0 && dir == "asc") {
        dir = "desc";
        switching = true;
      }
    }
  }
}
</script>"}
		html += "<h1>Radio Controller</h1><br>"
		html += "<table id='table'>"
		var/first_row = TRUE
		for(var/freq_key as anything in frequencies)
			var/datum/radio_frequency/freq = frequencies[freq_key]
			var/datum/packet_network/net = freq.packet_network
			var/list/data = net.brief_debug_info()
			if(first_row)
				first_row = FALSE
				var/i = 0
				html += "<thead><tr>"
				for(var/key in data)
					html += "<th onclick='sortTable([i++])'>[key]</th>"
				html += "</tr></thead></thead><tbody>"
			html += "<tr>"
			var/first_col = TRUE
			for(var/key in data)
				var/value = data[key]
				if(first_col)
					first_col = FALSE
					html += "<td><a href='byond://?src=\ref[net];debug_window=1'>[value]</a></td>"
				else
					html += "<td>[value]</td>"
			html += "</tr>"
		html += "</tbody></table>"
		cl.Browse(jointext(html, ""), "window=radio_controller_\ref[src];size=500x700")


/client/proc/dbg_radio_controller()
	set name = "Inspect Radio Frequencies"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	ADMIN_ONLY

	global.radio_controller.debug_window(src)
