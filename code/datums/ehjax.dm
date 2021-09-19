/*********************************
EHJAX - Like ajax but for ~byond~
A framework for browser popups to interact with the byond server, async (client-side)
*********************************/


var/global/datum/ehjax/ehjax = new /datum/ehjax()

/datum/ehjax
	var/callbackName = "ehjaxCallback"
	var/list/allowedProcs = list("/proc/getBanApiFallback",
								"/proc/getWorldMins",
								"/datum/chui/proc/debug",
								"/datum/chui/proc/close",
								"/datum/chatOutput/proc/doneLoading",
								"/datum/chatOutput/proc/ping",
								"/datum/chatOutput/proc/handleContextMenu",
								"/datum/chatOutput/proc/analyzeClientData"
							)

	proc
		send(client/C, window, data)
			if (!C || !window || !data) return
			if (!isclient(C)) return
			if (istype(data, /list))
				data = json_encode(data)

			C << output("[data]", "[window]:[callbackName]")

		/**
			* Calls a proc from a javascript source and callsback with any data
			*
			* * href_list -> "proc" (string) The proc to call (no paths included)
			* * href_list -> "window" (string) The browser window name to send return data to (required for callback)
			* * href_list -> "param" (string) A url-encoded array of arguments to pass to the proc (e.g. `param[foo]=bar&param[bar]=foo`)
			* * href_list -> "type" (string) Type of proc to call. If none, assumes global proc.
			* * href_list -> "datum" (string) Requires type=datum. Name of the datum the proc belongs to (/datum/ path not required) Note: datum is relative to client ONLY.
			* * href_list -> "passClient" (boolean) Whether or not to send the client to the called proc
			*
			* * * return (string) If the call proc returns data and window is set, will send the proc return string to ehjaxCallback javascript function.
			*/
		topic(type, href_list, client/C)
			switch(type)
				if ("main")
					if (!href_list["proc"]) return 0
					var/windowName
					if (href_list["window"])
						windowName = href_list["window"]
					var/theProc = href_list["proc"]

					//Generate the full proc path to check against whitelist
					var/fullPath = ""
					if (href_list["datum"])
						fullPath = "/datum/[href_list["datum"]]"
					fullPath += "/proc/[theProc]"

					if (!(fullPath in src.allowedProcs))
						CRASH("EHJAX: Attempt to call disallowed proc: [strip_html(fullPath)] by user: [C?.key ? C.key : usr]")

					var/params[] = new()
					for (var/key in href_list)
						if (length(key) > 7 && findtext(key, "param"))
							var/subKey = copytext(key, 7, -1)
							var/item = href_list[key]
							params[subKey] = item

					if (href_list["passClient"] && (href_list["passClient"] == "1" || href_list["passClient"] == "true"))
						params += C

					var/data
					if (href_list["type"])
						var/callType = href_list["type"]
						switch (callType)
							if ("client")
								data = call(C, theProc)(arglist(params))
							if ("datum")
								var/datum = C.vars[href_list["datum"]]
								data = call(datum, theProc)(arglist(params))
							else
								data = call(fullPath)(arglist(params))
					else
						data = call(fullPath)(arglist(params))

					//This needs data to send back to the window.
					if (data && windowName)
						data = url_encode(data)
						src.send(C, windowName, data)

