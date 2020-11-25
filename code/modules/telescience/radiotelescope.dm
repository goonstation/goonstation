/* outdated
/obj/machinery/computer/telescope
	name = "quantum telescope"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer_generic"

	var/mob/using = null

	var/tracking_id = "" //id of the event we're tracking/targeting.

	New()
		..()

	attack_ai(mob/user as mob)
		return attack_hand(user)

	attack_hand(mob/user as mob)
		if(status & (BROKEN|NOPOWER))
			return

		if(using && (!using.client || using.client.inactivity >= 1200 || get_dist(src, using) > 1))
			using.Browse(null, "window=telescope;override_setting=1")
			using = null

		if(using && using != user)
			boutput(user, "<span class='alert'>Somebody is already using that machine.</span>")
			return

		using = user

		src.add_dialog(user)
		add_fingerprint(user)
		user.Browse(grabResource("html/quantumTelescope.html"), "window=telescope;size=800x435;can_resize=0;can_minimize=0;can_close=1;override_setting=1")

		onclose(user, "telescope", src)

		SPAWN_DBG(1 SECOND)
			callJsFunc(usr, "setRef", list("\ref[src]")) //This is shit but without it, it calls the JS before the window is open and doesn't work.
			loadContent("Starmap", "#contentInner")

		return

	proc/loadContent(var/content, var/divId)
		var/newHtml = ""

		switch(content)
			if("EventList")
				if(tele_man)
					for(var/A in tele_man.events_active)
						var/datum/telescope_event/E = tele_man.events_active[A]
						newHtml += "<div id=\"event[E.id]\" style=\"margin:1px;border: 1px solid;border-color: #ccc;background-color: [A == tracking_id?"#444":"#000"];\">[E.name_undiscovered]</div>"
						newHtml += {"<script>$(function(){$( "#event[E.id]" ).click(function() {if(window.scanRunning){return;} callByond("trackId", \["id=[E.id]"\]);});});</script>"}

					for(var/A in tele_man.events_found)
						var/datum/telescope_event/E = tele_man.events_found[A]
						newHtml += "<div id=\"event[E.id]\" style=\"color:white;margin:1px;border: 1px solid;border-color: #ccc;background-color: [A == tracking_id?"#229922":"#004400"];\">[E.name]</div>"
						newHtml += {"<script>$(function(){$( "#event[E.id]" ).click(function() {if(window.scanRunning){return;} callByond("trackId", \["id=[E.id]"\]);});});</script>"}
			if("Starmap")
				var/foundlocs = ""
				if(length(tele_man?.events_found))
					for(var/A in tele_man.events_found)
						var/datum/telescope_event/E = tele_man.events_found[A] //Clicking on the icons doesnt work.
						foundlocs += {"<div id="iconclick[E.id]" style="z-index:4;border: [A == tracking_id ? "2px":"0px"] solid;border-color: #ffffff;width:32px;height:32px;position: absolute;left:[E.loc_x-16]px;top:[E.loc_y-16]px;padding:0px;margin:0px;"><img src="[resource("images/radioTelescope/[E.icon]")]" style="padding:0px;margin:0px;border:0px;"></div>"}

				newHtml = {"
				<div id="starmap" style="z-index:1;width:600px;height:400px;padding:0px;margin:0px;border:0px;overflow:hidden;background: url('[resource("images/radioTelescope/starmap.png")]');">
					<div id="scanner" class="tight" style="top:175px;left:275px;z-index:2;position:fixed;width:51px;height:51px;background: url('[resource("images/radioTelescope/scanner.png")]');"></div>
					<div id="scannertooltip" class="tight" style="display:none;z-index:6;position:fixed;width:85px;height:15px;background-color:black;color:green;border: 1px solid;border-color: #ffffff;"></div>
					<div id="scan" class="tight" style="z-index:2;display:none;position:fixed;top:0;left:0;width:20px;height:400px;background: url('[resource("images/radioTelescope/scan.png")]');"></div>
					<div id="static" class="tight" style="z-index:4;position:absolute;top:0;left:0;width:600px;height:400px;background: url('[resource("images/radioTelescope/static.gif")]');opacity: 0.05;filter: alpha(opacity=5);"></div>
					<div id="screen" class="tight" style="z-index:5;position:absolute;top:0;left:0;width:600px;height:400px;background: url('[resource("images/radioTelescope/screenoverlay.png")]');"></div>
					[foundlocs]
				</div>

				<script type="text/javascript">
					$(function(){
						$("#starmap").click(function(event) {
							if(window.scanRunning){
								return;
							}

					        var posX = $(this).position().left,
					            posY = $(this).position().top;

					        setHtmlId("#scannertooltip", "X: " + ((event.pageY - posY) - 25).toString() + " Y:" + ((event.pageX - posX) - 25).toString());

					        $("#scannertooltip").show();
							$("#scannertooltip").offset({ top: (event.pageY - posY) + 18, left: (event.pageX - posX) + 30});
					        $("#scanner").offset({ top: (event.pageY - posY) - 25, left: (event.pageX - posX) - 25});
						});
					});
				</script>
				"}

		if(length(newHtml) && divId)
			callJsFunc(usr, "setHtmlId", list(divId, newHtml))

	Topic(href, href_list)
		//boutput(world, href)
		if(!using || get_dist(using, src) > 1)
			using.Browse(null, "window=telescope;override_setting=1")
			using = null
			return

		if(href_list["close"])
			using = null

		else if(href_list["jscall"])
			switch(href_list["jscall"])
				if("endinspect")
					loadContent("Starmap", "#contentInner")
					loadContent("EventList", "#contentSide")
					//boutput(world, "endinspect")

				if("contact")
					if(tele_man.events_found.Find(tracking_id))
						var/datum/telescope_event/E = tele_man.events_found[tracking_id]
						var/html = ""
						html += {"<br><img src="[resource("images/radioTelescope/[length(E.contact_image) ? E.contact_image : E.icon]")]"style="padding:0px;margin:0px;border:0px;"><br> [E.name] @ [E.loc_x]-[E.loc_y]<br>"}
						html += {"<p>[E.desc]</p>"}
						callJsFunc(usr, "setHtmlId", list("#contentInspect", html))
						callJsFunc(usr, "showContact", list())
						E.onContact(src)
						loadContent("EventList", "#contentSide")

				if("trackId")
					tracking_id = href_list["id"]
					loadContent("EventList", "#contentSide")
					if(tele_man && tracking_id)
						if(tele_man.events_active.Find(tracking_id))
							var/datum/telescope_event/E = tele_man.events_active[tracking_id]
							callJsFunc(usr, "setHtmlId", list("#statusText", "Now tracking: [E.name_undiscovered]"))
							callJsFunc(usr, "setHtmlId", list("#contentContact", ""))
						else if(tele_man.events_found.Find(tracking_id))
							var/datum/telescope_event/E = tele_man.events_found[tracking_id]
							callJsFunc(usr, "setHtmlId", list("#statusText", "Now targeting: [E.name]"))
							callJsFunc(usr, "setHtmlId", list("#contentContact", "[E.contact_verb]"))

						loadContent("Starmap", "#contentInner")

				if("scanComplete")
					if(tele_man)
						tele_man.onScan()
						if(tracking_id)
							if(tele_man.events_active.Find(tracking_id))
								var/datum/telescope_event/E = tele_man.events_active[tracking_id]
								var/posx = text2num(href_list["posx"])
								var/posy = text2num(href_list["posy"])
								var/distx = abs(posx - E.loc_x)
								var/disty = abs(posy - E.loc_y)

								if(distx + disty <= E.size) //CHANGE THIS BACK!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
									E.onActivate(src)
									tele_man.events_active.Remove(tracking_id)
									tele_man.events_found.Add(tracking_id)
									tele_man.events_found[tracking_id] = E
									tracking_id = ""
									loadContent("Starmap", "#contentInner")

								callJsFunc(usr, "setHtmlId", list("#statusText", "Distance: [distx + disty] LY"))

					loadContent("EventList", "#contentSide")
				if("closeWindow")
					usr.Browse(null, "window=telescope;override_setting=1")
					using = null
				if("loadContent")
					var/contentName = href_list["name"]
					var/targetCont = href_list["target"]
					loadContent(contentName, targetCont)

		src.add_fingerprint(usr)
		callJsFunc(usr, "setRef", list("\ref[src]"))
		return


	proc/callJsFunc(var/client, var/funcName, var/list/params)
		var/paramsJS = list2params(params)
		client << output(paramsJS,"telescope.browser:[funcName]")
		return

*/
