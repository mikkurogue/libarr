const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Error = error{ InsufficientCapacity, NoItems, IndexOutOfBounds, NextIndexOutOfBounds, PrevIndexOutOfBounds };

/// Basic Array, initial capacity is 100
/// dynamically allocate new memory when required
pub fn Array(comptime T: type) type {
    return struct {
        allocator: Allocator,
        items: []T,
        len: usize,

        const Self = @This();

        pub fn init(allocator: Allocator) !Array(T) {
            var buffer = try allocator.alloc(T, 100);

            return .{ .allocator = allocator, .items = buffer[0..], .len = 0 };
        }

        pub fn push(self: *Self, val: T) void {
            self.items[self.len] = val;
            self.len += 1;
        }

        /// push new item to head of array.
        /// if size exceeds capacity, then reallocate the size
        pub fn push_at(self: *Self, idx: usize, val: T) !void {
            try shift_right_reallocate(T, self, idx);
            self.items[idx] = val;
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

            return .{ .allocator = allocator, .items = buffer[0..capacity], .len = 0, .capacity = capacity };
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
            // TODO: add shift index to start from - this one defaults 0
            // try rotate_right(T, self);
            try shift_right(T, self);
            //insert the new value
            self.items[0] = val;
            self.len += 1;
        }

        /// add a new item of type initialised array value to given index
        /// position of array.
        /// requires space to complete operation in array, otherwise return
        /// InsufficientCapacity error.
        /// This does not re-allocate dynamically
        /// Maybe will make it that last item in array is popped to avoid err
        pub fn push_at(self: *Self, idx: usize, val: T) !void {
            if ((self.len + 1) > self.capacity) {
                return Error.InsufficientCapacity;
            }

            try shift_right_from(T, self, idx);
            self.items[idx] = val;
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

        // remove an item in the array at given index
        // then shift items to the left to re-organise indeces
        pub fn remove_at(self: *Self, idx: u8) !void {
            if (self.len == 0) {
                return Error.NoItems;
            }

            self.items[idx] = undefined;
            self.len -= 1;
        }

        // Advanced array methods
        // TODO: Add these methods

        /// shifts an item in the array to a different index towards the head
        /// this preserves values in the array, so it is more of a circular shift
        /// TODO_ add index to start shift
        pub fn left_shift(self: *Self) !void {
            try rotate_left(T, self);
        }

        pub fn iterator(self: *Self) ArrIterator(T) {
            return ArrIterator(T){
                // only iterate over valid values
                .items = self.items[0..self.len],
            };
        }

        pub fn peek_next(self: *Self, index: usize) !T {
            if (self.len == 0) {
                return Error.NoItems;
            }

            if (index == self.len) {
                return Error.NextIndexOutOfBounds;
            }

            return self.items[index + 1];
        }

        pub fn peek_prev(self: *Self, index: usize) !T {
            if (self.len == 0) {
                return Error.NoItems;
            }

            if (self.len - 1 == -1) {
                return Error.PrevIndexOutOfBounds;
            }

            return self.items[index - 1];
        }
    };
}

fn ArrIterator(comptime T: type) type {
    return struct {
        items: []const T,
        // needle ?
        index: usize = 0,

        const Self = @This();

        pub fn next(self: *Self) ?T {
            if (self.index >= self.items.len) {
                return null;
            }
            const value = self.items[self.index];
            self.index += 1;
            return value;
        }
    };
}

/// TODO: add index to shift from, starting point
fn rotate_left(comptime T: type, arr: *FixedArray(T)) !void {
    if (arr.len == 0) {
        return error.NoItems;
    }

    // Store the first element to wrap it around
    const temp = arr.items[0];

    // Shift elements to the left
    var i: usize = 0;
    while (i < arr.len - 1) : (i += 1) {
        arr.items[i - 1] = arr.items[i];
    }

    // Place the first element at the last index
    arr.items[arr.len - 1] = temp;
}

/// TODO: add index to shift from, starting point
fn rotate_right(comptime T: type, arr: *FixedArray(T)) !void {
    if (arr.len == 0) {
        return Error.NoItems;
    }

    const last_index = arr.len - 1;

    // Store the last element to wrap it around
    const temp = arr.items[last_index];

    // Shift elements to the right
    var i: usize = last_index;
    while (i > 0) : (i -= 1) {
        arr.items[i + 1] = arr.items[i];
    }

    // Place the last element at the first index
    arr.items[0] = temp;
}

/// shift all items from the start of the array 1 position to the right
fn shift_right(comptime T: type, arr: *FixedArray(T)) !void {
    if (arr.len == 0) {
        return Error.NoItems;
    }

    var i: usize = arr.len;
    while (i > 0) : (i -= 1) {
        arr.items[i] = arr.items[i - 1];
    }
}

fn shift_right_from(comptime T: type, arr: *FixedArray(T), idx: usize) !void {
    if (arr.len == 0) {
        return Error.NoItems;
    }

    // if (idx >= arr.len) {
    //     return Error.IndexOutOfBounds;
    // }

    var i: usize = arr.len;
    while (i > idx) : (i -= 1) {
        arr.items[i] = arr.items[i - 1];
    }
}

/// when shifting right, and we may need more space in the array
/// double the capacity in memory for the array
fn shift_right_reallocate(comptime T: type, arr: *FixedArray(T)) !void {
    if ((arr.len + 1) > arr.capacity) {
        var new_buf_items = try arr.allocator.alloc(T, arr.capacity * 2);
        @memcpy(
            new_buf_items[0..arr.len],
            arr.items,
        );

        arr.allocator.free(arr.items);
        arr.items = new_buf_items;
        arr.capacity = arr.capacity * 2;
    }

    const res = shift_right(T, arr) catch |err| {
        std.debug.print("Failed to add to array: {any}", .{err});
        return;
    };
    _ = res;
}
