#!/usr/bin/env -S fish --no-config

set archive_file logs.7z
set concat_file $archive_file.concat.txt
echo "" > $concat_file # idempotence
for file in $argv
  echo -e "\n## $file\n" >> $concat_file
  cat $file >> $concat_file
end
7z a $archive_file $argv

set trash_folder logs(pwd | sed "s#/#-#g")
echo $trash_folder
mkdir -- $trash_folder
mv $argv $trash_folder
trash $trash_folder
