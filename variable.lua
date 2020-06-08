MAX_TMP_COPY_BUF = 256

function VariableInit(pc)
    TableInitTable(pc.GlobalTable, pc.GlobalHashTable, GLOBAL_TABLE_SIZE, true)
    TableInitTable(pc.StringLiteralTable, pc.StringLiteralHashTable, STRING_LITERAL_TABLE_SIZE, true)
end

function VariableFree(pc, Val)
    -- Scan on the stack and remove all references to Val
    -- This ensures Val can be garbage-collected
    --[[
    local StackId = 1
    local StackNode = pc.HeapMemory[StackId]
    while StackNode ~= nil do
        if StackNode == Val then
            pc.HeapMemory[StackId] = {}
        end

        if StackNode.Val == Val.Val then
            pc.HeapMemory[StackId] = {}
        end

        if StackNode.Val ~= nil and Val.Val.RawValue ~= nil then
            if StackNode.Val.RawValue == Val.Val.RawValue then
                pc.HeapMemory[StackId] = {}
            end
        end

        StackId = StackId + 1
        StackNode = pc.HeapMemory[StackId]
    end
    ]]

    if Val.ValOnHeap or Val.AnyValOnHeap then
        if (Val.Typ == pc.FunctionType and
            Val.Val.FuncDef.Intrinsic == nil and 
            Val.Val.FuncDef.Body.ParsingTokens ~= nil) then
            Val.Val.FuncDef.Body.ParsingTokens = nil
        end

        if Val.Typ == pc.MacroType then
            Val.Val.MacroDef.Body.ParsingTokens = nil
        end

        if Val.AnyValOnHeap then
            Val.Val = nil
        end
    end

    -- If Val is not on the stack, then no other references shall exists for Val
    -- Val will be garbage-collected after exiting this function
    Val = nil
    collectgarbage()
end

function VariableTableCleanup(pc, HashTable)
    local Entry, NextEntry
    local ListDepth, LastEntry
    ListDepth = 0

    for Count = 1, HashTable.Size do
        Entry = HashTable.HashTable[Count]
        while Entry ~= nil do
            NextEntry = Entry.Next

            VariableFree(pc, Entry.p.v.Val)
            if Entry.p.v.Val.ValOnHeap then
                Entry.p.v.Val = nil
            end

            if ListDepth == 0 then
                HashTable.HashTable[Count] = nil
            else
                LastEntry.Next = nil
            end

            LastEntry = Entry
            Entry = NextEntry
            ListDepth = ListDepth + 1
        end
    end

    collectgarbage()
end

function VariableCleanup(pc)
    VariableTableCleanup(pc, pc.GlobalTable)
    VariableTableCleanup(pc, pc.StringLiteralTable)
end

function VariableAlloc(pc, Parser, OnHeap)
    if OnHeap then
        return {}
    else
        return HeapAllocStack(pc)
    end
end

function VariableAllocAnyValue(DataSize)
    local RawValue = string.rep("\000", DataSize)
    local NewValue
    NewValue = {    -- AnyValue
        RawValue = {
            Val = RawValue
        },
        Offset = 0,
        Ident = math.random(1, 0x7FFFFFFF),      -- 0 for temporary value on the stack, should be > 0 for defined variables
        RefOffsets = {},
        Pointer = {},
        FuncDef = {     -- FuncDef
            Body = {}   -- ParseState
        },
        MacroDef = {    -- MacroDef
            Body = {}   -- ParseState
        }
    }
    --setmetatable(NewValue.Val.Pointer, { __mode = "v" })

    return NewValue
end

function VariableAllocValueAndData(pc, Parser, DataSize, IsLValue, LValueFrom, OnHeap)
    local RawValue = string.rep("\000", DataSize)
    local NewValue
    NewValue = VariableAlloc(pc, Parser, OnHeap)
    NewValue.Val = {    -- AnyValue
        RawValue = {
            Val = RawValue
        },
        Offset = 0,
        Ident = math.random(1, 0x7FFFFFFF),      -- 0 for temporary value on the stack, should be > 0 for defined variables
        RefOffsets = {},
        Pointer = {},
        FuncDef = {     -- FuncDef
            Body = {}   -- ParseState
        },
        MacroDef = {    -- MacroDef
            Body = {}   -- ParseState
        }
    }
    --setmetatable(NewValue.Val.Pointer, { __mode = "v" })

    NewValue.ValOnHeap = OnHeap
    NewValue.AnyValOnHeap = false
    NewValue.ValOnStack = not OnHeap
    NewValue.IsLValue = IsLValue
    NewValue.LValueFrom = LValueFrom
    if Parser ~= nil then
        NewValue.ScopeID = Parser.ScopeID
    end

    NewValue.OutOfScope = false

    return NewValue
