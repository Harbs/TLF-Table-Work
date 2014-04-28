package flashx.textLayout.compose
{
	
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.elements.CellContainer;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.TableBlockContainer;
	import flashx.textLayout.elements.TableElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;

	public class TextFlowTableBlock extends TextFlowLine
		
	{
		public function TextFlowTableBlock(index:uint)
		{
			blockIndex = index;
			_container = new TableBlockContainer();
			super(null,null);
		}
		
		override tlf_internal function initialize(paragraph:ParagraphElement, outerTargetWidth:Number = 0, lineOffset:Number = 0, absoluteStart:int = 0, numChars:int = 0, textLine:TextLine = null):void
		{
			_container.userData = this;
			super.initialize(paragraph,outerTargetWidth,lineOffset,absoluteStart,numChars,textLine);
		}
		
		public var parentTable:TableElement;
		public var blockIndex:uint = 0;
		private var _container:TableBlockContainer;
		
		private var _cells:Array;
		private function getCells():Array{
			if(_cells == null){
				_cells = [];
			}
			return _cells;
		}
		public function clear():void{
			clearCells();
		}
		public function clearCells():void{
			_container.removeChildren();
			_cells.length = 0;
		}
		public function addCell(cell:CellContainer):void{
			if(_cells.indexOf(cell) < 0){
				_cells.push(cell);
				_container.addChild(cell);
			}
		}
		
		public function drawBackground(backgroundInfo:*):void{
			//TODO: need to figure this out...
			
		}

		public function get container():TableBlockContainer
		{
			return _container;
		}
		public function set height(value:Number):void{
			_container.height = value;
		}
		override public function get height():Number{
			return _container.height;
		}
		override public function set x(value:Number):void{
			super.x = _container.x = value;
		}
		override public function get x():Number{
			return _container.x;
		}
		override public function set y(value:Number):void{
			super.y = _container.y = value;
		}
		override public function get y():Number{
			return _container.y;
		}

	}
}