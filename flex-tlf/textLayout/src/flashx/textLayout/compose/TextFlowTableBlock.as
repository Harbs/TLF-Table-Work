package flashx.textLayout.compose
{
	
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.elements.CellContainer;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.TableBlockContainer;
	import flashx.textLayout.elements.TableCellElement;
	import flashx.textLayout.elements.TableElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;

	/**
	 * 
	 **/
	public class TextFlowTableBlock extends TextFlowLine
	{
		
		/** Constructor - creates a new TextFlowTableBlock instance. 
		 *  <p><strong>Note</strong>: No client should call this. It's exposed for writing your own composer.</p>
		 *
		 * @param index The index in the Table text flow.
		 * */
		public function TextFlowTableBlock(index:uint)
		{
			blockIndex = index;
			_container = new TableBlockContainer();
			super(null,null);
		}
		
		/**
		 * @inherit
		 **/
		override tlf_internal function initialize(paragraph:ParagraphElement, outerTargetWidth:Number = 0, lineOffset:Number = 0, absoluteStart:int = 0, numChars:int = 0, textLine:TextLine = null):void
		{
			_container.userData = this;
			super.initialize(paragraph, outerTargetWidth, lineOffset, absoluteStart, numChars, textLine);
		}
		
		/**
		 * The table that owns this table block
		 **/
		public var parentTable:TableElement;
		
		/**
		 * The index of this block in the table text flow layout
		 **/
		public var blockIndex:uint = 0;
		
		/**
		 * @private
		 **/
		private var _container:TableBlockContainer;
		
		private var _cells:Array;
		
		/**
		 * Returns an array of table cells. 
		 * @private
		 **/
		private function getCells():Array{
			if(_cells == null){
				_cells = [];
			}
			return _cells;
		}
		
		/**
		 * Clears the cells in the table block. Wraps clearCells(). 
		 **/
		public function clear():void{
			clearCells();
		}
		
		/**
		 * Clears the cells in the table block
		 **/
		public function clearCells():void{
			_container.removeChildren();
			getCells().length = 0;
		}
		
		/**
		 * Adds a cell container to table container. This adds it to the display list. 
		 * If the cell is already added it does not add it twice. 
		 **/
		public function addCell(cell:CellContainer):void{
			var cells:Array = getCells();
			if(cells.indexOf(cell) < 0){
				cells.push(cell);
				_container.addChild(cell);
			}
		}
		
		
		public function drawBackground(backgroundInfo:*):void{
			//TODO: need to figure this out...
			
		}
		
		/**
		 * Container that displays this collection of cells
		 **/
		public function get container():TableBlockContainer
		{
			return _container;
		}
		
		/**
		 * 
		 **/
		public function updateCompositionShapes():void{
			var cells:Array = getCells();
			for each(var cell:CellContainer in cells){
				cell.element.updateCompositionShapes();
			}
		}

		/**
		 * Sets the height of the container 
		 **/
		public function set height(value:Number):void{
			_container.height = value;
		}
		
		/**
		 * @inherit
		 **/
		override public function get height():Number{
			return _container.height;
		}
		
		/**
		 * Sets the x position of the container
		 **/
		override public function set x(value:Number):void{
			super.x = _container.x = value;
		}
		
		override public function get x():Number{
			return _container.x;
		}
		
		/**
		 * Sets the y value of the container
		 **/
		override public function set y(value:Number):void{
			super.y = _container.y = value;
		}
		override public function get y():Number{
			return _container.y;
		}
		
		/**
		 * Returns a vector of table cell elements.
		 **/
		public function getTableCells():Vector.<TableCellElement>
		{
			var tCells:Vector.<TableCellElement> = new Vector.<TableCellElement>();
			var cells:Array = getCells();
			
			for each(var cellContainer:CellContainer in cells){
				tCells.push(cellContainer.element);
			}
			
			return tCells;
		}

	}
}