/* ==============================================================================================================

NAME: ModelContextMenuItemLeaf

AUTHOR: AJ Canepa
DATE  : 4/12/2012

COMMENT: A menu item that performs an action.

============================================================================================================== */

package com.runtimelogic.ui.contextmenu
{
	import flash.events.Event;
	
	
	public class ModelContextMenuItemLeaf extends ModelContextMenuItem
	{
		protected var _actionData: Object;  // abstract object instance that describes action to take
		protected var _targetID: uint;  // optional ID of target model that this leaf represents
		
		
		public function ModelContextMenuItemLeaf(name: String, iconPath: String, actionData: Object,
			targetID: uint = 0)
		{
			super(name, iconPath);
			
			_actionData = actionData;
			_targetID = targetID;
		}
		
		
		///// Accessors / Mutators /////
		
		public function get actionData(): Object							{ return _actionData; }
		public function set actionData(val: Object): void					{ _actionData = val; }
		
		public function get targetID(): uint								{ return _targetID; }
		
		
		///// Public Interface /////
		
		
		///// Helper Methods /////
	}
}

