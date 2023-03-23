-- FUNCTION: public.update_marketstock_price()

-- DROP FUNCTION IF EXISTS public.update_marketstock_price();

CREATE OR REPLACE FUNCTION public.update_marketstock_price(
	)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$

declare
   stock_cursor refcursor;
   trow stock%rowtype;
   
   var_new_price float;
   var_current_time timestamp;
   var_update_date timestamp;
   var_current_price float;
   
begin

   raise notice 'start';
   open stock_cursor for select * from stock;
   loop
   
   		fetch next from stock_cursor into trow;
		exit when not found;
		
    	raise notice '<first>=%', stock_cursor;

		var_current_price = trow.current_price;
		var_update_date = trow.update_date;

		--select into var_current_price, var_update_date "current_price", "update_date" from "stock" where id=trow.id ;
    	raise notice '<current_price>=% ', var_current_price;
		
		var_current_time = timezone('utc', now());

		raise notice '<first>=% % %', var_current_time, var_update_date, DATE_PART('day', var_current_time - var_update_date);
		
		var_new_price = var_current_price + random() * 2 + 1; 
		raise notice '<var_new_price>=% ', var_new_price;
		
		if DATE_PART('day', var_current_time - var_update_date) > 0 then
			raise notice 'first time =% ', var_current_price;
			
			update stock set 
			    current_price=var_new_price,
				todays_max_price=var_new_price, 
				todays_min_price=var_new_price,
				todays_open_price=var_new_price,
				update_date=(now() at time zone 'utc')
			where id=trow.id;
		else
			raise notice 'second time =% ', var_current_price;
			update stock set
			    current_price=var_new_price, 
				todays_max_price=greatest(var_new_price, coalesce(todays_max_price, var_new_price)), 
				todays_min_price=least(var_new_price, coalesce(todays_min_price, var_new_price)),
				todays_open_price=coalesce(todays_open_price, var_new_price),
				update_date=(now() at time zone 'utc')
			where id=trow.id;	
		
		end if;
		
	end loop;
	
   close stock_cursor;

   raise notice 'finished';
end;
$BODY$;

ALTER FUNCTION public.update_marketstock_price()
    OWNER TO postgres;
