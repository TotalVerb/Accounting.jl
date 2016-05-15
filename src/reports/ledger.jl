
immutable LedgerReport <: Report
    heading::Compat.UTF8String
    transactions::Vector{LedgerEntry}
end
