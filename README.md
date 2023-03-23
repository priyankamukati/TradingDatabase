docker compose up
docker compose down
docker exec -it tradingplatform-db-1 psql -U postgres -W
docker inspect postgresql -f “{{json .NetworkSettings.Networks }}”