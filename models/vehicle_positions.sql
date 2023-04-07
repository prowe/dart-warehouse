SELECT
    ev.injest_year_month as injest_year_month,
    timestamp_seconds(cast(ev.timestamp as FLOAT)) as at_ts,
    
    ev.trip.tripId as trip_id,
    to_date(ev.trip.startDate, 'yyyyMMdd') as trip_start_date,
    ev.trip.routeId as trip_route_id,
    ev.position.latitude as latitude,
    ev.position.longitude as longitude,
    ev.position.bearing as bearing,
    ev.position.speed as speed,

    ev.vehicle.id as vehicle_id,
    ev.vehicle.label as vehicle_label,

    occupancyStatus as occupancy_status,

    r.route_long_name,
    r.route_type,
    r.route_text_color,
    r.route_color,
    r.route_short_name
FROM {{ source('poll_dart', 'vehicle_position_events') }} as ev
LEFT JOIN {{ ref('routes') }} as r on ev.trip.routeId = r.route_id
