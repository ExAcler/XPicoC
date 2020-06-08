--[[
    pointer.lua - Lua implementation of PicoC AnyValue type
]]

--[[
/* Extensions to definition of AnyValue type in Lua-PicoC */

struct RawValue {
    string Val
}

struct AnyValue {
    // Normal variable excluding pointer array
    struct RawValue *RawValue;      // Value of variable
    unsigned int Offset;            // For dereferencing
    unsigned int Ident;             // Identity of the value of the variable
                                    // We need this to void all pointers to a value
                                    // if the variable it attaches to
                                    // is deleted (gone out of scope)
                                    // to actually free value memory in Lua

    // -- Or --
    // Pointer or array of pointers
    struct RawValue *RawValue;      // Value of the pointer
                                    // Contains (every 4 bytes) the identity
                                    // of the variable that the pointer(s)
                                    // reference
    unsigned int Offset;
    unsigned int Ident;
    unsigned int RefOffsets[];      // Dictionary of pointer offsets of each
                                    // variable member
                                    // The key is the identity of corresponding
                                    // variable member
                                    // Merged if a struct or union contains
                                    // multiple pointers
    struct AnyValue *Pointers[];    // Dictionary of pointers to every
                                    // variable member
}
]]

Multiplier = {0x1, 0x100, 0x10000, 0x1000000}

-- Assign an integer value (-2147483648 to 2147483647 or 0 to 4294967295) to a variable
-- at the current offset, handles overflow cases
-- DestValue: AnyValue
function PointerSetSignedOrUnsignedInt(DestValue, FromInt)
    local Result
    local RawValue = DestValue.RawValue.Val
    local Offset = DestValue.Offset
    local byte1, byte2, byte3, byte4
    local ResultRawValue

    if FromInt < 0 then
        FromInt = 0x100000000 -
            ((-FromInt) - 0x100000000 * math.floor((-FromInt) / 0x100000000))
    else
        FromInt = FromInt - 0x100000000 * math.floor(FromInt / 0x100000000)
    end

    byte4 = math.floor(FromInt / 0x1000000)
    FromInt = FromInt - 0x1000000 * byte4
    byte3 = math.floor(FromInt / 0x10000)
    FromInt = FromInt - 0x10000 * byte3
    byte2 = math.floor(FromInt / 0x100)
    FromInt = FromInt - 0x100 * byte2
    byte1 = FromInt

    Result = string.char(byte1) .. string.char(byte2) ..
        string.char(byte3) .. string.char(byte4)

    RawValue = string.sub(RawValue, Offset + 1, Offset + 4)
    RawValue = string.sub(Result, 1, string.len(RawValue))

    ResultRawValue = string.sub(DestValue.RawValue.Val, 1, Offset) ..
        RawValue ..
        string.sub(DestValue.RawValue.Val, Offset + string.len(RawValue) + 1)

    DestValue.RawValue.Val = ResultRawValue
end

-- Assign a short integer value (-32768 to 32767 or 0 to 65535) to a variable
-- at the current offset, handles overflow cases
-- DestValue: AnyValue
function PointerSetSignedOrUnsignedShort(DestValue, FromInt)
    local Result
    local RawValue = DestValue.RawValue.Val
    local Offset = DestValue.Offset
    local byte1, byte2
    local ResultRawValue

    if FromInt < 0 then
        FromInt = 0x10000 -
            ((-FromInt) - 0x10000 * math.floor((-FromInt) / 0x10000))
    else
        FromInt = FromInt - 0x10000 * math.floor(FromInt / 0x10000)
    end

    byte2 = math.floor(FromInt / 0x100)
    FromInt = FromInt - 0x100 * byte2
    byte1 = FromInt

    Result = string.char(byte1) .. string.char(byte2)

    RawValue = string.sub(RawValue, Offset + 1, Offset + 2)
    RawValue = string.sub(Result, 1, string.len(RawValue))

    ResultRawValue = string.sub(DestValue.RawValue.Val, 1, Offset) ..
        RawValue ..
        string.sub(DestValue.RawValue.Val, Offset + string.len(RawValue) + 1)
    DestValue.RawValue.Val = ResultRawValue
