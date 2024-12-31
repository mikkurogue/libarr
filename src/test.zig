const std = @import("std");
const libarr = @import("libarr");

test "TEST:: libarr.reverse()" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const fixed_arr = libarr.Array(u8);
    var arr = try fixed_arr.init(allocator, 5);
    defer arr.deinit();

    try arr.push(1);
    try arr.push(2);
    try arr.push(3);
    try arr.push(4);

    std.debug.print("Before reverse: {any}\n", .{arr.items[0..arr.len]});

    try arr.reverse();

    std.debug.print("After reverse: {any}\n", .{arr.items[0..arr.len]});
}

test "TEST:: libarr.push()" {}
