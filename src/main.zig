const std = @import("std");
const Array = @import("array.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    //
    const allocator = gpa.allocator();
    const fixed_arr = Array.FixedArray(u8);
    var arr = try fixed_arr.init(allocator, 5);
    defer arr.deinit();

    try arr.push(1);
    try arr.push(3);
    try arr.push(4);
    try arr.push_head(8);
    // try arr.left_shift(1);

    // try arr.remove_at(1);

    // std.debug.print("FixedArray: {any}\n", .{arr.items[0..arr.len]});
    // try arr.pop();

    std.debug.print("FixedArray: {any}\n", .{arr.items[0..arr.len]});
}
