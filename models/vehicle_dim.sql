SELECT DISTINCT
    vehicle_id as id,
    last_value(vehicle_label) over (partition by vehicle_id order by timestamp) as label
FROM {{ source('poll_dart', 'vehicle_position_events') }}