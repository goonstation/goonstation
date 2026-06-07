# How to use the VS Code Debugger
## Oh God Why Did Everything Freeze Did The Game Crash
![](https://i.imgur.com/m4pXd1p.png)

***No, it didn't. (Probably.)
See the next section.***

## Using the Debugger

The **debugger** allows you to pause the game's execution so you can look inside and see what's going wrong. The debugger tab is found under the :beetle::arrow_forward: tab in the sidebar on the left, and if you haven't launched the game yet, it'll look something like this:
![](https://i.imgur.com/fNfPQGr.png)


First, find somewhere you want to inspect variables at, **inside a proc**. Breakpoints don't work outside of procs. Click just to the left of the line numbers to set a **breakpoint**. This is telling the debugger "stop running the code here so I can check things out."

Checking the debugger tab again, you'll see your breakpoint is listed here, under *breakpoints*:
![](https://i.imgur.com/vsvYAdg.png)

:::info
Notice the "runtime errors" checkbox- this is a 'special' setting which tells the game to always stop when a runtime error occurs. **You probably want to keep this on.** Otherwise, you might miss some errors while testing, which could cause bugs down the line.
:::

When the game runs a line of code which has a breakpoint, it **stops completely**, and the debugger panel will change to look like this:

![](https://i.imgur.com/t3uFjFr.png)

Let's go through these one at a time.

- **VARIABLES**
	- These are the variables which are in scope- essentially, everything that matters to this line of code. They're divided into a few different categories.
		- *Locals*
			- These are local variables to the proc, anything which is declared **in** the proc.
		- *Arguments*
			- ![](https://i.imgur.com/RUEMpQ1.png)
			- These are arguments to the proc, along with two 'special' arguments.
			- `usr`: A special variable which is set to whatever mob 'caused' the proc. It's generally unreliable. Further discussion [here](https://hackmd.io/KqcvmL-PQPSYCwfvwn9HYw#The-usr-keyword).
			- `src`: The thing the proc is being called 'on'- whatever object owns the proc. `src` is null for global procs.
		- *Globals*
			- These are global variables, variables which are visible to everything everywhere. There's a million of them and you shouldn't need to worry about them (if you do, something is probably very wrong).

- **WATCH**
	- You don't ever NEED this window, but it can be useful at times. By putting in some expression (like `user.loc.name` or `cat.owner.date_of_birth`), the value of that expression will always be displayed in this window.
	- ![](https://i.imgur.com/AnoTcc9.png)
	- Note that as you move between different procs and scopes, an expression may become undefined or change its value to a completely different thing.

- **BREAKPOINTS**
	- A list of active and inactive breakpoints, along with the 'stop on runtime errors' setting. Breakpoints can be toggled by clicking the checkbox, which will set them to inactive (ie, they won't do anything) without fully removing them. This allows you to easily reenable them later.
	- Note that **breakpoints remain on the same line even if you change the file they're set on**. For this reason, you shouldn't modify a file while you're in the middle of debugging, or the line which is currently running will be different than what's shown.

- **CALL STACK**
	- This is an **extremely** useful window which shows you the 'stack' of procs which lead to the current one. The top dropdown box is the current proc, and essentially the only relevant one- the other dropdowns below are unrelated concurrent processes running.
	- Here we can see the call stack for clicking a can of soda, leading all the way from the initial click (`client/Click`) to the `attack_hand` with a breakpoint in it.
	- ![](https://i.imgur.com/T1bgACc.png)
	- By clicking any of the listed procs, we can jump to exactly where in that proc the next proc was called (which may be in another file, which will be opened). Inspecting that `/mob/living/carbon/human/click` call, we see the line where `mob/living/click` was called:
	- ![](https://i.imgur.com/1itxF6d.png)
	- Note that macros (anything defined by `#define MACRO_NAME(args) ...`, typically having all-caps names) don't appear in the call stack, as the macro doesn't actually exist while you're running the game, only functioning as text replacement during compilation.
	- Also, built-in functions (`walk()`, `step()`, `get_dir()`, `viewers()`, etc) won't appear, because they aren't actually procs. You shouldn't need to worry about this.

:::info
You might see the same proc appearing multiple times in a row in the call stack, like `/client/Click` here. This isn't a bug- DM allows you to define a single proc in multiple places, and 'continue' executing it somewhere else. 
:::

Now we've stopped the game's execution on a breakpoint, and looked around at what's going on in that moment. However, we might want to continue execution one line at a time so we can see how things change as more code runs. For this, we need the little window somewhere at the top of your screen:

![](https://i.imgur.com/f8HtrTu.png)


From left to right, the buttons are:
- **Continue execution**; basically, resume running the code normally.
- **Step over**; basically, run the next line of code without entering any procs on that line.
- **Step in**; basically, enter the proc being called on this line. If there's multiple proc calls on the same line, you may have to step in multiple times to get where you want to go.
- **Step out**; basically, continue the current proc to the end, then stop as soon as we exit the proc.
- **Restart**; recompile and restart the game. Equivalent to closing the game and hitting F5 again.
- **Stop**; stops the game. The same as closing the game window.

That's about all you need to use the debugger; however, it takes some thought and experience to use the debugger **effectively**. Here's an example debugging case.

## Example Bug: Why Are All My Spacemen Exploding
Say I make some changes to the code, and now whenever a human moves, they instantly gib into a bunch of blood and organs. This isn't ideal. I need to find where the code that gibs them is being called from during movement, so I can fix or remove it.

I could just look for every instance of the `gib()` proc in code, as I'm *pretty* sure that's what's making them explode.

![](https://i.imgur.com/9nBff7S.png)

Alright, maybe not. I can use breakpoints and the call stack to find what's making my humans explode, but I don't know exactly where the person-exploding code is being called! I know that when I move, I explode, so I could just put a breakpoint in the `Move()` proc of humans. However, a lot of things happen when a person moves, so this might take a lot of stepping to find the right place.

Instead, I can take something that I know will happen **after** the person explodes, and put a breakpoint there. Then, the call stack leading to that point will show me exactly where the calling proc is!

I know that when a human gibs, they die, so I'll put a breakpoint in the `death()` proc of humans.
Running the code, and moving, we hit that death breakpoint and see...

![](https://i.imgur.com/0eosynI.png)

Clicking on the `/mob/living/Move()` call right before the `/mob/living/carbon/human/gib` call...
![](https://i.imgur.com/Vd7yNKC.png)

There it is! Someone (probably me) put a `gib()` call in the `/mob/living/Move()` proc. Whoops. Deleting that fixes the problem!

This is a silly, trivial bug, and actual bugs may be much more confusing and difficult to fix. As mentioned before, always feel free to ask the #imcoder channel in the [Discord](https://discord.gg/zd8t6pY).
