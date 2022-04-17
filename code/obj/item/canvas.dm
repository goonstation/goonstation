// Canvases/paintings.
// Feature idea stolen from bee.
//
//   PROGRAMMING TOTALLY ORIGINAL
//     UNAUTHORIZED DUPLICATION
//            PROHIBITED


// most of the initial values are cribbed from paper.
// this is like paper but it isn't. i don't want to inherit all the baggage paper has
// like folding, hats, etc. just some of the stuff it has for ease of use's sake.

/obj/item/canvas
	name = "canvas"
	desc = "A fairly big canvas for wowing the station with your artistic talent. Coming soon: Saving!"

	icon = 'icons/obj/canvas.dmi'
	icon_state = null

	var/icon/base = null
	var/icon/art = null
	var/canvas_width = 28
	var/canvas_height = 22
	var/bottom = 0
	var/left = 0
	var/list/artists = list()
	var/list/pixel_artists
	var/display_mult = 16
	var/gray_padding = 100


	uses_multiple_icon_states = 1
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "paper"

	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 3
	throw_range = 15
	layer = OBJ_LAYER

	burn_point = 220
	burn_output = 900
	burn_possible = 2
	health = 10

	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 0


	New()
		..()

		init_canvas()

		left = round((bound_width - canvas_width) / 2)
		bottom = round((bound_height - canvas_height) / 2)

	proc/init_canvas()
		base = icon(src.icon, icon_state = "[canvas_width]x[canvas_height]_base")
		art = icon(src.icon, icon_state = "[canvas_width]x[canvas_height]_blank")

		underlays += base
		icon = art
		pixel_artists = list()

	examine(mob/user)
		. = ..()
		icon = art
		pop_open_a_browser_box(user)

	attack_self(mob/user)
		. = ..()
		pop_open_a_browser_box(user)

	attackby(obj/item/W as obj, mob/user as mob)
		if (!W || !user)
			return

		if (istype(W, /obj/item/paint_can))
			// flood-fill the entire image
			// TODO: This should be a proc so you can use the can on the canvas,
			// or click the canvas with the paint can
			var/obj/item/paint_can/P = W
			art.DrawBox(P.paint_color, left + 1, bottom + 1, left + canvas_width, bottom + canvas_height)
			icon = art

			// tracks how many things someone's drawn on it.
			// so you can tell if scrimblo made a cool scene and then dogshit2000 put obscenities on top or whatever.
			artists[ckey(user.ckey)]++

			playsound(src, "sound/impact_sounds/Slimy_Splat_1.ogg", 40, 1)
			user.visible_message("[user] paints over \the [src] with \the [W].", "You paint over \the [src] with \the [W].")
			logTheThing("station", user, null, "coated [src] in paint: [log_loc(src)]: canvas{\ref[src], -1, -1, [P.paint_color]}")

			// send the damn icon and gently nudge the page into refreshing it
			send_the_damn_icon(user)
			return

		else if (istype(W, /obj/item/pen))
			pop_open_a_browser_box(user)
		else
			. = ..()

	proc/get_dot_color(mob/user)
		// check for writing implement...
		// in active hand ...
		var/obj/item/active_item = user.equipped()

		if (!istype(active_item, /obj/item/pen))
			// you need something to draw with you dope
			boutput(user, "You need something to draw with!")
			return null

		var/obj/item/pen/P = active_item
		return P.font_color

	Topic(href, href_list)
		// stolen from /obj/item/engibox. sorry, tgui.
		if(href_list["close"])
			usr << browse(null, "window=canvas")
			return

		if (usr.stat || usr.restrained()) return
		var/obj/noticeboard/our_board = src.loc
		ENSURE_TYPE(our_board)
		if (!in_interact_range(our_board || src, usr)) return

		var/dot_color = get_dot_color(usr)
		if(isnull(dot_color))
			return

		if (!href_list["x"] || !href_list["y"])
			CRASH("something broke. [json_encode(href_list)]")
		var/pixel_id = href_list["x"] + "," + href_list["y"]

		var/x = text2num(href_list["x"]) + 1
		var/y = text2num(href_list["y"]) - 1
		y = bound_height - 1 - y	// byond is upside down relative to reality

		if (x <= left || y <= bottom || x > (left + canvas_width) || y > (bottom + canvas_height))
			// YOU CAN'T DRAW OFF THE DANG CANVAS LIKE WHAT ARE YOU GONNA PUT THE INK ON
			// THE AIR????
			// FUCK YOU
			return
		art.DrawBox(dot_color, x, y)
		icon = art

		// tracks how many things someone's drawn on it.
		// so you can tell if scrimblo made a cool scene and then dogshit2000 put obscenities on top or whatever.
		artists[ckey(usr.ckey)]++
		pixel_artists[pixel_id] = usr.ckey
		logTheThing("station", usr, null, "draws on [src]: [log_loc(src)]: canvas{\ref[src], [x], [y], [dot_color]}")



		// send the damn icon and gently nudge the page into refreshing it
		send_the_damn_icon(usr)
		usr << output("canvas-\ref[src].png", "canvas.browser:updateImage")

	proc/send_the_damn_icon(mob/user)
		user << browse_rsc(base, "canvas-\ref[src]-base.png")
		user << browse_rsc(art, "canvas-\ref[src].png")

	proc/pop_open_a_browser_box(mob/user)
		send_the_damn_icon(user)
		var/mult = src.display_mult

		var/isadmin = user?.client?.holder?.level >= LEVEL_MOD

		var/dat = {"
<!doctype html>
<html>
<head>
<title>[src]</title>
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="pragma" content="no-cache">
<style>
	body {
		background: #666; /* hail satin */
		color: white;
		font-family: Tahoma, sans-serif;
		margin: 0;
		}
	#container {
    display: flex;
    justify-content: center;
    align-items: center;
    position: absolute;
    bottom: 0px;
    right: 0px;
    left: 0px;
    top: 0px;
		}
	#inner {
		position: relative;
		width: [bound_width * mult]px;
		height: [bound_height * mult]px;
		}
	#cursor {
		width: [mult]px;
		height: [mult]px;
		border: 1px solid black;
		position: absolute;
		left: -9001;
		z-index: 99999;
		margin-left: -1px;
		margin-top: -1px;
		}
	img {
		image-rendering: crisp-edges;
		image-rendering: pixelated;
		-ms-interpolation-mode:nearest-neighbor;
		}
	#canvas, #back {
		display: block;
		position: absolute;
		top: 0;
		left: 0;
		rigth: [bound_width * mult]px;
		bottom: [bound_height * mult]px;
		width: [bound_width * mult]px;
		height: [bound_height * mult]px;
		}
	#back {
		z-index: -1;
		background-color: #977;
		opacity: 0.7;
		}
	#canvas {
		z-index: 1;
		}
