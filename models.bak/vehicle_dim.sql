SELECT DISTINCT
    vehicle_id as id,
    last_value(vehicle_label) over (partition by vehicle_id order by timestamp) as label,
    max(timestamp) over (partition by vehicle_id) as last_ts
FROM {{ source('poll_dart', 'vehicle_position_events') }}
{% if is_incremental() %}
  where timestamp >= (select max(last_ts) from {{ this }})
{% endif %}