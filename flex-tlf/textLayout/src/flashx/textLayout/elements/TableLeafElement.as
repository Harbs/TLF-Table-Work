package flashx.textLayout.elements
{
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
	
	public class TableLeafElement extends FlowLeafElement
	{
		private var _table:TableElement;
		public function TableLeafElement(table:TableElement)
		{
			super();
			_table = table;
		}

		/** @private */
		override tlf_internal function createContentElement():void
		{
			// not sure if this makes sense...
		}

		/** @private */
		override protected function get abstract():Boolean
		{ return false; }		
		
		/** @private */
		tlf_internal override function get defaultTypeName():String
		{ return "table"; }
		
		/** @private */
		public override function get text():String
		{
			return "\u0016";
		}
		
		/** @private */
		public override function getText(relativeStart:int=0, relativeEnd:int=-1, paragraphSeparator:String="\n"):String
		{
			return _table.getText(relativeStart, relativeEnd, paragraphSeparator);
		}
		
		/** @private */
		tlf_internal override function normalizeRange(normalizeStart:uint,normalizeEnd:uint):void
		{
			// not sure what to do here (see SpanElement)...
			super.normalizeRange(normalizeStart,normalizeEnd);
		}
		
		/** @private */
		tlf_internal override function mergeToPreviousIfPossible():Boolean
		{
			// not sure what to do here (see SpanElement)...
			return false;
		}
		
		public override function getNextLeaf(limitElement:FlowGroupElement=null):FlowLeafElement
		{
			return _table.getNextLeafHelper(limitElement,this);
		}
		
		public override function getPreviousLeaf(limitElement:FlowGroupElement=null):FlowLeafElement
		{
			return _table.getPreviousLeafHelper(limitElement,this);
		}
		/** @private */
		public override function getCharAtPosition(relativePosition:int):String
		{
			return getText(relativePosition,relativePosition);
		}
		public override function get computedFormat():ITextLayoutFormat
		{
			return _table.computedFormat;
		}
		public override function get textLength():int
		{
			return _table.textLength;
		}

	}
}
