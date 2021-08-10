Holds standard macros and defines for Goonstation. First in the compile order. See __std.dme for details on compilation.

if your file is BROADLY meant to just be a list of defines for value replacement, put it in the defines folder.
even if it has a few macros or a global list, the purpse of the file is more important for organisation!
if it doesnt fit in either, then leave it in the _std folder. (*scream)
also: please see if any of the existing files work for your defines or macros.
if they dont, please make a new file. i dont want to have to de-bloat another setup.dm :'(

TODO:
add a procs folder, and move most of our generic helper procs there (from the random places theyre scattered across the codebase)
add a globals folder, and move most of our global stuff there? not sure about this.
identify files withs similar purposes across defines, macros, lists, procs, globals, whatever. then make a file in main std folder with that content and delete the others.
