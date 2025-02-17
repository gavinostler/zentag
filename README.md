# zentag

Basic tag related cacher that I wrote in a day. Could be used with [Promise](https://eryn.io/roblox-lua-promise/) for API calls... unsure of its performance.

## Usage

```luau
-- Example with math.random()
local getRandomNumberCache = zentag:unstableCache(function()
    return math.random(1,4)
end, {"number"})

print(getRandomNumberCache()) -- A random value
print(getRandomNumberCache()) -- A cached random value, same as the line directly above.
zentag:revalidateTag("number") -- Invalidates previous value.
print(getRandomNumberCache()) -- A new random value, differs from above.
print(getRandomNumberCache()) -- A cached random value, same as the line directly above.
zentag:revalidateTag("cool") -- Does not invalidate, will throw a warning unless disabled.
print(getRandomNumberCache()) -- A cached random value, same as the line two above.
```

Using `zentag.unstableCache()`, you can cache the values of what is returned from a function when it is requested. Using the return value from the function, you can request the cached value as explained by the comments.

You can also assign multiple tags:
```luau
-- Example with math.random()
local getRandomNumberCache = zentag:unstableCache(function()
    return math.random(1,4)
end, {"number", "random", "interesting"})

-- Any of the below will invalidate the above cached value.
zentag:revalidateTag("number")
zentag:revalidateTag("random")
zentag:revalidateTag("interesting")
zentag:revalidateMultipleTags({"number", "random"})
```

If you attempt to revalidate a tag with no functions assigned to it, you will get something like this in the console:
```
There was an attempt to invalidate a tag with no functions attached to it. This warning will not show up in production.
Tag: {tag}

To disable, run `zentag:disableTagWarning()` at runtime.
```

This warning will disappear in production, but if you'd like to disable it, just run `zentag:disableTagWarning()` once.

## Notes
Please star if you found this nice! I don't really publish anything usually, so this is out of the ordinary for me!
