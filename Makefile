download_detectron:
	-rm -rf ./*.zip[0-9]
	-rm -rf detectron2/
	wget https://github.com/facebookresearch/detectron2/archive/refs/tags/v0.4.zip
	unzip v0.4.zip
	rm v0.4.zip
	mv detectron2-0.4 detectron2

setup_detectron:
	make download_detectron
	cp detectron2_changes/config/defaults.py detectron2/detectron2/config/defaults.py
	cp detectron2_changes/engine/defaults.py detectron2/detectron2/engine/defaults.py
	cp detectron2_changes/modeling/meta_arch/rcnn.py detectron2/detectron2/modeling/meta_arch/rcnn.py
	cp detectron2_changes/modeling/meta_arch/build.py detectron2/detectron2/modeling/meta_arch/build.py
	python -m pip install -e detectron2

setup:
	python -m pip install --upgrade pip
	python -m pip install -r requirements.txt
	make spacy
	make setup_detectron

spacy:
	python -m spacy download en
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

dev:
	docker run \
        -it \
		--rm \
		-v $${PWD}/data/:/data/ \
		-v $${PWD}/model_archs/:/model_archs/ \
		-v $${PWD}/models_final/:/models_final/ \
		-v $${PWD}/detectron2_changes/config/defaults.py:/detectron2/detectron2/config/defaults.py \
		-v $${PWD}/detectron2_changes/engine/defaults.py:/detectron2/detectron2/engine/defaults.py \
		-v $${PWD}/detectron2_changes/modeling/meta_arch/rcnn.py:/detectron2/detectron2/modeling/meta_arch/rcnn.py \
		-v $${PWD}/detectron2_changes/modeling/meta_arch/build.py:/detectron2/detectron2/modeling/meta_arch/build.py \
        -v $${PWD}/evaluate_ooc.py:/evaluate_ooc.py \
		-v $${PWD}/Makefile:/Makefile \
        --name=cosmos_cont \
        cosmos:latest \
        bash

baseline:
	python evaluate_ooc.py --model=mmsys21-gc-cheapfakes-baseline-model

replicate:
	docker run \
		--rm \
		-v $${PWD}/data:/data \
		-v $${PWD}/models_final/:/models_final/ \
		--name=cosmos_cont \
		cosmos:latest \
		make baseline

temp:
	cp detectron2/detectron2/modeling/meta_arch/build.py detectron2_changes/modeling/meta_arch/build.py