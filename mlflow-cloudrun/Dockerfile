FROM python:latest

RUN pip install -U pip & pip install mlflow
RUN pip install psycopg2 google-cloud-storage


WORKDIR /
ADD run_mlflow.sh /run_mlflow.sh
RUN chmod u+x /run_mlflow.sh
ENTRYPOINT ["/run_mlflow.sh"]
