# libarr - what?

Why? Because im a midwit


## Docs

Currently we have 2 types of Arrays. Only 1 right now has any real support.

These are `Array` and `FixedArray`. The definitions of these will be "clearer" at some point (soon tm).
I will only document the current main working type.

### FixedArray

A FixedArray is an instance of an Array that has a fixed length, and does not allow for reallocation
of memory (capacity). This is essentially a fixed length array, but in size depending on the type of array it is.

```zig
struct FixedArray(T)
```
A Fixed array is a generic struct that takes in a `comptime T` of the type of array it is.

#### Members
`allocator: std.mem.Allocator`

An allocator must be provided to allocate memory.

`items: []T`

A slice of type T provided by the generic.

`len: usize`

The length of the amount of items in the array, also accessible by `items.len`.

`capacity`

The capacity of memory, required by the allocator.

#### Member methods

`init(allocator: Allocator, capacity: usize) !FixedArray(T)`

Function to initialise the array, this allocates and sets the basic default values. Capacity here is the maximum capacity of the array in memory.

`deinit() void`

Destruct function for the allocator to free the memory. Recommended to always defer this once initialised.

`push(val: T) !void` 

Push a new value to the end of the array. If this operation would exceed capacity, then return an error.

`push_head(val: T) !void`

Push a new value to the head (start) of the array. If this operation would exceed capacity, then return an error.

`pop() !void`

Pop the last item out of the array.

`replace_at(idx: u8, val: T) !void`

Replace an item in the array at a given index.

`remove_at(idx: u8) !void`

Remove an item in the array at a given index.

`left_shift() !void`

Move all items 1 place to the left in the array. (experimental)

`iterator() ArrIterator(T)`

Instantiate a new `ArrIterator` of given type. See `ArrIterator` for more.

`peek_next(index: usize) !T`

Given an index, return the value that comes AFTER the given index. Can error `NextIndexOutOfBounds`

`peek_prev(index: usize) !T`
Given an index, return the value that comes BEFORE the given index. Can error `PrevIndexOutOfBounds`

### ArrIterator

An `ArrIterator` is a helper struct to help iterate over the arrays. This iterator does not mutate the array in anyway.

#### Members

`items: []const T`

A constant of the given type of items. 

`index: usize = 0`

The current index we are at in the iterator. This is essentially a private member.

#### Member methods

`next() ?T`

Iterate to the next index. Returns `null` if we are at the end of the array.