end

-- Assign a one-byte value (-128 to 127 or 0 to 255) to a variable
-- at the current offset, handles overflow cases
-- DestValue: AnyValue
function PointerSetSignedOrUnsignedChar(DestValue, FromInt)
    local Result
    local RawValue = DestValue.RawValue.Val
    local Offset = DestValue.Offset
    local byte1

    if FromInt < 0 then
        FromInt = 0x100 -
            ((-FromInt) - 0x100 * math.floor((-FromInt) / 0x100))
    else
        FromInt = FromInt - 0x100 * math.floor(FromInt / 0x100)
    end
    byte1 = FromInt

    Result = string.char(byte1)

    if string.len(RawValue) > Offset then
        RawValue = Result
        DestValue.RawValue.Val = string.sub(DestValue.RawValue.Val, 1, Offset) ..
            RawValue ..
            string.sub(DestValue.RawValue.Val, Offset + 2)
    end
end

-- Assign a double precision FP value to a variable at the current offset
-- Converts FP into internal floating representation (IEEE 754)
-- DestValue: AnyValue
function PointerSetFP(DestValue, FromFP)
    local RawValue = DestValue.RawValue.Val
    local Offset = DestValue.Offset
    local FromFPAbs, IntegralPart, FractionalPart
    local NShift
    local R, Q
    local TotalBinLen
    local Exponent
    local BiasedExponent
    local ResultBits, NBits, Result, Byte
    local ResultRawValue

    -- Value is 0
    -- This is the minimum number that FP64 can represent
    if FromFP == 0 or math.abs(FromFP) < 2.225073858507e-308 then
        DestValue.RawValue.Val = "\000\000\000\000\000\000\000\000"
        return
    end

    -- Value is infinity
    -- This is the maximum number that FP64 can represent
    if math.abs(FromFP) > 1.797693134862e308 then
        if FromFP >= 0 then
            DestValue.RawValue.Val = "\000\000\000\000\000\000\240\127"
        else
            DestValue.RawValue.Val = "\000\000\000\000\000\000\240\255"
        end
        return
    end

    FromFPAbs = math.abs(FromFP)

    -- The binary exponent
    Exponent = math.floor(math.log(FromFPAbs) / math.log(2))

    -- Set appropriate rounding so that loops won't waste time on preceding or succeeding 0's
    if math.floor(FromFPAbs) > 0 then
        NShift = Exponent - 52
        if NShift < 0 then
            NShift = 0
        end
        FromFPAbs = FromFPAbs / 2 ^ NShift
    else
        NShift = -(Exponent + 1)
        FromFPAbs = FromFPAbs * 2 ^ NShift
    end

    IntegralPart = math.floor(FromFPAbs)
    FractionalPart = FromFPAbs - IntegralPart
    ResultBits = {}

    -- Take the binary number of integral part
    Q = IntegralPart
    while Q > 0 do
        R = Q % 2
        Q = math.floor(Q / 2)
        table.insert(ResultBits, 1, R)
    end

    TotalBinLen = #ResultBits

    Q = FractionalPart
    -- Take the binary number of fractional part
    -- Save iterations by taking the fewest steps possible
    while Q > 0 and TotalBinLen <= 53 do
        R = math.floor(Q * 2)
        Q = Q * 2 - R
        table.insert(ResultBits, R)

        TotalBinLen = TotalBinLen + 1
    end

    -- Remove preceding 1
    if ResultBits[1] == 1 then
        table.remove(ResultBits, 1)
    end

    -- Bit padding
    TotalBinLen = #ResultBits
    if TotalBinLen > 52 then
        while TotalBinLen > 52 do
            table.remove(ResultBits)
            TotalBinLen = TotalBinLen - 1
        end
    else
        while TotalBinLen < 52 do
            table.insert(ResultBits, 0)
            TotalBinLen = TotalBinLen + 1
        end
    end

    BiasedExponent = 1023 + Exponent
    if BiasedExponent > 2047 then
        -- Overflow, infinity
        if FromFP >= 0 then
            DestValue.RawValue.Val = "\000\000\000\000\000\000\240\127"
        else
            DestValue.RawValue.Val = "\000\000\000\000\000\000\240\255"
        end
        return
    elseif BiasedExponent < 0 then
        -- Overflow, 0
        if FromFP >= 0 then
            DestValue.RawValue.Val = "\000\000\000\000\000\000\000\000"
        else
            DestValue.RawValue.Val = "\000\000\000\000\000\000\000\128"
        end
        return
    end

    if FromFP >= 0 then
        table.insert(ResultBits, 1, 0)
    else
        table.insert(ResultBits, 1, 1)
    end

    Q = BiasedExponent
    NBits = 0
    while Q > 0 do
        R = Q % 2
        Q = math.floor(Q / 2)
        table.insert(ResultBits, 2, R)
        NBits = NBits + 1
    end
    for j = 1, 11 - NBits do
        table.insert(ResultBits, 2, 0)
    end

    Result = ""
    for i = 1, 64, 8 do
        Byte = 0
        for j = 0, 7 do
            Byte = Byte + 2 ^ (7 - j) * ResultBits[i + j]
        end
        Result = string.char(Byte) .. Result
    end

    RawValue = string.sub(RawValue, Offset + 1, Offset + 8)
    RawValue = string.sub(Result, 1, string.len(RawValue))

    ResultRawValue = string.sub(DestValue.RawValue.Val, 1, Offset) ..
        RawValue ..
        string.sub(DestValue.RawValue.Val, Offset + string.len(RawValue) + 1)
    DestValue.RawValue.Val = ResultRawValue
