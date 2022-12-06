
/obj/item/device/radio/headset
	name = "radio headset"
	icon = 'icons/obj/clothing/item_ears.dmi'
	wear_image_icon = 'icons/mob/clothing/ears.dmi'
	icon_state = "headset"
	inhand_image_icon = 'icons/mob/inhand/hand_headgear.dmi'
	item_state = "headset"
	w_class = W_CLASS_TINY
	rand_pos = 0
	var/protective_temperature = 0
	speaker_range = 0
	desc = "A standard-issue device that can be worn on a crewmember's ear to allow hands-free communication with the rest of the crew."
	flags = FPRINT | TABLEPASS | CONDUCT
	icon_override = "civ"
	icon_tooltip = "Civilian"
	wear_layer = MOB_EARS_LAYER
	duration_remove = 1.5 SECONDS
	duration_put = 1.5 SECONDS
	var/obj/item/device/radio_upgrade/wiretap = null
	hardened = 0

	attackby(obj/item/O, mob/user)
		if (istype(O, /obj/item/device/radio_upgrade))
			var/obj/item/device/radio_upgrade/R = O
			if (wiretap)
				boutput(user, "<span class='alert'>This [src] already has a wiretap installed! It doesn't have room for any more!</span>")
				return
			src.wiretap = R

			for (var/frequency in R.secure_frequencies)
				if (!(frequency in src.secure_frequencies))
					src.set_secure_frequency(frequency, R.secure_frequencies[frequency])
			for (var/class in R.secure_classes)
				if (!(class in src.secure_classes))
					src.secure_classes[class] = R.secure_classes[class]

			boutput(user, "<span class='notice'>You install [R] into [src].</span>")
			playsound(src.loc , 'sound/items/Deconstruct.ogg', 80, 0)
			set_secure_frequencies(src)
			R.set_loc(src)
			user.u_equip(R)

		else if (issnippingtool(O) && wiretap)
			boutput(user, "<span class='notice'>You begin removing [src.wiretap] from [src].</span>")
			if (!do_after(user, 2 SECONDS))
				boutput(user, "<span class='alert'>You were interrupted!.</span>")
				return
			boutput(user, "<span class='notice'>You remove [src.wiretap] from [src].</span>")
			playsound(src.loc , 'sound/items/Deconstruct.ogg', 80, 0)
			user.put_in_hand_or_drop(src.wiretap)
			src.wiretap = null

			var/obj/item/device/radio/headset/headset = new src.type
			src.secure_frequencies = headset.secure_frequencies
			src.secure_classes = headset.secure_classes
			set_secure_frequencies(src)
		..()

/obj/item/device/radio/headset/wizard
	emp_act()
		return //hax

/obj/item/device/radio/headset/command
	name = "command headset"
	desc = "A radio headset capable of communicating over the Command frequency, for use by support staff."
	icon_state = "command headset"
	secure_frequencies = list("h" = R_FREQ_COMMAND)
	secure_classes = list("h" = RADIOCL_COMMAND)
	icon_override = "head"
	icon_tooltip = "Head of Staff"

/obj/item/device/radio/headset/command/ai
	name = "\improper AI headset"
	desc = "A radio headset capable of communicating over additional, secure frequencies. This one seems designed for an AI."
	secure_frequencies = list(
		"h" = R_FREQ_COMMAND,
		"g" = R_FREQ_SECURITY,
		"e" = R_FREQ_ENGINEERING,
		"r" = R_FREQ_RESEARCH,
		"m" = R_FREQ_MEDICAL,
		"c" = R_FREQ_CIVILIAN,
		)
	secure_classes = list(
		"h" = RADIOCL_COMMAND,
		"g" = RADIOCL_SECURITY,
		"e" = RADIOCL_ENGINEERING,
		"r" = RADIOCL_RESEARCH,
		"m" = RADIOCL_MEDICAL,
		"c" = RADIOCL_CIVILIAN,
		)
	icon_override = "ai"
	icon_tooltip = "Artificial Intelligence"

