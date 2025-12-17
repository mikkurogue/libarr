const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Error = error{ InsufficientCapacity, NoItems, IndexOutOfBounds, NextIndexOutOfBounds, PrevIndexOutOfBounds };

/// An array with a Fixed size given on implementation.
/// exposes methods to dynamically reallocate
pub fn Array(comptime T: type) type {
    return struct {
        allocator: Allocator,
        items: []T,
        len: usize,
        capacity: usize,

        const Self = @This();

        /// initialise a new array, requires an allocator and a size to allocate
        /// size type and byte size is determined by the Array(type) when initialising a new instance
        /// of this module
        pub fn init(allocator: Allocator, capacity: usize) !Array(T) {
            var buffer = try allocator.alloc(T, capacity);

            return .{ .allocator = allocator, .items = buffer[0..capacity], .len = 0, .capacity = capacity };
        }

        /// deinitialise the current array
        /// remember to always call this!
        /// recommended to defer deinit() right after you call .init()!
        pub fn deinit(self: *Self) void {
            self.allocator.free(self.items);
        }

        /// resizes the array to by a "dynamic" value
        /// aka double it
        pub fn resize_dynamic(self: *Self) !void {
            if ((self.len + 1) > self.capacity) {
                var new_buf_items = try self.allocator.alloc(T, self.capacity * 2);
                @memcpy(
                    new_buf_items[0..self.len],
                    self.items,
                );

                self.allocator.free(self.items);
                self.items = new_buf_items;
                self.capacity = self.capacity * 2;
            }
        }

        /// resize the array by adding more size to the capacity
        pub fn resize_abs(self: *Self, add_to_capacity: usize) !void {
            if ((self.len + 1) > self.capacity) {
                var new_buf_items = try self.allocator.alloc(T, self.capacity + add_to_capacity);
                @memcpy(
                    new_buf_items[0..self.len],
                    self.items,
                );

                self.allocator.free(self.items);
                self.items = new_buf_items;
                self.capacity = self.capacity * 2;
            }
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

            // SAFETY: Uninitialize the item so when the len is correctly updated to
            // reflect the pointer
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
        pub fn remove_at(self: *Self, idx: usize) !void {
            if (self.len == 0) {
                return Error.NoItems;
            }

            if (idx >= self.len) {
                return Error.IndexOutOfBounds;
            }

            // Shift elements to the left to fill the gap
            for (idx..self.len - 1) |i| {
                self.items[i] = self.items[i + 1];
            }

            // SAFETY: Mark the last element as undefined
            // since we need to reduce length to accurately reflect the array
            // whilst also making sure the pointer is uninitialized
            self.items[self.len - 1] = undefined;

            // Reduce the length
            self.len -= 1;
        }

        // Advanced array methods

        /// shifts an item in the array to a different index towards the head
        /// this preserves values in the array, so it is more of a circular shift
        /// TODO_ add index to start shift
        pub fn left_shift(self: *Self) !void {
            try rotate_left(T, self);
        }

        /// initialise the iterator struct for array
        pub fn iterator(self: *Self) ArrIterator(T) {
            return ArrIterator(T){
                // only iterate over valid values
                .items = self.items[0..self.len],
            };
        }

        /// see next value in list from a given index
        pub fn peek_next(self: *Self, index: usize) !T {
            if (self.len == 0) {
                return Error.NoItems;
            }

            if (index == self.len) {
                return Error.NextIndexOutOfBounds;
            }

            return self.items[index + 1];
        }

        /// see previous value in list from a given index
        pub fn peek_prev(self: *Self, index: usize) !T {
            if (self.len == 0) {
                return Error.NoItems;
            }

            if (self.len - 1 == -1) {
                return Error.PrevIndexOutOfBounds;
            }

            return self.items[index - 1];
        }

        /// reverse the array
        pub fn reverse(self: *Self) !void {
            if (self.len == 0) {
                return Error.NoItems;
            }

            var start: usize = 0;
            var end: usize = self.len - 1;

            while (start < end) {
                // Swap elements at `start` and `end`
                const temp = self.items[start];
                self.items[start] = self.items[end];
                self.items[end] = temp;

                // Move indices closer
                start += 1;
                end -= 1;
            }
        }

        /// filter the array and remove all instances of {predicate}
        /// from the array.
        /// This is better than js one because we dont replace it with undefined
        /// we just shift things to the left. js is dogwater
        pub fn filter(self: *Self, predicate: T) !void {
            var iter = self.iterator();
            var idx: usize = 0;
            while (idx < self.len) {
                const value: ?T = iter.next();
                if (value == null) break;

                if (value == predicate) {
                    try self.remove_at(idx);
                } else {
                    idx += 1;
                }
            }
        }
    };
}

/// Helper struct to iterate on one of the above arrays
fn ArrIterator(comptime T: type) type {
    return struct {
        items: []const T,
        // needle ?
        index: usize = 0,

        const Self = @This();

        /// Move to the next item in the array
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
fn rotate_left(comptime T: type, arr: *Array(T)) !void {
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
fn rotate_right(comptime T: type, arr: *Array(T)) !void {
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
fn shift_right(comptime T: type, arr: *Array(T)) !void {
    if (arr.len == 0) {
        return Error.NoItems;
    }

    var i: usize = arr.len;
    while (i > 0) : (i -= 1) {
        arr.items[i] = arr.items[i - 1];
    }
}

fn shift_right_from(comptime T: type, arr: *Array(T), idx: usize) !void {
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
/// TODO: think if we want to even re-allocate for Array, or if we just make
/// Array dynamic to be either Fixed or not, so renaming to Array
fn shift_right_reallocate(comptime T: type, arr: *Array(T)) !void {
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
