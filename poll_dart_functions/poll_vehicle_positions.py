import requests
import gtfs_realtime_pb2
from google.protobuf.json_format import MessageToJson
import boto3
import os


firehose_client = boto3.client('firehose')

def __get_vehicle_positions():
    response = requests.get('https://www.ridedart.com/gtfs/real-time/vehicle-positions')
    response.content
    feed_message = gtfs_realtime_pb2.FeedMessage()
    feed_message.ParseFromString(response.content)
    return feed_message

def __convert_to_kinesis_record(entity) -> dict:
    json_payload = MessageToJson(entity.vehicle, indent=None) + "\n"
    print("record ", json_payload)
    return {
        "Data": json_payload.encode()
    }

def handler(event, context):
    feed_message = __get_vehicle_positions()
    records = [__convert_to_kinesis_record(entity) for entity in feed_message.entity]
    if 0 == len(records):
        print("No records to send")
        return
    
    put_response = firehose_client.put_record_batch(
        DeliveryStreamName=os.environ.get('STREAM_NAME'),
        Records=records
    )
    print("FailedPutCount: ", put_response['FailedPutCount'])

# handler(None, None)