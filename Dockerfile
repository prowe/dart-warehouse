FROM ghcr.io/dbt-labs/dbt-core:1.3.latest

ENV DBT_PROFILES_DIR=/usr/app/dbt

# RUN pip install dbt-athena-community
RUN pip install dbt-glue

ADD . .

RUN dbt deps