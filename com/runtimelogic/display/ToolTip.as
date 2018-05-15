/* ======================================================================

NAME: ToolTip

AUTHOR: AJ Canepa
DATE  : 5/17/2010

COMMENT: A simple class to display a tooltip.  It gets passed a string to display
and a reference to a DisplayObject that it should listen to for mouse events.

The class must be statically configured by setting the display layer that the
tool tips will be attached to for display before creating any.

VIEW TYPE: Dynamic

========================================================================= */

package com.runtimelogic.display
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	
	public class ToolTip extends Sprite
	{
		// static configuration of the display layer for tooltips
		public static var sDisplayLayer: DisplayObjectContainer = null;
		
		private var _enabled: Boolean = false;
		private var _attachedControl: DisplayObject;
		private var _background: Sprite;
		private var _label: TextField;
		private var _placement: uint;
		private var _hoverTimer: Timer;
		
		// this block of constants can be modified to configure tooltip behavior globally
		private static const BORDER_SIZE_HORIZONTAL: uint = 8;  // size of border from text to the edge of the tooltip
		private static const BORDER_SIZE_VERTICAL: uint = 4;
		private static const CORNER_ROUNDING: uint = 6;  // corner radius in pixels
		private static const SPACING: uint = 6;  // spacing between tooltip and control (must be > 0)
		private static const HOVER_DELAY: uint = 300;  // time in milliseconds to delay before displaying tooltip
		
		private static const BORDER_PIXELS_HORIZONTAL: uint = BORDER_SIZE_HORIZONTAL * 2;
		private static const BORDER_PIXELS_VERTICAL: uint = BORDER_SIZE_VERTICAL * 2;
		
		
		public static var TOOLTIP_SCALE: Number = 1;
		
		public static const PLACEMENT_TOP: uint = 0;
		public static const PLACEMENT_LEFT: uint = 1;
		public static const PLACEMENT_RIGHT: uint = 2;
		public static const PLACEMENT_BOTTOM: uint = 3;
		
		
		public function ToolTip(attachedControl: DisplayObject, toolTipLabel: String, placement: uint = PLACEMENT_TOP)
		{
			super();
			
			_attachedControl = attachedControl;
			_placement = placement;
			
			this.scaleX = TOOLTIP_SCALE;
			this.scaleY = TOOLTIP_SCALE;
			
			// create background layer
			_background = new Sprite();
			this.addChild(_background);
			
			// create label TextField
			_label = new TextField();
			_label.x = BORDER_SIZE_HORIZONTAL;
			_label.y = BORDER_SIZE_VERTICAL;
			_label.autoSize = TextFieldAutoSize.LEFT;
			_label.multiline = true;
			this.addChild(_label);
			
			// modify TextFormat
			var labelFormat: TextFormat = new TextFormat();
			labelFormat.font = "Arial";
			labelFormat.size = 14;
			_label.defaultTextFormat = labelFormat;
			
			// init display state
			this.visible = false;
			this.toolTipLabel = toolTipLabel;
			this.enabled = true;
			
			// attach to display layer
			if (ToolTip.sDisplayLayer)
			{
				ToolTip.sDisplayLayer.addChild(this);
			}
			else
			{
				throw new Error("ToolTip.sDisplayLayer has not been set.");
			}
			
			// create hover timer
			_hoverTimer = new Timer(HOVER_DELAY, 1);
			_hoverTimer.addEventListener(TimerEvent.TIMER, this.displayToolTip);
		}
		
		
		public function Done(): void
		{
			if (ToolTip.sDisplayLayer)
			{
				if (ToolTip.sDisplayLayer.contains(this))
				{
					ToolTip.sDisplayLayer.removeChild(this);
				}
			}
			else
			{
				throw new Error("ToolTip.sDisplayLayer has not been set.");
			}
			
			this.enabled = false;
			_attachedControl = null;
		}
		
		
		///// Accessors / Mutators /////
		
		public function get enabled(): Boolean									{ return _enabled; }
		public function set enabled(val: Boolean): void
		{
			if (_enabled == val)
			{
				// enabled state is not changing
				return;
			}
			
			_enabled = val;
			
			if (_enabled)
			{
				// add mouse handlers
				_attachedControl.addEventListener(MouseEvent.ROLL_OVER, this.rollOver);
				_attachedControl.addEventListener(MouseEvent.ROLL_OUT, this.rollOut);	
			}
			else
			{
				// remove mouse handlers
				_attachedControl.removeEventListener(MouseEvent.ROLL_OVER, this.rollOver);
				_attachedControl.removeEventListener(MouseEvent.ROLL_OUT, this.rollOut);	
				this.visible = false;
			}
		}
		
		public function get toolTipLabel(): String								{ return _label.text; }
		public function set toolTipLabel(val: String): void
		{
			_label.text = val;
			
			// draw background
			_background.graphics.beginFill(0xFFCC00);
			_background.graphics.drawRoundRect(0, 0, _label.width + BORDER_PIXELS_HORIZONTAL,
				_label.height + BORDER_PIXELS_VERTICAL, CORNER_ROUNDING);
			_background.graphics.endFill();
			
			// calculate initial position of tooltip
			this.UpdatePosition();
		}
		
		
		///// Public Interface /////
		
		public function UpdatePosition(): void
		{
			// determine true TL point of attached control and its content
			var attachedControlBounds: Rectangle = _attachedControl.getBounds(_attachedControl.parent);
			
			// translate TL point to coordinates of the tooltip display layer
			var attachedControlPosition: Point = new Point(attachedControlBounds.x, attachedControlBounds.y)
			var stagePosition: Point = _attachedControl.parent.localToGlobal(attachedControlPosition);
			var localPosition: Point = ToolTip.sDisplayLayer.globalToLocal(stagePosition);
			
			// position tooltip relative to controlling clip
			switch (_placement)
			{
				case PLACEMENT_TOP:
				{
					// horizontally align centers
					this.x = localPosition.x + (_attachedControl.width / 2) - (this.width / 2);
					this.y = localPosition.y - this.height - SPACING;  // above
				}
				break;
				case PLACEMENT_BOTTOM:
				{
					// horizontally align centers
					this.x = localPosition.x + (_attachedControl.width / 2) - (this.width / 2);
					this.y = localPosition.y + _attachedControl.height + SPACING;  // below
				}
				break;
				case PLACEMENT_LEFT:
				{
					// vertically align centers
					this.y = localPosition.y + (_attachedControl.height / 2) - (this.height / 2);
					this.x = localPosition.x - this.width - SPACING;  // to the left
				}
				break;
				case PLACEMENT_RIGHT:
				{
					// vertically align centers
					this.y = localPosition.y + (_attachedControl.height / 2) - (this.height / 2);
					this.x = localPosition.x + _attachedControl.width + SPACING;  // to the right
				}
				break;
			}
		}
		
		
		//// UI Events ////
		
		private function rollOver(e: MouseEvent): void
		{
			_hoverTimer.start();
		}
		
		
		private function rollOut(e: MouseEvent): void
		{
			_hoverTimer.reset();
			this.visible = false;
		}
		
		
		private function displayToolTip(e: Event): void
		{
			_hoverTimer.reset();
			this.visible = true;
		}
		
		
		///// Helper Methods /////
		
	}
}