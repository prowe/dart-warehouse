{{
  config(
    materialized='table'
  )
}}

select 
    "timestamp" as at_ts,
    vehicle_id::varchar(250) as vehicle_id,
    ST_Point(position_longitude, position_latitude, 4326)::geography as position,
    position_bearing
from vehicle_position_events