# tgui

## Introduction

tgui is a robust user interface framework of /tg/station.

tgui is very different from most UIs you will encounter in BYOND programming. It is heavily reliant on Javascript and web technologies as opposed to DM.

## Learn tgui

People come to tgui from different backgrounds and with different learning styles. Whether you prefer a more theoretical or a practical approach, we hope you’ll find this section helpful.

### Practical Tutorial

If you are completely new to frontend and prefer to **learn by doing**, start with our [practical tutorial](docs/tutorial-and-examples.md).

### Guides

This project uses React. Take your time to read the guide:

- [React guide](https://react.dev/learn)

### Other Documentation

- [Component Reference](docs/component-reference.md) - UI building blocks
- [Using TGUI and Byond API for custom HTML popups](docs/tgui-for-custom-html-popups.md)
- [Chat Embedded Components](docs/chat-embedded-components.md)
- [Writing Tests](docs/writing-tests.md)

## Pre-requisites

You will need these programs to start developing in tgui:

- [Node v**20**.15+](https://nodejs.org/en/download/)
  - Using either the prebuilt installer or a package manager works.
  - **LTS v20** release is recommended instead of latest, as well as the x64 arch.
  - **DO NOT install Chocolatey if Node installer asks you to!**
- [Yarn v4.1.1+](https://yarnpkg.com/getting-started/install) (optional)

## Usage

Run `bin/tgui --install-git-hooks` to install merge drivers which will
assist you in conflict resolution when rebasing your branches. This only has
to be done once.

**For Git Bash, MSys2, WSL, Linux or macOS users:**

Change your directory to `tgui`.

Run `bin/tgui` with any of the options listed below.

**For Windows CMD or PowerShell users:**

If you haven't opened the console already, you can do that by holding
Shift and right clicking on the `tgui` folder, then pressing
either `Open command window here` or `Open PowerShell window here`.

Run `bin/tgui.bat` with any of the options listed below.

> If using PowerShell, you will receive errors if trying to run
> `.\bin\tgui.ps1`, because default Windows policy does not allow direct
> execution of PS1 scripts. Run `.\bin\tgui.bat` instead.

**Available commands:**

- `bin/tgui` - Build the project in production mode.
- `bin/tgui --dev` - Launch a development server.
  - tgui development server provides you with incremental compilation,
  hot module replacement and logging facilities in all running instances
  of tgui. In short, this means that you will instantly see changes in the
  game as you code it. Very useful, highly recommended.
  - In order to use it, you should start the game server first, connect to it
  and wait until the world has been properly loaded and you are no longer
  in the lobby. Start tgui dev server, and once it has finished building,
  press F5 on any tgui window. You'll know that it's hooked correctly if
  you see a green bug icon in titlebar and data gets dumped to the console.
  - `bin/tgui --dev --reload` - Reload byond cache once.
  - `bin/tgui --dev --debug` - Run server with debug logging enabled.
  - `bin/tgui --dev --no-hot` - Disable hot module replacement (helps when doing development on IE8).
  - `bin/tgui --dev --no-tmp` - Don't use the tmp folder
- `bin/tgui --lint` - Show (and auto-fix) problems with the code.
- `bin/tgui --sonar` - Analyze code with SonarQube.
- `bin/tgui --test` - Run unit and integration tests.
- `bin/tgui --analyze` - Run a bundle analyzer.
- `bin/tgui --bench` - Run benchmarks. *Windows Only*
- `bin/tgui --clean` - Clean up tgui folder.
- `bin/tgui [webpack options]` - Build the project with custom webpack
options.

**For everyone else:**

You can double-click these batch files to achieve the same thing:

- `bin\tgui.bat` - Build the project in production mode.
- `bin\tgui-dev-server.bat` - Launch a development server.
- `bin\tgui-bench.bat` - Run benchmarks.

**Other Commands**
- `yarn tgui-polyfill:build` - Build polyfills. You need to run it when updating any of the static (numbered) polyfills.
- `yarn tgui-polyfill:static-css` -  Polyfill CSS Variables & autoprefix static css files. Takes a folder directory as an argument.

## Important Memo

Remember to always run a full build of tgui before submitting a PR, because it comes with the full suite of CI checks, and runs much faster on your computer than on GitHub servers. It will save you some time and possibly a few broken commits! Address the issues that are reported by the tooling as much as possible, because maintainers will beat you with a ruler and force you to address them anyway (unless it's a false positive or something unfixable).

## Troubleshooting

**Development server is crashing**

Make sure path to your working directory does not contain spaces, special unicode characters, exclamation marks or any other special symbols. If so, move codebase to a location which does not contain these characters.

This is a known issue with Yarn (and some other tools, like Webpack), and fix is going to happen eventually.

**Development server doesn't find my BYOND cache!**

This happens if your Documents folder in Windows has a custom location, for example in `E:\Libraries\Documents`. Development server tries its best to find this non-standard location (searches for a Windows Registry key), but it can fail. You have to run the dev server with an additional environmental variable, with a full path to BYOND cache.

```
BYOND_CACHE="E:/Libraries/Documents/BYOND/cache"
```

**`Script error.` on CDN-originating .js files**

Add `crossorigin="anonymous"` to the script tags in your downloaded tgui-window-x.html file found in your BYOND cache.

**Webpack errors out with some cryptic messages!**

> Example: `No template for dependency: PureExpressionDependency`

Webpack stores its cache on disk since tgui 4.3, and it is very sensitive to build configuration. So if you update webpack, or share the same cache directory between development and production build, it will start hallucinating.

To fix this kind of problem, run `bin/tgui --clean` and try again.

**Error: Unable to locate pnpapi, the module '...\goonstation\tgui\packages\tgui-dev-server\index.js' is controlled by multiple pnpapi instances.**

At present, due to an issue with yarn the dev server cannot be ran if the path to your repo contains spaces. This could be caused if you have the repo in your Documents folder and your Windows user is your first name and last name (e.g. `C:\Users\Firstname Lastname\Documents\goonstation`).

For now, you'll have to move the whole repo to a different location without spaces (e.g. `C:\Dev\goonstation`). Moving the whole `goonstation` folder in this way shouldn't cause any issues, but make sure to close down VS Code and anything else you have that might be accessing the files within.

## Dev Server Tools

When developing with `tgui-dev-server`, you will have access to certain
development only features.

**Debug Logs.**
When running server via `bin/tgui --dev --debug`, server will print debug
logs and time spent on rendering. Use this information to optimize your
code, and try to keep re-renders below 16ms.

**Kitchen Sink.**
Press `F12` or click the green bug to open the KitchenSink interface. This interface is a
playground to test various tgui components.

**Layout Debugger.**
Press `F11` to toggle the _layout debugger_. It will show outlines of
all tgui elements, which makes it easy to understand how everything comes
together, and can reveal certain layout bugs which are not normally visible.

## Browser Developer Tools

To debug TGUI interfaces with browser-style developer tools, there exists a utility
that Microsoft bundles with Windows called IEChooser/F12 to debug any Internet Explorer/Trident-using interface,
which BYOND uses.

This provides invaluable tools such as a local console, a DOM viewer, an interactive debugger, and more.

You can access the `IEChooser.exe` by pressing <kbd>Win + R</kbd>, then typing `f12`, then pressing enter.
To manually go there: 64-bit version that we use is located at `%windir%\SysWOW64\F12\IEChooser.exe`.
There's also a 32-bit one in `system32\`.

Simply launch the application after you've opened a TGUI window, and choose the .html name.
This is likely to be something like `tgui-window-1`. There's a refresh button in the top right.

Unfortunately, it seems this program doesn't have a new target chooser if your window is fully closed
so you'll need to restart it if it disconnects from the window.

## Project Structure

- `/packages` - Each folder here represents a self-contained Node module.
- `/packages/common` - Helper functions that are used throughout all packages.
- `/packages/tgui/index.js` - Application entry point.
- `/packages/tgui/components` - Basic UI building blocks.
- `/packages/tgui/interfaces` - Actual in-game interfaces.
- `/packages/tgui/layouts` - Root level UI components, that affect the final look and feel of the browser window. These hold various window elements, like the titlebar and resize handlers, and control the UI theme.
- `/packages/tgui/routes.js` - This is where tgui decides which interface to pull and render.
- `/packages/tgui/styles/main.scss` - CSS entry point.
- `/packages/tgui/styles/functions.scss` - Useful SASS functions. Stuff like `lighten`, `darken`, `luminance` are defined here.
- `/packages/tgui/styles/atomic` - Atomic CSS classes. These are very simple, tiny, reusable CSS classes which you can use and combine to change appearance of your elements. Keep them small.
- `/packages/tgui/styles/components` - CSS classes which are used in UI components. These stylesheets closely follow the [BEM](https://en.bem.info/methodology/) methodology.
- `/packages/tgui/styles/interfaces` - Custom stylesheets for your interfaces. Add stylesheets here if you really need a fine control over your UI styles.
- `/packages/tgui/styles/layouts` - Layout-related styles.
- `/packages/tgui/styles/themes` - Contains themes that you can use in tgui. Each theme must be registered in `/packages/tgui/index.js` file.

## Component Reference

See: [Component Reference](docs/component-reference.md).

## FontAwesome Icon

For a list of all the icons you can use, see the [FontAwesome website](https://fontawesome.com/v6/search?o=r&m=free&s=solid%2Cregular)

For additional font styles you can use, see the [FontAwesome Docs](https://fontawesome.com/v6/docs/web/style/style-cheatsheet#contentHeader)

## License

### All tgui code in the Goonstation repository is licensed under [**MIT**](https://choosealicense.com/licenses/mit/) unless otherwise indicated.

The original source code on the tgstation repository is covered by /tg/station's parent license - **AGPL-3.0**
(see their main [README](https://github.com/tgstation/tgstation/blob/master/README.md)).

However, tgui files from tgstation used by us are annotated with a copyright header,
which explicitly states the copyright holder and license of the file.
Most of the tgui source code is available under the **MIT** or **ISC** license.


The Authors retain all copyright to their respective work here submitted.
