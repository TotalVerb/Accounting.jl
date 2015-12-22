
abstract Report

function balancetable(accounts)

end

immutable BSSection
    heading::UTF8String
    subsections::Vector{BSSection}
    entries::Vector{Pair{UTF8String, DynamicBasket}}

    BSSection(heading) = new(heading, [], [])
end

function total(s::BSSection)
    acc = zero(DynamicBasket)
    for sect in s.subsections
        acc += total(sect)
    end
    for (_, account) in s.entries
        acc += account
    end
    acc
end

function Base.push!{T<:AbstractString}(s::BSSection, p::Pair{T, DynamicBasket})
    push!(s.entries, UTF8String(p[1]) => p[2])
end

function Base.push!(s::BSSection, p::BSSection)
    push!(s.subsections, p)
end

immutable BalanceSheet <: Report
    assets::BSSection
    le::BSSection
end

function balancesheet(ledger::Ledger)
    bals = balances(ledger)
    assets = BSSection("Assets")
    liabilities = BSSection("Liabilities")
    equity = BSSection("Equity")
    le = BSSection("Liabilities & Equity")
    earnings = DynamicBasket()
    unrealized = DynamicBasket()
    for (acc, bal) in bals
        @match accounttype(acc) begin
            :asset => push!(assets, name(acc) => bal)
            :liability => push!(liabilities, name(acc) => -bal)
            :equity => push!(equity, name(acc) => -bal)
            :revenue => push!(earnings, -bal)
            :expense => push!(earnings, -bal)
            :trading => push!(unrealized, -bal)
        end
    end
    push!(le, liabilities)
    push!(le, equity)
    push!(equity, "Retained Earnings" => earnings)
    push!(equity, "Unrealized Gains" => unrealized)
    BalanceSheet(assets, le)
end

Currencies.valuate(table, as::Symbol, p::Pair{UTF8String, DynamicBasket}) =
    p.first => DynamicBasket(valuate(table, as, p.second))

function Currencies.valuate(table, as::Symbol, s::BSSection)
    ns = BSSection(s.heading)
    for ss in s.subsections
        push!(ns, valuate(table, as, ss))
    end
    for ent in s.entries
        push!(ns, valuate(table, as, ent))
    end
    ns
end

Currencies.valuate(table, as::Symbol, bs::BalanceSheet) =
    BalanceSheet(valuate(table, as, bs.assets), valuate(table, as, bs.le))
