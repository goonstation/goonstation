///////////////////////////////////////////// lunchboxes /////////////////////////////////////////////

/obj/item/storage/lunchbox
	name = "lunchbox"
	desc = "A sturdy lunchbox for carrying your favorite foods."
	icon_state = "lunchbox"
	inhand_image_icon = 'icons/mob/inhand/hand_lunchboxes.dmi'
	throw_speed = 1
	throw_range = 8
	w_class = W_CLASS_NORMAL
	max_wclass = W_CLASS_SMALL

	New()
		..()
		var/my_lunchbox = pick("black","red","orange","yellow","purple", "silver", "blue", "green", "pink", "brown")
		src.icon_state = "lunchbox_[my_lunchbox]"
		src.item_state = src.icon_state

	food1
		spawn_contents = list(/obj/item/reagent_containers/food/snacks/sandwich/eggsalad,\
		/obj/item/reagent_containers/food/snacks/goldfish_cracker,\
		/obj/item/reagent_containers/food/snacks/plant/grape/green,\
		/obj/item/reagent_containers/food/drinks/water,\
		/obj/item/paper/lunchbox_note)

	food2
		spawn_contents = list(/obj/item/reagent_containers/food/snacks/sandwich/banhmi,\
		/obj/item/reagent_containers/food/snacks/granola_bar,\
		/obj/item/reagent_containers/food/snacks/yoghurt,\
		/obj/item/reagent_containers/food/drinks/water,\
		/obj/item/kitchen/utensil/spoon,\
		/obj/item/paper/lunchbox_note)

	food3
		spawn_contents = list(/obj/item/reagent_containers/food/snacks/friedrice,\
		/obj/item/reagent_containers/food/snacks/zongzi,\
		/obj/item/reagent_containers/food/snacks/fortune_cookie,\
		/obj/item/reagent_containers/food/drinks/water,\
		/obj/item/kitchen/utensil/spoon,\
		/obj/item/paper/lunchbox_note)

	food4
		spawn_contents = list(/obj/item/reagent_containers/food/snacks/omelette,\
		/obj/item/reagent_containers/food/snacks/croissant,\
		/obj/item/reagent_containers/food/snacks/candy/caramel,\
		/obj/item/reagent_containers/food/drinks/water,\
		/obj/item/kitchen/utensil/fork,\
		/obj/item/paper/lunchbox_note)

	food5
		spawn_contents = list(/obj/item/reagent_containers/food/snacks/taco/complete,\
		/obj/item/reagent_containers/food/snacks/donut/custom/cinnamon,\
		/obj/item/reagent_containers/food/snacks/plant/cherry,\
		/obj/item/reagent_containers/food/drinks/water,\
		/obj/item/paper/lunchbox_note)

	food6
		spawn_contents = list(/obj/item/reagent_containers/food/snacks/breakfast,\
		/obj/item/reagent_containers/food/snacks/waffles,\
		/obj/item/reagent_containers/food/snacks/plant/strawberry,\
		/obj/item/reagent_containers/food/drinks/water,\
		/obj/item/kitchen/utensil/fork,\
		/obj/item/paper/lunchbox_note)

	food7
		spawn_contents = list(/obj/item/reagent_containers/food/snacks/swedishmeatball,\
		/obj/item/reagent_containers/food/snacks/stroopwafel,\
		/obj/item/reagent_containers/food/snacks/swedish_fish,\
		/obj/item/reagent_containers/food/drinks/water,\
		/obj/item/kitchen/utensil/fork,\
		/obj/item/paper/lunchbox_note)

	food8
		spawn_contents = list(/obj/item/reagent_containers/food/snacks/salad,\
		/obj/item/reagent_containers/food/snacks/breadslice/toastslice/banana,\
		/obj/item/reagent_containers/food/snacks/plant/avocado,\
		/obj/item/reagent_containers/food/drinks/water,\
		/obj/item/kitchen/utensil/fork,\
		/obj/item/paper/lunchbox_note)

	food9
		spawn_contents = list(/obj/item/reagent_containers/food/snacks/soup/tomato,\
		/obj/item/reagent_containers/food/snacks/sandwich/cheese,\
		/obj/item/reagent_containers/food/snacks/candy/taffy/watermelon,\
		/obj/item/reagent_containers/food/drinks/water,\
		/obj/item/kitchen/utensil/spoon,\
		/obj/item/paper/lunchbox_note)

	food10
		spawn_contents = list(/obj/item/reagent_containers/food/snacks/taco/complete,\
		/obj/item/reagent_containers/food/snacks/soup/chili,\
		/obj/item/reagent_containers/food/snacks/tortilla_chip,\
		/obj/item/reagent_containers/food/drinks/water,\
		/obj/item/kitchen/utensil/spoon,\
		/obj/item/paper/lunchbox_note)

	food11
		spawn_contents = list(/obj/item/reagent_containers/food/snacks/steak_h,\
		/obj/item/reagent_containers/food/snacks/mashedpotatoes,\
		/obj/item/reagent_containers/food/snacks/biscuit,\
		/obj/item/reagent_containers/food/snacks/cookie/oatmeal,\
		/obj/item/reagent_containers/food/drinks/water,\
		/obj/item/kitchen/utensil/spoon,\
		/obj/item/paper/lunchbox_note)

	food12
		spawn_contents = list(/obj/item/reagent_containers/food/snacks/corndog,\
		/obj/item/item_box/chips,\
		/obj/item/reagent_containers/food/snacks/plant/grape/green,\
		/obj/item/reagent_containers/food/drinks/water,\
		/obj/item/paper/lunchbox_note)

	food13
		spawn_contents = list(/obj/item/reagent_containers/food/snacks/spaghetti/alfredo,\
		/obj/item/reagent_containers/food/snacks/garlicbread,\
		/obj/item/reagent_containers/food/snacks/candy/gummy_worm,\
		/obj/item/reagent_containers/food/drinks/water,\
		/obj/item/kitchen/utensil/fork,\
		/obj/item/paper/lunchbox_note)

	food14
		spawn_contents = list(/obj/item/reagent_containers/food/snacks/sandwich/pbh,\
		/obj/item/reagent_containers/food/snacks/moon_pie/chocolate_chip,\
		/obj/item/reagent_containers/food/snacks/plant/apple,\
		/obj/item/reagent_containers/food/drinks/water,\
		/obj/item/paper/lunchbox_note)

	food15
		spawn_contents = list(/obj/item/reagent_containers/food/snacks/burger/baconburger,\
		/obj/item/reagent_containers/food/snacks/bakedpotato,\
		/obj/item/reagent_containers/food/snacks/plant/lashberry,\
		/obj/item/reagent_containers/food/drinks/water,\
		/obj/item/paper/lunchbox_note)

