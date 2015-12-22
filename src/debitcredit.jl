# Debits & Credits

type UnbalancedException <: Exception end

function debit end
credit(args...) = -debit(args...)
