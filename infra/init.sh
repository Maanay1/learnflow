#!/bin/bash
set -e

echo "Starting LearnFlow..."
docker compose up -d
echo "Waiting for services..."
sleep 10
echo "Running migrations..."
docker compose exec backend /app/bin/learnflow rpc 'Ecto.Migrator.run(Learnflow.Repo, :up, all: true)'
echo "Seeding database..."
docker compose exec backend /app/bin/learnflow rpc 'Code.eval_file(:code.priv_dir(:learnflow) |> Path.join("repo/seeds.exs"))'
echo ""
echo "LearnFlow is running!"
echo "Frontend: http://localhost:3000"
echo "Backend:  http://localhost:4000"
echo "MinIO:    http://localhost:9001"
