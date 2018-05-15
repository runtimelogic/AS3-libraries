/* ==============================================================================================================

NAME: Controller

AUTHOR: AJ Canepa
DATE  : 4/11/2012

COMMENT: The singleton controller for managing contextual menus.

============================================================================================================== */

package com.runtimelogic.ui.contextmenu
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.display.DisplayObject;
	import flash.display.Bitmap;
	import flash.geom.Point;
	
	
	public class Controller
	{
		// static reference to this singleton instance
		public static var sInstance: Controller = null;
		
		private var _currentMenu: ModelContextMenu;
		private var _highlightMenu: ModelContextMenu;
		
		private var _actionCallbackFunction: Function;
		
		private var _targetModel: EventDispatcher;
		private var _highlightTargetModel: EventDispatcher;
		
		private var _updatePositionEventType: String;
		private var _highlightUpdatePositionEventType: String;
		private var _modelPositionAccessor: Function;
		private var _positionOffset: Point;
		
		
		public function Controller()
		{
			// set the singleton instance
			Controller.sInstance = this;
		}
		
		
		///// Accessors / Mutators /////
		
		public static function get instance(): Controller
		{
			if (sInstance == null)
			{
				// create singleton instance
				new Controller();
			}
			
			return sInstance;
		}
		
		
		public function set actionCallbackFunction(val: Function): void			{ _actionCallbackFunction = val; }
		
		public function get targetModel(): EventDispatcher						{ return _targetModel; }
		
		
		///// Commands /////
		
		public function HighlightMenu(modelContextMenu: ModelContextMenu = null,
			targetModel: EventDispatcher = null, position: Point = null, updatePositionEventType: String = "",
			modelPositionAccessor: Function = null, positionOffset: Point = null): void
		{
			// cleanup previous highlight
			if (_highlightMenu)
			{
				_highlightMenu.isHighlighted = false;
				if (_highlightTargetModel.hasEventListener(_highlightUpdatePositionEventType))
				{
					_highlightTargetModel.removeEventListener(_highlightUpdatePositionEventType, this.updatePosition);
				}
			}
			
			// init new highlight
			if (modelContextMenu && (modelContextMenu != _currentMenu))
			{
				_highlightMenu = modelContextMenu;
				_highlightTargetModel = targetModel;
				_highlightUpdatePositionEventType = updatePositionEventType;
				_modelPositionAccessor = modelPositionAccessor;
				_positionOffset = positionOffset;
				
				if (_highlightUpdatePositionEventType != "")
				{
					_highlightTargetModel.addEventListener(_highlightUpdatePositionEventType, this.updatePosition);
					this.updatePosition(null);
				}
				
				if (position)
				{
					// set initial position
					if (_positionOffset)
					{
						_highlightMenu.position = _positionOffset.add(position);
					}
					else
					{
						_highlightMenu.position = position;
					}
				}
				
				_highlightMenu.isHighlighted = true;
			}
			else
			{
				_highlightMenu = null;
				_highlightTargetModel = null;
				_highlightUpdatePositionEventType = "";
				_modelPositionAccessor = null;
				_positionOffset = null;
			}
		}
		
		
		public function DisplayMenu(modelContextMenu: ModelContextMenu = null,
			targetModel: EventDispatcher = null, targetBitmap: Bitmap = null, position: Point = null,
			updatePositionEventType: String = ""): void
		{
			if (_currentMenu)
			{
				_currentMenu.isOpen = false;
				
				if (_targetModel.hasEventListener(_updatePositionEventType))
				{
					_targetModel.removeEventListener(_updatePositionEventType, this.showSnapshot);
				}
				
				if (modelContextMenu == _currentMenu)
				{
					// same menu was passed as is currently open, so just reset values and exit
					_currentMenu = null;
					_targetModel = null;
					return;
				}
			}
			
			_currentMenu = modelContextMenu;
			_targetModel = targetModel;
			_updatePositionEventType = updatePositionEventType;
			
			if (_currentMenu)
			{
				_currentMenu.targetBitmap = targetBitmap;
				_currentMenu.targetModel = targetModel;
				if (_updatePositionEventType != "")
				{
					_targetModel.addEventListener(_updatePositionEventType, this.showSnapshot);
				}
				
				if (position)
				{
					// set initial position
					if (_positionOffset)
					{
						_currentMenu.position = _positionOffset.add(position);
					}
					else
					{
						_currentMenu.position = position;
					}
				}
				
				_currentMenu.isOpen = true;
			}
		}
		
		
		public function ActivateMenuItem(modelContextMenuItem: ModelContextMenuItem): void
		{
			if (modelContextMenuItem is ModelContextMenuItemLeaf)
			{
				// process action
				var itemLeaf: ModelContextMenuItemLeaf = ModelContextMenuItemLeaf(modelContextMenuItem);
				_actionCallbackFunction(itemLeaf.actionData, _targetModel, itemLeaf.targetID);
				
				// close menu
				_currentMenu.isOpen = false;
				_currentMenu = null;
				_targetModel = null;
			}
			else if (modelContextMenuItem is ModelContextMenuItemNode)
			{
				// display submenu
				var modelContextMenu: ModelContextMenu = ModelContextMenuItemNode(modelContextMenuItem).submenu;
				var isOpen: Boolean = ! modelContextMenu.isOpen;  // toggle submenu state
				modelContextMenu.isOpen = isOpen;
				
				if (! modelContextMenu.isRoot)
				{
					// set enabled state for items of parent menu
					var items: Array = modelContextMenu.parent.items;
					var item: ModelContextMenuItem;
					for (var i: uint = 0; i < items.length; i++)
					{
						item = items[i];
						if (item != modelContextMenuItem)
						{
							item.isEnabled = ! isOpen;
						}
					}
				}
			}
		}
		
		
		public function ProcessClick(target: DisplayObject): void
		{
			// determine if the click was on something other than a part of a context menu
			if (target is ViewContextMenu || target is ViewContextMenuList || target is ViewContextMenuItem)
			{
				return;
			}
			if (target.parent && (target.parent is ViewContextMenuItem || target.parent is ViewContextMenuList))
			{
				return;
			}
			
			// close any currently open menu
			this.DisplayMenu();
		}
		
		
		///// Model Notifications /////
		
		private function updatePosition(e: Event): void
		{
			if (_positionOffset)
			{
				_highlightMenu.position = _positionOffset.add(_modelPositionAccessor());
			}
			else
			{
				_highlightMenu.position = _modelPositionAccessor();
			}
		}
		
		
		private function showSnapshot(e: Event): void
		{
			trace("ContextMenu --> show snapshot");
			if (_currentMenu)
			{
				_currentMenu.targetBitmapDisplayed = true;
				
				// remove position change listener
				_targetModel.removeEventListener(_updatePositionEventType, this.showSnapshot);
				
				if (_highlightMenu)
				{
					// hide highlight which also disables calls to updatePosition
					this.HighlightMenu(null);
				}
			}
		}
		
	}
}

