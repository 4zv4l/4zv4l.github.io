---
layout: post
tags: [programming, linux, cli]
excerpt_separator: "\n\n"
---

For this port, I will talk about few snippet of code (full code at the end) and explain the reason of "Why I Love Zig".

```zig
const std = @import("std");
const ns_per_s = std.time.ns_per_s;
const Thread = std.Thread;
```

## Import

Starting with the basic, how to "import" the standard library. In this snippet of code we can see the usage of `@import("std")`, the `@` symbole as a special meaning in Zig, we can use `@import` to import local zig file such as `@import("mylib.zig")`, but here it is specific for the stdlib, there is also `builtin`. If I can say it that way, every import in Zig is a structure, containing sub struct, constants, etc., for example:

```zig
// mylib.zig

const NAME = "Paul";

pub fn foo() []const u8 {
    return NAME;
}
```

Here if I can import and use it like this

```zig
const std = @import("std");
const Mylib = @import("mylib.zig");

pub fn main() void {
    std.debug.print("{s}\n", .{Mylib.foo()});
}
```

Here we cannot directly access `NAME` since its not declared as `pub` but if it was I could access it using `Mylib.NAME`.

## Print

```zig
fn print(comptime fmt: []const u8, args: anytype) void {
    const S = struct {
        var mutex = Thread.Mutex{};
    };
    S.mutex.lock();
    defer S.mutex.unlock();

    const stdout = std.io.getStdOut();
    var bout = std.io.bufferedWriter(stdout.writer());
    bout.writer().print(fmt, args) catch return;
    bout.flush() catch return;
}
```

This code is a bit complex for a first time Zig view, and it uses multiple sweet features of Zig (`comptime`, `defer`, `anytype`).
This function basically accept a `comptime` known format string and an `anytype` args argument, 
`anytype` here will be an anonymous struct containing the arguments to pass to the `bout.print` function.
Then I use `const S = struct` with a variable inside, not a field but a variable, which will make the variable `static` so it wont live in the function stack, it allows to share the same Mutex between different call of the `print` function (since the code contains thread).
Then I lock the mutex and use `defer` which is like Golang defer, it will unlock the mutex at the function exit.
Then basic I/O, creating a buffered writer and writing to stdout and flushing.
The error handling here is basically to return on error, not amazing but if I cannot write to stdout, I think it is ok to just give up xD.

Very quick paragraph about Zig error handling, its not using exception, its error by value, when a function return `!type` it means it returns either the `type` or an `!` error. The error can be handled with `catch` or if your function can return a `!` then you can use `try` to simply return the error to the calling function and for example handle all the error in `main` directly.

## pointer and struct

```zig
fn spin(running: *bool, opt: struct { frames: []const u8 = "-\\|/", ns_sleep: u64 = ns_per_s * 0.25 }) void {
    var idx: usize = 0;
    while (running.*) : (idx +%= 1) {
        print("{c}", .{opt.frames[idx % opt.frames.len]});
        std.time.sleep(opt.ns_sleep);
        print("\x08", .{});
    }
}
```




// to continue writing

```zig
pub fn run(comptime function: anytype, args: anytype, opt: anytype) !@typeInfo(@TypeOf(function)).Fn.return_type.? {
    if (args[1].len == 0) return error.NoNumberProvided;
    var running: bool = true;
    var th = try Thread.spawn(.{}, spin, .{ &running, opt });
    const rc = @call(.auto, function, args);
    running = false;
    th.join();
    return rc;
}

fn task(str: []const u8, num: []const u8) [2]u8 {
    print("\rStarting: {s}...\n", .{str});
    std.time.sleep(3 * std.time.ns_per_s);
    const n1 = blk: {
        var acc: u8 = 0;
        for (num) |n| acc +%= n;
        break :blk acc;
    };
    const n2 = blk: {
        var acc: u8 = 0;
        for (num) |n| acc +|= n;
        break :blk acc;
    };
    print("\rDone !\n", .{});
    return [2]u8{ n1, n2 };
}

fn obf(comptime str: []const u8) *const [str.len]u8 {
    const S = struct {
        var s: [str.len]u8 = undefined;
    };
    S.s = comptime blk: {
        var buff: [str.len]u8 = undefined;
        for (str, &buff) |c, *b| b.* = c -% 1;
        break :blk buff;
    };
    return &S.s;
}

pub fn main() u8 {
    var rc: u8 = 0;
    const vals: [2]u8 = run(
        task,
        .{ obf("Ifmmp-!Xpsme!\""), &[_]u8{ 1, 3, 255 } },
        .{ .frames = "|-" },
    ) catch |err| blk: {
        std.log.err("Oops: {s}\n", .{@errorName(err)});
        rc = 1;
        break :blk [2]u8{ 0, 0 };
    };
    print("=> {d}\n", .{vals});
    return rc;
}

test obf {
    const testing = std.testing;
    try testing.expectEqualStrings("Foo", obf("Gpp"));
}
```
