function MathSin(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Val = math.sin(PointerGetFP(Param[1].Val))
    PointerSetFP(ReturnValue.Val, Val)
end

function MathCos(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Val = math.cos(PointerGetFP(Param[1].Val))
    PointerSetFP(ReturnValue.Val, Val)
end

function MathTan(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Val = math.tan(PointerGetFP(Param[1].Val))
    PointerSetFP(ReturnValue.Val, Val)
end

function MathAsin(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Val = math.asin(PointerGetFP(Param[1].Val))
    PointerSetFP(ReturnValue.Val, Val)
end

function MathAcos(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Val = math.acos(PointerGetFP(Param[1].Val))
    PointerSetFP(ReturnValue.Val, Val)
end

function MathAtan(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Val = math.atan(PointerGetFP(Param[1].Val))
    PointerSetFP(ReturnValue.Val, Val)
end

function MathAtan2(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Val = math.atan(PointerGetFP(Param[1].Val),
        PointerGetFP(Param[2].Val))
    PointerSetFP(ReturnValue.Val, Val)
end

function MathSinh(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Val = math.sinh(PointerGetFP(Param[1].Val))
    PointerSetFP(ReturnValue.Val, Val)
end

function MathCosh(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Val = math.cosh(PointerGetFP(Param[1].Val))
    PointerSetFP(ReturnValue.Val, Val)
end

function MathTanh(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Val = math.tanh(PointerGetFP(Param[1].Val))
    PointerSetFP(ReturnValue.Val, Val)
end

function MathExp(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Val = math.exp(PointerGetFP(Param[1].Val))
    PointerSetFP(ReturnValue.Val, Val)
end

function MathFabs(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Val = math.abs(PointerGetFP(Param[1].Val))
    PointerSetFP(ReturnValue.Val, Val)
end

function MathFmod(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Val = math.fmod(PointerGetFP(Param[1].Val),
        PointerGetFP(Param[2].Val))
    PointerSetFP(ReturnValue.Val, Val)
end

function MathFrexp(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local m, e = math.frexp(PointerGetFP(Param[1].Val))
    local Param1 = PointerDereference(Param[2].Val)
    if Param1 ~= nil then
        PointerSetSignedOrUnsignedInt(Param1, e)
    end
    PointerSetFP(ReturnValue.Val, m)
end

function MathLdexp(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Val = math.ldexp(PointerGetFP(Param[1].Val),
        PointerGetSignedInt(Param[2].Val))
    PointerSetFP(ReturnValue.Val, Val)
end

function MathLog(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Val = math.log(PointerGetFP(Param[1].Val))
    PointerSetFP(ReturnValue.Val, Val)
end

function MathLog10(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Val = math.log10(PointerGetFP(Param[1].Val))
    PointerSetFP(ReturnValue.Val, Val)
end

function MathModf(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local i, f = math.modf(PointerGetFP(Param[1].Val))
    local Param1 = PointerDereference(Param[2].Val)
    if Param1 ~= nil then
        PointerSetFP(Param1, i)
    end
    PointerSetFP(ReturnValue.Val, f)
end

function MathPow(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Val = math.pow(PointerGetFP(Param[1].Val),
        PointerGetFP(Param[2].Val))
    PointerSetFP(ReturnValue.Val, Val)
end

function MathSqrt(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Val = math.sqrt(PointerGetFP(Param[1].Val))
    PointerSetFP(ReturnValue.Val, Val)
end

function MathRound(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Val = math.ceil(PointerGetFP(Param[1].Val) - 0.5)
    PointerSetFP(ReturnValue.Val, Val)
end

function MathCeil(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Val = math.ceil(PointerGetFP(Param[1].Val))
    PointerSetFP(ReturnValue.Val, Val)
end

function MathFloor(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Val = math.floor(PointerGetFP(Param[1].Val))
    PointerSetFP(ReturnValue.Val, Val)
end

MathFunctions = {
    {
        Func = MathAcos,
        Prototype = "float acos(float);"
    },
    {
        Func = MathAsin,
        Prototype = "float asin(float);"
    },
    {
        Func = MathAtan,
        Prototype = "float atan(float);"
    },
    {
        Func = MathAtan2,
        Prototype = "float atan2(float, float);"
    },
    {
        Func = MathCeil,
        Prototype = "float ceil(float);"
    },
    {
        Func = MathCos,
        Prototype = "float cos(float);"
    },
    {
        Func = MathCosh,
        Prototype = "float cosh(float);"
    },
    {
        Func = MathExp,
        Prototype = "float exp(float);"
    },
    {
        Func = MathFabs,
        Prototype = "float fabs(float);"
    },
    {
        Func = MathFloor,
        Prototype = "float floor(float);"
    },
    {
        Func = MathFmod,
        Prototype = "float fmod(float, float);"
    },
    {
        Func = MathFrexp,
        Prototype = "float frexp(float, int *);"
    },
    {
        Func = MathLdexp,
        Prototype = "float ldexp(float, int);"
    },
    {
        Func = MathLog,
        Prototype = "float log(float);"
    },
    {
        Func = MathLog10,
        Prototype = "float log10(float);"
    },
    {
        Func = MathModf,
        Prototype = "float modf(float, float *);"
    },
    {
        Func = MathPow,
        Prototype = "float pow(float,float);"
    },
    {
        Func = MathRound,
        Prototype = "float round(float);"
    },
    {
        Func = MathSin,
        Prototype = "float sin(float);"
    },
    {
        Func = MathSinh,
        Prototype = "float sinh(float);"
    },
    {
        Func = MathSqrt,
        Prototype = "float sqrt(float);"
    },
    {
        Func = MathTan,
        Prototype = "float tan(float);"
    },
    {
        Func = MathTanh,
        Prototype = "float tanh(float);"
    },
    {
        Func = nil,
        Prototype = nil
    }
}
