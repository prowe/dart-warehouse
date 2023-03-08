WITH grouped_positions as (
    SELECT
        at_ts,
        route_id,
        vehicle_id,
        position,
        position_bearing,
        row_number() over (partition by vehicle_id order by at_ts desc) as row_num
    FROM {{ ref('vehicle_position_fact') }}
)
SELECT
    at_ts,
    route_id,
    vehicle_id,
    position,
    position_bearing
from grouped_positions
where row_num = 1