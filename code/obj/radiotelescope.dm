/* outdated
var/datum/telescope_manager/tele_man
var/list/telescope_computers = list()

/datum/telescope_manager
	var/list/events_inactive = list()
	var/list/events_active = list()
	var/list/events_found = list()

	proc/setup()
		var/types = childrentypesof(/datum/telescope_event)
		for(var/x in types)
			var/datum/telescope_event/R = new x(src)
			events_inactive.Add(R.id)
			events_inactive[R.id] = R
			if(!R.fixed_location)
				R.loc_x = rand(0, 600)
				R.loc_y = rand(0, 400)
		return

	proc/tick()
		return

	proc/onScan() //TBI update event list of all telecomps
		if(events_active.len < 3)
			if(events_inactive.len)
				var/picked = pick(events_inactive)
				var/datum/telescope_event/T = events_inactive[picked]
				events_active.Add(picked)
				events_active[picked] = T
				events_inactive.Remove(picked)
		return

/datum/telescope_event/sosvaliant
	name = "SS Valiant distress signal"
	name_undiscovered = "Unknown signal 23.23"
	desc = "This is a distress signal sent by the spaceship 'Valiant'.<br>The ship is not responding to hails.<br>It seems like there is currently no way to contact them."
	id = "valiantdistress"
	icon = "valiant.png"
	size = 10
	contact_verb = "CONTACT"
	contact_image = "audio.png" //Alternative image of the object for the contact screen. otherwise icon is used.

	onActivate(var/obj/machinery/computer/telescope/T)
		..()
		return

/datum/telescope_event/geminorum
	name = "5604 Geminorum V"
	name_undiscovered = "Unknown beacon A23V"
	desc = "There appears to be some sort of signal beacon in a cave on this planet.<br>Scans show that the planet is strangely devoid of any sentient life despite it's lush vegetation.<br>An expedition would be required to find out more about this place.<br>Co-ordinates have been uploaded to the science teleporter. (TBI, Sorry about that)"
	id = "geminorum"
	icon = "planet3.png"
	size = 15
	contact_verb = "SCAN"
	contact_image = "blueplanet.png" //Alternative image of the object for the contact screen. otherwise icon is used.

	onActivate(var/obj/machinery/computer/telescope/T)
		..()
		if(!special_places.Find(name))
			special_places.Add(name)
			var/datum/computer/file/coords/C = new()
			C.destx = 255
			C.desty = 3
			C.destz = 2
			special_places[id] = C
		return

/datum/telescope_event
	var/name = ""			   //Name which is shown after discovery
	var/name_undiscovered = "" //Name which is shown when you haven't found this event yet.
	var/desc = ""
	var/id = ""
	var/icon = ""
	//TBI Add rarity controls
	var/fixed_location = 0
	var/loc_x = 0
	var/loc_y = 0

	var/size = 10 			//The size of the spot you need to hit.

	var/contact_verb = "PING"
	var/contact_image = ""

	proc/onActivate(var/obj/machinery/computer/telescope/T)
		return

/obj/machinery/computer/telescope
	name = "quantuum telescope"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer_generic"

	var/mob/using = null

	var/tracking_id = "" //id of the event we're tracking/targeting.

	var/links = {"<link rel="stylesheet" type="text/css" href="[resource("css/style.css")]">"}

	var/js = {"<script src="[resource("js/jquery.min.js")]"></script>
	<script src="[resource("js/jquery-migrate-1.2.1.min.js")]"></script>
	<script src="[resource("js/jquery-ui.min.js")]"></script>
	<script src="[resource("js/pointer_events_polyfill.js")]"></script>
	<script type="text/javascript">
		var tabs;
		var ref;
		var scanInterval;
		var scanRunning;

		setRef = function setRef(theRef) {
        	ref = theRef;
    	}

   		function callByond(action, data)
		{
	        var newLoc = '?src=' + ref + ';jscall=' + action + ';' + data.join(';');
	        window.location = newLoc;
		}

		function setHtmlId(element, data)
		{
			$(element).empty().html(data);
		}

		function showContact()
		{
			$( "#contentInspect" ).show();
		}


		function scanProcess()
		{
			var p = $("#scan");
			var posX = (p.position().left + 3);
			p.offset({ top: 0, left: posX});

			if (posX >= 600) {
			    p.hide();
			    clearInterval(window.scanInterval);
			    scanRunning = 0;
			    setHtmlId("#statusText", "Idle ...");
			    callByond("scanComplete", \["posx=" + ($('#scanner').position().left + 25).toString() + "&" + "posy=" + ($('#scanner').position().top + 25).toString() \]);
			}
		}

		function showScan()
		{
			if(window.scanRunning){
				return;
			}
			setHtmlId("#statusText", "Scanning ...");
			$("#scan").show();
			$("#scan").offset({ top: 0, left: 0});
			scanInterval = setInterval(scanProcess, 25);
			scanRunning = 1;
		}

		$(function(){

			$(document).ready(function(){
				PointerEventsPolyfill.initialize({mouseEvents:  \['click','dblclick','mousedown','mouseup','mousemove','mouseover','mouseout'\]});
			});

			$( "#scanbutt" ).click(function( event ) {
				showScan();
			});

			$( "#contentContact" ).click(function( event ) {
				callByond("contact", \[\]);
			});

			$( "#contentInspect" ).click(function( event ) {
				$( "#contentInspect" ).hide();
			});
		});
	</script>
	"}

	New() //TBI REMOVE FROM LIST ON DELETION
		telescope_computers.Add(src)
		..()

	attack_ai(mob/user as mob)
		return attack_hand(user)

	attack_hand(mob/user as mob)
		if(status & (BROKEN|NOPOWER))
			return

		if(using && (!using.client || using.client.inactivity >= 1200 || get_dist(src, using) > 1))
			using << browse(null, "window=materials")
			using = null

		if(using && using != user)
			boutput(user, "<span class='alert'>Somebody is already using that machine.</span>")
			return.

		using = user

		//MAKE THE STATIC FLOAT SO STUFF CAN GO UNDER IT. POSITION ABSOLUTE ETC

		var/html = {"<!doctype html>
					<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
					<html>
					<head>
					[links]
					<title>Radio telescope</title>
					</head>
					<body style="overflow:hidden">
					<div id="content" class="tight" style="z-index:9;width:800px;height:435px;background-color: black;">
							<div id="contentInner" class="tight" style="z-index:9;position:fixed;width:600px;height:400px;background-color: black"></div>
							<div id="contentInspect" class="tight" style="color:green;display:none;z-index:10;position:fixed;width:600px;height:400px;background-color: black"></div>

							<div id="contentSide" class="tight" style="z-index:9;position:fixed;overflow:auto;color: green;border: 1px solid;border-color: #ccc;top:0px;left:600px;width:198px;height:398px;background-color: black"></div>

							<div id="contentBottom" class="tight" style="z-index:9;border: 1px solid;border-color: #ccc;position:fixed;top:400px;left:0px;width:600px;height:35px;background-color: black">
								<div style="color:green;margin:3px;">
								<div style="padding:5px;display:inline-block;width:50px;height:15px;border: 1px solid;border-color: #ccc;background-color: #333" id="scanbutt">Scan</div><div id="statusText" style="margin-left: 10px;display:inline;">Ready ...</div>
								</div>
							</div>

							<div id="contentContact" class="tight" style="z-index:9;padding-top:5px;color:green;text-align: center;border: 1px solid;border-color: #ccc;position:fixed;top:400px;left:600px;width:198px;height:33px;background-color: black"></div>
					</div>

					</body>
					[js]
					</html>
					"}

		src.add_dialog(user)
		add_fingerprint(user)
		user << browse(html, "window=telescope;size=800x435;can_resize=0;can_minimize=0;can_close=1")
		onclose(user, "telescope", src)

		SPAWN_DBG(1 SECOND)
			callJsFunc(user, "setRef", list("\ref[src]")) //This is shit but without it, it calls the JS before the window is open and doesn't work.
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
						newHtml += {"<script>$(function(){$( "#event[E.id]" ).click(function() {callByond("trackId", \["id=[E.id]"\]);});});</script>"}

					for(var/A in tele_man.events_found)
						var/datum/telescope_event/E = tele_man.events_found[A]
						newHtml += "<div id=\"event[E.id]\" style=\"color:white;margin:1px;border: 1px solid;border-color: #ccc;background-color: [A == tracking_id?"#229922":"#004400"];\">[E.name]</div>"
						newHtml += {"<script>$(function(){$( "#event[E.id]" ).click(function() {callByond("trackId", \["id=[E.id]"\]);});});</script>"}
			if("Starmap")
				var/foundlocs = ""
				if(tele_man && length(tele_man.events_found))
					for(var/A in tele_man.events_found)
						var/datum/telescope_event/E = tele_man.events_found[A] //Clicking on the icons doesnt work.
						foundlocs += {"<div id="iconclick[E.id]" style="z-index:4;border: [A == tracking_id ? "2px":"0px"] solid;border-color: #ffffff;width:32px;height:32px;position: absolute;left:[E.loc_x-16]px;top:[E.loc_y-16]px;padding:0px;margin:0px;"><img src="[resource("images/radioTelescope/[E.icon]")]" style="padding:0px;margin:0px;border:0px;"></div>"}
						//foundlocs += {"<script>$(function(){$( "#iconclick[E.id]" ).click(function() { alert("CLICK"); });});</script>"}

				newHtml = {"
				<div id="starmap" style="z-index:1;width:600px;height:400px;padding:0px;margin:0px;border:0px;overflow:hidden;background: url('[resource("images/radioTelescope/starmap.png")]');">
					<div id="scanner" class="tight" style="z-index:2;position:fixed;top:175;left:275;width:51px;height:51px;background: url('[resource("images/radioTelescope/scanner.png")]');"></div>
					<div id="scan" class="tight" style="z-index:2;display:none;position:absolute;top:0;left:0;pointer-events: none;width:20px;height:400px;background: url('[resource("images/radioTelescope/scan.png")]');"></div>
					<div id="static" class="tight" style="z-index:4;position:absolute;top:0;left:0;pointer-events: none;width:600px;height:400px;background: url('[resource("images/radioTelescope/static.gif")]');opacity: 0.05;filter: alpha(opacity=5);"></div>
					<div id="screen" class="tight" style="z-index:5;position:absolute;top:0;left:0;pointer-events: none;width:600px;height:400px;background: url('[resource("images/radioTelescope/screenoverlay.png")]');"></div>
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

					        $("#scanner").offset({ top: (event.pageY - posY) - 25, left: (event.pageX - posX) - 25});
					        //alert((event.pageX - posX) + ' , ' + (event.pageY - posY));
						});
					});
				</script>
				"}

		if(length(newHtml) && divId)
			callJsFunc(usr, "setHtmlId", list(divId, newHtml))

	Topic(href, href_list)
		//boutput(world, href)
		if(!using || get_dist(using, src) > 1)
			using << browse(null, "window=telescope")
			using = null
			return

		if(href_list["close"])
			using = null
		else if(href_list["jscall"])
			switch(href_list["jscall"])
				if("contact")
					if(tele_man.events_found.Find(tracking_id))
						var/datum/telescope_event/E = tele_man.events_found[tracking_id]
						var/html = ""
						html += {"<br><img src="[resource("images/radioTelescope/[length(E.contact_image) ? E.contact_image : E.icon]")]"style="padding:0px;margin:0px;border:0px;"> [E.name]"}
						html += {"<p>[E.desc]</p>"}
						callJsFunc(usr, "setHtmlId", list("#contentInspect", html))
						callJsFunc(usr, "showContact", list())

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

								if(distx + disty <= E.size) //REVERT CONDITION TO NORMAL AFTER TESTING!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
									E.onActivate(src)
									tele_man.events_active.Remove(tracking_id)
									tele_man.events_found.Add(tracking_id)
									tele_man.events_found[tracking_id] = E
									tracking_id = ""
									loadContent("Starmap", "#contentInner")

								callJsFunc(usr, "setHtmlId", list("#statusText", "Distance: [distx + disty] LY"))

					loadContent("EventList", "#contentSide")
				if("closeWindow")
					usr << browse(null, "window=telescope")
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
