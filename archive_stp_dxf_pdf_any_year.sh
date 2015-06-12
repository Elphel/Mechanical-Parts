#!/bin/sh
#**
#** -----------------------------------------------------------------------------**
#** archive_stp_dxf.sh
#** Preparing Varicad output files output for uploadig to wiki.elphel.com:
#** 1 - adding license information to *.stp files output
#** 2 - compressing *.dwb, *.dxf and *.stp files
#** 3 - cropping and converting *.bmp renderings to JPEG
#**
#** Copyright (C) 2010-2011 Elphel, Inc.
#**
#** -----------------------------------------------------------------------------**
#**
#**  focus_tuning.java is free software: you can redistribute it and/or modify
#**  it under the terms of the GNU General Public License as published by
#**  the Free Software Foundation, either version 3 of the License, or
#**  (at your option) any later version.
#**
#**  This program is distributed in the hope that it will be useful,
#**  but WITHOUT ANY WARRANTY; without even the implied warranty of
#**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#**  GNU General Public License for more details.
#**
#**  You should have received a copy of the GNU General Public License
#**  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#** -----------------------------------------------------------------------------**

#Replacing description and organization tags in STEP 3D files.
#Varicad outputs them as:
#...
#FILE_DESCRIPTION(
#/* description */ ('VariCAD 2010-3.03 AP-214'),
#/* implementation_level */ '2;1');
#
#FILE_NAME(
#/* name */ '0353-22-10-test-load-saved',
#/* time_stamp */ '2011-10-13T17:21:56-06:00',
#/* author */ (''),
#/* organization */ (''),
YEAR=`date +"%Y"`
DESCRIPTION="(C) Elphel, Inc. $YEAR. Licensed under CERN OHL v.1.1 or later, see http://ohwr.org/cernohl";
ORGANIZATION="Elphel, Inc";
process_step_files() {
#  DESCRIPTION="(C) Elphel, Inc. 2013. Licensed under CERN OHL v.1.1 or later, see http://ohwr.org/cernohl";
#  ORGANIZATION="Elphel, Inc";
  echo "Adding >$DESCRIPTION< and >$ORGANIZATION< to >$1<"
  mv $1 $1.original
  cat $1.original | sed -e "s#\* description \*/ [(]'[^']*'[)]#* description */ ('$DESCRIPTION')#g" | sed -e "s#\* organization \*/ [(]'[^']*'[)]#* organization */ ('$ORGANIZATION')#g" > $1
  tar -czvf $1.tar.gz $1
  mv $1.original $1
}
process_pdf_files() {
  if [ -z "`which pdftk`" ] ; then
    echo "pdftk is not installed, pdf metadata will not be edited. You may install pdftk with"
    echo "sudo apt-get install pdftk"
  else
   fullname=$(basename $1)
   filename=${fullname%.*}
   echo $filename
#cat  << EOF
cat >pdfmeta << EOF
InfoKey: Author
InfoValue: Elphel, Inc.
InfoKey: Title
InfoValue: $filename (C) Elphel, Inc. $YEAR
InfoKey: Subject
InfoValue: $DESCRIPTION
InfoKey: Producer
InfoValue: Qt 4.7.0 (C) 2010 Nokia Corporation and/or its subsidiary(-ies)
EOF
  mv $1 $1~
  pdftk $1~ update_info pdfmeta output $1
  rm pdfmeta
  fi
}

if [ -n "$1" ]; then
  $@
  #  DESCRIPTION="(C) Elphel, Inc. 2013. Licensed under CERN OHL v.1.1 or later, see http://ohwr.org/cernohl";
  #  ORGANIZATION="Elphel, Inc";
  #  echo "Adding >$DESCRIPTION< and >$ORGANIZATION< to >$1<"
  #  mv $1 $1.original
  #  cat $1.original | sed -e "s#\* description \*/ [(]'[^']*'[)]#* description */ ('$DESCRIPTION')#g" | sed -e "s#\* organization \*/ [(]'[^']*'[)]#* organization */ ('$ORGANIZATION')#g" > $1
  #  tar -czvf $1.tar.gz $1
  #  mv $1.original $1
else
  #find . -maxdepth 1 -iname '*.stp' -exec $0 '{}' \;
  find . -maxdepth 1 -iname '*.stp' -exec $0 process_step_files '{}' \;
  find . -maxdepth 1 -iname '*.pdf' -exec $0 process_pdf_files '{}' \;
  find . -maxdepth 1 -iname '*.dxf' -exec tar '-czvf' '{}'.tar.gz '{}' \;
  find . -maxdepth 1 -iname '*.igs' -exec tar '-czvf' '{}'.tar.gz '{}' \;
  find . -maxdepth 1 -iname '*.dwb' -exec tar '-czvf' '{}'.tar.gz '{}' \;
  
  # Process all bmps
  # b - border size in pixels
  b=20
  for f in *.bmp *.jpg *.png
  do
    #if there are no *.bmp it still runs once?!
    if [ -f $f ]; then 
      filename=$(basename $f)
      name=${filename%.*}
      crop=`convert -trim -format %[fx:w+2*$b]x%[fx:h+2*$b]+%[fx:page.X-$b]+%[fx:page.Y-$b] $f info:`
      convert $f -crop $crop "$name.jpeg";
      convert "$name.jpeg" -resize 250 $name"_resized.jpeg"
    fi
  done
    
 exit 0
fi
#