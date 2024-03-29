#!/usr/bin/env bash

set -euo pipefail

# This script is an integral part of the release workflow: .github/workflows/release.yml
# It requires the following environment variables to function correctly:
#
# REQUESTED_BUILDPACK_ID - The ID of the buildpack to package and push to the container registry.

while IFS="" read -r -d "" buildpack_toml_path; do
	buildpack_id="$(yj -t <"${buildpack_toml_path}" | jq -r .buildpack.id)"
	buildpack_path=$(dirname "${buildpack_toml_path}")
	buildpack_version="$(yj -t <"${buildpack_toml_path}" | jq -r .buildpack.version)"
	buildpack_docker_repository="$(yj -t <"${buildpack_toml_path}" | jq -r .metadata.release.docker.repository)"
	buildpack_build_path="${buildpack_path}"

	if [[ $buildpack_id == "${REQUESTED_BUILDPACK_ID}" ]]; then

		echo "Found buildpack ${buildpack_id} at ${buildpack_path}"

		# Some buildpacks require a build step before packaging. If we detect a build.sh script, we execute it and
		# modify some variables to point to the directory with the built buildpack instead.
		if [[ -f "${buildpack_path}/build.sh" ]]; then
			echo "Buildpack has build script, executing..."
			"${buildpack_path}/build.sh"
			echo "Build finished!"

			buildpack_path="${buildpack_path}/target"
			buildpack_toml_path="${buildpack_path}/buildpack.toml"
		fi

		# We update docker repo to use our docker hub
		jq_filter=".metadata.release.docker.repository |= sub(\"docker.io\"; \"${DOCKER_HUB}\")"
		updated_buildpack_toml=$(yj -t <"${buildpack_toml_path}" | jq "${jq_filter}" | yj -jt)
		echo "${updated_buildpack_toml}" >"${buildpack_toml_path}"

		# Update vars after buildpack.toml manipulations
		buildpack_version="$(yj -t <"${buildpack_toml_path}" | jq -r .buildpack.version)"
		buildpack_docker_repository="$(yj -t <"${buildpack_toml_path}" | jq -r .metadata.release.docker.repository)"
		buildpack_build_path="${buildpack_path}"

		image_name="${buildpack_docker_repository}:${buildpack_version}"
		pack buildpack package --verbose --config "${buildpack_build_path}/package.toml" --publish "${image_name}"

		# We might have local changes after building and/or shimming the buildpack. To ensure scripts down the pipeline
		# work with a clean state, we reset all local changes here.
		# git reset --hard
		# git clean -fdx

		if [[ ! -z "${CI_COMMIT_TAG:-}" ]]; then
			docker pull ${image_name}
			archive_image ${image_name} ${INFRA_VERSION}
		fi

		echo "::set-output name=id::${buildpack_id}"
		echo "::set-output name=version::${buildpack_version}"
		echo "::set-output name=path::${buildpack_path}"
		# echo "::set-output name=address::${buildpack_docker_repository}@$(crane digest "${image_name}")"
		echo "::set-output name=image::${image_name}"
		exit 0
	fi
done < <(find . -name buildpack.toml -print0)
