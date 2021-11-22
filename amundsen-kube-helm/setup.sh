echo -e "Step 1. uninstalling existing amundsen svc"
helm uninstall amundsen -n amundsen
echo -e "Step 2. creating docker image for search component"



helm install amundsen ./templates/helm --values ./templates/helm/values.yaml \
	--set oidc.enabled=true \
	--set oidc.frontend.client_id=1090327900887-3eg2tqrp3616t1m6vjtc3a1v4sd49cp7.apps.googleusercontent.com \
	--set oidc.frontend.client_secret=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 \
	--set oidc.metadata.client_id=1090327900887-3eg2tqrp3616t1m6vjtc3a1v4sd49cp7.apps.googleusercontent.com \
	--set oidc.metadata.client_secret=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 \
	--set oidc.search.client_id=1090327900887-3eg2tqrp3616t1m6vjtc3a1v4sd49cp7.apps.googleusercontent.com \
	--set oidc.search.client_secret=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 \
	--set search.image=9990666275/amundsen-search \
	--set search.imageTag=latest \
	--set search.proxy.endpoint=https://amundsen-74d7fa.es.us-central1.gcp.cloud.es.io:9243 \
	--set search.user=elastic \
	--set search.password=Aa94TjoC0sDxUL0jyJGiV36Q \
	--set metadata.image=amundsendev/amundsen-metadata-oidc \
	--set metadata.imageTag=3.9.0 \
	--set metadata.proxy.host=bolt://0385fa13.databases.neo4j.io \
	--set metadata.proxy.user=neo4j \
	--set metadata.proxy.password=YBI5p5iNmtAey5Q70OemSJxQF0mFi9gFuV82trbP0qk \
	--set frontEnd.image=amundsendev/amundsen-frontend-oidc \
	--set frontEnd.imageTag=3.11.1 \
	--set frontEnd.config.class=amundsen_application.oidc_config.OidcConfig \
	--set elasticsearch.enabled=false \
	--set neo4j.enabled=false \
	-n amundsen

