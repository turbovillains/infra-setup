nomad
===

## API Snippet
```
curl \
	--cacert ${NOMAD_CACERT} \
	--cert ${NOMAD_CLIENT_CERT} \
	--key ${NOMAD_CLIENT_KEY} \
    --header "X-Nomad-Token: ${NOMAD_TOKEN}" \
    ${NOMAD_ADDR}/v1/jobs
```