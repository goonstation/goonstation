/* ---------- WHAT'S HERE ---------- */
/*
 - Pens
 - Markers
 - Crayons
 - Infrared Pens (not "infared", jfc mport)
 - Hand labeler
 - Clipboard
 - Booklet
 - Sticky notes
 - Folder
*/
/* --------------------------------- */

/* =============== PENS =============== */
/obj/item/pen
	desc = "The humble National Notary 'Arundel' model pen. It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/writing.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "pen"
	flags = FPRINT | TABLEPASS
	c_flags = ONBELT
	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 7
	throw_range = 15
	m_amt = 60
	var/font = "Georgia" // custom pens
	var/webfont = null // atm this is used to add things to paper's font list. see /obj/item/pen/fancy and /obj/item/paper/attackby()
	var/font_color = "black"
	var/uses_handwriting = 0
	stamina_damage = 0
	stamina_cost = 0
	rand_pos = TRUE
	var/in_use = 0
	var/color_name = "black"
	var/clicknoise = 1
	var/spam_flag_sound = 0
	var/spam_flag_message = 0 // one message appears for every five times you click the pen if you're just sitting there jamming on it
	var/spam_timer = 20
	var/symbol_setting = null
	var/material_uses = 10
	var/can_dip = TRUE // can we dip this in reagents to write with them?
	var/static/list/c_default = list("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "Exclamation Point", "Question Mark", "Period", "Comma", "Colon", "Semicolon", "Ampersand", "Left Parenthesis", "Right Parenthesis",
	"Left Bracket", "Right Bracket", "Percent", "Plus", "Minus", "Times", "Divided", "Equals", "Less Than", "Greater Than")
	var/static/list/c_symbol = list("Dollar", "Euro", "Credit", "Arrow North", "Arrow East", "Arrow South", "Arrow West",
	"Square", "Circle", "Triangle", "Heart", "Star", "Smile", "Frown", "Neutral Face", "Bee", "Pentacle", "Skull")
	var/static/list/c_char_to_symbol = list(
		"!" = "Exclamation Point",
		"?" = "Question Mark",
		"." = "Period",
		"," = "Comma",
		":" = "Colon",
		";" = "Semicolon",
		"&" = "Ampersand",
		"(" = "Left Parenthesis",
		")" = "Right Parenthesis",
		"\[" = "Left Bracket",
		"]" = "Right Bracket",
		"%" = "Percent",
		"+" = "Plus",
		"-" = "Minus",
		"*" = "Times",
		"/" = "Divided",
		"=" = "Equals",
		"<" = "Less Than",
		">" = "Greater Than",
		"[CREDIT_SIGN]" = "Credit"
	)

	New()
		. = ..()
		src.create_reagents(PEN_REAGENT_CAPACITY)


	attack_self(mob/user as mob)
		..()
		if (!src.spam_flag_sound && src.clicknoise)
			src.spam_flag_sound = 1
			playsound(user, 'sound/items/penclick.ogg', 50, 1)
			if (!src.spam_flag_message)
				src.spam_flag_message = 1
				user.visible_message("<span style='color:#888888;font-size:80%'>[user] clicks [src].</span>")
				SPAWN((src.spam_timer * 5))
					if (src)
						src.spam_flag_message = 0
			SPAWN(src.spam_timer)
				if (src)
					src.spam_flag_sound = 0

	get_desc()
		. = ..()
		if (src.reagents.total_volume && src.can_dip)
			. += "<br><span class = 'notice'>It's been dipped in a [get_nearest_color(src.reagents.get_average_color())] substance."

	proc/apply_material_to_drawing(obj/decal/cleanable/writing/drawing, mob/user)
		if(src.material)
			drawing.setMaterial(src.material)
			src.material_uses--
			if(src.material_uses <= 0)
				boutput(user, "<span class='notice'>[src.material.name] rubs off of [src].</span>")
				src.removeMaterial()
			return TRUE
		return FALSE

	proc/write_on_turf(var/turf/T as turf, var/mob/user as mob, params)
		if (!T || !user || src.in_use || BOUNDS_DIST(T, user) > 0 || isghostdrone(user))
			return
		if(!user.literate)
			boutput(user, "<span class='alert'>You don't know how to write.</span>")
			return
		src.in_use = 1
		var/t = tgui_input_text(user, "What do you want to write?", "Write")
		if (!t || BOUNDS_DIST(T, user) > 0)
			src.in_use = 0
			return
		phrase_log.log_phrase("floorpen", t)
		var/obj/decal/cleanable/writing/G = make_cleanable(/obj/decal/cleanable/writing, T)
		G.artist = user.key

		logTheThing(LOG_STATION, user, "writes on [T] with [src][src.material ? " (material: [src.material.name])" : null] [log_loc(T)]: [t]")
		t = copytext(html_encode(t), 1, MAX_MESSAGE_LEN)
		if (src.font_color)
			G.color = src.font_color
		if(apply_material_to_drawing(G, user))
			;
		else if (src.font)
			G.font = src.font
		G.words = "[t]"
		if (islist(params) && params["icon-y"] && params["icon-x"])
			G.pixel_x = text2num(params["icon-x"]) - 16
			G.pixel_y = text2num(params["icon-y"]) - 16
		else
			G.pixel_x = rand(-4,4)
			G.pixel_y = rand(-4,4)
		if (src.reagents.total_volume)
			G.color = src.reagents.get_average_rgb()
			G.sample_reagent = src.reagents.get_master_reagent_id()
			var/datum/reagent/master_reagent = src.reagents.reagent_list[G.sample_reagent]
			G.sample_amt = master_reagent.volume
			src.reagents.clear_reagents()

			src.remove_filter("reagent_coloration")
			src.color_name = initial(src.color_name)
			src.font_color = initial(src.font_color)

		src.in_use = 0

	onMaterialChanged()
		..()
		if (src.color != src.font_color)
			src.font_color = src.color
			src.color_name = hex2color_name(src.color)
		if(src.material)
			src.material_uses = initial(src.material_uses)

	afterattack(atom/target, mob/user)
		if (target.is_open_container())
			if (src.reagents.maximum_volume <= src.reagents.total_volume)
				boutput(user, "<span class='alert'>The pen is totally coated!</span>")
				return

			if (istype(target, /obj/fluid) && !istype(target, /obj/fluid/airborne))
				var/obj/fluid/F = target
				F.group.reagents.skip_next_update = TRUE
				F.group.update_amt_per_tile()
				var/amt = min(F.group.amt_per_tile, src.reagents.maximum_volume - src.reagents.total_volume)
				boutput(user, "<span class='notice'>You fill [src] with [amt] units of [target].</span>")
				F.group.drain(F, amt / F.group.amt_per_tile, src) // drain uses weird units
			else if (target.reagents && src.can_dip)
				if (target.reagents.total_volume)
					boutput(user, "<span class='hint'>You dip [src] in [target].</span>")
					target.reagents.trans_to(src, min(PEN_REAGENT_CAPACITY , src.reagents.maximum_volume - src.reagents.total_volume))
				else
					boutput(user, "<span class='alert'>[target] is empty!</span>")
		else
			return ..()

		if (src.reagents.total_volume)
			src.add_filter("reagent_coloration", 1, color_matrix_filter(normalize_color_to_matrix(src.reagents.get_average_rgb())))
			src.color = src.reagents.get_average_color()
			src.font_color = src.color
			src.color_name = get_nearest_color(src.reagents.get_average_color()) // why the fuck are there 3 vars for this

			if (src.material)
				src.removeMaterial() // no
				src.visible_message("<span class='alert'>Dipping [src] causes the material to slough off.</span>")

	setMaterial(datum/material/mat1, appearance, setname, copy, use_descriptors)
		. = ..()
		src.reagents.clear_reagents() // no

	custom_suicide = TRUE
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return FALSE
		user.visible_message("<span class='alert'><b>[user] gently pushes the end of [src] into [his_or_her(user)] nose, then leans forward until [he_or_she(user)] falls to the floor face first!</b></span>")
		user.TakeDamage("head", 175, 0)
		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = FALSE
		qdel(src)
		return TRUE
