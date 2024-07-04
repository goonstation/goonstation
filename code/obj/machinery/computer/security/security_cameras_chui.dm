
chui/window/security_cameras
	name = "Security Cameras"
	var/obj/machinery/computer/security/owner
	windowSize = "650x500"
	flags = CHUI_FLAG_MOVABLE | CHUI_FLAG_CLOSABLE

	proc/create_viewport(client/target_client, turf/T)
		if(BOUNDS_DIST(owner, target_client.mob) > 0)
			boutput(target_client,SPAN_ALERT("You are too far to see the screen."))
		else
			var/list/viewports = target_client.getViewportsByType("cameras: Viewport")
			if(length(viewports))
				boutput( target_client, "<b>You can only have 1 active viewport. Close the existing viewport to create another.</b>" )
				return

			var/datum/viewport/vp = new(target_client, "cameras: Viewport")
			var/turf/startPos = null
			for(var/i = 4, i >= 0 || !startPos, i--)
				startPos = locate(T.x - i, T.y + i, T.z)
				if(startPos) break
			vp.clickToMove = 1
			vp.SetViewport(startPos, 8, 8)

	New(var/obj/machinery/computer/security/seccomp)
		..()
		owner = seccomp
		theAtom = owner
	GetBody()
		var/list/L = list()
		var/bool = 1
		for_by_tcl(C, /obj/machinery/camera)
			if (bool)
				owner.current = C
				bool = 0
			L.Add(C)

		L = camera_sort(L)

		var/cameras_list
		for (var/obj/machinery/camera/C in L)
			if (C.network == owner.network)
				. = "[C.c_tag][C.camera_status ? null : " (Deactivated)"]"
				// Don't draw if it's in favorites or AI core/upload
				if ((C in owner.favorites) || C.ai_only)
					continue
				// &#128190; is save symbol
				cameras_list += \
	{"<tr>
	<td><a class='link' href='byond://?src=\ref[src];camera=\ref[C]' style='display:block;'>[.]</a></td> <td class='fav'align='right'>&#128190;</td>
	</tr>
	"}

		var/script = 	{"
		<script type='text/javascript'>
		//stolen from W3Schools.com. Simple filtering, works well enough, didn't bother to make anything special for this.
		function filterTable() {
			var input, filter, table, tr, cameraName, i, txtValue;
			input = document.getElementById('searchbar');
			filter = input.value.toUpperCase();
			table = document.getElementById("cameraList");
			tr = table.getElementsByTagName("tr");
			// Loop through all table rows, and hide those who don't match the search query
			for (i = 0; i < tr.length; i++) {
				cameraName = tr\[i\].getElementsByTagName("td")\[0\];
				if (cameraName) {
					txtValue = cameraName.textContent || cameraName.innerText;
					if (txtValue.toUpperCase().indexOf(filter) > -1) {
						tr\[i\].style.display = "";
					} else {
						tr\[i\].style.display = "none";
					}
				}
			}
		}
		</script>
		<script type='text/javascript'>
		function handle_key_movement(e) {
			var keyId = e.which;
			//takes arrows, wasd, and ijkl.
			//If any other key is pressed, just default to return
			switch(keyId) {
			case 37:
			case 65:
			case 74:
				keyId = 37;
				break;
			case 38:
			case 87:
			case 73:
				keyId = 38;
				break;
			case 39:
			case 68:
			case 76:
				keyId = 39;
				break;
			case 40:
			case 83:
			case 75:
				keyId = 40;
				break;
			default:
			  	return;
			}
			window.location='byond://?src=\ref[src];move='+keyId;
			e.preventDefault();
			e.stopPropagation();
			e.preventDefault();
			e.stopPropagation();
		}
		$(document).delegate('#abM', 'keyup', $.throttle(handle_key_movement,500));
		$(document).delegate('#37', 'click', $.throttle(handle_button_click_movement,500));
		$(document).delegate('#38', 'click', $.throttle(handle_button_click_movement,500));
		$(document).delegate('#39', 'click', $.throttle(handle_button_click_movement,500));
		$(document).delegate('#40', 'click', $.throttle(handle_button_click_movement,500));
		function handle_button_click_movement(e) {
			var buttonId = this.id;
			switch(buttonId) {
				case '37':
				case '38':
				case '39':
				case '40':
					window.location = 'byond://?src=\ref[src];move=' + buttonId;
					break;
				default:
					return;
			}
		}
		//for these just add a save link to those list items
		$(document).delegate('.fav', 'click', function(e) {
			var table = $(this).parent().parent().parent()
			//check which list it's in. adding/removing.
			if (table.attr("id") == "cameraList") {
				if ($('#savedCameras tr').length >= [owner.favorites_Max]) {
					alert('Cannot have more than [owner.favorites_Max] favorites.');
					return;
				}
			var tr = $(this).parent();
			$(this).html('&#128165;');
			tr.appendTo(document.getElementById("savedCameras"));
			// make topic call from a href
			var href = tr.find('a').attr('href');
			var re = /.*camera=(.*)$/g;
			var cameraID = re.exec(href)\[1\];
			window.location='byond://?src=\ref[src];save='+cameraID;
		  //Removing shit
		  } else if(table.attr("id") == "savedCameras") {
			var tr = $(this).parent();
			$(this).html('&#128190');
			tr.appendTo(document.getElementById("cameraList"));
			var href = tr.find('a').attr('href');
			var re = /.*camera=(.*)$/g;
			var cameraID = re.exec(href)\[1\];
			window.location='byond://?src=\ref[src];remove='+cameraID;
			}
	});
		</script>
		<style>
		table {
			  width: 80;
			}
	    a {
	      color:green;
	    }
	    h3 {
	    	color:green;
			margin:0px;
	    }
	    td.fav {
			cursor: pointer;
		}
		#searchbar {
			width:100%;
			margin-left:-2px;
			display:block;
			color:green;
			background-color:black;
			border: 1px solid green;
		}
		input {
			style='width:100%;
		}
		input::placeholder {
			caret-color: green;
			color:#556455;
		}
		#main_list {
			margin-top: 5px;
			padding: 5px;
			border: 3px solid green;
			display: inline-block;
			background-color: black;
			width: 275px;
			height: 400px;
			float: left;
			-ms-overflow-style: none;
			overflow: auto;
		}
		#main_list::-webkit-scrollbar{
		    display:none
		}
		#fav_list {
			margin-top: 5px;
			padding: 5px;
			border: 3px solid green;
			display: inline-block;
			background-color: black;
			width: 275px;
			height: 175px;
			overflow: auto;
		}
	#right{
		float:right;
	}
	#arrow{
		width: 275px;
		height: 200px;
		margin-top: 5px;
		padding:5px;
		border: 3px solid green;
		background-color:black;
		position: absolute;
	}
	.arrbutton {
		padding: 12px 25px;
		position: absolute;
		background-color: grey;
		color: black;
		border: 3px solid #4CAF50;
	}

	\[id='37'\] {
		top: 90px;
		left:12px;
	}
	\[id='39'\] {
		top: 90px;
		left:194px;
	}
	\[id='38'\] {
		top: 30px;
		left:104px;
	}
	\[id='40'\] {
		top: 150px;
		left:104px;
	}
	#abM {
		top: 90px;
		left:104px;
	}
	#abM:focus{
		background-color: #10AA10;
	}
	div{
		color:green;
	}
		</style>
		"}

		var/fav_cameras
		for (var/obj/machinery/camera/C in owner.favorites)
			if (C.network == owner.network)
				. = "[C.c_tag][C.camera_status ? null : " (Deactivated)"]"
				fav_cameras += \
				{"<tr>
				<td><a class='link' href='byond://?src=\ref[src];camera=\ref[C]' style='display:block;'>[.]</a></td> <td class='fav'>&#128165;</td>
				</tr>"}

		var/dat = {"[script]
		<body>
			<div id='viewport_button'>
			<a class='link' href='byond://?src=\ref[src];viewport=true'>Create viewport</a>
			</div>
			<div id='main_list'>
			<input type='text' id='searchbar' onkeyup='filterTable()' placeholder=' Search for cameras..'>
			<table id='cameraList'>
				[cameras_list]
			</table>
			</div>

			<div id='right'>
				<div id='fav_list'>
					<h3>Favorite Cameras: </h3>
					<table id='savedCameras'>
						[fav_cameras]
					</table>
				</div>
				<div id='arrow' >
					Camera Movement (&#x2BCC; = keyboard movement)
					<button class='arrbutton' id='37'>&#x2BC7;</button>
					<button class='arrbutton' id='39'>&#x2BC8;</button>
					<button class='arrbutton' id='38'>&#x2BC5;</button>
					<button class='arrbutton' id='40'>&#x2BC6;</button>
					<button class='arrbutton' id='abM'>&#x2BCC;</button>
				</div>
			</div>
		</body>"}

		return dat

	OnTopic( client/clint, href, href_list[] )
		var/mob/user = clint.mob
		if (!islist(href_list))	//don't need to check for user. that is done in chui/Topic()
			owner.current?.disconnect_viewer(user)
			owner.current = null
			owner.last_viewer = null
			Unsubscribe(clint)
			return

		else if (href_list["camera"])
			var/obj/machinery/camera/C = locate(href_list["camera"])
			if (!istype(C, /obj/machinery/camera))
				return

			//maybe I should change this, could be dumb for the movement mode - Kyle
			if (!C.camera_status)
				boutput(user, SPAN_ALERT("BEEEEPP. Camera broken."))
				return
			else
				owner.use_power(50)
				if (length(clint.getViewportsByType("cameras: Viewport")))
					owner.move_viewport_to_camera(C, clint)
					return
				else if (owner.current)
					owner.current.move_viewer_to(user, C)
				else
					C.connect_viewer(user)
				owner.current = C
				owner.last_viewer = user
				if(!(locate(/obj/ability_button/reset_view/console) in user.item_abilities))
					user.item_abilities += new /obj/ability_button/reset_view/console()
					user.need_update_item_abilities = 1
					user.update_item_abilities()

		else if (href_list["save"])
			var/obj/machinery/camera/C = locate(href_list["save"])

			if (istype(C) && length(owner.favorites) < owner.favorites_Max)
				owner.favorites += C
		else if (href_list["remove"])
			var/obj/machinery/camera/C = locate(href_list["remove"])

			if (istype(C))
				owner.favorites -= C

		else if (href_list["viewport"])
			if (!owner.current)
				boutput(clint, "<b>You need to select a camera before creating a viewport.</b>")
			else
				create_viewport(clint, get_turf(owner.current))
				owner.current?.disconnect_viewer(user)
				owner.current = null
				owner.last_viewer = null


		//using arrowkeys/wasd/ijkl to move from camera to camera
		else if (href_list["move"])
			var/direction = href_list["move"]

			//validate direction returned. JS tries to sanitize client side keypresses so we won't be getting any keys other than arrow keycodes hopefully. But I added the others here just cause...
			//arrow keys, wasd, ijkl
			switch (direction)
				if ("37","65","74")
					direction = WEST
				if ("38","87","73")
					direction = NORTH
				if ("39", "68", "76")
					direction = EAST

				if ("40", "83", "75")
					direction = SOUTH
				else
					return

			owner.move_security_camera(direction,clint)

	Unsubscribe( client/who )
		..()
		who.clearViewportsByType("cameras: Viewport")
		owner.current?.disconnect_viewer(who.mob)
		owner.current = null
		owner.last_viewer = null
		for (var/obj/ability_button/reset_view/console/ability in who.mob.item_abilities)
			who.mob.item_abilities -= ability
		who.mob.need_update_item_abilities = 1
		who.mob.update_item_abilities()
