# libarr - what?

Why? Because im a midwit. This is a "library" I am building to learn some Zig constructs.

This project is not at all usable for any production environment or product, so if you do decide that the features/functions here are somewhat usable then do use this at your own risk.

As this is not a package or anything official, you can just copy and paste the code. It is "unlicensed" and therefore I do not request any type of commendation for usage.

You can however feel free to link to this repository if you feel so inclined, but again; that's completely optional and in all honesty not important to me.

I am however looking for pointers, tips, tricks or any resource to help me make this somewhat usable maybe in the future, or at least as a reference to upcoming projects.


## Docs


### Array

A Array is an instance of an Array that has a fixed size.

This is essentially a fixed length array, but in size depending on the type of array it is.

There are ways to re-allocate more capacity for this array.

```zig
struct Array(T)
```
An array is a generic struct that takes in a `comptime T` of the type of array it is.

#### Members
```zig
allocator: std.mem.Allocator
```

An allocator must be provided to allocate memory.

```zig
items: []T
```

A slice of type T provided by the generic.

```zig
len: usize
```

The length of the amount of items in the array, also accessible by `items.len`.

```zig
capacity: u8
```

The capacity of memory, required by the allocator.

#### Member methods

```zig
init(allocator: Allocator, capacity: usize) !Array(T)
```

Function to initialise the array, this allocates and sets the basic default values. Capacity here is the maximum capacity of the array in memory.

```zig
deinit() !void
```

Destruct function for the allocator to free the memory. Recommended to always defer this once initialised.

```zig
resize_dynamic() !void
```

Resize the array dynamically by doubling the capacity.

```zig
resize_abs(add_to_capacity: usize) !void
```

Resize the array based on new capacity to add to existing capacity.


```zig
push(val: T) !void
```

Push a new value to the end of the array. If this operation would exceed capacity, then return an error.

```zig
push_head(val: T) !void
```

Push a new value to the head (start) of the array. If this operation would exceed capacity, then return an error.

```zig
pop() !void
```

Pop the last item out of the array.

```zig
replace_at(idx: u8, val: T) !void
```

Replace an item in the array at a given index.

```zig
remove_at(idx: u8) !void
```

Remove an item in the array at a given index.

```zig
left_shift() !void
```

Move all items 1 place to the left in the array. (experimental)

```zig
iterator() ArrIterator(T)
```

Instantiate a new `ArrIterator` of given type. See `ArrIterator` for more.

```zig
peek_next(index: usize) !T
```

Given an index, return the value that comes AFTER the given index. Can error `NextIndexOutOfBounds`

```zig
peek_prev(index: usize) !T
```

Given an index, return the value that comes BEFORE the given index. Can error `PrevIndexOutOfBounds`

### ArrIterator

An `ArrIterator` is a helper struct to help iterate over the arrays. This iterator does not mutate the array in anyway.

#### Members

```zig
items: []const T
```

A constant of the given type of items. 

```zig
index: usize = 0
```

The current index we are at in the iterator. This is essentially a private member.

#### Member methods

```zig
next() ?T
```

Iterate to the next index. Returns `null` if we are at the end of the array.
