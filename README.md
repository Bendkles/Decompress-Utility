# Decompress Utility

## Overview

This utility is a bash script designed to decompress files of various types. It supports several compression types including gzip, bzip2, Zip, and POSIX. The utility can operate on individual files or recursively on directories. It also supports a verbose mode that outputs additional information.

## Use Cases

This utility can be used in any situation where you need to decompress files. For example:

- You have downloaded a collection of compressed files and want to decompress them all at once.
- You are working with a large dataset that has been compressed to save space, and you need to decompress the files to process the data.
- You are a system administrator who needs to decompress log files for analysis.

## How to Use

To use this utility, you simply run the script and provide the names of the files you want to decompress as arguments. Here are some examples:

- To decompress a single file:

  ```bash
  ./decompress.sh myfile.gz
  ```

- To decompress multiple files:

  ```bash
  ./decompress.sh file1.bz2 file2.gz file3.zip
  ```

- To decompress all files in a directory recursively:

  ```bash
  ./decompress.sh -r mydirectory
  ```

- To run in verbose mode:

  ```bash
  ./decompress.sh -v myfile.gz
  ```

## Options

- `-r`: Enables recursive mode. If a directory is provided as an argument, the script will traverse the directory recursively and decompress all files in it.
- `-v`: Enables verbose mode. The script will output additional information about each file it processes.

## Functions

- `decompress_file`: This function takes a file name as an argument and attempts to decompress the file. It first determines the compression type of the file, then retrieves the appropriate decompression command from an associative array, and finally attempts to decompress the file. If the decompression is successful, it increments a counter of successfully decompressed files. If the decompression fails, it increments a counter of files that were not decompressed.

- `traverse_directory`: This function takes a directory name as an argument and traverses the directory recursively, decompressing all files in it. It uses the `find` command to generate a list of all files in the directory, and then calls `decompress_file` on each file.

## Error Handling

If a file cannot be decompressed, the script will output an error message and increment a counter of files that were not decompressed. If the `-v` option is used, the script will also output a message for each file that is ignored because it is not a recognized compressed file.

## Output

At the end of its execution, the script will print the number of archives that were decompressed and the number of files that were not decompressed.