end

function PointerGetSignedInt(FromValue)
    local Result = PointerGetUnsignedInt(FromValue)

    if Result > 0x7FFFFFFF then
        --Result = Result - 0xFFFFFFFF
        Result = Result - 0x100000000
    end

    return Result
end

function PointerGetUnsignedInt(FromValue)
    local RawValue = FromValue.RawValue.Val
    local Offset = FromValue.Offset
    local Char, Byte
    local Result = 0
    --print("Enter")

    for i = Offset + 1, Offset + 4 do
        Char = string.sub(RawValue, i, i)
        if Char == "" then
            Byte = 0
        else
            Byte = string.byte(Char)
        end

        Result = Result + Multiplier[i - Offset] * Byte
        --Result = Result + 2 ^ (8 * (i - Offset - 1)) * Byte
    end

    return Result
end

function PointerGetSignedShort(FromValue)
    local Result = PointerGetUnsignedShort(FromValue)

    if Result > 0x7FFF then
        --Result = Result - 0xFFFF
        Result = Result - 0x10000
    end

    return Result
end

function PointerGetUnsignedShort(FromValue)
    local RawValue = FromValue.RawValue.Val
    local Offset = FromValue.Offset
    local Char, Byte
    local Result = 0

    for i = Offset + 1, Offset + 2 do
        Char = string.sub(RawValue, i, i)
        if Char == "" then
            Byte = 0
        else
            Byte = string.byte(Char)
        end

        Result = Result + Multiplier[i - Offset] * Byte
        --Result = Result + 2 ^ (8 * (i - Offset - 1)) * Byte
    end

    return Result
end

function PointerGetSignedChar(FromValue)
    local Result = PointerGetUnsignedChar(FromValue)

    if Result > 0x7F then
        --Result = Result - 0xFF
        Result = Result - 0x100
    end

    return Result
end

function PointerGetUnsignedChar(FromValue)
    local RawValue = FromValue.RawValue.Val
    local Offset = FromValue.Offset
    local Char
    local Result

    Char = string.sub(RawValue, Offset + 1, Offset + 1)
    if Char == "" then
        Result = 0
    else
        Result = string.byte(Char)
    end

    return Result
end

