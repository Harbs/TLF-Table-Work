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
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.events.FlowElementEventDispatcher;
	import flashx.textLayout.events.FlowElementMouseEventManager;
	import flashx.textLayout.events.ModelChange;
	import flashx.textLayout.formats.*;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
	
	
	/** 
	 * The TableElement class is used for grouping together items into a table. 
	 * A TableElement's children must be of type TableRowElement, TableColElement, TableColGroupElement, TableBodyElement.
	 * 
	 * 
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 *
	 */
	public class TableElement extends TableFormattedElement 
	{
		
		private var _height:Array = []; // parcel-indexed
		public var computedWidth:Number;
		
		public var x:Number;
		public var y:Number;
		
		//These attributes is from the original loop prototype. Maybe changed later
		public var totalRowDepth:Number = undefined;
		public var originParcelIndex:Number;
		public var numAcrossParcels:int;
        public var curRowIdx:int = 0; // this value should be only used while composing
        public var outOfLastParcel:Boolean = false; 
		
		private var columns:Vector.<TableColElement> = new Vector.<TableColElement>();
		private var rows:Vector.<TableRowElement> = new Vector.<TableRowElement>();
		private var damagedColumns:Vector.<TableColElement> = new Vector.<TableColElement>();
		private var damageRows:Vector.<TableRowElement> = new Vector.<TableRowElement>();
		private var _hasCellDamage:Boolean = true;
		
		public function TableElement()
		{
			super();
		}
		
		/** @private */
		override protected function get abstract():Boolean
		{ return false; }
		
		/** @private */
		tlf_internal override function get defaultTypeName():String
		{ return "table"; }
		
		/** @private */
		tlf_internal override function canOwnFlowElement(elem:FlowElement):Boolean
		{
			return  (elem is TableBodyElement) || (elem is TableCellElement); //(elem is TableRowElement) || (elem is TableColElement) || (elem is TableColGroupElement);
		}
		
		/** @private if its in a numbered list expand the damage to all list items - causes the numbers to be regenerated */
		tlf_internal override function modelChanged(changeType:String, elem:FlowElement, changeStart:int, changeLen:int, needNormalize:Boolean = true, bumpGeneration:Boolean = true):void
		{
			super.modelChanged(changeType,elem,changeStart,changeLen,needNormalize,bumpGeneration);
		}
		
		public function get numRows():int
		{
			return rows.length;
		}
		
		public function get numColumns():int
		{
			return columns.length;
		}
		public function set numRows(value:int):void
		{
			while(value < numRows){
				rows.pop();
			}
			var num:int = numRows;
			for(var i:int = num;i<value;i++){
				rows.push(new TableRowElement(defaultRowFormat));
			}
		}

		public function set numColumns(value:int):void
		{
			while(value < numColumns){
				columns.pop();
			}
			var num:int = numColumns;
			for(var i:int = num;i<value;i++){
				columns.push(new TableColElement(defaultColumnFormat));
			}
		}
		private var _defaultRowFormat:ITextLayoutFormat;

		public function get defaultRowFormat():ITextLayoutFormat
		{
			if(!_defaultRowFormat)
				_defaultRowFormat = new TextLayoutFormat(computedFormat);
			return _defaultRowFormat;
		}

		public function set defaultRowFormat(value:ITextLayoutFormat):void
		{
			_defaultRowFormat = value;
		}
		
		private var _defaultColumnFormat:ITextLayoutFormat;

		public function get defaultColumnFormat():ITextLayoutFormat
		{
			if(!_defaultColumnFormat)
				_defaultColumnFormat = new TextLayoutFormat(computedFormat);
			return _defaultColumnFormat;
		}

		public function set defaultColumnFormat(value:ITextLayoutFormat):void
		{
			_defaultColumnFormat = value;
		}
		
		public function addRow(format:ITextLayoutFormat=null):void{
			addRowAt(rows.length,format);
		}
		public function addRowAt(idx:int,format:ITextLayoutFormat=null):void{
			if(idx < 0 || idx > rows.length)
				throw RangeError(GlobalSettings.resourceStringFunction("badPropertyValue"));
			
			rows.splice(idx,0,new TableRowElement(format));
		}

		public function addColumn(format:ITextLayoutFormat=null):void{
			addColumnAt(rows.length,format);
		}
		public function addColumnAt(idx:int,format:ITextLayoutFormat=null):void{
			if(idx < 0 || idx > columns.length)
				throw RangeError(GlobalSettings.resourceStringFunction("badPropertyValue"));
			
			columns.splice(idx,0,new TableColElement(format));
		}

		public function getColumnAt(columnIndex:int):TableColElement
		{
			if ( columnIndex < 0 || columnIndex >= numColumns )
				return null;
			return columns[columnIndex];
		}
		
		public function getRowAt(rowIndex:int):TableRowElement
		{
			if ( rowIndex < 0 || rowIndex >= numRows )
				return null;
			return rows[rowIndex];
		}
		public function insertColumn(column:TableColElement):Boolean{
			return insertColumnAt(numColumns,column);
		}
		public function insertColumnAt(idx:int,column:TableColElement):Boolean{
			if(idx < 0 || idx > columns.length)
				throw RangeError(GlobalSettings.resourceStringFunction("badPropertyValue"));
			
			columns.splice(idx,0,column);
			return true;
		}
		
		public function insertRow(row:TableRowElement):Boolean{
			return insertColumnAt(numRows,row);
		}
		public function insertRowAt(idx:int,row:TableColElement):Boolean{
			if(idx < 0 || idx > rows.length)
				throw RangeError(GlobalSettings.resourceStringFunction("badPropertyValue"));
			
			rows.splice(idx,0,row);
			return true;
		}
		public function removeRow(row:TableRowElement):Boolean{
			var i:int = rows.indexOf(row);
			if(i < 0)
				return false;
			rows.splice(i,1);
			return true;
		}
		public function removeRowAt(idx:int):Boolean{
			if(idx < 0 || idx > rows.length - 1)
				return false;
			
			rows.splice(idx,1);
			return true;
		}
		
		public function removeColumn(column:TableColElement):Boolean{
			var i:int = columns.indexOf(column);
			if(i < 0)
				return false;
			columns.splice(i,1);
			return true;
		}
		public function removeColumnAt(idx:int):Boolean{
			if(idx < 0 || idx > columns.length - 1)
				return false;
			
			columns.splice(idx,1);
			return true;
		}
		
		public function setColumnWidth(columnIndex:int, value:*):Boolean
		{
			//TODO: changing the column width probably requires a recompose of all cells in that column. Mark the cells in that row damaged.
			var tableColElement:TableColElement = getColumnAt(columnIndex);
			if ( ! tableColElement )
				return false;
			
			tableColElement.tableColumnWidth = value;
			return true;
		}
		
		public function setRowHeight(rowIdx:int, value:*):Boolean{
			//TODO: setting the row hieght might change the composition height of the cells. We'll need to do some housekeeping here.
			// I'm not sure this function makes sense. We need to handle both min and max values to allow for expanding cells.
			var row:TableRowElement = getRowAt(rowIdx);
			if(!row)
				return false;
			
			return true;
		}
		public function getColumnWidth(columnIndex:int):*
		{
			var tableColElement:TableColElement = getColumnAt(columnIndex) as TableColElement;
			if ( tableColElement )
				return tableColElement.tableColumnWidth;
			return 0;
        }
		
		public function composeCells():void{
			// make sure the height that defines the row height did not change. If it did we might need to change the row height.
			if(!hasCellDamage)
				return;
			var damaagedCells:Vector.<TableCellElement> = getDamagedCells();
			var cell:TableCellElement;
			for each(cell in damaagedCells){
				// recompose the cells while tracking row height if necessary
			}
		}
        
		private function getDamagedCells():Vector.<TableCellElement>{
			var cells:Vector.<TableCellElement> = new Vector.<TableCellElement>();
			for each (var cell:* in this.mxmlChildren){
				if((cell is TableCellElement) && cell.isDamaged())
					cells.push(cell as TableCellElement);
			}
			return cells;
		}
        public function get height():Number
        {
            return _height[numAcrossParcels];
        }
        
        public function set height(val:*):void
        {
            _height[numAcrossParcels] = val;
        }
        
        public function get heightArray():Array
        {
            return _height;
        }
        
        public function set heightArray(newArray:Array):void
        {
            _height = newArray;
        }

		public function get hasCellDamage():Boolean
		{
			return _hasCellDamage;
		}

		public function set hasCellDamage(value:Boolean):void
		{
			_hasCellDamage = value;
		}

		
	}
}
