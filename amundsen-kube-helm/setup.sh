declare POSTGRES_CREDS_STR="$(aws ssm get-parameter --name amundsen-creds | jq ".Parameter.Value")"
POSTGRES_CREDS_STR=$( echo ${POSTGRES_CREDS_STR} | cut -d "\"" -f 2)
IFS=',' read -ra POSTGRES_CREDS_ARR <<< "${POSTGRES_CREDS_STR}"

TRIM() {
        TRIMMED="$(echo -e "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
}

TRIM "${POSTGRES_CREDS_ARR[0]}"; OIDC_CLIENT_ID="${TRIMMED}"
TRIM "${POSTGRES_CREDS_ARR[1]}"; OIDC_CLIENT_SECRET="${TRIMMED}"
TRIM "${POSTGRES_CREDS_ARR[2]}"; SEARCH_USER="${TRIMMED}"
TRIM "${POSTGRES_CREDS_ARR[3]}"; SEARCH_PWD="${TRIMMED}"
TRIM "${POSTGRES_CREDS_ARR[4]}"; SEARCH_ENDPOINT="${TRIMMED}"
TRIM "${POSTGRES_CREDS_ARR[5]}"; META_USER="${TRIMMED}"
TRIM "${POSTGRES_CREDS_ARR[6]}"; META_PWD="${TRIMMED}"
TRIM "${POSTGRES_CREDS_ARR[7]}"; META_HOST="${TRIMMED}"

echo -e "Step 1. uninstalling existing amundsen svc"
helm uninstall amundsen -n amundsen
echo -e "Step 2. creating docker image for search component"
cd ../search && make oidc-image && make push-oidc-image && cd ../amundsen-kube-helm
echo -e "Step 3. booting up amundsen"

helm install amundsen ./templates/helm --values ./templates/helm/values.yaml \
        --set oidc.enabled=true \
        --set oidc.frontend.client_id=${OIDC_CLIENT_ID} \
        --set oidc.frontend.client_secret=${OIDC_CLIENT_SECRET} \
        --set oidc.metadata.client_id=${OIDC_CLIENT_ID} \
        --set oidc.metadata.client_secret=${OIDC_CLIENT_SECRET} \
        --set oidc.search.client_id=${OIDC_CLIENT_ID} \
        --set oidc.search.client_secret=${OIDC_CLIENT_SECRET} \
        --set search.image=981935913893.dkr.ecr.us-west-2.amazonaws.com/amundsen-staging-search-oidc \
        --set search.imageTag=latest \
        --set search.imagePullSecrets[0].name=ecr-registry-secrets \
        --set search.proxy.endpoint=${SEARCH_ENDPOINT} \
        --set search.proxy.user=elastic \
        --set search.proxy.password=${SEARCH_PWD}\
        --set metadata.image=amundsendev/amundsen-metadata-oidc \
        --set metadata.imageTag=3.9.0 \
        --set metadata.proxy.host=${META_HOST} \
        --set metadata.proxy.user=neo4j \
        --set metadata.proxy.password=${META_PWD}\
        --set frontEnd.image=amundsendev/amundsen-frontend-oidc \
        --set frontEnd.imageTag=3.11.1 \
        --set frontEnd.config.class=amundsen_application.oidc_config.OidcConfig \
        --set elasticsearch.enabled=false \
        --set neo4j.enabled=false \
        -n amundsen