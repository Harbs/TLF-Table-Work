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
	import flash.events.IEventDispatcher;
	import flash.globalization.NumberParseResult;
	
	public interface NF_ModuleInterface extends IEventDispatcher
	{
		
		function format(value:Number):String
		function parse(parseString:String):NumberParseResult
		function parseNumber(parseString:String):Number
		function get actualLocaleIDName():String
		function set locale(value:String):void
		function get fractionalDigits():int
		function set fractionalDigits(value:int):void
		function get useGrouping():Boolean
		function set useGrouping(value:Boolean):void
		function get groupingPattern():String
		function set groupingPattern(value:String):void
		function get digitsType():uint
		function set digitsType(value:uint):void
		function get decimalSeparator():String
		function set decimalSeparator(value:String):void
		function get groupingSeparator():String
		function set groupingSeparator(value:String):void
		function get negativeSymbol():String
		function set negativeSymbol(value:String):void
		function get negativeNumberFormat():uint
		function set negativeNumberFormat(value:uint):void
		function get leadingZero():Boolean
		function set leadingZero(value:Boolean):void
		function get trailingZeros():Boolean
		function set trailingZeros(value:Boolean):void
		
	}
}