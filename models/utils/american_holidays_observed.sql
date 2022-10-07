with hours as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="to_date('01/01/2018', 'mm/dd/yyyy')",
        end_date="dateadd(month, 1, current_date)"
       )
    }} as date_day

),

american_holidays_observed as (
    select
        date_day,
        case 
        ---- New Years Day
            when date_part(month, date_day) = 12 and date_part(day, date_day) = 31 and dayofweek(date_day) = 5 then 1
            when date_part(month, date_day) = 1 and date_part(day, date_day) = 1 and dayofweek(date_day) not in (0,6) then 1
            when date_part(month, date_day) = 1 and date_part(day, date_day) = 2 and dayofweek(date_day) = 1 then 1
        ---- MLK day ( 3rd Monday in January )
            when date_part(month, date_day) = 1 and dayofweek(date_day) = 1 and ceil(date_part(day, date_day) / 7) = 3 then 1
        ------ President’s Day ( 3rd Monday in February )
            when date_part(month, date_day) = 2 and dayofweek(date_day) = 1 and ceil(date_part(day, date_day) / 7) = 3 then 1
        ------ Memorial Day ( Last Monday in May )
            when date_part(month, date_day) = 5 and dayofweek(date_day) = 1 and date_part(day, date_day) > 24 then 1
        ------ Juneteenth ( starting 2021 )
            when date_part(year, date_day) >= 2021 and date_part(month, date_day) = 6 and date_part(day, date_day) = 18 and dayofweek(date_day) = 5 then 1
            when date_part(year, date_day) >= 2021 and date_part(month, date_day) = 6 and date_part(day, date_day) = 19 and dayofweek(date_day) not in (0,6) then 1
            when date_part(year, date_day) >= 2021 and date_part(month, date_day) = 6 and date_part(day, date_day) = 20 and dayofweek(date_day) = 1 then 1
        ------ Independence Day ( July 4 )
            when date_part(month, date_day) = 7 and date_part(day, date_day) = 3 and dayofweek(date_day) = 5 then 1
            when date_part(month, date_day) = 7 and date_part(day, date_day) = 4 and dayofweek(date_day) not in (0,6) then 1
            when date_part(month, date_day) = 7 and date_part(day, date_day) = 5 and dayofweek(date_day) = 1 then 1
        ------ Labor Day ( 1st Monday in September )
            when date_part(month, date_day) = 9 and dayofweek(date_day) = 1 and ceil(date_part(day, date_day) / 7) = 1 then 1
        ------ Indigenous Peoples' Day / Columbus Day ( 2nd Monday in October )
            when date_part(month, date_day) = 10 and dayofweek(date_day) = 1 and ceil(date_part(day, date_day) / 7) = 2 then 1
        ------ Veteran’s Day ( November 11 )
            when date_part(month, date_day) = 11 and date_part(day, date_day) = 10 and dayofweek(date_day) = 5 then 1
            when date_part(month, date_day) = 11 and date_part(day, date_day) = 11 and dayofweek(date_day) not in (0,6) then 1
            when date_part(month, date_day) = 11 and date_part(day, date_day) = 12 and dayofweek(date_day) = 1 then 1
        ------ Thanksgiving Day ( 4th Thursday in November )
            when date_part(month, date_day) = 11 and dayofweek(date_day) = 4 and ceil(date_part(day, date_day) / 7) = 4 then 1
        ------ Christmas Day ( December 25 )
            when date_part(month, date_day) = 12 and date_part(day, date_day) = 24 and dayofweek(date_day) = 5 then 1
            when date_part(month, date_day) = 12 and date_part(day, date_day) = 25 and dayofweek(date_day) not in (0,6) then 1
            when date_part(month, date_day) = 12 and date_part(day, date_day) = 26 and dayofweek(date_day) = 1 then 1
            else 0
        end as is_observed_holiday
    from hours
),

final as (
    select
        date_day,
        is_observed_holiday
    from american_holidays_observed
)

select * from final where is_observed_holiday = 1