end

function VariableAllocValueFromType(pc, Parser, Typ, IsLValue, LValueFrom, OnHeap)
    local Size, NewValue
    Size = TypeSize(Typ, Typ.ArraySize, false)
    NewValue = VariableAllocValueAndData(pc, Parser, Size, IsLValue, LValueFrom, OnHeap)
    NewValue.Typ = Typ

    return NewValue
end

function VariableAllocValueAndCopy(pc, Parser, FromValue, OnHeap)
    local DType, NewValue
    DType = FromValue.Typ

    NewValue = VariableAllocValueAndData(pc, Parser, 0,
        FromValue.IsLValue, FromValue.LValueFrom, OnHeap)
    NewValue.Typ = DType
    NewValue.Val = PointerCopyAllValues(FromValue.Val, false)

    return NewValue
end

function VariableAllocValueFromExistingData(Parser, Typ, FromValue, IsLValue, LValueFrom)
    local NewValue
    NewValue = VariableAlloc(Parser.pc, Parser, false)
    NewValue.Typ = Typ
    NewValue.Val = FromValue
    NewValue.ValOnHeap = false
    NewValue.AnyValOnHeap = false
    NewValue.ValOnStack = false
    NewValue.IsLValue = IsLValue
    NewValue.LValueFrom = LValueFrom
    NewValue.ScopeID = 0
    NewValue.OutOfScope = false

    return NewValue
end

function VariableAllocValueShared(Parser, FromValue)
    if FromValue.IsLValue then
        return VariableAllocValueFromExistingData(Parser, FromValue.Typ,
            FromValue.Val, FromValue.IsLValue, FromValue)
    else
        return VariableAllocValueFromExistingData(Parser, FromValue.Typ,
            FromValue.Val, FromValue.IsLValue, nil)
    end
end

function VariableRealloc(Parser, FromValue, NewSize)
    local RawValue = string.rep('\000', NewSize)
    FromValue.Val.RawValue.Val = RawValue
end

function VariableScopeBegin(Parser)
    local Entry, NextEntry, HashTable
    local OldScopeID

    if Parser.ScopeID == -1 then
        return -1, nil
    end

    if Parser.pc.TopStackFrameId == 0 then
        HashTable = Parser.pc.GlobalTable
    else
        local TopStackFrame = HeapGetStackNode(Parser.pc, Parser.pc.TopStackFrameId)
        HashTable = TopStackFrame.LocalTable
    end

    OldScopeID = Parser.ScopeID
    Parser.ScopeID = Parser.Line * 0x10000 + Parser.CharacterPos

    for Count = 1, HashTable.Size do
        Entry = HashTable.HashTable[Count]
        while Entry ~= nil do
            NextEntry = Entry.Next
            if (Entry.p.v.Val.ScopeID == Parser.ScopeID and
                Entry.p.v.Val.OutOfScope == true) then
                Entry.p.v.Val.OutOfScope = false
                -- Here the address is altered back
                -- so we set the flag to false
                Entry.p.v.HiddenFromSearch = false
            end
            Entry = NextEntry
        end
    end

    return Parser.ScopeID, OldScopeID
end

function VariableScopeEnd(Parser, ScopeID, PrevScopeID)
    local Entry, NextEntry, HashTable

    if ScopeID == -1 then
        return
    end

    if Parser.pc.TopStackFrameId == 0 then
        HashTable = Parser.pc.GlobalTable
    else
        local TopStackFrame = HeapGetStackNode(Parser.pc, Parser.pc.TopStackFrameId)
        HashTable = TopStackFrame.LocalTable
    end

    for Count = 1, HashTable.Size do
        Entry = HashTable.HashTable[Count]
        while Entry ~= nil do
            NextEntry = Entry.Next
            if (Entry.p.v.Val.ScopeID == Parser.ScopeID and
                Entry.p.v.Val.OutOfScope == false) then
                Entry.p.v.Val.OutOfScope = true
                -- The purpose of author here is to alter the address of
                -- the key so that it cannot be found by the
                -- table search algorithm
                -- But Lua does not support direct addressing, so
                -- we put a flag here so that the search algorithm
                -- will ignore this key when it sees the flag
                Entry.p.v.HiddenFromSearch = true
            end
            Entry = NextEntry
        end
    end

    Parser.ScopeID = PrevScopeID
end