/obj/item/pen/fancy
	name = "fancy pen"
	desc = "One of those really fancy National Notary pens. Looks like the 'Grand Duchess' model with the gold nib and marblewood barrel."
	icon_state = "pen_fancy"
	item_state = "pen_fancy"
	font_color = "blue"
	font = "'Dancing Script', cursive"
	webfont = "Dancing Script"
	uses_handwriting = 1

/obj/item/pen/odd
	name = "odd pen"
	desc = "There's something strange about this pen. Inscriptions indicate it is a National Notary 'Francis Scott' model with an electrum nib and lignum vitae barrel. Huh."
	font = "Wingdings"

/obj/item/pen/red // we didn't have one of these already??
	name = "red pen"
	desc = "The horrible, the unspeakable, the dreaded <span class='alert'><b>RED PEN!!</b></span>"
	color = "red"
	font_color = "red"

/obj/item/pen/pencil // god this is a dumb path
	name = "pencil"
	desc = "The core is graphite, not lead, don't worry!"
	icon_state = "pencil-y"
	font_color = "#808080"
	font = "'Dancing Script', cursive"
	webfont = "Dancing Script"
	uses_handwriting = 1
	clicknoise = 0

	New()
		..()
		if (prob(25))
			src.icon_state = pick("pencil-b", "pencil-g")

/obj/item/pen/omni
	name = "omnipen"
	desc = "A fancy combination pen, capable of switching modes like those multi color pens you remember from school."

	var/penmode = "pen"
	var/extra_desc = null

	New()
		..()
		src.change_mode(penmode)

	attack_self(var/mob/user)
		..()
		// cycle between modes
		var/new_mode = null
		switch (src.penmode)
			if ("pen") new_mode = "fancy"
			if ("fancy") new_mode = "odd"
			if ("odd") new_mode = "red"
			if ("red") new_mode = "pencil"
			if ("pencil") new_mode = "pen"
		if (new_mode)
			src.change_mode(new_mode, user)

	proc/change_mode(var/new_mode, var/mob/holder)
		tooltip_rebuild = 1
		switch (new_mode)
			if ("pen")
				src.penmode = "pen"
				src.extra_desc = null
				src.icon_state = "pen"
				src.force = 1
				src.throwforce = 1
				src.throw_range = 7
				src.throw_speed = 2
				src.stamina_damage = 20
				src.stamina_cost = 10
				src.stamina_crit_chance = 10
				src.hit_type = DAMAGE_BLUNT
				src.hitsound = 'sound/impact_sounds/Generic_Hit_1.ogg'
				src.font = "Georgia"
				src.webfont = null
				src.color = null

			if ("fancy")
				src.penmode = "fancy"
				src.extra_desc = "It's in fancy mode."
				src.icon_state = "pen_fancy"
				src.force = 1
				src.throwforce = 1
				src.throw_range = 7
				src.throw_speed = 2
				src.stamina_damage = 20
				src.stamina_cost = 10
				src.stamina_crit_chance = 10
				src.hit_type = DAMAGE_BLUNT
				src.hitsound = 'sound/impact_sounds/Generic_Hit_1.ogg'
				src.font = "'Dancing Script', cursive"
				src.webfont = "Dancing Script"
				src.color = null

			if ("odd")
				src.penmode = "odd"
				src.extra_desc = "It's in 'odd' mode... Whatever that means."
				src.icon_state = "pen"
				src.force = 1
				src.throwforce = 1
				src.throw_range = 7
				src.throw_speed = 2
				src.stamina_damage = 20
				src.stamina_cost = 10
				src.stamina_crit_chance = 10
				src.hit_type = DAMAGE_BLUNT
				src.hitsound = 'sound/impact_sounds/Generic_Hit_1.ogg'
				src.font = "Wingdings"
				src.webfont = null
				src.color = "#ff66ff"

			if ("red")
				src.penmode = "red"
				src.extra_desc = "It's in red pen mode."
				src.icon_state = "pen"
				src.force = 1
				src.throwforce = 1
				src.throw_range = 7
				src.throw_speed = 2
				src.stamina_damage = 20
				src.stamina_cost = 10
				src.stamina_crit_chance = 10
				src.hit_type = DAMAGE_BLUNT
				src.hitsound = 'sound/impact_sounds/Generic_Hit_1.ogg'
				src.font = "red"
				src.webfont = null
				src.color = "#ff0000"

			if ("pencil")
				src.penmode = "pencil"
				src.extra_desc = "It's in pencil mode."
				src.icon_state = "pencil-y"
				src.force = 1
				src.throwforce = 1
				src.throw_range = 7
				src.throw_speed = 2
				src.stamina_damage = 20
				src.stamina_cost = 10
				src.stamina_crit_chance = 10
				src.hit_type = DAMAGE_BLUNT
				src.hitsound = 'sound/impact_sounds/Generic_Hit_1.ogg'
				src.font = "'Dancing Script', cursive"
				src.webfont = "Dancing Script"
				src.color = null

		if (holder)
			holder.update_inhands()

	get_desc(dist, mob/user)
		var/list/extras = list()
		if (extra_desc)
			extras += extra_desc
		extras += ..()
		return extras.Join(" ")

