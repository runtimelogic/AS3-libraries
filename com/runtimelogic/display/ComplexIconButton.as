/* ======================================================================

NAME: ComplexIconButton

AUTHOR: AJ Canepa
DATE  : 2/18/2013

COMMENT: A complex button that dynamically loads an icon on init.

VIEW TYPE: Linked (this class is linked to a loaded asset).

========================================================================= */

package com.runtimelogic.display
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import com.util.assetManager.AssetManager;
	
	
	public class ComplexIconButton extends ComplexButton
	{
		// instance members
		public var icon: Sprite;
		
		
		public function ComplexIconButton()
		{
			super();
		}
		
		
		override public function Done(): void
		{
			super.Done();
		}
		
		
		///// Accessors / Mutators /////
		
		
		///// Public Interface /////
		
		public function AddIcon(iconPath: String): void
		{
			// load icon
			AssetManager.loadFile(iconPath, this.iconLoaded);
		}
		
		
		//// UI Events ////
		
		
		///// AssetManager callbacks /////
		
		protected function iconLoaded(icon: DisplayObject): void
		{
			this.icon.addChild(icon);
		}
	}
}