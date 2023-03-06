{{
  config(
    materialized='table'
  )
}}

select 
    "timestamp" as at_ts,
    vehicle_id
from vehicle_position_events