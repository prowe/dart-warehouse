SELECT
    to_date(ev.injest_date, 'yyyy/mm/dd') as injest_date,
    cast(ev.injest_hour as INT) as injest_hour,
    timestamp_seconds(ev.timestamp) as at_ts,
    
    ev.trip.tripId as trip_id

    -- start_date
    -- route_id
    -- direction_id
    -- schedule_relationship
    -- latitude
    -- longitude
    -- bearing
    -- speed
    -- vehicle_id
    -- vehicle_label
    -- occupancy_status
FROM {{ source('poll_dart', 'vehicle_position_events') }} as ev
