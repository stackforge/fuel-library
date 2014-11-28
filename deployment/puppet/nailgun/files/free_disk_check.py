#!/usr/bin/env python

from datetime import datetime
import json
import logging
import logging.handlers
import os
import requests
import yaml
import sys

log = logging.getLogger('free_disk_check')
log_handler = logging.handlers.SysLogHandler(address='/dev/log')
log_handler.setFormatter(logging.Formatter('%(name)s: %(message)s'))
log.addHandler(log_handler)
log.setLevel(logging.INFO)

API_CONFIG_FILE = '/etc/fuel/client/config.yaml'
ASTUTE_CONFIG_FILE = '/etc/fuel/astute.yaml'
CONFIG_FILE = '/etc/fuel/free-disk-check.yaml'
STATE_FILE = '/var/cache/free_disk_check.yaml'

CONFIG = {
    'FREE_DISK': 3  # In GB, default value
}
try:
    with open(CONFIG_FILE) as f:
        CONFIG.update(yaml.load(f))
except IOError:
    pass

ASTUTE_CONFIG = {}
with open(ASTUTE_CONFIG_FILE) as f:
    ASTUTE_CONFIG = yaml.load(f)

API_CONFIG = {}
with open(API_CONFIG_FILE) as f:
    API_CONFIG = yaml.load(f)

SERVER_URL = 'http://{SERVER_ADDRESS}:{SERVER_PORT}'.format(**API_CONFIG)
AUTH_URL = '{0}/keystone/v2.0/tokens/'.format(SERVER_URL)
NOTIFICATIONS_URL = '{0}/api/notifications/'.format(SERVER_URL)


DEFAULT_STATE_SCHEMA = {
    'alert_date': None,
    'message': '',
}


class RequestFailed(Exception):
    pass


def api_notification(topic, message):
    headers = {
        'Content-Type': 'application/json',
    }

    response = requests.post(
        AUTH_URL,
        data=json.dumps({
            'auth': {
                'tenantName': 'services',
                'passwordCredentials': {
                    'username': ASTUTE_CONFIG['monitord']['user'],
                    'password': ASTUTE_CONFIG['monitord']['password'],
                }
            }
        }),
        headers=headers
    )

    if response.status_code != 200:
        log.critical('Could not authenticate with Keystone: %s', response)
        raise RequestFailed()

    headers['X-Auth-Token'] = response.json()['access']['token']['id']

    response = requests.post(
        NOTIFICATIONS_URL,
        data=json.dumps({
            'topic': topic,
            'message': message,
        }),
        headers=headers
    )

    if response.status_code != 201:
        log.critical('Could not create notification: %s', response)
        raise RequestFailed()


def read_state():
    try:
        f = open(STATE_FILE)
        return yaml.load(f) or DEFAULT_STATE_SCHEMA.copy()
    except IOError:
        # Touch file
        with open(STATE_FILE, 'w'):
            pass

    return DEFAULT_STATE_SCHEMA.copy()


def write_state(value):
    with open(STATE_FILE, 'w') as f:
        f.write(yaml.dump(value, default_flow_style=False))


def error_already_reported():
    return bool(read_state().get('alert_date', False))


def notify(message, topic=None):
    schema = DEFAULT_STATE_SCHEMA.copy()

    now = datetime.now().isoformat()

    if topic == 'error':
        schema['alert_date'] = now
        schema['message'] = message

    log.info('%s: %s', topic, message)

    # Only if request successful then write_state.
    # Otherwise report error and try again later.
    try:
        api_notification(topic, message)
    except RequestFailed:
        sys.exit(1)

    write_state(schema)


def get_disk_space_error():
    """Check free disk space.
    """
    s = os.statvfs('/')
    # Convert to GB
    free_gb = s.f_bavail * s.f_frsize / (1024.0 ** 3)

    if free_gb <= CONFIG['FREE_DISK']:
        return (
            True,
            'Your disk space is running low (%.2f GB currently available).'
            % free_gb
        )

    return (
        False,
        'Your free disk space is back to normal (%.2f GB currently available).'
        % free_gb
    )

if __name__ == '__main__':
    has_error, message = get_disk_space_error()

    if has_error:
        # Notify about detected problems
        if not error_already_reported():
            notify(message, topic='error')
    else:
        # Notify about no more valid problems
        if error_already_reported():
            notify(message, topic='done')

