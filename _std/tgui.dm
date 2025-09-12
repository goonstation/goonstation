/// Green eye; fully interactive
#define UI_INTERACTIVE 2
/// Orange eye; updates but is not interactive
#define UI_UPDATE 1
/// Red eye; disabled, does not update
#define UI_DISABLED 0
/// UI Should close
#define UI_CLOSE -1

/// Maximum number of windows that can be suspended/reused
#define TGUI_WINDOW_SOFT_LIMIT 5
/// Maximum number of open windows
#define TGUI_WINDOW_HARD_LIMIT 9

/// Maximum ping timeout allowed to detect zombie windows
#define TGUI_PING_TIMEOUT (4 SECONDS)
/// Used for rate-limiting to prevent DoS by excessively refreshing a TGUI window
#define TGUI_REFRESH_FULL_UPDATE_COOLDOWN (0.75 SECONDS) // |GOONSTATION-CHANGE| from 1

/// Window does not exist
#define TGUI_WINDOW_CLOSED 0
/// Window was just opened, but is still not ready to be sent data
#define TGUI_WINDOW_LOADING 1
/// Window is free and ready to receive data
#define TGUI_WINDOW_READY 2

/// Get a window id based on the provided pool index
#define TGUI_WINDOW_ID(index) "tgui-window-[index]"
/// Get a pool index of the provided window id
#define TGUI_WINDOW_INDEX(window_id) text2num(copytext(window_id, 13))

/// Creates a message packet for sending via output()
// This is {"type":type,"payload":payload}, but pre-encoded. This is much faster
// than doing it the normal way.
// To ensure this is correct, this is unit tested in tgui_create_message.
#define TGUI_CREATE_MESSAGE(type, payload) ( \
	"%7b%22type%22%3a%22[type]%22%2c%22payload%22%3a[url_encode(json_encode(payload))]%7d" \
)


//------------ TGUI Colours ------------//
// See `https://github.com/tgstation/tgui-core/blob/main/styles/colors.scss`
// Custom Goonstation Colours
#define TGUI_COLOUR_NAVY "navy"
#define TGUI_COLOUR_CRIMSON "crimson"

// Base Colours
#define TGUI_COLOUR_RED "red"
#define TGUI_COLOUR_ORANGE "orange"
#define TGUI_COLOUR_YELLOW "yellow"
#define TGUI_COLOUR_OLIVE "olive"
#define TGUI_COLOUR_GREEN "green"
#define TGUI_COLOUR_TEAL "teal"
#define TGUI_COLOUR_BLUE "blue"
#define TGUI_COLOUR_VIOLET "violet"
#define TGUI_COLOUR_PURPLE "purple"
#define TGUI_COLOUR_PINK "pink"
#define TGUI_COLOUR_BROWN "brown"

// Additional Colours
#define TGUI_COLOUR_GOLD "gold"

// Greyscale Colours
#define TGUI_COLOUR_BLACK "black"
#define TGUI_COLOUR_WHITE "white"
#define TGUI_COLOUR_GREY "grey"
#define TGUI_COLOUR_LIGHT_GREY "light-grey"

// Semantic Colours
#define TGUI_COLOUR_PRIMARY "primary"
#define TGUI_COLOUR_GOOD "good"
#define TGUI_COLOUR_AVERAGE "average"
#define TGUI_COLOUR_BAD "bad"
#define TGUI_COLOUR_LABEL "label"


/// A map between TGUI colour strings and their values.
var/global/list/tgui_colours_to_rgb = list(
	TGUI_COLOUR_NAVY		= hsl2rgb(211, 100, 28),
	TGUI_COLOUR_CRIMSON		= hsl2rgb(0, 100, 30),
	TGUI_COLOUR_RED			= hsl2rgb(0, 70, 50),
	TGUI_COLOUR_ORANGE		= hsl2rgb(25, 90, 50),
	TGUI_COLOUR_YELLOW		= hsl2rgb(50, 97.5, 50),
	TGUI_COLOUR_OLIVE		= hsl2rgb(70, 75, 45),
	TGUI_COLOUR_GREEN		= hsl2rgb(140, 70, 40),
	TGUI_COLOUR_TEAL		= hsl2rgb(180, 100, 35),
	TGUI_COLOUR_BLUE		= hsl2rgb(210, 65, 47.5),
	TGUI_COLOUR_VIOLET		= hsl2rgb(260, 60, 50),
	TGUI_COLOUR_PURPLE		= hsl2rgb(290, 60, 50),
	TGUI_COLOUR_PINK		= hsl2rgb(325, 70, 50),
	TGUI_COLOUR_BROWN		= hsl2rgb(25, 47.5, 45),
	TGUI_COLOUR_GOLD		= hsl2rgb(40, 90, 50),
	TGUI_COLOUR_BLACK		= hsl2rgb(0, 0, 0),
	TGUI_COLOUR_WHITE		= hsl2rgb(0, 0, 100),
	TGUI_COLOUR_GREY		= hsl2rgb(0, 0, 50),
	TGUI_COLOUR_LIGHT_GREY	= hsl2rgb(0, 0, 66.6),
)
