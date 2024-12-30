/// THIS IS JUST A PLAYGROUND FILE FOR ALL THE WEIRD
/// SHIT IM BUILDING
const std = @import("std");
const libarr = @import("array.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const StringArr = libarr.Array([]const u8);
    var str_arr = try StringArr.init(allocator, 5);
    defer str_arr.deinit();

    try str_arr.push("Hello"[0..]);
    try str_arr.push("World!"[0..]);
    var iter = str_arr.iterator();

    while (true) {
        const v = iter.next();
        if (v == null) break;
        std.debug.print("Value from iterator: {s}\n", .{v.?});
    }

    // const fixed_arr = Array.FixedArray(u8);
    // var arr = try fixed_arr.init(allocator, 5);
    // const a = Array.FixedArray(u8);
    // var arr = try a.init(allocator, 5);
    // defer arr.deinit();
    //
    // try arr.push(1);
    // try arr.push(2);
    // try arr.push(4);
    //

    // try arr.push_at(2, 3);

    // const peeked = try arr.peek_prev(1); // Expect 4 (index 2)

    // std.debug.print("Peek index 1: {d}\n", .{peeked});

    // std.debug.print("Arr: {any}\n", .{arr.items[0..arr.len]});
    // const p = arr.push_head(1) catch |err| {
    //     std.debug.print("could not push to head: {any}\n", .{err});
    // };
    // _ = p;

    // try arr.push("hello");
    // try arr.push("world");
    //
    // for (arr.items[0..arr.len]) |i| {
    //     std.debug.print("{s}", .{i});
    // }
}

// try arr.left_shift(1);

// try arr.remove_at(1);

// std.debug.print("FixedArray: {any}\n", .{arr.items[0..arr.len]});
// try arr.pop();
