
immutable LedgerReport <: Report
    heading::UTF8String
    transactions::Vector{LedgerEntry}
end
