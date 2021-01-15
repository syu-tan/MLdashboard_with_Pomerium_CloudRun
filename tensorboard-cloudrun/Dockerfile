FROM ubuntu:focal

RUN apt-get update && apt-get install -y python3-pip curl
RUN pip3 install tensorflow 

WORKDIR /
ADD run_tensorboard.sh /run_tensorboard.sh
RUN chmod u+x /run_tensorboard.sh
ENTRYPOINT ["/run_tensorboard.sh"]


