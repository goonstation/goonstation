/* |~~~~~~~~~~~~| SPAN MACROS |~~~~~~~~~~~~| */



/* == == == Normal messages == == == */


/// light: color "#000000" | dark: color "#dfdfcf"
#define SPAN_REGULAR(string) ("<span class='regular'>" + string + "</span>")

/// light: color "#0000ff" | dark: color "#7996ff"
#define SPAN_NOTICE(string) ("<span class='notice'>" + string + "</span>")

/// light: color "#ff0000" | dark: color "#e20000"
#define SPAN_COMBAT(string) ("<span class='combat'>" + string + "</span>")

/// light: color "#808000" | dark: color "#caca20"
#define SPAN_MEDAL(string) ("<span class='medal'>" + string + "</span>")

/// light: color "#008000" | dark: color "#92e592"
#define SPAN_SUCCESS(string) ("<span class='success'>" + string + "</span>")

/// light: color "#888888" | dark: color "#7a7471"
#define SPAN_SUBTLE(string) ("<span class='subtle'>" + string + "</span>")

/// light: color "#0000ff" | dark: color "#7996ff"
#define SPAN_HINT(string) ("<span class='hint'>" + string + "</span>")

/// light: color "#a97da9" | dark: color "#5A1D8A"
#define SPAN_ARTHINT(string) ("<span class='arthint'>" + string + "</span>")

/* == == == Important Messages == == == */


/// both: bold / larger font | light: color "#4c00ff" | dark: "#9c74fc"
#define SPAN_BLOBALERT(string) ("<span class='blobalert'>" + string + "</span>")

/// light: color "#ff0000" | dark: color "#ff6d6d"
#define SPAN_ALERT(string) ("<span class='alert'>" + string + "</span>")

/// light: color "#002fff" | dark: color "#92b4ff"
#define SPAN_INTERNAL(string) ("<span class='internal'>" + string + "</span>")



/* == == == Speech == == == */


/// wrapper class for filtering
#define SPAN_SAY(string) ("<span class='say'>" + string + "</span>")

/// color "#488276"
#define SPAN_FLOCKSAY(string) ("<span class='flocksay'>" + string + "</span>")

/// light: color "#5c00e6" | dark: color "#b27eff"
#define SPAN_DEADSAY(string) ("<span class='deadsay'>" + string + "</span>")

/// light: color "#663500" | dark: color "#e2a059"
#define SPAN_HIVESAY(string) ("<span class='hivesay'>" + string + "</span>")

/// both: color "#ffffff" | light: / background-color "#580283" | dark: background-color "#6f00a7"
#define SPAN_THRALLSAY(string) ("<span class='thrallsay'>" + string + "</span>")

/// both: color "#ffffff" | light: background-color "#566B44" | dark: background-color "#7B8F68"
#define SPAN_KUDZUSAY(string) ("<span class='kudzusay'>" + string + "</span>")

/** both
 * color  font-family / 'Courier New', Courier, monospace / font-weight bold
 *
 * light
 * background-color "#111" / color "#ffffff"
 *
 * dark
 * background-color "#c4c3c3" / color "#111"
 */
#define SPAN_ROBOTICSAY(string) ("<span class='roboticsay'>" + string + "</span>")

/// light: color "#d81aef" | dark: color "#ca4ed8"
#define SPAN_GHOSTDRONESAY(string) ("<span class='ghostdronesay'>" + string + "</span>")

/// light: color "#ffffff" / background-color "#226622" | dark: color "#111" background-color "#4ec44e"
#define SPAN_BLOBSAY(string) ("<span class='blobsay'>" + string + "</span>")

/// color "#E89235"
#define SPAN_MARTIANSAY(string) ("<span class='martiansay'>" + string + "</span>")

/// light: color "#605b59" | dark: color "#888888"
#define SPAN_EMOTE(string) ("<span class='emote'>" + string + "</span>")



/* == == == Intents == == == */


/// both: bold | light: color "#349E00" | dark: color "#42CC00"
#define SPAN_HELP(string) ("<span class='help'>" + string + "</span>")

/// both: bold | light: color "#EAC300" | dark: color "#FFFF00"
#define SPAN_DISARM(string) ("<span class='disarm'>" + string + "</span>")

/// bold / color "#FF6A00"
#define SPAN_GRAB(string) ("<span class='grab'>" + string + "</span>")

/// both: bold | light: color "#B51214" | dark: color "#D01416"
#define SPAN_HARM(string) ("<span class='harm'>" + string + "</span>")



/* == == == LOOC / OOC == == == */


/// light: color "#b82e00" | dark: color "#be6e53"
#define SPAN_ADMINOOC(string) ("<span class='adminooc'>" + string + "</span>")



/* == == == Admin / Mentor == == == */


/// light: color "#9a0eea" | dark: color "#e75ae0"
#define SPAN_MHELP(string) ("<span class='mhelp'>" + string + "</span>")

/// light: color "#0000ff" | dark: color "#ffa135"
#define SPAN_AHELP(string) ("<span class='ahelp'>" + string + "</span>")

/// light: color "#386aff" | dark: color "#ecc300"
#define SPAN_ADMIN(string) ("<span class='admin'>" + string + "</span>")



/* == == == Style == == == */


#define SPAN_BOLD(string) ("<span class='bold'>" + string + "</span>")
#define SPAN_ITALIC(string) ("<span class='italic'>" + string + "</span>")
#define SPAN_MONOSPACE(string) ("<span class='monospace'>" + string + "</span>")



/* == == == Misc == == == */


/// Wrapper class bold
#define SPAN_NAME(string) ("<span class='name'>" + string + "</span>")

/// Wrapper class
#define SPAN_MESSAGE(string) ("<span class='message'>" + string + "</span>")

/// centered text / float left
#define SPAN_PREFIX(string) ("<span class='prefix'>" + string + "</span>")

#define SPAN_HELPMSG(string) ("<span class='helpmsg'>" + string + "</span>")
