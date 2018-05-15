/* ==============================================================================================================

NAME: BaseView

AUTHOR: AJ Canepa
DATE  : 4/11/2012

COMMENT: The base view class for all view classes used with contextual menus.

This class inherits from Sprite because we never want a view class to be a MovieClip.  When a MovieClip is needed,
it's best to use a child of the Sprite based view so as to avoid issues with timeline ActionScript when using a
linked view class as a FLAs document class.

============================================================================================================== */

package com.runtimelogic.ui.contextmenu
{
	import flash.display.Sprite;
	

	public class BaseView extends Sprite
	{
		protected var _controllerRef: Controller;
		
		
		public function BaseView()
		{
			super();
			
			_controllerRef = Controller.instance;
		}
	}
}

