/// THIS IS JUST A PLAYGROUND FILE FOR ALL THE WEIRD
/// SHIT IM BUILDING
const std = @import("std");
const Array = @import("array.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const fixed_arr = Array.FixedArray(u8);
    var arr = try fixed_arr.init(allocator, 5);
    defer arr.deinit();

    try arr.push(1);
    try arr.push(2);
    try arr.push(4);

    try arr.push_at(2, 3);

    std.debug.print("FixedArray: {any}\n", .{arr.items[0..arr.len]});
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
