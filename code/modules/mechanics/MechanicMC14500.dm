
var/list/hex_digit_mask = list("0"=1,"1"=2,"2"=4,"3"=8,"4"=16,"5"=32,"6"=64,"7"=128,"8"=256,"9"=512,"A"=1024,"B"=2048,"C"=4096,"D"=8192,"E"=16384,"F"=32768)
var/list/hex_digit_values = list("0" = 0, "1" = 1, "2" = 2, "3" = 3, "4" = 4, "5" = 5, "6" = 6, "7" = 7, "8" = 8, "9" = 9, "A" = 10, "B" = 11, "C" = 12, "D" = 13, "E" = 14, "F" = 15)

/*
 *	Toy implementation of MC14500b industrial control unit, a 1970s 1-bit CMOS processor used to replace ladder logic.  It's a little baby PLC.
 *
 *	Instructions: Word size in this setup is one byte, one nibble is the instruction and the other is the operand. In that order. A0 is opcode A operand 0.
 *	0 and F are NOPs
 *	1 (LD) loads an input value into the accumulator, RR
 *	2 (LDC) acts like 1, but with the complement of the input
 *	3 (AND) sets RR to the logical AND of RR and the input.
 *	4 (ANDC) sets RR to the logical AND of RR and the complement of the input
 *	5 (OR) sets RR to the logical OR of RR and the input
 *	6 (ORC) sets RR to the logical OR of RR and the complement of the input
 *	7 (XNOR) essentially equates RR and the input, with RR set to the result of the test.
 *	8 (STO) store RR in either a RAM addess(High 8 bits) or one of 8 outputs(Low 8 bits).
 *	9 (STOC) store complement of RR in the same was as STO.
 *	A (IEN) sets IEN to the input
 *	B (OEN) sets OEN to the input
 *	C (JMP) will adjust the program counter by up to 32 addresses, forward or backward from the current instruction. Arguments 8+ will subtract 7 and then jump 4x that value forward, less than that will jump back 4x(that value + 1)
 *	D (RTN) skip next instruction.  For some reason.
 *	E (SKZ) skip next instruction if RR is zero.
 */

#define INSTRUCTIONS_PER_PROCESS 32
#define MAX_ROM_SIZE 128

