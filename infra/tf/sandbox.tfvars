#provider
project = "(YOUR_PROJECT)"
region  = "asia-northeast1"
zone    = "asia-northeast1-a"
env     = "sandbox"

# cloud run 
dashboard_name         = "tensorboard-cloudrun"
dashboard_cpu          = "1000"
dashboard_memory       = "512"
event_filepath         = "gs://(YOUR)/(PATH)/(TO)/(TENSORBOARD)"
tensorboard_reroadtime = "600"
autoscaling_max_num    = "2"

# auth cloud run 
auth_name      = "pomerium-cloudrun"
auth_cpu       = "1000"
auth_memory    = "512"
encoded_policy = "(YOUR_POMERIUM_POLISY_ENCODE_BY_BASE64)"