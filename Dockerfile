FROM ghcr.io/dbt-labs/dbt-postgres:1.3.latest

ENV DBT_HOST=TODO
ENV DBT_USER=TODO
ENV DBT_PASSWORD=TODO
ENV DBT_PROFILES_DIR=/usr/app/dbt

ADD . .

RUN dbt deps