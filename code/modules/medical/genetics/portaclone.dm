/obj/machinery/computer/cloner/portable
	name = "Port-A-Clone"
	desc = "A mobile cloning vat with a miniature enzymatic reclaimer attached. Requires corpses to be chopped up before they can be reclaimed."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "PAG_0"

	//Cloner vars
	var/obj/machinery/clone_scanner/scanner = null //Built-in scanner.
	var/obj/machinery/clonepod/pod1 = null //Built-in cloning pod.
	var/obj/machinery/computer/cloning/computer = null //Built-in computer for i/o.

	//Portable object vars
	anchored = 0
	var/locked = 0

	New()
		..()
		SPAWN(0)
			scanner = new /obj/machinery/clone_scanner(src) //Built-in scanner.
			pod1 = new /obj/machinery/clonepod(src) //Built-in cloning pod.
			computer = new /obj/machinery/computer/cloning(src) //Inbuilt computer for i/o.
			computer.max_pods = 1 //Don't connect to external pods.

			if(computer) computer.portable = 1
			if(pod1) pod1.portable = 1
		SPAWN(1 SECOND)
			computer.scanner = scanner
			computer.linked_pods += pod1

			if (!isnull(pod1))
				pod1.connected = computer

			if (isnull(computer.scanner) || isnull(pod1))
				computer.show_message((isnull(pod1) && "POD1-ERROR") || (isnull(computer.scanner) && "SCNR-ERROR"), "success")
				return
			else
				computer.show_message("System ready.", "success")
				return

	attackby(obj/item/W, mob/user)
		if (W)
			if (istype(W, /obj/item/disk/data/floppy) || isscrewingtool(W) || istype(W, /obj/item/cloner_upgrade))
				computer.Attackby(W,user)
				src.add_fingerprint(user)

			else if (istype(W, /obj/item/grab))
				scanner.Attackby(W,user)
				src.add_fingerprint(user)

			else if (istype(W, /obj/item/card/id) || (istype(W, /obj/item/device/pda2) && W:ID_card) || istype(W, /obj/item/card/emag) || istype(W, /obj/item/reagent_containers/glass))
				pod1.Attackby(W,user)
				src.add_fingerprint(user)

	attack_hand(mob/user)
		return computer.Attackhand(user)
