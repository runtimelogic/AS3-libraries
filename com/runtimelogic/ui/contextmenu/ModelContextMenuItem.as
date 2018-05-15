/* ==============================================================================================================

NAME: ModelContextMenuItem

AUTHOR: AJ Canepa
DATE  : 4/12/2012

COMMENT: Model class used to represent an interactive item that is part of a context menu.

============================================================================================================== */

package com.runtimelogic.ui.contextmenu
{
	import flash.events.Event;
	
	
	public class ModelContextMenuItem extends ModelMenuItem
	{
		protected var _isEnabled: Boolean = true;
		
		protected var _textAlignHorizontal: uint = LEFT;
		protected var _textAlignVertical: uint = TOP;
		protected var _radians: Number = 0;
		protected var _textPosX: Number;
		protected var _textPosY: Number;
		
		
		public static const TOP: uint = 0;
		public static const LEFT: uint = 0;
		public static const MIDDLE: uint = 1;
		public static const BOTTOM: uint = 2;
		public static const RIGHT: uint = 2;
		
		public static const ENABLED_CHANGED_EVENT: String = "ENABLED_CHANGED_EVENT";
		public static const TEXT_ALIGN_CHANGED_EVENT: String = "TEXT_ALIGN_CHANGED_EVENT";
		
		
		public function ModelContextMenuItem(name: String, iconPath: String)
		{
			super(name, iconPath);
		}
		
		
		///// Accessors / Mutators /////
		
		public function get isEnabled(): Boolean								{ return _isEnabled; }
		public function set isEnabled(val: Boolean): void
		{
			_isEnabled = val;
			this.dispatchEvent(new Event(ENABLED_CHANGED_EVENT));
		}
		
		public function get textAlignHorizontal(): uint							{ return _textAlignHorizontal; }
		
		public function get textAlignVertical(): uint							{ return _textAlignVertical; }
		
		public function setTextAlign(textAlignHorizontal: uint, textAlignVertical: uint): void
		{
			_textAlignHorizontal = textAlignHorizontal;
			_textAlignVertical = textAlignVertical;
			this.dispatchEvent(new Event(TEXT_ALIGN_CHANGED_EVENT));
		}
		
		public function get textPosX(): Number									{ return _textPosX; }
		
		public function get textPosY(): Number									{ return _textPosY; }
		
		
		///// Public Interface /////
		
		public function PositionChildren(radians: Number, distance: Number): void
		{
			// determine position of the attachment point for the text based on the provided distance from the center
			_radians = radians;
			_textPosX = distance * Math.cos(_radians);
			_textPosY = distance * Math.sin(_radians);
			
			this.calculateTextAlign(_radians);
		}
		
		
		///// Helper Methods /////
		
		private function calculateTextAlign(radians: Number): void
		{
			// divide by circle perimeter to get range 0-1
			var facing: Number = radians / (2 * Math.PI);
			// divide into 8 slices rotated so there is 22.5 degress on either side
			var facingIndex: uint = Math.round((facing + .125) * 8) - 1;
			// make sure bottom portion of angles for svl maps to proper facing
			if (facingIndex > 7) { facingIndex = 0; }
			
			switch (facingIndex)
			{
				case 0:  // svr
				{
					_textAlignHorizontal = LEFT;
					_textAlignVertical = MIDDLE;
				}
				break;
				case 1:  // fvr
				{
					_textAlignHorizontal = LEFT;
					_textAlignVertical = TOP;
				}
				break;
				case 2:  // fv
				{
					_textAlignHorizontal = MIDDLE;
					_textAlignVertical = TOP;
				}
				break;
				case 3:  // fvl
				{
					_textAlignHorizontal = RIGHT;
					_textAlignVertical = TOP;
				}
				break;
				case 4:  // svl
				{
					_textAlignHorizontal = RIGHT;
					_textAlignVertical = MIDDLE;
				}
				break;
				case 5:  // bvl
				{
					_textAlignHorizontal = RIGHT;
					_textAlignVertical = BOTTOM;
				}
				break;
				case 6:  // bv
				{
					_textAlignHorizontal = MIDDLE;
					_textAlignVertical = BOTTOM;
				}
				break;
				case 7:  // bvr
				{
					_textAlignHorizontal = LEFT;
					_textAlignVertical = BOTTOM;
				}
				break;
			}
			
			this.dispatchEvent(new Event(TEXT_ALIGN_CHANGED_EVENT));
		}
		
	}
}

