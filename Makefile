shell:
	docker compose run --rm dev

up:
	docker compose up -d

down:
	docker compose down

rebuild:
	docker compose build --no-cache

clean:
	docker compose down --volumes --remove-orphans