/obj/item/mechanics/mc14500
	name = "Control Unit"
	icon = 'icons/obj/networked.dmi'
	icon_state = "genericsmall0"
	plane = PLANE_DEFAULT
	var/ROM = ""
	var/ioPins = 1 //Bitfield. Low byte is IO, high byte is internal memory flags, lowest bit is read as complement of RR
	var/RR = 0 //Result register.  It's the accumulator.  Look, motorola picked these names.
	var/IEN = 0 //Input ENable flag
	var/OEN = 0 //Output ENable flag
	var/running = 0
	var/program_counter = 0
	var/tmp/datum/mechanicsMessage/lastSignal = null

	//var/tmp/list/sourceCode = list()

	var/dbgmode = 0

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 1", .proc/fire1)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 2", .proc/fire2)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 3", .proc/fire3)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 4", .proc/fire4)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 5", .proc/fire5)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 6", .proc/fire6)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 7", .proc/fire7)
		//SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 8", .proc/fire8)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set ROM",.proc/setROM)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Active",.proc/toggleActivate)

	proc/setROM(obj/item/W as obj, mob/user as mob)
		. = adminscrub(strip_html(input(user, "What should the ROM be set to?  This better be hexadecimal and an even number of characters!!", "Terrible debug ROM panel", src.ROM) as text))
		if(!in_interact_range(src, user) || user.stat)
			return
		. = uppertext(copytext(ckey(.), 1, 1+MAX_ROM_SIZE))
		if (length(.)%2 || !is_hex(.))
			boutput(user, "<span class='alert'>Invalid ROM values.  Great job, knucklehead!!</span>")
		ROM = .

	proc/toggleActivate(obj/item/W as obj, mob/user as mob)
		src.running = !src.running && src.level
		IEN = 0
		OEN = 0
		RR = 0
		program_counter = 0
		src.ioPins = 1 //All zero except the !RR section.
		src.icon_state = "genericsmall[src.running ? 1 : 0]"

	process()
		if (..() || !running || !level)
			return
		SPAWN(0) src.light_up_housing()
		. = length(ROM)
		if (. < 2 || . % 2) //Too short or an odd length and we're out of here.
			running = 0
			src.icon_state = "genericsmall0"
			return

		updateUsrDialog()

		SPAWN(0)
			for (var/i = INSTRUCTIONS_PER_PROCESS, i > 0, i--)
				if (!running || !level || disposed)
					break

				program_counter %= .

				switch (interpret_instruction(copytext(ROM, program_counter+1, program_counter+2), copytext(ROM, program_counter+2, program_counter+3)))
					if (-1)
						running = 0
						src.icon_state = "genericsmall0"
						break

					if (1)
						i -= 5

				program_counter += 2
				sleep(0.1 SECONDS)

	attack_hand(mob/user)
		if (src.level != 1)
			return ..(user)
		if (!istype(src.loc, /turf/)) return

		if (user.using_dialog_of(src))
			user << output("[src.running]&[RR ? 1 : 0]&[IEN]&[OEN]", "mcu14500b.browser:update_indicators")
			user << output("[ioPins]", "mcu14500b.browser:update_mem_lights")
			return

		. = user_interface(user)
		if (.)
			user.Browse(., "window=mcu14500b")
			onclose(user, "mcu14500b")

	proc/user_interface(mob/user as mob)
		if (!user || user.stat ||(iscarbon(user) && BOUNDS_DIST(user, src) > 0))
			return

		src.add_dialog(user)

		. = {"<html><head><title>Industrial Control Unit</title></head><body>
		<center><table border='1'><tr><td id='active_indicator'><font color=white style='background-color:[running ? "#33FF00" : "#F80000"]'>[running ? "&nbsp;ACTIVE&nbsp;" : "INACTIVE"]</font></td></tr></table><br>
		<table border='1' style='color:#FFFFFF'><tr'><td id='ind_rr'> <font style='background-color:[RR ? "#33FF00" : "#F80000"]'>RR</font></td><td id='ind_ien'><font style='background-color:[IEN ? "#33FF00" : "#F80000"]'>Input ENable</font></td><td id='ind_oen'><font style='background-color:[OEN ? "#33FF00" : "#F80000"]'>Output ENable</font></td></tr></table>
		<br><br>
		<b>INPUT STATUS</b>
		<table border='1' style='color:#FFFFFF'>
		<tr>"}

		for (var/bit = 7, bit >= 0, bit--)
			. += "<td id='bit[bit]'> <div align=left style='background-color=[ioPins &(1<<bit) ? "#33FF00" : "#F80000"]'>[bit]</div></td>"

		. += "</tr></table><b>RAM STATUS</b><table border='1' style ='color:#FFFFFF'><tr>"

		for (var/bit = 15, bit >= 8, bit--)
			. += "<td id='bit[bit]'> <div align=left style='background-color=[ioPins &(1<<bit) ? "#33FF00" : "#F80000"]'>[bit-8]</div></td>"

		. += {"</tr></table></center>
<script type="text/javascript">

function update_indicators(active, rr, ien, oen)
{
	if (active == 1)
	{
		document.getElementById("active_indicator").innerHTML = "<font style='background-color:#33FF00' color=white>&nbsp;ACTIVE&nbsp;</font>";
	}
	else
	{
		document.getElementById("active_indicator").innerHTML = "<font style='background-color:#F80000' color=white>INACTIVE</font>";
	}
	document.getElementById("ind_rr").innerHTML = "<font style='background-color:" + (rr == 1 ? "#33FF00" : "#F80000") + "'>RR</font>"
	document.getElementById("ind_ien").innerHTML = "<font style='background-color:" + (ien == 1 ? "#33FF00" : "#F80000") + "'>Input ENable</font>"
	document.getElementById("ind_oen").innerHTML = "<font style='background-color:" +(oen == 1 ? "#33FF00" : "#F80000") + "'>Output ENable</font>"

}

function update_mem_lights(mem)
{
	var ind = 1;
	for (var i = 0; i < 16; i++)
	{
		document.getElementById("bit" + i).innerHTML = "<div align=left style='background-color:#" + ((mem & ind) ? "33FF00" : "F80000") + "'>" + i%8 + "</div>";
		ind = ind << 1;
	}

}
</script>

		"}


		//WIP

	/*desc = {"*	Instructions: Word size in this setup is one byte, one nibble is the instruction and the other is the operand. In that order. A0 is opcode A operand 0.<br>
 *	0 and F are NOPs<br>
 *	1 (LD) loads an input value into the accumulator, RR.  Input 0 is !RR.<br>
 *	2 (LDC) acts like 1, but with the complement of the input<br>
 *	3 (AND) sets RR to the logical AND of RR and the input.<br>
 *	4 (ANDC) sets RR to the logical AND of RR and the complement of the input<br>
 *	5 (OR) sets RR to the logical OR of RR and the input<br>
 *	6 (ORC) sets RR to the logical OR of RR and the complement of the input<br>
 *	7 (XNOR) essentially equates RR and the input, with RR set to the result of the test.<br>
 *	8 (STO) store RR in either a RAM addess(High 8 bits) or one of 8 outputs(Low 8 bits).<br>
 *	9 (STOC) store complement of RR in the same was as STO.<br>
 *	A (IEN) sets IEN to the input.  IEN is Input ENable.<br>
 *	B (OEN) sets OEN to the input.  OEN is Output ENable.<br>
 *	C (JMP) will adjust the program counter by up to 32 addresses, forward or backward from the current instruction. Arguments 8+ will subtract 7 and then jump 4x that value forward, less than that will jump back 4x(that value + 1)<br>
 *	D (RTN) skip next instruction.  For some reason.<br>
 *	E (SKZ) skip next instruction if RR is zero.<br>
 Output signals have the value \"PIN:VALUE\" i.e \"2:1\" to output true on pin 2.  You can filter this with OR gate triggers, ok.<br>
 Example program: \"30A0B01181\" Will AND RR with 0 on the first iteration (As IEN is zero) and AND it with !RR on subsequent loops(Both set it to zero), load !RR(1) into IEN and OEN, then load input 1 and send it to output 1.  This will repeat without end."}*/


	proc/interpret_instruction(instruction, argument)
		if (src.dbgmode)
			boutput(world, "\[[instruction], [argument]] RR=[RR] IEN=[IEN] OEN=[OEN]")

		. = argument
		argument = hex_digit_mask["[argument]"]
		if (!argument)
			return -1

		switch (instruction)
			if ("0","F")//NOP
				return 0

			if ("1")	//LD, RR =(DATA & IEN)
				RR =(IEN &&(ioPins & argument))
				ioPins = (ioPins & 65534 & (~argument | 65280)) | !RR

			if ("2")	//LDC, RR = !(DATA & IEN)
				RR = !(IEN &&(ioPins & argument))
				ioPins = (ioPins & 65534 & (~argument | 65280)) | !RR

			if ("3")	//AND, RR = RR &(DATA & IEN)
				RR = RR &&(IEN &&(ioPins & argument))
				ioPins = (ioPins & 65534 & (~argument | 65280)) | !RR

			if ("4")	//ANDC, RR = RR & !(DATA & IEN)
				RR = RR && !(IEN &&(ioPins & argument))
				ioPins = (ioPins & 65534 & (~argument | 65280)) | !RR

			if ("5")	//OR, RR = RR |(DATA & IEN)
				RR = RR ||(IEN &&(ioPins & argument))
				ioPins = (ioPins & 65534 & (~argument | 65280)) | !RR

			if ("6")	//ORC, RR = RR | !(DATA & IEN).  Waugh.
				RR = RR || !(IEN &&(ioPins & argument))
				ioPins = (ioPins & 65534 & (~argument | 65280)) | !RR

			if ("7")	//XNOR, RR = RR ==(DATA & IEN)
				RR =(RR && 1) ==((IEN &&(ioPins & argument)) && 1) //The &&1 is so we can compare them both as booleans instead of tripping over two bitfields with ones in different places
				ioPins = (ioPins & 65534 & (~argument | 65280)) | !RR

			if ("8")	//STO, DATA = RR

				if (argument > 128)
					if (OEN)
						ioPins = RR ?(ioPins | argument) : (ioPins & ~argument)

					return 0

				else if (OEN)
					if (lastSignal)
						lastSignal.signal = "[.]:[RR ? 1 : 0]"
						SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,lastSignal)
						lastSignal = null
						if (src.dbgmode)
							boutput(world, "OUTe: [.]:[RR ? 1 : 0]")

					else
						SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"[.]:[RR ? 1 : 0]")
						if (src.dbgmode)
							boutput(world, "OUT: [.]:[RR ? 1 : 0]")

					return 1


			if ("9")	//STOC, DATA = !RR
				if (argument > 128)
					if (OEN)
						ioPins = RR ?(ioPins & ~argument) : (ioPins | argument)

					return 0

				else if (OEN)
					if (lastSignal)
						lastSignal.signal = "[.]:[RR ? 0 : 1]"
						SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,lastSignal)
						lastSignal = null
						if (src.dbgmode)
							boutput(world, "OUTe: [.]:[RR ? 0 : 1]")

					else
						SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"[.]:[RR ? 0 : 1]")
						if (src.dbgmode)
							boutput(world, "OUT: [.]:[RR ? 0 : 1]")

					return 1


			if ("A")	//IEN, IEN = DATA
				IEN =(ioPins & argument)

			if ("B")	//OEN, OEN = DATA
				OEN =(ioPins & argument)

			if ("C")	//JMP
				. = hex_digit_values[.]
				if (!isnum(.))
					return -1

				if (. > 7)
					program_counter += (4 *(. - 7)) - 2

				else
					program_counter -= (4 *(. + 1)) + 2

				. = length(ROM)
				if (program_counter < 0)
					program_counter = . + (program_counter % .)

				return 0

			if ("D")	//RTN, skip next instruction
				program_counter += 2

			if ("E")	//SKZ, skip next instruction if !RR
				if (!RR)
					program_counter += 2

			else
				return -1

		return 0

	proc
		fire1(var/datum/mechanicsMessage/anInput)
			if(level == 2)
				return

			if (anInput?.isTrue())
				ioPins |= 2

			else
				ioPins &= ~2

			lastSignal = anInput

		fire2(var/datum/mechanicsMessage/anInput)
			if(level == 2)
				return

			if (anInput?.isTrue())
				ioPins |= 4

			else
				ioPins &= ~4

			lastSignal = anInput

		fire3(var/datum/mechanicsMessage/anInput)
			if(level == 2)
				return

			if (anInput?.isTrue())
				ioPins |= 8

			else
				ioPins &= ~8

			lastSignal = anInput

		fire4(var/datum/mechanicsMessage/anInput)
			if(level == 2)
				return

			if (anInput?.isTrue())
				ioPins |= 16

			else
				ioPins &= ~16

			lastSignal = anInput

		fire5(var/datum/mechanicsMessage/anInput)
			if(level == 2)
				return

			if (anInput?.isTrue())
				ioPins |= 32

			else
				ioPins &= ~32

			lastSignal = anInput

		fire6(var/datum/mechanicsMessage/anInput)
			if(level == 2)
				return

			if (anInput?.isTrue())
				ioPins |= 64

			else
				ioPins &= ~64

			lastSignal = anInput

		fire7(var/datum/mechanicsMessage/anInput)
			if(level == 2)
				return

			if (anInput?.isTrue())
				ioPins |= 128

			else
				ioPins &= ~128

			lastSignal = anInput


#undef INSTRUCTIONS_PER_PROCESS
