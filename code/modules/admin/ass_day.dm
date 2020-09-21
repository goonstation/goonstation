

//set the BUILD_TIME_DAY in __build.dm to 13 for this to be true ~ Warcrimes
// LOOKING FOR HOW TO USE ASS_JAM ? SCROLL TO THE BOTTOM OF THIS FILE OKAY

/client/proc/cmd_ass_day_rules()
	set name = "Ass Day Rules"
	set category = "Commands"
/*
#ifdef TWITCH_BOT_ALLOWED
	src.Browse({"<center><h2>!!! ASS DAY !!!</h2></center><hr>

				SPECIAL ANNOUNCEMENT : For this ass day, you can control shitty bill through our Twitch stream!
				<br>
				Join in at : <a href="https://www.twitch.tv/itsmethewonk">https://www.twitch.tv/itsmethewonk</a>
				<br><br>

				You have joined us for Ass Day, an event that occurs on the 13th of every month. During this time, the rules and their enforcement are heavily relaxed on this server. If you choose to join the game, expect complete and total chaos, rampant grief, and levels of violence that would make Joe Pesci cry. Of course, there's nothing stopping you from causing all that yourself if you choose to.<br><br>
				Bear in mind that a few rules are still in effect, however:<br>
				<ol>
					<li>No intentionally crashing the server or causing lag.</li>
					<li>No bigotry.</li>
					<li>No sexual stuff.</li>
					<li>No creepy shit.</li>
					<li>No impersonating the admins.</li>
					<li>No walling off or obliterating arrivals.</li>
					<li>No giving out secret recipes and the like.</li>
					<li>If an admin tells you to quit doing something, quit it.</li>
					<li>No you do not get an antag token.</li>
				</ol>
				If you do not see this popup, that means it is not Ass Day. Rule-breakers invoking Ass Day when it is not Ass Day will be dealt with incredibly severely, so don't fuck this up! A good rule of thumb to keep in mind - Ass Day begins and ends when the admins or the game itself say it is, not when you say it is.<br><br>
				Does all this sound like it doesn't appeal to you? No problem, Ass Day is a feature of our non-RP server only, so if you'd like a bit of peace and quiet go ahead and check the RP server out. We won't mind.<br>
				"}, "window=assday;size=500x650;title=ASS DAY;fade_in=1")
#else
	src.Browse({"<center><h2>!!! ASS DAY !!!</h2></center><hr>
				You have joined us for Ass Day, an event that occurs on the 13th of every month. During this time, the rules and their enforcement are heavily relaxed on this server. If you choose to join the game, expect complete and total chaos, rampant grief, and levels of violence that would make Joe Pesci cry. Of course, there's nothing stopping you from causing all that yourself if you choose to.<br><br>
				Bear in mind that a few rules are still in effect, however:<br>
				<ol>
					<li>No intentionally crashing the server or causing lag.</li>
					<li>No bigotry.</li>
					<li>No sexual stuff.</li>
					<li>No creepy shit.</li>
					<li>No impersonating the admins.</li>
					<li>No walling off or obliterating arrivals.</li>
					<li>No giving out secret recipes and the like.</li>
					<li>If an admin tells you to quit doing something, quit it.</li>
					<li>No you do not get an antag token.</li>
				</ol>
				If you do not see this popup, that means it is not Ass Day. Rule-breakers invoking Ass Day when it is not Ass Day will be dealt with incredibly severely, so don't fuck this up! A good rule of thumb to keep in mind - Ass Day begins and ends when the admins or the game itself say it is, not when you say it is.<br><br>
				Does all this sound like it doesn't appeal to you? No problem, Ass Day is a feature of our non-RP server only, so if you'd like a bit of peace and quiet go ahead and check the RP server out. We won't mind.<br>
				"}, "window=assday;size=500x650;title=ASS DAY;fade_in=1")
#endif*/
	src.Browse({"<center><h2>!!! ASS JAM !!!</h2></center><hr>
				<h3>PLEASE READ THIS POPUP - THE RULES HAVE CHANGED</h3>
				You have joined us for Ass Jam, an event that occurs on the 13th of every month. During this time, unstable and off-kilter features and bugs are sure to be on the menu. New variations on old concepts, nostalgic ex-content, and colorful additions from the community may make gameplay radically different from what you're used to!<br><br>
				Some loss of productivity is to be expected, and accidents WILL happen! Some stuff will kill you, or you pals- understanding is key. That being said, <i>please don't intentionally grief other players if you are not an antagonist~</i>. <br>
				Bear in mind that the following rules are IN FORCE:<br>
				<ol>
					<li><h3>DO NOT GRIEF OR OTHERWISE SELF-ANTAG. PLAY AS NORMAL</h3></li>
					<li>No intentionally crashing the server or causing lag.</li>
					<li>No bigotry.</li>
					<li>No sexual stuff.</li>
					<li>No creepy shit.</li>
					<li>No impersonating the admins.</li>
					<li>No walling off or obliterating arrivals.</li>
					<li>No giving out secret recipes and the like.</li>
					<li>If an admin tells you to quit doing something, quit it.</li>
					<li>No you do not get an antag token.</li>
				</ol>
				If you do not see this popup, that means it is not Ass Jam. Rule-breakers invoking Ass Jam when it is not Ass Jam will be dealt with incredibly severely, so don't fuck this up! A good rule of thumb to keep in mind - Ass Jam begins and ends when the admins or the game itself say it is, not when you say it is.<br><br>
				Does all this sound like it doesn't appeal to you? No problem, Ass Jam is a feature of our non-RP server only, so if you'd like a bit of peace and quiet go ahead and check the RP server out. We won't mind.<br><br>
				Would you like to contribute? Easy Peasy! <a href="https://github.com/goonstation/goonstation">https://github.com/goonstation/goonstation</a>! Warcrimes will surely write a guide to joining the Ass Jam, and totally won't forget to do this before april 13th. <br>
				"}, "window=assday;size=500x650;title=ASS JAM;fade_in=1")

#if ASS_JAM
var/global/ass_mutation
#ifndef SECRETS_ENABLED
var/list/ass_trinket_blacklist = list()
#endif

proc/ass_jam_init()
	if(prob(25))
		ass_mutation = pick(mutini_effects)

	trinket_safelist = childrentypesof(/obj/item) - ass_trinket_blacklist

	for(var/datum/job/job in job_controls.special_jobs)
		if(prob(4) && !istype(job, /datum/job/special/machoman))
			job.limit += rand(1, 5)

#endif



#if false // this should stop the compiler reading any of this, so it's just between you n me, pal.
/*
Suppose for an instant that you have a brilliant idea to add to the game, something absolutely everyone ought to see, but maybe just once a month.
“Excellent” you shout, at no one.
It is time to add to the ASS_JAM.
Simply take your excellent idea, and sandwich it between "#if ASS_JAM" and "#endif"
*/

#if ASS_JAM
/obj/item/clothing/mask/cigarette/cigarillo/juicer/exploding // Wow! What an example!
	buttdesc = "Ain't twice the 'Rillo it used to be."
	exploding = 1
#endif

/*
If your ASS_JAM contribution replaces the functionality of a proc,
simply make a copy of that proc, and wrap it between "#if ASS_JAM" and "#else",
with the original proc between "#else" and "#endif", as demonstrated below.
*/

#if ASS_JAM

	on_pet(mob/user)
		my_new_terrible_idea()

#else
/*
	on_pet(mob/user)
		the_original_code()
*/
#endif
/*
It may be desireable, in longer procs, to only override one or several groups of lines.
Please avoid unnecessary fracturing, and use only one #if-#else-#endif block per proc or object when possible.

In order to assist in this request, the ASS_JAM define may also be used as a boolean variable.
Its truth value is set by the build process, based on the calendar date. It evaluates to 1 on the 13th day of the month, 0 at all other times.
Example Usage:
*/
	on_pet(mob/user)
		if (..())
			return 1
		if (prob(ASS_JAM?50:25))
			var/turf/T = get_turf(src)

/*When you're all done wrapping your hogg in a vorbis, just open a PR directly to goon master, no special branches.

*/
#endif
//ok my compiler ser you may continue

