package flashx.textLayout.elements
{
	import flash.display.Sprite;
	
	import flashx.textLayout.compose.TextFlowTableBlock;
	
	/**
	 * The sprite that contains the table cells. 
	 **/
	public class TableBlockContainer extends Sprite
	{
		
		public function TableBlockContainer()
		{
			super();
		}
		
		/**
		 * A reference to the TextFlowTableBlock
		 **/
		public var userData:TextFlowTableBlock;
	}
}