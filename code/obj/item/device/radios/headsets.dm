
/obj/item/device/radio/headset
	name = "Radio Headset"
	icon = 'icons/obj/clothing/item_ears.dmi'
	wear_image_icon = 'icons/mob/ears.dmi'
	icon_state = "headset"
	inhand_image_icon = 'icons/mob/inhand/hand_headgear.dmi'
	item_state = "headset"
	w_class = 1
	rand_pos = 0
	var/protective_temperature = 0
	speaker_range = 0
	desc = "A standard-issue device that can be worn on a crewmember's ear to allow hands-free communication with the rest of the crew."
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	icon_override = "civ"
	var/haswiretap

	attackby(obj/item/R as obj, mob/user as mob)
		if (istype(R, /obj/item/device/radio_upgrade))
			if (haswiretap)
				boutput(user, "<span class='alert'>This [src] already has a Wiretap Upgrade installed! What good could possibly come from having two?! </span>")
				return
			src.haswiretap = 1
			src.secure_frequencies = list(
				"h" = R_FREQ_COMMAND,
				"g" = R_FREQ_SECURITY,
				"e" = R_FREQ_ENGINEERING,
				"r" = R_FREQ_RESEARCH,
				"m" = R_FREQ_MEDICAL,
				"c" = R_FREQ_CIVILIAN,
				)
			src.secure_classes = list(
				"h" = RADIOCL_COMMAND,
				"g" = RADIOCL_SECURITY,
				"e" = RADIOCL_ENGINEERING,
				"r" = RADIOCL_RESEARCH,
				"m" = RADIOCL_MEDICAL,
				"c" = RADIOCL_CIVILIAN,
				)
			boutput(user, "<span class='notice'>Wiretap Radio Upgrade successfully installed in the [src].</span>")
			playsound(src.loc ,"sound/items/Deconstruct.ogg", 80, 0)
			set_secure_frequencies(src)
			qdel(R)

		..()


/obj/item/device/radio/headset/command
	name = "Command Headset"
	desc = "A radio headset capable of communicating over multiple secure frequencies."
	icon_state = "command headset"
	secure_frequencies = list("h" = R_FREQ_COMMAND)
	secure_classes = list("h" = RADIOCL_COMMAND)
	icon_override = "head"

/obj/item/device/radio/headset/command/ai
	name = "AI Headset"
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

/obj/item/device/radio/headset/command/nt
	name = "NT Headset"
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
	icon_override = "nt"

/obj/item/device/radio/headset/command/captain
	name = "Captain's Headset"
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

/obj/item/device/radio/headset/command/radio_show_host
	name = "Radio show host's Headset"
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
	icon_override = "civ"

/obj/item/device/radio/headset/command/hos
	name = "Head of Security's Headset"
	secure_frequencies = list(
		"h" = R_FREQ_COMMAND,
		"g" = R_FREQ_SECURITY,
		)
	secure_classes = list(
		"h" = RADIOCL_COMMAND,
		"g" = RADIOCL_SECURITY,
		)
	icon_override = "hos"

/obj/item/device/radio/headset/command/hop
	name = "Head of Personnel's Headset"
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

/obj/item/device/radio/headset/command/rd
	name = "Research Director's Headset"
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

/obj/item/device/radio/headset/command/md
	name = "Medical Director's Headset"
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

/obj/item/device/radio/headset/command/ce
	name = "Chief Engineer's Headset"
	secure_frequencies = list(
		"h" = R_FREQ_COMMAND,
		"e" = R_FREQ_ENGINEERING,
		)
	secure_classes = list(
		"h" = RADIOCL_COMMAND,
		"e" = RADIOCL_ENGINEERING,
		)
	icon_override = "ce"

/obj/item/device/radio/headset/security
	name = "Security Headset"
	desc = "A radio headset that is also capable of communicating over the Security radio channels."
	icon_state = "sec headset"
	secure_frequencies = list("g" = R_FREQ_SECURITY)
	secure_classes = list(
		"g" = RADIOCL_SECURITY,
		)
	icon_override = "sec"

