using Currencies
using Accounting
using Base.Test

@usingcurrencies USD, CAD

# make a ledger for testing
ledger = Ledger()

cash = asset!(ledger, "Cash")
ob = equity!(ledger, "Opening Balance")

transfer!(ledger, Date(2015, 11, 29), ob, cash, 100USD)

@test debit(ledger, cash, :USD) == 100USD
@test credit(ledger, ob, :USD) == 100USD
@test debit(ledger, cash, :CAD) == 0CAD

bal = balances(ledger)

@test bal[cash] == 100USD
@test bal[ob] == -100USD

# simulate some activity
bankloan = liability!(ledger, "Bank Loan")
inventory = asset!(ledger, "Inventory")
cogs = expense!(ledger, "Cost of Goods Sold")
sales = revenue!(ledger, "Sales")

transfer!(ledger, Date(2015, 11, 30), bankloan, cash, 5000USD)
transfer!(ledger, Date(2015, 12, 01), cash, inventory, 1000USD)
transfer!(ledger, Date(2015, 12, 02), inventory, cogs, 20USD)
transfer!(ledger, Date(2015, 12, 02), sales, cash, 30CAD)

bal = balances(ledger)

@test bal[cash] == Basket([4100USD, 30CAD])
@test bal[inventory] == 980USD
@test bal[bankloan] == -5000USD
@test bal[cogs] == 20USD
@test bal[sales] == -30CAD

sheet = balancesheet(ledger)

@test total(sheet.assets) == Basket([5080USD, 30CAD])
@test total(sheet.assets) == total(sheet.le)
