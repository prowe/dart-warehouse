import requests
import gtfs_realtime_pb2
import boto3
import os
from datetime import datetime, tzinfo

redshift_client = boto3.client('redshift-data')

create_landing_table_sql = """
    CREATE TABLE IF NOT EXISTS vehicle_position_events (
        timestamp TIMESTAMP SORTKEY,
        vehicle_id varchar(max),
        vehicle_label varchar(max),
        trip_trip_id varchar(max),
        trip_start_date varchar(10),
        trip_route_id varchar(max),
        trip_direction_id integer,
        position_latitude float,
        position_longitude float,
        position_bearing float,
        occupancy_status varchar(max)
    );
"""

def __create_table_if_needed():
    redshift_client.execute_statement(
        Database=os.environ.get('DB_NAME'),
        WorkgroupName=os.environ.get('WORKGROUP_NAME'),
        Sql=create_landing_table_sql
    )


def __get_vehicle_positions():
    response = requests.get('https://www.ridedart.com/gtfs/real-time/vehicle-positions')
    response.content
    feed_message = gtfs_realtime_pb2.FeedMessage()
    feed_message.ParseFromString(response.content)
    return feed_message

insert_statement = """
    INSERT INTO vehicle_position_events (timestamp, vehicle_id, vehicle_label, trip_trip_id, trip_start_date, trip_route_id, trip_direction_id, position_latitude, position_longitude, position_bearing, occupancy_status)
    VALUES (:timestamp, :vehicle_id, :vehicle_label, :trip_trip_id, :trip_start_date, :trip_route_id, :trip_direction_id, :position_latitude, :position_longitude, :position_bearing, :occupancy_status)
"""


def handler(event, context):
    print('handling event', event)
    feed_message = __get_vehicle_positions()
    print(feed_message)
    __create_table_if_needed()
    for entity in feed_message.entity:
        execute_response = redshift_client.execute_statement(
            Database=os.environ.get('DB_NAME'),
            WorkgroupName=os.environ.get('WORKGROUP_NAME'),
            Sql=insert_statement,
            Parameters=[
                {"name": "timestamp", "value": datetime.fromtimestamp(entity.vehicle.timestamp).isoformat()},
                {"name": "vehicle_id", "value": entity.vehicle.vehicle.id},
                {"name": "vehicle_label", "value": entity.vehicle.vehicle.label},
                {"name": "trip_trip_id", "value": entity.vehicle.trip.trip_id},
                {"name": "trip_start_date", "value": entity.vehicle.trip.start_date},
                {"name": "trip_route_id", "value": entity.vehicle.trip.route_id},
                {"name": "trip_direction_id", "value": str(entity.vehicle.trip.direction_id)},
                {"name": "position_latitude", "value": str(entity.vehicle.position.latitude)},
                {"name": "position_longitude", "value": str(entity.vehicle.position.longitude)},
                {"name": "position_bearing", "value": str(entity.vehicle.position.bearing)},
                {"name": "occupancy_status", "value": str(entity.vehicle.occupancy_status)},
            ]
        )
        print('Execute reponse ', execute_response)