/obj/item/device/radio/headset/engineer
	name = "Engineering Headset"
	desc = "A radio headset that is also capable of communicating over the Engineering radio channels."
	icon_state = "engine headset"
	secure_frequencies = list("e" = R_FREQ_ENGINEERING)
	secure_classes = list(
		"e" = RADIOCL_ENGINEERING,
		)
	icon_override = "eng"

/obj/item/device/radio/headset/medical
	name = "Medical Headset"
	desc = "A radio headset that is also capable of communicating over the Medical radio channels."
	icon_state = "med headset"
	secure_frequencies = list("m" = R_FREQ_MEDICAL)
	secure_classes = list(
		"m" = RADIOCL_MEDICAL,
		)
	icon_override = "med"

/obj/item/device/radio/headset/research
	name = "Research Headset"
	desc = "A radio headset that is also capable of communicating over the Research radio channels."
	icon_state = "research headset"
	secure_frequencies = list("r" = R_FREQ_RESEARCH)
	secure_classes = list(
		"r" = RADIOCL_RESEARCH,
		)
	icon_override = "sci"

/obj/item/device/radio/headset/civilian
	name = "Civilian Headset"
	desc = "A radio headset that is also capable of communicating over the Civilian radio channels."
	icon_state = "civ headset"
	secure_frequencies = list("c" = R_FREQ_CIVILIAN)
	secure_classes = list(
		"c" = RADIOCL_CIVILIAN,
		)

/obj/item/device/radio/headset/shipping
	name = "Shipping Headset"
	desc = "A radio headset that is also capable of communicating over the Engineering and Civilian channels."
	icon_state = "shipping headset"
	secure_frequencies = list(
	"e" = R_FREQ_ENGINEERING,
	"c" = R_FREQ_CIVILIAN)
	secure_classes = list(
		"e" = RADIOCL_ENGINEERING,
		"c" = RADIOCL_CIVILIAN,
		)
	icon_override = "qm"

/obj/item/device/radio/headset/clown
	name = "Clown's Headset"
	desc = "A standard-issue device that can be worn on a crewmember's ear to allow hands-free communication with the rest of the crew. Anybody using this one is unlikely to be taken seriously."
	icon_override = "clown"

/obj/item/device/radio/headset/syndicate
	name = "Radio Headset"
	desc = "A radio headset that is also capable of communicating over... wait, isn't that frequency illegal?"
	icon_state = "headset"
	secure_frequencies = list("z" = R_FREQ_SYNDICATE)
	secure_classes = list(RADIOCL_SYNDICATE)
	protected_radio = 1
	icon_override = "syndie"

	leader
		icon_override = "syndieboss"

/obj/item/device/radio/headset/deaf
	name = "Auditory Headset"
	desc = "A radio headset that interfaces with the ear canal, allowing the deaf to hear."
	icon_state = "deaf headset"
	item_state = "headset"
	block_hearing_when_worn = HEARING_ANTIDEAF

/obj/item/device/radio/headset/gang
	name = "Radio Headset"
	desc = "A radio headset, pre-tuned to your gang's frequency. Convinient."
	secure_frequencies = list("g" = R_FREQ_GANG) //placeholder so it sets up right
	secure_classes = list("g" = RADIOCL_SYNDICATE)
	protected_radio = 1

/obj/item/device/radio/headset/multifreq
	name = " Multi-frequency Headset"
	desc = "A radio headset that can communicate over multiple, customizable channels."
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
	if ((usr.contents.Find(src) || in_range(src, usr) && istype(src.loc, /turf)) || (usr.loc == src.loc) || (issilicon(usr)))
		src.add_dialog(usr)
		if (href_list["sfreq"])
			var/new_frequency = sanitize_frequency(text2num("[secure_frequencies["h"]]") + text2num(href_list["sfreq"]))
			set_secure_frequency("h", new_frequency)
	return ..(href, href_list)

/obj/item/device/radio_upgrade //traitor radio upgrader
	name = "Wiretap Radio Upgrade"
	desc = "An illegal device capable of picking up and sending all secure station radio signals. Can be installed in a radio headset. Does not actually work by wiretapping."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "syndie_upgr"
	w_class = 1
