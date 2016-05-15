type Split
    account::Account
    netdebit::Monetary
end
debit(split::Split) = split.netdebit
credit(split::Split) = -split.netdebit
currency(split::Split) = currency(split.netdebit)

type Entry
    id::Int64
    date::Date
    description::Compat.UTF8String
    splits::Vector{Split}

    function Entry(
        date::Date,
        description::Compat.UTF8String,
        splits::Vector{Split})

        dd = DefaultDict(Symbol, Int64, 0)
        for s in splits
            dd[currency(s)] += debit(s).val
        end
        if all(kv -> last(kv) == 0, dd)
            new(-1, date, description, splits)
        else
            throw(UnbalancedException())
        end
    end
end

id(e::Entry) = e.id
id!(e::Entry, o::Int64) = (e.id = o)
date(e::Entry) = e.date
isless(e::Entry, f::Entry) = (e.date, e.id) < (f.date, f.id)
