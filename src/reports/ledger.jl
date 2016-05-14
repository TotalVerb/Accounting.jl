
immutable LedgerReport <: Report
    heading::String
    transactions::Vector{LedgerEntry}
end
