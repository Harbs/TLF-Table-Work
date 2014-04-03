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
		
		private var columns:Vector.<TableColElement> = new Vector.<TableColElement>;
		private var rows:Vector.<TableRowElement> = new Vector.<TableRowElement>;
		private var _childrenValidated:Boolean;
		
		public function TableElement()
		{
			super();
		}
		
		override public function replaceChildren(beginChildIndex:int, endChildIndex:int, ...rest):void{
			var args:Array = [beginChildIndex,endChildIndex].concat(rest);
			super.replaceChildren.apply( this, args );
			_childrenValidated = false;
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
			return  (elem is TableBodyElement) || (elem is TableRowElement) || (elem is TableColElement) || (elem is TableColGroupElement);
		}
		
		/** @private if its in a numbered list expand the damage to all list items - causes the numbers to be regenerated */
		tlf_internal override function modelChanged(changeType:String, elem:FlowElement, changeStart:int, changeLen:int, needNormalize:Boolean = true, bumpGeneration:Boolean = true):void
		{
			super.modelChanged(changeType,elem,changeStart,changeLen,needNormalize,bumpGeneration);
		}
		/** @private */
		private function validateRowsAndColumns():void
		{
			if(_childrenValidated){return;}
			
			var rowArr:Array = [];
			var colArr:Array = [];
			for(var i:int=0;i<mxmlChildren.length;i++)
			{
				if(mxmlChildren[i] is TableColElement)
					colArr.push(mxmlChildren[i]);
				else if(mxmlChildren[i] is TableRowElement)
					rowArr.push(mxmlChildren[i]);
			}
			for(i=0;i<rowArr.length;i++){
				if(rows[i] != rowArr[i])
					rows[i] = rowArr[i];
			}
			if(rows.length != rowArr.length)
				rows.length = rowArr.length;
			
			for(i=0;i<colArr.length;i++){
				if(columns[i] != colArr[i])
					columns[i] = colArr[i];
			}
			if(columns.length != colArr.length)
				columns.length = colArr.length;
			
			_childrenValidated = true;
		}
		public function get numRows():int
		{
			validateRowsAndColumns();
			return rows.length;
		}
		
		public function get numColumns():int
		{
			validateRowsAndColumns();
			return columns.length;
		}
		public function set numRows(value:int):void
		{
			while(value < numRows){
				removeChild(rows[rows.length-1]);
			}
			var num:int = numRows;
			for(var i:int = num;i<value;i++){
				addChild(new TableRowElement(defaultRowFormat));
			}
		}

		public function set numColumns(value:int):void
		{
			while(value < numColumns){
				removeChild(columns[columns.length-1]);
			}
			var num:int = numColumns;
			for(var i:int = num;i<value;i++){
				addChild(new TableColElement(defaultColumnFormat));
			}
		}
		private var _defaultRowFormat:ITextLayoutFormat;

		public function get defaultRowFormat():ITextLayoutFormat
		{
			if(!_defaultRowFormat)
				_defaultRowFormat = new TextLayoutFormat();
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
				_defaultColumnFormat = new TextLayoutFormat();
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
			
			var insertIdx:int = 0;
			if(rows.length){
				insertIdx = getChildIndex(rows[idx]);
			} else if(columns.length){
				insertIdx = getChildIndex(columns[columns.length-1]);
			}
			if(!format)
				format = defaultRowFormat;
			
			addChildAt(insertIdx,new TableRowElement(format));
		}

		public function addColumn(format:ITextLayoutFormat=null):void{
			addColumnAt(rows.length,format);
		}
		public function addColumnAt(idx:int,format:ITextLayoutFormat=null):void{
			if(idx < 0 || idx > columns.length)
				throw RangeError(GlobalSettings.resourceStringFunction("badPropertyValue"));
			
			var insertIdx:int = 0;
			if(rows.length){
				insertIdx = getChildIndex(columns[idx]);
			}
			if(!format)
				format = defaultColumnFormat;
			
			addChildAt(insertIdx,new TableColElement(format));
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
		
		public function setColumnWidth(columnIndex:int, value:*):Boolean
		{
			var tableColElement:TableColElement = getColumnAt(columnIndex) as TableColElement;
			if ( ! tableColElement )
				return false;
			
			tableColElement.tableColumnWidth = value;
			return true;
		}
		
		public function getColumnWidth(columnIndex:int):*
		{
			var tableColElement:TableColElement = getColumnAt(columnIndex) as TableColElement;
			if ( tableColElement )
				return tableColElement.tableColumnWidth;
			return 0;
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
		
	}
}