/obj/item/paper/lunchbox_note
	name = "note"
	desc = "Dang, who wrote this?"

	New()
		..()
		var/which = rand(1,13)
		switch(which)
			if(1)
				info = {"I have eaten<br>
				the donks<br>
				that were in<br>
				the lunchbox<br>

				and which<br>
				you were probably<br>
				saving<br>
				for lunch<br>

				Forgive me<br>
				they were delicious<br>
				so savory<br>
				and so warm<br>"}
			if(2)
				info = "<i>Aw, there's a cute drawing of a bee here.</i>"
			if(3)
				info = "I packed your favorites. Enjoy and have a good shift!"
			if(4)
				info = "This is the last time I'm packing your lunch for you, fucker. You're old enough to do it yourself, for christ's sake."
			if(5)
				info = "<i>There's a drawing of a skull and crossbones here. Huh.</i>"
			if(6)
				info = {"SILICA GEL<br>
				DO NOT EAT<br>
				THROW AWAY<br>
				DESICCANT<br>
				<p><i>Huh, but it's a sheet of paper?</i>"}
			if(7)
				info = {"Are you tired of eating the same boring lunch every day? Try Discount Dan's burritos!<br>
				<p><i>Weird, it seems to be some dumb ad.</i>"}
			if(8)
				info = "I wasn't sure what you liked, so I packed a bit of everything. I hope that's okay!"
			if(9)
				info = {"Your company is so nice for letting us send these care packages! I hope this lunchbox reaches you safely. They said they'd put these in cold storage, so I'm not too worried.<br>
				Love, Mom"}
			if(10)
				info = {"This is my last hope. They're monitoring the mail servers and radio transmissions and I don't dare to try to circumvent their methods.<br>
				They say that the truth will set you free, but I'm feeling as trapped as ever. Still, this needs to get out. People have to know.<br>
				Come see me at the place we first met."}
			if(11)
				info = {"I know what you're thinking. <i>What an absolutely divine lunch.</i><br>
				But, really. No need to thank me. I fucking love meal prep."}
			if(12)
				info = {"Okay, I know you were hungry last time I made you lunch, so I packed a little more this time. I hope you like it!"}
			if(13)
				info = "<i>Something is written in really fancy cursive here, but you can't read it. Who even uses cursive anymore?</i>"