/obj/item/device/radio/headset/command/nt
	name = "\improper NT headset"
	desc = "Issued to NanoTrasen ancillaries, this radio headset can access several secure radio channels."
	secure_frequencies = list(
		"h" = R_FREQ_COMMAND,
		"g" = R_FREQ_SECURITY,
		)
	secure_classes = list(
		"h" = RADIOCL_COMMAND,
		"g" = RADIOCL_SECURITY,
		)
	icon_override = "nt"
	icon_tooltip = "NanoTrasen Special Operative"

/obj/item/device/radio/headset/command/captain
	name = "captain's headset"
	desc = "So the captain can know exactly what's going on around the station while doing nothing about any of it."
	icon_state = "captain headset"
	secure_frequencies = list(
		"h" = R_FREQ_COMMAND,
		"g" = R_FREQ_SECURITY,
		"e" = R_FREQ_ENGINEERING,
		"r" = R_FREQ_RESEARCH,
		"m" = R_FREQ_MEDICAL,
		"c" = R_FREQ_CIVILIAN,
		)
	secure_classes = list(
		"h" = RADIOCL_COMMAND,
		"g" = RADIOCL_SECURITY,
		"e" = RADIOCL_ENGINEERING,
		"r" = RADIOCL_RESEARCH,
		"m" = RADIOCL_MEDICAL,
		"c" = RADIOCL_CIVILIAN,
		)
	icon_override = "cap"
	icon_tooltip = "Captain"

/obj/item/device/radio/headset/command/radio_show_host
	name = "radio show host's headphones"
	desc = "This is a pair of wireless studio headphones with a pastel retro look and a flip-down mic. Either someone's really passionate about their work, or they want to look old-school. Maybe both!"
	icon_state = "radio"
	secure_frequencies = list(
		"e" = R_FREQ_ENGINEERING,
		"r" = R_FREQ_RESEARCH,
		"m" = R_FREQ_MEDICAL,
		"c" = R_FREQ_CIVILIAN,
		)
	secure_classes = list(
		"e" = RADIOCL_ENGINEERING,
		"r" = RADIOCL_RESEARCH,
		"m" = RADIOCL_MEDICAL,
		"c" = RADIOCL_CIVILIAN,
		)
	icon_override = "rh"
	icon_tooltip = "Radio Show Host"

	setupProperties()
		..()
		setProperty("disorient_resist_ear", 20)

/obj/item/device/radio/headset/command/comm_officer
	name = "communications officer's headset"
	desc = "Used by the communications officer, this headset can communicate over multiple secure frequencies. These things have been a rare sight as of late."
	secure_frequencies = list(
		"h" = R_FREQ_COMMAND,
		"g" = R_FREQ_SECURITY,
		"e" = R_FREQ_ENGINEERING,
		"r" = R_FREQ_RESEARCH,
		"m" = R_FREQ_MEDICAL,
		"c" = R_FREQ_CIVILIAN,
		)
	secure_classes = list(
		"h" = RADIOCL_COMMAND,
		"g" = RADIOCL_SECURITY,
		"e" = RADIOCL_ENGINEERING,
		"r" = RADIOCL_RESEARCH,
		"m" = RADIOCL_MEDICAL,
		"c" = RADIOCL_CIVILIAN,
		)
	icon_override = "co"
	icon_tooltip = "Communications Officer"

/obj/item/device/radio/headset/command/hos
	name = "head of security's headset"
	desc = "This headset has been worn by selfless heroes, cold-blooded killers, and everything in between. Where do you fall on that spectrum?"
	secure_frequencies = list(
		"h" = R_FREQ_COMMAND,
		"g" = R_FREQ_SECURITY,
		)
	secure_classes = list(
		"h" = RADIOCL_COMMAND,
		"g" = RADIOCL_SECURITY,
		)
	icon_override = "hos"
	icon_tooltip = "Head of Security"