/* =============== MARKERS =============== */

/obj/item/pen/marker
	name = "felt marker"
	desc = "It's the National Notary 'Edgewater' waterproof marker. Try not to sniff it too much. Weirdo."
	icon_state = "marker"
	color = "#333333"
	font = "'Permanent Marker', cursive"
	webfont = "Permanent Marker"
	clicknoise = 0

	red
		name = "red marker"
		color = "#FF0000"
		font_color = "#FF0000"

	orange
		name = "orange marker"
		color = "#FFAA00"
		font_color = "#FFAA00"

	yellow
		name = "yellow marker"
		color = "#FFFF00"
		font_color = "#FFFF00"

	green
		name = "green marker"
		color = "#00FF00"
		font_color = "#00FF00"

	aqua
		name = "aqua marker"
		color = "#00FFFF"
		font_color = "#00FFFF"

	blue
		name = "blue marker"
		color = "#0000FF"
		font_color = "#0000FF"

	purple
		name = "purple marker"
		color = "#AA00FF"
		font_color = "#AA00FF"

	pink
		name = "pink marker"
		color = "#FF00FF"
		font_color = "#FF00FF"

	random
		New()
			..()
			src.color = random_color()
			src.font_color = src.color
			src.name = "[hex2color_name(src.color)] marker"

/* =============== CRAYONS =============== */

/obj/item/pen/crayon
	name = "crayon"
	desc = "Don't shove it up your nose, no matter how good of an idea that may seem to you.  You might not get it back."
	icon_state = "crayon"
	color = "#333333"
	font = "Comic Sans MS"
	clicknoise = 0
	var/maptext_crayon = FALSE
	var/font_size = 32

	white
		name = "white crayon"
		color = "#FFFFFF"
		font_color = "#FFFFFF"
		color_name = "white"

	red
		name = "red crayon"
		color = "#FF0000"
		font_color = "#FF0000"
		color_name = "red"

	orange
		name = "orange crayon"
		color = "#FFAA00"
		font_color = "#FFAA00"
		color_name = "orange"

	yellow
		name = "yellow crayon"
		color = "#FFFF00"
		font_color = "#FFFF00"
		color_name = "yellow"

	green
		name = "green crayon"
		color = "#00FF00"
		font_color = "#00FF00"
		color_name = "green"

	aqua
		name = "aqua crayon"
		color = "#00FFFF"
		font_color = "#00FFFF"
		color_name = "aqua"

	blue
		name = "blue crayon"
		color = "#0000FF"
		font_color = "#0000FF"
		color_name = "blue"

	purple
		name = "purple crayon"
		color = "#AA00FF"
		font_color = "#AA00FF"
		color_name = "purple"

	pink
		name = "pink crayon"
		color = "#FF00FF"
		font_color = "#FF00FF"
		color_name = "pink"

	golden // HoP's crayon
		name = "golden crayon"
		desc = "The result of years of bribes and extreme bureaucracy."
		color = "#D4AF37"
		font_color = "#D4AF37"
		mat_changename = 0
		color_name = "golden"
		material_uses = 123456 // it's not plated. its solid gold-wax alloy!

		New()
			..()
			src.setMaterial(getMaterial("gold"))

	random
		New()
			..()
			src.color = random_color()
			src.font_color = src.color
			src.color_name = hex2color_name(src.color)
			src.name = "[src.color_name] crayon"

		choose
			desc = "Don't shove it up your nose, no matter how good of an idea that may seem to you.  You might not get it back. Spin it, go ahead, you know you want to."

			on_spin_emote(var/mob/living/carbon/human/user as mob)
				..(user)
				src.color = random_color()
				src.font_color = src.color
				src.color_name = hex2color_name(src.color)
				src.name = "[src.color_name] crayon"
				user.visible_message("<span class='notice'><b>\"Something\" special happens to [src]!</b></span>")

		robot
			desc = "Don't shove it up your nose, no matter how good of an idea that may seem to you. Wait, do you even have a nose? Maybe something else will happen if you try to stick it there."

			attack(mob/M, mob/user, def_zone)
				if (M == user)
					src.color = random_color()
					src.font_color = src.color
					src.color_name = hex2color_name(src.color)
					src.name = "[src.color_name] crayon"
					user.visible_message("<span class='notice'><b>\"Something\" special happens to [src]!</b></span>")
					return

				return ..()

		pixel
			maptext_crayon = TRUE
			font_size = 16
			font = "Small Fonts"
			New()
				..()
				src.name = "[src.color_name] pixel crayon"


	rainbow
		name = "strange crayon"
		color = "#FFFFFF"
		New()
			..()
			if (!ticker) // trying to avoid pre-game-start runtime bullshit
				SPAWN(3 SECONDS)
					src.font_color = random_saturated_hex_color(1)
					src.color_name = hex2color_name(src.font_color)
			else
				src.font_color = random_saturated_hex_color(1)
				src.color_name = hex2color_name(src.font_color)
				src.color = src.font_color

		write_on_turf(var/turf/T as turf, var/mob/user as mob, params)
			if (!T || !user || src.in_use || BOUNDS_DIST(T, user) > 0)
				return
			src.font_color = random_saturated_hex_color(1)
			src.color_name = hex2color_name(src.font_color)
			src.color = src.font_color
			..()

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] jams [src] up [his_or_her(user)] nose!</b></span>")
		SPAWN(0.5 SECONDS) // so we get a moment to think before we die
			user.take_brain_damage(120)
		user.u_equip(src)
		src.set_loc(user) // SHOULD be redundant but you never know.
		health_update_queue |= user
		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

	New()
		. = ..()
		src.create_inventory_counter()


	proc/write_input(mob/user)
		if(src.in_use)
			return null
		if(!user.client && ishuman(user))
			var/mob/living/carbon/human/H = user
			if(ismonkey(H) && H.ai_active)
				if(prob(90))
					return pick(src.c_symbol)
				else
					return pick(src.c_default)
		src.in_use = 1
		. = tgui_input_list(user, "What do you want to write?", "Write something", (isghostdrone(user) || !user.literate) ? src.c_symbol : (list("queue input") + src.c_default + src.c_symbol))
		if(. == "queue input")
			var/inp = tgui_input_text(user, "Type letters you want to write.", "Crayon Letter Queue")
			inp = uppertext(inp)
			phrase_log.log_phrase("crayon-queue", inp, no_duplicates=TRUE)
			. = list()
			for(var/i = 1 to min(length(inp), 100))
				var/c = copytext(inp, i, i + 1)
				if(maptext_crayon && c != " " || (c in src.c_default) || (c in src.c_char_to_symbol))
					. += c
		src.in_use = 0

	proc/update_inventory_counter()
		if(islist(src.symbol_setting) && length(src.symbol_setting))
			var/list/queue = src.symbol_setting
			var/first = queue[1]
			if(first == " ")
				first = "_"
			var/max_display_len = 5
			var/rest = ""
			for(var/i = 2 to min(max_display_len, length(queue)))
				rest += queue[i]
			if(length(queue) > max_display_len)
				rest += "..."
			src.inventory_counter.update_text("<span style='color:#ff000090;font-size:0.7em;-dm-text-outline: 1px #00000080;}'>[first]</span><span class='ol' style='color:#ffffff90;font-size:0.7em;-dm-text-outline: 1px #00000080;'>[rest]</span>")
		else if(istext(src.symbol_setting))
			src.inventory_counter.update_text(src.symbol_setting)
		else
			src.inventory_counter.update_text()

	attack_self(mob/user as mob)
		..()
		if (!user)
			return

		var/write_thing = write_input(user)

		if(write_thing)
			src.symbol_setting = write_thing
		else
			src.symbol_setting = null // and thus the click-floor-2-pick-shit goes on
		update_inventory_counter()


	write_on_turf(var/turf/T as turf, var/mob/user as mob, params)
		if (!T || !user || src.in_use || BOUNDS_DIST(T, user) > 0)
			return

		var/t // t is for what we're tdrawing

		if (length(src.symbol_setting))
			t = src.symbol_setting
		else
			t = write_input(user)

		if(isnull(t) || !length(t))
			return

		if(islist(t))
			var/list/queue = t
			if(length(t) == 1)
				src.symbol_setting = null
				t = t[1]
			else
				src.symbol_setting = queue.Copy(2) // remove first
				t = t[1]
			update_inventory_counter()

		if (!t || BOUNDS_DIST(T, user) > 0)
			return

		if(t == " ")
			return

		if(!src.maptext_crayon && (t in src.c_char_to_symbol))
			t = c_char_to_symbol[t]

		var/obj/decal/cleanable/writing/G
		if(src.maptext_crayon)
			G = make_cleanable(/obj/decal/cleanable/writing/maptext_dummy, T)
		else
			G = make_cleanable(/obj/decal/cleanable/writing, T)
		G.artist = user.key

		if(user.client) //I don't give a damn about monkeys writing stuff with crayon!!
			logTheThing(LOG_STATION, user, "writes on [T] with [src][src.material ? " (material: [src.material.name])" : null] [log_loc(T)]: [t]")

		var/size = 32

		if(src.maptext_crayon)
			G.maptext = "<span class='c' style='font-family:\"[font]\";font-size:[font_size]pt'>[t]</span>"
			G.maptext_width = 32 * 3
			G.maptext_height = 32 * 3
			G.maptext_x = -32
			G.maptext_y = size / 2 - font_size / 2
		else
			G.icon_state = "c[t]"
			if(src.font_size != 32)
				G.Scale(src.font_size / 32, src.font_size / 32)
		if (src.font_color && src.color_name)
			G.color = src.font_color
			G.color_name = src.color_name
			G.real_name = t
			G.UpdateName()
		apply_material_to_drawing(G, user)
		G.words = t
		if (islist(params) && params["icon-y"] && params["icon-x"])
			G.pixel_x = text2num(params["icon-x"]) - size / 2
			G.pixel_y = text2num(params["icon-y"]) - size / 2
		else
			G.pixel_x = rand(-4,4)
			G.pixel_y = rand(-4,4)
		if (src.reagents.total_volume)
			G.color = src.reagents.get_average_rgb()
			src.reagents.trans_to(G, PEN_REAGENT_CAPACITY)

			src.remove_filter("reagent_coloration")
			src.color_name = initial(src.color_name)
			src.font_color = initial(src.font_color)

	get_desc()
		. = ..()
		if(islist(src.symbol_setting))
			var/list/queue = src.symbol_setting
			. += " It currently has '[queue.Join()]' queued up."
		else if(src.symbol_setting)
			. += " It is currently set to write '[src.symbol_setting]'."

