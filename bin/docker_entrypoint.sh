#!/bin/sh -eux

if [ "$1" = "nginx" ]; then
    defined_envs=$(printf '${%s} ' $(env | cut -d= -f1))
    output_dir="${NGINX_ENVSUBST_OUTPUT_DIR:-/etc/nginx/conf.d}"
    suffix="${NGINX_ENVSUBST_TEMPLATE_SUFFIX:-.template}"
    template_dir="${NGINX_ENVSUBST_TEMPLATE_DIR:-/etc/nginx/templates}"
    find "$template_dir" -follow -type f -name "*$suffix" -print | while read -r template; do
        relative_path="${template#$template_dir/}"
        output_path="$output_dir/${relative_path%$suffix}"
        subdir=$(dirname "$relative_path")
        mkdir -p "$output_dir/$subdir"
        envsubst "$defined_envs" < "$template" > "$output_path"
    done
fi
exec "$@"
