#!/bin/python3

import subprocess
import select
import time
import threading
import socket
import sys
import select
import datetime

class ClientThread(threading.Thread):
    def __init__(self, conn: socket.socket, address):
        threading.Thread.__init__(self)
        self.conn = conn
        self.address = address
        self.closed = False

    def run(self):
        self.conn.sendall(b'Connection established\n')
        while True:
            try:
                command = self.conn.recv(64)
                if len(command) == 0:  # User has disconnected
                    self.conn.close()
                    self.closed = True
                    break
                else:
                    command = command.decode().strip()
                    if command == 'log nginx mdconference.vn':
                        tail_command = 'tail -f /var/log/nginx/dental.phuong.com'
                        f = subprocess.Popen(
                            tail_command.split(),
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE
                        )
                        p = select.poll()
                        p.register(f.stdout)

                        while True:
                            if p.poll(1):
                                data = '{}\n'.format(f.stdout.readline().decode().strip())
                                try:
                                    self.conn.sendall(data.encode())
                                except:
                                    raise SystemExit()
                            time.sleep(0.1)

                        # self.conn.sendall('###STOP\n'.encode())
                    else:
                        self.conn.sendall(
                            'Unknown command: {}\n'.format(command).encode())
            except Exception as e:
                print(e)
                self.closed = True
                self.conn.close()
                break

    def is_closed(self):
        return self.closed


sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.bind(('localhost', 60000))

connection_list = []

connection = None
sock.listen(1)

while True:
    conn, client_address = sock.accept()

    # Remove closed connection
    connection_list = list(
        filter(lambda c: c.is_closed() == False, connection_list))

    client_thread = ClientThread(conn, client_address)
    client_thread.start()
    connection_list.append(client_thread)
    print(connection_list)