function VariableDefinedAndOutOfScope(pc, Ident)
    local Entry, HashTable

    if pc.TopStackFrameId == 0 then
        HashTable = pc.GlobalTable
    else
        local TopStackFrame = HeapGetStackNode(pc, pc.TopStackFrameId)
        HashTable = TopStackFrame.LocalTable
    end

    for Count = 1, HashTable.Size do
        Entry = HashTable.HashTable[Count]
        while Entry ~= nil do
            if (Entry.p.v.Val.OutOfScope == true and
                Entry.p.v.Key == Ident) then
                return true
            end
            Entry = Entry.Next
        end
    end

    return false
end

function VariableDefine(pc, Parser, Ident, InitValue, Typ, MakeWritable)
    local ScopeID, AssignValue, currentTable, OnHeap
    local FileName, Line, CharacterPos

    if Parser ~= nil then
        ScopeID = Parser.ScopeID
        FileName = Parser.FileName
        Line = Parser.Line
        CharacterPos = Parser.CharacterPos
    else
        ScopeID = -1
        FileName = nil
        Line = 0
        CharacterPos = 0
    end
    if pc.TopStackFrameId == 0 then
        currentTable = pc.GlobalTable
        OnHeap = true
    else
        local TopStackFrame = HeapGetStackNode(pc, pc.TopStackFrameId)
        currentTable = TopStackFrame.LocalTable
        OnHeap = false
    end

    if InitValue ~= nil then
        AssignValue = VariableAllocValueAndCopy(pc, Parser, InitValue, OnHeap)
    else
        AssignValue = VariableAllocValueFromType(pc, Parser, Typ, MakeWritable, nil, OnHeap)
    end

    AssignValue.IsLValue = MakeWritable
    AssignValue.ScopeID = ScopeID
    AssignValue.OutOfScope = false
    --if Debug then
    --    print(Ident.RawValue.Val)
    --end

    if not TableSet(pc, currentTable, Ident, AssignValue, FileName, Line, CharacterPos) then
        ProgramFail(Parser, "'%s' is already defined", Ident.RawValue.Val)
    end

    return AssignValue
end

function VariableDefineButIgnoreIdentical(Parser, Ident, Typ, IsStatic)
    local FirstVisit
    local DeclLine, DeclColumn, DeclFileName, pc, ExistingValue
    local MangledName, RegisteredMangledName
    local Success
    local HashTable
    FirstVisit = false
    pc = Parser.pc

    if TypeIsForwardDeclared(Parser, Typ) then
        ProgramFail(Parser, "type '%t' isn't defined", Typ)
    end

    if IsStatic then
        -- Parser.FileName: AnyValue
        -- TopStackFrame.FunctionName: AnyValue
        MangledName = "/"
        MangledName = string.sub(MangledName .. Parser.FileName.RawValue.Val, 1, LINEBUFFER_MAX)

        if pc.TopStackFrameId ~= 0 then
            local TopStackFrame = HeapGetStackNode(pc, pc.TopStackFrameId)
            MangledName = MangledName .. "/"
            MangledName = string.sub(MangledName .. TopStackFrame.FuncName.RawValue.Val, 1, LINEBUFFER_MAX)
        end

        -- Ident: AnyValue
        MangledName = MangledName .. "/"
        MangledName = string.sub(MangledName .. Ident.RawValue.Val, 1, LINEBUFFER_MAX)
        RegisteredMangledName = TableStrRegister(pc, MangledName)

        Success, ExistingValue, DeclFileName, DeclLine, DeclColumn = TableGet(pc.GlobalTable, RegisteredMangledName)
        if not Success then
            ExistingValue = VariableAllocValueFromType(Parser.pc, Parser, Typ,
                true, nil, true)
            TableSet(pc, pc.GlobalTable, RegisteredMangledName,
                ExistingValue, Parser.FileName, Parser.Line,
                Parser.CharacterPos)
            FirstVisit = true
        end

        VariableDefinePlatformVar(Parser.pc, Parser, Ident.RawValue.Val, ExistingValue.Typ,
            ExistingValue.Val, true)
        return ExistingValue, FirstVisit
    else
        if pc.TopStackFrameId == 0 then
            HashTable = pc.GlobalTable
        else
            local TopStackFrame = HeapGetStackNode(pc, pc.TopStackFrameId)
            HashTable = TopStackFrame.LocalTable
        end

        Success, ExistingValue, DeclFileName, DeclLine, DeclColumn = TableGet(HashTable, Ident)
        if (Parser.Line ~= 0 and Success and
            DeclFileName == Parser.FileName and DeclLine == Parser.Line and
            DeclColumn == Parser.CharacterPos) then
            return ExistingValue, FirstVisit
        else
            return VariableDefine(Parser.pc, Parser, Ident, nil, Typ, true), FirstVisit
        end
    end
end

