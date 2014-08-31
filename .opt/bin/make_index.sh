#!/bin/bash

book_title='うさぎさんのClojureノート'
index='index.md'

global_index_buffer='';

main()
{
  pushed_dir=`pwd`

  while [ ! -d .git ]
  do
    cd ..
  done

  top_dir=`pwd`

  dirs=`find . -type d -regex './[^.][^/]+$' | sort`

  for d in $dirs
  do
    make_index $d
  done

  make_global_index

  cd $pushed_dir
}

make_index()
{
  cd $1
  section=`echo $1 | tr -d ./`
  echo [generate: $section/$index]
  rm $index
  echo "# $book_title" >> $index
  echo "- [../${index}](../${index})"  >> $index
  echo ""              >> $index
  echo "## $section"   >> $index
  global_index_buffer+="- [$section]($section/$index)\n"
  for c in `find . -type f -iname '*.md' | sort`
  do
    if [ $c == ./$index  ]; then continue; fi
    content=`echo $c | sed 's|.md$||g' | sed 's|^./||g'`
    echo "  $content"
    echo "- [$content](${content}.md)" >> $index
    global_index_buffer+="    - [$content](${section}/${content}.md)\n"
  done
  cd $top_dir
}

make_global_index()
{
  echo [generate: $index]
  rm $index
  echo "# $book_title" >> $index
  echo -e $global_index_buffer >> $index
}

main
