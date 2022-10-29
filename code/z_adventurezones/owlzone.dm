
obj/item/coin/bombini
	name = "Bombini's lucky proprietary coin-like token"
	desc = "One of Bombini's most prized posessions. What do you mean she's got no pockets?"
	icon = 'icons/misc/Owlzone.dmi'
	icon_state = "bombicoin"

/obj/machinery/shower/puzzle
	var/stage = 0 // how far along the puzzle are we
	var/obj/machinery/shower/puzzle/part_one/a = null // part one of the puzz
	var/obj/machinery/shower/puzzle/part_two/b = null // part two of the puzz
	var/obj/machinery/shower/puzzle/part_three/c = null // part three of the puzz
	var/obj/machinery/floorflusher/bathtub/tub = null
	var/next_choice = 0 // is this head the head we want?
	var/id = 0 // whoami?
	default_reagent = "poo"

	proc/cycle()
		if (stage >= 6)
			if(tub)
				tub.openup()
		else
			next_choice = pick(1,2,3)
			sync()
			stage++

	proc/sync()
		default_reagent = (pick("sarin","phlogiston","ants","radium","dbreath","beff","cheese","blood"))
		if (a)
			next_choice = a.next_choice
			stage = a.stage
		else
			b.sync()
			c.sync()

		if (id == next_choice)
			interesting = pick("This showerhead is energised","This showerhead is awaiting input","This showerhead has an active sensor")
		else
			interesting = pick("This device is loaded with noxious chemicals","This showerhead is armed","This showerhead is waiting to go off")

	attack_hand(mob/user)
		boutput(user, "<span class='notice'><B>The [src] beeps [src.stage] times softly</B></span>")
		if (id == next_choice)
			if (a)
				a.cycle()
			else
				cycle()
		else
			boutput(user, "<span class='alert'><B>The [src] sprays horrible gunk at you!</B></span>")
			if (a)
				a.stage = 0
				spray()
				a.cycle()
			else
				stage = 0
				spray()
				cycle()


/obj/machinery/shower/puzzle/part_one

	New()
		..()
		SPAWN(0.5 SECONDS)
			src.b = locate(/obj/machinery/shower/puzzle/part_two, orange(2,src))
			src.c = locate(/obj/machinery/shower/puzzle/part_three, orange(2,src))
			src.tub = locate(/obj/machinery/floorflusher/bathtub, orange(2,src))
			if (isnull(src.b)||isnull(src.c)||isnull(src.tub))
				return
			else
				id = 1
				b.a = src
				b.id = 2
				c.a = src
				c.id = 3
				cycle()

/obj/machinery/shower/puzzle/part_two
// thats it no meat just existence. warcrimes is a douche.
/obj/machinery/shower/puzzle/part_three
// thats it no meat just existence


obj/item/paper/bombininote/postgame
	name = "smellier note"
	interesting = "There are traces of Escherichia Coli, Salmonella, and synthetic grasslike fibers dusted across the note. The handwriting seems mechanical."
	desc = "A note which smells faintly of owls and... beer? cigars? weird."
	info = {"Hey Bombi, you got lucky this time- but next year's tournament won't be no joke either! Bring your best pokerface, and enjoy the winnings while you can! -THE OWLS
		<br>
		<br><b>(This message brought to you by Gaggle Translation services, this message was translated to ENGLISH from OWL.)"}