</style>
</head>
<body>
<div id="container">
	<div id="inner">
		<img id="back" src="canvas-\ref[src]-base.png">
		<img id="canvas" src="canvas-\ref[src].png">
		<div id="cursor"></div>
	</div>
</div>
<iframe src="about:blank" id="ehjax" style="position: absolute; left: -1000px; width: 1px; height: 1px; display: none;"></iframe>
<script type="text/javascript">
	var canvas = document.getElementById("canvas");
	var cursor = document.getElementById("cursor");
	var ehjax = document.getElementById("ehjax");
	var x = 0;
	var y = 0;
	[isadmin ? "var pixel_artists = [json_encode(src.pixel_artists)];" : ""]

	window.onkeydown = function( event ) {
		if ( event.keyCode == 27 ) {
			ehjax.src = "byond://?\ref[src];close=1";
		}
	};

	cursor.addEventListener("click", function(e) {
		var url = "byond://?\ref[src];x="+ x +";y="+ y;
		ehjax.src = url
	})

	canvas.addEventListener("click", function(e) {
		var url = "byond://?\ref[src];x="+ x +";y="+ y;
		ehjax.src = url
	})
	canvas.addEventListener("mousemove", function(e) {
		var ox = e.offsetX;
		var oy = e.offsetY;
		x = Math.floor(ox / [mult]);
		y = Math.floor(oy / [mult]);
		cursor.title = (x - [left]) + "," + (y - [bottom]);
		[isadmin ? {"cursor.title += " - " + pixel_artists\[x + "," + y\];"} : ""]
		cursor.style.left = (x * [mult]) + "px";
		cursor.style.top = (y * [mult]) + "px";
	});

	canvasURL = canvas.src
	// this should be requesting from the client's byond instance,
	// not anything server-side, so we can do whatever
	function updateImage(file) {
		canvasURL = file;
		canvas.src = canvasURL + "?" + Math.random() * 999999;
	}
	setInterval(function() {
		canvas.src = canvasURL + "?" + Math.random() * 999999;
	}, 200);

