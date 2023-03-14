with paths as (
    select 
        vehicle_id, 
        at_ts::date,
        count(1) as datapoint_count,
        ST_MakeLine(position::geometry order by at_ts asc)::geography as day_path
    from {{ ref('vehicle_position_fact') }}
    {% if is_incremental() %}
        where at_ts >= (select max(day) from {{ this }})
    {% endif %}
    group by vehicle_id, at_ts::date
)
select
    vehicle_id,
    at_ts::date as day,
    day_path,
    datapoint_count,
	ST_Length(p.day_path) * 0.000621371 as distance_traveled_miles
from paths as p