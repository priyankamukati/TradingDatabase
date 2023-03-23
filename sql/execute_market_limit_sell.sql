-- FUNCTION: public.execute_market_limit_sell()

-- DROP FUNCTION IF EXISTS public.execute_market_limit_sell();

CREATE OR REPLACE FUNCTION public.execute_market_limit_sell(
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
   var_cur_quantity float;
   var_execution_amount float;
   var_cash_balance float;
   var_portfolio_exist int;
   var_current_volume int;
   var_current_time timestamp;
   
begin

   raise notice 'start';
   open order_cursor for select * from user_order where order_nature='sell' and status='pending';
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

        elsif trow.order_type = 'limit' and var_current_price < trow.limit_price then
			raise notice '<skipping... trow.limit_price>=% ', trow.limit_price;
			raise notice '<skipping... trow.var_current_price>=% ', trow.var_current_price;
            continue;

        else
			var_execution_amount = var_current_price * trow.quantity;
			raise notice '<var_execution_amount>=%', var_execution_amount;
		
			select into var_cash_balance "cash_balance" from "user_info" where id=trow.user_id ;
	
			select into var_cur_quantity "quantity" from user_stock where user_id=trow.user_id and stock_id=trow.stock_id;

			raise notice 'var_cur_quantity=%', var_cur_quantity;
			raise notice 'trow.quantity=%', trow.quantity;
		
		    select into var_portfolio_exist count(*) from user_stock
		    	where user_id=trow.user_id and stock_id=trow.stock_id;
				
			if var_portfolio_exist = 0 then
				continue;
				
			elsif var_cur_quantity < trow.quantity then
				update user_order set status='execution_skipped', status_reason='stock in the account less than order quantity placed'
				where id=trow.id;
        
        	else
		    	update user_info set cash_balance=cash_balance+var_execution_amount, update_date=(now() at time zone 'utc')
		    	where id=trow.user_id;
		
		    	update user_order set transaction_execution_price=var_execution_amount, 
		    	status='completed', status_reason='success', update_date=(now() at time zone 'utc')
		    	where id=trow.id;	
		
			    update user_stock set quantity=quantity-trow.quantity, update_date=(now() at time zone 'utc')
			    where user_id=trow.user_id and stock_id=trow.stock_id;

		    	update stock set volume=volume+trow.quantity, update_date=(now() at time zone 'utc')
		    	where id=trow.stock_id;
        	end if;
		end if;
		
	end loop;
	
   close order_cursor;

   raise notice 'finished';
end;
$BODY$;

ALTER FUNCTION public.execute_market_limit_sell()
    OWNER TO postgres;
