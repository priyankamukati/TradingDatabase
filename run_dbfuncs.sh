#!/bin/bash
export PGPASSWORD=password

while :
do
	psql -U postgres -w -d postgres -h 0.0.0.0 -p 5432 -c "select * from public.execute_market_limit_buy()"
	echo "buy orders processed..."
	sleep 2
	psql -U postgres -w -d postgres -h 0.0.0.0 -p 5432 -c "select * from public.execute_market_limit_sell()"
	echo "sell orders processed..."
	sleep 2
	psql -U postgres -w -d postgres -h 0.0.0.0 -p 5432 -c "select * from public.update_marketstock_price()"
	echo "stock price updated..."
	sleep 2
done

