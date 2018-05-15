/* ==============================================================================================================

NAME: IContextMenuListElement

AUTHOR: AJ Canepa
DATE  : 4/19/2012

COMMENT: The interface that model data elements must implement to be used as elements of a data provider with
a ModelContextMenuList instance.

============================================================================================================== */

package com.runtimelogic.ui.contextmenu
{
	public interface IContextMenuListElement
	{
		function get contextMenuItemName(): String;  // the name to display in the menu item
		function get contextMenuItemIconPath(): String;  // path to the icon to display in the menu item
		function get contextMenuItemID(): uint;  // ID of the model element to provide when the context menu item
												 // is activated
	}
}