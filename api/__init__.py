import json
import logging
from enum import Enum
from pathlib import Path

log = logging.getLogger(__name__)
logging.basicConfig(
    level=logging.DEBUG,
    datefmt='%H:%M:%S',
    format='%(asctime)s %(message)s'
)
root = Path(__file__).resolve().parent.parent


class Repo(Enum):
    sd = 'superdesk/superdesk'
    sds = 'superdesk/superdesk-core'
    sdc = 'superdesk/superdesk-client-core'


def get_conf():
    path = root / 'config.json'
    if path.exists():
        conf = (root / 'config.json').read_text()
        conf = json.loads(conf)
    else:
        conf = {}

    defaults = [
        ('debug', False),
        ('debug_aio', False),
        ('lxc_base', 'base-sd'),
        ('lxc_data', 'data-sd'),
        ('domain', 'localhost'),
        ('logurl', lambda c: 'http://%s/' % c['domain']),
        ('e2e_chunks', 1),
        ('use_cpus', ''),
        ('no_statuses', False),
        ('url_prefix', ''),
        ('status_prefix', 'fire:'),

        ('github_auth', None),
        ('github_id', None),
        ('github_secret', None),
        ('github_orgs', ['superdesk']),
        ('github_callback', '/oauth_callback/github'),
    ]
    for key, value in defaults:
        if callable(value):
            value = value(conf)
        conf.setdefault(key, value)
    return conf


conf = get_conf()