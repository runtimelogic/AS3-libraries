/* ==============================================================================================================

NAME: ModelContextMenuItemNode

AUTHOR: AJ Canepa
DATE  : 4/12/2012

COMMENT: A menu item that has a submenu.

============================================================================================================== */

package com.runtimelogic.ui.contextmenu
{
	import flash.events.Event;
	
	
	public class ModelContextMenuItemNode extends ModelContextMenuItem
	{
		protected var _submenu: ModelContextMenu;
		
		
		public static const SUBMENU_STATE_CHANGED_EVENT: String = "SUBMENU_STATE_CHANGED_EVENT";
		
		
		public function ModelContextMenuItemNode(name: String, iconPath: String, submenu: ModelContextMenu)
		{
			super(name, iconPath);
			
			_submenu = submenu;
			
			// register for Model notifications
			_submenu.addEventListener(ModelContextMenu.OPEN_CHANGED_EVENT, this.updateSubmenuState);
		}
		
		
		public function Done(): void
		{
			_submenu.removeEventListener(ModelContextMenu.OPEN_CHANGED_EVENT, this.updateSubmenuState);
		}
		
		
		///// Accessors / Mutators /////
		
		public function get submenu(): ModelContextMenu							{ return _submenu; }
		public function set submenu(val: ModelContextMenu): void				{ _submenu = val; }
		
		public function get submenuIsOpen(): Boolean							{ return _submenu.isOpen; }
		
		
		///// Public Interface /////
		
		override public function PositionChildren(radians: Number, distance: Number): void
		{
			super.PositionChildren(radians, distance);
			
			// propagate alignment data to child submenus
			_submenu.menuAlignHorizontal = _textAlignHorizontal;
			_submenu.menuAlignVertical = _textAlignVertical;
			_submenu.parentRadians = radians;
		}
		
		///// Model Notifications /////
		
		private function updateSubmenuState(e: Event): void
		{
			// notify view that the submenu isOpen state changed
			this.dispatchEvent(new Event(SUBMENU_STATE_CHANGED_EVENT));
		}
		
		
		///// Helper Methods /////
	}
}

