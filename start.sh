#!/bin/bash

# Script de démarrage rapide pour l'infrastructure de monitoring
# Usage: ./start.sh

set -e

echo "🚀 Démarrage de l'infrastructure de monitoring..."
echo ""

# Vérifier que Docker est installé
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

# Vérifier que Docker Compose est installé
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

# Créer les dossiers nécessaires s'ils n'existent pas
echo "📁 Création des dossiers de données..."
mkdir -p nginx/logs
mkdir -p prometheus/data
mkdir -p grafana/data
mkdir -p loki/data

# Démarrer les services
echo "🐳 Démarrage des services Docker..."
docker-compose up -d

# Attendre que les services soient prêts
echo "⏳ Attente du démarrage des services..."
sleep 10

# Vérifier le statut des services
echo "🔍 Vérification du statut des services..."
docker-compose ps

echo ""
echo "✅ Infrastructure démarrée avec succès !"
echo ""
echo "🌐 Accès aux services :"
echo "   📄 Page d'accueil : http://localhost:8000"
echo "   📊 Grafana        : http://localhost:3000 (admin/admin)"
echo "   📈 Prometheus     : http://localhost:9090"
echo "   📝 Loki           : http://localhost:3100"
echo "   🔍 Node Exporter  : http://localhost:9100"
echo ""
echo "🚀 Pour générer du trafic de test :"
echo "   ./scripts/generate-traffic.sh 300 10"
echo ""
echo "📋 Pour voir les logs :"
echo "   docker-compose logs -f [service]"
echo ""
echo "🛑 Pour arrêter :"
echo "   docker-compose down" 