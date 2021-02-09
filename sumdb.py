import os
import subprocess
import json

containers = {}

# Get all containers
process = subprocess.Popen(
    'docker ps --format {{.Names}}#{{.Ports}}'.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = process.communicate()

# print(str(stdout, 'utf-8'))
# Handle err
if len(str(stderr, 'utf-8')) != 0:
    print('Cannot get containers\'s info, detail: {}'.format(stderr))
    os._exit(1)

info_lines = str(stdout, 'utf-8').splitlines()
for container_info in info_lines:
    # "mongo12999#127.0.0.1:12999->27017/tcp"
    host = '127.0.0.1'
    port = container_info.split('->')[0].split(':')[1]
    name = container_info.split('#')[0]
    containers[name] = {'host': host, 'port': port, 'name': name}

# Get database names of each container
for container_name in containers:
    get_db_name_process = subprocess.Popen(
        'docker exec mongo mongo --quiet --eval printjson(db.adminCommand(\'listDatabases\'))'.split(), stderr=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
    command = "docker exec mongo mongo --quiet --eval printjson(db.adminCommand('listDatabases'))".split(
    )
    stdo, stde = subprocess.Popen(
        command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).communicate()
    stdo = str(stdo, 'utf-8')
    containers[container_name]['databases'] = [database['name'] for database in json.loads(
        stdo)['databases'] if database['name'] not in ['config', 'admin', 'local']]
    print(containers[container_name])

# Create dump folder

dump_folder_path = os.path.join(os.getcwd(), 'dump')
if not os.path.exists(dump_folder_path):
    os.mkdir(dump_folder_path)

# Dump database

for container_name in containers:
    # create dump directory for each particular database
    tmp_dump_path = os.path.join(dump_folder_path, container_name)
    if not os.path.exists(tmp_dump_path):
        os.mkdir(tmp_dump_path)
    # Loop each database(string) of each instance
    for database_name in containers[container_name]['databases']:
        out_archive = os.path.join(tmp_dump_path, database_name + '.tar.gz')
        os.system('mongodump --host {host} --port {port} --db {dbname} --archive={out_path}'.format(
            host=containers[container_name]['host'], port=containers[container_name]['port'], out_path=out_archive, dbname=database_name))
        os.system('mongorestore --archive="{out_archive}" --nsFrom="{db_name}.*" --nsTo="{container_name}_{db_name}.*" '.format(
            out_archive=out_archive, db_name=database_name, container_name=container_name))
