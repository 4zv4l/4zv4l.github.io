---
layout: post
tags: [programming, windows]
excerpt_separator: "\n\n"
---

Today, the deployment of *CliProtect* was completed successfully.
However, during the testing phase, we found an issue with the rdpclip.exe process.
If this process was already running before my injector was executed, it caused a conflict.

I did not see that during the *testing phase* since between every attempt I was logged out not simply disconnected (which keeps processes running).
But on that server the users aren't directly logged out, there is a delay between the disconnection and the log out action.

The simple purpose of *CliProtect* is to monitor the `copy` and `paste` attempts during an `RDP Session`.
Only text is allowed and you can easily configure multiple settings with a `json` file.
I made it in Nim and that was quite a nice project to get familiar with the `WINAPI`, `hooking` and `dll injection`.
> I will soon post my report here about all that :)

To resolve this issue, I had to figure out a way to kill the `rdpclip.exe` process before running my injector.
Since there was no function available in the standard Nim library, I decided to use the execCmdEx function from the osproc module to run two commands:

```powershell
taskkill /F /T /IM foo.exe /FI "USERNAME eq {username}"
```

- this command finds the process that needs to be killed

```powershell
taskkill /F /T /IM {process} /FI "USERNAME eq {username}"
```

- this command kills the process

By running these two commands, I was able to kill the rdpclip.exe process before executing my injector,
which will hopefully resolve the conflict, we will check tomorrow to see if it solves the issue.
> That is also important for my log system which requires the injector to be restarted to create a new log file for a new day.

**edit**: The deployment has been a success yesterday with the changes I showed up here :) 