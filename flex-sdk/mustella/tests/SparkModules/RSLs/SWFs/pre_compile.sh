#!/bin/sh
################################################################################
##
##  Licensed to the Apache Software Foundation (ASF) under one or more
##  contributor license agreements.  See the NOTICE file distributed with
##  this work for additional information regarding copyright ownership.
##  The ASF licenses this file to You under the Apache License, Version 2.0
##  (the "License"); you may not use this file except in compliance with
##  the License.  You may obtain a copy of the License at
##
##      http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.
##
################################################################################
echo "***************************************"
echo ""
echo ""
echo ""
echo $SDK_DIR/bin
echo ""
echo ""
echo ""
echo "***************************************"
rm -f `find . -name "lnkReport.*"`
$SDK_DIR/bin/mxmlc -link-report=lnkReport.xml MainApp.mxml
cd assets
echo "Removing previously compiled files..."
rm -f `find . -name "*.swf"`
echo "Compiling module SWFs..."
$SDK_DIR/bin/mxmlc -load-externs=../lnkReport.xml  -static-rsls=true AnotherDataGridModule.mxml
$SDK_DIR/bin/mxmlc -load-externs=../lnkReport.xml  -static-rsls=true DataGridModule.mxml
$SDK_DIR/bin/mxmlc -load-externs=../lnkReport.xml  -static-rsls=true ComboModule.mxml
