import requests
import gtfs_realtime_pb2
import os
import json
import csv
import pg8000.native
from datetime import datetime
from io import StringIO


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


copy_in_statement = """
    COPY vehicle_position_events 
        (timestamp, vehicle_id, vehicle_label, trip_trip_id, trip_start_date, trip_route_id, trip_direction_id, position_latitude, position_longitude, position_bearing, occupancy_status) 
    FROM STDIN WITH (FORMAT CSV)
"""


def __get_database_secret():
    secret_arn = os.environ.get('DATABASE_SECRET_ARN')
    secret_url = f"http://localhost:2773/secretsmanager/get?secretId={secret_arn}"
    r = requests.get(secret_url, headers={"X-Aws-Parameters-Secrets-Token": os.environ.get('AWS_SESSION_TOKEN')})
    secret = json.loads(r.text)["SecretString"]
    return json.loads(secret)


def __get_vehicle_positions():
    response = requests.get('https://www.ridedart.com/gtfs/real-time/vehicle-positions')
    response.content
    feed_message = gtfs_realtime_pb2.FeedMessage()
    feed_message.ParseFromString(response.content)
    return feed_message


def __iterate_vehicle_positions():
    feed_message = __get_vehicle_positions()
    print(feed_message)
    txt_stream = StringIO()
    csv_writer = csv.writer(txt_stream)
    for entity in feed_message.entity:
        csv_writer.writerow([
            datetime.fromtimestamp(entity.vehicle.timestamp).isoformat(),
            entity.vehicle.vehicle.id,
            entity.vehicle.vehicle.label,
            entity.vehicle.trip.trip_id,
            entity.vehicle.trip.start_date,
            entity.vehicle.trip.route_id,
            str(entity.vehicle.trip.direction_id),
            str(entity.vehicle.position.latitude),
            str(entity.vehicle.position.longitude),
            str(entity.vehicle.position.bearing),
            str(entity.vehicle.occupancy_status)
        ])
    txt_stream.seek(0)
    return txt_stream


def handler(event, context):
    print('handling event', event)

    secret = __get_database_secret()
    con = pg8000.native.Connection(
        host=os.environ.get('DATABASE_HOST'),
        port=5432,
        database='wh',
        user=secret['username'],
        password=secret['password'],
        timeout=10,
        ssl_context=True)
    con.run(create_landing_table_sql)
    con.run(copy_in_statement, stream=__iterate_vehicle_positions())
    con.close()