-- Convert IEEE 754 representation to double precision FP
-- FromValue: AnyValue
function PointerGetFP(FromValue)
    local RawValue, Offset
    local ValueBits, Char, Byte
    local Q, R, NBits
    local ValueSign, BiasedExponent, Exponent, FractionalPart
    RawValue = FromValue.RawValue.Val
    Offset = FromValue.Offset
    ValueBits = {}

    RawValue = string.sub(RawValue, Offset + 1, Offset + 8)
    if string.len(RawValue) ~= 8 then
        -- Incomplete FP representation, set result to 0
        -- Debug only
        return 0
    end

    for i = 0, 7 do
        Char = string.sub(RawValue, 8 - i, 8 - i)
        if Char == "" then
            Byte = 0
        else
            Byte = string.byte(Char)
        end

        Q = Byte
        NBits = 0
        while Q > 0 do
            R = Q % 2
            Q = math.floor(Q / 2)
            table.insert(ValueBits, 1 + 8 * i, R)
            NBits = NBits + 1
        end
        for j = 1, 8 - NBits do
            table.insert(ValueBits, 1 + 8 * i, 0)
        end
    end

    if ValueBits[1] == 0 then
        ValueSign = 1
    else
        ValueSign = -1
    end

    BiasedExponent = 0
    for i = 2, 12 do
        BiasedExponent = BiasedExponent + 2 ^ (10 - (i - 2)) * ValueBits[i]
    end
    Exponent = BiasedExponent - 1023

    FractionalPart = 0
    for i = 13, 64 do
        FractionalPart = FractionalPart + 2 ^ (-(i - 12)) * ValueBits[i]
    end

    -- Value is 0
    if BiasedExponent == 0 and FractionalPart == 0 then
        return 0
    end

    -- Value is infinity
    if BiasedExponent == 2047 and FractionalPart == 0 then
        return math.huge
    end

    return ValueSign * 2 ^ Exponent * (1 + FractionalPart)
end

-- Get the C-style length of string in a char array
-- FromValue: AnyValue, must be a char array
function PointerStringLen(FromValue)
    local Offset = FromValue.Offset
    local RawValue = string.sub(FromValue.RawValue.Val, 1 + Offset)

    local i = string.find(RawValue, '\0')
    if i then
        return i - 1
    else
        return string.len(RawValue)
    end
end

function PointerGetString(FromValue)
    local Offset = FromValue.Offset
    local Len = PointerStringLen(FromValue)
    return string.sub(FromValue.RawValue.Val, 1 + Offset, 1 + Offset + Len - 1)
end

-- Copy a value from SourceVal to DestVal
-- DestVal, SourceVal: AnyValue; DestTyp: ValueType
-- DestTyp can only be arrays, structs and unions and have identical definitions
function PointerCopyValue(DestVal, SourceVal, DestTyp)
    local CopyRefs = false
    if DestTyp.Base == BaseType.TypeStruct or DestTyp.Base == BaseType.TypeUnion then
        CopyRefs = true
    end

    if DestTyp.Base == BaseType.TypeArray then
        local FromType = DestTyp.FromType
        while (FromType ~= nil and (FromType.Base == BaseType.TypeArray or
            FromType.Base == BaseType.TypePointer)) do
            if FromType == BaseType.TypePointer then
                CopyRefs = true
                break
            end
            FromType = FromType.FromType
        end
    end

    local Len = TypeSize(DestTyp, DestTyp.ArraySize, false)
    local SourceRawValue = SourceVal.RawValue.Val
    local SourceOffset = SourceVal.Offset
    local DestRawValue = DestVal.RawValue.Val
    local DestOffset = DestVal.Offset
    local DestLen = string.len(DestRawValue)

    if CopyRefs then
        local PointerPosList = {}
        if DestTyp.Base == BaseType.TypeStruct or DestTyp.Base == BaseType.TypeUnion then
            PointerGetPointerPos(DestTyp, 1, PointerPosList)
        else
            table.insert(PointerPosList, {
                From = 1,
                To = Len
            })
        end

        -- Remove old references
        for _, v in ipairs(PointerPosList) do
            local From = DestOffset + v.From
            local To = DestOffset + v.To
            for j = From, To, 4 do
                local IdentTo = string.sub(DestRawValue, j, j + 3)
                DestVal.RefOffsets[IdentTo] = nil
                DestVal.Pointer[IdentTo] = nil
            end
        end

        -- Assign new references
        for _, v in ipairs(PointerPosList) do
            local From = SourceOffset + v.From
            local To = SourceOffset + v.To
            for j = From, To, 4 do
                local IdentTo = string.sub(SourceRawValue, j, j + 3)
                DestVal.RefOffsets[IdentTo] = SourceVal.RefOffsets[IdentTo]
                DestVal.Pointer[IdentTo] = SourceVal.Pointer[IdentTo]
            end
        end
    end

    SourceRawValue = string.sub(SourceRawValue, 
        SourceOffset + 1, SourceOffset + MIN(Len, DestLen - DestOffset))
    local SourceLen = string.len(SourceRawValue)

    DestRawValue = string.sub(DestRawValue, 1, DestOffset) ..
        SourceRawValue .. string.sub(DestRawValue,
            DestOffset + SourceLen + 1)
    DestVal.RawValue.Val = DestRawValue
