import os
import subprocess
import re
import shutil

print('Chuong trinh xoa node_modules'.center(50))
print('\n\n')

find_command = 'find {cwd} -maxdepth 5 -type d -name node_modules'.format(
    cwd=os.getcwd()).split()


stdout, _ = subprocess.Popen(find_command,
                          stdout=subprocess.PIPE, stderr=subprocess.DEVNULL).communicate()

stdout = str(stdout, 'utf-8')

if len(stdout) == 0:
    print('Co ve nhu khong co node_modules duoc tim thay, bye bye!\n')
    os._exit(1)

node_module_paths = []
unique_node_module_paths = []

for node_module_path in stdout.splitlines():
    node_module_paths.append(node_module_path)

for path in node_module_paths:
    # match = re.search(r'^/(\w+/)+node_modules', path)
    i = path.index('node_modules')
    p = path[0:i+len('node_modules')]
    if i != -1 and p not in unique_node_module_paths:
        unique_node_module_paths.append(p)

if len(unique_node_module_paths) > 0:
    print("\n========= Da tim thay {} thu muc node_modules ===========\n".format(len(unique_node_module_paths)))
else:
    os._exit(1)
print('Index'.center(10) + '||', 'Path\n')
for idx, path in enumerate(unique_node_module_paths):
    print('{}|| {}'.format(str(idx).center(10), path))
print('\n\n')

ids_to_keep = []
while True:
    ids = input('Nhap index ban muon giu lai (ngan cach boi dau phay), hoac bo trong neu muon xoa het: ')
    ids_to_keep = ids.split(',')
    try:
        for idx, v in enumerate(ids_to_keep):
            ids_to_keep[idx] = int(v)
            if ids_to_keep[idx] < 0 or ids_to_keep[idx] > len(unique_node_module_paths) - 1:
                raise ValueError
    except ValueError:
        print('Index khong hop le, vui long nhap lai')
        continue

    break

for idx, path in enumerate(unique_node_module_paths):
    if idx not in ids_to_keep:
        try:
            subprocess.Popen('rm -rf {}'.format(path).split(), stderr=subprocess.STDOUT)
            print('Idx: {}, {} removed'.format(idx, path))
        except:
            print('Khong the xoa {}, da co loi xay ra'.format(path))

print('\nThank you, happy day!\n')