/obj/item/device/radio/headset/command/hop
	name = "head of personnel's headset"
	desc = "The HoP can listen to the security frequency, but they can't speak on it anymore. Not since the incident."
	secure_frequencies = list(
		"h" = R_FREQ_COMMAND,
		"e" = R_FREQ_ENGINEERING,
		"r" = R_FREQ_RESEARCH,
		"m" = R_FREQ_MEDICAL,
		"c" = R_FREQ_CIVILIAN,
		)
	secure_classes = list(
		"h" = RADIOCL_COMMAND,
		"g" = RADIOCL_SECURITY,
		"e" = RADIOCL_ENGINEERING,
		"r" = RADIOCL_RESEARCH,
		"m" = RADIOCL_MEDICAL,
		"c" = RADIOCL_CIVILIAN,
		)
	icon_override = "hop"
	icon_tooltip = "Head of Personnel"

/obj/item/device/radio/headset/command/rd
	name = "research director's headset"
	desc = "This headset can receive on the Medical channel in addition to other secure frequencies. The 'sci' part of 'medsci'."
	secure_frequencies = list(
		"h" = R_FREQ_COMMAND,
		"r" = R_FREQ_RESEARCH,
		"m" = R_FREQ_MEDICAL,
		)
	secure_classes = list(
		"h" = RADIOCL_COMMAND,
		"r" = RADIOCL_RESEARCH,
		"m" = RADIOCL_MEDICAL,
		)
	icon_override = "rd"
	icon_tooltip = "Research Director"

/obj/item/device/radio/headset/command/md
	name = "medical director's headset"
	desc = "This headset can receive on the Research channel in addition to other secure frequencies. The 'med' part of 'medsci'."
	secure_frequencies = list(
		"h" = R_FREQ_COMMAND,
		"r" = R_FREQ_RESEARCH,
		"m" = R_FREQ_MEDICAL,
		)
	secure_classes = list(
		"h" = RADIOCL_COMMAND,
		"r" = RADIOCL_RESEARCH,
		"m" = RADIOCL_MEDICAL,
		)
	icon_override = "md"
	icon_tooltip = "Medical Director"

/obj/item/device/radio/headset/command/ce
	name = "chief engineer's headset"
	desc = "Do you hear it? The fires are roaring. The generator hungers."
	secure_frequencies = list(
		"h" = R_FREQ_COMMAND,
		"e" = R_FREQ_ENGINEERING,
		)
	secure_classes = list(
		"h" = RADIOCL_COMMAND,
		"e" = RADIOCL_ENGINEERING,
		)
	icon_override = "ce"
	icon_tooltip = "Chief Engineer"

/obj/item/device/radio/headset/security
	name = "security headset"
	desc = "Worn by security officers, this thing could cause real problems in the wrong ears."
	icon_state = "sec headset"
	secure_frequencies = list("g" = R_FREQ_SECURITY)
	secure_classes = list(
		"g" = RADIOCL_SECURITY,
		)
	icon_override = "sec"
	icon_tooltip = "Security"

	get_desc(dist, mob/user)
		if (user.mind?.special_role)
			. += "<span class='alert'><b>Good.</b></span>"
		else
			. += "Keep it safe!"

/obj/item/device/radio/headset/detective
	name = "detective's headset"
	desc = "In addition to having access to the Security radio channel, this headset also features private frequency that's suited for only the sneakiest sleuthing."
	icon_state = "sec headset" //I see no use for a special sprite for the det headset itself.
	secure_frequencies = list(
		"g" = R_FREQ_SECURITY,
		"d" = R_FREQ_DETECTIVE,
		)
	secure_classes = list(
		"g" = RADIOCL_SECURITY,
		"d" = RADIOCL_DETECTIVE,
		)
	icon_override = "det" //neat little magnifying glass sprite I made
	icon_tooltip = "Detective"

