#!/bin/bash

# Script pour générer du trafic sur nginx pour tester le monitoring
# Usage: ./generate-traffic.sh [duration_in_seconds] [requests_per_second]

DURATION=${1:-300}  # 5 minutes par défaut
RPS=${2:-10}        # 10 requêtes par seconde par défaut
URL="http://localhost:8000"

echo "🚀 Génération de trafic sur $URL"
echo "⏱️  Durée: $DURATION secondes"
echo "📊 RPS: $RPS requêtes/seconde"
echo ""

# Fonction pour générer des requêtes variées
generate_request() {
    local endpoints=("/" "/health" "/nginx_status" "/nonexistent" "/error")
    local methods=("GET" "POST" "HEAD")
    local user_agents=(
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36"
        "curl/7.68.0"
        "Python-requests/2.25.1"
    )
    
    local endpoint=${endpoints[$RANDOM % ${#endpoints[@]}]}
    local method=${methods[$RANDOM % ${#methods[@]}]}
    local user_agent=${user_agents[$RANDOM % ${#user_agents[@]}]}
    
    case $method in
        "GET")
            curl -s -o /dev/null -w "%{http_code}" \
                -H "User-Agent: $user_agent" \
                -H "X-Forwarded-For: 192.168.1.$((RANDOM % 255))" \
                "$URL$endpoint" > /dev/null 2>&1
            ;;
        "POST")
            curl -s -o /dev/null -w "%{http_code}" \
                -X POST \
                -H "User-Agent: $user_agent" \
                -H "Content-Type: application/json" \
                -d '{"test": "data"}' \
                "$URL$endpoint" > /dev/null 2>&1
            ;;
        "HEAD")
            curl -s -o /dev/null -w "%{http_code}" \
                -I \
                -H "User-Agent: $user_agent" \
                "$URL$endpoint" > /dev/null 2>&1
            ;;
    esac
}

# Fonction pour générer des erreurs occasionnelles
generate_error() {
    local error_endpoints=("/error" "/nonexistent" "/admin" "/internal")
    local endpoint=${error_endpoints[$RANDOM % ${#error_endpoints[@]}]}
    
    curl -s -o /dev/null -w "%{http_code}" \
        -H "User-Agent: ErrorBot/1.0" \
        "$URL$endpoint" > /dev/null 2>&1
}

# Calcul du délai entre les requêtes
DELAY=$(echo "scale=3; 1/$RPS" | bc -l 2>/dev/null || echo "0.1")

echo "🔄 Début de la génération de trafic..."
echo "⏳ Délai entre requêtes: ${DELAY}s"
echo ""

# Boucle principale
start_time=$(date +%s)
request_count=0

while [ $(($(date +%s) - start_time)) -lt $DURATION ]; do
    # Générer une requête normale (90% du temps)
    if [ $((RANDOM % 10)) -lt 9 ]; then
        generate_request
    else
        # Générer une erreur (10% du temps)
        generate_error
    fi
    
    request_count=$((request_count + 1))
    
    # Afficher le progrès toutes les 10 secondes
    if [ $((request_count % (RPS * 10))) -eq 0 ]; then
        elapsed=$(( $(date +%s) - start_time ))
        remaining=$((DURATION - elapsed))
        echo "📈 $request_count requêtes envoyées (${elapsed}s écoulées, ${remaining}s restantes)"
    fi
    
    sleep $DELAY
done

echo ""
echo "✅ Génération de trafic terminée!"
echo "📊 Total des requêtes envoyées: $request_count"
echo "⏱️  Durée totale: $DURATION secondes"
echo "📈 RPS moyen: $(echo "scale=2; $request_count/$DURATION" | bc -l 2>/dev/null || echo "N/A")"
echo ""
echo "🔍 Vous pouvez maintenant consulter vos tableaux de bord:"
echo "   - Grafana: http://localhost:3000 (admin/admin)"
echo "   - Prometheus: http://localhost:9090"
echo "   - Loki: http://localhost:3100" 