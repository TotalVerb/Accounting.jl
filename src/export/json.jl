using JSON
import JSON: json

export json

# JSON Export for reports, etc.
joreduce(x) = x
joreduce{S,T}(a::Array{S,T}) = map(joreduce, a)
joreduce(m::Monetary) = stringmime("text/plain", m)
joreduce(b::Basket) = joreduce(collect(b))

joreduce{S<:AbstractString,B<:Basket}(b::Pair{S,B}) = Dict(
    "name" => b.first,
    "value" => joreduce(b.second))

joreduce(s::BSSection) = Dict(
    "heading" => joreduce(s.heading),
    "entries" => joreduce(s.entries),
    "subsections" => joreduce(s.subsections),
    "total" => joreduce(total(s)))

joreduce(s::BalanceSheet) = Dict(
    "assets" => joreduce(s.assets),
    "liabilitiesandequity" => joreduce(s.le))

json(s::BalanceSheet) = json(joreduce(s))
