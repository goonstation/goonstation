//CONTENTS:
//Captain cart
//Head cart
//Research Director cart
//Medical cart
//Security cart
//Toxins cart
//QM cart
//Clown cart
//Janitor cart
//Atmos cart
//Syndicate cart
//Botanist cart
//Nuclear cart (syndicate cart with syndicate shuttle door control)
//Network diagnostic cart
//Game Carts
//Ringtone Carts

/obj/item/disk/data/cartridge
	name = "\improper PDA cartridge"
	desc = "A data cartridge for PDAs."
	icon = 'icons/obj/items/pda.dmi'
	icon_state = "cart-blank"
	item_state = "electronic"
	file_amount = 32
	title = "ROM Cart"

	captain
		name = "\improper Value-PAK cartridge"
		desc = "Now with 200% more value!"
		icon_state = "cart-fancy"
		file_amount = 128
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/manifest(src))
			src.root.add_file( new /datum/computer/file/pda_program/status_display(src))
			src.root.add_file( new /datum/computer/file/pda_program/signaler(src))
			src.root.add_file( new /datum/computer/file/pda_program/fileshare(src))
			src.root.add_file( new /datum/computer/file/pda_program/qm_records(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/forensic_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/health_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/medrecord_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/security(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/medical(src))
			src.root.add_file( new /datum/computer/file/pda_program/security_ticket(src))
			src.root.add_file( new /datum/computer/file/pda_program/power_checker(src))
			//src.root.add_file( new /datum/computer/file/pda_program/hologram_control(src))
			src.root.add_file( new /datum/computer/file/pda_program/station_name(src))
			src.file_amount = src.file_used
			src.read_only = 1

	head
		name = "\improper Easy-Record DELUXE cartridge"
		desc = "Not quite identity fraud on the go, but close."
		icon_state = "cart-records"
		file_amount = 64
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/manifest(src))
			src.root.add_file( new /datum/computer/file/pda_program/status_display(src))
			src.root.add_file( new /datum/computer/file/pda_program/qm_records(src))
			src.root.add_file( new /datum/computer/file/pda_program/fileshare(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/forensic_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/security(src))
			src.root.add_file( new /datum/computer/file/pda_program/security_ticket(src))
			src.root.add_file( new /datum/computer/file/pda_program/power_checker(src))
			src.read_only = 1

	ai
		name = "\improper AI Internal PDA cartridge"
		desc = "Wait, how did you even get this?"
		icon_state = "cart-ai"
		file_amount = 1024
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/manifest(src))
			src.root.add_file( new /datum/computer/file/pda_program/atmos_alerts(src))
			src.root.add_file( new /datum/computer/file/pda_program/power_checker(src))
			src.root.add_file( new /datum/computer/file/pda_program/status_display(src))
			src.root.add_file( new /datum/computer/file/pda_program/qm_records(src))
			src.root.add_file( new /datum/computer/file/pda_program/fileshare(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/security(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/medical(src))
			src.root.add_file( new /datum/computer/file/pda_program/portable_machinery_control/portananomed(src))
			src.root.add_file( new /datum/computer/file/pda_program/portable_machinery_control/portamedbay(src))
			src.root.add_file( new /datum/computer/file/pda_program/portable_machinery_control/portasci(src))
			src.root.add_file( new /datum/computer/file/pda_program/portable_machinery_control/portabrig(src))
			src.root.add_file( new /datum/computer/file/pda_program/bot_control/secbot(src))
			src.root.add_file( new /datum/computer/file/pda_program/bot_control/mulebot(src))
			src.root.add_file( new /datum/computer/file/pda_program/pingtool(src) )
			src.root.add_file( new /datum/computer/file/pda_program/packet_sniffer(src) )
			src.root.add_file( new /datum/computer/file/pda_program/packet_sender(src) )
			src.root.add_file( new /datum/computer/file/text/diagnostic_readme(src))
			src.root.add_file( new /datum/computer/file/pda_program/signaler(src))

	cyborg
		name = "\improper Cyborg Internal PDA cartridge"
		desc = "What does it mean if this internal cartridge is now external?"
		icon_state = "cart-ai"
		file_amount = 1024
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/manifest(src))
			src.root.add_file( new /datum/computer/file/pda_program/atmos_alerts(src))
			src.root.add_file( new /datum/computer/file/pda_program/signaler(src))
			src.root.add_file( new /datum/computer/file/pda_program/qm_records(src))
			src.root.add_file( new /datum/computer/file/pda_program/fileshare(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/security(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/medical(src))
			src.root.add_file( new /datum/computer/file/pda_program/security_ticket(src))
			// src.root.add_file( new /datum/computer/file/pda_program/scan/health_scan(src))
			// src.root.add_file( new /datum/computer/file/pda_program/scan/reagent_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/bot_control/secbot(src))
			src.root.add_file( new /datum/computer/file/pda_program/bot_control/mulebot(src))
			src.root.add_file( new /datum/computer/file/pda_program/pingtool(src) )
			src.root.add_file( new /datum/computer/file/pda_program/packet_sniffer(src) )
			src.root.add_file( new /datum/computer/file/pda_program/packet_sender(src) )
			src.root.add_file( new /datum/computer/file/text/diagnostic_readme(src))
			src.root.add_file( new /datum/computer/file/pda_program/power_checker(src))

	research_director
		name = "\improper SciMaster cartridge"
		desc = "There is a torn 'for ages 5 and up' sticker on the back."
		icon_state = "cart-rd2"
		file_amount = 64
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/manifest(src))
			src.root.add_file( new /datum/computer/file/pda_program/status_display(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/health_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/reagent_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/signaler(src))
			src.root.add_file( new /datum/computer/file/pda_program/fileshare(src))
			src.root.add_file( new /datum/computer/file/pda_program/portable_machinery_control/portasci(src))
			src.read_only = 1

	medical_director
		name = "\improper Med-Master cartridge"
		desc = "All the power of a Med-U cartridge but none of the red."
		icon_state = "cart-md"
		file_amount = 64
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/manifest(src))
			src.root.add_file( new /datum/computer/file/pda_program/status_display(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/health_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/medrecord_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/reagent_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/medical(src))
			src.root.add_file( new /datum/computer/file/pda_program/fileshare(src))
			src.root.add_file( new /datum/computer/file/pda_program/portable_machinery_control/portananomed(src))
			src.root.add_file( new /datum/computer/file/pda_program/portable_machinery_control/portamedbay(src))
			src.read_only = 1


	medical
		name = "\improper Med-U cartridge"
		desc = "Has a built-in health scanner program, if your would-be patient ever stood still."
		icon_state = "cart-med"
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/scan/health_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/medrecord_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/reagent_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/medical(src))
			src.root.add_file( new /datum/computer/file/pda_program/portable_machinery_control/portananomed(src))
			src.root.add_file( new /datum/computer/file/pda_program/portable_machinery_control/portamedbay(src))
			src.read_only = 1

	mechanic
		name = "\improper Analysis Made Easy cartridge"
		desc = "More like, copyright infringement made easy."
		icon_state = "cart-network"
		file_amount = 64
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/scan/electronics(src))
			src.root.add_file( new /datum/computer/file/pda_program/pingtool(src) )
			src.root.add_file( new /datum/computer/file/pda_program/packet_sniffer(src) )
			src.root.add_file( new /datum/computer/file/pda_program/packet_sender(src) )
			src.root.add_file( new /datum/computer/file/text/diagnostic_readme(src))
			src.read_only = 1

	security
		name = "\improper R.O.B.U.S.T. cartridge"
		desc = "Reliably Ordered By Useless Security Teams."
		icon_state = "cart-sec"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/scan/forensic_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/secrecord_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/security(src))
			src.root.add_file( new /datum/computer/file/pda_program/bot_control/secbot(src))
			src.root.add_file( new /datum/computer/file/pda_program/portable_machinery_control/portabrig(src))
			src.root.add_file( new /datum/computer/file/pda_program/security_ticket(src))
			src.read_only = 1

	forensic
		name = "\improper Forensic Analysis cartridge"
		desc = "Judging from the stains, someone tried to use this cartridge directly."
		icon_state = "cart-forensics"
		file_amount = 128

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/scan/forensic_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/health_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/reagent_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/medrecord_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/secrecord_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/medical(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/security(src))
			src.root.add_file( new /datum/computer/file/pda_program/bot_control/secbot(src))
			src.root.add_file( new /datum/computer/file/pda_program/security_ticket(src))
			src.root.add_file( new /datum/computer/file/pda_program/packet_sniffer(src) )
			src.read_only = 1

	hos
		name = "\improper R.O.B.U.S.T.E.R. cartridge"
		desc = "Someone registered the shareware version of the R.O.B.U.S.T. cartridge!"
		icon_state = "cart-hos"
		file_amount = 128
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/manifest(src))
			src.root.add_file( new /datum/computer/file/pda_program/status_display(src))
			src.root.add_file( new /datum/computer/file/pda_program/bot_control/secbot/pro(src))
			src.root.add_file( new /datum/computer/file/pda_program/portable_machinery_control/portabrig(src))
			src.root.add_file( new /datum/computer/file/pda_program/qm_records(src))
			src.root.add_file( new /datum/computer/file/pda_program/fileshare(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/forensic_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/health_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/secrecord_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/security(src))
			src.root.add_file( new /datum/computer/file/pda_program/security_ticket(src))
			src.file_amount = src.file_used
			src.read_only = 1

	toxins
		name = "\improper Signal Ace 2 cartridge"
		desc = "It's like a signaling device, but stuffed in another device!"
		icon_state = "cart-signalace"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/scan/reagent_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/signaler(src))
			src.read_only = 1

	genetics
		name = "\improper Deoxyribonucleic Amigo cartridge"
		desc = "There was, at one point, a time when this cartridge often got use."
		icon_state = "cart-gene"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/scan/health_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/medrecord_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/reagent_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/medical(src))
			src.read_only = 1

	quartermaster
		name = "\improper Space Parts & Vendors cartridge"
		desc = "Perfect for the Quartermaster on the go!"
		icon_state = "cart-qm"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/qm_records(src))
			src.root.add_file( new /datum/computer/file/pda_program/fileshare(src))
			src.root.add_file( new /datum/computer/file/pda_program/bot_control/mulebot(src))
			src.read_only = 1

	engineer
		name = "\improper Engine-buddy Atmospherics cartridge"
		desc = "Great for the enterprising engineer in everyone!"
		icon_state = "cart-engine"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/power_checker(src))
			src.root.add_file( new /datum/computer/file/pda_program/atmos_alerts(src))
			src.root.add_file( new /datum/computer/file/pda_program/signaler(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/health_scan(src))
			src.read_only = 1

	chiefengineer
		name = "\improper EngineDaemon Ultimate cartridge"
		desc = "A limited edition cartridge for high-class engineers. The warranty label is missing."
		icon_state = "cart-engine"
		file_amount = 64

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/manifest(src))
			src.root.add_file( new /datum/computer/file/pda_program/power_checker(src))
			src.root.add_file( new /datum/computer/file/pda_program/atmos_alerts(src))
			src.root.add_file( new /datum/computer/file/pda_program/signaler(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/health_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/qm_records(src))
			src.root.add_file( new /datum/computer/file/pda_program/fileshare(src))
			src.root.add_file( new /datum/computer/file/pda_program/security_ticket(src))
			src.root.add_file( new /datum/computer/file/pda_program/bot_control/mulebot(src))
			src.read_only = 1

	clown
		name = "\improper Honkworks 5.0 cartridge"
		desc = "There are some <em>very</em> questionable stains on this thing. Is that blood?"
		icon_state = "cart-clown2"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/honk_synth(src))
			src.root.add_file( new /datum/computer/file/pda_program/arcade(src))
			src.root.add_file( new /datum/computer/file/pda_program/ringtone/clown(src))
			src.read_only = 1

	janitor
		name = "\improper CustodiPRO cartridge"
		desc = "When you've mopped till you've dropped, this helps you pick it back up again. Special built-in radio picks up frequenies of nearby mops."
		icon_state = "cart-j"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/mopfinder(src))
			src.root.add_file( new /datum/computer/file/pda_program/arcade(src))
			src.read_only = 1

	atmos
		name = "\improper AlertMaster cartridge"
		desc = "For when you've fallen and you can't get up."
		icon_state = "cart-alert"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/atmos_alerts(src))
			src.read_only = 1

	botanist
		name = "\improper Farmer Melons' ScanCart v2"
		desc = "A must for any botanist. It's the ROMpost to your compost!"
		icon_state = "cart-hydro"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/scan/plant_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/reagent_scan(src))
			src.root.add_file( new /datum/computer/file/text/handbook_botanist(src))
			src.read_only = 1

	syndicate
		name = "\improper Detomatix cartridge"
		desc = "Designed with the latest advancements in blast processing."
		icon_state = "cart-deto"
		mats = 0

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/bomb(src))
			var/datum/computer/file/pda_program/missile/detofile = new /datum/computer/file/pda_program/missile(src)
			detofile.charges = 4
			src.root.add_file(detofile)
			src.root.add_file( new /datum/computer/file/text/bomb_manual(src))
			src.read_only = 1

	nuclear
		name = "\improper Syndi-Master cartridge"
		desc = "This cart uses only the finest-quality recycled soviet steel."
		icon_state = "cart-deto"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/manifest(src))
			src.root.add_file( new /datum/computer/file/pda_program/bomb(src))
			var/datum/computer/file/pda_program/missile/detofile = new /datum/computer/file/pda_program/missile(src)
			detofile.charges = 4
			src.root.add_file(detofile)
			src.root.add_file( new /datum/computer/file/text/bomb_manual(src))
			//src.root.add_file( new /datum/computer/file/pda_program/door_control/syndicate(src))
			src.read_only = 1

	diagnostics
		name = "\improper Network Diagnostics cartridge"
		desc = "Built-in radio supports a wide frequency range, making it capable of snooping on many devices."
		icon_state = "cart-network"
		file_amount = 64
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/pingtool(src) )
			src.root.add_file( new /datum/computer/file/pda_program/packet_sniffer(src) )
			src.root.add_file( new /datum/computer/file/pda_program/packet_sender(src) )
			src.root.add_file( new /datum/computer/file/pda_program/fileshare(src))
			src.root.add_file( new /datum/computer/file/text/diagnostic_readme(src))

			src.read_only = 1

	game_codebreaker
		name = "\improper CodeBreaker cartridge"
		desc = "Irata Inc ports another of their finest titles to your handheld PDA!"
		icon_state = "cart-c"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/codebreaker(src))
			src.read_only = 1

	ringtone
		name = "\improper Thinktronic Sound System Backup cartridge"
		desc = "Perfect for restoring default audio settings to any Thinktronic Systems handheld device."
		icon_state = "cart-c"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/ringtone(src))
			src.read_only = 1

	ringtone_dogs
		name = "\improper WOLF PACK ULTIMATE PRO ringtone cartridge"
		desc = "RIDE OR DIE WE HOWL TOGETHER AND PROWL TOGETHER"
		icon_state = "cart-c"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/ringtone/dogs(src))
			src.read_only = 1

	ringtone_numbers
		name = "\improper Leaptronics Learning System cartridge"
		desc = "Blossom into brilliance! For ages 4-6."
		icon_state = "cart-c"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/ringtone/numbers(src))
			src.read_only = 1

	ringtone_basic
		name = "\improper Celestial Soultones ringtone cartridge"
		desc = "Take flight with these enlightening soultones..."
		icon_state = "cart-c"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/ringtone/basic(src))
			src.read_only = 1

	ringtone_chimes
		name = "\improper Jangle Spacechimes ringtone cartridge"
		desc = "Jangle with us in the spacewind, together."
		icon_state = "cart-c"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/ringtone/chimes(src))
			src.read_only = 1

	ringtone_beepy
		name = "\improper Blipous Family Heirloom Spaceblips cartridge"
		desc = "Blipous family heirloom Spaceblips."
		icon_state = "cart-c"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/ringtone/beepy(src))
			src.read_only = 1

	ringtone_syndie
		name = "\improper SounDreamS PRO cartridge"
		desc = "HI-QUALITY and REALISTIC sound effects for your PDA or project!"
		icon_state = "cart-c"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/ringtone/syndie(src))
			src.read_only = 1
