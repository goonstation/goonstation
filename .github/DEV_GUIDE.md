# Goonstation Development Guide

[ToC]

## :question: So, how do I get started?

### Step 1: Downloading Visual Studio Code :arrow_down: 

Visit https://code.visualstudio.com/ to download the appropriate installation for your operating system. Then, run the installer.

You should be greeted with a screen that looks like this:![](https://i.imgur.com/HjDKDqj.png)

Now, we need to create our own repository to contribute to! :rocket: 

### Step 2: Forking :fork_and_knife: 

Now, visit https://github.com/goonstation/goonstation. You'll want to press the `Fork` button in the top right corner. It looks like this:

![](https://i.imgur.com/C3obiAS.png)

Woah, now you have your own repository!

Now, let's combine your repository and VS Code!

### Step 3: *Git* Good :arrows_clockwise: 

First, we're going to need to download git, which can be found on [this page](https://git-scm.com/downloads). Install as normal, though I'd recommend not using vim as the default git editor. 

Now, go back to VS Code and relaunch it. Under the version control sidebar (looks like a tree branch) click Clone Repository. It should look like this: ![](https://i.imgur.com/pBqGiT2.png)

If that's not there, you can press `Ctrl+Shift+P` to open the command palette, then type `Git: Clone`, and then press enter. 

Now, paste the URL of the repository you created in the last step. It should look like this: `https://github.com/YOURNAME/goonstation`. Then, select a folder to keep your local repository. *The process of downloading might take a while.*

Once it's downloaded, open the folder in VS Code. You now have your own local copy of the code!

Next, we're going to need to get some necessary extensions!


### Step 4: Extension-O-Rama :gear: 

Click the Extensions button on the left bar or press `Ctrl+Shift+X`. It looks like a bunch of squares. You should see 5 recommended extensions. If you don't, type `@recommended` into the search bar. You'll want to install all of these.

For the GitHub Pull Requests extension, you'll have to sign in to GitHub to link it properly.

:::warning
If it errors, try again by launching `Sign in to GitHub` from the command palette.
:::

Now, let's connect the main goonstation repository to your client.

### Step 5: Remote Control :satellite_antenna:

We need to add the main Goonstation repository as a remote now. :satellite:

To do this, open the command palette and type `Git: Add Remote`. It'll prompt you for a name, which should be `upstream`. Then, put https://github.com/goonstation/goonstation as the URL. Now, you'll have the main Goonstation repository as a remote named upstream.

You're just about done with that! Just one last thing you need to manually do.

### Step 6: Fixing Up :wrench: 

:::info
If you're a Goonstation maintainer, run `git submodule update --init` instead of this step.
:::

++**This step is required.**++ You'll need to create a file named `__secret.dme` in the `+secret` subdirectory. **It should be blank and have no contents.**


That's it! Your local codebase is all set up to contribute now.

## Making Changes :lower_left_fountain_pen: 

First, let's talk about **branches**.
I hope you've thought of what you actually want to do. First thing to do is to make a new branch on your fork. This is important because you should **never** make changes to the default(master) branch of your fork. It should remain as a clean slate.

**For every PR you make, make a new branch.** This way, each of your individual projects have their own branch. A commit you make to one branch will not affect the other branches, so you can work on multiple projects at once.

### Step 1: Branching :deciduous_tree: 

To make a new branch, open up the source control sidebar (looks like a Y). Navigate to the More Actions menu (looks like `...`) and click `Checkout to...` like this:
![](https://i.imgur.com/C1EeNQm.png)

Then, click `Create new branch`.
For this guide, I'll be creating a new hat, so I'll name my branch `hat-landia`. If you look at the bottom left hand corner, you'll see that VS Code has automatically checked out our branch: ![](https://i.imgur.com/Ut0trn2.png)

**Remember, never commit changes to your master branch!** You can work on any branch as much as you want, as long as you **commit** the changes to the proper branch.

Go wild! Make your code changes! This is a guide on how to contribute, not *what* to contribute. So, I won't tell you how to code, make sprites, or map changes. If you need help, try asking in the `#imcoder`, `#imspriter`, or the `#immapper` [Discord](https://discord.gg/0117EEzASKYV2vtek) channels respectively.

### Step 2: Change It Up :twisted_rightwards_arrows: 

Here's the changes I'm making for the purpose of this guide:

* I added a new hat sprite to icons/obj/clothing/item_hats.dmi
![](https://i.imgur.com/tCmU12l.png)

* I added the following code to code/obj/item/clothing/hats.dm
```c
/obj/item/clothing/head/party/birthday/green
	name = "birthday hat"
	icon_state = "birthday-green"
	item_state = "birthday-pink"
	desc = "Happy birthday to you, happy birthday to you, you look like a monkey and you smell like one too."
```

Now, save your changes. If we look at the Source Control tab, we'll see that we have some new changes. Git has found every change you made to your fork's repo on your computer! Even if you change a single space in a single line of code, Git will find that change. Just make sure you save your files.

### Step 3: Up On Stage :movie_camera: 

Hover over the word `Changes` and press the plus sign to stage all modified files. It should look like this:

![](https://i.imgur.com/dI6kchl.png)

Or, pick each file you want to change individually. Staged files are the changes you are going to be submitting in commit, and then in your pull request. Once you've done that, they'll appear in a new tab called Staged Changes. 

![](https://i.imgur.com/jmSwxVk.png)

Click on one of the code files you've changed now! You'll see a compare of the original file versus your new file pop up. Here you can see, line by line, every change that you made. Red lines are lines you removed or changed, and green lines are the lines you added or updated. You can even stage or unstage individual lines, by using the More Actions (`...`) menu in the top right.

Now that you've staged your changes, you're ready to make a commit. At the top of the panel, you'll see the Message section. Type a descriptive name for you commit, and a description if necessary. Be concise!

Make sure you're checked out on the new branch you created earlier, and click the checkmark! This will make your commit and add it to your branch. It should look like this:
![](https://i.imgur.com/tTDvM3A.png)

There you go! You have successfully made a commit to your branch. This is still 'unpublished', and only on your local computer, as indicated by the little cloud and arrow icon ![](https://i.imgur.com/3Ptpbgt.png) in the bottom left corner.

### Step 4: Publishing to GitHub :cloud: 

Now, to get these changes onto GitHub, press ![](https://i.imgur.com/3Ptpbgt.png) or push normally for a prompt. This will push the commit you made to the origin on GitHub. You need an internet connection to do this, *obviously*.

VS Code will ask you what remote you want to push to. Click origin.
*Origin refers to your fork of the Goonstation repo. Upstream refers to the **actual** master Goonstation repo. You want to make the changes to **your fork**, so always pick origin.*

If you go to your fork on the GitHub website and go to your code, you'll see that your changes have been made! Make sure you're checking out the right branch.

![](https://i.imgur.com/tzDMrCE.png)

*I know it's tempting, but don't press the green button.*

Okay, we're almost done! Make as many changes and commits on your branch as you want, and move to the next step when you're done! Make sure to test your code. If you're not sure how to do that, ask somebody on `#imcoder`.

## Making a Pull Request

Ok. We're almost there!
:::info
This can also be done (somewhat easier) using the GitHub interface, but this guide's goal is to stay in-editor.
:::
Click the GitHub icon on the left sidebar. It looks like a cat in  circle. Now, you'll want to click the + sign that appears in the top left, like this:

![](https://i.imgur.com/zsIawKE.png)

Then, select the `upstream` repo and target the `master` branch. Then, you'll be able to select the title of your PR. The extension will make your PR with your selected title and a default description.

Next, you'll want to change the description. To do so, you can click the `Created By Me` sub tab to see your new PR. Then, click it and it should look like this:
![](https://i.imgur.com/IJaFIkO.png)

Now, you can edit your description in-editor, add labels, and request reviewers. Nifty! If you want to open it on GitHub, click the blue #NUMBER hyperlink.

If you want to add more commits to your PR, all you need to do is just push those commits to the branch.

Wow! Great job on making your PR. :tada: 


## Appendix :eyeglasses: 

### Terminology :open_book: 

**Repo:** Short for Repository. Contains all the Goonstation code, assets, commits, and other info. This is what you see at https://github.com/goonstation/goonstation.

**Fork:** A copy of the repo that belongs to you. It is not synced with the main repo, so you can make changes to it without affecting the main repo, and vice versa.

**Branch:** An independent version of your fork that you can work on without affecting your other branches. It is a way to group your commits.

**Commit:** A change to the repo that is submitted by someone. This change can be as small as single space you decided to add, or a complete re-write of multiple files.

**Diff:** Short for Difference. The difference in a repo before and after a commit is made. It shows you each change line-by-line.

**PR:**  Short for Pull Request. This a request you make to the Goonstation repo to merge changes from one of your branches into the master branch on Goonstation.

**Merge:** When a branch is merged into a repo, all of the commits on that branch are applied to the repo.

**Origin:** In this guide, this refers to your fork of the goonstation repo.

**Upstream:** In this guide, this refers to the master Goonstation repo at https://github.com/goonstation/goonstation

*[repo]: Repository - contains all Goonstation code and etc.
*[fork]: Your personal copy of the repo.
*[commit]: A change to the repo that is submitted by someone.
*[diff]: Difference before and after a commit is made.
*[pr]: Pull Request - The changes you request to the upstream.
*[origin]: Your fork of the Goonstation repo
*[upstream]: The master Goonstation repo at https://github.com/goonstation/goonstation

### Credits :clapper: 

Yogstation for making an amazing guide that this is based on, found [here](https://forums.yogstation.net/index.php?threads/release-the-gitkraken-how-to-make-your-first-pull-request.15099/).

/TG/station for for their [contribution guide](https://github.com/tgstation/tgstation/blob/master/.github/CONTRIBUTING.md), which was invaluable.
