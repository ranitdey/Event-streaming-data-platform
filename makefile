get-lambda-zip:
	@echo ___ Starting Lambda zip creation Utility ____
	@echo ___ Running Ubuntu container ___
	docker run -dit --name ubuntu ubuntu:latest
	@echo ___ copying requirements file to container ___
	docker cp ./consumer_lambda/requirements.txt ubuntu:/root/requirements.txt
	docker exec -it ubuntu bash -c "apt -y update \
		&& apt install -y python3-pip \
		&& apt-get install -y zip \
		&& cd /root/ \
		&& pwd \
		&& mkdir -p build/python/lib/python3.8/site-packages \
		&& python3.8 -m pip install --upgrade pip \
		&& mkdir -p dependencies/ \
		&& pip install -r /root/requirements.txt -t dependencies/ \
		&& cd dependencies/ \
		&& zip -r package.zip ."
	docker cp ubuntu:/root/dependencies/package.zip ./consumer_lambda/
	cd ./consumer_lambda/ \
	&& zip -r package.zip .
	rm -f ./output/*
	mv ./consumer_lambda/package.zip ./output/
	docker container rm -f ubuntu

run-lambda-tests:
	@echo ___ Starting Lambda test running Utility ____
	@echo ___ Running Ubuntu container ___
	docker run -dit --name ubuntu ubuntu:latest
	@echo ___ copying source to container ___
	docker cp ./consumer_lambda/ ubuntu:/root/
	docker exec -it ubuntu bash -c "apt -y update \
		&& apt install -y python3-pip \
		&& apt-get install -y zip \
		&& cd /root/ \
		&& pwd \
		&& mkdir -p build/python/lib/python3.8/site-packages \
		&& python3.8 -m pip install --upgrade pip \
		&& pip install -r /root/consumer_lambda/requirements.txt  \
		&& pip install boto3 \
		&& export AWS_DEFAULT_REGION=us-east-1 \
		&& export subscription_table_name=user_subscription \
		&& export user_table_name=user \
		&& export PYTHONPATH="/root/consumer_lambda/" \
		&& pytest /root/consumer_lambda/tests/"
	docker container rm -f ubuntu

