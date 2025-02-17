--!native
--!strict

local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()

local Iterable = require(script.Iterable)

local CacheTag = {
	_tagWarning = isStudio,
	_tags = {},
	_cache = {},
}

type CacheTagger = {
	_tagWarning: boolean,
	_tags: { [string]: { string } },
	_cache: { [string]: Cache<any> },

	_addToTag: (self: CacheTagger, tag: string, id: string) -> (),

	unstableCache: <T>(self: CacheTagger, f: () -> T, tags: { string }) -> () -> T?,
	revalidateTag: (self: CacheTagger, tag: string) -> (),
	revalidateMultipleTags: (self: CacheTagger, tags: { string }) -> (),
	disableTagWarning: (self: CacheTagger) -> (),
}

type Cache<T> = {
	f: () -> T,
	value: T?,
	invalid: boolean,
}

--[[
    Assigns a tag to a cache id.
]]
function CacheTag._addToTag(self: CacheTagger, tag: string, id: string)
	if not self._tags[tag] then
		self._tags[tag] = {}
	end
	table.insert(self._tags[tag], id)
end

--[[
    Since the behavior of the garbage collection of lua will not delete a cache if it is no longer used, this is considered unsafe.
]]
function CacheTag.unstableCache<T>(self: CacheTagger, f: () -> T, tags: { string }): () -> T?
	if typeof(f) ~= "function" then
		error(`AssertionError: f must be a function, got {typeof(f)}`)
	end
	if typeof(tags) ~= "table" then
		error(`AssertionError: tags must be a table of strings, got {typeof(tags)}`)
	end

	local tagsIterable = Iterable(tags)

	tagsIterable:forEach(function(tag: string, index: number)
		if typeof(tag) ~= "string" then
			error(`AssertionError: tags must be a table of strings, got {typeof(tag)} at index {index}`)
		end
	end)

	-- Done seprately so if the type check fails it doesnt fuck up everything
	tagsIterable:forEach(function(tag: string)
		self:_addToTag(tag, tostring(f))
	end)

	self._cache[tostring(f)] = {
		f = f,
		invalid = true,
	}
	return function()
		local cached = self._cache[tostring(f)] :: Cache<T>
		if cached.invalid then
			cached.invalid, cached.value = pcall(f)
			cached.invalid = not cached.invalid
			if cached.invalid and isStudio then
				warn(
					`Cache was invalid but trying to revalidate resulted in something failing. Function: {cached.f}\n\n{cached.value}`
				)
			end
		end
		return cached.value
	end
end

--[[
    Invalidator, will only request new value upon use
]]
function CacheTag.revalidateTag(self: CacheTagger, tag: string)
	if typeof(tag) ~= "string" then
		error(`AssertionError: tag must be a string, got {typeof(tag)}`)
	end

	if not self._tags[tag] then
		if self._tagWarning then
			warn(
				`There was an attempt to invalidate a tag with no functions attached to it. This warning will not show up in production.`
					.. `\nTag: {tag}\n\nTo disable, run \`CacheTagger.disableTagWarning()\` at runtime.`
			)
		end
		return
	end

	Iterable(self._tags[tag]):forEach(function(currentValue: string)
		self._cache[currentValue].invalid = true
	end)
end

--[=[
	Revalidates multiple tags.

	@param tags {string}
]=]
function CacheTag.revalidateMultipleTags(self: CacheTagger, tags: { string })
	Iterable(tags):forEach(function(tag: string)
		self:revalidateTag(tag)
	end)
end

function CacheTag.disableTagWarning(self: CacheTagger)
	self._tagWarning = false
end

return CacheTag :: CacheTagger
