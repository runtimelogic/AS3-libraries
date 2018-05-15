/* ==============================================================================================================

NAME: ViewContextMenu

AUTHOR: AJ Canepa
DATE  : 4/11/2012

COMMENT: The view class for rending a single level context menu.  Clicking an item within the menu
(VewContextMenuItem) either displays a submenu (an instance of ViewContextMenu or ViewContextMenuList), or
triggers an action as determined by the model for the menu item.

VIEW TYPE: Linked - contextMenu.fla / Dynamic

============================================================================================================== */

package com.runtimelogic.ui.contextmenu
{
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.DisplayObjectContainer;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import fl.transitions.easing.Bounce;
	
	import com.greensock.TweenLite;
	
	
	public class ViewContextMenu extends BaseView
	{
		// instance members
		public var items: Sprite;
		public var backgroundEnabled: Sprite;
		public var backgroundDisabled: Sprite;
		public var targetSnapshot: MovieClip;
		
		protected var _modelContextMenuRef: ModelContextMenu;
		protected var _items: Array;  // of ViewContextMenuItem
		protected var _maxScale: Number = 1;
		
		
		// static configuration of the display layer for context menus
		public static var sDisplayLayer: DisplayObjectContainer = null;
		
		public static var PIE_RADIUS: Number = 68;
		public static var ITEM_TEXT_RADIUS: Number = 35;
		public static var ITEM_TEXT_SPACING_H: Number = 8;
		public static var ITEM_TEXT_SPACING_V: Number = 2.5;
		
		
		public function ViewContextMenu()
		{
			super();
			
			this.initClips();
		}
		
		
		public function Init(modelContextMenuRef: ModelContextMenu, maxScale: Number = 1): void
		{
			_modelContextMenuRef = modelContextMenuRef;
			_maxScale = maxScale;
			
			// register for Model notifications
			_modelContextMenuRef.addEventListener(ModelContextMenu.ITEMS_CHANGED_EVENT, this.updateItems);
			_modelContextMenuRef.addEventListener(ModelContextMenu.OPEN_CHANGED_EVENT, this.displayMenu);
			_modelContextMenuRef.addEventListener(ModelContextMenu.ENABLED_CHANGED_EVENT, this.enableMenu);
			
			if (_modelContextMenuRef.isRoot)
			{
				// attach root menus to display layer -- submenus are nested and not attached here
				if (ViewContextMenu.sDisplayLayer)
				{
					ViewContextMenu.sDisplayLayer.addChild(this);
				}
				else
				{
					throw new Error("ViewContextMenu.sDisplayLayer has not been set.");
				}
				
				// root menus track position
				_modelContextMenuRef.addEventListener(ModelContextMenu.POSITION_CHANGED_EVENT, this.updatePosition);
				this.x = _modelContextMenuRef.position.x;
				this.y = _modelContextMenuRef.position.y;
				
				// root menus should display highlighting
				_modelContextMenuRef.addEventListener(ModelContextMenu.HIGHLIGHTED_CHANGED_EVENT, this.highlightMenu);
				this.scaleX = .20;
				this.scaleY = .20;
				
				// root menus have an optional target bitmap
				_modelContextMenuRef.addEventListener(ModelContextMenu.BITMAP_CHANGED_EVENT, this.updateBitmap);
				_modelContextMenuRef.addEventListener(ModelContextMenu.BITMAP_DISPLAYED_CHANGED_EVENT, this.showBitmap);
			}
			
			// create item views
			this.updateItems(null);
		}
		
		
		public function Done(): void
		{
			if (ViewContextMenu.sDisplayLayer)
			{
				ViewContextMenu.sDisplayLayer.removeChild(this);
			}
			else
			{
				throw new Error("ViewContextMenu.sDisplayLayer has not been set.");
			}
			
			// clean up event listeners
			_modelContextMenuRef.removeEventListener(ModelContextMenu.ITEMS_CHANGED_EVENT, this.updateItems);
			_modelContextMenuRef.removeEventListener(ModelContextMenu.OPEN_CHANGED_EVENT, this.displayMenu);
			_modelContextMenuRef.removeEventListener(ModelContextMenu.ENABLED_CHANGED_EVENT, this.enableMenu);
			if (_modelContextMenuRef.isRoot)
			{
				_modelContextMenuRef.removeEventListener(ModelContextMenu.POSITION_CHANGED_EVENT, this.updatePosition);
				_modelContextMenuRef.removeEventListener(ModelContextMenu.HIGHLIGHTED_CHANGED_EVENT,
					this.highlightMenu);
				_modelContextMenuRef.removeEventListener(ModelContextMenu.BITMAP_CHANGED_EVENT, this.updateBitmap);
				_modelContextMenuRef.removeEventListener(ModelContextMenu.BITMAP_DISPLAYED_CHANGED_EVENT,
					this.showBitmap);
			}
		}
		
		
		///// Accessors / Mutators /////
		
		
		///// Public Interface /////
		
		protected function AdjustStagePosition(): void
		{
			if (_modelContextMenuRef.isRoot)
			{
				// temporarily set scale of items to zoomed size for proper measurement
				for (var i: uint = 0; i < _items.length; i++)
				{
					_items[i].PrepareForMeasure(true);
				}
				
				if (_modelContextMenuRef.mirrorOnMeasure)
				{
					// reset to right side layout - this triggers a view update before calculating
					_modelContextMenuRef.menuAlignHorizontal = ModelContextMenuItem.RIGHT;
				}
				
				// determine position of TL edge of content
				var bounds: Rectangle = this.getBounds(this);
				var xPosTrans: Number = this.x + bounds.x;
				var yPosTrans: Number = this.y + bounds.y;
				var positionInLayer: Point = new Point(xPosTrans, yPosTrans);
				var positionOnStage: Point = this.parent.localToGlobal(positionInLayer);
				
				if (_modelContextMenuRef.mirrorOnMeasure)
				{
					// test if context menu runs off right side of screen and should be mirrored left
					if (positionOnStage.x + this.width > this.stage.stageWidth)
					{
						_modelContextMenuRef.menuAlignHorizontal = ModelContextMenuItem.LEFT;
					}
/*					else
					{
						_modelContextMenuRef.menuAlignHorizontal = ModelContextMenuItem.RIGHT;
					}  */
				}
				else
				{
					var xPos: Number = this.x;
					var yPos: Number = this.y;
					var positionChanged: Boolean = false;
					
					if (positionOnStage.x < 0)
					{
						xPos += 0 - positionOnStage.x;
						positionChanged = true;
					}
					else if ((positionOnStage.x + this.width) > this.stage.stageWidth)
					{
						xPos -= (positionOnStage.x + this.width) - this.stage.stageWidth;
						positionChanged = true;
					}
					
					if (positionOnStage.y < 0)
					{
						yPos += 0 - positionOnStage.y;
						positionChanged = true;
					}
					else if ((positionOnStage.y + this.height) > this.stage.stageHeight)
					{
						yPos -= (positionOnStage.y + this.height) - this.stage.stageHeight;
						positionChanged = true;
					}
					
					if (positionChanged)
					{
						// change position of root menu in model
						_modelContextMenuRef.position = new Point(xPos, yPos);
						
						if (_modelContextMenuRef.isRoot)
						{
							// display bitmap rendering of target since we are no longer centered on target
							this.targetSnapshot.visible = true;
						}
					}
				}
				
				// restore scale of items to previous size
				for (i = 0; i < _items.length; i++)
				{
					_items[i].PrepareForMeasure(false);
				}
			}
			else
			{
				// prop to parent menu (ViewContextMenuItem->Sprite->ViewContextMenu)
				ViewContextMenu(this.parent.parent.parent).AdjustStagePosition();
			}
		}
		
		
		public function PrepareForMeasure(state: Boolean): void
		{
			for (var i: uint = 0; i < _items.length; i++)
			{
				_items[i].PrepareForMeasure(state);
			}
		}
		
				
		///// Model Notifications /////
		
		protected function updateItems(e: Event): void
		{
			this.updateViews();
			
			// position items
			if (_items.length > 0)
			{
				var radiansPerItem: Number = (360 / _items.length) * Math.PI / 180;
				var radians: Number = 0;
				var tempItem: ViewContextMenuItem;
				
				for (var i: uint = 0; i < _items.length; i++)
				{
					tempItem = _items[i];
					
					// calculate item position
					tempItem.x = PIE_RADIUS * Math.cos(radians);
					tempItem.y = PIE_RADIUS * Math.sin(radians);
					
					// position item text
					tempItem.modelContextMenuItemRef.PositionChildren(radians, ITEM_TEXT_RADIUS);
					
					radians += radiansPerItem;
				}
			}
		}
		
		
		protected function displayMenu(e: Event): void
		{
			if (_modelContextMenuRef.isOpen)
			{
				TweenLite.to(this, .6, {alpha: 1, scaleX: (1 * _maxScale), scaleY: (1 * _maxScale),
					ease: Bounce.easeOut, onComplete: this.showItems});
			}
			else
			{
				if (_modelContextMenuRef.isRoot)
				{
					TweenLite.to(this, .6, {alpha: 0, scaleX: (.2 * _maxScale), scaleY: (.2 * _maxScale),
						ease: Bounce.easeOut});
				}
				else
				{
					TweenLite.to(this, .6, {alpha: 0, scaleX: (.4 * _maxScale), scaleY: (.4 * _maxScale),
						ease: Bounce.easeOut});
				}
				
				this.items.visible = false;
				if (this.targetSnapshot)
				{
					this.targetSnapshot.visible = false;
				}
			}
		}
		
		
		protected function highlightMenu(e: Event): void
		{
			if (! _modelContextMenuRef.isOpen)
			{
				if (_modelContextMenuRef.isHighlighted)
				{
					TweenLite.to(this, .4, {alpha: 1, scaleX: (.4 * _maxScale), scaleY: (.4 * _maxScale),
						ease: Bounce.easeOut});
				}
				else
				{
					TweenLite.to(this, .4, {alpha: 0, scaleX: (.2 * _maxScale), scaleY: (.2 * _maxScale),
						ease: Bounce.easeOut});
				}
			}
		}
		
		
		protected function updateBitmap(e: Event): void
		{
			// cleanup old bitmap
			if (this.targetSnapshot.image.numChildren > 0)
			{
				this.targetSnapshot.image.removeChildAt(0);
			}
			
			if (_modelContextMenuRef.targetBitmap)
			{
				var newBitmap: Bitmap = _modelContextMenuRef.targetBitmap;
				this.targetSnapshot.image.addChild(newBitmap);
				newBitmap.x = 0 - newBitmap.width / 2;
				newBitmap.y = 0 - newBitmap.height / 2;
			}
		}
		
		
		protected function showBitmap(e: Event): void
		{
			this.targetSnapshot.visible = _modelContextMenuRef.targetBitmapDisplayed;
		}
		
		
		protected function enableMenu(e: Event): void
		{
			// display proper background
			this.backgroundEnabled.visible = _modelContextMenuRef.isEnabled;
			this.backgroundDisabled.visible = ! _modelContextMenuRef.isEnabled;
		}
		
		
		private function updatePosition(e: Event): void
		{
			this.x = _modelContextMenuRef.position.x;
			this.y = _modelContextMenuRef.position.y;
		}
		
		
		///// UI Events /////
		
		
		///// Helper Methods /////
		
		protected function initClips(): void
		{
			this.mouseEnabled = false;
			this.backgroundEnabled.mouseEnabled = false;
			this.backgroundDisabled.mouseEnabled = false;
			
			this.backgroundDisabled.visible = false;
			this.items.visible = false;
			this.targetSnapshot.visible = false;
			
			this.alpha = 0;
			this.scaleX = .40;
			this.scaleY = .40;
		}
		
		
		protected function updateViews(): void
		{
			var i: uint;
			var tempItem: ViewContextMenuItem;
			
			if (_items)
			{
				// cleanup item views
				for (i = 0; i < _items.length; i++)
				{
					tempItem = _items[i];
					this.items.removeChild(tempItem);
					tempItem.Done();
				}
			}
			
			_items = new Array();
			
			// create item views
			var itemsList: Array = _modelContextMenuRef.items;
			var modelContextMenuItem: ModelContextMenuItem;
			
			for (i = 0; i < itemsList.length; i++)
			{
				modelContextMenuItem = itemsList[i];
				
				tempItem = new ViewContextMenuItem();
				tempItem.Init(modelContextMenuItem, (this is ViewContextMenuList));
				this.items.addChild(tempItem);
				
				_items.push(tempItem);
			}
		}
		
		
		protected function showItems(): void
		{
			// menu has been opened
			this.items.visible = true;
			
			// make sure menu is fully on screen
			this.AdjustStagePosition();
		}
	}
}
