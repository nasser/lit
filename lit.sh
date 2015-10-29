#!/bin/bash
# given a filename ending in .md, return the base filename
function remove_extension {
  local file=$1
  # file extension .md will always have three characters
  local extension_length=3
  # old file path length
  local old_length=${#file}
  # calculate new filename length
  local new_length=$old_length-$extension_length
  # cut substring for new filename
  local new_filename=${file:0:$new_length}
  # return the new string
  echo "$new_filename"
}
# strip Markdown
function process_lines {
  # first argument is filename
  local file=$1
  # iterate through lines with awk
  local awk_command='
      # if it is a code block
      if (/^```/) {
        # increase backtick counter
        i++;
        # jump to next command
        next;
      }
      # print
      if ( i % 2 == 1) {
        print;
      }
  '
  # run awk command
  local processed=$(awk {"$awk_command"} $file)
  # return code blocks only
  echo "$processed"
}
# compile Markdown code blocks in a file using awk
function compile {
  # first argument is filename
  local file=$1
  # conver to the new filename
  local new_filename=$(remove_extension $file "md")
  # log message
  echo "compiling $file > $new_filename"
  # parse file content and remove Markdown comments
  local compiled=$(process_lines $file)
  # save results to file
  echo "$compiled" > $new_filename
}
# if the first argument exists, use it as the
# target directory
if [ $1 ]; then
  files=$1
# otherwise load all files in current directory
else
  # files must end in .md and must contain TWO
  # dots so as to exclude regular non-source
  # Markdown files
  files=*.*.md
fi

# loop through files
for file in $files
do
  # compile
  compile $file
done
