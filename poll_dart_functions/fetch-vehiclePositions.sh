#!/bin/bash

curl https://www.ridedart.com/gtfs/real-time/vehicle-positions | protoc --decode=transit_realtime.FeedMessage gtfs-realtime.proto