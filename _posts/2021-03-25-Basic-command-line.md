---
layout: post
tags: [programming, linux, cli, bash]
excerpt_separator: "\n\n"
---

Little tutorial about the command line :)

> translated quickly and dirty with Google translate

## To know

The command line is a text interface between the user and the machine, the language used to interpret these commands may vary, under windows it will be `dos` or `powershell` and under linux it will often be `bash` . But here we will focus on the command line under linux.
For the examples I will use `bash` but that to work with other languages like `zsh`, `fish`, `ksh`,…
We often represent a command with a `$` in front of it to show that it is indeed a command to be done in a terminal.
In bash this will often be `username@hostname:current_folder$`.
The bash configuration file is in your home file as `.bashrc`. For ease of reference, the prompt in the examples will be like this `> ` but the prompt will probably end in a `$`.

## Functioning

When you launch a terminal, you will arrive by default in your `$HOME` folder, which is your user folder. The terminal works with a file and binary file system.
For example to move in a folder you will use the command `cd` which is a program, a binary file which moves you in the tree structure of your disk. A command in linux takes several parameters:

```bash
> mkdir -p /home/user
```

- `mkdir`
the mkdir binary program which allows you to create one or more folders
- `-p`
a mkdir parameter that allows you to create the parent folders if they do not yet exist (here the parent folder)
- `/home/user`
a mkdir parameter that tells it which tree to create

> if you do not know the parameters of a program you can use `man command` or often `command -h` or `command --help`

> you can use **`TAB`** to autocomplete your command, you will **never** use it enough, it allows you to type your command faster and also to check that you are typing the names of the folders correctly /files.

> you can use the up and down arrow to navigate through your order history.

## Basic commands

| command  | action                                                       |
|:---------|-------------------------------------------------------------:|
| cd       | this move in the tree structure of your pc                   |
| ls | list files and folders |
| mdir | creates folder(s) |
| rmdir | deletes a folder or folders |
| rm | delete one or more files |
| nano/vim | command line text editor |
| man | show documentation about a command |
| vm | allows you to move or rename one or more folders/files |
| cat | show the contents of a file |
| wget | allows to download a file from a url |
| history | displays your order history |

## Global variables

Variables in bash are denoted with a `$` in front.
There are a lot of global variables so I will only cover two for the example.

- `$HOME`: This variable designates the path to your personal folder (often `/home/your_username/`).
   So you can do this command `cd $HOME` to get there.
- `$PATH`: This variable is more complex, it designates the folders that are in the `$PATH`. These are the files where your command interpreter (here bash) will look for binary files. For example, it may be wise to add the `/bin` folder to the `$PATH` variable to be able to use the `ls` or `cd` command for example without designating the path to these binaries.
   To add a folder to the `$PATH`, use the command `export PATH=$PATH:/to/your/folder`, this command only lasts for the duration of your session (as long as your terminal is open). If you want to make it permanent you can add this command line to your `.bashrc` file located in your `$HOME` folder.

## Move in the filesystem

To move we use the `cd` command, the tree structure of a folder is displayed like this:

```bash
.          # the current folder
..         # the parent folder
a_folder   # a folder
my_program # binary file
.hidden    # a hidden folder
```

- To move to the `un_dossier` folder, simply write `cd un_dossier`.
- To move in the parent folder (go up in the tree structure) `cd ..`.
- You can move further than a single folder, for example if I am in `a_folder` and I want to go to `.caché` I can do `cd ../.caché`.

**I emphasize that you can use `TAB` to go faster and verify that the (../.hidden) path exists.**

To display the contents of a folder we use the `ls` command, by default ls does not display hidden folders (starting with a dot), to display them we can use the `-a` parameter:

```bash
> ls -a
.
..
a file
my program
.hidden
```

## Execute binary

To run a binary from the command line you must specify the path to this binary, for example:

```bash
> /home/user/bin/my_program
```

Or if your program is in the global variable `$PATH` you can just write the name of the binary, for example:

```bash
> my_program
```

On the other hand, if your binary is in the current folder, you will have to add `./` before the name of the binary. `./<binary_file` because it designates the folder you are in with the name of your binary, otherwise it will look in the folders that are in the `$PATH` variable.
Small example:

```bash
> ls
my_folder # folder
my_program # binary file
> my_program
bash: my_program: command not found # it can't find it
> ./my_program
Bonjour Monde!
```

## Arguments

When you issue a command or run a program you can give it arguments.
For example :

```bash
> ls -l -a -h
```

- `-l` is the first argument given to ls
- `-a` the second

In a bash script to use arguments you can do it like this:

```bash
> catscript.sh
echo $1 $2
> bash script.sh hi you
Hi you
```

To display the return value of a program (if there was an error for example), you can use the `$?` variable.
In most cases the normal return value is 0.

## Exits and Redirects

In command line you have 2 main outputs which are `stdout` and `stderr`.

| name     | description                                    |
| -------- | ---------------------------------------------- |
| `stdout` | the display of text, the result of a command,… |
| `stderr` | error display                                  |

To redirect the result of a command, we use the characters `<` and `>`.

| redirect | description                                                                                               |
| -------- | --------------------------------------------------------------------------------------------------------- |
| >        | redirect normal output to a file (remove content if already exists)                                       |
| \>>      | redirects to a file but at the end of the one if (without deleting the content there)                     |
| 2>       | redirect error output to a file                                                                           |
| 2>&1     | redirect error output to normal output                                                                    |

- In most cases we redirect errors to a `log` file or to `/dev/null` which is nothing but a “black hole”, which you send to `/dev/ null` you will never find it again.
- `2>&1`, the `&` is used so that the output is not redirected to a file named `1`.

For example if I make a command in a way to have an error, I can redirect it so that the error does not display like this:

```bash
> mkdir /path/which/does/not exist # without redirecting error
mkdir: cannot create directory '/path/which/does/does not exist': No such file or directory

> mkdir /path/which/does not exist/not 2> /dev/null
# displays nothing
```

It is also possible to combine commands with the `|` (pipe).
The pipe redirects the normal output (`stdout`) of the program to the following command.
For example :

```bash
> echo -e "Hello\nGoodbye"
Good morning
Bye
> echo -e "Hello\nGoodbye" | hello
Good morning
```

- You can thus combine several commands.

## Jobs

Command line jobs are programs that run in the background, which allow you to continue doing commands with, for example, scripts that run in the background.
To run a program in the background, just add a `&`:

```bash
> sleep 500&
[1] 704414
```

|        |                | 
| ------ | -------------- |
| [1]    | The job number |
| 704414 | the job PID    |

- the PID is the process number, it can be useful to know it to stop a process for example.
- In the example here the sleep 500 will run in the background

If you have run a command and want to run it in the background, you can do `ctrl+z` which will pause the process by default and put it in the background. To put a job in “running” it is enough to make the command `bg` for background.
To put a job in the foreground just do the command `fg` for foreground.

- If you have several jobs you must specify which jobs `%numero_jobs`, to display the jobs, just do the command `jobs`.

```bash
> jobs
[1] - running sleep 5000 # show command and job status
[2] + suspended sleep 300
```

And finally to kill a job if it no longer responds you can do `kill %numero_jobs`.

## Conclusion

You now have enough to know that to get by with a terminal,
You now know how to search/find documentation and how a command works,
Move around and interact with the tree structure of your computer (view, modify, delete, create files/folders).
You know how to redirect output to log files, text files and to the *black hole*.
And you know how to manage jobs, programs in the background.
Have fun!