const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Error = error{ InsufficientCapacity, NoItems };

/// Basic Array, no fixed length or capacity. The capacity here will be
/// calculated dynamically.
pub fn Array(comptime T: type) type {
    return struct {
        allocator: Allocator,
        items: []T,
        len: usize,

        const Self = @This();

        pub fn init(allocator: Allocator) !Array(T) {
            var buffer = try allocator.alloc(T);

            return .{ .allocator = allocator, .items = buffer[0..], .len = 0 };
        }

        pub fn push(self: *Self, val: T) void {
            self.items[self.len] = val;
            self.len += 1;
        }

        pub fn prepend(self: *Self, val: T) void {
            // shift elements 1 place to the right each
            var i: usize = self.len;
            while (i > 0) : (i -= 1) {
                self.items[i] = self.items[i - 1];
            }

            //insert the new value
            self.items[0] = val;
            self.len += 1;
        }

        pub fn pop(self: *Self) void {
            if (self.len == 0) return;

            self.items[self.len - 1] = undefined;
            self.len -= 1;
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.items);
        }
    };
}

/// An array with a Fixed size given on implementation.
pub fn FixedArray(comptime T: type) type {
    return struct {
        allocator: Allocator,
        items: []T,
        len: usize,
        capacity: usize,

        const Self = @This();

        /// initialise a new array, requires an allocator and a size to allocate
        /// size type and byte size is determined by the FixedArray(type) when initialising a new instance
        /// of this module
        pub fn init(allocator: Allocator, capacity: usize) !FixedArray(T) {
            var buffer = try allocator.alloc(T, capacity);

            return .{ .allocator = allocator, .items = buffer[0..], .len = 0, .capacity = capacity };
        }

        /// deinitialise the current array
        /// remember to always call this!
        /// recommended to defer deinit() right after you call .init()!
        pub fn deinit(self: *Self) void {
            self.allocator.free(self.items);
        }

        // Basic array methods

        /// add a new item of type initialised array value to end of array
        /// requires there to be space in the capacity of the array
        /// otherwise return InsufficientCapacity error
        pub fn push(self: *Self, val: T) !void {
            if ((self.len + 1) > self.capacity) {
                return Error.InsufficientCapacity;
            }

            self.items[self.len] = val;
            self.len += 1;
        }

        /// add a new item of type initialised array value to start of array
        /// requires there to be space in the capacity of the array
        /// otherwise return InsufficientCapacity error
        pub fn push_head(self: *Self, val: T) !void {
            if ((self.len + 1) > self.capacity) {
                return Error.InsufficientCapacity;
            }

            // shift elements 1 place to the right each
            var i: usize = self.len;
            while (i > 0) : (i -= 1) {
                self.items[i] = self.items[i - 1];
            }

            //insert the new value
            self.items[0] = val;
            self.len += 1;
        }

        /// remove last item of the array
        pub fn pop(self: *Self) !void {
            if (self.len == 0) {
                return Error.NoItems;
            }

            self.items[self.len - 1] = undefined;
            self.len -= 1;
        }

        /// replace an item in the array at given index
        /// with an item of type initialised array value
        pub fn replace_at(self: *Self, idx: u8, val: T) !void {
            if (self.len == 0) {
                return Error.NoItems;
            }

            self.items[idx] = val;
        }

        // Advanced array methods
        // TODO: Add these methods
    };
}
