frontend-nodejs-create-env:
	rm -f frontend/.env.local
	cp frontend/.env.local.example frontend/.env.local

frontend-install:
	docker-compose exec frontend-nodejs yarn install

frontend-build:
	docker-compose exec frontend-nodejs yarn run build

frontend-serve:
	docker-compose exec frontend-nodejs yarn serve

frontend-watch:
	docker-compose exec frontend-nodejs yarn run watch