/* =============== CHALK (By Adhara) =============== */

/obj/item/pen/crayon/chalk
	name = "chalk"
	desc = "A stick of rock and dye that reminds you of your childhood. Don't get too carried away!"
	icon_state = "chalk-9"
	color = "#333333"
	font = "Comic Sans MS"
	var/chalk_health = 10 //10 uses before it snaps

	random
		New()
			..()
			src.color = "#[num2hex(rand(0, 255),2)][num2hex(rand(0, 255),2)][num2hex(rand(0, 255),2)]"
			src.font_color = src.color
			src.color_name = hex2color_name(src.color)
			src.name = "[src.color_name] chalk"

	proc/assign_color(var/color)
		if(isnull(color))
			color = "#ffffff"
		src.color = color
		src.font_color = src.color
		src.color_name = hex2color_name(color)
		src.name = "[src.color_name] chalk"

	proc/chalk_break(var/mob/user as mob)
		if (src.chalk_health <= 1)
			user.visible_message("<span class='alert'><b>\The [src] snaps into pieces so small that you can't use them to draw anymore!</b></span>")
			qdel(src)
			return
		if (src.chalk_health % 2)
			src.chalk_health--
		src.chalk_health /= 2
		var/obj/item/pen/crayon/chalk/C = new(get_turf(src))
		C.chalk_health = src.chalk_health
		C.assign_color(src.color)
		C.adjust_icon()
		src.adjust_icon()
		user.visible_message("<span class='alert'><b>\The [src] snaps in half! [pick("Fuck!", "Damn!", "Shit!", "Damnit!", "Fucking...", "Argh!", "Arse!", "Piss!")]")

	proc/adjust_icon()
		if (src.chalk_health > 10) //shouldnt happen but it could
			src.icon_state = "chalk-9"
			return
		else if (src.chalk_health < 0) //shouldnt happen but it could
			src.icon_state = "chalk-0"
		else
			src.icon_state = "chalk-[src.chalk_health]"

	write_on_turf(var/turf/T as turf, var/mob/user as mob)
		..()
		if (src.chalk_health <= 1)
			src.chalk_break(user)
			return
		if (prob(15))
			src.chalk_break(user)
			return
		src.chalk_health--
		src.adjust_icon()

	attack(mob/M, mob/user, def_zone)
		if (user == M && ishuman(M) && istype(M:mutantrace, /datum/mutantrace/lizard))
			user.visible_message("[user] shoves \the [src] into [his_or_her(user)] mouth and takes a bite out of it! [pick("That's sick!", "That's metal!", "That's punk as fuck!", "That's hot!")]")
			playsound(user.loc, 'sound/items/eatfoodshort.ogg', rand(30, 60), 1)
			src.chalk_health -= rand(2,5)
			if (src.chalk_health <= 1)
				src.chalk_break(user)
				return
			src.adjust_icon()
		else
			boutput(user, "You couldn't possibly eat \the [src], that's such a cold blooded thing to do!") //heh

	suicide(var/mob/user as mob)
		user.visible_message("<span class='alert'><b>[user] crushes \the [src] into a powder and then [he_or_she(user)] snorts it all! That can't be good for [his_or_her(user)] lungs!</b></span>")
		SPAWN(5 DECI SECONDS) // so we get a moment to think before we die
			user.take_oxygen_deprivation(175)
		user.u_equip(src)
		src.set_loc(user) //yes i did this dont ask why i cant literally think of anything better to do
		SPAWN(10 SECONDS)
			if (user)
				user.suiciding = 0
		qdel(src)
		return 1

