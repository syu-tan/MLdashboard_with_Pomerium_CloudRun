#!/bin/bash 
mlflow server --backend-store-uri $STORE_URI  --default-artifact-root $ARTIFACTE_URI --port $PORT --host 0.0.0.0
