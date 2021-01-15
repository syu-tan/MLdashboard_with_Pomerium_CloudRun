#!/bin/sh
python3 -m tensorboard.main --logdir $EVENT_FILE_PATH --reload_interval $RELOAD_INTERVAL  --port $PORT --bind_all

