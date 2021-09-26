
/obj/item/storage/box/cablesbox
	name = "electrical cables storage"
	icon_state = "cables"
	spawn_contents = list(/obj/item/cable_coil = 7)

/obj/item/storage/box/cablesbox/reinforced
	name = "reinforced electrical cables storage"
	spawn_contents = list(/obj/item/cable_coil/reinforced = 7)

/obj/item/storage/box/PDAbox
	name = "spare PDAs"
	desc = "A box of spare PDA microcomputers."
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "pdabox"
	spawn_contents = list(/obj/item/device/pda2 = 4)

	make_my_stuff()
		..()
		//Let's spawn up some carts (Unless they shouldn't randomly show up, like detomaxes)
		var/list/invalid_carts = list(/obj/item/disk/data/cartridge,
		/obj/item/disk/data/cartridge/captain,
		/obj/item/disk/data/cartridge/nuclear,
		/obj/item/disk/data/cartridge/syndicate,
		/obj/item/disk/data/cartridge/ai,
		/obj/item/disk/data/cartridge/cyborg,
		/obj/item/disk/data/cartridge/ringtone_syndie)

		var/list/spawnable = typesof(/obj/item/disk/data/cartridge)
		spawnable -= invalid_carts
		for (var/i = 1, i <= 3, i++)
			var/cartpath = pick(spawnable)
			new cartpath(src)

/obj/item/storage/box/diskbox
	name = "diskette box"
	icon_state = "disk_kit"
	spawn_contents = list(/obj/item/disk/data/floppy = 7)

/obj/item/storage/box/tapebox
	name = "\improper ThinkTape box"
	desc = "A box of magnetic data tapes."
	icon_state = "tape_kit"
	spawn_contents = list(/obj/item/disk/data/tape = 7)

/obj/item/storage/box/zeta_boot_kit
	name = "mainframe recovery tapes"
	desc = "A box of system recovery tapes."
	icon_state = "tape2_kit"
	spawn_contents = list(/obj/item/disk/data/tape/boot2,\
	/obj/item/disk/data/memcard,\
	/obj/item/disk/data/memcard,\
	/obj/item/paper/zeta_boot_kit)

/obj/item/storage/box/guardbot_kit
	name = "\improper Guardbot construction kit"
	icon_state = "flashbang"
	desc = "A useful kit for building guardbuddies. All you need is a module!"
	spawn_contents = list(/obj/item/guardbot_frame,\
	/obj/item/guardbot_core,\
	/obj/item/parts/robot_parts/arm/right/standard,\
	/obj/item/cell)

/obj/item/storage/box/lightbox
	name = "replacement light bulbs"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "light"
	spawn_contents = list(/obj/item/light/bulb = 7)

	bulbs
		// its already bulbs by default
		red
			name = "red light bulbs"
			spawn_contents = list(/obj/item/light/bulb/red = 7)
		yellow
			name = "yellow light bulbs"
			spawn_contents = list(/obj/item/light/bulb/yellow = 7)
		green
			name = "green light bulbs"
			spawn_contents = list(/obj/item/light/bulb/green = 7)
		cyan
			name = "cyan light bulbs"
			spawn_contents = list(/obj/item/light/bulb/cyan = 7)
		blue
			name = "blue light bulbs"
			spawn_contents = list(/obj/item/light/bulb/blue = 7)
		purple
			name = "purple light bulbs"
			spawn_contents = list(/obj/item/light/bulb/purple = 7)
		blacklight
			name = "blacklight bulbs"
			spawn_contents = list(/obj/item/light/bulb/blacklight = 7)
	tubes
		name = "replacement light tubes"
		icon_state = "light_tube"
		spawn_contents = list(/obj/item/light/tube = 7)

		red
			name = "red light tubes"
			spawn_contents = list(/obj/item/light/tube/red = 7)
		yellow
			name = "yellow light tubes"
			spawn_contents = list(/obj/item/light/tube/yellow = 7)
		green
			name = "green light tubes"
			spawn_contents = list(/obj/item/light/tube/green = 7)
		cyan
			name = "cyan light tubes"
			spawn_contents = list(/obj/item/light/tube/cyan = 7)
		blue
			name = "blue light tubes"
			spawn_contents = list(/obj/item/light/tube/blue = 7)
		purple
			name = "purple light tubes"
			spawn_contents = list(/obj/item/light/tube/purple = 7)
		blacklight
			name = "blacklight light tubes"
			spawn_contents = list(/obj/item/light/tube/blacklight = 7)

/obj/item/storage/box/glowstickbox
	name = "emergency glowsticks"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "glowstickbox"
	spawn_contents = list(/obj/item/device/light/glowstick = 7)

	assorted
		name = "assorted glowsticks"
		spawn_contents = list()
		make_my_stuff()
			..()
			var/glowstick
			for (var/i=7,i>0,i--)
				glowstick = pick(/obj/item/device/light/glowstick,
				/obj/item/device/light/glowstick/red,
				/obj/item/device/light/glowstick/blue,
				/obj/item/device/light/glowstick/cyan,
				/obj/item/device/light/glowstick/orange,
				/obj/item/device/light/glowstick/yellow,
				/obj/item/device/light/glowstick/pink,
				/obj/item/device/light/glowstick/purple)
				new glowstick(src)

