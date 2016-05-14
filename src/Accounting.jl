module Accounting

using Compat
import Compat: String

import Currencies: currency
using Currencies
using DataStructures
import Base.push!

include("debitcredit.jl")
include("accounts.jl")
include("entries.jl")
include("ledger.jl")
include("reports.jl")

export Split, Entry, Ledger
export Asset, Liability, Equity, Revenue, Expense, Trading
export asset!, liability!, equity!, revenue!, expense!, trading!
export debit, credit, balances, currency
export register!, transfer!

end  # module
