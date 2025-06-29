#!/usr/bin/env bash

export CSV_FILE=/manifests/cloud-resource-operator.clusterserviceversion.yaml

export EPOC_TIMESTAMP=$(date +%s)
# time for some direct modifications to the csv
python3 - << CSV_UPDATE
import os
from collections import OrderedDict
from sys import exit as sys_exit
from datetime import datetime
from ruamel.yaml import YAML
yaml = YAML()
def load_manifest(pathn):
   if not pathn.endswith(".yaml"):
      return None
   try:
      with open(pathn, "r") as f:
         return yaml.load(f)
   except FileNotFoundError:
      print("File can not found")
      exit(2)

def dump_manifest(pathn, manifest):
   with open(pathn, "w") as f:
      yaml.dump(manifest, f)
   return
timestamp = int(os.getenv('EPOC_TIMESTAMP'))
datetime_time = datetime.fromtimestamp(timestamp)
cro_csv = load_manifest(os.getenv('CSV_FILE'))

# For 1.1.6 remove replaces
if 'spec' in cro_csv and 'replaces' in cro_csv['spec']:
    del cro_csv['spec']['replaces']
    
# Add arch and os support labels
cro_csv['metadata']['labels'] = cro_csv['metadata'].get('labels', {})
cro_csv['metadata']['labels']['operatorframework.io/os.linux'] = 'supported'
# Ensure that the created timestamp is current
cro_csv['metadata']['annotations']['createdAt'] = datetime_time.strftime('%d %b %Y, %H:%M')
# Add annotations for the openshift operator features
cro_csv['metadata']['annotations']['features.operators.openshift.io/disconnected'] = 'true'
cro_csv['metadata']['annotations']['features.operators.openshift.io/fips-compliant'] = 'false'
cro_csv['metadata']['annotations']['features.operators.openshift.io/proxy-aware'] = 'false'
cro_csv['metadata']['annotations']['features.operators.openshift.io/tls-profiles'] = 'false'
cro_csv['metadata']['annotations']['features.operators.openshift.io/token-auth-aws'] = 'false'
cro_csv['metadata']['annotations']['features.operators.openshift.io/token-auth-azure'] = 'false'
cro_csv['metadata']['annotations']['features.operators.openshift.io/token-auth-gcp'] = 'false'
cro_csv['metadata']['annotations']['features.operators.openshift.io/cnf'] = 'false'
cro_csv['metadata']['annotations']['features.operators.openshift.io/cni'] = 'false'
cro_csv['metadata']['annotations']['features.operators.openshift.io/csi'] = 'false'

dump_manifest(os.getenv('CSV_FILE'), cro_csv)
CSV_UPDATE

cat $CSV_FILE