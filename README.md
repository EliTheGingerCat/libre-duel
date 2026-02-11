# <img src="./images/icon_small.svg" alt="Libre Duel icon" width="30"/> Libre Duel

## Table of Contents

- [Contact](#contact)
- [Purpose](#purpose)
- [Contributing](#contributing)
	- [Setup the environment](#setup-the-environment)
	- [Lune commands](#lune-commands)
	- [Add a feature](#add-a-feature)
	- [Development guidelines](#development-guidelines)
	- [Style](#style)
- [Credits](#credits)
- [License](#license)

## Contact

Stoat (formerly known as Revolt) server: <https://stt.gg/p4azhCRE>

## Purpose

Libre Duel was originally conceived because there were several features that Breter and I thought could really benefit Bridge Duel, but the owner refused to add. The earliest record I have of this is on 2025 June 27, though I think the actual conception date was probably around a month earlier.

I also realised it would be a good idea because I love [FOSS](<https://opensource.org/osd>).

At some point I realised it would be cool how Bridge Duel would have two editions: Proprietary and Libre, just like Minecraft has Java and Bedrock.

When Bridge Duel got taken down, a new reason emerged: Libre Duel would now be the *only* variant of Bridge Duel available. The hope is that this game will be different enough to not warrant a takedown.

## Contributing

### Setup the environment

Here is a guide to prepare everything to start contributing. It assumes you know NOTHING.

Similar to the scientific method, it is optimal to read through all the instructions before beginning.

Feel free to ask for help on the Stoat (formerly known as Revolt) server!

1. Fork this repository on GitHub. In the fork options, unselect this option: Copy the `main` branch only
1. Install [Git](https://git-scm.com/).
3. Open up a terminal.
4. Using the `cd` command, change working directory into a folder in which you want to store the `libre-duel` repository. The repository will soon be a *child* of this folder.

Let us follow an example in which someone wants to store the repository in a directory called `projects`. The `projects` directory is in their home directory (`~`). Thus, they run `cd ~/projects`.

New term: USER = Your GitHub username.

5. Clone your fork. This can be done with `git clone https://github.com/USER/libre-duel.git`. Notice the use of "USER", which represents your GitHub username.
6. Let Git do its thing.

You now have a local copy of the `libre-duel` repository. It is all stored in a directory. In the example, this directory would be `~/projects/libre-duel`.

7. Run `git clone https://github.com/EliTheGingerCat/roblox-build-tools.git`.
8. Let Git do its thing.

You now have a local copy of the `roblox-build-tools` repository.

It is a *sibling* of `libre-duel. That is, they both share the same parent.

Consider this diagram:

```
> ~
--> projects
----> libre-duel
----> roblox-build-tools
```

9. Enter the `libre-duel` repository with `cd libre-duel`.
10. Install [Rokit](https://github.com/rojo-rbx/rokit).
11. Run `rokit install`.

You now have [Lune](https://lune-org.github.io/docs/) and [Rojo](https://rojo.space/).

You might want to check out the [Lune commands](#lune-commands).

Question: How do I know I can trust all this?  
Answer: This is not something that really belongs in this README. If you want, we can talk about it in the Stoat (formerly known as Revolt) server.

### Lune commands

Run `lune list` for an explanation of what each command does. Output:
- `build` - Build the Place.
- `build_no_map` - Build the Place without the massive map.
- `crlf` - Replace LF with CRLF in text files.
- `generate_no_map` - Generate a project file without the massive map.
- `run-context` - Remove all meta files that only set RunContext.
- `serve` - Serve information from the filesystem to the Roblox Studio plugin.
- `serve_no_map` - Serve without the massive map.
- `sourcemap` - Create a mapping of the filesystem into Roblox objects.
- `syncback` - Sync instances from the built Place into the filesystem.

Sourcemapping and serving are the main utilities. However, `sourcemap` and `serve` are both simple Rojo commands that do not depend on the name of the game, so there is not really any strong reason to use them. I use `sourcemap` anyway.

Building is also important, though serving accomplishes the same thing for development. However, I still build every so often so that there will be less work for the plugin.

When the lobby was added ([#15](<https://github.com/EliTheGingerCat/libre-duel/pull/15>)), serving started to take a lot longer. Thus, I created some scripts to enable development without the massive map. `generate_no_map` takes the existing project file, `default.project.json`, and creates `no_map.project.json`. It should be run every time the project file changes. `serve_no_map` and `build_no_map` use this new project file for serving and building, respectively. I use them instead of `serve` and `build`. In theory, this problem may return as the codebase grows larger, though text files are a lot smaller than Roblox models; furthermore, I can come up with some ways of even serving without certain code files 😼.

I use `syncback` whenver I want to sync models into the filesystem from ServerStorage or from Workspace. Sometimes, though, I just sync models manually by saving them to file.

`crlf` and `run-context` (I ought to make it use an underscore) have never been necessary for Libre Duel. I used them when converting over another game of mine, [Ethical Eli Hub](<https://github.com/EliTheGingerCat/ethical-eli-hub>), since it was made before I started using Rojo.

All of these scripts depend on [./build_name.luau](./build_name.luau), so the Rojo command for them requires specifying `libre-duel.rbxl` if one wishes to use Rojo directly:
- `build`
- `build_no_map`
- `syncback`

### Add a feature

This guide should be followed everytime you want to add a new feature or fix a bug.

This guide adheres to git-flow, as mentioned below.

1. Make sure your local repository is up to date. This comes in two parts:
	1. Make sure your fork on GitHub is up to date. This can be done by going to the page, on <https://github.com/USER/libre-duel/tree/develop>, and clicking the Sync button.
	2. Pull in any changes in your local repository. On the commandline, enter the folder that contains your local reposiotry via the `cd` command, then run `git pull`.
2. Checkout the `develop` branch with `git checkout develop`.
3. Make a new branch.

The branch name is not so important as long as it concisely describes the branch purpose. Personally, I follow some rules for it, which you can follow too if you want.

My branch names essentially come in two parts, `type` and `name`, and take the form of `{type}_{name}`.

If the change I am making is a new feature, then `type = "feature"`. If the change is fixing a problem, then `type = "fix"`. There are other types of changes one may make, but I would probably just pick whichever one makes the most sense. Most changes are `feature`. [One time](https://github.com/evaera/moonwave/pull/171) I used `type = "docs"` but I would not do it anymore.

As for `name`, I just describe the feature as concisely as possible. I use 2 to 4 words. Sometimes I use imperative tense, sometimes it is just a compound noun.

The whole branch is in `lower_snake_case`. Since Luau does not allow dashes in identifiers, I feel like all Luau projects should avoid dashes for names, even in Git. At some point, I researched about dashes in Git branch names, and I do not remember finding a conclusive answer, probably because names do not really matter that much. They matter *a little*. Also, I think underscores just make more sense, as they are low down and do not take up attention, unlike hyphens (and definitely unlike the longer dashes (en and em)), so they are closer to a space, which would be ideal. One might point out that the name of this repository uses a dash: "bridge-duel"; yeah, I might need to think more on this.

For example, a branch that I [used](https://github.com/EliTheGingerCat/libre-duel/commit/5471a8e32c51b2449ebae025dcecc544c29a110f) for this repository is `feature-melee-attack`.

Anyway, let your branch name be `BRANCH_NAME`. You would make a new branch with `git branch BRANCH_NAME`.

4. Checkout your new branch with `git checkout BRANCH_NAME`.

It is possible to do steps 3 and 4 in one command with `git checkout -b BRANCH_NAME`, but personally, I like doing each action separately.

5. Work on your branch.

First, make changes. Make sure to follow the [code style](#style).

Then, you can stage all changes with `git add -A`.

Then, commit the changes with `git commit`. Let your commit message be `COMMIT_MESSAGE`. You could use `git commit -m 'COMMIT_MESSAGE'`, but I prefer using the file (`COMMIT_EDITMSG`) that pops up without the `-m` flag. In my editor, Visual Studio Code, there are two vertical lines that appear in the file that make it easy for me to follow column limits. The first line should be at most 50 characters long, and every other line should be at most 72 characters long. Some stuff, like hyperlinks or commit ids, go over this limit; they should be placed on their own line (while still going over the limit since it would be weird to break them up into pieces).

Repeat this until your work is done.

6. Push the branch upstream with `git push -u origin HEAD`. (There are two assumptions here: that your remote is called "origin" and that you are currently checked out on the branch you are working on (since "HEAD" is used).)

7. The terminal will output a link to use to make a pull request. Use that link. Write a good title and description for your pull request.

8. I, EliTheGingerCat, will review your code.

If it gets approved, then I will merge it. You are done!

If I request changes, then you will probably need to work on the branch more, though I often apply these changes on my own. If you want to apply the changes, then you can follow step 5 again. When you are done, you can just run `git push`. (I am pretty sure this pushes all local commits in your repository. If you only want to push commits in the branch you are working on, then I am pretty sure the command is `git push origin BRANCH_NAME`.)

Thank you for contributing to Libre Duel!

### Development guidelines

See: <https://github.com/EliTheGingerCat/roblox-build-tools?tab=readme-ov-file#only-for-me>  
This is covered in the guide above.

Though, I am going to have to come up with an actual solution for this since this project has a decent chance of receiving contributions from random people.

I want to follow git-flow: <https://nvie.com/posts/a-successful-git-branching-model/>

Personally, I follow Conventional Commits: https://www.conventionalcommits.org/en/v1.0.0/

Also see: https://gist.github.com/qoomon/5dfcdf8eec66a051ecd85625518cfd13

This project does not follow Semantic Versioning since I do not see how it could be applied to video games. However, it *does* keep a [changelog](./CHANGELOG.md).

One can add the file `./src/ServerScriptService/modules/IPinfo_token.luau`, though that only makes sense under all of the following conditions:
- It is outside of a published Roblox game (otherwise, one can use [Secrets](<https://create.roblox.com/docs/cloud-services/secrets>)).
- One wants to use the [IPinfo Lite](<https://ipinfo.io/lite>) API (which is worse because it does not provide city).

(The file is ignored by Git (so that API tokens are not logged to the repository).)

The file should look like this:

```luau
local IPinfo_token = "[TOKEN HERE]"

return IPinfo_token
```

### Style

- Add a trailing newline to text files.
- Use trailing commas in code.
- Use `lower_snake_case`.
- Place all requires in the same spot.
- Order requires alphabetically.
- Use `Color3.new` over the other constructors (`fromHex`, `fromHSV`, `fromRGB`).
- Functions should return a single value.
- Add type annotations to all function parameters and return values. Exceptions:
	- Do not annotate the return type if it is a React element.
	- Do not annotate the return type if it is a function. (For example: React Effects.)
- Do not use anonymous functions.
- It is preferred to use British English spelling (such as "colour" instead of "color").

## Credits

Libre Duel is developed by [@EliTheGingerCat](https://github.com/EliTheGingerCat) and [@coolpeter98](https://github.com/coolpeter98).

It also has contributions from:
- [@Austriaaa](https://github.com/Austriaaa)
- [@oTillyy](https://github.com/oTillyy)

The following are external projects and assets that Libre Duel uses.

### IPinfo

Type: Application programming interface  
Link: <https://ipinfo.io/>  
License: [CC BY-SA 4.0](<https://creativecommons.org/licenses/by-sa/4.0/>)

Used for: Retrieving Roblox server location.  
Relevant files: [`IPinfo.luau`](./src/ServerScriptService/modules/IPinfo.luau), [`server_location.server.luau`](./src/ServerScriptService/server_location.server.luau)

### Half Life 2 Grenade Tick

Author: [@the1oler](https://www.roblox.com/users/87456522/profile)  
Type: Sound effect  
Link: https://create.roblox.com/store/asset/2164165859

Used for: Cube placed  
Relvant files: [`play_sound_local.luau`](./src/ReplicatedStorage/client/modules/play_sound_local.luau)

### cartoon_pop

Author: [@Schnogrind](https://www.roblox.com/users/52134822/profile)  
Type: Sound effect  
Link: https://create.roblox.com/store/asset/6586979979

Used for: Nothing yet, but will be used for player damaged.  
Relvant files: [`play_sound_local.luau`](./src/ReplicatedStorage/client/modules/play_sound_local.luau)

### Signal

Authors: [@sleitnick](<https://github.com/Sleitnick>), [@stravant](<https://github.com/stravant>)  
Type: Software  
Link: <https://github.com/Sleitnick/RbxUtil/blob/main/modules/signal/init.luau>

Used for: Signals.

# License

Libre Duel is licensed under the MIT License. See [`LICENSE.txt`](./LICENSE.txt). This license does not even need a summary.

Yes, you are allowed to republish the game exactly and profit off of it!

However, as the license says, attribution is necessary, preferably in the game description. Could also be in an in-game menu, on a website, et cetera. As long as it is easily visible.
