/* ======================================================================

NAME: Line

AUTHOR: AJ Canepa
DATE  : 1/18/2012

COMMENT: Model class to represent a point / slope line and provide methods
for calculations.

========================================================================= */

package com.runtimelogic.geom
{
	import flash.geom.Point;
	
	
	public class Line
	{
		protected var _point: Point;
		protected var _slope: Number;
		
		// reused variables for fast calculations
		private var _intersection: Point = new Point();
		private var _pointB: Point;
		private var _slopeB: Number;
		
		public function Line(x: Number, y: Number, slope: Number)
		{
			_point = new Point(x, y);
			_slope = slope;
		}
		
		
		///// Accessors / Mutators /////
		
		public function get point(): Point								{ return _point; }
		public function set point(val: Point): void						{ _point = val; }
		
		public function get slope(): Number								{ return _slope; }
		public function set slope(val: Number): void					{ _slope = val; }
		
		
		///// Public Interface /////
		
		public function CalcLineIntersection(lineB: Line): Point
		{
			// store references for speed
			_pointB = lineB.point;
			_slopeB = lineB.slope;
			
			if (_slope == _slopeB)
			{
				return null;
			}
			else
			{
				_intersection.x = (_pointB.y + (_slope * _point.x) - _point.y - (_slopeB * _pointB.x)) /
					(_slope - _slopeB);
				_intersection.y = _slope * (_intersection.x - _point.x) + _point.y;
			}
			
			return _intersection;
		}		
		
		
		public function DistanceToLineIntersection(lineB: Line): Number
		{
			this.CalcLineIntersection(lineB);
			
			return Point.distance(_intersection, lineB.point);
		}
		
		
		///// Helper Methods /////
	}
}

