function TableInit(pc)
    TableInitTable(pc.StringTable, pc.StringHashTable,
        STRING_TABLE_SIZE, true)
    pc.StrEmpty = TableStrRegister(pc, "")
end

function TableHash(KeyStr, Len)
    local Hash, Offset
    local KeyCharOrd
    Hash = Len

    Offset = 8
    for Count = 1, Len do
        if Offset > 4 * 8 - 7 then
            Offset = Offset - (4 * 8 - 6)
        end

        KeyCharOrd = string.byte(KeyStr, Count)
        Hash = bxor(Hash, lshift(KeyCharOrd, Offset))

        Count = Count + 1
        Offset = Offset + 7
    end

    return Hash
end

function TableInitTable(Tbl, HashTable, Size, OnHeap)
    Tbl.Size = Size
    Tbl.OnHeap = OnHeap
    Tbl.HashTable = HashTable
end

-- The original idea is that addresses to keys are unique even if
-- contents of two keys are identical
-- Key: AnyValue
function TableSearch(Tbl, Key)
    local HashValue, Entry, AddAt
    HashValue = (Key.Ident % Tbl.Size) + 1
    Entry = Tbl.HashTable[HashValue]

    while Entry ~= nil do
        if (Entry.p.v.Key == Key and not Entry.p.v.HiddenFromSearch) then
            return Entry, nil
        end
        Entry = Entry.Next
    end

    AddAt = HashValue
    return nil, AddAt
end

function TableSet(pc, Tbl, Key, Val, DeclFileName, DeclLine, DeclColumn)
    local AddAt, FoundEntry, NewEntry
    FoundEntry, AddAt = TableSearch(Tbl, Key)
    if FoundEntry == nil then
        NewEntry = VariableAlloc(pc, nil, Tbl.OnHeap)
        NewEntry.p = {
            v = {}, -- ValueEntry
            b = {}  -- BreakpointEntry
        }
        NewEntry.DeclFileName = DeclFileName
        NewEntry.DeclLine = DeclLine
        NewEntry.DeclColumn = DeclColumn
        NewEntry.p.v.Key = Key
        NewEntry.p.v.Val = Val
        NewEntry.Next = Tbl.HashTable[AddAt]
        Tbl.HashTable[AddAt] = NewEntry
        return true
    end

    return false
end

function TableGet(Tbl, Key)
    local FoundEntry
    local Val, DeclFileName, DeclLine, DeclColumn
    FoundEntry, _ = TableSearch(Tbl, Key)
    if FoundEntry == nil then
        return false, nil, nil, nil, nil
    end

    Val = FoundEntry.p.v.Val

    DeclFileName = FoundEntry.DeclFileName
    DeclLine = FoundEntry.DeclLine
    DeclColumn = FoundEntry.DeclColumn

    return true, Val, DeclFileName, DeclLine, DeclColumn
end

function TableDelete(pc, Tbl, Key)
    local HashValue, EntryPtr, DeleteEntry, Val
    local LastEntryPtr, ListDepth
    HashValue = (Key.Ident % Tbl.Size) + 1
    EntryPtr = Tbl.HashTable[HashValue]
    LastEntryPtr = EntryPtr
    ListDepth = 0

    while EntryPtr ~= nil do
        if EntryPtr.p.v.Key == Key then
            DeleteEntry = EntryPtr
            Val = DeleteEntry.p.v.Val
            if ListDepth == 0 then
                Tbl.HashTable[HashValue] = DeleteEntry.Next
            else
                LastEntryPtr.Next = DeleteEntry.Next
            end

            collectgarbage()
            return Val
        end

        LastEntryPtr = EntryPtr
        EntryPtr = EntryPtr.Next
        ListDepth = ListDepth + 1
    end

    return nil
end

function TableSearchIdentifier(Tbl, KeyStr, Len)
    local HashValue, Entry
    local AddAt
    -- Lua index starts from 1
    HashValue = (TableHash(KeyStr, Len) % Tbl.Size) + 1
    Entry = Tbl.HashTable[HashValue]

    while Entry ~= nil do
        --if string.sub(Entry.p.Key.RawValue.Val, 1, Len) == string.sub(KeyStr, 1, Len) then
        if string.sub(Entry.p.Key.RawValue.Val, 1, Len) == string.sub(KeyStr, 1, Len) and
            Len == string.len(Entry.p.Key.RawValue.Val) then
            return Entry, nil
        end
        Entry = Entry.Next
    end

    AddAt = HashValue
    return nil, AddAt
end

-- Return: AnyValue
function TableSetIdentifier(pc, Tbl, IdentStr, IdentLen)
    local AddAt, FoundEntry, NewEntry
    FoundEntry, AddAt = TableSearchIdentifier(Tbl, IdentStr, IdentLen)

    if FoundEntry ~= nil then
        return FoundEntry.p.Key
    else
        -- Allocating the minimum portion of table needed
        NewEntry = {    -- TableEntry
            p = {
                v = {}, -- ValueEntry
                b = {}  -- BreakpointEntry
            },
        }
        NewEntry.p.Key = {    -- AnyValue
            RawValue = {
                Val = string.sub(IdentStr, 1, IdentLen)
            },
            Offset = 0,
            Ident = math.random(1, 0x7FFFFFFF),
            RefOffsets = {},
            Pointer = {}
        }
        --setmetatable(NewEntry.p.Key.Pointer, { __mode = "v" })

        NewEntry.Next = Tbl.HashTable[AddAt]
        Tbl.HashTable[AddAt] = NewEntry
        return NewEntry.p.Key
    end
end

-- Str: string
-- Return: AnyValue
function TableStrRegister2(pc, Str, Len)
    return TableSetIdentifier(pc, pc.StringTable, Str, Len)
end

-- Str: string
-- Return: AnyValue
function TableStrRegister(pc, Str)
    return TableStrRegister2(pc, Str, string.len(Str))
end

function TableStrFree(pc)
    local Entry, NextEntry

    for Count = 1, pc.StringTable.Size do
        Entry = pc.StringTable.HashTable[Count]
        while Entry ~= nil do
            NextEntry = Entry.Next
            Entry.Next = nil
            Entry = NextEntry
        end

        pc.StringTable.HashTable[Count] = nil
        collectgarbage()
    end
end
