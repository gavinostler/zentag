--!native
--!strict

-- guess this is here, never really pushed out to the public

local Iterable = {
	_tbl = {} :: {},
}
Iterable.__index = Iterable

type IterableImpl<T> = {
	t: { T },

	map: <A>(self: IterableImpl<T>, func: (currentValue: T, index: number) -> A) -> { A },
	forEach: (self: IterableImpl<T>, func: (currentValue: T, index: number) -> ()) -> nil,
	append: (self: IterableImpl<T>, value: T) -> (),
}

type Iterable<T> = typeof(setmetatable({} :: Iterable<T>, {})) & IterableImpl<T>

function createIterable<T>(tbl: { T })
	local newCache = setmetatable({ t = tbl }, Iterable)

	return newCache :: Iterable<T>
end

function Iterable.map<T, A>(self: IterableImpl<T>, func: (currentValue: T, index: number) -> A): { A }
	local mappedTable = {} :: { A }

	for index, item in self.t do
		mappedTable[index] = func(item, index)
	end

	return createIterable(mappedTable)
end

function Iterable.forEach<T>(self: IterableImpl<T>, func: (currentValue: T, index: number) -> ()): nil
	for index, item in self.t do
		func(item, index)
	end
	return
end

function Iterable.append<T>(self: IterableImpl<T>, value: T): ()
	table.insert(self.t, value)
end

return createIterable
