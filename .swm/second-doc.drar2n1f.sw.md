---
title: Second doc
---
<SwmSnippet path="/src/JulIO.jl" line="35">

---

`flatmap` function

```julia
function flatmap(T2::Type, f::Function, jo::JO{T1}) where {T1}
    JO{T2}(
        expr = :(if Parent("input").status == Succeed eval(Func("mapper")(Parent("input").result).expr) else Parent("input").error end),
        parents = Dict("input" => jo),
        functions = Dict("mapper" => f))
end
```

---

</SwmSnippet>

<SwmMeta version="3.0.0" repo-id="Z2l0aHViJTNBJTNBSnVsSU8lM0ElM0FzdGVha292ZXJmbG93LW1l" repo-name="JulIO"><sup>Powered by [Swimm](https://app.swimm.io/)</sup></SwmMeta>
