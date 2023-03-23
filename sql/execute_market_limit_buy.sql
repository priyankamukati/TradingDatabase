-- FUNCTION: public.execute_market_limit_buy()

-- DROP FUNCTION IF EXISTS public.execute_market_limit_buy();

CREATE OR REPLACE FUNCTION public.execute_market_limit_buy(
	)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$

declare
   order_cursor refcursor;
   trow user_order%rowtype;
   var_current_price float;
   var_current_volume float;
   var_execution_amount float;
   var_cash_balance float;
   var_portfolio_exist int;
   var_current_time timestamp;
   
begin

   raise notice 'start';
   open order_cursor for select * from user_order where order_nature='buy' and status='pending';
   loop
   
   		fetch next from order_cursor into trow;
		exit when not found;
		
    	raise notice '<first>=% % % % % % % %', trow.id, trow.user_id, trow.stock_id, trow.order_nature, trow.quantity, trow.order_type, trow.limit_price, trow.limit_expiration;

		select into var_current_price, var_current_volume "current_price", "volume" from "stock" where id=trow.stock_id ;
    	raise notice '<current_price>=% <var_current_volume>=%', var_current_price, var_current_volume;
		
		var_current_time = timezone('utc', now());
		
		raise notice 'var_current_time=%', var_current_time;
		raise notice 'trow_limit_expiration=%', trow.limit_expiration;

        if trow.order_type = 'limit' and var_current_time > trow.limit_expiration then
			update user_order set status='execution_skipped', status_reason='limit order expired'
			where id=trow.id;        

        elsif trow.order_type = 'limit' and var_current_price > trow.limit_price then
            continue;

        else
			var_execution_amount = var_current_price * trow.quantity;
			raise notice '<var_execution_amount>=%', var_execution_amount;
		
			select into var_cash_balance "cash_balance" from "user_info" where id=trow.user_id ;
		
			if var_cash_balance < var_execution_amount then
				update user_order set status='execution_skipped', status_reason='cash balance less than execution amount'
				where id=trow.id;
		
			elsif var_current_volume < trow.quantity then
				update user_order set status='execution_skipped', status_reason='current stock volume lower than order quantity placed'
				where id=trow.id;
        
        	else
		    	update user_info set cash_balance=cash_balance-var_execution_amount, update_date=(now() at time zone 'utc')
		    	where id=trow.user_id;
		
		    	update user_order set transaction_execution_price=var_execution_amount, 
		    	status='completed', status_reason='success', update_date=(now() at time zone 'utc')
		    	where id=trow.id;	
		
		    	select into var_portfolio_exist count(*) from user_stock
		    	where user_id=trow.user_id and stock_id=trow.stock_id;
		
		    	if var_portfolio_exist > 0 then
			    	update user_stock set quantity=quantity+trow.quantity, update_date=(now() at time zone 'utc')
			    	where user_id=trow.user_id and stock_id=trow.stock_id;
		    	else
			    	insert into user_stock( user_id, stock_id, quantity, update_date) 
			    	values (trow.user_id, trow.stock_id, trow.quantity, now() at time zone 'utc');
		    	end if;

		    	update stock set volume=volume-trow.quantity, update_date=(now() at time zone 'utc')
		    	where id=trow.stock_id;
        	end if;
		end if;
		
	end loop;
	
   close order_cursor;

   raise notice 'finished';
end;
$BODY$;

ALTER FUNCTION public.execute_market_limit_buy()
    OWNER TO postgres;
