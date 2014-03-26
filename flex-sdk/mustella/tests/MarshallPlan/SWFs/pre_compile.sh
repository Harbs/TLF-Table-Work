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
cd assets

echo "Removing previously compiled files..."
rm -f `find . -name "*.swf"`


echo "Compiling sub application SWFs..."
$SDK_DIR/bin/mxmlc -includes=mx.managers.systemClasses.MarshallingSupport -source-path=$MUSTELLA_DIR/as3/src/mustella -includes=UnitTester simpleForms.mxml
$SDK_DIR/bin/mxmlc -includes=mx.managers.systemClasses.MarshallingSupport -source-path=$MUSTELLA_DIR/as3/src/mustella -includes=UnitTester simpleLoader.mxml
$SDK_DIR/bin/mxmlc -includes=mx.managers.systemClasses.MarshallingSupport -source-path=$MUSTELLA_DIR/as3/src/mustella -includes=UnitTester tabbs.mxml

echo "Compiling RSL"

if ([ -e MyUtils ])
then
cd MyUtils
rm -rf * 
cd ..
rmdir MyUtils	
fi

$SDK_DIR/bin/compc -include-classes=MyUtils -sp=. -directory=true -output=MyUtils

$SDK_DIR/bin/mxmlc -static-link-runtime-shared-libraries=false -rslp=MyUtils,MyUtils/library.swf  -remove-unused-rsls=true -includes=mx.managers.systemClasses.MarshallingSupport SubApp.mxml
$SDK_DIR/bin/mxmlc -static-link-runtime-shared-libraries=false -rslp=MyUtils,MyUtils/library.swf  -remove-unused-rsls=true -includes=mx.managers.systemClasses.MarshallingSupport UntrustedApp.mxml