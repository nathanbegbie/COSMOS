rm:
	rm -rf detectron2/

setup_detectron:
	wget https://github.com/facebookresearch/detectron2/archive/refs/tags/v0.5.zip
	unzip v0.5.zip
	mv detectron2-0.5 detectron2
	cp detectron2_changes/config/defaults.py detectron2/detectron2/config/defaults.py
	cp detectron2_changes/engine/defaults.py detectron2/detectron2/engine/defaults.py
	cp detectron2_changes/modeling/meta_arch/rcnn.py detectron2/detectron2/modeling/meta_arch/rcnn.py
	python -m pip install -e detectron2

setup:
	python -m pip install --upgrade pip
	python -m pip install -r requirements.txt
	make spacy
	make setup_detectron

spacy:
	python -m spacy download en_core_web_sm

eval: 
	python evaluate_ooc.py

image:
	docker build \
		-f Dockerfile \
		-t cosmos:latest \
		-t cosmos:$$(date +%s) \
		.

run:
	docker run \
		--rm \
		-v $${PWD}/data:/data \
		--name=cosmos_cont \
		cosmos:latest