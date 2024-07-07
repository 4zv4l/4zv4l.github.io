---
layout: post
tags: [programming, linux, cli]
excerpt_separator: "\n\n"
---

I really enjoy [Zig](https://ziglang.org/), I have tried a lot of different language looking for the "best suited" 
programming language to make `safe`, `light` and `fast` program. And so far Zig check all the boxes.

I am a huge fan of C, it is the language that introduced me to IT and later to infosec. And as much as I like to play with pointers and memory,
I would be a fool to say it is easy to make safe software in C. The past few weeks have revealed **A LOT** of CVEs/Vulnerabilities:

- [OpenSSH](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2024-6387)
- [Palo Alto](https://knowledgebase.paloaltonetworks.com/KCSArticleDetail?id=kA14u000000CrM5CAK&lang=en_US)
- some [UEFI firmware](https://eclypsium.com/blog/ueficanhazbufferoverflow-widespread-impact-from-vulnerability-in-popular-pc-and-server-firmware/)

While `Zig` didnt yet reach `v1.0`, it already allows to make pretty good software. I am especially looking forward to discover [Ghostty](https://mitchellh.com/ghostty).

I made few toy project in `Zig` (my GitHub is mostly filled with Zig toy/half finished projects) like a very basic proxy server,
a beginning of a [Chip-8](https://en.wikipedia.org/wiki/CHIP-8) emulator,
a [BusyBox](https://en.wikipedia.org/wiki/BusyBox) replacement (easy to implement new commands, but lacking a lot of them for now),
[bencode](https://en.wikipedia.org/wiki/Bencode) library
and I am working on a [BitTorrent](https://en.wikipedia.org/wiki/BitTorrent) client, but since this project is especially interesting to me, I may wait for `Zig v1.0` before continuing this project.

`Zig` is exactly at the right place under `Nim`, and when I say "under" I dont mean less good, I mean lower level, Zig is very low level, I almost want to say lower level than C since Zig stdlib doesnt do anything unless you ask for it, for example `printf` in `C` is buffered while in `Zig` printing to `stdout` wont be buffered unless you make a `io.bufferedWriter`.

I will show a little bit of code that shows a lot of why I love Zig:

```zig
const std = @import("std");
const posix = std.posix;

fn obfuscate(comptime str: []const u8) *[str.len]u8 {
    // const struct make the data lifetime infinite
    const S = struct {
        var buff: [obf_str.len]u8 = undefined;
        // obfuscate given str
        const obf_str = blk: {
            var tmp: [str.len]u8 = undefined;
            for (0..str.len) |idx| {
                tmp[idx] = str[idx] +% 120;
            }
            break :blk tmp;
        };
    };

    // deobfuscate and return it (runtime)
    for (0..str.len) |idx| {
        S.buff[idx] = S.obf_str[idx] -% 120;
    }
    return &S.buff;
}

test obfuscate {
    // same length
    const foo = obfuscate("foo");
    const bar = obfuscate("bar");
    try std.testing.expectEqualStrings(foo, "foo");
    try std.testing.expectEqualStrings(bar, "bar");

    const hello = obfuscate("Hello, World !");
    try std.testing.expectEqualStrings(hello, "Hello, World !");
}

pub fn main() u8 {
    const myStr = obfuscate("Hello, World !\n");
    _ = posix.write(posix.STDOUT_FILENO, myStr) catch return 1;
    std.io.getStdOut().writeAll(obfuscate("Hello, You !\n")) catch {};
}
```

This simple piece of code can show:

- the error handling `try`/`catch` but no exception, the error is a value
- special operator to handle overflow `+%` (`+|` also exists)
- `comptime` which obfuscate the string at `compile time` but deobfuscate the string at `run time` (`strings myprog.bin` will not show the string)
- the slice system, array/strings have a `len and ptr` field and allow to easily loop without overflow

> There is also something to explain about the `const S struct` which is similar to `static` in C, but tbh I am not sure to understand it completely so I will avoid spreading potential wrong information.

There is a lot to say about Zig, I will maybe make a bigger post next time with a decent project to show as example of each points I love about the language. But for now
if you are interested about Zig, I highly encourage you to check [this website](https://zighelp.org/) and [this website](https://zig.guide/).
