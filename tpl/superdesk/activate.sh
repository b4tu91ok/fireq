# you could write variables to {{config}}
. {{repo_env}}/bin/activate

set -a
LC_ALL=en_US.UTF-8
PYTHONUNBUFFERED=1
PATH={{repo_client}}/node_modules/.bin/:$PATH

[ ! -f {{config}} ] || . {{config}}

HOST=${HOST:-'localhost'}
HOST_SSL=${HOST_SSL:-}
DB_HOST=${DB_HOST:-'localhost'}
DB_NAME=${DB_NAME:-'{{name}}'}

[ -n "${HOST_SSL:-}" ] && SSL='s' || SSL=''
# To work properly inside and outside container, must be
# - "proxy_set_header Host <host>;" in nginx
# - the same "<host>" for next two settings
# TODO: try to fix at backend side, it should accept any host
SUPERDESK_URL="http$SSL://$HOST/api"
CONTENTAPI_URL="http$SSL://$HOST/contentapi"
SUPERDESK_WS_URL="ws$SSL://$HOST/ws"
SUPERDESK_CLIENT_URL="http$SSL://$HOST"
PRODAPI_URL="http$SSL://$HOST"
PRODAPI_URL_PREFIX=prodapi
AUTH_SERVER_SHARED_SECRET=7fZOf0VI9T70vU5uNlKLrc5GlabxVgl6
# internal request is http not https
# see nginx.conf
AUTHLIB_INSECURE_TRANSPORT=1

MONGO_URI="mongodb://$DB_HOST/$DB_NAME"
LEGAL_ARCHIVE_URI="mongodb://$DB_HOST/${DB_NAME}_la"
ARCHIVED_URI="mongodb://$DB_HOST/${DB_NAME}_ar"

# use elastic based on superdesk-core config
_ELASTIC_PORT=${ELASTIC_PORT:-'9200'}
[ -f {{fireq_json}} ] && [ `jq ".elastic?" {{fireq_json}}` -eq 7 ] && _ELASTIC_PORT=9201
ELASTICSEARCH_URL="http://$DB_HOST:$_ELASTIC_PORT"
ELASTICSEARCH_INDEX="$DB_NAME"


CONTENTAPI_ELASTICSEARCH_INDEX="${DB_NAME}_ca"
# TODO: fix will be in 1.6 release, keep it for a while
CONTENTAPI_ELASTIC_INDEX=$CONTENTAPI_ELASTICSEARCH_INDEX
CONTENTAPI_MONGO_URI="mongodb://$DB_HOST/${CONTENTAPI_ELASTICSEARCH_INDEX}"

REDIS_URL=${REDIS_URL:-redis://$DB_HOST:6379/1}

C_FORCE_ROOT=1
CELERYBEAT_SCHEDULE_FILENAME=${CELERYBEAT_SCHEDULE_FILENAME:-/tmp/celerybeatschedule}
CELERY_BROKER_URL=${CELERY_BROKER_URL:-$REDIS_URL}

if [ -n "$AMAZON_CONTAINER_NAME" ]; then
    AMAZON_S3_SUBFOLDER=${AMAZON_S3_SUBFOLDER:-'{{db_name}}'}
    MEDIA_PREFIX=${MEDIA_PREFIX:-"http$SSL://$HOST/api/upload-raw"}

    # TODO: remove after full adoption of MEDIA_PREFIX
    AMAZON_SERVE_DIRECT_LINKS=${AMAZON_SERVE_DIRECT_LINKS:-True}
    AMAZON_S3_USE_HTTPS=${AMAZON_S3_USE_HTTPS:-True}
fi

if [ -n "${SUPERDESK_TESTING:-}" ]; then
    SUPERDESK_TESTING=True
    CELERY_ALWAYS_EAGER=True
    ELASTICSEARCH_BACKUPS_PATH=/var/tmp/elasticsearch
    LEGAL_ARCHIVE=True
fi

# scope custom env for {{scope}}
{{env_string}}

{{^is_superdesk}}
### Liveblog custom
S3_THEMES_PREFIX=${S3_THEMES_PREFIX:-"/{{db_name}}/"}
EMBEDLY_KEY=${EMBEDLY_KEY:-}
{{/is_superdesk}}
set +a