function VariableDefined(pc, Ident)
    local Success

    if pc.TopStackFrameId ~= 0 then
        local TopStackFrame = HeapGetStackNode(pc, pc.TopStackFrameId)
        Success, _, _, _, _ = TableGet(TopStackFrame.LocalTable, Ident)
    end

    if pc.TopStackFrameId == 0 or not Success then
        Success, _, _, _, _ = TableGet(pc.GlobalTable, Ident)
        if not Success then
            return false
        end
    end

    return true
end

function VariableGet(pc, Parser, Ident)
    local LVal
    local Success

    if pc.TopStackFrameId ~= 0 then
        local TopStackFrame = HeapGetStackNode(pc, pc.TopStackFrameId)
        Success, LVal, _, _, _ = TableGet(TopStackFrame.LocalTable, Ident)
    end

    if pc.TopStackFrameId == 0 or not Success then
        Success, LVal, _, _, _ = TableGet(pc.GlobalTable, Ident)
        if not Success then
            if VariableDefinedAndOutOfScope(pc, Ident) then
                ProgramFail(Parser, "'%s' is out of scope", Ident.RawValue.Val)
            else
                ProgramFail(Parser, "VariableGet Ident: '%s' is undefined", Ident.RawValue.Val)
            end
        end
    end

    return LVal
end

function VariableDefinePlatformVar(pc, Parser, IdentStr, Typ, FromValue, IsWritable)
    local SomeValue
    local HashTable
    local FileName, Line, CharacterPos
    SomeValue = VariableAllocValueAndData(pc, nil, 0, IsWritable,
        nil, true)
    SomeValue.Typ = Typ
    SomeValue.Val = FromValue

    if Parser ~= nil then
        FileName = Parser.FileName
        Line = Parser.Line
        CharacterPos = Parser.CharacterPos
    else
        FileName = nil
        Line = 0
        CharacterPos = 0
    end
    if pc.TopStackFrameId == 0 then
        HashTable = pc.GlobalTable
    else
        local TopStackFrame = HeapGetStackNode(pc, pc.TopStackFrameId)
        HashTable = TopStackFrame.LocalTable
    end

    if (not TableSet(pc, HashTable, TableStrRegister(pc, IdentStr), SomeValue,
        FileName, Line, CharacterPos)) then
        ProgramFail(Parser, "'%s' is already defined", IdentStr)
    end
end

function VariableStackPop(Parser, Var)
    local Success = HeapPopStack(Parser.pc, 1, Var.StackId - 1)

    if not Success then
        ProgramFail(Parser, "stack underrun")
    end
end

function VariableStackFrameAdd(Parser, FuncName, NumParams)
    local NewFrame

    HeapPushStackFrame(Parser.pc)
    NewFrame = HeapAllocStack(Parser.pc)
    if NewFrame == nil then
        ProgramFail("(VariableStackFrameAdd) out of memory")
    end

    -- Initialize the StackFrame structure
    NewFrame.ReturnParser = {}
    NewFrame.LocalTable = {}
    NewFrame.LocalHashTable = {}

    ParserCopy(NewFrame.ReturnParser, Parser)
    NewFrame.FuncName = FuncName
    if NumParams > 0 then
        NewFrame.Parameter = {}
    else
        NewFrame.Parameter = nil
    end
    TableInitTable(NewFrame.LocalTable, NewFrame.LocalHashTable,
        LOCAL_TABLE_SIZE, false)
    NewFrame.PreviousStackFrameId = Parser.pc.TopStackFrameId
    Parser.pc.TopStackFrameId = NewFrame.StackId
end

function VariableStackFramePop(Parser)
    if Parser.pc.TopStackFrameId == 0 then
        ProgramFail(Parser, "stack is empty - can't go back")
    end

    local TopStackFrame = HeapGetStackNode(Parser.pc, Parser.pc.TopStackFrameId)
    ParserCopy(Parser, TopStackFrame.ReturnParser)
    Parser.pc.TopStackFrameId = TopStackFrame.PreviousStackFrameId
    HeapPopStackFrame(Parser.pc)
end

function VariableStringLiteralGet(pc, Ident)
    local LVal
    local Success

    Success, LVal, _, _, _ = TableGet(pc.StringLiteralTable, Ident)
    if Success then
        return LVal
    else
        return nil
    end
end

function VariableStringLiteralDefine(pc, Ident, Val)
    TableSet(pc, pc.StringLiteralTable, Ident, Val, nil, 0, 0)
end

function VariableDereferencePointer(PointerValue)
    local DerefVal, DerefType, DerefOffset, DerefIsLValue

    DerefType = PointerValue.Typ.FromType
    DerefOffset = 0
    DerefIsLValue = true
    DerefVal = PointerDereference(PointerValue.Val)

    return DerefVal, nil, DerefType, DerefOffset, DerefIsLValue
end
