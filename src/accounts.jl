type Account
    id::Int64
    acctype::Symbol
    accname::String
end

id(acc::Account) = acc.id
id!(acc::Account, o::Int64) = (acc.id = o)

name(acc::Account) = acc.accname
accounttype(acc::Account) = acc.acctype