end

-- Recursively get all positions of pointers in a struct or union
function PointerGetPointerPos(StructTyp, InitPos, PointerPosList)
    for i = 1, StructTyp.Members.Size do
        local Entry = StructTyp.Members.HashTable[i]
        while Entry ~= nil do
            local MemberTyp = Entry.p.v.Val.Typ
            local MemberOffset = PointerGetSignedInt(Entry.p.v.Val.Val)

            if MemberTyp.Base == BaseType.TypePointer then
                table.insert(PointerPosList, {
                    From = InitPos + MemberOffset,
                    To = InitPos + MemberOffset + 4 - 1})
            elseif MemberTyp.Base == BaseType.TypeArray then
                local FromType = MemberTyp.FromType
                local Size = TypeSize(MemberTyp, MemberTyp.ArraySize, false)
                while (FromType ~= nil and (FromType.Base == BaseType.TypeArray or
                    FromType.Base == BaseType.TypePointer)) do
                    if FromType == BaseType.TypePointer then
                        table.insert(PointerPosList, {
                            From = InitPos + MemberOffset,
                            To = InitPos + MemberOffset + Size - 1
                        })
                        break
                    end
                    FromType = FromType.FromType
                end
            elseif MemberTyp.Base == BaseType.TypeStruct or MemberTyp.Base == BaseType.TypeUnion then
                PointerGetPointerPos(MemberTyp, InitPos + MemberOffset, PointerPosList)
            end

            Entry = Entry.Next
        end
    end
end

-- Generate a complete copy of SourceVal
-- SourceVal: AnyValue
function PointerCopyAllValues(SourceVal, Compact)
    local DestVal = {}
    DestVal.RawValue = {}
    DestVal.RawValue.Val = SourceVal.RawValue.Val

    DestVal.Ident = SourceVal.Ident
    DestVal.Offset = SourceVal.Offset

    DestVal.RefOffsets = {}
    for k in pairs(SourceVal.RefOffsets) do
        DestVal.RefOffsets[k] = SourceVal.RefOffsets[k]
    end

    DestVal.Pointer = {}
    for k in pairs(SourceVal.Pointer) do
        DestVal.Pointer[k] = SourceVal.Pointer[k]
    end
    --setmetatable(DestVal.Pointer, { __mode = "v" })

    if not Compact then
        DestVal.Typ = SourceVal.Typ

        if SourceVal.FuncDef ~= nil then
            DestVal.FuncDef = {}
            DestVal.FuncDef.ReturnType = SourceVal.FuncDef.ReturnType
            DestVal.FuncDef.NumParams = SourceVal.FuncDef.NumParams
            DestVal.FuncDef.VarArgs = SourceVal.FuncDef.VarArgs
            DestVal.FuncDef.ParamType = SourceVal.FuncDef.ParamType
            DestVal.FuncDef.ParamName = SourceVal.FuncDef.ParamName
            DestVal.FuncDef.Intrinsic = SourceVal.FuncDef.Intrinsic
            DestVal.FuncDef.Body = {}
            ParserCopy(DestVal.FuncDef.Body, SourceVal.FuncDef.Body)
        end

        if SourceVal.MacroDef ~= nil then
            DestVal.MacroDef = {}
            DestVal.MacroDef.NumParams = SourceVal.MacroDef.NumParams
            DestVal.MacroDef.ParamName = SourceVal.MacroDef.ParamName
            DestVal.MacroDef.Body = {}
            ParserCopy(DestVal.MacroDef.Body, SourceVal.FuncDef.Body)
        end
    end

    return DestVal
