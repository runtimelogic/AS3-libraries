/* ==============================================================================================================

NAME: ViewContextMenuList

AUTHOR: AJ Canepa
DATE  : 4/11/2012

COMMENT: The view class for rending a linear list context menu.  Clicking an item within the menu triggers an
action as determined by the model for the menu item.

The list is rendered from an instance of a ModelContextMenuList subclass.  ModelContextMenuList contains a list
of items and sends a notification on list change.  The subclass is an adaptor to a specific set of model data
in the project domain, and listens for changes to that data to update its list of ModelContextMenuItemLeaf
instances.

VIEW TYPE: Linked - contextMenu.fla / Dynamic

============================================================================================================== */

package com.runtimelogic.ui.contextmenu
{
	import com.greensock.TweenLite;
	
	import fl.transitions.easing.Bounce;
	import fl.transitions.easing.Regular;
	
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextField;
	
	
	public class ViewContextMenuList extends ViewContextMenu
	{
		// instance members
		public var buttonUp: SimpleButton;
		public var buttonDown: SimpleButton;
		public var circleUp: Sprite;
		public var circleDown: Sprite;
		public var itemMask: Sprite;
		public var panel: MovieClip;
		public var t_scrollIndex:TextField;
		
		protected var _modelContextMenuListRef: ModelContextMenuList;  // convenience memeber
		
		private var _scrollIndex: int = 0;
		private var _YLoc: int;
		private var _itemsDepth: int;
		
		
		public static var ITEMS_PER_PAGE: uint = 3;
		public static var ITEM_SPACING: uint = 50;
		public static var PANEL_LOCATION_X: int = 50;
		public static var PANEL_LOCATION_Y: int = -80;
		public static var PANEL_WIDTH: int = 240;
		public static var PANEL_HEIGHT: int = 160;
		public static var ITEM_OFFSET: int = 31;  // this number is less than the distance to the registration point
												// of the item because it includes a compound offset to align the
												// items visually with the list panel
		
		
		public function ViewContextMenuList()
		{
			super();
		}
		
		
		override public function Init(modelContextMenuRef: ModelContextMenu, maxScale: Number = 1): void
		{
			super.Init(modelContextMenuRef, maxScale);
			
			_modelContextMenuListRef = ModelContextMenuList(modelContextMenuRef);
			
			// UI event listeners
			this.buttonUp.addEventListener(MouseEvent.CLICK, this.upClicked);
			this.buttonDown.addEventListener(MouseEvent.CLICK, this.downClicked);
			
			// register for Model notifications
			_modelContextMenuListRef.addEventListener(ModelContextMenu.MENU_ALIGN_CHANGED_EVENT, this.alignMenu);
			this.alignMenu(null);
		}
		
		
		override public function Done(): void
		{
			// clean up event listeners
			_modelContextMenuListRef.removeEventListener(ModelContextMenu.MENU_ALIGN_CHANGED_EVENT, this.alignMenu);
			
			super.Done();
		}
		
		
		///// Accessors / Mutators /////
		
		
		///// Public Interface /////
		
		override public function PrepareForMeasure(state: Boolean): void
		{
			if (state)
			{
				// temporarily remove items from view since getBounds doesn't pay attention to masks and the returned
				// size will be incorrect
				_itemsDepth = this.getChildIndex(this.items);
				this.removeChild(this.items);
			}
			else
			{
				this.addChildAt(this.items, _itemsDepth);
			}
		}
		
		
		///// Model Notifications /////
		
		override protected function updateItems(e: Event): void
		{
			this.updateViews();
			
			// reset scroll position
			_scrollIndex = 0;
			
			changeButton(buttonUp, false);
			changeButton(buttonDown, true);
			
			this.positionItems();
			
			// position items
			var tempItem: ViewContextMenuItem2;
			var yPos: uint = 0;
			
			for (var i: uint = 0; i < _items.length; i++)
			{
				tempItem = _items[i];
				tempItem.y = yPos;
				
				yPos += ITEM_SPACING;
			}
		}
		
		override protected function updateViews(): void
		{
			var i: uint;
			var tempItem: ViewContextMenuItem2;
			
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
				
				tempItem = new ViewContextMenuItem2();
				tempItem.Init(modelContextMenuItem, (this is ViewContextMenuList));
				this.items.addChild(tempItem);
				
				_items.push(tempItem);
			}
		}
		
		
		override protected function displayMenu(e: Event): void
		{
			if (_modelContextMenuRef.isOpen)
			{
				TweenLite.to(this, .6, {alpha: 1, scaleX: 1, scaleY: 1, ease: Bounce.easeOut,
					onComplete: this.showItems});
			}
			else
			{
				TweenLite.to(this, .6, {alpha: 0, scaleX: .6, scaleY: .6, ease: Bounce.easeOut});
			}
		}
		
		
		override protected function enableMenu(e: Event): void
		{
			// unused but we don't want parent behavior
		}
		
		
		protected function alignMenu(e: Event): void
		{
			// configure position based on list menu orientation
			if (_modelContextMenuListRef.menuAlignHorizontal == ModelContextMenuItem.LEFT)
			{
				this.panel.scaleX = 1;
				this.items.x = PANEL_LOCATION_X + ITEM_OFFSET;
				this.itemMask.x = PANEL_LOCATION_X;
			}
			else
			{
				this.panel.scaleX = -1;
				this.items.x = 0 - PANEL_LOCATION_X - PANEL_WIDTH - 2 + ITEM_OFFSET;
				this.itemMask.x = 0 - PANEL_LOCATION_X - PANEL_WIDTH - 2;
				
				// flip buttons horizontally
				this.buttonUp.scaleX = -1;
				this.buttonDown.scaleX = -1;
				this.circleUp.scaleX = -1;
				this.circleDown.scaleX = -1;
			}
		}
		
		
		///// UI Events /////
		
		private function upClicked(e: MouseEvent): void
		{
			if (_items.length > ITEMS_PER_PAGE)
			{
				_scrollIndex -= ITEMS_PER_PAGE;
				
				if (_scrollIndex < 0)
				{
					_scrollIndex = 0;
					
					changeButton(buttonUp, false);
					changeButton(buttonDown, true);
				}
				this.positionItems();
			}
		}
		
		
		private function downClicked(e: MouseEvent): void
		{
			if (_items.length > ITEMS_PER_PAGE)
			{
				_scrollIndex += ITEMS_PER_PAGE;
				
				if (_scrollIndex > _items.length - ITEMS_PER_PAGE)
				{
					_scrollIndex = _items.length - ITEMS_PER_PAGE;

					changeButton(buttonUp,true);
					changeButton(buttonDown,false);
				}
				this.positionItems();
			}
		}
		
		
		///// Helper Methods /////
		
		override protected function initClips(): void
		{
			this.alpha = 0;
			this.scaleX = .60;
			this.scaleY = .60;
		}
		
		
		private function positionItems(): void
		{
			_YLoc = PANEL_LOCATION_Y + ITEM_OFFSET - (ITEM_SPACING * _scrollIndex);
			TweenLite.to(this.items, .6, {y: _YLoc, ease: Regular.easeInOut});
		}
		
		
		private function changeButton(btn:SimpleButton,enable:Boolean): void
		{
			if (!enable){
				var matrix:Array = new Array();
                matrix = matrix.concat([0.33, 0.33, 0.33, 0, 0]);
                matrix = matrix.concat([0.33, 0.33, 0.33, 0, 0]);
                matrix = matrix.concat([0.33, 0.33, 0.33, 0, 0]);
                matrix = matrix.concat([0, 0, 0, 1, 0]);
		        var myFilter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
				btn.filters = [myFilter];
				btn.enabled=false;
			}else{
				btn.filters = [];
				btn.enabled=true;
			}
		}
	}
}
