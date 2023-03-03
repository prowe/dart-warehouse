{{
  config(
    materialized='table'
  )
}}

select 
    "timestamp" as at_ts,
    vehicle_id
from public.vehicle_position_events