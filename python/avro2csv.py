#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# avro2csv - Avro file converter to CSV
# Copyright (c) 2021 Paulo Vital <paulo@vital.eng.br>
#
# Requirements: pip install avro
#

import argparse
import csv
import sys

from os.path import basename
from typing import Dict, List, NoReturn

from avro.datafile import DataFileReader
from avro.io import DatumReader


DEBUG = False


def printd(content: str) -> None:
    '''
    Prints DEBUG messages with given content.

    Args:
        content: str   string to print as DEBUG message
    Returns:
        None
    '''
    if DEBUG:
        print(f'---> \033[1;33;40mDEBUG\033[m - {content}')


def init_argparse() -> argparse.ArgumentParser:
    '''
    Initialize the argument parsing.

    Returns:
        argparse.ArgumentParser
    '''
    parser = argparse.ArgumentParser(
        prog='avro2csv',
        usage='%(prog)s [OPTIONS]',
        description='Converts an Avro file into CSV file.'
    )

    parser.add_argument(
        '-i', '--input',
        action='store',
        dest='avro_file',
        default=None, help='Avro file to be converted'
    )

    parser.add_argument(
        '-o', '--output',
        action='store',
        dest='csv_file',
        default=None, help='CSV file to be created'
    )

    parser.add_argument(
        '-d', '--debug',
        action='store_true',
        help='Print debug messages.'
    )

    parser.add_argument(
        '-v', '--version',
        action='version',
        version=f'{parser.prog} version 0.1'
    )

    return parser


def read_avro_file(file: str) -> List[Dict]:
    '''
    Read a given Avro file.
    '''
    printd(f'Reading Avro file {file}')
    avro_file = DataFileReader(open(file, 'rb'), DatumReader())

    ret =[entry for entry in avro_file]    
    avro_file.close()

    printd(f'Read {len(ret)} entries from the Avro file.')

    return ret if len(ret) > 0 else [{}]


def write_csv_file(content: List[Dict], output: str) -> None:
    '''
    Write a given content on a specified output
    '''
    printd(f'Writing CSV file {output}')

    with open(output, 'w') as csv_file:
        dict_writer = csv.DictWriter(csv_file, content[0].keys())
        dict_writer.writeheader()
        dict_writer.writerows(content)
    
    print(f'CSV file {output} created.')


def main() -> NoReturn:
    '''
    Main function
    '''
    global DEBUG

    # Parse the arguments
    parser = init_argparse()
    args = parser.parse_args()

    # Set DEBUG variable
    if args.debug:
        DEBUG = True
        printd('DEBUG mode = ON')
        printd(f'{args}')
    
    # Check arguments
    if not args.avro_file:
        print(f'No Avro file given as input.')
        sys.exit(1)

    if not args.csv_file:
        printd(f'No CSV file name provided. Using Avro file name as base.')
        csv_file = '.'.join(
            [basename(args.avro_file).split('.')[0], 'csv']
        )
    else:
        csv_file = args.csv_file

    # Read Avro file
    avro_content = read_avro_file(args.avro_file)

    # Write content of Avro file into CSV
    write_csv_file(avro_content, csv_file)


if __name__ == '__main__':
   main()
