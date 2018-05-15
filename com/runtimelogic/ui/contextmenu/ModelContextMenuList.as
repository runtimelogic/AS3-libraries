/* ==============================================================================================================

NAME: ModelContextMenuList

AUTHOR: AJ Canepa
DATE  : 4/19/2012

COMMENT: The model class representing a contextual menu list.  This class inherits from ModelContextMenu and
derives its list of items and list change notifications from it.  This class provides a mechanism to create
ModelContextMenuItemLeaf instances from a generic set of model data and update them when the model data changes.
The class of the model data list elements must implement IContextMenuListElement so that this class can create
corresponding ModelContextMenuItemLeaf instances.

============================================================================================================== */

package com.runtimelogic.ui.contextmenu
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	
	public class ModelContextMenuList extends ModelContextMenu
	{
		private var _modelDataProvider: EventDispatcher;
		private var _dataChangeEventType: String;
		private var _modelDataAccessor: Function;
		private var _actionData: Object;  // the instance to provide to all ModelContextMenuItemLeaf instances
		
		
		public function ModelContextMenuList(menuConfig: Object = null, parent: ModelContextMenu = null)
		{
			super(menuConfig, parent);
		}
		
		
		public function Done(): void
		{
			_modelDataProvider.removeEventListener(_dataChangeEventType, this.updateItems);
		}
		
		
		///// Accessors / Mutators /////
		
				
		///// Public Interface /////
		
		
		///// Model Notifications /////
		
		private function updateItems(e: Event): void
		{
			// create item models from model data provider
			_items = new Array();
			
			var modelContextMenuItemLeaf: ModelContextMenuItemLeaf;
			var items: Array = _modelDataAccessor();
			var element: IContextMenuListElement;
			
			for (var i: uint = 0; i < items.length; i++)
			{
				element = items[i];
				
				modelContextMenuItemLeaf = new ModelContextMenuItemLeaf(element.contextMenuItemName,
					element.contextMenuItemIconPath, _actionData, element.contextMenuItemID);
				
				_items.push(modelContextMenuItemLeaf);
			}
			
			// notify of change
			this.dispatchEvent(new Event(ModelContextMenu.ITEMS_CHANGED_EVENT));
		}
		
		
		///// Helper Methods /////
		
		override protected function createMenuFromConfig(menuConfig: Object): void
		{
			// use optional menu config object to configure contextual menu list
			// Ex. {modelDataProvider: aModelInstance, dataChangeEventType: ModelInventory.ITEMS_ADDED_EVENT,
			//	modelDataAccessor: aModelInstance.anAccessorMethod, actionData: anActionInstance}
			_modelDataProvider = menuConfig.modelDataProvider;
			_dataChangeEventType = menuConfig.dataChangeEventType;
			_modelDataAccessor = menuConfig.modelDataAccessor;
			_actionData = menuConfig.actionData;
			
			// register for Model notifications
			_modelDataProvider.addEventListener(_dataChangeEventType, this.updateItems);
			
			// create the initial items
			this.updateItems(null);
		}
	}
}

