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
package flashx.textLayout.elements
{
	public class CellCoordinates
	{
		private var _column:int;
		private var _row:int;
		public function CellCoordinates(row:int,column:int)
		{
			_row = row;
			_column = column;
		}

		public function get column():int
			{return _column;}
		public function set column(value:int):void
			{_column = value;}

		public function get row():int
			{return _row;}
		public function set row(value:int):void
			{_row = value;}
		
		public static function areEqual(coords1:CellCoordinates,coords2:CellCoordinates):Boolean
		{
			return coords1.row == coords2.row && coords1.column == coords2.column;
		}
		
		public function isValid():Boolean
		{
			return column > -1 && row > -1;
		}
		
		public function clone():CellCoordinates
		{
			return new CellCoordinates(row,column);
		}

	}
}