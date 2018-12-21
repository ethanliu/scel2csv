#  scel2csv

Convert SCEL dictionary from Sogou to CSV file with lexicon, weight and pinyin columns separated by tab.

    scel2csv - version 1.0
    Convert Sogou SCEL dictionary to CSV with lexicon, weight and pinyin columns.

    Usage:
    scel2csv -s scel_path [-o output_csv_path] [-w 1234] [-t]

    Options:
    -h to show usage information
    -s scel_path
    -o output_csv_path
    -w lexicon weight
    -t to transform from Simplified Chinese to Traditional Chinese

## Description

This parser was original created for OkidoKey app for iOS for testing purpose.  
Therefore this is a command line tool and only works on macos platform.  

- dictionary/*.swift was taken from Tonwen, remove duplicate and convert to swift dictionary
- memory usage or performance is not a concern in current purpose


