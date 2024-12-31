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

    // try str_arr.reverse();

    var iter = str_arr.iterator();

    while (true) {
        const v = iter.next();
        if (v == null) break;
        std.debug.print("Value from iterator: {s}\n", .{v.?});
    }
}

test "Test Filter" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const NumArr = libarr.Array(i32);
    var num_arr = try NumArr.init(allocator, 5);
    defer num_arr.deinit();

    try num_arr.push(0);
    try num_arr.push(1);
    try num_arr.push(2);
    try num_arr.push(3);
    try num_arr.push(4);

    std.debug.print("Pre filter {any}\n", .{num_arr.items[0..num_arr.len]});

    try num_arr.filter(3);

    std.debug.print("After filter {any}\n", .{num_arr.items[0..num_arr.len]});
}
