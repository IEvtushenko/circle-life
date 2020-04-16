up: docker-up

stop: docker-stop

init: api-php-create-env \
    docker-clean \
    docker-up \
    api-php-composer \
    api-php-migration \
    api-php-migration-test \
    api-php-fixtures \
    frontend-nodejs-create-env \
    frontend-install \
    frontend-build \
    api-php-oauth2-setup

api-php-database: api-php-migration \
    api-php-fixtures

api-php-create-env:
	rm -f api/.env.local
	cp api/.env api/.env.local

api-php-apply-local-env:
	rm -f api/.env
	cp api/.env.local api/.env
	rm -f api/.env.test
	cp api/.env.test.local api/.env.test

docker-clean:
	docker-compose down --remove-orphans

docker-up:
	docker-compose up --build -d

docker-stop:
	docker-compose stop

api-php-composer:
	docker-compose exec api-php composer install

api-php-migration:
	docker-compose exec api-php bin/console doctrine:database:drop --connection=default --if-exists --force
	docker-compose exec api-php bin/console doctrine:database:create -n -vvv
	docker-compose exec api-php bin/console doctrine:migrations:migrate -n -vvv
	docker-compose exec api-php bin/console doctrine:database:drop --connection=old_wms --if-exists --force
	docker-compose exec api-php bin/console doctrine:database:create --connection=old_wms -n -vvv
	docker-compose exec api-php bin/console doctrine:schema:create --em=old_wms -n -vvv

api-php-migration-test:
	docker-compose exec api-php bin/console doctrine:database:drop --env=test --connection=default --if-exists --force
	docker-compose exec api-php bin/console doctrine:database:create --env=test -n -vvv
	docker-compose exec api-php bin/console doctrine:migrations:migrate --env=test -n -vvv
	docker-compose exec api-php bin/console doctrine:database:drop --env=test --connection=old_wms --if-exists --force
	docker-compose exec api-php bin/console doctrine:database:create --env=test --connection=old_wms -n -vvv
	docker-compose exec api-php bin/console doctrine:schema:create --env=test --em=old_wms -n -vvv

api-php-oauth2-setup:
	docker-compose exec api-php mkdir -p var
	docker-compose exec api-php chmod -R 0777 var
	docker-compose exec api-php openssl genrsa -out var/private.key 2048
	docker-compose exec api-php openssl rsa -in var/private.key -pubout -out var/public.key
	docker-compose exec api-php chmod 0777 var/private.key
	docker-compose exec api-php chmod 0777 var/public.key
	docker-compose exec api-php sed -i 's/SSL_PRIVATE_KEY_PATH=\(.*\)/SSL_PRIVATE_KEY_PATH\=\/var\/www\/var\/private.key/g' .env.local
	docker-compose exec api-php sed -i 's/SSL_PUBLIC_KEY_PATH=\(.*\)/SSL_PUBLIC_KEY_PATH\=\/var\/www\/var\/public.key/g' .env.local
	docker-compose exec api-php sed -i 's/SSL_ENCRYPTION_KEY=\(.*\)/SSL_ENCRYPTION_KEY\='$$(php -r "echo md5(time());")'/g' .env.local

api-php-fixtures:
	docker-compose exec api-php bin/console doctrine:fixtures:load --em=old_wms --group=old_wms -n -vvv
	docker-compose exec api-php bin/console doctrine:fixtures:load --em=default --group=wms -n -vvv

composer-update:
	docker-compose exec api-php composer update


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

frontend-lint:
	docker-compose exec frontend-nodejs yarn run lint

frontend-update:
	docker-compose exec frontend-nodejs yarn upgrade

frontend-tests:
	docker-compose exec frontend-nodejs yarn test


tests:
	docker-compose exec api-php bin/phpunit

phpcs:
	docker-compose exec api-php composer run phpcs --timeout 5000

phpcs-summary:
	docker-compose exec api-php composer run phpcs-summary --timeout 5000

phplint:
	docker-compose exec api-php composer run phplint

phpstan:
	docker-compose exec api-php composer run phpstan

swagger:
	docker-compose exec api-php composer run swagger
