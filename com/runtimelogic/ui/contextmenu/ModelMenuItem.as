/* ==============================================================================================================

NAME: ModelMenuItem

AUTHOR: AJ Canepa
DATE  : 4/12/2012

COMMENT: Model class to represent the most basic menu item comprised of a name and optional path to an icon.

============================================================================================================== */

package com.runtimelogic.ui.contextmenu
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	
	public class ModelMenuItem extends EventDispatcher
	{
		protected var _name: String;
		protected var _iconPath: String;
		
		
		public function ModelMenuItem(name: String, iconPath: String)
		{
			super();
			
			_name = name;
			_iconPath = iconPath;
		}
		
		
		///// Accessors / Mutators /////
		
		public function get name(): String							{ return _name; }
		public function set name(val: String): void					{ _name = val; }
		
		public function get iconPath(): String							{ return _iconPath; }
		public function set iconPath(val: String): void					{ _iconPath = val; }
		
		
		///// Public Interface /////
		
		
		///// Helper Methods /////
	}
}

