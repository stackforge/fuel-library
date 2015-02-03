#!/usr/bin/python
import os
import sys
import json
import subprocess
from novaclient.client import Client
from optparse import OptionParser

parser = OptionParser()
parser.add_option("--create_zones", action="store_false", help="Create needed \
                  availability zones and puts coresponding compute services \
                  in corresponding availability zones")
parser.add_option("--delete_network_services", action="store_false",
                  help="Delete unusable nova-network services from computes")
(options, args) = parser.parse_args()


def get_data_from_hiera(key):
    cmd_data = subprocess.Popen("hiera " + key, shell=True,
                                stdout=subprocess.PIPE).stdout.read(). \
        replace('=>', ':').replace('nil', '"null"')
    try:
        data = json.loads(cmd_data)
    except:
        data = {key: cmd_data.strip()}
    return data


def check_availability_zones(nova_client, compute):
    nova_zones = nova_client.availability_zones.list()
    nova_aggregates = nova_client.aggregates.list()
    compute_zone = compute['availability_zone_name']
    a = next((az for az in nova_zones if az.to_dict()['zoneName'] ==
             compute_zone), None)
    b = next((az for az in nova_aggregates
             if az.to_dict()['availability_zone'] == compute_zone), None)
    if not (a or b):
        print "Zone " + compute_zone + " is missing, creating it."
        nova_client.aggregates.create(compute_zone, compute_zone)
    else:
        print "Zone " + compute_zone + " already present."


def check_host_in_zone(nova_client, compute):
    nova_zones = nova_client.availability_zones.list()
    nova_aggregates = nova_client.aggregates.list()
    compute_zone = compute['availability_zone_name']
    compute_host = compute_zone + "-" + compute['service_name']

    for aggregate in nova_aggregates:
        if aggregate.to_dict()['name'] == compute_zone:
            host_aggregate = aggregate

    c = next((az for az in nova_zones if compute_host in
             az.to_dict()['hosts'] and az.to_dict()['zoneName'] ==
              compute_zone), None)
    if c is None:
        print "Compute service " + compute['service_name'] + " not in " + \
            compute_zone + " zone. " + "Adding."
        nova_client.aggregates.add_host(host_aggregate, compute_host)
    else:
        print "Compute service " + compute['service_name'] + " already in " + \
            compute_zone + " zone."


def delete_nova_service(client, service_id):
            client.services.delete(service_id)

use_vcenter = get_data_from_hiera('use_vcenter')
if use_vcenter is not True:
    sys.exit(0)

credentials = get_data_from_hiera('access')
USERNAME = credentials['user']
PASSWORD = credentials['password']
PROJECT_ID = credentials['tenant']
VERSION = 2
IP = get_data_from_hiera('management_vip')['management_vip']
AUTH_URL = "http://" + IP + ":5000/v2.0/"

nova = Client(VERSION, USERNAME, PASSWORD, PROJECT_ID, AUTH_URL)
vcenter_settings = get_data_from_hiera('vcenter')

if options.create_zones. is True:
    for compute in vcenter_settings['computes']:
        print "---Start of Compute service " + compute['service_name'] + \
            " zone creation.---"
        check_availability_zones(nova, compute)
        check_host_in_zone(nova, compute)
        print "----End of Compute service " + compute['service_name'] + \
            "----\n"
elif options.delete_network_services is True:
    for node in nodes:
        if node['role'] == 'compute':
            network_services = nova.services.list(node['name'], 'nova-network')
            for network_service in network_services:
                print "Found unusable nova-network on " + node['name'] + \
                    " compute node, deleting it."
                delete_nova_service(nova, network_service.to_dict()['id'])
