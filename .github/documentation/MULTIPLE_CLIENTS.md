# How to test with multiple clients
Sometimes you make changes you'd really like another player to help you test. Obviously you can't just push your buggy code onto the live servers and have them test it (unless you're a dev of course, then it's expected :P) so how can you test it locally?
- Run the game normally with F5.
- Click the very top left corner of the window, not the menus below it, the actual logo at the top left corner.
- Go to Server -> Host and put in a port number, remember this for later
- Open the Byond pager (that's the one with the blue icon that has the games list down the side)
- Log out of your Byond account (or if you weren't logged in when you started the server, log *into* your Byond account)
- Click the blue cog at the top right of the Byond pager
- Select "Open Location" and enter "localhost:<portnumber>" where <portnumber> is the port you entered earlier.
Tadaa, you now have a local server with a debugger attached and two clients connected.

## FAQs
- Why not just use Dream Daemon?
	- The debugger is only set up to attach to the Dream *Seeker* instance we run with F5. You can run a local server with Dream Daemon but you won't have the debugger.
- Why do I have to log out?
	- Each Byond client needs to have a unique key, Byond will just disconnect any duplicate clients out of hand. When you're logged out, Byond generates a random guest key for you to connect to the server with. You can set Byond to save your password to make it less of a hassle.