end

-- Copy the content of pointer FromValue to DestValue
-- DestValue, FromValue: AnyValue
-- The type of FromValue and DestValue can only be pointers
function PointerCopyPointer(DestValue, FromValue)
    local FromOffset = FromValue.Offset
    local DestOffset = DestValue.Offset

    local FromRawValue = FromValue.RawValue.Val
    local DestRawValue = DestValue.RawValue.Val
    local DestLen = string.len(DestRawValue)
    local FormerDestIdentTo = string.sub(DestRawValue, 1 + DestOffset, 4 + DestOffset)

    FromRawValue = string.sub(FromRawValue,
        FromOffset + 1, FromOffset + MIN(4, DestLen - DestOffset))
    local SourceLen = string.len(FromRawValue)

    -- Trying to copy a pointer identity at an unexpected location
    -- This should never happen
    assert(SourceLen == 4 or SourceLen == 0, "PointerCopyPointer: SourceLen is not 4 or 0")

    if SourceLen == 0 then
        return
    end

    local RefOffset = FromValue.RefOffsets[FromRawValue]
    local Pointer = FromValue.Pointer[FromRawValue]

    if RefOffset == nil or Pointer == nil then
        return
    end
    --assert(RefOffset ~= nil and Pointer ~= nil, "PointerCopyPointer: No reference in pointer")

    DestRawValue = string.sub(DestRawValue, 1, DestOffset) ..
        FromRawValue .. string.sub(DestRawValue,
            DestOffset + SourceLen + 1)

    DestValue.RawValue.Val = DestRawValue

    -- Remove former reference
    DestValue.RefOffsets[FormerDestIdentTo] = nil
    DestValue.Pointer[FormerDestIdentTo] = nil

    -- Assign new reference
    DestValue.RefOffsets[FromRawValue] = RefOffset
    DestValue.Pointer[FromRawValue] = Pointer
end

-- Derive a new value to NewPointerValue, all fields except Offset are linked to FromPointerValue
-- NewPointerValue, FromPointerValue: AnyValue
-- The type of FromPointerValue can only be arrays, structs or unions
function PointerDeriveNewValue(NewPointerValue, FromPointerValue, KeepIdent)
    NewPointerValue.Offset = FromPointerValue.Offset
    NewPointerValue.RawValue = FromPointerValue.RawValue
    if KeepIdent then
        NewPointerValue.Ident = FromPointerValue.Ident
    else
        NewPointerValue.Ident = math.random(1, 0x7FFFFFFF)  -- Generate a new identity
    end

    NewPointerValue.RefOffsets = FromPointerValue.RefOffsets
    NewPointerValue.Pointer = FromPointerValue.Pointer
end

function PointerReference(PointerValue, FromValue)
    local Ident = FromValue.Ident
    local Offset = FromValue.Offset
    local PointerOffset = PointerValue.Offset

    -- No enough space in the pointer to put reference
    if string.len(PointerValue.RawValue.Val) - PointerOffset < 4 then
        return
    end

    -- Remove former reference
    local FormerIdent = string.sub(PointerValue.RawValue.Val, 1 + PointerOffset, 4 + PointerOffset)
    PointerValue.RefOffsets[FormerIdent] = nil
    PointerValue.Pointer[FormerIdent] = nil

    -- Assign new reference
    -- Alter the identity to allow storing references to the same variable
    -- with different offsets
    PointerSetSignedOrUnsignedInt(PointerValue, math.random(1, 0x7FFFFFFF))
    local EncodedIdent = string.sub(PointerValue.RawValue.Val, 1 + PointerOffset, 4 + PointerOffset)
    PointerValue.RefOffsets[EncodedIdent] = Offset
    PointerValue.Pointer[EncodedIdent] = FromValue
end

