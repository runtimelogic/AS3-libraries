/* ==============================================================================================================

NAME: ModelContextMenu

AUTHOR: AJ Canepa
DATE  : 4/12/2012

COMMENT: The model class representing a contextual menu.  Submenus are not aggregated directly, instead menu items
that open a submenu aggregate the submenu instance of this class.

============================================================================================================== */

package com.runtimelogic.ui.contextmenu
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.display.Bitmap;
	
	
	public class ModelContextMenu extends EventDispatcher
	{
		protected var _items: Array = new Array();  // of ModelContextMenuItem
		protected var _targetBitmap: Bitmap;
		protected var _targetModel: EventDispatcher;
		
		protected var _parent: ModelContextMenu;
		protected var _isOpen: Boolean = false;
		protected var _isHighlighted: Boolean = false;
		protected var _isEnabled: Boolean = true;
		protected var _targetBitmapDisplayed: Boolean = false;
		
		protected var _position: Point = new Point(200, 200);
		protected var _parentRadians: Number = 0;
		protected var _menuAlignHorizontal: uint = ModelContextMenuItem.LEFT;
		protected var _menuAlignVertical: uint = ModelContextMenuItem.TOP;
		protected var _mirrorOnMeasure: Boolean = false;
		
		
		public static const ITEMS_CHANGED_EVENT: String = "ITEMS_CHANGED_EVENT";
		public static const OPEN_CHANGED_EVENT: String = "OPEN_CHANGED_EVENT";
		public static const HIGHLIGHTED_CHANGED_EVENT: String = "HIGHLIGHTED_CHANGED_EVENT";
		public static const ENABLED_CHANGED_EVENT: String = "ENABLED_CHANGED_EVENT";
		public static const POSITION_CHANGED_EVENT: String = "POSITION_CHANGED_EVENT";
		public static const MENU_ALIGN_CHANGED_EVENT: String = "MENU_ALIGN_CHANGED_EVENT";
		public static const BITMAP_CHANGED_EVENT: String = "BITMAP_CHANGED_EVENT";
		public static const BITMAP_DISPLAYED_CHANGED_EVENT: String = "BITMAP_DISPLAYED_CHANGED_EVENT";
		public static const TARGET_MODEL_CHANGED_EVENT: String = "TARGET_MODEL_CHANGED_EVENT";
		
		
		public function ModelContextMenu(menuConfig: Object = null, parent: ModelContextMenu = null)
		{
			super();
			
			_parent = parent;
			
			// use optional menu config object to populate contextual menu
			// Ex. [{name: "awards", assetPath: "icons/awards.swf", actionData: anActionInstance},
			//	{name: "inventory", assetPath: "icons/inventory.swf", submenu: [{name: "hats",
			//	assetPath: "icons/inventory-hats.swf", actionData: anActionInstance}]}]
			//
			// for list-based submenus, see ModelContextMenuList for the correct format for the "submenu" value
			if (menuConfig)
			{
				this.createMenuFromConfig(menuConfig);
			}
		}
		
		
		///// Accessors / Mutators /////
		
		public function get items(): Array										{ return _items; }
		public function set items(val: Array): void
		{
			_items = val;
			this.dispatchEvent(new Event(ITEMS_CHANGED_EVENT));
		}
		
		public function get targetBitmap(): Bitmap								{ return _targetBitmap; }
		public function set targetBitmap(val: Bitmap): void
		{
			_targetBitmap = val;
			this.dispatchEvent(new Event(BITMAP_CHANGED_EVENT));
		}
		
		public function get targetModel(): EventDispatcher								{ return _targetModel; }
		public function set targetModel(val: EventDispatcher): void
		{
			_targetModel = val;
			this.dispatchEvent(new Event(TARGET_MODEL_CHANGED_EVENT));
		}
		
		public function get parent(): ModelContextMenu							{ return _parent; }
		
		public function get isRoot(): Boolean									{ return (_parent == null); }
		
		public function get isOpen(): Boolean									{ return _isOpen; }
		public function set isOpen(val: Boolean): void
		{
			if (_parent)
			{
				// set enabled state of parent menu
				_parent.isEnabled = ! val;
			}
			
			_isOpen = val;
			this.dispatchEvent(new Event(OPEN_CHANGED_EVENT));
			
			if (! _isOpen)
			{
				// make sure any submenus are closed when this menu is closed
				var modelContextMenuItem: ModelContextMenuItem;
				for (var i: uint = 0; i < _items.length; i++)
				{
					modelContextMenuItem = _items[i];
					if (modelContextMenuItem is ModelContextMenuItemNode)
					{
						ModelContextMenuItemNode(modelContextMenuItem).submenu.isOpen = false;
					}
				}
			}
		}
		
		public function get isHighlighted(): Boolean							{ return _isHighlighted; }
		public function set isHighlighted(val: Boolean): void
		{
			_isHighlighted = val;
			this.dispatchEvent(new Event(HIGHLIGHTED_CHANGED_EVENT));
		}
		
		public function get isEnabled(): Boolean								{ return _isEnabled; }
		public function set isEnabled(val: Boolean): void
		{
			_isEnabled = val;
			this.dispatchEvent(new Event(ENABLED_CHANGED_EVENT));
			
			// make sure child items are enabled when re-enabling the menu
			if (_isEnabled)
			{
				var modelContextMenuItem: ModelContextMenuItem;
				for (var i: uint = 0; i < _items.length; i++)
				{
					modelContextMenuItem = _items[i];
					modelContextMenuItem.isEnabled = true;
				}
			}
		}
		
		public function get position(): Point									{ return _position; }
		public function set position(val: Point): void
		{
			_position = val;
			this.dispatchEvent(new Event(POSITION_CHANGED_EVENT));
		}
		
		
		public function get parentRadians(): Number								{ return _parentRadians; }
		public function set parentRadians(val: Number): void
		{
			_parentRadians = val;
			this.dispatchEvent(new Event(MENU_ALIGN_CHANGED_EVENT));
		}
		
		
 		public function get menuAlignHorizontal(): Number						{ return _menuAlignHorizontal; }
		public function set menuAlignHorizontal(val: Number): void
		{
			_menuAlignHorizontal = val;
			this.dispatchEvent(new Event(MENU_ALIGN_CHANGED_EVENT));
		}
		
 		public function get menuAlignVertical(): Number							{ return _menuAlignVertical; }
		public function set menuAlignVertical(val: Number): void				{ _menuAlignVertical = val; }
		
		
		public function get mirrorOnMeasure(): Boolean							{ return _mirrorOnMeasure; }
		public function set mirrorOnMeasure(val: Boolean): void					{ _mirrorOnMeasure = val; }
		
		
		public function get targetBitmapDisplayed(): Boolean					{ return _targetBitmapDisplayed; }
		public function set targetBitmapDisplayed(val: Boolean): void
		{
			_targetBitmapDisplayed = val;
			this.dispatchEvent(new Event(BITMAP_DISPLAYED_CHANGED_EVENT));
		}
		
		
		///// Public Interface /////
		
		// TODO: define functional interface for adding removing and modifying menu items
		
		
		///// Helper Methods /////
		
		protected function createMenuFromConfig(menuConfig: Object): void
		{
			var item: Object;
			var submenuModel: ModelContextMenu;
			var itemModel: ModelContextMenuItem;
			
			for (var i: uint = 0; i < menuConfig.length; i++)
			{
				item = menuConfig[i];
				if (item.submenu != undefined)
				{
					// this is a node - create the submenu
					if (item.submenu is Array)
					{
						// standard submenu is an array of items
						submenuModel = new ModelContextMenu(item.submenu, this);
					}
					else
					{
						// list menu config is an Object
						submenuModel = new ModelContextMenuList(item.submenu, this);
					}
					itemModel = new ModelContextMenuItemNode(item.name, item.assetPath, submenuModel);
				}
				else
				{
					// this is a leaf
					itemModel = new ModelContextMenuItemLeaf(item.name, item.assetPath, item.actionData);
				}
				
				_items.push(itemModel);
			}
		}
	}
}