</script>


		"}

		user << browse(dat, "window=canvas;size=[bound_width * mult + gray_padding]x[bound_height * mult + gray_padding]")

	picklify(atom/loc)
		if(!startswith(src.name, "pickled"))
			src.name = "pickled [src.name]"
		src.desc = "A fairly pickled canvas for wowing the station with your pickled talent. Coming soon: Pickles!"
		src.edible = TRUE
		return src

	proc/load_from_id(id)
		src.art = world.load_intra_round_value("persistent_canvas_[id]")
		if(isnull(src.art))
			src.art = icon(src.icon, icon_state = "blank")
			src.art.Scale(bound_width, bound_height)
		src.art.Crop(1, 1, bound_width, bound_height)
		if(isnull(src.base))
			src.base = icon(src.icon, icon_state = "transparent") // idc
		src.icon = src.art
		src.pixel_artists = world.load_intra_round_value("persistent_canvas_artists_[id]") || list()

	proc/save_to_id(id)
		world.save_intra_round_value("persistent_canvas_[id]", src.art)
		world.save_intra_round_value("persistent_canvas_artists_[id]", src.pixel_artists)

/obj/item/canvas/lazy_restore
	var/id = null
	var/initialized = FALSE

	New(loc, id)
		..(loc)
		src.id = id

	save_to_id(id)
		if(initialized)
			..()
		else if(id == src.id)
			return
		else
			src.load_from_id(src.id)
			..()

	set_loc(newloc)
		. = ..()
		if(!initialized)
			src.load_from_id(src.id)
			initialized = TRUE

	pop_open_a_browser_box(mob/user)
		if(!initialized)
			src.load_from_id(src.id)
			initialized = TRUE
		. = ..()

/obj/item/canvas/big_persistent
	name = "Big Persistent Canvas"
	desc = "A huge canvas. You don't even need a crayon to draw on it but you can only draw one dot per shift."
	canvas_width = 7 * 32
	canvas_height = 7 * 32
	bound_width = 7 * 32
	bound_height = 7 * 32
	anchored = TRUE
	display_mult = 4
	plane = PLANE_FLOOR
	var/id = null
	burn_possible = FALSE
	gray_padding = 5

	New(loc)
		..()
		START_TRACKING
		src.add_filter("frame", 1, outline_filter(2, "#ccaa00"))

	init_canvas()
		if(isnull(src.id))
			SPAWN(1)
				qdel(src)
			CRASH("big canvas has no id set")
		load_from_id(src.id)

	disposing()
		STOP_TRACKING
		..()

	proc/save()
		save_to_id(src.id)

	get_dot_color(mob/user)
		if(user.ckey in src.artists)
			boutput(user, "<span class='alert'>The first brush stroke exhausted you too much. You will need to wait until the next shift for another.</span>")
			return null
		. = input(user, "Please select the color to paint with.", "Your Single Brushstroke", null) as null|color
		if(user.ckey in src.artists)
			return null

	attackby(obj/item/W, mob/user)
		pop_open_a_browser_box(user)

	attack_hand(mob/user)
		pop_open_a_browser_box(user)

	reagent_act()
		return
	ex_act(severity)
		return

/obj/item/canvas/big_persistent/centcom
	name = "Memorial CentCom Canvas"
	id = "centcom"
	icon_state = "centcomcanvas"
	mouse_over_pointer = MOUSE_HAND_POINTER

// the intro at the start of this file is a joke:
// https://www.youtube.com/watch?v=wpNxzJk7xUc#t=42s
// ...and is not to be taken seriously, or as any definition
// of copyright/license or otherwise.
// I didn't look at anything about how bee's worked except
// seeing the ui, sort of.
