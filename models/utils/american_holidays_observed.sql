with days as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="to_date('01/01/2018', 'mm/dd/yyyy')",
        end_date="dateadd(month, 1, current_date)"
       )
    }} as date_day

),

date_parts as (
    select
        date_day,
        date_part(year, date_day) as date_year,
        date_part(month, date_day) as date_month,
        date_part(day, date_day) as day_of_month,
        dayofweek(date_day) as day_of_week
    from days
),

american_holidays as (
    select
        date_day,
        case 
        ---- New Years Day
            when date_month = 12 and day_of_month = 31 and day_of_week = 5 then '{{ escape_single_quotes("New Year's Day (observed)") }}'
            when date_month = 1 and day_of_month = 1 and day_of_week not in (0,6) then '{{ escape_single_quotes("New Year's Day") }}'
            when date_month = 1 and day_of_month = 2 and day_of_week = 1 then '{{ escape_single_quotes("New Year's Day (observed)") }}'
        ---- MLK day ( 3rd Monday in January )
            when date_month = 1 and day_of_week = 1 and ceil(day_of_month / 7) = 3 then 'MLK Day'
        ------ President’s Day ( 3rd Monday in February )
            when date_month = 2 and day_of_week = 1 and ceil(day_of_month / 7) = 3 then '{{ escape_single_quotes("President's Day") }}'
        ------ Memorial Day ( Last Monday in May )
            when date_month = 5 and day_of_week = 1 and day_of_month > 24 then 'Memorial Day'
        ------ Juneteenth ( starting 2021 )
            when date_year >= 2021 and date_month = 6 and day_of_month = 18 and day_of_week = 5 then 'Juneteenth (observed)'
            when date_year >= 2021 and date_month = 6 and day_of_month = 19 and day_of_week not in (0,6) then 'Juneteenth'
            when date_year >= 2021 and date_month = 6 and day_of_month = 20 and day_of_week = 1 then 'Juneteenth (observed)'
        ------ Independence Day ( July 4 )
            when date_month = 7 and day_of_month = 3 and day_of_week = 5 then 'Independence Day (observed)'
            when date_month = 7 and day_of_month = 4 and day_of_week not in (0,6) then 'Independence Day'
            when date_month = 7 and day_of_month = 5 and day_of_week = 1 then 'Independence Day (observed)'
        ------ Labor Day ( 1st Monday in September )
            when date_month = 9 and day_of_week = 1 and ceil(day_of_month / 7) = 1 then 'Labor Day'
        ------ Indigenous Peoples' Day ( 2nd Monday in October )
            when date_month = 10 and day_of_week = 1 and ceil(day_of_month / 7) = 2 then '{{ escape_single_quotes("Indigenous Peoples' Day") }}'
        ------ Veteran’s Day ( November 11 )
            when date_month = 11 and day_of_month = 10 and day_of_week = 5 then '{{ escape_single_quotes("Veteran’s Day (observed)") }}'
            when date_month = 11 and day_of_month = 11 and day_of_week not in (0,6) then '{{ escape_single_quotes("Veteran’s Day") }}'
            when date_month = 11 and day_of_month = 12 and day_of_week = 1 then '{{ escape_single_quotes("Veteran’s Day (observed)") }}'
        ------ Thanksgiving Day ( 4th Thursday in November )
            when date_month = 11 and day_of_week = 4 and ceil(day_of_month / 7) = 4 then 'Thanksgiving'
        ------ Christmas Day ( December 25 )
            when date_month = 12 and day_of_month = 24 and day_of_week = 5 then 'Christmas (observed)'
            when date_month = 12 and day_of_month = 25 and day_of_week not in (0,6) then 'Christmas'
            when date_month = 12 and day_of_month = 26 and day_of_week = 1 then 'Christmas (observed)'
            else null
        end as holiday_description
    from date_parts
),

final as (
    select
        date_day,
        holiday_description,
        case when holiday_description is not null then 1 else 0 end as is_american_holiday
    from american_holidays
)

select * from final
