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

<SwmSnippet path="/Project.toml" line="6">

---

Dependencies!

```toml
[deps]
Distributed = "8ba89e20-285c-5b6f-9357-94700520ee1b"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
Logging = "56ddb016-857b-54e1-b83d-db4d58db5568"
MacroTools = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
```

---

</SwmSnippet>

<SwmMeta version="3.0.0" repo-id="Z2l0aHViJTNBJTNBSnVsSU8lM0ElM0FzdGVha292ZXJmbG93LW1l" repo-name="JulIO"><sup>Powered by [Swimm](https://app.swimm.io/)</sup></SwmMeta>
