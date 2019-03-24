#!/usr/bin/env python3

import sys
import argparse
import collections

parser = argparse.ArgumentParser('Httpd Log Analyzer version')

parser.add_argument('-2', '--success', action='store_true',
                    help='successful connections')
parser.add_argument('-c', '--best', action='store_true', help='best attemtps')
parser.add_argument('-d', '--days', help='days')
parser.add_argument('-F', '--failures', help='Faliures from ips')
parser.add_argument(
    '-f', '--file', type=argparse.FileType('r'), default=sys.stdin, help='file path')
parser.add_argument('-H', '--hours', help='hours of the day')
parser.add_argument('-n', '--number', type=int, help='number of results')
parser.add_argument('-r', help='common code from ips')
parser.add_argument('-v', '--version', action='version',
                    version='%(prog)s 1.0')


# fails and print when no option or stdin given
if len(sys.argv) == 1 and sys.stdin.isatty():
    parser.print_help()
    sys.exit(1)

# when arguments are passed
args = parser.parse_args()
data = args.file.readlines()


def display_list(ips, num_of_lines):
    for ip, count in collections.Counter(ips).most_common()[:num_of_lines]:
        print(f'{ip}\t{count}')


def successful_connection_attempts(data, num_of_lines):
    ips = []
    for line in data:
        ip, _, _, _, _, _, _, _, status, *_ = line.split()
        if int(status) == 200:
            ips.append(ip)
    display_list(ips, num_of_lines)


def best_attempts(data, num_of_lines=1):
    ips = []
    for line in data:
        ips.append(line.split()[0])
    display_list(ips, num_of_lines)


if args.best:
    best_attempts(data, args.number)

if args.success:
    successful_connection_attempts(data, args.number)
