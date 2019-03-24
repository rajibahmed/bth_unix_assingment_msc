#!/usr/bin/env python3

import sys
import argparse
import collections

parser = argparse.ArgumentParser('Httpd Log Analyzer')

parser.add_argument('-2', '--success', action='store_true',
                    help='successful connections')
parser.add_argument('-c', '--best', action='store_true', help='best attemtps')
parser.add_argument('-d', '--days', help='days')
parser.add_argument('-F', '--failures', help='Faliures from ips')
parser.add_argument('-H', '--hours', type=int, help='hours of the day')
parser.add_argument('-r', '--common', action='store_true',
                    help='common code from ips')
parser.add_argument('-n', '--number',
                    type=int,
                    help='number of results')
parser.add_argument(
    '-f', '--file',
    type=argparse.FileType('r'),
    default=sys.stdin,
    help='file path'
)
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
    for ip, count in collections.Counter(ips).most_common(num_of_lines):
        print(f'{ip}\t{count}')


def successful_connection_attempts(data, num_of_lines):
    ips = []
    for line in data:
        ip, *_, status = line.split()[0:9]
        if int(status) == 200:
            ips.append(ip)
    display_list(ips, num_of_lines)


def common_status_codes(data, num_of_lines):
    ips = []
    for line in data:
        ip, *_, status = line.split()[0:9]
        ips.append((ip, status))

    for (ip, status), count in collections.Counter(ips).most_common(num_of_lines):
        print(f'{ip}\t{status}\t{count}')


def best_attempts(data, num_of_lines):
    ips = []
    for line in data:
        ips.append(line.split()[0])
    display_list(ips, num_of_lines)


if args.hours:
    if args.hours not in range(1, 23):
        sys.stderr.write('Hours must be 0-23')
    data = [line for line in data
            if args.hours == int(line.split()[3].split(':')[1])]

if args.best:
    best_attempts(data, args.number)

if args.success:
    successful_connection_attempts(data, args.number)

if args.common:
    common_status_codes(data, args.number)

sys.exit(0)