/obj/item/device/radio/headset/engineer
	name = "engineering headset"
	desc = "They stopped spending extra money trying to make these heat-resistant a while ago."
	icon_state = "engine headset"
	secure_frequencies = list("e" = R_FREQ_ENGINEERING)
	secure_classes = list(
		"e" = RADIOCL_ENGINEERING,
		)
	icon_override = "eng"
	icon_tooltip = "Engineer"

/obj/item/device/radio/headset/medical
	name = "medical headset"
	desc = "Nominally worn by the trained staff of the medbay, this headset can be counted on to either be utterly silent or to be squawking constantly at any given moment."
	icon_state = "med headset"
	secure_frequencies = list("m" = R_FREQ_MEDICAL)
	secure_classes = list(
		"m" = RADIOCL_MEDICAL,
		)
	icon_override = "med"
	icon_tooltip = "Medical"

/obj/item/device/radio/headset/research
	name = "research headset"
	desc = "A science headset, for science. Whether directly or by proxy, these are frequently burned, exploded, corroded, dissolved, shot, and teleported, to name a few."
	icon_state = "research headset"
	secure_frequencies = list("r" = R_FREQ_RESEARCH)
	secure_classes = list(
		"r" = RADIOCL_RESEARCH,
		)
	icon_override = "sci"
	icon_tooltip = "Scientist"

/obj/item/device/radio/headset/civilian
	name = "civilian headset"
	desc = "These headsets are used by the civilian staff, who are employed to keep the station clean, fed, and productive. As if."
	icon_state = "civ headset"
	secure_frequencies = list("c" = R_FREQ_CIVILIAN)
	secure_classes = list(
		"c" = RADIOCL_CIVILIAN,
		)
	icon_tooltip = "Civilian"

/obj/item/device/radio/headset/shipping
	name = "shipping headset"
	desc = "Used by the station's quartermasters, who move freight and master the art of watching numbers go up and down."
	icon_state = "shipping headset"
	secure_frequencies = list(
	"e" = R_FREQ_ENGINEERING,
	"c" = R_FREQ_CIVILIAN)
	secure_classes = list(
		"e" = RADIOCL_ENGINEERING,
		"c" = RADIOCL_CIVILIAN,
		)
	icon_override = "qm"
	icon_tooltip = "Quartermaster"

/obj/item/device/radio/headset/miner
	name = "mining headset"
	desc = "Rumor has it that these grow naturally in space, typically alongside discarded breath masks or space suits drenched in human blood. Nature is beautiful."
	icon_state = "shipping headset"
	secure_frequencies = list(
	"e" = R_FREQ_ENGINEERING)
	secure_classes = list(
		"e" = RADIOCL_ENGINEERING,
		)
	icon_override = "Min"
	icon_tooltip = "Miner"

/obj/item/device/radio/headset/mail
	name = "mailman's headset"
	desc = "In a land of belt hells, the pit fiend is king."
	icon_state = "command headset"
	secure_frequencies = list(
	"h" = R_FREQ_COMMAND,
	"e" = R_FREQ_ENGINEERING)
	secure_classes = list(
		"h" = RADIOCL_COMMAND,
		"e" = RADIOCL_ENGINEERING,
		)
	icon_override = "mail"
	icon_tooltip = "Mailman"

/obj/item/device/radio/headset/clown
	name = "clown's headset"
	desc = "Anybody using this headset is unlikely to be taken seriously."
	icon_override = "clown"
	icon_tooltip = "Clown"

/obj/item/device/radio/headset/ghost_buster
	name = "\improper Ghost Buster's headset"
	desc = "So you can hear those who are calling you when there's something strange in their department."
	icon_state = "multi headset"
	secure_frequencies = list(
		"h" = R_FREQ_COMMAND,
		"g" = R_FREQ_SECURITY,
		"e" = R_FREQ_ENGINEERING,
		"r" = R_FREQ_RESEARCH,
		"m" = R_FREQ_MEDICAL,
		"c" = R_FREQ_CIVILIAN,
		)
	secure_classes = list(
		"h" = RADIOCL_COMMAND,
		"g" = RADIOCL_SECURITY,
		"e" = RADIOCL_ENGINEERING,
		"r" = RADIOCL_RESEARCH,
		"m" = RADIOCL_MEDICAL,
		"c" = RADIOCL_CIVILIAN,
		)
	icon_override = "ghost_buster"
	icon_tooltip = "Ghost Buster"

