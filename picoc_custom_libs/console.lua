function ConsoleRunFile(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Meter = GetSystemCounter()
    local PicoC = {}
    local RunMain = C_INT_TO_LUA_BOOLEAN(PointerGetSignedInt(Param[2].Val))
    PicocInitialize(PicoC, true)

    local Success = PicocPlaformScanFile(PicoC, "[clipboard]")
    if not Success then
        PointerSetSignedOrUnsignedInt(ReturnValue.Val, 1)
        return
    end

    if RunMain then
        local PCCallMain = coroutine.create(function() 
            PicocCallMain(PicoC, 0, {})
        end)
        local Suc, Err = coroutine.resume(PCCallMain)
        if not Suc then
            if string.find(Err, "C Parsing Error") ~= nil then
                PointerSetSignedOrUnsignedInt(ReturnValue.Val, 1)
                return
            else
                error(Err)
            end
        end
    end

    Meter = GetSystemCounter() - Meter
    PicoC.CStdOut.puts("Execution time: " .. tostring(Meter) .. "ms\n")
    PointerSetSignedOrUnsignedInt(ReturnValue.Val, PicoC.PicocExitValue)
end

ConsoleFunctions = {
    {
        Func = ConsoleRunFile,
        Prototype = "int runfile(char *, int, ...);"
    },
    {
        Func = nil,
        Prototype = nil
    }
}