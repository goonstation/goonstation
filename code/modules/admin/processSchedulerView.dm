var/global/datum/processSchedulerView/processSchedulerView

/datum/processSchedulerView

/datum/processSchedulerView/Topic(href, href_list)
	USR_ADMIN_ONLY
	if (!href_list["action"])
		return

	switch (href_list["action"])
		if ("kill")
			var/toKill = href_list["name"]
			processScheduler.killProcess(toKill)
			refreshProcessTable()
		if ("enable")
			var/toEnable = href_list["name"]
			processScheduler.enableProcess(toEnable)
			refreshProcessTable()
		if ("disable")
			var/toDisable = href_list["name"]
			processScheduler.disableProcess(toDisable)
			refreshProcessTable()
		if ("edit")
			var/toEdit = href_list["name"]
			processScheduler.editProcess(toEdit)
		if ("refresh")
			refreshProcessTable()

/datum/processSchedulerView/proc/refreshProcessTable()
	windowCall("handleRefresh", getProcessTable())

/datum/processSchedulerView/proc/windowCall(var/function, var/data = null)
	usr << output(data, "processSchedulerContext.browser:[function]")

/datum/processSchedulerView/proc/getProcessTable()
	var/text = "<table class=\"table table-striped\"><thead><tr><td>Name</td><td>Avg(s)</td><td>Last(s)</td><td>Highest(s)</td><td>Tickcount</td><td>Tickrate</td><td>State</td><td>Action</td></tr></thead><tbody>"
	// and the context of each
	for (var/list/data in processScheduler.getStatusData())
		text += "<tr>"
		text += "<td>[data["name"]]</td>"
		text += "<td class='text-right'>[num2text(data["averageRunTime"]/10,3)]</td>"
		text += "<td class='text-right'>[num2text(data["lastRunTime"]/10,3)]</td>"
		text += "<td class='text-right'>[num2text(data["highestRunTime"]/10,3)]</td>"
		text += "<td class='text-right'>[num2text(data["ticks"],4)]</td>"
		text += "<td class='text-right'>[data["schedule"]]</td>"
		text += "<td>[data["status"]]</td>"
		text += "<td><button type='button' class=\"btn kill-btn\" data-process-name=\"[data["name"]]\" id=\"kill-[data["name"]]\">Kill</button>"
		if (data["disabled"])
			text += "<button type='button' class=\"btn enable-btn\" data-process-name=\"[data["name"]]\" id=\"enable-[data["name"]]\">Enable</button>"
		else
			text += "<button type='button' class=\"btn disable-btn\" data-process-name=\"[data["name"]]\" id=\"disable-[data["name"]]\">Disable</button>"
		text += "<button type='button' class=\"btn edit-btn\" data-process-name=\"[data["name"]]\" id=\"edit-[data["name"]]\">Edit</button>"
		text += "</td>"
		text += "</tr>"

	text += "</tbody></table>"
	return text

/**
 * getContext
 * Outputs an interface showing stats for all processes.
 */
/datum/processSchedulerView/proc/getContext()
	var/text = {"<html><head>
		<title>Process Scheduler Detail</title>
		<link rel="stylesheet" href="[resource("css/bootstrap.min.css")]" />
		<script type="text/javascript">var ref = '\ref[src]';</script>
		<script type="text/javascript" src="[resource("js/json2.js")]"></script>
		<script type="text/javascript" src="[resource("js/jquery.min.js")]"></script>
		<script type="text/javascript" src="[resource("js/bootstrap.min.js")]"></script>
		<script type="text/javascript" src="[resource("js/processScheduler.js")]"></script>
		<style type="text/css">.btn { padding: 0; }</style>
	</head>
	<body>
		<div class="container-fluid">
		<h2>Process Scheduler</h2>
		<button type='button' id="btn-refresh" class="btn">Refresh</button>
		<h3>The process scheduler controls [processScheduler.getProcessCount()] loops.</h3>"}

	text += "<div id=\"processTable\">"
	text += getProcessTable()
	text += "</div></div></body></html>"

	usr.Browse(text, "window=processSchedulerContext;size=800x600")
