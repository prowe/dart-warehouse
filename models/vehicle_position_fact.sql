SELECT
    "timestamp" as at_ts,
    trip_route_id as route_id,
    vehicle_id::varchar(250) as vehicle_id,
    ST_Point(position_longitude, position_latitude, 4326)::geography as position,
    position_bearing
FROM {{ source('poll_dart', 'vehicle_position_events') }}
{% if is_incremental() %}
  where timestamp >= (select max(at_ts) from {{ this }})
{% endif %}
