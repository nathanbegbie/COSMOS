FROM python:3.8.5

# to get cv2 to work
RUN apt-get update
RUN apt-get install -y libgl1-mesa-dev

# split out this copy and install
# to speed up builds with layers
COPY requirements.txt requirements.txt
# Install dependencies.
RUN python -m pip install --upgrade pip
RUN python -m pip install --upgrade  --no-binary numpy==1.18.4 numpy==1.18.4
RUN python -m pip install -r requirements.txt

# to get cv2 to work
RUN python -m pip install opencv-contrib-python

RUN python -m spacy download en_core_web_sm && \
    python -m spacy download en

COPY Makefile ./Makefile
COPY detectron2_changes detectron2_changes/
RUN make setup_detectron



# copy the rest of the files over
COPY . ./

# we do this to avoid accidentally adding models to a Docker Image
# instead we add pre-existing models using volumes or train the model
# within the docker container
RUN mkdir models_final/

CMD python evaluate_ooc.py