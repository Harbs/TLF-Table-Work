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
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.engine.GraphicElement;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import flashx.textLayout.tlf_internal;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.IEditManager;
	import flashx.textLayout.edit.ISelectionManager;
	import flashx.textLayout.events.DamageEvent;
	import flashx.textLayout.events.ModelChange;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Float;
	import flashx.undo.UndoManager;
	
	use namespace tlf_internal;
	
	/** 
	 * TableCellElement is an item in a TableElement. It most commonly contains one or more ParagraphElement objects.
	 *
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 *
	 */
	public final class TableCellElement extends TableFormattedElement
	{		
		private var _x:Number;
		private var _y:Number;
		private var _width:Number;
		private var _height:Number;
		private var _widthWithPadding:Number;
		private var _heightWithPadding:Number;
		private var _elementWidth:Number;
		private var _elementHeight:Number;

		private var _parcelIndex:int;
		private var _container:CellContainer;
		private var _enableIME:Boolean = true;
		private var _damaged:Boolean = true;
		private var _controller:ContainerController;

		private var _rowSpan:uint = 1;
		private var _columnSpan:uint = 1;
		private var _rowIndex:int = -1;
		private var _colIndex:int = -1;
		
		public function TableCellElement()
		{
			super();
			_controller = new ContainerController(container,NaN,NaN);
		}

		/** @private */
		override protected function get abstract():Boolean
		{ return false; }
		
		/** @private */
		tlf_internal override function get defaultTypeName():String
		{ return "td"; }
		
		/** @private */
		tlf_internal override function canOwnFlowElement(elem:FlowElement):Boolean
		{// Table cells have no TLF children. Instead it contains its own TextFlow.
			return (elem is FlowElement);
		}
		
		public function isDamaged():Boolean {
			return _damaged;
		}
		
		public function compose():Boolean {
			var table:TableElement = getTable();
			
			if (table && table.getColumnAt(colIndex)) {
				width = table.getColumnAt(colIndex).columnWidth;
			}
			
			_damaged = false;
			
			if (_textFlow && _textFlow.flowComposer) {
				return _textFlow.flowComposer.compose();
			}
			
			return false;
		}
		
		public function update():Boolean
		{
			if(_textFlow && _textFlow.flowComposer){
				return _textFlow.flowComposer.updateAllControllers();
			}
			return false;
		}
		
		public function get parcelIndex():int
		{
			return _parcelIndex;
		}
		
		public function set parcelIndex(value:int):void
		{
			_parcelIndex = value;
		}
		
		public function get rowIndex():int
		{
			return _rowIndex;
		}
		
		public function set rowIndex(value:int):void
		{
			_rowIndex = value;
		}
		
		public function get colIndex():int
		{
			return _colIndex;
		}
		
		public function set colIndex(value:int):void
		{
			_colIndex = value;
		}
		
		protected var _textFlow:TextFlow;
		
		public function get textFlow():TextFlow {
			
			if (_textFlow == null) {
				var flow:TextFlow = new TextFlow();
				
				if (table && table.getTextFlow() && table.getTextFlow().interactionManager is IEditManager) {
					flow.interactionManager = new EditManager(IEditManager(_textFlow.interactionManager).undoManager);
				}
				else if(table && table.getTextFlow() && table.getTextFlow().interactionManager) {
					var im:Class = getDefinitionByName(getQualifiedClassName(table.getTextFlow().interactionManager)) as Class;
					flow.interactionManager = new im();
				}
				else {
					flow.normalize();
				}
				
				textFlow = flow;

			}
			
			return _textFlow;
		}
		
		public function set textFlow(value:TextFlow):void
		{
			if (_textFlow) {
				_textFlow.removeEventListener(DamageEvent.DAMAGE, handleCellDamage);
				_textFlow.flowComposer.removeAllControllers();
			}
			
			_textFlow = value;
			_textFlow.parentElement = this;
			_textFlow.flowComposer.addController(_controller);
			_textFlow.addEventListener(DamageEvent.DAMAGE, handleCellDamage);
			
		}
		
		private function handleCellDamage(ev:DamageEvent):void{
			damage();
		}

		public function get enableIME():Boolean
		{
			return _enableIME;
		}

		public function set enableIME(value:Boolean):void
		{
			_enableIME = value;
		}
		
		public function get container():CellContainer{
			if(!_container){
				_container = new CellContainer(enableIME);
				_container.element = this;
			}
			
			return _container;
		}

		/**
		 * Gets the width.
		 **/
		public function get width():Number
		{
			return _width;
		}

		/**
		 * @private
		 **/
		public function set width(value:Number):void
		{
			if(_width != value) {
				_damaged = true;
			}
			
			_width = value;
			_widthWithPadding = _width + getTotalPaddingWidth();
			_elementWidth = value;
			
			_controller.setCompositionSize(_width, _controller.compositionHeight);
		}
		
		/**
		 * Returns the height of the cell. 
		 **/
		public function get height():Number
		{
			return _height;
		}

		/**
		 * @private
		 **/
		public function set height(value:Number):void
		{
			if (_height != value) {
				_damaged = true;
			}
			
			_height = value;
			_heightWithPadding = _height + getTotalPaddingHeight();
			_elementHeight = value;
			
			_controller.setCompositionSize(_controller.compositionWidth, _height);
		}
		
		public function getComposedHeight():Number
		{
			return _controller.getContentBounds().height;
		}

		public function get rowSpan():uint
		{
			return _rowSpan;
		}

		public function set rowSpan(value:uint):void
		{
			if(value >= 1)
				_rowSpan = value;
		}

		public function get columnSpan():uint
		{
			return _columnSpan;
		}

		public function set columnSpan(value:uint):void
		{
			if(value >= 1)
				_columnSpan = value;
		}
		
		public function updateCompositionShapes():void{
			_controller.updateCompositionShapes();
		}
		
		/**
		 * Return the row that this cell is part of or null 
		 * if not part of a row.
		 **/
		public function getRow():TableRowElement
		{
			return table ? table.getRowAt(rowIndex) : null;
		}
		
		/**
		 * Returns the next cell in the table or null if not part of a
		 * table or no cells exist after this cell.
		 **/
		public function getNextCell():TableCellElement {
			return table ? table.getNextCell(this) : null;
		}
		
		/**
		 * Returns the previous cell in the table or null if not part of a
		 * table or no cells exist before this cell.
		 **/
		public function getPreviousCell():TableCellElement {
			return table ? table.getPreviousCell(this) : null;
		}

		public function get x():Number
		{
			return container.x;
		}

		public function set x(value:Number):void
		{
			container.x = value;
		}

		public function get y():Number
		{
			return container.y;
		}

		public function set y(value:Number):void
		{
			container.y = value;
		}

		public function damage():void
		{
			if (table) {
				table.hasCellDamage = true;
			}
			
			_damaged = true;
		}
		
		/**
		 * Adds in the table cell spacing, border stroke width. 
		 * We may be able to set this value when the format changes. 
		 * For now we just want to get it to work. 
		 **/
		public function getTotalPaddingWidth():Number {
			var paddingAmount:Number = 0;
			
			// no textflow is no padding
			if (!textFlow) {
				return 0;
			}
			
			if (table && table.cellSpacing!=undefined) {
				paddingAmount += table.cellSpacing;
			}
			
			if (textFlow.computedFormat.blockProgression == BlockProgression.RL) {
				paddingAmount += Math.max(getEffectivePaddingTop() + getEffectivePaddingBottom(), getEffectiveBorderTopWidth() + getEffectiveBorderBottomWidth());
			}
			else {
				paddingAmount += Math.max(getEffectivePaddingLeft() + getEffectivePaddingRight(), getEffectiveBorderLeftWidth() + getEffectiveBorderRightWidth());
			}
			
			return paddingAmount;
		}
		
		/**
		 * Adds in the table cell spacing, border stroke height. 
		 * We may be able to set this value when the format changes. 
		 **/
		public function getTotalPaddingHeight():Number {
			var paddingAmount:Number = 0;
			
			// no textflow is no padding
			if (!textFlow) {
				return 0;
			}
			
			if (table && table.cellSpacing!=undefined) {
				paddingAmount += table.cellSpacing;
			}
			
			if (textFlow.computedFormat.blockProgression == BlockProgression.RL) {
				paddingAmount += Math.max(getEffectivePaddingLeft() + getEffectivePaddingRight(), getEffectiveBorderLeftWidth() + getEffectiveBorderRightWidth());
			}
			else {
				paddingAmount += Math.max(getEffectivePaddingTop() + getEffectivePaddingBottom(), getEffectiveBorderTopWidth() + getEffectiveBorderBottomWidth());
			}
			
			return paddingAmount;
		}
		
		
		/** @private */
		tlf_internal function elementWidthWithMarginsAndPadding():Number
		{
			var paddingAmount:Number = 0;
			
			// no textflow is no padding
			if (!textFlow) {
				return elementWidth;
			}
			
			if (textFlow.computedFormat.blockProgression == BlockProgression.RL) {
				paddingAmount = getTotalPaddingWidth();
			}
			else {
				paddingAmount = getTotalPaddingHeight();
			}
			
			return elementWidth + paddingAmount;
		}
		
		/** @private */
		tlf_internal function elementHeightWithMarginsAndPadding():Number
		{
			var paddingAmount:Number;
			
			// no textflow is no padding
			if (!textFlow) {
				return elementHeight;
			}
			
			if (textFlow.computedFormat.blockProgression == BlockProgression.RL) {
				paddingAmount = getTotalPaddingHeight();
			}
			else {
				paddingAmount = getTotalPaddingWidth();
			}
			
			return isNaN(elementHeight) ? height + paddingAmount : elementHeight + paddingAmount;
		}
		
		
		/** 
		 * Width used by composition for laying out text
		 * */
		tlf_internal function get elementWidth():Number
		{
			return _elementWidth;           
		}
		
		/** 
		 * @private 
		 * */
		tlf_internal function set elementWidth(value:Number):void
		{
			_elementWidth = value;
			
			elementWidth = elementWidthWithMarginsAndPadding();
			
			modelChanged(ModelChange.ELEMENT_MODIFIED, this, 0, textLength, true, false);
		}
		
		/**
		 * Height used by composition for laying out text 
		 * */
		tlf_internal function get elementHeight():Number
		{
			return _elementHeight;          
		}
		
		/** 
		 * @private 
		 * */
		tlf_internal function set elementHeight(value:Number):void
		{
			_elementHeight = value;
			
			elementHeight = elementHeightWithMarginsAndPadding();    
			
			modelChanged(ModelChange.ELEMENT_MODIFIED, this, 0, textLength, true, false);
		}
	}
}
