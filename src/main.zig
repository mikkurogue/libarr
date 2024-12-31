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
}