/obj/item/device/radio/headset/syndicate
	name = "radio headset"
	desc = "A radio headset that is also capable of communicating over- wait, isn't that frequency illegal?"
	icon_state = "headset"
	chat_class = RADIOCL_SYNDICATE
	secure_frequencies = list("z" = R_FREQ_SYNDICATE)
	secure_classes = list(RADIOCL_SYNDICATE)
	protected_radio = 1 // Ops can spawn with the deaf trait.
	icon_override = "syndie"
	icon_tooltip = "Syndicate Operative"

	New()
		..()
		SPAWN(1 SECOND)
			var/the_frequency = R_FREQ_SYNDICATE
			if (ticker?.mode && istype(ticker.mode, /datum/game_mode/nuclear))
				var/datum/game_mode/nuclear/N = ticker.mode
				the_frequency = N.agent_radiofreq
			src.frequency = the_frequency // let's see if this stops rounds from being ruined every fucking time

	leader
		icon_override = "syndieboss"
		icon_tooltip = "Syndicate Commander"

	bard
		name = "military headset"
		desc = "A two-way radio headset designed to protect the wearer from dangerous levels of noise from guns, woofers, and tweeters."
		secure_frequencies = list("z" = R_FREQ_SYNDICATE, "l"=R_FREQ_LOUDSPEAKERS)
		secure_classes = list("z" = RADIOCL_SYNDICATE, "l"=RADIOC_OTHER)
		icon_state = "comtac"

		New()
			..()
			START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)

		setupProperties()
			..()
			setProperty("disorient_resist_ear", 100)

		pickup(mob/user)
			if(isvirtual(user))
				SPAWN(0)
					var/obj/item/clothing/ears/plugs = new /obj/item/clothing/ears/earmuffs/earplugs(src.loc)
					plugs.name = src.name
					plugs.desc = src.desc
					plugs.icon_state = src.icon_state
					user.u_equip(src)
					qdel(src)
					user.put_in_hand_or_drop(plugs)

		disposing()
			STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
			..()

	comtac
		name = "military headset"
		icon_state = "comtac"
		desc = "A two-way radio headset designed to protect the wearer from dangerous levels of noise during gunfights."

		New()
			..()
			START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)

		setupProperties()
			..()
			setProperty("disorient_resist_ear", 100)

		disposing()
			STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
			..()

/obj/item/device/radio/headset/deaf
	name = "auditory headset"
	desc = "A radio headset that also interfaces with the ear canal, allowing the deaf to hear normally while wearing it."
	icon_state = "deaf headset"
	item_state = "headset"
	block_hearing_when_worn = HEARING_ANTIDEAF

/obj/item/device/radio/headset/gang
	name = "radio headset"
	desc = "A radio headset, pre-tuned to your gang's frequency. Convenient!"
	secure_frequencies = list("g" = R_FREQ_GANG) //placeholder so it sets up right
	secure_classes = list("g" = RADIOCL_SYNDICATE)
	protected_radio = 1

/obj/item/device/radio/headset/multifreq
	name = "multi-frequency headset"
	desc = "A radio headset that can communicate over multiple customizable channels."
	icon_state = "multi headset"
	secure_frequencies = list("q" = R_FREQ_MULTI)
	secure_classes = list(RADIOCL_OTHER)

