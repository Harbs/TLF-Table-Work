////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package
{
	import mx.core.RuntimeDPIProvider;
	
	public class InvalidValues extends RuntimeDPIProvider
	{
		
		public var num:uint = 3;
		
		public function InvalidValues()
		{
			super();
		}
		
		override public function get runtimeDPI():Number
		{
			
			var myNum:Number;
			
			switch(num){
				case 1: myNum = NaN; break;
				case 2: myNum = 0; break;
				case 3: myNum = -160; break;
				case 4: myNum = 160.000000000001; break;
				
			}
			
			return myNum;
					
		}
		
		
	}
}