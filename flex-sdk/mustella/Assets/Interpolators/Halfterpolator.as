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
package Interpolators
{
	import spark.effects.interpolation.IInterpolator;

	public class Halfterpolator implements IInterpolator
	{
		public function Halfterpolator()
		{
		}

		public function get interpolatedType():Class
		{
			return null;
		}
		
		public function interpolate(fraction:Number, startValue:Object, endValue:Object):Object
		{
			return(.5);
		}
		
		public function increment(baseValue:Object, incrementValue:Object):Object
		{
			return null;
		}
		
		public function decrement(baseValue:Object, decrementValue:Object):Object
		{
			return null;
		}
		
	}
}