/obj/item/device/radio/headset/multifreq/attack_self(mob/user as mob)
	src.add_dialog(user)
	var/t1
	if (src.b_stat)
		t1 = {"
-------<BR>
Green Wire: <A href='byond://?src=\ref[src];wires=4'>[src.wires & 4 ? "Cut" : "Mend"] Wire</A><BR>
Red Wire:   <A href='byond://?src=\ref[src];wires=2'>[src.wires & 2 ? "Cut" : "Mend"] Wire</A><BR>
Blue Wire:  <A href='byond://?src=\ref[src];wires=1'>[src.wires & 1 ? "Cut" : "Mend"] Wire</A><BR>"}
	else
		t1 = "-------"
	var/dat = {"
<TT>
Microphone [src.broadcasting ? "<A href='byond://?src=\ref[src];talk=0'>Always on</A>" : "<A href='byond://?src=\ref[src];talk=1'>Push to talk</A>"]<BR>
Speaker: [src.listening ? "<A href='byond://?src=\ref[src];listen=0'>On</A>" : "<A href='byond://?src=\ref[src];listen=1'>Off</A>"]<BR>
Frequency:
<A href='byond://?src=\ref[src];freq=-10'>-</A>
<A href='byond://?src=\ref[src];freq=-2'>-</A>
[format_frequency(src.frequency)]
<A href='byond://?src=\ref[src];freq=2'>+</A>
<A href='byond://?src=\ref[src];freq=10'>+</A><BR>
Secure Frequency:
<A href='byond://?src=\ref[src];sfreq=-10'>-</A>
<A href='byond://?src=\ref[src];sfreq=-2'>-</A>
[format_frequency(src.secure_frequencies["h"])]
<A href='byond://?src=\ref[src];sfreq=2'>+</A>
<A href='byond://?src=\ref[src];sfreq=10'>+</A><BR>
[t1]
</TT>"}
	user.Browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/device/radio/headset/multifreq/Topic(href, href_list)
	if (usr.stat)
		return
	if ((usr.contents.Find(src) || in_interact_range(src, usr) && istype(src.loc, /turf)) || (usr.loc == src.loc) || (issilicon(usr)))
		src.add_dialog(usr)
		if (href_list["sfreq"])
			var/new_frequency = sanitize_frequency(text2num_safe("[secure_frequencies["h"]]") + text2num_safe(href_list["sfreq"]))
			set_secure_frequency("h", new_frequency)
	return ..(href, href_list)

/obj/item/device/radio_upgrade //traitor radio upgrader
	name = "wiretap radio upgrade"
	desc = "An illegal device capable of picking up and sending all secure station radio signals, along with a secure Syndicate frequency. Can be installed in a radio headset. Does not actually work by wiretapping."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "syndie_upgr"
	w_class = W_CLASS_TINY
	is_syndicate = 1
	mats = 12
	var/secure_frequencies = list(
		"h" = R_FREQ_COMMAND,
		"g" = R_FREQ_SECURITY,
		"e" = R_FREQ_ENGINEERING,
		"r" = R_FREQ_RESEARCH,
		"m" = R_FREQ_MEDICAL,
		"c" = R_FREQ_CIVILIAN,
		"z" = R_FREQ_SYNDICATE,
		)
	var/secure_classes = list(
		"h" = RADIOCL_COMMAND,
		"g" = RADIOCL_SECURITY,
		"e" = RADIOCL_ENGINEERING,
		"r" = RADIOCL_RESEARCH,
		"m" = RADIOCL_MEDICAL,
		"c" = RADIOCL_CIVILIAN,
		"z" = RADIOCL_SYNDICATE,
		)

	conspirator
		name = "private radio channel upgrade"
		desc = "A device capable of communicating over a private secure radio channel. Can be installed in a radio headset."
		secure_frequencies = null
		secure_classes = null

		New()
			..()
			var/datum/game_mode/conspiracy/C = new /datum/game_mode/conspiracy
			if (ticker?.mode && istype(ticker.mode, /datum/game_mode/conspiracy))
				C = ticker.mode
			src.secure_frequencies = list("z" = C.agent_radiofreq)
			src.secure_classes = list("z" = RADIOCL_SYNDICATE)