/* =============== INFRARED PENS =============== */

/obj/item/pen/infrared
	desc = "A pen that can write in infrared."
	name = "infrared pen"
	color = "#FFEE44" // color var owns
	font_color = "#D20040"

	write_on_turf(var/turf/T as turf, var/mob/user as mob, params)
		if (!T || !user || src.in_use || BOUNDS_DIST(T, user) > 0)
			return
		if(!user.literate)
			boutput(user, "<span class='alert'>You don't know how to write.</span>")
			return
		src.in_use = 1
		var/t = tgui_input_text(user, "What do you want to write?", "Write")
		if (!t || BOUNDS_DIST(T, user) > 0)
			src.in_use = 0
			return
		var/obj/decal/cleanable/writing/infrared/G = make_cleanable(/obj/decal/cleanable/writing/infrared,T)
		G.artist = user.key

		logTheThing(LOG_STATION, user, "writes on [T] with [src][src.material ? " (material: [src.material.name])" : null] [log_loc(T)]: [t]")
		t = copytext(html_encode(t), 1, MAX_MESSAGE_LEN)
		if (src.font_color)
			G.color = src.font_color
		if(apply_material_to_drawing(G, user))
			;
		/*if (src.uses_handwriting && user?.mind?.handwriting)
			G.font = user.mind.handwriting
			G.webfont = 1
		*/
		else if (src.font)
			G.font = src.font
			//if (src.webfont)
				//G.webfont = 1
		G.words = "[t]"
		if (islist(params) && params["icon-y"] && params["icon-x"])
			G.pixel_x = text2num(params["icon-x"]) - 16
			G.pixel_y = text2num(params["icon-y"]) - 16
		else
			G.pixel_x = rand(-4,4)
			G.pixel_y = rand(-4,4)
		src.in_use = 0

/* =============== HAND LABELERS =============== */

/obj/item/hand_labeler
	name = "hand labeler"
	icon = 'icons/obj/writing.dmi'
	icon_state = "labeler"
	item_state = "labeler"
	desc = "Make things seem more important than they really are with the hand labeler!<br/>Can also name your fancy new area by naming the fancy new APC you created for it."
	var/label = null
	var/labels_left = 10
	flags = FPRINT | TABLEPASS | SUPPRESSATTACK
	c_flags = ONBELT
	rand_pos = 1

	get_desc()
		if (!src.label || !length(src.label))
			. += "<br>It doesn't have a label set."
		else
			. += "<br>Its label is set to \"[src.label]\"."

	attack(mob/M, mob/user)
		/* lol vvv
		if (!ismob(M)) // do this via afterattack()
			return
		*/
		if (!src.labels_left)
			boutput(user, "<span class='alert'>No labels left.</span>")
			return
		if (!src.label || !length(src.label))
			RemoveLabel(M, user)
			return

		src.Label(M, user)

	afterattack(atom/A, mob/user as mob)
		if (ismob(A)) // do this via attack()
			return
		if (!src.labels_left)
			boutput(user, "<span class='alert'>No labels left.</span>")
			return
		if (!src.label || !length(src.label))
			RemoveLabel(A, user)
			return

		src.Label(A, user)

	attack_self(mob/user as mob)
		if(!user.literate)
			boutput(user, "<span class='alert'>You don't know how to write.</span>")
			return
		tooltip_rebuild = 1
		var/holder = src.loc
		var/str = copytext(html_encode(tgui_input_text(user, "Label text?", "Set label", allowEmpty = TRUE)), 1, 32)
		if(str)
			phrase_log.log_phrase("label", str, no_duplicates=TRUE)
		if (src.loc != holder)
			return
		if(url_regex?.Find(str))
			str = null
		if (!str || !length(str))
			boutput(user, "<span class='notice'>Label text cleared.</span>")
			src.label = null
			return
		if (length(str) > 30)
			boutput(user, "<span class='alert'>Text too long.</span>")
			return
		src.label = "[str]"
		boutput(user, "<span class='notice'>You set the text to '[str]'.</span>")
		logTheThing(LOG_STATION, user, "sets a hand labeler label to \"[str]\".")

	proc/RemoveLabel(var/atom/A, var/mob/user, var/no_message = 0)
		if(!islist(A.name_suffixes))
			//Name_suffixes wasn't a list, but it is now.
			A.name_suffixes = list()
			return	//No need to clear stuff if it wasn't a list in the first place

		if (A.name_suffixes.len)
			A.remove_suffixes(1)
			A.UpdateName()
			user.visible_message("<span class='notice'><b>[user]</b> removes the label from [A].</span>",\
			"<span class='notice'>You remove the label from [A].</span>")
			return

	proc/Label(var/atom/A, var/mob/user, var/no_message = 0)
		var/obj/machinery/power/apc/apc = A
		if(istype(A,/obj/machinery/power/apc) && apc.area.type == /area/built_zone)
			if(tgui_alert(user, "Would you like to name this area, or just label the APC?", "Area Naming", list("Label the APC", "Name the Area")) == "Name the Area")
				var/area/built_zone/ba = apc.area
				ba.SetName(src.label)
				return

		if (user && !no_message)
			user.visible_message("<span class='notice'><b>[user]</b> labels [A] with \"[src.label]\".</span>",\
			"<span class='notice'>You label [A] with \"[src.label]\".</span>")
		if (istype(A, /obj/item/paper))
			A.name = "'[src.label]'"
		else
			if(!islist(A.name_suffixes))
				//Name_suffixes wasn't a list, but it is now.
				A.name_suffixes = list()
			A.name_suffix("([src.label])")
			A.UpdateName()
		playsound(src, 'sound/items/hand_label.ogg', 40, 1)
		if (user && !no_message)
			logTheThing(LOG_STATION, user, "labels [constructTarget(A,"combat")] with \"[src.label]\"")
		else if(!no_message)
			logTheThing(LOG_COMBAT, A, "has a label applied to them, \"[src.label]\"")
		A.add_fingerprint(user)

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] labels [him_or_her(user)]self \"DEAD\"!</b></span>")
		src.label = "DEAD"
		Label(user,user,1)

		user.TakeDamage("chest", 300, 0) //they have to die fast or it'd make even less sense
		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

