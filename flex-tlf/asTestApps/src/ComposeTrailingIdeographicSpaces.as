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
package
{
	import flash.display.Sprite;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.IEditManager;
	import flashx.textLayout.elements.TextFlow;

	public class ComposeTrailingIdeographicSpaces extends Sprite
	{
		public function ComposeTrailingIdeographicSpaces()
		{
			var markup:String = "<TextFlow xmlns=\"http://ns.adobe.com/textLayout/2008\"><p textAlign=\"right\" justificationRule=\"eastAsian\"><span>ideographic spaces:&#x3000;&#x3000;&#x3000;</span></p></TextFlow>";
			
			var textFlow:TextFlow = TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
			textFlow.flowComposer.addController(new ContainerController(this, 200, 100));
			textFlow.flowComposer.updateAllControllers();
			textFlow.interactionManager = new EditManager() as IEditManager;
		}
	}
}