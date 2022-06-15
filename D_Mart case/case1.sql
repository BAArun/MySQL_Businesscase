use data_mart;
select * from data_mart.weekly_sales;
describe data_mart.weekly_sales;
select count(*) from data_mart.weekly_sales;
create table date_format as
#Convert the week_date to a DATE format
select STR_TO_DATE(week_date, '%d/%m/%Y') as dd , region, platform , segment , customer_type, transactions,sales from data_mart.weekly_sales;
select * from date_format;
#Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
#->Add a month_number with the calendar month for each week_date value as the 3rd column
#->Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
#->Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value - 1 Young Adults
# 2 Middle Aged , 3 or 4 Retirees
create table clean_weekly_sales as SELECT dd,
FLOOR((DAYOFMONTH(dd))/7) +1 as week_number,
month(dd) as month_number , YEAR(dd) as calendar_year, region, platform , segment ,
case 
	when segment regexp '1' then 'Young Adults'
	when segment regexp '2' then 'Middle Aged'
	when segment regexp '[3-4]' then 'Retirees'
	when segment is null then 'unknown'
    end as age_band ,
    case 
		when segment regexp 'C' then 'Couples'
		when segment regexp 'F' then 'Families'
        end as demographic,
customer_type, transactions,sales, round(sales/transactions,2) as avg_transaction
from date_format order by week_number;
select * from clean_weekly_sales;
#3. How many total transactions were there for each year in the dataset?
select sum(transactions), calendar_year
from clean_weekly_sales
group by calendar_year ;

# What is the total sales for each region for each month?
select calendar_year,sum(sales), region,month_number
     from clean_weekly_sales
     group by region , month_number , calendar_year
     order by calendar_year, sum(sales);
     
# q.5. What is the total count of transactions for each platform ?
select sum(transactions) as total_transactions ,platform
from clean_weekly_sales group by platform ;

# 6. What is the percentage of sales for Retail vs Shopify for each month?
select sum(sales) as sum_shopify_sales from clean_weekly_sales where platform='shopify' ;
select (sum(if(platform='shopify',sales,0))/sum(sales))*100 from clean_weekly_sales;
select sum(if(platform='shopify',sales,0))/sum(sales)*100 as shopify_sales_percentage ,calendar_year,month_number 
from clean_weekly_sales group by calendar_year,month_number;
select sum(if(platform='retail',sales,0))/sum(sales)*100 as shopify_sales_percentage ,calendar_year,month_number 
from clean_weekly_sales group by calendar_year,month_number order by calendar_year;

#7. What is the percentage of sales by demographic for each year in the dataset?
select ifnull(age_band,"unknown") ,ifnull(demographic,"unknown") ,calendar_year, sum(sales) from clean_weekly_sales group by demographic , calendar_year;
