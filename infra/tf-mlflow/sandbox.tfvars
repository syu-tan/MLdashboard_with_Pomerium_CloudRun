#provider
project = "(YOUR_PROJECT)"
region  = "asia-northeast1"
zone    = "asia-northeast1-a"

# cloud run 
dashboard_name             = "mlflow-cloudrun"
dashboard_cpu              = "2000"
dashboard_memory           = "1024"
autoscaling_max_num        = "4"
mlflow_artifact_store_name = "mlflow-artifact"

# auth cloud run 
auth_name      = "pomerium-mlflow"
auth_cpu       = "1000"
auth_memory    = "512"

# db
db_name = "mlflow"