/obj/item/clothing/head/fruithat
	name = "fruit basket hat"
	desc = "Where do these things even come from? It reeks of welch, and it's not the grapes."
	icon_state = "fruithat"
	var/bites = 8
	var/list/youarebad = list("You're a liar.", "You're a cheat.","You're a fraud.") // h e h

	attack(mob/M, mob/user) //edible hats? why not
		if (M == user)
			if (!src.bites)
				boutput(user, "<span class='alert'>No more bites of \the [src] left, oh no!</span>")
				user.u_equip(src)
				qdel(src)
			else
				M.visible_message("<span class='notice'>[M] takes a bite of [src]!</span>",\
				"<span class='notice'>You take a bite of [src]!</span>")
				src.bites--
				M.nutrition += 20
				playsound(M.loc,'sound/items/eatfood.ogg', rand(10,50), 1)
				if (!src.bites)
					user.u_equip(src)
					qdel(src)
				sleep(rand(10,50))
				boutput(M, voidSpeak(pick(youarebad)))
				random_brute_damage(user, 5)
		else if(check_target_immunity(M))
			user.visible_message("<span class='alert'>You try to feed [M] [src], but fail!</span>")
		else
			user.tri_message(M, "<span class='alert'><b>[user]</b> tries to feed [M] [src]!</span>",\
				"<span class='alert'>You try to feed [M] [src]!</span>",\
				"<span class='alert'><b>[user]</b> tries to feed you [src]!</span>")
			if (!do_after(user, 1 SECONDS))
				boutput(user, "<span class='alert'>You were interrupted!</span>")
				return ..()
			else
				user.tri_message(M, "<span class='alert'><b>[user]</b> feeds [M] [src]!</span>",\
					"<span class='alert'>You feed [M] [src]!</span>",\
					"<span class='alert'><b>[user]</b> feeds you [src]!</span>")
				src.bites--
				M.nutrition += 20
				playsound(M.loc, 'sound/items/eatfood.ogg', rand(10,50), 1)
				if (!src.amount)
					user.u_equip(src)
					qdel(src)
				sleep(rand(10,50))
				boutput(M, voidSpeak(pick(youarebad)))
				random_brute_damage(user, 5)

//////////////////////////////////////////////FRUITHAT ASSEMBLIES

/obj/item/dynassembly/fruit
	name = "wire" //This gets funky otherwise.
	icon = 'icons/obj/foodNdrink/food_produce.dmi'
	validparts = list(/obj/item/reagent_containers/food/snacks/plant/)
	multipart = 1

	checkifdone()
		if (src.contents.len >= 8)
			src.product = 1
			src.desc += "<BR><span class='notice'>It looks like this assembly can be secured with a screwdriver.</span>"

	createproduct(mob/user)
		if (product == 1)
			var/obj/item/clothing/head/fruithat/N = new /obj/item/clothing/head/fruithat(get_turf(src))
			boutput(user, "You have successfully created \a [N]!")
		return

/obj/item/reagent_containers/food/snacks/plant/attackby(obj/item/W, mob/user) //first phase of fruithat construction
	if (istype(W, /obj/item/cable_coil))
		var/obj/item/cable_coil/C = W
		if (src.validforhat == 1) //is it a fruit and not a filthy vegetable?
			if (C.amount <= 7)
				boutput(user, "You don't have enough cable to add to \the [src.name]")
			else
				boutput(user, "<span class='notice'>You begin adding \the [C.name] to \the [src.name].</span>")
				if (!do_after(user, 3 SECONDS))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return ..()
				else
					C.amount -= 8
					C.UpdateIcon()
					user.drop_item()
					var/obj/item/dynassembly/fruit/A = new /obj/item/dynassembly/fruit(get_turf(src))
					A.newpart(A,src,1) //returns assembly we created, fruit we made it from, and 1st run
					var/image/I = new /image('icons/obj/foodNdrink/food_produce.dmi', "hatwires")
					I.layer += 1
					A.overlays += I
		else
			boutput(user, "The [src.name] cannot be wired with the [C.name]")
	return ..()
