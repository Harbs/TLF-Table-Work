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
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.IEditManager;
	import flashx.textLayout.edit.ISelectionManager;
	import flashx.textLayout.events.DamageEvent;
	import flashx.textLayout.tlf_internal;
	import flashx.undo.UndoManager;
	
	use namespace tlf_internal;
	
	/** 
	 * <p> TableCellElement is an item in a TableElement. It most commonly contains one or more ParagraphElement objects.
	 *
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 *
	 */
	public final class TableCellElement extends TableFormattedElement
	{		
		public var x:Number;
		public var y:Number;
		private var _width:Number;
		private var _height:Number;
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
			return false;
		}
		
		public function isDamaged():Boolean{
			return _damaged;
		}
		
		public function compose():Boolean{
			_damaged = false;
			if(_textFlow && _textFlow.flowComposer)
				return _textFlow.flowComposer.compose();
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
		
		public function get textFlow():TextFlow
		{
			return _textFlow;
		}
		
		public function set textFlow(value:TextFlow):void
		{
			if(_textFlow)var a:DamageEvent
				_textFlow.removeEventListener(DamageEvent.DAMAGE,handleCellDamage);
			_textFlow = value;
				_textFlow.addEventListener(DamageEvent.DAMAGE,handleCellDamage);
				
			_textFlow.parentElement = this;
		}
		
		private function handleCellDamage(ev:DamageEvent):void{
			getTable().hasCellDamage = true;
			_damaged = true;
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
			if(!_container)
				_container = new CellContainer(enableIME);
			
			return _container;
		}

		public function get width():Number
		{
			return _width;
		}

		public function set width(value:Number):void
		{
			_width = value;
			_controller.setCompositionSize(value,_controller.compositionHeight);
//			_controller.compositionWidth 
			_damaged = true;
		}

		public function get height():Number
		{
			return _height;
		}

		public function set height(value:Number):void
		{
			_height = value;
			_controller.setCompositionSize(_controller.compositionWidth,value);
			_damaged = true;
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
		
		
	}
}
