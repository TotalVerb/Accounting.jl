type Ledger
    accounts::Set{Account}
    entries::SortedMultiDict{Date,Entry}
    lastid::Int64
end

Ledger() = Ledger(
    Set{Account}(),
    SortedMultiDict(Date[], Entry[]),
    0)

nextid!(l::Ledger) = (l.lastid += 1)
function push!(l::Ledger, ent::Entry)
    id!(ent, nextid!(l))
    insert!(l.entries, date(ent), ent)
    nothing
end
function register!(l::Ledger, acc::Account)
    id!(acc, nextid!(l))
    push!(l.accounts, acc)
    acc
end

# Make account type functions.
for acctype in [:Asset, :Liability, :Equity, :Revenue, :Expense, :Trading]
    # Get symbols.
    lc = lowercase(string(acctype))
    asym = Expr(:quote, symbol(lc))  # :asset
    mutfn = symbol(lc, "!")  # :asset!

    # Make constructor (Asset).
    @eval ($acctype)(name) = Account(-1, $asym, UTF8String(name))

    # Define asset! method.
    @eval begin
        ($mutfn)(l::Ledger, name::AbstractString) =
            register!(l, ($acctype)(name))
    end
end

function transfer!(
    sys::Ledger,
    date::Date,
    credit::Account,
    debit::Account,
    amount::Monetary,
    description::AbstractString = "")
    ent = Entry(date, UTF8String(description), [
        Split(debit, amount),
        Split(credit, -amount)
    ])
    push!(sys, ent)
    ent
end

# access functions
function debit(ledger::Ledger, account::Account, cur::Symbol)
    netdebit = zero(Monetary{cur})
    for (date, tx) in ledger.entries
        for split in tx.splits
            if split.account ≡ account && currency(split) == cur
                netdebit += debit(split)
            end
        end
    end
    netdebit
end

immutable Balance
    account::Account
    netdebit::Monetary
end
currency(b::Balance) = currency(b.netdebit)
debit(b::Balance) = b.amount

function balances(ledger::Ledger)
    ret = Dict{Account, DynamicBasket}()
    for (date, tx) in ledger.entries
        for split in tx.splits
            symb = currency(split)
            key = split.account
            if haskey(ret, key)
                ret[key][symb] += debit(split)
            else
                ret[key] = DynamicBasket(debit(split))
            end
        end
    end
    ret
end