/* =============== CLIPBOARDS =============== */

/obj/item/clipboard
	name = "clipboard"
	icon = 'icons/obj/writing.dmi'
	icon_state = "clipboard"
	var/obj/item/pen/pen = null
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "clipboard0"
	throwforce = 1
	w_class = W_CLASS_NORMAL
	throw_speed = 3
	throw_range = 10
	desc = "You can put paper on it. Ah, technology!"
	stamina_damage = 10
	stamina_cost = 1
	stamina_crit_chance = 5
	var/tmp/list/image/overlay_images = null

	New()
		..()
		BLOCK_SETUP(BLOCK_BOOK)
		src.overlay_images = list()
		overlay_images["paper"] = image('icons/obj/writing.dmi', "clipboard_paper")
		overlay_images["pen"] = image('icons/obj/writing.dmi', "clipboard_pen")

	attack_self(mob/user as mob)
		var/dat = "<B>Clipboard</B><BR>"
		if (src.pen)
			dat += "<A href='?src=\ref[src];pen=1'>Remove Pen</A><BR><HR>"
		for(var/obj/item/paper/P in src)
			dat += "<A href='?src=\ref[src];read=\ref[P]'>[P.name]</A> <A href='?src=\ref[src];title=\ref[P]'>Title</A> <A href='?src=\ref[src];remove=\ref[P]'>Remove</A><BR>"

		for(var/obj/item/photo/P in src) //Todo: make it actually show the photo.  Currently, using [bicon()] just makes an egg image pop up (??)
			dat += "<A href='?src=\ref[src];remove=\ref[P]'>[P.name]</A><br>"

		user.Browse(dat, "window=clipboard")
		onclose(user, "clipboard")
		return

	Topic(href, href_list)
		..()
		if ((usr.stat || usr.restrained()))
			return

		if (!(src in usr.contents))
			return

		src.add_dialog(usr)
		if (href_list["pen"])
			if (src.pen)
				usr.put_in_hand_or_drop(src.pen)
				src.pen = null
				src.update()

		else if (href_list["remove"])
			var/obj/item/P = locate(href_list["remove"])
			if (P && P.loc == src)
				usr.put_in_hand_or_drop(P)
				src.update()

		else if (href_list["read"])
			var/obj/item/paper/P = locate(href_list["read"])
			P.ui_interact(usr)

		else//Stuff that involves writing from here on down
			if(!usr.literate)
				boutput(usr, "<span class='alert'>You don't know how to write.</span>")
				return
			var/obj/item/pen/available_pen = null
			if (istype(usr.r_hand, /obj/item/pen))
				available_pen = usr.r_hand
			else if (istype(usr.l_hand, /obj/item/pen))
				available_pen = usr.l_hand
			else if (istype(src.pen, /obj/item/pen))
				available_pen = src.pen
			else
				boutput(usr, "<span class='alert'>You need a pen for that.</span>")
				return

			if (href_list["write"])
				var/obj/item/P = locate(href_list["write"])
				if ((P && P.loc == src))
					P.Attackby(available_pen, usr)

			else if (href_list["title"])
				if (istype(available_pen, /obj/item/pen/odd))
					boutput(usr, "<span class='alert'>Try as you might, you fail to write anything sensible.</span>")
					src.add_fingerprint(usr)
					return
				var/obj/item/P = locate(href_list["title"])
				if (P && P.loc == src)
					var/str = copytext(html_encode(input(usr,"What do you want to title this?","Title document","") as null|text), 1, 32)
					if (str == null || length(str) == 0)
						return
					if (length(str) > 30)
						boutput(usr, "<span class='alert'>A title that long will never catch on!</span>") //We're actually checking because titles above a certain length get clipped, but where's the fun in that
						return
					if(url_regex?.Find(str))
						return
					P.name = str

		src.add_fingerprint(usr)
		src.updateSelfDialog()
		return

	attack_hand(mob/user)
		if (!user.equipped() && (user.l_hand == src || user.r_hand == src))
			var/obj/item/paper/P = locate() in src
			if (P)
				user.put_in_hand_or_drop(P)
				src.update()
			src.add_fingerprint(user)
		else
			return ..()

	attackby(obj/item/P, mob/user)

		if (istype(P, /obj/item/paper) || istype(P, /obj/item/photo))
			if (src.contents.len < 15)
				user.drop_item()
				P.set_loc(src)
			else
				boutput(user, "<span class='notice'>Not enough space!!!</span>")
		else
			if (istype(P, /obj/item/pen))
				if (!src.pen)
					user.drop_item()
					P.set_loc(src)
					src.pen = P
			else
				return
		src.update()
		user.update_inhands()
		SPAWN(0)
			attack_self(user)
			return
		return

	proc/update()
		if (locate(/obj/item/paper) in src)
			src.UpdateOverlays(src.overlay_images["paper"], "paper")
		else
			src.ClearSpecificOverlays("paper")
		if (src.pen)
			src.UpdateOverlays(src.overlay_images["pen"], "pen")
		else
			src.ClearSpecificOverlays("pen")
		src.item_state = "clipboard[(locate(/obj/item/paper) in src) ? "1" : "0"]"

/obj/item/clipboard/with_pen
	New()
		..()
		src.pen = new /obj/item/pen(src)
		src.update()
		return

/obj/item/clipboard/with_pen/inspector
	icon = 'icons/obj/writing.dmi'
	icon_state = "clipboard_inspector"
	name = "inspector's clipboard"
	desc = "An official Nanotrasen Inspector's clipboard."
	var/inspector_name = null
	New()
		..()
		src.inhand_color = "#3F3F3F"
		START_TRACKING
	proc/set_owner(var/mob/living/carbon/human/M)
		inspector_name = M.real_name
		src.name = "Inspector [inspector_name]'s clipboard"
	disposing()
		STOP_TRACKING
		..()