function PointerDereference(FromValue)
    local Offset = FromValue.Offset
    local IdentTo = string.sub(FromValue.RawValue.Val, 1 + Offset, 4 + Offset)
    local RefOffset = FromValue.RefOffsets[IdentTo]
    local Pointer = FromValue.Pointer[IdentTo]
    local Result

    if RefOffset ~= nil and Pointer ~= nil then
        Result = {}
        Result.RawValue = Pointer.RawValue
        Result.Offset = RefOffset
        Result.Ident = Pointer.Ident
        Result.RefOffsets = Pointer.RefOffsets
        Result.Pointer = Pointer.Pointer
        return Result
    else
        return nil
    end
end

-- A small modification from C standard that void pointers will also be considered null
function IsPointerNull(PointerValue)
    local Offset = PointerValue.Offset
    local IdentTo = string.sub(PointerValue.RawValue.Val, 1 + Offset, 4 + Offset)

    local RefOffset = PointerValue.RefOffsets[IdentTo]
    local Pointer = PointerValue.Pointer[IdentTo]

    --if IdentTo == "\000\000\000\000" and RefOffset == nil and Pointer == nil then
    if RefOffset == nil and Pointer == nil then
        return true
    else
        return false
    end
end

function PointerSetNull(PointerValue)
    local Offset = PointerValue.Offset

    local RawValue = PointerValue.RawValue.Val
    local NullValue
    local Len = string.len(RawValue)
    local FormerIdentTo = string.sub(RawValue, 1 + Offset, 4 + Offset)

    NullValue = string.sub("\000\000\000\000", 1, MIN(4, Len - Offset))
    local NullLen = string.len(NullValue)

    assert(NullLen == 4 or NullLen == 0, "PointerSetNull: Len is not 4 or 0")

    if Len == 0 then
        return
    end

    RawValue = string.sub(RawValue, 1, Offset) ..
        NullValue .. string.sub(RawValue, Offset + NullLen + 1)

    PointerValue.RawValue.Val = RawValue

    -- Remove former reference
    PointerValue.RefOffsets[FormerIdentTo] = nil
    PointerValue.Pointer[FormerIdentTo] = nil
end

function PointerMovePointer(PointerValue, N)
    local Offset = PointerValue.Offset
    local IdentTo = string.sub(PointerValue.RawValue.Val, 1 + Offset, 4 + Offset)
    local RefOffset = PointerValue.RefOffsets[IdentTo]
    local Pointer = PointerValue.Pointer[IdentTo]

    if RefOffset ~= nil and Pointer ~= nil then
        RefOffset = RefOffset + N

        if RefOffset >= 0xFFFFFFFFFF then
            RefOffset = RefOffset - 0xFFFFFFFFFF
        elseif RefOffset < 0 then
            RefOffset = 0xFFFFFFFFFF + RefOffset
        end

        PointerValue.RefOffsets[IdentTo] = RefOffset
    end
end

function PointerComparePointer(PointerValue1, PointerValue2, CompareRefOffset)
    local Offset1 = PointerValue1.Offset
    local Offset2 = PointerValue2.Offset

    local IdentTo1 = string.sub(PointerValue1.RawValue.Val, 1 + Offset1, 4 + Offset1)
    local IdentTo2 = string.sub(PointerValue2.RawValue.Val, 1 + Offset2, 4 + Offset2)

    if IdentTo1 ~= IdentTo2 then
        return false, 0
    end

    local RefOffset1 = PointerValue1.RefOffsets[IdentTo1]
    local Pointer1 = PointerValue1.Pointer[IdentTo1]
    local RefOffset2 = PointerValue2.RefOffsets[IdentTo2]
    local Pointer2 = PointerValue2.Pointer[IdentTo2]

    if (RefOffset1 == nil or Pointer1 == nil or
        RefOffset2 == nil or Pointer2 == nil) then
        return false, 0
    end

    if Pointer1 ~= Pointer2 then
        return false, 0
    end

    if CompareRefOffset then
        if RefOffset1 ~= RefOffset2 then
            return false, RefOffset2 - RefOffset1
        end
    end

    return true, RefOffset2 - RefOffset1
end
