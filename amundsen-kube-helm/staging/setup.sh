declare POSTGRES_CREDS_STR="$(aws ssm get-parameter --name amundsen-creds-staging | jq ".Parameter.Value")"
POSTGRES_CREDS_STR=$( echo ${POSTGRES_CREDS_STR} | cut -d "\"" -f 2)
IFS=',' read -ra POSTGRES_CREDS_ARR <<< "${POSTGRES_CREDS_STR}"

TRIM() {
        TRIMMED="$(echo -e "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
}

TRIM "${POSTGRES_CREDS_ARR[0]}"; SEARCH_PWD="${TRIMMED}"
TRIM "${POSTGRES_CREDS_ARR[1]}"; SEARCH_ENDPOINT="${TRIMMED}"
TRIM "${POSTGRES_CREDS_ARR[2]}"; META_PWD="${TRIMMED}"
TRIM "${POSTGRES_CREDS_ARR[3]}"; META_HOST="${TRIMMED}"

echo -e "Step 1. uninstalling existing amundsen svc"
helm uninstall amundsen -n amundsen
echo -e "Step 2. booting up amundsen"

helm install amundsen ./templates/helm --values ./templates/helm/values.yaml \
        --set oidc.enabled=false \
        --set search.image=981935913893.dkr.ecr.us-west-2.amazonaws.com/amundsen-staging-search \
        --set search.imageTag=latest \
        --set search.imagePullSecrets[0].name=ecr-registry-secrets \
        --set frontEnd.imagePullSecrets[0].name=ecr-registry-secrets \
        --set metadata.imagePullSecrets[0].name=ecr-registry-secrets \
        --set search.proxy.endpoint=${SEARCH_ENDPOINT} \
        --set search.proxy.user=elastic \
        --set search.proxy.password=${SEARCH_PWD} \
        --set metadata.image=981935913893.dkr.ecr.us-west-2.amazonaws.com/amundsen-staging-metadata \
        --set metadata.imageTag=latest \
        --set metadata.proxy.host=${META_HOST} \
        --set metadata.proxy.user=neo4j \
        --set metadata.proxy.password=${META_PWD}\
        --set frontEnd.image=981935913893.dkr.ecr.us-west-2.amazonaws.com/amundsen-staging-frontend \
        --set frontEnd.imageTag=latest \
        --set frontEnd.config.class=amundsen_application.config.TestConfig \
        --set elasticsearch.enabled=false \
        --set neo4j.enabled=false \
        -n amundsen