/* =============== FOLDERS (wip) =============== */

/obj/item/folder //if any of these are bad numbers just change them im a bad idiot
	name = "folder"
	desc = "A folder for holding papers!"
	icon = 'icons/obj/writing.dmi'
	icon_state = "folder" //futureproofed icons baby
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "folder"
	w_class = W_CLASS_SMALL
	throwforce = 0
	w_class = W_CLASS_NORMAL
	throw_speed = 3
	throw_range = 10
	tooltip_flags = REBUILD_DIST

	attackby(var/obj/item/W, var/mob/user)
		if (istype(W, /obj/item/paper))
			if (src.contents.len < 10)
				boutput(user, "You cram the paper into the folder.")
				user.drop_item()
				W.set_loc(src)
				src.amount++
				tooltip_rebuild = 1

	attack_self(var/mob/user as mob)
		show_window(user)

	Topic(var/href, var/href_list)
		if (BOUNDS_DIST(src, usr) > 0 || iswraith(usr) || isintangible(usr))
			return
		if (is_incapacitated(usr))
			return
		..()

		if(href_list["action"] == "retrieve")
			usr.put_in_hand_or_drop(src.contents[text2num(href_list["id"])], usr)
			tooltip_rebuild = 1
			usr.visible_message("[usr] takes a piece of paper out of the folder.")
		show_window(usr) // to refresh the window

	get_desc(dist)
		var/fullness = ""
		if (dist > 4)
			fullness = "You're too far away to see how many papers are in the folder."
		else if (src.contents.len)
			fullness = "It looks like there's about [src.contents.len] papers in the folder."
		else
			fullness = "It looks like the folder's empty!"
		return fullness

	proc/show_window(var/user)
		var/output = "<html><head><title>Folder</title></head><body><br>"
		for(var/i = 1, i <= src.contents.len, i++)
			output += "<a href='?src=\ref[src];id=[i];action=retrieve'>[src.contents[i].name]</a><br>"
		output += "</body></html>"
		user << browse(output, "window=folder;size=400x600")

/* =============== BOOKLETS =============== */

/obj/item/paper_booklet
	name = "booklet"
	desc = "A stack of papers stapled together in a sequence intended for reading in."
	icon = 'icons/obj/writing.dmi'
	icon_state = "booklet-thin"
	uses_multiple_icon_states = 1
	//cogwerks - burning vars
	burn_point = 220
	burn_output = 900
	burn_possible = 1
	health = 10
	w_class = W_CLASS_TINY

	var/offset = 1

	var/list/obj/item/paper/pages = new/list()

	New()
		..()
		if (!offset)
			return
		else
			src.pixel_y = rand(-8, 8)
			src.pixel_x = rand(-9, 9)

	proc/give_title(var/mob/user)
		var/n_name = input(user, "What would you like to label the booklet?", "Booklet Labelling", null) as null|text //stolen from paper.dm
		if (!n_name)
			return
		n_name = copytext(html_encode(n_name), 1, 32)
		if (((src.loc == user || (src.loc && src.loc.loc == user)) && isalive(user)))
			src.name = "booklet[n_name ? "- '[n_name]'" : null]"
			logTheThing(LOG_SAY, user, "labels a paper booklet: [n_name]")
		src.add_fingerprint(user)
		return

	proc/display_booklet_contents(var/mob/user as mob, var/page = 1)
		set src in view()
		set category = "Local"

		if (!length(pages))
			return

		var/obj/item/paper/cur_page = pages[page]
		var/next_page = ""
		var/prev_page = "     "

		if(!user.literate)
			. = html_encode(illiterateGarbleText(cur_page.info)) // deny them ANY useful information
		else
			. = cur_page.info

			if (cur_page.form_startpoints && cur_page.form_endpoints)
				for (var/x = cur_page.form_startpoints.len, x > 0, x--)
					. = copytext(., 1, cur_page.form_startpoints[cur_page.form_startpoints[x]]) + "<a href='byond://?src=\ref[cur_page];form=[cur_page.form_startpoints[x]]'>" + copytext(., cur_page.form_startpoints[cur_page.form_startpoints[x]], cur_page.form_endpoints[cur_page.form_endpoints[x]]) + "</a>" + copytext(., cur_page.form_endpoints[cur_page.form_endpoints[x]])

		var/font_junk = ""
		for (var/i in cur_page.fonts)
			font_junk += "<link href='http://fonts.googleapis.com/css?family=[i]' rel='stylesheet' type='text/css'>"

		if (page > 1)
			prev_page = "<a href='byond://?src=\ref[src];action=prev_page;page=[page]'>Back</a> "
		if (page < pages.len)
			next_page = "<a href='byond://?src=\ref[src];action=next_page;page=[page]'>Next</a>"

		user.Browse("<HTML><HEAD><TITLE>[src.name] - [cur_page.name]</TITLE>[font_junk]</HEAD><BODY>Page [page] of [pages.len]<BR><a href='byond://?src=\ref[src];action=first_page'>First Page</a> <a href='byond://?src=\ref[src];action=title_book'>Title Book</a> <a href='byond://?src=\ref[src];action=last_page'>Last Page</a><BR>[prev_page]<a href='byond://?src=\ref[src];action=write;page=[page]'>Write</a> <a href='byond://?src=\ref[src];action=title_page;page=[page]'>Title</a> [next_page]<HR><TT>[.]</TT></BODY></HTML>", "window=[src.name]")

		onclose(user, "[src.name]")
		return null

	attack_self(var/mob/user)
		..()
		src.display_booklet_contents(user,1)

	examine(mob/user)
		. = ..()
		src.display_booklet_contents(user, 1)

	Topic(href, href_list)
		..()

		if ((usr.stat || usr.restrained()) || (BOUNDS_DIST(src, usr) > 0))
			return

		var/page_num = text2num(href_list["page"])
		var/obj/item/paper/cur_page = pages[page_num]

		switch (href_list["action"])
			if ("next_page")
				src.display_booklet_contents(usr,page_num + 1)
			if ("prev_page")
				src.display_booklet_contents(usr,page_num - 1)
			if ("write")
				if (istype(usr.equipped(), /obj/item/pen))
					cur_page.Attackby(usr.equipped(),usr)
					src.display_booklet_contents(usr,page_num)
			if ("title_page")
				if (cur_page.loc.loc == usr)
					cur_page.attack_self(usr)
			if ("title_book")
				src.give_title(usr)
			if ("first_page")
				src.display_booklet_contents(usr,1)
			if ("last_page")
				src.display_booklet_contents(usr,pages.len)

	attackby(var/obj/item/P, mob/user)
		if (istype(P, /obj/item/paper))
			var/obj/item/staple_gun/S = user.find_type_in_hand(/obj/item/staple_gun)
			if (S?.ammo)
				user.drop_item()
				src.pages += P
				P.set_loc(src)
				S.ammo--
				if (pages.len >= 10 && !icon_state == "booklet-thick")
					src.icon_state = "booklet-thick"
				src.visible_message("[user] staples [P] at the back of [src].")
				playsound(user,'sound/impact_sounds/Generic_Snap_1.ogg', 50, 1)
			else
				boutput(user, "<span class='alert'>You need a loaded stapler in hand to add this paper to the booklet.</span>")
		else
			..()
		return

