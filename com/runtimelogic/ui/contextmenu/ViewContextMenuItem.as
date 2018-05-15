/* ==============================================================================================================

NAME: ViewContextMenuItem

AUTHOR: AJ Canepa
DATE  : 4/11/2012

COMMENT: The view class for rending an item within a context menu.  Clicking an item within the menu
(VewContextMenuItem) either displays a submenu (an instance of ViewContextMenu or ViewContextMenuList), or
triggers an action as determined by the model for the menu item.

VIEW TYPE: Linked - contextMenu.fla / Dynamic

============================================================================================================== */

package com.runtimelogic.ui.contextmenu
{
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import fl.transitions.easing.Bounce;
	
	import com.util.assetManager.AssetManager;
	import com.greensock.TweenLite;
	
	
	public class ViewContextMenuItem extends BaseView
	{
		// instance members
		public var icon: Sprite;
		public var buttonActivate: SimpleButton;
		public var nameText: TextField;
		public var nameBackground: Sprite;
		public var connector: Sprite;
		
		protected var _modelContextMenuItemRef: ModelContextMenuItem;
		protected var _alwaysDisplayName: Boolean;
		
		private var _submenu: ViewContextMenu;
		
		
		public function ViewContextMenuItem()
		{
			super();
			
			this.nameText.autoSize = TextFieldAutoSize.LEFT;
		}
		
		
		public function Init(modelContextMenuItemRef: ModelContextMenuItem, alwaysDisplayName: Boolean = false): void
		{
			_modelContextMenuItemRef = modelContextMenuItemRef;
			_alwaysDisplayName = alwaysDisplayName;
			
			// init name display
			this.nameText.text = _modelContextMenuItemRef.name;
			this.nameBackground.width = this.nameText.width + (ViewContextMenu.ITEM_TEXT_SPACING_H * 2);
			if (! _alwaysDisplayName)
			{
				this.nameText.visible = false;
				this.nameBackground.visible = false;
			}
			this.connector.visible = false;
			
			this.scaleX = .8;
			this.scaleY = .8;
			
			// load icon from path provided in model
			AssetManager.loadFile(_modelContextMenuItemRef.iconPath, this.iconLoaded);
			
			// UI event listeners
			this.buttonActivate.addEventListener(MouseEvent.CLICK, this.activateClicked);
			this.buttonActivate.addEventListener(MouseEvent.MOUSE_OVER, this.zoomIn);
			this.buttonActivate.addEventListener(MouseEvent.MOUSE_OUT, this.zoomOut);
			
			// register for Model notifications
			_modelContextMenuItemRef.addEventListener(ModelContextMenuItem.ENABLED_CHANGED_EVENT, this.enableItem);
			_modelContextMenuItemRef.addEventListener(ModelContextMenuItem.TEXT_ALIGN_CHANGED_EVENT,
				this.positionText);
			
			if (_modelContextMenuItemRef is ModelContextMenuItemNode)
			{
				// register for Model notifications
				_modelContextMenuItemRef.addEventListener(ModelContextMenuItemNode.SUBMENU_STATE_CHANGED_EVENT,
					this.updateSubmenuState);
				
				// create the submenu view
				if (ModelContextMenuItemNode(_modelContextMenuItemRef).submenu is ModelContextMenuList)
				{
					_submenu = new ViewContextMenuList();
				}
				else
				{
					_submenu = new ViewContextMenu();
				}
				_submenu.Init(ModelContextMenuItemNode(_modelContextMenuItemRef).submenu);
				this.addChild(_submenu);
			}
		}
		
		
		public function Done(): void
		{
			this.buttonActivate.removeEventListener(MouseEvent.CLICK, this.activateClicked);
			this.buttonActivate.removeEventListener(MouseEvent.MOUSE_OVER, this.zoomIn);
			this.buttonActivate.removeEventListener(MouseEvent.MOUSE_OUT, this.zoomOut);
			
			_modelContextMenuItemRef.removeEventListener(ModelContextMenuItem.ENABLED_CHANGED_EVENT, this.enableItem);
			_modelContextMenuItemRef.removeEventListener(ModelContextMenuItem.TEXT_ALIGN_CHANGED_EVENT,
				this.positionText);
			
			if (_modelContextMenuItemRef is ModelContextMenuItemNode)
			{
				_modelContextMenuItemRef.removeEventListener(ModelContextMenuItemNode.SUBMENU_STATE_CHANGED_EVENT,
					this.updateSubmenuState);
				
				// dispose the submenu view
				this.removeChild(_submenu);
				_submenu.Done();
			}
		}
		
		
		///// Accessors / Mutators /////
		
		public function get modelContextMenuItemRef(): ModelContextMenuItem		{ return _modelContextMenuItemRef; }
		
		
		///// Public Interface /////
		
		public function PrepareForMeasure(state: Boolean): void
		{
			if (state)
			{
				// we are measuring an item so set to full scale
				this.scaleX = 1;
				this.scaleY = 1;
			}
			else if (_modelContextMenuItemRef is ModelContextMenuItemNode &&
					ModelContextMenuItemNode(_modelContextMenuItemRef).submenuIsOpen)
			{
				// we are restoring an item that is open, so set to full scale
				this.scaleX = 1;
				this.scaleY = 1;
			}
			else
			{
				// this item is not open and measurement is done so restore to non-zoomed scale
				this.scaleX = .8;
				this.scaleY = .8;
			}
				
			if (_submenu)
			{
				// prop to submenu
				_submenu.PrepareForMeasure(state);
			}
		}
		
		
		///// Model Notifications /////
		
		private function updateSubmenuState(e: Event): void
		{
			// called if the item instance displays a submenu whenever the submenu is opened or closed
			if (ModelContextMenuItemNode(_modelContextMenuItemRef).submenuIsOpen)
			{
				// disable zoom while open
				this.buttonActivate.removeEventListener(MouseEvent.MOUSE_OVER, this.zoomIn);
				this.buttonActivate.removeEventListener(MouseEvent.MOUSE_OUT, this.zoomOut);
				this.scaleX = 1;
				this.scaleY = 1;
				// hide text
				this.nameText.visible = false;
				this.nameBackground.visible = false;
				this.connector.visible = false;
			}
			else
			{
				// enable zoom while closed
				this.buttonActivate.addEventListener(MouseEvent.MOUSE_OVER, this.zoomIn);
				this.buttonActivate.addEventListener(MouseEvent.MOUSE_OUT, this.zoomOut);
				TweenLite.to(this, .6, {scaleX: .8, scaleY: .8, ease: Bounce.easeOut});
			}
		}
		
		
		private function enableItem(e: Event): void
		{
			this.visible = _modelContextMenuItemRef.isEnabled;
		}
		
		
		private function positionText(e: Event): void
		{
			var xPos: Number = _modelContextMenuItemRef.textPosX;
			var yPos: Number = _modelContextMenuItemRef.textPosY;
			
			// display calculated attach point
			this.connector.x = xPos;
			this.connector.y = yPos;
			
			// position horizontally
			switch (_modelContextMenuItemRef.textAlignHorizontal)
			{
				case ModelContextMenuItem.LEFT:
				{
					// no-op
				}
				break;
				case ModelContextMenuItem.MIDDLE:
				{
					xPos -= this.nameBackground.width / 2;
				}
				break;
				case ModelContextMenuItem.RIGHT:
				{
					xPos -= this.nameBackground.width;
				}
				break;
			}
			
			// position vertically
			switch (_modelContextMenuItemRef.textAlignVertical)
			{
				case ModelContextMenuItem.TOP:
				{
					// no-op
				}
				break;
				case ModelContextMenuItem.MIDDLE:
				{
					yPos -= this.nameBackground.height / 2;
				}
				break;
				case ModelContextMenuItem.BOTTOM:
				{
					yPos -= this.nameBackground.height;
				}
				break;
			}
			
			this.nameBackground.x = xPos;
			this.nameBackground.y = yPos;
			this.nameText.x = xPos + ViewContextMenu.ITEM_TEXT_SPACING_H;
			this.nameText.y = yPos + ViewContextMenu.ITEM_TEXT_SPACING_V;
		}
		
		
		///// UI Events /////
		
		private function activateClicked(e: MouseEvent): void
		{
			e.stopPropagation();  // consume event at target
			_controllerRef.ActivateMenuItem(_modelContextMenuItemRef);
		}
		
		
		public function zoomIn(e: MouseEvent): void
		{
			TweenLite.to(this, .6, {scaleX: 1, scaleY: 1, ease: Bounce.easeOut});
			
			if (! _alwaysDisplayName)
			{
				this.nameText.visible = true;
				this.nameBackground.visible = true;
				this.connector.visible = true;
			}
		}
		
		
		public function zoomOut(e: MouseEvent): void
		{
			TweenLite.to(this, .6, {scaleX: .8, scaleY: .8, ease: Bounce.easeOut});
			
			if (! _alwaysDisplayName)
			{
				this.nameText.visible = false;
				this.nameBackground.visible = false;
				this.connector.visible = false;
			}
		}
		
		
		///// AssetManager callbacks /////
		
		protected function iconLoaded(icon: Sprite): void
		{
			this.icon.addChild(icon);
		}
		
		
		///// Helper Methods /////
		
	}
}
