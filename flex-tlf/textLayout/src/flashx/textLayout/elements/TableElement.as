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
	import flashx.textLayout.compose.TextFlowTableBlock;
	import flashx.textLayout.events.ModelChange;
	import flashx.textLayout.formats.FormatValue;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
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
		
		private var _headerRowCount:uint = 0;
		private var _footerRowCount:uint = 0;
		private var _tableRowsComputed:Boolean;
		
		private var _headerRows:Vector.< Vector.<TableCellElement> >;
		private var _footerRows:Vector.< Vector.<TableCellElement> >;
		private var _bodyRows:Vector.< Vector.<TableCellElement> >;
		private var _composedRowIndex:uint = 0;
		
		private var _tableBlocks:Vector.<TextFlowTableBlock>;
		private var _tableBlockIndex:uint = 0;
		
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
			return (elem is TableCellElement); // (elem is TableBodyElement) ||  //(elem is TableRowElement) || (elem is TableColElement) || (elem is TableColGroupElement);
		}
		
		/** @private if its in a numbered list expand the damage to all list items - causes the numbers to be regenerated */
		tlf_internal override function modelChanged(changeType:String, elem:FlowElement, changeStart:int, changeLen:int, needNormalize:Boolean = true, bumpGeneration:Boolean = true):void
		{
			switch(changeType)
			{
				case ModelChange.ELEMENT_ADDED:
				case ModelChange.ELEMENT_REMOVAL:
					if(headerRowCount > 0 || footerRowCount > 0){
						
					}
			}
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
			
			var row:TableRowElement = new TableRowElement(format)
			rows.splice(idx,0,row);
			row.composedHeight = row.computedFormat.minCellHeight;
			row.isMaxHeight = row.computedFormat.minCellHeight == row.computedFormat.maxCellHeight;
		}

		public function addColumn(format:ITextLayoutFormat=null):void{
			addColumnAt(columns.length,format);
		}
		public function addColumnAt(idx:int,format:ITextLayoutFormat=null):void{
			if(idx < 0 || idx > columns.length)
				throw RangeError(GlobalSettings.resourceStringFunction("badPropertyValue"));
			if(!format)
				format = defaultColumnFormat;
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
		public function getCellsForRow(index:int):Array{
			var retVal:Array = [];
			for each(var cell:TableCellElement in this.mxmlChildren){
				if(cell.rowIndex == index)
					retVal.push(cell);
			}
			return retVal;
		}
		public function insertColumn(column:TableColElement=null,cells:Array = null):Boolean{
			return insertColumnAt(numColumns,column,cells);
		}
		public function insertColumnAt(idx:int,column:TableColElement=null,cells:Array = null):Boolean{
			if(idx < 0 || idx > columns.length)
				throw RangeError(GlobalSettings.resourceStringFunction("badPropertyValue"));
			if(!column)
				column = new TableColElement(defaultColumnFormat);
			columns.splice(idx,0,column);
			
			var blockedCoords:Vector.<CellCoords> = getBlockedCoords(-1,idx);
			var cellIdx:int = getCellIndex(0,idx);
			var rowIdx:int = 0;
			while(cells.length < numRows){
				cells.push(new TableCellElement());
			}
			for each(var cell:TableCellElement in cells){
				while(blockedCoords.length && blockedCoords[0].row == rowIdx){
					rowIdx++;
					blockedCoords.shift();
				}
				cellIdx = getCellIndex(rowIdx,idx);
				if(rowIdx < numRows){
					addChildAt(cellIdx,cell);
				}
			}


			return true;
		}
		
		public function insertRow(row:TableRowElement=null,cells:Array = null):Boolean{
			return insertRowAt(numRows,row,cells);
		}
		
		public function insertRowAt(idx:int,row:TableRowElement=null,cells:Array = null):Boolean{
			if(idx < 0 || idx > rows.length)
				throw RangeError(GlobalSettings.resourceStringFunction("badPropertyValue"));
			if(!row)
				row = new TableRowElement(defaultRowFormat);
			rows.splice(idx,0,row);
			row.composedHeight = row.computedFormat.minCellHeight;
			row.isMaxHeight = row.computedFormat.minCellHeight == row.computedFormat.maxCellHeight;

			var blockedCoords:Vector.<CellCoords> = getBlockedCoords(idx);
			var cellIdx:int = getCellIndex(idx,0);
			var colIdx:int = 0;
			while(cells.length < numColumns){
				cells.push(new TableCellElement());
			}
			for each(var cell:TableCellElement in cells){
				while(blockedCoords.length && blockedCoords[0].column == colIdx){
					colIdx++;
					blockedCoords.shift();
				}
				if(colIdx < numColumns){
					addChildAt(cellIdx,cell);
					cellIdx++;
				}
			}
			return true;
		}
		
		public function removeRow(row:TableRowElement):TableRowElement {
			var i:int = rows.indexOf(row);
			if(i < 0)
				return null;
			return removeRowAt(i);
		}
		
		public function removeRowWithContent(row:TableRowElement):Array
		{
			var i:int = rows.indexOf(row);
			if(i < 0)
				return null;
			return removeRowWithContentAt(i);
		}
		
		public function removeRowAt(idx:int):TableRowElement {
			if(idx < 0 || idx > rows.length - 1)
				return null;
			
			var row:TableRowElement = TableRowElement(rows.splice(idx,1)[0]);
			normalizeCells();
			hasCellDamage = true;
			return row;
			
		}
		
		public function removeRowWithContentAt(idx:int):Array
		{

			var removedCells:Array = [];
			if(mxmlChildren){
				for (var i:int = mxmlChildren.length-1;i>=0;i--){
					var child:* = mxmlChildren[i];
					if(!(child is TableCellElement))
						continue;
					var cell:TableCellElement = child as TableCellElement;
					if(cell.rowIndex == idx){
						removedCells.unshift(removeChild(cell));
					}
				}
			}
			removeRowAt(idx);
			return removedCells;
		}
		
		public function removeColumn(column:TableColElement):TableColElement {
			var i:int = columns.indexOf(column);
			if(i < 0)
				return null;
			return removeColumnAt(i);
		}
		public function removeColumnWithContent(column:TableColElement):Array
		{
			var i:int = columns.indexOf(column);
			if(i < 0)
				return null;
			return removeColumnWithContentAt(i);
		}

		
		public function removeColumnAt(idx:int):TableColElement {
			if(idx < 0 || idx > columns.length - 1)
				return null;
			
			var col:TableColElement = columns.splice(idx,1)[0];
			normalizeCells();
			hasCellDamage = true;
			return col;
		}
		
		public function removeColumnWithContentAt(idx:int):Array
		{
			
			var removedCells:Array = [];
			if(mxmlChildren){
				for (var i:int = mxmlChildren.length-1;i>=0;i--){
					var child:* = mxmlChildren[i];
					if(!(child is TableCellElement))
						continue;
					var cell:TableCellElement = child as TableCellElement;
					if(cell.colIndex == idx){
						removedCells.unshift(removeChild(cell));
					}
				}
			}
			removeColumnAt(idx);

			return removedCells;
		}
		private function getBlockedCoords(inRow:int = -1, inColumn:int = -1):Vector.<CellCoords>{
			var coords:Vector.<CellCoords> = new Vector.<CellCoords>();
			if(mxmlChildren)
			{
				for each(var child:* in mxmlChildren){
					var cell:TableCellElement = child as TableCellElement;
					if(cell.columnSpan == 1 && cell.rowSpan == 1)
						continue;
					var curRow:int = cell.rowIndex;
					if(inRow >= 0 && curRow != inRow)
						continue;
					if(inColumn >= 0 && inColumn != curColumn)
						continue;
					var curColumn:int = cell.colIndex;
					var endRow:int = curRow + cell.rowSpan - 1;
					var endColumn:int = curColumn + cell.columnSpan -1;
					for(var rowIdx:int = curRow;rowIdx <= endRow;rowIdx++){
						for(var colIdx:int = curColumn;colIdx <=endColumn;colIdx++){
							if(rowIdx == curRow && colIdx == curColumn){
								continue;
							}
							coords.push( new CellCoords(colIdx,rowIdx) );
						}
					}

				}
			}
			return coords;
		}
		public function normalizeCells():void
		{
			this.numColumns;this.numRows;
			var i:int;
			var blockedCoords:Vector.<CellCoords> = new Vector.<CellCoords>();
			if(!mxmlChildren)
				return;
			var curRow:int = 0;
			var curColumn:int = 0;
			for each(var child:* in mxmlChildren){
				if(!(child is TableCellElement))
					continue;
				var cell:TableCellElement = child as TableCellElement;
				cell.rowIndex = curRow;
				cell.colIndex = curColumn;
				
				// add blocked coords if the cell spans rows or columns
				var endRow:int = curRow + cell.rowSpan - 1;
				var endColumn:int = curColumn + cell.columnSpan -1;
				for(var rowIdx:int = curRow;rowIdx <= endRow;rowIdx++){
					for(var colIdx:int = curColumn;colIdx <=endColumn;colIdx++){
						if(rowIdx == curRow && colIdx == curColumn){
							continue;
						}
						blockedCoords.push(new CellCoords(colIdx,rowIdx) );
					}
				}
				
				// advance coordinates while checking blocked ones from spans
				do{
					curColumn++;
					if(curColumn >= numColumns){
						curColumn = 0;
						curRow++;
					}
					var advanced:Boolean = true;
					for(i=0;i<blockedCoords.length;i++){
						if(blockedCoords[i].column == curColumn && blockedCoords[i].row == curRow){
							advanced = false;
							blockedCoords.splice(i,1);
						}
					}
					if(advanced)
						break;
					
				}while(1);
					
			}
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
			_composedRowIndex = 0;
			// make sure the height that defines the row height did not change. If it did we might need to change the row height.
			if(!hasCellDamage)
				return;
			var damaagedCells:Vector.<TableCellElement> = getDamagedCells();
			var cell:TableCellElement;
			for each(cell in damaagedCells){
				// recompose the cells while tracking row height if necessary
				cell.compose();
			}
			// set row heights to minimum
			for each (var row:TableRowElement in rows){
				var minH:Number = row.computedFormat.minCellHeight;
				var maxH:Number = row.computedFormat.maxCellHeight;
				row.totalHeight = row.composedHeight = minH;
				if(maxH > minH)
					row.isMaxHeight = false;
				else
					row.isMaxHeight = true;
				
			}
			// set column positions...
			var xPos:Number = 0;
			for each (var col:TableColElement in columns){
				col.x = xPos;
				xPos += col.columnWidth;
			}
			
			if (mxmlChildren) {
				for(var i:int=0;i<mxmlChildren.length;i++){
					if( !(mxmlChildren[i] is TableCellElement) )
						continue;
					cell = mxmlChildren[i] as TableCellElement;
					while(rows.length < cell.rowIndex+1){
						addRow(defaultRowFormat);
					}
					row = getRowAt(cell.rowIndex);
					if(!row)
						throw new Error("this should not happen...");
					if(row.isMaxHeight)
						continue;
					var cellHeight:Number = cell.getComposedHeight();
					if(cell.rowSpan > 1)
					{
						// figure out the total height taking into account fixed height rows and the total span.
						
						// for now, we're taking the easy way out assuming the rows are not fixed...
						row.totalHeight = Math.max(row.totalHeight,cellHeight);
						
					}
					else
					{
						row.composedHeight = Math.max(row.composedHeight,cellHeight);
						row.composedHeight = Math.min(row.composedHeight,row.computedFormat.maxCellHeight);
						row.totalHeight = Math.max(row.composedHeight,row.totalHeight);
					}
					if(row.composedHeight == row.computedFormat.maxCellHeight)
						row.isMaxHeight = true;
				}
			}
			
			
			if(!_tableRowsComputed)
			{
				// create arrays or rows to make table composition simpler
				// For now we're assuming all cells have the correct row and column indices.
				// For this assumption to remain valid, the interaction manager will have to update all indices when inserting rows and columns.
				// actually, it probably makes sense for TableElement to handle that when adding rows and columns.
				// we need to think this through.
				_bodyRows = new Vector.< Vector.<TableCellElement> >();
				
				for(i=0;i<mxmlChildren.length;i++){
					if( !(mxmlChildren[i] is TableCellElement) )
						continue;
					cell = mxmlChildren[i] as TableCellElement;
					while(cell.rowIndex >= _bodyRows.length)
						_bodyRows.push(new Vector.<TableCellElement>());
						
					var rowVec:Vector.<TableCellElement> = _bodyRows[cell.rowIndex] as Vector.<TableCellElement>;
					if(!rowVec){
						rowVec = new Vector.<TableCellElement>();
						_bodyRows[cell.rowIndex] = rowVec;
					}
					if(rowVec.length > cell.colIndex && rowVec[cell.colIndex])
						throw new Error("Two cells cannot have the same coordinates");
					rowVec[cell.colIndex] = cell;
				}
				
				if(headerRowCount > 0){
					_headerRows = _bodyRows.splice(0,headerRowCount);
				} else {
					_headerRows = null;
				}
				
				if(footerRowCount > 0){
					_footerRows = _bodyRows.splice(-footerRowCount,Number.MAX_VALUE);
				} else {
					_footerRows = null;
				}
			}
		}
		
		public function getHeaderRows():Vector.< Vector.<TableCellElement> >{
			return _headerRows;
		}
		
		public function getFooterRows():Vector.< Vector.<TableCellElement> >{
			return _footerRows;
		}
		
		public function getBodyRows():Vector.< Vector.<TableCellElement> >{
			return _bodyRows;
		}
		
		public function getNextRow():Vector.<TableCellElement>{
			if(_composedRowIndex >= _bodyRows.length)
				return null;
			return _bodyRows[_composedRowIndex++];
		}
		
		public function getHeaderHeight():Number{
			//TODO: compute the header height from the header cells
			return 0;
		}
		public function getFooterHeight():Number{
			//TODO: compute the footer height from the footer cells
			return 0;
			
		}
		
		public function normalizeColumnWidths(suggestedWidth:Number = 600):void{
			//TODO: before composition make sure all column widths are rational numbers
			// We feed in a width to use if there's no width otherwise specified.
			
			// quick and dirty...
			var setCount:* = computedFormat.columnCount;
			if(!setCount){
				// we need to figure this out...
			} else if(setCount == FormatValue.AUTO){
				// figure out...
			} else {
				var cCount:Number = computedFormat.columnCount;
			}
			while (cCount > columns.length){
				addColumn();
			}
			var w:Number;
			switch(typeof(computedFormat.tableWidth)){
				case "number":
					w = suggestedWidth;
					break;
				case "string":
					if(computedFormat.tableWidth.indexOf("%") > 0){
						w = suggestedWidth / (parseFloat(computedFormat.tableWidth)/100);
						break;
					}
				default:
					w = suggestedWidth;
					break;
			}
			if(isNaN(w))
				w = 600;
			if(w > 20000)
				w = 600;
			for each(var col:TableColElement in columns){
				// simply stomp on the settings. (need to finesse this...)
					col.columnWidth = w / numColumns;
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

		public function get headerRowCount():uint
		{
			return _headerRowCount;
		}

		public function set headerRowCount(value:uint):void
		{
			if(value != _headerRowCount)
				_tableRowsComputed = false;
			_headerRowCount = value;
		}

		public function get footerRowCount():uint
		{
			return _footerRowCount;
		}

		public function set footerRowCount(value:uint):void
		{
			if(value != _footerRowCount)
				_tableRowsComputed = false;
			_footerRowCount = value;
		}
		public function getFirstBlock():TextFlowTableBlock{
			if(_tableBlocks == null)
				_tableBlocks = new Vector.<TextFlowTableBlock>();
			if(_tableBlocks.length == 0)
				_tableBlocks.push(new TextFlowTableBlock(0));
			_tableBlockIndex = 0;
			_tableBlocks[0].parentTable = this;
			return _tableBlocks[0];
		}
		public function getNextBlock():TextFlowTableBlock{
			if(_tableBlocks == null)
				_tableBlocks = new Vector.<TextFlowTableBlock>();
			_tableBlockIndex++;
			while(_tableBlocks.length <= _tableBlockIndex){
				_tableBlocks.push( new TextFlowTableBlock(_tableBlocks.length) );
			}
			_tableBlocks[_tableBlockIndex].parentTable = this;
			return _tableBlocks[_tableBlockIndex];
		}
		override public function get textLength():int{
			return 1;
		}
		private function getCellIndex(rowIdx:int,columnIdx:int):int{
			if(rowIdx == 0 && columnIdx == 0)
				return 0;
			for (var i:int=0;i<mxmlChildren.length;i++){
				var item:* = mxmlChildren[i];
				if(!(item is TableCellElement))
					continue;
				var cell:TableCellElement = item as TableCellElement;
				if(cell.rowIndex == rowIdx && cell.colIndex == columnIdx)
					return i;
			}
			return -1;
			
		}
	}
}
class CellCoords
{
	public var column:int;
	public var row:int;
	public function CellCoords(colIdx:int,rowIdx:int)
	{
		column = colIdx;
		row = rowIdx;
	}
}