/* =============== STICKY NOTES =============== */

/obj/item/postit_stack
	name = "SHOULDN'T BE SEEING THIS"
	desc = "OLD AND BAD"
	icon = 'icons/obj/writing.dmi'
	icon_state = "postit_stack"
	/* force = 1
	throwforce = 1
	w_class = W_CLASS_TINY
	amount = 10
	burn_point = 220
	burn_output = 200
	burn_possible = 1
	health = 2

	// @TODO
	// HOLY SHIT REMOVE THIS THESE OLD POST ITS ARE GONE or something idk fuck
	New()
		..()
		new /obj/item/item_box/postit(get_turf(src))

	afterattack(var/atom/A as mob|obj|turf, var/mob/user as mob, reach, params)
		if (!A)
			return
		if (isarea(A))
			return
		if (src.amount < 0)
			qdel(src)
			return
		var/turf/T = get_turf(A)
		var/obj/decal/cleanable/writing/postit/P = make_cleanable(/obj/decal/cleanable/writing/postit ,T)
		if (params && islist(params) && params["icon-y"] && params["icon-x"])
			// oh boy i can't wait to see people make huge post-it note trains across the station somehow!
			P.pixel_x = text2num(params["icon-x"]) - 16 //round(A.bound_width/2)
			P.pixel_y = text2num(params["icon-y"]) - 16 //round(A.bound_height/2)

		P.layer = A.layer + 1 //Do this instead so the stickers don't show over bushes and stuff.
		P.appearance_flags = RESET_COLOR

		user.visible_message("<b>[user]</b> sticks a sticky note to [T].",\
		"You stick a sticky note to [T].")
		var/obj/item/pen/pen = user.find_type_in_hand(/obj/item/pen)
		if (pen)
			P.Attackby(pen, user)
		src.amount --
		if (src.amount < 0)
			qdel(src)
			return
*/

/* ============== PRINTERS & TYPEWRITERS ================= */

/obj/item/pen/typewriter
	name = "National Notary 'Turbot Landing' experimental integrated typewriter pen"
	desc = "A mechanical pen that writes on paper inside the portable typewriter. How did you even get this?"
	font = "Monospace"
	clicknoise = FALSE

	write_on_turf(var/turf/T as turf, var/mob/user as mob, params)
		return

/obj/item/portable_typewriter
	name = "portable typewriter"
	desc = "A portable typewriter, whoa!"
	icon_state = "portable_typewriter"
	icon = 'icons/obj/writing.dmi'
	flags = FPRINT | TABLEPASS
	c_flags = ONBELT
	throwforce = 0
	w_class = W_CLASS_TINY
	var/paper_creation_cooldown = 1 MINUTE
	var/can_create_paper = FALSE

	var/obj/item/paper/stored_paper = null
	var/obj/item/pen/pen

	New()
		..()
		if(isnull(src.pen))
			src.pen = new /obj/item/pen/typewriter(src)

	attack_self(mob/user)
		. = ..()
		if(isnull(src.stored_paper))
			if(!src.can_create_paper)
				return
			if(ON_COOLDOWN(src, "create_paper", src.paper_creation_cooldown))
				boutput(user, "<span class='alert'>\The [src]'s paper-manufacturing mechanism is recharging.</span>")
				return
			playsound(src.loc, 'sound/machines/printer_thermal.ogg', 30, 0, pitch=0.7)
			src.stored_paper = new/obj/item/paper/thermal/portable_printer(src)
			src.UpdateIcon()
			src.stored_paper.Attackby(src.pen, user)
		else
			src.stored_paper.Attackby(src.pen, user)

	attack_hand(mob/user)
		if(src.loc == user && src.stored_paper)
			var/obj/item/paper/paper = src.stored_paper
			if(src.eject_paper(user.loc))
				user.put_in_hand_or_drop(paper)
		else
			. = ..()

	update_icon()
		if(src.stored_paper)
			src.icon_state = "portable_typewriter-full"
		else
			src.icon_state = "portable_typewriter"

	proc/eject_paper(atom/target, mob/user)
		if(isnull(src.stored_paper))
			return FALSE
		boutput(user, "<span class='notice'>\The [src] ejects \the [src.stored_paper].</span>")
		if(!ON_COOLDOWN(src, "eject_sound", 3 SECONDS))
			playsound(src.loc, 'sound/machines/typewriter.ogg', 60, 0)
			// CC0 license on the sound, source here: https://freesound.org/people/tams_kp/sounds/43559/
		src.stored_paper.set_loc(target)
		src.stored_paper = null
		src.UpdateIcon()
		return TRUE

	attackby(obj/item/W, mob/user, params)
		if(istype(W, /obj/item/paper))
			user.drop_item(W)
			W.set_loc(src)
			src.stored_paper = W
			src.UpdateIcon()
		else
			. = ..()

	afterattack(atom/target, mob/user, reach, params)
		. = ..()
		if(istype(target, /obj/item/paper))
			var/obj/item/paper/paper = target
			if(isnull(stored_paper))
				paper.set_loc(src)
				src.stored_paper = paper
				user.visible_message("<span class='notice'>[user] sucks up \the [paper] into \the [src].</span>", "<span class='notice'>You suck up \the [paper] into \the [src].</span>")
				src.UpdateIcon()
			else
				boutput(user, "<span class='alert'>\The [src] already has a paper in it.</span>")
		else if(isfloor(target) || istype(target, /obj/table))
			if(src.stored_paper)
				src.eject_paper(get_turf(target), user)

/obj/item/portable_typewriter/borg
	name = "integrated typewriter"
	desc = "A built-in typewriter that can even create its own paper, whoa!"
	paper_creation_cooldown = 10 SECONDS
	can_create_paper = TRUE
